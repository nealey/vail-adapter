#pragma once

#include <Arduino.h>
#define POLYBUZZER_MAX_TONES 2

// PolyBuzzer provides a proritized monophonic buzzer.
//
// A given tone will only be played when all higher priority tones have stopped.
class PolyBuzzer {
public:
    unsigned int tones[POLYBUZZER_MAX_TONES];
    unsigned int playing;
    uint8_t pin;

    PolyBuzzer(uint8_t pin);
    void update();
    void Tone(int slot, unsigned int frequency);
    void Note(int slot, uint8_t note);
    void NoTone(int slot);
};
