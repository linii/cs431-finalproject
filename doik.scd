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
	|synths, samples, direction, coord|

	// convert from paths to real samples
	var convSamples = List.new();

	// init length of grain
	var durBase = ~durBase;

	synths.postln;
	samples.postln;
	samples.size.postln;
	direction.postln;
	coord.postln;

	samples.do { |s|
		convSamples.add(~sample.(s));
	};

	// Increment UID counter and assign doik a UID.
	~id = ~id + 1;
	(
		// Unique identifier
		id_: ~id - 1,

		// Instrument/synth, aka grain definitions contained in doik
		instruments_: synths,

		// Samples that can be played in combo with a Synth
		samples_: convSamples,

		// durBase
		durBase_: durBase,

		// 0 (up) 1 (left) 2 (down) 3(right)
		direction_: direction,
		coords_: coord,

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
		d0 = doiks[0].samples_;
		doiks.size.do { |i, d|
			if (i == (doiks.size - 1), {
				doiks[doiks.size - 1].samples_ = d0;
			}, {
				doiks[i].samples_ = doiks[i+1].samples_;
			};
			);
			allDoiks.add(d);
		};

		// play each of the instruments in the collision
		doiks.do { |doik|
			doik.durBase_ = ~durMax.max(doik.durBase_ * ~durMultiplier);
			doik.instruments_.do { |inst|
				doik.samples_.do { |sample|
					{
						var b, bufnum;
						b = Buffer.read(s, sample.buf_); // assign to server
						bufnum = b.bufnum;
						~grains.do {
							x = Synth(\sfgrain,
								[
									\bufnum, bufnum,
									\startPos, inst.posFunc_.value[1], // todo: fix
									\amp, 0.3,
									\pan, 1,
									\dur, inst.durFunc_.value(doik.durBase_);
								]
							);
							0.01.rand.wait; // todo
						};
					}.fork;
				};
			};
		};
	});

	// For each doik that has collided with a wall:
	wallCollisions.do({
		|doik|
		doik.durBase_ = ~durMax.max(doik.durBase_ * ~durMultiplier);
		"New dur base".postln;
		doik.durBase_.postln;
		doik.instruments_.do { |inst|
			doik.samples_.do { |sample|
				{
					var b, bufnum;
					"reading into buffer".postln;
					sample.buf_.postln;
					b = Buffer.read(s, sample.buf_); // assign to server

					~grains * doik.durBase_.rand.do {
						x = Synth(\sfgrain,
							[
								\bufnum, b.bufnum,
								\startPos, rrand(0.0, 3), // todo: fix
								\amp, exprand(0.005, 0.1),   // random for now
								\pan, 1.0.rand,             // random for now
								\dur, inst.durFunc_.value(doik.durBase_);
							]
						);
						0.05.rand.wait;
					};
				}.fork;
			};
		};
	});
	allDoiks; // for easier processing in grid
};

/*~playInstWithSamples = {
|instruments, samples|
s.sync;
instruments.do { |inst|
samples.do { |sample|
inst.debug_;
sample.debug_;
30.do {
Synth(\sfgrain,
[
\bufnum, sample.buf_.bufnum,
\startPos, inst.posFunc_.value[1], // todo: fix
\amp, exprand(0.005,0.1),   // random for now
\pan, 1.0.rand,             // random for now
\dur, inst.durFunc_.value;
]
);
}
};
};
};*/



