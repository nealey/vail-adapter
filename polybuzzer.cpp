#include <Arduino.h>
#include "polybuzzer.h"
#include "equal_temperament.h"

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
        if (this->tones[i]) {
            if (this->playing != this->tones[i]) {
                this->playing = this->tones[i];
                tone(this->pin, this->tones[i]);
            }
            return;
        }
    }
    this->playing = 0;
    noTone(this->pin);
}

void PolyBuzzer::Tone(int slot, unsigned int frequency) {
    this->tones[slot] = frequency;
    this->update();
}

void PolyBuzzer::Note(int slot, uint8_t note) {
    if (note > 127) {
        note = 127;
    }
    this->Tone(slot, equalTemperamentNote[note]);
}

void PolyBuzzer::NoTone(int slot) {
    tones[slot] = 0;
    this->update();
}

