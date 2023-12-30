# Overview
This repository contains an annotated disassembly of the _Contra_ (US) NES ROM
and the build script(s) to reassemble the assembly into a byte-for-byte match of
the game.  This repo also contains supplemental documentation, diagrams,
scripts, and tools to further understand the game.

A special thanks goes to Trax.  This project would not have gotten started
without the amazing initial disassembly by him for his [Revenge of the Red
Falcon](https://www.romhacking.net/hacks/2701/) project.

```
|-- docs - supplemental documentation
|   |-- attachments - files used in other documentation
|   |-- debugging - files used to help debugging
|   |-- diagrams - mermaid diagram files documenting program flow
|   |-- lua_scripts - lua scripts for mesen and fceux
|   |-- sprite_library - extracted sprites for ease of viewing
|-- src - the source code for the game
|   |-- assets - the compressed graphics data and encoded audio for the game
|-- assets.txt - a list of assets, their offset in baserom.nes and their length
|-- build.bat - build script for Windows cmd (no PowerShell)
|-- build.ps1 - recommended build script for Windows (PowerShell)
|-- build.sh - bash build script for Linux/mac
|-- contra.cfg - memory mapping of PRG banks used when building
|-- README.md
|-- set_bytes.vbs - script used by build.bat to extract data from baserom.nes
```
# Building

In addition to _Contra_ (US), this repo can also build the _Probotector_ rom.
To keep instructions simple, the section below only contains instructions for
building _Contra_ (US).

If you are interested in building a _Probotector_ rom file, first read this
section to understand what is needed, then follow the instructions in the
section titled _Probotector_.

## Prerequisites
  * This repo does not include all assets (graphics data and audio data)
  necessary for assembling the ROM. An existing copy of the game is required.
  Place a copy of the US NES version of _Contra_ with the name `baserom.nes` in
  the project root folder.  The file will be used by the build script to extract
  the necessary assets.  The MD5 hash of `baserom.nes` ROM should be
  `7BDAD8B4A7A56A634C9649D20BD3011B`.
  * Building requires the [cc65 compiler suite](https://cc65.github.io/) to
  assemble and link the 6502 assembly files.  Please install it and ensure the
  bin folder is added to your path.

## Instructions
There are 3 build scripts in this repository. All of them do the same thing.  To
build the resulting .nes rom file, simply execute the appropriate build script
based on your environment.

| Environment             | Command       |
|-------------------------|---------------|
| Windows                 | `.\build.ps1` |
| Windows (no PowerShell) | `.\build.bat` |
| Mac/Unix/Linux          | `./build.sh`  |

* `build.ps1` - PowerShell script recommended for building on Windows machines.
  Some users have reported needing to run the script as admin to access the
  `baserom.nes`, although I haven't experienced this.  Additionally, on older
  versions of PowerShell, you may need to adjust the execution policy with the
  command `Set-ExecutionPolicy`.
* `build.bat` - bat script that can be used on windows machines without
  PowerShell, but requires VBScript support.
* `build.sh` - bash script to be used in unix environments, or on Windows
  environments with bash support (Git bash, WSL, etc.)

### Video Instructions
If you prefer video build instructions, @jdsilva has published a video on
YouTube called
[Contra ROM Compiling Tutorial](https://www.youtube.com/watch?v=Sa1O3S5YK5U)

## Documentation

Supplemental materials have been added that help explain interesting features of
the code.  Below are some of the more important documents.

* [docs/Aim Documentation.md](./docs/Aim%20Documentation.md) - documentation on
  how enemy aiming works
* [docs/Bugs.md](./docs/Bugs.md) - bugs identified while disassembling
* [docs/Contra Control Flow.md](./docs/Contra%20Control%20Flow.md) - detailed
  look at the game routine and level routine flows.
* [docs/Enemy Glossary.md](./docs/Enemy%20Glossary.md) - documentation on every
  enemy type in the game
* [docs/Enemy Routines.md](./docs/Enemy%20Routines.md) - documentation on level
  enemy configuration and random soldier generation.
* [docs/Graphics Documentation.md](./docs/Graphics%20Documentation.md) -
  documentation on pattern tables, nametables, palettes, palette cycling,
  super-tiles, background collision, and compression.
* [docs/ROM Map.md](./docs/ROM%20Map.md) - detailed description of ROM file
  contents 
* [docs/Sound Documentation.md](./docs/Sound%20Documentation.md) - documentation
  on the audio engine used as well as information on all sounds from the game.

All sprites were captured and labeled for easy reference in
[docs/sprite_library/README.md](./docs/sprite_library/README.md)

### Getting Started

At first, there is a lot to take in and it may be confusing where to start.
The files in the repo under the `src/` folder are broken up based on the memory
banks in the game.  The _Contra_ cartridge is a
[UxROM](https://www.nesdev.org/wiki/UxROM) cartridge.  The game has 8, 16 KiB
banks of memory for a total size of 128 KiB.  Banks 0 through 6 are swapped in
and out of memory at address $8000-$bfff and bank 7 is always in memory at
$c000-$ffff.  Knowing this helps understand the code since only 2 banks are
available at any given time.  The start of the game and most of the game engine
logic exists in `bank7.asm` since that's in memory all of the time and where
the 3 NES interrupts are.

I think a good way to start reading this code is to look into
`docs/Contra Control Flow.md`.  That file shows the responsibilities of the game
engine loop routines and in what order those routines are called.

* `bank0.asm` - used exclusively for enemy routines. Enemy routines are the
  logic controlling enemy behaviors and settings: AI, movements, attack
  patterns, health, etc. Almost every enemy is coded in bank 0, but some
  enemy routines, usually those who appear in more than one level, are in
  `bank7.asm`.
* `bank1.asm` - responsible for audio and sprites.  The audio code takes up
  about 3/4 of the bank. The remaining 1/4 of the bank is for sprite data and
  code to draw sprites.
* `bank2.asm` - starts with RLE-encoded level data (graphic super tiles for the
  level screens).  It then contains compressed tile data and alternate tile data
  and occasional attribute table data.  Then, bank 2 contains logic for setting
  the players' sprite based on player state.  Next, bank 2 contains the level
  headers, which define specifics about each level. Bank 2 then has the data
  that specifies which enemies are on which screen and their attributes.  Bank
  2 also contains the soldier enemy generation code.
* `bank3.asm` - starts with the data that specifies which pattern table tiles
  comprises super-tiles along with the color palettes.  This bank also has the
  routines to manage the end of levels.
* `bank4.asm` - mostly contains compressed graphic data. The rest of bank 4 is
  the code for the ending scene animation and the ending credits, including the
  ending credits text data.
* `bank5.asm` - mostly contains compressed graphic data.  The rest of bank 5 is
  the code and lookup tables for automated input for the 3 demo (attract)
  levels.
* `bank6.asm` - contains compressed graphics data, data for short text sequences
  like level names and menu options.  Bank 6 also contains the code for the
  players' weapons and bullets.
* `bank7.asm` - the core of the game's programming. Reset, NMI, and IRQ vectors
  are in this bank and is the entry point to the game.  Bank 7 contains the code
  for drawing of nametables and sprites, bank switching, routines for the intro
  sequence, controller input, score calculation, graphics decompression
  routines, palette codes, collision detection, pointer table for enemy
  routines, shared enemy logic, score table, enemy attributes, and bullet angles
  and speeds, and the NES undocumented footer, among other things.

### Annotations

While reviewing the assembly, I used a notation to categorize unexpected, or
interesting observations.  You can search the code for these annotations.

* `!(BUG?)` - a possible bug
* `!(HUH)` - unexpected code or logic used
* `!(WHY?)` - unsure of why the code is the way it is
* `!(UNUSED)` - unused code or data that is never executed nor read
* `!(OBS)` - observation or note

# Debugging

One of the biggest advantages of building this rom is that the build scripts
also build the debugging symbols.  Debugging symbols can be read by emulators
and be included in the source view while debugging the game.  For example,
[Mesen](https://github.com/SourMesen/Mesen2) will automatically load the
debugging symbols as long as the `contra.dbg` file exists in the same folder as
`contra.nes`.  Below is a screenshot of what debugging looks like with symbols.

![Mesen debugger screenshot](docs/attachments/mesen_debugger_screenshot.png?raw=true)

You can see that the debugging symbols file points to the source code to include
comments and labels.  If you move or delete the source files, you will lose all
the debugging information.

## FCEUX NameList

[FCEUX](https://fceux.com/web/home.html) doesn't support reading the debugger
symbols, but you can load NameList (`.nl`) files.  These files aren't as fully
featured as the debugging symbols file, but does at least allow you to label
jump/branch locations.  It doesn't easily support comments on individual lines.

I've included the `.nl` files in `docs/debugging/fceux_namelists`.  These files
were generated from the `-Ln contra.labels.txt` command line parameter to
`ld65`.  Then the that file was converted to the `.nl` files with a custom
script.  I can't promise to keep these up to date as the source labels change,
but I will try to.

# Project History
I first became interested in this project after watching the
[Summoning Salt](https://www.youtube.com/channel/UCtUbO6rBht0daVIOGML3c8w) video
[The History of Contra World Records](https://www.youtube.com/watch?v=GgOE64kgjjo).
In the video starting at 35m 19s, there was a section where a speedrunner named
`dk28` died in the middle of level 1, and was advanced to level 2 for their next
life.  The video explains that there still isn't a known explanation as to why
this happened.  This got me interested in the assembly and thus this project
began.  Spoilers, I have not found the cause of the level skip bug.  It is still
unknown whether the bug is from some bug in the code, or whether it was a
hardware glitch.

The _Contra_ (US) NES ROM was disassembled using a NES disassembly tool. This
provided a starting point for code investigation.  The disassembler incorrectly
marked many lines of code as data and this had to be manually corrected.  At
this point, there was an .asm file for each ROM bank in _Contra_.

Build scripts were then created for both windows console (.bat), and powershell
(.ps1).  These scripts are equivalent and use ca65 to assemble the .asm files
and cl65 to link the .o files into a single ROM file. Creating these build
scripts required defining the memory addresses and bank layouts in the
`contra.cfg` file.

At this point, I had a repository that could be built that matched the NES rom
byte for byte.  Then, I found and was able to incorporate the comments from
Trax's IDA Pro disassembly.  This was incredibly helpful, but more work had to
be done as Trax's disassembly couldn't be used directly for reassembly.  For
instance, it had a label for every line and all jump and branch statements were
hard-coded memory address offsets and not label references.

I then worked on updating all branch and jump offsets to point to label
addresses.  This helped ensure that the code was more readable.  At this point,
I also started updating data blocks that included memory offsets to use label
offsets.  The goal here was twofold:

 * make the code more readable and similar to what the original developers would
   have written
 * allow rom hacking without breaking the entire build due to breaking
   hard-coded memory offsets

When all of this was done, the project could assemble and be byte-for-byte
exactly as the _Contra_ (US) ROM.  However, this was just the prerequisite to
documenting the codebase.  Every label had to be given an appropriate name, and
each line of assembly had to be documented.

# Probotector
This repo can also produce a _Probotector_ rom file.  _Probotector_ is the
PAL-specific variation of the _Contra_ (US) game.  It is mostly identical except
different sprites.  For a full list of differences, see the document
`docs/Probotector.md`.

## Building

First read the section above for building _Contra_ (US) in general.  The process
is very similar.  Place a _Probotector_ rom in the root folder with the name
`baserom.nes`.  It should have a MD5 hash of `7127F616C13B58087481DD9E93AEB2FF`.

Then, depending on your environment, run one of the following commands.

| Environment             | Command                         |
|-------------------------|---------------------------------|
| Windows                 | `.\build.ps1 -Game Probotector` |
| Windows (no PowerShell) | `.\build.bat Probotector`       |
| Mac/Unix/Linux          | `./build.sh Probotector`        |

Notes of caution, especially for people building both _Contra_ (US) and
_Probotector_.

1.  Be sure you have the correct `baserom.nes` for the game you are building.
Otherwise, the generated rom will be incorrect.
2.  If you have _Contra_ (US) assets in the `/src/assets/` folder and are
building _Probotector_, or vice versa, the build scripts will delete the graphic
asset data and re-extract it from the `baserom.nes`. This prevents accidentally
using the wrong game's assets in the result rom.

# Build Details

The build scripts accomplish the following tasks:
 * extracts necessary data from `baserom.nes` into `src/assets`
 * assemble each bank .asm file into a .o file
 * assemble constants.asm and ines_header into .o files
 * link all output .o files into a single .nes rom file

The build scripts all utilize [cc65 compiler suite](https://cc65.github.io/) to
assemble and link the 6502 assembly files.  The asset data is pulled from
`baserom.nes` as specified in `assets.txt`.  Each line in `assets.txt` specifies
the file name of the asset, its offset into `baserom.nes`, and its length.

## 1. Assembly
Each .asm file is assembled into a .o object file.  This section outlines what
is happening as part of that process.

### Import Export Validation
During assembly, if any symbol is undefined and not explicitly defined in an
`.import` directive, an error will be generated.

## 2. Linking
Linking is the concept of combining the various .o object files into a single
.nes rom file.  This is done by the cl65 linker.  Its job is to replace labels
with actual CPU memory addresses where the labels will exist when loaded. These
are then stored in the resulting contra.nes rom file. This is aided by the
linker configuration file contra.cfg.

This file specifies the layout of the .net rom file.  Without this file, or with
a misconfigured file, the linker would not generate an identical .nes file.
There are two parts to the contra.cfg file: MEMORY layout and SEGMENTS layout.

### Contra.cfg MEMORY Layout
This section tells the linker where in memory each bank will exist.  The linker
needs this to know to replace a label with the correct address.  For example,
the opcodes that get generated for `jsr zero_out_nametables` depend on where in
memory the label `zero_out_nametables` will exist. This is what the
configuration file memory section specifies.

### Contra.cfg SEGMENTS Layout
This section specifies defines in which order the .o files should appear in the
resulting .nes rom file.

# References
 * Trax's [Disassembly of _Contra (US)_](https://www.bwass.org/romhack/contra/)
 * Trax's [documentation on romhacking.net](https://www.romhacking.net/documents/713/)
 * [Tomorrow Corporation's Retro Game Internal Series on Contra](http://tomorrowcorporation.com/posts/retro-game-internals)
 * [Overview of NES Rendering by Austin Morlan](https://austinmorlan.com/posts/nes_rendering_overview/)
 * [Rom Detective article on Contra](http://www.romdetectives.com/Wiki/index.php?title=Contra_(NES))