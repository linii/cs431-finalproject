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

	// Increment UID counter and assign doik a UID.
	~id = ~id + 1;
	(
		// Unique identifier
		id_: ~id - 1,

		// Instruments/synths, aka grain definitions contained in doik
		synths_: synths,

		// Samples that can be played in combo with a Synth
		samples_: samples,

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

	var direction, coordinates, count; // Holds props of the particular Doik under consideration

	var panningArray = Array.new(6); // Controls spatialization of note
	panningArray = [0, 0.7, 1, 0.7, 0, 1];

	// For each doik that has collided with another doik:
	doikCollisions.do({
		|doik|

		x =  Synth(\sfgrain,
			[
				\bufnum, b.bufnum,
				\startPos,rrand(timestart,timeend),
				\amp, exprand(0.005,0.1),
				\pan, lastval.rand2,
				\dur, 0.1+(lastval*0.5)
			]
		);
	});

	// For each doik that has collided with a wall:
	wallCollisions.do({
		|doik|
		direction     = doik.direction_;
		coordinates = doik.coords_;
		count          = doik.count_;

		x =  Synth(\sfgrain,
			[
				\bufnum, b.bufnum,
				\startPos,rrand(timestart,timeend),
				\amp, exprand(0.005,0.1),
				\pan, lastval.rand2,
				\dur, 0.1+(lastval*0.5)
			]
		);
	});
};

