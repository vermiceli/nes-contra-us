; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 6 contains compressed graphics data, data for short text sequences like
; level names and menu options.  Bank 6 also contains the code for the players'
; weapons and bullets.

.segment "BANK_6"

.include "constants.asm"

; import labels from bank 7
.import play_sound, run_routine_from_tbl_below
.import set_vel_for_speed_vars, get_bg_collision_far, set_bullet_routine_to_2

; export labels for bank 7
.export short_text_pointer_table
.export graphic_data_0c, graphic_data_0d
.export graphic_data_0e, graphic_data_15
.export graphic_data_16
.export run_player_bullet_routines, check_player_fire

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $06 ; The PRG ROM bank number (6)

; compressed graphics data - code 0c (#$cdb bytes)
; same PPU addresses as graphic_data_0d
; pattern table data - writes addresses
; * [$09a0-$0a80)
; * [$0dc0-$0ee0)
; * [$0fc0-$1200)
; * [$1320-$2000)
; CPU address $8001
graphic_data_0c:
    .incbin "assets/graphic_data/graphic_data_0c.bin"

; compressed graphics data - code 0d (#$efa bytes)
; same PPU addresses as graphic_data_0c
; pattern table data - writes addresses
; * [$09a0-$0a80)
; * [$0dc0-$0ee0)
; * [$0fc0-$1200)
; * [$1320-$2000)
; CPU address $8cdc
graphic_data_0d:
    .incbin "assets/graphic_data/graphic_data_0d.bin"

; compressed graphics data - code 0e (#$14a4 bytes)
; pattern table data - writes addresses [$09a0-$2000)
; CPU address $9bd6
graphic_data_0e:
    .incbin "assets/graphic_data/graphic_data_0e.bin"

; compressed graphics data - code 15 (#$e2 bytes)
; Turret Guy
; left pattern data - writes addresses [$0ee0-$0fc0)
; CPU address $b07a
graphic_data_15:
    .incbin "assets/graphic_data/graphic_data_15.bin"

; compressed graphics data - code 16 (#$106 bytes)
; Weapon Box
; right pattern data - writes addresses [$1200-$1320)
; CPU address $b15c
graphic_data_16:
    .incbin "assets/graphic_data/graphic_data_16.bin"

; pointer table for all the strings, and palette data (#$02 bytes * #$19 strings = #$32 bytes)
short_text_pointer_table:
    .addr text_1_player              ; CPU address $b2e1 - 1 PLAYER
    .addr text_1_player              ; CPU address $b2e1 - 1 PLAYER
    .addr text_2_players             ; CPU address $b2ec - 2 PLAYERS
    .addr text_play_select           ; CPU address $b2d3 - PLAY SELECT
    .addr intro_background_palette2  ; CPU address $b3b4 - These are the intro screen palettes and intro palettes for Bill and Lance (players)
    .addr text_jungle                ; CPU address $b356 - JUNGLE
    .addr transition_screen_palettes ; CPU address $b333 - These are the intro screen palettes and intro palettes for Bill and Lance (players)
    .addr text_rest                  ; CPU address $b2f8 - REST
    .addr text_rest2                 ; CPU address $b302 - REST
    .addr text_hi                    ; CPU address $b30c - HI
    .addr text_1p                    ; CPU address $b319 - 1P
    .addr text_2p                    ; CPU address $b326 - 2P
    .addr text_stage                 ; CPU address $b294 - STAGE
    .addr text_game_over             ; CPU address $b29e - GAME OVER
    .addr text_continue              ; CPU address $b2c2 - CONTINUE
    .addr text_game_over2            ; CPU address $b2aa - GAME OVER
    .addr text_game_over3            ; CPU address $b2b6 - GAME OVER
    .addr text_jungle                ; CPU address $b356 - JUNGLE
    .addr text_base1                 ; CPU address $b360 - BASE1
    .addr text_waterfall             ; CPU address $b36a - WATERFALL
    .addr text_base2                 ; CPU address $b376 - BASE2
    .addr text_snow_field            ; CPU address $b380 - SNOW FIELD
    .addr text_energy_zone           ; CPU address $b38d - ENERGY ZONE
    .addr text_hangar                ; CPU address $b39b - HANGAR
    .addr text_alien_lair            ; CPU address $b3a5 - ALIEN'S LAIR

; first two bytes are PPU address, followed by text
; $fe is the end of text string
; the two bytes after $fd specify the PPU address
; "STAGE" text
text_stage:
    .byte $22,$0c
    .byte $53,$54,$41,$47,$45,$00,$00,$fe

; "GAME OVER" text
text_game_over:
.ifdef Probotector
    .byte $22,$0a
.else
    .byte $22,$2a
.endif
    .byte $47,$41,$4d,$45,$00,$4f,$56,$45,$52,$fe

; "GAME OVER" text
text_game_over2:
    .byte $20,$c2
    .byte $47,$41,$4d,$45,$00,$4f,$56,$45,$52,$fe

; "GAME OVER" text
text_game_over3:
    .byte $20,$d2
    .byte $47,$41,$4d,$45,$00,$4f,$56,$45,$52,$fe

; "CONTINUE" text
text_continue:
.ifdef Probotector
    .byte $22,$6c
.else
    .byte $22,$8c
.endif
    .byte $43,$4f,$4e,$54,$49,$4e,$55,$45,$fd

.ifdef Probotector
    .byte $22,$ac  ; change to PPU address $22ac and read next text (text_end)
.else
    .byte $22,$cc  ; change to PPU address $22ac and read next text (text_end)
.endif

; "END" text, written when writing previous text text_continue
text_end:
    .byte $45,$4e,$44,$fe

; "PLAY SELECT" text
text_play_select:
    .byte $22,$8a
    .byte $50,$4c,$41,$59,$00,$53,$45,$4c,$45,$43,$54,$fe

; "1 PLAYER" text
text_1_player:
.ifdef Probotector
    .byte $22,$6d
.else
    .byte $22,$87
.endif
    .byte $31,$00,$50,$4c,$41,$59,$45,$52,$fe

; "2 PLAYERS" text
text_2_players:
.ifdef Probotector
    .byte $22,$ad
.else
    .byte $22,$c7
.endif
    .byte $32,$00,$50,$4c,$41,$59,$45,$52,$53,$fe

; "REST" text (PPU address $20c2)
text_rest:
    .byte $20,$c2,$52,$45,$53,$54,$00,$00,$00,$fe

; "REST" text (PPU address $20d2)
text_rest2:
    .byte $20,$d2,$52,$45,$53,$54,$00,$00,$00,$fe

; "HI" text
text_hi:
    .byte $21,$2a,$48,$49,$00,$00,$00,$00,$00,$00,$00,$00,$fe

; "1P" text
text_1p:
    .byte $20,$82,$31,$50,$00,$00,$00,$00,$00,$00,$00,$00,$fe

; "2P" text
text_2p:
    .byte $20,$92,$32,$50,$00,$00,$00,$00,$00,$00,$00,$00,$fe

; background palette data for use with graphic_data_02 nametable
; palettes for intro screen, and screen showing level name and high score (#$12 bytes)
; when reading this label, reads continue through intro_sprite_palettes until #$fe
; CPU address $b333
; PPU address $3f00 (start of palette data)
transition_screen_palettes:
.ifdef Probotector
    .byte $3f,$00                                                     ; PPU address $3f00 - palette address start
    .byte COLOR_BLACK_0f                                              ; universal background color
    .byte COLOR_LT_GRAY_10    ,COLOR_LT_ORANGE_27,COLOR_MED_RED_16    ; background palette 0
    .byte $0f
    .byte COLOR_PALE_VIOLET_32,COLOR_LT_VIOLET_22,COLOR_MED_VIOLET_12 ; background palette 1
    .byte $0f
    .byte COLOR_DARK_VIOLET_02,COLOR_LT_VIOLET_22,COLOR_MED_VIOLET_12 ; background palette 2
    .byte $0f
    .byte COLOR_MED_RED_16    ,COLOR_BLACK_0f    ,COLOR_BLACK_0f      ; background palette 3 (red, black, black)
.else
    .byte $3f,$00                                                     ; PPU address $3f00 - palette address start
    .byte COLOR_BLACK_0f                                              ; universal background color
    .byte COLOR_LT_GRAY_10,COLOR_LT_OLIVE_28,COLOR_MED_RED_16         ; background palette 0
    .byte $0f
    .byte COLOR_WHITE_30  ,COLOR_LT_GRAY_10 ,COLOR_MED_PINK_15        ; background palette 1
    .byte $0f
    .byte COLOR_LT_GRAY_10,COLOR_LT_OLIVE_28,COLOR_PALE_OLIVE_38      ; background palette 2
    .byte $0f
    .byte COLOR_BLACK_0f  ,COLOR_BLACK_0f   ,COLOR_BLACK_0f           ; background palette 3 (black, black, black)
.endif

; sprite palettes for intro guys (#$11 bytes)
; loaded along with transition_screen_palettes
intro_sprite_palettes:
    .byte $0f
.ifdef Probotector
    .byte COLOR_WHITE_20,COLOR_LT_ORANGE_27 ,COLOR_MED_RED_16      ; sprite palette 0
.else
    .byte COLOR_WHITE_30,COLOR_LT_GRAY_10,COLOR_DARK_GRAY_00       ; sprite palette 0
.endif
    .byte $0f
    .byte COLOR_WHITE_30,COLOR_PALE_OLIVE_38,COLOR_LT_OLIVE_28     ; sprite palette 1
    .byte $0f
    .byte COLOR_LT_TEAL_2c,COLOR_MED_TEAL_1c,COLOR_DARK_TEAL_0c    ; sprite palette 2
    .byte $0f
    .byte COLOR_DARK_GRAY_00,COLOR_DARK_GRAY_00,COLOR_DARK_GRAY_00 ; sprite palette 3
    .byte $fe                                                      ; end of palette data signal

; "JUNGLE" text
text_jungle:
    .byte $22,$4b,$00,$4a,$55,$4e,$47,$4c,$45,$fe

; "BASE1" text
text_base1:
    .byte $22,$4b,$00,$00,$42,$41,$53,$45,$31,$fe

; "WATERFALL" text
text_waterfall:
    .byte $22,$4b,$57,$41,$54,$45,$52,$46,$41,$4c,$4c,$fe

; "BASE2" text
text_base2:
    .byte $22,$4b,$00,$00,$42,$41,$53,$45,$32,$fe

; "SNOW FIELD" text
text_snow_field:
    .byte $22,$4b,$53,$4e,$4f,$57,$00,$46,$49,$45,$4c,$44,$fe

; "ENERGY ZONE" text
text_energy_zone:
    .byte $22,$4b,$45,$4e,$45,$52,$47,$59,$00,$5a,$4f,$4e,$45,$fe

; "HANGAR" text
text_hangar:
    .byte $22,$4b,$00,$48,$41,$4e,$47,$41,$52,$fe

; "ALIEN'S LAIR" text
text_alien_lair:
    .byte $22,$4b,$41,$4c,$49,$45,$4e,$f7,$53,$00,$4c,$41,$49,$52,$fe

; background palettes for intro screen (when Bill and Lance appear) (#$13 bytes)
; PPU address $3f00
intro_background_palette2:
.ifdef Probotector
    .byte $3f,$00                                                        ; PPU address $3f00
    .byte COLOR_BLACK_0f                                                 ; universal background color
    .byte COLOR_LT_GRAY_10,COLOR_LT_ORANGE_27,COLOR_MED_RED_16           ; background palette 0
    .byte $0f
    .byte COLOR_PALE_VIOLET_32  ,COLOR_LT_VIOLET_22 ,COLOR_MED_VIOLET_12 ; background palette 1
    .byte $0f
    .byte COLOR_DARK_VIOLET_02,COLOR_LT_VIOLET_22,COLOR_MED_VIOLET_12    ; background palette 2
    .byte $0f
    .byte COLOR_MED_RED_16  ,COLOR_BLACK_0f,COLOR_BLACK_0f               ; background palette 3
    .byte $fe
.else
    .byte $3f,$00                                                        ; PPU address $3f00
    .byte COLOR_BLACK_0f                                                 ; universal background color
    .byte COLOR_LT_GRAY_10,COLOR_LT_OLIVE_28,COLOR_MED_RED_16            ; background palette 0
    .byte $0f
    .byte COLOR_WHITE_30  ,COLOR_LT_GRAY_10 ,COLOR_MED_PINK_15           ; background palette 1
    .byte $0f
    .byte COLOR_LT_GRAY_10,COLOR_LT_OLIVE_28,COLOR_PALE_OLIVE_38         ; background palette 2
    .byte $0f
    .byte COLOR_WHITE_30  ,COLOR_PALE_RED_36,COLOR_LT_RED_26             ; background palette 3
    .byte $fe
.endif

; check to see if the player is trying to fire a bullet (B button pressed)
; ensure player in valid state to fire a bullet, e.g. not being electrocuted
check_player_fire:
    lda PLAYER_HIDDEN,x        ; 0 - visible; #$01/#$ff = invisible (any non-zero)
    ora ELECTROCUTED_TIMER,x   ; counter for electrocution
    bne check_player_fire_exit ; exit if being electrocuted or $ba,x is set
    lda PLAYER_WATER_STATE,x   ; see if player in water
    beq @player_shoot_test
    lda PLAYER_AIM_DIR,x       ; can't shoot downward if in water
    cmp #$03
    bcc @player_shoot_test     ; continue if < 3 (up, up-right, and right)
    cmp #$07
    bcc check_player_fire_exit ; exit if less than 7 and greater than 3 (down-right, down, down-left)

@player_shoot_test:
    lda P1_CURRENT_WEAPON,x ; current player's weapon
    and #$0f                ; strip to weapon type without rapid fire bit
    tay                     ; run_create_bullet_routine looks in y for the weapon type
    lda #$40                ; a = #$40
    cpy #$01                ; see if current weapon is M weapon
    beq @m_or_l_weapon
    cpy #$04                ; see if current weapon is L weapon
    bne @weapon

; M and L weapons will run_create_bullet_routine twice if first iteration returned #$00
@m_or_l_weapon:
    and CONTROLLER_STATE,x        ; see if B button pressed (#$40)
    bne run_create_bullet_routine ; fire weapon if B button pressed
    beq @continue                 ; no B button pressed, continue

@weapon:
    and CONTROLLER_STATE_DIFF,x   ; see if B button pressed (#$40)
    bne run_create_bullet_routine ; fire weapon if B button pressed

; B button not pressed, strip PLAYER_M_WEAPON_FIRE_TIME to low nibble, then
; increment PLAYER_M_WEAPON_FIRE_TIME up to #$07 when fire button isn't pressed
@continue:
    lda PLAYER_M_WEAPON_FIRE_TIME,x ; load how many frames the fire button has been pressed
    and #$0f                        ; keep only low nibble
    cmp #$07                        ; compare to #$07
    bcs @set_and_exit               ; branch if >= #$07
    adc #$01

@set_and_exit:
    sta PLAYER_M_WEAPON_FIRE_TIME,x

check_player_fire_exit:
    rts

; creates the appropriate bullet when firing weapon
run_create_bullet_routine:
    stx $11                        ; store current player index into $11
    jsr @run_create_bullet_routine
    ldx $11                        ; restore current player index to x
    rts

; y is the current weapon type (low byte of P1_CURRENT_WEAPON)
; x and $11 are current player
; run the appropriate weapon routine based on what weapon the player has
@run_create_bullet_routine:
    sty $08                  ; store weapon type (Standard, M, F, S, L) in $08
    lda P1_CURRENT_WEAPON,x  ; current player's weapon
    lsr
    lsr
    lsr
    lsr                      ; ignore low nibble (weapon type)
    and #$01                 ; keep bit 4 of P1_CURRENT_WEAPON (rapid fire flag)
    sta $09                  ; store weapon rapid fire flag in $09
    lda PLAYER_AIM_DIR,x     ; which direction the player is aiming/looking
    ldy PLAYER_JUMP_STATUS,x ; load player jump status
    sty $0a                  ; store jump status in $0a
    beq @fire_weapon_routine ; branch if PLAYER_JUMP_STATUS is #$00 (not jumping)
    cmp #$04                 ; see if shooting down facing right while jumping
    beq @continue            ; branch if shooting down
    cmp #$05                 ; branch if shooting down facing left while jumping
    bne @fire_weapon_routine ; branch if not shooting down and to the left

@continue:
    lda #$0b ; a = #$0b

; runs the appropriate weapon routine, based on current weapon type (Standard, M, F, S, L)
@fire_weapon_routine:
    sta $0b                 ; store PLAYER_AIM_DIR in $0b
    lda SPRITE_X_POS,x      ; load player x position on screen
    sta $0c                 ; store player x position on screen
    lda SPRITE_Y_POS,x      ; load player y position on screen
    sta $0d                 ; store player y position on screen
    lda $08                 ; load weapon type (Standard, M, F, S, L)
    ldy LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    bmi fire_weapon_routine ; branch if base/indoor boss level screen
    beq fire_weapon_routine ; branch for outdoor level
    clc                     ; clear carry in preparation for addition
    adc #$05                ; indoor/base level add #$05 to weapon routine to run

; runs weapon routine at offset A into fire_weapon_routine_ptr_tbl
fire_weapon_routine:
    jsr run_routine_from_tbl_below ; run routine a in the following table (fire_weapon_routine_ptr_tbl)

; pointer table for weapon routines (a * 2 = 14 bytes)
fire_weapon_routine_ptr_tbl:
    .addr fire_weapon_routine_standard        ; Standard Weapon CPU address $b455
    .addr fire_weapon_routine_m               ; M Weapon CPU address $b46e
    .addr fire_weapon_routine_f               ; F Weapon CPU address $b4ae
    .addr fire_weapon_routine_s               ; S Weapon CPU address $b4ca
    .addr fire_weapon_routine_l               ; L Weapon CPU address $b508
    .addr fire_weapon_routine_indoor_standard ; indoor/base level Standard Weapon CPU address $b460
    .addr fire_weapon_routine_indoor_m        ; indoor/base level M Weapon address $b476
    .addr fire_weapon_routine_indoor_f        ; indoor/base level F Weapon address $b4b9
    .addr fire_weapon_routine_s               ; indoor/base level S Weapon address $b4ca
    .addr fire_weapon_routine_l               ; indoor/base level L Weapon address $b508

; standard weapon
fire_weapon_routine_standard:
    jsr create_bullet_max_04 ; create bullet if possible
    bne weapon_routine_exit  ; exit if no bullet slot found

init_bullet_pos_and_velocity:
    jsr init_bullet_sprite_pos ; set initial bullet sprite position
    jmp set_bullet_velocity    ; set the bullet x and y velocities

; indoor/base level Standard Weapon
fire_weapon_routine_indoor_standard:
    jsr create_bullet_max_04 ; create bullet if possible
    bne weapon_routine_exit  ; exit if no bullet slot found

init_indoor_bullet_pos_and_vel:
    jsr set_indoor_bullet_pos_and_slot
    jsr set_indoor_bullet_vel
    jmp set_indoor_bullet_delay

; m weapon
fire_weapon_routine_m:
    jsr gen_m_bullet_if_delay_met    ; possibly generate a bullet based on PLAYER_M_WEAPON_FIRE_TIME
    beq init_bullet_pos_and_velocity ; set initial bullet position and velocity if bullet was created

gen_m_bullet_exit:
    lda #$01 ; a = #$01

weapon_routine_exit:
    rts

; indoor/base level M Weapon
fire_weapon_routine_indoor_m:
    jsr gen_m_bullet_if_delay_met      ; possibly generate a bullet based on PLAYER_M_WEAPON_FIRE_TIME
    beq init_indoor_bullet_pos_and_vel ; set initial bullet position and velocity if bullet was created
    rts

; indoor and outdoor m weapon
; checks PLAYER_M_WEAPON_FIRE_TIME to determine if a bullet should be generated
; updates PLAYER_M_WEAPON_FIRE_TIME based on logic
gen_m_bullet_if_delay_met:
    inc PLAYER_M_WEAPON_FIRE_TIME,x ; increment bullet generation delay
    lda PLAYER_M_WEAPON_FIRE_TIME,x ; load its current value
    cmp #$60                        ; compare to #$60 (burst fire time limit)
    ldy #$08                        ; set y = #$08 (bullet generation delay while holding B button)
    bcc @continue                   ; branch if less than #$06 bullets have fired in a row while holding B
    ldy #$0f                        ; set y = #$0f (prevents bullet from generating)

@continue:
    sty $0f                         ; store either #$08 or #$0f in $0f
    and #$0f                        ; low nibble of of burst fire time
    cmp $0f                         ; compare to burst fire time time
    bcc gen_m_bullet_exit           ; exit if less than #$08 (delay between bullets hasn't elapsed)
                                    ; also exit when low nibble less than #$0f when burst time >= #$60
                                    ; e.g. must wait a full #$0f frames before next bullet will generate
    lda PLAYER_M_WEAPON_FIRE_TIME,x ; re-load full value of PLAYER_M_WEAPON_FIRE_TIME
    adc #$0f                        ; add #$0f to burst fire time to see if the full #$0f frames have elapsed during burst fire 'cool down'.
                                    ; !(OBS) could have just added #$01 since can't get here unless low nibble #$0f
    cmp #$70                        ; see if #$10 frame delay has elapsed and burst fire time is now #$70
    bcc @gen_m_bullet               ; continue if not elapsed
    lda #$00                        ; reset burst fire time back to #$00, skipped bullet delay has elapsed

; generate bullet for M weapon if slot available
@gen_m_bullet:
    and #$f0                        ; keep high nibble
    sta PLAYER_M_WEAPON_FIRE_TIME,x ; set new time value with only high nibble set (or #$00)
    lda #$05                        ; a = #$05 (up to #$06 bullets on screen for m weapon)
    jsr create_bullet_max_a_p2_0a   ; create bullet if possible, p2 starting at slot #$0a
    bne @no_bullet_created          ; if #$06 bullets on screen, branch
    rts

@no_bullet_created:
    ldy $11                         ; load player index
    lda #$07                        ; set a = #$07, clears zero flag
                                    ; this will allow the bullet to be reattempted to be created the next frame
    sta PLAYER_M_WEAPON_FIRE_TIME,y ; reset $ac back down to #$07
    rts

; f weapon (outdoor)
fire_weapon_routine_f:
    jsr create_bullet_max_04         ; create bullet if possible
    bne weapon_routine_exit          ; exit if no bullet slot found
    jsr init_bullet_pos_and_velocity ; set initial bullet position and velocity
    jmp f_bullet_outdoor_init_center ; initialize the center x and y point that is swirled around

; indoor/base level F Weapon
fire_weapon_routine_indoor_f:
    jsr create_bullet_max_04           ; create bullet if possible
    bne weapon_routine_exit            ; exit if no bullet slot found
    jsr init_indoor_bullet_pos_and_vel
    jsr indoor_f_weapon_set_fs_x
    lda $09                            ; rapid fire flag
    sta PLAYER_BULLET_F_RAPID,x        ; store in memory specifically for F weapon
    rts

; S (Spray Gun/Spread Gun) weapon routine
fire_weapon_routine_s:
    lda #$00 ; a = #$00
    sta $17

; loop through creating up to #$05 bullets in a spray pattern
@loop:
    lda #$09                      ; a = #$09 (up to #$0a bullets total for s weapon)
    ldx #$06                      ; set p2 bullet slot starting offset at #$06
    jsr create_bullet_max_a       ; create bullet if slot available
    bne weapon_s_l_exit           ; exit if no bullet was generated
    jsr init_s_bullet_pos_and_vel
    inc $17                       ; increment number of bullets created in current shot
    lda $17
    cmp #$05                      ; max bullets per shot for s weapon
    bcc @loop                     ; loop if more bullets to create for current shot

weapon_s_l_exit:
    rts

init_s_bullet_pos_and_vel:
    lda $17                            ; current bullet counter within shot
    sta PLAYER_BULLET_S_BULLET_NUM,x
    ldy LEVEL_LOCATION_TYPE            ; 0 = outdoor; 1 = indoor
    bmi @outdoor_or_indoor_boss        ; branch if indoor boss
    beq @outdoor_or_indoor_boss        ; branch if outdoor
    jsr set_indoor_bullet_pos_and_slot ; indoor/base, set bullet position and slot
    jsr set_indoor_bullet_vel
    lda PLAYER_BULLET_X_POS,x          ; load bullet's x position
    sta PLAYER_BULLET_FS_X,x
    lda $09                            ; rapid fire flag
    sta PLAYER_BULLET_S_RAPID,x        ; store in memory specifically for S weapon
    jmp set_indoor_bullet_delay

@outdoor_or_indoor_boss:
    jsr init_bullet_sprite_pos          ; set initial bullet sprite position
    jmp s_weapon_init_bullet_velocities

; l weapon
fire_weapon_routine_l:
    lda #$01      ; a = #$01
    sta $09       ; set rapid fire flag
    ldy #$0a      ; y = #$0a
    txa
    bne @continue ; branch if player 2
    ldy #$00      ; y = #$00

@continue:
    sty $10
    lda #$03                    ; a = #$03
    sta $00                     ; set number of bullet slots to #$03
    lda CONTROLLER_STATE_DIFF,x ; controller 1/2 buttons pressed
    and #$40                    ; keep bits .x.. .... (b button)
    bne @create_3_lasers        ; branch if b button pressed

@set_slot_loop:
    lda PLAYER_BULLET_SLOT,y
    bne weapon_s_l_exit      ; exit if slot already populated
    iny
    dec $00
    bpl @set_slot_loop

@create_3_lasers:
    lda #$03 ; a = #$03 (number of laser "bullets")
    sta $00

@create_bullet_loop:
    ldx $10
    jsr create_enemy_bullet
    jsr @l_bullet_created
    inc $10
    dec $00
    bpl @create_bullet_loop
    rts

; $00 is the bullet number (3 down to 0)
@l_bullet_created:
    ldy $00
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    beq @init_l_bullet      ; branch for outdoor level
    bmi @init_l_bullet      ; branch for indoor boss screen
    iny
    iny
    iny
    iny

@init_l_bullet:
    lda laser_bullet_delay_tbl,y
    sta PLAYER_BULLET_TIMER,x
    lda LEVEL_LOCATION_TYPE            ; 0 = outdoor; 1 = indoor
    beq @init_bullet_pos_and_velocity  ; branch for outdoor level
    bmi @init_bullet_pos_and_velocity  ; branch for indoor boss screen
    jsr set_indoor_bullet_pos_and_slot
    jmp set_indoor_bullet_vel

@init_bullet_pos_and_velocity:
    jmp init_bullet_pos_and_velocity ; set initial bullet position and velocity

; table for laser bullet delays (#$8 bytes)
laser_bullet_delay_tbl:
    .byte $0a,$07,$04,$01 ; outdoor and indoor boss
    .byte $07,$05,$03,$01 ; indoor

; creates a bullet up to #$04 bullets on the screen
create_bullet_max_04:
    lda #$03 ; a standard weapon can fire #$04 bullets at a time
             ; @find_bullet_slot creates a + 1 number of bullets

; creates a bullet up to the amount specified in accumulator + one
; sets player 2 bullet offset to start at #$0a
create_bullet_max_a_p2_0a:
    ldx #$0a ; set player 2 bullet slot start offset

; creates a bullet up to the amount specified in accumulator + one
create_bullet_max_a:
    sta $00               ; store max bullets in $00
    ldy $11               ; load current player being evaluated
    bne @find_bullet_slot ; branch if player 2 and start at slot specified in x register
    ldx #$00              ; player 1, start at #$00

@find_bullet_slot:
    lda PLAYER_BULLET_SLOT,x ; get value of current bullet slot
    beq create_enemy_bullet  ; create bullet if slot is empty
    inx                      ; slot is already occupied, move to next available slot
    dec $00                  ; decrement max bullets counter
    bpl @find_bullet_slot    ; if still slots to search, continue
    rts                      ; no bullet slots found, exit

create_enemy_bullet:
    ldy $11                             ; load player index (0-1)
    lda #$0f                            ; a = #$0f
    sta PLAYER_RECOIL_TIMER,y           ; set recoil timer to #$0f
    jsr clear_bullet_values             ; initialize bullet memory values to #$00
    tya
    sta PLAYER_BULLET_OWNER,x           ; bullet owner (#$00 for p1, #$01 for p2)
    lda $08                             ; load weapon type (Standard, M, F, S, L) in $08
    clc                                 ; clear carry in preparation for addition
    adc #$01                            ; add #$01 to weapon type
    sta PLAYER_BULLET_SLOT,x            ; store weapon type + #$01 in bullet slot
    tay
    lda weapon_sound_tbl-1,y            ; table for weapon sounds (actually one byte off from table data, and y starts at #$01)
    jsr play_sound                      ; play sound for bullet firing
    lda weapon_bullet_sprite_code_tbl,y ; table for weapon bullet sprite codes
    sta PLAYER_BULLET_SPRITE_CODE,x     ; player bullet tile code
    lda $0b                             ; load player aim direction PLAYER_AIM_DIR from @fire_weapon_routine
    sta PLAYER_BULLET_AIM_DIR,x         ; set the bullet direction based on player direction when firing
    lda #$00                            ; a = #$00
    rts

; table for weapon sounds (#$4 bytes)
; sound_0a, sound_0c, sound_10, sound_12
; next table byte 0 is sound_0e for L
weapon_sound_tbl:
    .byte $0a,$0c,$10,$12

; table for weapon bullet types (#$5 bytes)
; subtract 2 to get sprite code
; * #$0e - belongs to previous table L weapon sound (sound_0e)
;        - not used for sprites, as read offset for this table is at least #$01
; * #$1f - sprite_1f (M Bullet)
; * #$22 - sprite_22 (F bullet)
; * #$00 - for l bullet, but not used, overwritten with #$24 from l_bullet_sprite_code_tbl
weapon_bullet_sprite_code_tbl:
    .byte $0e,$1e,$1f,$22,$1f,$00

set_indoor_bullet_delay:
    ldy #$2a      ; default y = #$2a
    lda $08       ; load weapon type (Standard, M, F, S, L) in $08
    cmp #$04      ; compare to #$04 (laser)
    beq @continue ; branch if laser
    lda $09       ; not laser, check rapid fire flag
    beq @continue ; branch if rapid fire is not set
    ldy #$15      ; y = #$15

@continue:
    tya
    sta PLAYER_BULLET_TIMER,x
    rts

; set initial bullet sprite position
init_bullet_sprite_pos:
    ldy #$00                ; y = #$00
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    beq @handle_outdoor     ; start at offset #$00 for outdoor levels
    ldy #$04                ; indoor level, increase offset by #$04 (#$02 entries)

@handle_outdoor:
    lda $0a       ; load player jump status
    beq @continue ; branch if player isn't jumping, don't adjust offset
    iny           ; player is jumping, increment offset into bullet_initial_pos_ptr_tbl by an additional #$02 bytes
    iny

@continue:
    lda bullet_initial_pos_ptr_tbl,y
    sta $0e
    lda bullet_initial_pos_ptr_tbl+1,y
    sta $0f
    lda $0b                            ; load PLAYER_AIM_DIR
    asl                                ; double entry
    tay                                ; set as offset into bullet_dir_XX
    lda ($0e),y                        ; load bullet initial offset based on player aim direction
    clc                                ; clear carry in preparation for addition
    adc $0c                            ; add offset to player x position on screen
    sta PLAYER_BULLET_X_POS,x
    iny
    lda ($0e),y
    clc                                ; clear carry in preparation for addition
    adc $0d                            ; add offset to player y position on screen
    sta PLAYER_BULLET_Y_POS,x
    rts

; pointer table for initial bullet offsets (4 * 2 = 8 bytes)
bullet_initial_pos_ptr_tbl:
    .addr bullet_initial_pos_00 ; outdoor CPU address $b5fa
    .addr bullet_initial_pos_01 ; outdoor - jumping CPU address $b60e
    .addr bullet_initial_pos_02 ; indoor CPU address $b626
    .addr bullet_initial_pos_03 ; indoor jumping CPU address $b63a

; initial bullet offset - outdoor - on ground (#$14 bytes)
; byte #$01 - x offset from player position
; byte #$02 - y offset from player position
bullet_initial_pos_00:
.ifdef Probotector
    .byte $03,$e5  ;  $05 -1b Up
    .byte $0d,$f0  ;  $0d -10 Up-Right
    .byte $07,$fb  ;  $10 -05 Right
    .byte $0a,$03  ;  $0d  06 Down-Right
    .byte $10,$09  ;  $10  09 Prone Facing Right
    .byte $f0,$09  ; -$10  09 Prone Facing Left
    .byte $f6,$03  ; -$0d  06 Down-Left
    .byte $f3,$fb  ; -$10 -05 Left
    .byte $f3,$f0  ; -$0d -10 Up-Left
    .byte $fd,$e5  ; -$05 -1b Down (impossible)
.else
    .byte $05,$e5  ;  $05 -1b Up
    .byte $0d,$f0  ;  $0d -10 Up-Right
    .byte $10,$fb  ;  $10 -05 Right
    .byte $0d,$06  ;  $0d  06 Down-Right
    .byte $10,$09  ;  $10  09 Prone Facing Right
    .byte $f0,$09  ; -$10  09 Prone Facing Left
    .byte $f3,$06  ; -$0d  06 Down-Left
    .byte $f0,$fb  ; -$10 -05 Left
    .byte $f3,$f0  ; -$0d -10 Up-Left
    .byte $fb,$e5  ; -$05 -1b Down (impossible)
.endif

; initial bullet offset - outdoor - jumping (#$18 bytes)
; byte #$01 - x offset from player position
; byte #$02 - y offset from player position
bullet_initial_pos_01:
    .byte $00,$f0
    .byte $0f,$f1
    .byte $10,$00
    .byte $0f,$0f
    .byte $00,$10
    .byte $00,$10
    .byte $f1,$0f
    .byte $f0,$00
    .byte $f1,$f1
    .byte $00,$f0
    .byte $00,$10
    .byte $00,$10

; initial bullet offsets - indoor - on ground (#$14 bytes)
; byte #$01 - x offset from player position
; byte #$02 - y offset from player position
bullet_initial_pos_02:
    .byte $ff,$e8
    .byte $0f,$f0
    .byte $10,$fa
    .byte $0f,$08
    .byte $10,$0b
    .byte $f0,$0b
    .byte $f1,$08
    .byte $f0,$fa
    .byte $f1,$f0
    .byte $ff,$e8

; initial bullet offsets - indoor - jumping (#$18 bytes)
; byte #$01 - x offset from player position
; byte #$02 - y offset from player position
bullet_initial_pos_03:
    .byte $00,$f0
    .byte $0f,$f1
    .byte $10,$00
    .byte $0f,$0f
    .byte $00,$10
    .byte $00,$10
    .byte $f1,$0f
    .byte $f0,$00
    .byte $f1,$f1
    .byte $00,$f0
    .byte $00,$f0
    .byte $00,$f0

set_indoor_bullet_pos_and_slot:
    lda #$00              ; a = #$00
    sta $0e               ; set bullet x position offset to #$00
    ldy #$00              ; set bullet y offset position to #$00
    lda $0a               ; load jump status
    bne @set_pos_and_slot ; branch if jumping
    ldy #$f4              ; start with assuming player is crouching
                          ; set bullet y offset position to #$f4
    dec $0e               ; set bullet x position offset to #$ff
    lda $0b               ; load player aim direction
    cmp #$04              ; see if aiming down facing right
    beq @set_pos_and_slot ; branch if aiming down facing right
    cmp #$05              ; see if aiming dow facing left
    beq @set_pos_and_slot ; branch if aiming down facing left
    ldy #$e8              ; set bullet y position offset to #$e8
    bcs @set_pos_and_slot
    lda #$01              ; a = #$01
    sta $0e               ; set bullet x position offset to #$01

; y is bullet y offset from player
; a is bullet x offset from player
@set_pos_and_slot:
    tya
    clc                       ; clear carry in preparation for addition
    adc $0d                   ; add offset to player y position
    sta PLAYER_BULLET_Y_POS,x ; store bullet y position
    lda $0e                   ; load bullet x position offset
    clc                       ; clear carry in preparation for addition
    adc $0c                   ; add bullet offset to player x position
    sta PLAYER_BULLET_X_POS,x ; store bullet x position
    cpy #$f4                  ; compare bullet y offset to #$f4
    bne @continue             ; branch if not crouching while shooting
    lda PLAYER_BULLET_SLOT,x  ; player is crouching (pressing down while shooting)
    ora #$80                  ; set bits x... ....
    sta PLAYER_BULLET_SLOT,x  ; mark bullet as special ?

@continue:
    lda $0a
    beq @exit
    lda PLAYER_BULLET_Y_POS,x
    cmp #$98
    bcc @exit
    lda #$98                  ; a = #$98
    sta PLAYER_BULLET_Y_POS,x

@exit:
    rts

; not used for s weapon
set_bullet_velocity:
    ldy #$04              ; y = #$04
    lda $08               ; load weapon type (Standard, M, F, S, L) in $08
    cmp #$02              ; 02 = f weapon
    beq @check_rapid_flag ; branch if f weapon
    ldy #$02              ; y = #$02
    cmp #$04              ; 04 = l weapon
    beq @check_rapid_flag
    ldy #$00              ; y = #$00

@check_rapid_flag:
    lda $09       ; rapid fire flag
    beq @continue
    iny           ; rapid fire is set for weapon, increment bullet_velocity_ptr_tbl read offset

@continue:
    tya
    asl                             ; double offset since each entry is #$02 bytes
    tay
    lda bullet_velocity_ptr_tbl,y   ; load appropriate table of velocities low byte
    sta $01
    lda bullet_velocity_ptr_tbl+1,y ; load appropriate table of velocities high byte
    sta $02
    lda $0b                         ; load player aim direction
    asl                             ; each entry is #$04 bytes
    asl                             ; double twice to get correct offset
    tay
    lda ($01),y                     ; load x velocity fast value
    sta PLAYER_BULLET_X_VEL_FAST,x  ; store x velocity fast value
    iny                             ; increment velocity table read offset
    lda ($01),y                     ; load x fractional velocity value
    sta PLAYER_BULLET_X_VEL_FRACT,x ; store x fractional velocity value
    iny                             ; increment velocity table read offset
    lda ($01),y                     ; load y velocity fast value
    sta PLAYER_BULLET_Y_VEL_FAST,x  ; store y velocity fast value
    iny                             ; increment velocity table read offset
    lda ($01),y                     ; load y fractional velocity byte
    sta PLAYER_BULLET_Y_VEL_FRACT,x ; store y fractional velocity byte
    rts

; pointer table for player bullet velocity (6 * 2 = c bytes)
bullet_velocity_ptr_tbl:
    .addr bullet_velocity_normal  ; Standard, M - Normal CPU address $b6e9
    .addr bullet_velocity_rapid   ; Standard, M - Rapid Fire CPU address $b719
    .addr bullet_velocity_rapid   ; L Weapon - Normal CPU address $b719
    .addr bullet_velocity_rapid   ; L Weapon - Rapid Fire CPU address $b719
    .addr bullet_velocity_f       ; F Weapon - Normal CPU address $b779
    .addr bullet_velocity_f_rapid ; F Weapon - Rapid Fire CPU address $b749

; player bullet velocity - standard, and m weapon - normal (#$30 bytes)
; #$4 bytes per angle (#$2 bytes for x, #$2 bytes for y)
; #$c velocities in table, but only #$0a are accessible due to possible PLAYER_AIM_DIR values !(WHY?)
; all values are calculated assuming a velocity of #$300 (768 decimal)
; format: XX XX YY YY
; ex:
; 00 00 - X Velocity - (high byte, low byte) - #$0000 = 0
; FD 00 - Y Velocity - (high byte, low byte) - #$fd00 = -768
; for angled shots use sin(45 deg) = 0.707
; 768 * 0.707 = 543 -> #$21f
bullet_velocity_normal:
    .byte $00,$00,$fd,$00 ;  #$00  , -#$300 - up facing right
    .byte $02,$1f,$fd,$e1 ;  #$21f , -#$21f - up right
    .byte $03,$00,$00,$00 ;  #$300 ,  #$000 - right
    .byte $02,$1f,$02,$1f ;  #$21f ,  #$21f - right down
    .byte $03,$00,$00,$00 ;  #$300 ,  #$000 - down facing right
    .byte $fd,$00,$00,$00 ; -#$300 ,  #$000 - down facing left
    .byte $fd,$e1,$02,$1f ; -#$21f ,  #$21f - down left
    .byte $fd,$00,$00,$00 ; -#$300 ,  #$000 - left
    .byte $fd,$e1,$fd,$e1 ; -#$21f , -#$21f - up left
    .byte $00,$00,$fd,$00 ;  #$000 , -#$300 - up facing left
    .byte $00,$00,$fd,$00 ;  #$000 , -#$300 - unused
    .byte $00,$00,$03,$00 ;  #$000 ,  #$300 - unused

; player bullet velocity - standard, and m weapon - rapid fire (#$30 bytes)
; l weapon uses this table for both normal and rapid fire
; #$4 bytes per angle (#$2 bytes for x, #$2 bytes for y)
; #$c velocities in table, but only #$0a are accessible due to possible PLAYER_AIM_DIR values !(HUH)
; all values are calculated assuming a velocity of #$400 (1024 decimal)
; format: XX XX YY YY
; ex:
; 00 00 - X Velocity - (high byte, low byte) - #$0000 = 0
; FC 00 - Y Velocity - (high byte, low byte) - #$fc00 = -1024
; for angled shots use sin(45 deg) = 0.707
; 1024 * 0.707 = 724 -> #$2d4
bullet_velocity_rapid:
    .byte $00,$00,$fc,$00 ;  #$000 , -#$400 - up facing right
    .byte $02,$d4,$fd,$2c ;  #$2d4 , -#$2d4 - up right
    .byte $04,$00,$00,$00 ;  #$400 ,  #$000 - right
    .byte $02,$d4,$02,$d4 ;  #$2d4 ,  #$2d4 - right down
    .byte $04,$00,$00,$00 ;  #$400 ,  #$000 - down facing right
    .byte $fc,$00,$00,$00 ; -#$400 ,  #$000 - down facing left
    .byte $fd,$2c,$02,$d4 ; -#$2d4 ,  #$2d4 - down left
    .byte $fc,$00,$00,$00 ; -#$400 ,  #$000 - left
    .byte $fd,$2c,$fd,$2c ; -#$2d4 , -#$2d4 - up left
    .byte $00,$00,$fc,$00 ;  #$000 , -#$400 - up facing left
    .byte $00,$00,$fc,$00 ; - unused
    .byte $00,$00,$04,$00 ; - unused

; player bullet velocity - f weapon - rapid fire (#$30 bytes)
; #$4 bytes per angle (#$2 bytes for x, #$2 bytes for y)
; #$c velocities in table, but only #$0a are accessible due to possible PLAYER_AIM_DIR values !(HUH)
; all values are calculated assuming a velocity of #$200 (512 decimal)
; format: XX XX YY YY
; ex:
; 00 00 - X Velocity - (high byte, low byte) - #$0000 = 0
; FE 00 - Y Velocity - (high byte, low byte) - #$fe00 = -512
; for angled shots use sin(45 deg) = 0.707
; 512 * 0.707 = 362 -> #$16a
bullet_velocity_f_rapid:
    .byte $00,$00,$fe,$00 ;  #$000 , -#$200 ; up facing left
    .byte $01,$6a,$fe,$96 ;  #$16a , -#$16a ; up right
    .byte $02,$00,$00,$00 ;  #$200 ,  #$000 ; right
    .byte $01,$6a,$01,$6a ;  #$16a ,  #$16a ; right down
    .byte $02,$00,$00,$00 ;  #$200 ,  #$000 ; down facing right
    .byte $fe,$00,$00,$00 ; -#$200 ,  #$000 ; down facing left
    .byte $fe,$96,$01,$6a ; -#$16a ,  #$16a ; down left
    .byte $fe,$00,$00,$00 ; -#$200 ,  #$000 ; left
    .byte $fe,$96,$fe,$96 ; -#$16a , -#$16a ; up left
    .byte $00,$00,$fe,$00 ;  #$000 , -#$200 ; up facing left
    .byte $00,$00,$fe,$00 ;  #$000 , -#$200 ; unused
    .byte $00,$00,$02,$00 ;  #$000 ,  #$200 ; unused

; player bullet velocity - f weapon - normal (#$30 bytes)
; #$4 bytes per angle (#$2 bytes for x, #$2 bytes for y)
; #$c velocities in table, but only #$0a are accessible due to possible PLAYER_AIM_DIR values !(HUH)
; all values are calculated assuming a velocity of #$180 (384 decimal)
; format: XX XX YY YY
; ex:
; 00 00 - X Velocity - (high byte, low byte) - #$0000 = 0
; FE 80 - Y Velocity - (high byte, low byte) - #$fe80 = -384
; for angled shots use sin(45 deg) = 0.707
; 384 * 0.707 = 271 -> #$10f
bullet_velocity_f:
    .byte $00,$00,$fe,$80 ;  #$000 , -#$180 ; up facing left
    .byte $01,$0f,$fe,$f1 ;  #$10f , -#$10f ; up right
    .byte $01,$80,$00,$00 ;  #$180 ,  #$000 ; right
    .byte $01,$0f,$01,$0f ;  #$10f ,  #$10f ; right down
    .byte $01,$80,$00,$00 ;  #$180 ,  #$000 ; down facing right
    .byte $fe,$80,$00,$00 ; -#$180 ,  #$000 ; down facing left
    .byte $fe,$f1,$01,$0f ; -#$10f ,  #$10f ; down left
    .byte $fe,$80,$00,$00 ; -#$180 ,  #$000 ; left
    .byte $fe,$f1,$fe,$f1 ; -#$10f , -#$10f ; up left
    .byte $00,$00,$fe,$80 ;  #$000 , -#$180 ; up facing left
    .byte $00,$00,$fe,$80 ;  #$000 , -#$180 ; unused
    .byte $00,$00,$01,$80 ;  #$000 ,  #$180 ; unused

set_indoor_bullet_vel:
    lda #$00                        ; a = #$00
    sta $12                         ; specify to branch to @negate_bullet_velocities in set_vel_for_speed_vars
    lda #$40                        ; a = #$40 (bullet speed code)
    jsr @set_vel_for_speed_code     ; convert 'speed code' to fast and fractional velocities based on rapid fire flag
    lda $0f                         ; load resulting fast velocity
    sta PLAYER_BULLET_Y_VEL_FAST,x  ; set indoor bullet fast y velocity
    lda $0e                         ; load resulting fractional velocity
    sta PLAYER_BULLET_Y_VEL_FRACT,x ; set indoor bullet fractional y velocity
    lda $0c
    sec                             ; set carry flag in preparation for subtraction
    sbc #$80
    sta $12                         ; when non-negative, negate result velocities from @set_vel_for_speed_code
    bcs @set_x_vel
    eor #$ff                        ; underflow, flip all bits and add one
    adc #$01

@set_x_vel:
    jsr @set_vel_for_speed_code     ; determine fast and fractional velocity based on a and whether rapid fire is enabled
    lda $0f                         ; load resulting fast velocity
    sta PLAYER_BULLET_X_VEL_FAST,x  ; set indoor bullet fast x velocity
    lda $0e                         ; load resulting fractional velocity
    sta PLAYER_BULLET_X_VEL_FRACT,x ; set indoor bullet fractional x velocity
    rts

; input
;  * a - a sort-of speed code, this value is split into fast and fractional velocity based on rapid fire flag
; output
;  * $09 - rapid fire flag
;  * $0e - bullet x or y fractional velocity
;  * $0f - bullet x or y fast velocity
@set_vel_for_speed_code:
    sta $0f       ; set initial 'speed code'
    lda #$00      ; a = #$00
    sta $0e       ; reset fractional velocity to #$00
    ldy #$06      ; y = #$06, specifies to shift 6 bits of $0f into high bits of $0e (ror)
    lda $09       ; load rapid fire flag
    beq @continue ; continue if rapid fire not set
    dey           ; only shift #$05 bits of $0f into the high bits of $0e

@continue:
    jmp set_vel_for_speed_vars ; set fast ($0f) and fractional ($0e) velocities based on $0f and y

; f weapon (outdoor) initialization of the center x and y point that is swirled around
f_bullet_outdoor_init_center:
    lda $0b                             ; load player aim direction
    asl
    clc                                 ; clear carry in preparation for addition
    adc $0b                             ; #$02 * $0b + $0b => #$03 * $0b (each entry in f_bullet_initialization_tbl is #$03 bytes)
    tay                                 ; transfer to offset register
    lda f_bullet_initialization_tbl,y   ; load initial bullet timer value
    sta PLAYER_BULLET_TIMER,x           ; set initial bullet timer value
    lda f_bullet_initialization_tbl+1,y ; load PLAYER_BULLET_FS_X offset amount
    clc                                 ; clear carry in preparation for addition
    adc PLAYER_BULLET_X_POS,x           ; add to bullet's generated x position
    sta PLAYER_BULLET_FS_X,x            ; set center x position on screen f bullet swirls around
    lda f_bullet_initialization_tbl+2,y ; load PLAYER_BULLET_F_Y offset amount
    clc                                 ; clear carry in preparation for addition
    bmi @negative_f_y_offset            ; branch if PLAYER_BULLET_F_Y offset value is negative (aiming upwards)
    adc PLAYER_BULLET_Y_POS,x           ; PLAYER_BULLET_F_Y offset was positive, add to f bullet generated y position
    bcs @clear_bullet_values            ; branch if had an overflow (shouldn't happen) to remove bullet
    bcc @set_fs_y                       ; always branch to set PLAYER_BULLET_F_Y and exit

; aim direction facing up
@negative_f_y_offset:
    adc PLAYER_BULLET_Y_POS,x ; add PLAYER_BULLET_F_Y (negative) to f bullet generated y position
    bcc @clear_bullet_values  ; if bullet y position plus negative amount didn't overflow, then remove bullet
                              ; this is because the player is at the top of the screen and the shot is off the screen above

@set_fs_y:
    sta PLAYER_BULLET_F_Y,x ; set center y position on screen f bullet swirls around
    rts

@clear_bullet_values:
    jmp clear_bullet_values ; initialize bullet memory values to #$00

; table for initial bullet f data depending on player aim direction (#$24 bytes)
; byte 0 = initial PLAYER_BULLET_TIMER used to lookup into f_bullet_outdoor_x_swirl_amt_tbl and f_bullet_outdoor_y_swirl_amt_tbl
; byte 1 = PLAYER_BULLET_FS_X offset, added to x position to get center x position that f bullet swirls around
; byte 2 = PLAYER_BULLET_F_Y offset, added to y position to get center y position that f bullet swirls around
f_bullet_initialization_tbl:
    .byte $0c,$00,$f0 ; (facing up) - vertical
    .byte $0e,$0b,$f5 ; (up-right) - angled
    .byte $00,$10,$00 ; (right) - flat
    .byte $02,$0b,$0b ; (down-right) - angled
    .byte $00,$10,$00 ; (crouching facing right) - flat
    .byte $08,$f0,$00 ; (crouching facing left) - flat
    .byte $06,$f5,$0b ; (down-left) - angled
    .byte $08,$f0,$00 ; (left) - flat
    .byte $0a,$f5,$f5 ; (up-left) - angled
    .byte $0c,$00,$f0 ; (up) - vertical
    .byte $0c,$00,$f0 ; (??) vertical
    .byte $04,$00,$10 ; (??) vertical

; indoor weapon only, set PLAYER_BULLET_FS_X and PLAYER_BULLET_F_Y
indoor_f_weapon_set_fs_x:
    lda #$04                  ; a = #$04
    sta PLAYER_BULLET_DIST,x  ; set bullet size to #04
    lda PLAYER_BULLET_X_POS,x
    sta PLAYER_BULLET_FS_X,x  ; set center x position on screen f bullet swirls around
    lda PLAYER_BULLET_Y_POS,x
    sec                       ; set carry flag in preparation for subtraction
    sbc #$02
    sta PLAYER_BULLET_F_Y,x   ; set center y position on screen f bullet swirls around
    rts

; called for all 4 bullets created by the S weapon
s_weapon_init_bullet_velocities:
    ldy #$00      ; y = #$00
    lda $09       ; load rapid fire flag
    beq @continue ; branch if no rapid fire flag for player weapon
    ldy #$02      ; y = #$02

@continue:
    lda s_bullet_y_vel_ptr_tbl,y
    sta $04
    lda s_bullet_y_vel_ptr_tbl+1,y
    sta $05
    lda s_bullet_x_vel_ptr_tbl,y
    sta $06
    lda s_bullet_x_vel_ptr_tbl+1,y
    sta $07
    ldy $0b                               ; load PLAYER_AIM_DIR
    lda player_aim_dir_ptr_tbl,y
    ldy $17                               ; bullets number of of current shot (#$00 to #$04 for each shot)
    clc                                   ; clear carry in preparation for addition
    adc s_bullet_num_index_modifier_tbl,y ; load scalar to add to the player aim direction based on the S weapon bullet number
    and #$1f                              ; max the result out at #$1f (...x xxxx)
    asl
    tay
    lda ($04),y                           ; s_bullet_y_vel_normal_tbl,y or s_bullet_y_vel_rapid_fire_tbl,y
    sta PLAYER_BULLET_Y_VEL_FRACT,x
    lda ($06),y
    sta PLAYER_BULLET_X_VEL_FRACT,x
    iny
    lda ($04),y
    sta PLAYER_BULLET_Y_VEL_FAST,x
    lda ($06),y
    sta PLAYER_BULLET_X_VEL_FAST,x
    rts

; table for player aim direction (#$c bytes)
; #$00 - facing right aiming up
; #$01 - facing right aiming upwards right (diagonally up)
; #$02 - facing right
; #$03 - facing right aiming downwards right (diagonally down)
; #$04 - crouched facing right
; #$05 - crouched facing left
; #$06 - facing left aiming downwards left (diagonally down)
; #$07 - facing left
; #$08 - facing left aiming upwards left (diagonally up)
; #$09 - facing left aiming up
player_aim_dir_ptr_tbl:
    .byte $00,$04,$08,$0c,$08,$18,$14,$18,$1c,$00,$00,$10

; table for initial index modifiers into velocity tables for each of the #$05 bullets created by the S weapon (#$5 bytes)
s_bullet_num_index_modifier_tbl:
    .byte $00,$01,$ff,$02,$fe

; pointer table for ? (2 * 2 = #$4 bytes)
s_bullet_y_vel_ptr_tbl:
    .addr s_bullet_y_vel_normal_tbl     ; CPU address $b8aa (no rapid fire)
    .addr s_bullet_y_vel_rapid_fire_tbl ; CPU address $b8fa (rapid fire)

; pointer table for ? (2 * 2 = #$4 bytes)
s_bullet_x_vel_ptr_tbl:
    .addr s_bullet_x_vel_normal_tbl     ; CPU address $b8ba
    .addr s_bullet_x_vel_rapid_fire_tbl ; CPU address $b90a

; bullet y velocity when no rapid fire (8 * 2 = #$10 bytes)
; byte 0 is PLAYER_BULLET_Y_VEL_FRACT
; byte 1 is PLAYER_BULLET_Y_VEL_FAST
s_bullet_y_vel_normal_tbl:
    .byte $03,$fd
    .byte $0f,$fd
    .byte $3c,$fd
    .byte $84,$fd
    .byte $e1,$fd
    .byte $56,$fe
    .byte $dd,$fe
    .byte $6d,$ff

; table for bullet x velocity with no rapid fire (#$40 bytes)
; s_bullet_y_vel_normal_tbl,y can overflow into this table
s_bullet_x_vel_normal_tbl:
    .byte $00,$00
    .byte $93,$00
    .byte $23,$01
    .byte $aa,$01
    .byte $1f,$02
    .byte $7c,$02
    .byte $c4,$02
    .byte $f1,$02
    .byte $fd,$02
    .byte $f1,$02
    .byte $c4,$02
    .byte $7c,$02
    .byte $1f,$02
    .byte $aa,$01
    .byte $23,$01
    .byte $93,$00
    .byte $00,$00
    .byte $6d,$ff
    .byte $dd,$fe
    .byte $56,$fe
    .byte $e1,$fd
    .byte $84,$fd
    .byte $3c,$fd
    .byte $0f,$fd
    .byte $03,$fd
    .byte $0f,$fd
    .byte $3c,$fd
    .byte $84,$fd
    .byte $e1,$fd
    .byte $56,$fe
    .byte $dd,$fe
    .byte $6d,$ff

; bullet y velocity when rapid fire (8 * 2 = #$10 bytes)
; byte 0 is PLAYER_BULLET_Y_VEL_FRACT
; byte 1 is PLAYER_BULLET_Y_VEL_FAST
s_bullet_y_vel_rapid_fire_tbl:
    .byte $84,$fc
    .byte $92,$fc
    .byte $c6,$fc
    .byte $1a,$fd
    .byte $87,$fd
    .byte $0f,$fe
    .byte $ad,$fe
    .byte $55,$ff

; table for bullet x velocity with rapid fire (#$40 bytes)
; s_bullet_y_vel_rapid_fire_tbl,y can overflow into this table
s_bullet_x_vel_rapid_fire_tbl:
    .byte $00,$00
    .byte $ab,$00
    .byte $53,$01
    .byte $f1,$01
    .byte $79,$02
    .byte $e6,$02
    .byte $3a,$03
    .byte $6e,$03
    .byte $7c,$03
    .byte $6e,$03
    .byte $3a,$03
    .byte $e6,$02
    .byte $79,$02
    .byte $f1,$01
    .byte $53,$01
    .byte $ab,$00
    .byte $00,$00
    .byte $55,$ff
    .byte $ad,$fe
    .byte $0f,$fe
    .byte $87,$fd
    .byte $1a,$fd
    .byte $c6,$fc
    .byte $92,$fc
    .byte $84,$fc
    .byte $92,$fc
    .byte $c6,$fc
    .byte $1a,$fd
    .byte $87,$fd
    .byte $0f,$fe
    .byte $ad,$fe
    .byte $55,$ff

run_player_bullet_routines:
    ldx #$00 ; start at first bullet slot

@loop:
    lda PLAYER_BULLET_SLOT,x      ; load bullet type
    beq @advance_bullet_slot      ; move to next slot if current slot doesn't have a bullet
    stx $10                       ; store bullet type (+1) in $10
    lda PLAYER_BULLET_OWNER,x     ; load the player who fired the bullet (#$00 = p1, #$01 = p2)
    sta $11                       ; store player who fired the bullet in $11
    jsr run_player_bullet_routine ; run current bullet routine for the bullet slot x

@advance_bullet_slot:
    inx
    cpx #$10
    bcc @loop

; placeholder empty routine that isn't used since PLAYER_BULLET_SLOT starts at #$01
player_bullet_routine_00_ptr_tbl:
    rts

; input
;  * x - PLAYER_BULLET_SLOT index
;  * $10 - PLAYER_BULLET_SLOT (bullet type + 1)
;  * $11 - player who fired the bullet (#$00 = p1, #$01 = p2)
run_player_bullet_routine:
    lda PLAYER_BULLET_SLOT,x ; load bullet type + #$01
    and #$0f                 ; keep bits .... xxxx
    ldy LEVEL_LOCATION_TYPE  ; 0 = outdoor; 1 = indoor; #$80 = indoor boss
    bmi @continue            ; branch if indoor boss screen
    beq @continue            ; branch for outdoor level
    clc                      ; clear carry in preparation for addition
    adc #$06                 ; indoor level, offset to use indoor player bullet routines (add #$06)

@continue:
    asl
    tay
    lda player_bullet_routine_ptr_tbl,y
    sta $0a
    lda player_bullet_routine_ptr_tbl+1,y
    sta $0b
    lda PLAYER_BULLET_ROUTINE,x
    asl
    tay
    lda ($0a),y
    sta $08
    iny
    lda ($0a),y
    sta $09
    jmp ($0008)

; pointer table for ? (#$c * #$2 = #$18 bytes)
player_bullet_routine_ptr_tbl:
    .addr player_bullet_routine_00_ptr_tbl ; CPU address $b960 (dead code, not used, placeholder since PLAYER_BULLET_SLOT starts at #$01)
    .addr player_bullet_routine_01_ptr_tbl ; CPU address $b9a4 (default bullet)
    .addr player_bullet_routine_02_ptr_tbl ; CPU address $b9aa (M bullet)
    .addr player_bullet_routine_03_ptr_tbl ; CPU address $b9b0 (F bullet)
    .addr player_bullet_routine_04_ptr_tbl ; CPU address $b9b6 (S bullet)
    .addr player_bullet_routine_05_ptr_tbl ; CPU address $b9bc (L bullet)

    ; indoor routines
    .addr player_bullet_routine_00_ptr_tbl        ; CPU address $b960 (dead code, not used, placeholder since PLAYER_BULLET_SLOT starts at #$01)
    .addr player_bullet_routine_indoor_01_ptr_tbl ; CPU address $b9c2 (default bullet)
    .addr player_bullet_routine_indoor_02_ptr_tbl ; CPU address $b9c8 (M bullet)
    .addr player_bullet_routine_indoor_03_ptr_tbl ; CPU address $b9ce (F bullet)
    .addr player_bullet_routine_indoor_04_ptr_tbl ; CPU address $b9d4 (S bullet)
    .addr player_bullet_routine_indoor_05_ptr_tbl ; CPU address $b9da (L bullet)

; pointer table for default bullet routines (#$2 * #$3 = #$6 bytes)
player_bullet_routine_01_ptr_tbl:
    .addr inc_player_bullet_routine_far   ; CPU address $b9e0
    .addr player_shared_bullet_routine_01 ; CPU address $ba46
    .addr player_bullet_collision_routine ; CPU address $bc1e

; pointer table for M bullet routines (#$2 * #$3 = #$6 bytes)
player_bullet_routine_02_ptr_tbl:
    .addr inc_player_bullet_routine_far   ; CPU address $b9e0
    .addr player_shared_bullet_routine_01 ; CPU address $ba46
    .addr player_bullet_collision_routine ; CPU address $bc1e

; pointer table for F bullet routines (#$2 * #$3 = #$6 bytes)
player_bullet_routine_03_ptr_tbl:
    .addr inc_player_bullet_routine_far   ; CPU address $b9e0
    .addr player_f_bullet_routine_01      ; CPU address $ba4f
    .addr player_bullet_collision_routine ; CPU address $bc1e

; pointer table for S bullet routines (#$2 * #$3 = #$6 bytes)
player_bullet_routine_04_ptr_tbl:
    .addr inc_player_bullet_routine_far   ; CPU address $b9e0
    .addr player_s_bullet_routine_01      ; CPU address $ba60 - determines sprite (size) then calls player_shared_bullet_routine_01
    .addr player_bullet_collision_routine ; CPU address $bc1e

; pointer table for L bullet routines (#$2 * #$3 = #$6 bytes)
player_bullet_routine_05_ptr_tbl:
    .addr player_l_bullet_routine_00      ; CPU address $b9e3
    .addr player_shared_bullet_routine_01 ; CPU address $ba46
    .addr player_bullet_collision_routine ; CPU address $bc1e

; pointer table for default bullet routines on indoor levels (#$2 * #$3 = #$6 bytes)
player_bullet_routine_indoor_01_ptr_tbl:
    .addr inc_player_bullet_routine_far_2        ; CPU address $ba2f
    .addr player_shared_indoor_bullet_routine_01 ; CPU address $ba7c
    .addr player_bullet_collision_routine        ; CPU address $bc1e

; pointer table for M (#$2 * #$3 = #$6 bytes)
player_bullet_routine_indoor_02_ptr_tbl:
    .addr inc_player_bullet_routine_far_2        ; CPU address $ba2f
    .addr player_shared_indoor_bullet_routine_01 ; CPU address $ba7c
    .addr player_bullet_collision_routine        ; CPU address $bc1e

; pointer table for F bullet routines on indoor levels (#$2 * #$3 = #$6 bytes)
player_bullet_routine_indoor_03_ptr_tbl:
    .addr inc_player_bullet_routine_far_2   ; CPU address $ba2f
    .addr player_f_indoor_bullet_routine_01 ; CPU address $ba82
    .addr player_bullet_collision_routine   ; CPU address $bc1e

; pointer table for S bullet routines on indoor levels (#$2 * #$3 = #$6 bytes)
player_bullet_routine_indoor_04_ptr_tbl:
    .addr inc_player_bullet_routine_far_2   ; CPU address $ba2f
    .addr player_s_indoor_bullet_routine_01 ; CPU address $ba8b
    .addr player_bullet_collision_routine   ; CPU address $bc1e

; pointer table for L bullet routines on indoor levels (#$2 * #$3 = #$6 bytes)
player_bullet_routine_indoor_05_ptr_tbl:
    .addr player_l_indoor_bullet_routine_00 ; CPU address $ba32
    .addr player_l_indoor_bullet_routine_01 ; CPU address $baa7
    .addr player_bullet_collision_routine   ; CPU address $bc1e

inc_player_bullet_routine_far:
    jmp inc_player_bullet_routine

player_l_bullet_routine_00:
    lda LEVEL_SCROLLING_TYPE  ; 0 = horizontal, indoor/base; 1 = vertical
    bne @handle_vertical      ; branch for vertical level
    lda PLAYER_BULLET_X_POS,x
    sec                       ; set carry flag in preparation for subtraction
    sbc FRAME_SCROLL          ; how much to scroll the screen (#00 - no scroll)
    sta PLAYER_BULLET_X_POS,x
    jmp @adv_routine          ; dec bullet timer, set sprite, and advance routine

; player l bullet routine for vertical level
@handle_vertical:
    lda PLAYER_BULLET_Y_POS,x
    clc                       ; clear carry in preparation for addition
    adc FRAME_SCROLL          ; how much to scroll the screen (#00 - no scroll)
    sta PLAYER_BULLET_Y_POS,x

@adv_routine:
    dec PLAYER_BULLET_TIMER,x
    beq l_bullet_set_sprite_adv_bullet_routine
    rts

; sets correct l bullet sprite based on player aim direction
; advances bullet routine
l_bullet_set_sprite_adv_bullet_routine:
    jsr inc_player_bullet_routine
    lda PLAYER_BULLET_AIM_DIR,x
    asl
    tay
    lda l_bullet_sprite_code_tbl,y
    sta PLAYER_BULLET_SPRITE_CODE,x
    lda l_bullet_sprite_code_tbl+1,y
    sta PLAYER_BULLET_SPRITE_ATTR,x

player_l_bullet_exit:
    rts

; table for l bullet sprite depending on direction (#$18 bytes)
; byte 0 is the sprite_code
; byte 1 is the sprite attribute for flipping sprite_code
l_bullet_sprite_code_tbl:
    .byte $23,$00 ; (facing up) - vertical
    .byte $25,$80 ; (up-right) - angled
    .byte $24,$00 ; (right) - flat
    .byte $25,$00 ; (down-right) - angled
    .byte $24,$00 ; (crouching facing right) - flat
    .byte $24,$40 ; (crouching facing left) - flat
    .byte $25,$40 ; (down-left) - angled
    .byte $24,$40 ; (left) - flat
    .byte $25,$c0 ; (up-left) - angled
    .byte $23,$00 ; (up) - vertical
    .byte $23,$80 ; (??) vertical
    .byte $23,$80 ; (??) vertical

inc_player_bullet_routine_far_2:
    jmp inc_player_bullet_routine

player_l_indoor_bullet_routine_00:
    dec PLAYER_BULLET_TIMER,x
    bne player_l_bullet_exit
    jsr inc_player_bullet_routine
    lda #$15                       ; a = #$15
    sta PLAYER_BULLET_TIMER,x
    jmp set_indoor_l_bullet_sprite

inc_player_bullet_routine:
    inc PLAYER_BULLET_ROUTINE,x

player_f_bullet_routine_01_exit:
    rts

; shared by many bullet routines for outdoor levels
; bullet moves according to velocity until it flies off screen or collides with solid object
; for enemy collision, this is handled by bullet_enemy_collision_test
; default, M, L, S bullets use this routine
player_shared_bullet_routine_01:
    jsr update_player_bullet_pos     ; update bullet position based on its velocities
    jsr add_scroll_to_bullet_pos     ; add scrolling to bullet position
    jmp destroy_bullet_if_off_screen ; destroy bullet if it has gone off screen

; F bullet logic for outdoor levels
; bullet moves according to velocity until it flies off screen or collides with solid object
; for enemy collision, this is handled by bullet_enemy_collision_test
player_f_bullet_routine_01:
    jsr check_bullet_solid_bg_collision       ; if specified, check for bullet collision with solid background
                                              ; and if so move bullet routine to player_bullet_collision_routine
    bmi player_f_bullet_routine_01_exit       ; branch if collision with solid background
    jsr adjust_f_bullet_if_scrolling          ; adjust bullet variables if frame is scrolling
    jsr update_player_f_bullet_center_pos     ; update x and y center position (not including swirl effect)
    jsr adjust_f_outdoor_bullet_pos_for_swirl ; determine swirl pattern position and adjust x and y position of bullet
    jmp destroy_bullet_if_off_screen          ; destroy bullet if it has gone off screen

; outdoor S bullet - adjust bullet sprite based on distance traveled
; determines s bullet sprite then calls player_shared_bullet_routine_01
player_s_bullet_routine_01:
    inc PLAYER_BULLET_DIST,x ; increase bullet travel distance
    lda PLAYER_BULLET_DIST,x ; load current bullet travel distance
    ldy #$02                 ; specify bullet frame (sprite_21)
    cmp #$20                 ; see if traveled for #$20 frames
    bcs @continue            ; branch if traveled for #$20 or more frames (use sprite_21)
    dey                      ; traveled less than #$20 frames, decrement bullet frame (sprite_20)
    cmp #$10                 ; see if traveled for #$10 frames
    bcs @continue            ; branch if traveled for #$20 or more frames (use sprite_20)
    dey                      ; traveled less than #$10 frames, decrement bullet frame (sprite_1f)

@continue:
    tya                                 ; transfer bullet frame to a
    clc                                 ; clear carry in preparation for addition
    adc #$1f                            ; add sprite offset to get actual sprite code
    sta PLAYER_BULLET_SPRITE_CODE,x     ; set bullet sprite: sprite_1f (small), sprite_20 (medium), sprite_21 (large)
    jmp player_shared_bullet_routine_01 ; run regular shared bullet routine

player_shared_indoor_bullet_routine_01:
    jsr update_player_bullet_pos
    jmp dec_bullet_delay_possibly_adv_routine ; decrement PLAYER_BULLET_TIMER, and if #$00, move to next bullet routine (remove bullet)

player_f_indoor_bullet_routine_01:
    jsr update_player_f_bullet_center_pos     ; update x and y center position (not including swirl effect)
    jsr f_bullet_indoor_update_pos            ; updates position based on PLAYER_BULLET_DIST and PLAYER_BULLET_TIMER
    jmp dec_bullet_delay_possibly_adv_routine ; decrement PLAYER_BULLET_TIMER, and if #$00, move to next bullet routine (remove bullet)

player_s_indoor_bullet_routine_01:
    ldy #$00                  ; y = #$00
    lda PLAYER_BULLET_TIMER,x ; starts at #$2a (see set_indoor_bullet_delay)
    cmp #$1a                  ; compare bullet delay to #$1a (1/2 of screen)
    bcs @continue             ; still in first half of distance, use #$1f as bullet sprite
    iny                       ; bullet has traveled >= half distance, use #$20 as bullet sprite
    cmp #$0a                  ; see if in last quarter of distance
    bcs @continue             ; in 50%-75% of trip, keep #$20 as bullet sprite
    iny                       ; in last quarter of distance, use #$21 as bullet sprite (largest)

; set bullet position and decrement bullet delay timer, once elapsed, remove bullet (advance bullet routine)
@continue:
    tya
    clc                                       ; clear carry in preparation for addition
    adc #$1f                                  ; first S bullet sprite starts at #$1f
    sta PLAYER_BULLET_SPRITE_CODE,x           ; based on Y can be either sprite_1f (smallest), sprite_20, or sprite_21 (largest)
    jsr update_s_bullet_indoor_pos            ; update bullet position based on various velocities and spread configurations
    jmp dec_bullet_delay_possibly_adv_routine ; decrement PLAYER_BULLET_TIMER, and if #$00, move to next bullet routine (remove bullet)

player_l_indoor_bullet_routine_01:
    jsr update_player_bullet_pos
    jmp dec_bullet_delay_possibly_adv_routine ; decrement PLAYER_BULLET_TIMER, and if #$00, move to next bullet routine (remove bullet)

; outdoor f bullet
; use PLAYER_BULLET_TIMER to determine swirl pattern position and adjust x and y pos of bullet
; sets new PLAYER_BULLET_TIMER depending on firing direction
adjust_f_outdoor_bullet_pos_for_swirl:
    lda PLAYER_BULLET_TIMER,x              ; load bullet timer value
    and #$0f                               ; keep bits .... xxxx
    tay                                    ; transfer to offset register
    lda f_bullet_outdoor_x_swirl_amt_tbl,y ; load x adjustment amount based on PLAYER_BULLET_TIMER
                                           ; this means the swirl repeats every 16 frames
    clc                                    ; clear carry in preparation for addition
    adc PLAYER_BULLET_FS_X,x               ; add to center x position on screen f bullet swirls around
    sta PLAYER_BULLET_X_POS,x              ; set x position adjusted for swirl
    lda f_bullet_outdoor_y_swirl_amt_tbl,y ; load y adjustment amount based on PLAYER_BULLET_TIMER
                                           ; this means the swirl repeats every 16 frames
    clc                                    ; clear carry in preparation for addition
    adc PLAYER_BULLET_F_Y,x                ; add to base center y position on screen f bullet swirls around
    sta PLAYER_BULLET_Y_POS,x              ; set y position adjusted for swirl
    lda PLAYER_BULLET_AIM_DIR,x            ; load direction of the bullet (#$00 for up facing right, incrementing clockwise up to #09 for up facing left)
    cmp #$0a                               ; PLAYER_BULLET_AIM_DIR can't ever be #$0a !(WHY?)
                                           ; seems like code was added to prevent case when PLAYER_BULLET_AIM_DIR was #$0a, but that's not possible !(WHY?)
    beq @set_bullet_delay_1                ; if #$0a, assume shooting up-right (#$01)
    cmp #$05                               ; see if facing left or right
    lda #$ff                               ; a = #$ff
    bcs @set_bullet_delay_a                ; branch if shooting to the left

@set_bullet_delay_1:
    lda #$01 ; a = #$01

@set_bullet_delay_a:
    clc                       ; clear carry in preparation for addition
    adc PLAYER_BULLET_TIMER,x ; add 1 or subtract 1 from PLAYER_BULLET_TIMER depending on direction
    sta PLAYER_BULLET_TIMER,x ; set new PLAYER_BULLET_TIMER
    rts

; table for y adjustment for f bullets to create swirl effect (#$4 bytes)
; overflows into next table
f_bullet_outdoor_y_swirl_amt_tbl:
    .byte $00,$fa,$f5,$f2

; table for x adjustment for f bullets to create swirl effect (#$f bytes)
f_bullet_outdoor_x_swirl_amt_tbl:
    .byte $f1,$f2,$f5,$fa,$00,$06,$0b,$0e,$0f,$0e,$0b,$06,$00,$fa,$f5,$f2

; pointer table for f indoor bullet x and y adjustment based on PLAYER_BULLET_DIST (6 * 2 = c bytes)
f_bullet_indoor_pos_adj_ptr_tbl:
    .addr f_bullet_indoor_x_adj_tbl_00 ; CPU address $bb2a (farthest from player)
    .addr f_bullet_indoor_y_adj_tbl_00 ; CPU address $bb26
    .addr f_bullet_indoor_x_adj_tbl_01 ; CPU address $bb16
    .addr f_bullet_indoor_y_adj_tbl_01 ; CPU address $bb12
    .addr f_bullet_indoor_x_adj_tbl_02 ; CPU address $bb02
    .addr f_bullet_indoor_y_adj_tbl_02 ; CPU address $bafe (closest from player)

; table for f indoor bullet y adjustment based on PLAYER_BULLET_DIST (#$4 bytes) (bleeds into next table)
f_bullet_indoor_y_adj_tbl_02:
    .byte $00,$fc,$f8,$f5

; table for f indoor x adjustment based on PLAYER_BULLET_DIST (#$10 bytes)
f_bullet_indoor_x_adj_tbl_02:
    .byte $f5,$f5,$f8,$fc,$00,$04,$08,$0b,$0b,$0b,$08,$04,$00,$fc,$f8,$f5

; table for f indoor bullet y adjustment based on PLAYER_BULLET_DIST (#$4 bytes) (bleeds into next table)
f_bullet_indoor_y_adj_tbl_01:
    .byte $00,$fd,$fb,$f9

; table for f indoor x adjustment based on PLAYER_BULLET_DIST (#$10 bytes)
f_bullet_indoor_x_adj_tbl_01:
    .byte $f9,$f9,$fb,$fd,$00,$03,$05,$07,$07,$07,$05,$03,$00,$fd,$fb,$f9

; table for f indoor bullet y adjustment based on PLAYER_BULLET_DIST (#$4 bytes) (bleeds into next table)
f_bullet_indoor_y_adj_tbl_00:
.byte $00,$ff,$fe,$fd

; table for f indoor x adjustment based on PLAYER_BULLET_DIST (#$10 bytes)
f_bullet_indoor_x_adj_tbl_00:
    .byte $fd,$fd,$fe,$ff,$00,$01,$02,$03,$03,$03,$02,$01,$00,$ff,$fe,$fd

add_scroll_to_bullet_pos:
    lda FRAME_SCROLL                  ; how much to scroll the screen (#00 - no scroll)
    beq add_scroll_to_bullet_pos_exit ; no adjustment needed, exit
    lda LEVEL_SCROLLING_TYPE          ; 0 = horizontal, indoor/base; 1 = vertical
    bne @vertical_scroll              ; branch if vertical scroll
    dec PLAYER_BULLET_X_POS,x
    jmp add_scroll_to_bullet_pos_exit

@vertical_scroll:
    lda PLAYER_BULLET_Y_POS,x
    clc                       ; clear carry in preparation for addition
    adc FRAME_SCROLL          ; how much to scroll the screen (#00 - no scroll)
    sta PLAYER_BULLET_Y_POS,x

add_scroll_to_bullet_pos_exit:
    rts

; decrements PLAYER_BULLET_FS_X for horizontal/indoor levels
; adds FRAME_SCROLL to PLAYER_BULLET_F_Y for vertical levels
adjust_f_bullet_if_scrolling:
    lda FRAME_SCROLL                  ; whether or not the screen is scrolling (#$00 or #$01)
    beq @exit                         ; exit if not scrolling
    ldy LEVEL_SCROLLING_TYPE          ; 0 = horizontal, indoor/base; 1 = vertical
    bne @vertical_scroll
    dec PLAYER_BULLET_FS_X,x          ; horizontal level, decrement center x position on screen f bullet swirls around
    jmp add_scroll_to_bullet_pos_exit

@vertical_scroll:
    lda PLAYER_BULLET_F_Y,x ; load center y position on screen f bullet swirls around
    clc                     ; clear carry in preparation for addition
    adc FRAME_SCROLL        ; how much to scroll the screen (#00 - no scroll)
    sta PLAYER_BULLET_F_Y,x ; set center y position on screen f bullet swirls around

@exit:
    rts

; updates the player's (indoor and outdoor) F bullet's X and Y center position (not including swirl effect)
; swirl effect adjustment happens update_player_bullet_pos
update_player_f_bullet_center_pos:
    lda PLAYER_BULLET_VEL_F_Y_ACCUM,x ; load bullet fractional velocity accumulator (f)
    clc                               ; clear carry in preparation for addition
    adc PLAYER_BULLET_Y_VEL_FRACT,x   ; add accumulator and factional velocity
    sta PLAYER_BULLET_VEL_F_Y_ACCUM,x ; store new accumulator value
    lda PLAYER_BULLET_F_Y,x           ; load center y position on screen f bullet swirls around
    adc PLAYER_BULLET_Y_VEL_FAST,x    ; add fast velocity to y position (including any overflow from accumulator, i.e. fractional velocity)
    sta PLAYER_BULLET_F_Y,x           ; set new center y position

; updates the player's F and S (indoor) bullet's PLAYER_BULLET_FS_X position based on the bullet's velocities
; includes additional variable compared to update_player_bullet_pos to incorporate swirl effect
update_player_fs_bullet_x_pos:
    lda PLAYER_BULLET_VEL_FS_X_ACCUM,x ; load accumulator value for bullet X velocity
    clc                                ; clear carry in preparation for addition
    adc PLAYER_BULLET_X_VEL_FRACT,x    ; add x fractional velocity, noting the carry being set if overflow
    sta PLAYER_BULLET_VEL_FS_X_ACCUM,x ; add accumulated value back
    lda PLAYER_BULLET_FS_X,x
    adc PLAYER_BULLET_X_VEL_FAST,x     ; add fast X velocity and any carry from accumulator
    sta PLAYER_BULLET_FS_X,x
    rts

; updates the player bullet's X and Y position based on the bullet's velocities
update_player_bullet_pos:
    jsr check_bullet_solid_bg_collision ; if specified, check for bullet collision with solid background
                                        ; and if so move bullet routine to player_bullet_collision_routine
    bmi bullet_logic_exit               ; exit if bullet collided with solid object
    lda PLAYER_BULLET_X_VEL_ACCUM,x     ; load accumulator value for bullet X velocity
    clc                                 ; clear carry in preparation for addition
    adc PLAYER_BULLET_X_VEL_FRACT,x     ; add x fractional velocity, noting the carry being set if overflow
    sta PLAYER_BULLET_X_VEL_ACCUM,x     ; add accumulated value back
    lda PLAYER_BULLET_X_POS,x           ; load bullet X position
    adc PLAYER_BULLET_X_VEL_FAST,x      ; add fast X velocity and any carry from accumulator
    sta PLAYER_BULLET_X_POS,x           ; set new X position

update_player_bullet_y_pos:
    clc                             ; clear carry in preparation for addition
    lda PLAYER_BULLET_Y_VEL_ACCUM,x ; load accumulator value for bullet Y velocity
    adc PLAYER_BULLET_Y_VEL_FRACT,x ; add y fractional velocity, noting the carry being set if overflow
    sta PLAYER_BULLET_Y_VEL_ACCUM,x ; add accumulated value back
    lda PLAYER_BULLET_Y_POS,x       ; load bullet Y position
    adc PLAYER_BULLET_Y_VEL_FAST,x  ; add fast Y velocity and any carry from accumulator
    sta PLAYER_BULLET_Y_POS,x       ; set new Y position

bullet_logic_exit:
    rts

; depending on the level, checks if bullet has collided with solid background
; if collision with solid object move to next bullet routine (player_bullet_collision_routine)
; output
;  * a - collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
check_bullet_solid_bg_collision:
    lda LEVEL_SOLID_BG_COLLISION_CHECK ; level header offset #$19
                                       ; determines whether to check player bullet - solid bg collision
    bpl bullet_logic_exit              ; exit if shouldn't check for solid bg collisions (level 6 energy zone and level 7 hangar)
    ldy PLAYER_BULLET_Y_POS,x          ; load bullet y position
    lda PLAYER_BULLET_X_POS,x          ; load bullet x position
    jsr get_bg_collision_far           ; determine player background collision code at position (a,y)
    bpl bullet_logic_exit              ; branch if not a collision with solid object
    jsr set_bullet_routine_to_2        ; collided with solid object, move to bullet routine 2 and reset PLAYER_BULLET_TIMER to #$06
    lda #$80                           ; a = #$80 (solid collision code)
    rts

; for outdoor levels, determines where bullet is and if it is off screen, the
; bullet is removed.
destroy_bullet_if_off_screen:
    lda PLAYER_BULLET_X_POS,x
    cmp #$05                  ; see if bullet is off screen to the left
    bcc clear_bullet_values   ; destroy bullet
    cmp #$fb                  ; see if bullet is off screen to the right
    bcs clear_bullet_values   ; destroy bullet
    lda PLAYER_BULLET_Y_POS,x
    cmp #$05                  ; see if bullet is off screen to the top
    bcc clear_bullet_values   ; destroy bullet
    cmp #$e8                  ; see if bullet is off screen to the bottom
    bcc clear_bullet_exit

; initialize bullet memory values to #$00
clear_bullet_values:
    lda #$00                           ; a = #$00
    sta PLAYER_BULLET_SLOT,x
    sta PLAYER_BULLET_SPRITE_CODE,x
    sta PLAYER_BULLET_SPRITE_ATTR,x
    sta PLAYER_BULLET_ROUTINE,x
    sta PLAYER_BULLET_OWNER,x
    sta PLAYER_BULLET_TIMER,x
    sta PLAYER_BULLET_FS_X,x
    sta PLAYER_BULLET_VEL_FS_X_ACCUM,x
    sta PLAYER_BULLET_F_Y,x
    sta PLAYER_BULLET_VEL_F_Y_ACCUM,x
    sta PLAYER_BULLET_F_RAPID,x
    sta PLAYER_BULLET_DIST,x
    sta PLAYER_BULLET_AIM_DIR,x
    sta PLAYER_BULLET_X_VEL_FAST,x
    sta PLAYER_BULLET_X_VEL_FRACT,x
    sta PLAYER_BULLET_Y_VEL_FAST,x
    sta PLAYER_BULLET_Y_VEL_FRACT,x

clear_bullet_exit:
    rts

player_bullet_collision_routine:
    lda INDOOR_SCREEN_CLEARED       ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
    bne clear_bullet_values         ; initialize bullet memory values to #$00
    lda #$47                        ; a = #$47 (sprite_47)
    sta PLAYER_BULLET_SPRITE_CODE,x ; change bullet to hollow ring
    jsr add_scroll_to_bullet_pos    ; add any scroll to bullet position
    dec PLAYER_BULLET_TIMER,x       ; decrement delay before deletion of bullet
    beq clear_bullet_values         ; initialize bullet memory values to #$00
    rts

; called from f bullet indoor routine 01
; updates f bullet indoor position based on PLAYER_BULLET_DIST and PLAYER_BULLET_TIMER
f_bullet_indoor_update_pos:
    ldy #$00                    ; y = #$00
    lda PLAYER_BULLET_F_RAPID,x ; load rapid fire flag for f weapon
    beq @continue               ; branch if rapid fire is not set
    ldy #$02                    ; y = #$02

@continue:
    lda #$02                  ; a = #$02
    sta $0b                   ; store initial f bullet offset (see f_bullet_indoor_pos_adj_ptr_tbl)
    lda PLAYER_BULLET_TIMER,x ; load timer value for how long until bullet is removed
    cmp #$02                  ; compare to #$02 (about to be removed (too far deep in screen))
    bcs @loop                 ; branch if f bullet not about to be removed
    lda PLAYER_BULLET_FS_X,x  ; load center x position on screen f bullet swirls around
    sta PLAYER_BULLET_X_POS,x ; set final x position
    lda PLAYER_BULLET_F_Y,x   ; load center y position on screen f bullet swirls around
    sta PLAYER_BULLET_Y_POS,x ; set final y position
    rts

; f bullet indoor - update bullet position based on
; input
;  * a - PLAYER_BULLET_TIMER
;  * $0b - offset for f_bullet_indoor_pos_adj_ptr_tbl
;  * y - offset for f_bullet_indoor_delay_cutoff_tbl
@loop:
    cmp f_bullet_indoor_delay_cutoff_tbl,y ; (#$00 = rapid fire disabled, #$02 = rapid fire enabled)
    bcs @cutoff_found
    iny                                    ; increment cutoff table read offset
    dec $0b                                ; decrement f_bullet_indoor_pos_adj_ptr_tbl offset
    bne @loop

@cutoff_found:
    lda $0b                                 ; load f_bullet_indoor_pos_adj_ptr_tbl offset
    asl                                     ; double
    asl                                     ; double again
    tay                                     ; transfer to offset register
    lda f_bullet_indoor_pos_adj_ptr_tbl,y   ; load low byte of x adjustment table
    sta $08                                 ; set low byte of x adjustment table
    lda f_bullet_indoor_pos_adj_ptr_tbl+1,y ; load high byte of x adjustment table
    sta $09                                 ; set high byte of x adjustment table
    lda f_bullet_indoor_pos_adj_ptr_tbl+2,y ; load low byte of y adjustment table
    sta $0a                                 ; set low byte of y adjustment table
    lda f_bullet_indoor_pos_adj_ptr_tbl+3,y ; load high byte of y adjustment table
    sta $0b                                 ; set high byte of y adjustment table
    lda PLAYER_BULLET_DIST,x                ; load how far a bullet has traveled (timer since fired)
    and #$0f                                ; keep bits .... xxxx
    tay
    lda ($08),y                             ; load x adjustment amount
    clc                                     ; clear carry in preparation for addition
    adc PLAYER_BULLET_FS_X,x                ; add current swirl size [#$71-#$7b]
    sta PLAYER_BULLET_X_POS,x               ; store new x position
    lda ($0a),y                             ; load y adjustment amount
    clc                                     ; clear carry in preparation for addition
    adc PLAYER_BULLET_F_Y,x                 ; add to center y position on screen f bullet swirls around
    sta PLAYER_BULLET_Y_POS,x
    lda PLAYER_BULLET_F_RAPID,x
    clc                                     ; clear carry in preparation for addition
    adc #$01
    clc                                     ; clear carry in preparation for addition
    adc PLAYER_BULLET_DIST,x
    sta PLAYER_BULLET_DIST,x
    rts

; table for PLAYER_BULLET_TIMER cutoff values for use in determining f_bullet_indoor_pos_adj_ptr_tbl index (#$4 bytes)
f_bullet_indoor_delay_cutoff_tbl:
    .byte $1c,$0e ; no f rapid fire
    .byte $0e,$07 ; f rapid fire

; updates indoor level S bullet positions
; y position is straightforward, but x position is more complicated for spread effect.
; x position calculation includes the _FS_* variables and PLAYER_BULLET_S_INDOOR_ADJ
update_s_bullet_indoor_pos:
    jsr update_player_fs_bullet_x_pos  ; update PLAYER_BULLET_FS_X based on _FS_ velocities
    jsr update_player_bullet_y_pos     ; update PLAYER_BULLET_Y_POS based on regular velocities
    lda PLAYER_BULLET_VEL_FS_X_ACCUM,x ; ignore, no affect
    clc                                ; ignore, no affect
    adc PLAYER_BULLET_S_ADJ_ACCUM,x    ; ignore, no affect
    sta PLAYER_BULLET_X_VEL_ACCUM,x    ; unused result, never read for S indoor bullets !(WHY?)
    lda PLAYER_BULLET_FS_X,x           ; load center x position on screen f bullet swirls around
    clc                                ; clear carry in preparation for addition
    adc PLAYER_BULLET_S_INDOOR_ADJ,x   ; add the indoor adjustment
    sta PLAYER_BULLET_X_POS,x          ; set new x position
    lda PLAYER_BULLET_S_RAPID,x        ; load S weapon rapid fire flag
    lsr                                ; shift rapid fire flag to carry register
    lda PLAYER_BULLET_S_BULLET_NUM,x
    bcc @load_bullet_pos_mod           ; branch if rapid fire flag
    adc #$04                           ; rapid fire set, load rapid fire position modifications

@load_bullet_pos_mod:
    asl
    tay
    lda s_bullet_pos_mod_tbl,y
    clc                              ; clear carry in preparation for addition
    adc PLAYER_BULLET_S_ADJ_ACCUM,x
    sta PLAYER_BULLET_S_ADJ_ACCUM,x  ; add PLAYER_BULLET_S_ADJ_ACCUM to itself possibly causing overflow
    lda s_bullet_pos_mod_tbl+1,y
    adc PLAYER_BULLET_S_INDOOR_ADJ,x ; load indoor adjustment plus any carry from PLAYER_BULLET_S_ADJ_ACCUM addition
    sta PLAYER_BULLET_S_INDOOR_ADJ,x ; set adjustment for next frame
    rts

; table for indoor S bullet X spread configuration (#$14 bytes)
; byte 0 - x spread fractional velocity - amount to add to PLAYER_BULLET_S_ADJ_ACCUM every frame (overflows into PLAYER_BULLET_S_INDOOR_ADJ)
; byte 1 - x spread velocity fast - amount to add to PLAYER_BULLET_S_INDOOR_ADJ every frame
s_bullet_pos_mod_tbl:
    .byte $00,$00 ; S bullet 0 - no rapid fire
    .byte $20,$00 ; S bullet 1 - no rapid fire
    .byte $e0,$ff ; S bullet 2 - no rapid fire
    .byte $40,$00 ; S bullet 3 - no rapid fire
    .byte $c0,$ff ; S bullet 4 - no rapid fire
    .byte $00,$00 ; S bullet 0 - rapid fire
    .byte $40,$00 ; S bullet 1 - rapid fire
    .byte $c0,$ff ; S bullet 2 - rapid fire
    .byte $80,$00 ; S bullet 3 - rapid fire
    .byte $80,$ff ; S bullet 4 - rapid fire

; determine appropriate indoor l bullet sprite code and attribute based on x position on screen
set_indoor_l_bullet_sprite:
    lda PLAYER_BULLET_X_POS,x
    ldy #$08                  ; y = #$08

@loop:
    cmp l_bullet_indoor_x_cutoff_tbl-1,y ; compare to x cutoff from table
    bcs @cutoff_found                    ; branch if l bullet X position > X cutoff from table
    dey
    bne @loop

@cutoff_found:
    lda l_bullet_indoor_sprite_code_tbl,y
    sta PLAYER_BULLET_SPRITE_CODE,x
    lda #$40                              ; #$40 specifies to flip l bullet sprite horizontally
    cpy #$04                              ; see if bullet x position is past midpoint of screen
    bcc @continue                         ; if on left half of screen flip l bullet sprite horizontally
    lda #$00                              ; on right half of screen, do not flip l bullet sprite horizontally

@continue:
    sta PLAYER_BULLET_SPRITE_ATTR,x ; store the l bullet sprite attribute if any reflection needed
    rts                             ; index #$00 of label is never read, so this is safe as rts

; table for indoor l bullet x cutoff to specify angle to make the l bullet (#$8 bytes)
; actually starts at one byte less
l_bullet_indoor_x_cutoff_tbl:
    .byte $40,$50,$60,$74,$8c,$a0,$b0,$c0

; table for indoor l bullet sprite codes, depending on bullet fired x position (#$9 bytes)
; sprite_23, sprite_82, sprite_83, sprite_84, sprite_92
l_bullet_indoor_sprite_code_tbl:
    .byte $92,$84,$83,$82,$23,$82,$83,$84,$92

; decrements PLAYER_BULLET_TIMER and if down to #$00,
; then move to bullet routine #$02 and set PLAYER_BULLET_TIMER to #$06
dec_bullet_delay_possibly_adv_routine:
    dec PLAYER_BULLET_TIMER,x   ; decrement PLAYER_BULLET_TIMER
    bne @exit                   ; exit if delay has not elapsed
    jmp set_bullet_routine_to_2 ; move to bullet routine 2 and reset PLAYER_BULLET_TIMER to #$06

@exit:
    rts

; unused #$2da bytes out of #$4,000 bytes total (95.54% full)
; unused 730 bytes out of 16,384 bytes total (95.54% full)
; filled with 730 #$ff bytes by contra.cfg configuration
bank_6_unused_space: