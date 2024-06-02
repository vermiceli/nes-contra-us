; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 0 is used exclusively for enemy routines. Enemy routines are the logic
; controlling enemy behaviors, AI, movements, and attack patterns. Almost every
; enemy is coded in bank 0, but some enemies, usually those who appear in more
; than one level, are coded in bank 7.

.segment "BANK_0"

.include "constants.asm"

; import labels from bank 7
.import play_sound, init_APU_channels, load_bank_3_update_nametable_supertile
.import load_bank_3_update_nametable_tiles, load_palettes_color_to_cpu
.import get_bg_collision_far, get_cart_bg_collision, wall_core_routine_05
.import boss_defeated_routine, enemy_routine_init_explosion
.import mortar_shot_routine_03, set_enemy_delay_adv_routine
.import advance_enemy_routine, roller_routine_04, shared_enemy_routine_03
.import enemy_routine_explosion, enemy_routine_remove_enemy
.import shared_enemy_routine_clear_sprite, set_enemy_routine_to_a
.import update_enemy_pos, update_enemy_x_pos_rem_off_screen
.import set_enemy_y_vel_rem_off_screen, set_outdoor_weapon_item_vel
.import add_scroll_to_enemy_pos, set_enemy_velocity_to_0
.import set_enemy_y_velocity_to_0, set_enemy_x_velocity_to_0
.import reverse_enemy_x_direction, set_destroyed_enemy_routine
.import destroy_all_enemies, clear_supertile_bg_collision
.import set_supertile_bg_collision, set_supertile_bg_collisions
.import create_explosion_89, create_two_explosion_89, create_enemy_for_explosion
.import level_boss_defeated, set_delay_remove_enemy
.import disable_bullet_enemy_collision, disable_enemy_collision
.import enable_enemy_player_collision_check, enable_bullet_enemy_collision
.import enable_enemy_collision, add_a_to_enemy_y_pos, add_a_to_enemy_x_pos
.import set_08_09_to_enemy_pos, add_with_enemy_pos, add_10_to_enemy_y_fract_vel
.import add_a_to_enemy_y_fract_vel, generate_enemy_a, generate_enemy_at_pos
.import add_4_to_enemy_y_pos, add_a_with_vert_scroll_to_enemy_y_pos
.import update_nametable_tiles_set_delay, draw_enemy_supertile_a_set_delay
.import draw_enemy_supertile_a, update_2_enemy_supertiles
.import update_enemy_nametable_tiles_no_palette, update_enemy_nametable_tiles
.import check_enemy_collision_solid_bg, init_vars_get_enemy_bg_collision
.import add_y_to_y_pos_get_bg_collision, add_a_y_to_enemy_pos_get_bg_collision
.import set_flying_capsule_y_vel, set_flying_capsule_x_vel
.import red_turret_find_target_player, player_enemy_x_dist
.import find_far_segment_for_x_pos, find_far_segment_for_a
.import set_enemy_falling_arc_pos, set_weapon_item_indoor_velocity
.import find_next_enemy_slot, clear_sprite_clear_enemy_pt_3
.import clear_enemy_custom_vars, initialize_enemy, aim_and_create_enemy_bullet
.import bullet_generation, create_enemy_bullet_angle_a, set_bullet_velocities
.import aim_var_1_for_quadrant_aim_dir_01, aim_var_1_for_quadrant_aim_dir_00
.import get_rotate_00, get_rotate_01
.import get_rotate_dir, dragon_arm_orb_seek_should_move
.import get_quadrant_aim_dir_for_player, remove_enemy

; export labels for bank 7
; level 1 enemies
.export bomb_turret_routine_ptr_tbl
.export boss_wall_plated_door_routine_ptr_tbl
.export exploding_bridge_routine_ptr_tbl

; level 2 and 4 enemies
.export boss_eye_routine_ptr_tbl
.export roller_routine_ptr_tbl
.export grenade_routine_ptr_tbl
.export wall_turret_routine_ptr_tbl
.export wall_core_routine_ptr_tbl
.export indoor_soldier_routine_ptr_tbl
.export jumping_soldier_routine_ptr_tbl
.export grenade_launcher_routine_ptr_tbl
.export four_soldiers_routine_ptr_tbl
.export indoor_soldier_gen_routine_ptr_tbl
.export indoor_roller_gen_routine_ptr_tbl
.export eye_projectile_routine_ptr_tbl
.export boss_gemini_routine_ptr_tbl
.export spinning_bubbles_routine_ptr_tbl
.export blue_soldier_routine_ptr_tbl
.export red_soldier_routine_ptr_tbl
.export red_blue_soldier_gen_routine_ptr_tbl

; level 3 enemies
.export floating_rock_routine_ptr_tbl
.export moving_flame_routine_ptr_tbl
.export rock_cave_routine_ptr_tbl
.export falling_rock_routine_ptr_tbl
.export boss_mouth_routine_ptr_tbl
.export dragon_arm_orb_routine_ptr_tbl

; level 5 enemies
.export ice_grenade_generator_routine_ptr_tbl
.export ice_grenade_routine_ptr_tbl
.export tank_routine_ptr_tbl
.export ice_separator_routine_ptr_tbl
.export boss_ufo_routine_ptr_tbl
.export mini_ufo_routine_ptr_tbl
.export boss_ufo_bomb_routine_ptr_tbl

; level 6 enemies
.export fire_beam_down_routine_ptr_tbl
.export fire_beam_left_routine_ptr_tbl
.export fire_beam_right_routine_ptr_tbl
.export boss_giant_soldier_routine_ptr_tbl
.export boss_giant_projectile_routine_ptr_tbl

; level 7 enemies
.export claw_routine_ptr_tbl
.export rising_spiked_wall_routine_ptr_tbl
.export spiked_wall_routine_ptr_tbl
.export mine_cart_generator_routine_ptr_tbl
.export moving_cart_routine_ptr_tbl
.export immobile_cart_generator_routine_ptr_tbl
.export boss_door_routine_ptr_tbl
.export boss_mortar_routine_ptr_tbl
.export boss_soldier_generator_routine_ptr_tbl

; level 8 enemies
.export alien_guardian_routine_ptr_tbl
.export alien_fetus_routine_ptr_tbl
.export alien_mouth_routine_ptr_tbl
.export white_blob_routine_ptr_tbl
.export alien_spider_routine_ptr_tbl
.export alien_spider_spawn_routine_ptr_tbl
.export boss_heart_routine_ptr_tbl

; enemies that exist on multiple levels
.export enemy_bullet_routine_ptr_tbl
.export rotating_gun_routine_ptr_tbl
.export red_turret_routine_ptr_tbl
.export sniper_routine_ptr_tbl
.export soldier_routine_ptr_tbl
.export weapon_box_routine_ptr_tbl
.export weapon_item_routine_ptr_tbl
.export flying_capsule_routine_ptr_tbl

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $00 ; The PRG ROM bank number (0)

; table of pointers for weapon item routines ($03 * $02 = $06 bytes)
weapon_item_routine_ptr_tbl:
    .addr weapon_item_routine_00 ; CPU address $8007
    .addr weapon_item_routine_01 ; CPU address $8068
    .addr weapon_item_routine_02 ; CPU address $8100

; weapon item - pointer 1
; sets collision code, velocity
; weapon items are created after flying capsule, pill box sensors, or red soldiers (in indoor/base levels) are destroyed
weapon_item_routine_00:
    lda #$80                            ; a = #$80
    sta ENEMY_STATE_WIDTH,x             ; mark weapon item so bullets travel through it
    lda #$22                            ; a = #$22
    sta ENEMY_SCORE_COLLISION,x         ; score code #$02, collision type #$02
.ifdef Probotector
    lda #$00                            ; use sprite code palette
.else
    lda #$05                            ; set sprite palette #$01, bit 2 specifies sprite code ROM data override
.endif
    sta ENEMY_SPRITE_ATTR,x             ; set weapon item sprite palette to palette
    lda LEVEL_LOCATION_TYPE             ; 0 = outdoor; 1 = indoor
    beq @set_velocity_outdoor           ; branch for outdoor level
    lda ENEMY_Y_POS,x                   ; indoor level, load y position on screen
    sta ENEMY_VAR_1,x                   ; set ENEMY_VAR_1 to initial Y position
    jsr set_weapon_item_indoor_velocity ; sets X and Y velocities for indoor level based on X position
    lda #$80
    sta ENEMY_VAR_4,x
    lda #$fd
    sta ENEMY_VAR_B,x
    jmp advance_enemy_routine           ; advance enemy x to next routine

@set_velocity_outdoor:
    ldy #$00                 ; set weapon_item_init_vel_tbl to first set of entries
    lda LEVEL_SCROLLING_TYPE ; 0 = horizontal, indoor/base; 1 = vertical
    beq @continue            ; branch for horizontal scrolling
    ldy #$04                 ; vertical scrolling, set weapon_item_init_vel_tbl to second set of entries
    lda ENEMY_X_POS,x        ; load weapon item position on screen
    cmp #$80
    bcc @continue            ; branch if ENEMY_X_POS < #$80
    ldy #$08                 ; weapon item close to right edge, set weapon_item_init_vel_tbl to 3rd set of entries

@continue:
    lda weapon_item_init_vel_tbl,y   ; load weapon item initial fractional y velocity
    sta ENEMY_Y_VELOCITY_FRACT,x     ; set weapon item initial fractional y velocity
    lda weapon_item_init_vel_tbl+1,y ; load weapon item initial fast y velocity
    sta ENEMY_Y_VELOCITY_FAST,x      ; set weapon item initial fast y velocity
    lda weapon_item_init_vel_tbl+2,y ; load weapon item initial fractional x velocity
    sta ENEMY_X_VELOCITY_FRACT,x     ; set weapon item initial fractional x velocity
    lda weapon_item_init_vel_tbl+3,y ; load weapon item initial fast x velocity
    sta ENEMY_X_VELOCITY_FAST,x      ; set weapon item initial fast x velocity

weapon_item_advance_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; table for outdoor weapon item velocities (#$4 * #$4 = #$c bytes)
; #$04 bytes each entry
;  * byte 0 - initial y velocity - fractional velocity byte
;  * byte 1 - initial y velocity - fast velocity byte
;  * byte 2 - initial x velocity - fractional velocity byte
;  * byte 3 - initial x velocity - fast velocity byte
weapon_item_init_vel_tbl:
    .byte $00,$fd,$80,$00 ; outdoor horizontal level initial velocities (go up 3, go right .5)
    .byte $00,$fd,$40,$00 ; vertical level left side of screen (go up 3, go right .25)
    .byte $00,$fd,$c0,$ff ; vertical level close to right edge (to up -3, go left .75)

; weapon item - pointer 2
; responsible for falling and landing on ground pattern in outdoor levels and
; falling arc pattern on indoor levels until land on ground, then advance enemy routine
weapon_item_routine_01:
    jsr set_weapon_item_sprite            ; set the correct sprite code based on weapon item type
    lda LEVEL_LOCATION_TYPE               ; 0 = outdoor; 1 = indoor
    beq @outdoor_pos_update               ; branch for outdoor level
    lda ENEMY_VAR_4,x                     ; indoor level, load ENEMY_VAR_4,x
    clc                                   ; clear carry in preparation for addition
    adc #$12                              ; ENEMY_VAR_4 + #$12
    sta ENEMY_VAR_4,x                     ; used to help calculate arc trajectory
    lda ENEMY_VAR_B,x                     ; used to help calculate arc trajectory
    adc #$00                              ; add any overflow from ENEMY_VAR_4 + #$12
    sta ENEMY_VAR_B,x                     ; used to help calculate arc trajectory
    jsr set_enemy_falling_arc_pos         ; set X and Y position to follow a falling arc
    lda ENEMY_VAR_3,x                     ; used to help calculate arc trajectory
    bmi @exit                             ; see if weapon item should "land" at the bottom of the indoor/base level
    lda #$a4                              ; weapon item should stop on ground, hard-coded y position #$a4 for indoor levels
    sta ENEMY_Y_POS,x                     ; set weapon item Y position on screen
    bne weapon_item_advance_enemy_routine ; set routine to weapon_item_routine_02

@exit:
    rts

; updates weapon item's X and Y position for outdoor levels
@outdoor_pos_update:
    jsr set_outdoor_weapon_item_vel           ; apply weapon item velocity and remove if off screen (at bottom, left, and right)
    jsr @top_of_screen_check                  ; see if off screen to the top, if so, don't do collision checks
    bcc @check_collision_reverse_dir          ; branch if no collision
    lda #$0a                                  ; collision detected, set a #$0a (the amount to move in the Y direction to land)
    jsr add_a_with_vert_scroll_to_enemy_y_pos ; weapon item landed on ground, update weapon item Y position
    jsr set_enemy_velocity_to_0               ; set x/y velocities to zero
    jmp advance_enemy_routine                 ; move to weapon_item_routine_02

@check_collision_reverse_dir:
    lda ENEMY_X_POS,x                  ; load enemy x position on screen
    ldy ENEMY_X_VELOCITY_FAST,x        ; load fast x velocity
    bmi @check_collision               ; check if a collision for weapon item floating left
    cmp #$e8                           ; weapon item stationary or floating right, compare x position to #$e8
    bcs @reverse_direction             ; if close to right side of screen > #$e8, then reverse direction
    lda #$0a                           ; add #$0a to weapon item X position
    jsr weapon_item_check_bg_collision ; add a to X position and get bg collision
                                       ; exit if LEVEL_SOLID_BG_COLLISION_CHECK is #$00
    bmi @reverse_direction             ; branch if weapon item collided with solid object to reverse direction
    bpl @add_10_to_y_fract_vel         ; branch if not solid bg collision to add #$10 to fractional y velocity and exit

; no collision detected or negative X velocity
@check_collision:
    cmp #$18                           ; see if close close to left edge of screen
    bcc @reverse_direction             ; branch if close to left edge of screen
    lda #$f6                           ; subtract #$10 (#$f6) from weapon item X position
    jsr weapon_item_check_bg_collision ; going left, see if about to collide with solid bg
    bpl @add_10_to_y_fract_vel         ; branch if not solid bg collision to add #$10 to fractional y velocity and exit

@reverse_direction:
    jsr reverse_enemy_x_direction ; reverse enemy's x direction

@add_10_to_y_fract_vel:
    jmp add_10_to_enemy_y_fract_vel ; add #$10 to y fractional velocity (.06 faster)

@top_of_screen_check:
    lda ENEMY_Y_POS,x    ; load enemy y position on screen
    cmp #$20             ; compare ENEMY_Y_POS,x < #$20
    bcc clear_carry_exit ; branch if weapon item is off the top of the screen

; outdoor weapon item collision check
; if weapon item is falling (not ascending), then check for bg collision
; output
;  * carry set when falling and collided with background
;  * carry clear when either ascending or no bg collision
check_weapon_item_collision:
    lda ENEMY_FRAME,x                   ; load enemy animation frame number
    ora ENEMY_Y_VELOCITY_FAST,x
    bmi clear_carry_exit                ; branch if flying upward, no bg collision detection
    ldy #$08                            ; y = #$08
    jsr add_y_to_y_pos_get_bg_collision ; add #$10 to enemy y position and gets bg collision code
                                        ; (see if about to land on something)
    beq clear_carry_exit                ; exit if no background collision
    sec                                 ; landing on something, set carry
    rts

clear_carry_exit:
    clc ; clear the carry flag
    rts

; check for background collision for weapon item if LEVEL_SOLID_BG_COLLISION_CHECK is non-zero
; add a to ENEMY_X_POS,x
; input
;  * a - weapon item test x position
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;    carry clear when LEVEL_SOLID_BG_COLLISION_CHECK is #$00
weapon_item_check_bg_collision:
    clc                                ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                  ; add to enemy x position on screen
    sta $08
    lda LEVEL_SOLID_BG_COLLISION_CHECK ; see if level specifies that weapon items should collide with solid bg objects
    beq clear_carry_exit               ; exit as if no background solid collision enabled for level
    lda ENEMY_FRAME,x                  ; checking for solid bg collision, enemy animation frame number
    bne @continue
    ldy ENEMY_Y_POS,x                  ; enemy y position on screen
    cpy #$10
    bcs @continue_2                    ; branch if ENEMY_Y_POS,x >= #$10

@continue:
    ldy #$10 ; use position #$10 for weapon item Y position for bg collision check

@continue_2:
    lda $08                  ; load enemy X position
    jmp get_bg_collision_far ; get background collision code

; weapon item - pointer 3
; continually watches to see if still on ground
; if ground disappears or weapon item slides off, move back to weapon_item_routine_01
weapon_item_routine_02:
    jsr set_weapon_item_sprite
    lda LEVEL_LOCATION_TYPE        ; 0 = outdoor; 1 = indoor
    beq @outdoor_weapon_item       ; branch for outdoor level
    lda LEVEL_SCREEN_SCROLL_OFFSET ; indoor level, load scrolling offset within frame in pixels
    beq @exit
    jmp remove_enemy               ; from bank 7

@outdoor_weapon_item:
    jsr set_outdoor_weapon_item_vel ; apply weapon item velocity and remove if off screen (at bottom, left, and right)
    jsr check_weapon_item_collision ; check weapon item bg collision if falling
    bcs @exit                       ; exit if collision detected
    lda #$02                        ; no bg collision detected, a = #$02
    jmp set_enemy_routine_to_a      ; set routine index to weapon_item_routine_01

@exit:
    rts

; sets sprite, attributes (palette) and updates for flashing if falcon weapon item
set_weapon_item_sprite:
    lda #$00                       ; a = #$00
    ldy ENEMY_FRAME,x              ; enemy animation frame number
    bne @set_a_to_sprite_code_exit ; not first frame of animation, set invisible and exit
    lda ENEMY_ATTRIBUTES,x         ; load enemy attributes
    and #$07                       ; keep enemy attributes portion
    tay
    cmp #$06                       ; 06 = falcon item
    bne @set_sprite_code
    lda FRAME_COUNTER              ; falcon item, flash falcon colors based on frame counter
    lsr
    lsr
    lsr                            ; flash every #$08 frames
    and #$03                       ; keep bits .... ..xx
    ora #$04                       ; set bit 2 (use palette defined in bits 0 and 1)
    sta ENEMY_SPRITE_ATTR,x        ; update enemy sprite attribute so it flashes

@set_sprite_code:
    lda weapon_item_sprite_code_tbl,y ; load weapon item sprite code

@set_a_to_sprite_code_exit:
    sta ENEMY_SPRITES,x ; set weapon item sprite code
    rts

; table for item sprite codes (#$7 bytes)
; #$33 - sprite code for r weapon (sprite_33)
; #$34 - sprite code for m weapon (sprite_34)
; #$31 - sprite code for f weapon (sprite_35)
; #$2f - sprite code for s weapon (sprite_2f)
; #$32 - sprite code for l weapon (sprite_32)
; #$30 - sprite code for b weapon (barrier/invincibility) (sprite_30)
; #$4e - sprite code for falcon (sprite_4e)
weapon_item_sprite_code_tbl:
    .byte $33,$34,$31,$2f,$32,$30,$4e

; pointer table for enemy bullet (#$4 * #$2 = #$8 bytes)
enemy_bullet_routine_ptr_tbl:
    .addr enemy_bullet_routine_00 ; CPU address $814f (initialize collision code)
    .addr enemy_bullet_routine_01 ; CPU address $8161 (init palette, sprite, and velocity)
    .addr enemy_bullet_routine_02 ; CPU address $81e4 (level 1 boss cannonball explosion animation routine)
    .addr remove_enemy            ; CPU address $e809 from bank 7

; enemy bullet - pointer 1
enemy_bullet_routine_00:
    ldy ENEMY_VAR_1,x               ; load bullet type
    lda bullet_collision_code_tbl,y ; load bullet collision code
    sta ENEMY_SCORE_COLLISION,x     ; store bullet collision code
    jmp advance_enemy_routine       ; advance to next routine

; for enemy bullet collision box (#$6 bytes)
; * #$01 - regular bullets (bullet types #$00, #$03)
; * #$05 - larger cannonball bullets (bullet types #$01, #$02)
; * #$02 - level 3 dragon boss fire ball (dragon arm orb projectile) (bullet type #$04)
bullet_collision_code_tbl:
    .byte $01,$05,$05,$01,$02,$00

; enemy bullet - pointer 2
enemy_bullet_routine_01:
    ldy ENEMY_VAR_1,x               ; load bullet type
    bne @init_bullet_vel_pos_sprite ; bullet type is not #$00, no need changing to red for snow field
    lda CURRENT_LEVEL               ; current level
    cmp #$04                        ; check if level 5 (snow field)
    bne @init_bullet_vel_pos_sprite ; not level 5, don't change bullet type #$00 to #05
    ldy #$05                        ; snow field, change bullet type #$00 to #05 (for red bullets)

@init_bullet_vel_pos_sprite:
    lda bullet_sprite_tbl,y            ; load bullet sprite
    sta ENEMY_SPRITES,x                ; store bullet sprite
    lda bullet_palette_tbl,y           ; load bullet's palette
    sta ENEMY_SPRITE_ATTR,x            ; set sprite attribute (palette)
    jsr update_enemy_pos               ; apply velocities and scrolling adjust
    ldy ENEMY_VAR_1,x                  ; re-load bullet type (clears snow level #$05 override)
    bne @continue                      ; skip if not a regular bullet
    lda LEVEL_SOLID_BG_COLLISION_CHECK ; see if should test bullet - solid bg collisions
    bpl @continue                      ; skip if level doesn't specify bullets should collide with solid bg objects
    jsr check_enemy_collision_solid_bg ; see if bullet is colliding with solid object, or floor on top of solid object
    bpl enemy_bullet_routine_01_exit   ; exit if solid collision code
    jmp remove_enemy                   ; from bank 7

@continue:
    dey
    beq cannonball_add_gravity_explode ; branch if bullet type #$01 (large cannonball)
    dey
    dey
    beq indoor_bullet_offscreen_check  ; branch if bullet type #$03 (indoor regular bullet)
    dey
    bne enemy_bullet_routine_01_exit   ; exit if bullet not bullet type #$04 (dragon arm orb projectile)
    lda FRAME_COUNTER                  ; bullet type #$04, load frame counter for animating fire ball projectile
    lsr                                ; shift right twice
    lsr
    and #$03                           ; bits 0 and 1 cause animation to change every #$04 frames
    tay                                ; transfer bullet_04_palette_mirror_tbl offset to y
    lda bullet_04_palette_mirror_tbl,y ; load sprite flipping and palette code for animating dragon arm orb projectile
    sta ENEMY_SPRITE_ATTR,x            ; set enemy sprite attributes

enemy_bullet_routine_01_exit:
    rts

; dragon arm orb projectile (orange fireballs) palette code and mirroring (#$4 bytes)
; used for animating palette and sprite flipping every #$04 frames
bullet_04_palette_mirror_tbl:
    .byte $01,$41,$c1,$81

; check if bullet should be removed, otherwise exit
indoor_bullet_offscreen_check:
    lda ENEMY_Y_POS,x     ; load enemy y position on screen
    cmp #$b4              ; see if bullet far at bottom of screen
    bcs @remove_bullet    ; remove if too far down on screen
    lda ENEMY_X_POS,x     ; load enemy x position on screen
    cmp #$20              ; see if bullet far to the left
    bcc @remove_bullet    ; remove if bullet too far to the left
    cmp #$e0              ; see if bullet too far to the right
    bcc enemy_bullet_exit ; exit if not too far to the left

@remove_bullet:
    jmp remove_enemy ; from bank 7

; large cannonball bullet (bullet type #$01)
; adds gravity to create arc, and explodes at height #$d0 (the ground)
; if explodes, moves to enemy_bullet_routine_02, otherwise exists
cannonball_add_gravity_explode:
    lda #$14                       ; a = #$14 (gravity coefficient for bombs)
    jsr add_a_to_enemy_y_fract_vel ; add a to enemy y fractional velocity
    lda ENEMY_Y_POS,x              ; load enemy y position on screen
    cmp #$d0                       ; bombs explode at this height
    bcc enemy_bullet_exit          ; exit if not yet exploded
    lda #$00                       ; a = #$00
    sta ENEMY_FRAME,x              ; set enemy animation frame number
    lda #$01                       ; a = #$01
    sta ENEMY_ANIMATION_DELAY,x    ; enemy explosion animation frame delay counter

adv_bullet_routine:
    jmp advance_enemy_routine ; advance to next routine

; table for bullet sprite codes (#$6 bytes)
; sprite_1e - regular bullet
; sprite_21 - large cannonball bullet
; sprite_79 - level 3 dragon boss fire ball
; sprite_07 - level 5 - snow field red bullets
bullet_sprite_tbl:
    .byte $1e,$21,$21,$1e,$79,$07

; table for bullet palette codes (#$6 bytes)
bullet_palette_tbl:
    .byte $01,$02,$02,$01,$01,$02

; enemy bullet - pointer 3
; only used for bullet type #$03 (level 1 boss cannonball) explosion animation
enemy_bullet_routine_02:
    jsr add_scroll_to_enemy_pos           ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x           ; decrement enemy animation frame delay counter
    bne enemy_bullet_exit                 ; exit if animation delay hasn't elapsed
    lda #$08                              ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x           ; set enemy animation frame delay counter
    inc ENEMY_FRAME,x                     ; increment enemy animation frame number
    ldy ENEMY_FRAME,x                     ; load enemy animation frame number
    cpy #$03                              ; see if on third frame of animation
    bcs adv_bullet_routine                ; go to enemy_bullet_routine_03 if explosion animation complete
    lda cannonball_explosion_sprite_tbl,y ; load cannonball explosion sprite
    sta ENEMY_SPRITES,x                   ; write enemy sprite code to CPU buffer

enemy_bullet_exit:
    rts

; table for bullet type #$02 (cannonball) explosion sprite codes (#$3 bytes)
cannonball_explosion_sprite_tbl:
    .byte $37,$36,$37

; pointer table for weapon box (#$b * #$2 = #$16 bytes)
weapon_box_routine_ptr_tbl:
    .addr weapon_box_routine_00        ; CPU address $821b
    .addr weapon_box_routine_01        ; CPU address $8225
    .addr weapon_box_routine_02        ; CPU address $8248
    .addr weapon_box_routine_03        ; CPU address $82b0
    .addr weapon_box_routine_04        ; CPU address $82bd
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

; weapon box - pointer 1
; initialize ENEMY_FRAME, set delay and move to weapon_box_routine_01
weapon_box_routine_00:
    lda #$01          ; a = #$01
    sta ENEMY_FRAME,x ; set enemy animation frame number
    lda #$20          ; a = #$20 (weapon box initial delay)

set_enemy_delay_adv_routine_far:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; Weapon Box - Pointer 2
; wait for scroll to bring weapon box to specified position, then advance to weapon_box_routine_02
; if pill box sensor is close to edge of screen (left for horizontal levels, bottom for vertical levels), then move to weapon_box_routine_03
weapon_box_routine_01:
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    lda #$f0                            ; set x position for weapon box activation
    ldy #$30                            ; set y position for vertical level weapon box activation
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$f0 X position for horizontal levels, and #$30 for vertical levels
    bcc weapon_box_exit                 ; exit if player is too far from pill box sensor to activate it
    lda #$18                            ; a = #$18
    ldy #$c8                            ; y = #$c8
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$18 X position for horizontal levels, and #$c8 for vertical levels
    bcs adv_to_weapon_box_routine_03    ; see if pill box sensor is close to left (or bottom) of screen, if so, move to weapon_box_routine_03 (closes weapon box)
    dec ENEMY_ANIMATION_DELAY,x         ; decrement enemy animation frame delay counter
    bne weapon_box_exit
    lda #$08                            ; a = #$08
    bne set_enemy_delay_adv_routine_far ; set ENEMY_ANIMATION_DELAY to #$08 and move to weapon_box_routine_02

adv_to_weapon_box_routine_03:
    lda #$04                   ; a = #$04
    jmp set_enemy_routine_to_a ; set to weapon_box_routine_03

; Weapon Box - Pointer 3
; animates opening and closing of weapon box
weapon_box_routine_02:
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    lda #$18                            ; a = #$18
    ldy #$c8                            ; y = #$c8
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$18 X position for horizontal levels, and #$c8 for vertical levels
    bcs adv_to_weapon_box_routine_03    ; see if pill box sensor is close to left (or bottom) of screen, if so, move to weapon_box_routine_03 (closes weapon box)
    dec ENEMY_ANIMATION_DELAY,x         ; decrement animation frame
    bne weapon_box_exit                 ; exit if animation hasn't completed
    lda #$08                            ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x         ; set enemy animation frame delay counter
    lda ENEMY_VAR_2,x                   ; load whether the weapon box is open or not
    bne @open_weapon_box                ; branch if weapon box is open
    jsr set_weapon_box_supertile        ; weapon box is close,d set the weapon box super tile based on ENEMY_FRAME
    bcs weapon_box_exit
    lda ENEMY_FRAME,x                   ; load enemy animation frame number
    cmp #$02                            ; see if weapon box is open
    bcc inc_weapon_box_frame            ; branch if weapon box is closed, or closing/opening, increment ENEMY_FRAME to move to next frame's super-tile
    dec ENEMY_FRAME,x                   ; weapon box is closed; animate closing by decrementing ENEMY_FRAME to use the partially closed super-tile
    lda #$01                            ; a = #$01
    sta ENEMY_HP,x                      ; set weapon box hp to #$01 (when not closed)
    lda #$01                            ; a = #$01
    bne @set_animation_delay            ; always branch

@open_weapon_box:
    jsr set_weapon_box_supertile ; set the weapon box super tile based on ENEMY_FRAME
    bcs weapon_box_exit
    lda ENEMY_FRAME,x            ; load enemy animation frame number
    bne dec_weapon_box_frame     ;
    inc ENEMY_FRAME,x            ; increment enemy animation frame number
    lda #$f0                     ; a = #$f0 (f0 = no hit)
    sta ENEMY_HP,x               ; set enemy hp
    lda #$00                     ; a = #$00

@set_animation_delay:
    sta ENEMY_VAR_2,x           ; store whether the weapon box is open
    lda #$40                    ; a = #$40 (delay when weapon box fully open)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set routine to weapon_box_routine_01

; next animation frame
inc_weapon_box_frame:
    inc ENEMY_FRAME,x ; increment enemy animation frame number

weapon_box_exit:
    rts

; previous animation frame
dec_weapon_box_frame:
    dec ENEMY_FRAME,x ; decrement enemy animation frame number
    rts

; sets the weapon box super tile based on ENEMY_FRAME
set_weapon_box_supertile:
    ldy ENEMY_FRAME,x                    ; enemy animation frame number
    lda weapon_box_supertile_tbl,y       ; load the correct super-tile index (indexes into level_X_nametable_update_supertile_data)
    jmp draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position

; table for weapon box frame codes (#$3 bytes)
; #$00 closed
; #$01 semi-open
; #$02 fully open
weapon_box_supertile_tbl:
    .byte $00,$01,$02

; weapon box pointer 4
; weapon box deactivated, mark closed, only executed once
weapon_box_routine_03:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$00                    ; #$00 = weapon box closed (indexes into level_X_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a  ; draw the closed weapon box super-tile
    bcs weapon_box_exit_1
    jmp remove_enemy            ; remove the enemy since not drawn

; Weapon Box - Pointer 5
; initiated when weapon box is destroyed via enemy_destroyed_routine_00
; set appropriate background super-tile based on level and ENEMY_ATTRIBUTES (bit 4)
weapon_box_routine_04:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda CURRENT_LEVEL           ; current level
    asl
    tay
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    and #$08                    ; keep bits .... x...
    beq @continue               ; if big 4 is not set then use the first byte
    iny                         ; bit 4 was set, use second byte

@continue:
    lda weapon_box_destroyed_supertile,y
    jsr draw_enemy_supertile_a           ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs weapon_box_exit

play_explosion_sound:
    lda #$19                          ; a = #$19 (sound_19)
    jsr play_sound                    ; play enemy destroyed sound
    jsr set_08_09_to_enemy_pos        ; set $08 and $09 to enemy x's X and Y position
    jsr create_two_explosion_89       ; create explosion #$89 at location ($09, $08)
    lda ENEMY_ATTRIBUTES,x            ; load enemy attributes
    and #$07                          ; keep bits .... .xxx
    sta ENEMY_ATTRIBUTES,x
    jsr clear_sprite_clear_enemy_pt_3
    lda #$01                          ; a = #$01
    sta ENEMY_ROUTINE,x               ; enemy routine index
    lda #$00                          ; a = #$00
    sta ENEMY_TYPE,x                  ; set enemy slot to be weapon item

weapon_box_exit_1:
    rts

; table for weapon box tile code after destruction (#$8 * #$2 = #$10 bytes)
; each entry is for a level
; the least significant bit of the vertical position is also used to
; specify which tile is shown after being destroyed.
weapon_box_destroyed_supertile:
    .byte $16,$16 ; level 1
    .byte $16,$16 ; level 2
    .byte $16,$16 ; level 3
    .byte $16,$16 ; level 4
    .byte $19,$1a ; level 5
    .byte $03,$04 ; level 6
    .byte $09,$09 ; level 7
    .byte $16,$16 ; ending

; pointer table for weapon zeppelin (#$3 * #$2 = #$6 bytes)
flying_capsule_routine_ptr_tbl:
    .addr flying_capsule_routine_00 ; CPU address $830b
    .addr flying_capsule_routine_01 ; CPU address $835d
    .addr flying_capsule_routine_02 ; CPU address $8376

; weapon zeppelin - pointer 1
flying_capsule_routine_00:
    lda #$03                    ; a = #$03 (weapon zeppelin palette code)
    sta ENEMY_SPRITE_ATTR,x     ; set enemy sprite attributes
    lda ENEMY_Y_POS,x
    sta ENEMY_VAR_1,x
    lda ENEMY_X_POS,x           ; load enemy x position on screen
    sta ENEMY_VAR_2,x
    lda LEVEL_SCROLLING_TYPE    ; 0 = horizontal, indoor/base; 1 = vertical
    bne @set_vertical_level_vel ; branch for vertical level (waterfall)
    lda #$20                    ; a = #$20 (zeppelin vertical amplitude)
    jsr add_a_to_enemy_y_pos    ; add #$20 to y position
    lda #$10                    ; a = #$10 (zeppelin initial x position)
    sta ENEMY_X_POS,x           ; set initial enemy x position on screen
    ldy #$00                    ; y = #$00
    beq @set_vel_adv_routine    ; always branch

@set_vertical_level_vel:
    lda #$20                 ; a = #$20
    jsr add_a_to_enemy_x_pos ; add #$20 to enemy x position on screen
    lda #$e0                 ; a = #$e0
    sta ENEMY_Y_POS,x        ; enemy y position on screen
    ldy #$04                 ; y = #$04

@set_vel_adv_routine:
    lda flying_capsule_vel_tbl,y   ; load y fractional velocity byte
    sta ENEMY_Y_VELOCITY_FRACT,x   ; set y fractional velocity byte
    lda flying_capsule_vel_tbl+1,y ; load y velocity fast byte
    sta ENEMY_Y_VELOCITY_FAST,x    ; set y velocity fast byte
    lda flying_capsule_vel_tbl+2,y ; load x fractional velocity byte
    sta ENEMY_X_VELOCITY_FRACT,x   ; set x fractional velocity byte
    lda flying_capsule_vel_tbl+3,y ; load x velocity fast byte
    sta ENEMY_X_VELOCITY_FAST,x    ; set x velocity fast byte
    jmp advance_enemy_routine      ; go to flying_capsule_routine_01

; table for weapon zeppelin velocities (#$4 * #$2 = #$8 bytes)
flying_capsule_vel_tbl:
    .byte $00,$00,$80,$01 ; horizontal and indoor/base levels
    .byte $80,$fe,$00,$00 ; vertical level (level 3 - waterfall)

; weapon zeppelin - pointer 2
flying_capsule_routine_01:
    lda #$4d                     ; a = #$4d (sprite_4d)
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
    lda LEVEL_SCROLLING_TYPE     ; 0 = horizontal, indoor/base; 1 = vertical
    bne @continue                ; branch if indoor level
    ldy #$01                     ; outdoor level; y = #$01
    jsr set_flying_capsule_y_vel
    jmp @update_enemy_pos

@continue:
    ldy #$01                     ; y = #$01
    jsr set_flying_capsule_x_vel

@update_enemy_pos:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

; weapon zeppelin pointer 3
flying_capsule_routine_02:
    jmp play_explosion_sound ; create explosion sound and 2 sets of explosion type #$89 at location

; pointer table for rotating gun (#$a * #$2 = #$14 bytes)
; level 1 or level 3 enemy
rotating_gun_routine_ptr_tbl:
    .addr rotating_gun_routine_00      ; CPU address $838d - set aim direction to left
    .addr rotating_gun_routine_01      ; CPU address $8397 - wait until player is close to activate
    .addr rotating_gun_routine_02      ; CPU address $83ac - show opening animation, enable collision
    .addr rotating_gun_routine_03      ; CPU address $83d5 - shut down if off screen, otherwise, wait for animation delay, then aim
    .addr rotating_gun_routine_04      ; CPU address $842e - fire desired number of bullets at player, once complete go back to rotating_gun_routine_03
    .addr rotating_gun_routine_05      ; CPU address $8482 - shuts down rotating gun, gun retracts and no longer fires, removes enemy
    .addr rotating_gun_routine_06      ; CPU address $848f - enemy destroyed routine (see enemy_destroyed_routine_01)
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; rotating gun - pointer 1
; set aim direction to left
rotating_gun_routine_00:
    jsr add_scroll_to_enemy_pos       ; add scrolling to enemy position
    lda #$06                          ; a = #$06
    sta ENEMY_VAR_1,x                 ; set aim direction to face left
    bne rotating_gun_adv_routine_exit ; advance routine to rotating_gun_routine_01 and exit

; rotating gun - pointer 2
; wait until player is close to activate
rotating_gun_routine_01:
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    lda #$f0                            ; a = #$f0 (horizontal level trigger point)
    ldy #$30                            ; y = #$30 (vertical level trigger point)
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$f0 X position for horizontal levels, and #$30 for vertical levels
    bcc rotating_gun_exit_00            ; exit if not yet at trigger point on screen, i.e. don't activate
    lda #$08                            ; should activate rotating gun, set delay to #$08
                                        ; advance routine to rotating_gun_routine_02

rotating_gun_set_delay_adv_routine_exit:
    sta ENEMY_ANIMATION_DELAY,x

rotating_gun_adv_routine_exit:
    jmp advance_enemy_routine

rotating_gun_exit_00:
    rts

; rotating gun - pointer 3
; show opening animation (#$02 frames), enable collision
rotating_gun_routine_02:
    jsr add_scroll_to_enemy_pos                 ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x                 ; decrement animation delay
    bne rotating_gun_exit_00                    ; exit if animation delay hasn't elapsed
    lda #$08                                    ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x                 ; set next animation delay to #$08
    lda ENEMY_FRAME,x                           ; load current super-tile index to (level_xx_nametable_update_supertile_data)
    clc                                         ; clear carry in preparation for addition
    adc #$03                                    ; rotating gun super-tiles start at offset #$03, add #$03
    jsr draw_enemy_supertile_a_set_delay        ; draw pattern table tile specified in a at enemy position
    bcs rotating_gun_exit_00                    ; exit if unable to update super-tile
    inc ENEMY_FRAME,x                           ; increment rotating gun super-tile to draw
    lda ENEMY_FRAME,x                           ; load rotating gun super-tile to draw
    cmp #$03                                    ; see if rotating gun is active and open, i.e. the gun is showing
    bcc rotating_gun_exit_00                    ; branch if rotating gun not yet open
    jsr enable_bullet_enemy_collision           ; rotating gun active, allow bullets to collide (and stop) upon colliding with rotating gun
    lda #$08                                    ; a = #$08
    bne rotating_gun_set_delay_adv_routine_exit ; set delay and move to rotating_gun_routine_03

; rotating gun - pointer 4
; shut down if off screen, otherwise, wait for animation delay, then aim
rotating_gun_routine_03:
    jsr rotating_gun_should_disable      ; determine if almost scrolled off screen
    bcc rotating_gun_routine_03_continue ; branch if not past trigger point

; shuts down rotating gun by moving to rotating_gun_routine_05,
; which sets super-tile to closed and removes enemy
rotating_gun_disable:
    lda #$06                   ; a = #$06
    jmp set_enemy_routine_to_a ; set enemy routine index to rotating_gun_routine_05

; rotating gun isn't disabled, continue animation delay and aiming
rotating_gun_routine_03_continue:
    dec ENEMY_ANIMATION_DELAY,x           ; decrement animation delay
    bne @exit                             ; exit if animation delay hasn't elapsed
    ldy PLAYER_WEAPON_STRENGTH            ; load player's weapon strength
    lda rotating_gun_rotation_delay_tbl,y ; load rotation animation delay based on weapon strength
    sta ENEMY_ANIMATION_DELAY,x           ; set new animation delay
    jsr player_enemy_x_dist               ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                               ; store closest player index in $0a
    jsr set_08_09_to_enemy_pos            ; set $08 and $09 to enemy x's X and Y position
    jsr aim_var_1_for_quadrant_aim_dir_00 ; determine next aim direction [#$00-#$0b] ($0c), adjusts ENEMY_VAR_1 to get closer to that value using quadrant_aim_dir_00
    php                                   ; save the processor flags to the stack
    lda ENEMY_VAR_1,x                     ; load new enemy aim direction [#$00-#$0b] #$00 when facing right incrementing clockwise
    sec                                   ; set carry flag in preparation for subtraction
    sbc #$06                              ; subtract #$06 to get to correct super-tile to draw based on aim dir
    bcs @draw_supertile                   ; draw super-tile immediately if no underflow occurred
    adc #$0c                              ; underflow, add #$0c to wrap around back to correct super-tile
                                          ; e.g. aim dir #$03 should result in #$09

@draw_supertile:
    clc                                  ; clear carry in preparation for addition
    adc #$05                             ; add #$05, offset to open rotating gun super-tiles (level_xx_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position
    bcc @set_vars_adv_routine            ; branch if successfully drawn supertile
                                         ; to set ENEMY_VAR_2, animation delay, and advance routine if rotating gun aiming at player
    plp                                  ; restore processor flags

@exit:
    rts

; if rotating gun aiming at player (carry flag set when enemy aiming at player from aim_var_1_for_quadrant_aim_dir_00)
; set vars and advance routine to rotating_gun_routine_04 to fire at player
@set_vars_adv_routine:
    plp                                       ; restore processor flags
    bcc @exit                                 ; exit if not aiming at player
    lda ENEMY_ATTRIBUTES,x                    ; load enemy attributes
    and #$03                                  ; keep bits .... ..xx
    tay
    lda rotating_gun_bullets_per_attack_tbl,y ; load bullets per attack
    sta ENEMY_VAR_2,x                         ; store bullets per attack in ENEMY_VAR_2
    lda #$08                                  ; a = #$08
    jmp set_enemy_delay_adv_routine           ; set ENEMY_ANIMATION_DELAY counter to #$08 go to rotating_gun_routine_04

; table for rotating gun bullets per attack (from attributes) (#$4 bytes)
rotating_gun_bullets_per_attack_tbl:
    .byte $01,$02,$03,$03

; whether or not to disable/shut down the rotating gun
; rotating gun shuts down when scrolled to the left 10% of the screen (horizontal level)
; rotating gun shuts down when scrolled down to the bottom 20% of the screen (vertical level)
rotating_gun_should_disable:
    jsr add_scroll_to_enemy_pos         ; adjust enemy location based on scroll
    lda #$18                            ; a = #$18
    ldy #$c8                            ; y = #$c8
    jmp set_carry_if_past_trigger_point ; set carry if enemy has crossed #$18 X position for horizontal levels, and #$c8 for vertical levels

; rotating gun - pointer 5
; fire desired number of bullets at player, once complete go back to rotating_gun_routine_03
rotating_gun_routine_04:
    jsr rotating_gun_should_disable        ; determine if almost scrolled off screen
    bcs rotating_gun_disable               ; if out of range, shut down by moving to rotating_gun_routine_05
    dec ENEMY_ANIMATION_DELAY,x            ; decrement animation delay
    bne @exit                              ; exit if animation delay hasn't elapsed
    ldy ENEMY_VAR_1,x                      ; load current aim direction. [#$00-#$0b] #$00 when facing right incrementing clockwise
    lda rotating_gun_bullet_y_offset_tbl,y ; load the bullet y offset from rotating gun based on aim direction
    clc                                    ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                      ; add bullet offset to enemy position
    sta $08                                ; store bullet generation y position
    lda rotating_gun_bullet_x_offset_tbl,y ; load the bullet x offset from rotating gun based on aim direction
    clc                                    ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                      ; add to enemy x position on screen
    sta $09                                ; store bullet generation x position
    tya                                    ; set bullet type
    ldy #$04                               ; y = #$04 rotating gun bullet speed
    jsr bullet_generation                  ; create enemy bullet (ENEMY_TYPE #$02) of type a with speed y at ($09, $08)
    lda #$10                               ; a = #$10 delay between bullets
    sta ENEMY_ANIMATION_DELAY,x            ; set delay between bullets
    dec ENEMY_VAR_2,x                      ; created bullet, decrement number of bullets to fire
    bne @exit                              ; exit if still more bullets to fire
    ldy PLAYER_WEAPON_STRENGTH             ; fired all bullets, load player weapon strength
    lda rotating_gun_animation_delay_tbl,y ; load animation delay based on weapon strength
    sta ENEMY_ANIMATION_DELAY,x            ; store enemy animation delay
    lda #$04                               ; a = #$04
    jmp set_enemy_routine_to_a             ; set enemy routine index to rotating_gun_routine_03

@exit:
    rts

; table for rotating gun delays while rotating based on player weapon strength (#$4 bytes)
; the stronger the weapon the shorter the delay
rotating_gun_rotation_delay_tbl:
    .byte $30,$28,$20,$18

; table for rotating gun delays after attack (#$4 bytes)
rotating_gun_animation_delay_tbl:
    .byte $80,$60,$40,$30

; table for rotating gun bullet initial y offset positions (#$f bytes)
rotating_gun_bullet_y_offset_tbl:
    .byte $00,$07,$0c

rotating_gun_bullet_x_offset_tbl:
    .byte $0d,$0c,$07
    .byte $00,$f9,$f4
    .byte $f3,$f4,$f9
    .byte $00,$07,$0c

; rotating gun - pointer 6
; shuts down rotating gun, gun retracts and no longer fires, removes enemy
rotating_gun_routine_05:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$03                    ; a = #$03 (rotating gun closed super-tile)
    jsr draw_enemy_supertile_a  ; draw super-tile a (level_xx_nametable_update_supertile_data offset) at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs rotating_gun_exit_01    ; exit if unable to draw super-tile
    jmp remove_enemy            ; remove rotating gun

; rotating gun - pointer 7
; enemy destroyed routine (see enemy_destroyed_routine_01)
rotating_gun_routine_06:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    lda #$16                    ; a = #$16 (red turret and rotating gun rock background, see level_xx_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a  ; draw super-tile a (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs rotating_gun_exit_01    ; exit if unable to draw super-tile
    jmp advance_enemy_routine   ; advance to enemy_routine_init_explosion

; sets carry once enemy is far enough on the screen
; for horizontal levels, triggers once enemy is to the left of specified x location
; for vertical levels, triggers once enemy is below the specified y location
; also used to see if player past enemy for red turrets
; input
;  * a - x position on screen to trigger enemy (for horizontal levels)
;  * y - y position on screen where enemy is activated (for vertical levels)
set_carry_if_past_trigger_point:
    sta $08
    sty $09
    lda LEVEL_SCROLLING_TYPE ; 0 = horizontal, indoor/base; 1 = vertical
    bne @vertical_level      ; branch for vertical level
    lda ENEMY_X_POS,x        ; horizontal or indoor/base level, load enemy x position on screen
    cmp $08                  ; compare enemy position to X trigger position
    bcs @exit_carry_clear    ; scroll has not put enemy at trigger position, exit with carry clear
    bcc @exit_carry_set      ; enemy crossed trigger position, exit with carry set

@vertical_level:
    lda ENEMY_Y_POS,x     ; load enemy Y position on screen
    cmp $09               ; compare enemy position to Y trigger position
    bcc @exit_carry_clear ; scroll has not put enemy at trigger position, exit with carry clear

@exit_carry_set:
    sec ; set the carry flag, enemy close to player
    rts

@exit_carry_clear:
    clc ; clear the carry flag, enemy too far away from player

rotating_gun_exit_01:
    rts

; pointer table for red turret (#$9 * #$2 bytes = #$12 bytes)
red_turret_routine_ptr_tbl:
    .addr red_turret_routine_00        ; CPU address $84ca - initialize ENEMY_VAR_1 (aim direction), advance to red_turret_routine_01
    .addr red_turret_routine_01        ; CPU address $84d4 - wait for player to get close, then advance routine
    .addr red_turret_routine_02        ; CPU address $84e8
    .addr red_turret_routine_03        ; CPU address $8537
    .addr red_turret_routine_04        ; CPU address $85d1
    .addr red_turret_routine_05        ; CPU address $85e1
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

; red turret - pointer 1
; initialize ENEMY_VAR_1 (aim direction), advance to red_turret_routine_01
; identical code to rotating_gun_routine_00
red_turret_routine_00:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$06                    ; a = #$06
    sta ENEMY_VAR_1,x           ; set aim direction to face left
    bne red_turret_adv_routine  ; always branch, advance enemy routine

; red turret - pointer 2
; wait for player to get close, then advance routine
red_turret_routine_01:
    lda #$f0                            ; a = #$f0 (red turret emerge at this x offset)
    ldy #$40                            ; y = #$40
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$f0 X position for horizontal levels, and #$40 for vertical levels
    bcc red_turret_add_scroll_to_pos    ; player not close, do nothing
    lda #$01                            ; player close, set a = #$01 (delay before emerging)

red_turret_set_delay_adv_routine:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

red_turret_adv_routine:
    jsr advance_enemy_routine ; advance to next routine

red_turret_add_scroll_to_pos:
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position

; red turret - pointer 3
red_turret_routine_02:
    jsr red_turret_load_supertile          ; load the appropriate super-tile if the animation delay has elapsed
    bcs red_turret_add_scroll_to_pos       ; exit if enemy animation delay hasn't elapsed, no super-tile to update
    inc ENEMY_FRAME,x                      ; increment the enemy animation frame number
    lda ENEMY_FRAME,x                      ; load the enemy animation frame number
    cmp #$04                               ; compare to the last frame
    bcc red_turret_add_scroll_to_pos       ; if not the last frame, then add scroll and exit
    lda #$02                               ; a = #$02
    sta ENEMY_VAR_2,x
    lda #$28                               ; a = #$28 (delay before first attack)
    ldy GAME_COMPLETION_COUNT              ; load the number of times the game has been completed
    beq @set_attack_delay_enable_collision ; keep #$28 attack delay if game hasn't been beaten
    lda #$08                               ; lower attack delay to #$08 when game has been beaten at least once

@set_attack_delay_enable_collision:
    sta ENEMY_ATTACK_DELAY,x
    jsr enable_bullet_enemy_collision    ; allow bullets to collide (and stop) upon colliding with red turret
    lda #$10                             ; set animation delay to #$10
    bne red_turret_set_delay_adv_routine ; always branch, set animation delay to #$10 and advance routine

red_turret_load_supertile:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne @set_carry_exit         ; set carry and exit if animation delay hasn't elapsed
    lda #$04                    ; a = #$04
    sta ENEMY_ANIMATION_DELAY,x ; delay between frames when emerging
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    lsr                         ; move bit 0 to carry flag, this bit specifies which background to load
    lda ENEMY_FRAME,x           ; load enemy animation frame number
    bcc @load_supertile         ; if bit 0 was 0, then rocky background, don't adjust super-tile offset
    adc #$03

@load_supertile:
    tay
    lda red_turret_supertile_1_tbl,y
    jmp draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position

@set_carry_exit:
    sec ; set carry flag
    rts

; table for red turret super-tile codes (#$b bytes)
; see level_1_nametable_update_supertile_data
; see level_3_nametable_update_supertile_data
; #$11 - red turret facing left
; #$12 - red turret facing up left
; #$13 - red turret facing up up left (almost straight up)
; #$14 - red turret 1/2 rising from ground rocky
; #$15 - red turret 1/2 rising from ground metal/waterfall background
; #$16 - just rocky background no red turret
; #$17 - just secondary background no red turret (mostly metal background for level 1, waterfall for level 3)
; #$18 - red turret 3/4 rising from ground black background
red_turret_supertile_1_tbl:
    .byte $16,$14

; see level_1_nametable_update_supertile_data
; see level_3_nametable_update_supertile_data
red_turret_supertile_2_tbl:
    .byte $18,$11,$17,$15,$18,$11,$11,$12,$13

; red turret - pointer 4
red_turret_routine_03:
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    lda #$30                            ; a = #$30 (x offset to return to ground)
    ldy #$c0                            ; y = #$c0
    jsr set_carry_if_past_trigger_point ; set carry if enemy has crossed #$30 X position for horizontal levels (left side of screen)
                                        ; and #$c0 for the vertical level (bottom of screen)
    bcc @gen_bullet_if_appropriate      ; branch if red turret should still be active (not scrolled to left/bottom of screen yet)
    lda #$02                            ; red turret on far left (horizontal) or far bottom (vertical), disable
    sta ENEMY_FRAME,x                   ; initial frame code when returning to ground (#$02)
    jsr disable_enemy_collision         ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$01                            ; a = #$01
    jmp set_enemy_delay_adv_routine     ; set ENEMY_ANIMATION_DELAY counter to #$01 advance to red_turret_routine_04

@gen_bullet_if_appropriate:
    jsr red_turret_find_target_player ; find player to target, set to y
    jsr check_red_turret_firing_range ; see if the player is above (or equal) and to the left of the red turret
    tya                               ; transfer closest player to a
    bcs @continue
    eor #$01                          ; flip bits .... ...x

@continue:
    sta $0a                           ; store player index in $0a
    jsr set_08_09_to_enemy_pos        ; set $08 and $09 to enemy x's X and Y position
    jsr get_rotate_00                 ; get enemy aim direction and rotation direction using quadrant_aim_dir_00
    sta $08                           ; set rotate direction in $08 (#$00 clockwise, #$01 counterclockwise, #$80 no rotation)
    dec ENEMY_ANIMATION_DELAY,x       ; decrement enemy animation frame delay counter
    bne @dec_attack_delay_fire_bullet
    lda #$10                          ; a = #$10
    sta ENEMY_ANIMATION_DELAY,x       ; set enemy animation frame delay counter
    ldy ENEMY_VAR_1,x
    lda $08
    bmi @dec_attack_delay_fire_bullet
    bne @continue2
    cpy #$08
    beq @dec_attack_delay_fire_bullet
    inc ENEMY_VAR_1,x
    bne @set_supertile_fire

@continue2:
    cpy #$06
    beq @dec_attack_delay_fire_bullet
    dec ENEMY_VAR_1,x

@set_supertile_fire:
    ldy ENEMY_VAR_1,x
    lda red_turret_supertile_2_tbl,y
    jsr draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position

@dec_attack_delay_fire_bullet:
    dec ENEMY_ATTACK_DELAY,x ; decrement attack delay
    bne red_turret_exit      ; exit if attack delay hasn't elapsed
    ldy #$10                 ; y = #$10 (delay between attacks)
    dec ENEMY_VAR_2,x        ; delay between consecutive bullets
    bpl @generate_bullet     ; fire bullet
    lda #$02                 ; a = #$02
    sta ENEMY_VAR_2,x        ; consecutive bullets (#$02 = 3 bullets)
    ldy #$50                 ; y = #$50 (delay between attacks)

@generate_bullet:
    tya
    sta ENEMY_ATTACK_DELAY,x             ; set delay between attacks
    ldy $0f                              ; load the closest player in y
    jsr check_red_turret_firing_range    ; see if the player is above (or equal) and to the left of the red turret
    bcc red_turret_exit                  ; exit if player not in firing range of red turret
    ldy ENEMY_VAR_1,x
    lda @bullet_offset_tbl_base,y        ; load y bullet generation point y offset
    clc                                  ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                    ; add offset to red turret's y position
    sta $08                              ; store result in $08 for bullet_generation call
    lda red_turret_bullet_offset_tbl-3,y ; silly to have offsets like this !(WHY?)
                                         ; load bullet generation point x offset
    clc                                  ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                    ; add offset to red turret's x position
    sta $09                              ; store in $09 for bullet_generation call
    tya

; !(WHY?) weird to have this as a label point when only used for reading offset data in red_turret_bullet_offset_tbl
; #$06 bytes before table data
@bullet_offset_tbl_base:
    ldy #$05              ; red turret bullet speed
    jmp bullet_generation ; create enemy bullet (ENEMY_TYPE #$02) of type a with speed y at ($09, $08)

red_turret_exit:
    rts

; table for red turret bullet initial offsets (#$6 bytes)
red_turret_bullet_offset_tbl:
    .byte $00,$f8,$f0 ; x offset  #$0 , -#$8 , -#$10
    .byte $f2,$f2,$f8 ; y offset -#$e , -#$e , -#$8

; red turret - pointer 5
red_turret_routine_04:
    jsr add_scroll_to_enemy_pos   ; add scrolling to enemy position
    jsr red_turret_load_supertile
    bcs red_turret_exit
    dec ENEMY_FRAME,x             ; decrement enemy animation frame number
    bpl red_turret_exit
    jmp remove_enemy              ; from bank 7

; red turret - pointer 6
red_turret_routine_05:
    jsr add_scroll_to_enemy_pos     ; add scrolling to enemy position
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    lsr                             ; move bit 0 to carry
    lda #$16                        ; a = #$16 (rocky background)
    bcc @draw_supertile_adv_routine ; branch if ENEMY_ATTRIBUTES specifies red turret has rocky background (bit 0 - 0)
    lda #$17                        ; a = #$17 (metal or waterfall background)

@draw_supertile_adv_routine:
    jsr draw_enemy_supertile_a ; update red turret super-tile
    bcs red_turret_exit        ; exit if unable to update super-tile, will try again later
    jmp advance_enemy_routine  ; updated super-tile, advance to next routine

; red turrets only fire left and up left, checks to see if player is in firing range
; i.e. the player is above (or equal) and to the left of the red turret
; output
;  * carry - set when red turret below player and to the right
check_red_turret_firing_range:
    lda ENEMY_Y_POS,x  ; load enemy y position on screen
    clc                ; clear carry in preparation for addition
    adc #$20           ; add #$20 to allow firing if player and turret are at same height
    cmp SPRITE_Y_POS,y ; player y position on screen
    bcc @exit          ; red turret above player, exit with carry clear
    lda ENEMY_X_POS,x  ; load enemy x position on screen
    cmp SPRITE_X_POS,y ; set carry if red turret to right of player

@exit:
    rts

; pointer table for running man (#$6 * #$2 = #$16 bytes)
soldier_routine_ptr_tbl:
    .addr soldier_routine_00           ; CPU address $861e - slightly offset y position, set initial animation delay based on ENEMY_ATTRIBUTES
    .addr soldier_routine_01           ; CPU address $8665 - set velocities, enable collision
    .addr soldier_routine_02           ; CPU address $86af - soldier animation routine: walk, if jumping try to find find landing
    .addr soldier_routine_03           ; CPU address $8803 - try and fire bullet
    .addr soldier_routine_04           ; CPU address $88c3 - soldier hit, begin destroying soldier
    .addr soldier_routine_05           ; CPU address $8900 - soldier hit, apply negative gravity
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806
    .addr soldier_routine_09           ; CPU address $888c - soldier landing in water routine
    .addr soldier_routine_0a           ; CPU address $88a1 - continue splash animation and begin removing soldier

; running man - pointer 1
; slightly offset y position, set initial animation delay based on ENEMY_ATTRIBUTES
soldier_routine_00:
    jsr add_scroll_to_enemy_pos          ; adjust enemy location based on scroll
    jsr add_4_to_enemy_y_pos             ; adjust soldier down slightly so walks on ground
    lda ENEMY_ATTRIBUTES,x               ; load enemy attributes
    lsr                                  ; shift right 4 times to load high byte
    lsr
    lsr
    lsr
    and #$03                             ; keep bits 0,1,2
    tay                                  ; transfer offset to y
    lda soldier_initial_anim_delay_tbl,y ; load enemy animation delay
    jmp set_enemy_delay_adv_routine      ; set ENEMY_ANIMATION_DELAY counter to a
                                         ; advance enemy routine

; table for soldier initial animation delay (#$4 bytes)
soldier_initial_anim_delay_tbl:
    .byte $01,$10,$20,$30

; set soldier x velocity based on ENEMY_VAR_2 (#$00 left, #$01 right) (see soldier_x_vel_tbl)
; stop y velocity
soldier_stop_y_set_x_velocity:
    jsr soldier_set_x_velocity    ; set soldier x velocity based on ENEMY_VAR_2 (#$00 left, #$01 right)
    jmp set_enemy_y_velocity_to_0 ; stop any y velocity

; set soldier x velocity based on ENEMY_VAR_2 index and level scrolling type
soldier_set_x_velocity:
    ldy #$00                 ; y = #$00
    lda LEVEL_SCROLLING_TYPE ; 0 = horizontal, indoor/base; 1 = vertical
    beq @continue            ; horizontal scrolling, continue
    ldy #$04                 ; vertical level, add #$04 to offset, y = #$04

@continue:
    sty $08                      ; set offset into $08
    lda ENEMY_VAR_2,x            ; load soldier x direction (#$00 left, #$01 right)
    asl                          ; multiply by #$02, each entry is #$02 bytes
    clc                          ; clear carry in preparation for addition
    adc $08                      ; add result to base offset (#$00 or #$04)
    tay                          ; transfer offset to y
    lda soldier_x_vel_tbl,y      ; load x velocity fractional byte
    sta ENEMY_X_VELOCITY_FRACT,x ; set x velocity fractional byte
    lda soldier_x_vel_tbl+1,y    ; load x velocity fast byte
    sta ENEMY_X_VELOCITY_FAST,x  ; set x velocity fast byte

soldier_routine_exit:
    rts

; table for running man (#$8 bytes)
; first pair of bytes per level scroll is moving left, second pair is moving right
; byte 0 - x fractional velocity
; byte 1 - x fast velocity
soldier_x_vel_tbl:
    .byte $00,$ff ; (-1.00) (horizontal scrolling)
    .byte $40,$01 ; ( 1.25) (horizontal scrolling)
    .byte $00,$ff ; (-1.00) (vertical level)
    .byte $00,$01 ; ( 1.00) (vertical level)

; running man - pointer 2
; set velocities, enable collision
soldier_routine_01:
    lda LEVEL_SCROLLING_TYPE      ; 0 = horizontal, indoor/base; 1 = vertical
    beq @horizontal_level         ; branch for horizontal/indoor levels
    jsr add_scroll_to_enemy_pos   ; vertical level, adjust enemy location based on scroll
    jmp @dec_delay_enable_set_vel ; decrement animation delay and exit

@horizontal_level:
    lda FRAME_SCROLL              ; how much to scroll the screen (#00 - no scroll)
    beq @dec_delay_enable_set_vel
    lda ENEMY_ATTRIBUTES,x        ; scrolling, load soldier enemy attributes
    and #$01                      ; keep bit 0 specifying run direction
    beq @continue                 ; branch if running left
    and FRAME_COUNTER             ; running right, load frame counter
    lsr                           ; push bit 0 to carry
    bcs @dec_delay_enable_set_vel ; if odd frame, decrement animation delay
    bcc soldier_routine_exit      ; even frame, exit without decrementing animation delay

@continue:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    beq @enable_set_vel

@dec_delay_enable_set_vel:
    dec ENEMY_ANIMATION_DELAY,x
    bne soldier_routine_exit

@enable_set_vel:
    ldy #$10                            ; y = #$10
    jsr add_y_to_y_pos_get_bg_collision ; add #$10 to enemy y position and gets bg collision code
    bne @enable_collision_set_vel       ; branch if collision with ground, water, or solid
    jmp remove_enemy                    ; remove enemy if no collision
                                        ; soldier wasn't placed in an appropriate position, e.g. bridge destroyed

@enable_collision_set_vel:
    jsr enable_enemy_collision    ; enable bullet-enemy collision and player-enemy collision checks
    lda ENEMY_ATTRIBUTES,x        ; load soldier enemy attributes
    and #$01                      ; keep soldier running direction
    sta ENEMY_VAR_2,x             ; set running direction in ENEMY_VAR_2
    beq @stop_y_set_x_adv_routine ; if running left, branch
    lda #$0a                      ; running right, set x position to #$0a, a = #$0a
    sta ENEMY_X_POS,x             ; set enemy x position on screen

@stop_y_set_x_adv_routine:
    jsr soldier_stop_y_set_x_velocity ; set soldier x velocity based on direction (ENEMY_VAR_2); set y velocity to #$00
    lda #$10                          ; a = #$10
    jmp set_enemy_delay_adv_routine   ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; Running Man - Pointer 3
; soldier animation routine: walk, if jumping try to find find landing
soldier_routine_02:
    lda ENEMY_VAR_3,x                   ; see if soldier is jumping or not
    beq @continue                       ; branch if not jumping
    lda #$0a                            ; soldier jumping, set a = #$0a
    sta ENEMY_FRAME,x                   ; set enemy animation frame number to jumping frame
    lda ENEMY_Y_VELOCITY_FAST,x         ; load y velocity
    bmi @no_landing
    ldy #$10                            ; y = #$10
    jsr add_y_to_y_pos_get_bg_collision ; add #$10 to enemy y position and gets bg collision code
    bmi @floor_solid_landing            ; branch if landed on solid object
    bcc @land_in_water_or_no_landing    ; branch if not a collision with the floor, i.e. empty, or water collision

; floor or solid collision
@floor_solid_landing:
    lda #$00                                    ; a = #$00
    sta ENEMY_VAR_3,x                           ; clear flag specifying soldier is jumping
    sta ENEMY_FRAME,x                           ; set enemy animation frame number
    jsr add_4_to_enemy_y_pos
    jsr soldier_stop_y_set_x_velocity           ; set soldier x velocity based on direction (ENEMY_VAR_2); set y velocity to #$00
    jmp soldier_apply_vel_check_solid_collision

@land_in_water_or_no_landing:
    cmp #$02                   ; see if water collision code (#$02)
    bne @no_landing            ; branch if not a water collision, i.e. floor collision or empty collision
    lda #$0a                   ; soldier landed in water, change routine, a = #$0a
    jsr set_enemy_routine_to_a ; set enemy routine index to soldier_routine_09

@no_landing:
    jsr add_10_to_enemy_y_fract_vel             ; add #$10 to y fractional velocity (.06 faster)
    jmp soldier_apply_vel_check_solid_collision

; soldier_routine_02 - soldier not jumping
@continue:
    lda ENEMY_ATTRIBUTES,x            ; load enemy attributes
    and #$0c                          ; keep bits .... xx..
    beq @continue_walk_routine        ; soldier doesn't fire, continue walking routine
    lda ENEMY_ATTACK_FLAG             ; see if enemies should attack
    beq @continue_walk_routine        ; enemies shouldn't attack, continue walking routine
    dec ENEMY_ANIMATION_DELAY,x       ; decrement enemy animation frame delay counter
    bne @continue_walk_routine        ; delay timer hasn't elapsed, continue walking routine
    lda #$80                          ; a = #$80
    sta ENEMY_ANIMATION_DELAY,x       ; set enemy animation frame delay counter
    lda #$08                          ; a = #$08
    sta ENEMY_ATTACK_DELAY,x          ; set enemy attack delay to #$08
    jsr get_soldier_num_bullets       ; get random number of bullets to fire (influenced by PLAYER_WEAPON_STRENGTH)
    sta ENEMY_VAR_3,x                 ; set number of bullets to fire
    jsr advance_enemy_routine         ; advance to soldier_routine_03
    jmp set_soldier_sprite_update_pos ; set soldier sprite and apply velocities to position

; soldier isn't firing
@continue_walk_routine:
    inc ENEMY_VAR_A,x ; increment ENEMY_FRAME update timer
    lda ENEMY_VAR_A,x ; load ENEMY_FRAME update timer
    and #$07          ; keep bits 0, 1, and 2
    bne @soldier_move ; continue if #$08 frames haven't elapsed
    inc ENEMY_FRAME,x ; increment enemy animation frame number
    lda ENEMY_FRAME,x ; load enemy animation frame number
    cmp #$06          ; compare to last frame of soldier animation sequence
    bcc @soldier_move ; continue if not past last frame
    lda #$00          ; animated past last frame, go back to #$0th frame
    sta ENEMY_FRAME,x ; set enemy animation frame number to first frame

@soldier_move:
    ldy #$10                                    ; increment y position by #$10
    lda ENEMY_X_VELOCITY_FAST,x                 ; load x fast velocity
    jsr add_a_y_to_enemy_pos_get_bg_collision   ; add a to X position and y to Y position; get bg collision code
    bmi soldier_apply_vel_check_solid_collision ; branch if enemy collided with solid bg object
    bcs soldier_apply_vel_check_solid_collision ; branch if collision with floor (#$01)
    lda ENEMY_VAR_4,x                           ; no collision, or collision with water
    cmp #$02                                    ; compare the number of times the soldier has already turned around
                                                ; if #$02, have soldier jump off ledge
    bcs @soldier_fall_off_ledge                 ; branch if soldier has decided to jump off ledge
    lda ENEMY_ATTRIBUTES,x                      ; load enemy attributes
    and #$02                                    ; see if soldier should turn around at edge
    beq @soldier_fall_off_ledge                 ; branch if soldier should walk off edge
    jsr soldier_change_direction                ; soldier should turn around, change direction
    jmp soldier_apply_vel_check_solid_collision ; apply velocity

@soldier_fall_off_ledge:
    inc ENEMY_VAR_3,x       ; set that the soldier is jumping
    jsr player_enemy_x_dist ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    lda SPRITE_Y_POS,y      ; load the y position of the closest player
    sec                     ; set carry flag in preparation for subtraction
    sbc ENEMY_Y_POS,x       ; subtract closest player y position from the enemy y position on screen
    ldy #$04                ; set default soldier_vel_index_tbl offset (higher probability of larger y jump)
    bcs @cmp_player_dist    ; branch if no underflow occurred
    eor #$ff                ; underflow occurred, flip all bits and add #$01 to get absolute value
    adc #$01
    ldy #$00                ; set soldier_vel_index_tbl (higher probability of larger x jump)

@cmp_player_dist:
    cmp #$10                  ; compare closest player and enemy y distance
    bcs @soldier_set_jump_vel ; branch if enemy is far away from player vertically to keep the configured y
    ldy #$00                  ; if enemy is close, give higher probability of shorter y jump

@soldier_set_jump_vel:
    sty $08                       ; store current soldier_vel_index_tbl offset into $08
    lda RANDOM_NUM                ; load random number
    and #$03                      ; random number between #$00 and #$03
    clc                           ; clear carry in preparation for addition
    adc $08                       ; add random number between #$00 and #$03 to current soldier_vel_index_tbl offset (#$00 or #$04)
    tay                           ; transfer offset to y
    lda soldier_vel_index_tbl,y   ; load appropriate jump velocity configuration
    tay                           ; transfer jump velocity configuration to y
    lda soldier_velocity_tbl,y    ; load jump y fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x  ; set jump y fractional velocity
    lda soldier_velocity_tbl+1,y  ; load jump y fast velocity
    sta ENEMY_Y_VELOCITY_FAST,x   ; se jump y fast velocity
    lda soldier_velocity_tbl+2,y  ; load jump x fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x  ; set jump x fractional velocity
    lda soldier_velocity_tbl+3,y  ; load jump x fast velocity
    sta ENEMY_X_VELOCITY_FAST,x   ; set jump x fast velocity
    lda ENEMY_VAR_2,x             ; load enemy running direction
    beq @set_sprite_update_pos    ; branch if running left
    jsr reverse_enemy_x_direction ; reverse enemy's x velocities if running right
                                  ; soldier_velocity_tbl had values assuming running left

@set_sprite_update_pos:
    jmp set_soldier_sprite_update_pos ; set soldier sprite and apply velocities to position

soldier_apply_vel_check_solid_collision:
    jsr check_enemy_collision_solid_bg ; see if soldier is colliding with solid object
    bpl @continue                      ; continue if solid collision code
    lda #$07                           ; no solid collision, go to soldier_routine_09, a = #$07
    jmp set_enemy_routine_to_a         ; set enemy routine index soldier_routine_09

@continue:
    lda ENEMY_VAR_4,x
    cmp #$02
    bcs set_soldier_sprite_update_pos ; set soldier sprite and apply velocities to position
    lda #$f8                          ; set amount to adjust x position to -8
    ldy ENEMY_VAR_2,x                 ; load current enemy direction (#$00 = left, #$01 = right)
    beq @check_collision_update_x_pos ; continue to add -8 to x position if current direction is left
    lda #$08                          ; direction is right, set x amount to add to #$08

; update soldier location, if on screen see if running into a solid object, if so, turn soldier around
; input
;  * a - amount to add to x position
@check_collision_update_x_pos:
    clc                               ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                 ; add to enemy x position on screen
    cmp #$f0                          ; see if off screen to the right
    bcs set_soldier_sprite_update_pos ; branch if far right to set soldier sprite and apply velocities to position
    cmp #$10                          ; see if off screen to the left
    bcc set_soldier_sprite_update_pos ; branch if far left to set soldier sprite and apply velocities to position
    ldy ENEMY_Y_POS,x                 ; on screen, load enemy y position on screen
    jsr get_bg_collision_far          ; determine player background collision code at position (a,y)
    bpl set_soldier_sprite_update_pos ; branch if solid collision to set soldier sprite and apply velocities to position
    jsr soldier_change_direction      ; solid collision, turn soldier around

set_soldier_sprite_update_pos:
    jsr set_soldier_sprite ; set soldier sprite code based on ENEMY_FRAME
    jmp update_enemy_pos   ; apply velocities and scrolling adjust

soldier_change_direction:
    inc ENEMY_VAR_4,x
    lda ENEMY_VAR_2,x          ; load current enemy x direction
    eor #$01                   ; swap offset to turn the soldier around (change soldier x direction)
                               ; #$00 -> #$01, or #$01 -> #$0
    sta ENEMY_VAR_2,x          ; update soldier direction
    jmp soldier_set_x_velocity ; set soldier x velocity based on ENEMY_VAR_2 index (#$00 left, #$01 right)

; randomly (based on PLAYER_WEAPON_STRENGTH) determine the number of bullets to fire and store in a
; output
;  * a - number of bullets to fire, #$00 or #$02
get_soldier_num_bullets:
    lda PLAYER_WEAPON_STRENGTH    ; load player weapon strength
    and #$02                      ; keep bit 1 (FSL)
    asl                           ; shift left
    sta $08                       ; store value in $08
    lda RANDOM_NUM                ; load random number
    and #$03                      ; between #$00 and #$03
    adc $08                       ; add value between #$00 and #$04
    tay                           ; transfer to y for offset
    lda soldier_num_bullets_tbl,y ; load ENEMY_VAR_3
    rts

; table for soldier running direction (#$8 bytes)
; PLAYER_WEAPON_STRENGTH increases chances of soldiers firing twice
soldier_num_bullets_tbl:
    .byte $01,$01,$02,$01,$02,$01,$02,$02

; running man possible jumping codes (#$8 bytes)
; offset into table at soldier_velocity_tbl below
; higher probability of
soldier_vel_index_tbl:
    .byte $00,$00,$04,$00,$04,$00,$04,$04

; table for running man jumping velocities (#$8 byte)
; grouped into 2 sections
; first #$04 bytes is a larger y jump, but a shorter x jump
; second #$04 bytes is a shorter y jump, but a farther x jump
soldier_velocity_tbl:
    .byte $00,$fe ; jumping y velocity
    .byte $48,$ff ; jumping x velocity
    .byte $00,$ff ; jumping y velocity
    .byte $60,$ff ; jumping x velocity

; running man - pointer 4 - try and fire bullet
soldier_routine_03:
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    and #$0c                    ; keep bits .... xx..
    cmp #$05                    ; see if should fire bullet
    ldy #$00                    ; set y = #$00 for standing bullet y pos offset index (soldier_bullet_y_offset offset)
    lda #$06                    ; ENEMY_FRAME #$06 (see soldier_sprite_codes) (sprite_40 - soldier shooting)
    bcc @continue               ; branch if soldier should shoot while standing
    lda #$1b                    ; ENEMY_ATTRIBUTES bit 3 is set, enemy crouches to shoot, set a = #$1b
    sta ENEMY_SCORE_COLLISION,x ; update collision code for crouching soldier (score byte (high byte) is already #$01)
    ldy #$02                    ; set y = #$02 for crouching bullet y pos offset index (soldier_bullet_y_offset offset)
    lda #$07                    ; ENEMY_FRAME #$07 (see soldier_sprite_codes) (sprite_26 - soldier crouching shooting)

@continue:
    sta ENEMY_FRAME,x                    ; set the enemy animation frame (either shooting while standing, or shooting while crouching)
    dec ENEMY_ATTACK_DELAY,x             ; decrement enemy attack delay
    bne set_soldier_sprite_add_scroll_01 ; attack delay hasn't elapsed, update sprite and exit
    dec ENEMY_VAR_3,x                    ; decrement number of bullets to fire
    bmi soldier_fired_all_bullets        ; branch if fired all bullets to reset and go to soldier_routine_02
    lda #$10                             ; another bullet to fire, a = #$10
    sta ENEMY_ATTACK_DELAY,x             ; set attack delay to #$10
    lda ENEMY_VAR_2,x                    ; load soldier running direction (#$00 left, #$01 right)
    beq @set_bullet_pos_and_fire         ; branch if running left
    iny                                  ; running right, increment soldier_bullet_y_offset offset

; determine where bullet should generate based on enemy pos and fire if on screen
@set_bullet_pos_and_fire:
    lda ENEMY_Y_POS,x                    ; load enemy y position on screen
    clc                                  ; clear carry in preparation for addition
    adc soldier_bullet_y_offset,y        ; add bullet y position offset to enemy position
    sta $08                              ; set bullet y position
    lda soldier_bullet_x_offset,y        ; load bullet x position offset
    clc
    bmi @negative_x_offset               ; branch if x position offset of bullet is negative
    adc ENEMY_X_POS,x                    ; bullet x position offset positive, add to enemy x position on screen
    bcs set_soldier_sprite_add_scroll_01 ; branch to update sprite and exit if soldier's bullet would be offscreen to the right
    bcc @soldier_fire_bullet

@negative_x_offset:
    adc ENEMY_X_POS,x                    ; add enemy x position on screen
    bcc set_soldier_sprite_add_scroll_01 ; branch to update sprite and exit if soldier's bullet would be offscreen
    cmp #$08
    bcc set_soldier_sprite_add_scroll_01 ; branch to update sprite and exit if soldier's bullet would be offscreen to the left

@soldier_fire_bullet:
    sta $09
    ldy ENEMY_VAR_2,x                    ; set y to walking direction (#$00 - left, #$01 - right)
    lda soldier_bullet_type_tbl,y        ; load bullet type
    ldy #$06                             ; y = #$06 (regular bullet firing left (angle #$0c)
    jsr bullet_generation                ; create enemy bullet (ENEMY_TYPE #$02) of type a (and angle) with speed y at ($09, $08)
    bne set_soldier_sprite_add_scroll_01 ; branch if unable to create bullet
    lda #$06                             ; a = #$06
    sta ENEMY_VAR_1,x                    ; set gun recoil timer

set_soldier_sprite_add_scroll_01:
    jsr set_soldier_sprite      ; set soldier sprite code based on ENEMY_FRAME
    jmp add_scroll_to_enemy_pos ; adjust enemy location based on scroll

; soldier has fired all bullets, stand back up if crouching,
; set enemy routine back soldier animation routine (soldier_routine_02)
soldier_fired_all_bullets:
    lda #$10                    ; a = #$10
    sta ENEMY_SCORE_COLLISION,x ; reset collision box in case soldier was crouched
    lda #$00                    ; a = #$00
    sta ENEMY_VAR_3,x           ; reset number of bullets to fire to #$00
    sta ENEMY_FRAME,x           ; reset enemy animation frame (see soldier_sprite_codes) (sprite_3b - soldier running frame #$00)
    jsr set_soldier_sprite      ; set soldier sprite code based on ENEMY_FRAME
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    lda #$03                    ; a = #$03
    jmp set_enemy_routine_to_a  ; set enemy routine index to soldier_routine_02

; table for specifying y offset from soldier position of generated bullets for soldier (#$4 bytes)
; first two bytes are while soldier is standing, second 2 bytes are for crouching and firing
; byte 0 - running left
; byte 1 - running right
soldier_bullet_y_offset:
    .byte $f7,$f7 ; -9, -9 - standing and firing
    .byte $0a,$0a ; 10, 10 - crouching and firing

; table for specifying x offset from soldier position of generated bullets for soldier (#$4 bytes)
; first two bytes are while soldier is standing, second 2 bytes are for crouching and firing
; byte 0 - running left
; byte 1 - running right
soldier_bullet_x_offset:
    .byte $f0,$10 ; -16, 10 standing and firing
    .byte $f0,$10 ; -16, 10 crouching and firing

; table for the bullet type and angle to generate for a soldier (#$2 bytes)
; byte 0 - soldier walking left (#$0c firing direction)
; byte 1 - soldier walking right
soldier_bullet_type_tbl:
    .byte $06,$00

; running man - pointer a
; soldier landing in water routine
soldier_routine_09:
    lda #$08                                ; ENEMY_FRAME #$08 (see soldier_sprite_codes) (sprite_73 - water splash)
    sta ENEMY_FRAME,x                       ; set enemy animation frame number to be a water splash, soldier is landing in water
    lda #$10                                ; a = #$10
    jsr soldier_set_y_pos_sprite_add_scroll ; add #$10 to solider y position to slightly lower his position in the water
    jsr set_soldier_sprite                  ; set soldier sprite code based on ENEMY_FRAME (water splash)
    jsr add_scroll_to_enemy_pos             ; add scrolling to enemy position
    lda #$08                                ; a = #$08
    jmp set_enemy_delay_adv_routine         ; set ENEMY_ANIMATION_DELAY and advance enemy routine to soldier_routine_0a

; running man - pointer b
; continue splash animation and begin removing soldier
soldier_routine_0a:
    dec ENEMY_ANIMATION_DELAY,x       ; decrement enemy animation frame delay counter
    bne set_soldier_sprite_add_scroll ; continue animation if should still show splash
    lda #$08                          ; splash animation complete, begin removing soldier
    sta ENEMY_ANIMATION_DELAY,x       ; set enemy animation frame delay counter to #$08
    inc ENEMY_FRAME,x                 ; increment enemy animation frame number to #$09 (see soldier_sprite_codes) (sprite_18 - water splash/puddle)
    lda ENEMY_FRAME,x                 ; load enemy animation frame number
    cmp #$0a                          ; compare ENEMY_FRAME to #$0a (water splash sprite)
    bcc @continue                     ; branch if haven't completed showing sprite_18
    jmp remove_enemy                  ; animation elapsed and sprite_18 has been shown, remove soldier (from bank 7)

@continue:
    lda #$08 ; add #$08 to enemy y position, a = #$08

soldier_set_y_pos_sprite_add_scroll:
    jsr add_a_to_enemy_y_pos ; add a to y position on screen

set_soldier_sprite_add_scroll:
    jsr set_soldier_sprite      ; set soldier sprite code based on ENEMY_FRAME
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position

; running man - pointer 5
; soldier hit, begin destroying soldier
soldier_routine_04:
    lda #$0b               ; a = #$0b
    sta ENEMY_FRAME,x      ; set enemy animation frame number
    jsr set_soldier_sprite ; set soldier sprite code based on ENEMY_FRAME

; set velocities for soldier being hit to
; -4.5 y velocity
;  6.0 x velocity
init_soldier_hit_vel:
    jsr disable_enemy_collision           ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$80                              ; a = #$80
    sta ENEMY_Y_VELOCITY_FRACT,x          ; initial y velocity when enemy fly up (low)
    lda #$fc                              ; a = #$fc
    sta ENEMY_Y_VELOCITY_FAST,x           ; initial y velocity when enemy fly up (high)
    lda #$60                              ; a = #$60
    sta ENEMY_X_VELOCITY_FRACT,x          ; initial x velocity when enemy fly up (low)
    lda #$00                              ; a = #$00
    sta ENEMY_X_VELOCITY_FAST,x           ; initial x velocity when enemy fly up (high)
    lda ENEMY_X_POS,x                     ; load enemy x position on screen
    cmp #$10                              ; compare enemy x position to left edge
    bcc @stop_x_vel_set_delay_adv_routine ; stop x velocity if on left edge
    cmp #$f0                              ; compare to right edge
    bcc @set_dir_delay_adv_routine        ; branch if not near right edge, otherwise, stop x velocity

@stop_x_vel_set_delay_adv_routine:
    jsr set_enemy_x_velocity_to_0 ; set x velocity to zero

@set_dir_delay_adv_routine:
    lda ENEMY_VAR_2,x             ; load soldier running direction
    beq @set_delay_adv_routine    ; branch if running left
    jsr reverse_enemy_x_direction ; reverse enemy's x direction to face left

@set_delay_adv_routine:
    jsr add_scroll_to_enemy_pos     ; add scrolling to enemy position
    lda #$10                        ; a = #$10
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; running man - pointer 6
; soldier hit, apply negative gravity
soldier_routine_05:
    jsr set_soldier_sprite ; set soldier sprite code based on ENEMY_FRAME

; applies gravity to destroyed soldier that is floating up
; removes enemy if off screen, or if animation timer has elapsed
apply_gravity_to_destroyed_soldier:
    lda #$30                       ; a = #$30 (gravity to slow enemy down as they are flying up)
    jsr add_a_to_enemy_y_fract_vel ; add #$30 to enemy y fractional velocity
    lda ENEMY_Y_POS,x              ; load enemy y position on screen
    cmp #$08                       ; compare to top of screen
    bcc @adv_enemy_routine         ; branch if soldier moved off top of screen, move to next routine
    jsr update_enemy_pos           ; apply velocities and scrolling adjust
    dec ENEMY_ANIMATION_DELAY,x    ; decrement enemy animation frame delay counter
    bne soldier_routine_05_exit    ; exit if animation timer hasn't elapsed

@adv_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; set soldier sprite code based on ENEMY_FRAME
set_soldier_sprite:
    ldy ENEMY_FRAME,x          ; enemy animation frame number
    lda soldier_sprite_codes,y ; load appropriate sprite code
    sta ENEMY_SPRITES,x        ; write enemy sprite code to CPU buffer
    lda #$40                   ; a = #$40 (running man facing right, flip sprite horizontally)
    ldy ENEMY_VAR_2,x          ; load running direction
    beq @set_sprite_attr       ; branch if running left
    lda #$00                   ; a = #$00 (running man facing right, don't flip sprite)

@set_sprite_attr:
    ldy ENEMY_VAR_1,x         ; load gun recoil timer
    beq @set_sprite_attr_exit ; exit if not firing weapon
    dec ENEMY_VAR_1,x         ; decrement gun recoil timer
    ora #$08                  ; set bits .... x... (gun recoil flag)

@set_sprite_attr_exit:
    sta ENEMY_SPRITE_ATTR,x ; set enemy sprite attributes

soldier_routine_05_exit:
    rts

; table for running man sprite codes (#$c bytes)
; sprite_18, sprite_26, sprite_27, sprite_28
; sprite_3b, sprite_3c, sprite_3d, sprite_3e
; sprite_3f, sprite_40, sprite_73
soldier_sprite_codes:
    .byte $3b,$3c,$3d,$3f,$3c,$3e,$40,$26,$73,$18,$28,$27

; pointer table for rifle man (#$9 * #$2 = #$12 bytes)
sniper_routine_ptr_tbl:
    .addr sniper_routine_00            ; CPU address $8958 - load variables (ENEMY_ANIMATION_DELAY, ENEMY_FRAME), adjust y pos for crouching sniper
    .addr sniper_routine_01            ; CPU address $8982 - cycle crouch animation (if crouching sniper), enable collision (when standing only for crouching snipers)
    .addr sniper_routine_02            ; CPU address $89d2 - attack
    .addr sniper_routine_03            ; CPU address $8ab3
    .addr sniper_routine_04            ; CPU address $8af1
    .addr sniper_routine_05            ; CPU address $8afc
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; rifle man - pointer 1
; load variables (ENEMY_ANIMATION_DELAY, ENEMY_FRAME), adjust y pos for crouching sniper
sniper_routine_00:
    ldy ENEMY_ATTRIBUTES,x           ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    lda sniper_animation_delay_tbl,y ; load animation delay based on sniper type
    sta ENEMY_ANIMATION_DELAY,x      ; set enemy animation frame delay counter
    lda sniper_frame_tbl,y           ; load ENEMY_FRAME (sniper_sprite_xx offset)
    sta ENEMY_FRAME,x                ; set enemy animation frame number
    jsr add_4_to_enemy_y_pos         ; adjust sniper slightly down
    lda ENEMY_ATTRIBUTES,x           ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    cmp #$01                         ; see if sniper type #$01 (crouching sniper)
    bne @adv_enemy_routine           ; advance routine if standing sniper, or boss screen sniper
    lda #$05                         ; crouching sniper adjust y position by #$05
    jsr add_a_to_enemy_y_pos         ; lower enemy y position on screen

@adv_enemy_routine:
    jmp advance_enemy_routine

; table for rifle man initial animation delay (#$3 bytes)
; each byte is for each sniper type #$00, #$01, or #$04
sniper_animation_delay_tbl:
    .byte $01,$30,$80

; table for rifle man sniper_routine_03 animation delay (#$3 bytes)
; each byte is for each sniper type #$00, #$01, or #$04
sniper_animation_delay_2_tbl:
    .byte $01,$60,$80

; table for rifle man initial ENEMY_FRAME (#$3 bytes)
; each byte is for each sniper type #$00, #$01, or #$04
; offsets into sniper_sprite_xx table
; byte 0 - sprite_43 or sprite_2c (sniper aiming horizontally)
; byte 1 and byte 2 - sprite_44 (sniper crouched behind bush)
sniper_frame_tbl:
    .byte $03,$00,$00

; rifle man - pointer 2
; cycle crouch animation (if crouching sniper), enable collision (when standing only for crouching snipers)
sniper_routine_01:
    jsr sniper_set_sprite             ; set sprite and attributes based on sniper type and firing angle
    jsr add_scroll_to_enemy_pos       ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x       ; decrement enemy animation frame delay counter
    bne sniper_routine_exit           ; exit if animation delay hasn't elapsed
    ldy ENEMY_ATTRIBUTES,x            ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    beq @enable_collision_adv_routine ; exit if sniper type #$00 (standing sniper), the following logic is only for crouching snipers
    lda #$08                          ; crouching or boss screen sniper, set a = #$08
    sta ENEMY_ANIMATION_DELAY,x       ; set delay between frames when un-hiding to #$08
    inc ENEMY_FRAME,x                 ; increment enemy animation frame number (sniper_sprite_xx offset)
    lda ENEMY_FRAME,x                 ; load current enemy animation frame number (sniper_sprite_xx offset)
    cmp #$03                          ; see if last sprite of animation
    bcc sniper_routine_exit           ; exit if animation cycle not yet complete
    cpy #$01                          ; see if ENEMY_FRAME is #$01 (sprite_45 - rifle man behind bush (frame 2))
    bne @continue                     ; branch if not finished crouch animation
    dec ENEMY_FRAME,x                 ; decrement enemy animation frame number
    bne @enable_collision_adv_routine

@continue:
    lda #$f2                 ; a = #$f2 (-14)
    jsr add_a_to_enemy_y_pos ; add #$f2 (-14) to enemy y position on screen
    lda #$01                 ; a = #$01
    jsr add_a_to_enemy_x_pos ; add #$01 to enemy x position on screen

@enable_collision_adv_routine:
    jsr enable_enemy_collision           ; enable bullet-enemy collision and player-enemy collision checks
    lda #$30                             ; a = #$30 (related to score and collision test)
    sta ENEMY_SCORE_COLLISION,x          ; set score code to #$03, collision code to #$00
    lda sniper_attack_delay_tbl,y        ; load attack delay
    sta ENEMY_ATTACK_DELAY,x             ; set delay between attacks based on sniper type
    lda sniper_bullet_attack_count_tbl,y ; load number of bullets for attack round
    sta ENEMY_VAR_4,x                    ; enemy bullet counter
    jmp advance_enemy_routine            ; advance to sniper_routine_02

sniper_routine_exit:
    rts

; table for rifle man (#$3 bytes)
; #$40 - delay before resuming attack - standing rifle man
; #$04 - delay before shooting after un-hiding (hiding rifle man)
; #$10 - delay before shooting after un-hiding (boss screen rifle man)
sniper_attack_delay_tbl:
    .byte $40,$04,$10

; table for rifle man, number of bullets per attack (#$3 bytes)
; #$03 - number of bullets to shoot per attack - standing rifle man
; #$01 - number of bullets to shoot per attack - hiding rifle man
; #$03 - number of bullets to shoot per attack - boss screen rifle man
sniper_bullet_attack_count_tbl:
    .byte $03,$01,$03

; rifle man - pointer 3
sniper_routine_02:
    jsr sniper_set_sprite               ; set sprite and attributes based on sniper type and firing angle
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    dec ENEMY_ATTACK_DELAY,x            ; decrement delay between attacks
    bne sniper_routine_exit             ; exit if attack delay hasn't elapsed
    dec ENEMY_VAR_4,x                   ; decrement enemy bullet counter
    bpl @continue_fire_bullet           ; if bullets left to fire, branch
    jmp @standing_set_attack_count_exit ; fired all bullets, jump

@continue_fire_bullet:
    lda #$18                 ; a = #$18
    sta ENEMY_ATTACK_DELAY,x ; set attack delay between bullets
    jsr player_enemy_x_dist  ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                  ; store closest player index in $0a
    lda SPRITE_X_POS,y       ; load the x position of the closest player
    cmp ENEMY_X_POS,x        ; enemy x position on screen
    lda #$00                 ; a = #$00
    bcc @check_bullet_angle  ; branch if closest player is left of the enemy
    lda #$01                 ; closest player to right of enemy, set a = #$01

@check_bullet_angle:
    sta ENEMY_VAR_2,x                 ; #$00 if player to left, #$01 if player to right of enemy
    lda ENEMY_ATTRIBUTES,x            ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    lsr
    bcc @adjust_bullet_angle_y_offset
    lda #$00                          ; a = #$00
    ldy ENEMY_VAR_2,x                 ; bullet angle
    bne @adjust_bullet_angle_with_a
    lda #$0c                          ; a = #$0c

@adjust_bullet_angle_with_a:
    sta $0c                  ; set bullet type (xxx. ....) and angle index (...x xxxx)
    jmp @adjust_bullet_angle

@adjust_bullet_angle_y_offset:
    ldy #$00                     ; y = #$00
    lda ENEMY_ATTRIBUTES,x       ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    cmp #$02                     ; compare to boss screen sniper
    bne @prep_create_bullet_vars ; branch if not boss screen sniper
    ldy #$f0                     ; set vertical offset from enemy position for crouching sniper (param for add_with_enemy_pos)

@prep_create_bullet_vars:
    lda #$00               ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos ; stores absolute screen x position in $09, and y position in $08
    jsr get_rotate_01      ; get enemy aim direction and rotation direction using quadrant_aim_dir_01

@adjust_bullet_angle:
    lda $0c       ; load bullet aim direction
    clc           ; clear carry in preparation for addition
    adc #$06      ; add one quadrant to the calculated direction
    cmp #$18      ; compare to maximum direction code (3 o'clock)
    bcc @continue
    sbc #$18      ; wrapped around, subtract max value
                  ; i.e. a = ($0c + #$06) % #$18

@continue:
    cmp #$0c       ; compare the midway aim direction (9 o'clock)
    bcc @continue2 ; branch if player is in quadrant I
    sta $08
    lda #$18       ; a = #$18
    sec            ; set carry flag in preparation for subtraction
    sbc $08

@continue2:
    ldy #$00                    ; y = #$00
    cmp #$05
    bcc @continue_create_bullet
    iny
    cmp #$08
    bcc @continue_create_bullet
    iny

@continue_create_bullet:
    lda ENEMY_ATTRIBUTES,x           ; load sniper type (#$00 = standing, #$01 = crouching, #$02 = boss screen crouching)
    cmp #$01                         ; compare to crouching sniper
    beq @get_pos_create_bullet       ; branch if crouching sniper
    lda sniper_standing_sprite_tbl,y ; standing sniper, or boss screen sniper, load sprite
    sta ENEMY_FRAME,x                ; set enemy animation frame number

@get_pos_create_bullet:
    lda ENEMY_Y_POS,x            ; load sniper y position
    clc                          ; clear carry in preparation for addition
    adc sniper_bullet_y_offset,y ; add bullet y offset
    sta $08                      ; store bullet creation y location
    lda ENEMY_VAR_2,x            ; load sniper firing angle
    lsr
    lda sniper_bullet_x_offset,y
    bcc @create_bullet
    eor #$ff                     ; negative offset, flip all bits and add #$01
    adc #$00

@create_bullet:
    clc                             ; clear carry in preparation for addition
    adc ENEMY_X_POS,x               ; add to enemy x position on screen
    sta $09                         ; store bullet creation x location
    ldy ENEMY_ATTRIBUTES,x          ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    lda sniper_bullet_speed,y       ; load bullet speed based on sniper type
    tay                             ; transfer bullet speed to y
    lda $0c                         ; load bullet type (xxx. ....) and angle index (...x xxxx)
                                    ; bullet type is going to be #$00
    jsr create_enemy_bullet_angle_a ; create a bullet with speed y, bullet type a, angle a at position ($09, $08)
    bne @exit
    lda #$06                        ; a = #$06
    sta ENEMY_VAR_3,x               ; sniper firing, set to #$03

@exit:
    rts

@standing_set_attack_count_exit:
    ldy ENEMY_ATTRIBUTES,x               ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    bne @set_frame_adv_routine           ; branch if sniper that crouches
    lda sniper_bullet_attack_count_tbl,y ; standing sniper, load bullet attack count
    sta ENEMY_VAR_4,x                    ; set enemy bullet counter
    lda #$80                             ; a = #$80
    sta ENEMY_ATTACK_DELAY,x             ; set delay between attacks (standing)
    rts

@set_frame_adv_routine:
    lda ENEMY_ATTRIBUTES,x           ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    lsr                              ; shift bit 0 to carry
    lda #$02                         ; a = #$02
    bcs @set_enemy_frame_adv_routine ; branch if sniper type #$01 (crouching) to set frame #$02 (sprite_46)
    lda #$03                         ; boss screen sniper, sprite_2c by setting ENEMY_FRAME to #$03

@set_enemy_frame_adv_routine:
    sta ENEMY_FRAME,x               ; set enemy animation frame number
    lda #$80                        ; a = #$80 (delay before re-hiding)
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; tile codes while shooting - standing rifle man
; $04 = shooting up
; $03 = shooting straight
; $05 = shooting down
sniper_standing_sprite_tbl:
    .byte $04,$03,$05

; initial y offset of bullets - standing rifle man
sniper_bullet_y_offset:
    .byte $ee,$f5,$06

; initial x offset of bullets - standing rifle man
sniper_bullet_x_offset:
    .byte $f3,$f1,$f1

; bullet speed code
; $03 = bullet speed code for standing rifle man
; $05 = bullet speed code for hiding rifle man
; $03 = bullet speed code for boss screen sniper
sniper_bullet_speed:
    .byte $03,$05,$03

; rifle man - pointer 4
sniper_routine_03:
    dec ENEMY_ANIMATION_DELAY,x
    bne @set_sprite_add_scroll_exit
    jsr disable_enemy_collision        ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$08                           ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x        ; delay between frames when hiding
    dec ENEMY_FRAME,x                  ; decrement enemy animation frame number
    bne @continue
    ldy ENEMY_ATTRIBUTES,x             ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    lda sniper_animation_delay_2_tbl,y
    sta ENEMY_ANIMATION_DELAY,x
    lda #$02                           ; a = #$02
    jsr set_enemy_routine_to_a         ; set enemy routine index to a

@continue:
    lda ENEMY_ATTRIBUTES,x          ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    cmp #$02
    bne @set_sprite_add_scroll_exit
    lda ENEMY_FRAME,x               ; load enemy animation frame number
    cmp #$02
    bne @set_sprite_add_scroll_exit
    lda #$0e                        ; a = #$0e
    jsr add_a_to_enemy_y_pos        ; add a to enemy y position on screen
    lda #$ff                        ; a = #$ff
    jsr add_a_to_enemy_x_pos        ; add #$ff to enemy x position on screen

@set_sprite_add_scroll_exit:
    jsr sniper_set_sprite       ; set sprite and attributes based on sniper type and firing angle
    jmp add_scroll_to_enemy_pos ; adjust enemy location based on scroll

; rifle man - pointer 5
sniper_routine_04:
    lda #$06                 ; a = #$06
    sta ENEMY_FRAME,x        ; set enemy animation frame number
    jsr sniper_set_sprite    ; set sprite and attributes based on sniper type and firing angle
    jmp init_soldier_hit_vel ; set the velocities for sniper to start floating after hit

; rifle man - pointer 6
sniper_routine_05:
    jsr sniper_set_sprite                  ; set sprite and attributes based on sniper type and firing angle
    jmp apply_gravity_to_destroyed_soldier ; apply gravity to destroyed sniper that is floating up
                                           ; removes enemy if off screen, or if animation timer has elapsed

; set sniper sprite and sprite attributes based on sniper type and firing angle
sniper_set_sprite:
    ldy #$00               ; default to use sniper_sprite_00
    lda ENEMY_ATTRIBUTES,x ; load sniper type (#$00 = standing, #$01 = hiding, #$02 = boss hiding)
    cmp #$02               ; see if sniper type #$02 (boss screen sniper)
    bcc @continue          ; branch if not boss screen sniper
    ldy #$02               ; boss screen sniper, use sniper_sprite_01

@continue:
    lda sniper_sprite_ptr_tbl,y   ; load low byte
    sta $08                       ; set low byte
    lda sniper_sprite_ptr_tbl+1,y ; load high byte
    sta $09                       ; set high byte
    ldy ENEMY_FRAME,x             ; load current ENEMY_FRAME index
    lda ($08),y                   ; load specific sprite code from sniper_sprite_xx
    sta ENEMY_SPRITES,x           ; set enemy sprite code to CPU buffer
    lda ENEMY_VAR_2,x             ; load sniper firing angle
    lsr                           ; shift right
    lda #$40                      ; a = #$40
    bcc @continue2                ; branch if bullet bit 0 was clear
    lda #$00                      ; a = #$00

@continue2:
    ldy ENEMY_VAR_3,x
    beq @set_sprite_attr_exit
    dec ENEMY_VAR_3,x
    ora #$08                  ; set bits .... x... (gun recoil flag)

@set_sprite_attr_exit:
    sta ENEMY_SPRITE_ATTR,x ; set enemy sprite attributes
    rts

; pointer table for rifle man sprite codes (#$2 * #$2 = #$4 bytes)
sniper_sprite_ptr_tbl:
    .addr sniper_sprite_00 ; CPU address $8b3b - regular/hiding rifle man (sniper type #$00 and type #$01)
    .addr sniper_sprite_01 ; CPU address $8b42 - boss screen sniper (sniper type #$04)

; regular/hiding rifle man sprite codes (#$7 bytes)
; sprite_29, sprite_41 sprite_42, sprite_43, sprite_44, sprite_45, sprite_46
sniper_sprite_00:
    .byte $44,$45,$46,$43,$42,$41,$29

; boss screen sniper sprite codes (#$7 bytes)
; sprite_29, sprite_2c, sprite_2d, sprite_42, sprite_44, sprite_45, sprite_46
sniper_sprite_01:
    .byte $44,$45,$46,$2c,$42,$2d,$29

; pointer table for level 1 bomb turret (#$6 * #$2 = c bytes)
; the two turrets on the jungle level boss wall
bomb_turret_routine_ptr_tbl:
    .addr boss_bomb_turret_routine_00  ; CPU address $8b55
    .addr boss_bomb_turret_routine_01  ; CPU address $8b5c
    .addr boss_bomb_turret_routine_02  ; CPU address $8bbf
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; bomb turret - pointer 1
; set attack delay and move to routine_01
boss_bomb_turret_routine_00:
    lda #$20                             ; a = #$20
    sta ENEMY_ATTACK_DELAY,x             ; set attack delay to 20 frames
    bne boss_bomb_turret_advance_routine ; set to go to next routine boss_bomb_turret_routine_01

; bomb turret - pointer 2
; firing animation and bullet generation
; ENEMY_VAR_1 is the enemy super-tile index to draw (level_1_nametable_update_supertile_data)
boss_bomb_turret_routine_01:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    dec ENEMY_ATTACK_DELAY,x    ; decrement delay between attacks
    bne level_1_boss_exit       ; exit if delay timer hasn't elapsed
                                ; either #$08 frames between firing animation, or #$28 frames between bullets
    jsr draw_boss_bomb_turret   ; draws the bomb turret based on the current recoil (ENEMY_VAR_1)
    bcs level_1_boss_exit
    lda #$28                    ; set bomb firing delay to #28 frames
    ldy ENEMY_VAR_1,x           ; load current super-tile index (alternates between #$00 and #$02)
    beq @continue               ; branch if #$00 (not firing)
    lda #$08                    ; firing a bomb, set delay to #$08 (number of frames between recoil animation)

@continue:
    sta ENEMY_ATTACK_DELAY,x                 ; store delay between bombs (either #$28 or #$08)
    tya                                      ; move ENEMY_VAR_1 to a
    eor #$02                                 ; toggle between #$00 and #$02 (which super-tile to draw)
    sta ENEMY_VAR_1,x                        ; store updated super-tile index back in ENEMY_VAR_1
    beq level_1_boss_exit                    ; if not firing a bomb, exit
    lda #$f8                                 ; set bomb horizontal offset from enemy position (param for add_with_enemy_pos)
    ldy #$00                                 ; set bomb vertical offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos                   ; stores absolute screen x position in $09, and y position in $08
    lda RANDOM_NUM                           ; load random number
    and #$03                                 ; random number between 0 and 3
    tay
    lda boss_bomb_turret_bomb_velocity_tbl,y ; select the random initial velocity
    tay
    lda #$17                                 ; a = #$17 - bullet type (#$00) and angle (#$17)
    jmp bullet_generation                    ; create enemy bullet (ENEMY_TYPE #$02) of type a with speed y at ($09, $08)

; table for bombs initial x velocities (#$4 bytes)
boss_bomb_turret_bomb_velocity_tbl:
    .byte $01,$03,$05,$07

draw_boss_bomb_turret:
    ldy ENEMY_VAR_1,x ; load current super-tile index for enemy

; uses value y to load correct super-tile
draw_boss_bomb_turret_y:
    lda ENEMY_ATTRIBUTES,x   ; load enemy attributes
    lsr
    bcc @continue            ; branch if ENEMY_ATTRIBUTES bit 0 is 0 (wall background)
    iny                      ; increment boss_bomb_turret_supertile_tbl offset by 1 to get jungle bg super-tile
    lda #$f8                 ; move jungle bg bomb turret enemy to the left 8 pixels
                             ; the jungle turret super-tile has some background, which isn't part of the enemy position
                             ; so subtract #$08, draw super-tile at position, then add #$08 back
    jsr add_a_to_enemy_x_pos ; subtract 8 from the enemy position (drawn super-tile is 8 to the left of enemy position)

@continue:
    lda boss_bomb_turret_supertile_tbl,y ; load the correct super-tile to draw for the bomb turret (3-frame)
    jsr draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position
    php                                  ; save status flags on stack
    lda ENEMY_ATTRIBUTES,x               ; load enemy attributes
    beq @exit                            ; exit if wall background
    iny
    lda #$08                             ; move jungle bg bomb turret enemy to the right 8 pixels
    jsr add_a_to_enemy_x_pos             ; add #$08 back to enemy x position on screen

@exit:
    plp ; restore pushed status flags from above

level_1_boss_exit:
    rts

; table for bomb turrets super-tile codes (#$6 bytes)
; offsets into level_1_nametable_update_supertile_data
; $29, $2a, $2b - wall bg bomb turret super-tiles
; $26, $27, $28 - jungle bg bomb turret super-tiles
boss_bomb_turret_supertile_tbl:
    .byte $29,$26,$2a,$27,$2b,$28

; bomb turret - pointer 3
; updates super-tile to show boss bomb turret destroy and move to next routine
; this routine is started when enemy is destroyed (enemy_destroyed_routine_ptr_tbl)
boss_bomb_turret_routine_02:
    ldy #$04                    ; load the super-tile for the turret being destroyed
    jsr draw_boss_bomb_turret_y ; draw super-tile from boss_bomb_turret_supertile_tbl ($2b or $28 depending on bg)
    bcs level_1_boss_exit       ; exit

boss_bomb_turret_advance_routine:
    jmp advance_enemy_routine ; advance to next routine

; pointer table for door plate with siren (#$7 * #$2 = #$e bytes)
; level 1 boss defense wall boss target
boss_wall_plated_door_routine_ptr_tbl:
    .addr boss_wall_plated_door_routine_00  ; CPU address $8bd7
    .addr add_scroll_to_enemy_pos           ; CPU address $e8a7 from bank 7 - add scrolling to enemy position
    .addr boss_defeated_routine             ; CPU address $e740 from bank 7
    .addr enemy_routine_explosion           ; CPU address $e7b0 from bank 7
    .addr shared_enemy_routine_clear_sprite ; CPU address $e814 from bank 7 - set tile sprite code to #$00 and advance routine
    .addr boss_wall_plated_door_routine_05  ; CPU address $8bdf
    .addr boss_wall_plated_door_routine_06  ; CPU address $8be9

; plays a siren sound and advance enemy routine
boss_wall_plated_door_routine_00:
    lda #$1b                  ; a = #$1b (sound_1b)
    jsr play_sound            ; play level 1 jungle boss siren sound
    jmp advance_enemy_routine ; advance to next routine

; door plate - pointer 6
boss_wall_plated_door_routine_05:
    lda #$00                        ; a = #$00
    sta ENEMY_VAR_1,x
    lda #$08                        ; a = #$08
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; door plate - pointer 7
boss_wall_plated_door_routine_06:
    dec ENEMY_ANIMATION_DELAY,x
    bne @create_tunnel_explosion              ; create tunnel explosion to go to next level if delay has elapsed
    lda #$08                                  ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x
    ldy ENEMY_VAR_1,x                         ; load current tunnel explosion index
    lda wall_plated_door_supertile_tbl,y      ; load the correct supertile for the tunnel
    jsr draw_enemy_supertile_a_set_delay      ; draw tunnel supertile specified in a at enemy position
    bcs level_1_boss_exit                     ; exit if unable to draw supertile
    ldy ENEMY_VAR_1,x                         ; load current tunnel explosion index
    lda wall_plated_door_collision_code_tbl,y ; load correct collision code for tunnel super-tile component
    jsr set_supertile_bg_collision            ; update bg collision codes to collision code a for a single super-tile at PPU address $12 (low) $13 (high)
    jsr set_08_09_to_enemy_pos                ; set $08 and $09 to enemy x's X and Y position
    inc ENEMY_VAR_1,x                         ; increment current tunnel index
    jmp create_enemy_for_explosion            ; create explosion

; creates tunnel to go to next level if delay has elapsed
@create_tunnel_explosion:
    lda ENEMY_ANIMATION_DELAY,x
    cmp #$01                                      ; see if explosion delay on wall plated door is completed
    bne level_1_boss_exit                         ; exit if delay hasn't elapsed
    lda ENEMY_VAR_1,x                             ; current tunnel creation index
    asl                                           ; double entry since each entry is two bytes
    tay                                           ; transfer offset to y
    lda wall_plated_door_explosion_offset_tbl,y   ; load current tunnel index
    cmp #$ff                                      ; see if end of tunnel explosions
    beq @set_delay_remove_enemy                   ; set delay to #$30 and remove enemy if all explosions have been shown
    jsr add_a_to_enemy_y_pos                      ; add offset to plated door location y position
    lda wall_plated_door_explosion_offset_tbl+1,y
    jmp add_a_to_enemy_x_pos                      ; add a to enemy x position on screen

@set_delay_remove_enemy:
    lda #$30                   ; a = #$30
    jmp set_delay_remove_enemy

; table for destroyed plated door tunnel explosions offsets (#$11 bytes)
; byte 0 - y offset
; byte 1 - x offset
wall_plated_door_explosion_offset_tbl:
    .byte $f0,$f0 ; -10, -10
    .byte $20,$00 ;  20, 00
    .byte $e0,$20 ; -20, 20
    .byte $20,$00 ;  20, 00
    .byte $e0,$20 ; -20, 20
    .byte $20,$00 ;  20, 00
    .byte $e0,$20 ; -20, 20
    .byte $20,$00 ;  20, 00
    .byte $ff

; table for boss wall plated door tunnel super-tiles (#$8 bytes)
wall_plated_door_supertile_tbl:
    .byte $1e,$22,$1f,$23,$20,$24,$21,$25

; table for wall plated door tunnel collision codes (#$8 bytes)
wall_plated_door_collision_code_tbl:
    .byte $00,$00,$00,$04,$00,$04,$00,$04

; pointer table for exploding bridge (#$5 * #$2 = #$a bytes)
exploding_bridge_routine_ptr_tbl:
    .addr exploding_bridge_routine_00  ; CPU address $8c5c
    .addr exploding_bridge_routine_01  ; CPU address $8c73
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr exploding_bridge_routine_04  ; CPU address $8cf0

; waits until player is close to bridge, then advance to next routine
exploding_bridge_routine_00:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    jsr player_enemy_x_dist     ; a = closest x distance to bridge from players, y = closest player (#$00 or #$01)
    cmp #$18                    ; see if the player is within #$18 x distance from the bridge
    bcs exploding_bridge_exit   ; player(s) aren't close enough, simply exit
    lda #$01                    ; a = #$01

; sets delay to a, clears ENEMY_VAR_2 and advances to next routine
exploding_bridge_advance_routine:
    sta ENEMY_ANIMATION_DELAY,x ; set delay to #$01 frame
    lda #$00                    ; a = #$00
    sta ENEMY_VAR_2,x           ; clear cloud explosion animation number

advance_enemy_routine_far:
    jmp advance_enemy_routine

exploding_bridge_routine_01:
    jsr add_scroll_to_enemy_pos                    ; adjust enemy location based on scroll
    dec ENEMY_ANIMATION_DELAY,x                    ; decrement animation delay between explosions
    bne exploding_bridge_exit                      ; current animation not complete, exit
    lda ENEMY_VAR_1,x                              ; load currently exploding bridge section
    asl                                            ; each bridge section has 2 super-tiles to animate through
    sta $08                                        ; store into $08
    lda ENEMY_VAR_2,x                              ; load the sprite cloud explosion number
    cmp #$02                                       ; see if last small explosion before generic explosion animation
    bcs bridge_explosion_clouds                    ; only 2 super-tile animations per bridge section, skip updating nametable if already done
    clc                                            ; clear carry in preparation for addition
    adc $08                                        ; (2 * ENEMY_VAR_1,x) + ENEMY_VAR_2
                                                   ; ENEMY_VAR_2 is only ever #$00 or #$01 here due to cmp above
    tay                                            ; set as offset, y can be #$00 to #$07, which overflows into exploding_bridge_cloud_y_offset by 1 entry
    lda exploding_bridge_destroyed_supertile_tbl,y ; load super-tile code
    beq bridge_explosion_clouds                    ; if loaded #$00, then no nametable update, draw explosion cloud sprites
    sta $10                                        ; store super-tile code in $10 to update nametable
    lda ENEMY_Y_POS,x                              ; load the bridge X position
    clc                                            ; clear carry in preparation for addition
    adc #$f4                                       ; bridge Y position minus #$c
    tay                                            ; store value in Y, this is the super-tile draw y position
    lda ENEMY_VAR_2,x                              ; load the sprite cloud explosion number
    lsr                                            ; move bit 0 into carry
    lda ENEMY_X_POS,x                              ; load the bridge X position
    bcs @draw_exploding_bridge_supertile           ; if ENEMY_VAR_2 is #$00, updating current bridge section
    adc #$e0                                       ; updating previous bridge section, subtract #$20 (one super-tile width)

; executed twice per bridge section (except last bridge section, only executes once)
; updates nametable super-tile for current bridge section on first frame of explosion animation
; on next call, updates previous bridge section to second animation super-tile
@draw_exploding_bridge_supertile:
    clc                                          ; clear carry in preparation for addition
    adc #$f4                                     ; subtract #$c from x position
    jsr load_bank_3_update_nametable_supertile   ; draw super-tile $10 at position (a,y)
    ldx ENEMY_CURRENT_SLOT
    bcc clear_supertile_bg_collision_draw_clouds
    lda #$01                                     ; a = #$01
    sta ENEMY_ANIMATION_DELAY,x                  ; set enemy animation frame delay counter

exploding_bridge_exit:
    rts

; exploding bridge - clear the background collision code so that a player falls through
; continue through to bridge_explosion_clouds logic
clear_supertile_bg_collision_draw_clouds:
    jsr clear_supertile_bg_collision ; set background collision code to #$00 (empty) for a single super-tile at PPU address $12 (low) $13 (high)

; show cloud explosion and play sound
bridge_explosion_clouds:
    inc ENEMY_VAR_2,x                     ; increment explosion cloud number
    lda ENEMY_VAR_2,x                     ; a = explosion cloud number
    cmp #$04                              ; number of explosion clouds per segment
    bcs advance_enemy_routine_far         ; >= 4 explosions have happened, move to next routine
    lda #$24                              ; a = #$24 (sound_24)
    jsr play_sound                        ; play explosion sound
    lda #$04                              ; a = #$04 (delay between explosions and clouds)
    sta ENEMY_ANIMATION_DELAY,x           ; set a #$4 frame delay between explosions
    ldy ENEMY_VAR_2,x                     ; a = explosion cloud number
    lda exploding_bridge_cloud_x_offset,y ; load explosion x offset
    sta $08                               ; store x offset in $08
    lda exploding_bridge_cloud_y_offset,y ; load explosion y offset (#$01 to #$03)
    tay                                   ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda $08                               ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos                ; stores absolute screen x position in $09, and y position in $08
    jmp create_enemy_for_explosion        ; create new enemy for explosion animation (enemy_routine_init_explosion)

; table for tile codes after destruction (#$7 bytes), see level_1_nametable_update_supertile_data
; for first animation of left-most section of bridge, #$00 indicates no super-tile is changed
; #$19 - blank super-tile, used for destroyed bridges
; #$1a - exploding bridge partially destroyed both ends still exist
; #$1b - exploding bridge partially destroyed left only
; #$1c - exploding bridge partially destroyed right only
; #$1d - exploding bridge partially destroyed right only (more destroyed)
exploding_bridge_destroyed_supertile_tbl:
    .byte $00
    .byte $1a,$1b ; first bridge section
    .byte $1c,$19 ; second bridge section
    .byte $1c,$19 ; third bridge section

; table for clouds y offsets (#$4 bytes)
; #$1d is actually used when referencing exploding_bridge_destroyed_supertile_tbl
; #$00 = 0
; #$f0 = -16
exploding_bridge_cloud_y_offset:
    .byte $1d,$00,$f0,$00

; table for clouds x offsets (#$5 bytes)
; #$f0 = -16
; #$00 = 0
; #$10 = 20
exploding_bridge_cloud_x_offset:
    .byte $10,$f0,$00,$10,$00

; initializes next section of bridge for exploding
; then sets ENEMY_ROUTINE #$02 (exploding_bridge_routine_01) to initiate next explosion
; if all bridge sections have exploded, then remove enemy
exploding_bridge_routine_04:
    jsr add_scroll_to_enemy_pos          ; adjust enemy location based on scroll
    inc ENEMY_VAR_1,x                    ; increment currently exploding bridge section (#$00 - #$03)
    lda ENEMY_VAR_1,x                    ; load currently exploding bridge section
    cmp #$04                             ; number of explosions
    bcs @remove_enemy                    ; remove bridge if all sections have exploded
    lda ENEMY_X_POS,x                    ; load enemy x position on screen
    adc #$20                             ; adjust position to next bridge section (move over to the next super-tile)
    bcs @remove_enemy                    ; unnecessary, already checked if last section earlier, this branch shouldn't ever happen
    sta ENEMY_X_POS,x                    ; set enemy x position on screen
    lda #$01                             ; a = #$01
    sta ENEMY_SPRITES,x                  ; remove last cloud explosion sprite from previous bridge section (sprite_01 is invisible sprite)
    lda #$01                             ; a = #$01
    jsr exploding_bridge_advance_routine ; set delay to #$01, clear ENEMY_VAR_2 (advance to next routine is overwritten below)
    lda #$02                             ; initialize a to desired enemy routine to initiate next explosion
    jmp set_enemy_routine_to_a           ; set enemy routine to exploding_bridge_routine_01 to begin next bridge element explosion

@remove_enemy:
    jmp remove_enemy ; remove enemy

; pointer table for green guys generator (#$3 * #$2 = #$6 bytes)
; generates soldier enemies: running, jumping, grenade launcher, and group of 4
indoor_soldier_gen_routine_ptr_tbl:
    .addr indoor_soldier_gen_routine_00 ; CPU address $8d1f
    .addr indoor_soldier_gen_routine_01 ; CPU address $8d28
    .addr remove_enemy                  ; CPU address $e809 from bank 7

indoor_soldier_gen_routine_00:
    lda #$40                    ; a = #$40
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter to #$40
    jmp advance_enemy_routine

indoor_soldier_gen_exit:
    rts

; generates indoor soldier enemies: running, jumping, grenade launcher, and group of 4
; delay between enemy generation is specified in byte 3 of lvl_x_enemy_gen_screen_xx
indoor_soldier_gen_routine_01:
    lda FRAME_COUNTER             ; load frame counter
    lsr
    bcc indoor_soldier_gen_exit   ; if FRAME_COUNTER is even, return
    lda GRENADE_LAUNCHER_FLAG     ; see if a grenade launcher enemy (ENEMY_TYPE #$15) is on the screen
    bne indoor_soldier_gen_exit   ; if GRENADE_LAUNCHER_FLAG exists on screen, exit
    dec ENEMY_ANIMATION_DELAY,x   ; decrement enemy animation frame delay counter
    bne indoor_soldier_gen_exit   ; exit if the animation delay hasn't elapsed
    lda ENEMY_ATTRIBUTES,x        ; load the soldier attributes (byte 2 of level_x_enemy_screen_xx for enemy)
    asl                           ; disregard bit 7 and double bit 0, which is used as offset indoor_enemy_gen_tbl
    tay                           ; transfer
    lda indoor_enemy_gen_tbl,y    ; pointer to table entry, low byte
    sta $0a                       ; load lvl_x_enemy_gen_tbl low byte
    lda indoor_enemy_gen_tbl+1,y  ; pointer to table entry, high byte
    sta $0b                       ; load lvl_x_enemy_gen_tbl high byte
    lda LEVEL_SCREEN_NUMBER       ; load current screen number within the level
    asl                           ; double screen number since each entry is a 2 byte address
    tay                           ; transfer offset lvl_x_enemy_gen_tbl offset to y
    lda ($0a),y                   ; load the low byte of the lvl_x_enemy_gen_tbl address
    sta $08                       ; store in $08
    iny                           ; increment indoor_enemy_gen_tbl read offset
    lda ($0a),y                   ; load the high byte of the lvl_x_enemy_gen_tbl address
    sta $09                       ; store in $09
    ldy ENEMY_VAR_1,x             ; load current screen's enemy offset
    lda ($08),y                   ; read the first byte
    and #$3f                      ; keep bits 0 to 5 (ENEMY_ATTRIBUTES)
    sta $0a                       ; store ENEMY_ATTRIBUTES
    lda ($08),y                   ; re-read the first byte
    rol                           ; look at bits 6 and 7 to see enemy type
    rol                           ; (0 = indoor soldier, 1 = jumping soldier, 2 = group of four, 3 = grenade launcher)
    rol                           ; rotate until top 2 bits are bits 0 and bit 1
    and #$03                      ; keep bits .... ..xx (enemy type)
    sta $0b                       ; set current enemy type (#$00-#$03)
                                  ; #$00 - running guy, #$01 - jumping guy, #$02 - group of 4, #$03 - grenade launcher
    iny                           ; increment lvl_x_enemy_gen_screen_xx read offset
    lda ($08),y                   ; read next byte (delay byte)
    iny                           ; increment lvl_x_enemy_gen_screen_xx read offset
    asl                           ; shift bit 7 to the carry flag
    bcc @create_enemy             ; if bit 7 = 0, don't increment INDOOR_ENEMY_ATTACK_COUNT
    ldy #$00                      ; y = #$00
    pha                           ; push a on to the stack
    inc INDOOR_ENEMY_ATTACK_COUNT ; increment the total number of enemy attack rounds
    lda INDOOR_ENEMY_ATTACK_COUNT ; load the total number of enemy attack rounds for the screen
    cmp #$07                      ; guys stop after 7 cycles
    pla                           ; pop a from stack
    bcc @create_enemy             ; continue to create an enemy if not all #$07 rounds of attack have occurred
    jmp remove_enemy              ; remove enemy generator if all 7 rounds of attack have happened

@create_enemy:
    lsr                         ; shift byte 2 back (with the former bit 7 now 0)
                                ; this is the animation delay for the enemy to generate
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    tya                         ; transfer lvl_x_enemy_gen_screen_xx read offset to a
    sta ENEMY_VAR_1,x           ; store updated lvl_x_enemy_gen_screen_xx read offset in ENEMY_VAR_1
    ldy $0b                     ; load enemy type (#$00 - #$03)
    beq @create_running_guy     ; if enemy type is #$00 create indoor soldier
    dey                         ; decrement enemy type
    beq @create_jumping_guy     ; if enemy type was #$01 create jumping soldier
    dey                         ; decrement enemy type
    beq @create_group_of_4      ; if enemy type was #$02 create group of 4 soldiers
    lda #$17                    ; a = #$17 grenade launcher
    bne @create_enemy_a         ; enemy type was #$03, create grenade launcher

@create_running_guy:
    lda #$15            ; a = #$15 running guy
    bne @create_enemy_a

@create_jumping_guy:
    lda #$16 ; a = #$16 jumping guy

; creates indoor soldier, jumping soldier, and seeking guy (grenade launcher) based on ENEMY_TYPE value in a
@create_enemy_a:
    sta $08                             ; store ENEMY_TYPE in $08
    jsr find_next_enemy_slot            ; find next available enemy slot, put result in x register
    bne indoor_soldier_gen_routine_exit ; exit if not empty enemy slots
    lda $08                             ; load ENEMY_TYPE to create
    sta ENEMY_TYPE,x                    ; save in ENEMY_TYPE
    jsr initialize_enemy                ; initialize enemy variables
    lda $0a                             ; load enemy attributes from lvl_x_enemy_gen_screen_xx
    sta ENEMY_ATTRIBUTES,x              ; store in ENEMY_ATTRIBUTES
    jmp indoor_soldier_gen_routine_exit ; done creating enemy, exit

; group of 4 running guys
@create_group_of_4:
    lda #$03 ; a = #$03
    sta $0c  ; loop counter, create #$04 green soldiers

; create 4 green guys
@green_guy_creation_loop:
    jsr find_next_enemy_slot            ; find next available enemy slot, put result in x register
    bne indoor_soldier_gen_routine_exit ; exit if unable find an empty slog
    lda #$18                            ; a = #$18 (group of 4 running guys)
    sta ENEMY_TYPE,x                    ; set enemy to type 18
    jsr initialize_enemy                ; initialize enemy variables
    lda $0a                             ; load enemy attributes from lvl_x_enemy_gen_screen_xx
    sta ENEMY_ATTRIBUTES,x              ; store in ENEMY_ATTRIBUTES
    lda $0c                             ; load remaining number of green soldiers (enemy type #$18) to create
    sta ENEMY_VAR_1,x                   ; store in ENEMY_VAR_1, this is used to label each individual soldier [#$00-#$03]
    dec $0c                             ; decrement remaining number of green soldiers (enemy type #$18) to create
    bpl @green_guy_creation_loop        ; loop if haven't yet created #$04 soldiers

indoor_soldier_gen_routine_exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; pointer table for level 2/4 enemy cycles pointers (#$2 * #$2 = #$4 bytes)
indoor_enemy_gen_tbl:
    .addr lvl_2_enemy_gen_tbl ; CPU address $8dd3
    .addr lvl_4_enemy_gen_tbl ; CPU address $8e09

; pointer table for level 2 enemy cycles (#$5 * #$2 = #$e)
lvl_2_enemy_gen_tbl:
    .addr lvl_2_enemy_gen_screen_00 ; CPU address $8ddd
    .addr lvl_2_enemy_gen_screen_01 ; CPU address $8de3
    .addr lvl_2_enemy_gen_screen_02 ; CPU address $8def
    .addr lvl_2_enemy_gen_screen_03 ; CPU address $8df3
    .addr lvl_2_enemy_gen_screen_04 ; CPU address $8df9

; byte 0
; - xx.. .... type (0 = indoor soldier, 1 = jumping soldier, 2 = group of four, 3 = grenade launcher)
; - ..xx xxxx enemy attributes, different per enemy type
; byte 1
;  * bit 7 = 0, don't increment INDOOR_ENEMY_ATTACK_COUNT
;  * bits 0-6 = delay
lvl_2_enemy_gen_screen_00:
    .byte $42,$30 ; jumping soldier, regular bullet, from right
    .byte $01,$01 ; indoor soldier, regular bullet, from left
    .byte $00,$c0 ; indoor soldier, regular bullet, from right

lvl_2_enemy_gen_screen_01:
    .byte $46,$30 ; jumping soldier
    .byte $81,$50 ; group of 4
    .byte $01,$10 ; indoor soldier
    .byte $00,$30 ; indoor soldier
    .byte $00,$10 ; indoor soldier
    .byte $01,$e0 ; indoor soldier

lvl_2_enemy_gen_screen_02:
    .byte $00,$30 ; indoor soldier
    .byte $c5,$a0 ; grenade launcher

lvl_2_enemy_gen_screen_03:
    .byte $46,$20 ; jumping soldier
    .byte $81,$60 ; group of 4
    .byte $c3,$e1 ; grenade launcher

lvl_2_enemy_gen_screen_04:
    .byte $40,$30 ; jumping soldier
    .byte $81,$60 ; group of 4
    .byte $00,$10 ; indoor soldier
    .byte $03,$30 ; indoor soldier
    .byte $02,$10 ; indoor soldier
    .byte $01,$40 ; indoor soldier
    .byte $47,$10 ; jumping soldier
    .byte $4a,$e0 ; jumping soldier

; pointer table for level 4 enemy cycles (#$8 * #$2 = #$10 bytes)
lvl_4_enemy_gen_tbl:
    .addr lvl_4_enemy_gen_screen_00 ; CPU address $8e19
    .addr lvl_4_enemy_gen_screen_01 ; CPU address $8e25
    .addr lvl_4_enemy_gen_screen_02 ; CPU address $8e33
    .addr lvl_4_enemy_gen_screen_03 ; CPU address $8e3b
    .addr lvl_4_enemy_gen_screen_04 ; CPU address $8e43
    .addr lvl_4_enemy_gen_screen_05 ; CPU address $8e49
    .addr lvl_4_enemy_gen_screen_06 ; CPU address $8e51
    .addr lvl_4_enemy_gen_screen_07 ; CPU address $8e5d

; (#$c bytes)
lvl_4_enemy_gen_screen_00:
    .byte $04,$30 ; indoor soldier
    .byte $05,$60 ; indoor soldier
    .byte $41,$60 ; jumping soldier
    .byte $02,$30 ; indoor soldier
    .byte $03,$60 ; indoor soldier
    .byte $80,$e0 ; group of 4

; (#$e bytes)
lvl_4_enemy_gen_screen_01:
    .byte $4a,$50 ; jumping soldier
    .byte $c3,$20 ; grenade launcher
    .byte $c2,$20 ; grenade launcher
    .byte $04,$20 ; indoor soldier
    .byte $05,$50 ; indoor soldier
    .byte $47,$50 ; jumping soldier
    .byte $c2,$b0 ; grenade launcher

; (#$8 bytes)
lvl_4_enemy_gen_screen_02:
    .byte $05,$40 ; indoor soldier
    .byte $80,$60 ; group of 4
    .byte $53,$60 ; jumping soldier
    .byte $80,$e0 ; group of 4

; (#$8 bytes)
lvl_4_enemy_gen_screen_03:
    .byte $57,$60 ; jumping soldier
    .byte $40,$60 ; jumping soldier
    .byte $41,$60 ; jumping soldier
    .byte $40,$e0 ; jumping soldier

; (#$6 bytes)
lvl_4_enemy_gen_screen_04:
    .byte $05,$30 ; indoor soldier
    .byte $04,$60 ; indoor soldier
    .byte $42,$e0 ; jumping soldier

; (#$8 bytes)
lvl_4_enemy_gen_screen_05:
    .byte $4e,$40 ; jumping soldier
    .byte $81,$60 ; group of 4
    .byte $41,$60 ; jumping soldier
    .byte $40,$e0 ; jumping soldier

; (#$c bytes)
lvl_4_enemy_gen_screen_06:
    .byte $04,$20 ; indoor soldier
    .byte $03,$40 ; indoor soldier
    .byte $4b,$60 ; jumping soldier
    .byte $07,$20 ; indoor soldier
    .byte $02,$40 ; indoor soldier
    .byte $4b,$e0 ; jumping soldier

; (#$a bytes)
lvl_4_enemy_gen_screen_07:
    .byte $02,$30 ; indoor soldier
    .byte $47,$40 ; jumping soldier
    .byte $80,$60 ; group of 4
    .byte $03,$20 ; indoor soldier
    .byte $04,$d0 ; indoor soldier

; pointer table for base i boss eye (#$7 * #$2 = #$e bytes)
boss_eye_routine_ptr_tbl:
    .addr boss_eye_routine_00     ; CPU address $8e75
    .addr boss_eye_routine_01     ; CPU address $8e7d
    .addr boss_eye_routine_02     ; CPU address $8ea4
    .addr boss_eye_routine_03     ; CPU address $8f08
    .addr boss_defeated_routine   ; CPU address $e740
    .addr enemy_routine_explosion ; CPU address $e7b0
    .addr boss_eye_routine_06     ; CPU address $8f2d

; base I boss eye - pointer 1
boss_eye_routine_00:
    lda #$40 ; a = #$40 (delay before indoor boss appears)

; set the animation delay to a and advanced the ENEMY_ROUTINE
; input
;  * a - the ENEMY_ANIMATION_DELAY
; this label is identical to two other labels
;  * bank 7 - set_anim_delay_adv_enemy_routine
;  * bank 0 - (this bank) set_anim_delay_adv_enemy_routine_01
set_anim_delay_adv_enemy_routine_00:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jmp advance_enemy_routine   ; advance to next routine

boss_eye_routine_01:
    lda WALL_PLATING_DESTROYED_COUNT        ; number of boss platings destroyed
    cmp #$04                                ; number of boss platings to destroy (level 1)
    bcc boss_eye_exit                       ; exit if not all boss platings have been destroyed
    dec ENEMY_ANIMATION_DELAY,x             ; decrement enemy animation frame delay counter
    bne boss_eye_exit                       ; exist if ENEMY_ANIMATION_DELAY hasn't elapsed
    lda #$40                                ; ready to create boss, a = #$40
    sta ENEMY_X_VELOCITY_FRACT,x            ; boss x velocity (low byte)
    lda #$01                                ; a = #$01
    sta ENEMY_X_VELOCITY_FAST,x             ; boss x velocity (high byte)
    lda #$10                                ; a = #$10
    sta ENEMY_VAR_1,x                       ; boss hp
    jsr enable_enemy_collision              ; enable bullet-enemy collision and player-enemy collision checks
    lda #$20                                ; a = #$20 (delay before first attack)
    sta ENEMY_ATTACK_DELAY,x                ; set delay between attacks
    lda #$c0                                ; a = #$c0
    bne set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to #$c0 and advance enemy routine

boss_eye_exit:
    rts

boss_eye_routine_02:
    ldy #$00                    ; y = #$00
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @continue               ; animation delay has elapsed, continue
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    lda FRAME_COUNTER           ; load frame counter
    lsr
    lsr
    lsr
    bcc @continue
    ldy #$04                    ; y = #$04

@continue:
    sty $08
    inc ENEMY_FRAME,x                ; increment enemy animation frame number
    lda ENEMY_FRAME,x                ; load enemy animation frame number
    lsr
    lsr
    lsr
    and #$03                         ; keep bits .... ..xx
    clc                              ; clear carry in preparation for addition
    adc $08
    tay
    lda boss_eye_sprite_code_tbl,y
    sta ENEMY_SPRITES,x              ; write enemy sprite code to CPU buffer
    jsr update_enemy_pos             ; apply velocities and scrolling adjust
    lda ENEMY_X_POS,x                ; load enemy x position on screen
    ldy ENEMY_X_VELOCITY_FAST,x
    bmi @check_pos_create_projectile ; see if boss
    cmp #$b0                         ; compare to left-most 70% of horizontal screen
    bcc @create_projectile_if_should ; in firing position, create eye projectile if attack delay has elapsed
    bcs @reverse_dir_fire_projectile ; reverse player direction and create eye projectile if attack delay has elapsed

@check_pos_create_projectile:
    cmp #$50                         ; minimum  x position
    bcs @create_projectile_if_should ; branch if boss eye is on the right 2/3rds of the screen

@reverse_dir_fire_projectile:
    jsr reverse_enemy_x_direction ; reverse enemy's x direction

@create_projectile_if_should:
    lda ENEMY_ATTACK_FLAG           ; see if enemies should attack
    beq boss_eye_exit               ; exit if enemies shouldn't attack
    dec ENEMY_ATTACK_DELAY,x        ; decrement attack delay
    bne boss_eye_exit               ; exit if ENEMY_ATTACK_DELAY hasn't elapsed
    ldy PLAYER_WEAPON_STRENGTH      ; weapon strength code
    lda boss_eye_attack_delay_tbl,y ; load attack delay based on player's weapon strength
    sta ENEMY_ATTACK_DELAY,x        ; set delay between attacks
    lda #$1b                        ; a = #$1b (boss eye fire ring projectile)
    jmp generate_enemy_a            ; generate eye projectile enemy

; tables for indoor/base level 1 boss eye
; boss eye attack delay (#$04 bytes)
; based off player's weapon strength
boss_eye_attack_delay_tbl:
    .byte $70,$50,$40,$28

; table for boss eye sprite codes (#$8 bytes)
; sprite_5d, sprite_5e, sprite_5f
; sprite_60, sprite_61, sprite_62
boss_eye_sprite_code_tbl:
    .byte $5d,$5e,$5f,$5e,$60,$61,$62,$61

; 'enemy destroyed routine', called every time the boss eye is hit since his
; ENEMY_HP is 1.  Real HP stored in ENEMY_VAR_1.  This is used to play a metal
; ting sound (sound_16) every time the player hits the enemy and reset ENEMY_HP
; to 1 unless boss eye destroyed. If destroyed, advance to boss_defeated_routine
boss_eye_routine_03:
    dec ENEMY_VAR_1,x           ; decrement boss eye's actual HP
    beq boss_eye_adv_routine    ; advance to boss_defeated_routine if boss destroyed
    lda ENEMY_VAR_1,x           ; boss not destroyed, load enemy's actual HP
    cmp #$01                    ; see if only 1 HP
    bne @continue               ; branch if greater than 1 HP remaining
    lda #$52                    ; a = #$52
    sta ENEMY_SCORE_COLLISION,x ; update score (collision code doesn't change)

@continue:
    lda #$16                    ; a = #$16 (sound_16)
    jsr play_sound              ; play bullet - metal ting sound
    lda #$01                    ; a = #$01
    sta ENEMY_HP,x              ; set enemy hp
    lda #$20                    ; a = #$20
    sta ENEMY_ANIMATION_DELAY,x ; time for enemy flashing red when hit
    lda #$03                    ; a = #$03
    jmp set_enemy_routine_to_a  ; set enemy routine index to a

boss_eye_routine_06:
    jsr shared_enemy_routine_clear_sprite ; set tile sprite code to #$00 and advance routine
    lda #$60                              ; a = #$60
    jmp set_delay_remove_enemy

; pointer table for base i boss eye sphere projectile (#$5 * #$2 = #$a bytes)
eye_projectile_routine_ptr_tbl:
    .addr eye_projectile_routine_00    ; CPU address $8f3f
    .addr eye_projectile_routine_01    ; CPU address $8f58
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

eye_projectile_routine_00:
    jsr player_enemy_x_dist             ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                             ; store closest player in $0a
    jsr set_08_09_to_enemy_pos          ; set $08 and $09 to enemy x's X and Y position
    lda #$06                            ; a = #$06 (projectile speed)
    sta $06
    lda #$01                            ; a = #$01 (quadrant_aim_dir_01)
    sta $0f                             ; quadrant_aim_dir_lookup_ptr_tbl offset
    jsr get_quadrant_aim_dir_for_player ; set a to the aim direction within a quadrant
                                        ; based on source position ($09, $08) targeting player index $0a
    jsr set_bullet_velocities           ; set the projectile X and Y velocities (both high and low) based on register a (#$01)

boss_eye_adv_routine:
    jmp advance_enemy_routine

eye_projectile_routine_01:
    lda #$63                   ; a = #$63
    ldy ENEMY_Y_POS,x          ; enemy y position on screen
    cpy #$48                   ; height for projectile to become big & hittable
    bcc @continue
    jsr enable_enemy_collision ; enable bullet-enemy collision and player-enemy collision checks
    lda #$64                   ; a = #$64

@continue:
    sta ENEMY_SPRITES,x                  ; write enemy sprite code to CPU buffer
    lda FRAME_COUNTER                    ; load frame counter
    lsr
    lsr
    and #$03                             ; keep bits .... ..xx
    tay
    lda ENEMY_SPRITE_ATTR,x              ; load enemy sprite attributes
    and #$3f                             ; keep bits ..xx xxxx
    ora eye_projectile_sprite_attr_tbl,y
    sta ENEMY_SPRITE_ATTR,x
    jmp update_enemy_pos                 ; apply velocities and scrolling adjust

; table for sphere projectile mirroring codes (#$4 bytes)
eye_projectile_sprite_attr_tbl:
    .byte $00,$40,$c0,$80

; pointer table for rollers (#$5 * #$2 = #$a bytes)
roller_routine_ptr_tbl:
    .addr roller_routine_00            ; CPU address $8f8c - initialize y position to #$72 advance routine
    .addr roller_routine_01            ; CPU address $8f94 - set appropriate sprite, apply velocity, enable player collision when close, remove when rolled past
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr roller_routine_04            ; CPU address $e7a4 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; initialize y position to #$72 advance routine
roller_routine_00:
    lda #$72                  ; a = #$72 (initial y position)
    sta ENEMY_Y_POS,x         ; enemy y position on screen
    jmp advance_enemy_routine

; set appropriate sprite, apply velocity, enable player collision when close, remove when rolled past
roller_routine_01:
    ldy #$03          ; y = #$03
    lda ENEMY_Y_POS,x ; load enemy y position on screen

@sprite_y_check:
    cmp roller_sprite_y_cutoff_tbl-1,y ; see if y position is below cutoff
    bcs @found_size                    ; branch if found size of sprite to use
    dey                                ; roller isn't below y cutoff for current y, got to next higher cutoff
    bne @sprite_y_check                ; loop to next y offset if y isn't 0
                                       ; otherwise use smallest sprite (sprite_99)

@found_size:
    tya                         ; transfer sprite size index to a
    clc                         ; clear carry in preparation for addition
    adc #$99                    ; add #$99 to get actual sprite code (sprite_99 up to sprite_9c)
    sta ENEMY_SPRITES,x         ; write roller sprite code to CPU buffer
    cpy #$02                    ; see how close the roller is to the player
    bcc @continue               ; branch if roller is relatively far from the player
    lda #$2e                    ; a = #$2e
    sta ENEMY_SCORE_COLLISION,x ; set score and collision code to #$2e

@continue:
    jsr update_enemy_pos       ; apply velocities and scrolling adjust
    lda ENEMY_Y_POS,x          ; load enemy y position on screen
    cmp #$ac                   ; see if roller should have collision enabled (close to the player)
    bcc @exit                  ; exit if roller shouldn't yet be enabled for player-roller collision
    cmp #$bc                   ; see if roller should be removed
    bcs @remove_enemy          ; roller rolled past player, remove roller
    jmp enable_enemy_collision ; roller position is between #$ac and #$bc, enable roller-player collision

@exit:
    rts

@remove_enemy:
    jmp remove_enemy ; remove enemy

; the y positions where the roller sprite changes to a larger size
; #$7c - sprite_9a
; #$8c - sprite_9b
; #$9c - sprite_9c
roller_sprite_y_cutoff_tbl:
    .byte $7c,$8c,$9c

; pointer table for grenades (indoor) (#$6 * #$2 = #$c bytes)
; thrown by indoor soldiers (15) and grenade launchers (17) on indoor levels
grenade_routine_ptr_tbl:
    .addr grenade_routine_00           ; CPU address $8fd5 - init ENEMY_VAR_1, ENEMY_VAR_4, and ENEMY_ATTACK_DELAY, advance routine
    .addr grenade_routine_01           ; CPU address $8fe8 - sets sprite code, sprite attribute, apply vector to get falling arc, advance routine if appropriate
    .addr grenade_routine_02           ; CPU address $907c
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; init ENEMY_VAR_1, ENEMY_VAR_4, and ENEMY_ATTACK_DELAY, advance routine
grenade_routine_00:
    lda ENEMY_Y_POS,x        ; load grenade y position
    sta ENEMY_VAR_1,x        ; store grenade y position in ENEMY_VAR_1
    lda #$00                 ; a = #$00
    sta ENEMY_VAR_4,x
    lda #$fd                 ; a = #$fd
    sta ENEMY_ATTACK_DELAY,x ; set attack delay to #$fd (253)

grenade_adv_routine:
    jmp advance_enemy_routine

; sets sprite code, sprite attribute, apply vector to get falling arc, advance routine if appropriate
grenade_routine_01:
    ldy #$02          ; y = #$02 (start at farthest point from player)
    lda ENEMY_VAR_1,x ; load grenade y position

; find appropriate y register index based on y position
@determine_sprite_code_loop:
    cmp grenade_sprite_tbl_y_cutoff_tbl-1,y ; compare y position to cutoff point
    bcs @sprite_code_tbl_found              ; branch if found appropriate y value
    dey                                     ; y position was less than value, decrement y
    bne @determine_sprite_code_loop         ; try next higher cutoff point if y isn't #$00

@sprite_code_tbl_found:
    lda FRAME_COUNTER       ; load current frame number
    and #$07                ; keep bits 0-2
    bne @check_frame_number ; don't move to next frame if the frame number isn't divisible by #$08
    inc ENEMY_FRAME,x       ; increment enemy animation frame number every #$08 frames

@check_frame_number:
    lda ENEMY_FRAME,x                  ; load enemy animation frame number
    cmp grenade_sprite_codes_len_tbl,y ; see if ENEMY_FRAME hasn't gone past last frame
    bcc @set_sprite_create_arc         ; branch if showing a frame in animation and don't need to loop back
    lda #$00                           ; loop back to first frame, a = #$00

; sets sprite code, sprite attribute, apply vector to get falling arc, advance routine if appropriate
@set_sprite_create_arc:
    sta ENEMY_FRAME,x                    ; set enemy animation frame number (offset into grenade_sprite_codes_xx)
    lda grenade_sprite_codes_len_tbl,y   ; load the number of sprites in the grenade_sprite_codes_xx table
    sta $0a                              ; store value in $09
    tya                                  ; transfer the sprite code table index to a
    asl                                  ; double sprite code table index since each entry has #$92 bytes
    tay                                  ; transfer sprite code table index back to y
    lda grenade_sprite_codes_ptr_tbl,y   ; load low byte of grenade_sprite_codes_xx
    sta $08                              ; store in $08
    lda grenade_sprite_codes_ptr_tbl+1,y ; load high byte of grenade_sprite_codes_xx
    sta $09                              ; store in $09
    ldy ENEMY_FRAME,x                    ; load enemy animation frame number
    lda ($08),y                          ; load sprite code from grenade_sprite_codes_xx
    sta ENEMY_SPRITES,x                  ; write enemy sprite code to CPU buffer
    tya                                  ; transfer sprite code table index back to y
    clc                                  ; clear carry in preparation for addition
    adc $0a                              ; add offset to get to corresponding sprite attribute
                                         ; each grenade_sprite_codes_xx contains both sprite codes and sprite attribute values
                                         ; $0a is the number of (sprite code, sprite attribute) pairs
    tay                                  ; transfer offset back to y
    lda ($08),y                          ; load grenade sprite attribute
    sta ENEMY_SPRITE_ATTR,x              ; store grenade sprite attribute
    lda ENEMY_VAR_4,x
    clc                                  ; clear carry in preparation for addition
    adc #$0c                             ; add #$0c into ENEMY_VAR_4
    sta ENEMY_VAR_4,x
    lda ENEMY_ATTACK_DELAY,x
    adc #$00
    sta ENEMY_ATTACK_DELAY,x
    jsr set_enemy_falling_arc_pos        ; set X and Y position to follow a falling arc
    lda ENEMY_VAR_3,x
    bpl grenade_adv_routine
    rts

; table for delays before changing sprite (#$2 bytes)
grenade_sprite_tbl_y_cutoff_tbl:
    .byte $80,$90

; table for sprite attribute offset  (related to z position and palette) (#$3 bytes)
grenade_sprite_codes_len_tbl:
    .byte $04,$08,$08

; pointer table for grenade sprites and palettes (#$3 * #$2 = #$6 bytes)
grenade_sprite_codes_ptr_tbl:
    .addr grenade_sprite_codes_00 ; CPU address $9054
    .addr grenade_sprite_codes_01 ; CPU address $905c
    .addr grenade_sprite_codes_02 ; CPU address $906c

; table for grenade sprites and sprite attributes (closest to player) (#$8 bytes)
; sprite_a8, sprite_a9, sprite_a6
; sprite attributes
;  * $c0 - flip horizontally and vertically
grenade_sprite_codes_00:
    .byte $a8,$a9,$a6,$a9 ; sprite codes
    .byte $00,$00,$00,$c0 ; sprite attributes

; table for grenade sprites and sprite attributes (close to player) (#$10 bytes)
; sprite_a4, sprite_a5, sprite_a6, sprite_a6, sprite_a7
; sprite attributes
;  * $c0 - flip horizontally and vertically
grenade_sprite_codes_01:
    .byte $a4,$a5,$a6,$a5,$a4,$a7,$a6,$a7 ; sprite codes
    .byte $00,$00,$00,$c0,$c0,$00,$00,$c0 ; sprite attributes

; table for grenade sprites and sprite attributes (farthest from player) (#$10 bytes)
; sprite_a0, sprite_a1, sprite_a2, sprite_a3
; sprite attributes
;  * $c0 - flip horizontally and vertically
grenade_sprite_codes_02:
    .byte $a0,$a1,$a2,$a1,$a0,$a3,$a2,$a3 ; sprite codes
    .byte $00,$00,$00,$c0,$c0,$00,$00,$c0 ; sprite attributes

; play sound, set
grenade_routine_02:
    lda #$24                   ; a = #$24 (sound_24)
    jsr play_sound             ; play explosion sound
    lda #$ac                   ; a = #$ac
    sta ENEMY_Y_POS,x          ; set y position to #$ac (bottom of screen where explosion occurs)
    jsr mortar_shot_routine_03 ; update collision to allow player-enemy collision
    jmp advance_enemy_routine  ; go to enemy_routine_init_explosion

; pointer table for wall turret (#$8 * #$2 = #$10 bytes)
wall_turret_routine_ptr_tbl:
    .addr wall_turret_routine_00     ; CPU address $909c - set initial delay and advance routine
    .addr wall_turret_routine_01     ; CPU address $90a8 - draw 'wall turret / core - closed' super-tile, wait for delay, advance routine
    .addr wall_turret_routine_02     ; CPU address $90c1 - opening animation and enabling collision
    .addr wall_turret_routine_03     ; CPU address $90ee - aim and fire turret
    .addr wall_turret_routine_04     ; CPU address $9108 - enemy destroyed routine - draw 'core - destroyed' nametable tiles, advance routine
    .addr wall_core_routine_05       ; CPU address $e737 from bank 7
    .addr enemy_routine_explosion    ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy ; CPU address $e806 from bank 7

; set initial delay and advance routine
wall_turret_routine_00:
    ldy ENEMY_ATTRIBUTES,x              ; load enemy attributes
    lda wall_turret_initial_delay_tbl,y
    bne set_turret_delay_adv_routine

; table for wall turret deployment delays (#$4 bytes)
wall_turret_initial_delay_tbl:
    .byte $50,$80,$b0,$f0

; draw 'wall turret / core - closed' super-tile, wait for delay, advance routine
wall_turret_routine_01:
    lda ENEMY_VAR_1,x                ; load byte specifying
    bne @wait_for_delay_adv_routine  ; branch if already set 'wall turret / core - closed' super-tile
    lda #$84                         ; level_2_4_tile_animation offset (#$04) (wall turret / core - closed)
    jsr update_enemy_nametable_tiles ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
    bcs @wait_for_delay_adv_routine  ; branch if unable to draw super-tile. Don't set super-tile drawn byte (ENEMY_VAR_1)
    inc ENEMY_VAR_1,x                ; set byte specifying that the 'wall turret / core - closed' super-tile was drawn

@wait_for_delay_adv_routine:
    dec ENEMY_ANIMATION_DELAY,x ; decrement animation delay as set by ENEMY_ATTRIBUTES (wall_turret_initial_delay_tbl)
    bne wall_turret_exit        ; exit if delay hasn't elapsed
    lda #$01                    ; animation delay elapsed, set new animation delay, and advance routine to wall_turret_routine_02

set_turret_delay_adv_routine:
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to a and advance enemy routine

; opening animation and enabling collision
wall_turret_routine_02:
    dec ENEMY_ANIMATION_DELAY,x          ; decrement animation delay
    bne wall_turret_exit                 ; exit if delay hasn't elapsed
    lda #$08                             ; a = #$08 (delay between deployment frames)
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    ldy ENEMY_FRAME,x                    ; load enemy animation frame number
    lda wall_turret_tile_animation_tbl,y ; load level_2_4_tile_animation offset
    jsr update_nametable_tiles_set_delay ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
                                         ; set animation delay to #$01 if drawing was successful
    bcs wall_turret_exit                 ; exit if unable to draw nametable tiles
    inc ENEMY_FRAME,x                    ; increment enemy animation frame number
    lda ENEMY_FRAME,x                    ; load enemy animation frame number
    cmp #$03                             ; see if last frame of opening animation frames
    bcc wall_turret_exit                 ; exit if not finished opening
    jsr enable_bullet_enemy_collision    ; allow bullets to collide (and stop) upon colliding with wall turret
    lda #$80                             ; a = #$80 (initial delay before attacking)
    sta ENEMY_ATTACK_DELAY,x             ; set attack delay

wall_turret_adv_routine:
    jmp advance_enemy_routine ; advance to next routine

; table for wall turret opening tile super-tile codes (#$3 bytes)
; offsets into level_2_4_tile_animation
; #$85 - wall turret / core - opening frame 1
; #$88 - wall turret - opening frame 2
; #$89 - wall turret - open
wall_turret_tile_animation_tbl:
    .byte $85,$88,$89

; aim and fire turret
wall_turret_routine_03:
    dec ENEMY_ATTACK_DELAY,x        ; decrement attack delay
    bne wall_turret_exit            ; exit if attack delay hasn't elapsed
    lda #$50                        ; ready to attack, set next round attack delay to #$50
    sta ENEMY_ATTACK_DELAY,x        ; set next round of attack delay to #$50
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                         ; store closest player in $0a
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    lda #$60                        ; a = #$60
    ldy #$04                        ; bullet speed code
    jmp aim_and_create_enemy_bullet ; get firing dir based on enemy ($08, $09) and player pos ($0b, $0a)
                                    ; and creates bullet (type a) with speed y if appropriate

wall_turret_exit:
    rts

; draw 'core - destroyed' nametable tiles, advance routine
wall_turret_routine_04:
    lda #$83                         ; a = #$83 (core - destroyed)
    jsr update_enemy_nametable_tiles ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
    bcc wall_turret_adv_routine      ; advance routine to wall_core_routine_05
    rts                              ; exit if unable to draw 'core - destroyed' super-tile

; pointer table for base core (#$a * #$2 = #$14 bytes)
wall_core_routine_ptr_tbl:
    .addr wall_core_routine_00    ; CPU address $9124 (init variables)
    .addr wall_core_routine_01    ; CPU address $9167 (set core plating)
    .addr wall_core_routine_02    ; CPU address $91a0 (wall core opening)
    .addr wall_core_routine_03    ; CPU address $91cf (fire at player if conditions met)
    .addr wall_core_routine_04    ; CPU address $91fb (update nametable for destroyed plating/destroyed core, reset HP)
    .addr wall_core_routine_05    ; CPU address $e737 (initialize explosion)
    .addr enemy_routine_explosion ; CPU address $e7b0
    .addr wall_core_routine_07    ; CPU address $923b (core destroyed, see if last core, if so destroy all enemies)
    .addr wall_core_routine_08    ; CPU address $9251 (boss appears after or during this routine)
    .addr wall_core_routine_09    ; CPU address $92ae (wait for explosion delay, mark screen cleared, remove enemy)

; initializes variables like HP, collision box code, destruction animation sequence
wall_core_routine_00:
    lda ENEMY_ATTRIBUTES,x ; load enemy attributes
    lsr                    ; shift right
    lsr                    ; shift right, removing opening delay
    and #$03               ; keep bits .... ..xx (core size, and whether or not it is plated)
    tay                    ; transfer value to y
    lsr                    ; shift bit 2 of ENEMY_ATTRIBUTES into carry
    lda #$25               ; a = #$25
    bcc @continue          ; branch if not plated
    lda #$04               ; plated, set bullet collision sound code to #$04
    sta ENEMY_VAR_A,x      ; core plating bullet collision sound code (see bullet_hit_sound_tbl)
    lda #$22               ; score code #$02, collision box code #$02

@continue:
    sta ENEMY_SCORE_COLLISION,x            ; set score code and collision box code
    lda wall_core_hp_tbl,y                 ; load ENEMY_HP based on core type (size and plating)
    sta ENEMY_HP,x                         ; set enemy hp
    lda wall_core_init_dmg_tile_anim_tbl,y ; load correct initial tile update animation offset (wall_core_tile_anim_tbl)
                                           ; based on core type (size and plating) for destruction animation sequence
    sta ENEMY_VAR_2,x                      ; set current wall_core_tile_anim_tbl offset
    ldy #$00                               ; default #$20 core opening delay
    lda ENEMY_ATTRIBUTES,x                 ; load enemy attributes
    and #$04                               ; keep bit 2 (whether core is plated)
    bne @set_opening_delay_adv_routine     ; branch if core is plated, use default #$20 opening delay
    lda ENEMY_ATTRIBUTES,x                 ; load enemy attributes
    and #$03                               ; keep bits 0 and 1 (core opening delay)
    tay                                    ; transfer opening delay offset to y

@set_opening_delay_adv_routine:
    lda core_opening_delay,y
    bne wall_core_adv_routine ; always branch
                              ; set animation delay and advance to wall_core_routine_01

; table for core opening delays (#$4 bytes)
; the larger the number, the longer the delay (#$f0 is largest delay)
core_opening_delay:
    .byte $20,$80,$b0,$f0

; table for indoor/base wall core hp (#$4 bytes)
; #$08 - ENEMY_HP for normal-sized core not plated
; #$05 - ENEMY_HP for normal-sized plated core
; #$10 - ENEMY_HP for big core, not plated
; #$05 - ENEMY_HP for big core, plated (not used)
wall_core_hp_tbl:
    .byte $08,$05,$10,$05

; table for initial cracked core tiles when being attacked (#$4 bytes)
; as core is destroyed nametable tiles are updated in descending sequence
; from wall_core_tile_anim_tbl
; #$00 - normal-sized core not plated - #$83 core - destroyed
; #$03 - normal-sized plated core - #$81 core plating - cracked
; #$00 - big core, not plated - #$83 core - destroyed
; #$03 - big core, plated (not used) - #$81 core plating - cracked
wall_core_init_dmg_tile_anim_tbl:
    .byte $00,$03,$00,$03

; set core plating
wall_core_routine_01:
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    and #$08                        ; keep bit 3 (whether or not is a large core)
    bne @wait_for_delay_adv_routine ; branch if big core
    lda ENEMY_VAR_1,x               ; see if nametable has been updated
    bne @wait_for_delay_adv_routine
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    lsr
    lsr
    lsr
    lda #$84                        ; a = #$84 (level_2_4_tile_animation offset) wall turret / core - closed
    bcc @update_nametable           ; branch if not plated core
    lda #$80                        ; plated core, set a = #$80 (level_2_4_tile_animation offset) core plating

@update_nametable:
    jsr update_enemy_nametable_tiles ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
    bcs @wait_for_delay_adv_routine  ; branch if unable to update nametable tiles
    inc ENEMY_VAR_1,x                ; mark nametable as updated

@wait_for_delay_adv_routine:
    dec ENEMY_ANIMATION_DELAY,x                ; decrement enemy animation frame delay counter
    bne wall_core_exit_00
    lda ENEMY_ATTRIBUTES,x                     ; load enemy attributes
    and #$04                                   ; keep bit 2 (whether or not is a plated core)
    beq @set_delay_adv_routine                 ; branch if not a plated core, no need to enable collision
    jsr wall_core_enable_collision_adv_routine ; enable collision and move to wall_core_routine_02

@set_delay_adv_routine:
    lda #$01                 ; a = #$01, attack and animation delay
    sta ENEMY_ATTACK_DELAY,x
    lda #$01                 ; a = #$01 (unneeded)

wall_core_adv_routine:
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to a and advance enemy routine

wall_core_routine_02:
    dec ENEMY_ANIMATION_DELAY,x                ; decrement enemy animation frame delay counter
    bne wall_core_exit_00
    lda ENEMY_ATTRIBUTES,x                     ; load enemy attributes
    and #$08                                   ; keep bit 3 (whether or not is a large core)
    bne wall_core_enable_collision_adv_routine ; enable collision and move to wall_core_routine_03, large core doesn't have opening delay
    lda #$08                                   ; a = #$08 (delay between frames when core opens)
    sta ENEMY_ANIMATION_DELAY,x                ; set enemy animation frame delay counter
    ldy ENEMY_FRAME,x                          ; enemy animation frame number
    lda wall_core_nametable_update_tbl,y
    jsr update_nametable_tiles_set_delay       ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
                                               ; set animation delay to #$01 if drawing was successful
    bcs wall_core_exit_00                      ; exit if unable to update nametable tiles
    inc ENEMY_FRAME,x                          ; increment enemy animation frame number
    lda ENEMY_FRAME,x                          ; load enemy animation frame number
    cmp #$03                                   ; see if last frame (fully open)
    bcc wall_core_exit_00                      ; exit if not fully open yet

wall_core_enable_collision_adv_routine:
    jsr enable_bullet_enemy_collision ; allow bullets to collide (and stop) upon colliding with wall core
    jmp advance_enemy_routine

; table for core opening update nametable tiles (offsets into level_2_4_tile_animation) (#$03 bytes)
; #$85 wall turret / core - opening frame 1
; #$86 core - opening frame 2
; #$87 core - open
wall_core_nametable_update_tbl:
    .byte $85,$86,$87

; fire at player if conditions met
wall_core_routine_03:
    lda INDOOR_ENEMY_ATTACK_COUNT   ; load the total number of enemy attack rounds for the screen
    cmp #$07                        ; number of cycles for core to start shooting
    bcc wall_core_exit_00           ; don't attack, not enough rounds of soldier attacks have happened
    lda ENEMY_VAR_2,x               ; load current nametable index
    bne wall_core_exit_00           ; exit if wall core is still plated
    lda ENEMY_Y_POS,x               ; load enemy y position on screen
    cmp #$70                        ; check if core is not too low
    bcs wall_core_exit_00           ; exit if core is too low (player needs to crouch to attack)
    dec ENEMY_ATTACK_DELAY,x        ; decrement delay between attacks
    bne wall_core_exit_00           ; exit if attack delay hasn't elapsed
    lda #$28                        ; a = #$28 (delay between bullets)
    sta ENEMY_ATTACK_DELAY,x        ; reset attack delay
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                         ; store closest player in $0a
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    lda #$60                        ; a = #$60
    ldy #$05                        ; y = #$05 (wall turret bullet speed code)
    jmp aim_and_create_enemy_bullet ; get firing dir based on enemy ($08, $09) and player pos ($0b, $0a)
                                    ; and creates bullet (type a) with speed y if appropriate

wall_core_exit_00:
    rts

; update nametable for destroyed plating/destroyed core, reset HP
wall_core_routine_04:
    ldy ENEMY_VAR_2,x      ; load current state of nametable tiles
    lda ENEMY_ATTRIBUTES,x ; load enemy attributes
    and #$08               ; keep bit 3 (whether or not is a large core)
    beq @continue          ; branch if a normal-sized core
    tya                    ; large core, transfer ENEMY_VAR_2 to a
    clc                    ; clear carry in preparation for addition
    adc #$04               ; add #$04 to set correct large core nametable tiles
    tay                    ; transfer a back to y to use as animation offset

@continue:
    lda wall_core_tile_anim_tbl,y    ; load appropriate level_2_4_tile_animation offset to update tiles
    jsr update_enemy_nametable_tiles ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
    bcs wall_core_exit_00            ; exit if unable to update nametable tiles
    ldy #$05                         ; y = #$05 (hp for 2nd and 3rd levels of plating)
    dec ENEMY_VAR_2,x                ; decrement to next level of destroyed plating
    bmi @adv_routine                 ; go to wall_core_routine_05 if plating has been destroyed
    bne @set_hp_go_routine_03        ; plating not yet destroyed, set HP to #$05 and set enemy routine to wall_core_routine_03
    lda #$00                         ; plating destroyed, a = #$00
    sta ENEMY_VAR_A,x                ; normal collision sound since bullet no longer colliding with plating (see bullet_hit_sound_tbl)
    lda #$25                         ; a = #$25 (updating collision box code)
    sta ENEMY_SCORE_COLLISION,x      ; score code #$02, collision box code #$05
    ldy #$08                         ; y = #$08 (hp for core after plating destroyed)

@set_hp_go_routine_03:
    tya                        ; transfer HP to a
    sta ENEMY_HP,x             ; set enemy hp
    lda #$04                   ; a = #$04
    jmp set_enemy_routine_to_a ; set enemy routine index to wall_core_routine_03

@adv_routine:
    jmp advance_enemy_routine

; nametable update offsets into level_2_4_tile_animation for destroyed core (#$8 bytes)
; #$81 core plating - cracked
; #$82 core plating - more cracks
; #$83 core - destroyed
; #$87 core - open
; #$8a big core
wall_core_tile_anim_tbl:
    .byte $83,$87,$82,$81,$83,$8a,$82,$81

; core destroyed, see if last core, if so destroy all enemies
wall_core_routine_07:
    dec WALL_CORE_REMAINING    ; decrement remaining cores/bosses to destroy required to allow advance to next screen
    bne wall_core_remove_enemy ; branch to remove enemy if other wall cores still need to be destroyed
    lda #$00                   ; all wall cores have been destroyed, set a = #$00 (sprite_00)
    sta ENEMY_SPRITES,x        ; hide enemy (invisible sprite)
    jsr destroy_all_enemies    ; destroy any other enemies on screen
    lda #$03                   ; a = #$03
    sta ENEMY_VAR_3,x          ;
    lda #$04                   ; a = #$04 (animation delay)

wall_core_set_delay_adv_routine:
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to a and advance enemy routine

; removes back wall
wall_core_routine_08:
    dec ENEMY_ANIMATION_DELAY,x          ; decrement enemy animation frame delay counter
    bne wall_core_wait_play_sound
    ldy ENEMY_VAR_3,x                    ; load current destroyed back wall super-tile index to load
    lda wall_core_y_pos_tbl,y            ; load destroyed back wall quadrant y position
    sta ENEMY_Y_POS,x                    ; enemy y position on screen
    lda wall_core_x_pos_tbl,y            ; load destroyed back wall quadrant x position
    sta ENEMY_X_POS,x                    ; set enemy x position on screen
    lda wall_core_update_supertile_tbl,y ; load level update super-tile to draw (level_xx_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a           ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs @set_delay_exit                  ; exit if unable to update super-tile
    ldy ENEMY_VAR_3,x                    ; load current destroyed back wall super-tile index
    tya                                  ; transfer to y
    lsr
    lsr
    lda #$fc                             ; a = #$fc
    bcc @continue                        ; branch if not updating bottom super-tile
    lda #$f4                             ; a = #$f4

@continue:
    clc                                    ; clear carry in preparation for addition
    adc wall_core_y_pos_tbl,y              ; subtract from wall position to set explosion animation y position
    sta $08                                ; store y position of explosion in $08
    lda wall_core_x_pos_tbl,y              ; subtract from wall position to set explosion animation x position
    sta $09                                ; store x position of explosion in $09
    jsr create_explosion_89                ; create explosion type #$89 at ($09, $08)
    dec ENEMY_VAR_3,x                      ; move to next destroyed wall quadrant
    bmi wall_core_set_delay_10_adv_routine ; advance routine if finished updated destroyed back wall

@set_delay_exit:
    lda #$01                    ; a = #$01
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

wall_core_exit_01:
    rts

wall_core_set_delay_10_adv_routine:
    lda #$10                            ; a = #$10
    bne wall_core_set_delay_adv_routine

wall_core_wait_play_sound:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    cmp #$01
    bne wall_core_exit_01
    lda #$25                    ; a = #$25 (small boom sound)
    jmp play_sound

; tables related to back wall cleared explosions and replacing super-tiles
; indexes into level_2_nametable_update_supertile_data/level_4_nametable_update_supertile_data
 ; #$00 - top left back wall destroyed
 ; #$01 - top right back wall destroyed
 ; #$02 - bottom left back wall destroyed
 ; #$03 - bottom right back wall destroyed
wall_core_update_supertile_tbl:
    .byte $02,$03,$01,$00

; table for destroyed back wall super-tile y position (#$4 bytes)
wall_core_y_pos_tbl:
    .byte $78,$78,$58,$58

; table for destroyed back wall super-tile x position (#$4 bytes)
wall_core_x_pos_tbl:
    .byte $70,$90,$90,$70

; wait for explosion delay, mark screen cleared, remove enemy
wall_core_routine_09:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne wall_core_exit_01       ; exit if explosion animations aren't completed
    lda #$01                    ; a = #$01 (mark screen cleared)
    sta INDOOR_SCREEN_CLEARED   ; indoor screen cleared flag (0 = not cleared; 1 = cleared)

wall_core_remove_enemy:
    jmp remove_enemy ; remove enemy

indoor_soldier_routine_ptr_tbl:
    .addr indoor_soldier_routine_00    ; CPU address $92c8
    .addr indoor_soldier_routine_01    ; CPU address $92d5
    .addr shared_enemy_routine_00      ; CPU address $9346 - soldier has been hit by player bullet
    .addr shared_enemy_routine_01      ; CPU address $9360 - perform enemy hit by bullet animation, then advance routine
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr shared_enemy_routine_03      ; CPU address $e7aa from bank 7 - show explosion_type_02
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; initializes indoor soldier
; * sets position, velocity and attack delay
indoor_soldier_routine_00:
    ldy #$00                          ; y = #$00
    jsr init_indoor_enemy_pos_and_vel ; initialize indoor soldier soldier velocity and position
    lda #$08                          ; a = #$08 (delay before attacking, running guy)
    sta ENEMY_ATTACK_DELAY,x          ; set delay between attacks
    jmp advance_enemy_routine

; wait for attack delay to elapse, then fire weapon based on ENEMY_ATTRIBUTES
indoor_soldier_routine_01:
    jsr init_sprite_from_frame               ; determine enemy sprite based on ENEMY_FRAME, flip sprite horizontally if running left
    jsr apply_enemy_velocity_set_bg_priority ; apply enemy velocity to position (remove if off screen), set bg priority
    dec ENEMY_ATTACK_DELAY,x                 ; decrement delay between attacks
    bne @exit                                ; delay between attacks not yet elapsed, just exit
    lda #$10                                 ; ready to attack, first reset attack delay to #$10
    sta ENEMY_ATTACK_DELAY,x                 ; set delay between attacks
    lda ENEMY_X_POS,x                        ; load enemy x position on screen
    cmp #$68                                 ; location of disappearance, from left
    bcc @exit                                ; enemy too far to the left to attack, exit
    cmp #$98                                 ; location of disappearance, from right
    bcs @exit                                ; enemy too far to the right to attack, exit
    lda ENEMY_ATTRIBUTES,x                   ; load the enemy weapon type and enemy direction
    lsr                                      ; shift enemy direction bit to carry (not used to determine enemy weapon type)
    and #$03                                 ; keep bits .... ..xx that specify weapon type
    tay                                      ; transfer weapon type to y
    bne @continue                            ; not a regular bullet weapon type (#$00), see if grenade or a roller
    jmp create_indoor_bullet                 ; fire a regular indoor bullet

@continue:
    dey                      ; decrement enemy weapon type
    bne @create_roller       ; not a grenade, so create a roller (ENEMY_TYPE #$11)
    inc ENEMY_VAR_1,x        ; increment total grenades fired
    lda ENEMY_VAR_1,x        ; load total grenades fired
    lsr                      ; shift bit 0 to the carry flag
    bcc @exit                ; exit every other time, effectively doubling ENEMY_ATTACK_DELAY
    jmp enemy_launch_grenade ; create a grenade (ENEMY_TYPE #$12)

; creates a roller x pixels down from indoor soldier to roll towards player
@create_roller:
    ldy #$08               ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda #$00               ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos ; stores absolute screen x position in $09, and y position in $08
    jmp create_roller      ; create the roller

@exit:
    rts

; sets the enemy sprite and flips it if necessary depending on enemy direction
init_sprite_from_frame:
    lda FRAME_COUNTER              ; load frame counter
    and #$03                       ; keep bits .... ..xx
    bne @set_sprite_and_attr       ; set the enemy sprite code, and sprite attribute
    inc ENEMY_FRAME,x              ; increment enemy animation frame number
    lda ENEMY_FRAME,x              ; load enemy animation frame number
    cmp #$03                       ; indoor enemies have 3 frames to cycle through
    bcc @set_frame_sprite_and_attr ; set the enemy sprite based on frame, and flip sprite if necessary
    lda #$00                       ; a = #$00

@set_frame_sprite_and_attr:
    sta ENEMY_FRAME,x ; update enemy animation frame number

@set_sprite_and_attr:
    lda ENEMY_FRAME,x           ; load enemy animation frame number
    clc                         ; clear carry in preparation for addition
    adc #$93                    ; determine sprite based on enemy frame
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer
    lda ENEMY_SPRITE_ATTR,x     ; load enemy sprite attributes
    ldy ENEMY_X_VELOCITY_FAST,x ; see if enemy is running left
    bmi @horizontal_flip_sprite ; branch if enemy is traveling left, flip sprite horizontally
    and #$bf                    ; keep bits x.xx xxxx (no horizontal flipping)
    bpl @set_sprite_attr

@horizontal_flip_sprite:
    ora #$40 ; set bits .x.. .... (flip sprite horizontally)

@set_sprite_attr:
    sta ENEMY_SPRITE_ATTR,x ; set updated sprite attribute

; also exit for
shared_enemy_routine_01_exit:
    rts

; used by the indoor soldiers: #$15 - Indoor Soldier, #$16 - Jumping Soldier, #$17 - Grenade Launcher, #$18 - Group of Four Soldiers
; soldier has been hit by player bullet
shared_enemy_routine_00:
    jsr disable_enemy_collision             ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$96                                ; a = #$96 (sprite_96) indoor soldier hit by bullet
    sta ENEMY_SPRITES,x                     ; write enemy sprite code to CPU buffer
    lda #$80                                ; a = #$80
    sta ENEMY_Y_VELOCITY_FRACT,x            ; set negative velocity for initial hit reaction (slow .5)
    lda #$fd                                ; a = #$fd
    sta ENEMY_Y_VELOCITY_FAST,x             ; set negative velocity for initial hit reaction (fast -3)
    jsr set_enemy_x_velocity_to_0           ; set x velocity to zero
    lda #$10                                ; a = #$10
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to #$10 and advance enemy routine

; perform enemy hit by bullet animation
shared_enemy_routine_01:
    jsr update_enemy_pos             ; apply velocities and scrolling adjust
    lda #$38                         ; a = #$38 (gravity when flying up, indoor)
    jsr add_a_to_enemy_y_fract_vel   ; add a to enemy y fractional velocity
    dec ENEMY_ANIMATION_DELAY,x      ; decrement enemy animation frame delay counter
    bne shared_enemy_routine_01_exit
    jmp advance_enemy_routine

; pointer table for jumping guy (#$8 * #$2 = #$10 bytes)
jumping_soldier_routine_ptr_tbl:
    .addr jumping_soldier_routine_00   ; CPU address $9380 - see if red soldier, if so mark flag, advance routine
    .addr jumping_soldier_routine_01   ; CPU address $93a5 - set sprite, and perform jump animation
    .addr shared_enemy_routine_00      ; CPU address $9346 - soldier has been hit by player bullet
    .addr shared_enemy_routine_01      ; CPU address $9360 - perform enemy hit by bullet animation, then advance routine
    .addr jumping_soldier_routine_04   ; CPU address $9437 - soldier destroyed, if red soldier play explosion
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr shared_enemy_routine_03      ; CPU address $e7aa from bank 7  - show explosion_type_02
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; see if red soldier, if so mark flag, advance routine
jumping_soldier_routine_00:
    lda ENEMY_ATTRIBUTES,x          ; load the ENEMY_ATTRIBUTES to get bit 1
    lsr                             ; shift bit 0 into carry to disregard
    lsr                             ; shift bit 1 into carry. This specifies if jumping soldier is red (drops a weapon item)
    bcc @init_enemy_adv_routine     ; branch if jumping soldier is not red
    lda INDOOR_RED_SOLDIER_CREATED  ; jumping soldier is red, see if one has already been created
    bne @clear_red_soldier_continue ; jumping red soldier has been created, don't create another
    lda INDOOR_ENEMY_ATTACK_COUNT   ; load the total number of enemy attack rounds for the screen
    beq @clear_red_soldier_continue ; don't have red jumping soldier on the first round of attacks
    lda #$01                        ; a = #$01
    sta INDOOR_RED_SOLDIER_CREATED  ; create a red jumping soldier, mark as created to prevent further creation
    bne @init_enemy_adv_routine     ; always jump, create red jumping soldier

@clear_red_soldier_continue:
    lda ENEMY_ATTRIBUTES,x ; load the original ENEMY_ATTRIBUTES
    and #$fd               ; keep bits xxxx xx.x (drop red soldier status)
    sta ENEMY_ATTRIBUTES,x ; update ENEMY_ATTRIBUTES to no longer create a red jumping soldier

@init_enemy_adv_routine:
    ldy #$02                          ; y = #$02 (jumping soldier)
    jsr init_indoor_enemy_pos_and_vel ; initialize indoor jumping soldier enemy velocity and position
    jmp advance_enemy_routine         ; advance routine to jumping_soldier_routine_01

; set sprite, and perform jump animation
jumping_soldier_routine_01:
    lda #$97                    ; a = #$97 (sprite_97 jumping man in air)
    ldy ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @set_sprite             ; branch to continue if animation delay is #$00
    lda #$93                    ; a = #$93 (sprite_93 jumping man running)
    cpy #$04                    ; compare animation delay to #$04
    bcc @set_sprite             ; continue if animation delay is less than #$04
    lda #$98                    ; animation delay is > #$04, set a = #$98 (sprite_98 jumping man running)

@set_sprite:
    sta ENEMY_SPRITES,x    ; write enemy sprite code to CPU buffer
    lda ENEMY_ATTRIBUTES,x ; load enemy attributes
    lsr
    lsr
    lda #$00               ; a = #$00 (default palette)
    bcc @set_sprite_attr   ; branch if jumping soldier doesn't drop a R weapon item
.ifdef Probotector
    lda #$07               ; red jumping soldier, set sprite palette #$03 and sprite code override bit
                           ; jumping soldier drops R weapon, so override palette so it's red
.else
    lda #$05               ; red jumping soldier, set sprite palette #$01 and sprite code override bit
                           ; jumping soldier drops R weapon, so override palette so it's red
.endif

@set_sprite_attr:
    sta $08
    lda ENEMY_SPRITE_ATTR,x     ; load enemy sprite attributes
    ldy ENEMY_X_VELOCITY_FAST,x ; load enemy x velocity (direction)
    bmi @flip_spite             ; branch if jumping left
    and #$bf                    ; jumping towards the right, strip bit 6 (don't horizontally flip sprite)
    bpl @continue               ; always branch

@flip_spite:
    ora #$40 ; set bit 6 (flip sprite horizontally)

@continue:
    and #$f8                        ; strip sprite palette bits
    ora $08                         ; set sprite palette bits as calculated above (#$05 if jumping soldier is red, #$00 otherwise)
    sta ENEMY_SPRITE_ATTR,x         ; set enemy sprite attributes
    lda ENEMY_ANIMATION_DELAY,x     ; load enemy animation frame delay counter
    beq @apply_y_vel
    dec ENEMY_ANIMATION_DELAY,x     ; decrement enemy animation frame delay counter
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    and #$02                        ; keep bits .... ..x.
    bne @exit
    lda ENEMY_ANIMATION_DELAY,x     ; load enemy animation frame delay counter
    cmp #$08
    bne @exit
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                         ; store closest player in $0a
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    lda #$60                        ; a = #$60
    ldy #$04                        ; y = #$04 (jumping guy bullet speed code)
    jmp aim_and_create_enemy_bullet ; get firing dir based on enemy ($08, $09) and player pos ($0b, $0a)
                                    ; and creates bullet (type a) with speed y if appropriate

@apply_y_vel:
    jsr apply_enemy_velocity_set_bg_priority ; apply enemy velocity to position (remove if off screen), set bg priority
    ldy ENEMY_VAR_1,x                        ; load current jumping_soldier_y_vel_tbl velocity
    lda jumping_soldier_y_vel_tbl,y          ; load actual amount to change y velocity
    clc                                      ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                        ; add distance to current jumping soldier y position
    sta ENEMY_Y_POS,x                        ; set new enemy y position on screen
    inc ENEMY_VAR_1,x                        ; increment jumping_soldier_y_vel_tbl for next frame
    lda ENEMY_VAR_1,x                        ; load new jumping_soldier_y_vel_tbl
    cmp #$14                                 ; check to see if finished jump
    bcc @exit                                ; exit if haven't yet finished jump
    lda #$00                                 ; finished jumping, set a = #$00
    sta ENEMY_VAR_1,x                        ; reset jumping_soldier_y_vel_tbl index to start next jump
    lda #$10                                 ; a = #$10
    sta ENEMY_ANIMATION_DELAY,x              ; set enemy animation frame delay counter

@exit:
    rts

; table for jumping guy y velocities when jumping (#$14 bytes)
jumping_soldier_y_vel_tbl:
    .byte $fd,$fd,$fe,$fe,$fe,$ff,$ff,$ff,$00,$00,$00,$00,$01,$01,$01,$02
    .byte $02,$02,$03,$03

jumping_soldier_routine_04:
    lda ENEMY_ATTRIBUTES,x   ; load enemy attributes
    and #$02                 ; keep bits .... ..x.
    beq @adv_routine         ; not a red jumping soldier, just advance routine
    lda ENEMY_X_POS,x        ; red jumping soldier, enemy x position on screen
    cmp #$64                 ; check if on left side
    bcc @adv_routine         ; if too far to the left (behind wall), just advance routine
    cmp #$9c                 ; check if on right side
    bcs @adv_routine         ; if too far to the right (behind wall), just advance routine
    lda ENEMY_ATTRIBUTES,x   ; load enemy attributes
    bmi @adv_routine         ; if bit 7 is set, just advance routine (not sure when this happens) !(WHY?)
    lsr ENEMY_ATTRIBUTES,x
    lsr ENEMY_ATTRIBUTES,x   ; zero out the ENEMY_ATTRIBUTES (not sure why this is needed) !(WHY?)
    jmp play_explosion_sound ; play explosion

@adv_routine:
    jmp advance_enemy_routine

; pointer table for seeking guy (#$7 * #$2 = #$e bytes)
grenade_launcher_routine_ptr_tbl:
    .addr grenade_launcher_routine_00  ; CPU address $9468
    .addr grenade_launcher_routine_01  ; CPU address $9479
    .addr shared_enemy_routine_00      ; CPU address $9346 - soldier has been hit by player bullet
    .addr shared_enemy_routine_01      ; CPU address $9360 - perform enemy hit by bullet animation, then advance routine
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr shared_enemy_routine_03      ; CPU address $e7aa from bank 7
    .addr grenade_launcher_routine_06  ; CPU address $9529

grenade_launcher_routine_00:
    lda #$01                                ; a = #$01
    sta GRENADE_LAUNCHER_FLAG               ; flag that there is a grenade launcher on screen to prevent other enemies from being generated
    jsr set_enemy_var_2_to_closest_x_player ; set closest player (#$00 or #$01) in ENEMY_VAR_2, a, and y
    ldy #$06                                ; y = #$06 (offset specifying grenade launcher configuration)
    jsr init_indoor_enemy_pos_and_vel       ; initialize indoor grenade launcher enemy velocity and position
    lda #$20                                ; a = #$20
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to #$20 and advance enemy routine

grenade_launcher_routine_01:
    lda ENEMY_VAR_3,x
    beq grenade_launcher_apply_vel_aim      ; apply velocities, if animation timer elapsed, aim and set number of grenades to fire
    lda #$96                                ; a = #$96 (sprite_96) - grenade launcher
    sta ENEMY_SPRITES,x                     ; write enemy sprite code to CPU buffer
    dec ENEMY_ANIMATION_DELAY,x             ; decrement animation delay
    bne @launch_grenade_if_appropriate      ; fire if animation timer has elapsed
    lda #$08                                ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x             ; set delay between bullets
    lda #$00                                ; a = #$00
    sta ENEMY_VAR_3,x                       ;
    lda ENEMY_X_POS,x                       ; load enemy x position on screen
    jsr find_far_segment_for_a              ; find the appropriate velocity code, given the X position
    sta $0a                                 ; store enemy segment code in $0a
    jsr set_enemy_var_2_to_closest_x_player ; set closest player (#$00 or #$01) in ENEMY_VAR_2, a, and y
    jsr find_close_segment                  ; get segment number for where player is on screen (#$06 = farthest left, #$00 = farthest right)
    cmp $0a                                 ; compare player and enemy segment
    lda #$00                                ; a = #$00
    bcc @set_direction                      ; branch if player is to the right of the enemy
    lda #$80                                ; player to left of enemy

@set_direction:
    eor ENEMY_X_VELOCITY_FAST,x   ; exclusive or #$80 and the current fast velocity
    bpl @exit                     ; branch if enemy needs to change direction to seek player
    jsr reverse_enemy_x_direction ; reverse x direction

@exit:
    rts

@launch_grenade_if_appropriate:
    lda ENEMY_VAR_1,x        ; see if grenade launcher is in same horizontal segment as player and ready to fire
    beq @launch_grenade_exit ; exit if not ready to fire
    dec ENEMY_ATTACK_DELAY,x ; decrement delay between attacks
    bne @launch_grenade_exit ; exit if attack delay hasn't elapsed
    lda #$14                 ; a = #$14 (delay between grenades, indoor)
    sta ENEMY_ATTACK_DELAY,x ; need to attack, but first reinitialize attack delay
    dec ENEMY_VAR_1,x        ; mark that the grenade has launched
    jmp enemy_launch_grenade ; create a grenade enemy (ENEMY_TYPE #$12)

@launch_grenade_exit:
    rts

; apply velocities, if animation timer elapsed, aim and set number of grenades to fire
grenade_launcher_apply_vel_aim:
    jsr init_sprite_from_frame         ; determine enemy sprite based on ENEMY_FRAME, flip sprite horizontally if running left
    lda ENEMY_X_POS,x                  ; load enemy x position on screen
    ldy ENEMY_X_VELOCITY_FAST,x        ; load enemy fast velocity
    bmi @grenade_launcher_running_left ; branch if enemy is running left
    cmp #$a0                           ; see if enemy position is off the screen to the right
    bcs @cmp_player_enemy_segment      ; if enemy too far to the right
    bcc @apply_vel_and_aim             ; always branch, enemy is running right and not off screen

@grenade_launcher_running_left:
    cmp #$60
    bcc @cmp_player_enemy_segment ; if enemy too far to the left

@apply_vel_and_aim:
    jsr apply_enemy_velocity_set_bg_priority ; apply enemy velocity to position (remove if off screen), set bg priority
    dec ENEMY_ANIMATION_DELAY,x              ; decrement enemy animation frame delay counter
    bne grenade_launcher_exit                ; exit if animation delay hasn't elapsed

; animation delay elapsed
@cmp_player_enemy_segment:
    lda ENEMY_X_POS,x          ; load enemy x position on screen
    jsr find_far_segment_for_a ; find the appropriate velocity code, given the X position
    sta $0a                    ; set enemy segment in $0a
    ldy ENEMY_VAR_2,x          ; player offset to find the segment of
    jsr find_close_segment     ; get segment number for where player is on screen (#$06 = farthest left, #$00 = farthest right)
    ldy #$18                   ; y = #$18 (delay for pause between seeks)
    cmp $0a                    ; see if player and enemy are in same segment
    php                        ; push status flags on to the stack (namely the zero flag)
    bne @set_num_grenades_exit ; branch if player and enemy are in different horizontal segments
    ldy #$38                   ; y = #$38 (delay for resume seek after attack)

@set_num_grenades_exit:
    tya
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    inc ENEMY_VAR_3,x
    lda #$04                    ; a = #$04 (delay before attacking)
    sta ENEMY_ATTACK_DELAY,x    ; set delay between attacks
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    lsr                         ; strip off direction bit
    and #$03                    ; keep bits .... ..xx (number of grenades)
    plp                         ; restore status flags
    beq @set_enemy_var_1        ; player and grenade launcher in same segment, mark as available to fire
    lda #$00                    ; a = #$00 (don't fire grenades)

; set whether or not the grenade launcher is in the same horizontal segment as the player
; meaning the grenade launcher is ready to fire
@set_enemy_var_1:
    sta ENEMY_VAR_1,x ; set number of grenades to fire

grenade_launcher_exit:
    rts

; determine the closest player to the enemy horizontally, then store result in ENEMY_VAR_2, a, and y
; output
;  * ENEMY_VAR_2, y, and a - closest player index (#$00 or #$01)
set_enemy_var_2_to_closest_x_player:
    jsr player_enemy_x_dist ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    lda PLAYER_STATE,y      ; load the player state of the closest player
    cmp #$01                ; see if in normal player state
    beq @set_closest_player
    tya                     ; store closest player in a
    eor #$01                ; swap to other player (flip bit 0)
    tay                     ; move new closest player back to y

@set_closest_player:
    tya               ; move closest player to a
    sta ENEMY_VAR_2,x ; store closest player in ENEMY_VAR_2
    rts

grenade_launcher_routine_06:
    jsr enemy_routine_remove_enemy
    lda #$00                       ; a = #$00
    sta GRENADE_LAUNCHER_FLAG      ; clear flag that there is a grenade launcher on screen
                                   ; allows others enemies to be generated again
    rts

; pointer table for group of 4 (#$8 * #$2 = #$10 bytes)
four_soldiers_routine_ptr_tbl:
    .addr four_soldiers_routine_00     ; CPU address $9541 - initialize soldier
    .addr four_soldiers_routine_01     ; CPU address $954c - walk until timer elapsed begin firing move to four_soldiers_routine_02
    .addr four_soldiers_routine_02     ; CPU address $9582 - waits for delay, get into firing position, set new delay, go back to four_soldiers_routine_01
    .addr shared_enemy_routine_00      ; CPU address $9346 - soldier has been hit by player bullet
    .addr shared_enemy_routine_01      ; CPU address $9360 - perform enemy hit by bullet animation, then advance routine
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr shared_enemy_routine_03      ; CPU address $e7aa from bank 7  - show explosion_type_02
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; initialize soldier
four_soldiers_routine_00:
    ldy #$04                           ; y = #$04
    jsr init_indoor_enemy_pos_and_vel  ; initialize indoor group of 4 soldiers enemy velocity and position
    jsr four_soldiers_set_firing_delay ; set appropriate animation delay
    jmp advance_enemy_routine          ; advance routine to four_soldiers_routine_01

; wait for firing delay, then begin running
four_soldiers_routine_01:
    dec ENEMY_ANIMATION_DELAY,x   ; decrement enemy animation frame delay counter
    bne @fire_if_appropriate      ; branch if delay hasn't elapsed to possibly fire
    lda ENEMY_VAR_2,x             ; animation delay is #$00, load number of fires in current round
    cmp #$01                      ; see if fired already
    bne @set_delay_adv_routine    ; branch haven't fired to continue
    lda ENEMY_VAR_1,x             ; already fired once, load soldier number within the group of four [#$00-#$03]
    cmp #$02                      ; split soldiers so some go left, some go right
    bcc @set_delay_adv_routine    ; continue in same direction for first 2 soldiers
    jsr reverse_enemy_x_direction ; reverse enemy's x direction for other 2 soldiers

@set_delay_adv_routine:
    jsr four_soldiers_get_delay_offset
    lda four_soldiers_delay_running_tbl,y   ; load initial animation delay
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY and advance to four_soldiers_routine_02

; fire if animation delay is #$04 fire, otherwise, just exit
@fire_if_appropriate:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    cmp #$04                    ; compare animation delay to #$04
    bne four_soldiers_exit      ; exit if animation delay isn't #$04
    jmp create_indoor_bullet    ; animation delay is #$04, fire a regular indoor bullet

four_soldiers_exit:
    rts

; table for group of 4 running distances (#$c bytes)
; initial delays before stop
; each column is for the specific soldier within the group of 4
four_soldiers_delay_running_tbl:
    .byte $3f,$39,$33,$2d
    .byte $18,$10,$10,$18 ; delays for second attack, each side
    .byte $ff,$ff,$ff,$ff

; waits for animation delay to elapse, get into firing position, set new delay, go back to four_soldiers_routine_01
four_soldiers_routine_02:
    jsr init_sprite_from_frame               ; determine enemy sprite based on ENEMY_FRAME, flip sprite horizontally if running left
    jsr apply_enemy_velocity_set_bg_priority ; apply enemy velocity to position (remove if off screen), set bg priority
    dec ENEMY_ANIMATION_DELAY,x              ; decrement enemy animation frame delay counter
    bne four_soldiers_exit                   ; exit if animation delay hasn't elapsed
    lda #$96                                 ; animation delay elapsed, set a = #$96 (sprite_96) indoor soldier firing position
    sta ENEMY_SPRITES,x                      ; set enemy sprite to indoor soldier firing position
    inc ENEMY_VAR_2,x                        ; increment the number of times the soldier has fired
    jsr four_soldiers_set_firing_delay       ; set animation delay
    lda #$02                                 ; a = #$02
    jmp set_enemy_routine_to_a               ; set enemy routine index to four_soldiers_routine_01

four_soldiers_set_firing_delay:
    jsr four_soldiers_get_delay_offset   ; determine next delay for soldier and set it to y
    lda four_soldiers_firing_delay_tbl,y ; load appropriate delay
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    rts

; gets the appropriate delay based on how many times the soldier has fired and
; the soldier index within the group of four
; output
;  * y - the four_soldiers_delay_running_tbl and four_soldiers_firing_delay_tbl offset for the enemy
four_soldiers_get_delay_offset:
    lda ENEMY_VAR_2,x ; load number of times the soldier has fired
    asl
    asl               ; double twice since each entry is #$04 bytes
    sta $08           ; store result in $08
    lda ENEMY_VAR_1,x ; load soldier number within the group of four [#$00-#$03]
    clc               ; clear carry in preparation for addition
    adc $08           ; add the soldier index to the row offset to get exact delay offset
    tay               ; transfer offset to y
    rts

; table for group of 4 soldiers standing still to fire delay (#$c bytes)
; each row is are delays for a round of attacks
; each column is for the specific soldier within the group of 4
; used in four_soldiers_routine_00 and four_soldiers_routine_02
four_soldiers_firing_delay_tbl:
    .byte $01,$07,$0d,$13 ; delay before running into screen
    .byte $18,$18,$18,$18 ; delay for firing first shot
    .byte $10,$18,$18,$10 ; delay for firing second shot

; pointer table for rollers generator (#$3 * #$2 = #$6 bytes)
indoor_roller_gen_routine_ptr_tbl:
    .addr indoor_roller_gen_routine_00 ; CPU address $95c8
    .addr indoor_roller_gen_routine_01 ; CPU address $95cd
    .addr remove_enemy                 ; CPU address $e809 from bank 7

indoor_roller_gen_routine_00:
    lda #$60                                ; a = #$60 (delay before first set of rollers)
    jmp set_anim_delay_adv_enemy_routine_00 ; set ENEMY_ANIMATION_DELAY to #$60 and advance enemy routine

indoor_roller_gen_routine_01:
    lda INDOOR_ENEMY_ATTACK_COUNT ; load the total number of enemy attack rounds for the screen
    cmp #$07                      ; total number of cycles for rollers to stop
    bcc @continue                 ; haven't reached total 'rounds' of attack, create roller if timer elapsed
    jmp remove_enemy              ; remove enemy

@continue:
    lda FRAME_COUNTER           ; load frame counter
    lsr
    bcc @exit                   ; ENEMY_ANIMATION_DELAY is decremented every odd frame
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne @exit                   ; exit if ENEMY_ANIMATION_DELAY hasn't elapsed
    lda ENEMY_ATTRIBUTES,x      ; generate roller, load roller generator attributes
    and #$07                    ; keep bits .... .xxx
    asl                         ; double since each entry is #$02 byte memory address
    tay                         ; transfer offset to y
    lda roller_gen_init_tbl,y   ; rollers pattern - low byte
    sta $10                     ; store address low byte in $10
    lda roller_gen_init_tbl+1,y ; rollers pattern - high byte
    sta $11                     ; store address high byte in $11

@create_roller:
    ldy ENEMY_VAR_1,x ; load roller number to generate

@loop:
    lda ($10),y              ; load the first byte
    cmp #$ff
    bne @create_roller_for_a
    ldy #$00                 ; y = #$00
    beq @loop

@create_roller_for_a:
    sta $0b                          ; store first byte in $0b
    and #$0f                         ; keep bits .... xxxx
    sta $0a                          ; store ENEMY_ATTRIBUTES for roller
    iny
    lda ($10),y
    sta ENEMY_ANIMATION_DELAY,x      ; set enemy animation frame delay counter
    iny
    tya
    sta ENEMY_VAR_1,x
    lda $0b
    lsr
    lsr
    lsr
    lsr
    tay
    lda roller_initial_x_pos_tbl,y   ; load the roller's initial x position
    sta $09                          ; store roller x position
    lda #$70                         ; a = #$70 (rollers starting y position)
    sta $08                          ; store roller y position
    tya                              ; move the horizontal segment number into a
    jsr create_roller_with_segment_a ; set roller x velocity based on X position
    lda ENEMY_ANIMATION_DELAY,x      ; load enemy animation frame delay counter
    beq @create_roller

@exit:
    rts

; rollers starting x positions (#$7 bytes)
roller_initial_x_pos_tbl:
    .byte $98,$90,$88,$80,$78,$70,$68

; pointer table for rollers pattern (#$2 * #$2 = #$4 bytes)
roller_gen_init_tbl:
    .addr roller_gen_init_00 ; CPU address $9634
    .addr roller_gen_init_01 ; CPU address $966d

; table for rollers type a (#$39 bytes)
; byte 0 : position and attributes for roller 0
; byte 1 : delay before roller 0
; byte 2 : position and attributes for roller 1
; byte 3 : delay before roller 1
;
; ... 7 times (d bytes) ...
;
; byte d : delay before next set of rollers
;
; ff : end of sets, go from the start
roller_gen_init_00:
    .byte $00,$00
    .byte $10,$00
    .byte $20,$00
    .byte $30,$00
    .byte $40,$00
    .byte $50,$00
    .byte $60,$f0
    .byte $01,$00
    .byte $11,$00
    .byte $21,$00
    .byte $31,$00
    .byte $41,$00
    .byte $51,$00
    .byte $61,$f0
    .byte $30,$10
    .byte $20,$00
    .byte $40,$10
    .byte $10,$00
    .byte $50,$10
    .byte $00,$00
    .byte $60,$f0
    .byte $00,$00
    .byte $60,$10
    .byte $10,$00
    .byte $50,$10
    .byte $20,$00
    .byte $40,$10
    .byte $30,$f0
    .byte $ff

; table for rollers type b (#$f bytes)
roller_gen_init_01:
    .byte $00,$00
    .byte $20,$00
    .byte $40,$00
    .byte $60,$f0
    .byte $10,$00
    .byte $30,$00
    .byte $50,$f0
    .byte $ff

; gets a number from #$06 to #$00 indicating how far the closest player to the enemy is from the left of the screen
; starting from #$06 for farthest left, down to #$00 for farthest right
; input
;  * y - player offset to compare
; output
;  * a - #$00 when player to the right of cutoff, offset when to the left
; very similar to find_far_segment_for_a in bank 7
; usually used together to compare player and enemy x positions on indoor levels
find_close_segment:
    lda SPRITE_X_POS,y ; load the player's x position
    ldy #$06           ; y = #$06

@loop:
    cmp indoor_close_segment_tbl,y
    bcc @exit
    dey
    bmi @use_segment_0
    bcs @loop

@use_segment_0:
    lda #$00 ; a = #$00
    rts

@exit:
    tya
    rts

; table for close segment x offsets (right to left) (#$7 bytes)
indoor_close_segment_tbl:
    .byte $ff,$bc,$a4,$8c,$74,$5c,$44

; initializes indoor enemy velocity and position
; input
;  * a - is indoor enemy type
;   * #$00 - indoor soldier (ENEMY_TYPE #$15)
;   * #$02 - jumping soldier (ENEMY_TYPE #$16)
;   * #$04 - group of 4 soldiers (ENEMY_TYPE #$18)
;   * #$06 - grenade launcher (ENEMY_TYPE #$17)
init_indoor_enemy_pos_and_vel:
    lda indoor_soldier_x_velocity_tbl,y   ; load the enemy's fractional velocity byte
    sta ENEMY_X_VELOCITY_FRACT,x          ; store the enemy's fractional velocity byte
    lda indoor_soldier_x_velocity_tbl+1,y ; load the enemy's velocity high byte
    sta ENEMY_X_VELOCITY_FAST,x           ; store the enemy's velocity high byte
    lda ENEMY_ATTRIBUTES,x                ; load the ENEMY_ATTRIBUTES
    lsr                                   ; shift bit 0 to the carry
    lda #$a8                              ; a = #$a8 (initial x position, from right)
    bcc @set_enemy_pos                    ; if bit 0 is 0 then enemy comes from right screen, branch
    jsr reverse_enemy_x_direction         ; enemy comes from left side, reverse enemy's x direction
    lda #$58                              ; a = #$58 (initial x position, from left)

@set_enemy_pos:
    sta ENEMY_X_POS,x ; set enemy x position on screen
    lda #$6d          ; load y position, hard-coded for indoor levels
    sta ENEMY_Y_POS,x ; set enemy y position on screen
    rts

; table for guys x velocities (#$8 bytes)
; byte 0 - ENEMY_X_VELOCITY_FRACT
; byte 1 - ENEMY_X_VELOCITY_FAST
indoor_soldier_x_velocity_tbl:
    .byte $20,$ff ; indoor soldier (-.875)
    .byte $40,$ff ; jumping soldier (-.75)
    .byte $40,$ff ; group of 4 (-.75)
    .byte $40,$ff ; grenade launcher (-.75)

; apply enemy velocity to position
; use updated position to determine if enemy off screen and removes enemy if so
; use updated position to determine sprite attribute background priority
; (enemy drawn in front or behind background)
apply_enemy_velocity_set_bg_priority:
    lda ENEMY_X_VEL_ACCUM,x
    clc                          ; clear carry in preparation for addition
    adc ENEMY_X_VELOCITY_FRACT,x
    sta ENEMY_X_VEL_ACCUM,x
    lda ENEMY_X_POS,x            ; load enemy x position on screen
    adc ENEMY_X_VELOCITY_FAST,x
    sta ENEMY_X_POS,x            ; set enemy x position on screen
    ldy ENEMY_X_VELOCITY_FAST,x
    bmi @continue
    cmp #$b0                     ; indoor enemy right limit (disappearance)
    bcs @remove_enemy            ; remove enemy if too far to the right
    bcc @set_enemy_bg_priority

@continue:
    cmp #$50                   ; indoor enemy left limit (disappearance)
    bcs @set_enemy_bg_priority

@remove_enemy:
    jmp remove_enemy ; remove enemy

@set_enemy_bg_priority:
    ldy ENEMY_SPRITE_ATTR,x        ; enemy sprite attributes
    cmp #$a0
    bcs @draw_enemy_behind_bg
    cmp #$60
    bcs @draw_enemy_in_front_of_bg

@draw_enemy_behind_bg:
    tya
    ora #$20                   ; set bits ..x. .... (drawn behind bg)
    bne @set_enemy_sprite_attr

@draw_enemy_in_front_of_bg:
    tya
    and #$df ; keep bits xx.x xxxx (drawn in front of bg)

@set_enemy_sprite_attr:
    sta ENEMY_SPRITE_ATTR,x
    rts

; dead code, never called !(UNUSED)
bank_0_unused_label_00:
    jsr set_08_09_to_enemy_pos ; set $08 and $09 to enemy x's Y and X position respectively

; creates an indoor roller enemy (ENEMY_TYPE #$11)
create_roller:
    jsr find_far_segment_for_x_pos ; get horizontal segment based on X position ($09)

; creates an indoor roller enemy (ENEMY_TYPE #$11)
; input
;  * a - roller horizontal segment number (offset into roller_vel_code_tbl)
;  * $09 - x position
;  * $08 - y position
create_roller_with_segment_a:
    sta $0f                         ; store horizontal segment code in $0f
    lda ENEMY_ATTACK_FLAG           ; see if enemies should attack
    beq @exit                       ; exit if enemies shouldn't attack
    jsr find_next_enemy_slot        ; find next available enemy slot, put result in x register
    bne @exit                       ; exit if not enemy slot available to create the roller
    lda #$11                        ; a = #$11 (enemy type code for rollers)
    jsr init_enemy_set_type_and_pos ; initialize enemy, set enemy type to a, and set X ($09) and Y ($08) position
    lda $0a                         ; load ENEMY_ATTRIBUTES
    sta ENEMY_ATTRIBUTES,x
    lda $0f                         ; load velocity code
    asl
    tay
    lda roller_vel_code_tbl,y
    sta ENEMY_X_VELOCITY_FRACT,x
    lda roller_vel_code_tbl+1,y
    sta ENEMY_X_VELOCITY_FAST,x
    lda #$80                        ; a = #$80 (y velocity for rollers, low byte) (.5)
    sta ENEMY_Y_VELOCITY_FRACT,x
    lda #$00                        ; a = #$00 (y velocity for rollers, high byte)
    sta ENEMY_Y_VELOCITY_FAST,x

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; table for rollers x velocities (#$e bytes)
roller_vel_code_tbl:
    .byte $55,$00
    .byte $38,$00
    .byte $1c,$00
    .byte $00,$00
    .byte $e4,$ff
    .byte $c8,$ff
    .byte $ab,$ff

; grenade launcher and indoor soldier
enemy_launch_grenade:
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    jsr find_far_segment_for_x_pos  ; get horizontal segment based on X position ($09)
    sta $0f                         ; store velocity code in $0f
    lda ENEMY_ATTACK_FLAG           ; see if enemies should attack
    beq @exit                       ; exit if enemies shouldn't attack
    jsr find_next_enemy_slot        ; find next available enemy slot, put result in x register
    bne @exit
    lda #$12                        ; a = #$12 (code for grenade)
    jsr init_enemy_set_type_and_pos ; initialize enemy, set enemy type to a, and set X ($09) and Y ($08) position
    lda $0f                         ; load velocity code
    asl
    tay
    lda grenade_vel_code_tbl,y
    sta ENEMY_X_VELOCITY_FRACT,x
    lda grenade_vel_code_tbl+1,y
    sta ENEMY_X_VELOCITY_FAST,x
    lda #$80                        ; a = #$80
    sta ENEMY_Y_VELOCITY_FRACT,x
    lda #$00                        ; a = #$00
    sta ENEMY_Y_VELOCITY_FAST,x

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; table for grenade X velocities (#$e bytes)
grenade_vel_code_tbl:
    .byte $55,$00,$38,$00,$1c,$00,$00,$00,$e4,$ff,$c8,$ff,$ab,$ff

; fire a regular indoor bullet
create_indoor_bullet:
    jsr set_08_09_to_enemy_pos         ; set $08 and $09 to enemy x's X and Y position
    lda $09                            ; load enemy x position
    cmp #$a0                           ; compare to right side of screen
    bcs @exit                          ; if x position is >= #$a0 (right edge of indoor screen), just exit
    cmp #$60                           ; compare to left side of screen
    bcc @exit                          ; if x position is < #$60 (left edge of indoor screen), just exit
    lda ENEMY_ATTACK_FLAG              ; see if enemies should attack
    beq @exit                          ; exit if enemies shouldn't attack
    jsr find_far_segment_for_x_pos     ; get horizontal segment based on X position ($09)
    sta $0f                            ; store segment number in $0f
    jsr find_next_enemy_slot           ; find next available enemy slot, put result in x register
    bne @exit                          ; exit if no enemy slot available
    lda #$01                           ; a = #$01 (bullet enemy type)
    jsr init_enemy_set_type_and_pos    ; initialize bullet enemy, set enemy type to a, and set X ($09) and Y ($08) position
    lda #$03                           ; a = #$03 (indoor regular bullet type)
    sta ENEMY_VAR_1,x                  ; set ENEMY_VAR_1 to #$03
    lda $0f                            ; load horizontal segment
    asl                                ; each entry in table is #$02 bytes (fractional and fast), so double offset
    tay                                ; transfer offset to y
    lda indoor_bullet_velocity_tbl,y   ; load the x fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x       ; store in ENEMY_X_VELOCITY_FRACT
    lda indoor_bullet_velocity_tbl+1,y ; load the x fast velocity
    sta ENEMY_X_VELOCITY_FAST,x        ; store in ENEMY_X_VELOCITY_FAST
    lda #$40                           ; a = #$40 (y velocity of bullet)
    sta ENEMY_Y_VELOCITY_FRACT,x
    lda #$01                           ; a = #$01 (y velocity of bullet)
    sta ENEMY_Y_VELOCITY_FAST,x

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; table for indoor bullet velocity (#$e bytes)
indoor_bullet_velocity_tbl:
    .byte $d4,$00 ; (.83)
    .byte $8d,$00 ; (.55)
    .byte $46,$00 ; (.27)
    .byte $00,$00 ; (0)
    .byte $ba,$ff ; (-.27)
    .byte $73,$ff ; (-.55)
    .byte $2c,$ff ; (-.83)

; initialize enemy, set enemy type to a, and set X ($09) and Y ($08) position
init_enemy_set_type_and_pos:
    sta ENEMY_TYPE,x     ; set enemy type
    jsr initialize_enemy
    lda $08
    sta ENEMY_Y_POS,x    ; enemy y position on screen
    lda $09
    sta ENEMY_X_POS,x    ; set enemy x position on screen
    rts

; Pointer table for Rock Platform Code (#$2 * #$2 = #$4 bytes)
floating_rock_routine_ptr_tbl:
    .addr floating_rock_routine_00 ; CPU address $97e9
    .addr floating_rock_routine_01 ; CPU address $981c

; also used for moving flame enemy
; loads initial velocity, direction, and boundaries for floating rock and moving flames on vertical level
floating_rock_routine_00:
    lda ENEMY_ATTRIBUTES,x                   ; load attributes to determine direction and boundaries
    asl
    tay
    lda rock_moving_flame_init_vel_tbl,y     ; load x fractional velocity value
    sta ENEMY_X_VELOCITY_FRACT,x             ; store x fractional velocity value
    lda rock_moving_flame_init_vel_tbl+1,y   ; load x number of units to move per frame
    sta ENEMY_X_VELOCITY_FAST,x              ; store x number of units to move per frame
    lda rock_moving_flame_boundaries_tbl,y   ; load left X boundary
    sta ENEMY_VAR_2,x                        ; store left boundary in ENEMY_VAR_2
    lda rock_moving_flame_boundaries_tbl+1,y
    sta ENEMY_VAR_1,x                        ; store right boundary in ENEMY_VAR_1
    jsr add_scroll_to_enemy_pos              ; adjust enemy location based on scroll
    jmp advance_enemy_routine

; table for rock platform and moving flame velocities (#$8 bytes)
; byte 0 - x fractional velocity value
; byte 1 - x velocity fast value
rock_moving_flame_init_vel_tbl:
    .byte $80,$ff ; slow (00) rock platform x velocity (move left every other frame)
    .byte $c0,$00 ; fast (01) rock platform x velocity (move right 3 out of every 4 frames)
    .byte $80,$ff ; moving flame going left x velocity (move left every other frame)
    .byte $80,$00 ; moving flame going right x velocity (move right every other frame)

; table for rock platform and moving flame boundaries (#$8 bytes)
; byte 0 - left X boundary
; byte 1 - right X boundary
rock_moving_flame_boundaries_tbl:
    .byte $50,$b0 ; slow (00) rock platform boundaries
    .byte $70,$c0 ; fast (01) rock platform boundaries
    .byte $48,$b8 ; flame going left boundaries
    .byte $48,$b8 ; flame going right boundaries

; update enemy position based on velocity and direction
; see if enemy encountered left or right barrier if so, tell enemy to turn around
floating_rock_routine_01:
    lda #$48            ; a = #$48 (sprite_48) floating rock
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer

; also used by moving flame
update_pos_turn_around_if_needed:
    jsr update_enemy_pos        ; apply velocities and scrolling adjust
    lda ENEMY_X_POS,x           ; load enemy x position on screen
    ldy ENEMY_X_VELOCITY_FAST,x ; see if moving left (#$ff) or right (#$00)
    bmi @compare_left_barrier   ; branch if enemy is moving left
    cmp ENEMY_VAR_1,x           ; enemy moving right; compare X position to right barrier
    bcc @exit                   ; enemy didn't hit barrier, exit
    bcs @turn_around            ; enemy hig barrier, tell them to turn around

@compare_left_barrier:
    cmp ENEMY_VAR_2,x ; compare enemy X position to left barrier position
    bcs @exit         ; enemy didn't hit barrier, exit

@turn_around:
    jmp reverse_enemy_x_direction ; reverse x direction

@exit:
    rts

; pointer table for moving flame (#$2 * #$2 = #$4 bytes)
moving_flame_routine_ptr_tbl:
    .addr floating_rock_routine_00 ; CPU address $97e9
    .addr moving_flame_routine_01  ; CPU address $9840

; update enemy position based on velocity and direction
; see if enemy encountered left or right barrier if so, tell enemy to turn around
; also, set flashing palette
moving_flame_routine_01:
    lda #$49            ; a = #$49 (sprite_49) bridge fire
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer
    lda FRAME_COUNTER   ; load frame counter to enable flashing every #$08 frames
    lsr
    lsr
    lsr
    lsr
    lda #$00            ; default sprite attribute (palette)
    bcc @continue
    lda #$40            ; secondary sprite attribute (palette)

@continue:
    sta ENEMY_SPRITE_ATTR,x              ; set enemy sprite attributes
    jmp update_pos_turn_around_if_needed ; update enemy position and turn around if encountered barrier

; pointer table for falling rock generator (#$3 * #$2 = #$6 bytes)
rock_cave_routine_ptr_tbl:
    .addr rock_cave_routine_00 ; CPU address $985d
    .addr rock_cave_routine_01 ; CPU address $9863
    .addr rock_cave_routine_02 ; CPU address $986b

rock_cave_routine_00:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    jmp advance_enemy_routine   ; advance to next routine

rock_cave_routine_01:
    jsr add_scroll_to_enemy_pos    ; add scrolling to enemy position
    lda #$08                       ; a = #$08 (delay before first falling rock)
    jmp set_anim_delay_adv_routine ; set ENEMY_ANIMATION_DELAY then advance enemy routine to rock_cave_routine_02

rock_cave_routine_02:
    jsr update_enemy_pos        ; apply velocities and scrolling adjust
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne rock_exit
    lda #$e0                    ; a = #$e0 (delay before next falling rock)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$13                    ; a = #$13 (enemy type for falling rock)
    jmp generate_enemy_a        ; generate #$13 enemy (falling rock)

; pointer table for falling rock (#$6 * #$2 = #$c bytes)
falling_rock_routine_ptr_tbl:
    .addr falling_rock_routine_00      ; CPU address $9889 - initialize sprite, set initial delay, advance routine
    .addr falling_rock_routine_01      ; CPU address $988e - wobble left and right until animation delay elapsed, then advance routine
    .addr falling_rock_routine_02      ; CPU address $98ce - actual falling of the rock, and bounce against the ground
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

falling_rock_routine_00:
    lda #$40                       ; a = #$40 (delay before rock starts falling)
    jmp set_anim_delay_adv_routine ; set ENEMY_ANIMATION_DELAY then advance enemy routine to falling_rock_routine_01

; wobble left and right until animation delay elapsed, then advance routine
falling_rock_routine_01:
    jsr falling_rock_set_sprite ; set boulder sprite (sprite_4a)
    jsr update_enemy_pos        ; apply velocities and scrolling adjust
    lda FRAME_COUNTER           ; load frame counter
    and #$03                    ; keep bits .... ..xx
    bne @continue               ; branch if not 4th frame since no rocking/swaying direction change
    lda FRAME_COUNTER           ; frame counter divisible by #$04, reload frame counter
    lsr
    lsr
    lsr                         ; push bit 2 into carry, every #$04 frames rock sways in a direction
    bcc @dec_x_pos              ; branch if rocking left
    inc ENEMY_X_POS,x           ; rocking right, increment enemy x position
    bcs @continue               ; skip decrement if rocking right

; rocking left
@dec_x_pos:
    dec ENEMY_X_POS,x ; enemy x position

; enable collision, set animation delay, wait, advance routine
@continue:
    dec ENEMY_ANIMATION_DELAY,x    ; decrement enemy animation frame delay counter
    bne rock_exit                  ; exit if animation delay hasn't elapsed
    jsr enable_enemy_collision     ; delay elapsed, enable bullet-enemy collision and player-enemy collision checks
    lda #$01                       ; a = #$01
    jmp set_anim_delay_adv_routine ; set ENEMY_ANIMATION_DELAY then advance enemy routine to falling_rock_routine_02

; sets the sprite attribute for the falling rock so it tumbles
falling_rock_set_sprite_and_attr:
    lda FRAME_COUNTER                  ; load frame counter
    lsr
    lsr                                ; moves to next flip every #$04 frames
    and #$03                           ; keep bits .... ..xx
    tay                                ; transfer to y to be falling_rock_sprite_attr_tbl offset
    lda ENEMY_SPRITE_ATTR,x            ; load enemy sprite attributes
    and #$3f                           ; strip horizontal and vertical flip bits
    ora falling_rock_sprite_attr_tbl,y ; load whether the rock needs to be reflected
    sta ENEMY_SPRITE_ATTR,x            ; set enemy sprite attributes

falling_rock_set_sprite:
    lda #$4a            ; a = #$4a (sprite_4a - boulder)
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer

rock_exit:
    rts

; actual falling of the rock, and bounce against ground
falling_rock_routine_02:
    jsr falling_rock_set_sprite_and_attr ; set the sprite attribute so the rock tumbles
    lda ENEMY_Y_POS,x                    ; load enemy y position on screen
    cmp ENEMY_VAR_1,x                    ; compare y position to the ground collision y position
    bcc @apply_gravity_update_pos        ; branch if rock is still above where it collided with the ground
    ldy #$08                             ; rock below the ground it collided with, check for next collision
    jsr add_y_to_y_pos_get_bg_collision  ; add #$08 to enemy y position and gets bg collision code
    bcc @apply_gravity_update_pos        ; branch if no floor collision
    lda #$05                             ; collision with floor, a = #$05 (sound_05)
    jsr play_sound                       ; play sound of rock hitting ground
    lda #$40                             ; a = #$40
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    lda ENEMY_Y_POS,x                    ; load enemy y position on screen
    clc                                  ; clear carry in preparation for addition
    adc #$10                             ; add #$10 to get y position of ground
    bcc @continue                        ; branch if no overflow occurred (not offscreen)
    lda #$ff                             ; off screen, set y position to #$ff

; set y velocity to -1.25
@continue:
    sta ENEMY_VAR_1,x            ; set ENEMY_VAR_1 to ground y position
    lda #$c0                     ; a = #$c0 (.75) (y velocity for rock bouncing, low)
    sta ENEMY_Y_VELOCITY_FRACT,x
    lda #$fe                     ; a = #$fe (-2) (y velocity for rock bouncing, high)
    sta ENEMY_Y_VELOCITY_FAST,x  ; combined the total velocity is -1.25

@apply_gravity_update_pos:
    jsr add_10_to_enemy_y_fract_vel ; add #$10 to y fractional velocity (.06 faster) (applying gravity)
    lda ENEMY_VAR_1,x               ; load rock ground collision y position
    clc                             ; clear carry in preparation for addition
    adc FRAME_SCROLL                ; how much to scroll the screen (#00 - no scroll)
    bcc @update_pos                 ; branch if no carry to set ENEMY_VAR_1 and update position
    lda #$ff                        ; a = #$ff

@update_pos:
    sta ENEMY_VAR_1,x    ; adjust by scroll position
    jmp update_enemy_pos ; apply velocities and scrolling adjust

; table for falling rock mirroring codes (#$4 bytes)
; $00 - no flip
; $40 - flip horizontally
; $c0 - flip horizontally and vertically
; $80 - flip vertically
falling_rock_sprite_attr_tbl:
    .byte $00,$40,$c0,$80

; pointer table for level 3 boss mouth (dragon) (#$9 * #$2 = #$12 bytes)
boss_mouth_routine_ptr_tbl:
    .addr boss_mouth_routine_00             ; CPU address $992a
    .addr boss_mouth_routine_01             ; CPU address $9941
    .addr boss_mouth_routine_02             ; CPU address $9954
    .addr boss_mouth_routine_03             ; CPU address $99a2
    .addr boss_mouth_routine_04             ; CPU address $99ef
    .addr boss_defeated_routine             ; CPU address $e740 from bank 7
    .addr enemy_routine_explosion           ; CPU address $e7b0 from bank 7
    .addr shared_enemy_routine_clear_sprite ; CPU address $e814 from bank 7 - set tile sprite code to #$00 and advance routine
    .addr boss_mouth_routine_08             ; CPU address $9a14

; set HP, frame, animation/attack delay, advance routine
boss_mouth_routine_00:
    lda #$20          ; a = #$20
    sta ENEMY_VAR_1,x ; level 3 boss mouth hp
    lda #$02          ; a = #$02
    sta ENEMY_VAR_3,x ; set flag so when dragon is destroyed, the animation is
                      ; delayed by one frame.  See `boss_mouth_routine_08`
    lda #$01          ; a = #$01
    sta ENEMY_FRAME,x ; set enemy animation frame number
    lda #$ff          ; a = #$ff (positive delay before first attack)

; used by boss mouth, rock cave, and falling rock
set_anim_delay_adv_routine:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jmp advance_enemy_routine

; wait for boss auto scroll to complete, wait for animation delay to elapse, advance routine
boss_mouth_routine_01:
    jsr add_scroll_to_enemy_pos   ; adjust enemy location based on scroll
    lda BOSS_AUTO_SCROLL_COMPLETE ; see if boss reveal auto-scroll has completed
    beq boss_mouth_exit           ; exit if boss reveal auto-scroll hasn't completed
    lda BG_PALETTE_ADJ_TIMER
    bne boss_mouth_exit
    dec ENEMY_ANIMATION_DELAY,x   ; decrement enemy animation frame delay counter
    bne boss_mouth_exit           ; exit if animation delay hasn't elapsed
    jmp advance_enemy_routine     ; advance to boss_mouth_routine_02

; animate opening of mouth
boss_mouth_routine_02:
    jsr boss_mouth_draw_supertiles_set_delay
    bcs boss_mouth_exit                      ; exit if didn't need to draw updates super-tiles
    lda ENEMY_FRAME,x                        ; updated super-tiles, load enemy animation frame number
    cmp #$02
    bcs boss_mouth_enable_collision          ; boss mouth is open, enable collision, set attack delay, advance routine
    inc ENEMY_FRAME,x                        ; increment enemy animation frame number

boss_mouth_exit:
    rts

boss_mouth_enable_collision:
    jsr enable_bullet_enemy_collision ; allow bullets to collide (and stop) upon colliding with boss mouth
    lda ENEMY_VAR_1,x
    sta ENEMY_HP,x                    ; set enemy hp
    lda #$06                          ; a = #$06
    sta ENEMY_ATTACK_DELAY,x          ; delay between mouth open and attack
    lda #$70                          ; a = #$70 (time during which mouth is open)
    bne set_anim_delay_adv_routine    ; set ENEMY_ANIMATION_DELAY then advance enemy routine to boss_mouth_routine_03

boss_mouth_draw_supertiles_set_delay:
    jsr add_scroll_to_enemy_pos             ; adjust enemy location based on scroll
    dec ENEMY_ANIMATION_DELAY,x             ; decrement enemy animation frame delay counter
    bne @set_carry_exit                     ; exit if animation delay timer hasn't elapsed
    lda ENEMY_FRAME,x                       ; load enemy animation frame number
    asl                                     ; double since each entry is #$02 bytes
    tay                                     ; transfer offset to y
    lda boss_mouth_nametable_update_tbl,y   ; load first nametable update super-tile index
    sta $10                                 ; store in $10 for update_2_enemy_supertiles
    lda boss_mouth_nametable_update_tbl+1,y ; load second nametable update super-tile index
    ldy #$01                                ; y = #$01, skip setting collision
    jsr update_2_enemy_supertiles           ; draw nametable update super-tile $10, then a at enemy position
    lda #$06                                ; a = #$06
    bcc @set_anim_exit                      ; (delay between frames when animating mouth open/close)
    lda #$01                                ; a = #$01

@set_anim_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    rts

@set_carry_exit:
    sec ; set carry flag
    rts

; table for nametable update super-tile indexes (#$6 bytes)
; offsets into level_3_nametable_update_supertile_data
; related to closed/closing mouth nametable tiles
; #$20 (#$a0) - boss mouth closed (top half)
; #$21 (#$a1) - boss mouth closed (bottom half)
; #$22 (#$a2) - boss mouth partially open (top half)
; #$23 (#$a3) - boss mouth partially open (bottom half)
; #$24 (#$a4) - boss mouth fully open (top half)
; #$25 (#$a4) - boss mouth fully open (bottom half)
boss_mouth_nametable_update_tbl:
    .byte $a0,$a1 ; closed
    .byte $a2,$a3 ; partially open
    .byte $a4,$a5 ; fully open

boss_mouth_routine_03:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    lda ENEMY_ATTACK_DELAY,x    ; load delay between attacks
    beq @adv_routine
    dec ENEMY_ATTACK_DELAY,x    ; decrement delay between attacks
    bne @adv_routine
    lda #$02                    ; a = #$02
    sta $16                     ; number of projectiles

@projectile_loop:
    ldy #$08                          ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda #$00                          ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos            ; stores absolute screen x position in $09, and y position in $08
    ldy #$06                          ; y = #$06 (bullet speed)
    lda BOSS_SCREEN_ENEMIES_DESTROYED ; load number of destroyed dragon arm orbs
    cmp #$02                          ; see if both arms have been destroyed
    bcc @continue                     ; branch if at least one dragon arm orb still exists
    ldy #$07                          ; both dragon arm orbs destroyed, increase bullet speed to #$07 (bullet speed)

@continue:
    sty $0f
    ldy $16
    lda mouth_projectile_type_angle,y ; load mouth projectile type (xxx. ....) and angle index (...x xxxx)
    ldy $0f                           ; load mouth projectile speed
    jsr create_enemy_bullet_angle_a   ; create a bullet with speed y, bullet type a, angle a at position ($09, $08)
    dec $16
    bpl @projectile_loop

@adv_routine:
    dec ENEMY_ANIMATION_DELAY,x        ; decrement enemy animation frame delay counter
    bne boss_mouth_exit
    jsr disable_bullet_enemy_collision ; allow bullets to travel through boss mouth
    lda ENEMY_HP,x                     ; load enemy hp
    sta ENEMY_VAR_1,x                  ; store enemy hp here while it's closed
    lda #$f1                           ; a = #$f1 (f1 = hittable, no damage)
    sta ENEMY_HP,x                     ; set enemy hp
    lda #$06                           ; a = #$06
    jmp set_anim_delay_adv_routine     ; set ENEMY_ANIMATION_DELAY then advance enemy routine to boss_mouth_routine_04

; table for mouth projectiles types and angles (#$3 bytes)
; from 3h, clockwise
; $00-$17: white bullets
; $20-$37: bomb drop (like level 1 boss bomb turret)
; $40-$57: red bullets (like base triple cannon)
; $60-$77: white bullets with limited range
; $80-$97: orange fireballs (default)
mouth_projectile_type_angle:
    .byte $88,$86,$84

boss_mouth_routine_04:
    jsr boss_mouth_draw_supertiles_set_delay
    bcs @exit
    lda ENEMY_FRAME,x                        ; load enemy animation frame number
    beq @set_mouth_delay
    dec ENEMY_FRAME,x                        ; decrement enemy animation frame number

@exit:
    rts

@set_mouth_delay:
    lda BOSS_SCREEN_ENEMIES_DESTROYED ; load number of destroyed dragon arm orbs
    cmp #$02                          ; see if both arms have been destroyed
    bcc @continue                     ; branch if at least one dragon arm orb still exists
    lda #$02                          ; both dragon arms destroyed, ensure a = #$02, should already be #$02

@continue:
    tay                             ; transfer delay offset to y
    lda boss_mouth_anim_delay_tbl,y
    sta ENEMY_ANIMATION_DELAY,x     ; set enemy animation frame delay counter
    lda #$03                        ; a = #$03
    jmp set_enemy_routine_to_a      ; set enemy routine index to boss_mouth_routine_02
                                    ; to begin wait to open mouth

; table for delays between mouth attacks, depends on number of dragon arms (#$3 bytes)
; #$c0 delay with 2 arms
; #$70 delay with 1 arm
; #$20 delay without arms
boss_mouth_anim_delay_tbl:
    .byte $c0,$70,$20

; draw explosions
boss_mouth_routine_08:
    dec ENEMY_VAR_3,x                       ; decrement variable to not start explosion until next iteration
    bne @exit                               ; exit if ENEMY_VAR_3 is not #$00
    lda #$01                                ; a = #$01
    sta ENEMY_VAR_3,x
    jsr @update_nametable_create_explosions
    bcs @exit                               ; exit if unable to create explosion
    inc ENEMY_VAR_2,x                       ; increment current explosion counter
    lda ENEMY_VAR_2,x
    cmp #$0e                                ; see if have generated all explosions
    bcs @set_delay_remove                   ; remove enemy all explosions have been generated

@exit:
    rts

@set_delay_remove:
    lda #$60                   ; a = #$60
    jmp set_delay_remove_enemy

@update_nametable_create_explosions:
    ldy ENEMY_VAR_2,x
    lda boss_mouth_y_pos_tbl,y
    sta ENEMY_Y_POS,x                               ; enemy y position on screen
    lda boss_mouth_x_pos_tbl,y
    sta ENEMY_X_POS,x                               ; set enemy x position on screen
    lda boss_mouth_destroyed_nametable_update_tbl,y
    jsr draw_enemy_supertile_a                      ; draw super-tile a (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs @draw_failed_exit                           ; exit when unable to update super-tile
    ldy ENEMY_VAR_2,x                               ; load current explosion counter
    lda boss_mouth_y_pos_tbl,y                      ; load explosion y position
    sta $08                                         ; store explosion y position in $80
    lda boss_mouth_x_pos_tbl,y                      ; load explosion x position
    sta $09                                         ; store explosion x position in $09
    jsr create_two_explosion_89                     ; create explosion #$89 at location ($09, $08)
    clc                                             ; indicate successfully created explosions
    rts

@draw_failed_exit:
    lda #$01
    sta ENEMY_VAR_3,x ; unnecessary since already #$01
    rts

; tables for explosions and replacing nametable super-tiles (after level 3 boss)
; y positions (#$e bytes)
boss_mouth_y_pos_tbl:
    .byte $20,$20,$20,$20,$40,$40,$60,$60,$80,$80,$a0,$a0,$c0,$c0

; x positions (#$e bytes)
boss_mouth_x_pos_tbl:
    .byte $50,$b0,$70,$90,$70,$90,$70,$90,$70,$90,$70,$90,$70,$90

; nametable update super-tile indexes (#$e bytes)
; offset into level_3_nametable_update_supertile_data or level_3_nametable_update_palette_data
boss_mouth_destroyed_nametable_update_tbl:
    .byte $19,$19,$19,$19,$1a,$1b,$29,$2a,$1c,$1d,$1e,$1f,$26,$27

; pointer table for dragon arm orb (#$8 * #$2 = #$10 bytes)
dragon_arm_orb_routine_ptr_tbl:
    .addr dragon_arm_orb_routine_00    ; CPU address $9a9c - variable initialization
    .addr dragon_arm_orb_routine_01    ; CPU address $9ac5
    .addr dragon_arm_orb_routine_02    ; CPU address $9b63 - dragon arms extending outward animation
    .addr dragon_arm_orb_routine_03    ; CPU address $9c03 - dragon arms attack patterns, only executes code for shoulder orbs
    .addr dragon_arm_orb_routine_04    ; CPU address $9edd - dragon arm orb destroyed routine
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; variable initialization
dragon_arm_orb_routine_00:
    lda ENEMY_ATTRIBUTES,x ; load ENEMY_ATTRIBUTES
    lsr                    ; shift bit 0 to the carry flag (dragon arm side)
    lda #$38               ; a = #$38 (position index)
    ldy #$08               ; used for enemy x adjustment
    bcc @continue          ; continue if right arm
    lda #$28               ; left arm ball, a = #$28 (position index)
    ldy #$f8               ; used for enemy x adjustment (-8)

@continue:
    sta ENEMY_VAR_1,x         ; set position index (see dragon_arm_orb_pos_tbl)
    sta ENEMY_VAR_A,x         ; set position index (see dragon_arm_orb_pos_tbl)
    tya                       ; transfer x adjustment to a
    jsr add_a_to_enemy_x_pos  ; adjust enemy x position on screen
    lda #$ff                  ; a = #$ff
    sta ENEMY_VAR_4,x         ; set previous dragon arm orb index to #$ff (shoulder)
    lda #$04                  ; a = #$04 (number of child dragon arm orbs to spawn)
    sta ENEMY_FRAME,x         ; set number of child dragon arm orbs to spawn
    txa
    sta ENEMY_VAR_2,x
    jmp advance_enemy_routine ; advance routine to dragon_arm_orb_routine_01

dragon_arm_orb_routine_01:
    jsr add_scroll_to_enemy_pos      ; adjust enemy location based on scroll
    lda BOSS_AUTO_SCROLL_COMPLETE    ; see if boss reveal auto-scroll has completed
    beq @exit                        ; exit if scrolling isn't complete
    lda BG_PALETTE_ADJ_TIMER         ; boss reveal auto-scroll complete, load BG_PALETTE_ADJ_TIMER
    bne @exit
    lda ENEMY_VAR_4,x                ; load ENEMY_VAR_4 to see if parent dragon arm orb
    bmi @create_child_dragon_arm_orb ; if parent dragon arm orb, spawn and initialize another dragon arm orb
                                     ; once spawned all child dragon arm orbs, advance all their routines

@exit:
    rts

; only called from left and right parent dragon arm orbs to generate the entire arm
@create_child_dragon_arm_orb:
    jsr find_next_enemy_slot       ; find next available enemy slot, put result in x register
    bne @set_slot_exit             ; exit if no enemy slot available
    lda #$15                       ; enemy slot found, a = #$15 (dragon arm orb)
    sta ENEMY_TYPE,x               ; set enemy type to dragon arm orb
    jsr initialize_enemy           ; initialize dragon arm orb
    jsr @init_child_dragon_arm_orb ; initialize dragon arm orb specific variables
    stx $10                        ; store spawn dragon arm orb enemy slot index in $10
    ldx ENEMY_CURRENT_SLOT         ; restore parent dragon arm orb slot index
    dec ENEMY_FRAME,x              ; decrement number of child dragon arm orbs to spawn
    bne @set_slot_exit             ; exit if enemy frame isn't #$00
    ldy $10                        ; spawned all dragon arm orbs for side
                                   ; continue to initialize red dragon arm orb and advance all arms enemy routines
                                   ; load last spawned dragon arm orb enemy slot index (red dragon arm orb)
    lda #$ff                       ; a = #$ff
    sta ENEMY_VAR_3,y              ; set spawned dragon arm orb ENEMY_VAR_3 to #$ff to signify it's the 'hand' (red dragon arm orb)
    lda #$10                       ; a = #$10
    sta ENEMY_HP,y                 ; set hand orb enemy hp (red dragon arm orb)
    lda #$0c                       ; a = #$0c
    sta ENEMY_STATE_WIDTH,y        ; set hand orb collision box type, and explosion type (red dragon arm orb)
    lda #$01                       ; a = #$01
    sta ENEMY_VAR_2,y              ; set hand orb ENEMY_VAR_2 (red dragon arm orb)
    lda #$20                       ; a = #$20 (delay before arms appear)
    sta ENEMY_ANIMATION_DELAY,y    ; set spawned enemy dragon arm orb animation frame delay counter
    tya                            ; transfer spawned enemy dragon arm orb slot index to a
    sta ENEMY_X_VELOCITY_FRACT,x   ; set fractional velocity based on enemy slot index

@loop:
    jsr advance_enemy_routine ; advance dragon arm orb enemy routine to dragon_arm_orb_routine_02
    lda ENEMY_VAR_3,x         ; load next enemy dragon arm orb slot to advance the routine of
    tax                       ; transfer enemy slot index of linked dragon arm orb to x
    bpl @loop                 ; if not last orb (red orb) continue to advance the next orb's routine
    ldx ENEMY_CURRENT_SLOT    ; load parent orb slot index
    lda #$00                  ; a = #$00
    sta ENEMY_VAR_2,x
    sta ENEMY_FRAME,x         ; set enemy animation frame number to #$00

@set_slot_exit:
    ldx ENEMY_CURRENT_SLOT ; restore parent dragon arm orb slot index
    rts

; input
;  * x - enemy slot
@init_child_dragon_arm_orb:
    lda #$02                    ; a = #$02 (dragon_arm_orb_routine_01)
    sta ENEMY_ROUTINE,x         ; set enemy slot to dragon_arm_orb_routine_01
    lda #$8c                    ; a = #$8c
    sta ENEMY_STATE_WIDTH,x     ; set bit 7, 3, 2. explosion type, enable sound on collision, allow bullets to fly through
    lda #$52                    ; a = #$52 (last nibble determines size)
    sta ENEMY_SCORE_COLLISION,x ; score code 5 (2,000 points), collision code 2
    lda #$f1                    ; a = #$f1
    sta ENEMY_HP,x              ; set enemy hp to #$f1 (241)
    lda #$00                    ; a = #$00
    sta ENEMY_VAR_1,x
    ldy ENEMY_CURRENT_SLOT      ; load parent orb
    lda ENEMY_ATTRIBUTES,y      ; load parent dragon arm orb attributes
    sta ENEMY_ATTRIBUTES,x      ; set dragon arm orb part attribute so it's the same side
    lda ENEMY_Y_POS,y           ; load enemy y position on screen
    sta ENEMY_Y_POS,x           ; copy parent dragon arm orb y position
    lda ENEMY_X_POS,y           ; load enemy x position on screen
    sta ENEMY_X_POS,x           ; copy parent dragon arm orb enemy x position on screen
    lda ENEMY_VAR_2,y
    sta ENEMY_VAR_4,x           ; set parent dragon arm orb ENEMY_VAR_2 into ENEMY_VAR_4
    sta $08
    txa
    sta ENEMY_VAR_2,y
    ldy $08
    sta ENEMY_VAR_3,y           ; set child dragon arm orb
    rts

; dragon arms extending outward animation
dragon_arm_orb_routine_02:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @set_pos_and_delay
    lda FRAME_COUNTER           ; load frame counter
    lsr
    bcc @exit
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter

@exit:
    rts

@set_pos_and_delay:
    lda ENEMY_VAR_2,x
    beq @exit2
    jsr dragon_arm_orb_set_sprite ; set dragon arm orb sprite, either sprite_7a (gray) or sprite_7b (red)
    jsr @set_pos_add_accum
    lda ENEMY_VAR_2,x
    bmi @exit2
    inc ENEMY_VAR_2,x
    lda ENEMY_VAR_2,x
    cmp #$10
    bcc @exit2
    lda #$ff                      ; a = #$ff
    sta ENEMY_VAR_2,x
    ldy ENEMY_VAR_4,x             ; load parent orb in y
    lda #$01                      ; a = #$01
    sta ENEMY_VAR_2,y
    lda #$00                      ; a = #$00
    sta ENEMY_ANIMATION_DELAY,y   ; set animation delay for parent orb
    lda ENEMY_VAR_4,y             ; load parent orb of parent orb
    bpl @set_enemy_slot_exit      ; restore x to current enemy slot and exit
    tya
    tax

; arms fully extended, advance orb routines
@adv_routine_exit:
    jsr advance_enemy_routine ; advance arm orb routine in slot x
                              ; !(BUG?) doesn't check what enemy routine the orb is currently on before updating
                              ; usually each orb will be in dragon_arm_orb_routine_02, but if the hand orb
                              ; was destroyed in the previous frame, the routine will be dragon_arm_orb_routine_04
                              ; this causes the dragon_arm_orb_routine_04 routine to not be executed, which will
                              ; cause the game to freeze due to an infinite loop
    lda #$00                  ; a = #$00
    sta ENEMY_VAR_2,x
    lda ENEMY_VAR_3,x         ; load child arm orb
    tax
    bpl @adv_routine_exit     ; loop to advance arm orb routine of child
    ldx ENEMY_CURRENT_SLOT
    lda #$00                  ; a = #$00
    sta ENEMY_FRAME,x         ; set enemy animation frame number

@set_enemy_slot_exit:
    ldx ENEMY_CURRENT_SLOT

@exit2:
    rts

@set_pos_add_accum:
    lda ENEMY_ATTRIBUTES,x           ; load enemy attributes
    and #$01                         ; keep bit 0 (left or right arm)
    asl
    asl                              ; quadruple since each entry is #$04 bytes
    tay                              ; transfer to animation table offset
    lda dragon_arm_open_anim_tbl,y   ; load y velocity accumulator adjustment
    clc                              ; clear carry in preparation for addition
    adc ENEMY_Y_VEL_ACCUM,x
    sta ENEMY_Y_VEL_ACCUM,x
    lda dragon_arm_open_anim_tbl+1,y
    adc ENEMY_Y_POS,x
    sta ENEMY_Y_POS,x                ; enemy y position on screen
    lda dragon_arm_open_anim_tbl+2,y
    clc                              ; clear carry in preparation for addition
    adc ENEMY_X_VEL_ACCUM,x
    sta ENEMY_X_VEL_ACCUM,x
    lda dragon_arm_open_anim_tbl+3,y
    adc ENEMY_X_POS,x                ; add to enemy x position on screen
    sta ENEMY_X_POS,x                ; set enemy x position on screen
    rts

; table for dragon arm extending out animation values (#$8 bytes)
; byte 0 - y velocity accumulator adjustment
; byte 1 - y position adjustment
; byte 2 - x velocity accumulator adjustment
; byte 3 - x position adjustment
dragon_arm_open_anim_tbl:
    .byte $4b,$ff,$b5,$00 ; right arm - go up one pixel
    .byte $4b,$ff,$4b,$ff ; left arm - go up one pixel, go left one pixel

; set dragon arm orb sprite, either sprite_7a (gray) or sprite_7b (red)
dragon_arm_orb_set_sprite:
    lda #$7a             ; a = #$7a (sprite_7a) dragon arm interior orb (gray)
    ldy ENEMY_VAR_3,x    ; load the child dragon arm orb to see if its a hand (red orb)
    bpl @set_sprite_exit ; branch if not #$ff (red orb) to keep gray sprite
    lda #$7b             ; a = #$7b (sprite_7b) dragon arm hand orb (red)

@set_sprite_exit:
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer
    rts

; dragon arms attack patterns, only executes code for shoulder orbs
dragon_arm_orb_routine_03:
    jsr dragon_arm_orb_set_sprite ; set dragon arm orb sprite, either sprite_7a (gray) or sprite_7b (red)
    lda ENEMY_VAR_4,x             ; load to see which orb this is
    bmi @continue                 ; continue if shoulder orb, otherwise do nothing
    rts

@continue:
    jsr dragon_arm_orb_attack_pat ; run appropriate logic based on attack pattern (ENEMY_FRAME)
    lda ENEMY_FRAME,x             ; load enemy animation frame number
    cmp #$04                      ; compare to #$04 (arm seeking player, reaching down)
    beq @set_positions_exit       ; branch if attack pattern is arm seeking player, reaching down
    jsr dragon_arm_animate        ; executed for all except ENEMY_FRAME #$04 (arm seeking player)

@set_positions_exit:
    jmp dragon_arm_orb_set_positions

; dead code, never called !(UNUSED)
bank_0_unused_label_01:
    bmi dragon_arm_open_anim_tbl ; .byte $30,$d0

dragon_arm_orb_attack_pat:
    ldy ENEMY_FRAME,x                      ; load attack pattern, e.g. #$00 - wave up and down, #$01 - spin towards center, etc.
    bne dragon_arm_orb_pat_1_2_3_or_4      ; branch if not the wave arms up and down pattern
    jsr dragon_arm_orb_fire_projectile     ; ENEMY_FRAME #$00 wave arm up and down
                                           ; fire projectile if shoulder dragon arm orb's ENEMY_VAR_A timer has elapsed
    lda ENEMY_ATTRIBUTES,x                 ; load enemy attributes
    and #$01                               ; keep bit 0 (which side of dragon the arm is)
    tay                                    ; transfer to offset register
    lda ENEMY_Y_VELOCITY_FRACT,x           ; 1 = dragon arm wave up, 0 = wave down
                                           ; not actually used to move shoulder dragon arm orb
    bne @hand_below_shoulder               ; branch if hands are below the shoulder
    lda ENEMY_VAR_1,x                      ; hands above shoulder, load position index
    cmp wave_direction_up_change_tbl,y     ; compare to value that determines when to change direction
    beq @set_delay_swap_dir                ; see if need to change direction
    lda dragon_arm_orb_pattern_timer_tbl,y ; load timer for given side of the dragon
    sta ENEMY_VAR_2,x
    rts

; dragon arm orb 'wave arms up and down' attack pattern (ENEMY_FRAME = #$00)
@hand_below_shoulder:
    lda ENEMY_VAR_1,x                        ; load height of red arm ??
    cmp wave_direction_down_change_tbl,y     ; see if arm should change direction
    beq @wave_in_other_direction             ; branch if ENEMY_VAR_1 has value to cause change in directions
    lda dragon_arm_orb_pattern_timer_tbl+1,y ; load timer for given side of the dragon
    sta ENEMY_VAR_2,x
    rts

@wave_in_other_direction:
    inc ENEMY_ATTACK_DELAY,x ;
    lda ENEMY_ATTACK_DELAY,x ; load delay between attacks
    cmp #$03
    bne @set_delay_swap_dir
    inc ENEMY_FRAME,x        ; move to next attack pattern (#$01 - spin toward center)

@set_delay_swap_dir:
    lda #$03                     ; a = #$03
    sta ENEMY_ANIMATION_DELAY,x  ; set enemy animation frame delay counter
    lda ENEMY_Y_VELOCITY_FRACT,x
    eor #$01                     ; flip bits .... ...x
    sta ENEMY_Y_VELOCITY_FRACT,x
    rts

; table for ENEMY_VAR_1 trigger point to change waving direction (#$2 bytes)
; byte 0 - right screen of dragon arm value
; byte 1 - left screen of dragon arm value
wave_direction_up_change_tbl:
    .byte $14,$0c

; table for ENEMY_VAR_1 trigger point to change waving direction (#$2 bytes)
; byte 0 - right screen of dragon arm value
; byte 1 - left screen of dragon arm value
wave_direction_down_change_tbl:
    .byte $2c,$34

; used for ENEMY_FRAME #00 and #$02 to set ENEMY_VAR_2 (rotation timer)
dragon_arm_orb_pattern_timer_tbl:
    .byte $40,$c0,$40

dragon_arm_orb_pat_1_2_3_or_4:
    dey                                ; decrement from loaded ENEMY_FRAME
    bne dragon_arm_orb_pat_2_3_or_4    ; branch if ENEMY_FRAME is not #$01 (spin toward center)
    jsr dragon_arm_orb_fire_projectile ; ENEMY_FRAME is #$01 (spin toward center)
                                       ; fire projectile if shoulder dragon arm orb's ENEMY_VAR_A timer has elapsed
    lda ENEMY_Y_VELOCITY_FAST,x        ; load merged value of all orb ENEMY_VAR_2 timers
    bne @exit                          ; exit without advancing ENEMY_FRAME if all rotation timers are not yet elapsed
    inc ENEMY_FRAME,x                  ; increment enemy animation frame number (attack pattern)

@exit:
    rts

dragon_arm_orb_pat_2_3_or_4:
    dey                                ; decrement from loaded ENEMY_FRAME
    bne dragon_arm_orb_pat_3_or_4      ; branch if ENEMY_FRAME is not #$02 (spin away from center)
    jsr dragon_arm_orb_fire_projectile ; ENEMY_FRAME is #$02 (spin away from center)
                                       ; fire projectile if shoulder dragon arm orb's ENEMY_VAR_A timer has elapsed
    lda ENEMY_ATTRIBUTES,x             ; load enemy attributes
    and #$01                           ; keep bit 0 (which side of dragon the arm is)
    sta $08                            ; store side into $08 (0 = right side of screen, 1 = left side of screen)
    lda ENEMY_VAR_3,x                  ; load next arm orb (farther from body) enemy slot index
    tax                                ; transfer to x

@frame_02_arm_orb_loop:
    ldy $08                                ; load the arm side (0 = right side of screen, 1 = left side of screen)
    lda ENEMY_VAR_1,x
    cmp dragon_arm_frame_02_tbl,y
    beq @next_arm_orb
    lda dragon_arm_orb_pattern_timer_tbl,y
    sta ENEMY_VAR_2,x
    ldx ENEMY_CURRENT_SLOT                 ; restore dragon arm shoulder orb enemy slot index
    rts

@next_arm_orb:
    lda ENEMY_VAR_3,x          ; load next dragon arm orb (farther from body) enemy slot index
    bmi @frame_02_exit         ; branch if next dragon arm orb is the red hand
    tax                        ; move next dragon arm orb enemy slot index to x
    bpl @frame_02_arm_orb_loop

@frame_02_exit:
    ldx ENEMY_CURRENT_SLOT
    lda RANDOM_NUM                       ; load random number
    adc FRAME_COUNTER
    and #$03                             ; keep bits .... ..xx
    tay
    lda dragon_arm_delay_tbl,y
    bne dragon_arm_orb_03_set_delay_exit ; always branch

; table for ENEMY_VAR_1 trigger points for when ENEMY_FRAME is #$02 (spin away from center) (#$2 bytes)
; byte 0 - right side of screen
; byte 1 - left side of screen
dragon_arm_frame_02_tbl:
    .byte $08,$38

; table for ? (#$4 bytes)
dragon_arm_delay_tbl:
    .byte $40,$60,$30,$70

; see if ENEMY_FRAME is #$03 or #$04 and execute appropriate logic
; then decrement delay that controls moving to next attack pattern (ENEMY_FRAME)
dragon_arm_orb_pat_3_or_4:
    dey                                ; decrement from loaded ENEMY_FRAME
    bne dragon_arm_orb_seek_player     ; branch if ENEMY_FRAME is not #$03 (hook shape)
                                       ; i.e. ENEMY_FRAME = #$04 (arm seeking player, reaching down)
    jsr dragon_arm_orb_fire_projectile ; ENEMY_FRAME is #$03 (hook shape)
                                       ; fire projectile if shoulder dragon arm orb's ENEMY_VAR_A timer has elapsed
    dec ENEMY_ATTACK_DELAY,x           ; decrement delay to control moving to next ENEMY_FRAME attack pattern
    bne dragon_arm_orb_03_exit         ; exit if attack delay hasn't elapsed
    lda #$c0                           ; prepare to move to next attack pattern
                                       ; set a = #$c0 (delay between switching attack patterns)

dragon_arm_orb_03_set_delay_exit:
    sta ENEMY_ATTACK_DELAY,x ; set delay between switching attack patterns to a
    inc ENEMY_FRAME,x        ; increment enemy animation frame number (attack pattern)

dragon_arm_orb_03_exit:
    rts

; ENEMY_FRAME #$04 (arm seeking player, reaching down)
dragon_arm_orb_seek_player:
    jsr dragon_arm_seek_player_logic
    dec ENEMY_ATTACK_DELAY,x         ; decrement enemy attack delay (timer before moving to next attack pattern)
    bne @exit                        ; exit if timer hasn't elapsed
    lda #$00                         ; attack pattern delay elapsed, a = #$00
    sta ENEMY_Y_VELOCITY_FRACT,x     ; reset initial orb position point
    sta ENEMY_ATTACK_DELAY,x         ; clear delay between attacks
    sta ENEMY_FRAME,x                ; set enemy attack pattern to #$00 (wave arm up and down)

@exit:
    rts

; fire projectile if shoulder dragon arm orb's ENEMY_VAR_A timer has elapsed
dragon_arm_orb_fire_projectile:
    dec ENEMY_VAR_A,x
    bne @exit
    lda #$90                        ; a = #$90
    sta ENEMY_VAR_A,x
    lda ENEMY_X_VELOCITY_FRACT,x
    tax
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                         ; store closest player in $0a
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    lda #$80                        ; a = #$80
    ldy #$05                        ; bullet speed code
    jsr aim_and_create_enemy_bullet ; get firing dir based on enemy ($08, $09) and player pos ($0b, $0a)
                                    ; and creates bullet (type a) with speed y if appropriate
    ldx ENEMY_CURRENT_SLOT

@exit:
    rts

; ENEMY_FRAME #$04 (arm seeking player, reaching down) set appropriate ENEMY_VAR_1
; update orb(s) ENEMY_VAR_1 (position offset index into dragon_arm_orb_pos_tbl)
dragon_arm_seek_player_logic:
    lda ENEMY_X_VELOCITY_FRACT,x ; load enemy slot index of hand orb
                                 ; ENEMY_X_VELOCITY_FRACT is set to hand enemy slot index on shoulder orm
    tax                          ; transfer hand orb enemy slot index to x
    jsr player_enemy_x_dist      ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
                                 ; find closest player to the hand orb
    sty $10                      ; store closest player to hand orb in $10

; loop through enemy orbs (by following ENEMY_VAR_4, i.e. previous orbs) looking for when dragon_arm_orb_seek_should_move returns positive
; starting at hand, going up to shoulder
@enemy_orb_loop:
    txa                                 ; transfer current dragon arm orb enemy slot index to a
    tay                                 ; transfer current dragon arm orb enemy slot index to y
    stx $11                             ; store current dragon arm orb enemy slot index in $11
    ldx ENEMY_VAR_4,y                   ; see if previous orb (closer to body) is shoulder dragon arm orb
    bmi @exit                           ; exit if previous orb is shoulder dragon arm orb
    lda $10                             ; load player index of player closest to enemy
    sta $0a                             ; store closest player index in $0a for use in get_quadrant_aim_dir_for_player
    jsr dragon_arm_orb_seek_should_move ; determine whether dragon arm orb should move, and if so, in which direction
    bmi @enemy_orb_loop                 ; continue to previous orb (closer to body) if orb doesn't need to move
    ldx $11                             ; orb should move, load successful dragon arm orb enemy slot index
    tay                                 ; transfer successful orb enemy slot index to y
    bne @dec_position                   ; branch if dragon_arm_orb_seek_should_move returned #$01, i.e. decrement ENEMY_VAR_1

; increment ENEMY_VAR_1, very similar to @dec_position
@inc_position:
    lda ENEMY_VAR_4,x        ; see if specified orb is shoulder dragon arm orb
    bmi @check_child_orb_inc ; continue if shoulder dragon arm orb
    ldy ENEMY_VAR_1,x        ; not shoulder dragon arm orb, load ENEMY_VAR_1
    cpy #$08
    bne @check_child_orb_inc
    tax
    jmp @inc_position

@check_child_orb_inc:
    cpx $11                ; compare orb to move enemy slot index with enemy slot index of orb with ENEMY_VAR_1 set to #$08
                           ; (or shoulder orb if not found)
    bne @inc_var_1_exit    ; branch if or is not the same
    lda ENEMY_VAR_3,x      ; load next dragon arm enemy slot index (farther away from body)
    bmi @inc_11_var_1_exit ; increment enemy slot index $11's ENEMY_VAR_1 and exit if dragon arm orb is the hand
    tax                    ; transfer next dragon arm enemy slot index (farther away from body) to x
    dec ENEMY_VAR_1,x      ; decrement position index (see dragon_arm_orb_pos_tbl)
    lda ENEMY_VAR_1,x      ; load position index (see dragon_arm_orb_pos_tbl)
    and #$3f               ; keep bits ..xx xxxx
    sta ENEMY_VAR_1,x      ; update position index

@inc_11_var_1_exit:
    ldx $11 ; load enemy slot index of orb with ENEMY_VAR_1 set to #$08 (or shoulder) to $11

@inc_var_1_exit:
    inc ENEMY_VAR_1,x            ; increment position index (see dragon_arm_orb_pos_tbl)
    jmp @sanitize_pos_index_exit

; finds the orb with the ENEMY_VAR_1 value of #$38 and decrements it if found
; decrement ENEMY_VAR_1, very similar to @inc_position
@dec_position:
    lda ENEMY_VAR_4,x        ; load previous dragon arm orb (closer to body)
    bmi @check_child_orb_dec ; branch if previous orb is the shoulder
    ldy ENEMY_VAR_1,x        ; load successfully orb's position index
    cpy #$38                 ; see if it's #$38
    bne @check_child_orb_dec ; branch if not #$38
    tax                      ; found orb where ENEMY_VAR_1 is #$38
                             ; transfer previous dragon arm orb (closer to body) to x
    jmp @dec_position        ; see if previous orb has an position index of #$38

; found orb with ENEMY_VAR_1 of #$38 or ended up on shoulder orb
@check_child_orb_dec:
    cpx $11                ; compare found orb enemy slot index to successful dragon_arm_orb_seek_should_move orb enemy slot index
    bne @dec_var_1_exit    ; branch if they are not the same to decrement ENEMY_VAR_1 and exit
    lda ENEMY_VAR_3,x      ; load the next dragon arm orb (farther from body)
    bmi @dec_11_var_1_exit ; branch if next orb is the hand
    tax                    ; next orb is not hand, transfer that orb's enemy slot index to x
    inc ENEMY_VAR_1,x      ; increment that next orb's ENEMY_VAR_1 (position index)
    lda ENEMY_VAR_1,x      ; load ENEMY_VAR_1 to 'sanitize' it, i.e. make sure its bounds are safe
    and #$3f               ; keep bits ..xx xxxx
    sta ENEMY_VAR_1,x      ; store sanitized position index

@dec_11_var_1_exit:
    ldx $11

@dec_var_1_exit:
    dec ENEMY_VAR_1,x

@sanitize_pos_index_exit:
    lda ENEMY_VAR_1,x
    and #$3f          ; keep bits ..xx xxxx
    sta ENEMY_VAR_1,x

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; executed for all but ENEMY_FRAME #$04 (arm seeking player)
; input
;  * x - current dragon arm orb enemy slot index
;  * $08 -
;  * negative flag -
dragon_arm_animate:
    lda #$00 ; a = #$00
    sta $08
    sta $0e

; merges every arm orb's ENEMY_VAR_2 to set new y velocity control value
@arm_orb_loop:
    stx $10                     ; backup shoulder orb's enemy slot index to $10
    jsr @check_delay_run_timer
    ldx $10                     ; restore shoulder orb's enemy slot index to $10
    lda ENEMY_VAR_2,x           ; load rotation direction timer
    ora $0e                     ; merge with previous arm orb rotation timers
    sta $0e                     ; update shoulder orb's arm orb rotation timer
    lda ENEMY_VAR_3,x           ; load next orb farther out from current orb
    tax                         ; transfer to x register
    bpl @arm_orb_loop           ; loop if next orb is not the hand
    ldx ENEMY_CURRENT_SLOT      ; next orb is the hand, load shoulder orb's enemy slot
    lda $0e                     ; when all orbs' ENEMY_VAR_2 are #$00 and ENEMY_FRAME = #$01, then ENEMY_FRAME #$01 is complete
    sta ENEMY_Y_VELOCITY_FAST,x ; when ENEMY_Y_VELOCITY_FAST is #$00 and ENEMY_FRAME = #$01, will specify to move to ENEMY_FRAME = #$02
                                ; only used for ENEMY_FRAME = #$01
    rts

; dec animation timer and run @timer_logic
@check_delay_run_timer:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @timer_elapsed          ; continue once animation timer has elapsed
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    lda #$00                    ; timer elapsed, a = #$00
    beq @timer_logic            ; always branch

@timer_elapsed:
    lda ENEMY_VAR_2,x                 ; load dragon arm orb rotation timer (can be negative)
    beq @timer_logic                  ; branch if dragon arm is frozen (not moving)
    bmi @negative_rotation_adjustment ; branch if dragon arm is rotating counterclockwise
    dec ENEMY_VAR_2,x                 ; rotating clockwise, decrement dragon arm rotation timer
    lda #$01                          ; a = #$01
    bne @timer_logic                  ; always branch

@negative_rotation_adjustment:
    inc ENEMY_VAR_2,x
    lda #$ff          ; a = #$ff

@timer_logic:
    sta $0c             ; store dragon arm rotation timer adjustment (increase, decrease, stay same)
    ldy #$00            ; y = #$00
    sty $0d
    clc                 ; clear carry in preparation for addition
    adc $08
    sta $0b
    beq @exit
    bmi @inc_timer_loop

; very similar to @inc_timer_loop
@enemy_var_2_loop:
    lda ENEMY_VAR_4,x ; load previous arm orb enemy slot (closer to body)
    bmi @inc_var_1    ; branch if previous arm orb is the shoulder
    ldy ENEMY_VAR_1,x ; load position index
    cpy #$08          ; see if it is #$08
    bne @inc_var_1    ; branch if position index is not #$08
    ldy $0c           ; load dragon arm rotation timer adjustment (increase, decrease, stay same)
    beq @dec_var_2    ; decrement rotation timer if current rotation is frozen
    bmi @dec_var_2    ; decrement rotation timer if current rotation is counterclockwise
    lda #$00          ; rotation timer is positive, clear rotation timer
    sta ENEMY_VAR_2,x ; reset duration timer
    beq @continue     ; always branch

@dec_var_2:
    lda #$01
    sta ENEMY_ANIMATION_DELAY,x
    dec ENEMY_VAR_2,x
    jmp @continue

@inc_var_1:
    dec $0d
    inc ENEMY_VAR_1,x
    lda ENEMY_VAR_1,x
    and #$3f          ; keep bits ..xx xxxx
    sta ENEMY_VAR_1,x

@continue:
    dec $0b
    bne @enemy_var_2_loop
    beq @exit             ; always branch

; very similar to enemy_var_2_loop
@inc_timer_loop:
    lda ENEMY_VAR_4,x    ; load previous arm orb enemy slot (closer to body)
    bmi @dec_var_1       ; branch if previous arm orb is the shoulder
    ldy ENEMY_VAR_1,x    ; load position index
    cpy #$38             ; see if it is #$38
    bne @dec_var_1       ; branch if position index is not #$38
    ldy $0c              ; load dragon arm rotation timer adjustment (increase, decrease, stay same)
    beq @inc_var_2       ; increment rotation timer if current rotation is frozen
    bpl @inc_var_2       ; increment rotation timer if current rotation is clockwise
    lda #$00             ; rotation timer is negative, clear rotation timer
    sta ENEMY_VAR_2,x    ; reset duration timer
    beq @inc_0b_continue ; always branch

@inc_var_2:
    lda #$01                    ; a = #$01
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    inc ENEMY_VAR_2,x
    jmp @inc_0b_continue

@dec_var_1:
    inc $0d
    dec ENEMY_VAR_1,x
    lda ENEMY_VAR_1,x
    and #$3f          ; keep bits ..xx xxxx
    sta ENEMY_VAR_1,x

@inc_0b_continue:
    inc $0b
    bne @inc_timer_loop

@exit:
    lda $08
    clc     ; clear carry in preparation for addition
    adc $0d
    sta $08
    rts

; adjust dragon arm orb positions based on ENEMY_VAR_1 for all orbs in an arm
dragon_arm_orb_set_positions:
    ldy ENEMY_CURRENT_SLOT      ; load current dragon arm orb enemy slot (shoulder)
    lda ENEMY_VAR_1,y           ; load position index
    sta ENEMY_X_VELOCITY_FAST,y ; set to position index

; update the next arm orb's (farther away from body) x and y position based on
; the previous arm orb (closer to the body) for all orbs in the arm
@orb_pos_update_loop:
    lda ENEMY_VAR_3,y               ; load the next dragon arm orb enemy slot
    bmi @exit                       ; exit if next orb is the hand (last orb in the arm) (#$ff)
    tax                             ; transfer next orb enemy slot to x
                                    ; starting here x refers to 'current' orb and
                                    ; y refers to 'previous' orb (closer to body)
    lda ENEMY_Y_POS,y               ; load previous orb's y position on screen
    sta $08                         ; store previous orb y position in $08
    lda ENEMY_X_POS,y               ; load previous orb's x position on screen
    sta $09                         ; store previous orb x position in $09
    lda ENEMY_X_VELOCITY_FAST,y     ; load previous orb's position index (ENEMY_VAR_1)
    clc                             ; clear carry in preparation for addition
    adc ENEMY_VAR_1,x               ; add previous orb's position index to current orb's position index
    and #$3f                        ; strip bit 6 and 7 (sanitize)
    sta ENEMY_X_VELOCITY_FAST,x     ; set current orb's new ENEMY_VAR_1 (position index)
    tay                             ; transfer position index to offset register
    lda dragon_arm_orb_pos_tbl,y    ; load offset from current y position for next orb
    clc                             ; clear carry in preparation for addition
    adc $08                         ; add to current arm orb's y position
    sta ENEMY_Y_POS,x               ; update next orb's y position on screen
    lda dragon_arm_orb_pos_tbl+16,y ; load offset from current x position for next orb
    clc                             ; clear carry in preparation for addition
    adc $09                         ; add current arm orb's x position
    sta ENEMY_X_POS,x               ; update next orb's x position on screen
    txa                             ; transfer next orb enemy slot to a
    tay                             ; transfer next orb enemy slot to y
    jmp @orb_pos_update_loop        ; loop to next orb in the arm

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; table for dragon arm orb position offsets from previous orb's pos based on ENEMY_VAR_1
; possible offsets from previous orb (in decimal)
; note that [row 2] = -1 * [row 0] and [row 3] = -1 * [row 2]
; (15,0) (15,1) (15,3) (15,4) (14,6) (14,7) (13,8) (12,10) (11,11) (10,12) (8,13) (7,14) (6,14) (4,15) (3,15) (1,15)
; (0,15) (-1,15) (-3,15) (-4,15) (-6,14) (-7,14) (-8,13) (-10,12) (-11,11) (-12,10) (-13,8) (-14,7) (-14,6) (-15,4) (-15,3) (-15,1)
; (-15,0) (-15,-1) (-15,-3) (-15,-4) (-14,-6) (-14,-7) (-13,-8) (-12,-10) (-11,-11) (-10,-12) (-8,-13) (-7,-14) (-6,-14) (-4,-15) (-3,-15) (-1,-15)
; (0,-15) (1,-15) (3,-15) (4,-15) (6,-14) (7,-14) (8,-13) (10,-12) (11,-11) (12,-10) (13,-8) (14,-7) (14,-6) (15,-4) (15,-3) (15,-1)
dragon_arm_orb_pos_tbl:
    .byte $00,$01,$03,$04,$06,$07,$08,$0a,$0b,$0c,$0d,$0e,$0e,$0f,$0f,$0f
    .byte $0f,$0f,$0f,$0f,$0e,$0e,$0d,$0c,$0b,$0a,$08,$07,$06,$04,$03,$01
    .byte $00,$ff,$fd,$fc,$fa,$f9,$f8,$f6,$f5,$f4,$f3,$f2,$f2,$f1,$f1,$f1
    .byte $f1,$f1,$f1,$f1,$f2,$f2,$f3,$f4,$f5,$f6,$f8,$f9,$fa,$fc,$fd,$ff
    .byte $00,$01,$03,$04,$06,$07,$08,$0a,$0b,$0c,$0d,$0e,$0e,$0f,$0f,$0f

; dragon arm orb destroyed routine -
dragon_arm_orb_routine_04:
    lda ENEMY_VAR_3,x                 ; load the child orb for current orb (farther from dragon)
    bpl @adv_routine                  ; if not the hand, then advance routine to show explosions
    inc BOSS_SCREEN_ENEMIES_DESTROYED ; current orb is the hand, increase number of dragon arms destroyed

@destroy_arm_part_loop:
    lda ENEMY_VAR_4,x               ; load the parent orb
    bmi @set_slot_adv_routine       ; branch if shoulder to exit, destroyed all orbs in arb
    tax                             ; transfer parent orb index to x
    jsr set_destroyed_enemy_routine ; update enemy's routine to the destroyed routine (enemy_routine_init_explosion)
    jmp @destroy_arm_part_loop      ; loop to update parent orb to the destroyed routine

@set_slot_adv_routine:
    ldx ENEMY_CURRENT_SLOT ; restore x to current enemy slot

@adv_routine:
    jmp advance_enemy_routine ; all arm orbs set to run explosions, advance routine to explode hand as well

; pointer table for boss gemini (#$7 * #$2 = #$e bytes)
boss_gemini_routine_ptr_tbl:
    .addr boss_gemini_routine_00  ; CPU address $9f03 - initialize velocities and attack delay to #$80 once created
    .addr boss_gemini_routine_01  ; CPU address $9f25 - wait for the #$03 wall platings to be destroyed, then wait for attack delay, enable collision
    .addr boss_gemini_routine_02  ; CPU address $9f3d - main routine, animate and fire based on timer
    .addr boss_gemini_routine_03  ; CPU address $9fff - boss gemini 'destroyed' routine. destroy if ENEMY_VAR_4 is 1, otherwise, reset ENEMY_HP, play ting! sound, and go back to boss_gemini_routine_02
    .addr boss_gemini_routine_04  ; CPU address $a038 - create explosion, if both boss gemini destroyed, jump to boss_defeated_routine
    .addr enemy_routine_explosion ; CPU address $e7b0 from bank 7
    .addr boss_gemini_routine_06  ; CPU address $a042 - remove enemy, if last gemini destroyed set level end delay

; initialize velocities and attack delay to #$80 once created
boss_gemini_routine_00:
    lda #$0a                     ; a = #$0a (boss gemini hp)
    sta ENEMY_VAR_4,x            ; set initial HP to #$0a, this routine doesn't ENEMY_HP in the standard way
    lda ENEMY_X_POS,x            ; load enemy x position on screen (set from level_4_enemy_screen_08)
    sta ENEMY_VAR_1,x            ; set static x position, used for offset calculations
    lda #$80                     ; a = #$80 (.5)
    sta ENEMY_X_VELOCITY_FRACT,x ; set amount to move per frame to #$80 (.5)
    lda #$00                     ; a = #$00
    sta ENEMY_X_VELOCITY_FAST,x  ; set initial x fast velocity to 0
    lda #$80                     ; a = #$80
    sta ENEMY_ATTACK_DELAY,x     ; set delay between attacks
    lda #$40                     ; a = #$40 (delay before appearing)

; set the animation delay to a and advanced the ENEMY_ROUTINE
; input
;  * a - the ENEMY_ANIMATION_DELAY
; this label is identical to two other labels
;  * bank 7 - set_anim_delay_adv_enemy_routine
;  * bank 0 - (this bank) set_anim_delay_adv_enemy_routine_00
set_anim_delay_adv_enemy_routine_01:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jmp advance_enemy_routine   ; advance to next routine

; wait for the #$03 wall platings to be destroyed, then wait for attack delay, enable collision
boss_gemini_routine_01:
    lda WALL_PLATING_DESTROYED_COUNT        ; number of boss platings destroyed
    cmp #$03                                ; number of boss platings to destroy (level 4)
    bcc @exit                               ; don't start up the boss gemini until all 3 platings have been destroyed
    dec ENEMY_ANIMATION_DELAY,x             ; decrement enemy animation frame delay counter
    bne @exit                               ; exit if animation delay hasn't elapsed
    lda #$a0                                ; a = #$a0
    sta ENEMY_ATTACK_DELAY,x                ; set delay between attacks
    jsr enable_bullet_enemy_collision       ; allow bullets to collide (and stop) upon colliding with boss gemini
    lda #$20                                ; a = #$20
    bne set_anim_delay_adv_enemy_routine_01 ; set ENEMY_ANIMATION_DELAY to #$20 and advance enemy routine

@exit:
    rts

; main routine, animate and fire based on timer
boss_gemini_routine_02:
    lda FRAME_COUNTER        ; load frame counter
    and #$07                 ; keep bits .... .xxx
    bne @set_sprite_mod_flag ; branch if not #$08th frame
    inc ENEMY_FRAME,x        ; #$08 frames have elapsed, increment enemy animation frame number (see boss_gemini_sprite_tbl)
    lda ENEMY_FRAME,x        ; load enemy animation frame number (see boss_gemini_sprite_tbl)
    cmp #$03                 ; see if past last frame
    bcc @set_frame           ; not past last frame, continue
    lda #$00                 ; past the last frame, go back to first frame (sprite_68)

@set_frame:
    sta ENEMY_FRAME,x ; set enemy animation frame number

; determine sprite to used based on whether flashing after being hit and low hp flag
; if both low hp flag (ENEMY_VAR_3) is set and timer is odd, then flip so sprite is correct
@set_sprite_mod_flag:
    lda ENEMY_VAR_3,x               ; load boss gemini low hp flag
    ldy ENEMY_VAR_2,x               ; load timer that starts after being hit (#$10 -> #$00)
    beq @set_sprite_offset_continue ; branch if the hit timer is #$00
    dec ENEMY_VAR_2,x               ; hit timer is not zero, decrement
    lda ENEMY_VAR_2,x               ; re-load updated timer that starts after being hit
    lsr                             ; shift bit 0 to carry
    lda ENEMY_VAR_3,x               ; re-load boss gemini low hp flag
    bcc @set_sprite_offset_continue ; branch if bit 0 of hit timer is 0
    eor #$01                        ; hit timer bit 0 was 1, flip bit 0 of low hp flag

@set_sprite_offset_continue:
    lsr           ; shift low hp flag/flashing due to being hit flag to the carry flag
    lda #$00      ; a = #$00
    bcc @continue ; branch if should show the green brain and not the red brain
                  ; (low hp or flashing after being hit)
    lda #$03      ; a = #$03

; create projectile if attack delay has elapsed
@continue:
    clc                                ; clear carry in preparation for addition
    adc ENEMY_FRAME,x                  ; add #$00 or #$03 to enemy animation frame number
    tay                                ; transfer to offset register
    lda boss_gemini_sprite_tbl,y       ; load correct sprite based on ENEMY_FRAME
    sta ENEMY_SPRITES,x                ; write enemy sprite code to CPU buffer
    lda ENEMY_ATTACK_FLAG              ; see if enemies should attack
    beq @wait_delay_update_pos         ; branch if attack flag disabled to see if update position animation delay has elapsed
    dec ENEMY_ATTACK_DELAY,x           ; decrement delay between attacks
    bne @wait_delay_update_pos         ; branch if attack flag disabled to see if update position animation delay has elapsed
    lda PLAYER_WEAPON_STRENGTH         ; load player's weapon strength
    asl
    asl
    asl                                ; multiply weapon strength by 8
    sta $08                            ; store multiplied weapon strength into $08
    lda RANDOM_NUM                     ; load random number
    adc FRAME_COUNTER                  ; add frame counter to random number
    sta RANDOM_NUM                     ; re-randomize random number
    lsr                                ; shift random number right (not sure of need) !(WHY?)
    and #$03                           ; keep bits 0 and 1
    tay                                ; transfer random number between 0 and 3 to offset register
    lda boss_gemini_attack_delay_tbl,y ; load random attack delay
    sec                                ; set carry flag in preparation for subtraction
    sbc $08                            ; subtract multiplied weapon strength from attack delay. the stronger the weapon, the shorter the attack delay
    sta ENEMY_ATTACK_DELAY,x           ; set delay between attacks
    lda #$1d                           ; a = #$1d (#$1d = spinning bubbles)
    jsr generate_enemy_a               ; generate #$1d enemy (spinning bubbles)

@wait_delay_update_pos:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
                                ; this specifies how long the helmets should freeze when merged or when really far apart
                                ; always #$00 when moving
                                ; !(BUG?) if a bullet collision with the boss gemini occurs in a frame when ENEMY_ANIMATION_DELAY is #$02
                                ; then the disable_enemy_collision method will not be called
                                ; and the boss gemini will be vulnerable until the next time it starts moving again
    beq @calc_offset_set_pos    ; branch if moving, i.e. animation delay is #$00,
                                ; or animation delay has elapsed and helmets should start moving
                                ; to calculate new position
    dec ENEMY_ANIMATION_DELAY,x ; helmets are staying still, either merged, or really far apart
                                ; decrement enemy animation frame delay counter
    bne @set_x_pos              ; if animation delay still hasn't elapsed, set position based on FRAME_COUNTER and ENEMY_VAR_1
    jsr disable_enemy_collision ; animation delay has elapsed and boss gemini are about to separate
                                ; prevent player enemy collision check and allow bullets to pass through enemy

@calc_offset_set_pos:
    lda ENEMY_Y_VELOCITY_FRACT,x ; alternates between #$00 or #$80
    clc                          ; clear carry in preparation for addition
    adc ENEMY_X_VELOCITY_FRACT,x ; load x fractional velocity. Always #$80 (.5)
    sta ENEMY_Y_VELOCITY_FRACT,x ; store result back into x position offset
                                 ; this overflows every #$02 frames, causing ENEMY_Y_VELOCITY_FAST (x position) to increment
                                 ; every other frame
    lda ENEMY_Y_VELOCITY_FAST,x  ; load x position offset from merge point (#$00 to #$30)
    adc ENEMY_X_VELOCITY_FAST,x  ; add x direction (#$00 = away from center, #$ff = towards center)
                                 ; this includes any overflow from previous addition
    sta ENEMY_Y_VELOCITY_FAST,x  ; set new x position offset (#$00 to #$30)
    ldy ENEMY_X_VELOCITY_FAST,x  ; load x direction (#$00 = away from center, #$ff = towards center)
    bmi @check_combined_set_x    ; branch if boss gemini helmets are going to the center (combining), or have combined
    cmp #$30                     ; see if x position offset is at maximum (#$30)
    bcc @set_x_pos               ; branch if x position offset is less than max (#$30)
    lda #$20                     ; x position offset is max, set animation delay to #$20
    bne @set_delay_reverse_dir   ; always branch to reverse direction

; phantom helmets moving toward center (merging)
@check_combined_set_x:
    tay                               ; transfer x position away from merge point (#$00 to #$30) offset to y
                                      ; x position will temporarily underflow to #$ff (-1)
                                      ; this is when helmet freeze for ENEMY_ANIMATION_DELAY amount of time
    bpl @set_x_pos                    ; branch if boss gemini haven't yet combined, i.e. their offset isn't #$ff
    jsr set_enemy_y_velocity_to_0     ; boss gemini have combined to become solid, pause motion
    jsr enable_bullet_enemy_collision ; allow bullets to collide (and stop) upon colliding with boss gemini
    lda #$30                          ; a = #$30 (delay when gemini is not moving)
                                      ; either merged or really far apart

@set_delay_reverse_dir:
    sta ENEMY_ANIMATION_DELAY,x   ; set enemy animation frame delay counter
    jsr reverse_enemy_x_direction ; reverse x direction

; sets x position based on ENEMY_VAR_1 and FRAME_COUNTER
; even frames use addition, odd frames use subtraction
@set_x_pos:
    lda FRAME_COUNTER           ; load frame counter
    lsr                         ; shift bit 0 to carry flag
    lda ENEMY_VAR_1,x           ; load boss gemini initial x position
    bcs @phase_left             ; odd frame, branch to subtract offset from initial x position
    adc ENEMY_Y_VELOCITY_FAST,x ; even frame, add offset from initial x position
    jmp @set_x_pos_exit         ; set new x position and exit

@phase_left:
    sbc ENEMY_Y_VELOCITY_FAST,x

@set_x_pos_exit:
    sta ENEMY_X_POS,x ; set enemy x position on screen
    rts

; table for gemini boss sprite codes (#$6 bytes)
; ENEMY_FRAME is #$00, #$01, or #$02, but if ENEMY_VAR_3 is #$01, then #$03 is added so
; ENEMY_VAR_3 = #$00 -> sprite_68, sprite_69, sprite_6a
; ENEMY_VAR_3 = #$01 -> sprite_68, sprite_6b, sprite_6c (hit by bullet, or almost dead, red brain)
; sprite_68, sprite_69, sprite_6a, sprite_6b, sprite_6c
boss_gemini_sprite_tbl:
    .byte $68,$69,$6a ; ENEMY_VAR_3 is #$00
    .byte $68,$6b,$6c ; ENEMY_VAR_3 is #$01

; table for possible delays (#$4 bytes)
boss_gemini_attack_delay_tbl:
    .byte $8a,$a9,$63,$d7

; boss gemini 'destroyed' routine, however, doesn't remove the enemy unless
; ENEMY_VAR_4 is 1, otherwise, reset ENEMY_HP, play ting! sound, and go back to boss_gemini_routine_02
boss_gemini_routine_03:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @continue
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter

@continue:
    dec ENEMY_VAR_4,x              ; decrement boss gemini's HP
    beq @adv_routine               ; advance if HP is #$00
    lda ENEMY_VAR_4,x              ; load boss gemini HP
    cmp #$07                       ; compare to #$07
    bcs @play_sound_set_routine_02 ; branch to skip low health flag setting and HP = 1 test
    cmp #$01                       ; see if HP is #$01
    bne @set_low_hp_flag           ; branch if HP is not #$01
    lda #$52                       ; HP is #$01, set score code to #$05 (2,000 points) and collision box to #$02
    sta ENEMY_SCORE_COLLISION,x    ; update score and collision code

@set_low_hp_flag:
    lda #$01          ; a = #$01
    sta ENEMY_VAR_3,x ; set low hp flag, used to use different sprites so brain is red and not green

@play_sound_set_routine_02:
    lda #$01                   ; a = #$01
    sta ENEMY_HP,x             ; reset enemy hp to #$01, always #$01 until ENEMY_VAR_4 is #$00 when killed
    lda #$10                   ; a = #$10
    sta ENEMY_VAR_2,x          ; initialize timer after being hit
    lda #$16                   ; a = #$16 (sound_16)
    jsr play_sound             ; play metal enemy hit ting sound
    lda #$03                   ; a = #$03
    jmp set_enemy_routine_to_a ; set enemy routine index to boss_gemini_routine_02

@adv_routine:
    jmp advance_enemy_routine ; advance to next routine

; create explosion, if both boss gemini destroyed, jump to boss_defeated_routine
boss_gemini_routine_04:
    dec WALL_CORE_REMAINING   ; load remaining boss gemini to destroy
    bne @adv_routine          ; at least one boss gemini exist, create normal explosion
    jmp boss_defeated_routine ; normal explosion + final boom (with echo)

@adv_routine:
    jmp enemy_routine_init_explosion ; normal explosion

; remove enemy, if last gemini destroyed set level end delay
boss_gemini_routine_06:
    lda WALL_CORE_REMAINING    ; load remaining boss gemini to destroy (at this point either #$00 or #$01)
    beq @both_gemini_destroyed ; branch if both gemini are destroyed
    jmp remove_enemy           ; one more boss gemini exists, just remove this enemy

@both_gemini_destroyed:
    jsr shared_enemy_routine_clear_sprite ; set sprite code to 0 and advance to next routine
                                          ; no routine after this, will be overwritten to #$00 in set_delay_remove_enemy
    lda #$60                              ; a = #$60 (delay before auto-move)
    jmp set_delay_remove_enemy            ; set delay to #$60 and remove the enemy

; pointer table for spinning bubbles projectile (#$5 * #$2 = #$a bytes)
spinning_bubbles_routine_ptr_tbl:
    .addr spinning_bubbles_routine_00  ; CPU address $a05b
    .addr spinning_bubbles_routine_01  ; CPU address $a094
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

spinning_bubbles_routine_00:
    jsr player_enemy_x_dist             ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                             ; store closest player in $0a
    tya                                 ; transfer closest player to a
    sta ENEMY_VAR_2,x                   ; store closest player to enemy in ENEMY_VAR_2
    jsr set_08_09_to_enemy_pos          ; set $08 and $09 to enemy x's X and Y position
    lda FRAME_COUNTER                   ; load frame counter
    and #$03                            ; keep bits .... ..xx
    sta ENEMY_ATTRIBUTES,x              ; store random number between 0 and 3 in the enemy attributes
    tay                                 ; transfer random number to y
    lda spinning_bubbles_speed_tbl,y    ; load bullet velocity routine table value (bullet_velocity_adjust_xx)
    sta $06                             ; store bullet direction velocity routine value (bullet_velocity_adjust_xx) in $06
    lda #$01                            ; a = #$01 (quadrant_aim_dir_01)
    sta $0f                             ; set quadrant_aim_dir_lookup_ptr_tbl offset to #$01
    jsr get_quadrant_aim_dir_for_player ; set a to the aim direction within a quadrant
                                        ; based on source position ($09, $08) targeting player index $0a
    pha                                 ; push quadrant aim dir to the stack
    jsr set_bullet_velocities           ; set the projectile X and Y velocities (both high and low) based on register a (#$01)
    pla                                 ; pop quadrant aim dir from stack
    jsr get_rotate_dir                  ; determine which direction to rotate
                                        ; based on a (quadrant aim dir) and quadrant ($07)
    lda $0c                             ; load new enemy aim direction
    sta ENEMY_VAR_1,x                   ; set new enemy aim direction
    lda #$20                            ; a = #$20
    sta ENEMY_ATTACK_DELAY,x            ; set delay between aim readjustments
    jmp advance_enemy_routine           ; advance to spinning_bubbles_routine_01

; table for possible initial speed codes (#$4 bytes)
; bullet_velocity_adjust_01 (.75x), bullet_velocity_adjust_03 (1.25x)
; bullet_velocity_adjust_04 (1.5x), bullet_velocity_adjust_05 (1.62x)
spinning_bubbles_speed_tbl:
    .byte $01,$03,$04,$05

spinning_bubbles_routine_01:
    ldy ENEMY_ATTRIBUTES,x         ; load enemy attributes initialized in spinning_bubbles_routine_00
                                   ; it is random number between 0 and 3 inclusively
    inc ENEMY_ANIMATION_DELAY,x    ; increment animation delay
    lda ENEMY_ANIMATION_DELAY,x    ; load enemy animation frame delay counter
    cmp spinning_bullet_spin_tbl,y ; compare animation delay to random value from table
                                   ; used to determine if bubble should animation, i.e. spin
    bcc @continue                  ; don't animate bubble if delay was below threshold in spinning_bullet_spin_tbl
    lda #$00                       ; a = #$00
    sta ENEMY_ANIMATION_DELAY,x    ; set enemy animation frame delay counter
    inc ENEMY_FRAME,x              ; increment enemy animation frame number
    lda ENEMY_FRAME,x              ; load enemy animation frame number
    cmp #$06                       ; see if past last frame
    bcc @set_frame_continue        ; continue to set ENEMY_FRAME if not past the last frame
    lda #$00                       ; past the last animation frame, reset to #$00

@set_frame_continue:
    sta ENEMY_FRAME,x ; set enemy animation frame number

@continue:
    lda ENEMY_FRAME,x                     ; load enemy animation frame number
    clc                                   ; clear carry in preparation for addition
    adc #$6d                              ; determine sprite code based on ENEMY_FRAME
    sta ENEMY_SPRITES,x                   ; write enemy sprite code to CPU buffer
    jsr update_enemy_pos                  ; apply velocities and scrolling adjust
    lda ENEMY_VAR_3,x                     ; load the number of times the bubbles have checked for aiming readjustment
    cmp #$14                              ; compare that to #$14
    bcs @exit                             ; don't readjust more than 13 times
    dec ENEMY_ATTACK_DELAY,x              ; decrement delay between attacks
    bne @exit                             ; exit if direction adjustment delay hasn't elapsed
    lda #$08                              ; attack delay has elapsed, set a = #$08 (delay before direction adjust)
    sta ENEMY_ATTACK_DELAY,x              ; set new direction adjustment delay
    inc ENEMY_VAR_3,x                     ; increment number of direction adjustments
    jsr set_08_09_to_enemy_pos            ; set $08 and $09 to enemy x's X and Y position
    lda ENEMY_VAR_2,x                     ; load the player closest to the spinning bubble
    sta $0a                               ; set player index for call aim_var_1_for_quadrant_aim_dir_01
    jsr aim_var_1_for_quadrant_aim_dir_01 ; determine next aim direction [#$00-#$0b] ($0c), adjusts ENEMY_VAR_1 to get closer to that value using quadrant_aim_dir_01
    bcs @exit                             ; exit if already aiming at player
    lda ENEMY_ATTRIBUTES,x                ; need to readjust aiming direction, load enemy attributes
    ora #$03                              ; set bits .... ..xx
    sta ENEMY_ATTRIBUTES,x                ; set enemy attributes to #$03
                                          ; this will cause the bubble to spin very frequently due to check against spinning_bullet_spin_tbl
    lda ENEMY_VAR_1,x                     ; load enemy aim direction
    asl                                   ; double since each entry is #$02 bytes
    tay                                   ; transfer to offset register
    lda spinning_bullet_vel_tbl,y         ; load y fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x          ; set y fractional velocity
    lda spinning_bullet_vel_tbl+1,y       ; load y fast velocity
    sta ENEMY_Y_VELOCITY_FAST,x           ; set y fast velocity
    lda spinning_bullet_vel_tbl+12,y      ; load x fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x          ; set y fractional velocity
    lda spinning_bullet_vel_tbl+13,y      ; load x fast velocity
    sta ENEMY_X_VELOCITY_FAST,x           ; set x fast velocity

@exit:
    rts

; table for spinning bubble x/y velocities (#$3c bytes)
spinning_bullet_vel_tbl:
    .byte $00,$00 ; 0
    .byte $63,$00 ; .39
    .byte $c0,$00 ; .75
    .byte $0f,$01 ; 1.06
    .byte $4b,$01 ; 1.29
    .byte $72,$01 ; 1.44
    .byte $7e,$01 ; 1.49
    .byte $72,$01 ; 1.44
    .byte $4b,$01 ; 1.29
    .byte $0f,$01 ; 1.06
    .byte $c0,$00 ; .75
    .byte $63,$00 ; .39
    .byte $00,$00 ; 0
    .byte $9d,$ff ; -.39
    .byte $40,$ff ; -.75
    .byte $f1,$fe ; -1.06
    .byte $b5,$fe ; -1.29
    .byte $8e,$fe ; -1.44
    .byte $82,$fe ; -1.49
    .byte $8e,$fe ; -1.44
    .byte $b5,$fe ; -1.29
    .byte $f1,$fe ; -1.06
    .byte $40,$ff ; -.75
    .byte $9d,$ff ; -.39
    .byte $00,$00 ; 0
    .byte $63,$00 ; .39
    .byte $c0,$00 ; .75
    .byte $0f,$01 ; 1.06
    .byte $4b,$01 ; 1.29
    .byte $72,$01 ; 1.44

; table for possible spinning speeds (#$4 bytes)
spinning_bullet_spin_tbl:
    .byte $08,$06,$04,$02

; pointer table for blue soldier (#$7 * #$2 = #$e bytes)
blue_soldier_routine_ptr_tbl:
    .addr red_blue_soldier_routine_00  ; CPU address $a157 - initialize position and x velocity
    .addr blue_soldier_routine_01      ; CPU address $a18a - run across screen, once past trigger point, see if close to player, if so advance routine to jump down
    .addr blue_soldier_routine_02      ; CPU address $a1f7 - go through jump animation routine, then initialize jump velocities and advance routine
    .addr blue_soldier_routine_03      ; CPU address $a245 - animate jumping down frames based on time since jump, apply velocity
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; initialization for both red and blue soldiers
red_blue_soldier_routine_00:
    lda ENEMY_ATTRIBUTES,x                ; load enemy attributes
    asl                                   ; double since each entry is #$02 bytes
    tay                                   ; transfer offset to y
    lda red_blue_soldier_init_pos_tbl,y   ; load initial y position
    sta ENEMY_Y_POS,x                     ; set enemy y position on screen
    lda red_blue_soldier_init_pos_tbl+1,y ; load initial x position
    sta ENEMY_X_POS,x                     ; set enemy x position on screen
    lda ENEMY_ATTRIBUTES,x                ; reload enemy attributes
    and #$01                              ; keep bit 0
    asl                                   ; double since each entry is #$02 bytes
    tay                                   ; transfer offset to y
    lda red_blue_soldier_init_vel_tbl,y   ; load initial fractional x velocity
    sta ENEMY_X_VELOCITY_FRACT,x          ; set fractional x velocity
    lda red_blue_soldier_init_vel_tbl+1,y ; load initial fast x velocity
    sta ENEMY_X_VELOCITY_FAST,x           ; set fast x velocity
    jmp advance_enemy_routine             ; advance to next routine

; table for blue guys stop positions (#$8 bytes)
; byte 0 - y position
; byte 1 - x position
red_blue_soldier_init_pos_tbl:
    .byte $9c,$f0 ; lower right - (#$f0, #$9c) - uses negative x velocity
    .byte $9c,$10 ; lower left - (#$10, #$9c) - uses positive x velocity
    .byte $61,$f0 ; upper right - (#$f0, #$61) - uses negative x velocity
    .byte $61,$10 ; upper left - (#$10, #$61) - uses positive x velocity

; table for red/blue guys running velocities (#$4 bytes)
; byte 0 - fractional x velocity
; byte 1 - fast x velocity
red_blue_soldier_init_vel_tbl:
    .byte $00,$ff ; x velocity from left
    .byte $00,$01 ; x velocity from right

; run across screen, once past trigger point, see if close to player, if so advance routine to jump down
blue_soldier_routine_01:
    jsr red_blue_soldier_set_run_frame ; set appropriate ENEMY_FRAME for running animation
    lda ENEMY_FRAME,x                  ; load enemy animation frame number
    clc                                ; clear carry in preparation for addition
    adc #$85                           ; ENEMY_FRAME is offset from sprite_85, add #$85 to get sprite
    sta ENEMY_SPRITES,x                ; write enemy sprite code to CPU buffer
    lda ENEMY_ATTRIBUTES,x             ; load enemy attributes
    lsr                                ; shift bit 0 to carry (left or right soldier)
    lda #$47                           ; right soldier, horizontal flip and override with sprite palette #$02
    bcc @continue                      ; branch if right soldier
    lda #$07                           ; left soldier, no flip and override with sprite palette #$02

@continue:
    sta ENEMY_SPRITE_ATTR,x                 ; set enemy sprite attributes (palette and whether to flip horizontally)
    jsr red_blue_soldier_set_bg_priority    ; set sprite bg priority for when blue soldiers are behind pillar
    jsr update_enemy_pos                    ; apply velocities and scrolling adjust
    lda ENEMY_X_POS,x                       ; load enemy x position on screen
    cmp #$d8                                ; compare to enable attack x position from right
    bcs blue_soldier_routine_01_exit        ; exit if (right) soldier should keep running toward enable attack trigger point
    cmp #$28                                ; compare to enable attack x position from left
    bcc blue_soldier_routine_01_exit        ; exit if (left) soldier should keep running toward enable attack trigger point
    jsr player_enemy_x_dist                 ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    cmp #$10                                ; see if blue soldier within #$10 horizontal pixels of closest player
    bcs blue_soldier_routine_01_exit        ; exit if farther than #$10 from enemy
    lda #$00                                ; close to player, set delay and move to next routine to jump attack
    sta ENEMY_FRAME,x                       ; set ENEMY_FRAME to #$00 (sprite_85)
                                            ; will be interpreted as sprite_88 in blue_soldier_routine_01
    lda #$01                                ; a = #$01
    jmp set_anim_delay_adv_enemy_routine_01 ; set ENEMY_ANIMATION_DELAY to #$01 and advance enemy routine

red_blue_soldier_set_run_frame:
    lda FRAME_COUNTER                ; load frame counter
    and #$03                         ; keep bits .... ..xx
    bne blue_soldier_routine_01_exit ; exit if not 4th frame
    inc ENEMY_FRAME,x                ; 4th frame, increment enemy animation frame number
    lda ENEMY_FRAME,x                ; load enemy animation frame number
    cmp #$03                         ; compare to the last blue soldier running sprite
    bcc blue_soldier_routine_01_exit ; exit if not past last running sprite
    lda #$00                         ; reset back to first blue soldier running sprite
    sta ENEMY_FRAME,x                ; set enemy animation frame number

blue_soldier_routine_01_exit:
    rts

; sets the sprite bg priority for when red and blue soldiers are behind pillar
red_blue_soldier_set_bg_priority:
    ldy #$00             ; y = #$00
    lda ENEMY_X_POS,x    ; load enemy x position on screen
    cmp #$dc             ; compare x position to #$dc (86% of screen)
    bcs @continue        ; branch if to the right of #$dc (not behind pillar)
    cmp #$24             ; compare x position to #$24 (14% of screen)
    bcs @set_sprite_attr ; branch if to the right of #$24 (not behind pillar)

; left of #$24 or right of #$dc, e.g. behind pillar
@continue:
    ldy #$20 ; y = #$20

@set_sprite_attr:
    sty $08                 ; set $08 to have the bg priority and sprite palette flags
    lda ENEMY_SPRITE_ATTR,x ; load enemy sprite attributes
    and #$df                ; strip bit 5 (bg priority)
    ora $08                 ; specify bg priority and palette flags from $08
    sta ENEMY_SPRITE_ATTR,x ; set sprite attributes

blue_soldier_routine_02_exit:
    rts

; go through jump animation routine, then initialize jump velocities and advance routine
    blue_soldier_routine_02:
    dec ENEMY_ANIMATION_DELAY,x             ; decrement enemy animation frame delay counter
    bne blue_soldier_routine_02_exit        ; exit if animation delay hasn't elapsed
    lda #$08                                ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x             ; set next animation frame enemy delay counter
    lda ENEMY_FRAME,x                       ; load enemy animation frame number (offset from sprite_88)
    clc                                     ; clear carry in preparation for addition
    adc #$88                                ; add blue soldier attack starting sprite location (sprite_88)
    sta ENEMY_SPRITES,x                     ; write enemy sprite code to CPU buffer
    inc ENEMY_FRAME,x                       ; increment enemy animation frame number
    lda ENEMY_FRAME,x                       ; load enemy animation frame number
    cmp #$03                                ; see if past last attacking sprite of attack animation
    bcc blue_soldier_routine_02_exit        ; exit if not on last attack frame
    lda ENEMY_SPRITE_ATTR,x                 ; showing last attack sprite, start jump down to actually attack
                                            ; load enemy sprite attributes
    and #$df                                ; strip bits 5 (bg priority)
    sta ENEMY_SPRITE_ATTR,x                 ; update sprite attribute so blue soldier when attacking is always in foreground
    jsr enable_enemy_collision              ; enable bullet-enemy collision and player-enemy collision checks
    lda ENEMY_ATTRIBUTES,x                  ; load enemy attributes
    and #$01                                ; keep bit 0 (left or right soldier)
    asl                                     ; double since each entry is #$02 bytes
    tay                                     ; transfer to offset register
    lda blue_soldier_jmp_x_vel_tbl,y        ; load fractional x velocity
    sta ENEMY_X_VELOCITY_FRACT,x            ; set enemy fractional x velocity
    lda blue_soldier_jmp_x_vel_tbl+1,y      ; load fast x velocity
    sta ENEMY_X_VELOCITY_FAST,x             ; set enemy fast x velocity
    lda #$00
    sta ENEMY_Y_VELOCITY_FRACT,x            ; set y fractional velocity to #$00
    lda #$ff                                ; -1
    sta ENEMY_Y_VELOCITY_FAST,x             ; set y fast velocity to #$ff (-1)
    lda #$10                                ; a = #$10
    jmp set_anim_delay_adv_enemy_routine_01 ; set ENEMY_ANIMATION_DELAY to #$10 and advance enemy routine

; table for blue guy x velocity while jumping (attacking) (#$4 bytes)
blue_soldier_jmp_x_vel_tbl:
    .byte $c0,$ff ; coming from left
    .byte $40,$00 ; coming from right

; animate jumping down frames based on time since jump, apply velocity
blue_soldier_routine_03:
    lda #$8b                    ; a = #$8b (sprite_8b)
    ldy ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    beq @continue               ; branch if delay is #$00 to use sprite_8b
    dec ENEMY_ANIMATION_DELAY,x ; delay hasn't elapsed. decrement enemy animation frame delay counter
    lda #$8a                    ; a = #$8a (sprite_8a)

@continue:
    sta ENEMY_SPRITES,x             ; write enemy sprite code to CPU buffer
    jsr add_10_to_enemy_y_fract_vel ; add #$10 to y fractional velocity (.06 faster)
    jmp update_enemy_pos            ; apply velocities and scrolling adjust

; pointer table for red shooting guys (#$6 * #$2 = #$c bytes)
red_soldier_routine_ptr_tbl:
    .addr red_blue_soldier_routine_00  ; CPU address $a157 - initialize position and x velocity
    .addr red_soldier_routine_01       ; CPU address $a266 - run across screen, once past trigger point, see if close to player, if so advance routine to fire at player
    .addr red_soldier_routine_02       ; CPU address $a2bb - fire ENEMY_VAR_1 times and then go back to red_soldier_routine_01 to continue running off screen
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; run across screen, once past trigger point, see if close to player, if so advance routine to fire at player
; if already fired from red_soldier_routine_02, just continue running off screen
red_soldier_routine_01:
    jsr red_blue_soldier_set_run_frame ; set appropriate ENEMY_FRAME for running animation
    lda ENEMY_FRAME,x                  ; load enemy animation frame number
    clc                                ; clear carry in preparation for addition
    adc #$8c                           ; ENEMY_FRAME is offset from sprite_8c, add #$8c to get sprite
    sta ENEMY_SPRITES,x                ; write enemy sprite code to CPU buffer
    lda ENEMY_ATTRIBUTES,x             ; load enemy attributes
    lsr                                ; shift bit 0 to carry (left or right soldier)
    lda #$46                           ; right soldier, horizontal flip and override with sprite palette #$01
    bcc @continue                      ; branch if right soldier
    lda #$06                           ; left soldier, no flip and override with sprite palette #$01

@continue:
    sta ENEMY_SPRITE_ATTR,x              ; set enemy sprite attributes (palette and whether to flip horizontally)
    jsr red_blue_soldier_set_bg_priority ; set sprite bg priority for when red soldiers are behind pillar
    jsr update_enemy_pos                 ; apply velocities and scrolling adjust
    lda ENEMY_VAR_2,x                    ; load soldier fired flag
    bne red_soldier_routine_exit         ; exit when red soldier has already fired at the player
                                         ; this allows the red soldier to continue running off screen
    lda ENEMY_X_POS,x                    ; load enemy x position on screen
    cmp #$d8                             ; compare to enable attack x position from right
    bcs red_soldier_routine_exit         ; exit if (right) soldier should keep running toward enable attack trigger point
    cmp #$28                             ; compare to enable attack x position from left
    bcc red_soldier_routine_exit         ; exit if (left) soldier should keep running toward enable attack trigger point
    lda ENEMY_ATTRIBUTES,x               ; load enemy attributes
    lsr
    lsr                                  ; shift bit 1 into the carry flag
    lda #$10                             ; a = #$10 (carry clear attack distance)
    bcc @attack_if_close                 ; branch if carry flag clear
    lda #$30                             ; a = #$30 (carry flag set attack distance)

@attack_if_close:
    sta $0f                      ; set minimum attack distance
    jsr player_enemy_x_dist      ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    cmp $0f                      ; compare closest player x to $0f
    bcs red_soldier_routine_exit ; exit if player too far away from enemy to attack
    lda #$8f                     ; a = #$8f (sprite_8f) red soldier facing player
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
    lda #$03                     ; a = #$03
    sta ENEMY_VAR_1,x            ; set to fire #$03 bullets
    lda #$10                     ; a = #$10 (delay before first attack)
    sta ENEMY_ATTACK_DELAY,x     ; set delay between attacks
    jmp advance_enemy_routine    ; advance to red_soldier_routine_02

; fire ENEMY_VAR_1 times and then go back to red_soldier_routine_01
red_soldier_routine_02:
    dec ENEMY_ATTACK_DELAY,x     ; decrement delay between attacks
    beq red_soldier_fire_weapon  ; fire weapon if attack delay has elapsed
    lda ENEMY_ATTACK_DELAY,x     ; load delay between attacks
    cmp #$2c                     ; see if attack delay is #$2c
    bne red_soldier_routine_exit ; exit if attack delay isn't #$2c
    lda ENEMY_SPRITE_ATTR,x      ; attack delay is #$2c, load enemy sprite attributes
    and #$f7                     ; strip recoil effect flag
    sta ENEMY_SPRITE_ATTR,x      ; update enemy sprite attribute

red_soldier_routine_exit:
    rts

red_soldier_fire_weapon:
    lda #$90                        ; a = #$90 (sprite_90) red soldier facing player with weapon
    sta ENEMY_SPRITES,x             ; write enemy sprite code to CPU buffer
    dec ENEMY_VAR_1,x               ; decrement number of bullets to fire
    bmi @set_routine_01             ; go back to red_soldier_routine_01 if all bullets have been fired
    lda #$30                        ; a = #$30 (delay when shooting)
    sta ENEMY_ATTACK_DELAY,x        ; set delay between attacks
    lda ENEMY_SPRITE_ATTR,x         ; load enemy sprite attributes
    ora #$08                        ; set bit 3 (recoil effect)
    sta ENEMY_SPRITE_ATTR,x         ; update sprite attribute
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                         ; store closest player in $0a
    jsr set_08_09_to_enemy_pos      ; set $08 and $09 to enemy x's X and Y position
    lda #$00                        ; a = #$00
    ldy #$04                        ; bullet speed code
    jmp aim_and_create_enemy_bullet ; get firing dir based on enemy ($08, $09) and player pos ($0b, $0a)
                                    ; and creates bullet (type a) with speed y if appropriate

@set_routine_01:
    inc ENEMY_VAR_2,x          ; set flag indicating soldier has already fired at player
    lda #$02                   ; a = #$02
    jmp set_enemy_routine_to_a ; set enemy routine index to red_soldier_routine_01

; pointer table for red/blue guys generator (#$3 * #$2 = #$6 bytes)
red_blue_soldier_gen_routine_ptr_tbl:
    .addr red_blue_soldier_gen_routine_00 ; CPU address $a304
    .addr red_blue_soldier_gen_routine_01 ; CPU address $a309
    .addr remove_enemy                    ; CPU address $e809 from bank 7

red_blue_soldier_gen_routine_00:
    lda #$80                                ; a = #$80
    jmp set_anim_delay_adv_enemy_routine_01 ; set generation delay to #$80 and advance enemy routine

red_blue_soldier_gen_routine_01:
    lda WALL_PLATING_DESTROYED_COUNT ; number of boss platings destroyed
    cmp #$03                         ; compare to number of wall platings on level 4 boss screen
    bcc @continue                    ; continue to generate red and blue soldiers if all plates haven't been destroyed
    jmp remove_enemy                 ; all plates have been destroyed, remove enemy to stop generating red and blue soldiers

@continue:
    lda FRAME_COUNTER                        ; load frame counter
    lsr                                      ; shift bit 0 to the carry flag
    bcs red_blue_soldier_gen_routine_01_exit ; exit if odd frame
    dec ENEMY_ANIMATION_DELAY,x              ; even frame, decrement enemy animation frame delay counter
    bne red_blue_soldier_gen_routine_01_exit ; exit if generation delay hasn't elapsed

; reads from red_blue_solider_data_tbl and based on byte, creates red or blue soldier, or waits
@read_soldier_byte:
    ldy ENEMY_VAR_1,x ; load the soldier generation read offset

@read_soldier_data:
    inc ENEMY_VAR_1,x               ; increment the soldier generation read offset
    lda red_blue_solider_data_tbl,y ; read the data byte for generating a red or blue soldier
    cmp #$ff                        ; see if the last byte was read (end of data byte)
    bne @eval_data_byte             ; continue if didn't read the end of data byte
    ldy #$00                        ; finished reading data, reset read offset and start over
    tya                             ; transfer y to a
    sta ENEMY_VAR_1,x               ; reset the soldier generation read offset to repeated the pattern
    beq @read_soldier_data          ; always branch to start from the beginning

@eval_data_byte:
    lda red_blue_solider_data_tbl,y      ; reload the data byte
    bmi @set_delay_exit                  ; if the byte is negative, don't create soldier, instead delay for amount specified
    and #$03                             ; byte is positive, creating red or blue soldier, keep bits .... ..xx
    sta $08                              ; set red or blue soldier to generate's ENEMY_ATTRIBUTES
    lda red_blue_solider_data_tbl,y      ; reload the data byte
    lsr
    lsr                                  ; bit 3 specifies which soldier to generate
    sta $09                              ; set whether to create a red or blue soldier (0 = red soldier, 1 = blue soldier)
    jsr @find_slot_init_red_blue_soldier ; find enemy slot and create soldier
    jmp @read_soldier_byte               ; move to the next byte

@set_delay_exit:
    asl
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    rts

@find_slot_init_red_blue_soldier:
    jsr find_next_enemy_slot   ; find next available enemy slot, put result in x register
    bne @exit                  ; exit if no enemy slot available
    lda $09                    ; load whether to create a red or blue soldier (0 = red soldier, 1 = blue soldier)
    lsr                        ; shift bit 0 to the carry flag
    lda #$1f                   ; a = #$1f (enemy type for red soldier)
    bcc @init_red_blue_soldier ; branch if
    lda #$1e                   ; a = #$1e (enemy type for blue soldier)

@init_red_blue_soldier:
    sta ENEMY_TYPE,x       ; set current enemy type to either red or blue soldier
    jsr initialize_enemy   ; initialize enemy variables
    lda $08                ; load blue or red soldier's initial position and velocity
                           ; see red_blue_soldier_init_pos_tbl and red_blue_soldier_init_vel_tbl
    sta ENEMY_ATTRIBUTES,x

@exit:
    ldx ENEMY_CURRENT_SLOT ; restore x to red blue soldier generator enemy slot index

red_blue_soldier_gen_routine_01_exit:
    rts

; table for red or blue soldier soldier generation (#$1c bytes)
; if byte is negative
;  * a soldier isn't generated and the byte value shifted left is the delay
; if positive
;  * bits 0, 1, and 2 - ENEMY_ATTRIBUTES for red or blue soldier to generate
;  * bit 3 - 0 = red solider, 1 = blue soldier
red_blue_solider_data_tbl:
    .byte $00,$01,$02,$03,$d0 ; red soldier (x4), #$a0 delay
    .byte $06,$07,$a0         ; blue soldier (x2), #$40 delay
    .byte $04,$05,$c0         ; blue soldier (x2), #$80 delay
    .byte $00,$01,$b0         ; red soldier (x2), #$60 delay
    .byte $02,$03,$d0         ; red soldier (x4), #$a0 delay
    .byte $04,$05,$06,$07,$d0 ; blue soldier (x4), #$a0 delay
    .byte $00,$01,$02,$03,$fe ; red soldier (x4), #$fc delay
    .byte $ff

; pointer table for grenade generator (#$3 * #$2 = #$6 bytes)
ice_grenade_generator_routine_ptr_tbl:
    .addr ice_grenade_generator_routine_00 ; CPU address $a38a
    .addr ice_grenade_generator_routine_01 ; CPU address $a399
    .addr remove_enemy                     ; CPU address $e809 from bank 7

ice_grenade_generator_routine_00:
    jsr add_scroll_to_enemy_pos     ; adjust enemy location based on scroll
    lda ENEMY_X_POS,x               ; load enemy x position on screen
    cmp #$c8
    bcs ice_grenade_exit            ; exit if grenade generator not yet at trigger point (78% of screen)
    lda #$01                        ; a = #$01 (ENEMY_ANIMATION_DELAY)
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to #$01; advance enemy routine

ice_grenade_generator_routine_01:
    jsr add_scroll_to_enemy_pos ; adjust enemy location based on scroll
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne ice_grenade_exit        ; exit if delay hasn't elapsed
    lda #$80                    ; a = #$80 (delay between grenades)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$11                    ; a = #$11 (ice grenade)
    jmp generate_enemy_a        ; generate #$11 enemy (ice grenade)

; pointer table for grenade (#$5 * #$2 = #$a bytes)
ice_grenade_routine_ptr_tbl:
    .addr ice_grenade_routine_00     ; CPU address $a3b5 - play sound, initialize velocity
    .addr ice_grenade_routine_01     ; CPU address $a3d7 - animate, apply gravity, check for collision
    .addr mortar_shot_routine_03     ; CPU address $e752 from bank 7 - play explosion sound, update collision, hide sprite
    .addr enemy_routine_explosion    ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy ; CPU address $e806 from bank 7

; play sound, initialize velocity
ice_grenade_routine_00:
    lda #$1a                     ; a = #$1a ("piiuuu" sound) (sound_1a)
    jsr play_sound               ; play ice grenade whistling noise sound
    lda #$20                     ; a = #$20 (bg priority flag)
    sta ENEMY_SPRITE_ATTR,x      ; set enemy sprite attributes
    lda #$80                     ; a = #$80 (.5)
    sta ENEMY_X_VELOCITY_FRACT,x ; set ice grenade fractional x velocity
    lda #$00                     ; a = #$00
    sta ENEMY_X_VELOCITY_FAST,x  ; set ice grenade fast x velocity
    lda #$00                     ; a = #$00 (unnecessary)
    sta ENEMY_Y_VELOCITY_FRACT,x ; set ice grenade fractional y velocity
    lda #$fe                     ; a = #$fe (-2)
    sta ENEMY_Y_VELOCITY_FAST,x  ; set ice grenade fast y velocity
    jmp advance_enemy_routine    ; advance to ice_grenade_routine_01

ice_grenade_exit:
    rts

; animate, apply gravity, check for collision
ice_grenade_routine_01:
    lda FRAME_COUNTER ; load frame counter
    and #$07          ; keep bits ... .xxx
    bne @continue     ; continue without changing sprite if #$08 frames haven't elapsed
    inc ENEMY_FRAME,x ; #$08 frames have elapsed, increment enemy animation frame number

@continue:
    lda ENEMY_FRAME,x                   ; load enemy animation frame number
    and #$03                            ; keep bit 0 and 1 (allows frame number to continue incrementing)
    tay                                 ; transfer ice_grenade_sprite_tbl offset to y
    lda ice_grenade_sprite_tbl,y        ; load appropriate sprite code
    sta ENEMY_SPRITES,x                 ; write enemy sprite code to CPU buffer
    jsr update_enemy_pos                ; apply velocities and scrolling adjust
    lda #$0a                            ; a = #$0a (gravity)
    jsr add_a_to_enemy_y_fract_vel      ; add a to enemy y fractional velocity
    bmi ice_grenade_exit                ; exit if no overflow
    lda #$00                            ; a = #$00
    sta ENEMY_SPRITE_ATTR,x             ; set enemy sprite attributes
    ldy #$04                            ; y = #$04 (distance from ground for explosion)
    jsr add_y_to_y_pos_get_bg_collision ; add #$04 to enemy y position and gets bg collision code
    beq ice_grenade_exit                ; exit if no collision
    lda #$24                            ; collision, set a = #$24 (sound_24)
    jsr play_sound                      ; play explosion sound
    jmp advance_enemy_routine           ; advance to mortar_shot_routine_03

; table for grenade sprite codes (#$4 bytes)
; sprite_74, sprite_75, sprite_76, sprite_77
ice_grenade_sprite_tbl:
    .byte $74,$75,$76,$77

; pointer table for tank (#$6 * #$2 = #$c bytes)
; tank is actually in nametable and stationary (not a sprite)
; auto scroll makes it look like the tank is approaching the player (ice separators are actually sprites)
tank_routine_ptr_tbl:
    .addr tank_routine_00 ; CPU address $a41a - initialize tank position and palettes
    .addr tank_routine_01 ; CPU address $a448 - animate tank driving to player until gets to within #$a0 pixels of player
    .addr tank_routine_02 ; CPU address $a4ee - tank stopped, fire at player
    .addr tank_routine_03 ; CPU address $a5b5 - tank starts moving again after stopping in previous routine
    .addr tank_routine_04 ; CPU address $a5e3 - disable collision, prep variables for next routine to remove tank, play
    .addr tank_routine_05 ; CPU address $a5f8 - tank destroyed routine

; initialize tank position and palettes
tank_routine_00:
    lda #$30                       ; a = #$30
    sta ENEMY_X_POS,x              ; set enemy x position on screen
    lda #$01                       ; a = #$01
    sta ENEMY_X_VEL_ACCUM,x        ; specify that the tank is off the screen to the right
    lda #$90                       ; a = #$90
    sta ENEMY_Y_POS,x              ; enemy y position on screen
    lda #$0c                       ; a = #$0c
    sta ENEMY_VAR_1,x              ; set turret aim direction (straight to the left)
    lsr                            ; a = #$06
    sta ENEMY_ATTACK_DELAY,x       ; set delay between attacks (#$06)
    lda #$3f                       ; a = #$3f
    sta PAUSE_PALETTE_CYCLE        ; disable palette color cycling
                                   ; tank is nametable tiles not a sprite, don't want its colors to change
    sta TANK_ICE_JOINT_SCROLL_FLAG ; set the ice joint enemy move left while player walks right
    sta LEVEL_PALETTE_INDEX+2      ; overwrite level palette to #$3f (offset into game_palettes)
                                   ; (COLOR_WHITE_20, COLOR_DARK_GRAY_00, COLOR_MED_ORANGE_17)
    lda #$41                       ; a = #$41 (COLOR_DARK_ORANGE_07, COLOR_DARK_GRAY_00, COLOR_MED_ORANGE_17)
    sta LEVEL_PALETTE_INDEX+3      ; overwrite level background palette to #$41 (offset into game_palettes)
    lda #$10                       ; number of palettes to load
    jsr load_palettes_color_to_cpu ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    ldx ENEMY_CURRENT_SLOT         ; load the current enemy slot number
    jmp advance_enemy_routine      ; move to tank_routine_01

; animate tank driving to player until gets to within #$a0 pixels of player
tank_routine_01:
    lda FRAME_COUNTER       ; load frame counter
    and #$01                ; auto scroll every other frame
    sta TANK_AUTO_SCROLL    ; enable automatic screen scroll to simulate tank scrolling left
    jsr tank_update_pos     ; update the tank's position, enabling bullet collision when appropriate
    lda ENEMY_X_VEL_ACCUM,x ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    bne tank_move_logic     ; branch if tank is not fully visible
    lda ENEMY_X_POS,x       ; tank is now on screen, load enemy x position on screen
    cmp #$a0                ; compare to tank stopping point
    bcc tank_stop           ; stop the tank if it at the stopping point

tank_move_logic:
    lda ENEMY_HP,x           ; load enemy hp
    beq @draw_tire           ; branch if hp is 0
    dec ENEMY_ATTACK_DELAY,x ; enemy hp is not 0, decrement delay between attacks
    bne @draw_tire           ; branch if attack delay hasn't elapsed
    lda #$1e                 ; a = #$1e (sound_1e)
    jsr play_sound           ; play tank attack sound
    lda #$06                 ; a = #$06 (tank sound repeat frequency)
    sta ENEMY_ATTACK_DELAY,x ; set delay between attacks

@draw_tire:
    lda FRAME_COUNTER              ; load frame counter
    and #$03                       ; keep bits .... ..xx (change tire animation every #$04 frames)
    tay                            ; transfer to tank_wheel_supertile_tbl offset
    lda tank_wheel_supertile_tbl,y ; load the correct tank tires based on frame
    sta $10                        ; tank tire super-tile
    lda FRAME_COUNTER              ; load frame counter
    and #$01                       ; keep bits .... ...x
    bne @draw_back_tire            ; draw different tire every other frame
    lda ENEMY_X_POS,x              ; load enemy x position on screen
    sec                            ; set carry flag in preparation for subtraction
    sbc #$0c                       ; subtract #$0c from enemy position to get front tire position
    sta $09                        ; set x position in $09
    lda ENEMY_X_VEL_ACCUM,x        ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    sbc #$00                       ; subtract 1
    bne @exit                      ; exit if front tire is already off screen
    beq @draw_specific_tire        ; draw tire if tank front tire is visible on screen

@draw_back_tire:
    lda ENEMY_X_POS,x       ; load enemy x position on screen
    clc                     ; clear carry in preparation for addition
    adc #$14                ; add #$14 to get back tire position
    sta $09                 ; set x position in $09
    lda ENEMY_X_VEL_ACCUM,x ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    adc #$00                ; add any overflow when determining back tire x position (#$ff = right edge of screen)
    bne @exit               ; exit if back tire is off screen to the right

@draw_specific_tire:
    ldy ENEMY_Y_POS,x                          ; tire y position on screen
    lda $09                                    ; load tire x position
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    ldx ENEMY_CURRENT_SLOT                     ; restore tank slot index

@exit:
    rts

tank_stop:
    lda #$00                    ; a = #$00
    sta TANK_AUTO_SCROLL        ; disabled automatic screen scroll
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    and #$01                    ; keep bit 0 (attack delay offset)
    tay                         ; transfer to offset register
    lda tank_attack_delay_tbl,y ; load specific tank attack delay
    sta ENEMY_VAR_4,x           ; delay for entire attack sequence
    lda #$47                    ; a = #$47 (hp for tank)
    sta ENEMY_HP,x              ; set enemy hp
    lda #$08                    ; a = #$08 (initial delay before first attack)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

tank_adv_routine:
    jmp advance_enemy_routine

; updates the tanks position and when on screen, enables player bullet collision
; note that the tank is still 'invincible' until it stops
; before the tank is visible, its actual position is behind the player.
; it isn't until the actual tank position is off screen to the left before
; the bullet collision is enabled
tank_update_pos:
    lda FRAME_SCROLL        ; how much to scroll the screen (#00 - no scroll)
    clc                     ; clear carry in preparation for addition
    adc TANK_AUTO_SCROLL    ; add amount to auto scroll
    sta $00                 ; store new frame scroll in $00
    lda ENEMY_X_POS,x       ; load enemy x position on screen
    sec                     ; set carry flag in preparation for subtraction
    sbc $00                 ; subtract the frame scroll
    sta ENEMY_X_POS,x       ; update enemy x position on screen
    bcs tank_routine_exit   ; exit if no underflow when determining new x position
    dec ENEMY_X_VEL_ACCUM,x ; tank visibility change state
                            ; either going from #$01 to #$00 (appearing on screen from right)
                            ; or going from #$00 to #$ff (offscreen to the left)
                            ; time to 'enable' to allow it to be attacked
    lda ENEMY_HP,x          ; load enemy hp
    beq tank_routine_exit   ; exit if tank hp is 0
    lda ENEMY_STATE_WIDTH,x ; load whether bullets affect and interact with tank
    eor #$81                ; flip bits x... ...x
    sta ENEMY_STATE_WIDTH,x ; enable bullet - tank collisions

tank_routine_exit:
    rts

; table for time during which tank is immobile (#$2 bytes)
; offset determined by ENEMY_ATTRIBUTES bit 0
tank_attack_delay_tbl:
    .byte $00,$f8

; tank stopped, fire at player
tank_routine_02:
    jsr tank_set_palette_update_pos ; update position, set palette, remove if appropriate
    bcc tank_routine_exit
    lda FRAME_COUNTER               ; load frame counter
    and #$01                        ; keep bits .... ...x
    bne @check_aim_fire
    dec ENEMY_VAR_4,x               ; decrement tank stop timer
    beq tank_adv_routine            ; if timer has elapsed, advance routine

; attack time counter is decreased by 1 on even frames (every other frame)
; tank isn't ready to start moving again, should fire at player
@check_aim_fire:
    lda ENEMY_STATE_WIDTH,x               ; load whether bullets should travel through tank
    bmi tank_routine_exit                 ; exit bullets should travel through tank (bit 7 is set)
    dec ENEMY_ANIMATION_DELAY,x           ; decrement enemy animation frame delay counter
    bne tank_routine_exit                 ; exit if animation delay hasn't elapsed
    lda ENEMY_VAR_3,x                     ; animation delay has elapsed, load remaining bullets to fire
    bne @create_bullet                    ; branch if there are still bullets to fire
    lda ENEMY_VAR_1,x                     ; fired all bullets in current round of attack, need to re-aim
    sta $17                               ; set aim direction in $17 (#$0c = straight left, #$0b = aiming down left, #$0a = down down left)
    jsr player_enemy_x_dist               ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    sty $0a                               ; store closest player in $0a
    ldy #$f4                              ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda #$00                              ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos                ; stores absolute screen x position in $09, and y position in $08
    jsr aim_var_1_for_quadrant_aim_dir_01 ; determine next aim direction [#$00-#$0b] ($0c), adjusts ENEMY_VAR_1 to get closer to that value using quadrant_aim_dir_01
    lda ENEMY_VAR_1,x                     ; load calculated aim direction
    cmp #$0a                              ; compare to the tank's lowest aiming direction
    bcc @keep_aim_direction               ; branch if calculated aim direction is not possible for tank to use previous aim direction
    cmp #$0d                              ; compare calculated aim direction to one past the maximum aim direction (straight left)
    bcc @set_bullets_draw_turret          ; branch if aiming less than up-left

; calculated aim direction from aim_var_1_for_quadrant_aim_dir_01 is not possible for tank
; instead, re-use previous round of attack's aim direction
@keep_aim_direction:
    lda $17           ; load last round of attack's aim direction
    sta ENEMY_VAR_1,x ; store back in ENEMY_VAR_1
    sta $0c           ; store result in $0c as well

@set_bullets_draw_turret:
    cmp $0c                         ; see if drawing the same turret as what's already drawn
                                    ; used to allow turret to slowly aim towards player, and only fire once aimed
    bne @draw_tank_turret_supertile ; branch to draw new turret super-tile if different
    lda #$03                        ; a = #$03 (number of consecutive bullets)
    sta ENEMY_VAR_3,x               ; set number of bullets to fire in next round of attack

@draw_tank_turret_supertile:
    lda ENEMY_VAR_1,x                          ; load tank turret aim direction
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$0a                                   ; subtract smallest aim direction (turret can only aim from #$0a to #$0c inclusively)
    tay                                        ; transfer offset to y
    lda tank_turret_supertile_code_tbl,y       ; load appropriate super-tile
    sta $10                                    ; set super-tile to draw
    lda ENEMY_Y_POS,x                          ; load enemy y position on screen
    sbc #$1c                                   ; subtract #$1c from from enemy's y position (y location of super-tile to draw)
    tay                                        ; transfer result to y for load_bank_3_update_nametable_supertile
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    sbc #$2c                                   ; subtract #$2c from from enemy's x position (x location of super-tile to draw)
    sta $00                                    ; set result in $00, will be used later in load_bank_3_update_nametable_supertile
    lda ENEMY_X_VEL_ACCUM,x                    ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    sbc #$00                                   ; subtract #$00 or #$01 if carry clear !(WHY?)
                                               ; I couldn't get this to happen
    bne tank_exit                              ; exit if result isn't #$00
    lda $00                                    ; load x position to draw tank super-tile
    jsr load_bank_3_update_nametable_supertile ; draw turret super-tile $10 at position (a,y)
    lda #$01                                   ; a = #$01
    bcs @set_delay_exit                        ; exit if unable to draw the super-tile for the turret
    ldx ENEMY_CURRENT_SLOT                     ; restore x to current enemy slot
    lda #$30                                   ; a = #$30 (delay before attack)
    bne @set_delay_exit                        ; set animation delay and exit

@create_bullet:
    lda ENEMY_VAR_1,x               ; load turret aim direction [#$0a-#$0c]
    sec                             ; set carry flag in preparation for subtraction
    sbc #$0a                        ; subtract minimum aim direction to get relative index, e.g. aim direction #$0b becomes #$01
    sta $00                         ; store offset in $00
    asl
    adc $00                         ; multiply offset by #$03 since each entry in tank_bullet_pos_vel_tbl is #$03 bytes
    tay                             ; transfer to offset register
    lda ENEMY_X_POS,x               ; load enemy x position on screen
    sbc tank_bullet_pos_vel_tbl,y   ; subtract relative x offset
    sta $09                         ; set bullet initial x position
    lda ENEMY_X_VEL_ACCUM,x         ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    sbc #$00                        ; subtract #$00 if turret on screen, #$01 if turret offscreen
    bcc tank_exit                   ; exit if turret is off screen to the left
    lda ENEMY_Y_POS,x               ; load enemy y position on screen
    sbc tank_bullet_pos_vel_tbl+1,y ; subtract relative y offset
    sta $08                         ; set bullet initial y position
    lda tank_bullet_pos_vel_tbl+2,y ; load bullet type (xxx. ....) and angle index (...x xxxx)
    ldy ENEMY_ATTRIBUTES,x          ; (tank bullets speed)
    jsr create_enemy_bullet_angle_a ; create a bullet with speed y, bullet type a, angle a at position ($09, $08)
    dec ENEMY_VAR_3,x               ; decrement number of bullets to fire for the round
    lda #$20                        ; a = #$20 (delay between bullets)

@set_delay_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

tank_exit:
    rts

; table for tank cannon tile codes (#$3 bytes)
; see level_5_nametable_update_supertile_data
tank_turret_supertile_code_tbl:
    .byte $13,$12,$0f

; table for tank bullets (#$9 bytes)
; byte 0: x offset of bullet (to the left)
; byte 1: y offset of bullet (to the left)
; byte 2: bullet type and angle
tank_bullet_pos_vel_tbl:
    .byte $24,$03,$09 ; position 0 (#$0a)
    .byte $29,$09,$0a ; position 1 (#$0b)
    .byte $2e,$14,$0c ; position 2 (#$0c)

; update position, set palette, remove if appropriate
tank_set_palette_update_pos:
    jsr tank_set_palette   ; set the tank's palette based on its hp
    jsr tank_update_pos    ; update the tank's position
    jmp tank_check_removal ; check if tank is destroyed and at position to be removed

; tank starts moving again after stopping in previous routine
tank_routine_03:
    lda FRAME_COUNTER               ; load frame counter
    and #$01                        ; keep bits .... ...x
    sta TANK_AUTO_SCROLL            ; enable automatic screen scroll
    jsr tank_set_palette_update_pos ; update position, set palette, remove if appropriate
    bcc tank_routine_03_exit
    jmp tank_move_logic

; output
;  * carry flag - clear when tank removed, set when not removed
tank_check_removal:
    lda ENEMY_X_VEL_ACCUM,x        ; load whether or not the tank is visible on screen
    sec                            ; set carry flag
    bpl tank_routine_03_exit       ; exit if tank is off screen
    lda ENEMY_X_POS,x              ; load enemy x position on screen
    cmp #$d0                       ; see if (invisible) destroyed tank has wrapped around and can be removed
    bcs tank_routine_03_exit       ; exit if tank hasn't gotten to removal point
    jsr remove_enemy               ; tank at removal point, remove enemy (from bank 7)
    lda #$00                       ; a = #$00
    sta TANK_AUTO_SCROLL           ; disable automatic screen scroll
    sta PAUSE_PALETTE_CYCLE        ; re-enable palette color cycling
    sta TANK_ICE_JOINT_SCROLL_FLAG ; stop the pipe joints from autoscrolling left
    ldx ENEMY_CURRENT_SLOT         ; restore x to enemy offset
    clc

tank_routine_03_exit:
    rts

; table for tank update super-tiles (#$4 bytes)
tank_wheel_supertile_tbl:
    .byte $10,$11,$14,$15

; disable collision, prep variables for next routine to remove tank, play
tank_routine_04:
    jsr tank_update_pos             ; update the tank's position
    jsr disable_enemy_collision     ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$05                        ; a = #$05
    sta ENEMY_VAR_1,x               ; set number of explosions and super-tiles to go through when destroying tank
    lda #$55                        ; a = #$55 (sound_55)
    jsr play_sound                  ; play tank destroyed sound
    lda #$00                        ; a = #$00
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; tank destroyed routine
tank_routine_05:
    lda FRAME_COUNTER                          ; load frame counter
    and #$01                                   ; keep bits .... ...x
    sta TANK_AUTO_SCROLL                       ; randomly enable/disable automatic screen scroll
    jsr tank_update_pos                        ; update the tank's position
    jsr tank_check_removal                     ; check if tank is destroyed and at position to be removed
    bcc @exit                                  ; branch if tank was removed
    lda ENEMY_ANIMATION_DELAY,x                ; load enemy animation frame delay counter
    bne @dec_delay_exit                        ; branch if animation delay hasn't elapsed
    lda ENEMY_VAR_1,x                          ; load current explosion animation to do
    bmi @exit                                  ; exit if have finished explosion animations
    asl
    asl
    adc ENEMY_VAR_1,x                          ; each entry is #$05 bytes, so double twice and add to itself
    tay                                        ; transfer to offset register
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    adc tank_destroy_tbl+1,y                   ; add relative x offset from enemy position
    sta $00                                    ; store in $00
    lda ENEMY_X_VEL_ACCUM,x                    ; load tank visibility (#$00 = visible, #$01 = off screen to right, #$ff = off screen to left)
    adc tank_destroy_tbl,y
    bne @dec_var_1_exit                        ; decrement explosion offset and exit
    lda ENEMY_Y_POS,x                          ; load enemy y position on screen
    adc tank_destroy_tbl+2,y                   ; add relative y offset from enemy position
    sty $07                                    ; store explosion destruction offset (ENEMY_VAR_1,x * #$05) in $07
    tay                                        ; transfer y position to draw super-tile to y
    lda #$9b                                   ;all black supertile (level_5_nametable_update_supertile_data - #$1b)
    sta $10                                    ; set black super-tile to draw in $10
    lda $00                                    ; load x position to draw super-tile in a
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    bcs @exit                                  ; exit if unable to draw super-tile so it can be attempted the next frame
    ldx ENEMY_CURRENT_SLOT                     ; restore x to the current enemy slot
    ldy $07                                    ; load explosion destruction offset (ENEMY_VAR_1,x * #$05) in $07
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    adc tank_destroy_tbl+3,y                   ; add relative x offset for explosion
    sta $09                                    ; store x position for explosion in $09
    lda ENEMY_Y_POS,x                          ; load enemy y position on screen
    clc                                        ; clear carry in preparation for addition
    adc tank_destroy_tbl+4,y                   ; add relative y offset for explosion
    sta $08                                    ; store y position for explosion in $08
    dec ENEMY_VAR_1,x                          ; decrement destruction sequence offset
    lda #$04                                   ; a = #$04
    sta ENEMY_ANIMATION_DELAY,x                ; set enemy animation frame delay counter
    jmp create_two_explosion_89                ; create explosion #$89 at location ($09, $08)

@dec_var_1_exit:
    dec ENEMY_VAR_1,x ; don't animate explosion, just decrement offset and exit

@exit:
    rts

@dec_delay_exit:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    rts

; table for data to use when a tank is destroyed (#$1e bytes)
; * byte 0 - used to help only animate part of the tank that is visible
; * byte 1 - x offset from tank position for blank super-tile to draw
; * byte 2 - y offset from tank position for blank super-tile to draw
; * byte 3 - x offset from tank position for explosion
; * byte 4 - y offset from tank position for explosion
tank_destroy_tbl:
    .byte $00,$16,$04,$1c,$0e ; ( 22,   4)
    .byte $00,$16,$e4,$1c,$f2 ; ( 22, -28)
    .byte $ff,$f6,$04,$00,$0e ; (-10,   4)
    .byte $ff,$f6,$e4,$00,$f2 ; (-10, -28)
    .byte $ff,$d6,$04,$e4,$0e ; (-42,   4)
    .byte $ff,$d6,$e4,$e4,$f2 ; (-42, -28)

; set tank palette based on HP
tank_set_palette:
    lda ENEMY_HP,x                 ; load enemy hp
    lsr
    lsr
    lsr
    lsr
    tay                            ; transfer to offset register, every 16 hp the palette changes
    lda tank_palette_tbl,y         ; load correct palette for tank
    sta LEVEL_PALETTE_INDEX+2      ; set tank's palette
    lda #$10                       ; a = #$10
    jsr load_palettes_color_to_cpu ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    ldx ENEMY_CURRENT_SLOT         ; restore x to enemy current slot (load_palettes_color_to_cpu overwrites x)
    rts

; table for tank palette changes based on hp (#$5 bytes)
tank_palette_tbl:
    .byte $61,$60,$5f,$3f,$3f

; pointer table for alien carrier - level 5 boss (#$18 bytes)
boss_ufo_routine_ptr_tbl:
    .addr boss_ufo_routine_00 ; CPU address $a6b2 - set y position and initialize palette fade in effect timer
    .addr boss_ufo_routine_01 ; CPU address $a6c3 - determine x position randomly, add #$20 to y (if overflow set y to #$30)
    .addr boss_ufo_routine_02 ; CPU address $a6e6 - draw super-tiles for the boss ufo at correct location
    .addr boss_ufo_routine_03 ; CPU address $a723 - animate opening top, enable collision
    .addr boss_ufo_routine_04 ; CPU address $a761 - generate mini ufos and bombs
    .addr boss_ufo_routine_05 ; CPU address $a7fd - animate closing of top, disable collision
    .addr boss_ufo_routine_06 ; CPU address $a817 - make ufo immediately invisible, and set BG_PALETTE_ADJ_TIMER to being fade in effect
    .addr boss_ufo_routine_07 ; CPU address $a82c - update nametable to black to get rid of old boss ufo drawn in nametable
    .addr boss_ufo_routine_08 ; CPU address $a834 - wait for animation delay and then go to boss_ufo_routine_01
    .addr boss_ufo_routine_09 ; CPU address $a83f - boss ufo destroyed routine, play sound disable collision, remove all enemies
    .addr boss_ufo_routine_0a ; CPU address $a857 - animate boss ufo explosions
    .addr boss_ufo_routine_0b ; CPU address $a8b5 - animate door explosion and opening

; set y position and initialize palette fade in effect timer
boss_ufo_routine_00:
    lda #$10                       ; a = #$10
    sta ENEMY_Y_POS,x              ; enemy y position on screen
    lda #$10                       ; a = #$10
    sta BG_PALETTE_ADJ_TIMER       ; create initial fade in effect for boss ufo
                                   ; gives #$08 frames to draw boss ufo super-tiles before fade in effect will start
    jsr load_palettes_color_to_cpu ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    ldx ENEMY_CURRENT_SLOT         ; restore x to current enemy slot
    jmp advance_enemy_routine      ; advance to boss_ufo_routine_01

; determine x position randomly, add #$20 to y (if overflow set y to #$30)
boss_ufo_routine_01:
    lda RANDOM_NUM           ; load random number
    and #$03                 ; keep bits .... ..xx
    tay                      ; transfer to offset register
    lda boss_ufo_x_pos_tbl,y ; load random boss ufo initial random x position
    sta ENEMY_X_POS,x        ; set enemy x position on screen
    lda ENEMY_Y_POS,x        ; load enemy y position on screen
    clc                      ; clear carry in preparation for addition
    adc #$20
    cmp #$71                 ; compare to max y position
    bcc @continue            ; continue if not greater than max y position
    lda #$30                 ; past max y position, set a = #$30

@continue:
    sta ENEMY_Y_POS,x ; set enemy y position on screen
    lda #$03          ; ENEMY_ANIMATION_DELAY is used as an index to know which super-tile to draw
                      ; and not really an animation delay

boss_ufo_set_delay_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a and advance enemy routine

; table for boss possible x positions (#$4 bytes)
boss_ufo_x_pos_tbl:
    .byte $40,$60,$80,$80

; draw super-tiles for the boss ufo at correct location
boss_ufo_routine_02:
    ldy ENEMY_ANIMATION_DELAY,x             ; load enemy animation frame delay counter (index of which super-tile to draw)
    lda boss_ufo_supertile_update_ptr_tbl,y ; load appropriate supertile based on delay [#$00-#$03]
                                            ; see level_5_nametable_update_supertile_data

; draw boss ufo supertiles as specified location index
; decrements ENEMY_ANIMATION_DELAY and see if result is positive,
;  * if positive, exit.  Otherwise, advance the routine
; input
;  * a - index into level_5_nametable_update_supertile_data
;  * y - location to draw super-tile (indexes into boss_ufo_supertile_pos_tbl)
boss_ufo_draw_supertile_a:
    sta $10                                    ; store nametable super-tile update index in $10
    tya                                        ; transfer delay index to a
    asl                                        ; double since each entry in boss_ufo_supertile_pos_tbl is #$02 bytes
    tay                                        ; transfer to offset register
    lda boss_ufo_supertile_pos_tbl,y           ; load the relative x position of the super-tile to draw
    adc ENEMY_X_POS,x                          ; add enemy x position to relative offset
    sta $00                                    ; store result in $00
    lda boss_ufo_supertile_pos_tbl+1,y         ; load the relative y position of the super-tile to draw
    clc                                        ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                          ; add enemy y position on screen to relative offset
    tay                                        ; transfer result to y for load_bank_3_update_nametable_supertile call
    lda $00                                    ; load x position of super-tile to draw for load_bank_3_update_nametable_supertile
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    ldx ENEMY_CURRENT_SLOT                     ; restore the enemy current slot to x
    dec ENEMY_ANIMATION_DELAY,x                ; decrement enemy animation frame delay counter
    bpl boss_ufo_exit_00                       ; exit if still have more super-tiles to draw
    lda #$02                                   ; drawn all super-tiles, a = #$02
    sta ENEMY_VAR_1,x                          ;
    lda #$60                                   ; a = #$60 (delay before starting attacks)
    bne boss_ufo_set_delay_adv_routine         ; always branch to advance routine

boss_ufo_exit_00:
    rts

; table for boss ufo super-tile data (see level_5_nametable_update_supertile_data) (#$4 bytes)
; #$0d - blue top fully open (left)
; #$0e - blue top fully open (right)
; #$07 - bottom thruster full throttle (left)
; #$08 - bottom thruster full throttle (right)
boss_ufo_supertile_update_ptr_tbl:
    .byte $0d,$0e,$07,$08

; table for relative x/y positions of boss ufo tile parts (#$8 bytes)
boss_ufo_supertile_pos_tbl:
    .byte $e4,$e4 ; top-left     (-28, -28)
    .byte $04,$e4 ; top-right    ( 04, -28)
    .byte $e4,$04 ; bottom-left  (-28,  04)
    .byte $04,$04 ; bottom-right ( 04,  04)

; animate opening top, enable collision
boss_ufo_routine_03:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    beq @timer_elapsed          ; branch if timer has elapsed
    jmp boss_ufo_draw_thrusters ; draw thruster super-tiles at appropriate thrust

@timer_elapsed:
    jsr enable_enemy_collision      ; enable bullet-enemy collision and player-enemy collision checks
    jsr boss_ufo_draw_blue_top      ; draw blue top if the delay timer has elapsed
    dec ENEMY_VAR_1,x               ; decrement which frame of the blue top to draw
    bpl boss_ufo_exit_00            ; exit if still more to animate
    lda #$00                        ; a = #$00
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

boss_ufo_draw_blue_top:
    lda #$0a                                    ; a = #$0a (delay when opening the side bays)
    sta ENEMY_ANIMATION_DELAY,x                 ; set enemy animation frame delay counter
    lda ENEMY_VAR_1,x                           ; load blue top super-tile index to draw
    asl                                         ; double since each entry is #$02 bytes
    tay                                         ; transfer to offset register
    lda boss_ufo_supertile_update_ptr_tbl_2+1,y ; load left side blue top super-tile
    sta $07                                     ; store super-tile to draw in $07
    lda boss_ufo_supertile_update_ptr_tbl_2,y   ; load right side blue top super-tile
    ldy #$00                                    ; set boss_ufo_supertile_pos_tbl index to #$00 (top-left)
    jsr boss_ufo_draw_supertile_a               ; draw boss ufo super-tile a at location index y
    lda $07                                     ; load left side blue top super-tile nametable update
    ldy #$01                                    ; set boss_ufo_supertile_pos_tbl index to #$01 (top-right)
    jmp boss_ufo_draw_supertile_a               ; draw boss ufo super-tile a at location index y

; table for side bays opening/closing sequence super-tiles (#$8 bytes)
; see (see level_5_nametable_update_supertile_data)
boss_ufo_supertile_update_ptr_tbl_2:
    .byte $0b,$05 ; top closing frame 1 (left), top closing frame 1 (right)
    .byte $0a,$04 ; top closing frame 2 (left), top closing frame 2 (right)
    .byte $09,$03 ; top closing frame 3 (left), top closing frame 3 (right)
    .byte $0d,$0e ; blue top fully open (left), blue top fully open (right)

; generate mini ufos and bombs
boss_ufo_routine_04:
    dec ENEMY_ANIMATION_DELAY,x    ; decrement enemy animation frame delay counter
    beq boss_ufo_set_routine_05    ; advance to boss_ufo_set_routine_05 if animation delay has elapsed
    lda ENEMY_ANIMATION_DELAY,x    ; load enemy animation frame delay counter
    and #$0f                       ; keep bits .... xxxx
    bne boss_ufo_draw_thrusters
    lda ENEMY_ANIMATION_DELAY,x    ; load enemy animation frame delay counter
    lsr
    lsr
    and #$0c                       ; keep bits .... xx..
    tay
    lda boss_ufo_enemy_gen_tbl,y   ; load enemy type to generate
    sta $0a                        ; store enemy type to generate
    lda boss_ufo_enemy_gen_tbl+1,y ; load x position of enemy to generate
    sty $17                        ; store x position of enemy to generate in $17
    ldy #$f4                       ; y = #$f4 (relative height of bombs and ufos)
    jsr generate_enemy_at_pos      ; generate enemy type $0a at relative position a,y
    bne boss_ufo_exit_01           ; exit if unable to create enemy
    ldx $17                        ; load x position of generated enemy
    lda boss_ufo_enemy_gen_tbl+2,x ; load x fast velocity for generated enemy
    sta ENEMY_X_VELOCITY_FAST,y    ; set x fast velocity for generated enemy
    lda #$10                       ; a = #$10 (delay between ufo appear and move)
    sta ENEMY_ANIMATION_DELAY,y    ; set delay for generated enemy
    lda #$02                       ; a = #$02
    sta ENEMY_SCORE_COLLISION,y    ; set enemy score collision code
    txa                            ; transfer x position of generated enemy to a
    and #$04                       ; keep bit 2
    bne @continue                  ; exit if x positions bit 2 is set (mini-ufo and not drop bomb)
    lda #$80                       ; a = #$80
    sta ENEMY_X_VELOCITY_FRACT,y   ; set mini-ufo fractional velocity to .5

@continue:
    lda boss_ufo_enemy_gen_tbl+3,x ; load enemy sprite code
    sta ENEMY_SPRITES,y            ; write enemy sprite code to CPU buffer
    ldx ENEMY_CURRENT_SLOT         ; restore x to boss ufo enemy slot index

boss_ufo_exit_01:
    rts

boss_ufo_set_routine_05:
    lda #$01                    ; a = #$01
    sta ENEMY_VAR_1,x           ; prep ENEMY_VAR_1 for drawing super-tiles in boss_ufo_routine_05
    lda #$08                    ; a = #$08
    bne boss_ufo_adv_routine_00 ; advance routine to boss_ufo_routine_05

boss_ufo_draw_thrusters:
    lda ENEMY_ANIMATION_DELAY,x          ; load enemy animation frame delay counter
    and #$07                             ; keep bits .... .xxx
    cmp #$03                             ; compare to #$03
    bne boss_ufo_exit_01                 ; exit if not #$03
    lda ENEMY_ANIMATION_DELAY,x          ; reload enemy animation frame delay counter
    sta $06                              ; backup animation delay in $06
    ldy #$00                             ; y = #$00 (thrusters full throttle)
    and #$08                             ; keep bit 3 of animation delay
    bne @load_rocket_thrusters_nametable ; throttle on thrusters changes every #$08 frames
    ldy #$02                             ; thrusters half throttle

@load_rocket_thrusters_nametable:
    lda #$02                                    ; a = #$02
    sta ENEMY_ANIMATION_DELAY,x                 ; set animation delay so that boss_ufo_draw_supertile_a doesn't advance routine
    lda boss_ufo_supertile_update_ptr_tbl_3+1,y ; load right thruster super-tile index
    sta $07                                     ; store right thruster super-tile in $07
    lda boss_ufo_supertile_update_ptr_tbl_3,y   ; load left thruster super-tile index
    ldy #$02                                    ; set the position index to draw to #$02 (bottom left)
    jsr boss_ufo_draw_supertile_a               ; draw boss ufo super-tile a at location index y
    lda $07                                     ; load right thruster super-tile index
    ldy #$03                                    ; set the position index to draw to #$03 (bottom right)
    jsr boss_ufo_draw_supertile_a               ; draw boss ufo super-tile a at location index y
    lda $06                                     ; restore animation delay to correct value
    sta ENEMY_ANIMATION_DELAY,x                 ; set enemy animation frame delay counter
    rts

; table for boss ufo enemy generation data (#$14 bytes)
; #$15 = enemy type
; #$14 = relative initial x position
; #$01 = initial x velocity (high byte)
; #$7c = enemy sprite code
boss_ufo_enemy_gen_tbl:
    .byte $15,$14,$01,$7c ; mini ufo (#$15) from right side (sprite_7c)
    .byte $16,$00,$00,$22 ; dropped bomb 1 (sprite_22)
    .byte $15,$ec,$fe,$7c ; mini ufo (#$15) from left side (sprite_7c)
    .byte $16,$00,$00,$22 ; dropped bomb 2 (sprite_22)

; #$07 = boss ufo - bottom thruster full throttle (left)
; #$08 = boss ufo - bottom thruster full throttle (right)
; #$0c = boss ufo - bottom thruster half throttle (left)
; #$06 = boss ufo - bottom thruster half throttle (right)
; see (see level_5_nametable_update_supertile_data)
boss_ufo_supertile_update_ptr_tbl_3:
    .byte $07,$08,$0c,$06 ; rocket thrusters tile codes

; animate closing of top, become invisible after drawing
boss_ufo_routine_05:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne boss_ufo_draw_thrusters ; draw thrusters super-tiles at appropriate thrust
    jsr boss_ufo_draw_blue_top  ; draw boss ufo top super-tiles
    inc ENEMY_VAR_1,x           ; move to
    lda ENEMY_VAR_1,x
    cmp #$04
    bne boss_ufo_exit_02
    jsr disable_enemy_collision ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$20                    ; a = #$20 (delay between bays closing and fade)

boss_ufo_adv_routine_00:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; make ufo immediately invisible, and set BG_PALETTE_ADJ_TIMER to being fade in effect
boss_ufo_routine_06:
    dec ENEMY_ANIMATION_DELAY,x     ; decrement enemy animation frame delay counter
    bne boss_ufo_draw_thrusters     ; continue to animate thrusters until animation delay has elapsed
    lda #$18                        ; delay has elapsed, a = #$18
    sta BG_PALETTE_ADJ_TIMER        ; create 'fade in' effect and make ufo immediately invisible
                                    ; every frame BG_PALETTE_ADJ_TIMER will be decremented, while outside the range of #$09 to #$01, black is drawn
                                    ; once in range [#$01-#$09], the ufo will be faded in, but it'll be at a new location
    lda #$10                        ; a = #$10 (loading #$10 nametable palettes)
    jsr load_palettes_color_to_cpu  ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    ldx ENEMY_CURRENT_SLOT          ; restore x to boss ufo enemy slot index
    lda #$03                        ; a = #$03
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a and advance enemy routine

; clear nametable where boss ufo was so that when BG_PALETTE_ADJ_TIMER is back in range [#$01-#$09], there is only one boss ufo
; and it's in a new location
boss_ufo_routine_07:
    ldy ENEMY_ANIMATION_DELAY,x   ; load super-tile index location [#$03-#$00]
    lda #$9b                      ; a = #$9b (#$1b - all black)
    jmp boss_ufo_draw_supertile_a ; draw boss ufo super-tile a at location index y

; wait for animation delay and then go to boss_ufo_routine_01
boss_ufo_routine_08:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne boss_ufo_exit_02        ; exit if animation delay hasn't elapsed
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to boss_ufo_routine_01

boss_ufo_exit_02:
    rts

; boss ufo destroyed routine, play sound disable collision, remove all enemies
boss_ufo_routine_09:
    jsr init_APU_channels
    lda #$55                    ; a = #$55 (sound_55)
    jsr play_sound              ; play sound
    jsr disable_enemy_collision ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$04                    ; a = #$04 (final explosions count)
    sta ENEMY_VAR_1,x           ; initialize explosion location index
    jsr destroy_all_enemies     ; destroy all mini-ufos and dropped bombs
    lda #$10                    ; a = #$10 (delay before final explosions)

boss_ufo_adv_routine_01:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; animate boss ufo explosions
boss_ufo_routine_0a:
    lda ENEMY_ANIMATION_DELAY,x            ; load enemy animation frame delay counter
    bne boss_ufo_dec_delay_exit            ; exit if animation delay hasn't elapsed
    lda ENEMY_VAR_1,x                      ; load explosion location index
    bmi boss_ufo_adv_to_0b                 ; branch if all explosions animated to advance to boss_ufo_routine_0b
    asl                                    ; double current explosion location index
    tay                                    ; transfer to offset register
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    sta $16                                ; store enemy x position in $16
    adc boss_ufo_explosion_rel_pos_tbl,y   ; add relative x offset for explosion
    sta ENEMY_X_POS,x                      ; set enemy x position on screen
    lda ENEMY_Y_POS,x                      ; load enemy y position on screen
    sta $17                                ; store enemy y position in $17
    clc                                    ; clear carry in preparation for addition
    adc boss_ufo_explosion_rel_pos_tbl+1,y ; add relative y offset for explosion
    sta ENEMY_Y_POS,x                      ; store enemy y position on screen
    cpy #$10                               ; see if position index is >= #$04, not sure why this is here, never happens !(WHY?)
    bcs boss_ufo_create_explosion          ; prevent updating the super-tile with black if location index is greater #$04
    lda #$9b                               ; a = #$9b (#$1b - all black)
    jsr draw_enemy_supertile_a             ; draw super-tile a (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs boss_ufo_move_explosion            ; branch if unable to draw explosion, not sure why this is coded like this !(WHY?)

boss_ufo_create_explosion:
    jsr set_08_09_to_enemy_pos  ; set $08 and $09 to enemy x's X and Y position
    dec ENEMY_VAR_1,x           ; decrement explosion location index
    lda #$08                    ; a = #$08 (delay between final explosions)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jmp create_two_explosion_89 ; create explosion #$89 at location ($09, $08)

boss_ufo_dec_delay_exit:
    dec ENEMY_ANIMATION_DELAY,x

boss_ufo_exit_03:
    rts

; moves the explosion by moving base enemy position
; backup for when unable to draw explosion due to CPU_GRAPHICS_BUFFER being full
; couldn't get to execute and not sure why this is implemented !(WHY?)
boss_ufo_move_explosion:
    lda $16
    sta ENEMY_X_POS,x ; set enemy x position on screen
    lda $17
    sta ENEMY_Y_POS,x
    rts

boss_ufo_adv_to_0b:
    lda #$02                    ; a = #$02
    sta ENEMY_VAR_1,x           ; init door explosion/opening index
    lda #$04                    ; a = #$04
    bne boss_ufo_adv_routine_01 ; advance routine to boss_ufo_routine_0b

; table for boss ufo final explosions relative offsets (#$a bytes)
; byte 0 - x relative offset
; byte 1 - y relative offset
boss_ufo_explosion_rel_pos_tbl:
    .byte $e0,$00 ; (-32,   0)
    .byte $00,$20 ; (  0,  32)
    .byte $20,$00 ; ( 20,   0)
    .byte $f0,$f0 ; (-16, -16)
    .byte $00,$00 ; (  0 ,  0)

; animate door explosion and opening
boss_ufo_routine_0b:
    lda ENEMY_ANIMATION_DELAY,x         ; load animation delay
    bne boss_ufo_dec_delay_exit         ; exit if animation delay hasn't elapsed
    lda ENEMY_VAR_1,x                   ; load door explosion index
    bmi @remove_boss                    ; branch to remove boss if all door explosions have happened
    asl
    adc ENEMY_VAR_1,x                   ; multiply by 3
    tay                                 ; transfer to offset register
    lda boss_ufo_door_explosion_tbl,y   ; load x position of door explosion
    sta ENEMY_X_POS,x                   ; set enemy x position on screen of door explosion
    lda boss_ufo_door_explosion_tbl+1,y ; load y position of door explosion
    sta ENEMY_Y_POS,x                   ; set enemy y position on screen of door explosion
    lda boss_ufo_door_explosion_tbl+2,y ; load super-tile to draw (see level_5_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a          ; draw super-tile a (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs boss_ufo_exit_03                ; exit if unable to draw super-tile
    jmp boss_ufo_create_explosion       ; create explosion at enemy position, i.e. explosion position

@remove_boss:
    jsr level_boss_defeated    ; play sound a (#$ff) !(BUG?) and set auto-move delay to ff, and set boss defeated flag
                               ; this does not occur in Japanese version of the game, because in that version
                               ; level_boss_defeated doesn't call play_sound
    lda #$30                   ; a = #$30
    jmp set_delay_remove_enemy

; table for boss ufo generation (#$9 bytes)
; byte 0 - x position for exit explosions
; byte 1 - y position for exit explosions
; byte 2 - super-tile to draw (see level_5_nametable_update_supertile_data)
boss_ufo_door_explosion_tbl:
    .byte $c0,$80,$96 ; (192, 128) (#$16 - boss screen open door top)
    .byte $c0,$a0,$97 ; (192, 160) (#$17 - boss screen open door)
    .byte $d0,$c0,$98 ; (208, 192) (#$18 - boss screen open door bottom)

; pointer table for flying saucer (#$7 * #$2 = #$e bytes)
mini_ufo_routine_ptr_tbl:
    .addr mini_ufo_routine_00          ; CPU address $a8fa
    .addr mini_ufo_routine_01          ; CPU address $a905
    .addr mini_ufo_routine_02          ; CPU address $a922
    .addr mini_ufo_routine_03          ; CPU address $a94c
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; flying saucer - pointer 1
mini_ufo_routine_00:
    dec ENEMY_ANIMATION_DELAY,x  ; decrement enemy animation frame delay counter
    beq mini_ufo_advance_routine ; go to mini_ufo_routine_01 if animation delay has elapsed
    jmp set_mini_ufo_sprite      ; go through sprites every #$04 frames to create rotation animation

mini_ufo_advance_routine:
    jmp advance_enemy_routine ; advance to next routine

; flying saucer - pointer 2
mini_ufo_routine_01:
    jsr dec_mini_ufo_anim_delay_set_sprite ; decrement ENEMY_ANIMATION_DELAY and update sprite (if needed)
    jsr update_enemy_x_pos_rem_off_screen  ; update X velocity; remove enemy if X position < #$08 (off screen to left)
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    cmp #$20                               ; left moving mini ufo point where starts vertical descent
    bcc @begin_descent                     ; if mini ufo is too far to the left, reverse direction
    cmp #$e0                               ; right moving mini ufo point where starts vertical descent
    bcc mini_ufo_exit                      ; exit if not ready to descend

; flying saucer y velocity going down (1.5) (high byte and low byte)
@begin_descent:
    lda #$80                     ; a = #$80 (.5)
    sta ENEMY_Y_VELOCITY_FRACT,x ; set fractional velocity to 1/2
    lda #$01                     ; a = #$01 (1)
    sta ENEMY_Y_VELOCITY_FAST,x  ; set fast velocity to 1
    bne mini_ufo_advance_routine ; move to mini_ufo_routine_02

; flying saucer - pointer 3
mini_ufo_routine_02:
    jsr dec_mini_ufo_anim_delay_set_sprite ; decrement ENEMY_ANIMATION_DELAY and update sprite (if needed)
    jsr set_enemy_y_vel_rem_off_screen     ; add velocity to enemy Y position; remove enemy if Y position >= #$e8 (off screen to bottom)
    lda ENEMY_Y_POS,x                      ; load enemy y position on screen
    cmp #$a8                               ; flying saucer bottom limit
    bcc mini_ufo_exit                      ; exit if not at lowest point of path
    lda #$a9                               ; a = #$a9 (y adjust when at bottom limit)
    sta ENEMY_Y_POS,x                      ; enemy y position on screen
    ldy #$01                               ; set fast velocity x portion to 1 (go right)
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    bpl @set_vel_adv_routine               ; branch if left mini ufo
    ldy #$fe                               ; set right mini ufo fast x velocity to -1 (go left)
                                           ; x velocity is -1.5 when considering fast and fractional velocities

@set_vel_adv_routine:
    tya                           ; transfer x velocity fast byte to a
    sta ENEMY_X_VELOCITY_FAST,x   ; set x velocity fast byte (1 for right, -1 for left)
    lda #$80                      ; a = #$80
    sta ENEMY_X_VELOCITY_FRACT,x  ; set x fractional velocity byte to .5 (1/2)
    jsr set_enemy_y_velocity_to_0 ; set y velocity to zero (stop descent)
    beq mini_ufo_advance_routine  ; go to mini_ufo_routine_03

mini_ufo_exit:
    rts

; flying saucer - pointer 4
mini_ufo_routine_03:
    jsr dec_mini_ufo_anim_delay_set_sprite ; decrement ENEMY_ANIMATION_DELAY and update sprite (if needed)

set_mini_ufo_drop_bomb_pos:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

dec_mini_ufo_anim_delay_set_sprite:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter

set_mini_ufo_sprite:
    lda ENEMY_ANIMATION_DELAY,x ; load animation delay
    and #$03                    ; keep bits .... ..xx
    bne @exit                   ; exit if not the #$04th frame
    inc ENEMY_SPRITES,x         ; every #$04 frames, change sprite
    lda ENEMY_SPRITES,x         ; load new sprite code
    cmp #$7f                    ; last sprite of mini ufo sprites
    bcc @exit                   ; exit if sprite is a mini ufo sprite
    sbc #$03                    ; went to non mini ufo sprite, subtract #$03 to set sprite_7c
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer

@exit:
    rts

; pointer table for drop bomb (#$4 * #$2 = #$8 bytes)
boss_ufo_bomb_routine_ptr_tbl:
    .addr boss_ufo_bomb_routine_00     ; CPU address $a974
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; drop bomb - pointer 1
boss_ufo_bomb_routine_00:
    lda #$28                       ; a = #$28 (gravity value for drop bomb)
    jsr add_a_to_enemy_y_fract_vel ; add a to enemy y fractional velocity, added every frame
    lda ENEMY_Y_POS,x              ; load enemy y position on screen
    cmp #$b0                       ; drop bomb explosion height
    bcc set_mini_ufo_drop_bomb_pos ; apply velocities and scrolling adjust
    jmp advance_enemy_routine      ; advance to next routine enemy_routine_init_explosion

; pointer table for pipe joint (2 bytes)
ice_separator_routine_ptr_tbl:
    .addr ice_separator_routine_00 ; CPU address $a985

; pipe joint - pointer 1
ice_separator_routine_00:
    lda #$c4                       ; a = #$c4 (sprite_c4)
    sta ENEMY_SPRITES,x            ; write sprite to sprite buffer
    lda TANK_ICE_JOINT_SCROLL_FLAG
    beq @add_scroll
    lda FRAME_SCROLL               ; how much to scroll the screen (#00 - no scroll)
    beq @exit                      ; exit if scroll is #$00
    dec ENEMY_X_POS,x              ; subtract sprite x position from scroll to keep it still on screen

@exit:
    rts

@add_scroll:
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position

; pointer table for energy fire down (#$4 * #$2 = #$8 bytes)
fire_beam_down_routine_ptr_tbl:
    .addr fire_beam_down_routine_00 ; CPU address $a9a1
    .addr fire_beam_down_routine_01 ; CPU address $a9c8
    .addr fire_beam_down_routine_02 ; CPU address $aa0f
    .addr fire_beam_down_routine_03 ; CPU address $aa2b

; fire beam down - pointer 1 - initialize enemy and initial attack delay, then advance routine
fire_beam_down_routine_00:
    lda #$04          ; a = #$04
    sta ENEMY_FRAME,x ; set enemy animation frame number
    lda #$80          ; a = #$80

; set fire beam collision attribute bit, position, and initial attack/animation delay, and advance routine
; input
;  * a - value to merge with fire beam's attributes to update collision code
fire_beam_add_pos_set_delay:
    ora ENEMY_ATTRIBUTES,x         ; merge flip bits with original enemy attributes
    sta ENEMY_ATTRIBUTES,x         ; update enemy attributes (to support flipping horizontally and/or vertically)
    lda #$08                       ; a = #$08
    jsr add_a_to_enemy_y_pos       ; add a to enemy y position on screen
    lda ENEMY_ATTRIBUTES,x         ; load enemy attributes
    lsr
    lsr
    and #$03                       ; keep bits .... ..xx
    tay                            ; set ... xx.. from enemy attributes to y
    lda fire_beam_anim_delay_tbl,y ; load animation delay
    sta ENEMY_VAR_A,x              ; storey in ENEMY_VAR_A

fire_beam_set_delay_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; table for fire beams delay between bursts (#$4 bytes)
fire_beam_anim_delay_tbl:
    .byte $00,$20,$40,$60

; fire beam down - pointer 2 - wait for initial attack delay, then wait for player proximity, then initialize attack and advance routine
fire_beam_down_routine_01:
    jsr animate_small_flame      ; animate small flame when fire beam isn't firing
    jsr add_scroll_to_enemy_pos  ; add scrolling to enemy position
    lda ENEMY_ANIMATION_DELAY,x  ; load enemy animation frame delay counter
    bne fire_beam_dec_delay_exit ; decrement animation delay and exit if delay hasn't elapsed
    jsr player_enemy_x_dist      ; animation delay timer elapsed, get closest player and his distance
                                 ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    cmp #$20                     ; see if player is within #$20 pixels of fire beam
    bcs fire_beam_down_exit      ; branch if closest player is farther than #$20

; load fire beam length, play sound, clear variables for use
begin_fire_beam_attack:
    lda ENEMY_X_POS,x                       ; load enemy x position on screen
    cmp #$30                                ; position at which fire beam stops firing (as player scrolls right)
    bcc fire_beam_down_exit                 ; don't fire if fire beam is too far to the left
    lda #$09                                ; load a = #$09 (sound_09)
    jsr play_sound                          ; play fire beam burning sound
    jsr enable_enemy_player_collision_check ; enable player collision check with flame
    lda ENEMY_ATTRIBUTES,x                  ; load enemy attributes
    and #$03                                ; keep bits 0 and 1 (fire beam length offset)
    tay                                     ; move offset to y
    lda fire_beam_length_tbl,y              ; load fire beam length
    sta ENEMY_VAR_2,x                       ; store fire beam length
                                            ; for transfer to either ENEMY_VAR_3 or ENEMY_VAR_4
                                            ; based on specific fire beam enemy type
    lda #$01                                ; a = #$01 (sprite_01 - blank)
    sta ENEMY_SPRITES,x                     ; write enemy sprite code to CPU buffer
    lda #$00                                ; a = #$00
    sta ENEMY_VAR_1,x
    sta ENEMY_VAR_3,x
    sta ENEMY_VAR_4,x
    beq fire_beam_set_delay_adv_routine     ; always branch

fire_beam_dec_delay_exit:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    rts

; table for fire beams possible lengths (#$4 bytes)
fire_beam_length_tbl:
    .byte $05,$09,$0d,$0f

; fire beam down - pointer 3 - attack
fire_beam_down_routine_02:
    jsr add_scroll_to_enemy_pos            ; add scrolling to enemy position
    ldy #$00                               ; y = #$00
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_down_exit
    dec ENEMY_VAR_2,x                      ; decrement fire beam length
    beq set_fire_beam_delay_10_adv_routine
    lda ENEMY_VAR_4,x                      ; load current fire beam length
    adc #$08                               ; add #$08 to length of fire beam
    sta ENEMY_VAR_4,x                      ; update fire beam length

fire_beam_down_exit:
    rts

set_fire_beam_delay_10_adv_routine:
    lda #$10                            ; a = #$10 (delay for fire beam to stay at max)
    bne fire_beam_set_delay_adv_routine

; fire beam down - pointer 4 - recede after delay, set new attack delay and go back to fire_beam_right_routine_01
fire_beam_down_routine_03:
    jsr add_scroll_to_enemy_pos        ; add scrolling to enemy position
    ldy #$02                           ; y = #$02
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_down_exit
    lda ENEMY_VAR_4,x
    sbc #$07
    sta ENEMY_VAR_4,x
    bpl fire_beam_down_exit

; set next ignition delay, disable collision, and set routine to fire_beam_xx_routine_01 to wait for delay and player proximity
fire_beam_disable_collision_routine_01:
    lda ENEMY_VAR_A,x           ; load next attack delay
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jsr disable_enemy_collision ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine fire_beam_xx_routine_01

; pointer table for fire beam left (#$4 * #$2 = #$8 bytes)
fire_beam_left_routine_ptr_tbl:
    .addr fire_beam_left_routine_00 ; CPU address $aa55
    .addr fire_beam_left_routine_01 ; CPU address $aa5a
    .addr fire_beam_left_routine_02 ; CPU address $aa6c
    .addr fire_beam_left_routine_03 ; CPU address $aa84

fire_beam_left_routine_00:
    lda #$40                        ; a = #$40
    jmp fire_beam_add_pos_set_delay ; merge #$40 (bit 6) with fire beam enemy attributes and advance routine

fire_beam_left_routine_01:
    jsr animate_small_flame     ; animate small flame when fire beam isn't firing
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda FRAME_COUNTER           ; load frame counter
    and #$7f                    ; keep bits .xxx xxxx
    cmp ENEMY_VAR_A,x
    bne fire_beam_left_exit
    jmp begin_fire_beam_attack  ; load fire beam length, play sound, clear variables for use

fire_beam_left_routine_02:
    jsr add_scroll_to_enemy_pos            ; add scrolling to enemy position
    ldy #$04                               ; y = #$04
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_left_exit
    dec ENEMY_VAR_2,x                      ; fire beam length
    beq set_fire_beam_delay_10_adv_routine
    lda ENEMY_VAR_3,x
    sbc #$07
    sta ENEMY_VAR_3,x

fire_beam_left_exit:
    rts

fire_beam_left_routine_03:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    ldy #$06                                   ; y = #$06
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_left_exit
    lda ENEMY_VAR_3,x
    adc #$08
    sta ENEMY_VAR_3,x
    bmi fire_beam_left_exit
    beq fire_beam_left_exit
    bpl fire_beam_disable_collision_routine_01

; pointer table for fire beam right (#$4 * #$2 = #$8 bytes)
fire_beam_right_routine_ptr_tbl:
    .addr fire_beam_right_routine_00 ; CPU address $aaa4 - initialize enemy and initial attack delay, then advance routine
    .addr fire_beam_right_routine_01 ; CPU address $aaae - wait for attack delay, then initialize attack and advance routine
    .addr fire_beam_right_routine_02 ; CPU address $aac3 - attack
    .addr fire_beam_right_routine_03 ; CPU address $aade - recede after delay, set new attack delay and go back to fire_beam_right_routine_01

; initialize enemy and initial attack delay, then advance routine
fire_beam_right_routine_00:
    lda #$40                        ; a = #$40
    sta ENEMY_SPRITE_ATTR,x         ; set enemy sprite attributes (flip sprite horizontally)
    lda #$00                        ; a = #$00
    jmp fire_beam_add_pos_set_delay ; set fire beam collision attribute bit, position, initial attack/animation delay, and advance routine

; wait for attack delay, then initialize attack and advance routine
fire_beam_right_routine_01:
    jsr animate_small_flame     ; animate small flame when fire beam isn't firing
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne fire_beam_right_exit_00 ; branch if attack delay hasn't elapsed to exit
    lda RANDOM_NUM              ; attack delay has elapsed, load random number
    and #$3f                    ; keep bits ..xx xxxx
    sta ENEMY_VAR_A,x           ; set delay between burst for subsequent attack (re-ignition)
    jmp begin_fire_beam_attack  ; load fire beam length, play sound, clear variables for use, and advance routine to attack (ignite)

; attack
fire_beam_right_routine_02:
    jsr add_scroll_to_enemy_pos        ; add scrolling to enemy position
    ldy #$08                           ; y = #$08
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_right_exit_00
    dec ENEMY_VAR_2,x                  ; decrement the current fire beam number of segments
    beq fire_beam_delay_10_adv_routine ; fire beam finished growing, advance routine to shrink back after delay
    lda ENEMY_VAR_3,x                  ; load horizontal fire beam length
    adc #$08                           ; add #$08 to length
    sta ENEMY_VAR_3,x                  ; update horizontal fire beam length

fire_beam_right_exit_00:
    rts

fire_beam_delay_10_adv_routine:
    jmp set_fire_beam_delay_10_adv_routine

; recede after delay, set new attack delay and go back to fire_beam_right_routine_01
fire_beam_right_routine_03:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    ldy #$0a                                   ; y = #$0a (fire_beam_tile_tbl tile offset)
    jsr draw_fire_beam_if_anim_elapsed
    bcs fire_beam_right_exit_00
    lda ENEMY_VAR_3,x                          ; load horizontal beam length
    sbc #$07                                   ; subtract #$08 (carry bit set) from horizontal beam length
    sta ENEMY_VAR_3,x                          ; update horizontal beam length
    bpl fire_beam_right_exit_00                ; exit if flame not fully receded
    jmp fire_beam_disable_collision_routine_01 ; flame fully receded, set attack delay and go back to fire_beam_right_routine_01

; input
;  * x - current enemy offset
;  * y - fire_beam_tile_tbl offset minus 1
; output
;  * carry flag - set when delay has not elapsed and fire beam should not yet recede
draw_fire_beam_if_anim_elapsed:
    lda ENEMY_ANIMATION_DELAY,x       ; load enemy animation frame delay counter
    bne set_fire_beam_anim_delay_exit
    lda ENEMY_VAR_3,x                 ; either ENEMY_VAR_3 or ENEMY_VAR_4 contain fire beam length
    ora ENEMY_VAR_4,x                 ; merge horizontal and vertical fire beam length
    beq @draw_fire_beam_section       ;
    iny                               ; fire beam length isn't #$00, increment fire_beam_tile_tbl offset

@draw_fire_beam_section:
    lda fire_beam_tile_tbl,y        ; offset into level_6_tile_animation
    sta $10                         ; load fire beam section update tiles offset
    lda ENEMY_VAR_4,x               ; load vertical fire beam length
    clc                             ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x               ; add fire eam length to enemy y position
    tay                             ; transfer result to y
    dey                             ; subtract #$01 from result
    lda ENEMY_X_POS,x               ; load enemy x position on screen
    sec                             ; set carry flag in preparation for subtraction
    sbc #$07                        ; subtract #$07 from fire beam x position
    sta $00                         ; store result in $00
    lda ENEMY_VAR_3,x               ; load horizontal fire beam length
    clc
    bmi fire_beam_add_x_length_exit ; add horizontal length, but don't draw if off screen
    adc $00
    bcc draw_fire_beam_tiles        ; draw fire beam section at (a, y)
    clc

fire_beam_exit:
    rts

fire_beam_add_x_length_exit:
    adc $00
    bcc fire_beam_exit

; draws the fire beam tiles $10 at (a, y), decrements animation delay
; input
;  * $10 - level_6_tile_animation offset (tiles to draw)
;  * a - x position to draw tile
;  * y - y position to draw tile
draw_fire_beam_tiles:
    jsr load_bank_3_update_nametable_tiles ; draw tile code $10 to nametable at (a, y)
    bcs @exit                              ; exit if unable to update nametable tiles
    ldx ENEMY_CURRENT_SLOT                 ; restore current enemy slot
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    cmp #$30                               ; see if fire beam is closer to the left edge
    lda #$00                               ; clear animation delay
    bcc @set_vars_exit                     ; set animation delay and update ENEMY_VAR_1 to fire beam length
    clc
    lda #$01                               ; a = #$01 (delay between steps of burst)

@set_vars_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda ENEMY_VAR_3,x
    ora ENEMY_VAR_4,x
    sta ENEMY_VAR_1,x

@exit:
    rts

set_fire_beam_anim_delay_exit:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    sec                         ; set carry flag
    rts

; table for fire beams tile codes (#$c bytes)
; offset into level_6_tile_animation
fire_beam_tile_tbl:
    .byte $87,$88,$80,$89 ; beam down
    .byte $84,$85,$80,$86 ; beam left
    .byte $81,$82,$80,$83 ; beam right

; animates small flame for when fire beam isn't firing
animate_small_flame:
    dec ENEMY_ATTACK_DELAY,x              ; decrement attack delay
    lda ENEMY_ATTACK_DELAY,x              ; load attack delay
    and #$07                              ; keep bits .... .xxx
    bne fire_beam_exit                    ; exit if not 8th frame
    lda ENEMY_ATTACK_DELAY,x              ; every 8th frame, change to next small flame animation
    lsr
    lsr
    lsr
    and #$03                              ; keep bits .... ..xx
    ora ENEMY_FRAME,x                     ; enemy animation frame number
    tay
    lda fire_beam_not_firing_sprite_tbl,y ; load sprite for animating flame before firing
    sta ENEMY_SPRITES,x                   ; write enemy sprite code to CPU buffer
    rts

; table for sprites for animating small flame before firing fire beam (#$8 bytes)
fire_beam_not_firing_sprite_tbl:
    .byte $01,$bf,$c0,$bf
    .byte $01,$c1,$c2,$c1

; pointer table for boss robot (#$a * #$2 = #$14 bytes)
boss_giant_soldier_routine_ptr_tbl:
    .addr boss_giant_soldier_routine_00 ; CPU address $ab93 - set hp sprite, y position and animation delay
    .addr boss_giant_soldier_routine_01 ; CPU address $abb3 - wait for animation delay
    .addr boss_giant_soldier_routine_02 ; CPU address $abbf
    .addr boss_giant_soldier_routine_03 ; CPU address $ac7b
    .addr boss_giant_soldier_routine_04 ; CPU address $acd4
    .addr boss_giant_soldier_routine_05 ; CPU address $ad16
    .addr boss_giant_soldier_routine_06 ; CPU address $ad49
    .addr boss_giant_soldier_routine_07 ; CPU address $ad61
    .addr boss_giant_soldier_routine_08 ; CPU address $ad9b
    .addr boss_giant_soldier_routine_09 ; CPU address $adad

; boss robot - pointer 0 - set hp sprite, y position and animation delay
boss_giant_soldier_routine_00:
.ifdef Probotector
    stx ENEMY_CURRENT_SLOT              ; backup current enemy slot number
    lda #$5e                            ; 4th level sprite palette
    sta LEVEL_PALETTE_INDEX+7           ; set 4th level sprite palette (offset into game_palettes)
    lda #$20                            ; a = #$20
    jsr load_palettes_color_to_cpu      ; load #$20 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    ldx ENEMY_CURRENT_SLOT              ; restore current enemy slot number
.endif
    lda PLAYER_WEAPON_STRENGTH
    asl
    asl
    asl
    adc #$40
    sta ENEMY_HP,x                      ; set enemy hp (40 + wsc * 8)
    lda RANDOM_NUM                      ; load random number
    sta ENEMY_VAR_1,x                   ; store random number in ENEMY_VAR_1
    lda #$b8                            ; a = #$b8 (sprite_b8) giant boss soldier standing
    sta ENEMY_SPRITES,x                 ; write enemy sprite code to CPU buffer
    lda #$9b                            ; a = #$9b (initial boss y position)
    sta ENEMY_Y_POS,x                   ; enemy y position on screen
    lda #$31                            ; a = #$31 (initial boss delay waiting)
    sta ENEMY_ANIMATION_DELAY,x         ; set enemy animation frame delay counter
    bne giant_soldier_adv_enemy_routine

; boss robot - pointer 1 - wait for delay
boss_giant_soldier_routine_01:
    jsr update_enemy_pos                ; apply velocities and scrolling adjust
    dec ENEMY_ANIMATION_DELAY,x         ; decrement enemy animation frame delay counter
    beq giant_soldier_adv_enemy_routine
    rts

giant_soldier_adv_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; boss robot - pointer 2
boss_giant_soldier_routine_02:
    jsr update_enemy_pos                 ; apply velocities and scrolling adjust
    lda ENEMY_VAR_1,x                    ; load initialized random number
    and #$03                             ; keep bits .... ..xx
    bne begin_giant_soldier_attack       ; 3/4 chance of branching
    jsr giant_soldier_face_random_player ; 1/4 chance of happening, walk towards player
    lda #$f9                             ; a = #$f9
    sta ENEMY_Y_VELOCITY_FAST,x          ; set initial y fast velocity when jumping
    lda #$80                             ; a = #$80
    sta ENEMY_Y_VELOCITY_FRACT,x         ; set initial y fractional velocity when jumping
    lda RANDOM_NUM                       ; load random number
    adc FRAME_COUNTER                    ; add random number to frame counter
    and #$03                             ; keep bits .... ..xx
    asl                                  ; strip #$00 to #$04 to just either #$00 or #$02
    tay                                  ; transfer #$00 or #$02 to y
    lda boss_giant_soldier_x_vel_tbl,y   ; load x velocity fast byte
    sta ENEMY_X_VELOCITY_FAST,x          ; store in x velocity fast byte
    lda boss_giant_soldier_x_vel_tbl+1,y ; load x fractional velocity byte
    sta ENEMY_X_VELOCITY_FRACT,x         ; store in x fractional velocity byte
    lda #$00                             ; a = #$00
    sta ENEMY_VAR_4,x                    ; initialize number of thrown saucers to #$00
    lda #$ba                             ; a = #$ba (sprite_ba) sprite code while jumping
    sta ENEMY_SPRITES,x                  ; set sprite code to sprite_ba
    lda #$05                             ; a = #$05 (advance to boss_giant_soldier_routine_04)

giant_soldier_set_enemy_routine_a:
    jmp set_enemy_routine_to_a ; set enemy routine index to a

begin_giant_soldier_attack:
    cmp #$01                             ; probability of attacking (1/4)
    bne @walk_to_player                  ; don't attack
    jsr giant_soldier_face_random_player ; attack
    inc ENEMY_VAR_4,x                    ; increment number of thrown saucers
    lda ENEMY_VAR_4,x                    ; load number of thrown saucers
    cmp #$04                             ; max number of consecutive thrown saucers
    bcs giant_soldier_stay_still         ; stay still if thrown #$04 consecutive saucers
    lda #$20                             ; a = #$20 (delay before throwing position)
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    bne giant_soldier_adv_enemy_routine  ; go to boss_giant_soldier_routine_03

@walk_to_player:
    jsr giant_soldier_face_random_player
    lda RANDOM_NUM                            ; load random number
    and #$01                                  ; keep bits .... ...x
    asl
    tay
    lda boss_giant_soldier_walk_x_vel_tbl,y   ; load walking x velocity fast byte
    sta ENEMY_X_VELOCITY_FAST,x               ; store walking x velocity fast byte
    lda boss_giant_soldier_walk_x_vel_tbl+1,y ; load walking x fractional velocity byte
    sta ENEMY_X_VELOCITY_FRACT,x              ; store walking x fractional velocity byte
    lda #$0c                                  ; a = #$0c
    sta ENEMY_VAR_2,x                         ; delay for first step of walking
    lda #$06                                  ; a = #$06
    bne giant_soldier_set_enemy_routine_a     ; go to boss_giant_soldier_routine_05

giant_soldier_stay_still:
    lda #$b8                              ; a = #$b8 (sprite_b8) giant boss soldier standing
    sta ENEMY_SPRITES,x                   ; write enemy sprite code to CPU buffer
    jsr set_enemy_velocity_to_0           ; set x/y velocities to zero
    lda RANDOM_NUM                        ; load random number
    sta ENEMY_VAR_1,x                     ; store random number in ENEMY_VAR_1
    adc FRAME_COUNTER                     ; add frame counter to random number
    and #$80                              ; keep bits x... ....
    ora ENEMY_ANIMATION_DELAY,x           ; (extend delay before next attack by 0 or 80)
    sta ENEMY_ANIMATION_DELAY,x           ; set enemy animation frame delay counter
    lda #$03                              ; a = #$03
    bne giant_soldier_set_enemy_routine_a ; always branch to boss_giant_soldier_routine_02

; gets boss to face random non-game over player
giant_soldier_face_random_player:
    ldy #$00                ; y = #$00 (player 1)
    lda P2_GAME_OVER_STATUS ; load player 2 game over state (1 = game over)
    bne @set_sprite_attr    ; flip sprite horizontally if appropriate, then exit
    lda RANDOM_NUM          ; player 2 not in game over, load random number
    and #$01                ; keep bit 0 (select random player)
    tay                     ; transfer player index to y
    lda P1_GAME_OVER_STATUS ; game over state of player 1
    beq @set_sprite_attr    ; flip sprite horizontally if appropriate, then exit
    ldy #$01                ; y = #$01, player 1 in game over, use player 2

@set_sprite_attr:
    lda SPRITE_X_POS,y        ; load randomly selected non-dead player's current x position
    sta $08                   ; store in $08
    lda ENEMY_X_POS,x         ; load enemy current x position
    cmp $08                   ; compare enemy x position to player x position
    lda #$00                  ; a = #$00 (assume boss facing left)
    bcs @set_sprite_attr_exit ; branch if enemy to right of player (boss face left)
    lda #$40                  ; player to right of enemy, flip sprite horizontally to face right

@set_sprite_attr_exit:
    sta ENEMY_SPRITE_ATTR,x ; set enemy sprite attributes
    rts

; table for possible x velocities when jumping (#$8 bytes)
; seems to happen rarely, only at the beginning
; when he is not on his left or right limit (x position)
boss_giant_soldier_x_vel_tbl:
    .byte $00,$80
    .byte $00,$00
    .byte $00,$00
    .byte $ff,$80

; table for level 6 boss walking speed (#$4 bytes)
boss_giant_soldier_walk_x_vel_tbl:
    .byte $01,$18
    .byte $fe,$e8

; boss robot - pointer 3
; creates spiked projectiles
boss_giant_soldier_routine_03:
    jsr update_enemy_pos          ; apply velocities and scrolling adjust
    lda ENEMY_ATTACK_FLAG         ; see if enemies should attack
    beq boss_giant_stay_still     ; exit if enemies shouldn't attack
    dec ENEMY_ANIMATION_DELAY,x   ; decrement enemy animation frame delay counter
    beq create_spiked_projectile  ; create the spiked projectile
    lda ENEMY_ANIMATION_DELAY,x   ; attack delay not elapsed, load enemy animation frame delay counter
    cmp #$0f                      ; (determines delay for throw stance)
    bcs set_giant_soldier_palette ; change palette according to hp (every #$04 frames)
    lda #$c3                      ; a = #$c3 (sprite_c3) sprite code before throw
    sta ENEMY_SPRITES,x           ; write enemy sprite code to CPU buffer

; change palette according to hp
set_giant_soldier_palette:
    lda FRAME_COUNTER ; load frame counter
    and #$07          ; keep bits .... .xxx
    cmp #$03          ; only update palette every #$04 frames
    bne @exit
    lda ENEMY_HP,x    ; every #$04 frames, check palette, load enemy hp
    cmp #$20          ; normal palette if hp >= #$20
    bcs @exit
    ldy #$51          ; palette #$01 (palette for medium damage)
    cmp #$10          ; medium damage if hp >= #$10 and < #$20
    bcs @set_palette  ; branch if hp > #$10, use palette #$01
    ldy #$52          ; hp < #$10, palette #$02 (palette for critical damage)

; critical damage if hp < 10
@set_palette:
    tya                            ; transfer palette (and sprite byte override) to a
    sta LEVEL_PALETTE_INDEX+7      ; set sprite's 3rd palette
    lda #$20                       ; a = #$20
    jsr load_palettes_color_to_cpu ; load #$20 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

create_spiked_projectile:
    lda #$14                  ; a = #$14 (14 = spiked disk projectile)
    sta $0a                   ; set enemy type for projectile
    lda #$f0                  ; a = #$f0 (initial relative x position)
    ldy #$e8                  ; y = #$e8 (initial relative y position)
    jsr generate_enemy_at_pos ; generate enemy type $0a at relative position a,y
    bne boss_giant_stay_still ; exit if unable to create spiked disk projectile
    lda ENEMY_SPRITE_ATTR,x   ; load boss giant's ENEMY_SPRITE_ATTR
    and #$40                  ; load boss giant's horizontal flip bit
    beq boss_giant_stay_still ; branch if boss giant facing left
    lda ENEMY_X_POS,y         ; load spiked saucer x position on screen
    adc #$30                  ; add 30 to x position if facing right
    sta ENEMY_X_POS,y         ; set spiked saucer x position on screen

boss_giant_stay_still:
    jmp giant_soldier_stay_still

; boss robot - pointer 4
boss_giant_soldier_routine_04:
    jsr set_giant_soldier_palette ; change palette according to hp (every #$04 frames)
    jsr @apply_gravity            ; apply gravity and x boundaries check
    jsr update_enemy_pos          ; apply velocities and scrolling adjust
    lda ENEMY_Y_POS,x             ; load enemy y position on screen
    cmp #$9b                      ; ground limit when landing after jump
    bcs @boss_landing             ; branch if landed on ground
    rts

; boss robot landing
@boss_landing:
    lda #$15                    ; a = #$15 (sound_15)
    jsr play_sound              ; play boss robot landing sound
    jsr set_enemy_velocity_to_0 ; set x/y velocities to zero
    lda #$9b                    ; a = #$9b
    sta ENEMY_Y_POS,x           ; set enemy y position on screen to ground
    lda #$b8                    ; a = #$b8 (sprite_b8) (same as sprite_b7)
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer
    bne boss_giant_stay_still

; apply gravity and x boundaries check
@apply_gravity:
    lda #$38                       ; a = #$38 (gravity when jumping)
    jsr add_a_to_enemy_y_fract_vel ; add a to enemy y fractional velocity (#$38)
    lda ENEMY_X_POS,x              ; load enemy x position on screen
    cmp #$21                       ; #$20 = left boundary
    bcc @set_enemy_to_left_edge    ; giant soldier is at left edge, hard code stop at boundary
    cmp #$c0                       ; #$c0 = right boundary
    bcc @exit                      ; enemy hasn't reached left nor right boundary, exit
    lda #$c0                       ; reached right boundary hard code stop at boundary
    bne @set_to_x_boundary         ; always branch to set giant soldier to right boundary

@set_enemy_to_left_edge:
    lda #$20 ; a = #$20

@set_to_x_boundary:
    sta ENEMY_X_POS,x             ; set enemy x position on screen
    jsr set_enemy_x_velocity_to_0 ; set x velocity to zero

@exit:
    rts

; boss robot - pointer 5
boss_giant_soldier_routine_05:
    jsr set_giant_soldier_palette ; change palette according to hp (every #$04 frames)
    jsr update_enemy_pos          ; apply velocities and scrolling adjust
    lda ENEMY_X_POS,x             ; load enemy x position on screen
    cmp #$20                      ; left limit when walking
    bcc @stay_still
    cmp #$c0                      ; right limit when walking
    bcs @stay_still
    dec ENEMY_VAR_2,x             ; decrement delay between steps
    beq @continue                 ; branch if delay has elapsed
    rts

@stay_still:
    jmp giant_soldier_stay_still

@continue:
    lda #$00            ; a = #$00
    sta ENEMY_VAR_4,x   ; clear number of consecutive thrown saucers
    lda #$0c            ; a = #$0c (delay between steps)
    sta ENEMY_VAR_2,x   ; initialize delay between steps
    inc ENEMY_VAR_3,x
    lda ENEMY_VAR_3,x
    and #$01            ; keep bits .... ...x
    clc                 ; clear carry in preparation for addition
    adc #$b8            ; load sprite_b8 (sprite_b7) or sprite_b9
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer
    rts

boss_giant_soldier_routine_06:
    jsr init_APU_channels
    lda #$55                        ; a = #$55 (sound_55)
    jsr level_boss_defeated         ; play sound and initiate auto-move
    jsr clear_enemy_custom_vars     ; set ENEMY_VAR_1, ENEMY_VAR_2, ENEMY_VAR_3, ENEMY_VAR_4 to zero
    sta ENEMY_SPRITES,x             ; write enemy sprite code to CPU buffer
    sta $08                         ; set relative y offset to #$00
    sta $09                         ; set relative x offset to #$00
    jsr create_giant_boss_explosion ; create explosion at center of enemy
                                    ; $09 - relative x offset, $08 - relative y offset
    jmp advance_enemy_routine       ; advance enemy in slot x to next routine

; create explosion animations
boss_giant_soldier_routine_07:
    lda #$08                        ; a = #$08
    sta ENEMY_ANIMATION_DELAY,x     ; set enemy animation frame delay counter
    lda ENEMY_VAR_1,x               ; load explosion number
    cmp #$04                        ; number of explosions when boss is destroyed
    bcc @create_explosion           ; when not yet created all explosions branch
    lda #$30                        ; all explosions have been created, set delay and move to next routine
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to #$30
                                    ; move to boss_giant_soldier_routine_08

@create_explosion:
    inc ENEMY_VAR_1,x                    ; increment explosion number
    asl                                  ; double for offset
    tay                                  ; transfer boss_giant_explosion_loc_tbl offset to y
    lda boss_giant_explosion_loc_tbl,y   ; load relative y offset to enemy for explosion
    sta $08                              ; store relative y offset to enemy for explosion
    lda boss_giant_explosion_loc_tbl+1,y ; load relative x offset to enemy for explosion
    sta $09                              ; store relative x offset to enemy for explosion

create_giant_boss_explosion:
    lda ENEMY_Y_POS,x           ; load enemy y position on screen
    adc $08                     ; add relative y offset for explosion y location
    tay                         ; transfer result to y
    lda ENEMY_X_POS,x           ; load enemy x position on screen
    adc $09                     ; add relative x offset for explosion x location
    sty $08                     ; store absolute y location of explosion in $08
    sta $09                     ; store absolute x location of explosion in $09
    jmp create_two_explosion_89 ; create explosion #$89 at location ($09, $08)

; table for explosions relative offsets (#$4 * #$2 = #$8 bytes)
; byte 0 - y offset
; byte 1 - x offset
boss_giant_explosion_loc_tbl:
    .byte $f0,$f0 ; -16, -16
    .byte $10,$10 ;  16,  16
    .byte $f0,$10 ; -16,  16
    .byte $10,$f0 ;  10, -10

boss_giant_soldier_routine_08:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    beq @continue               ; useless branching !(HUH)

@continue:
    jsr clear_enemy_custom_vars     ; set ENEMY_VAR_1, ENEMY_VAR_2, ENEMY_VAR_3, ENEMY_VAR_4 to zero
    lda #$08                        ; a = #$08 (number of steps for door opening)
    sta ENEMY_VAR_3,x
    lda #$0a                        ; a = #$0a (delay for 1st step of door opening)
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; waits for animation timer to elapse, then opens next part of door, repeats until door opened
boss_giant_soldier_routine_09:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    beq @open_door_section      ; enemy destroyed delay elapsed, open door
    rts

; updates the door nametable tiles for most of the opening animation when ENEMY_VAR_1 is #$01
; this is the majority of the door opening animation
@mode_1_open_door:
    lda #$8c                               ; a = #$8c (blank spot and top of door tile code)
    sta $10                                ; set tile index offset for load_bank_3_update_nametable_tiles
    lda ENEMY_VAR_2,x                      ; load the y position of the bottom of the end of level door (for animating)
    tay                                    ; set y position
    lda #$d0                               ; a = #$d0 (x position to draw tiles)
    jsr load_bank_3_update_nametable_tiles ; draw the open door tile code $10 at position (#$d0, y)
    ldx ENEMY_CURRENT_SLOT                 ; restore x's value to the current enemy (boss giant)
    dec ENEMY_VAR_3,x                      ; decrement door opening animation timer
    bne @set_door_next_open_pos            ; if animation timer hasn't elapsed don't update ENEMY_VAR_1 to #$02
    inc ENEMY_VAR_1,x                      ; animation timer has elapsed, increment ENEMY_VAR_1 to #$02 (top of door animation frame)

@set_door_next_open_pos:
    lda ENEMY_VAR_2,x ; load current y position of the bottom of the end of level door
    sec               ; set carry flag in preparation for subtraction
    sbc #$08          ; subtract #$08 from y position
    sta ENEMY_VAR_2,x ; update y position
    rts

; boss_giant_soldier_routine_09, delay elapsed, open door
; ENEMY_VAR_1 #$00 and #$02 uses boss_giant_door_open_ptr_tbl, #$01 uses @mode_1_open_door
@open_door_section:
    lda #$0a                             ; a = #$0a (delay for each step of door opening)
    sta ENEMY_ANIMATION_DELAY,x          ; frame delay counter for door opening animation
    lda ENEMY_VAR_1,x                    ; load door opening animation frame type
    cmp #$01                             ; see if use the most common nametable update tile
    beq @mode_1_open_door                ; ENEMY_VAR_1 uses #$8c for animating the door opening (most common)
    asl                                  ; ENEMY_VAR_1 is either #$00 or #$02, double since each entry is #$02 bytes
    tay                                  ; transfer to offset register
    lda boss_giant_door_open_ptr_tbl,y   ; load low byte of address
    sta $04                              ; set low byte of address in $04
    lda boss_giant_door_open_ptr_tbl+1,y ; load high byte of address
    sta $05                              ; store high byte of address in $05
    ldy #$00                             ; initialize y = #$00
    lda ($04),y                          ; load initial y position of door animation
    clc                                  ; clear carry in preparation for addition
    adc #$10                             ; add #$10 to the position (move down)
    sta $06                              ; update initial y position of door opening update
    lda #$d0                             ; a = #$d0
    sta $07                              ; set x position of door
    stx ENEMY_CURRENT_SLOT

@update_door_tiles:
    lda $07                                ; load x position of door
    iny                                    ; increment boss_giant_door_open_xx read offset
    lda ($04),y                            ; load tile to draw (offset into tile_animation table)
    cmp #$ff                               ; see if end of data byte
    beq @finished_drawing_door
    sta $10                                ; set nametable tile to draw
    tya                                    ; transfer to offset register
    pha                                    ; push a to stack
    lda $07                                ; load x position
    ldy $06                                ; load y position
    jsr load_bank_3_update_nametable_tiles ; draw tile code $10 to nametable at (a, y)
    pla                                    ; restore a register (nametable tile to draw)
    tay                                    ; transfer a to offset register
    lda $06                                ; load y position of door animation
    clc                                    ; clear carry in preparation for addition
    adc #$10                               ; add #$10 to y position (move down)
    sta $06                                ; update $06 with new y position
    jmp @update_door_tiles                 ; loop to next part of nametable to draw

@finished_drawing_door:
    ldx ENEMY_CURRENT_SLOT
    lda $06                ; load current door opening position
    sec                    ; set carry flag in preparation for subtraction
    sbc #$20               ;
    sta ENEMY_VAR_2,x      ; update door opening y location
    inc ENEMY_VAR_1,x      ; increment opening animation frame type
    lda ENEMY_VAR_1,x      ; load opening animation frame type
    cmp #$03               ; compare to #$03
    beq @remove_enemy      ; if finished all three frame types (#$00, #$01, #$02)
    rts

@remove_enemy:
    lda #$01                   ; a = #$01
    jmp set_delay_remove_enemy

; pointer table for boss giant soldier door opening (#$3 * #$2 = #$6 bytes)
; related to ENEMY_VAR_1
; boss_giant_door_open_00 is for the beginning of the animation (lifting from floor)
; boss_giant_door_open_01 is for the end of the animation (lifting into top)
boss_giant_door_open_ptr_tbl:
    .addr boss_giant_door_open_00 ; CPU address $ae3b
    .addr boss_giant_door_open_00 ; CPU address $ae3b (unused, filler)
                                  ; filler because ENEMY_VAR_1 = 1 uses #$8c (see @mode_1_open_door)
    .addr boss_giant_door_open_01 ; CPU address $ae3f

; table for boss giant door being opening tiles (#$4 bytes)
; byte 0 is initial y position. the rest of the bytes reference level_6_tile_animation
boss_giant_door_open_00:
    .byte $90,$8b,$8a,$ff

; table for boss giant end door opening (#$3 bytes)
; byte 0 is initial y position. the rest of the bytes reference level_6_tile_animation
boss_giant_door_open_01:
    .byte $58,$8d,$ff

; pointer table for spiked disk projectile (#$3 * #$2 = #$6 bytes)
boss_giant_projectile_routine_ptr_tbl:
    .addr boss_giant_projectile_routine_00 ; CPU address $ae48 - set sprite code, and velocities
    .addr boss_giant_projectile_routine_01 ; CPU address $ae8a - update position, if animation delay has elapsed, update sprite so the disk rotates
    .addr remove_enemy                     ; CPU address $e809 from bank 7

; set sprite code, and velocities
boss_giant_projectile_routine_00:
    lda #$06                     ; a = #$06 (delay between frames when airborne)
    sta ENEMY_ANIMATION_DELAY,x  ; set enemy animation frame delay counter
    lda #$bb                     ; a = #$bb (sprite_bb)
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
                                 ; assume boss giant facing left, set spiked velocity
                                 ; if not, will be changed later (+14 lines down)
    lda #$fd                     ; a = #$fd (-3)
    sta ENEMY_X_VELOCITY_FAST,x  ; set spiked disk x fast velocity
    lda #$00                     ; a = #$00
    sta ENEMY_X_VELOCITY_FRACT,x ; set spiked disk x fractional velocity
    ldx #$0f                     ; set enemy slot offset to #$0f

@find_boss_giant:
    lda ENEMY_TYPE,x     ; load current enemy type
    cmp #$13             ; see if current slot is boss giant
    beq @continue        ; branch if boss giant found
    dex                  ; search next enemy slot
    bne @find_boss_giant ; boss giant not found, loop

@continue:
    lda ENEMY_SPRITE_ATTR,x      ; load enemy sprite attributes
    and #$40                     ; keep bit 6 (horizontal flip flag)
    beq @set_y_vel_adv_routine   ; branch if boss giant facing left to set y vel and advance routine
    ldx ENEMY_CURRENT_SLOT       ; boss giant facing right, load spiked disk slot
    lda #$03                     ; a = #$03
    sta ENEMY_X_VELOCITY_FAST,x  ; set spiked disk x fast velocity going right
    lda #$00                     ; a = #$00
    sta ENEMY_X_VELOCITY_FRACT,x ; set spiked disk x fractional velocity

; y velocity for spiked disk
@set_y_vel_adv_routine:
    ldx ENEMY_CURRENT_SLOT       ; restore spiked disk enemy slot
    lda #$02                     ; a = #$02
    sta ENEMY_Y_VELOCITY_FAST,x  ; set spiked disk fast y velocity to #$02
    lda #$00                     ; a = #$00
    sta ENEMY_Y_VELOCITY_FRACT,x ; set spiked disk fractional y velocity to #$00

boss_giant_projectile_adv_routine:
    jmp advance_enemy_routine ; advance spiked disk to next routine, boss_giant_projectile_routine_01 or remove_enemy

; update position, if animation delay has elapsed, update sprite so the disk rotates
; remove enemy if off screen
boss_giant_projectile_routine_01:
    lda ENEMY_X_POS,x                     ; load enemy x position on screen
    cmp #$e0                              ; see if off screen to the right
    bcs boss_giant_projectile_adv_routine ; advance routine to remove_enemy
    dec ENEMY_ANIMATION_DELAY,x           ; decrement enemy animation frame delay counter
    beq @set_sprite_update_pos_exit       ; update sprite if animation delay has elapsed
    lda ENEMY_Y_POS,x                     ; animation delay hasn't elapse,d load enemy y position on screen
    cmp #$af                              ; ground limit for spiked disk
    bcs @stop_y_velocity                  ; branch if landed on ground to stop disk from falling down below ground
    bcc @update_pos_exit                  ; update pos and exit if not yet landed on ground

; stops y velocity, keeping x velocity
@stop_y_velocity:
    jsr set_enemy_y_velocity_to_0 ; set y velocity to zero

@update_pos_exit:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

@set_sprite_update_pos_exit:
    lda #$06                    ; a = #$06
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    inc ENEMY_VAR_1,x           ; increment sprite code control flag
    lda ENEMY_VAR_1,x           ; load sprite code control flag
    and #$01                    ; keep bit 0
    clc                         ; clear carry in preparation for addition
    adc #$bb                    ; add to #$bb to determine wither sprite_bb or sprite_bc will be drawn
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer
    jmp update_enemy_pos        ; apply velocities and scrolling adjust

; pointer table for mechanical claw (#$4 * #$2 = #$8 bytes)
claw_routine_ptr_tbl:
    .addr claw_routine_00 ; CPU address $aec3 - set ENEMY_FRAME to frame counter trigger, strip ENEMY_ATTRIBUTES to just claw length, set delay, advance routine
    .addr claw_routine_01 ; CPU address $aee5 - wait for descent, advance routine
    .addr claw_routine_02 ; CPU address $af30 - animate claw descent
    .addr claw_routine_03 ; CPU address $af4d - animate claw ascent

; set ENEMY_FRAME to frame counter trigger, strip ENEMY_ATTRIBUTES to just claw length, set delay, advance routine
claw_routine_00:
    jsr add_scroll_to_enemy_pos  ; add scrolling to enemy position
    lda ENEMY_ATTRIBUTES,x       ; load enemy attributes
    lsr
    lsr                          ; get rid of claw length
    and #$03                     ; keep bits 0 and 1 (descend delay)
    tay                          ; transfer to offset register
    lda claw_frame_trigger_tbl,y ; load frame counter number at which to trigger descent
    sta ENEMY_FRAME,x            ; store claw delay in ENEMY_FRAME
    lda ENEMY_ATTRIBUTES,x       ; reload enemy attributes
    and #$03                     ; keep bits 0 and 1 (claw length)
    sta ENEMY_ATTRIBUTES,x       ; update ENEMY_ATTRIBUTES to just store claw length
    lda #$20                     ; a = #$20 (initial delay before going descending)

claw_set_delay_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; table of frame counter triggers before going down (#$4 bytes)
; whenever (FRAME_COUNTER & #$7f) matches this value, the claw will descend
; used so that all claws of the same delay go down at the same time
; enemy attribute bits .... xx..
claw_frame_trigger_tbl:
    .byte $00,$20,$40,$60

; wait for descent, advance routine
claw_routine_01:
    jsr add_scroll_to_enemy_pos  ; add scrolling to enemy position
    lda ENEMY_ATTRIBUTES,x       ; load enemy attributes
    cmp #$03                     ; see if claw length 3 (seeking claw - only attack when player near)
    beq @check_delay_seek_player ; branch if seeking claw
    lda FRAME_COUNTER            ; not seeking claw, load frame counter to see if should descend
    and #$7f                     ; strip bit 7
    cmp ENEMY_FRAME,x            ; compare to enemy animation frame number (frame counter trigger point)
    bne claw_routine_01_exit     ; branch if frame counter doesn't match and claw shouldn't descend

@descend_claw:
    lda ENEMY_X_POS,x              ; load enemy x position on screen
    cmp #$2c                       ; compare to the left 17% of screen
    bcc claw_routine_01_exit       ; don't descend if exit if claw is far to the left
    lda ENEMY_ATTRIBUTES,x         ; load enemy attributes
    tay                            ; transfer maximum claw length to offset register
    asl                            ; double since each entry in claw_update_nametable_ptr_tbl is #$02 bytes
    sta ENEMY_VAR_4,x              ; set claw_update_nametable_ptr_tbl offset
    lda claw_length_tbl,y          ; load claw length
    sta ENEMY_VAR_2,x              ; set claw length
    lda #$00                       ; a = #$00
    sta ENEMY_VAR_3,x
    beq claw_set_delay_adv_routine ; always branch

; claw length 3 - seeking claw
@check_delay_seek_player:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    bne claw_dec_delay_exit     ; decrement delay and exit if timer hasn't elapsed
    lda FRAME_COUNTER           ; load frame counter
    cmp #$c0                    ; seeking claws don't attack 25% of the time, i.e. between #$c0 and #$ff inclusively
    bcs claw_routine_01_exit    ; exit if claw shouldn't attack due to timing
    jsr player_enemy_x_dist     ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    cmp #$10                    ; see if player within #$10 horizontal pixels of claw
    bcc @descend_claw           ; descend claw if closest player is < #$10 distance away
    rts                         ; exit if player too far from claw for it to attack

claw_dec_delay_exit:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    sec                         ; set carry flag (indicates claw wasn't animated)
    rts

; table for possible claw lengths (#$4 bytes)
; length code 3 makes the claw activate only when the player is near
claw_length_tbl:
    .byte $04,$03,$08,$03

; animate claw descent
claw_routine_02:
    jsr add_scroll_to_enemy_pos   ; add scrolling to enemy position
    jsr animate_claw              ; update the nametable tiles
    bcs claw_routine_01_exit      ; exit if unable to update the nametable tiles
    dec ENEMY_VAR_2,x             ; decrement remaining claw length for ascending
    beq claw_inc_tile_adv_routine ; advance routine if claw fully extended
    lda #$08                      ; a = #$08
    jsr add_a_to_enemy_y_pos      ; add #$08 to enemy y position on screen
    inc ENEMY_VAR_3,x             ; increment current length of the claw

claw_routine_01_exit:
    rts

claw_inc_tile_adv_routine:
    inc ENEMY_VAR_4,x              ; increment claw_update_nametable_ptr_tbl offset
    lda #$08                       ; a = #$08
    bne claw_set_delay_adv_routine ; advance to claw_routine_03

; animate claw ascent
claw_routine_03:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    jsr animate_claw            ; animate claw ascent
    bcs claw_routine_01_exit    ; exit if unable to update nametable tiles
    dec ENEMY_VAR_3,x           ; decrement current length of the claw
    bmi @wait_for_descent       ; go back to claw_routine_01 to wait for next descent if claw fully retracted
    lda #$f8                    ; a = #$f8 (-8)
    jmp add_a_to_enemy_y_pos    ; add a to enemy y position on screen

@wait_for_descent:
    lda ENEMY_FRAME,x           ; load enemy animation frame number
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to claw_routine_01 to wait for next descent

; updates nametable tiles to animate ascending and descending the claw
; output
;  * carry flag - clear when nametable updated, set when not
animate_claw:
    lda ENEMY_ANIMATION_DELAY,x            ; load enemy animation frame delay counter
    bne claw_dec_delay_exit                ; exit if animation delay hasn't elapsed
                                           ; with carry flag set indicating no update
    lda ENEMY_VAR_4,x                      ; load current offset into claw_update_nametable_ptr_tbl
    asl                                    ; double since each entry is #$02 bytes
    tay                                    ; transfer to offset register
    lda claw_update_nametable_ptr_tbl,y    ; load low byte of address
    sta $10                                ; store low byte of address in $10
    lda claw_update_nametable_ptr_tbl+1,y  ; load high byte of address
    sta $11                                ; store high byte of address in $11
    ldy ENEMY_VAR_3,x                      ; load current extension of the claw
    lda ($10),y                            ; load tile code to draw
    sta $10                                ; store tile code to draw for load_bank_3_update_nametable_tiles
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    ldy ENEMY_Y_POS,x                      ; enemy y position on screen
    jsr load_bank_3_update_nametable_tiles ; draw tile code $10 to nametable at (a, y)
    bcs @exit                              ; exit if unable to update nametable tiles
    ldx ENEMY_CURRENT_SLOT                 ; temporary storage for x register
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    cmp #$2c                               ; compare to the left 17% of screen
    lda #$00                               ; a = #$00 (no delay when claw wasn't updated)
    bcc @set_anim_delay_exit               ; if enemy is too far to the left, exit
    clc                                    ; clear carry to indicate success
    lda #$02                               ; a = #$02 (speed of claw)

@set_anim_delay_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

@exit:
    rts

; pointer table for claw super-tile animation indexes (8 * 2 = 10 bytes)
; see level_7_tile_animation
claw_update_nametable_ptr_tbl:
    .addr claw_tile_code_00 ; CPU address $afb2 - ascent
    .addr claw_tile_code_01 ; CPU address $afb6 - descent
    .addr claw_tile_code_00 ; CPU address $afb2 - ascent
    .addr claw_tile_code_01 ; CPU address $afb6 - descent
    .addr claw_tile_code_02 ; CPU address $afba - ascent
    .addr claw_tile_code_03 ; CPU address $afc2 - descent
    .addr claw_tile_code_00 ; CPU address $afb2 - ascent
    .addr claw_tile_code_01 ; CPU address $afb6 - descent

; tables for claw tile codes
; see level_7_tile_animation
; this table is different from Trax source
claw_tile_code_00:
    .byte $86,$86,$86,$86

claw_tile_code_01:
    .byte $80,$80,$82,$84

claw_tile_code_02:
    .byte $86,$86,$86,$86

; unused space
; same as claw_tile_code_00
claw_tile_code_unused_00:
    .byte $86,$86,$86,$86

claw_tile_code_03:
    .byte $80,$80,$80,$80

; unused space
; same as claw_tile_code_01
claw_tile_code_unused_01:
    .byte $80,$80,$82,$84

; pointer table for raising spiked wall (enemy type #$11) (#$6 * #$2 = #$c bytes)
rising_spiked_wall_routine_ptr_tbl:
    .addr rising_spiked_wall_routine_00 ; CPU address $afd6 - init variables
    .addr rising_spiked_wall_routine_01 ; CPU address $b00c - wait for player to get close, and advance routine
    .addr rising_spiked_wall_routine_02 ; CPU address $b025 - animate rising wall and configure collision box size
    .addr rising_spiked_wall_routine_03 ; CPU address $b200 - ensure scroll up to date
    .addr rising_spiked_wall_routine_04 ; CPU address $b087 - destroyed routine, set spiked_wall_destroyed_update_tbl offset, play sound
    .addr rising_spiked_wall_routine_05 ; CPU address $b09c - animate wall destruction by updating super-tiles

; init variables
rising_spiked_wall_routine_00:
    lda ENEMY_ATTRIBUTES,x                     ; load the rising spiked wall's attribute
    and #$0c                                   ; keep bits 2 and 3, for use in distance trigger
    lsr                                        ; only shift once since each entry is #$02 bytes
    tay                                        ; transfer offset to y
    lda rising_spike_wall_trigger_dist_tbl,y   ; load trigger distance
    sta ENEMY_VAR_3,x                          ; store trigger distance
    lda rising_spike_wall_trigger_dist_tbl+1,y ; load rising delay timer
    sta ENEMY_VAR_4,x                          ; set rising delay timer
    lda ENEMY_ATTRIBUTES,x                     ; load attributes again
    and #$03                                   ; keep bits 0 and 1
    tay                                        ; transfer index to y
    lda rising_spike_wall_delay_tbl,y          ; load ENEMY_ATTACK_DELAY
    sta ENEMY_ATTACK_DELAY,x                   ; store delay

; used for both rising spiked wall and spiked wall to set collision box index to 16
; this is to specify that the collision box grows upwards in heigh with a fixed width
spiked_wall_set_collision_box:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$c0                    ; a = #$c0
    sta ENEMY_ATTRIBUTES,x      ; set negative collision code f values
                                ; and use offset #$10 (16) into collision_code_f_adj_tbl (expand collision box upwards)

advance_spiked_wall_enemy_routine:
    jmp advance_enemy_routine

; table for distance of emergence and subsequent delays (#$c bytes)
rising_spike_wall_trigger_dist_tbl:
    .byte $30,$00 ; first wall (no delay)
    .byte $50,$0f ; distance and delay before second wall
    .byte $70,$1e ; distance and delay before third wall
    .byte $40,$00

; table for possible delays between emerging steps (#$4 bytes)
; determines emergence speed
rising_spike_wall_delay_tbl:
    .byte $0c,$08,$04,$02

; wait for player to get close, and advance routine
rising_spiked_wall_routine_01:
    jsr add_scroll_to_enemy_pos     ; add scrolling to enemy position
    jsr player_enemy_x_dist         ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    cmp ENEMY_VAR_3,x               ; compare the distance of the closest player to the trigger distance before the rising timer will start
    bcs rising_spiked_wall_exit     ; branch if closest player is farther than ENEMY_VAR_3,x
    jsr enable_enemy_collision      ; enable bullet-enemy collision and player-enemy collision checks
    lda #$06                        ; a = #$06
    sta ENEMY_VAR_2,x               ; set initial offset
    lda ENEMY_VAR_4,x               ; load the delay timer before the wall starts rising
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a and advance enemy routine

; animate rising wall
rising_spiked_wall_routine_02:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    lda ENEMY_ANIMATION_DELAY,x                ; load enemy animation frame delay counter
    bne dec_delay_enable_set_vel_exit          ; if the animation delay hasn't elapsed, decrement and exit
    lda ENEMY_VAR_2,x                          ; animation delay has elapsed, load rising_spiked_wall_data_tbl read offset
    asl
    adc ENEMY_VAR_2,x                          ; multiply by 3
    tay                                        ; transfer to offset register
    lda rising_spiked_wall_data_tbl+1,y        ; load nametable super-tile update index
    sta $10                                    ; set nametable super-tile update index
    lda rising_spiked_wall_data_tbl+2,y        ; load collision box placeholder replacement amount (see collision_code_f_adj_tbl)
    sta ENEMY_VAR_1,x                          ; store collision box placeholder replacement amount (see collision_code_f_adj_tbl)
                                               ; since bit 6 of ENEMY_ATTRIBUTES is set, the final value is actually (-1 * ENEMY_VAR_1,x) + #$08
                                               ; this value (or its negation) are used to replace placeholder values in collision_code_f_adj_tbl
                                               ; to support a dynamic collision box size that can grow upwards with a fixed width
    lda rising_spiked_wall_data_tbl,y          ; load y position offset
    adc ENEMY_Y_POS,x                          ; add to enemy y position on screen
    tay                                        ; transfer result to offset register for load_bank_3_update_nametable_supertile
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    sbc #$0d                                   ; subtract 13 from x position
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    bcs rising_spiked_wall_exit                ; exit if unable to draw the rising wall
    ldx ENEMY_CURRENT_SLOT                     ; restore x to rising wall enemy slot index
    lda ENEMY_VAR_2,x                          ; load rising_spiked_wall_data_tbl read offset
    cmp #$04                                   ; compare to the last #$04 super-tiles to draw
    bcs @continue                              ; branch if drawing the first #$03 super-tiles
    lda #$00                                   ; x <= 3, left side of super-tile bg collision (#$00 = empty collision codes)
    ldy #$0f                                   ; right side of super-tile bg collision (#$0f = solid collision codes)
    jsr set_supertile_bg_collisions            ; update bg collision codes for a single super-tile at PPU address $12 (low) $13 (high)

@continue:
    lda ENEMY_ATTACK_DELAY,x              ; load animation delay
    sta ENEMY_ANIMATION_DELAY,x           ; set enemy animation frame delay counter
    dec ENEMY_VAR_2,x                     ; move to next rising_spiked_wall_data_tbl read offset
    bpl rising_spiked_wall_exit           ; exit if still more super-tiles to draw
    bmi advance_spiked_wall_enemy_routine ; finished animation, move to rising_spiked_wall_routine_03

dec_delay_enable_set_vel_exit:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter

rising_spiked_wall_exit:
    rts

; tile codes for raising spiked wall (#$15 bytes)
; byte 0 - enemy y position offset
; byte 1 - super-tile code (see level_7_nametable_update_supertile_data)
; byte 2 - collision box initial configuration (see collision_code_f_base_tbl)
rising_spiked_wall_data_tbl:
    .byte $c0,$91,$d0 ; #$11 - rising wall (frame 5) (four rows of spikes visible) (collision box heigh = #$38)
    .byte $d0,$91,$e0 ; #$11 - rising wall (frame 5) (four rows of spikes visible) (collision box heigh = #$20)
    .byte $e0,$90,$f0 ; #$10 - rising wall (frame 4) (three rows of spikes visible) (collision box heigh = #$18)
    .byte $e0,$8f,$f8 ; #$0f - rising wall (frame 3) (two rows of spikes visible) (collision box heigh = #$10)
    .byte $f0,$8e,$00 ; #$0e - rising wall (frame 2) (first row of spikes visible) (collision box heigh = #$08)
    .byte $f0,$8d,$09 ; #$0d - rising wall (frame 1) (slightly out of ground) (collision box heigh = #$ff)
    .byte $f0,$8c,$09 ; #$0c - rising wall (frame 0) (barely out of ground) (collision box heigh = #$ff)

; destroyed routine, set spiked_wall_destroyed_update_tbl offset, play sound
rising_spiked_wall_routine_04:
    lda #$00                    ; a = #$00
    sta ENEMY_VAR_4,x           ; set spiked_wall_destroyed_update_tbl offset to #$00
    lda #$03                    ; a = #$03
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

; spiked wall destroyed routine - play sound advance routine
spiked_wall_routine_02:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$24                    ; a = #$24 (sound_24)
    jsr play_sound              ; play explosion sound
    jmp advance_enemy_routine   ; advance to next routine

; animate wall destruction by updating super-tiles
rising_spiked_wall_routine_05:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    lda ENEMY_VAR_4,x                          ; load spiked_wall_destroyed_update_tbl read offset
    asl
    adc ENEMY_VAR_4,x                          ; multiple by 3
    tay                                        ; transfer to offset register
    lda spiked_wall_destroyed_update_tbl+1,y   ; load super-tile nametable update index (see level_7_nametable_update_supertile_data)
    sta $10                                    ; store in $10 for load_bank_3_update_nametable_supertile call
    lda spiked_wall_destroyed_update_tbl,y     ; load relative y position
    adc ENEMY_Y_POS,x                          ; add to enemy y position on screen
    sty $f0                                    ; store read offset in $f0
    tay                                        ; transfer result y position to y
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    sbc #$0d                                   ; subtract #$0d from x position
    bcc remove_spiked_wall                     ; if underflow, remove spiked wall (far left of screen)
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    bcs rising_spiked_wall_exit                ; exit if unable to draw destroyed spiked wall super-tile
    ldx ENEMY_CURRENT_SLOT                     ; updated super-tile in graphics buffer
                                               ; restore rising spiked wall enemy slot index
    lda ENEMY_VAR_4,x                          ; load the current entry in spiked_wall_destroyed_update_tbl
    and #$03                                   ; keep bits .... ..xx
    beq @continue                              ; branch if currently drawing first super-tile
    jsr clear_supertile_bg_collision           ; set background collision code to #$00 (empty) for a single super-tile at PPU address $12 (low) $13 (high)

@continue:
    ldy $f0                                  ; restore spiked_wall_destroyed_update_tbl read offset
    lda spiked_wall_destroyed_update_tbl+2,y ; load relative x position
    tay                                      ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda #$fc                                 ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos                   ; stores absolute screen x position in $09, and y position in $08
    jsr create_two_explosion_89              ; create explosion
    inc ENEMY_VAR_4,x                        ; move to next super-tile to draw (higher up on wall)
    dec ENEMY_ANIMATION_DELAY,x              ; decrement enemy animation frame delay counter
    bne rising_spiked_wall_exit              ; exit if animation delay hasn't elapsed

remove_spiked_wall:
    jmp remove_enemy ; remove enemy

; spiked walls block indexes after destruction and
; fixed walls of 3 tiles high (#$15 bytes)
; byte 0 - relative y position
; byte 1 - super-tile nametable update index (see level_7_nametable_update_supertile_data)
; byte 2 - relative x position (+#$0d)
spiked_wall_destroyed_update_tbl:
    .byte $00,$84,$08 ; #$04 - spiked wall super-tile destroyed floor
    .byte $e0,$8b,$f0 ; #$0b - fence
    .byte $c0,$8a,$d0 ; #$0a - blank super-tile
    .byte $a0,$86,$b0 ; #$06 - tall spiked wall destroyed top (parting hanging from ceiling)
    .byte $00,$84,$08 ; #$04 - spiked wall super-tile destroyed floor
    .byte $e0,$8b,$f0 ; #$0b - fence
    .byte $c0,$86,$d0 ; #$06 - tall spiked wall destroyed top (parting hanging from ceiling)

; pointer table for spiked wall (12) (#$4 * #$2 = #$8 bytes)
spiked_wall_routine_ptr_tbl:
    .addr spiked_wall_routine_00        ; CPU address $b103 - initialize collision box and wall destroyed variables
    .addr rising_spiked_wall_routine_03 ; CPU address $b200 - ensure scroll up to date
    .addr spiked_wall_routine_02        ; CPU address $b091 - spiked wall destroyed routine - play sound advance routine
    .addr rising_spiked_wall_routine_05 ; CPU address $b09c - animate wall destruction by updating super-tiles

; initialize collision box and wall destroyed variables, advance routine
spiked_wall_routine_00:
    lda #$b8                               ; a = #$b8
    sta ENEMY_VAR_1,x                      ; dynamic collision box height = #$50 ((-1 * #$b8) + #$08))
    ldy ENEMY_ATTRIBUTES,x                 ; load enemy attributes
    lda spiked_wall_destroyed_data_tbl,y   ; load spiked_wall_destroyed_update_tbl offset
    sta ENEMY_VAR_4,x                      ; set spiked_wall_destroyed_update_tbl offset
    lda spiked_wall_destroyed_data_tbl+1,y ; load wall-destroyed enemy animation delay timer
    sta ENEMY_ANIMATION_DELAY,x            ; set wall-destroyed enemy animation delay timer
    jmp spiked_wall_set_collision_box      ; set collision code f dynamic mode to #$10 (grow upwards)
                                           ; and advance routine

; table for spiked wall routine (#$4 bytes)
; byte 0 - initial spiked_wall_destroyed_update_tbl offset
; byte 1 - wall destroyed enemy animation delay timer (timer before wall is removed after explosion)
spiked_wall_destroyed_data_tbl:
    .byte $04,$03 ; half-screen wall on top half of screen
    .byte $00,$04 ; full screen wall

; pointer table for cart generator (13) (#$2 * #$2 = #$4 bytes)
mine_cart_generator_routine_ptr_tbl:
    .addr mine_cart_generator_routine_00 ; CPU address $b122
    .addr mine_cart_generator_routine_01 ; CPU address $b12c

mine_cart_generator_routine_00:
    lda #$80                        ; a = #$80
    sta ENEMY_FRAME,x               ; set generated cart slot number to signify no cart generated
    lda #$01                        ; a = #$01
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

mine_cart_generator_routine_01:
    jsr add_scroll_to_enemy_pos      ; add scrolling to enemy position
    lda ENEMY_FRAME,x                ; load generated cart's slot number, #$80 means no cart generated
    bpl @check_generated_cart_status ; if generated cart exists, see how it is doing. did it get destroyed yet
    dec ENEMY_ANIMATION_DELAY,x      ; no cart generated, decrement enemy animation frame delay counter
    bne cart_routine_exit            ; exit if delay timer hasn't elapsed
    inc ENEMY_ANIMATION_DELAY,x      ; enemy animation frame delay counter
    jsr find_next_enemy_slot         ; find next available enemy slot, put result in x register
    bne @exit                        ; exit when no enemy slot available
    lda #$14                         ; a = #$14 (14 = moving cart)
    sta ENEMY_TYPE,x                 ; set current enemy type to moving cart
    jsr initialize_enemy             ; generate enemy
    lda #$f8                         ; a = #$f8
    sta ENEMY_X_POS,x                ; set enemy x position on screen to #$f8
    lda #$ff                         ; a = #$ff
    sta ENEMY_X_VELOCITY_FAST,x      ; set to move 1 unit left every frame
    lda #$02                         ; a = #$02
    sta ENEMY_VAR_4,x                ; set cart direction to left
    lda #$80                         ; a = #$80
    sta ENEMY_ATTRIBUTES,x           ; specify the cart should blow up upon collision with background
    jsr init_cart_vel_and_y_pos      ; set cart initial velocity and y position
    txa
    ldx ENEMY_CURRENT_SLOT
    sta ENEMY_FRAME,x                ; set enemy animation frame number

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; see status of generated cart, if no longer active, set to generate new cart after delay
@check_generated_cart_status:
    ldy ENEMY_FRAME,x           ; load generated cart's slot number
    lda ENEMY_ROUTINE,y         ; load current routine index for generated mining cart
    bne cart_routine_exit       ; generated cart has not been destroyed, exit
    lda #$80                    ; generated cart has been destroyed, start logic to generate a new cart
    sta ENEMY_FRAME,x           ; set generated cart slot number to signify no cart generated
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

cart_routine_exit:
    rts

; pointer table for moving cart (14) (#$6 * #$2 = #$c bytes)
moving_cart_routine_ptr_tbl:
    .addr moving_cart_routine_00       ; CPU address $b186
    .addr moving_cart_routine_00       ; CPU address $b186
    .addr moving_cart_routine_00       ; CPU address $b186
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

moving_cart_routine_00:
    lda FRAME_COUNTER                         ; load frame counter
    lsr
    lsr
    and #$01                                  ; every 8 frames alternate sprite code to show wheel moving animation
    clc                                       ; clear carry in preparation for addition
    adc #$2a                                  ; either sprite code #$2a or #$2b depending if big 2 of FRAME_COUNTER is 1 or not
    sta ENEMY_SPRITES,x                       ; save mine cart sprite to enemy sprite buffer
    jsr update_enemy_pos                      ; apply velocities and scrolling adjust
    ldy ENEMY_VAR_4,x                         ; cart direction (0 = right, 2 = left)
    lda ENEMY_X_POS,x                         ; load enemy x position on screen
    clc                                       ; clear carry in preparation for addition
    adc cart_collision_config_tbl+1,y         ; load x offset for bg collision check depending on cart direction
    sta $00                                   ; store in variable used in get_cart_bg_collision as x position
    lda #$00                                  ; a = #$00
    adc cart_collision_config_tbl,y           ; add XOR value used in bg collision depending on cart direction
                                              ; note carry can be set from previous addition
    sta $10                                   ; XOR for use in bg collision
    lda $00                                   ; sprite x position
    ldy ENEMY_Y_POS,x                         ; enemy y position on screen
    jsr get_cart_bg_collision                 ; get enemy background collision
    bne cart_bg_collision                     ; branch if cart has collided with anything (floor (#$01), water (#$02), or a solid object (#$80))
    lda #$00                                  ; a = #$00
    ldy #$09                                  ; y = #$09
    jsr add_a_y_to_enemy_pos_get_bg_collision ; add a (#$00) to X position and y (#$09) to Y position; get bg collision code
    bne cart_routine_exit                     ; exit if no collision
    lda #$20                                  ; a = #$20 (gravity for cart)
    jmp add_a_to_enemy_y_fract_vel            ; add a to enemy y fractional velocity

; cart has collided with something, reverse direction
cart_bg_collision:
    lda ENEMY_ATTRIBUTES,x        ; generated moving carts explode on impact, but immobile carts will reverse direction
    bmi set_cart_explosion        ; whether or not the cart should turn around or explode upon collision
    lda ENEMY_VAR_4,x             ; load cart direction variable
    eor #$02                      ; swap cart direction by flipping bit 1 (0 = right, 2 = left)
    sta ENEMY_VAR_4,x             ; set new cart direction
    jmp reverse_enemy_x_direction ; reverse x direction

; move to enemy_routine_init_explosion routine
set_cart_explosion:
    lda #$04                   ; a = #$04
    jmp set_enemy_routine_to_a ; set enemy routine index to a

; byte 0 is the XOR value used to help level_screen_mem_offset_tbl_01 lookup ($10)
; byte 1 is the X offset from cart X position for use in collision detection
cart_collision_config_tbl:
    .byte $00,$0f
    .byte $ff,$f1

; pointer table for immobile cart (15), can start rolling when player lands on it (#$6 * #$2 = #$c bytes)
immobile_cart_generator_routine_ptr_tbl:
    .addr immobile_cart_generator_routine_00 ; CPU address $b1e5
    .addr immobile_cart_generator_routine_01 ; CPU address $b1fb
    .addr moving_cart_routine_00             ; CPU address $b186
    .addr enemy_routine_init_explosion       ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion            ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy         ; CPU address $e806 from bank 7

; initialize x velocity, sprite, and y pos on screen
immobile_cart_generator_routine_00:
    lda #$c0                    ; a = #$c0
    jsr init_cart_vel_and_y_pos ; set x velocity of cart when stepped on to #$c0

cart_advance_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

init_cart_vel_and_y_pos:
    sta ENEMY_X_VELOCITY_FRACT,x ; set x fractional velocity to a
    lda #$2a                     ; a = #$2a (mining cart sprite code)
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
    lda #$c8                     ; a = #$c8
    sta ENEMY_Y_POS,x            ; enemy y position on screen
    rts

immobile_cart_generator_routine_01:
    lda ENEMY_FRAME,x              ; load enemy animation frame number (set to #01 when @land_on_enemy executes)
    bne cart_advance_enemy_routine ; player has landed on cart, start moving cart (moving_cart_routine_00)

; ensure scroll up to date
rising_spiked_wall_routine_03:
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position

; pointer table for jungle armored door (level 7) (16) (#$7 * #$2 = #$e bytes)
boss_door_routine_ptr_tbl:
    .addr boss_door_routine_00    ; CPU address $b211
    .addr boss_door_routine_01    ; CPU address $b219
    .addr boss_door_routine_02    ; CPU address $b228
    .addr boss_defeated_routine   ; CPU address $e740 from bank 7
    .addr enemy_routine_explosion ; CPU address $e7b0 from bank 7
    .addr boss_door_routine_05    ; CPU address $b240 - set tile sprite code to #$00, advance routine, add #$20 to y position
    .addr boss_door_routine_06    ; CPU address $b248

; armored door - pointer 0
boss_door_routine_00:
    lda #$1b                  ; a = #$1b (sound_1b)
    jsr play_sound            ; play level 1 jungle boss siren sound
    jmp advance_enemy_routine ; advance to next routine

; armored door - pointer 1
boss_door_routine_01:
    jsr add_scroll_to_enemy_pos       ; add scrolling to enemy position
    lda ENEMY_HP,x                    ; load enemy hp
    cmp #$05                          ; stop spawning enemies when hp < 5
    bcs @exit
    lda #$02                          ; a = #$02
    sta BOSS_SCREEN_ENEMIES_DESTROYED ; set number of mortar launchers to be destroyed before soldiers stop being generated

@exit:
    rts

; armored door - pointer 2
boss_door_routine_02:
    lda ENEMY_VAR_1,x
    bne @continue
    lda #$08                 ; a = #$08
    jsr add_a_to_enemy_x_pos ; add #$08 to enemy x position on screen
    inc ENEMY_VAR_1,x

@continue:
    lda #$05                        ; a = #$05
    jsr draw_enemy_supertile_a      ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcc boss_door_adv_enemy_routine

boss_door_exit:
    rts

boss_door_adv_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; set tile sprite code to #$00, advance routine, add #$20 to y position
boss_door_routine_05:
    jsr shared_enemy_routine_clear_sprite ; set tile sprite code to #$00 and advance routine

boss_door_add_20_to_y_pos:
    lda #$20                 ; a = #$20
    jmp add_a_to_enemy_y_pos ; add a to enemy y position on screen

boss_door_routine_06:
    ldy ENEMY_VAR_2,x
    lda boss_door_update_supertile_tbl,y ; load super tile to draw (offset into  level_xx_nametable_update_supertile_data)
    jsr draw_enemy_supertile_a           ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs boss_door_exit
    lda #$05                             ; left side of super-tile bg collision (#$05 = ground collision codes)
    ldy #$05                             ; right side of super-tile bg collision (#$05 = ground collision codes)
    jsr set_supertile_bg_collisions      ; update bg collision codes for a single super-tile at PPU address $12 (low) $13 (high)
    jsr set_08_09_to_enemy_pos           ; set $08 and $09 to enemy x's X and Y position
    jsr create_two_explosion_89          ; create explosion #$89 at location ($09, $08)
    jsr boss_door_add_20_to_y_pos
    inc ENEMY_VAR_2,x
    lda ENEMY_VAR_2,x
    cmp #$02
    bcc boss_door_exit
    lda #$80                             ; a = #$80 (delay before auto-move)
    jmp set_delay_remove_enemy

; super-tile codes for destroyed door (#$2 bytes)
boss_door_update_supertile_tbl:
    .byte $08,$04

; pointer table for hangar boss mortar launcher (17) (#$8 * #$2 = #$10 bytes)
boss_mortar_routine_ptr_tbl:
    .addr boss_mortar_routine_00       ; CPU address $b284 - offset y position, set default aim direction, set initial delay, advance routine
    .addr boss_mortar_routine_01       ; CPU address $b29a - wait for auto scroll, wait for animation delay, update nametable tiles, set delay, increment frame, advance routine if firing
    .addr boss_mortar_routine_02       ; CPU address $b2c3 - fire once animation delay has elapsed
    .addr boss_mortar_routine_03       ; CPU address $b2ef - animate closing of mortar launcher, set routine to boss_mortar_routine_01
    .addr boss_mortar_routine_04       ; CPU address $b30f - draw destroyed nametable tiles, advance routine
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; offset y position, set default aim direction, set initial delay, advance routine
boss_mortar_routine_00:
    lda #$04                   ; a = #$04 to offset y position a little bit
    jsr add_a_to_enemy_y_pos   ; add #$04 to enemy y position on screen
    lda #$04                   ; a = #$04
    sta ENEMY_VAR_1,x          ; default mortar shot direction (see mortar_shot_velocity_tbl)
    lda ENEMY_ATTRIBUTES,x     ; load enemy attributes
    lsr                        ; shift initial attack delay flag to carry
    lda #$60                   ; a = #$60 (initial delay)
    bcc @set_delay_adv_routine ; continue with #$60 delay if ENEMY_ATTRIBUTES bit 0 is 0
    lda #$10                   ; ENEMY_ATTRIBUTES bit 0 is 1, use #$10 delay

@set_delay_adv_routine:
    bne mortar_set_delay_adv_routine

; wait for auto scroll, wait for animation delay, update nametable tiles, set delay, increment frame, advance routine if firing
boss_mortar_routine_01:
    jsr add_scroll_to_enemy_pos   ; add scrolling to enemy position
    lda BOSS_AUTO_SCROLL_COMPLETE ; see if boss reveal auto-scroll has completed
    beq @exit                     ; exit if boss auto scroll hasn't completed
    dec ENEMY_ANIMATION_DELAY,x   ; decrement enemy animation frame delay counter
    bne @exit                     ; exit if animation delay hasn't elapsed
    jsr boss_mortar_update_tiles  ; update nametable tiles based on enemy frame
    bcs @exit                     ; exit if unable to update the nametable tiles
    lda ENEMY_FRAME,x             ; load enemy animation frame number
    cmp #$02                      ; see if completed opening animation and should fire
    bcs @enable_adv_routine       ; if completed opening, branch to enable collision detection and advance to boss_mortar_routine_02
    inc ENEMY_FRAME,x             ; increment enemy animation frame number

@exit:
    rts

; enable collision detection and advance to boss_mortar_routine_02
@enable_adv_routine:
    jsr enable_enemy_collision ; enable bullet-enemy collision and player-enemy collision checks
    lda #$10                   ; a = #$10 (delay between opening and attack)
    sta ENEMY_ATTACK_DELAY,x   ; set delay between attacks
    lda #$60                   ; a = #$60 (total delay for open state)

mortar_set_delay_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a; advance enemy routine

; fire mortar after delay, advance routine when animation delay elapsed
boss_mortar_routine_02:
    jsr add_scroll_to_enemy_pos        ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x        ; open launcher timer
    beq @disable_collision_adv_routine ; if timer elapsed, disable collision and go to boss_mortar_routine_03 to begin closing
    dec ENEMY_ATTACK_DELAY,x           ; animation delay hasn't elapsed, decrement delay between attacks
    bne @exit                          ; exit if attack delay hasn't elapsed
    lda #$0b                           ; a = #$0b (0b = mortar shot)
    jsr generate_enemy_a               ; generate #$0b enemy (mortar shot)
    bne @exit                          ; exit if unable to generate mortar shot
    lda ENEMY_VAR_1,x                  ; load launcher's current aim direction [#$01-#$04]
    sta ENEMY_VAR_1,y                  ; set mortar shot initial velocities index (aim direction)
    dec ENEMY_VAR_1,x                  ; decrement launcher's current aim direction
    bne @exit                          ; exit if still a valid velocity index (aim dir)
    lda #$04                           ; wrapped around, reset aim direction to #$04
    sta ENEMY_VAR_1,x                  ; set next firing round's aim direction

@exit:
    rts

@disable_collision_adv_routine:
    jsr disable_enemy_collision      ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$01                         ; a = #$01
    bne mortar_set_delay_adv_routine ; set delay and set routine to boss_mortar_routine_02

; animate closing of mortar launcher, set routine to boss_mortar_routine_01
boss_mortar_routine_03:
    jsr add_scroll_to_enemy_pos    ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x    ; decrement enemy animation frame delay counter
    bne mortar_exit                ; exit if animation delay hasn't elapsed
    jsr boss_mortar_update_tiles   ; update mortar nametable tiles based on ENEMY_FRAME
    bcs mortar_exit                ; exit if unable to update the nametable tiles
    lda ENEMY_FRAME,x              ; load enemy animation frame number
    beq boss_mortar_set_routine_01 ; set #$a0 delay and set enemy routine to boss_mortar_routine_01
    dec ENEMY_FRAME,x              ; decrement enemy animation frame number

mortar_exit:
    rts

boss_mortar_set_routine_01:
    lda #$a0                    ; a = #$a0 (delay between mortar shots)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to boss_mortar_routine_01

; draw destroyed nametable tiles, advance routine
boss_mortar_routine_04:
    lda #$03                          ; a = #$03 (8b mortar launcher - destroyed)
    jsr boss_mortar_update_tiles_a    ; set nametable tiles to show a destroyed mortar launcher
    bcs mortar_exit                   ; exit if unable to update the nametable tiles
    inc BOSS_SCREEN_ENEMIES_DESTROYED ; increment number of destroyed mortar launchers
                                      ; once both are destroyed soldiers stop being generated
    jmp advance_enemy_routine         ; advance to enemy_routine_init_explosion

; update nametable tiles based on ENEMY_FRAME
boss_mortar_update_tiles:
    lda ENEMY_FRAME,x ; load enemy animation frame number

; update nametable tiles based on a register
boss_mortar_update_tiles_a:
    clc                                         ; clear carry in preparation for addition
    adc #$08                                    ; convert to real offset into level_7_tile_animation
    jsr update_enemy_nametable_tiles_no_palette ; draw the nametable tiles from level_7_tile_animation (a) at the enemy position
    lda #$01                                    ; a = #$01
    bcs @set_delay_exit                         ; exit if unable to update nametable tiles
    lda #$08                                    ; a = #$08 (delay between door opening frames)

@set_delay_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    rts

; pointer table for hangar boss screen enemy generator door (enemy type = #$18) (#$5 * #$2 = #$a bytes)
boss_soldier_generator_routine_ptr_tbl:
    .addr boss_soldier_generator_routine_00 ; CPU address $b338 - set delay to #$a0, advance routine
    .addr boss_soldier_generator_routine_01 ; CPU address $b33c - animate door and, if appropriate, prep to generate soldiers before advancing the routine
    .addr boss_soldier_generator_routine_02 ; CPU address $b38f - generate soldiers
    .addr boss_soldier_generator_routine_03 ; CPU address $b3d0 - close door, set delay for next time to open, set routine to boss_soldier_generator_routine_01
    .addr boss_soldier_generator_routine_04 ; CPU address $b3f5 - enemy destroyed routine, remove enemy

; set delay to #$a0, advance routine
boss_soldier_generator_routine_00:
    lda #$a0                               ; a = #$a0
    bne boss_soldier_generator_adv_routine ; initial delay before first attack

; animate door and, if appropriate, prep to generate soldiers before advancing the routine
boss_soldier_generator_routine_01:
    lda ENEMY_VAR_3,x                    ; load number of waves of soldiers generated
    cmp #$1e                             ; see if 30 waves of soldiers have been generated
    bcs @stop_soldier_gen                ; branch to stop generating soldiers if 30 waves have occurred
    lda BOSS_SCREEN_ENEMIES_DESTROYED    ; load how many mortar launchers have been destroyed
    cmp #$02                             ; see if both mortar launchers have been destroyed
    bcc @draw_door_check_if_gen_soldiers ; branch if at least one mortar launcher not destroyed
                                         ; updates door tiles, and see if should generate soldiers

; sets an animation delay so that boss_soldier_draw_door exits early and no soldier is generated
; soldiers aren't generated when there have been #$1e waves, or both mortar launchers have been destroyed
@stop_soldier_gen:
    lda #$f0                    ; a = #$f0
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

@draw_door_check_if_gen_soldiers:
    jsr boss_soldier_draw_door ; draw the appropriate super-tiles for the armored door based on ENEMY_FRAME
    bcs @exit                  ; branch if unable update the super-tiles
    lda ENEMY_FRAME,x          ; load enemy animation frame number
    cmp #$02                   ; see if last frame of animation, i.e. the door is open
    bcs @init_gen_soldiers     ; if open, determine from which side and how many soldiers to generate, advance routine
    inc ENEMY_FRAME,x          ; still opening door, increment enemy animation frame number

@exit:
    rts

@init_gen_soldiers:
    inc ENEMY_VAR_3,x                     ; increment number of waves of soldiers generated
    ldy #$00                              ; y = #$00
    lda SPRITE_X_POS                      ; load player 1 x position
    cmp #$a0                              ; see if close to the door on the right
    bcs @gen_from_left                    ; branch if close to the door on the right
    lda SPRITE_X_POS+1                    ; load if player 2 x position
    cmp #$a0                              ; see if close to the door on the right
    bcc @prep_soldiers_to_gen_adv_routine ; branch if player 2 is not close to the door on the right

@gen_from_left:
    iny ; increment facing direction so it's 1 (face right, attack from left)

@prep_soldiers_to_gen_adv_routine:
    tya                                 ; transfer soldier attack direction (0 = left, 1 = right) to a
    sta ENEMY_VAR_2,x                   ; set soldier facing direction (0 = left, 1 = right)
    lda RANDOM_NUM                      ; load random number
    and #$03                            ; keep bits 0 and 1
    tay                                 ; transfer to offset register
    lda boss_soldier_num_soldiers_tbl,y ; load random number of soldiers to generate
    sta ENEMY_VAR_1,x                   ; set the number of soldiers to generate
    lda #$10                            ; a = #$10 (delay between door open and attack)
    sta ENEMY_ATTACK_DELAY,x            ; set delay between attacks
    lda #$80                            ; a = #$80 (delay for door staying open)

boss_soldier_generator_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a and set routine to boss_soldier_generator_routine_02

; table for number of enemies generated (#$4 bytes)
boss_soldier_num_soldiers_tbl:
    .byte $03,$04,$02,$04

; generate soldiers
boss_soldier_generator_routine_02:
    jsr add_scroll_to_enemy_pos       ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x       ; decrement enemy animation frame delay counter
    beq @set_delay_adv_routine        ; if door open timer has elapsed, advance routine
    dec ENEMY_ATTACK_DELAY,x          ; decrement delay between attacks
    bne @exit
    lda #$05                          ; a = #$05 (05 = running man)
    sta $0a                           ; set type of generated enemy
    ldy #$00                          ; y = #$00
    lda #$f8                          ; a = #$f8
    jsr generate_enemy_at_pos         ; generate enemy type $0a at relative position a,y
    lda ENEMY_VAR_2,x                 ; load soldier facing direction
    bne @set_soldier_attr_delay_exit  ; exit if soldiers will spawn from the left (facing right)
    lda ENEMY_VAR_3,x                 ; soldiers to come from right, load the number of waves of attack
    cmp #$14                          ; see if there have been 20 waves of attack
    bcs @init_random_soldier_exit     ; branch if there have been 20 rounds of attacks to randomize soldier spawn direction
    lda BOSS_SCREEN_ENEMIES_DESTROYED ; load how many mortar launchers have been destroyed
    beq @set_soldier_attr_delay_exit  ; branch if no mortar launchers have been destroyed

; soldiers will be generated from a random direction if
; there have been #$14 (20) waves of attack or if one of the two mortar launchers have been destroyed
@init_random_soldier_exit:
    lda RANDOM_NUM ; load random number
    lsr            ; shift bit 0 to carry (!(WHY?) not sure why needed, still 50% odds)
    and #$01       ; randomly decide the soldier's running direction

@set_soldier_attr_delay_exit:
    sta ENEMY_ATTRIBUTES,y     ; set soldier enemy attributes (facing direction)
                               ; specifies which side of the screen the soldier spawns from
    lda #$10                   ; a = #$10 (delay between generated enemies)
    dec ENEMY_VAR_1,x          ; decrement number of soldiers to generate
    bne @set_attack_delay_exit ; exit with #$10 attack delay if more soldiers to generate
    lda #$ff                   ; no more soldiers to generate, exit with #$ff attack delay

@set_attack_delay_exit:
    sta ENEMY_ATTACK_DELAY,x ; set delay between attacks

@exit:
    rts

@set_delay_adv_routine:
    lda #$01                               ; a = #$01
    bne boss_soldier_generator_adv_routine ; set routine to boss_soldier_generator_routine_03

; close door, set delay for next time to open, set routine to boss_soldier_generator_routine_01
boss_soldier_generator_routine_03:
    jsr boss_soldier_draw_door ; draw the appropriate super-tiles for the armored door based on ENEMY_FRAME
    bcs @exit                  ; exit if unable to update the door tiles
    lda ENEMY_FRAME,x          ; load enemy animation frame number
    beq @door_closed           ; branch if door fully closed
    dec ENEMY_FRAME,x          ; decrement enemy animation frame number to continue closing door

@exit:
    rts

@door_closed:
    lda RANDOM_NUM                         ; load random number
    lsr
    lsr
    lsr                                    ; !(WHY?) not sure why needed if number is random
    and #$03                               ; keep bits .... ..xx
    tay                                    ; transfer random number to offset register
    lda boos_soldier_door_open_delay_tbl,y ; load delay for opening door back up
    sta ENEMY_ANIMATION_DELAY,x            ; set enemy animation frame delay counter
    lda #$02                               ; a = #$02
    jmp set_enemy_routine_to_a             ; set enemy routine index to boss_soldier_generator_routine_01

; possible delays between door openings (#$4 bytes)
boos_soldier_door_open_delay_tbl:
    .byte $f0,$80,$a0,$c0

; enemy destroyed routine, remove enemy
boss_soldier_generator_routine_04:
    jmp remove_enemy ; remove enemy

; draw the appropriate super-tiles for the armored door based on ENEMY_FRAME
; output
;  * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
boss_soldier_draw_door:
    jsr add_scroll_to_enemy_pos               ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x               ; decrement enemy animation frame delay counter
    bne @set_carry_exit                       ; exit if the animation delay hasn't elapsed
    lda ENEMY_FRAME,x                         ; load enemy animation frame number
    asl                                       ; double since each entry is #$02 bytes
    tay                                       ; transfer to offset register
    lda boss_soldier_nametable_update_tbl,y   ; load first nametable update super-tile index
    sta $10                                   ; store in $10 for update_2_enemy_supertiles
    lda boss_soldier_nametable_update_tbl+1,y ; load second nametable update super-tile index
    ldy #$00                                  ; y = #$00
    jsr update_2_enemy_supertiles             ; draw nametable update super-tile $10, then a at enemy position
    lda #$08                                  ; a = #$08
    bcc @set_delay_exit
    lda #$01                                  ; a = #$01

@set_delay_exit:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    rts

@set_carry_exit:
    sec ; set carry flag
    rts

; table for door nametable update super-tile index (#$6 bytes)
; index into level_7_nametable_update_supertile_data
boss_soldier_nametable_update_tbl:
    .byte $03,$12 ; closed armored door
    .byte $13,$14 ; partially open armored door
    .byte $07,$15 ; opened armored door

; pointer table for alien guardian (#$d * #$2 = #$1a bytes)
alien_guardian_routine_ptr_tbl:
    .addr alien_guardian_routine_00 ; CPU address $b44b - set enemy variables for super-tiles, hp and delays, advance routine
    .addr alien_guardian_routine_01 ; CPU address $b47c - repeatedly open and close mouth
    .addr alien_guardian_routine_02 ; CPU address $b545 - generates alien fetuses (enemy type #$11)
    .addr alien_guardian_routine_03 ; CPU address $b69b - play alien guardian destroyed sound, create initial explosion
    .addr alien_guardian_routine_04 ; CPU address $b6b2 - create series of explosions, each with a #$05 frame delay before next explosion
    .addr alien_guardian_routine_05 ; CPU address $b572 - blank super-tiles for lower jaw
    .addr alien_guardian_routine_06 ; CPU address $b5d8 - blank top jaw first call, second call will blank body portion
    .addr alien_guardian_routine_07 ; CPU address $b601 - draws the destroyed alien guardian body super-tiles
    .addr alien_guardian_routine_08 ; CPU address $b623 - blank more of the alien guardian body
    .addr alien_guardian_routine_09 ; CPU address $b643 - destroys wall in front of alien guardian
    .addr alien_guardian_routine_0a ; CPU address $b676 - remove lowest part of wall's collision and set floor for where wall was
    .addr alien_guardian_routine_0b ; CPU address $bd02 - destroy all enemies
    .addr remove_enemy              ; CPU address $e809 from bank 7

; determine the game completion count multiplied by #$10
; output
;  * $07 - GAME_COMPLETION_COUNT * #$10
set_game_completion_10x:
    lda GAME_COMPLETION_COUNT ; load the number of times the game has been completed
    jsr mv_low_nibble_to_high ; move low nibble of GAME_COMPLETION_COUNT to high nibble
    sta $07                   ; set result in $07
    rts

; shift low nibble to high nibble, e.g. %01101100 -> %11000000
mv_low_nibble_to_high:
    asl
    asl
    asl
    asl
    rts

; set enemy variables for super-tiles, hp, and delays, advance routine
alien_guardian_routine_00:
    jsr set_guardian_and_heart_enemy_hp ; calculate and set alien guardian's ENEMY_HP
    lda #$20                            ; a = #$20
    sta ENEMY_VAR_4,x                   ; delay between mouth movements
    lda #$90                            ; specify animated super-tiles for alien guardian
                                        ; #$90 -> super-tiles offset #$10, #$11 and #$12 (mouth closed) (see level_8_nametable_update_supertile_data)
    sta ENEMY_VAR_1,x                   ; set super-tile code for drawing a closed mouth
    lda #$40                            ; set timer to #$40 to complete showing alien guardian with auto scroll
    sta AUTO_SCROLL_TIMER_01            ; auto scroll counter
    lda #$03                            ; a = #$03
    jmp set_enemy_delay_adv_routine     ; set ENEMY_ANIMATION_DELAY counter to #$03; advance enemy routine

; called to calculate alien guardian and heart's ENEMY_HP
; (weapon strength code * #$10) + #$37 + (completion count * #$10)
; if the result is >= #$a0, ENEMY_HP is set to #$a0
set_guardian_and_heart_enemy_hp:
    jsr set_game_completion_10x ; $07 = #$10 * GAME_COMPLETION_COUNT
    lda PLAYER_WEAPON_STRENGTH  ; load player's weapon strength
    jsr mv_low_nibble_to_high   ; move low nibble into high nibble, setting low nibble to all 0, i.e. PLAYER_WEAPON_STRENGTH * #$10
    clc                         ; clear carry in preparation for addition
    adc #$37                    ; add #$37 to a
    bcs @set_max_hp             ; if this caused an overflow set HP to #$a0
    adc $07                     ; no overflow occurred, add (#$10 * GAME_COMPLETION_COUNT)
    bcs @set_max_hp             ; if this caused an overflow set HP to #$a0
    cmp #$a0                    ; see if sum is larger than #$a0
    bcc @set_enemy_hp           ; branch if sum is smaller than #$a0 to set sum to result; otherwise use max HP of #$a0

@set_max_hp:
    lda #$a0 ; a = #$a0 (max hp)

@set_enemy_hp:
    sta ENEMY_HP,x ; set enemy hp
    rts

; repeatedly open and close mouth
alien_guardian_routine_01:
    lda ENEMY_X_POS,x           ; load enemy x position on screen, decremented as frame scrolls right
    cmp #$50                    ; see if enemy is in the right 70% of the screen
    bcs @continue               ; branch if alien guardian is in the right 70% of the screen
                                ; !(WHY?) not sure of use of this check, player cannot cause alien guardian to scroll
                                ; this far due to wall in the way.  Possibly wall wasn't originally there
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position (doesn't occur in normal game play)

@continue:
    lda ENEMY_VAR_2,x                 ; load whether or not the drawing routine was successful for top jaw (0 = success, 1 = failure)
    beq @update_nametable_adv_routine ; branch if successfully drew top jaw
    jsr draw_alien_guardian_top_jaw   ; update nametable to draw top 2 super-tiles specified by ENEMY_VAR_1

@update_nametable_adv_routine:
    lda ENEMY_VAR_3,x                 ; load whether or not the drawing routine was successful for bottom jaw (0 = success, 1 = failure)
    beq @draw_mouth_adv_routine       ; branch if successfully drew bottom jaw
    jsr draw_alien_guardian_lower_jaw ; update nametable to animate the bottom super-tile of the mouth

; draw top and bottom of mouth
@draw_mouth_adv_routine:
    dec ENEMY_VAR_4,x                     ; decrement delay alien guardian between mouth animation
    bne @draw_lower_jaw_adv_routine       ; branch if delay hasn't elapsed
    lda #$20                              ; a = #$20
    sta ENEMY_VAR_4,x                     ; delay between mouth movements
    lda ENEMY_VAR_1,x                     ; load the top-right super-tile code
    cmp #$90                              ; see if it is super-tile code #$10 (alien guardian jaw mouth closed)
    bne @draw_alien_guardian_closed_mouth ; if not, then set it to closed and draw mouth closed
    lda #$92                              ; a = #$92
    sta ENEMY_VAR_1,x                     ; super-tile code for open mouth
    dec ENEMY_ANIMATION_DELAY,x           ; decrement enemy animation frame delay counter
    jmp @draw_alien_guardian_mouth

@draw_alien_guardian_closed_mouth:
    lda #$90          ; a = #$90
    sta ENEMY_VAR_1,x ; #$10 -> super-tile code for closed mouth

; input
;  * ENEMY_VAR_1 - #$90 for an open mouth, #$92 for a closed mouth
@draw_alien_guardian_mouth:
    jsr draw_alien_guardian_top_jaw   ; update nametable to draw top 2 super-tiles specified by ENEMY_VAR_1
    jsr draw_alien_guardian_lower_jaw ; update nametable to animate the bottom super-tile of the mouth

@draw_lower_jaw_adv_routine:
    jsr add_scroll_to_enemy_pos         ; add scrolling to enemy position
    lda ENEMY_ANIMATION_DELAY,x         ; load enemy animation frame delay counter
    bne @exit
    jmp draw_lower_jaw_open_adv_routine ; update nametable to animate the bottom super-tile of the mouth
                                        ; advance enemy routine to alien_guardian_routine_02

@exit:
    rts

; draw super-tile $08 at position ($0a - #$0e, $09 - #$10)
; input
;  * $08 - super-tile code to draw
;  * $09 - y position of the super-tile to draw (#$10 is subtracted from this point)
;  * $0a - x position of the super-tile to draw (#$0e is subtracted rom this point)
; output
;  * $0b - clear when successful, set when CPU_GRAPHICS_BUFFER is full
draw_alien_guardian_supertile:
    stx ENEMY_CURRENT_SLOT                     ; temporarily save value of x
    lda $08                                    ; load super-tile number to draw
    sta $10                                    ; store in $10 for load_bank_3_update_nametable_supertile call
    lda $09                                    ; load tile relative y position
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$10                                   ; subtract #$10 from y position
    tay                                        ; transfer to y position input for load_bank_3_update_nametable_supertile
    lda $0a                                    ; load x position into nametable
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$0e                                   ; subtract #$0e
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    ldx ENEMY_CURRENT_SLOT                     ; restore value of x
    lda #$00                                   ; a = #$00
    rol                                        ; move carry result from load_bank_3_update_nametable_supertile
    sta $0b                                    ; set whether call to update nametable was successful (0 success, 1 failure)
    rts

; draws specified ENEMY_VAR_1 super-tile and its subsequent value for the top two super-tiles
; of the alien guardian mouth
draw_alien_guardian_top_jaw:
    lda ENEMY_VAR_1,x                          ; load super-tile code for alien guardian
    sta $08                                    ; store top-right super-tile code in $08
    clc                                        ; clear carry in preparation for addition
    adc #$01
    sta $0c                                    ; set the top-left jaw super-tile to draw
    lda #$10                                   ; a = #$10
    jsr set_nametable_x_pos_for_alien_guardian ; add #$10 to enemy x position and stores result in $0a
    jsr draw_alien_boss_supertiles             ; draw top 2 super-tiles of alien guardian jaw ($08, $0c)
    lda $0b                                    ; load whether or not the top jaw was drawn (0 = success, 1 = failure)
    sta ENEMY_VAR_2,x                          ; set whether or not the supertile was updated for the top jaw (0 = success, 1 = failure)
    rts

; draws either a blank super-tile (mouth closed), or the lower jaw of alien guardian (mouth open)
; based on ENEMY_VAR_1
; this is the bottom right of the 3 super-tiles that are animated for the alien guardian
draw_alien_guardian_lower_jaw:
    lda ENEMY_VAR_1,x ; load the super-tile code for the top right, use to determine bottom super-tile code
    cmp #$92          ; super-tile #$14 (alien guardian lower jaw mouth open)
    beq @continue
    lda #$81          ; super-tile #$03 (blank super-tile used to clear before drawing new super-tile)

@continue:
    clc                                      ; clear carry in preparation for addition
    adc #$02                                 ; add #$02 to super-tile index (level_8_nametable_update_supertile_data)
    sta $08                                  ; set super-tile to draw
    ldy #$20                                 ; y = #$20
    lda #$11                                 ; a = #$11
    jsr set_nametable_pos_for_alien_guardian ; add #$11 to enemy x position and #$20 to enemy y position. store result x in $0a, y in $09
    jsr draw_alien_guardian_supertile        ; draw super-tile $08 at position ($0a - #$0e, $09 - #$10)
    lda $0b                                  ; set whether or not the supertile was updated for the bottom jaw (0 = success, 1 = failure)
    sta ENEMY_VAR_3,x                        ; store in ENEMY_VAR_3
    rts

; updates 2 super-tiles (#$20 tiles apart) for both alien guardian and alien heart
; draws the top 2 super-tiles of the 3 super-tiles that are animated for the alien guardian
; all super-tiles are indexes into level_8_nametable_update_supertile_data
; top left super-tiles
; * #$11 - alien guardian top teeth and lower left jaw mouth closed
; * #$13 - alien guardian top teeth mouth open
; top right super-tiles
; * #$10 - alien guardian jaw mouth closed
; * #$12 - alien guardian jaw mouth open
; input
;  * $09 - relative y position of super-tiles to draw
;  * $0a - relative x position of the top-right super tile to draw
;  * $08 - top right super-tile to draw
;  * $0c - top left super-tile to draw
; output
;  * $0b - clear when successful, set when CPU_GRAPHICS_BUFFER is full
draw_alien_boss_supertiles:
    lda $09                           ; load relative y position of tile
    sta $05                           ; store in $05 as backup
    lda $0a                           ; load relative x position of tile
    sta $06                           ; store in $06 as backup
    lda $0c                           ; load top right super tile code
    sta $04                           ; store in $04
    jsr draw_alien_guardian_supertile ; draw top right super-tile $08 at position ($0a - #$0e, $09 - #$10)
    lda $04                           ; restore value of $0c (top right super-tile code)
    sta $08                           ; set as super-tile code to draw
    lda $05                           ; load saved relative y position of super-tile to draw
    sta $09                           ; set as relative y position of super-tile to draw
    lda $06                           ; load relative x position of top-left super tile to draw
    sec                               ; set carry flag in preparation for subtraction
    sbc #$20                          ; subtract #$20 to get relative x position of top left super-tile
    sta $0a                           ; store in relative x position of super-tile to draw
    jmp draw_alien_guardian_supertile ; draw top left super-tile $08 at position ($0a - #$0e, $09 - #$10)

alien_guardian_exit_00:
    rts

; draws the bottom right super-tile of the alien guardian
; sets delay to #$20 and advance enemy routine
draw_lower_jaw_open_adv_routine:
    jsr draw_alien_guardian_lower_jaw ; update nametable to animate the bottom super-tile of the mouth
    lda #$20                          ; a = #$20 (delay between mouth open and attack)
    jmp set_enemy_delay_adv_routine   ; set ENEMY_ANIMATION_DELAY counter to a. advance enemy routine to #$03

; generates alien fetuses
alien_guardian_routine_02:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda ENEMY_ATTACK_FLAG       ; see if enemies should attack
    beq @set_delay_routine_01   ; branch if attack flag is disabled to set delay to #$03 and go to alien_guardian_routine_01
    dec ENEMY_ANIMATION_DELAY,x ; enemy attack flag set to off, decrement enemy animation frame delay counter
    lda ENEMY_ANIMATION_DELAY,x
    cmp #$02                    ; see if ENEMY_ANIMATION_DELAY is almost elapsed
    bcc @create_fetus_exit      ; timer is close to elapsing, create fetus and exit (creates #$02 fetuses)
    bne alien_guardian_exit_00  ; timer is not about to elapse, exit
    lda PLAYER_WEAPON_STRENGTH  ; timer is 2 cycles from elapsing
    cmp #$03
    bcc alien_guardian_exit_00

@create_fetus_exit:
    lda #$11                    ; a = #$11 (11 = alien fetus)
    jsr generate_enemy_a        ; generate #$11 enemy (alien fetus)
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    bne alien_guardian_exit_00

@set_delay_routine_01:
    lda #$03                    ; a = #$03 (mouth movements before next attack)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine to alien_guardian_routine_01

; blank super-tiles for lower jaw
; called by alien_guardian_routine_06 to blank out body portion above top jaw
alien_guardian_routine_05:
    jsr add_scroll_to_enemy_pos      ; add scrolling to enemy position
    lda #$00                         ; a = #$00 (blank super-tile entry in alien_boss_supertile_tbl)
    jsr update_alien_boss_supertiles ; updates 2 nametable super-tiles for alien guardian animation
    lda $0b                          ; load whether successfully able to update the super-tiles
    bne alien_guardian_exit_00       ; exit if unable to update the super-tiles
    lda #$01                         ; updated super-tiles, load a = #$01
    sta ENEMY_VAR_2,x                ; prep variable for alien_guardian_routine_05 to draw part of alien guardian
    jmp advance_enemy_routine        ; advance to alien_guardian_routine_06

; updates 2 nametable tiles for alien heart and alien guardian animation
; input
;  * a - entry in alien_boss_supertile_tbl
; output
;  * $0b - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_alien_boss_supertiles:
    asl
    asl                              ; quadruple since each entry is #$04 bytes
    tay                              ; transfer to offset register
    lda alien_boss_supertile_tbl,y   ; load pattern table tile code
    sta $08                          ; store left supertile code
    lda alien_boss_supertile_tbl+1,y ; load pattern table tile code
    sta $0c                          ; store right supertile code
    lda alien_boss_supertile_tbl+2,y ; load relative y position
    clc                              ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                ; add to enemy y position on screen
    sta $09                          ; store y position
    lda alien_boss_supertile_tbl+3,y ; load relative x position
    clc                              ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                ; add to enemy x position on screen
    sta $0a                          ; store x position
    jmp draw_alien_boss_supertiles   ; draw 2 super-tiles ($08, $0c) of alien guardian jaw or alien heart

; tile codes for alien guardian and heart (#$c * #$4 = #$30)
; byte 0: super-tile code 1 - right
; byte 1: super-tile code 2 - left
; byte 2: relative y position
; byte 3: relative x position
alien_boss_supertile_tbl:
    .byte $83,$83,$00,$10 ; #$03, #$03 - 2 blank super-tiles
    .byte $95,$96,$c0,$30 ; #$15, #$16 - alien guardian body destroyed
    .byte $97,$83,$e0,$50 ; #$17, #$03 - alien guardian body destroyed and blank super-tile
    .byte $84,$85,$f0,$10 ; heart - frame 0 - top-right and top-left
    .byte $86,$87,$10,$10 ; heart - frame 0 - bottom-right and bottom-left
    .byte $88,$89,$f0,$10 ; heart - frame 1 - top-right and top-left
    .byte $8a,$8b,$10,$10 ; heart - frame 1 - bottom-right and bottom-left
    .byte $8c,$8d,$f0,$10 ; heart - destroyed - top-right and top-left
    .byte $8e,$8f,$10,$10 ; heart - destroyed - bottom-right and bottom-left
    .byte $83,$83,$20,$f0 ; #$03, #$03 - 2 blank super-tiles (used for wall in front of alien guardian)
    .byte $83,$83,$40,$f0 ; #$03, #$03 - 2 blank super-tiles
    .byte $29,$29,$60,$f0 ; #$29, #$29 - empty ground

; blank top jaw first call, second call will blank body portion
alien_guardian_routine_06:
    jsr add_scroll_to_enemy_pos              ; add scrolling to enemy position
    lda ENEMY_VAR_2,x                        ; load whether or not the top jaw has been successfully blanked
    beq @blank_body                          ; branch to blank out the body portion if already blanked out top of jaw
    lda #$83                                 ; a = #$83 (blank super-tile from level_8_nametable_update_supertile_data)
    sta $08                                  ; set super-tile to draw (blank super-tile)
    ldy #$20                                 ; y = #$20
    lda #$10                                 ; a = #$10
    jsr set_nametable_pos_for_alien_guardian ; add #$10 to enemy x position and #$20 to enemy y position. store result x in $0a, y in $09
    jsr draw_alien_guardian_supertile        ; draw super-tile $08 at position ($0a - #$0e, $09 - #$10)
    lda $0b                                  ; load whether or not the top jaw was drawn (0 = success, 1 = failure)
    sta ENEMY_VAR_2,x                        ; store value in ENEMY_VAR_2,x so that next loop @blank_body can run if drawn successfully
                                             ; or another attempt at drawing can happen
    rts

@blank_body:
    lda #$e0                      ; a = #$e0
    jsr add_a_to_enemy_y_pos      ; add a to enemy y position on screen
    jsr alien_guardian_routine_05 ; blank out body portion
    lda #$20                      ; a = #$20
    jmp add_a_to_enemy_y_pos      ; add a to enemy y position on screen for alien_guardian_routine_07

; draws the destroyed alien guardian body super-tiles
alien_guardian_routine_07:
    jsr add_scroll_to_enemy_pos      ; add scrolling to enemy position
    lda ENEMY_VAR_2,x                ; load whether or not the body portion of alien guardian was blanked
    beq alien_guardian_destroy_body  ; draw the portion of the body that is destroyed (not blanked)
    lda #$01                         ; a = #$01 (entry in alien_boss_supertile_tbl) - top portion of destroyed body
    jsr update_alien_boss_supertiles ; updates 2 nametable super-tiles for alien guardian animation
    lda $0b                          ; load whether or not the top destroyed body was drawn (0 = success, 1 = failure)
    sta ENEMY_VAR_2,x                ; store value in ENEMY_VAR_2,x so that next loop alien_guardian_routine_07 can run if drawn successfully
                                     ; or another attempt at drawing can happen

alien_guardian_exit_02:
    rts

alien_guardian_destroy_body:
    lda #$02                         ; a = #$02 (entry in alien_boss_supertile_tbl)
    jsr update_alien_boss_supertiles ; updates 2 nametable super-tiles for alien guardian animation

; advance routine if successfully drew alien guardian super-tiles
alien_guardian_adv_routine_if_drawn:
    lda $0b                    ; load whether or not the super-tile was drawn (0 = success, 1 = failure)
    bne alien_guardian_exit_02 ; exit if unable to draw super-tiles so that next frame can retry

alien_guardian_set_draw_adv_routine:
    inc ENEMY_VAR_2,x         ; set flag indicating not drawn for next routine to draw
    jmp advance_enemy_routine

; blank more of the alien guardian body
alien_guardian_routine_08:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    lda #$83                                   ; a = #$83 (blank super-tile)
    sta $08                                    ; set super-tile to draw
    lda #$30                                   ; a = #$30 (amount to add to enemy x position)
    jsr set_nametable_x_pos_for_alien_guardian ; add #$30 to enemy x position and stores result in $0a
    jsr draw_alien_guardian_supertile          ; draw super-tile $08 at position ($0a - #$0e, $09 - #$10)
    ldy #$c0                                   ; y = c0
    lda #$f0                                   ; a = #$f0
    jsr set_nametable_pos_for_alien_guardian   ; subtract #$10 from enemy x position and add #$c0 to enemy y position. store result x in $0a, y in $09
    lda #$83                                   ; a = #$83 (blank super-tile)
    sta $08                                    ; set super-tile to draw
    jsr draw_alien_guardian_supertile          ; draw super-tile $08 at position ($0a - #$0e, $09 - #$10)
    jmp alien_guardian_adv_routine_if_drawn    ; advance routine if updated super-tiles, otherwise just exit to retry next frame

; destroys wall in front of alien guardian
alien_guardian_routine_09:
    jsr add_scroll_to_enemy_pos              ; add scrolling to enemy position
    lda ENEMY_VAR_2,x                        ; load whether or not successfully updated super-tiles for current routine
    beq @delete_bottom_wall_and_bg_collision
    lda #$09                                 ; a = #$09 (#$02 blank super-tiles) - entry in alien_boss_supertile_tbl

@delete_wall_and_bg_collision:
    jsr update_alien_boss_supertiles           ; updates 2 nametable super-tiles for alien guardian animation
    pha                                        ; backup a on the stack
    jsr alien_guardian_clear_wall_bg_collision
    pla                                        ; restore a from the stack
    sta ENEMY_VAR_2,x                          ; store whether or not was able to update super-tiles
    rts

@delete_bottom_wall_and_bg_collision:
    lda #$0a                                ; a = #$0a (#$02 blank super-tiles) - entry in alien_boss_supertile_tbl
    jsr @delete_wall_and_bg_collision       ; draw blank super-tiles over wall, and clear bg collision
    beq alien_guardian_set_draw_adv_routine ; advance routine if updated super-tiles, otherwise just exit to retry next frame
    rts

alien_guardian_clear_wall_bg_collision:
    lda $12                          ; backup $12 on stack
    pha                              ; store $12 on stack for backing up
    jsr clear_supertile_bg_collision ; set background collision code for wall to #$00 (empty) for super-tile at PPU address $12 (low) $13 (high)
    pla                              ; pop $12 off of stack
    clc                              ; clear carry in preparation for addition
    adc #$04                         ; add #$04 to PPU address low byte
    sta $12                          ; set PPU address low byte
    lda $13                          ; load PPU address high byte
    adc #$00                         ; add any carry from $12
    sta $13                          ; set PPU address high byte
    jmp clear_supertile_bg_collision ; set background collision code to #$00 (empty) for single super-tile at PPU address $12 (low) $13 (high)

; remove lowest part of wall's collision and set floor for where wall was
alien_guardian_routine_0a:
    jsr add_scroll_to_enemy_pos                ; add scrolling to enemy position
    lda ENEMY_VAR_2,x                          ; load whether or not successfully updated super-tiles for current routine
    beq alien_guardian_adv_routine             ; advance routine if successfully drawn
    lda #$0b                                   ; a = #$0b (empty ground) (alien_boss_supertile_tbl)
                                               ; regular ground where wall was in the way
    jsr update_alien_boss_supertiles           ; updates 2 nametable super-tiles for alien guardian animation
    pha                                        ; backup a on the stack
    lda $12                                    ; load background collision code location
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$20
    sta $12
    lda $13
    sbc #$00
    sta $13
    jsr alien_guardian_clear_wall_bg_collision ; clear lowest part of wall's collision code
    pla                                        ; restore a on the stack
    beq alien_guardian_adv_routine             ; advance routine to alien_guardian_routine_0b

alien_guardian_exit_01:
    rts

alien_guardian_adv_routine:
    jmp advance_enemy_routine

; play alien guardian destroyed sound, create initial explosion
alien_guardian_routine_03:
    lda #$55       ; a = #$55 (sound_55)
    jsr play_sound ; play alien guardian destroyed sound

create_boss_heart_explosion:
    jsr add_scroll_to_enemy_pos     ; add scrolling to enemy position
    jsr clear_enemy_custom_vars     ; set ENEMY_VAR_1, ENEMY_VAR_2, ENEMY_VAR_3, ENEMY_VAR_4 to zero
    sta $08                         ; set vertical offset from enemy position to #$00
    sta $09                         ; set horizontal offset from enemy position to #$00
    jsr create_explosion_at_x_y
    lda #$05                        ; a = #$05
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to #$05 and advance enemy routine

; alien guardian - pointer 5
; heart - pointer 5
; create series of explosions over screen, each with a #$05 frame delay before next explosion
alien_guardian_routine_04:
    jsr add_scroll_to_enemy_pos    ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x    ; decrement enemy animation frame delay counter
    bne alien_guardian_exit_01     ; exit if initial explosion from alien_guardian_routine_03 hasn't completed
    lda #$05                       ; a = #$05
    sta ENEMY_ANIMATION_DELAY,x    ; set enemy animation frame delay counter
    inc ENEMY_VAR_1,x              ; increment explosion number (!(BUG?) #$00 isn't used)
    lda ENEMY_VAR_1,x              ; load explosion number
    cmp #$0c                       ; see if drawn all explosions
    beq alien_guardian_adv_routine ; advance routine if drawn all explosions
    jmp @continue                  ; why jmp? doesn't seem necessary !(HUH)

@continue:
    asl                                         ; double since each entry in alien_guardian_explosion_offset_tbl is #$02 bytes
    tay                                         ; transfer to offset register
    lda alien_guardian_explosion_offset_tbl,y   ; load x position of explosion
    sta $08                                     ; set x position of explosion
    lda alien_guardian_explosion_offset_tbl+1,y ; load y position of explosion
    sta $09                                     ; set y position of explosion

; input
; * y - vertical offset
; * x - horizontal offset
create_explosion_at_x_y:
    ldy $08                     ; set vertical offset from enemy position (param for add_with_enemy_pos)
    lda $09                     ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos      ; stores a + enemy x position in $09, and y + enemy y position in $08
    jmp create_two_explosion_89 ; create explosion #$89 at location ($09, $08)

; pointer table for alien fetus (11) (#$5 * #$2 = #$a bytes)
alien_fetus_routine_ptr_tbl:
    .addr alien_fetus_routine_00       ; CPU address $b6ec
    .addr alien_fetus_routine_01       ; CPU address $b736
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; alien fetus - pointer 0
alien_fetus_routine_00:
    jsr alien_fetus_get_aim_timer ; set ENEMY_VAR_3,x to the delay before re-aiming towards player's current location
    asl ENEMY_VAR_3,x             ; double the value
    lda GAME_COMPLETION_COUNT     ; load the number of times the game has been completed
    clc                           ; clear carry in preparation for addition
    adc #$02                      ; add #$02 to game completion count
    sta ENEMY_HP,x                ; set enemy hp = completion count + #$02
    lda #$ac                      ; a = #$ac (sprite_ac)
    sta ENEMY_SPRITES,x           ; write enemy sprite code to CPU buffer
    lda #$06                      ; a = #$06
    sta ENEMY_ANIMATION_DELAY,x   ; set enemy animation frame delay counter
    lda P2_GAME_OVER_STATUS       ; player 2 game over state (1 = game over)
    bne @calc_velocity            ; branch if player 2 is in game over state
    lda RANDOM_NUM                ; player 2 is game over or not playing, load random number
    adc FRAME_COUNTER             ; add frame counter to random number
                                  ; !(WHY?) not sure why adding to random number. it is already random
                                  ; perhaps random number is used for something else this frame and
                                  ; developers didn't want the same number
    and #$1f                      ; keep bits ...x xxxx
    clc                           ; clear carry in preparation for addition
    adc #$0e                      ; add #$0e to random number
    sta ENEMY_VAR_4,x             ; set to random number [#$0e-#$2d]
    lda P1_GAME_OVER_STATUS       ; player 1 game over state (1 = game over)
    beq @calc_velocity            ; branch if player 1 not in game over state
    lda #$01                      ; player 1 in game over state, set ENEMY_VAR_4,x to #$01
    sta ENEMY_VAR_4,x

@calc_velocity:
    lda RANDOM_NUM  ; load random number
    and #$03        ; random number between #$00 and #$03
    bne @check_attr ; branch if not #$00 (3/4 probability)
    lda #$03        ; random number was #$00, set to #$03

; 50% chance of #$03, 25% of #$01, 25% of #$02
@check_attr:
    asl                    ; double random number between #$00 and #$03
    ldy ENEMY_ATTRIBUTES,x ; load the enemy attributes
    beq @set_velocity
    lda #$06               ; a = #$06

@set_velocity:
    sta ENEMY_VAR_1,x            ; store enemy aim direction
    inc ENEMY_ROUTINE,x          ; advance to alien_fetus_routine_01
    jmp alien_fetus_set_velocity ; set velocity based on ENEMY_VAR_1,x

; alien fetus - pointer 1
alien_fetus_routine_01:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne @check_velocity
    lda #$06                    ; animation delay has elapsed, a = #$06
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    ldy #$ff                    ; y = #$ff (-1)
    lda ENEMY_VAR_1,x           ; load enemy direction, #$00 = facing right incrementing clockwise, max #$0b
    clc                         ; clear carry in preparation for addition
    adc #$01                    ; add one to the aim direction
    cmp #$0c                    ; compare to #$0c (max facing direction)
    bne @get_sprite_offset      ; branch if not facing down
    lda #$00                    ; reset to facing right

@get_sprite_offset:
    sec                     ; set carry flag in preparation for subtraction
    sbc #$03                ; subtract #$03 from facing direction
    iny                     ; increment sprite code offset
    bcs @get_sprite_offset  ; loop until value of a is negative, this determines which sprite to show
    tya                     ; transfer sprite code offset to a [#$00-#$01]
    asl                     ; double value [#$00-#$02]
    sta $08                 ; set sprite code offset
    lda ENEMY_VAR_2,x       ; load whether or not the mouth is open (0 = closed, 1 = open)
    eor #$01                ; flip bit 0 (close mouth if open, open if closed)
    sta ENEMY_VAR_2,x       ; set new value of whether or not the mouth is open (0 = closed, 1 = open)
    lda ENEMY_SPRITE_ATTR,x ; enemy animation frame delay counter
    and #$3f                ; strip sprite flip flags
    sta ENEMY_SPRITE_ATTR,x ; enemy animation frame delay counter
    lda $08                 ; load sprite code
    cmp #$04                ; see if past the last sprite (sprite_af)
    bcc @set_sprite         ; branch if not past the last sprite
    lda ENEMY_SPRITE_ATTR,x ; load sprite attributes
    ora #$c0                ; set bits xx.. .... (flip sprite horizontally and vertically)
    sta ENEMY_SPRITE_ATTR,x ; set enemy sprite attributes
    lda $08                 ; load sprite code offset
    sec                     ; set carry flag in preparation for subtraction
    sbc #$04                ; subtract #$04 from offset to get back to #$00 (sprite_ac)

@set_sprite:
    clc                 ; clear carry in preparation for addition
    adc #$ac            ; add #$ac to to base sprite offset [#$00-#$02] (sprite_ac)
    adc ENEMY_VAR_2,x   ; add 0 or 1 depending on whether mouth is open
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer

@check_velocity:
    dec ENEMY_VAR_3,x              ; decrement velocity adjustment timer
    bne @maintain_current_velocity ; maintain current velocity if timer not elapsed
    jsr @aim_towards_player        ; timer elapsed, re-aim towards player

@maintain_current_velocity:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

@aim_towards_player:
    lda ENEMY_VAR_4,x
    and #$3e                              ; keep bits ..xx xxx.
    beq alien_fetus_exit
    jsr alien_fetus_get_aim_timer
    jsr set_08_09_to_enemy_pos            ; set $08 and $09 to enemy x's X and Y position
    lda ENEMY_VAR_4,x                     ; load target player index control, bit 0 specifies which player to target
    and #$01                              ; keep bit 0
    sta $0a                               ; store player index in $0a
    jsr aim_var_1_for_quadrant_aim_dir_00 ; determine next aim direction [#$00-#$0b] ($0c)
                                          ; adjusts ENEMY_VAR_1 to get closer to that value using quadrant_aim_dir_00

alien_fetus_set_velocity:
    lda ENEMY_VAR_1,x                  ; load calculated enemy aim direction
    asl
    asl                                ; quadruple since each entry in set_white_blob_alien_fetus_vel is #$04 bytes
    tay                                ; transfer to offset register
    jsr set_white_blob_alien_fetus_vel ; set the alien fetus velocity based on a
    lda ENEMY_VAR_4,x                  ; load target player index control
    clc                                ; clear carry so that #$03 is subtracted and not #$02
    sbc #$02                           ; subtract #$03 from target player index control (carry is clear)
    sta ENEMY_VAR_4,x                  ; set new value for target player index control

alien_fetus_exit:
    rts

; input
;  * y - the offset into white_blob_alien_fetus_vel_tbl
set_white_blob_alien_fetus_vel:
    lda white_blob_alien_fetus_vel_tbl,y    ; load y fast velocity
    sta ENEMY_Y_VELOCITY_FAST,x             ; set y fast velocity
    lda white_blob_alien_fetus_vel_tbl+1,y  ; load y fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x            ; set y fractional velocity
    lda white_blob_alien_fetus_vel_tbl+12,y ; load x fast velocity
    sta ENEMY_X_VELOCITY_FAST,x             ; set x fast velocity
    lda white_blob_alien_fetus_vel_tbl+13,y ; load x fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x            ; set x fractional velocity
    rts

; determine how frequently to re-aim towards player
alien_fetus_get_aim_timer:
    ldy ALIEN_FETUS_AIM_TIMER_INDEX ; load current
    inc ALIEN_FETUS_AIM_TIMER_INDEX ; increment read offset for next round
    lda alien_fetus_aim_timer_tbl,y ; load amount of time between re-aiming towards player
    cmp #$ff                        ; see if read last byte
    bne @set_aim_timer_exit         ; set ENEMY_VAR_3,x and exit if not end of data stream
    lda #$00                        ; read past last byte, reset offset to get first byte
    sta ALIEN_FETUS_AIM_TIMER_INDEX ; reset offset back to #$00
    jmp alien_fetus_get_aim_timer   ; jump to read the first byte (#$16) from alien_fetus_aim_timer_tbl

@set_aim_timer_exit:
    sta ENEMY_VAR_3,x
    rts

; table for delay amount between re-aiming alien fetus toward player (#$e bytes)
; CPU address $b7e8
alien_fetus_aim_timer_tbl:
    .byte $16,$0f,$08,$13,$3a,$06,$21
    .byte $3a,$1d,$14,$12,$28,$48,$ff

; pointer table for alien mouth (12) (#$6 * #$2 = #$c bytes)
alien_mouth_routine_ptr_tbl:
    .addr alien_mouth_routine_00       ; CPU address $b802 - set mouth hp and draw open mouth super-tile
    .addr alien_mouth_routine_01       ; CPU address $b81f - opens and closes while generating white blobs
    .addr alien_mouth_routine_02       ; CPU address $b85e - draw destroyed mouth super-tile
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; set mouth hp and draw open mouth super-tile
; alien mouth hp = (#$02 * GAME_COMPLETION_COUNT) + (PLAYER_WEAPON_STRENGTH + #$04)
alien_mouth_routine_00:
    lda PLAYER_WEAPON_STRENGTH      ; load player's weapon strength
    adc #$03                        ; add #$04 to player weapon strength (carry is always set here)
                                    ; because the carry flag is set from the cmp #$10 check before to run `exec_level_enemy_routine`
    sta $08                         ; store PLAYER_WEAPON_STRENGTH + #$03 in $08
    lda GAME_COMPLETION_COUNT       ; load the number of times the game has been completed
    asl                             ; double the number of times the game has been completed
    adc $08                         ; (#$02 * GAME_COMPLETION_COUNT) + (PLAYER_WEAPON_STRENGTH + #$03)
    sta ENEMY_HP,x                  ; set alien mouth's hp to this computed result
    lda #$20                        ; a = #$20 (delay after opening mouth for white blob to generate)
    sta ENEMY_VAR_3,x               ; set initial animation delay
    lda #$01                        ; a = #$01 (level_8_nametable_update_supertile_data - alien mouth (wadder) open)
    jsr draw_enemy_supertile_a      ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    lda #$0a                        ; a = #$0a (delay before first white blob is generated)
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a and advance enemy routine

; opens and closes while generating white blobs
alien_mouth_routine_01:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda ENEMY_X_POS,x           ; load enemy x position on screen
    cmp #$20                    ; stop moving/attacking past this x position
    bcs @continue               ; branch if the alien mouth isn't about to be scrolled off screen
    rts                         ; exit if alien mouth is about to be scrolled off screen

@continue:
    lda ENEMY_ATTACK_FLAG       ; see if enemies should attack
    beq @check_supertile        ; branch if enemies shouldn't attack
    dec ENEMY_ANIMATION_DELAY,x ; decrement white blob spawning delay
    bne @check_supertile        ; branch if animation delay hasn't elapsed
    lda #$13                    ; enemy type #$13 = white sentient blob
    jsr generate_enemy_a        ; generate #$13 enemy (white sentient blob)
    lda RANDOM_NUM              ; load random number
    and #$1f                    ; load random number between #$00 and #$1f
    adc #$c0                    ; add #$c0 to random number
    sta ENEMY_ANIMATION_DELAY,x ; set delay before next white sentient blob will be spawned

@check_supertile:
    dec ENEMY_VAR_3,x          ; decrement nametable update timer
    bne alien_mouth_exit       ; exit if the super-tile shouldn't be changed
    lda ENEMY_VAR_4,x          ; load which super-tile to draw (#$00 = alien mouth closed, #$01 = alien mouth open)
    and #$01                   ; keep bit 0
    clc                        ; clear carry in preparation for addition
    adc #$00                   ; !(HUH) carry is explicitly clear, this line of code doesn't do anything
    jsr draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    lda #$01                   ; a = #$01
    bcs @set_anim_delay_exit   ; branch if unable to draw super-tile to retry next frame
    inc ENEMY_VAR_4,x          ; successfully drew super-tile, set next super-tile
                               ; (only bit 0 matters and that alternates between #$00 and #$01)
    lda #$20                   ; a = #$20 (delay between mouth open/closed)

@set_anim_delay_exit:
    sta ENEMY_VAR_3,x ; set nametable update timer to #$20

alien_mouth_exit:
    rts

; draw destroyed mouth super-tile
alien_mouth_routine_02:
    lda #$02                   ; level_8_nametable_update_supertile_data - #$02 - alien mouth (wadder) destroyed
    jsr draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs alien_mouth_exit       ; exit if unable to drwa destoryed mouht to try again next frame
    jmp advance_enemy_routine  ; advance to next routine

; pointer table for white sentient blob (13) (#$6 * #$2 = #$c bytes)
white_blob_routine_ptr_tbl:
    .addr white_blob_routine_00        ; CPU address $b874 - find player to target
    .addr white_blob_routine_01        ; CPU address $b8b3 - float down until the blob 'gains sentience' and begins to target/hone in on the player
    .addr white_blob_routine_02        ; CPU address $b940 - targets player and rushes towards them at 3x speed, retargeting every so often
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; find player to target
white_blob_routine_00:
    lda RANDOM_NUM              ; load random number
    and #$1f                    ; keep bits ...x xxxx
    adc #$50                    ; add #$50
    sta ENEMY_VAR_2,x           ; delay before sentience starts, e.g. before the white blob pauses
                                ; then targets player quickly [#$50-#$6f]
    lda #$c0                    ; a = #$c0
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda P2_GAME_OVER_STATUS     ; player 2 game over state (1 = game over)
    bne @continue               ; branch if player 2 is game over
    lda RANDOM_NUM              ; load random number
    adc FRAME_COUNTER           ; add frame counter to random number
    and #$01                    ; keep bit 0
    sta ENEMY_VAR_3,x           ; store which player should be targeted
    lda P1_GAME_OVER_STATUS     ; player 1 game over state (1 = game over)
    beq @continue               ; branch if player 1 is not in game over
    lda #$01                    ; player 1 game over, have blob target player 2
    sta ENEMY_VAR_3,x           ; set to target player 2

@continue:
    lda #$b0                     ; a = #$b0 (sprite_b0 - poisonous insect gel)
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
    lda ENEMY_VAR_3,x            ; load which player to target
    sta $0a                      ; store player to target index in $0a
    jsr set_08_09_to_enemy_pos   ; set $08 and $09 to enemy x's X and Y position
    jsr get_rotate_01            ; get enemy aim direction and rotation direction using quadrant_aim_dir_01
    lda $0c                      ; load new aim direction
    sta ENEMY_VAR_1,x            ; store the aim direction in ENEMY_VAR_1
    inc ENEMY_ROUTINE,x          ; enemy routine index to white_blob_routine_01
    jmp white_blob_init_velocity ; initialize the x and y velocities

; float down until the blob 'gains sentience' and begins to target/hone in on the player
white_blob_routine_01:
    lda #$b0                         ; load base sprite offset
                                     ; white blob's use sprites sprite_b0, sprite_b1, sprite_b2
    jsr white_blob_spider_set_sprite ; check if ENEMY_ANIMATION_DELAY elapsed, and if so update the sprite
    jsr update_enemy_pos             ; apply velocities and scrolling adjust
    lda ENEMY_VAR_4,x                ; see if ENEMY_VAR_2,x (freeze delay) has elapsed, once ENEMY_VAR_2,x elapses ENEMY_VAR_4,x is set
    bne white_blob_freeze            ; branch if freeze delay has elapsed to freeze and advance to white_blob_routine_02
    jsr blob_spider_ld_delay_timer   ; set a to the timer portion of ENEMY_ANIMATION_DELAY (high nibble), e.g. #$74 -> #$07
                                     ; loops from #$08 to #$01
    cmp #$08                         ; see if sprite has just changed and timer has reset
    bne @dec_delay                   ; skip adjusting the velocity if sprite just changed
    jsr @adjust_velocity             ; ajust the velocity based on the aiming direction

@dec_delay:
    dec ENEMY_VAR_2,x                ; decrement delay before advancing to white_blob_routine_02
    beq white_blob_set_freeze_length ; branch if timer has elapsed to determine freeze delay before attacking
    rts

@adjust_velocity:
    ldy ENEMY_VAR_1,x              ; load the aim direction
    lda ENEMY_Y_VELOCITY_FRACT,x   ; load the fractional y velocity
    clc                            ; clear carry in preparation for addition
    adc white_blob_y_vel_adj_tbl,y ; add velocity adjument amount per frame based on aim direction
    sta ENEMY_Y_VELOCITY_FRACT,x   ; set new y fractional velocity
    lda ENEMY_X_VELOCITY_FRACT,x   ; load fractional x velocity
    clc                            ; clear carry in preparation for addition
    adc white_blob_x_vel_adj_tbl,y ; add x velocity adjument amount per frame based on aim direction
    sta ENEMY_X_VELOCITY_FRACT,x   ; set new x fractional velocity
    rts

white_blob_init_velocity:
    lda ENEMY_VAR_1,x                  ; load enemy aim direction
    asl                                ; double value since each entry in white_blob_alien_fetus_vel_tbl is #$02 bytes
    tay                                ; transfer to offset register
    jmp set_white_blob_alien_fetus_vel ; set the x and y velocities

; set a to the timer portion of ENEMY_ANIMATION_DELAY (high nibble), e.g. #$74 -> #$07
blob_spider_ld_delay_timer:
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    lsr
    lsr
    lsr
    lsr                         ; transfer high nibble to low nibble
    rts

; table for amount to add to y fractional velocity each frame based on aim rotation direction [#$00-#$16] (#$6 bytes)
; spills over into next table
white_blob_y_vel_adj_tbl:
    .byte $00,$fd,$fa,$f8,$f6,$f5

; table for amount to add to x fractional velocity each frame based on aim rotation direction [#$00-#$16] (#$6 bytes)
; spills over into next table
white_blob_x_vel_adj_tbl:
    .byte $f4,$f5,$f6,$f8,$fa,$fd
    .byte $00,$03,$06,$08,$0a,$0b
    .byte $0c,$0b,$0a,$08,$06,$03
    .byte $00,$fd,$fa,$f8,$f6,$f5

; randomly chooses a freeze duration of #$02 or #$20 frames
white_blob_set_freeze_length:
    lda RANDOM_NUM    ; load random number
    and #$20          ; keep bit 5
    clc               ; clear carry in preparation for addition
    adc #$02          ; add #$02
    sta ENEMY_VAR_4,x ; store either #$02 or #$22 as the 'freeze' duration before attacking

white_blob_exit:
    rts

; freezes white blob and quickly target player within 4 directions and advance to white_blob_routine_02
; sets ENEMY_VAR_2,x to #$08 to freeze white blob for additional #$08 frames
white_blob_freeze:
    jsr set_enemy_velocity_to_0  ; set x/y velocities to zero
    dec ENEMY_VAR_4,x            ; decrement freeze timer
    bne white_blob_exit          ; exit if freeze timer hasn't elapsed
    lda #$08                     ; freeze timer elapsed, target player with a #$08 frame delay
    sta ENEMY_VAR_4,x            ; set value for use in white_blob_routine_02
    sta ENEMY_VAR_2,x            ; set amount of additional frames to freeze blob for before attacking
    inc ENEMY_ROUTINE,x          ; advance to white_blob_routine_02
    jsr white_blob_aim_to_player ; hone towards player by calling #$04 times
    jsr white_blob_aim_to_player
    jsr white_blob_aim_to_player
    jmp white_blob_aim_to_player

; targets player and rushes towards them at 3x speed, retargeting every so often
white_blob_routine_02:
    lda #$b0                         ; set base sprite code offset for alien spiders (sprite_b0, sprite_b1, sprite_b2)
    jsr white_blob_spider_set_sprite ; check if ENEMY_ANIMATION_DELAY elapsed, and if so update the sprite
    lda ENEMY_VAR_4,x                ; load initial value of the velocity/direction update pause timer
    beq @update_enemy_pos            ; !(WHY?) not sure the real reason for this check, ENEMY_VAR_4, starts at #$08 and increments by #$02
    dec ENEMY_VAR_2,x                ; decrement velocity/direction update pause timer
    beq @update_velocity             ; branch if velocity/direction update pause timer elapsed to adjust velocity
    jmp @update_enemy_pos            ; additional freeze timer hasn't elapsed

; targets player and updates velocity to be 3x the standard velocities
@update_velocity:
    inc ENEMY_VAR_4,x                      ; add #$01 to ENEMY_VAR_4
    inc ENEMY_VAR_4,x                      ; add #$01 to ENEMY_VAR_4
    lda ENEMY_VAR_4,x                      ; re-load ENEMY_VAR_4,x, this is the new velocity/direction update pause timer
    sta ENEMY_VAR_2,x                      ; set velocity/direction update pause timer value for new velocity that is about to be calculated
    jsr white_blob_aim_to_player           ; aim towards player one increment towards correct direction
    lda ENEMY_VAR_1,x                      ; load aim direction [#$00-#$16]
    asl                                    ; double since each entry is #$02 bytes
    tay                                    ; transfer to offset register
    lda white_blob_alien_fetus_vel_tbl+3,y ; load fractional y velocity to multiply by #$03
    sta $08                                ; set fractional y velocity before multiplication
    lda white_blob_alien_fetus_vel_tbl+2,y ; load fast y velocity to multiply by #$03
    jsr mult_velocity_by_3                 ; multiply velocity by #$03 (a = fast velocity, $08 = fractional velocity)
    sta ENEMY_Y_VELOCITY_FAST,x            ; set y fast velocity (sped up 3x from table value)
    lda $08                                ; load new fractional y velocity
    sta ENEMY_Y_VELOCITY_FRACT,x           ; set y fractional velocity (sped up 3x from table value)
    lda white_blob_alien_fetus_vel_tbl+9,y ; load fractional x velocity to multiply by #$03
    sta $08                                ; set fractional x velocity before multiplication
    lda white_blob_alien_fetus_vel_tbl+8,y ; load fast x velocity to multiply by #$03
    jsr mult_velocity_by_3                 ; multiply velocity by #$03 (a = fast velocity, $08 = fractional velocity)
    sta ENEMY_X_VELOCITY_FAST,x            ; set x fast velocity (sped up 3x from table value)
    lda $08                                ; load new fractional x velocity
    sta ENEMY_X_VELOCITY_FRACT,x           ; set x fractional velocity (sped up 3x from table value)

@update_enemy_pos:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

; multiply loaded velocity by 3x
; e.g. fast vel: #$ff, fractional vel: #$23 (-.863) becomes fast vel: #$fd, fractional vel: #$69 (-2.589)
; input
;  * a - fast velocity component (either #$00 or #$ff)
;  * $08 - fractional velocity component
; output
;  * a - sped up fast velocity value
;  * $08 - sped up fractional velocity value
mult_velocity_by_3:
    sta $09 ; initialize $09 to fast velocity component
    sta $0a ; initialize $0a to fast velocity component
    lda $08 ; load fractional velocity value
    asl     ; double fractional component
    rol $09 ; move any carry from addition to $09 while also doubling $09
    clc     ; clear carry in preparation for addition
    adc $08 ; add shifted-left $08 to its original value, i.e. 2 * $08 + $08 -> #$03 * $08
    sta $08 ; store new value in $08
    lda $09 ; load doubled fast velocity component and any overflow from the fractional velocity doubling
    adc $0a ; add to original fast velocity (along with any additional overflow when getting the tripled fractional velocity)
    rts

; aim towards player one increment towards correct direction
white_blob_aim_to_player:
    jsr set_08_09_to_enemy_pos            ; set $08 and $09 to enemy x's X and Y position
    lda ENEMY_VAR_3,x                     ; load which player to attack
    sta $0a                               ; store value in $0a
    jmp aim_var_1_for_quadrant_aim_dir_01 ; determine next aim direction [#$00-#$0b] ($0c), adjusts ENEMY_VAR_1 to get closer to that value using quadrant_aim_dir_01

; alien spider and white blob
; check if ENEMY_ANIMATION_DELAY has elapsed, and if so update the sprite
; ENEMY_ANIMATION_DELAY timer is just high nibble portion, low nibble is for knowing which sprite to show next
; input
;  * a - base sprite offset to be added to that is specific to enemy type
white_blob_spider_set_sprite:
    sta $08                         ; set enemy type's base sprite offset
    lda ENEMY_ANIMATION_DELAY,x     ; load enemy animation frame delay counter
                                    ; preparing to move high nibble (timer portion) to the low nibble, e.g. #$73 -> #$07
    and #$0f                        ; keep low nibble
    tay                             ; transfer sprite index to offset register
    jsr blob_spider_ld_delay_timer  ; set a to the timer portion of ENEMY_ANIMATION_DELAY (high nibble), e.g. #$74 -> #$07
    sta ENEMY_ANIMATION_DELAY,x     ; set enemy animation frame delay counter to be just the high nibble moved to low nibble
    dec ENEMY_ANIMATION_DELAY,x     ; decrement timer portion of ENEMY_ANIMATION_DELAY
    bne @set_delay_and_sprite_index ; branch to skip changing sprite, if the animation delay hasn't elapsed

@get_sprite_offset:
    lda white_blob_spider_sprite_tbl,y ; load offset from $08 to determine sprite code
    cmp #$ff                           ; see if reached end of table data
    bne @set_sprite_and_delay          ; branch if haven't reached end of table data, otherwise point to first entry in table
    ldy #$00                           ; reset sprite offset index to first entry
    jmp @get_sprite_offset             ; jump to load the first table entry's sprite offset value

@set_sprite_and_delay:
    iny                         ; increment sprite index for next animation
    clc                         ; clear carry in preparation for addition
    adc $08                     ; add enemy type-specific sprite base offset
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer
    lda #$08                    ; reset enemy animation frame delay counter to #$08
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter (#$08 frames until sprite changes)

; moves low nibble of ENEMY_ANIMATION_DELAY into high nibble (animation timer)
; then adds y to result, setting the sprite index for the next frame
@set_delay_and_sprite_index:
    lda ENEMY_ANIMATION_DELAY,x ; load the timer portion of ENEMY_ANIMATION_DELAY
    jsr mv_low_nibble_to_high   ; move low nibble (timer nibble) into high nibble, setting low nibble to all 0
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    tya                         ; transfer the next white_blob_spider_sprite_tbl index to a
    clc                         ; clear carry in preparation for addition
    adc ENEMY_ANIMATION_DELAY,x ; set the low nibble to the sprite index
    sta ENEMY_ANIMATION_DELAY,x ; set full ENEMY_ANIMATION_DELAY with timer (high nibble) and index (low nibble)
    rts

; alien spider and white blob sprite code offsets (#$5 bytes)
; white blob - sprite_b0, sprite_b1, sprite_b2, sprite_b1
white_blob_spider_sprite_tbl:
    .byte $00,$01,$02,$01,$ff

; white blob velocities based on aim rotation direction (#$c bytes)
white_blob_alien_fetus_vel_tbl:
    .byte $00,$00
    .byte $00,$42 ; aim rotation dir - #$00 - facing right
    .byte $00,$7f ; aim rotation dir - #$01
    .byte $00,$b2
    .byte $00,$dd
    .byte $00,$f7
    .byte $00,$ff
    .byte $00,$f7
    .byte $00,$dd
    .byte $00,$b2
    .byte $00,$7f
    .byte $00,$42
    .byte $00,$00
    .byte $ff,$be
    .byte $ff,$81
    .byte $ff,$4e
    .byte $ff,$23
    .byte $ff,$09
    .byte $ff,$01
    .byte $ff,$09
    .byte $ff,$23
    .byte $ff,$4e
    .byte $ff,$81
    .byte $ff,$be
    .byte $00,$00
    .byte $00,$42
    .byte $00,$7f
    .byte $00,$b2
    .byte $00,$dd
    .byte $00,$f7

; pointer table for alien spider (14) (#$8 * #$2 = #$10 bytes)
alien_spider_routine_ptr_tbl:
    .addr alien_spider_routine_00      ; CPU address $ba3b - set spider hp, velocity, set whether will jump, advance routine to alien_spider_routine_03
    .addr alien_spider_routine_01      ; CPU address $bb44 - set score and collision code, set sprite to egg, set x velocity to -.3125 and y velocity to +-4, advance to alien_spider_routine_02
    .addr alien_spider_routine_02      ; CPU address $bb68 - alien spider while it's still an egg, float to ceiling or fall to ground, once close spawn from egg
    .addr alien_spider_routine_03      ; CPU address $ba8c - alien spider is on the ground/ceiling, or just landing on the ground/ceiling
    .addr alien_spider_routine_04      ; CPU address $bb2a - spider is jumping, check for groud/ceiling collision and if collided, go back to alien_spider_routine_03
    .addr enemy_routine_init_explosion ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion      ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy   ; CPU address $e806 from bank 7

; alien spider - pointer 1
; spider is on the ground from spawn as generated by level enemies, not by heart boss
alien_spider_routine_00:
    jsr set_alien_spider_hp_sprite_attr ; calculate alien spider hp and other variables

; set x velocity to -2.5, set y velocity to 0, choose player to target
; determine whether spider will jump, and set routine to alien_spider_routine_03
alien_spider_set_ground_vel_and_routine:
    jsr clear_enemy_custom_vars   ; set ENEMY_VAR_1, ENEMY_VAR_2, ENEMY_VAR_3, ENEMY_VAR_4 to zero
    lda #$b3                      ; a = #$b3 (sprite_b3)
    sta ENEMY_SPRITES,x           ; write enemy sprite code to CPU buffer (sprite_b3)
    lda #$fe                      ; a = #$fe
    sta ENEMY_X_VELOCITY_FAST,x   ; set fast x velocity of alien spider to -2
    lda #$80                      ; a = #$80
    sta ENEMY_X_VELOCITY_FRACT,x  ; set enemy fractional velocity to .5
    jsr set_enemy_y_velocity_to_0 ; set y velocity to zero
    lda P2_GAME_OVER_STATUS       ; player 2 game over state (1 = game over or player 2 not playing)
    bne @set_jump_flag_routine_03 ; branch if player 2 game over or not playing
    lda RANDOM_NUM                ; player 2 playing, load random number
    adc FRAME_COUNTER             ; add frame counter to random number
    and #$01                      ; keep bit 0
    sta ENEMY_VAR_1,x             ; store player to attack (0 = player 1, 1 = player 2)

; determine whether or not the alien spider will jump randomly and then set routine to alien_spider_routine_03
@set_jump_flag_routine_03:
    lda RANDOM_NUM             ; load random number
    lsr                        ; shift bit 0 to carry
    adc FRAME_COUNTER          ; add frame counter
    and #$02                   ; keep bit 1
    sta ENEMY_VAR_2,x          ; store whether spider will jump (#$00 = will not jump, #$02 = will jump)
    lda #$04                   ; a = #$04
    jmp set_enemy_routine_to_a ; set routine to alien_spider_routine_03

; alien spider hp = weapon strength + completion count + 2
set_alien_spider_hp_sprite_attr:
    lda PLAYER_WEAPON_STRENGTH  ; load player weapon strength
    adc GAME_COMPLETION_COUNT   ; add with the number of times the game has been completed
    adc #$01                    ; add #$01
    sta ENEMY_HP,x              ; set enemy hp (weapon strength + completion count + 2)
                                ; 2 because the carry flag is set from the cmp #$10 check before to run `exec_level_enemy_routine`
    lda #$60                    ; a = #$60
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda ENEMY_Y_POS,x           ; load enemy y position on screen
    cmp #$80                    ; see if alien spider in the bottom half of the screen
    lda #$00                    ; a = #$00 (no horizontal flip, no vertical flip)
    bcs @set_attr_exit          ; branch if in the bottom half of the screen
    lda #$80                    ; a = #$80 (vertical flip, no horizontal flip)

@set_attr_exit:
    sta ENEMY_SPRITE_ATTR,x ; set enemy sprite attributes
    rts

; alien spider is on the ground/ceiling, or just landing on the ground/ceiling
alien_spider_routine_03:
    lda #$b3                         ; set base sprite code offset for alien spiders (sprite_b3, sprite_b4, sprite_b5)
    jsr white_blob_spider_set_sprite ; check if ENEMY_ANIMATION_DELAY elapsed, and if so update the sprite
    lda ENEMY_VAR_3,x                ; load spider y fast velocity
    bne @walk_on_ground_ceiling      ; branch if spider has a y velocity, indicating it has jumped from ceiling and landed on ground
                                     ; or jumped from ground and landed on ceiling
    lda ENEMY_VAR_2,x                ; load whether or not the spider should jump
    beq @walk_on_ground_ceiling      ; branch if spider isn't jumping
    lda ENEMY_VAR_1,x                ; spider should jump, load targeted player (selected at random)
    tay                              ; transfer targeted player index to y
    lda SPRITE_Y_POS,y               ; load targeted player y position on screen
    cmp #$20                         ; see if towards the top 12.5% of the screen
    bcc @walk_on_ground_ceiling      ; don't jump if player is so high
    lda ENEMY_X_POS,x                ; load enemy x position on screen
    sec                              ; set carry flag in preparation for subtraction
    sbc SPRITE_X_POS,y               ; subtract targeted player x position from enemy x position
    cmp #$30                         ; distance for initiating jump
    bcs @walk_on_ground_ceiling      ; branch if player is too far to not jump yet
    lda ENEMY_Y_POS,x                ; spider should jump, load enemy y position on screen
    cmp SPRITE_Y_POS,y               ; player y position on screen
    bcs @jump_from_ground            ; branch if targeted player is above or at same level as spider
                                     ; to jump if player is within #$20 pixels
    lda #$02                         ; alien spider y velocity while descending to ground from ceiling
    sta ENEMY_Y_VELOCITY_FAST,x      ; set y fast velocity to 2
    lda #$40                         ; a = #$40
    sta ENEMY_Y_VELOCITY_FRACT,x     ; set y fractional velocity to .25
                                     ; new y velocity is 2.25
    lda PLAYER_WEAPON_STRENGTH       ; load player weapon strength
    jsr mv_low_nibble_to_high        ; move low nibble into high nibble, setting low nibble to all 0
    adc ENEMY_Y_VELOCITY_FRACT,x     ; add weapon strength * 10 to y velocity
    sta ENEMY_Y_VELOCITY_FRACT,x     ; set new y fractional velocity, more powerful the weapon, the faster the y velocity
    lda ENEMY_Y_VELOCITY_FAST,x      ; load spider y fast velocity
    adc #$00                         ; add any overflow from fractional y velocity
    sta ENEMY_Y_VELOCITY_FAST,x      ; set new spider y fast velocity
    jmp @set_vars_for_jump           ; set sprite, velocity, has jumped flag, and set routine to alien_spider_routine_04

@jump_from_ground:
    lda ENEMY_X_POS,x            ; load enemy x position on screen
    sec                          ; set carry flag in preparation for subtraction
    sbc SPRITE_X_POS,y           ; subtract sprite y's x position from enemy x position
    cmp #$20                     ; distance for initiating take off when jumping from ground
                                 ; (compare to #$30 when descending from ceiling)
    bcs @walk_on_ground_ceiling  ; branch to continue alien spider crawling on ground if not close enough
    lda #$ff                     ; a = #$ff
    sta ENEMY_Y_VELOCITY_FAST,x  ; set alien spider y velocity to -1
    lda #$00                     ; a = #$00
    sta ENEMY_Y_VELOCITY_FRACT,x ; set alien spider y fractional velocity to 0

; set sprite, velocity, has jumped flag, and set routine to alien_spider_routine_04
@set_vars_for_jump:
    lda #$b3                     ; a = #$b3
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer
    lda ENEMY_SPRITE_ATTR,x      ; load enemy sprite attributes
    and #$3f                     ; keep bits ..xx xxxx (no flip)
    sta ENEMY_SPRITE_ATTR,x      ; set enemy sprite attributes
    lda ENEMY_Y_VELOCITY_FAST,x
    bmi @set_jump_adv_routine
    lda #$ff                     ; a = #$ff
    sta ENEMY_X_VELOCITY_FAST,x
    lda #$80                     ; a = #$80
    sta ENEMY_X_VELOCITY_FRACT,x

@set_jump_adv_routine:
    inc ENEMY_VAR_3,x    ; set spider to jump
    inc ENEMY_ROUTINE,x  ; move to enemy routine index to alien_spider_routine_04
    jmp update_enemy_pos ; apply velocities and scrolling adjust

; spider is landing on ground or ceiling, set y position and stop y velocity
@walk_on_ground_ceiling:
    lda #$b8               ; a = #$b8 (spider on ground y position)
    cmp ENEMY_Y_POS,x      ; compare #$b8 with enemy y position on screen
    bcc @continue          ; branch to continue if higher than #$b8 on screen (smaller y)
    lda #$38               ; spider higher than #$b8, set a = #$38 (spider on ceiling y position)
    cmp ENEMY_Y_POS,x      ; compare #$38 to enemy y position on screen
    bcc @update_pos_stop_y ; branch if spider's y position is greather than #$38 (below ceiling)

; spider's y position is either
;  1. higher than #$b8 (above the ground)
;  2. higher than #$38 (below ceiling)
@continue:
    sta ENEMY_Y_POS,x ; enemy y position on screen

@update_pos_stop_y:
    jsr update_enemy_pos          ; apply velocities and scrolling adjust
    jmp set_enemy_y_velocity_to_0 ; set y velocity to zero

; spider is jumping, check for groud/ceiling collision and if collided, go back to alien_spider_routine_03
alien_spider_routine_04:
    jsr init_vars_get_enemy_bg_collision ; initialize required memory and call get_enemy_bg_collision to determine bg collision
    bcc @update_pos                      ; branch if no collision with the ground
    jsr set_enemy_y_velocity_to_0        ; collided with ground or ceiling, set y velocity to zero
    lda #$fe                             ; a = #$fe, alien spider x velocity after landing (-2)
    sta ENEMY_X_VELOCITY_FAST,x          ; set enemy fast velocity
    lda #$80                             ; a = #$80 (.5)
    sta ENEMY_X_VELOCITY_FRACT,x         ; set enemy fractional velocity
    lda #$04                             ; a = #$04
    sta ENEMY_ROUTINE,x                  ; set routine back to alien_spider_routine_03

@update_pos:
    jmp update_enemy_pos ; apply velocities and scrolling adjust

; alien spider - pointer 2
; set score and collision code, set sprite to egg, set x velocity to -.3125 and y velocity to +-4, advance to alien_spider_routine_02
alien_spider_routine_01:
    lda #$33                            ; a = #$33
    sta ENEMY_SCORE_COLLISION,x         ; set score code to 3 (500 points), collision code to 3
    jsr set_alien_spider_hp_sprite_attr ; alien spider x/y velocities when out of spider spawn
    lda #$b6                            ; a = #$b6 (sprite_b6 - alien egg)
    sta ENEMY_SPRITES,x                 ; write enemy sprite code to CPU buffer
    lda #$ff                            ; a = #$ff
    sta ENEMY_X_VELOCITY_FAST,x         ; set fast x velocity to -1
    lda #$b0                            ; a = #$b0
    sta ENEMY_X_VELOCITY_FRACT,x        ; set fractional velocity to
                                        ; x velocity result in decimal is -0.3125
    lda #$fc                            ; a = #$fc
    sta ENEMY_VAR_3,x                   ; enemy y fast velocity (-4)
    lda #$00                            ; a = #$00
    sta ENEMY_VAR_4,x                   ; enemy y fractional velocity
    jmp advance_enemy_routine           ; advance to alien_spider_routine_02

; alien spider while it's still an egg, float to ceiling or fall to ground, once close spawn from egg
alien_spider_routine_02:
    lda ENEMY_VAR_4,x            ; load y fractional velocity
    clc                          ; clear carry in preparation for addition
    adc #$28                     ; add gravity when out of spider spawn
    sta ENEMY_VAR_4,x            ; add #$28 to y fractional velocity
    lda ENEMY_VAR_3,x            ; load y fast velocity
    adc #$00                     ; add any overflow from y velocity accumulator
    sta ENEMY_VAR_3,x            ; update y fast velocity
    lda ENEMY_Y_POS,x            ; load enemy y position on screen
    cmp #$80                     ; compare to midway down the screen
    bcc @float_to_ceiling        ; branch if above the top of the screen to get 'sucked' up to the ceiling
    lda ENEMY_VAR_3,x            ; below the middle if the screen, gravity pulls spider down, load y fast velocity
    sta ENEMY_Y_VELOCITY_FAST,x  ; set y fast velocity
    lda ENEMY_VAR_4,x            ; load updated fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x ; set y fractional velocity
    jmp @check_if_spawn          ; jump to apply velocity and see if should 'spawn' from egg

@float_to_ceiling:
    lda ENEMY_VAR_3,x            ; load y fast velocity
    eor #$ff                     ; flip all bits
    sta ENEMY_Y_VELOCITY_FAST,x  ; set y fast velocity
    lda #$00                     ; a = #$00
    sec                          ; set carry flag in preparation for subtraction
    sbc ENEMY_VAR_4,x            ; subtract y fractional velocity (inverted gravity applied)
    sta ENEMY_Y_VELOCITY_FRACT,x ; set new y fractional velocity

@check_if_spawn:
    jsr update_enemy_pos       ; apply velocities and scrolling adjust
    lda ENEMY_Y_POS,x          ; load enemy y position on screen
    cmp #$c1                   ; see if close to the ceiling
    bcs @spawn_spider_from_egg ; spawn from egg if close to ceiling
    cmp #$30                   ; see if close to ground
    bcc @spawn_spider_from_egg ; spawn from egg if close to ground
    rts                        ; exit if not near ceiling nor ground

@spawn_spider_from_egg:
    lda #$b3                                    ; a = #$b3 (sprite_b3) boss alien bugger insect/spider (frame 1)
    sta ENEMY_SPRITES,x                         ; write enemy sprite code to CPU buffer
    jmp alien_spider_set_ground_vel_and_routine ; set x velocity to -2.5, set y velocity to 0, choose player to target
                                                ; determine whether spider will jump, and set routine to alien_spider_routine_03

; pointer table for spider spawn (15) (#$6 * #$2 = #$c bytes)
alien_spider_spawn_routine_ptr_tbl:
    .addr alien_spider_spawn_routine_00 ; CPU address $bbc3 - set spider spawn hp and nametable update supertile index
    .addr alien_spider_spawn_routine_01 ; CPU address $bbf0 - cycle animating the opening of the flower and the generation of alien spiders
    .addr alien_spider_spawn_routine_02 ; CPU address $bc6d - destroyed routine, draw destroyed super-tile and advance routine
    .addr enemy_routine_init_explosion  ; CPU address $e74b from bank 7
    .addr enemy_routine_explosion       ; CPU address $e7b0 from bank 7
    .addr enemy_routine_remove_enemy    ; CPU address $e806 from bank 7

; set spider spawn hp and nametable update supertile index
; spider spawn hp = (completion count * 2) + *weapon strength * 2) + #$18
alien_spider_spawn_routine_00:
    lda GAME_COMPLETION_COUNT   ; load the number of times the game has been completed
    asl                         ; double the number of times the game has been completed
    sta $08                     ; store result in $08
    lda PLAYER_WEAPON_STRENGTH  ; load player's weapon strength
    asl                         ; double player's weapon strength
    adc $08                     ; add to doubled game completion count
    adc #$18                    ; add a base hp of #$18
    sta ENEMY_HP,x              ; set enemy hp (#$18 + (2 * GAME_COMPLETION_COUNT) + (2 * PLAYER_WEAPON_STRENGTH))
    lda RANDOM_NUM              ; load random number
    adc FRAME_COUNTER           ; add frame counter
    and #$3f                    ; keep bits ..xx xxxx
    adc #$a0                    ; add #$a0
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation delay before spider spawn opens and starts spawning enemies
                                ; random between 0 and #$3f + #$a0
    ldy #$a5                    ; #$25 - alien spider spawn on ground closed (frame 1) (see level_8_nametable_update_supertile_data)
    lda ENEMY_Y_POS,x           ; load enemy y position on screen
    cmp #$80                    ; compare to the middle of the screen
    bcs @continue               ; branch if towards the ground
    ldy #$a1                    ; #$21 - alien spider spawn on ceiling closed (frame 1) (see level_8_nametable_update_supertile_data)

@continue:
    tya                 ; transfer to offset register
    sta ENEMY_VAR_1,x   ; store nametable tile update supertile index (see level_8_nametable_update_supertile_data)
    inc ENEMY_ROUTINE,x ; enemy routine index (0 = empty enemy slot)
    rts

; cycle animating the opening of the flower and the generation of alien spiders
alien_spider_spawn_routine_01:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda ENEMY_VAR_4,x           ; load delay between generating spiders
    bne @check_frame_gen_spider ; branch if spider generation delay not elapsed to advance the animation frame if animation delay elapsed
                                ; and possibly generate spider
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    lda ENEMY_ANIMATION_DELAY,x ; load frame animation delay
    beq @gen_spider             ; branch if delay has elasped, can now generate a spider
    cmp #$30                    ; compare delay to #$30 (animation happens at #$30 and #$10)
    beq @adv_frame              ; move to next super-tile in the animation (closed -> partially open -> open)
    cmp #$10                    ; compare delay to #$10 (animation happens at #$30 and #$10)
    beq @adv_frame              ; move to next super-tile in the animation (closed -> partially open -> open)
    rts

@gen_spider:
    lda ENEMY_ATTACK_FLAG ; see if enemies should attack (1 = yes, 0 = no)
    beq @continue         ; branch if shouldn't attack
    lda #$14              ; a = #$14 (14 = alien spider)
    jsr generate_enemy_a  ; generate #$14 enemy (alien spider)
    bne @continue         ; branch if unable to generate alien spider
    lda #$02              ; generated alien spider, a = #$02
    sta ENEMY_ROUTINE,y   ; set newly created alien spider's enemy routine index to alien_spider_routine_01
                          ; this skips alien_spider_routine_00, which sets initial ground/ceiling velocities

; determine delay between generating spiders based on weapon code
@continue:
    lda P1_CURRENT_WEAPON       ; load player 1 current weapon code (and rapid fire flag)
    ora P2_CURRENT_WEAPON       ; merge with player 2 current weapon code (and rapid fire flag)
    and #$07                    ; keep bits .... .xxx
    sta $08                     ; store merged weapon code in $08
    lda #$0a                    ; a = #$0a
    sec                         ; set carry flag in preparation for subtraction
    sbc $08                     ; #$0a - merged weapon code
    sta ENEMY_VAR_4,x           ; store calculated delay between alien spider generation
    lda FRAME_COUNTER           ; load frame counter
    adc RANDOM_NUM              ; randomizer
    and #$03                    ; keep bits .... ..xx
    adc ENEMY_VAR_4,x           ; add random number between #$00 and #$3 inclusively to delay
    sta ENEMY_VAR_4,x           ; update delay between alien spider generation
    lda #$14                    ; a = #$14 (related to delay between spawns)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter before starting cycle over

@exit:
    rts

@adv_frame:
    inc ENEMY_VAR_1,x   ; increment nametable super-tile index (see level_8_nametable_update_supertile_data)
    inc ENEMY_VAR_3,x   ; increment animation frame number (easier to keep track of which super-tile is being drawn)
    lda ENEMY_VAR_3,x   ; load animation frame number
    cmp #$03            ; see if past the last frame (alien spider spawn fully open)
    bcc @draw_supertile ; branch if super-tile to draw isn't past last animation frame
    dec ENEMY_VAR_1,x   ; go back to frame 1 by subtracting 2 from ENEMY_VAR_1 (actual index) and ENEMY_VAR_3 (frame number)
    dec ENEMY_VAR_1,x   ; go back to first super-tile (alien spider spawn closed (frame 1))
    dec ENEMY_VAR_3,x
    dec ENEMY_VAR_3,x

@draw_supertile:
    lda ENEMY_VAR_1,x          ; load super-tile to draw
    jmp draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)

; advance the animation frame if delay elapsed and generate spider if generation delay elapsed
@check_frame_gen_spider:
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne @exit                   ; exit if delay hasn't elapsed
    lda #$14                    ; delay elapsed, a = #$14
    sta ENEMY_ANIMATION_DELAY,x ; reset enemy animation frame delay counter
    jsr @adv_frame              ; move to the next super-tile
    dec ENEMY_VAR_4,x           ; decrement delay between generating spiders
    beq @gen_spider             ; generate a spider if delay has elapsed
    rts

; destroyed routine, draw destroyed super-tile and advance routine
alien_spider_spawn_routine_02:
    ldy #$a8                        ; #$28 - destroyed alien spider spawn on ground (see level_8_nametable_update_supertile_data)
    lda ENEMY_Y_POS,x               ; load enemy y position on screen
    cmp #$80                        ; see if spawn is above or below the middle of the screen
    bcs @draw_supertile_adv_routine ; branch if below
    ldy #$a4                        ; #$24 - destroyed alien spider spawn on ceiling (see level_8_nametable_update_supertile_data)

@draw_supertile_adv_routine:
    tya                        ; transfer to offset register
    jsr draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcc @adv_enemy_routine     ; advance routine if able to update super-tile
    rts                        ; exit to try again next loop

@adv_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; pointer table for final boss heart (#$8 * #$2 = #$10 bytes)
boss_heart_routine_ptr_tbl:
    .addr boss_heart_routine_00     ; CPU address $bc92 - set heart hp, animation delay, and advance routine
    .addr boss_heart_routine_01     ; CPU address $bc9d
    .addr boss_heart_routine_02     ; CPU address $bcb4
    .addr boss_heart_routine_03     ; CPU address $bd4c
    .addr alien_guardian_routine_04 ; CPU address $b6b2 - create series of explosions, each with a #$05 frame delay before next explosion
    .addr boss_heart_routine_05     ; CPU address $bceb
    .addr boss_heart_routine_06     ; CPU address $bcf8
    .addr alien_guardian_routine_0b ; CPU address $bd02

; set heart hp, animation delay, and advance routine
boss_heart_routine_00:
    jsr set_guardian_and_heart_enemy_hp ; calculate heart hp
    lda #$0a                            ; a = #$0a (delay before first heartbeat)
    sta ENEMY_ANIMATION_DELAY,x         ; set enemy animation frame delay counter
                                        ; (wait for AUTO_SCROLL_TIMER_00 set in set_boss_auto_scroll)
    jmp advance_enemy_routine           ; advance to next routine

; heart - pointer 2
; wait for boss auto scroll, advance routine
boss_heart_routine_01:
    jsr add_scroll_to_enemy_pos  ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x  ; decrement enemy animation frame delay counter
    beq @animation_delay_elapsed
    rts                          ; exit if animation time has not elapsed

@animation_delay_elapsed:
    inc ENEMY_VAR_2,x
    lda ENEMY_HP,x             ; load enemy hp
    lsr
    bne @set_delay_adv_routine
    lda #$01                   ; set animation delay counter to #$01

@set_delay_adv_routine:
    jmp set_enemy_delay_adv_routine ; set ENEMY_ANIMATION_DELAY counter to a
                                    ; advance enemy routine

; heart - pointer 3
boss_heart_routine_02:
    jsr add_scroll_to_enemy_pos      ; add scrolling to enemy position
    lda ENEMY_VAR_2,x
    beq @continue
    inc ENEMY_VAR_4,x
    lda ENEMY_VAR_4,x
    and #$01                         ; keep bits .... ...x
    asl
    clc                              ; clear carry in preparation for addition
    adc #$03
    jsr update_alien_boss_supertiles ; updates 2 nametable tiles for boss heart animation
    lda $0b
    sta ENEMY_VAR_2,x
    rts

@continue:
    lda ENEMY_VAR_4,x
    and #$01                         ; keep bits .... ...x
    asl
    clc                              ; clear carry in preparation for addition
    adc #$04                         ; determine correct entry in alien_boss_supertile_tbl
    jsr update_alien_boss_supertiles ; updates 2 nametable tiles for boss heart animation
    lda $0b
    sta ENEMY_VAR_2,x
    beq @set_boss_heart_routine_01
    rts

@set_boss_heart_routine_01:
    lda #$02            ; a = #$02 (boss_heart_routine_01)
    sta ENEMY_ROUTINE,x ; enemy routine index
    rts

; heart - pointer 6
boss_heart_routine_05:
    lda #$07                             ; a = #$07
    jsr update_alien_boss_supertiles     ; updates 2 nametable tiles for boss heart animation (destroyed)
    lda $0b
    beq boss_heart_destroyed_adv_routine
    rts

boss_heart_destroyed_adv_routine:
    jmp advance_enemy_routine ; advance to next routine

; heart - pointer 7
boss_heart_routine_06:
    lda #$08                             ; a = #$08
    jsr update_alien_boss_supertiles     ; updates 2 nametable tiles for boss heart animation (destroyed)
    lda $0b
    beq boss_heart_destroyed_adv_routine
    rts

; alien guardian - pointer c
; heart - pointer 8
; destroy all enemies
alien_guardian_routine_0b:
    ldx #$0f ; x = #$0f

; looks for specific enemies and runs routine appropriate destroy routine
@destroy_enemy_loop:
    lda ENEMY_TYPE,x               ; load current enemy type
    cmp #$14                       ; ENEMY_TYPE #$14 (alien spider)
    beq @spider_destroy            ; branch if alien spider
    cmp #$15                       ; ENEMY_TYPE #$15 (spider spawn)
    beq @spawn_mouth_fetus_destroy ; branch if spider spawn
    cmp #$12                       ; ENEMY_TYPE #$12 (alien mouth)
    beq @spawn_mouth_fetus_destroy ; branch if alien mouth
    cmp #$13                       ; ENEMY_TYPE #$13 (white blob)
    beq @white_blob_destroy        ; branch if white blob
    cmp #$11                       ; ENEMY_TYPE #$11 (alien fetus)
    beq @spawn_mouth_fetus_destroy ; alien fetus

@move_next_enemy:
    dex                        ; move down to next enemy slot
    bne @destroy_enemy_loop    ; move to next enemy to see if should handle
    ldx ENEMY_CURRENT_SLOT     ; restore enemy current slot back to x
    lda #$a0                   ; a = #$a0
    jmp set_delay_remove_enemy ; set delay to a and remove enemy

; alien_spider_spawn_routine_02
; alien_mouth_routine_02
; enemy_routine_init_explosion
@spawn_mouth_fetus_destroy:
    lda #$03                         ; a = #$03
    bne @set_routine_move_next_enemy ; set routine to start destroying enemy

; enemy_routine_init_explosion
@spider_destroy:
    lda #$06 ; a = #$06

@set_routine_move_next_enemy:
    sta ENEMY_ROUTINE,x  ; set enemy slot (0 = empty)
    bne @move_next_enemy

; enemy_routine_init_explosion
@white_blob_destroy:
    lda #$04                         ; a = #$04
    bne @set_routine_move_next_enemy

; table for explosions relative positions for heart (#$c * #$2 = #$18 bytes)
alien_guardian_explosion_offset_tbl:
    .byte $10,$10 ;  #$10 ,  #$10 - unused !(UNUSED) (see alien_guardian_routine_04)
    .byte $f0,$10 ; -#$10 ,  #$10
    .byte $f0,$f0 ; -#$10 , -#$10
    .byte $10,$f0 ;  #$10 , -#$10
    .byte $20,$20 ;  #$20 ,  #$20
    .byte $e0,$20 ; -#$20 ,  #$20
    .byte $e0,$e0 ; -#$20 , -#$20
    .byte $20,$e0 ;  #$20 , -#$20
    .byte $40,$40 ;  #$40 ,  #$40
    .byte $c0,$40 ; -#$40 ,  #$40
    .byte $c0,$c0 ; -#$40 , -#$40
    .byte $50,$00 ;  #$50 ,  #$00

; heart - pointer 4
boss_heart_routine_03:
    jsr init_APU_channels
    lda #$57                        ; a = #$57 (sound_57) - boss destroyed
    jsr level_boss_defeated         ; play boss destroyed sound and initiate auto-move
    jmp create_boss_heart_explosion ; start animation of heart explosion

; adds a to ENEMY_X_POS and stores result in $0a
; $0a and $09 are used in draw_alien_guardian_supertile
set_nametable_x_pos_for_alien_guardian:
    ldy #$00                                 ; y = #$00
    beq set_nametable_pos_for_alien_guardian ; always jump
    lda #$00                                 ; dead code, never called !(UNUSED)

; adds a to ENEMY_X_POS and stores result in $0a
; adds y to ENEMY_Y_POS and stores result in $09
; $0a and $09 are used in draw_alien_guardian_supertile
set_nametable_pos_for_alien_guardian:
    clc               ; clear carry in preparation for addition
    adc ENEMY_X_POS,x ; add to enemy x position on screen
    sta $0a
    tya
    clc               ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x ; add to enemy y position on screen
    sta $09
    rts

; unused #$295 bytes out of #$4,000 bytes total (95.96% full)
; unused 661 bytes out of 16,384 bytes total (95.96% full)
; filled with 661 #$ff bytes by contra.cfg configuration
bank_0_unused_space: