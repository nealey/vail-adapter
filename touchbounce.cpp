#include "touchbounce.h"

void TouchBounce::attach(int pin) {
    this->qt = Adafruit_FreeTouch(pin);
    this->qt.begin();
}

bool TouchBounce::readCurrentState() {
    int val = this->qt.measure();
    return val < QT_THRESHOLD;
}
