// based on SynthDefs from:
// https://www.youtube.com/watch?v=kuSI5MXDPNw&ab_channel=SynthDef
(
SynthDef(\kick, {
	var snd;
	snd = SinOsc.ar(59 * (1 + (5 * Env.perc(0, 0.1, curve: -8).ar)) * (1 + (0.4 * Env.perc(0, 0.2, curve: -2).ar)));
	// snd = snd + (SinOsc.ar(XLine.ar(7000, 100, 0.03)) * Env.perc(0.002, 0.03).ar);
	// snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 8130, 0.5) * Env.perc(0.001, 0.03).ar * -9.dbamp);
	snd = snd * (1 + Env.perc(0.0, 0.5).ar);
	snd = snd.tanh;
	snd = snd * Env.perc(0.001, 0.5, curve: -4).ar(Done.freeSelf);
	snd = snd * \amp.kr(-4.dbamp);
	snd = snd ! 2;
	Out.ar(\out.kr(0), snd);
}).add;


SynthDef(\clapDry, {
	var snd;
	snd = Hasher.ar(Sweep.ar + [0, 1, 2]);
	snd = BPF.ar(snd, 1135 * [0.9, 1.0, 1.16], 0.1) * 13.dbamp;
	snd = snd * Env.perc(0.001, 0.2, curve: -6).delay([0, 1, 2] * 2e-2).ar;
	snd = Splay.ar(snd, 0.5);
	snd = snd * 8.dbamp;
	snd = snd * \amp.kr(1);
	snd = snd * Env.linen(0, 0.3, 0.1).ar(Done.freeSelf);
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\clapWet, {
	var snd;
	snd = Hasher.ar(Sweep.ar + [0, 1, 2]);
	snd = BPF.ar(snd, 1105 * [0.9, 1.0, 1.16], 0.1) * 13.dbamp;
	snd = snd * Env.perc(0.001, \decay.kr(0.9), curve: -6).delay([0, 1, 2] * 2e-2).ar;
	snd = Splay.ar(snd, 0.3);
	snd = snd * -3.dbamp;
	snd = snd * Env.linen(0, \decay.kr(0.9), 0.1).ar(Done.freeSelf);
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\hat, {
	var snd;
	snd = SinOsc.ar(1320) * Env.perc(0.001, 0.03).ar * 8000;
	snd = SinOsc.ar(3340 + snd) * Env.perc(0.001, 0.1).ar * 16000;
	snd = SinOsc.ar(1220 + snd);
	snd = snd + Hasher.ar(Sweep.ar);
	snd = BPF.ar(snd, [3844, 12844, 5249], 0.3);
	snd = snd * [-10, -5, 0].dbamp;
	snd = snd.sum;
	snd = snd * Env.perc(0.003, 0.05, curve: -8).ar(Done.freeSelf);
	snd = Pan2.ar(snd, \pan.kr(0));
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\pad, {
	var snd, env, pitchEnv;
	env = Env.perc(0.03, 0.5).ar(Done.none, \duck.tr);
	snd = Saw.ar(\freq.kr(440) * (LFNoise2.kr(3 ! 8) * 0.1).midiratio);
	snd = Splay.ar(snd);
	snd = MoogFF.ar(snd, LFNoise2.kr(3).linexp(-1, 1, 500, 1000) * (env.neg * 8).midiratio, 1.5) * 10.dbamp;
	snd = Latch.ar(snd, Impulse.ar(LFNoise2.kr(3).linexp(-1, 1, 4e3, 16e3)));
	snd = snd * (1 - env);
	snd = snd * Env.asr(0.1, 1, 0.1).ar(Done.freeSelf, \gate.kr(1));
	snd = snd * \amp.kr(1);
	snd = snd * -12.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\pluck, {
	var snd, freq;
	freq = 60 * \transpose.kr(0).midiratio;
	snd = Pulse.ar(freq * [-0.1, 0.1].midiratio);
	snd = MoogFF.ar(snd, Env.perc(0.001, 0.2).ar.linexp(0, 1, 100, 8000), 1);
	snd = snd * (1 + (SinOsc.ar(963) * Env.perc(0, 0.1).ar));
	snd = snd * Env.perc(0.001, 0.2, curve: -1).ar;
	snd = snd + (GVerb.ar(snd.sum, 20, 1) * -10.dbamp);
	snd = snd * Env.perc(0.001, 0.5, curve: -1).ar(Done.none, \duck.tr);
	snd = snd * \amp.kr(1);
	snd = snd * 3.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)
ServerOptions.outDevices;
// s.options.outDevice_("Scarlett 4i4 USB");
s.options.outDevice_("MacBook Pro Speakers");
s.reboot;
s.meter;

~a = [0, 1, 3, 7];

~seqArray = [];
~a.do{ |elem| ~seqArray = ~seqArray.add(12 - elem % 12); };
~seqArray;


(
// Synth(\bass, [freq: (18 + 0).midicps]);
~synth = Synth(\pad, [\freq, (30 + 12).midicps]);
// ~synth.play;
~synth.set(\freq, (30 + 0).midicps);
// ~synth.set(\duck, 1);
)

(
// ~offset = Pseq([0, 7, -2], inf).asStream;
~offset = Pseq([0, 1, 3, 7], inf).asStream * 0.333;

~oct = 12*3;//[12*4, 12*3];
~kick_amp = Pbrown(-inf.dbamp, -36.dbamp, inf).asStream;
~r = Routine({
	~synth = Synth(\pad, [\freq, (18 + ~oct).midicps]);
	// ~synth = Synth(\kick);
	[
		1,
		0.5,
		1,
		2,
		1/2, 1/2,
		1/3, 1/3, 1/3,
		2,
		1,
		1/5, 1/5, 1/5, 1/5, 1/5,
		1/3, 1/3, 1/3,
		1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7,
		1/2, 1/2,
		1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11,
		1/6, 1/6, 1/6, 1/6, 1/6, 1/6,
		1/4, 1/4, 1/4, 1/4,
		2,
		0.5,
	].do{ |dur|
		~synth.set(\duck, 1);
		Synth(\kick, [\amp, -8.dbamp]);
		if(dur < (1/7)) { Synth(\hat); };
		if(dur > (1/1)) { Synth(\clapDry);  };
		~synth.set(\freq, (18 + ~oct + ~offset.next).midicps);
		(0.75*dur).wait;
	};
	1.wait;
	Synth(\clapWet);
	// Synth(\clapDry);
	~synth.free;
});
)
~r.reset.play;
// ~oct = 12*3;