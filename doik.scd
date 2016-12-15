// ------------------------------------------------------------------
// example SynthDefs

// Basic grain
// Source: http://composerprogrammer.com/teaching/supercollider/sctutorial/5.2 Granular Synthesis.html

SynthDef(\sfgrain,
	{arg bufnum = 0,
		pan = 0.0,
		startPos = 0.0,
		amp = 0.1,
		dur = 0.04;

		var grain;

		grain = PlayBuf.ar(
			numChannels:2,
			bufnum:bufnum,
			rate:BufRateScale.kr(bufnum),
			trigger:1,
			startPos: BufFrames.ir(bufnum) *  startPos,
			doneAction: 0
		) * (EnvGen.kr(Env.perc(0.01, dur), doneAction:2) - 0.001);

		Out.ar(0,Splay.ar([grain[0], grain[1]], 0.5, 1, pan));
}).add;


// ~id is a global counter that assigns each instantiated Doik a unique
// id. We increment it on the creation of a Doik.
~id = 0;

// a Doik "class" implemented using a Supercollider environment.
// Doiks are initialized with:
// 1. set of instrument
// 2. set of samples
// 3. starting direction
// 4. initial coordinate
~doik = {
	|instrument, sample_bufnum, direction, coords|


	// Increment UID counter and assign doik a UID.
	~id = ~id + 1;
	(
		// Unique identifier
		id_: ~id - 1,

		// Instrument/synth, aka grain definitions contained in doik
		instrument_: instrument,

		// Sample that can be played in combo with an instrument
		sample_: sample_bufnum,

		// 0 (up) 1 (left) 2 (down) 3(right)
		direction_: direction,
		coords_: coords,

		// These are all statistics collected on the doik as it moves through
		// the grid

		// Total number of times it's collided with any object
		count_: 0,

		// Total number of times it's collided with other doiks
		// reset on collision with grid
		count_since_wall_:0,

		// Number of grid iterations it's survived
		lifetime_: 0,

		// Debug function to print information about the doik
		debug_: {
			|self|
			"id:".post;
			self.id_.post;
			" d:".post;
			self.direction_.post;
			" (".post;
			self.coords_[0].post;
			",".post;
			self.coords_[1].post;
			")".post;
		}
	)
};

~onCollision = {
	// doikCollisions is a list of doiks that are in collision with other doik
	// (one chosen randomly out of each collision)
	// [ doikA, doikB, doikC, doikD, doikE, ...]
	// ex. access a doik's count
	// doikCollisions[i].count;
	// wallCollisions is list of doiks that have collided with a wall

	// note: these aren't mutually exclusive in the real case, but for
	// simplicity purposes if a doik-doik-wall collision occurs,
	// it counts as a wall collision.
	| doikCollisions, wallCollisions |
	var d0;
	var allDoiks;

	// For each set of doiks that has collided with another doik:
	doikCollisions.do({
		|doiks|
		// do the swapping:
		// the samples of doik[i] gets swapped with doik[i+1]
		// last one gets wrapped around
		doiks.size.do { |i, d|
			allDoiks = allDoiks.add(doiks[i]);
		};
	});

	// For each doik that has collided with a wall:
	wallCollisions.do({
		|doik|
		// Generate score if 'score_' is a function instead of an array
		var notes = if (doik.instrument_.score_.isFunction,
			{doik.instrument_.score_.value},
			{doik.instrument_.score_}
		);
		notes.do { |note, idx|
			// Schedule all notes for playback in the future
			SystemClock.sched(note[0], {
				x = Synth(\sfgrain,
					[
						\bufnum, doik.sample_,
						\startPos, note[1],
						\amp, exprand(0.005, 0.1),
						\dur, note[2],

						// Pan according to 'x' position on grid
						\pan, doik.coords_[0].linlin(0, d.size_-1, -1.0, 1.0)
					]
				);
			});
		};
	});
	allDoiks;
};

