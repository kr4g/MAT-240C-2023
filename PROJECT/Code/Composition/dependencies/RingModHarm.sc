SumDifferenceToneGenerator {

    *sumTonesWithModHarmonics { arg modPitch=60, carrierPitch=21, modHarmonics=5, mode='frequency';
        ^Array.fill(modHarmonics, {
            |i|
            if(mode=='frequency', {
                ((modPitch.midicps * (i+1)) + carrierPitch.midicps).abs.cpsmidi;
            }, {
                ((modPitch * (i+1)) + carrierPitch).abs;
            });
        })
    }

    *differenceTonesWithModHarmonics { arg modPitch=60, carrierPitch=21, modHarmonics=5, mode='frequency';
        ^Array.fill(modHarmonics, {
            |i|
            if(mode=='frequency', {
                ((modPitch.midicps * (i+1)) - carrierPitch.midicps).abs.cpsmidi;
            }, {
                ((modPitch * (i+1)) - carrierPitch).abs;
            });
        })
    }

    *sumDifferenceTonesWithModHarmonics { arg modPitch=60, carrierPitch=21, modHarmonics=5, mode='frequency';
        ^Array.fill(modHarmonics, {
            |i|
            if(mode=='frequency', {
                [
                    ((modPitch.midicps * (i+1)) + carrierPitch.midicps),
                    ((modPitch.midicps * (i+1)) - carrierPitch.midicps),
                ].abs.cpsmidi;
            }, {
                [
                    ((modPitch * (i+1)) + carrierPitch),
                    ((modPitch * (i+1)) - carrierPitch),
                ].abs;
            });
        })
    }

    *sumDifferenceTonesWithModCarrierHarmonics { arg modPitch=60, carrierPitch=21, modHarmonics=3, carrierHarmonics=2, mode='frequency';
        ^Array.fill(modHarmonics, {
            |i|
            Array.fill(carrierHarmonics, {
                |j|
                if(mode=='frequency', {
                    [
                        (modPitch.midicps * (i+1)) + (carrierPitch.midicps * (j+1)),
                        (modPitch.midicps * (i+1)) - (carrierPitch.midicps * (j+1))
                    ].abs.cpsmidi;
                }, {
                    [
                        (modPitch * (i+1)) + (carrierPitch * (j+1)),
                        (modPitch * (i+1)) - (carrierPitch * (j+1))
                    ].abs;
                });
            })});
    }
}
