// ============= PARAMETERS ==================

//// everything within these parenthesis is all you need to try out one version of the grid \\\\

~gridSize = 9; // 9x9 grid
~bpm = 120;
~bassFreq = 35; //lowest frequency in cps (30-40 is recommended)

/// helps adjust tempo relative to initial BPM
~convertBPM = {arg bpm; 30/bpm };
~tempo = ~convertBPM.value(~bpm);

~movement.value(1); // starting grid position

//// everything within these parenthesis is all you need to try out one version of the grid \\\\


// play the grid
SystemClock.sched(0.0,{arg time;

	// find out where we are before new grid is created

	~gridCount = ~gridCount + 1;
	~bar = (~gridCount/8+0.45).round;
	~beat = ((~gridCount-1)%8+0.9).round;
	~whereAreWe.value(~bar, ~beat, ~gridCount);

	d.next_;

	// display bar, beat, and frame number
	("Bar: " + ~bar).post;
	("   Beat: " + ~beat).post;
	("   Grid Count: " + ~gridCount).postln;
	~tempo // delay before running this function again.

});



// set up the different sections of the piece

// diretions
// 0: up   1: left   2: down   3: right
// coordinates range: 0, (~gridSize - 1)

// [ [ direction array ], [ X-coordinate array ], [Y-coordinate array ] ]
~initDoiks0 = List[]; // this will stay empty. act as a rest or fadeout.
~initDoiksA = List[];
~initDoiksB = List[];
~initDoiksC = List[];
~initDoiksD = List[];

~initParamsA = [[0, 0, 1, 3], [3, 5, 5, 5], [0, 0, 4, 2]];
~initParamsB = [[0, 0, 1, 3, 1, 2], [3, 5, 5, 5, 2, 8], [0, 0, 4, 2, 4, 2]];
~initParamsC = [[0, 1, 2, 3, 0, 0, 1, 1, 0, 1, 2, 3, 0], [0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8], [0, 0, 1, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8].scramble];
~initParamsD = [[ ], [ ], [ ]];


~initParamsA[1].size.do{arg i;
	~initDoiksA.add(~doik.value(\A, ~initParamsA[0][i],  [~initParamsA[1][i], ~initParamsA[2][i]]))};

~initParamsB[1].size.do{arg i;
	~initDoiksB.add(~doik.value(\A, ~initParamsB[0][i],  [~initParamsB[1][i], ~initParamsB[2][i]]))};

~initParamsC[1].size.do{arg i;
	~initDoiksC.add(~doik.value(\A, ~initParamsC[0][i],  [~initParamsC[1][i], ~initParamsC[2][i]]))};

rrand(12, 20).do({ ~initDoiksD.add(~doik.value(\A, rrand(0, 3),  [rrand(0, ~gridSize - 1), rrand(0, ~gridSize - 1)]))});


// function to call a new grid position
~movement = {arg mvt;
	case
	{mvt == 0}{d = ~grid.value(~gridSize, ~initDoiks0.asArray)}
	{mvt == 1}{d = ~grid.value(~gridSize, ~initDoiksA.asArray)}
	{mvt == 2}{d = ~grid.value(~gridSize, ~initDoiksB.asArray)}
	{mvt == 3}{d = ~grid.value(~gridSize, ~initDoiksC.asArray)}
	{mvt == 4}{d = ~grid.value(~gridSize, ~initDoiksD.asArray)}
};

// GLOBAL DOIK SYNTH PARAMATERS
~d_attackTime = 0.0125;
~d_amp = 0.2;
~d_sawDecay = 1;
~d_susLvl  = 0.5;
~d_panningArray =  [[0, 1, 1, 1, 0, 1], [1, 0, 1, 0, 1, 1]].choose;
~d_deTune = 0.35;
~d_deTuneLevel = 0.15;
~d_ramp = 2;
~d_rate = 16;
~d_decay = 2;
~d_sawRate = 2;

// GLOBAL WALL SYNTH PARAMATERS
~w_attackTime = 0.025;
~w_amp = 0.2;
~w_sawDecay = 4;
~w_susLvl  = 0.15;
~w_panningArray =  [1, 1, 1, 1, 1, 1];
~w_deTune = 0.005;
~w_deTuneLevel = 0.45;
~w_ramp = 0.02;
~w_rate = 2;
~w_decay = 2;
~w_sawRate = 2;


///   ________________________________________________________   \\\
///                                                                                               \\\
/////// - - - - - - - - - - MUSICAL SCORE - - - - - - - - - - \\\\\\
///   ________________________________________________________   \\\


// Starting position of piece (for working on transitions)
// set to 0, 0, 0 when performing
~gridCount = 0*8; ~bar = 0; ~beat = 0;

// ~whereAreWe monitors the count from the grid frames
//    and makes adjustments at appropriate times

~whereAreWe = {arg bar, beat, frame;
	var pos;
	pos = [bar, beat];
	// bars count from 1
	// beats cycle 1 through 8

	case
	{pos == [5, 1]}{
		~w_sawDecay = 8;
		~w_sawRate = 4;
		~w_decay = 4;
	}
	{pos == [6, 1]}{
		~w_sawDecay = 2;
		~w_sawRate = 12;
		~w_decay = 1;
	}
	{pos == [7, 1]}{
		~w_sawDecay = 8;
		~w_sawRate = 8;
		~w_decay = 4;
	}
	{pos == [7, 5]}{
		~movement.value(0); /// silence
		~d_attackTime = 1
	}
	{pos == [8, 4]}{
		~pBind1.play
	}
	{pos == [9, 1]}{
		~d_attackTime = 0.25;
		~w_sawDecay = 5;
		~w_sawRate = 3;
		~w_decay = 1;
		~w_deTune = 0.013;
		~movement.value(2);
		~subSynth =  Synth(\S_pitchSetTuning, [\freq: ~bassFreq*2, \amp: 1])
	}
	{pos == [11, 1]}{
		~w_sawDecay = 8;
		~w_sawRate = 4;
		~w_susLvl  = 0.35;
	}
	{pos == [13, 1]}{
		~w_sawDecay = 2;
		~w_sawRate = 24;
		~w_decay = 1;
		~w_deTune = 0.013;
		~movement.value(2); /// section
		~subSynth =  Synth(\S_pitchSetTuning, [\freq: ~bassFreq*1.5, \amp: 1])
	}
	{pos == [14, 1]}{
		~w_sawDecay = 1}
	{pos == [15, 1]}{
		~w_sawDecay = 4;
		~w_sawRate = 8;
		~w_attackTime = 0.01;
		~w_decay = 4;
		~w_susLvl  = 0.35;
	}
	{pos == [17, 1]}{
		~w_sawDecay = 2;
		~w_sawRate = 16;
		~w_attackTime = 0.005;
		~w_susLvl  = 0.15;
		~w_decay = 2;
	}
	{pos == [18, 1]}{
		~w_sawDecay = 8;
		~w_sawRate = 32;
		~w_attackTime = 0.0025;
		~w_susLvl  = 0.15;
		~w_decay = 4;
	}
	{pos == [18, 5]}{
		~movement.value(0);
		~d_attackTime = 1
	}
	{pos == [19, 4]}{
		~pBind1.play;
	}
	{pos == [20, 1]}{
		~w_sawDecay = 2;
		~w_sawRate = 4;
		~d_rate = 1;
		~w_attackTime = 0.125;
		~w_susLvl  = 0.45;
		~w_decay = 1;
		~movement.value(3); /// section
	}
	{pos == [21, 4]}{
		~pBind1.play;
	}
	{pos == [23, 4]}{
		~pBind1.play;
	}
	{pos == [24, 1]}{
		~subSynth =  Synth(\S_pitchSetTuning, [\freq: ~bassFreq*[2, 4], \amp: 0.33, \rate: [4, 6, 8, 12].choose, \decay: 2, \attackTime: 2])
	}
	{pos == [25, 4]}{
		~pBind1.play;
	}
	{pos == [25, 5]}{
		~movement.value(0);
	}
	{pos == [26, 1]}{
		~subSynth =  Synth(\S_pitchSetTuning, [freq: ~bassFreq*[1, 5], amp: 1, rate: [4, 6, 8, 12].choose])
	}
	{pos == [26, 4]}{
		~pBind1.play;
	}
	{pos == [27, 4]}{
		~pBind1.play;
	}
	{pos == [28, 1]}{
		~w_sawDecay = 4;
		~w_sawRate = 8;
		~d_rate = rrand(4, 6, 8, 12, 16);
		~w_attackTime = 0.0125;
		~w_susLvl  = 0.1;
		~w_decay = 0.5;
		~movement.value(1)
	}
	{pos == [32, 1]}{
		~w_sawRate = [10, 15].choose;
		~w_decay = 5;
	}
	{pos == [32, 5]}{
		~movement.value(0);
	}
	{pos == [33, 1]}{
		~w_sawRate = [5, 10].choose;
		~w_amp = 0.1;
		~d_amp = 0.05;
		~d_rate = 8;
		~w_decay = 2;
		~d_decay = 0.5;
		~movement.value(4);
	}
	{pos == [35, 1]}{
		~w_sawRate = [4, 8].choose;
		~w_amp = 0.05;
		~d_amp = 0.025;
		~d_rate = 8;
		~w_decay = 1;
		~d_decay = 0.5;

	}
	{pos == [37, 1]}{
		~w_sawRate = [3, 6].choose;
		~w_amp = 0.025;
		~d_amp = 0.0125;
		~d_rate = 8;
		~w_decay = 0.5;
		~d_decay = 0.5;
	}
	{pos == [39, 1]}{
		~movement.value(1);
		~w_amp = 0.025;
		~d_amp = 0.00625;
		~subSynth =  Synth(\S_pitchSetTuning, [freq: ~bassFreq*[1, 3], amp: 0.2, rate: [0.1, 0.2, 0.4].choose])
	}
	{pos == [40, 1]}{
		~w_amp = 0.0125;
		~d_amp = 0;
		~subSynth =  Synth(\S_pitchSetTuning, [freq: ~bassFreq*[1, 1.5], amp: 0.1, rate: [0.1, 0.2, 0.4].choose])
	}
	{pos == [42, 1]}{
		~w_amp = 0.00625;
		~d_amp = 0;
		~subSynth =  Synth(\S_pitchSetTuning, [freq: ~bassFreq*[1, 1.5], amp: 0.1, rate: [0.1, 0.2, 0.4].choose])
	}
	{pos == [44, 1]}{
		~w_amp = 0.000325;
		~subSynth =  Synth(\S_pitchSetTuning, [freq: ~bassFreq*[1, 1.5], amp: 0.1, rate: [0.1, 0.2, 0.4].choose])
	}
	{pos == [46, 1]}{
		~w_amp = 0.000125;
	}
	{pos == [48, 1]}{
		~w_amp = 0;
		SystemClock.clear; /// WHYYYY!!???? I HATE COMPUTERS
	}


};

/// WHYYYY!!???? I HATE COMPUTERS
/// this isn't changing.  do you know how to make it reevaluate Pbind each time its called?
~pBind1 = Pbind(
	\instrument, \S_pitchSetTuning,
	\freq, Pseq({([0.001, 5, 2, 0.001, 0.001, 8, 12].scramble + [0, 3].choose)*~bassFreq}, 1),
	\amp, Pseq([0.001, 0.3, 0.3, 0.3, 1, 0.5, 0.5], 1),
	\dur, Pseq({[
		[0.25, 0.5, 0.5, 1, 1, 0.5, 0.5 ],
		[0.25, 0.5, 0.5, 1, 0.5, 0.5, 1 ],
		[0.25, 0.5, 1, 0.5, 1, 0.5, 0.5]].choose*~tempo}, 1),
	\decay, Pseq([0.1, 0.25, 4, 0.5, 4, 0.5, 0.5]*~tempo, 1),
	\rate, Pseq( {[0, 3, 0, 5, 1, 0, 0].scramble+rrand(0.1, 1.5).round(0.25)*~tempo}, 1),
	\ramp, Pseq([0.3, 0.01, 0.71, 0.5, 4, 0.2, 0.1]*~tempo, 1),
	\deTune, Pseq([0.05, 0.005, 0.015, 0.0125, 1, 0.075, 0.025], 1),
	\susLvl, Pseq([0.001, 0.2, 0.5, 0.15, 0.5, 0.05, 0.25] ,1)
);



