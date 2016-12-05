// ============= PARAMETERS ==================

// Size of grid
~gridSize = 9;

// Iteration speed
~bpm = 120;

// How dense the cloud gets
~durMutipler = 2.0;

// ============= END PARAMETERS ==================
/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.(~bpm);

// starting grid position
~init.(1);

// play the grid
SystemClock.sched(0.0,{arg time;
	// find out where we are before new grid is created
	~gridCount = ~gridCount + 1;
	~bar = (~gridCount/8+0.45).round;
	~beat = ((~gridCount-1)%8+0.9).round;

	d.next_;

	// display bar, beat, and frame number
	("Bar: " + ~bar).post;
	("   Beat: " + ~beat).post;
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
	case
	{mvt == 0}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsA).asArray)}
	{mvt == 1}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsB).asArray)}
	{mvt == 2}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsC).asArray)}
	{mvt == 3}{d = ~grid.value(~gridSize, ~initRandom.asArray)}
};

// first init config
~initParamsA = [
	[0, 0, 1, 3],        // directions
	[3, 5, 5, 5],
	[0, 0, 4, 2]]
;

// second init config
~initParamsB = [
	[0, 0, 1, 3, 1, 2],
	[3, 5, 5, 5, 2, 8],  // x-coordinates
	[0, 0, 4, 2, 4, 2]   // y-coordinates
];

// third init config
~initParamsC = [
	[0, 1, 2, 3, 0, 0, 1, 1, 0, 1, 2, 3, 0],
	[0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8],
	[0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8].scramble
];

~initWithParams = {
	|params|
	var doiks = List.new();
	params[1].size.do{arg i;
		doiks.add(~doik.value(
			\A,
			params[0][i],  // direction
			[params[1][i], params[2][i]]))};  // x & y coords
	doiks;
};

~initRandom = {
	var doiks = List.new();
	rrand(12, 20).do(
		doiks.add( ~doik.value(
			\A,
			rrand(0, 3),
			[(~gridSize - 1).rand, (~gridSize - 1).rand])
		)
	);
	doiks;
};
