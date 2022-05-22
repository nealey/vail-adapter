---
Author: neale
Email: neale@woozle.org
License: MIT
---

# Vail Adapter: Morse Code Key/Paddle to USB

![Vail adapter, assembled and connected](doc/vail-adapter-v2.jpg)


# Features

* Lets you key even if you move focus to another window
* Works with [Vail](https://vail.woozle.org/)
* Works with [VBand](https://hamradio.solutions/vband/)
* Optional sidetone generator for straight keying, which helps with latency
* Free firmware updates for life
* Can be wired up in about 5 minutes

[Vail Adapter benefits video](https://www.youtube.com/watch?v=XQ-mwdyLkOY) (4:46)

# Setting Up

* [Easy Setup](doc/easy-install.md)
* [Advanced Setup](doc/advanced-install.md)


# Future Work

Things I plan to add:

* Local keyer logic for Ultimatic, Iambic, etc.
* Local keyer generating sidetones
* Vail site sends MIDI note events to the adapter, 
  so you don't need your computer speaker on to listen.


# Contributing
To contribute to this project please contact neale@woozle.org
https://id.arduino.cc/neale



# Similar projects

* Vail user Michele Giugliano's 
  [MorsePaddle2USB](https://github.com/mgiugliano/MorsePaddle2USB),
  which runs on a DigiSpark (attiny85). It only sends keystrokes, so you must keep the Vail
  window focused: you can't switch to other apps and still transimit.
* Ham Radio Solutions sells a 
  [USB Paddle Interface](https://hamradio.solutions/vband/)
  which appears to be very similar to Michele's project. You must keep the 
  Vail window focused.
* [CWKeyboard](https://github.com/kevintechie/CWKeyboard) looks almost 
  exactly the same as the VBand adapter.
