~sounds = "sounds";
~load = { |path|
	Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ ~sounds +/+ path)
};

// AMBIENT
// Natural sounds
~rain = ~load.("rain.wav");
~fire = ~load.("fire.wav");
~stream = ~load.("stream.wav");
~storm = ~load.("storm_with_rain.wav");
~wind = ~load.("wind.wav");

// Manmade noises
~breathing = ~load.("breathing.wav");
~sawing = ~load.("saw.wav");
~ambient = ~load.("restaurant.wav");
~trail = ~load.("trail.wav");
~city = ~load.("city.wav");
~bg = ~load.("bg.wav");

// Misc
~computer = ~load.("computer.wav");
~spaceship = ~load.("spaceship.wav");
~bubbles = ~load.("bubbles.wav");

// MUSIC
// Instruments (solo / w/ accompaniment)
~piano1 = ~load.("glass.wav");
~piano2 = ~load.("y_o_i.wav");
~orchestra = ~load.("orchestra.wav");

// Songs
~edm = ~load.("shelter.wav");
~pop = ~load.("closer.wav");
~alt = ~load.("no.wav");
~alt2 = ~load.("heartbeat.wav");
~alt3 = ~load.("takecare.wav");

~samples = ();
~samples.putPairs([
	\rain, ~rain,
	\fire, ~fire,
	\stream, ~stream,
	\storm, ~storm,
	\wind, ~wind,

	\computer, ~computer,
	\spaceship, ~spaceship,
	\bubbles, ~bubbles,

	\breathing, ~breathing,
	\saw, ~sawing,
	\ambient_restaurant, ~ambient,
	\hiking_trail, ~trail,
	\city, ~city,
	\bg, ~bg,

	\piano1__Metamorphosis_PhilipGlass, ~piano1,
	\piano2__animeOST, ~piano2,
	\orchestra_Miyazaki, ~orchestra,

	\edm__Shelter_PorterRobinson, ~edm,
	\pop__Closer, ~pop,
	\alt__No_NicholasJaar, ~alt,
	\alt__Heartbeat_Annie, ~alt2,
	\alt__TakeCare_BeachHouse, ~alt3
]);

~allSamples = ~samples.keys.asArray;
