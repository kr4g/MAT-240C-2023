

(
// Initialize UT object
~~utObject = UT.new(1, [1, 2, 3], 60); // For example, tempus=1, prolationis=[1,2,3], tempo=120

// Set new values
~utObject.tempus_(2);
// ~utObject.prolationis_([2, 3, 4]);
// ~utObject.tempo_(140); // Notice that tempo changes will also affect tempoClock internally

// Check type
Post << ~utObject.checkType << "\n";

// Calculate denom
Post << ~utObject.calc_denom << "\n";

// Dump object
~utObject.dump;


~utObject.postTimeblockAndBeat;
)

[1,2,3].rotate();

~p = Pinf(0,1).asStream;
~p.next;

[191,72,41,96,23,54,120].do{ |x| x.abs.nthPrime.postln; };