s.boot;
ServerOptions.outDevices;
s.options.outDevice_("JBL Flip 6");
s.reboot;

~tempo = TempoClock.new(72/60);
(
Pbind(
	\instrument, \default,
	\dur, Autoref([3,2,5,7,1,4]*3, inf),
	\freq, (78 + Pinf(0,1,inf)).midicps,
).play(~tempo, quant:1);
)

~tempo = TempoClock.new(48/60);
(
Routine({
	var p_scale = 2;
	var prol = [3,5,7,5,11]*p_scale;
	prol.do{ |p, i|
		Pbind(
			\dur, Autoref(prol*2, inf),
			\freq, (78 - (12*(i%3)) + (Pinf(0,p)*0.6667)).midicps * Pdup(prol.size, (Pinf(0,p)*7.01).midiratio),
			\pan, Pbrown(-1,1,0.16667),
			\instrument, \interpolatingSynth,
			\mu, .....
		).play(~tempo, quant:1);
		p.wait;
	};
}).play(~tempo, quant:1);
)

(
SynthDef(\interpolatingSynth, { |out = 0, freq = 440, mu = 0.5, dur = 1, cutoff = 5000|

	// Percussive envelope: fast attack and decay
	var percEnv = Env.perc(releaseTime: dur).kr(Done.freeSelf, gate:1);

	// Smooth envelope: slow attack and release
	var smoothEnv = Env.linen(releaseTime: dur).kr(Done.freeSelf, gate:1);

	// Define interpolation levels based on mu
	var percEnvLevel = mu;
	var smoothEnvLevel = 1 - mu;

	// Interpolate between the two envelopes
	var mixedEnv = (percEnv * percEnvLevel) + (smoothEnv * smoothEnvLevel);

	// Oscillator with the mixed envelope applied
	var sig = SinOsc.ar(freq) * (mixedEnv * 0.25);

	// Apply a low pass filter to cut high frequencies
	sig = LPF.ar(sig, cutoff) * \amp.ar(-48.dbamp);

	// Output the signal in stereo
	Out.ar(out, [sig, sig]);

}).add;
)
(
var midSides;

midSides = { |snd|
	[snd[0] + snd[1], snd[0] - snd[1]] / sqrt(2);
};
SynthDef(\marker1, {
	var snd;
	snd = (\freq.ar(800) * (\ratio.ar(1) ** [0, 1, 2, 3])).collect { |f|
		var snd;
		snd = SinOsc.ar(f * (LFNoise2.kr(8 ! 2) * 0.1).midiratio) * LFNoise2.kr(8 ! 2);
		snd = midSides.(snd);
		snd;
	};
	snd = snd.sum;
	snd = snd * Env.perc(0.1, 3).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -3.dbamp;
	snd = snd * \amp.ar(0.dbamp);
	Out.ar(\out.kr(0), snd);
}).add;


SynthDef(\marker2, {
	var snd;
	snd = (260 * (1.5 ** [0, 1, 2, 3]) * \ratio.kr(1)).collect { |freq|
		var snd;
		snd = LFTri.ar(freq * (LFNoise2.kr(8 ! 2) * 0.1).midiratio) * LFNoise2.kr(1 ! 2);
		snd = midSides.(snd);
		snd;
	};
	snd = snd.sum;
	snd = snd * (1 + (5 * Env.perc(0, 0.3).ar));
	snd = snd.tanh;
	snd = snd * Env.perc(0.1, 3.0).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -6.dbamp;
	snd = snd * \amp.ar(0.dbamp);
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\marker3, {
	var snd, freq;
	freq = 440 * \ratio.kr(1) * Demand.ar(Impulse.ar(20 * XLine.kr(1, 2, 1)), 0, Dseq(1.5 ** (0..3), 5));
	snd = Pulse.ar(freq);
	snd = snd + GVerb.ar(snd, 30);
	snd = snd * Env.perc(0.01, 3.0).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -20.dbamp;
	snd = snd * \amp.ar(0.dbamp);
	Out.ar(\out.kr, snd);
}).add;


SynthDef(\marker4, {
	var snd, freq;
	freq = 260 * (1.5 ** (0..3));
	snd = Saw.ar(freq);
	snd = snd.collect { |snd| LPF.ar(snd, TExpRand.ar(100, 8000, Dust.ar(10)).lag(0.01)); };
	snd = snd.sum;
	3.do {
		snd = snd + DelayC.ar(snd, 0.1, LFNoise2.kr(1 ! 2).linlin(-1, 1, 1e-3, 10e-3));
	};
	snd = snd * Env.perc(0.01, 3.0).ar(Done.freeSelf, \gate.kr(1));
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * -20.dbamp;
	snd = snd * \amp.ar(0.dbamp);
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\vocal, {
	var snd, duration;
	duration = 0.09;
	snd = Pulse.ar(50);
	snd = RLPF.ar(snd, XLine.kr([1520, 1820], [820, 3200], duration), 0.05);
	snd = snd.sum;
	snd = snd.tanh;
	snd = snd * (1 + (10 * Env.perc(0.001, 0.01).ar));
	snd = snd * Env.linen(0.0, duration, 0.001).ar(Done.freeSelf);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -15.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\vocal2, {
	var snd, duration;
	duration = 0.08;
	snd = Pulse.ar(50);
	snd = RLPF.ar(snd, XLine.kr([820, 3200], [1520, 1820], duration), 0.05);
	snd = snd.sum;
	snd = snd.tanh;
	snd = snd * (1 + (10 * Env.perc(0.001, 0.01).ar));
	snd = snd * Env.linen(0.0, duration, 0.001).ar(Done.freeSelf);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -15.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\ressquares,{|out= 0 freq = 440 amp = 0.01 gate=1 cutoff=800 rq=0.1 pan=(-0.1)|

	var pulse, filter, env;

	//2 cents detune for second oscillator
	pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

	filter =  BLowPass.ar(pulse,100+cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.25,0.1,\dur.kr(1),0.2),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp*0.5,pan));

}).add;

SynthDef(\fmPluck, { |out = 0, freq = 440, dur = 1, amp = 0.5, gate = 1|
	var carrier = SinOsc.ar(freq);
	var modulator = SinOsc.ar(freq * 2);
	var envelope = Env.perc(0.25, dur*\blur.kr(1)).kr(gate, doneAction: Done.freeSelf);

	modulator = modulator * envelope * 50;  // The envelope and modulation index (100 here) affect the 'brightness' of the sound
	carrier = SinOsc.ar(freq + modulator) * envelope * -8.dbamp;

	Out.ar(out, (carrier * amp).dup);
}).add;

SynthDef(\kick, {
	var snd;
	snd = SinOsc.ar(
		60
		* ([-1, 1] * 0.3).midiratio
		* (1 + (3 * Env.perc(0.0, 0.05, curve: -4).ar))
		* (1 + (0.5 * Env.perc(0.001, 0.4, curve: -4).ar))
	);
	snd = snd * (1 + (5 * Env.perc(0, 0.04).ar));
	snd = snd + (Env.perc(0.01, 0.03).ar * BPF.ar(Hasher.ar(Sweep.ar + [0, 1]), 3120, 0.5) * 3.dbamp);
	snd = snd + (Env.perc(0.001, 0.01).ar * BPF.ar(Hasher.ar(Sweep.ar + [2, 3]), 8120, 0.5) * 20.dbamp);
	snd = snd.tanh;
	snd = snd * Env.perc(0.001, 1.3).ar(Done.freeSelf);
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -6.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\snare, {
	var snd;
	snd = SinOsc.ar(
		230
		* [1, 2.3, 3.8, 4.8]
		* (1 + (0.3 * Env.perc(0.0, 0.05, curve: -4).ar))
		* (1 + (0.01 * Env.perc(0.0, 0.1, curve: -4).ar))
	);
	snd = snd * Env.perc(0, [1, 0.3, 0.1, 0.05]).ar;
	snd = snd * [0, -20, -25, -20].dbamp;
	snd = snd.sum;
	snd = snd + (Env.perc(0.02, 0.05).ar * BPF.ar(Hasher.ar(Sweep.ar + [0, 1]), 2120, 0.5) * 15.dbamp);
	snd = snd * (1 + (5 * Env.perc(0, 0.01).ar));
	snd = snd * (1 + (5 * Env.perc(0, 0.001).ar));
	snd = (snd * 5.dbamp).tanh;
	snd = snd * Env.perc(0.0, 0.3, curve: -2.5).ar(Done.freeSelf);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -15.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\perc, {
	var snd;
	snd = SinOsc.ar(900 * \oct.kr(0).midiratio * (1.5 ** [0, 1, 2])).sum;
	snd = snd * (1 + (4 * Env.perc(0, 0.01).ar));
	snd = snd * Env.perc(0.001, 0.1).ar;
	snd = snd + GVerb.ar(snd * -15.dbamp, 10);
	snd = snd * Env.perc(0.0, 1).ar(Done.freeSelf);
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -16.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\perc2, {
	var snd;
	snd = SinOsc.ar(420 * \oct.kr(0).midiratio * (1.5 ** [0, 1, 2])).sum;
	snd = snd * (1 + (4 * Env.perc(0, 0.01).ar));
	snd = snd * Env.perc(0.001, 0.05).ar;
	snd = snd + Latch.ar(GVerb.ar(snd * -15.dbamp, 3), Impulse.ar(8320));
	snd = snd * Env.perc(0.0, 0.5).ar(Done.freeSelf);
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -16.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\glitch1, {
	var snd;
	snd = Hasher.ar(Sweep.ar(Impulse.ar(7235)) + [0, 1]);
	snd = snd * Env([0, 5, 0.1, 0], [0, 0.1, 1]).ar(Done.freeSelf);
	snd = snd.clip2;
	snd = FreqShift.ar(snd, 310);
	snd = HPF.ar(snd, 1120);
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -15.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\glitch2, {
	var snd;
	snd = SinOsc.ar(60);
	snd = snd - Latch.ar(snd, Impulse.ar(3213 * [1, 1.5]));
	snd = snd * 10.dbamp;
	snd = snd * Env([0, 5, 1, 1, 5, 0], [0.001, 0.001, 0.2, 0.001, 0.001]).ar(Done.freeSelf);
	snd = snd.clip2;
	snd = Balance2.ar(snd[0], snd[1], \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -8.dbamp;
	Out.ar(\out.kr, snd);
}).add;

SynthDef(\fx, {
	var snd, trigger;
	// trigger = \trigger.tr;
	trigger = 1;
	snd = In.ar(\out.kr, 2);
	snd = midSides.(snd);
	5.do {
		snd = snd + DelayC.ar(snd * -8.dbamp, 0.2, { TRand.kr(1e-3, 20e-3, trigger) } ! 2);
	};
	snd = snd * ((Impulse.ar(TExpRand.ar(100, 16000, T2A.ar(trigger))) * 2) - 1);
	snd = snd.collect { |snd|
		snd = FFT(LocalBuf(1024), snd);
		snd = PV_MagAbove(snd, TRand.kr(0.5, 5, trigger));
		snd = IFFT.ar(snd);
	};
	snd = midSides.(snd);
	snd = BHiShelf.ar(snd, 3201, 1, -5);
	snd = Limiter.ar(snd);
	ReplaceOut.ar(\out.kr, snd);
}).add;

SynthDef(\apadMH, {
	arg
	//Standard Values:
	out = 0, pan = 0, freq = 880, amp = 0.06, att = 0.4, dec = 0.5, sus = 0.8, rel = 0.5, gate = 1,
	//Other Controls:
	vibratoRate = 4, vibratoDepth = 0.015, tremoloRate = 5,
	//These controls go from 0 to 1:
	tremoloDepth = 0.5, reverbMix = 0.5, roomSize = 1, damp = 0.5;

	var env, snd, vibrato, tremolo, mod2, mod3;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate);
	vibrato = SinOsc.kr(vibratoRate).range(freq * (1 - vibratoDepth), freq * (1 + vibratoDepth));
	tremolo = LFNoise2.kr(1).range(0.2, 1) * SinOsc.kr(tremoloRate).range((1 - tremoloDepth), 1);

	snd = SinOsc.ar(freq: [freq, vibrato], mul:(env * tremolo * amp)).distort;
	snd = Mix.ar([snd]);
	snd = FreeVerb.ar(snd, reverbMix, roomSize, damp);

	DetectSilence.ar(snd, 0.0001, 0.2, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata:(
	credit: "Mike Hairston",
	tags: [\pad, \vibrato, \sustained]
)
).add;
SynthDef(\pad, {
	var snd, freq;
	freq = \freq.kr(60);
	snd = Saw.ar(freq);
	snd = DelayN.ar(snd, 0.01, { Rand(0, 0.005) } ! 4);
	snd = RLPF.ar(snd, LFNoise2.kr(1 ! 4).exprange(500, 1200), 0.1);
	snd = Splay.ar(snd);
	snd = LPF.ar(snd, 3000);
	snd = snd * Env.asr(0.3, 1, 1).ar(Done.freeSelf, \gate.kr(1));
	snd = snd * -3.dbamp;
	snd = snd * \amp.kr(0.01);
	Out.ar(\out.kr(0), snd);
}).add;
)

// Synth(\ressquares)
~tempo = TempoClock.new(92/60);
(
Routine({
	var p_scale = 1;
	var prol = [6,4,5,3,1,7,2,8].nthPrime*p_scale;
	var maxP = max(prol);  // calculate maximum of prol array
	var reg_seq = (Pinf(0,1)*12).asStream;
	// var inst = Pseq([\vocal2, \glitch1, \kick, \fmPluck, \perc, \vocal, \glitch2, \perc2, \fmPluck, \snare].scramble,1).asStream;
	var inst = Pseq([\fmPluck,\apadMH,Pseq([\perc, \perc2, \vocal],1),\glitch1],inf).asStream;
	var marker = Pseq([\marker1, \marker4, \marker1, \marker3],inf).asStream;
	var interval = Pseq([0.6667, 1.333, 1.833, 2],inf).asStream;
	var fx;
	prol.do{ |p, i|
		var reg = reg_seq.next;
		var synth = inst.next;
		var mrk_synth = marker.next;
		var int_scale = interval.next;
		// if(synth==nil,
		// 	{ synth = \default },
		// 	{}
		// );
		reg = reg.fold(-36, 48);
		("VOICE " ++ (i+1) ++ " p: " ++ p ++ " reg: " ++ reg ++ " inst: " ++ synth).postln;
		s.bind { Synth(mrk_synth, [freq: 66.midicps, ratio: 1.8333, amp: -16.dbamp]) };
		Pbind(
			\instrument, synth,
			// \dur, Autoref(prol.copySeries(i%7, 7).rotate(-1*i), 1),
			\dur, Autoref(prol.rotate(-1*i), 1),
			\freq, (66 + reg /*+ Pdup(prol.size, (Pinf(0,3)*3.86))*/ + (Pinf(0,39)*int_scale)).midicps,
			\pan, Pbrown(-1,1,0.16667),
			// \mu, 1.0 - (p / maxP),  // Normalize p to range [0,1] and subtract from 1
			\amp, (-3 - (p*0.3)).dbamp,
			// \blur, Pfunc({
			// 	if(synth==\fmPluck,
			// 		{1 + (1*(p / maxP))},
			// 		{1},
			// 	)
			// }),
			// \out, Prand([0, \fx]),
		).play(~tempo, quant:1);
		p.wait;
	};
}).play(~tempo, quant:1);
)

s.meter;