---
Author: neale
Email: neale@woozle.org
License: MIT
---

# Project: USB Morse Adapter

![Vail adapter, assembled and connected](https://lh3.googleusercontent.com/pw/ACtC-3d9xbLxL23QeLm-3gy3-Yt0VHE3IlQ-qyMDqTfdF6Bo7fHkkokACdIs68pmXevu14VzrrCeKj1JmRUiekUNiZe9J9rYIh_pTagvCbKSzpY8Ynp1m6cF4G_jTvtiU5eRtoNCsmU5OLy2SR9kYcCDYSt-AA=s1471-no)

This translates Morse key inputs into USB events,
either MIDI or MIDI+Keyboard,
so you can use a computer.

It is fully compatible with [VBand](https://hamradio.solutions/vband/)
and anything else that uses the VBand adapter.

I use this with an Internet morse code repeater I wrote,
available at https://vail.woozle.org/.

This project requires an Arduino that can send USB.
The following should work:

### Verified Working

* Seeeduino Xiao **(recommended)**
* Arduino Micro
* KeeYees Pro Micro

### Unverified but should work

Any USB-capable Arduino should be fine, including:

* Arduino Leonardo
* Arduino Zero
* Adafruit Trinket M0
* Adafruit GEMMA M0
* Adafruit Feather M0

It may also be possible to get this working on a DigiSpark.
I'm trying to convince Michele Giugliano to try :)

=== Similar projects

* Vail user Michele Giugliano's [MorsePaddle2USB](https://github.com/mgiugliano/MorsePaddle2USB),
  which runs on a DigiSpark (attiny85). It only sends keystrokes, so you must keep the Vail
  window focused: you can't switch to other apps and still transimit.
* Ham Radio Solutions sells a [USB Paddle Interface](https://hamradio.solutions/vband/)
  which appears to be very similar to Michele's project. You must keep the Vail window focused.

## Step 1: Installation

#### The Easy Way

1. Get a Seeeduino XIAO
2. Download the most recent xiao firmware from
[releases](https://github.com/nealey/vail-adapter/releases)
3. [Enter bootloader mode](https://wiki.seeedstudio.com/Seeeduino-XIAO/#enter-bootloader-mode)
4. Copy the firmware onto the XIAO

A longer write-up is [on the wiki](https://github.com/nealey/vail-adapter/wiki/Flashing-firmware).

#### The Other Way

Install the MidiUSB and Keyboard libraries.
These are highly popular libraries,
and there is much better documentation elsewhere on the Internet.
The code should then build in the Arduino IDE.

## Step 2: Assmble the circuit

### For the impatient:

[Photos of assembled circuit](https://github.com/nealey/vail-adapter/wiki)

### For the inquisitive:

Morse code keyers are very simple devices, 
they just connect two wires together.
You could use a button if you wanted to,
or even touch wires together.

The only real complication here is that some browsers
need to get keyboard events instead of musical instrument events.

The Vail adapter boots into a mode that sends both keyboard events
and MIDI messages. 
If it receives a MIDI key release event
on channel 0
for note C0,
it will disable keyboard events.

Vail sends this "disable keyboard" MIDI event, so as soon as you
load up Vail, the keyboard events are disabled, and your adapter
will no longer interfere with your typing.
If your browser doesn't support MIDI, 
the disable command can't be sent,
and it keeps on sending keystrokes.

### Wire up your input device

Hook a straight key into ground on one side,
pin 10 on the other.
It's okay to leave pin 10 disconnected if you don't have a straight key.

Hook an iambic paddle in ground in the middle,
pins 11 and 12 on the outside posts.
It's okay to leave pins 11 and 12 disconnected if you don't have a paddle.

=== Using a headphone jack

If you prefer, you can wire a headphone jack up to GND, 11, and 12.
GND should be the sleeve, 11 the ring, and 12 the tip.

     o  --- 12
    |_| --- 11
    | | --- GND
    | |

Make sure any straight key you plug in has a TS adapter (mono plug):
this will short pin 11 to ground and signal to the Arduino to 
go into straight key mode.

If you change from an iambic key to a straight key,
you'll have to reset the adapter by unplugging it from the computer.


## Step 3: Load the code

Upload the code contained in this sketch on to your board.

## Step 4: Test it out

Make sure it's plugged in to your computer's USB port.

If you connected pin 9 to ground,
Open anything where you can type,
type in "hello", and hit the straight key.
You should see a comma after your hello.

Now you can open https://vail.woozle.org/,
click the "KEY" button once to let the browser know it's okay to make sound,
and you should be able to wail away on your new USB keyer.

## Step 5: Debugging

If you plug in your straight key and it looks like DAH is being held down,
it means you need to switch the connections to pins 11 and 12.

If you plug in your straight key and it looks like DIT is being held down,
it means you need to reset the Arduino to make it detect the key type again.


# License

This project is released under an MIT License.

Copyright © 2020 Neale Pickett
Copyright © 2013 thomasfredericks

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability, fitness
for a particular purpose, and noninfringement. In no event shall the authors or
copyright holders be liable for any claim, damages, or other liability, whether
in an action of contract, tort or otherwise, arising from, out of, or in
connection with the software or the use or other dealings in the software.


# Contributing
To contribute to this project please contact neale@woozle.org
https://id.arduino.cc/neale


# BOM

In addition to a key, some hookup wires, and a USB cable,
you only need a USB-capable Arduino: see above.

Since I don't know what might try to parse this section,
I'm calling for an Arduino Micro. But, really, many options
will work fine.

| ID | Part name      | Part number | Quantity |
| --- | ------- | ------ | ------ |
| A1 | Seeeduino XIAO | 102010328    | 1 |
