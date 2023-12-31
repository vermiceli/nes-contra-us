Below is a detailed overview of the layout of the Contra ROM file's contents.

In summary, the ROM contains the following things

| Type                    | Percentage |  Bytes |
|-------------------------|------------|--------|
| Compressed Graphic Data |    49.179% | 64,461 |
| Code                    |    29.726% | 38,962 |
| Compressed Audio        |     8.109% | 10,629 |
| Unused                  |     5.585% |  7,320 |
| Configuration Data      |     4.027% |  5,278 |
| Sprite Data             |     2.677% |  3,509 |
| Text Data               |      .697% |    913 |

# ROM Map

* Header
  * `$00000-$0000F` - iNES ROM Header Data
* Bank 0
  * `$00010-$03D7A` - Enemy Logic
  * `$03D7B-$0400F` - Unused
* Bank 1
  * `$04010-$048F7` - Sound Engine Code
  * `$048F8-$06EAC` - Encoded Sound Data
  * `$06EAD-$0703F` - Code to Draw Sprites
  * `$07040-$07DF4` - Encoded Sprite Data
  * `$07DF5-$0800F` - Unused
* Bank 2
  * `$08010-$090A7` - Level Supertile Screen Assignments
  * `$090A8-$0B001` - Compressed Graphic Data
  * `$0B002-$0B328` - Player State Logic
  * `$0B329-$0B428` - Level Header Data
  * `$0B429-$0BD4B` - Enemy Generation Logic
  * `$0BD4C-$0C00F` - Unused
* Bank 3
  * `$0C010-$0FE09` - Supertile and Palette Data
  * `$0FE0A-$0FFBE` - End Level Routine Logic
  * `$0FFBF-$1000F` - Unused
* Bank 4
  * `$10010-$138C8` - Compressed Graphic Data
  * `$138C9-$13BA4` - Game End Routine Logic
  * `$13BA5-$13DD0` - Ending Credits Data
  * `$13DD1-$1400F` - Unused
* Bank 5
  * `$14010-$1736D` - Compressed Graphic Data
  * `$1736E-$17643` - Automated Demo Input
  * `$17644-$1800F` - Unused
* Bank 6
  * `$18010-$1B271` - Compressed Graphic Data
  * `$1B272-$1B3D6` - Text Data
  * `$1B3D7-$1BD35` - Weapon Logic
  * `$1BD36-$1C00F` - Unused
* Bank 7
  * `$1C010-$1F621` - Game Engine Logic
  * `$1F622-$1FC0F` - Unused
  * `$1FC10-$1FFDF` - Differential Pulse Code Modulation (DPCM) Data
  * `$1FFE0-$2000F` - NES Undocumented Footer

## Visual Rom Map

```
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCUUUUU
CCCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAACCCSSSSSSSSSSSSSSSSSSSSSSSSSSSUUUUD
DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGCCCCCCDDCCCCCCCCCCCCCCCCCCUUUUUUG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGCCCUG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGCCCCCCTTTTUUUUGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGDDDDDDUUUUUUUUUUUUUUUUUUUUG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGTTTCCCCCCCCCCCCCCCCCCCUUUUUU
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCUUUUUUUUUUUUAAAAAAAA
```

Legend
* G = Compressed Graphic Data
* C = Code
* A = Compressed Audio
* U = Unused
* D = Configuration Data
* S = Sprite Data
* T = Text Data