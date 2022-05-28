#pragma once

#include <MIDIUSB.h>
#include "keyers.h"
#include "polybuzzer.h"

class VailAdapter: public Transmitter {
private:
    unsigned int txToneFrequency;
    unsigned int ditDuration = 100;
    bool keyboardMode = false;
    Keyer *keyer = NULL;
    PolyBuzzer *buzzer = NULL;

    void midiKey(uint8_t key, bool down);
    void keyboardKey(uint8_t key, bool down);


public:
    VailAdapter(unsigned int PiezoPin);
    void HandlePaddle(Paddle key, bool pressed);
    void HandleMIDI(midiEventPacket_t event);
    void BeginTx();
    void EndTx();
    void Tick(unsigned millis);
};
