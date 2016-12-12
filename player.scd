// first init config
~initParamsA = [
	[~instrument1], // one for each doik
	[~piano1], // one for each doik
	[0],        // init directions
	[0],
	[0],
];


~initParamsB = [
	[~instrument1, ~instrument2],
	[~piano1, ~sawing],
	[0, 0],
	[0, 4],
	[0, 4]
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
~bpm = 120;

// ============= END PARAMETERS ==================
/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.(~bpm);

// starting grid position
~init.(1);

// reset ~gridCount
~gridCount = 0;

// s.prepareForRecord; // you have to call this first
//s.record;
// play the grid
SystemClock.sched(0.0, {arg time;
	~gridCount = ~gridCount + 1;
	d.next_;

	("   Grid Count: " + ~gridCount).postln;
	~tempo // delay before running this function again.
});

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
