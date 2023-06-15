// s.options.outDevice_("External Headphones");
s.options.outDevice_("MacBook Pro Speakers");
s.reboot;

s.meter;

s.quit;


~path = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/"
a = Buffer.read(s, ~path ++ "granCHatters_1.wav");
b = Buffer.read(s, ~path ++ "drone_1.wav");
c = Buffer.read(s, ~path ++ "liquid_swells_1.wav");

(
SynthDef.new(\stereo_randwipe, {
	arg bufA, bufB, rateA=1.0, rateB=1.0;
	var sigA, sigB, sig, chainA, chainB, chain;
	sigA = PlayBuf.ar(2, bufA, rate: rateA, startPos: 0, loop:1);
	sigB = PlayBuf.ar(2, bufB, rate: rateB, startPos: 0, loop:1);

	//array of two unique monophonic LocalBuf instances for each stereo signal
	//a stereo LocalBuf instance will not work!
	chainA = FFT({LocalBuf(4096)}!2, sigA);
	chainB = FFT({LocalBuf(4096)}!2, sigB);
	chain = PV_RandWipe(
		chainA,
		chainB,
		LFTri.kr(1/20,3).unipolar(1),
		Impulse.kr(1/10)
	);
	sig = IFFT(chain) * 0.5;
	sig = sig * Env.asr(0.01, 1, 4).kr(2, \gate.kr(1));
	Out.ar(\out.ir(0), sig);
}).add;
)

x = Synth(\stereo_randwipe, [\bufA, a, \bufB, c, \rateA, 1.0, \rateB, 1.0]);

x.set(\bufB, b);

x.set(\rateA, 2.0);
x.set(\rateB, 0.5);

x.set(\bufA, c);
x.set(\gate, 0);

s.meter;

{LFTri.kr(1/20, 3).unipolar(1)}.plot;