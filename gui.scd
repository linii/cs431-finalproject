// GUI
// Ability to add/remove doiks on a graphic grid,
//     Select sample, instrument for each doik while paused or before clicking LOAD GRID
//     Or, can select placement of new doik while playing.
// Ability to choose random configuration


// height and width of the window
~h = 550;
~w = 750;
~offset = 15;

// button width and height for main buttons
~bWidth = 90;
~bHeight = 30;
~mainBuf = 10;

// Offsets for main buttons
~bX = 15;
~bY = 450;

// button width and height for sample attributes to the right
~width = 150;
~height = 20;
~buf = 5;

// default number of random doiks generated when clicking random
~numRandom = 5;

w = Window.new("Granular synthesis automata controller", Rect(50,200,~w,~h));
w.background = Color.white;
w.alpha = 0.9;

~getID = {
	|obj|
	obj.identityHash;
};

~coor = {
	arg n, base=~cO, unit=~cW, buf=~cB;
	base + ((unit + buf) * n);
};


//==================================================================================
//---------------------------- instruction text-------------------------------------

//---------------------------- tempo slider help text  -----------------------------
l = StaticText.new(w,Rect(~offset, 0, ~w, ~bHeight + 50));

l.stringColor = Color.red;
l.string_("Instructions: Click on grid squares to select direction of doik; instrument, sample opts on right (corresponding to color).\nClick LOAD GRID when ready. You cannot change doik opts after loading or playing after pause. \nLive input: drop in doiks while PLAYING w rand. direction / sample / instrument, \nor click PAUSE, add doiks, customize dir, etc. then PLAY. For random opt, input # of rand doiks and click Random.");


//==================================================================================
//---------------------------- create grid -----------------------------------------

// Representation of a doik in its GUI form.
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
		debug_: { |self|
			"dir: ".post;
			self.dir_.post;
			"  | sample: ".post;
			self.sample_.post;
			"  | inst: ".post;
			self.inst_.postln;
		}
	)
};

//---------------------------- basic grid button  ------------------------------------

~size = (~h - 200) / ~gridSize;
~dict = Dictionary.new; // start new dictionary for doiks
~num = 0; // number of doiks currently active
~counter = 0; // for assigning unique ID's

// instantiate grid, with the default direction/state of -1/0
~makeGrid = {
	~gridSize.do{ |i|
		~gridSize.do{ |j|
			~createButton.(i, j, -1);
		}
	};
};

~makeGrid.();
Library.put(\dict, ~dict);
~state = \stopped;

~createButton = {
	arg i, j, dir;
	var newDoik;
	var but = Button.new(w, Rect(~offset + (~size * i),
		(~offset * 5) + (~size * j), ~size, ~size));

	newDoik = ~guiDoik.value(~counter, d, i, j, dir);
	if (dir != -1) {
		// indicates it's from random function;
		newDoik.active_ = True;
	};

	~dict.add(but.identityHash -> newDoik);

	// update id counter
	~counter = ~counter + 1;

	but.states_([
		["-", Color.clear, Color.white],
		["^", newDoik.textColor_, newDoik.color_],
		["<", newDoik.textColor_, newDoik.color_],
		["v", newDoik.textColor_, newDoik.color_],
		[">", newDoik.textColor_, newDoik.color_],
	]);

	// init with default direction.
	but.value = dir + 1;

	// what the button does when it is clicked
	but.action_({ |v|
		var doik;
		var h = but.identityHash;
		z = Library.at(\dict);

		// once clicked, update internal state.
		switch(v.value,
			0, {
				"\tDeleting.".postln;
				z[h].active_ = False;
			},
			{
				"\tChanging direction to: ".post;
				v.value.postln;
				z[h].dir_ = v.value - 1;
			}
		);

		// once clicked & not deleted, add to GUI with background color, etc
		if ((z[h].active_ == False) && (v.value != 0) &&
			((v.value == 1) || (v.value == 2) || (v.value == 3) || (v.value == 4))) {
			~addDoikGUI.(h, ~num);
			~num = ~num + 1;
			z[h].active_ = True;

			// nothing else needs to be done, doiks loaded when Load Grid clicked
			if (~state == \stopped, {
				"STOPPED, adding initdoik, default direction is ^ ".post;
			}, {
				var i = z[h].coor_[0];
				var j = z[h].coor_[1];

				// else, drop in doik with random direction
				if (~state == \play, {
					z[h].dir_ = (0..3).choose;

					"PLAYING: adding doik on the fly to grid, with random direction ".postln;
					but.value = z[h].dir_ + 1; // need to make it reflect graphically
					~grd.grid_[i, j].add(~toDoik.(z[h]));
				}, {
					// or, remind self to update when you click play
					"PAUSED: adding doik while paused, ".post;
					"will add to grid upon clicking PLAY".postln;
				});
			});
		};

		// update environment
		Library.put(\dict, z);
	});
	but;
};


//---------------------------- add doik gui  ---------------------------------------
~addDoikGUI = { |h, n|
	var lib = Library.at(\dict); // load current dictionary
	var yval = (~height + ~buf) * (n + 1) + 60;

	var color = lib[h].color_;
	var lighter = lib[h].textColor_;

	// do some array swapping lol
	var c1 = Array.newFrom(~allSamples);
	var c2 = Array.newFrom(~allInstruments);
	var item1 = c1.removeAt(lib[h].sample_idx_);
	var item2 = c2.removeAt(lib[h].inst_idx_);
	c1 = [item1] ++ c1;
	c2 = [item2] ++ c2;

	// X offset, width, and buffer for the right option selections
	~cO = 400;
	~cW = ~width;
	~cB = 10;

	//---------------------------- sample selection dropdown -----------------------
	b = PopUpMenu.new(w, Rect(~coor.(0), yval, ~width, ~height));
	b.items_(c1);
	b.background_(color);
	b.stringColor_(lighter);
	b.action_({|v|
		lib[h].sample_ = c1[v.value];
		"\tChanged sample to: ".post;
		lib[h].sample_.postln;
	});

	//---------------------- instrument selection dropdown -------------------------
	i = PopUpMenu.new(w, Rect(~coor.(1), yval, ~width, ~height));
	i.items_(c2);
	i.background_(color);
	i.stringColor_(lighter);
	i.action_({|v|
		lib[h].inst_ = c2[v.value];
		"\tChanged instrument to: ".post;
		lib[h].inst_.postln;
	});
};

//==================================================================================
//---------------------------- main controls, first row ----------------------------
// calc y-coordinates for each row
~y1 = ~coor.(0, ~bY, ~bHeight, ~mainBuf);
~y2 = ~coor.(1, ~bY, ~bHeight, ~mainBuf);

// set up for calculating x-coordinates
~cO = ~bX;
~cW = ~bWidth;
~cB = ~mainBuf;

//---------------------------- random config num text box  --------------------------
t = TextField(w,Rect(~coor.(0), ~y1, ~bWidth, ~bHeight));
t.string = "# random";
t.stringColor = Color.gray;
t.background = Color.white;

t.action_({ |f|
	"  # random doiks: ".post;
	~numRandom = f.value.asInteger;
	~numRandom.postln;
});

//---------------------------- random config button  -------------------------------
r = Button.new(w, Rect(~coor.(1, ~bX, ~bWidth, ~mainBuf), ~y1, ~bWidth, ~bHeight));
r.states_([["Random!", Color.white, Color.black]]);
r.action_({
	var dict = Library.at(\dict);
	"\tgenerating random configuration of ~".post;
	~numRandom.post;
	" doiks: ".postln;
	~numRandom.do { |k|
		var i = (0..(~gridSize - 1)).choose;
		var j = (0..(~gridSize - 1)).choose;
		var dir = (0..3).choose;
		~createButton.(i, j, dir);
	};
});


//---------------------------- add ability to load own sample  -----------------------

~loadYourOwn = { |path|
	var buf;
	buf = Buffer.read(s, path);
	~samples.putPairs([path, buf]);
	~allSamples = ~samples.keys.asArray;
};

a = TextField(w, Rect(~coor.(2), ~y1, 190, ~bHeight));
a.string = "custom sample path (absolute)";
a.action = {arg field;
	var path = field.value;
	"\tChanged custom sample path: ".post;
	path.postln;
};

a.background_(Color.white);
a.stringColor_(Color.gray);

//---------------------------- add own path  -------------------------------
r = Button.new(w, Rect(~coor.(4), ~y1, ~bWidth, ~bHeight));
r.states_([["Add", Color.white, Color.black]]);
r.action_({
	"\tLoading custom sample path: ".post;
	a.value.postln;
	~loadYourOwn.(a.value);
});


//==================================================================================
//---------------------------- main controls, second row ---------------------------

//---------------------------- start button -----------------------------------------
y = Button.new(w,Rect(~coor.(0), ~y2, ~bWidth, ~bHeight));
y.font_("Courier");
y.states_([
	["Load grid", Color.black, Color.rand]
]);
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
			var doiks = ~getDoiksFromDict.();
			"PLAYING, adding new doiks from dictionary: ".postln;
			// add them to grid manually
			doiks.do { |d|
				var i = d.coords_[0];
				var j = d.coords_[1];
				d.debug_;
				~grd.grid_[i, j].add(d);
			};

			~state = \play;

		}, {
			"PAUSED. time to add new doiks!!".postln;
			~state = \pause;
		}
	);
});


//---------------------------- tempo slider  ---------------------------------------
~lowTempo = 60;
t = Slider.new(w,Rect(~coor.(2), ~y2, ~bWidth, ~bHeight));
t.action_({ |b|
	var tem = b.value * 100 + ~lowTempo;
	"New bpm: ".post;
	tem.postln;
	~tempo = ~convertBPM.(tem);
});
t.value = 0.3;

//---------------------------- tempo slider help text  -----------------------------
l = StaticText.new(w,Rect(~coor.(3), ~y2, 200, ~bHeight));
l.stringColor = Color.gray;
l.string_("bpm: [60, 160]");

//==================================================================================
//---------------------------- callback funcs --------------------------------------

~toDoik = {
	|d|
	d.postln;
	~doik.value(
		~insts.at(d.inst_), // Instrument
		~samples.at(d.sample_), // Sample
		d.dir_, // Direction [0..3]
		d.coor_ // X & Y coords
	);
};

//---------------------------- init function  --------------------------------------
// holds mappings of doik id's to their current coordinates.
~doikCoords = Dictionary.new();

~getDoiksFromDict = {
	var doiks = List.new();
	var dict = Library.at(\dict);
	"\tGetting doiks from current dictionary.".postln;
	dict.do{ |d, i|
		if (d.active_ == True) {
			d.debug_;
			doiks.add(~toDoik.(d));
		};
	};
	doiks;
};

~initAll = {
	// extract all doiks from the dictionary, and add them to the grid
	var grd;
	var doiks = ~getDoiksFromDict.();
	~grd = ~grid.value(~gridSize, doiks.asArray);
	~curGridID = ~grd.identityHash;
	~grd.debug_;
	s.boot(recover:true);

	~state = \play;
	~play.(~grd);
};

w.front;