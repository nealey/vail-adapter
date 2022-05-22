# MIDI Negotiation

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

