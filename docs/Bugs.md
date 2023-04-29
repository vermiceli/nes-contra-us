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

# 3. Level 4 Boss Gemini Vulnerability

Under normal circumstances, when the level 4 indoor/base boss gemini helmet
(enemy type = #$1c) splits into 'phantoms', then they don't take damage.  Only
when the helmet re-combines is it vulnerable to damage.  However, `Mr. K`
[researched](http://www.youtube.com/watch?v=hL1BMFRt6aA) a glitch to find that
if a player's bullet collides with the helmet at just the right frame, then when
the helmet separates into two, it can still take damage.

The reason this happens is because the boss gemini uses `ENEMY_ANIMATION_DELAY`
to know when to be vulnerable or when to be invulnerable.
`ENEMY_ANIMATION_DELAY` specifies how long for the helmet to stay still when
merged, or when at the farthest distance apart. The timer is set to #$20 when
farthest apart, and #$30 when merged.  If the helmets are moving (either toward
each other or away), the value will be #$00.

When merged and `ENEMY_ANIMATION_DELAY` is 2, the helmet is not moving, but
about to start separating.  The value will be decremented to 1.  This logic
happens in `boss_gemini_routine_02`.  After `boss_gemini_routine_02` runs,
`bullet_enemy_collision_test` is executed to check for a bullet to enemy
collision.  If during this frame, a bullet hits the gemini, then the
`ENEMY_ROUTINE` is updated to `boss_gemini_routine_03`. This is known as the
enemy destroyed routine and it will be executed in the next frame.  However,
boss gemini is special, in that it isn't automatically destroyed in the
destroyed routine. Instead, unless boss gemini doesn't have any more health
(`ENEMY_VAR_4`), the routine will decrement `ENEMY_ANIMATION_DELAY` to 0 and
set back to `boss_gemini_routine_02` to be called the next frame.

Now when the next frame executes and the `boss_gemini_routine_02` routine is
run, `ENEMY_ANIMATION_DELAY` is 0 and game thinks that the code that makes the
helmet invulnerable has already been executed when it hasn't!

In short, the bug happens because for the special time when
`ENEMY_ANIMATION_DELAY` is decremented from 1 to 0, the code should make the
helmet invincible by calling `disable_enemy_collision`.  However, if you time
the bullet collision to happen on the frame when `ENEMY_ANIMATION_DELAY` is 2,
then the regular game code will decrement the timer to 1, and then next frame
will have a different routine (`boss_gemini_routine_03`) set the timer to
0, but that routine doesn't call `disable_enemy_collision`, leaving the helmet
in a vulnerable state.

Interestingly, if you take advantage of this bug, then you can exploit the same
logic mistake when the helmet is not moving at the edge of the screen, before it
starts merging.  If a bullet collides with the helmet right when
`ENEMY_ANIMATION_DELAY` is 2, then the helmets will remain vulnerable while
merging.

```
; ----- Frame 1 -----
boss_gemini_routine_02:
    ...
    lda ENEMY_ANIMATION_DELAY,x ; ENEMY_ANIMATION_DELAY = 2
    beq @calc_offset_set_pos    ; branch doesn't occur
    dec ENEMY_ANIMATION_DELAY,x ; ENEMY_ANIMATION_DELAY = 1
    bne @set_x_pos              ; helmet still not moving, branch
    ...
    rts

...

bullet_enemy_collision_test:
    ...
    jsr bullet_collision_logic ; set boss gemini routine `boss_gemini_routine_03`

; ----- Frame 2 -----
boss_gemini_routine_03:
    lda ENEMY_ANIMATION_DELAY,x ; ENEMY_ANIMATION_DELAY = 1
    beq @continue               ; branch doesn't occur
    dec ENEMY_ANIMATION_DELAY,x ; ENEMY_ANIMATION_DELAY = 0
    ...
    lda #$03                   ; a = #$03
    jmp set_enemy_routine_to_a ; set enemy routine index to boss_gemini_routine_02

; ----- Frame 3 -----
boss_gemini_routine_02:
    lda ENEMY_ANIMATION_DELAY,x ; ENEMY_ANIMATION_DELAY = 0
    beq @calc_offset_set_pos    ; branch skipping disabling of collision!!
    dec ENEMY_ANIMATION_DELAY,x ; skipped!
    bne @set_x_pos              ; skipped!
    jsr disable_enemy_collision ; skipped!

@calc_offset_set_pos:
    ...
```