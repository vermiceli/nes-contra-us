# Overview

This document outlines the bugs discovered in the code during the disassembly
process.

# 1. Missing Animation Entering Water

When animating the player falling into water, a comparison was missed which
causes `sprite_18` to not be used for the animation sequence.  This bug also
exists in the Japanese version as well as _Probotector_.  It's clear from the
code that there was an attempt to show `sprite_18` (frame 3 in the table below)
as part of the animation sequence.  `sprite_18` is the same sprite as when the
player is in water and presses the d-pad down button.

| Frame 1                             | Frame 2                             | Frame 3 (missing)                   | Frame 4                             |
|-------------------------------------|-------------------------------------|-------------------------------------|-------------------------------------|
| ![0](attachments/pw_0.png?raw=true) | ![1](attachments/pw_1.png?raw=true) | ![2](attachments/pw_2.png?raw=true) | ![3](attachments/pw_3.png?raw=true) |


```
@set_enter_water_sprite:
  ...
  lda PLAYER_WATER_TIMER,x ; load water animation timer
  beq ...                  ; if timer has elapsed, branch
  cmp #$0c                 ; see if timer is greater than or equal to #$0c
  bcs ...                  ; branch if timer >= #$0c (keep current sprite)
  lda #$73                 ; PLAYER_WATER_TIMER less than #$0c, update sprite
  sta PLAYER_SPRITE_CODE,x ; set player sprite (sprite_73) water splash
  cmp #$08                 ; !(BUG?) always branch, doesn't compare to PLAYER_WATER_TIMER
                           ; but instead compares against #$73
                           ; no lda PLAYER_WATER_TIMER,x before this line, so part of splash animation is missing
  bcs ...                  ; branch using sprite_73
  lda #$18                 ; dead code - a = #$18 (sprite_18) water splash/puddle
  sta PLAYER_SPRITE_CODE,x ; dead code - set player animation frame to water splash/puddle
```

# 2. Accidental Sound Sample In Snow Field

After defeating the boss UFO (Guldaf), before calling the method
`level_boss_defeated`, the developers forgot to load into the accumulator the
appropriate sound code, usually #$57 for `sound_57`.  So bytes in bank 7 are
interpreted as an audio sample incorrectly and a short DMC channel audio clip is
played.

`level_boss_defeated` uses whatever is in the accumulator as the sound code to
play. Since the accumulator wasn't set, it has the previous value of #$ff (see
`boss_ufo_routine_0b`).  This is interpreted by the audio engine as a DMC sound
code that doesn't exist.

The audio engine will incorrectly read bytes from `sound_table_00` as the dmc
data below.

  * sampling rate #$03 (5593.04 Hz), no loop
  * counter length #$77
  * offset #$97 --> $c000 + (#$97 * #$40) --> $e5c0
  * sample length #$19

The data that is interpreted as a DPCM-encoded DMC sample is $e5c0, which is
in bank 7's `collision_box_codes_03` data.  This bug does not exist in the
Japanese version of the game because the `level_boss_defeated` is not
responsible for playing the boss defeated sound.  This bug does exist in
_Probotector_.

Extracted sound sample: [sound_ff.mp3](attachments/sound_ff.mp3?raw=true)

Note that the boss defeated audio (`sound_55`) is still played because the enemy
defeated routine is set to `boss_ufo_routine_09` (see
`enemy_destroyed_routine_05`).  `boss_ufo_routine_09` plays `sound_55`.