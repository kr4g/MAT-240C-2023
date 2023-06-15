Autoref : Pattern {
    var <>proportions, <>repeats;

    *new { |proportions, repeats=inf|
        ^super.newCopyArgs(proportions, repeats)
    }

    storeArgs { ^[proportions, repeats] }

    embedInStream { |inval|
        var i = 0;
        var repeatCount = 0;
        while { repeatCount < repeats } {
            while { i < proportions.size } {
                var totalDuration = proportions[i];
                var subdiv = proportions.collect { |x| totalDuration * (x / proportions.sum) };
                var j = 0;
                while { j < subdiv.size } {
                    inval = subdiv[j].yield;
                    j = j + 1;
                };
                i = i + 1;
            };
            i = 0;  // reset index for next repetition
            repeatCount = repeatCount + 1;
        };
        ^inval;
    }
}

Homothetia : Pattern {
	// maybe do this as a routine instead
}

Monnayages : Pattern {

}

