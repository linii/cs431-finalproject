// ~id is a global counter that assigns each instantiated Doik a unique
// id. We increment it on the creation of a Doik.
~id = 0;

// a Doik "class" implemented using a Supercollider environment.
// Doiks are initialized type, starting direction, and initial coordinate

// direction: 0 (up) 1 (left) 2 (down) 3(right)
~doik = {
	|instrument, samples, direction, coord|

	// Increment UID counter and assign doik a UID.
	~id = ~id + 1;
	(
		id_: ~id - 1,
		samples_: samples;
		instrument_: instrument,
		direction_: direction,
		coords_: coord,

		// These are all statistics collected on the doik as it moves through
		// the grid
		//
		// Total number of times it's collided with any object
		count_: 0,
		// Total number of times it's collided with other doiks
		// reset on collision with wall
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
	var select_note, thisPitch; // 'select_note' is a helper variable for the selection of a pitch as a function of direction and coordinate
	var notesArray = [ 1, 2, 5, 6, 8, 12, 13, 17 ]; // Scott's pitch set (starting on 1)
	var panningArray = Array.new(6); // Controls spatialization of note

	// For each doik that has collided with a wall:
	doikCollisions.do({
		|doik|

		direction     = doik.direction_;
		coordinates = doik.coords_;
		count          = doik.count_;

		panningArray = [0, 0.7, 1, 0.7, 0, 1];
		if ( direction % 2 == 0,
		{ select_note = coordinates[0];},
			{ select_note = coordinates[1];});
		//this only allows DOIK to choose from the lowest 4 notes in notesArray
		thisPitch = notesArray[select_note % 4].postln;

		 // - - - - - DOIK DOIK DOIK DOIK DOIK - - - - - \\
		// - - - - -                                               - - - - - \\

		x =  Synth(\S_pitchSetTuning, [
			freq: thisPitch*~bassFreq*2,
			amp: ~d_amp,
			attackTime: ~d_attackTime*~tempo*2,
			deTune: ~d_deTune,
			ramp: ~d_ramp*~tempo*2,
			deTuneLevel: ~d_deTuneLevel,
			rate: ~d_rate*~tempo*2,
			decay: ~d_decay*~tempo*2,
			sawRate: ~d_sawRate*~tempo*2,
			sawDecay: ~d_sawDecay*~tempo*2,
			susLvl: ~d_susLvl,
			left_start: ~d_panningArray[0],
			left_end: ~d_panningArray[1],
			left_dur: ~d_panningArray[2],
			right_start: ~d_panningArray[3],
			right_end: ~d_panningArray[4],
			right_dur: ~d_panningArray[5],
		]);
	});

	wallCollisions.do({
		|doik|



		direction     = doik.direction_;
		coordinates = doik.coords_;
		count          = doik.count_;



		// set frequency
		if ( direction % 2 == 0,
		{ select_note = coordinates[0];},
			{ select_note = coordinates[1];});
		//this allows WALL to choose from the all 8 notes in notesArray
		thisPitch = notesArray[select_note % 8].postln;

		doik.postln;
		thisPitch.postln;

		 // - - - - - WALL WALL WALL WALL WALL - - - - - \\
		// - - - - -                                                 - - - - - \\
		x =  Synth(\S_pitchSetTuning, [
			freq: thisPitch*~bassFreq*4,
			attackTime: ~w_attackTime*~tempo*2,
			amp: ~w_amp,
			deTune: ~w_deTune,
			ramp: ~w_ramp*~tempo*2,
			deTuneLevel: ~w_deTuneLevel,
			rate: ~w_rate*~tempo*2,
			decay: ~w_decay*~tempo*2,
			sawRate: ~w_sawRate*~tempo*2,
			sawDecay: ~w_sawDecay*~tempo*2,
			susLvl: ~w_susLvl,
			left_start: ~w_panningArray[0],
			left_end: ~w_panningArray[1],
			left_dur: ~w_panningArray[2],
			right_start: ~w_panningArray[3],
			right_end: ~w_panningArray[4],
			right_dur: ~w_panningArray[5],
		]);
	});
};

