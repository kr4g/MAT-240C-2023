// Ryan Millett
// from starter code by Eli Fieldsteel:
// https://www.youtube.com/watch?v=wC-bj7Ajvhs&ab_channel=EliFieldsteel

// -------------------------------- //
// ------ TEMPLATE STRUCTURE ------ //

// 1. server config
// 2. initialize global variables
// 3. define piece-specific functions
// 4. register functions with ServerBoot/Quit/Tree
// 5. boot server
// 6. anything else requiring a booted server
().play;
(
// -------------------------------- //
// 1. server config
ServerTree.removeAll;

// s = Server.local;
// ServerOptions.devices;
s.options.outDevice_(
	"MacBook Pro Speakers"
	// "External Headphones"
	// "Scarlett 4i4 USB"
	// "LG TV"
);
// s.options.inDevice_("Built-in Microph");
// s.options.numOutputBusChannels_(2);
// s.options.numInputBusChannels_(2);
// s.options.sampleRate_(48000);
// s.options.memSize_(2.pow(20));

s.newBusAllocators; // for Step 3.
~reverbBus = Bus.audio(s, 2);

// -------------------------------- //
// 2. initialize global variables

~count = 0;
~prol_P = ([7,6,11,5,6]);
// ~prol_P = [11, 3, 5, 13, 2, 7, 1, 17];
// ~prol_P = [3, 5, 11, 2, 7, 13];
~prol_I = ~prol_P.invert;
// ~prol_I = (~prol_I * (~prol_P.sum/~prol_I.sum));  // normalize

// -------------------------------- //
// 3. define piece-specific functions

~makeNodes = {
	s.bind({
		~fxGroup = Group.new;
		~reverb = Synth(\reverb, [\in, ~reverbBus], ~fxGroup);
	});
};


/*~makeWavetables = {
// 10 wavetables with increasing complexity
~wt_sig = 10.collect({
arg i;
//random number of envelope segments
var numSegs = i.linexp(0,9,4,40).round;
Env(
//env always begins and ends with zero
//inner points are random from -1.0 to 1.0
[0]++({1.0.rand}.dup(numSegs-1) * [1,-1]).scramble++[0],

//greater segment duration variety in higher-index wavetables
{exprand(1,i.linexp(0,9,1,50))}.dup(numSegs),

//low-index wavetables tend to be sinusoidal
//high index wavetables tend to have sharp angles and corners
{[\sine,0,exprand(1,20) * [1,-1].choose].wchoose([9-i,3,i].normalizeSum)}.dup(numSegs)
).asSignal(1024);
});

//load into 10 buffers in wavetable format
~wt_buf = Buffer.allocConsecutive(10, s, 2048, 1, {
arg buf, index;
buf.setnMsg(0, ~wt_sig[index].asWavetable);
});
};*/

// Composition Events
~events = [
	// -------------------------------------------
	// EVENT 0:  SET PRECOMPOSITIONAL MATERIALS
	{
		// Set PROLATIONIS
		// prol_P = Prime Form
		// prol_I = Inverted Form (contour inversion -> ie `.invert`)

		// Select IFINITY INDICES
		// nthPrimes:
		// --- sequence of prime numbers (m..n) to be used for indexing the Infinity Series
		// Phase Series:
		// --- generators specifying a starting index and a stepsize
		// --- eg:
		//         ~p1 = Pinf(0, 17);
		//         ~p2 = Pinf(5, 17);
		~prol_P.postln;
		~prol_P.sum.postln;
		// ~prol_I.postln;
		// ~prol_I.sum.postln;
	},

	// -------------------------------------------
	// EVENT 1:  PULSE MATRICES
	{
		"EVENT 1\n".post;
		// UT Process 1:
		// prolSet = (prol_P, prol_I)
		// for each prol in prolSet:
		//     Routine{ AutoRef(prol, "pulse") }

		// Pitch Process 1:
		// Pulsating Infinity Cluster Drones

		// Sampler Process 1a:
		// Set, trigger A and B stereo buffers

		v = TempoClock.new(84/60);

		~r0 = { |seq, rot = 0, pitch = 60, inst = #[\default], pan = 0|
			Routine({
				var synth, c;
				/*s.bind{ Synth(\kick); };*/
				var inf_seq = Pinf(0,17).asStream;
				// var inf_seq = Pseq([0,6,7,4],inf).asStream;
				var p_rot = seq.rotate(rot);
				seq.do{ |p, i|
					var div = p_rot[i], syn = inst.choose;
					c = p/div;
					// s.bind { synth = Synth(\default, [pan: rrand(-1,1)]); };
					// p.postln;

					p.do{ // perform tuplet division
						// s.bind { synth.set(\freq, 11*(4)*p); };
						s.bind{ synth = Synth(syn, [freq: (pitch + (inf_seq.next*c)).midicps, pan: pan]); };
						(div/p).wait;
						s.bind { synth.set(\gate, 0); };
					};
					// s.bind { synth.set(\gate, 0); };
				};
			});
		};
		~center_pitch = 66;
		~regist = Pinf(0,1).asStream;
		Routine {
			~prol_P.size.do{ |i|
				// ("p1: " ++ i ++ " of " ++ ~prol_P.size).postln;
				var off = ~regist.next;
				var pitch = ~center_pitch + (off * 12);
				~r0.value(~prol_P, i + 2, pitch.fold(54,102), [\apadMH, \default, \trianglewavebells], rrand(-0.5,0.5)).play(v, quant:1);
				(~prol_P.sum).wait;
			};
		}.play(v, quant:1);
		Routine {
			~prol_P.size.do{ |i|
				var off = ~regist.next;
				var pitch = ~center_pitch + (off * 7.01);
				~r0.value(~prol_P, i + 1, pitch.fold(54,102), [\pad, \feedbackPad1], rrand(0.5,1)).play(v, quant:1);
				(~prol_P.sum).wait;
			};
		}.play(v, quant:1);
		Routine {
			~prol_P.size.do{ |i|
				var off = ~regist.next;
				var pitch = ~center_pitch + (off * 7.01);
				~r0.value(~prol_P, -1*i - 1, pitch.fold(54,102), [\pad, \feedbackPad2], rrand(-1,-0.5)).play(v, quant:1);
				(~prol_P.sum).wait;
			};
		}.play(v, quant:1);
	},

	// -------------------------------------------
	// EVENT 2:  SELF-GENERATING FRACTAL VARIATIONS
	{
		// UT Process 2:
		// for each prol in prolSet:
		//     Routine{ AutoRef(prol, "self") }

		t = TempoClock.new(54/60);
		u = TempoClock.new(54/60);

		// Regular Canon on 1-cycle AutoRef
		~r2 = Routine({
			var c = 3, pan = Pwhite(-1,1).asStream, edo_cycle = Pseq([96,72,36,18,9],inf).asStream;
			~prol_P.do{ |p, i|
				p.postln;
				(t.tempo).postln;
				(u.tempo).postln;
				~ut_p = ~ut_process_autoref.value(
					Pseq([\feedbackPad1, \feedbackPad2, \feedbackPad3].stutter(~prol_P.size),inf),
					// { if(i % 2 == 0) {rrand(\amTriangle, \default)} {\pulseMod}; }.value,
					~prol_P * c,
					(66+12).midicps,
					36,
					0,
					39,
					// Pseq([0,5,17].stutter(~prol_P.size),inf),
					// Pseq([1,2,5,17].stutter(~prol_P.size),inf),
					pan.next,
				).play(u, quant:1);
				// s.bind {
				// 	// Synth(\kick);
				// 	// u.tempo = u.tempo * 0.9195;
				// };
				(p*c).wait;
			}
		}).play(t, quant:1);

		// Pitch Process 2
		// Isorhythmic Infinity Segments

		// Sampler Process 1b:
		// Swap B buffer
	},

	// -------------------------------------------
	// EVENT 3:  GRANULATION BREAK
	{
		// UT Process 3:
		// Self-Scalar Oneshots
		// --- triggered at prol intervals

		// Pitch Process 3
		// Free Random Walk Indexing

		// Sampler Process 2:
		// Generate stratified, random stereo wipe events
	},

	// -------------------------------------------
	// EVENT 4:  INFINITY CANONS
	{
		// UT Process 4:
		// Prolation Canons

		// Pitch Process 4
		// Concurrent Infinity Phase Sequences

		// Sampler Process 2:
		// ...cont.
	},

	// -------------------------------------------
	// EVENT 5:  DISSOLUSION OF MATERIALS
	{
		// UT Process 1:
		//

		// Pitch Process 1
		//

		// Sampler Process 0:
		// rest
	},
];

s.waitForBoot({

	s.freeAll;
	Buffer.freeAll;

	s.sync;

	// -------------------------------- //
	// SYNTHDEFS

	SynthDef(\pad, {
		var snd, freq;
		freq = \freq.kr(60);
		snd = Saw.ar(freq);
		snd = DelayN.ar(snd, 0.01, { Rand(0, 0.005) } ! 4);
		snd = RLPF.ar(snd, LFNoise2.kr(1 ! 4).exprange(500, 1200), 0.1);
		snd = Splay.ar(snd);
		snd = LPF.ar(snd, 3000);
		snd = snd * Env.asr(0.3, 1, 1).ar(Done.freeSelf, \gate.kr(1));
		snd = snd * 6.dbamp;
		snd = snd * \amp.kr(0.01);
		Out.ar(\out.kr(0), snd);
	}).add;

	SynthDef(\apadMH, {
		arg
		//Standard Values:
		out = 0, pan = 0, freq = 880, amp = 0.1, att = 0.4, dec = 0.5, sus = 0.8, rel = 0.5, gate = 1,
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

	SynthDef(\spacetheremin,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 3 lfowidth= 0.5 cutoff= 4000 rq=0.25 lagTime=0.1 pan=0.0|

		var lfo, osc, filter, env;

		lfo = LFTri.kr(lforate+(LFNoise1.kr(5,0.3,0.3)),Rand(0,2.0));

		osc = Saw.ar((freq.lag(lagTime).cpsmidi+(lfo*lfowidth)).midicps,0.5);

		filter = BLowPass4.ar(osc,cutoff.lag(lagTime*4),rq);

		env = EnvGen.ar(Env.adsr(0.6,0.0,1.0,0.05),gate,doneAction:2);

		Out.ar(out,Pan2.ar(filter*env*amp.lag(lagTime*4),pan));

	}).add;

	SynthDef(\spacereverb,{|out =0 gate= 1 threshold= 0.1 amp=0.1|

		var a,c,z,y,in;
		var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

		c = 6; // number of comb delays
		a = 4; // number of allpass delays

		in=In.ar(out,2);

		// reverb predelay:
		z = DelayN.ar(in, 0.048,0.048);

		y=Mix.arFill(c,{CombL.ar(z,0.1,rrand(0.01, 0.1),5)});

		// chain of 4 allpass delays on each of two channels (8 total) :
		a.do({ y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });

		Out.ar(out,Pan2.ar(y,0)*env*amp);

	}).add;

	SynthDef(\trianglewavebells,{
		arg out = 0, pan = 0.0, freq = 440, amp = 0.05, gate = 1, att = 0.01, dec = 0.1, sus = 1, rel = 0.5, lforate = 10, lfowidth = 0.0, cutoff = 100, rq = 0.5;

		var osc1, osc2, vibrato, filter, env;
		vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
		osc1 = Saw.ar(freq * (1.0 + (lfowidth * vibrato)), 0.75);
		osc2 = Mix(LFTri.ar((freq.cpsmidi + [11.9, 12.1]).midicps));
		filter = RHPF.ar((osc1 + (osc2 * 0.5)) * 0.5, cutoff, rq);
		env = EnvGen.ar(
			envelope: Env.adsr(att, dec, sus, rel, amp),
			gate: gate,
			doneAction: 2);
		Out.ar(out, Pan2.ar(filter * env, pan));
	}).add;

	SynthDef(\laserbeam, {
		arg out = 0, pan = 0.0, freq = 440, amp = 0.1, att = 0.01, gate = 1;
		var snd, freqenv, ampenv;
		// frequency envelope
		freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [att, 0.01, 1.0]));
		// amplitude envelope
		// no gate: fixed-time envelope, self-terminating.
		ampenv = EnvGen.ar(
			envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
			levelScale: amp,
			gate: gate,
			doneAction: 2);
		snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
		Out.ar(out, Pan2.ar(snd, pan));
	}).add;

	SynthDef(\ressquares,{|out= 0 freq = 440 amp = 0.01 gate=1 cutoff=8000 rq=0.8 pan=(-0.1)|

		var pulse, filter, env;

		//2 cents detune for second oscillator
		pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

		filter =  BLowPass.ar(pulse,100+cutoff,rq);

		env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

		Out.ar(out,Pan2.ar(filter*env*amp,pan));

	}).add;

	SynthDef(\ressaws,{|out= 0 freq = 440 amp = 0.05 gate=1 cutoff=8000 rq=0.8 pan=(-0.1)|

		var pulse, filter, env;

		//2 cents detune for second oscillator
		pulse = Mix(Saw.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

		filter =  BLowPass.ar(pulse,100+cutoff,rq);

		env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

		Out.ar(out,Pan2.ar(filter*env*amp,pan));

	}).add;

	SynthDef(\synthdistortion, {|out =0 gate= 1|
		var source = In.ar(out,2);
		var env = Linen.kr(gate, 0.0, 1, 0.1, 2);
		var abs, excess,output;

		abs = source.abs;

		excess = (abs-0.1).max(0.0).min(0.9)/0.9;

		//original plus sinusoidal perturbation of amount based on absolute amplitude
		output = source+(excess*(sin(excess*2pi*5)*0.5-0.5));

		XOut.ar(out,env,output*env);

	}).add;

	SynthDef(\kick, {
		var snd;
		snd = (LFPulse.ar(30 * (1 + (8 * Env.perc(0.0, 0.1, curve: -3).ar))) - (1 / 2)).sign;
		snd = snd * Env.linen(0.0, \duration.kr(0.08), 0.0).ar(Done.freeSelf);
		snd = snd * \amp.kr(-10.dbamp);
		snd = Pan2.ar(snd, \pan.kr(0));
		OffsetOut.ar(\out.kr(0), snd);
	}).add;


	SynthDef(\chip, {
		var snd;
		snd = (LFPulse.ar(\freq.kr(440)));// * (2 ** LFPulse.ar(\octaveFreq.kr(3), 0.5))) - (1 / 2)).sign;
		snd = snd * Env.asr(0.0, 1, 0.0).ar(Done.freeSelf, \gate.kr(1));
		snd = snd * \amp.kr(-10.dbamp);
		snd = Pan2.ar(snd, \pan.kr(0));
		OffsetOut.ar(\out.kr(0), snd);
	}).add;

	SynthDef(\reverb, {
		var sig, wet;
		sig = In.ar(\in.ir(0), 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix:1, room:0.99, damp:0.99);
		sig = LPF.ar(sig, 900);
		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\feedbackPad1, {
		arg
		// Standard Values
		out = 0, amp = 1, gate = 1, freq = 75, pan = 0,
		// Controls for ampEnv
		att = 2, dec = 1, sus = 1, rel = 4, crv = 0,
		// Controls for fbEnv
		fbStartStop = 0, fbAtt = 3, fbPeak = 0.8, fbDec = 2, fbSus = 0.67, fbRel = 5,
		// Confrols for delEnv
		delStartStop = 0.55, delAtt = 1, delPeak = 0, delDec = 2, delSus = 0.25, delRel = 3.5;

		var snd, fbIn, fbOut, ampEnv, fbEnv, delEnv;

		// Set up the Envelopes
		ampEnv = Env.adsr(
			attackTime: att,
			decayTime: dec,
			sustainLevel: sus,
			releaseTime: rel,
			curve: crv).ar(gate: gate);

		fbEnv = Env.adsr(
			attackTime: fbAtt,
			decayTime: fbDec,
			sustainLevel: fbSus,
			releaseTime: fbRel,
			peakLevel: fbPeak,
			curve: \lin,
			bias: fbStartStop).ar(gate: gate);

		delEnv = Env.adsr(
			attackTime: delAtt,
			decayTime: delDec,
			sustainLevel: delSus,
			releaseTime: delRel,
			peakLevel: delPeak,
			curve: \lin,
			bias: delStartStop).ar(gate: gate);

		// Receive the feedback
		fbIn = LocalIn.ar;

		// The Sound (yup, that's all it is)
		snd = SinOsc.ar(
			freq: freq,
			phase: fbIn * pi);

		// Delay the feedback
		fbOut = DelayC.ar(
			in: snd,
			maxdelaytime: delStartStop.max(delPeak.max(delSus)),
			delaytime: delEnv,
			mul: fbEnv);

		// Send the feedback
		LocalOut.ar(fbOut);

		// Output Stuff
		snd = Mix.ar(snd) * ampEnv * amp;
		snd = Limiter.ar(snd);

		DetectSilence.ar(in: snd, doneAction: 2);

		Out.ar(out, Pan2.ar(snd, pan));
	},
	metadata: (
		credit: "Josh Mitchell",
		category: \pads,
		tags: [\pitched]
	)
	).add;

	SynthDef(\feedbackPad2, {
		arg
		// Standard Values
		out = 0, amp = 0.1, gate = 1, freq = 100, pan = 0,
		// Controls for ampEnv
		att = 1.5, dec = 0.1, sus = 1, rel = 1.75, crv = 0,
		// Controls for fbEnv
		fmStartStop = 0, fmAtt = 1, fmPeak = 5, fmDec = 0.5, fmSus = 2, fmRel = 1,
		// Other Controls (thresh goes from 0 to 1, polFlip is 0 or 1)
		thresh = 0.0075, polFlip = 1, del = 0.1, rq = 0.9, filterLo = 1500, filterHi = 5000;

		var snd, fbIn, polarity, fbOut, ampEnv, fmEnv;

		// Set up the Envelopes
		ampEnv = Env.adsr(
			attackTime: att,
			decayTime: dec,
			sustainLevel: sus,
			releaseTime: rel,
			peakLevel: amp,
			curve: crv).ar(gate: gate, doneAction: 2);

		fmEnv = Env.adsr(
			attackTime: fmAtt,
			decayTime: fmDec,
			sustainLevel: fmSus,
			releaseTime: fmRel,
			peakLevel: fmPeak,
			curve: \lin,
			bias: fmStartStop).ar(gate: gate);

		// Receive the feedback
		fbIn = LocalIn.ar;
		polarity = Schmidt.ar(
			in: fbIn,
			lo: -1 * thresh,
			hi: thresh) ;
		polarity = (polarity * 2) - 1;
		polarity = polarity * ((polFlip * -2) + 1);

		// Make The Sound
		snd = LFTri.ar(
			freq: Clip.ar(
				in: freq + (fbIn * fmEnv),
				lo: 30,
				hi: SampleRate.ir/2),
			mul: polarity
		);

		// Filter the Sound
		snd = RLPF.ar(
			in: snd,
			freq: LinExp.ar(
				in: ampEnv,
				srclo: 0, srchi: amp,
				dstlo: filterHi, dsthi: filterLo),
			rq: rq);

		// Delay the feedback
		fbOut = DelayC.ar(
			in: snd,
			maxdelaytime: del,
			delaytime: del,
			mul: 1);

		// Feedback the Sound
		LocalOut.ar(fbOut);

		// Output Stuff
		snd = Mix.ar(snd) * ampEnv;
		snd = Limiter.ar(snd);

		Out.ar(out, Pan2.ar(snd, pan));
	},
	metadata: (
		credit: "Josh Mitchell",
		category: \pads,
		tags: [\pitched]
	)
	).add;

	SynthDef(\feedbackPad3, {
		arg
		// Standard Values
		out = 0, amp = 0.15, gate = 1, freq = 100, pan = 0,
		// Envelope Controls
		att = 3, dec = 1, sus = 1, rel = 5, crv = 0,
		// Reverb Controls (all go from 0 to 1)
		reverbMix = 0.75, roomSize = 0.9, damp = 0.5,
		// Other Controls (interval is in semitones)
		sampleRate = 20, notes = 6, interval = 7;

		var env, fbIn, snd;

		// Set up the Envelopes
		env = Env.adsr(
			attackTime: att,
			decayTime: dec,
			sustainLevel: sus,
			releaseTime: rel,
			curve: crv).ar(gate: gate);

		// Receive and Sample the feedback
		fbIn = Latch.ar(
			in: (LocalIn.ar + 1)/2,
			trig: Impulse.ar(
				freq: sampleRate));
		fbIn = (fbIn * notes.abs * env).round(1);
		fbIn = (fbIn * interval).midiratio;

		// Make The Sound
		snd = LFTri.ar(
			freq: freq * fbIn,
			mul: env);

		// Feedback the Sound
		LocalOut.ar(snd);

		// Reverb the Sound
		snd = FreeVerb.ar(
			in:  snd,
			mix: reverbMix,
			room: roomSize,
			damp: damp);

		//Filter the Sound
		snd = RHPF.ar(
			in: snd,
			freq: freq,
			rq: 0.5);
		snd = LPF.ar(
			in: snd,
			freq: [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
			mul: 1/9);

		// Output Stuff
		snd = Mix.ar(snd) * amp;
		snd = Limiter.ar(snd);

		DetectSilence.ar(in: snd, doneAction: 2);

		Out.ar(out, Pan2.ar(snd, pan));
	},
	metadata: (
		credit: "Josh Mitchell",
		category: \pads,
		tags: [\pitched]
	)
	).add;

	s.sync;

	~bufPath = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "calibration_tone/";

	b = PathName.new(~bufPath).entries.collect({
		arg pathname;
		Buffer.read(s, pathname.fullPath);
	});

	s.sync;


	// -------------------------------- //
	// 4. register functions with ServerBoot/Quit/Tree

	ServerTree.add(~makeNodes);
	ServerTree.run;

	s.sync;

	// -------------------------------- //
	// PATTERN DEFS


	/*	~seq = (0..60) collect: _.infiniteNumber;


	~cluster = { |inst=\default, seq, freq=50, pan=0|
	var freqs = seq collect: (60 + _).midicps;
	var scale = Scale.new((0..72), 72);
	Pbind(
	\instrument, \default,
	\scale, scale,
	\dur, 1,
	\freq, ,
	);
	};*/

	~ut_process_autoref = { |inst=\default, prol, freq=50, edo=12, start=0, step=1, pan=0|
		// var edo_cycle = Pseq([6,9,18,36,72],inf);
		var scale = Scale.new((0..edo), edo);
		Pbind(
			\instrument, inst,
			\scale, scale,
			\dur, Autoref(prol, 1),
			\amp, 0.05,
			\freq, (freq.cpsmidi + (Pinf(start, step) * scale.tuning.at(1))  + Pseq([0,7,-7,0,28,-28,0,14,-14].stutter(prol.size),inf)).midicps,
			\pan, pan,
			// \out, 0,
			\out, ~reverbBus,
		);
	};

	~sampPat = Pbind(
		\instrument, \samp,
		\dur, 1/8,
		\type, Pwrand([\note, \rest], [0.6, 0.4], inf),
		\buf, Prand(b, inf),
		\rate, Pwhite(-12, 12, inf).midiratio,
		\amp, Pexprand(0.02, 0.5, inf),
		\atk, 0,
		\sus, 0,
		\rel, Pexprand(0.02, 0.5, inf),
		\out, 0,
		\outfx, ~reverbBus,
		\send, Pwhite(-40, -10, inf),
	);

	~beepPat = Pbind(
		\instrument, \beep,
		\dur, 2,
		\atk, 0,
		\sus, 0.02,
		\rel, 0.02,
		\freq, 1000,
		\amp, Pexprand(0.02, 0.2, inf),
		\pan, Pseq([-1, 0, 1, 0],inf),
		\out, 0,
		\outfx, ~reverbBus,
		\send, -10,
	);

	~dronesPat = Pbind(
		\instrument, \beep,
		\dur, 5,
		\atk, 4,
		\sus, 0,
		\rel, 4,
		\freq, Pexprand(150,300,inf) * Pfuncn({Array.rand(16, -1.0, 1.0).midiratio}, inf),
		\amp, 0.02,
		\out, 0,
		\outfx, ~reverbBus,
		\send, -10,
	);

});
)

s.meter;

s.record();
~prol_P;
~events[1].value;  // Proportion Matrix
~events[2].value;  // Autogenerative Canon by Self-Reference
s.stopRecording;