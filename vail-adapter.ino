// Copyright 2020 Neale Pickett
// Distributed under the MIT license
// Please see https://github.com/nealey/vail-adapter/

// MIDIUSB - Version: Latest 
#include <MIDIUSB.h>
#include <Keyboard.h>
#include "bounce2.h"

#ifdef ARDUINO_SEEED_XIAO_M0
#  define DIT_PIN 2
#  define DAH_PIN 1
#  define KEY_PIN 0
#else
#  define DIT_PIN 12
#  define DAH_PIN 11
#  define KEY_PIN 10
#endif

#define STRAIGHT_KEY ','
#define DIT_KEY KEY_LEFT_CTRL
#define DAH_KEY KEY_RIGHT_CTRL

bool iambic = true;
bool keyboard = true;
Bounce dit = Bounce();
Bounce dah = Bounce();
Bounce key = Bounce();

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  dit.attach(DIT_PIN, INPUT_PULLUP);
  dah.attach(DAH_PIN, INPUT_PULLUP);
  key.attach(KEY_PIN, INPUT_PULLUP);
  
  Keyboard.begin();

  // Straight keys need to wire the dah pin to ground somehow.
  // The easiest way I can think of to do this is to use a TS connector
  // instead of a TRS connector.
  for (int i = 0; i < 16; i++) {
    dah.update();
  }
  if (dah.read() == LOW) {
    iambic = false;
  } else {
    iambic = true;
  }

  // Blink 4 times
  for (int i = 0; i < 8; i += 1) {
    digitalWrite(LED_BUILTIN, i % 2);
    delay(250);
  }

}

void midiKey(bool down, uint8_t key) {
  midiEventPacket_t event = {down?9:8, down?0x90:0x80, key, 0x7f};
  MidiUSB.sendMIDI(event);
  MidiUSB.flush();
}

void midiProbe() {
  midiEventPacket_t event = MidiUSB.read();
  if (event.byte1 == 0x80) { 
    // Key release, channel 0
    if (event.byte2 == 0x00) { 
      // C0 note
      keyboard = false;
    }
  }  
}

void loop() {
  midiProbe();
  digitalWrite(LED_BUILTIN, !keyboard);

  // Monitor straight key pin
  if (key.update()) {
    midiKey(key.fell(), 0);
    if (keyboard) {
      if (key.fell()) {
        Keyboard.press(STRAIGHT_KEY);
      } else {
        Keyboard.release(STRAIGHT_KEY);
      }
    }
  }
  
  // Monitor dit pin, which could be straight key if dah was closed on boot
  if (dit.update()) {
    uint8_t kbdKey, mKey;
    if (iambic) {
      kbdKey = DIT_KEY;
      mKey = 1;
    } else {
      kbdKey = STRAIGHT_KEY;
      mKey = 0;
    }
    
    midiKey(dit.fell(), mKey);
    if (keyboard) {
      if (dit.fell()) {
        Keyboard.press(kbdKey);
      } else {
        Keyboard.release(kbdKey);
      }
    }
  }
  
  // Monitor dah pin
  if (iambic && dah.update()) {
    midiKey(dah.fell(), 2);
    
    if (keyboard) {
      if (dah.fell()) {
        Keyboard.press(DAH_KEY);
      } else {
        Keyboard.release(DAH_KEY);
      }
    }
  }
}
