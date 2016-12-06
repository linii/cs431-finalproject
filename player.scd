// ============= PARAMETERS ==================

// Size of grid
~gridSize = 9;

// Iteration speed
~bpm = 120;

// How quickly the cloud gets dense
~durMultiplier = 2;

// How long each "grain" can be
~durMax = 0.6;

// How long each grain is initially
~durBase = 0.02;

// How many times each grain is played on collision
~grains = 30;

// Maximum time to wait between each grain playing
~waitTime = 0.02;

// Minimum time of all samples, to be safe
~minLength = 10;

// ============= END PARAMETERS ==================
/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.(~bpm);

// init the sample buffers
~bufnums = List.new();
~allSamples.do { |loc|
	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ loc ); // assign to server
	b.bufnum.postln;
	~bufnums.add(b.bufnum);
};

~bufnums.postln;

// starting grid position
~init.(0);

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
	{mvt == 2}{d = ~grid.value(~gridSize, ~initWithParams.(~initParamsC).asArray)}
	{mvt == 3}{d = ~grid.value(~gridSize, ~initRandom.asArray)}
};

// first init config
~initParamsA = [
	[~instrument1, ~instrument1, ~instrument1, ~instrument1], // one for each doik
	[~piano2, ~edm, ~sawing, ~rain], // one for each doik
	[0, 0, 1, 3],        // init directions
	[3, 5, 5, 5],
	[0, 0, 4, 2],
];

// second init config
~initParamsB = [
	[~instrument1, ~instrument2, ~instrument1, ~instrument2, ~instrument1, ~instrument2],
	[~fire, ~stream, ~piano1, ~pop, ~rain, ~ambient],
	[0, 2, 1, 3, 1, 2],
	[3, 0, 5, 5, 2, 8],  // x-coordinates
	[0, 1, 4, 2, 4, 2]   // y-coordinates
];

// third init config:
// squares in diagonal pattern
~initParamsC = [
	Array.fill(9, {~instrument1}),
	~allSamples,
	[0, 1, 2, 3, 0, 0, 1, 1],
	[0, 1, 2, 3, 4, 5, 6, 7, 8],
	[0, 1, 2, 3, 4, 5, 6, 7, 8].scramble
];

~initWithParams = {
	|params|
	var doiks = List.new();
	var sampleArr = List.new();

	// contruct sample array
	params[1].do { |name|
		// find the entry by name in the array
		~allSamples.do { |s, i|
			s.postln;
			if (s == name) {
				sampleArr.add([name, ~bufnums[i], i]);
			};
		};
	};

	sampleArr.postln;

	params[2].size.do{arg i;
		doiks.add(~doik.value(
			[params[0][i]],
			sampleArr,  // samples
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
