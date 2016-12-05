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
		// Should be randomized
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

~allInsts = [~instrument.(\sfgrain, ~simplePos, ~simpleDur)];


// ------------------------------------------------------------------
// example position functions, make your own!

~simplePos = {
	[ [0, 1].choose, 10.rand ]; // todo: how does startPos interact with BufFrames
};


// ------------------------------------------------------------------
// example duration functions, make your own!

~simpleDur = {
	|durBase|
	0.01;
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