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
#  define PIEZO 7
#  define LED_ON false
#else
#  define DIT_PIN 12
#  define DAH_PIN 11
#  define KEY_PIN 10
#  define PIEZO 7
#  define LED_ON true
#endif
#define LED_OFF (!LED_ON)

#define STRAIGHT_KEY ','
#define DIT_KEY KEY_LEFT_CTRL
#define DAH_KEY KEY_RIGHT_CTRL
#define TONE 660

#define MILLISECOND 1
#define SECOND (1 * MILLISECOND)

bool keyboard = true;
bool trs = false; // true if a TRS plug is in a TRRS jack
uint16_t iambicDelay = 80 * MILLISECOND;
Bounce dit = Bounce();
Bounce dah = Bounce();
Bounce key = Bounce();

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(PIEZO, OUTPUT);
  dit.attach(DIT_PIN, INPUT_PULLUP);
  dah.attach(DAH_PIN, INPUT_PULLUP);
  key.attach(KEY_PIN, INPUT_PULLUP);
  
  Keyboard.begin();

  // To auto-sense a straight key in a TRRS jack,
  // we just check to see if DAH is closed. 
  // The sleeve on the straight key's TRS plug
  // will short the second ring to the sleeve.
  for (int i = 0; i < 16; i++) {
    delay(20);
    dah.update();
  }
  if (dah.read() == LOW) {
    trs = true;
    key = dit;
  }
}

// A reentrant doodad to blink out the letter V at startup
// After startup, display the status of the keyboard
#define HELLO_BITS 0b0000101010111000
void setLED() {
  static bool beepin = false;
  int beat = millis() / iambicDelay;
  bool on = keyboard; // If we're not in intro, display status of keyboard

  if (beat < 16) {
    on = HELLO_BITS & (1 << (15-beat));
    if (on != beepin) {
      if (on) {
        tone(PIEZO, TONE);
      } else {
        noTone(PIEZO);
      }
      beepin = on;
    }
  }
  
  digitalWrite(LED_BUILTIN, on?LED_ON:LED_OFF);
}

void midiKey(bool down, uint8_t key) {
  midiEventPacket_t event = {down?9:8, down?0x90:0x80, key, 0x7f};
  MidiUSB.sendMIDI(event);
  MidiUSB.flush();
}

void midiProbe() {
  midiEventPacket_t event = MidiUSB.read();

  uint16_t msg = (event.byte1 << 8) | (event.byte2 << 0);
  switch (msg) {
  case 0x8B00: // Controller 0: turn keyboard mode on/off
    keyboard = (event.byte3 > 0x3f);
    break;
  case 0x8B01: // Controller 1: set iambic speed (0-254)
    // I am probably never going to use this,
    // because as soon as I implement it,
    // people are going to want a way to select mode A or B,
    // or typeahead,
    // or some other thing that I don't want to maintain
    // simultaneously in both C and JavaScript
    iambicDelay = event.byte3 << 1;
    break;
  }
}

void loop() {
  midiProbe();
  setLED();

  // Monitor straight key pin
  if (key.update()) {
    midiKey(key.fell(), 0);
    if (key.fell()) {
      tone(PIEZO, TONE);
      if (keyboard) {
        Keyboard.press(STRAIGHT_KEY);
      }
    } else {
      noTone(PIEZO);
      if (keyboard) {
        Keyboard.release(STRAIGHT_KEY);
      }
    }
  }

  // If we made dit = dah, we have a straight key on the dit pin,
  // so we skip iambic polling.
  if (trs) {
    return;
  }

  if (dit.update()) {
    midiKey(dit.fell(), 1);
    if (keyboard) {
      if (dit.fell()) {
        Keyboard.press(DIT_KEY);
      } else {
        Keyboard.release(DAH_KEY);
      }
    }
  }
  
  // Monitor dah pin
  if (dah.update()) {
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
