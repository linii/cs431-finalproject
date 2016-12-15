// Instruments output arrays of tuples. Each tuple is of the form [time, pos, dur], and represents
// an individual grain of sound.
//
// 'time' is the number of seconds after the instrument is triggered to play the grain
// 'pos' is where the grain starts within the sample, expressed in relative terms. 0.0 is the beginning
//      of the sample, and 1.0 is the end
// 'dur' is the length of the grain, in seconds

// Plays 5 grains of successively longer lengths and positions within the sample
var defaultScore = Array.fill(5, {|i| [(i+1)/5, (i+1)/5, (i+1)/5]});

// Creates an accelerando effect by playing grains closer to each other as time goes on
var exponentialDecay = Array.fill(100, {|i| [exprand(0.01, 1), i/100, 1.0]});

// Over the course of 10 seconds, play a grain repeatedly with a duration of one second,
// to create a cloudy effect
var long = Array.fill(100, {|i| [10*i/100, 0.5, 1.0]});

// Play random positions within the grain over the course of 3 seconds,
// each grain is will be one of three different lengths, chosen at random
var randomcloud = Array.fill(20, {|i| [3.0*i/20, 1.0.rand, [0.01, 0.05, 0.25].choose]});

// Similar to 'exponentialDecay'
var zip = {Array.fill(20, {|i| [1 - (1/2.pow(i)), 1.0.rand, 0.5]})};

// Select two positions within a grain. Play them at similar intervals that gradually
// diverge from one another.
var zipper = {
	var s1 = 1.0.rand;
	var s2 = 1.0.rand;
	var zip1 = Array.fill(10, {
		|i|
		[2 - (2/3.pow(i/2)), s1, 0.5]
	});
	var zip2 = Array.fill(10, {
		|i|
		[2.2 * (2 - (1/3.pow(i/2))) + 0.2, s2, 0.5]
	});
	(zip1 ++ zip2);
};

// Similar to 'zipper', but the interval between identical grains is linear, instead of
// inverse exponential
var linearZipper = {
	var s1 = 1.0.rand;
	var s2 = 1.0.rand;
	var zip1 = Array.fill(50, {
		|i|
		[i*0.3, s1, 0.1]
	});
	var zip2 = Array.fill(50, {
		|i|
		[i*0.2, s2, 0.1]
	});
	(zip1 ++ zip2);
};

// Play a grain for gradually longer periods of time
var lengthen = {
	var s1 = 1.0.rand;
	Array.fill(20, {
		|i|
		[0.1*i, s1, 0.1*i]
	});
};

// Play a bunch of grains, each starting a little farther along in their sample
var seek = {
	var offset = 0.5.rand;
	Array.fill(20, {
		|i|
		[0.1*i, offset+(0.5*i/20), 0.5]
	});
};
// an Instrument "class" implemented using a Supercollider environment.

~instrument = {
	|score|
	(
		score_: score,

		// Debug function to print information about the sample
		debug_: {
			|self|
			"id:".post;
			self.id_.post;

			" score:".post;
			self.score_.post;

		}
	)
};


// ------------------------------------------------------------------
// Final Instruments list

~instrument1 = ~instrument.(defaultScore);
~instrument2 = ~instrument.(exponentialDecay);
~instrument_long = ~instrument.(long);
~instrument4 = ~instrument.(randomcloud);
~instrument5 = ~instrument.(zip);
~instrument_zipper = ~instrument.(zipper);
~instrument_linearzipper = ~instrument.(linearZipper);
~instrument_lengthen = ~instrument.(lengthen);
~instrument_seek = ~instrument.(seek);