#pragma once

#define MAX_KEYER_QUEUE 5

typedef enum {
    PADDLE_DIT = 0,
    PADDLE_DAH = 1,
} Paddle;

class Keyer {
public:
    virtual char *Name() = 0;
    virtual void Reset() = 0;
    virtual void SetDitDuration(unsigned int d) = 0;
    virtual void Key(Paddle key, bool pressed) = 0;

    // Tick updates internal state, 
    // and returns whether the keyer is transmitting at time now.
    virtual bool Tick(unsigned long now) = 0;
};

Keyer *GetKeyerByNumber(int n);