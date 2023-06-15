/////////////////////////////////
// PER NØRGÅRD INFINITY SERIES //
/////////////////////////////////

/* Write n in binary and read from left to right, starting with 0 and interpreting 1 as "add 1" and 0 as "change sign". For example 19 = binary 10011, giving 0 -> 1 -> -1 -> 1 -> 2 -> 3, so a(19) = 3. */

///////// FUNCTIONS /////////////

( // start funcs

// RETURN INTEGER IN INFINITY SERIES BY INDEX:
// max index = 4.29 billion (32 bit maximum)

~norgardInteger = {
	arg n;
	var binary = n.asBinaryDigits(32); // 4.29 billion max
	var tempOutput = 0;
	var output;
	binary.do({
		arg item;
		case
		{item == 0} {tempOutput = tempOutput * -1}
		{item == 1} {tempOutput = tempOutput + 1}
	});
	output = tempOutput;
	output;
};

// GENERATE SUBSET OF INF SERIES (ARRAY) BY START AND ENDING INDICES:
// N.B.: struggles with subsets longer than 100k

~norgardArray = {
	arg start, end;
	var length = end-start+1;
	var infinityArray = Array.newClear(length);
	for(start, end, {arg i; infinityArray.put(i-start, ~norgardInteger.value(i))});
	infinityArray;
}
) // end funcs

// EXAMPLE:
// start, end:
~norgardArray.value(0, 3); // -> [ 0, 1, -1, 2 ]

~test = Scale.new((0..72), 72);
~test.tuning.at(0);



(
SynthDef(\bpfsaw, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, detune=0.0, pan=0, cfhzmin=0.1, cfhzmax=0.3, cf=1500, rq=0.2, cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, lsf=200, ldb=0, out=0|
	var sig, env;
	env= EnvGen.kr(Env([0,1,1,0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	// sig = Balance2.ar(sig[0], sig[1], pan);

	sig = sig * env * amp;
	sig = Splay.ar(sig);
	Out.ar(out, sig);
}).add;
)


(
var edo = 27;
var scale = Scale.new((0..edo), edo);

var pbrownSeq = Pseq((0..256), inf).asStream;
// var pbrownSeq = Pbrown(0, 256, 1).asStream;

var len = 11;
var seqArray = [];
len.do{ seqArray = seqArray.add(pbrownSeq.next) };

~degs = seqArray.collect({ |index| ~norgardInteger.value(index) });

~degs.postln;

Pbind(
	\instrument, \bpfsaw,
	\scale, scale,
	// \degree, Pseq(~degs, 1) + (1 * scale.size),
	\freq, (Pseq(~degs, inf) * scale.tuning.at(1) + 84).midicps,
	\dur, Pseq([3,1,7,5,11,2], 9) * 0.67,
	\atk, 0,
	\sus, 1,
	\rel, 6,
	\cf, \freq,
	\rqmin, Pwhite(0.01, 0.33),
	\rqmax, Pwhite(\rqmin, 0.667),
	\pan, Pbrown(-1,1,0.001),
).play;
)



(
var edo = 24;
var scale = Scale.new((0..edo), edo);

// var pbrownSeq = Pseq((0..256), inf).asStream;
var pbrownSeq = Pbrown(0, 256, 1).asStream;

var len = 11;
var seqArray = [];
len.do{ seqArray = seqArray.add(pbrownSeq.next) };

~degs = seqArray.collect({ |index| ~norgardInteger.value(index) });

~degs.postln;
(
r = Routine.new({
	var atk, sus, rel, oct;
	atk = Pwhite(0.1,0.3);
	sus = 0.5;
	rel = 2;
	oct = Prand([48,60,72,84,96],inf);
	[11,7,5,2].normalizeSum.scramble.do({ |n|
		Pbind(
			\instrument, \bpfsaw,
			\scale, scale,
			// \degree, Pseq(~degs, 1) + (1 * scale.size),
			\freq, (Pseq(~degs, inf) * scale.tuning.at(1) + ~oct + n).midicps,
			\dur, Pseq([3,1,7,5,11,2], 9) * (3*n),
			\atk, atk,
			\sus, sus,
			\rel, rel,
			\cf, \freq,
			\rqmin, Pwhite(0.01, 0.33),
			\rqmax, Pwhite(\rqmin, 0.667),
			\pan, Pbrown(-1,1,0.001),
		).play;
		n.postln;
		(n*100).wait;
	});
}).play;

)


)

s.meter;

thisThread.beats % 50;
(
~beatFloat = thisThread.beats % 50;
// "Beat (float): ".post;
// ~beatFloat.postln;

~beatInt = ~beatFloat.round.asInteger; // Rounds to nearest whole number
// "Beat (int): ".post;
~beatInt.postln;
~norgardInteger.value(~beatInt);
)

~beatInt;







