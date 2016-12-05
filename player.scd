// ============= PARAMETERS ==================

// Size of grid
~gridSize = 9;

// Iteration speed
~bpm = 200;

// How quickly the cloud gets dense
~durMultiplier = 0.5;

// How long each "grain" can be
~durMax = 2.0;

// How long each grain is initially
~durBase = 0.04;

// How many times each grain is played on collision
~grains = 1;

// ============= END PARAMETERS ==================
/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.(~bpm);

// starting grid position
~init.(0);

// reset ~gridCount
~gridCount = 0;

// play the grid
SystemClock.sched(0.0, {arg time;
	~gridCount = ~gridCount + 1;
	d.next_;

	("   Grid Count: " + ~gridCount).postln;
	~tempo // delay before running this function again.
});



// ------------------------------------------------------------------
// init configs
// 0: up   1: left   2: down   3: right
// coordinates range: 0, (~gridSize - 1)
// doik: [ [ direction array ], [ X-coordinate array ], [Y-coordinate array ] ]

// function to get a new grid
~init = {arg mvt;
	~gridCount = 1;
	"mvt".postln;
	mvt.postln;

	case
	{mvt == 0}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsA).asArray)}
	{mvt == 1}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsB).asArray)}
	{mvt == 2}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsC).asArray)}
	{mvt == 3}{d = ~grid.value(~gridSize, ~initRandom.asArray)}
};

// first init config
~initParamsA = [
	[~instrument.()],
	[~piano1, ~ambient, ~stream],
	[0, 0, 1, 3],        // directions
	[3, 5, 5, 5],
	[0, 0, 4, 2]]
;

// second init config
~initParamsB = [
	[~instrument.()],
	[~fire, ~sawing, ~piano1, ~pop],
	[0, 0, 1, 3, 1, 2],
	[3, 5, 5, 5, 2, 8],  // x-coordinates
	[0, 0, 4, 2, 4, 2]   // y-coordinates
];

// third init config:
// squares in diagonal pattern
~initParamsC = [
	[~instrument.()],
	[~stream, ~ambient, ~piano2],
	[0, 1, 2, 3, 0, 0, 1, 1, 0, 1, 2, 3, 0],
	[0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8],
	[0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8].scramble
];

~initWithParams = {
	|params|
	var doiks = List.new();
	params.postln;

	params[2].size.do{arg i;
		doiks.add(~doik.value(
			params[0],
			params[1],
			params[2][i],  // direction
			[params[3][i], params[2][i]]))};  // x & y coords
	doiks;
};

~initRandom = {
	var doiks = List.new();
	var randSamples = List.new();
	var randInsts = List.new();
	4.rand.do {
		randSamples.add(~allSamples.choose);
		randInsts.add(~allInsts.choose);
	};

	rrand(12, 20).do(
		doiks.add( ~doik.value(
			randInsts,
			randSamples,
			rrand(0, 3),
			[(~gridSize - 1).rand, (~gridSize - 1).rand])
		)
	);
	doiks;
};
