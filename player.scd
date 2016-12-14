// first init config
~initParamsA = [
	[~instrument1, ~instrument5], // one for each doik
	[~piano1, ~sawing], // one for each doik
	[0,1],        // init directions
	[0,7],
	[0,2],
];


~initParamsB = [
	[~instrument_zipper],
	[~sawing],
	[0],
	[0],
	[0]
];


~initWithParams = {
	|params|
	var doiks = List.new();

	params[0].size.do{arg i;
		doiks.add(~doik.value(
			params[0][i], // Instrument
			params[1][i], // Sample
			params[2][i], // Direction
			[params[3][i], params[4][i]]))};  // x & y coords
	doiks;
};

// ============= PARAMETERS ==================

// Size of grid
~gridSize = 9;

// Iteration speed
~bpm = 150;

// ============= END PARAMETERS ==================
/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.(~bpm);

// starting grid position
~init.(0);

// reset ~gridCount
~gridCount = 0;

// s.prepareForRecord; // you have to call this first
//s.record;
// play the grid
~play = {
	|grid|
	SystemClock.sched(0.0, {arg time;
		if (~state == \play) {
			~gridCount = ~gridCount + 1;
			grid.next_;

			("   Grid Count: " + ~gridCount).postln;
		}
		~tempo // delay before running this function again.
	});
};
~play.(d);

// s.stopRecording;


// ------------------------------------------------------------------
// init configs
// 0: up   1: left   2: down   3: right
// coordinates range: 0, (~gridSize - 1)
// doik: [ [ direction array ], [ X-coordinate array ], [Y-coordinate array ] ]

// function to get a new grid
~init = {arg mvt;
	~gridCount = 1;

	case
	{mvt == 0}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsA).asArray)}
	{mvt == 1}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsB).asArray)}
	// {mvt == 2}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsC).asArray)}
	// {mvt == 3}{d = ~grid.value(~gridSize, ~initRandom.asArray)}
};
