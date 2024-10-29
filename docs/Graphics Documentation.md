# Overview

In the NES, a frame consists of the background and the sprites.  Both the
background and the sprites are composed of 8x8 pixel tiles from the pattern
table.  The background is 32 tiles wide and 30 tiles tall, for a total of
256x240 pixels. This data structure is called the nametable.  Each byte in the
nametable references an index into the pattern table.

The pattern table is the data structure that describes what the 8x8 tiles in the
nametable and sprites look like.  Each pattern table entry is 16 bytes.  This is
the fundamental drawing block of the NES.

There are 4 nametables in total, but only 2 are written to and the remaining two
are copies of the initial 2 nametables (mirroring).  Additionally, each
nametable has 64-bytes at the end to specify which palette is assigned each part
of the nametable.  This is called the attribute table.  Each entry in the
attribute table specifies the palette for a 4x4 set of tiles in the nametable.

Finally, there are sprites, which are drawn on top of the nametable and can be
easily moved around the screen.

Addresses specified in this article include both the address that is used by the
NES CPU to locate data, as well as the offset address in the PRG ROM where the
referenced address is.  Note that a ROM file has a #$10 byte iNES header that
doesn't exist in actual PRG ROM. So when using the ROM address to look for the
location in a NES ROM file, you will need to add an addition #$10 bytes to the
ROM address.

## Terms

 * Attribute Table - one of 2 64-byte tables (one for each nametable) that
     specifies which palettes to use for each part of the nametable
 * Background - A combination of the nametable and the attribute table
 * Graphic data - sections of compressed graphic data, typically pattern data,
     but can be nametable data, or even attribute data as well
 * Nametable - matrix of bytes referencing items in the pattern table. Can
     generally be thought of as the background.
 * Palette - a set of 4 colors that can be used for coloring a tile
 * Pattern table - a 16 byte object defining the look of an 8px by 8px tile
 * Screen - a set of super-tiles for a level that is 256 pixels wide
     * For horizontal levels, the size of a screen is 8x7 super-tiles, and for a
       vertical level it is 8x8 super-tiles
 * Sprite - a graphical element composed of pattern table tiles. Some
     documentation refers to these as 'objects'.
     * Sprites in _Contra_ are 8x16, meaning 2 pattern table tiles make up each
       component of a sprite.
 * Super-tile - a group of 4x4 set of tiles that are used to construct a level's
     nametable.  This term isn't standard and was borrowed from part 2 of Allan
     Blomquist's 7-part series on _Contra_ called [Retro Game Internals](https://tomorrowcorporation.com/posts/retro-game-internals-contra-levels).
     Some people may refer to this as a meta tile.
 * Tile - an element of the nametable, represents an 8x8 pixel from the pattern
   table

# Background

Usually, for attribute, palette, and sprite data, the data is first loaded from
the PRG ROM and then moved into CPU memory.  Then, every frame that data is read
from CPU memory into the PPU to display.  Pattern table data is read directly
from PRG ROM into the PPU.

The graphic data is in various places throughout the PRG ROM. For example
(with the exception of the intro sequence and ending sequence), the palette
colors are in bank 7, while the attribute table data is mostly in bank 3.  For
the game pattern table data, this is stored in compressed blocks in banks 2, 4,
5, and 6.  I refer to these blocks of data as 'graphic data', because while it
mostly stores pattern table data, in some cases (intro, outro, and clearing
screen) it does store nametable, and attribute data.

The graphic data in the game ROM are compressed using a encoding system known as
[Run-length encoding](https://en.wikipedia.org/wiki/Run-length_encoding) (RLE).
This algorithm is covered in another section in this document.  As the graphic
data are loaded into PPU memory from ROM memory, they are decompressed.

A level contains multiple "graphic data". These make up all the graphics (minus
sprites) necessary for a level.

As part of loading graphics a level, the `load_level_graphic_data` label is
executed, this looks up the appropriate graphic data from the
`level_graphic_data_tbl` and then immediately proceeds to decompress and write
the data to the PPU with label `write_graphic_data_to_ppu`.

As an example, the 7 graphic data used for level 1 `level_1_graphic_data`
(ROM: $1c8fd, MEM: $c8fd) are as follows: #$03, #$13, #$19, #$1a, #$14, #$16,
#$05, #$ff.  Each byte is an offset entry into the `graphic_data_ptr_tbl` table.

`load_level_graphic_data` will load each of those graphic data offsets into the
A register and then call `write_graphic_data_to_ppu`, which decompresses and
writes the graphics into the PPU.  This is repeated by `load_level_graphic_data`
until the offset specified is #$ff, which signifies there are no more graphics
data for the level to load.

While in theory you could specify the nametable with this same scheme, the
level's nametables are not specified in these graphics data in general and
instead graphics data is used only for pattern and attribute data.  The only
time the graphics data contains nametable data is for either blanking the
nametable (`graphic_data_00` (ROM: $1cb36, MEM: Bank 7 $cb36)), or setting up
the nametable for the intro and ending scenes (`graphic_data_02` and
`graphic_data_18` respectively).  Level nametable information is populated by
"Super-Tiles".  Read that section for more information.

In general, the left pattern table, PPU addresses [$0000-$1000), is used for
storing pattern tiles associated with sprites. The right pattern table, PPU
addresses [$1000-$2000), is used for storing pattern tiles associated with the
nametable.  This is useful to understand, because sprites are displayed with 2
pattern table tiles, making up a 8x16 sprite.  So, when viewing the PPU during
a level with any debugging tools, it's appropriate to view the left pattern
table as 8x16 sprites if that option is available.

## Graphics Data Locations

Below is a table of all graphic data locations in the ROM (excluding alternate
graphics data).

The PPU Address ranges are specified in interval notation.
  * The square brackets [] represent 'closed interval' and the address is
    included in the range
  * The parentheses () represent 'open interval' and are not included in the
    range

| Label Name        | Bank | Label In-Memory Address | PRG ROM Address | Graphics Data                             | PPU Addresses                                                      | Comments                                                                                                                                         |
|-------------------|------|-------------------------|-----------------|-------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `graphic_data_00` | 7    | `$cb36`                 | `$1cb36`        | Both nametables and Both Attribute tables | `[$2000-$2800)`                                                    | Sets all Nametable + Attribute table data to #$00.                                                                                               |
| `graphic_data_01` | 4    | `$aa2d`                 | `$12a2d`        | Left and Right Pattern tables             | `[$0ce0-$1f80)`                                                    | Used for intro screen, level title screens, and game over screens. Contains Contra logo, Bill and Lance, letters, numbers, and falcon tiles.     |
| `graphic_data_02` | 2    | `$9097`                 | `$9097`         | Nametable 0 and Attribute table 0         | `[$2000-$2400)`                                                    | Used for intro screen, contains layout of tiles for intro screen text.                                                                           |
| `graphic_data_03` | 4    | `$8001`                 | `$10001`        | Left Pattern table                        | `[$0000-$0680)`                                                    | Used in every level. Contains Bill and Lance outdoor sprite tiles, game over letters, lives medals, power-ups (SBFLRM), and explosions.          |
| `graphic_data_04` | 4    | `$85ae`                 | `$105ae`        | Left Pattern table                        | `[$0680-$08c0)`                                                    | Used in indoor/base levels. Player sprite pattern tiles.                                                                                         |
| `graphic_data_05` | 5    | `$8001`                 | `$14001`        | Left and Right Pattern tables             | `[$09a0-$0a80)`, `[$0dc0-$1200)`, `[$1320-$1600)`, `[$1bd0-$2000)` | Level 1 bridge, mountain, trees, and water tiles.  Player prone, and flying capsule tiles.                                                       |
| `graphic_data_06` | 4    | `$99fc`                 | `$119fc`        | Left and Right Pattern tables             | `[$08c0-$1100)`                                                    | Used in indoor/base levels.  Indoor player sprites, grenades, and som indoor/base background graphics                                            |
| `graphic_data_07` | 5    | `$8a61`                 | `$14a61`        | Left and Right Pattern tables             | `[$09a0-$0a80)`, `[$0dc0-$1200)`, `[$1320-$1600)`, `[$1bd0-$2000)` | Level 3 background and sprite pattern table tiles.  Player prone, and flying capsule tiles.                                                      |
| `graphic_data_08` | 4    | `$886c`                 | `$1086c`        | Left and Right Pattern tables             | `[$09a0-$2000)`                                                    | Indoor/base boss screen background and sprite pattern table tiles.                                                                               |
| `graphic_data_09` | 4    | `$99cd`                 | `$119cd`        | Left Pattern table                        | `[$0b00-$0b40)`                                                    | Level 4 boss screen sprite pattern table tiles. Just 3 tiles.                                                                                    |
| `graphic_data_0a` | 4    | `$a005`                 | `$12005`        | Right Pattern table                       | `[$1100-$1520)`                                                    | Indoor/base pattern table tiles.  Same as `graphic_data_10`, but horizontally flipped.                                                           |
| `graphic_data_0b` | 5    | `$93e0`                 | `$153e0`        | Left and Right Pattern tables             | `[$09a0-$0a80)`, `[$0dc0-$1200)`, `[$1320-$1600)`, `[$1bd0-$2000)` | Level 5 pattern table tiles.                                                                                                                     |
| `graphic_data_0c` | 6    | `$8001`                 | `$18001`        | Left and Right Pattern tables             | `[$09a0-$0a80)`, `[$0dc0-$0ee0)`, `[$0fc0-$1200)`, `[$1320-$2000)` | Level 6 pattern table tiles.                                                                                                                     |
| `graphic_data_0d` | 6    | `$8cdc`                 | `$18cdc`        | Left and Right Pattern tables             | `[$09a0-$0a80)`, `[$0dc0-$0ee0)`, `[$0fc0-$1200)`, `[$1320-$2000)` | Level 7 pattern table tiles.                                                                                                                     |
| `graphic_data_0e` | 6    | `$9bd6`                 | `$19bd6`        | Left and Right Pattern tables             | `[$09a0-$2000)`                                                    | Level 8 pattern table tiles.                                                                                                                     |
| `graphic_data_0f` | 4    | `$a346`                 | `$12346`        | Right Pattern table                       | `[$1520-$1600)`                                                    | Indoor/base pattern table tiles.  #$0e background tiles total.                                                                                   |
| `graphic_data_10` | 4    | `$a003`                 | `$12003`        | Right Pattern table                       | `[$1600-$1a20)`                                                    | Indoor/base pattern table tiles.  Same as `graphic_data_0a`, but horizontally flipped.                                                           |
| `graphic_data_11` | 4    | `$a3e7`                 | `$123e7`        | Right Pattern table                       | `[$1a20-$2000)`                                                    | Indoor/base background pattern table tiles.                                                                                                      |
| `graphic_data_12` | 4    | `$a940`                 | `$12940`        | Right Pattern table                       | `[$1b90-$1ca0)`                                                    | Level 4 background pattern table tiles.                                                                                                          |
| `graphic_data_13` | 4    | `$87a1`                 | `$107a1`        | Left Pattern table                        | `[$08c0-$09a0)`                                                    | Player top-half aiming angled up and player aiming straight.  Also contains the laser bullet sprites.                                            |
| `graphic_data_14` | 5    | `$a814`                 | `$16814`        | Right Pattern table                       | `[$1600-$1bd0)`                                                    | Rotating gun and red turret pattern table tiles.                                                                                                 |
| `graphic_data_15` | 6    | `$b07a`                 | `$1b07a`        | Left Pattern table                        | `[$0ee0-$0fc0)`                                                    | Level 5, 6, and 7 sprite pattern table tiles for turret man (basquez).                                                                           |
| `graphic_data_16` | 6    | `$b15c`                 | `$1b15c`        | Right Pattern table                       | `[$1200-$1320)`                                                    | Weapon box pattern table tiles.                                                                                                                  |
| `graphic_data_17` | 5    | `$addf`                 | `$16ddf`        | Left and Right Pattern tables             | `[$0a60-$0fe0)`, `[$15b0-$18a0)`                                   | Ending scene pattern table tiles. Includes helicopter sprite tiles and island background tiles.                                                  |
| `graphic_data_18` | 5    | `$b30d`                 | `$1730d`        | Nametable 0 and Attribute table 0         | `[$2000-$2400)`                                                    | Nametable and attribute table data for ending scene.                                                                                             |
| `graphic_data_19` | 5    | `$a31b`                 | `$1631b`        | Left Pattern table                        | `[$0680-$08c0)`                                                    | Player killed sprite tiles: recoil from hit and lying on ground.                                                                                 |
| `graphic_data_1a` | 5    | `$a500`                 | `$16500`        | Left Pattern table                        | `[$0a80-$0dc0)`                                                    | Enemy soldier sprite pattern table tiles.                                                                                                        |

Interestingly, the outdoor player prone and flying capsule sprite tiles are duplicated on all outdoor levels.

## Background Collision Data

The tiles in the pattern tables are ordered by which collision group they are
in.  There are 4 collision groups in Contra.  The level header byte offsets
#$09, #$0a, and #$ab define the boundaries of each collision group.  For
example, level 1's tile collision boundaries are $06, $f9, and $ff.  This means

  * Pattern tile index $00 has collision code 0 (empty). This is always true
  * Pattern tile indexes $01-$05 have collision code 1 (floor)
  * Pattern tile indexes $06-$f8 have collision code 0 (empty)
  * Pattern tile indexes $f9-$fe have collision code 2 (water)
  * Pattern tile index $ff has collision code 3 (solid)

For this reason, sometimes there are duplicate pattern table tiles, simply to
create barriers.

The collision codes are defined as follows. Technically Collision Code 2 is
treated as Collision code 0 #$00
  * Collision Code 0 (Empty) - tiles that have no collision data. Objects can
    freely pass through the tile
  * Collision Code 1 (Floor) - tiles that objects can land on when falling but
    pass through when moving left, up and right. Can fall through (drop down)
    with d-pad down, plus A only when there is another non-empty object below
    (or on vertical level).
  * Collision Code 2 (Water) - similar to code 1, but for water, prevents
    jumping, and causes player/enemy sprites to show only top half
  * Collision Code 3 (Solid) - The tile is solid and cannot be gone through
    regardless of directions or side.

For outdoor levels, the nametable collision codes are stored in CPU memory
`BG_COLLISION_DATA` [$0680-$0700).  Nametable collision codes are only stored
for every other column and every other row of the nametable.  Since a super-tile
is 4 columns wide and 4 columns tall, a single super-tile has 4 collision code
points: top left, middle left, middle top, and middle middle.

Each byte in `BG_COLLISION_DATA` can be broken down into 4 collision codes.
Every 2 bits represents the collision code (0, 1, 2, or 3) for every other
pattern table tile. The first 4 bytes are for the top row of collision points
for a single nametable row. The next 4 bytes are the next nametable row of
pattern table tiles.  This pattern repeats until all of the first nametable data
is specified and then is repeated for the 2nd nametable.  For a given background
collision index, add #$04 to determine the next row down.  The following is an
example of the byte offsets from `BG_COLLISION_DATA` for the top left nametable.
Note that next nametable starts at offset #$40 and not #$38.

```
00 00 00 00 01 01 01 01 02 02 02 02 03 03 03 03
04 04 04 04 05 05 05 05 06 06 06 06 07 07 07 07
08 08 08 08 09 09 09 09 0a 0a 0a 0a 0b 0b 0b 0b
0c 0c 0c 0c 0d 0d 0d 0d 0e 0e 0e 0e 0f 0f 0f 0f
10 10 10 10 11 11 11 11 12 12 12 12 13 13 13 13
14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 17
18 18 18 18 19 19 19 19 20 20 20 20 21 21 21 21
22 22 22 22 23 23 23 23 24 24 24 24 25 25 25 25
26 26 26 26 27 27 27 27 28 28 28 28 29 29 29 29
30 30 30 30 31 31 31 31 32 32 32 32 33 33 33 33
34 34 34 34 35 35 35 35 36 36 36 36 37 37 37 37
```

Indoor/base levels do not really rely on the `BG_COLLISION_DATA` for background
collision detection.  The level header byte offsets #$09, #$0a, and #$ab for
the indoor/base levels are #$00, #$ff, #$ff, which means all tiles are collision
code 0, i.e. empty.  The player is prevented from walking past the left and
right on indoor/base levels walls manually in the code, e.g. see
`level_right_edge_x_pos_tbl`, and `level_left_edge_x_pos_tbl`.

## Super-Tiles
_Contra_'s level nametable data is made up of "Super-tiles". Each super-tile is
#$10 bytes long and made of 4 rows of 4 pattern table entries each. Super-tiles
are not RLE-encoded.  A super-tile is how the level nametable's are defined and
can be thought of as smallest unit of art that can be used for nametable drawing
in a level.  This isn't technically true, because a nametable can be updated
after it's drawn for certain animations (claw, fire beam, etc).  For horizontal
levels, a background is composed of #$38 super-tiles (8x7). For the vertical
level, a background is composed of #$40 super-tiles (8x8).

Within a super-tile, there are 4 2x2 sections each #$4 bytes long.

The location of the pattern table tiles of each super-tile pattern is specified
in the 2-byte level header data byte #$04 (`LEVEL_SUPERTILE_DATA_PTR`).  For
example, level 1's super-tile data is defined at `level_1_supertile_data`
(ROM: $c001, MEM: Bank 3 $8001). Each #$10 bytes is a single super-tile.  Level
1 has a total of #$3b distinct super-tiles.

For each level, the 2-byte level header offset byte #$02
(`LEVEL_SCREEN_SUPERTILES_PTR`) specifies which super-tiles are part of each
'screen'.  A 'screen' is the set of #$38 or #$40 super-tiles that make up a
single background.  For an example, level 1's screen super-tile index data is
located at `level_1_supertiles_screen_ptr_table`
(ROM: $8001, MEM: Bank 2 $8001). Each entry specifies the super-tiles used for a
single screen.  The super-tiles used in the first screen of level 1 are
specified at `level_1_supertiles_screen_00` (ROM: $801d, MEM: Bank 2 $801d).
This data is compressed with RLE-encoding

Super-tiles indexes are stored in CPU memory and referenced when drawing the
background.  2 screens of super-tile indexes are stored in memory at a time.
This is to support scrolling.  The super-tiles indexes for the screens are
loaded into CPU memory at location $0600 (`LEVEL_SCREEN_SUPERTILES`) by
`load_supertiles_screen_indexes` and used when writing the pattern table tile
data to CPU memory by `load_level_supertile_data`.  The writing of the
super-tiles to the nametable takes place incrementally, one nametable column at
a time.

# Sprites
Sprites are movable objects that are composed of elements from the pattern
table.  This documentation refers to a group of sprites together as a single
sprite.  For example, Bill is composed of 5 sprites, but will spoken about as
a single sprite.  Sprites in _Contra_ are composed of 2-block pattern table
entries stacked on top of each other, making the smallest part of a sprite 8x16.
Like most NES games, _Contra_ does not write sprite data directly to the PPU
byte by byte via the `$2004` (OAMDATA) address but instead utilizes the `$4114`
(OAMDMA) address. OAMDMA stands for Object Attribute Memory Direct Memory
Access.  The OAMDMA address is set to #$02, which tells the PPU to load sprite
data from the address range `$0200` to `$02ff` inclusively every frame.

All of the sprites in _Contra_ are in bank 1 starting with `sprite_00` (ROM:
$71ce, MEM: Bank 1 $b1ce).  Each sprite can be referred to by an index starting
from 00.  I refer to these as the "sprite code" or "sprite number".  There are
two large pointer tables that point to each sprite address: `sprite_ptr_tbl_0`
and `sprite_ptr_tbl_1`.

## Sprite CPU Buffer
Sprites are drawn on the screen every frame after the current game routine is
run. This done in the `draw_sprites` label (ROM: $6e97, MEM: Bank 1 $ae97).
`draw_sprites` uses data stored in `$0300` to `$0367` inclusively. I refer to
this area of memory as the sprite cpu buffer.  _Contra_ supports a maximum of
#$19 sprites on screen simultaneously. However, the certain addresses are
reserved for "player" sprites, whereas other addresses are reserved for enemy
sprites.  The list below shows how the sprite CPU buffer is partitioned

| Address Range      | Length     | Alias             | Usage                                                                              |
|--------------------|------------|-------------------|------------------------------------------------------------------------------------|
| `$0300` to `0309`  | #$0a bytes | PLAYER_SPRITES    | sprite number for player and player bullets (`sprite_ptr_tbl` or `sprite_ptr_tbl_1`|
| `$030a` to `0319`  | #$10 bytes | ENEMY_SPRITES     | enemy sprite number (`sprite_ptr_tbl` or `sprite_ptr_tbl_1`)                       |
| `$031a` to `0323`  | #$0a bytes | SPRITE_Y_POS      | y position on screen of the each sprite                                            |
| `$0324` to `$0333` | #$10 bytes | ENEMY_Y_POS       | y position of each enemy sprite                                                    |
| `$0334` to `$033d` | #$0a bytes | SPRITE_X_POS      | x position on screen of the each sprite                                            |
| `$033e` to `$034d` | #$10 bytes | ENEMY_X_POS       | x position on screen of the each enemy sprite                                      |
| `$034e` to `$0357` | #$0a bytes | SPRITE_ATTR       | sprite attributes (palette, whether to flip horizontally, vertically)              |
| `$0358` to `$0367` | #$10 bytes | ENEMY_SPRITE_ATTR | sprite attributes (palette, whether to flip horizontally, vertically)              |

`draw_sprites` loops from #$19 to #$00 and uses the data from the sprite CPU
buffer to populate the #$100 bytes `$0200` to `$02ff`.  This data is then moved
to the PPU with OAMDMA when in vertical blank `nmi_start`.

One neat trick that's done when loading data from the sprite CPU buffer to the
`$0200` page memory is that every time the `draw_sprites` label is called, an
offset of #$4c is added to the write address. This causes the sprites to be
placed in a different starting spot in the `$0200` page every frame.  This is
done to work around a limitation of the NES that restricts a scan line from
having more than 8 sprites. By moving the sprites around in memory, if there are
too many sprites on a scan line, different sprites will be drawn on different
frames. The player shouldn't be able to detect a sprite missing if drawn quickly
enough.

When filling the OAMDMA data, the sprite tiles aren't written sequently, but
rather spaced every 49 sprite tiles apart (#$c4 bytes) wrapping around. I'm not
sure why this was done. Perhaps it has to do with concern about dynamic RAM
decay that OAM has.

## Sprite Number Encoding
The sprite data in bank 1 is encoded.  Except when #$fe, the first byte
specifies the number of entries in the sprite.  Then there are that many groups
of 4-bytes. Each #$4 bytes specify two tiles that are stacked vertically.
Except when the first byte is #$80, these four bytes follow the PPU OAM byte
specification.  For details on this data structure,
[NES Dev Wiki](https://wiki.nesdev.org/w/index.php?title=PPU_OAM) has a good
article on this.  These specifics are also outlined below.

  * Byte 0 specifies the y position of the tile relative to where the sprite is
    placed on the screen. This can be negative.
    * If Byte 0 is #$80, then it is a signal to change the read address. The
      next two bytes specify the CPU address to move to. This functionality
      allows sprites to share pieces from other sprites.
  * Byte 1 is the tile number, i.e. which tile in the pattern table to use.
    * Since sprites are built from 8x16 components, and byte 1 only specifies
      the first tile, the second tile stacked immediately below this tile is
      always the next one in the pattern table. For example, if byte 1 is #$05,
      then the two tiles will be #$05 and #$06. If the tile specified is even,
      then the tile
    * All of _Contra_'s sprites are composed of even bytes, meaning the tile is
      pulled from the left pattern table ($0000-$0fff).
  * Byte 2 specifies various attributes that can be used to modify the tiles
    * Bit 7 (`x... ....`) specifies vertical flip
      * When the vertical flip bit is set, the top and bottom tiles are drawn
        vertically flipped.  Also, the top tile is drawn at the bottom and the
        bottom tile is drawn at the top.
    * Bit 6 (`.x.. ....`) specifies horizontal flip
      * Whether or not to flip the tile horizontally
    * Bit 5 (`..x. ....`) specifies drawing priority
      * 0 = in front of background; 1 = behind background
    * Bits 1 and 0 (`.... ..xx`) specify the palette code
      * These bits specify the palette to use for the sprite
  * Byte 3 specifies the x position of the tile relative to where the sprite is
    placed on the screen. This can be negative.

When the first byte of the sprite code is #$fe, the sprite is a "small" sprite.
Small sprites are composed of #$3 bytes, including the #$fe byte.  Small sprites
always have their X position shifted left by #$04 and their Y position shifted
up by #$08.

  * Byte 0 is #$fe and signifies the sprite is a small sprite
  * Byte 1 specifies the tile number
  * Byte 2 is the sprite attributes

Note: Sprites are also referred to as objects. This explains the names of some
addresses in NES like Object Attribute Memory (OAM).

# Palette
The NES supports 4 palettes for the nametables (background) and 4 palettes for
sprites.  A palette is a set of 4 colors. For nametables, one palette is shared
for each square 16x16 set of 4 pattern table tiles.  For sprites, each tile in a
sprite has its own palette.

Defining which palette is assigned to which super-tile is located in bank 3. The
level headers specify the location in bank 3 of where the super-tile palette
data is defined (see `LEVEL_SUPERTILE_PALETTE_DATA`).  This data is used to
populate the attribute table.

For each sprite tile, the palette used is specified in the two least significant
bits of byte 2 of the sprite OAM data. For details about how sprites are stored
in the PRG ROM, see Sprite Number Encoding.

The initial colors that are associated with each palette are specified in the
level header starting at byte offset 15 (see `LEVEL_PALETTE_INDEX`).  Each of
the next 8 bytes specify an entry into `game_palettes`. The first 4 bytes are
the nametable palette colors, and the next 4 bytes are the sprite palette
colors. Each entry in `game_palettes` specifies the 3 colors that make up the
palette.  Each palette always starts with a black color #$0f.  Combined this
is how the 4 colors of each palette are determined.

## Fade-In Effect
_Contra_ supports a fade in effect for nametable palettes.  This effect is used
various parts of the game like base/indoor boss screens, dragon, and boss ufo.
This is implemented by adjusting the specified nametable palette colors by an
amount specified in `palette_shift_amount_tbl` when `BG_PALETTE_ADJ_TIMER` is
specified and within range [#$01-#$09].  To utilize this effect, the code sets
the `BG_PALETTE_ADJ_TIMER` to a value larger than #$09.  Every frame, this value
is decremented. When loading the palette colors for the frame, if
`BG_PALETTE_ADJ_TIMER` is greater than #$09, then the palette color will be
black, but once the value is in range, the palette colors will start to be
modified.  For example, to create the fade-in effect of the base/indoor boss
screen background, the value of `BG_PALETTE_ADJ_TIMER` is set to #$0c. This
gives #$03 frames of black, before the fade in effect starts.

## Cycling
_Contra_ cycles the colors within nametable palettes during game play.  The
palettes specified by the nametable don't change, but rather the colors within
the palettes are changed.  By swapping out the colors, _Contra_ can create
animations like blinking stars, waves in water, waterfalls, etc. Each level
natively supports having its 4th nametable (background) palette cycle through up
to 4 different sets of colors, where each set of colors is represented by an
index into the `game_palettes` table.  The specific indexes to cycle through are
in the level headers (`LEVEL_PALETTE_CYCLE_INDEXES`).  Level 3 (Waterfall) is
special in that it only cycles among 3 different sets of colors instead of 4
(see `lvl_palette_animation_count`).

Additionally, all levels cycle their 3rd nametable palette colors through a
single, shared set of palette indexes (`level_palette_2_index`).  This cycle of
colors is a flashing red. It is used so that enemies have flashing red lights.

Finally, there are a few special nametable cycles, like for indoor (base) boss
screens (`indoor_boss_palette_2_index`), and ending screen
(`ending_palette_2_index`).

Typically sprites don't have any palette color cycling support natively, but
when invincible, the player sprites will cycle the palette colors.

Like sprite data and nametable data, the palette color data is loaded from PRG
ROM into CPU memory first.  Then every frame, that data is read and loaded into
PPU memory. Every 8 frames, the `LEVEL_PALETTE_CYCLE` is incremented so that the
palettes colors are changed.

Every frame, the `load_palette_indexes` looks at the current
`LEVEL_PALETTE_CYCLE` and uses that to determine the appropriate indexes into
`game_palettes` to store into CPU memory $52 and $53 (`LEVEL_PALETTE_INDEX`).
Then `load_palette_colors_to_cpu` will look up the colors from the
`game_palettes` table and store the colors in CPU memory starting at $07c0
(`PALETTE_CPU_BUFFER`). Then in `write_palette_colors_to_ppu`, the data is read
from $07c0 to $07df and written to the PPU starting at $3f00

# _Contra_ Compression

The graphic data for _Contra_ is largely compressed with a relatively basic
compression algorithm known as
[Run-length encoding](https://en.wikipedia.org/wiki/Run-length_encoding) (RLE).

The idea of this algorithm is that the graphics data will have long "runs" of
repeated information.  So instead of specifying the same byte over and over, it
can be encoded so that the number of repetitions is specified.  In addition,
_Contra_'s algorithm specifies when a run of bytes isn't the same.  Below is
an example that can help clarify.

Below is an example of un-compressed graphics data
```
#$00 #$00 #$00 #00 #$00 #$00 #$0e #$1f #$07 #$04 #$c0
```

When compressed, it becomes

```
#$06 #$00 #$85 #$0e #$1f #$07 #$04 #$c0 #$ff
```

The special codes in this sequence are #$06, #$85, and #$ff

#$06 means the next byte #$00 is repeated 6 times.  Since the next code has bit
7 set, #$85 means to write the next 5 bytes to the PPU.  Finally, #$ff means the
sequence is complete.

Interestingly, this algorithm is implemented twice in _Contra_: once for pattern
table tiles (`write_graphic_data_to_ppu` and once again for super-tile
screen indexes (`load_supertiles_screen_indexes`).  Each implementation is
slightly different.

## graphic_data_xx Decompression
The graphic data is loaded from ROM directly to the PPU.  Not only is the
graphic data compressed, it also includes command bytes that specify where in
the PPU to write the data to.  This section outlines how the data is read and
decompressed.  This logic is all handled by the `write_graphic_data_to_ppu`
label in bank 7.

The graphic data are simply parts of the ROM that contain bytes.  The first two
bytes of any graphic data are the starting address of where to write the graphic
data to on the PPU.  For example, the first two bytes of `graphic_data_04` are
#$80, #$06.  This means that the graphics data will be written to the PPU
starting at PPU address $0680 (pattern table).

After the first two bytes are read, the following algorithm reads the graphics
data section.  When reading the graphic data, if the most significant bit of the
graphic data byte is set, i.e 1, then the byte is treated as a command byte.
There are 4 command byte types, evaluated in the following order

  * #$ff - specifies the end of graphic data
  * #$7f - command byte specifies to change PPU write address to the next 2
    bytes specified.
  * less than #$7f - or alternatively, any command byte that has its most
    significant bit clear is treated as a RLE command to write the subsequent
    byte to the PPU multiple times.  The number of times to repeatedly write the
    next byte is specified by the command byte value.
  * greater than #$7f - or alternatively, any command byte that has its most
    significant bit set is (but not #$ff) is interpreted as a command to write
    the next string of bytes to the PPU.  The number of bytes to write to the
    PPU is specified by bits 0-6 of the command byte.

Below is some pseudocode for decompressing a graphics section and writing it to
the PPU.  Note that due to the implementation, you can only flip graphics data
horizontally when that data only writes to a single PPU address location.

```
parse_ppu_address() {
  byte b = read_next_byte();
  write_to_PPUADDR(b);
  b = read_next_byte();
  write_to_PPUADDR(b);

  if(flip_horizontally) {
    read_next_byte();
    read_next_byte();
  }
}

while(true) {
  parse_ppu_address();
  byte b = read_next_byte();
  if(b == 0xff) {
    // finished decompressing graphics data
    return;
  }

  while(true) {
    if(b == 0x7f) {
      // finished reading one section of compressed graphic
      // next bytes are new PPU address
      break;
    }

    if(b < 0x7f) {
      // write same byte multiple times
      byte numberOfRepetitions = b;
      for (byte i = 0; i < numberOfRepetitions; i++) {
        if(flip_horizontally) {
          b = flip_horizontally(b);
        }

        write_to_PPUDATA(b);
      }
    } else if(b > 0x7f) {
      // write next numberOfBytesToWrite bytes directly to PPU
      byte numberOfBytesToWrite = b & 0x7f;
      for (byte i = 0; i < numberOfBytesToWrite; i++) {
        byte d = read_next_byte();
        if(flip_horizontally) {
          d = flip_horizontally(d);
        }

        write_to_PPUDATA(d);
      }
    }
  }
}
```

Level section data not encoded exactly the same way
`level_1_supertiles_screen_ptr_table`

# Quick Reference

## Graphic Locations
 * `level_graphic_data_tbl` (ROM: $1c8e3, MEM: Bank 7 $c8e3) specifies which
   pattern table data is loaded for a level, indexes into `graphic_data_ptr_tbl`
 * `graphic_data_ptr_tbl` (ROM: $1c950, MEM: $c950) specifies locations in banks
   2, 4, 5, 6, or 7 of RLE compressed graphic data (typically pattern table
   data)
 * `LEVEL_SUPERTILE_DATA_PTR` is specified in the level headers and points to
   the compressed makeup of the level's super-tiles, entries are into the
   pattern table. It is a 2-byte pointer stored in the CPU at address $44.
 * `LEVEL_SCREEN_SUPERTILES_PTR` is specified in the level headers and it
   points to a table whose entries are pointers to data specifying which
   super-tiles are loaded in each screen of the level. That data is
   RLE-compressed.  It is a 2-byte pointer stored in the CPU at address $42.

## Important Labels
 * `load_level_graphic_data` (ROM: $1c8c6, MEM: Bank 7 $c8c6) decompresses and
   loads the "Graphic data" for the current level
 * `load_current_supertiles_screen_indexes` (ROM: $1e169, MEM: Bank 7 $e169)
   decompresses and loads the super-tile indexes into memory
 * `load_level_supertile_data` (ROM: $1df48, MEM: Bank 7 $df48) decompresses
   and loads the super-tiles from the pattern table
 * `write_graphic_data_to_ppu` (ROM: $1c9a1, MEM: Bank 7 $c9a1) loads and
   decompresses the entire graphic data specified by the A register as offset
   into `graphic_data_ptr_tbl`
 * `@flush_cpu_graphics_buffer` (ROM: $1cc3f, MEM: $cc3f) writes all the data in
   the CPU graphics buffer to the PPU
 * `draw_sprites` (ROM: $6e97, MEM: Bank 1 $ae97) populates $0200-$02ff with
   sprite data for OAMDMA.
