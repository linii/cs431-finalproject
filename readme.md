### (CS431: Computer Music) final project

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
