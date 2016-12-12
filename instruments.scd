// Array of [time, pos, dur's]]
var defaultScore = Array.fill(5, {|i| [(i+1)/5, (i+1)/5, (i+1)/5]});

var exponentialDecay = Array.fill(100, {|i| [exprand(0.01, 1), i/100, 1.0]});

var long = Array.fill(100, {|i| [10*i/100, 0.5, 1.0]});

var randomcloud = Array.fill(1000, |i| [2*i/1000, 1.0.rand, 0.01]});

// an Instrument "class" implemented using a Supercollider environment.

~instrument = {
	|score|
	(
		id_: ~id - 1,

		score_: score.sort({|a, b| a[0] < b[0]}),

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