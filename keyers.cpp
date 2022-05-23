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
        if (arrlen == MAX_KEYER_QUEUE-1) {
            return;
        }
        for (int i = 0; i < arrlen; i++) {
            if (arr[arrlen] == i) {
                return;
            }
        }
        arr[arrlen] = val;
        arrlen++;
    }
};


class StraightKeyer: public Keyer {
public:
    Transmitter *output;
    unsigned int ditDuration;
    bool txRelays[2];

    StraightKeyer(Transmitter *output) {
        this->output = output;
        this->ditDuration = 100;
        this->Reset();
    }

    void Reset() {
        this->output->EndTx();
    }

    void SetDitDuration(int duration) {
        this->ditDuration = duration;
    }

    void Release() {}

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
        bool nowClosed = this->TxClosed();

        if (wasClosed != nowClosed) {
            if (nowClosed) {
                this->output->BeginTx();
            } else {
                this->output->EndTx();
            }
        }
    }

    void Key(Paddle key, bool pressed) {
        this->Tx(key, pressed);
    }

    void Tick(unsigned int millis) {};
};

class BugKeyer: public StraightKeyer {
public:
    unsigned int pulseTime = 0;
    bool keyPressed[2];

    using StraightKeyer::StraightKeyer;

    void Reset() {
        StraightKeyer::Reset();
        this->pulseTime = 0;
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

    void beginPulsing() {
        this->pulseTime = 1;
    }

    void pulse(unsigned int millis) {
        if (this->TxClosed(0)) {
            this->Tx(0, false);
        } else if (this->keyPressed[0]) {
            this->Tx(0, true);
        } else {
            this->pulseTime = 0;
            return;
        }
        this->pulseTime = millis + this->ditDuration;
    }

    void Tick(unsigned int millis) {
        if (this->pulseTime && (millis >= this->pulseTime)) {
            this->pulse(millis);
        }
    }
};

class ElBugKeyer: public BugKeyer {
public:
    unsigned int nextRepeat;

    using BugKeyer::BugKeyer;

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
        } else {
            this->nextRepeat = this->whichKeyPressed();
        }
        this->beginPulsing();
    }

    unsigned int keyDuration(int key) {
        switch (key) {
        case 0:
            return this->ditDuration;
        case 1:
            return 3 * this->ditDuration;
        }
        return 0;
    }

    int nextTx() {
        if (this->whichKeyPressed() == -1) {
            return -1;
        }
        return this->nextRepeat;
    }

    void pulse(unsigned int millis) {
        int nextPulse = 0;
        if (this->TxClosed(0)) {
            // Pause if we're currently transmitting
            nextPulse = this->ditDuration;
            this->Tx(0, false);
        } else {
            int next = this->nextTx();
            if (next >= 0) {
                nextPulse = this->keyDuration(next);
                this->Tx(0, true);
            }
        }

        if (nextPulse) {
            this->pulseTime = millis + nextPulse;
        } else {
            this->pulseTime = 0;
        }
    }
};

class UltimaticKeyer: public ElBugKeyer {
public:
    QSet *queue;
    
    using ElBugKeyer::ElBugKeyer;

    void Reset() {
        ElBugKeyer::Reset();
        this->queue = new QSet();
    }

    void Key(Paddle key, bool pressed) {
        if (pressed) {
            this->queue->add(key);
        }
        ElBugKeyer::Key(key, pressed);
    }

    int nextTx() {
        int key = this->queue->shift();
        if (key != -1) {
            return key;
        }
        return ElBugKeyer::nextTx();
    }
};

class SingleDotKeyer: public ElBugKeyer {
public:
    QSet *queue;

    using ElBugKeyer::ElBugKeyer;

    void Reset() {
        ElBugKeyer::Reset();
        this->queue = new QSet();
    }
    
    void Key(Paddle key, bool pressed) {
        if (pressed && (key == 0)) {
            this->queue->add(key);
        }
        ElBugKeyer::Key(key, pressed);
    }

    int nextTx() {
        int key = this->queue->shift();
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

    int nextTx() {
        int next = ElBugKeyer::nextTx();
        if (this->whichKeyPressed() != -1) {
            this->nextRepeat = 1 - this->nextRepeat;
        }
        return next;
    }
};

class IambicAKeyer: public IambicKeyer {
public:
    QSet *queue;

    using IambicKeyer::IambicKeyer;
    
    void Reset() {
        IambicKeyer::Reset();
        this->queue = new QSet();
    }

    void Key(Paddle key, bool pressed) {
        if (pressed && (key == 0)) {
            this->queue->add(key);
        }
        IambicKeyer::Key(key, pressed);
    }

    int nextTx() {
        int next = IambicKeyer::nextTx();
        int key = this->queue->shift();
        if (key != -1) {
            return key;
        }
        return next;
    }
};

class IambicBKeyer: public IambicKeyer {
public:
    QSet *queue;

    using IambicKeyer::IambicKeyer;

    void Reset() {
        IambicKeyer::Reset();
        this->queue = new QSet();
    }

    void Key(Paddle key, bool pressed) {
        if (pressed) {
            this->queue->add(key);
        }
        IambicKeyer::Key(key, pressed);
    }

    int nextTx() {
        for (int key = 0; key < 2; key++) {
            if (this->keyPressed[key]) {
                this->queue->add(key);
            }
        }

        return this->queue->shift();
    }
};

class KeyaheadKeyer: public ElBugKeyer {
public:
    int queue[MAX_KEYER_QUEUE];
    unsigned int qlen;

    using ElBugKeyer::ElBugKeyer;

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

    int nextTx() {
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

Keyer *GetKeyerByNumber(int n, Transmitter *output) {
    switch (n) {
    case 1:
        return new StraightKeyer(output);
    case 2:
        return new BugKeyer(output);
    case 3:
        return new ElBugKeyer(output);
    case 4:
        return new SingleDotKeyer(output);
    case 5:
        return new UltimaticKeyer(output);
    case 6:
        return new IambicKeyer(output);
    case 7:
        return new IambicAKeyer(output);
    case 8:
        return new IambicBKeyer(output);
    case 9:
        return new KeyaheadKeyer(output);
    default:
        return NULL;
    }
}
