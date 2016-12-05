// a Sample "class" implemented using a Supercollider environment.

~sample = {
	|loc|
	~id = ~id + 1; // assign sample an id

	b = Buffer.read(s, loc); // assign to server

	(
		id_: ~id - 1,
		name_: loc,

		// Reference to the sample
		buf_: b,

		// Length of the sample in seconds
		length_: (b.numFrames / b.numChannels ) / 44100,


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
}

// Example samples
// ideally, samples should be < 1 minute or less


// AMBIENT
// Natural sounds
~rain = "sounds/rain.wav";         // done
~fire = "sounds/fire.wav";         // done
~stream = "sounds/stream.wav";     // done

// Manmade noises
~sawing = "sounds/sawing.wav";      // done
~ambient = "sounds/restaurant.wav"; // done
~voice = "sounds/vocal.wav";        // done

// MUSIC
// Instruments (solo / w/ accompaniment)
~piano1 = "sounds/glass.wav";        // done
~piano2 = "sounds/yuri_on_ice.wav";         // done :D

// Songs
~edm = "sounds/shelter.wav"     // done
~pop = "sounds/closer.wav";     // done
