UT {
	var <tempus, <prolationis, <tempo;
	*new { arg tempus=1, prolationis=[], tempo=60;
		^super.newCopyArgs(tempus, prolationis, tempo)
	}

	// SETTERS
	tempus_ { arg val; tempus = val; }
	prolationis_ { arg val; prolationis = val; }
	tempo_ { arg val; tempo = val; }

	// UT TYPECHECK
	checkType {
		if(this.prolationis.isNil || this.prolationis.isEmpty) {
			if(this.tempus > 0) {
				^"absolute (duration)";
			} {
				^"absolute (rest)";
			};
		} {
			if(this.tempus == this.prolationis.sum) {
				^"simple";
			} {
				^"complex";
			};
		};
	}

	// Determines default metric denominator when one is not specified.
	// Basically, the default denom is whatever value expresses the `prolationis` without having to use tuplets.
	// I dont like this being here.
	calc_denom {
		var fractionsSum = 0;
		prolationis.do{ |p|
			fractionsSum = fractionsSum + (tempus / p);
		};
		^fractionsSum.round.asInteger
	}

	// String representation
	asString {
		^"a Temporal Unit\n";
	}

	dump {
		var str;
		str = "Temporal Unit\n";
		str = str ++ "Tempus: " ++ tempus;
		str = str ++ "\nProlationis: " ++ prolationis.join(", ");
		str = str ++ "\nTempo: " ++ tempo;
		str = str ++ "\nMeter: " ++ tempus ++ "//" ++ this.calc_denom;
		str.postln;
	}
}
