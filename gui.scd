// GUI
// Ability to add/remove doiks
// Select sample, instrument, and bpm (stretch goal) for each doik
// Ability to start/stop playing, + overall bpm
// Random configuration
var doikControls =  List.new();
~allSamples = [
	"rain",
	"fire",
	"stream",
	"saw",
	"ambient (restaurant)",
	"piano1 (Philip Glass)",
	"piano2 (anime OST)",
	"edm (Shelter, Porter Robinson)",
	"pop (Closer)"
];

~allInstruments = [
	"defaultScore",
	"exponential decay",
	"long",
	"random cloud",
	"zipper",
	"linear zipper"
];

~h = 600;
~w = 900;

w = Window.new("Granular synthesis automata controller", Rect(50,200,~w,~h));
w.background = Color.white;
w.alpha = 0.9;
// w.view.decorator = f = FlowLayout(w.view.bounds);

~getID = {
	|obj|
	obj.identityHash;
};

~offset = 15;

//==================================================================================
//---------------------------- instruction text-------------------------------------

//---------------------------- tempo slider help text  -----------------------------
l = StaticText.new(w,Rect(~offset, 0, ~w, ~bHeight + 50));
l.stringColor = Color.red;
l.string_("Instructions: click on grid squares to select direction of doik. Instrument, sample opts on the right (corresponding to color).\nClick START when ready. To restart, rearrange config and click START. (For random opt, input # of rand doiks and click Random.)");


//==================================================================================
//---------------------------- create grid -----------------------------------------

~guiDoik = {
	|id, button, i, j, dir|
	var color = Color.rand;
	var lighten = color.complementary;
	var active = False;
	var sampleIdx = (0..(~allSamples.size - 1)).choose;
	var sample = ~allSamples[sampleIdx];
	var instIdx = (0..(~allInstruments.size - 1)).choose;
	var inst = ~allInstruments[instIdx];
	var bpm = ~bpm;

	(
		id_: id,
		color_: color,
		textColor_: lighten,
		button_: button,
		coor_: [i, j],
		dir_: dir,
		active_: active,
		sample_: sample,
		sample_idx_: sampleIdx,
		inst_: inst,
		inst_idx_: instIdx,
		bpm_: bpm,
	)
};

//---------------------------- basic button  ---------------------------------------

~gridSize.do{ |i|
	~gridSize.do{ |j|
		~createButton.(i, j);
	}
};

Library.put(\dict, ~dict);

~size = (~h - 180) / ~gridSize;
~dict = Dictionary.new;
~num = 0; // number of doiks currently active
~counter = 0; // for assigning unique ID's

~createButton = {
	|i, j|
	var newDoik;
	var but = Button.new(w, Rect(~offset + (~size * i),
		(~offset * 4) + (~size * j),
		~size, ~size));
	but.identityHash.postln;

	newDoik = ~guiDoik.value(~counter, d, i, j, -1);
	~dict.add(but.identityHash -> newDoik);
	~counter = ~counter + 1;

	but.states_([
		["-"],
		["^", newDoik.textColor_, newDoik.color_],
		["<", newDoik.textColor_, newDoik.color_],
		[">", newDoik.textColor_, newDoik.color_],
		["v", newDoik.textColor_, newDoik.color_],
	]);

	but.action_({ |v|
		var doik;
		var h = but.identityHash;
		z = Library.at(\dict);
		h.postln;
		z[h].postln;


		if ((z[h].active_ == False) &&
			((v.value == 1) || (v.value == 2) || (v.value == 3) || (v.value == 4))) {
			"adding doik ".post;
			~addDoikGUI.(h, ~num);
			~num = ~num + 1;
			z[h].active_ = True;
		};

		switch(v.value,
			0, {
				"Deleting.".postln;
			},
			{
				"Changing direction to: ".post;
				v.value.postln;
				z[h].dir_ = v.value;
			}
		);
		doik = z[h];
		z.add(h -> doik);
		Library.put(\dict, z);
	});
};

//---------------------------- add doik gui  ---------------------------------------

~width = 160;
~height = 20;
~slideWidth = 75;
~buf = 5;

~addDoikGUI = { |h, n|
	var lib = Library.at(\dict);
	var yval = (~height + ~buf) * (n + 1) + 40;

	var color = lib[h].color_;
	var lighter = lib[h].textColor_;

	var c1 = Array.newFrom(~allSamples);
	var c2 = Array.newFrom(~allInstruments);
	var item1 = c1.removeAt(lib[h].sample_idx_);
	var item2 = c2.removeAt(lib[h].inst_idx_);
	c1 = [item1] ++ c1;
	c2 = [item2] ++ c2;

	c1.postln;
	c2.postln;


	~cO = 460;
	~cW = ~width;
	~cB = 10;

	//---------------------------- sample selection dropdown -----------------------
	b = PopUpMenu.new(w, Rect(~coor.(0), yval, ~width, ~height));
	b.items_(c1 ++ ["add your own"]);
	b.background_(color);
	b.stringColor_(lighter);
	b.action_({|v|
		if (v.value == (~allSamples.size), {
			"todo: allow upload of files".postln;
		}, {
			lib[h].sample_ = c1[v.value];
			"Changed sample to: ".post;
			lib[h].sample_.postln;
		});
	});

	//---------------------- instrument selection dropdown -------------------------
	i = PopUpMenu.new(w, Rect(~coor.(1), yval, ~width, ~height));
	i.items_(c2);
	i.background_(color);
	i.stringColor_(lighter);
	i.action_({|v|
		lib[h].inst_ = c2[v.value];
		"Changed instrument to: ".post;
		lib[h].inst_.postln;
	});

	//-------------------------------- tempo slider --------------------------------
	a = Slider.new(w,Rect(~coor.(2), yval, ~slideWidth, ~height));
	a.action_({ |a|
		var tem = a.value * 100 + 80;
		"New bpm: ".post;
		tem.postln;
		lib[h].bpm_ = tem;
	});
};

//==================================================================================
//---------------------------- main controls, first row ----------------------------

~bWidth = 100;
~bHeight = 30;
~bX = 15;
~bY = 500;
~mainBuf = 15;

~coor = {
	arg n, base=~cO, unit=~cW, buf=~cB;
	base + ((unit + buf) * n);
};

// calc y-coordinates for each row
~y1 = ~coor.(0, ~bY, ~bHeight, ~mainBuf);

// set up for calculating x-coordinates
~cO = ~bX;
~cW = ~bWidth;
~cB = ~mainBuf;

~numRandom = 3;
//---------------------------- random config num slider  ---------------------------
t = TextField(w,Rect(~coor.(0), ~y1, ~bWidth, ~bHeight));
t.string = "# random";
t.stringColor = Color.gray;
t.background = Color.black;

t.action_({
	|f|
	"# random doiks to be generated: ".post;
	~numRandom = f.value.asInteger;
	~numRandom.postln;
});

//---------------------------- random config button  -------------------------------
r = Button.new(w, Rect(~coor.(1, ~bX, ~bWidth, ~mainBuf), ~y1, ~bWidth, ~bHeight));
r.states_([["Random!", Color.white, Color.black]]);
r.action_({
	"generating random configuration".post;
	~numRandom.do { |i|
		"\tadding doik".post;
		i.postln;
	}

	// todo
});

//==================================================================================
//---------------------------- main controls, second row ---------------------------

//---------------------------- start button -----------------------------------------
y = Button.new(w,Rect(~coor.(0), ~y2, ~bWidth, ~bHeight));
p.font_("Courier");
y.states_([
	["Start", Color.blue, Color.green]]);

y.action_({ |v|
	~initAll.();
});

//---------------------------- play button -----------------------------------------
p = Button.new(w,Rect(~coor.(1), ~y2, ~bWidth, ~bHeight));
p.font_("Courier");
p.states_([
	["Pause", Color.gray],
	["Play", Color.blue]]);

p.action_({ |v|
	switch(v.value,
		0, {
			if (~start == False) {
				~start = True;
				// init everything

			};
			"playing".postln;
			~state = \play;


		}, {
			"paused".postln;
			~state = \paused;

		}
	);
});


//---------------------------- tempo slider  ---------------------------------------
t = Slider.new(w,Rect(~coor.(2), ~y2, ~bWidth, ~bHeight));
t.action_({ |b|
	var tem = b.value * 100 + 80;
	"New bpm: ".post;
	tem.postln;
	~tempo = ~convertBPM.(tem);
});

//---------------------------- tempo slider help text  -----------------------------
l = StaticText.new(w,Rect(~coor.(3), ~y2, 200, ~bHeight));
l.stringColor = Color.gray;
l.string_("bpm: [80, 180]");

//==================================================================================
//---------------------------- callback funcs --------------------------------------

~addAllDoiks = {
	var doiks = List.new();
	~doiks.do { |i, d|
		// add each of them to the grid
		doiks.add(~doik.value(
			d[2], // Direction
			d[3], // Instrument
			d[4], // Sample
			[d[0], d[1]]));  // x & y coords
	};
	d = ~grid.value(~gridSize, doiks.asArray);
};

//---------------------------- init function  --------------------------------------
~initAll = {


};

w.front;