// Grid class implemented using Supercollider Environments. Instantiated
// using two parameters:
//
// size: the square dimensions of the grid as an integer. '3' would represent
//   a 3x3 grid
// initDoiks: an array of Doik classes comprising the doiks that initially
//   are present on the grid.
~grid = {
	|size, initDoiks|

	var initGrid;
	var totalDoiks;
	var pos;

	// Initialize a blank 2D array of dimensions (size x size), each element
	// of the array is an empty list.
	initGrid = Array2D.fromArray(size, size,
		Array.fill(size * size, {List.new(0)}));


	// For each Doik, add it to the Grid if there is no other Doik
	// on that spot.
	initDoiks.do { |d|
		d.debug_;
		pos = initGrid[d.coords_[0],d.coords_[1]];

		if (pos.size == 0 && ~gridCount != 0) {
			initGrid[d.coords_[0],d.coords_[1]].add(d);
			// Marcus note: I commented the following line out and replaced
			// it with the one above because I was unsure if the original
			// syntax would update the List in initGrid, or just a copy
			// of it from when 'pos' was created.
			// pos.add(d);
		}
	};

	// We keep track of how many Doiks are on the grid at any point in time
	totalDoiks = initDoiks.size;

	(
		// Total # of Doiks on grid
		doiks_: totalDoiks,

		// Size of grid
		size_: size,

		// Current state of the grid
		grid_: initGrid,

		// Helper function to print a list of Doiks passed as 'list'
		printDoikList_: {
			|self, list|
			"[".post;
			list.do { |d|
				"(".post;
				d.debug_;
				"), ".post;
			};
			"]".postln;
		},

		// Helper function: takes a set of coordinates and a direction
		// and returns 'true' if a Doik traveling in that direction from
		// those coordinates is hitting a wall. A wall exists at any
		// coordinate equal to 0 or (size_-1)
		isWallCollision: {
			|self, coords, dir|
			var x = coords[0];
			var y = coords[1];

			((y == 0 && dir == 0) ||
				((y == (self.size_ - 1)) && (dir == 2)) ||
				((x == (self.size_ - 1)) && (dir == 3)) ||
				((x == 0) && (dir == 1)));
		},

		// Returns a list of all Doiks that are hitting a wall
		getWallCollisions: {
			|self|
			var collisions = List.new(0);
			var doiks = self.extractAllDoiks.value;
			doiks.do { |d|
				if (self.isWallCollision(d.coords_, d.direction_)) {
					collisions.add(d);
				}
			};
			collisions;
		},

		// Returns True if 'doikList' and 'comp' have a non-empty intersection,
		//   false otherwise.
		doikInList: {
			| self, doikList, comp |
			var return = False;
			comp.do { |d1|
				doikList.do { |d2|
					if (d1.id_ == d2.id_) {
						return = True;
					};
				};
			};
			return;
		},

		// Return an array of all Doiks that have hit each other, and have NOT hit a wall
		getDoikCollisions: {
			| self, wallCollisions |
			var collisions = List.new(0);
			self.size_.do { |i|
				self.size_.do { |j|
					var ds = self.grid_[i,j];
					// If the Doik has NOT collided with the wall
					if (ds.size > 1 && self.doikInList(wallCollisions, ds) == False,
						{
							if (ds.size < 3, {
								ds.do { |d, k|
									self.grid_[i, j][k].direction_ = (d.direction_ + 1) % 4;
									self.grid_[i, j][k].coords_ = self.reverseCoordsOnCollision(d);
									self.grid_[i, j][k].count_ = d.count_ + 1;
									self.grid_[i, j][k].count_since_wall_ = d.count_since_wall_ + 1;
								}
							}, { });
						}, {}
					)
				}
			};
			collisions;
		},

		// Given a Doik, invert its direction and move it one unit in that direction
		reverseCoordsOnCollision: {
			|self, d|
			var newCoords;
			var x = d.coords_[0];
			var y = d.coords_[1];

			switch(d.direction_,
				{0}, { newCoords = [x, y + 1]},  // up -> down
				{1}, { newCoords = [x + 1, y]},  // left -> right
				{2}, { newCoords = [x, y - 1]},  // down -> up
				{3}, { newCoords = [x - 1, y]} // right -> left
			);

			newCoords;
		},

		// Returns a list of all Doiks in the grid
		extractAllDoiks: {
			|self|
			// because nobody lkes triple loops
			var allDoiks = List.new(0);
			self.size_.do { |i|
				self.size_.do { |j|
					var ds = self.grid_[i,j];
					ds.do { |d|
						allDoiks.add(d);
					}
				}
			};
			allDoiks;
		},

		// Generates the next iteration of the grid
		next_: {
			|self|
			var newDoiks, wallCollisions, doikCollisions, allDoikColls;
			"\n\n============= New Grid ===============\n\n".postln;

			// Create empty list of doiks for next iteration
			newDoiks = List.new(0);

			// Get a list of wall collision candidates
			wallCollisions = self.getWallCollisions.value;
			"Wall collisions:\t".post;
			self.printDoikList_(wallCollisions);

			// Get list of doik collision candidates
			doikCollisions = self.getDoikCollisions(wallCollisions);
			"Doik collisions:\t".postln;
			doikCollisions.do{ |ds|
				self.printDoikList_(ds);
			};

			// Calling ~onCollision is what "plays" this iteration of the grid. ~onCollision receives arrays of
			// the Doiks that have hit each other, and the Doiks that have hit a wall
			allDoikColls = ~onCollision.(doikCollisions,wallCollisions);

			// Update the grid:
			//   generic movement of each doik on the grid is according to its direction
			self.size_.do { |i|
				self.size_.do { |j| // For every (x,y) cell on the grid
					var ds = self.grid_[i,j];
					ds.do { // For every doik in that cell
						|d|
						d.lifetime_ = d.lifetime_ + 1; // The doik has lived for one more unit of time

						switch (d.direction_, // Placement of doik in next iteration depends on direction it was moving
							{0}, { // up
								if (self.isWallCollision(d.coords_, d.direction_), // If it has collided with a wall
									{
										d.direction_ = (d.direction_ + 2) % 4; // Reverse its direction
										d.coords_ = [d.coords_[0], 1]; // Update its position
										d.count_ = d.count_ + 1; // Update .count_ of collisions
										d.count_since_wall_ = 0; // Update number of iterations since last wall collision
									}, {
										if (self.doikInList([d], allDoikColls) == False) { // It hasn't collided with a wall
											// Continue moving in original direction
											d.coords_ = [d.coords_[0], d.coords_[1]-1];
											d.count_since_wall_ = d.count_since_wall_ + 1;
										}
									}
								)

							},
							{1}, { // left
								if (self.isWallCollision(d.coords_, d.direction_),
									{
										d.direction_ = (d.direction_ + 2) % 4;
										d.coords_ = [1, d.coords_[1]];
										d.count_ = d.count_ + 1;
										d.count_since_wall_ = 0;
									}, {
										if (self.doikInList([d], allDoikColls) == False) {
											d.coords_ = [d.coords_[0]-1, d.coords_[1]];
											d.count_since_wall_ = d.count_since_wall_ + 1;
										}
									}
								)
							},
							{2}, { // down
								if (self.isWallCollision(d.coords_, d.direction_),
									{
										d.direction_ = (d.direction_ + 2) % 4;
										d.coords_ = [d.coords_[0], self.size_ - 2];
										d.count_ = d.count_ + 1;
										d.count_since_wall_ = 0;
									}, {
										if (self.doikInList([d], allDoikColls) == False) {
											d.coords_ = [d.coords_[0], d.coords_[1] + 1];
											d.count_since_wall_ = d.count_since_wall_ + 1;
										}

									}
								)

							},
							{3}, { // right
								if (self.isWallCollision(d.coords_, d.direction_),
									{
										d.direction_ = (d.direction_ + 2) % 4;
										d.coords_ = [self.size_ - 2 , d.coords_[1]];
										d.count_ = d.count_ + 1;
										d.count_since_wall_ = 0;
									}, {
										if (self.doikInList([d], allDoikColls) == False) {
											d.coords_ = [d.coords_[0] + 1, d.coords_[1]];
											d.count_since_wall_ = d.count_since_wall_ + 1;
										}
									}
								)
							}
						);

						newDoiks.add(d);
					};
				}
			};

			"New doiks:".postln;
			newDoiks.postln;

			// Update our internal grid representation to represent all Doik movement
			self.grid_ = ~grid.(self.size_, newDoiks).grid_;
			self.numDoiks_ = self.extractAllDoiks.value.size;

			// Print the positions of Doiks on the grid
			self.debug_;
		},

		debug_: {
			|self|

			"\n\nGrid:  \tNumber of doiks: ".post;
			self.numDoiks_.postln;
			"\n".postln;
			self.size_.do { |i|
				self.size_.do { |j|
					if (self.grid_[j, i].size == 0, {
						"\t[    ]".post;
					}, {
						"\t[ ".post;
						self.grid_[j, i].do {
							//|d|
							//d.debug_.value;
							":D".post;
						};
						" ]".post;
					});
				};
				"\n\n".postln;
			};
		},
	)
};

