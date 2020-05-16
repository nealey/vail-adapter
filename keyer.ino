// MIDIUSB - Version: Latest 
#include <MIDIUSB.h>
#include <Keyboard.h>
#include "bounce2.h"

#define DIT_PIN 12
#define DAH_PIN 11
#define KEY_PIN 10
#define KBD_PIN 9

#define STRAIGHT_KEY ','
#define DIT_KEY '.'
#define DAH_KEY '/'

bool iambic = true;
Bounce kbd = Bounce();
Bounce dit = Bounce();
Bounce dah = Bounce();
Bounce key = Bounce();

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  kbd.attach(KBD_PIN, INPUT_PULLUP);
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
  
  digitalWrite(LED_BUILTIN, !iambic);
}

void midiKey(bool down, uint8_t key) {
  midiEventPacket_t event = {down?9:8, down?0x90:0x80, key, 0x7f};
  MidiUSB.sendMIDI(event);
  MidiUSB.flush();
}

void loop() {
  bool keyboard;
  
  kbd.update();
  keyboard = !kbd.read();

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
