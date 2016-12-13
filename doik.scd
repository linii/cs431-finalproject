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

		Out.ar(0,Pan2.ar(grain, pan))
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

		// Samples that can be played in combo with a Synth
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
	doikCollisions.do({ |doiks|
		// do the swapping:
		// the samples of doik[i] gets swapped with doik[i+1]
		// last one gets wrapped around
/*		d0 = doiks[0].samples_;
		doiks.size.do { |i, d|
			if (i == (doiks.size - 1), {
				doiks[doiks.size - 1].samples_ = d0;
			}, {
				doiks[i].samples_ = doiks[i+1].samples_;
			};
			);
			allDoiks.add(d);
		};*/

		// play each of the instruments in the collision
/*		doiks.do { |doik|
			doik.durBase_ = ~durMax.min(doik.durBase_ * ~durMultiplier);
			doik.instruments_.do { |inst|
				doik.samples_.do { |sample|
					if (sample != nil) {
						{
							~grains.rand.do {
								x = Synth(\sfgrain,
									[
										\bufnum, sample.buf_,
										\startPos, inst.posFunc_.value[1], // todo: fix
										\amp, exprand(0.005, 0.1),
										\pan, doik.coords_[0]/10,
										\dur, inst.durFunc_.value(doik.durBase_);
									]
								);
								~waitTime.rand.wait; // todo
							};
						}.fork;
					};
				};
			};
		};*/
	});
	// For each doik that has collided with a wall:
	wallCollisions.do({
		|doik|
		var notes = if (doik.instrument_.score_.isFunction, {doik.instrument_.score_.value},{doik.instrument_.score_});
			notes.do { |note, idx|
				SystemClock.sched(note[0], {
					x = Synth(\sfgrain,
						[
							\bufnum, doik.sample_,
							\startPos, note[1],
							\amp, exprand(0.005, 0.1),
							\dur, note[2],
						]
					);
				});
			};
	});
	allDoiks; // for easier processing in grid
};



