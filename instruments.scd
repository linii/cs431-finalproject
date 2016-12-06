// an Instrument "class" implemented using a Supercollider environment.

~instrument = {
	arg synthdef=\sfgrain, posFunc=~simplePos, durFunc=~simpleDur;

	~id = ~id + 1; // assign sample an id

	(
		id_: ~id - 1,

		// GRAIN DEFINITION: SynthDef + Pos + Dur (+ Amp + Pan_

		synthDef_: synthdef,

		// A function that returns a relative start positions within a sample
		// A position is a pair [0|1, #], where 0 means from start of sample, and
		// 1 is from end of sample
		// Should be randomized
		posFunc_: posFunc,

		// A function that returns the duration of the grain.
		// Should be randomized to some extent
		durFunc_: durFunc,

		// Debug function to print information about the sample
		debug_: {
			|self|
			"id:".post;
			self.id_.post;

			" synthDef:".post;
			self.synthDef_.post;

			" posFunc:".post;
			self.posFunc_.post;

			" durFunc:".post;
			self.durFunc_.post;
		}
	)
};


// ------------------------------------------------------------------
// sample instruments... pretty uninspiring thus far

~instrument1 = ~instrument.();
~instrument2 = ~instrument.(\bufgrain);
~allInsts = [~instrument1];


// ------------------------------------------------------------------
// example position functions, make your own!

~simplePos = {
	[ [0, 1].choose, ~minLength.rand ]; // todo: how does startPos interact with BufFrames
};


// ------------------------------------------------------------------
// example duration functions, make your own!

~simpleDur = {
	|self, durBase|
/*	"\n\nreceived".postln;
	durBase.postln;
	"other".post;
	other.postln;*/
	durBase;
};


// ------------------------------------------------------------------
// example SynthDefs

// Basic grain
// Source: http://composerprogrammer.com/teaching/supercollider/sctutorial/5.2 Granular Synthesis.html

SynthDef(\sfgrain,
	{arg bufnum = 0,
		pan = 0.0,
		startPos = 0.0,
		amp = 0.1,
		dur = 0.01;

		var grain;

		grain = PlayBuf.ar(
			numChannels:2,
			bufnum:bufnum,
			rate:BufRateScale.kr(bufnum),
			trigger:1,
			startPos: BufFrames.ir(bufnum) *  startPos,
			doneAction: 0
		) * (EnvGen.kr(Env.perc(0.01, dur), doneAction:2) - 0.001);

		Out.ar(0,Pan2.ar(grain, pan))
}).add;

// Source: "http://quod.lib.umich.edu/cgi/p/pod/dod-idx/grancloud-a-new-supercollider-class-for-real-time-granular.pdf?c=icmc;idno=bbp2372.2006.015"

SynthDef(\bufgrain, {
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
}).add;