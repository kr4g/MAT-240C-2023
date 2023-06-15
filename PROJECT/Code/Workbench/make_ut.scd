(// create a function to generate a Pbind
~makePbind = { |inst, freq=440, pan=0|
	Pbind(
		\instrument, inst,
		\dur, Pseq(~prol_P, inf),
		\freq, freq,
		\pan, pan,
	);
};)

// usage
~ut_process_1a = ~makePbind.value(\default, 440, -1);
~ut_process_1b = ~makePbind.value(\kick, 432, 1);

~ut_process_1a.play;
~ut_process_1b.play;



~p = [1,2,3];

~p = Pseq(~p, 1).asStream;

~p.next

(

)