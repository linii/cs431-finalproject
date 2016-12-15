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


















// Source: "http://quod.lib.umich.edu/cgi/p/pod/dod-idx/grancloud-a-new-supercollider-class-for-real-time-granular.pdf?c=icmc;idno=bbp2372.2006.015"

/*SynthDef(\bufgrain, {
	// name grain arguments
	arg bufnum = 0,
	pan = 0.0,
	startPos = 0.0,
	amp = 0.1,
	dur = 0.04,
	out, // ???
	bufRate = 0.1,
	envCenter = 0.25.rrand(0.75),
	ffreq = 1,
	rq; // ???

	// define some variables
	var env, sound;
	// define an evelope that
	// changes shape based on
	// the envCenter argument
	env = EnvGen.kr(
		Env.new(
			[ 0, amp, 0 ],
			[ dur * envCenter,
				dur * (1 - envCenter)
			],
			// ’sine’
		),
		doneAction: 2
	);
	// read source from buffer,
	// start position and read rate
	// are based on parameters
	sound = PlayBuf.ar(
		1, bufnum,
		BufRateScale.kr(bufnum) * bufRate,
		1,
		BufFrames.kr(bufnum) * startPos,
		0
	);
	// apply the envelope to the sound
	sound = sound * env;
	// apply some filtering on the sound
	sound = BPF.ar(sound, ffreq, rq);
	// apply a spatial position
	sound = Pan2.ar(sound, pan);
	// write the output to a bus
	Out.ar(out, sound);
}).add;*/