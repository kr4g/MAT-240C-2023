(
SynthDef(\beep, {
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, \dur.kr(0.1)), doneAction: Done.freeSelf);
    sig = SinOsc.ar(\freq.ar(440), mul: env);
    sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth.new(\beep, [freq: rrand(440,1760), dur: 0.1]);

~me = NetAddr.new("127.0.0.01", NetAddr.langPort); // port 57120

~me.sendMsg('/test', 0.1);

(
o = OSCdef(\reciever, {
	|msg|
	msg.postln;
	Synth(\beep, [freq: rrand(440,1760), dur: msg[1]]);
}, '\test')
)

