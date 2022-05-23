#include <Arduino.h>
#include "polybuzzer.h"

PolyBuzzer::PolyBuzzer(uint8_t pin) {
        for (int i = 0; i < POLYBUZZER_MAX_TONES; i++) {
            this->tones[i] = 0;
        }
        this->playing = 0;
        this->pin = pin;
        pinMode(pin, OUTPUT);
    }

void PolyBuzzer::update() {
    for (int i = 0; i < POLYBUZZER_MAX_TONES; i++) {
        if (tones[i]) {
            if (playing != tones[i]) {
                playing = tones[i];
                tone(this->pin, tones[i]);
                return;
            }
        }
    }
    this->playing = 0;
    noTone(this->pin);
}

void PolyBuzzer::Tone(int slot, unsigned int frequency) {
    tones[slot] = frequency;
    this->update();
}

void PolyBuzzer::Note(int slot, int note) {
    unsigned int frequency = 8.18; // MIDI note 0
    for (int i = 0; i < note; i++) {
        frequency *= 1.0594630943592953; // equal temperament half step
    }
    this->Tone(slot, frequency);
}

void PolyBuzzer::NoTone(int slot) {
    tones[slot] = 0;
    this->update();
}

