s.boot;

s.dumpOSC;

// --- SynthDefs
(
SynthDef(\poppy, {
    | out=0, freq=440, amp=0.1, pan=0 |

    var envelope = EnvGen.kr(Env.perc(0.001, 0.01), doneAction: 2);
    var signal = SinOsc.ar(freq) * envelope * amp;
    var panned = Pan2.ar(signal, pan);

    Out.ar(out, panned);
}).add;
)

(
SynthDef(\plucky, {
    | out=0, freq=440, amp=0.9, pan=0, scale=0.1 |

    var impulse = Impulse.ar(freq);
    var envelope = EnvGen.kr(Env.perc(0.001, scale), doneAction: 2);
    var signal = impulse * envelope * amp;
    var panned = Pan2.ar(signal, pan);

    Out.ar(out, panned);
}).add;
)

(
SynthDef(\paddy, {
    |amp=0.3, freq=440, out=0, pan=0, gate=1, atk=1, rel=2|
    var env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);
    var harmonics = [1, 2, 3, 4, 5, 6, 7];
    var amplitudes = [1, 0.5, 0.25, 0.125, 0.06, 0.03, 0.015];
    var sig = Mix(SinOsc.ar(freq * harmonics) * amplitudes);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef(\crackly, {
    | out=0, density=1, amp=0.1, pan=0 |

    var crackle = Dust.ar(density);
    var signal = crackle * amp;
    var panned = Pan2.ar(signal, pan);

    Out.ar(out, panned);
}).add;
)


// --- Helper funcs
(
~getSynthDef = {
    var x = Demand.kr(Impulse.kr(10), 0, ~mouseX);
    var y = Demand.kr(Impulse.kr(10), 0, ~mouseY);

    if (x < 0.5 && y < 0.5) { \poppy }
    else if (x >= 0.5 && y < 0.5) { \plucky }
    else if (x < 0.5 && y >= 0.5) { \paddy }
    else { \crackly }
};
)


// --- Ps

(
Pdef(\rhythm, Pbind(
	// \instrument, Pfunc({ ~getSynthDef.value }),
    \instrument, \poppy,
    \freq, Pexprand(200, 800, inf).round(25),
    \amp, 0.1,
    \pan, Pwhite(-1, 1, inf),
    \dur, Pwrand([0.125, 0.25, 0.5], [0.33, 0.47, 0.2], inf),
    \legato, 0.1
)).play;
)


// --- Routines

~mouseX = 0;
~mouseY = 0;
(
Routine.run({
    var updateMousePos;
    updateMousePos = {
        ~mouseX = MouseX.kr(0, 1);
        ~mouseY = MouseY.kr(0, 1);
    };
    while {true} {
        updateMousePos.value;
        0.1.wait;
    };
});
)

