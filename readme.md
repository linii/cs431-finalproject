### (CS431: Computer Music) final project – GrainyGrid

GrainyGrid allows semi-structured grainular synthesis composition. The 'grid' is a two-dimensional square. Each square of the grid can hold one or many 'doiks.' A 'doik' is just a unit that can move around on the grid. Initially, it has a starting position on the grid, a direction, a sound sample, and an instrument.

The grid updates regularly, according to how many beats per minute it is running at. On each update, doiks move one step in their direction. Sometimes, they hit a wall and reverse their direction. Sometimes they hit each other, and bounce off. When they collide, they swap the samples they each carry.

Instruments and samples provide the basis for audio synthesis: an instrument is defined independently of a sample, but it is 'played' upon the sample it is packaged with inside of a doik. The instrument is a set of 'grains', again defined independently of the sample. There are various instruments you can choose from and they all sound a little different: some of them are 'fixed': when applied to a sample they always play the same sound. Some of them are defined functionally and will sound slightly different, but similar, when played against the sample multiple times. In this way, music generated in GrainyGrid generally has identifiable patterns but remains organic enough to never 'loop'. The combination of a set of instruments and samples that generate families of interrelated yet distinct sound with a grid endowing these sounds with rhythmic movement allows the creation of novel through a straightforward GUI. The GUI allows for experimentation and rapid prototyping, because very different soundscapes can be greated through changing only a few parameters. The ability to load your own sounds and apply instrumentation to them positions our GUI as a really basic digital audio workstation.

## Overview
- Granular synthesis
- Automata
- Intentionality

## Running with GUI

1. Boot server.
2. Evaluate: `doik.scd`, `grid.scd`, `instrument.scd`, `sample.scd`, `player.scd`
- of these: `sample.scd` requires the server to be booted.
3. Evaluate `gui.scd` **two times**.
- The first time, it will be very slow and give you a view w/o the grid.
4. Enjoy
5. The GUI is designed to faciliate semi-live production of music. The grid shown will NOT update live, but you can:
    - PAUSE and add new doiks, customizing dir / sample / instrument, then hit PLAY again
    - drop new doiks as the music is playing, which will initiate it with a random direction, sample, instrument
    - dynamically change the bpm
6. If you want to completely start over, it is best to stop the server, close the gui and reopen it again.

## Sounds

can be found under the `sounds/` folder.

**Team members:**
Marcus Russi
Lining Wang
