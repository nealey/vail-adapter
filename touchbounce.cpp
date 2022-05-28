#include "touchbounce.h"

void TouchBounce::attach(int pin) {
    this->qt = Adafruit_FreeTouch(pin, OVERSAMPLE_2, RESISTOR_50K, FREQ_MODE_NONE);
    this->qt.begin();
}

bool TouchBounce::readCurrentState() {
    int val = this->qt.measure();
    return val > QT_THRESHOLD/2;
}
