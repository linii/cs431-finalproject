// a Sample "class" implemented using a Supercollider environment.

~sample = {
	|s|
	var loc = s[0];
	var bufnum = s[1];
	var bufidx = s[2];

	~id = ~id + 1; // assign sample an id

	(
		id_: ~id - 1,

		// name of the loc on the file
		name_: loc,

		// index into global buffer array
		idx_: bufidx,

		// Reference to the sample, needed to play
		buf_: bufnum,

		// Length of the sample in seconds
		// todo: fix
/*		length_: (b.numFrames / b.numChannels ) / 44100,*/


		// Debug function to print information about the sample
		debug_: {
			|self|
			"id:".post;
			self.id_.post;
			" path:".post;
			self.name_.post;
			" length (secs): ".post;
			self.length_.post;
		}
	)
};

// Example samples
// ideally, samples should be < 1 minute or less


// AMBIENT
// Natural sounds
~rain = "sounds/rain.wav";         // done
~fire = "sounds/fire.wav";         // done
~stream = "sounds/stream.wav";     // done

// Manmade noises
~sawing = "sounds/saw.wav";      // done
~ambient = "sounds/restaurant.wav"; // done

// MUSIC
// Instruments (solo / w/ accompaniment)
~piano1 = "sounds/glass.wav";        // done
~piano2 = "sounds/yuri_on_ice.wav";         // done :D

// Songs
~edm = "sounds/shelter.wav";     // done
~pop = "sounds/closer.wav";     // done

~allSamples = [
	~rain, ~fire, ~stream,
	~sawing, ~ambient,
	~piano1, ~piano2,
	~edm, ~pop
];
