# Overview
This file outlines the differences between _Contra_ (US) and _Probotector_.
_Probotector_ is the PAL-specific variation of the _Contra_ (US) game.  Note
that all of the documentation that refers to code or look up table memory
addresses were documented using _Contra_ (US) and may not be identical to the
addresses in _Probotector_.  All of the addresses that are used for game logic
are the same. This includes pretty much any address defined in `constants.asm`.

# Differences

There are about 168 differences (#$a8 differences) between _Contra_ (US) and
_Probotector_.  Most of these differences are sprites.

## Logic

* When destroying all enemies (cleared screen, defeated boss, or picked up
falcon weapon item), there is an additional check to not update the enemy to the
"enemy destroyed" routine if its HP is 0.  This check isn't done in _Contra_
(US).  This has no known effective difference in game play.
* There is a useless execution of a function that does nothing but exit in the
  `check_for_pause` label.

## Audio

The helicopter sound is not played during the ending animation in _Probotector_.
This is because the helicopter was replaced with a Jet.

## Background

* The introduction screen is completely different in _Probotector_. There is no
  scrolling introduction, and Bill and Lance have been replaced with a large
  PROBOTECTOR graphic.
* The `level_8_supertile_data` is different between _Probotector_ and _Contra_
(US).  3 super-tiles on the wall in front of the Alien Guardian (enemy type
#$10) in Alien's Lair contain more well-formed shells in _Probotector_.  The
shells in _Probotector_ are actually retained from the super-tiles from the
Japanese version.

## Palettes

A few palettes are different, causing the sprites to have been updated to use
a different palette index to maintain the same color as the _Contra_.  Some of
the sprites are different colors due to the sprite changes

* Giant boss soldier's (enemy type #$13) spiked projectiles (enemy type #$14)
  were changed from blue to gray.
* Enemy bullet color is red rather than white.
* Dragon orbs (enemy type #$15) are red and blue rather than grey and red.
* Ice grenades (enemy type #$11) are gray instead of blue.
* Mining carts (enemy type #$14 and #$15) have black wheels instead of blue.
* Flying capsules (enemy type #$03) on Alien's Lair are pink.

Player invincibility sprite palette pattern for player 2 alternates between red
and gray instead of red and blue like in _Contra_ (US).  In _Contra_ (US) both
player 1 and player 2 flash between red and blue when have the B weapon.

## Text

* In the SPECIAL THANKS section of the credits, the to "AC CONTRA TEAM" has been
replaced with "AC TEAM".
* The location of various text on the game over screen and continue screen have
  been slightly moved
  * GAME OVER
  * CONTINUE
  * END
  * 1 PLAYER
  * 2 PLAYERS
* Similarly, the introduction screen cursor locations have been updated to match
  the new location of CONTINUE/END.

## Sprites

Many of the sprites were changed to replace humans with robots.
Additionally, some sprite animations were simplified, making many sprites
identical, when they weren't in _Contra_ (US)

* `sprite_27`, `sprite_28`, `sprite_3c` are equal
* `sprite_29` and `sprite_42` are equal
* `sprite_3b` and `sprite_3f` are equal
* `sprite_3d`and `sprite_3e` are equal
* `sprite_93` and `sprite_94` are equal
* `sprite_b7` and `sprite_b8` are equal
* `sprite_bd` and `sprite_be` are equal
* `sprite_cc`, `sprite_cd`, `sprite_ce` are unused in _Probotector_.  However,
they do exist and point to `sprite_cf` (ending animation islands).

To accommodate the player sprite changes, the initial location relative to the
center of the player where bullets are generated have been adjusted (see
`bullet_initial_pos_00`).

## Graphics

Below is the list of compressed graphics that are different.  I haven't
confirmed, but these differences are most likely just sprite pattern table tile
differences (left pattern table).

* `alt_graphic_data_03`
* `graphic_data_01`
* `graphic_data_02`
* `graphic_data_03`
* `graphic_data_04`
* `graphic_data_05`
* `graphic_data_06`
* `graphic_data_07`
* `graphic_data_08`
* `graphic_data_09`
* `graphic_data_0b`
* `graphic_data_0c`
* `graphic_data_0d`
* `graphic_data_0e`
* `graphic_data_13`
* `graphic_data_15`
* `graphic_data_17`
* `graphic_data_18`
* `graphic_data_19`
* `graphic_data_1a`