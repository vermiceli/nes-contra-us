# Overview

_Contra_ loads various level-specific configuration data from in bank 2. These
are called "level headers".  These headers are #$20 (32) bytes for each level
and contain information about the level, for example whether the level is and
indoor level, or an outdoor level, vertical level or horizontal level, etc.

In the code, the level headers are labeled `level_headers` and each level is
labeled with an appropriate `level_x_header` label.

# Byte Offset 0 - Location Type

  * Offset: 0
  * Memory Location: $40
  * Variable Name: `LEVEL_LOCATION_TYPE`

The first byte is the level's "location type".  There are 3 location types

  * Outdoor - #$00
  * Indoor/Base - #$01
  * Indoor Boss - #$80

Outdoor levels are typical platformer side-scrolling levels and scrolls
horizontally or vertically.  Indoor levels are also known as base levels and are
the levels where Bill and Lance are facing away from the player in a pseudo 3D
experience (Levels 2 and 4).

Although the value is never #$80 in the level headers table, for the boss fights
on the indoor levels (2 and 4), the location type will be set to $80. It is
similar to the indoor location type (#$01), except the player cannot go prone
and shooting up looks like shooting forward (z-plane).  When animating the
players walking into the screen between 3D screens, the value is also set to
#$80.

# Byte Offset 1 - Outdoor Scrolling Type

  * Offset: 1
  * Memory Location: $41
  * Variable Name: `LEVEL_SCROLLING_TYPE`

The second byte is the level's scrolling type. It is only used in outdoor
levels.

  * Horizontal - #$00
  * Vertical - #$01

# Byte Offsets 2 and 3 - Screen Super-Tile Pointer

  * Offset: 2 and 3
  * Memory Location: 2-byte address $42 and $43
  * Variable Name: `LEVEL_SCREEN_SUPERTILES_PTR`

The 3rd and 4th bytes make up the pointer that point to the data that specifies
which super-tiles are on each screen.  This is an address into Bank 2.  The
address is 2 bytes and stored in little-endian, i.e. the least significant byte
first.

For example, on level 3, the screen super tile pointer points to
`level_3_supertiles_screen_ptr_table` (ROM: $84ce, MEM: Bank 2 $84ce).  This
address contains a list of pointers for each "screen" of the level.  A screen is
a set of super-tiles for a level that is 256 pixels wide.  Since level 3 is a
vertical level, each screen is 64 super-tiles (8x8).  Looking at the data
specified at the address of a specific screen pointer, e.g.
`level_3_supertiles_screen_01` (ROM: $8635, MEM: Bank 2 $8635), you will find an
RLE-encoded set of bytes that specify the super-tile indexes used. After
decompressing, each byte is the offset into the
`level_3_supertile_data` (ROM: $cef8, MEM: Bank 3 $8ef8).

# Byte Offsets 4 and 5 - Super-Tile Data

  * Offset: 4 and 5
  * Memory Location: 2-byte address $44 and $45
  * Variable Name: `LEVEL_SUPERTILE_DATA_PTR`

The 5th and 6th bytes of the level headers are a pointer to the level's
super-tiles.  Each entry in table at the specified address is #$10 bytes long
and is a single super-tile.  This data is not RLE-encoded.  Each byte in each
super-tile represent a pattern table tile.  An example pointer is
`level_3_supertile_data` (ROM: $cef8, MEM: Bank 3 $8ef8)

# Byte Offsets 6 and 7 - Super-Tile Palette Data

  * Offset: 6 and 7
  * Memory Location: 2-byte address $46 and $47
  * Variable Name: `LEVEL_SUPERTILE_PALETTE_DATA`

Address to byte table that specifies the palette used for each super-tile in the
level.  Each byte describes the 4 palettes for a single super-tile.  An example
is `level_2_palette_data`

# Byte Offset 8 - Alternate Graphics Loading Location

  * Offset: 8
  * Location: $48
  * Variable Name: `LEVEL_ALT_GRAPHICS_POS`

This byte specifies the alternate graphics loading location.  This is the screen
where the game has the ability to change out the pattern table tiles for a
level.

# Byte Offsets 9, 10, and 11 - Tile Collision Limits

  * Offset: 9, 10, and 11
  * Location: $49, $4a, $4b
  * Variable Name: `COLLISION_CODE_1_TILE_INDEX`, `COLLISION_CODE_0_TILE_INDEX`,
    and `COLLISION_CODE_2_TILE_INDEX` (in that order)

These three bytes are used to specify which pattern table tiles are which
collision codes.

* Pattern table tiles below the value in $49 (excluding #$00) are considered
Collision Code 1 (floor).
* Pattern table tiles >= the value in $49, but less than the value in $4a are
considered Collision Code 0 (empty)
* Pattern table tiles >= $4a but less than this tile index are considered
Collision Code 2 (water)

Pattern table tiles above the last entry, are considered Collision Code 3
(Solid).

# Byte Offset 12, 13, 14, and 15 - Cycling Palette Colors

  * Offset: 12, 13, 14, and 15
  * Location: $4c, $4d, $4e, and $4f
  * Variable Name: `LEVEL_PALETTE_CYCLE_INDEXES`

Each level natively supports having its 4th nametable (background) palette cycle
through up to 4 different sets of colors, where each set of colors is
represented by an index into the `game_palettes` table.  This header section
contains those specific indexes to cycle through.

For more details see `Graphics Documentation.md`. There is a section titled
`Palette -> Cycling`.

# Byte Offset 16, 17, 18, and 19 - Nametable Palette Initial Colors

  * Offset: 16, 17, 18, and 19
  * Location: $50, $51, $52, and $53
  * Variable Name: `LEVEL_PALETTE_INDEX`

Initial background tile palette colors for the level. Indexes into
`game_palettes`.

# Byte Offset 20, 21, 22, and 23 - Nametable Palette Initial Colors

  * Offset: 20, 21, 22, and 23
  * Location: $54, $55, $56, and $57
  * Variable Name: `LEVEL_PALETTE_INDEX`

Initial sprite tile palette colors for the level. Indexes into `game_palettes`.

# Byte Offset 24 - Scroll Stop Screen

  * Offset: 24
  * Location: $58
  * Variable Name: `LEVEL_STOP_SCROLL`

The screen of the level to stop scrolling. The value in memory is set to #$ff
when boss auto scroll starts

# Byte Offset 25 - Solid Background Collision

  * Offset: 25
  * Location: $59
  * Variable Name: `LEVEL_SOLID_BG_COLLISION_CHECK`

Specifies whether to check for bullet and weapon item solid bg collisions.

  1. When non-zero, specifies that the weapon item should check for solid bg
     collisions (see `weapon_item_check_bg_collision`)
  2. When negative (bit 8 set), specifies to let bullets for both players and
     enemies to check for bullet-solid background collisions.  This is used on
     levels 6 - energy zone and 7 - hangar. (see
     `check_bullet_solid_bg_collision` and `enemy_bullet_routine_01`)

# Byte Offset 26 through 32 - Unused

The last 6 bytes in each level's level header are unused and set to #$00.