// Array of [time, pos, dur's]]
var defaultScore = Array.fill(5, {|i| [(i+1)/5, (i+1)/5, (i+1)/5]});

var exponentialDecay = Array.fill(100, {|i| [exprand(0.01, 1), i/100, 1.0]});

var long = Array.fill(100, {|i| [10*i/100, 0.5, 1.0]});

var randomcloud = Array.fill(20, {|i| [0.5*i/20, 1.0.rand, [0.01, 0.05, 0.25].choose]});

var zip = {Array.fill(20, {|i| [1 - (1/2.pow(i)), 1.0.rand, 0.5]})};

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

var lengthen = {
	var s1 = 1.0.rand;
	Array.fill(20, {
		|i|
		[0.1*i, s1, 0.1*i]
	});
};

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
// sample instruments... pretty uninspiring thus far

~instrument1 = ~instrument.(defaultScore);
~instrument2 = ~instrument.(exponentialDecay);
~instrument_long = ~instrument.(long);
~instrument4 = ~instrument.(randomcloud);
~instrument5 = ~instrument.(zip);
~instrument_zipper = ~instrument.(zipper);
~instrument_linearzipper = ~instrument.(linearZipper);
~instrument_lengthen = ~instrument.(lengthen);
~instrument_seek = ~instrument.(seek);