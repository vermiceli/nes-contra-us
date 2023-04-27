# Overview

Enemy logic is controlled by enemy routines, every enemy has a set of routines
that it can execute.  The list of routines per enemy is specified in the
`*_routine_ptr_tbl` tables all in bank 7.  Which enemies are in which screen of
a level are specified in the `enemy_routine_ptr_tbl` (for shared enemies) or one
of the 7 `enemy_routine_level_x` tables.  Level 2 and level 4 share the same
enemy routine `enemy_routine_level_2_4` table.

Upon execution of `level_routine_04` and `level_routine_0a`, every enemy is
given the opportunity to execute logic specific to that enemy type.  This is
done by looping down #$f to #$0 through the `ENEMY_ROUTINE` memory addresses in
the `exe_all_enemy_routine` method. Enemies are added to the end going down,
i.e. they start at #$f and go down.

# Generation

Enemies can be generated in the level in one of two ways: random generation, and
level-specific hard-coded locations.

# Level Enemies
Each level defines hard-coded locations on each screen where an enemy will be
generated. These enemies are always at that location in the level. This is
defined in the `level_enemy_screen_ptr_ptr_tbl` in bank 2.  There are #$08
2-byte entries in this table, one for each level, e.g.
`level_1_enemy_screen_ptr_tbl`.  Each 2-byte entry is a memory address to
another table of addresses, e.g. `level_1_enemy_screen_02`.  Each entry here
defines the enemies within a single screen of a level.  Screen 0 does never has
enemies, so the first entry in this table is associated to the second screen of
the level. There is always one more entry for a level than there are screens.

## Data Structure

### Outdoor levels
For a given screen, each enemy is defined with at least #$03 bytes.  For
example, the first enemy defined on `level_1_enemy_screen_00` is
`.byte $10,$05,$60`.  These three bytes define a soldier who runs left, but
doesn't shoot.  These bytes need to be broken up into bits to further understand
their meaning.

```
0001 0000  0000 0101  0110 0000
XXXX XXXX  RRTT TTTT  YYYY YAAA
```

* `X` - X offset
* `R` - Repeat
* `T` - Enemy Type
* `Y` - Y Offset
* `A` - Enemy Attribute

### Byte 1 - XX byte
The first byte, #$10, from the example above specifies the x position of the
enemy.

### Byte 2 - Repeat and Enemy Type
The second byte, #$05, from the example above defines two things: repeat, and
enemy type.  The most significant 2 bits define the number of times to repeat
an enemy, the least significant 6 bits define the enemy type.  To see a list of
all enemy types and what they are, see `Enemy Glossary.md`. For example, #$05
has a repeat of 0 and a enemy type of #$05. #$05 is the soldier.

If the repeat value is 0, then the enemy is not repeated and will take a total
of #$3 bytes. However, if there is a repeat, for each repetition, one more byte
is added and has the same structure as the `Y Offset and Attribute` byte. This
means an enemy with a repeated enemy will have the same XX position and the same
type, but have its own Y position and attributes.

Here is an example of a screen enemy definition with a repeat

```
level_1_enemy_screen_09:
    .byte $10,$43,$40,$b4 ; flying capsule (enemy type #$03), attribute: 000 (R), location: (#$10, #$40)
                          ; repeat: 1 [(y = #$b0, attr = 100)]
    .byte $e0,$07,$81     ; red turret (enemy type #$07), attribute: 001, location: (#$e0, #$80)
    .byte $ff
```

### Byte 3 - Y Offset and Attribute
The third byte, #$60, from the example above defines the vertical position of
the enemy as well as that enemy's attributes.  The #$05 most significant bits
specify the vertical offset and the least significant 3 bits are for the
attributes.  Each enemy can use the 3 attribute bits however they see fit. For
example, a soldier uses the attributes to know which way to start running, and
whether or not the soldier fires bullets from their gun.  For a detailed list of
each enemy type and their attributes, see `Enemy Glossary.md`.

### Indoor/Base Levels

```
XXXX YYYY CDTT TTTT AAAA AAAA
```

* `X` - X offset
* `Y` - Y Offset
* `C` - Whether or not to add #$08 to Y position
* `D` - Whether or not to add #$08 to X position
* `T` - Enemy Type
* `A` - Enemy Attribute

# Enemy Destroyed

When an enemy is determined to be destroyed, e.g. their `ENEMY_HP` has gone to 0
after collision with a bullet, then the enemy routine for the active enemy is
immediately adjusted to a routine index specified by
`enemy_destroyed_routine_xx`.  These are grouped in the
`enemy_destroyed_routine_ptr_tbl`.

For example, when a soldier is destroyed, `enemy_destroyed_routine_01` specifies
byte #$05 for the soldier.  This corresponds to `soldier_routine_04`

# Soldier Generation

In addition to the hard-coded screen-specific enemies that appear in the same
location every play through (specified in the `level_x_enemy_screen_xx` data
structures).  _Contra_ generates soldiers at regular intervals with slightly
random enemy logic so that each play through has a different experience.

When playing a level, the game state is in `game_routine_05`, and specifically
in `level_routine_04`.  `level_routine_04` is run every frame. One part of
`level_routine_04` is to run the logic to determine if an enemy soldier (enemy
type #$05) should be created.  This logic is in bank 2's
`exe_soldier_generation` method.

`exe_soldier_generation` runs one of three soldier generation routines depending
on the current value of `SOLDIER_GENERATION_ROUTINE`.  Initially, this value is
#$00 and `soldier_generation_00` is executed.

## soldier_generation_00
`soldier_generation_00` initializes a level-specific timer that controls the
speed of soldier generation.  This timer is subsequently adjusted based on the
number of times the game has been completed, and the player's current weapon
strength.  Every time the game has been completed (max of 3 times), #$28 is
subtracted from the initial level-specific soldier generation timer.
Additionally, the player weapon strength multiplied by #$05 is subtracted from
the soldier generation timer.

For example, level 3 (waterfall) has an initial level-specific timer value of
#$d8 (specified in the `level_soldier_generation_timer` table).  If the player
has beaten the game once and has a `PLAYER_WEAPON_STRENGTH` of #$03 (S weapon),
then the computed soldier generation timer would be #$a1.

```
#$a1 = #$d8 - (#$01 * #$28) - (#$05 * #$03)
```

Soldier generation is disabled on the indoor/base levels (level 2 and level 4)
along with level 8 (alien's lair).  They are disabled by a value of #$00 being
specified in the `level_soldier_generation_timer` table.  For these levels, no
other soldier generation routine will be run, only `soldier_generation_00`.

Once the soldier generation timer has been initialized and adjusted, the
`SOLDIER_GENERATION_ROUTINE` is incremented so that the next game loop's
`exe_soldier_generation` causes `soldier_generation_01` to execute.

## soldier_generation_01

`soldier_generation_01` is responsible for decrementing the soldier generation
timer until it elapses. Then it is responsible for creating the soldier, if
certain conditions are met. This includes randomizing the soldier's location and
enemy attributes.

`soldier_generation_01` will first look at the current soldier generation timer,
if the timer is not yet less than #$00, then the timer is decremented by #$02,
unless the frame is scrolling on an odd frame number. Then the timer is only
decremented by #$01.

Once the soldier generation timer has elapsed, the routine looks for an
appropriate location to generate the soldier on the screen.  Soldiers are
always generated from the left or right edge of the screen.  First the starting
horizontal position is determined. This is essentially determined randomly by
the current frame number and values in the `gen_soldier_initial_x_pos` table.
The result will be either the left edge (#$0a) or the right edge (#$fa or #$fc).

There is an exception for level one.  Until a larger number of soldiers have
already been generated, soldiers will only appear from the right, probably to
make the beginning of the game slightly easier.

Once the x position is decided, the routine will start looking for a vertical
location that has a ground for the soldier to stand on.  It does this in one of
3 ways randomly to ensure soldiers are generated from multiple locations if
possible.  The 3 methods are from top of the screen to the bottom, from the
bottom of the screen to the top, and from the player vertical position up to the
top.

If a horizontal and vertical position is found where a soldier can be placed on
the ground, then some memory is updated to specify the location and the soldier
generation routine is incremented to `soldier_generation_02`.

## soldier_generation_02

At this point, a location is found for the soldier to generate.
`soldier_generation_02` is responsible for actually initializing and creating
the soldier.  Some checks are performed to make sure it's appropriate to
generate a soldier, for example, when `ENEMY_ATTACK_FLAG` is set to #$00 (off),
then a soldier will not be generated. Other checks include that there are no
solid blocks (collision code #$80) right in front of the soldier to generate,
and that there is no player right next to the edge of the screen where the
soldier would be generated from (this check doesn't happen after beating the
game at least once).  If any checks determine that the soldier should not be
generated, then the routine resets the `SOLDIER_GENERATION_ROUTINE` back to #$00
and stops.

To randomize the various behaviors of the generated soldiers, this routine will
look up initial behavior from one of the `soldier_level_attributes_xx` tables
based on the level. This will randomize the soldier direction, whether or not
the soldier will shoot and how frequently, and a value specifying the
probability of ultimately not generating the soldier.  Finally, the soldier is
generated and the values are moved into the standard enemy memory location
addresses, creating the soldier.