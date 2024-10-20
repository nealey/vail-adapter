// Copyright 2020 Neale Pickett
// Distributed under the MIT license
// Please see https://github.com/nealey/vail-adapter/

#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Fonts/FreeSans9pt7b.h>
#include "bounce2.h"
#include "keyers.h"
#include "polybuzzer.h"

#define DIT_PIN 1
#define DAH_PIN 3
#define S1_PIN 4
#define S2_PIN 9
#define SPEAKER 7
#define SOUNDER 8
#define MILLISECOND 1
#define SECOND (1 * MILLISECOND)

uint16_t iambicDelay = 80 * MILLISECOND;
Bounce dit = Bounce();
Bounce dah = Bounce();
Bounce s1 = Bounce();
Bounce s2 = Bounce();
PolyBuzzer buzzer = PolyBuzzer(SPEAKER);

Adafruit_NeoPixel pixels(1, PIN_NEOPIXEL, NEO_GRB + NEO_KHZ800);
Adafruit_SSD1306 display(128, 32, &Wire, -1);

// Tones default to a minor third
unsigned int txNote = 72; // C5
unsigned int rxNote = 69; // A4

int keyerCurrentN = 0;
Keyer *keyerCurrent = NULL;

void led(uint32_t color = 0) {
  pixels.fill(color);
  pixels.show();
}

  
// A reentrant doodad to blink out the letter V at startup
#define HELLO_BITS 0b0000101010111000
void hello(unsigned long now) {
  static bool beeping = false;
  int beat = now / iambicDelay;

  if (beat < 16) {
    bool on = HELLO_BITS & (1 << (15-beat));
    if (on != beeping) {
      if (on) {
        buzzer.Note(0, rxNote);
        led(0x220000);
      } else {
        buzzer.NoTone(0);
        led(0);
      }
      beeping = on;
    }
  }
}

int loadKeyer(int n) {
  keyerCurrent = GetKeyerByNumber(n);
  if (NULL == keyerCurrent) {
    n = 0;
    keyerCurrent = GetKeyerByNumber(n);
  }

  display.clearDisplay();
  display.setCursor(1, 12);
  display.println(keyerCurrent->Name());
  display.display();

  return n;
}

void 

void setup() {
  dit.attach(DIT_PIN, INPUT_PULLUP);
  dah.attach(DAH_PIN, INPUT_PULLUP);
  s1.attach(S1_PIN, INPUT_PULLUP);
  s2.attach(S2_PIN, INPUT_PULLUP);
  pinMode(SOUNDER, OUTPUT);

  Serial.begin(115200);
  Serial.println("Vail Client / " __DATE__ " " __TIME__);

  pixels.begin(); // INITIALIZE NeoPixel strip object (REQUIRED)
  pixels.setBrightness(20); // not so bright

  Wire.begin();
  display.begin(SSD1306_SWITCHCAPVCC); // This never returns false, in my testing
  display.setFont(&FreeSans9pt7b);
  display.setTextColor(SSD1306_WHITE);

  display.clearDisplay();
  display.setCursor(1, 12);
  display.println(__DATE__);
  display.display();

  // To auto-sense a straight key in a TRRS jack,
  // check to see if DAH is closed. 
  // The sleeve on the straight key's TRS plug
  // will short the second ring to the sleeve.
  // In this case, set the keyer to straight.
  // Since keyers are edge triggered,
  // nothing will happen if the key stays closed.
  // If it opens, it falls back to being a straight key.
  for (int i = 0; i < 16; i++) {
    hello(millis());
    delay(20);
    dah.update();
  }
  if (dah.read() == LOW) {
    loadKeyer(0); // Straight
  } else {
    loadKeyer(7); // Iambic B
  }
}

void loop() {
  static unsigned long txBegin = 0;
  unsigned long now = millis();

  hello(now);

  s1.update();
  s2.update();
  if (s1.fell() || s2.fell()) {
    keyerCurrentN = loadKeyer(keyerCurrentN + 1);
    // XXX: menu
  }

  if (dit.update()) {
    keyerCurrent->Key(PADDLE_DIT, !dit.read());
  }
  
  if (dah.update()) {
    keyerCurrent->Key(PADDLE_DAH, !dah.read());
  }

  bool sounding = keyerCurrent->Tick(now);
  if (sounding) {
    if (!txBegin) {
      txBegin = now;
      buzzer.Note(0, txNote);
      digitalWrite(SOUNDER, HIGH);
      led(0xff0000);
    }
  } else {
    if (txBegin) {
      Serial.printf("%d %d\n", txBegin, now - txBegin);
      txBegin = 0;
      buzzer.NoTone(0);
      digitalWrite(SOUNDER, LOW);
      led();
    }
  }
}
