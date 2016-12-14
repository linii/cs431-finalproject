~load = {
	|path|
	Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ path)
};

// AMBIENT
// Natural sounds
~rain = ~load.("sounds/rain.wav");         // done
~fire = ~load.("sounds/fire.wav");         // done
~stream = ~load.("sounds/stream.wav");     // done

// Manmade noises
~sawing = ~load.("sounds/saw.wav");      // done
~ambient = ~load.("sounds/restaurant.wav"); // done

// MUSIC
// Instruments (solo / w/ accompaniment)
~piano1 = ~load.("sounds/glass.wav");        // done
~piano2 = ~load.("sounds/yuri_on_ice.wav");         // done :D

// Songs
~edm = ~load.("sounds/shelter.wav");     // done
~pop = ~load.("sounds/closer.wav");     // done

