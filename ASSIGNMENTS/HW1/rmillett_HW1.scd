// trying to replicate some FoxDot SynthDefs
https://github.com/Qirky/FoxDot/blob/master/FoxDot/lib/SCLang/_SynthDefs.py

(
SynthDef(\glass, {
    |out = 0, freq = 440, amp = 0.9, sus = 3, rel = 2, rate = 1, attack = 0.667, decay = 0.2, sustain = 0.5, release = 1, gate = 1|
    var osc, env, amp_scale = 1;

    sus = sus * 1.67;
	amp = amp * 1.33;
    osc = SinOsc.ar(freq * (1..3), 0, amp_scale);
	env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
    Out.ar(out, osc * env * amp);
}).add;
)

(
SynthDef(\varsaw, { |out = 0, freq = 440, amp = 0.5, pan = 0, attack = 0.667, decay = 0.2, sustain = 0.5, release = 1, detune = 0.5, width = 0.5, gate = 1|
	var env, sig;

	env = EnvGen.kr(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
	sig = VarSaw.ar(freq, 0, width, mul: amp) * env;
	sig = sig + (VarSaw.ar(freq * (1 + detune), 0, width, mul: amp) * env);
	sig = Pan2.ar(sig, pan);

	Out.ar(out, sig);
}).add;
)

(
var transpose = 12;

var chords = Pseq([
	[47, 50, 52],
	[51, 54, 56],
	[46, 49, 51],
	[52, 55, 59]
], inf).collect { |chord|
	chord.collect { |note| note + transpose }
};

Pdef(\glassPbind,
	Pbind(
		\instrument, \varsaw,
		\midinote, chords,
		\dur, 3.333,
		\rel, Pkey(\dur) * 1.667)
).play;
)

Pdef(\glassPbind).stop;








