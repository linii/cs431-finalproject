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
		[1 - (1/3.pow(i/2)), s1, 0.5]
	});
	var zip2 = Array.fill(10, {
		|i|
		[1.1 * (1 - (1/3.pow(i/2))) + 0.2, s2, 0.5]
	});
	(zip1 ++ zip2).sort({|a, b| a[0] < b[0]});
};

var linearZipper = {
	var s1 = 1.0.rand;
	var s2 = 1.0.rand;
	var zip1 = Array.fill(25, {
		|i|
		[i*0.2, s1, i*0.2]
	});
	var zip2 = Array.fill(25, {
		|i|
		[i*0.22, s1, i*0.2]
	});
	(zip1 ++ zip2).sort({|a, b| a[0] < b[0]});
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
~instrument3 = ~instrument.(long);
~instrument4 = ~instrument.(randomcloud);
~instrument5 = ~instrument.(zip);
~instrument_zipper = ~instrument.(zipper);
