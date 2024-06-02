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

# 4. Dragon Crash

On 2020-09-08, user [aiqiyou](https://tasvideos.org/Users/Profile/aiqiyou) had
[posted](https://tasvideos.org/Forum/Topics/485?CurrentPage=7&Highlight=499433#499433)
a .fm2 file [glitch.fm2](https://tasvideos.org/userfiles/info/65950171267733022)
on the TASVideos forums.  This showed a 2 player play through where the game
freezes on the level 3 - waterfall dragon boss.  The next day
[feos](https://tasvideos.org/Users/Profile/feos) posted a
[video of the run](https://www.youtube.com/watch?v=4ffhI2J2dA8) on YouTube for
easier viewing.  [Sand](https://tasvideos.org/Users/Profile/Sand) did some
initial investigation as to the cause of the freeze and noticed the game was in
a forever loop inside the `@enemy_orb_loop` code and it was looping forever due
to an invalid doubly linked list (`ENEMY_VAR_3` and `ENEMY_VAR_4` values).

The reason this freeze happens is due to a race condition where the left 'hand'
(red dragon arm orb) is destroyed, but before the next frame happens where the
'orb destroyed' routine is executed, another orb on the left arm changes the
routine of the left 'hand' to be a different routine.  Since the expected
'orb destroyed' routine wasn't run, the rest of the arm didn't get the notice to
self-destruct.  Then, a few frames later, the left shoulder creates a
projectile, which takes over the same slot where the left 'hand' was.  Finally,
one frame later, when the left shoulder tries to animate the arm, the left
'hand' not having correct data (because it is now a projectile), causes the game
to get stuck in an infinite loop.

## Detailed Explanation

Below is a diagram of the dragon boss and its arm orbs.  Each number below is
the enemy slot, i.e. the enemy number.  #$06 and #$05 are the left and right
'hands' respectively, and are red.  #$0d and #$0a are the left and right
'shoulders' respectively.  () represents the dragon's mouth and is uninvolved in
this bug. In fact, only the left arm is involved in this bug.

```
06 08 0c 0f 0d () 0a 0e 0b 07 05
```

1. Frame #$aa - Enemy #$06 (the left 'hand') is destroyed, the memory address
  specifying which routine to execute is updated to point to
  `dragon_arm_orb_routine_04`.
2. Frame #$ab - Enemy #$0f has a timer elapse in `dragon_arm_orb_routine_02`.
  Enemy #$0d updates the enemy routine for all orbs on the left arm.  It does
  this by incrementing a pointer.  Usually, this updates the routine from
  `dragon_arm_orb_routine_02` to `dragon_arm_orb_routine_03`.  However, since
  arm orb #$06 (the left 'hand') was no longer pointing to
  `dragon_arm_orb_routine_02`, but instead to `dragon_arm_orb_routine_04`,
  incrementing this pointer, set #$06's routine to
  `enemy_routine_init_explosion`.
3. Frames #$ac-#$d1 - The animation for the left 'hand' explosion completes and
  the 'hand' is removed from memory (`enemy_routine_remove_enemy`)
4. Frame #$d2 - The #$0d (left shoulder) decides that it should create a
  projectile.  The game logic finds an empty enemy slot where the left 'hand'
  originally was (slot #$06).  A bullet is created and initialized.  This
  initialization clears the data that linked the hand to the rest of the arm, in
  particular `ENEMY_VAR_3` and `ENEMY_VAR_4`.
5. Frame #$d3 - When #$0d (left shoulder) executes, it animates the rest of the
  orbs to make an attack pattern.  It loops down to the hand by following the
  links among the orbs.  When it gets to the hand, it expects that the hand's
  will have its `ENEMY_VAR_3` set to `#$ff` indicating there aren't any more
  orbs to process.  However, since the enemy at slot #$06 is no longer a hand,
  but instead a projectile, the value at `ENEMY_VAR_3` has been cleared and is
  #$00.  This causes the logic to get stuck in `@arm_orb_loop` as an infinite
  loop.

Step (2) caused `dragon_arm_orb_routine_04` to be skipped.  Since this routine
was not executed as expected, the rest of the arm didn't get updated to know
that the 'hand' was destroyed.  `dragon_arm_orb_routine_04` is responsible for
updating each orb on the arm to be begin its self destruct routine.  However,
that never happens.  So, the shoulder doesn't know to destroy itself.  Instead
the shoulder operates as if it wasn't destroyed and when it decides that a
projectile should be created, that overwrites the hand with a different enemy
type, and clears all the links between the hand and the arm.