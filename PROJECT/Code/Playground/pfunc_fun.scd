~edo_72 = Scale.new((0..71).collect { |i| i / 72.0 });

(
Pbind(
	\instrument, \default,
	// \dur, Prand([0.125, 0.25, 0.5, 1], inf),
	\dur, Prand([0.125, 0.25], inf),
	\degree, Pseq((0..71).scramble, inf) + 0,
	\scale, ~edo_72,
).play;
)


~set_72edo = [0, 6, 29, 58, 23, 66, 54, 18, 66, 60, 52, 44, 36, 28, 20, 12, 4, 72];

(
~pbindFunc = Pfunc({
	Pbind(
		\instrument, \default,
		\dur, Prand([0.125, 0.25], inf),
		\degree, Prand(~set_72edo, inf),
		\scale, ~edo_72
	)
});
)

~pbindFunc.value.play;

