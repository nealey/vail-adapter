#include <stddef.h>
#include "keyers.h"

#define len(t) (sizeof(t)/sizeof(*t))

// Queue Set: A Set you can shift and pop.
class QSet {
    int arr[MAX_KEYER_QUEUE];
    unsigned int arrlen = 0;

public:
    int shift() {
        if (arrlen == 0) {
            return -1;
        }
        int ret = arr[0];
        arrlen--;
        for (int i = 0; i < arrlen; i++) {
            arr[i] = arr[i+1];
        }
        return ret;
    }

    int pop() {
        if (arrlen == 0) {
            return -1;
        }
        int ret = arr[arrlen];
        arrlen--;
        return ret;
    }

    void add(int val) {
        if (arrlen == MAX_KEYER_QUEUE) {
            return;
        }
        for (int i = 0; i < arrlen; i++) {
            if (arr[i] == val) {
                return;
            }
        }
        arr[arrlen] = val;
        arrlen++;
    }
};


class StraightKeyer: public Keyer {
public:
    bool transmitting = false;
    unsigned int ditDuration = 100;
    bool txRelays[2];

    StraightKeyer() {
        this->Reset();
    }

    char *Name() {
      return "straight";
    }

    void SetDitDuration(unsigned int duration) {
        this->ditDuration = duration;
    }

    void Reset() {
        this->transmitting = false;
    }

    bool TxClosed() {
        for (int i = 0; i < len(this->txRelays); i++) {
            if (this->TxClosed(i)) {
                return true;
            }
        }
        return false;
    }

    bool TxClosed(int relay) {
        return this->txRelays[relay];
    }

    void Tx(int relay, bool closed) {
        bool wasClosed = this->TxClosed();
        this->txRelays[relay] = closed;
        this->transmitting = this->TxClosed();
    }

    void Key(Paddle key, bool pressed) {
        this->Tx(key, pressed);
    }

    bool Tick(unsigned long now) {
      return this->transmitting;
    }
};

class BugKeyer: public StraightKeyer {
public:
    unsigned int nextPulse = 0;
    bool keyPressed[2];

    using StraightKeyer::StraightKeyer;

    char *Name() {
      return "bug";
    }

    void Reset() {
        StraightKeyer::Reset();
        this->nextPulse = 0;
        this->keyPressed[0] = false;
        this->keyPressed[1] = false;
    }

    void Key(Paddle key, bool pressed) {
        this->keyPressed[key] = pressed;
        if (key == 0) {
            this->beginPulsing();
        } else {
            StraightKeyer::Key(key, pressed);
        }
    }

    bool Tick(unsigned long now) {
        if (this->nextPulse && (now >= this->nextPulse)) {
            this->pulse(now);
        }
        return this->transmitting;
    }

    void beginPulsing() {
        if (!this->nextPulse) {
            this->nextPulse = 1;
        }
    }

    virtual void pulse(unsigned int now) {
        if (this->TxClosed(0)) {
            this->Tx(0, false);
        } else if (this->keyPressed[0]) {
            this->Tx(0, true);
        } else {
            this->nextPulse = 0;
            return;
        }
        this->nextPulse = now + this->ditDuration;
    }
};

class ElBugKeyer: public BugKeyer {
public:
    unsigned int nextRepeat;

    using BugKeyer::BugKeyer;

    char *Name() {
      return "el bug";
    }

    void Reset() {
        BugKeyer::Reset();
        this->nextRepeat = -1;
    }

    // Return which key is pressed. If none, return -1.
    int whichKeyPressed() {
        for (int i = 0; i < len(this->keyPressed); i++) {
            if (this->keyPressed[i]) {
                return i;
            }
        }
        return -1;
    }

    void Key(Paddle key, bool pressed) {
        this->keyPressed[key] = pressed;
        if (pressed) {
            this->nextRepeat = key;
            this->beginPulsing();
        } else {
            this->nextRepeat = this->whichKeyPressed();
        }
    }

    unsigned int keyDuration(int key) {
        switch (key) {
        case PADDLE_DIT:
            return this->ditDuration;
        case PADDLE_DAH:
            return 3 * (this->ditDuration);
        }
        return this->ditDuration; // XXX
    }

    virtual int nextTx() {
        if (this->whichKeyPressed() == -1) {
            return -1;
        }
        return this->nextRepeat;
    }

    virtual void pulse(unsigned int now) {
        int nextPulse = 0;
        if (this->TxClosed(0)) {
            // Pause if we're currently transmitting
            nextPulse = this->keyDuration(PADDLE_DIT);
            this->Tx(0, false);
        } else {
            int next = this->nextTx();
            if (next >= 0) {
                nextPulse = this->keyDuration(next);
                this->Tx(0, true);
            }
        }

        if (nextPulse) {
            this->nextPulse = now + nextPulse;
        } else {
            this->nextPulse = 0;
        }
    }
};

class UltimaticKeyer: public ElBugKeyer {
public:
    QSet queue;
    
    using ElBugKeyer::ElBugKeyer;

    char *Name() {
      return "ultimatic";
    }

    void Key(Paddle key, bool pressed) {
        if (pressed) {
            this->queue.add(key);
        }
        ElBugKeyer::Key(key, pressed);
    }

    virtual int nextTx() {
        int key = this->queue.shift();
        if (key != -1) {
            return key;
        }
        return ElBugKeyer::nextTx();
    }
};

class SingleDotKeyer: public ElBugKeyer {
public:
    QSet queue;

    using ElBugKeyer::ElBugKeyer;

    char *Name() {
      return "single dot";
    }

    void Key(Paddle key, bool pressed) {
        if (pressed && (key == PADDLE_DIT)) {
            this->queue.add(key);
        }
        ElBugKeyer::Key(key, pressed);
    }

    virtual int nextTx() {
        int key = this->queue.shift();
        if (key != -1) {
            return key;
        }
        if (this->keyPressed[1]) return 1;
        if (this->keyPressed[0]) return 0;
        return -1;
    }
};

class IambicKeyer: public ElBugKeyer {
public:
    using ElBugKeyer::ElBugKeyer;

    char *Name() {
      return "iambic plain";
    }

    virtual int nextTx() {
        int next = ElBugKeyer::nextTx();
        if (this->keyPressed[PADDLE_DIT] && this->keyPressed[PADDLE_DAH]) {
            this->nextRepeat = 1 - this->nextRepeat;
        }
        return next;
    }
};

class IambicAKeyer: public IambicKeyer {
public:
    QSet queue;

    using IambicKeyer::IambicKeyer;
    
    char *Name() {
      return "iambic a";
    }

    void Key(Paddle key, bool pressed) {
        if (pressed && (key == PADDLE_DIT)) {
            this->queue.add(key);
        }
        IambicKeyer::Key(key, pressed);
    }

    virtual int nextTx() {
        int next = IambicKeyer::nextTx();
        int key = this->queue.shift();
        if (key != -1) {
            return key;
        }
        return next;
    }
};

class IambicBKeyer: public IambicKeyer {
public:
    QSet queue;
    int sending;

    using IambicKeyer::IambicKeyer;

    char *Name() {
      return "iambic b";
    }

    void Reset() {
        this->sending = -1;
        IambicKeyer::Reset();
    }

    void Key(Paddle key, bool pressed) {
        if (pressed && (this->sending != key)) {
            this->queue.add(key);
        }
        IambicKeyer::Key(key, pressed);
    }

    virtual int nextTx() {
        for (int key = 0; key < len(this->keyPressed); key++) {
            if (this->keyPressed[key]) {
                this->queue.add(key);
            }
        }

        this->sending = this->queue.shift();
        return this->sending;
    }
};

class KeyaheadKeyer: public ElBugKeyer {
public:
    int queue[MAX_KEYER_QUEUE];
    unsigned int qlen;

    using ElBugKeyer::ElBugKeyer;

    char *Name() {
      return "keyahead";
    }

    void Reset() {
        ElBugKeyer::Reset();
        this->qlen = 0;
    }

    void Key(Paddle key, bool pressed) {
        if (pressed) {
            if (this->qlen < MAX_KEYER_QUEUE) {
                this->queue[this->qlen++] = key;
            }
        }
        ElBugKeyer::Key(key, pressed);
    }

    virtual int nextTx() {
        if (this->qlen > 0) {
            int next = this->queue[0];
            this->qlen--;
            for (int i = 0; i < this->qlen; i++) {
                this->queue[i] = this->queue[i+1];
            }
            return next;
        }
        return ElBugKeyer::nextTx();
    }
};

StraightKeyer straightKeyer = StraightKeyer();
BugKeyer bugKeyer = BugKeyer();
ElBugKeyer elBugKeyer = ElBugKeyer();
SingleDotKeyer singleDotKeyer = SingleDotKeyer();
UltimaticKeyer ultimaticKeyer = UltimaticKeyer();
IambicKeyer iambicKeyer = IambicKeyer();
IambicAKeyer iambicAKeyer = IambicAKeyer();
IambicBKeyer iambicBKeyer = IambicBKeyer();
KeyaheadKeyer keyaheadKeyer = KeyaheadKeyer();

Keyer *AllKeyers[] = {
    &straightKeyer,
    &bugKeyer,
    &elBugKeyer,
    &singleDotKeyer,
    &ultimaticKeyer,
    &iambicKeyer,
    &iambicAKeyer,
    &iambicBKeyer,
    &keyaheadKeyer,
};

Keyer *GetKeyerByNumber(int n) {
  if (n >= len(AllKeyers)) {
    return NULL;
  }

  return AllKeyers[n];
}