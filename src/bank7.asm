; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 7 is the core of the game's programming. Reset, NMI, and IRQ vectors are
; in this bank and is the entry point to the game.  Bank 7 is always loaded in
; memory unlike other banks, which are memory-mapped and can be swapped out.
; Bank 7 contains the code for drawing of nametables and sprites, bank
; switching, routines for the intro sequence, controller input, score
; calculation, graphics decompression routines, palette codes, collision
; detection, pointer table for enemy routines, shared enemy logic, score table,
; enemy attributes, and bullet angles and speeds, and the NES undocumented
; footer, among other things.

.segment "BANK_7"

.include "constants.asm"

; import labels needed from other banks
; this allows bank 7 to call into other banks

; bank 0 imports - enemy routines
; bank 0 level 1 enemies
.import bomb_turret_routine_ptr_tbl
.import boss_wall_plated_door_routine_ptr_tbl
.import exploding_bridge_routine_ptr_tbl

; bank 0 level 2 and 4 enemies
.import boss_eye_routine_ptr_tbl
.import roller_routine_ptr_tbl
.import grenade_routine_ptr_tbl
.import wall_turret_routine_ptr_tbl
.import wall_core_routine_ptr_tbl
.import indoor_soldier_routine_ptr_tbl
.import jumping_soldier_routine_ptr_tbl
.import grenade_launcher_routine_ptr_tbl
.import four_soldiers_routine_ptr_tbl
.import indoor_soldier_gen_routine_ptr_tbl
.import indoor_roller_gen_routine_ptr_tbl
.import eye_projectile_routine_ptr_tbl
.import boss_gemini_routine_ptr_tbl
.import spinning_bubbles_routine_ptr_tbl
.import blue_soldier_routine_ptr_tbl
.import red_soldier_routine_ptr_tbl
.import red_blue_soldier_gen_routine_ptr_tbl

; bank 0 level 3 enemies
.import floating_rock_routine_ptr_tbl
.import moving_flame_routine_ptr_tbl
.import rock_cave_routine_ptr_tbl
.import falling_rock_routine_ptr_tbl
.import boss_mouth_routine_ptr_tbl
.import dragon_arm_orb_routine_ptr_tbl

; bank 0 level 5 enemies
.import ice_grenade_generator_routine_ptr_tbl
.import ice_grenade_routine_ptr_tbl
.import tank_routine_ptr_tbl
.import ice_separator_routine_ptr_tbl
.import boss_ufo_routine_ptr_tbl
.import mini_ufo_routine_ptr_tbl
.import boss_ufo_bomb_routine_ptr_tbl

; bank 0 level 6 enemies
.import fire_beam_down_routine_ptr_tbl
.import fire_beam_left_routine_ptr_tbl
.import fire_beam_right_routine_ptr_tbl
.import boss_giant_soldier_routine_ptr_tbl
.import boss_giant_projectile_routine_ptr_tbl

; bank 0 level 7 enemies
.import claw_routine_ptr_tbl
.import rising_spiked_wall_routine_ptr_tbl
.import spiked_wall_routine_ptr_tbl
.import mine_cart_generator_routine_ptr_tbl
.import moving_cart_routine_ptr_tbl
.import immobile_cart_generator_routine_ptr_tbl
.import boss_door_routine_ptr_tbl
.import boss_mortar_routine_ptr_tbl
.import boss_soldier_generator_routine_ptr_tbl

; bank 0 level 8 enemies
.import alien_guardian_routine_ptr_tbl
.import alien_fetus_routine_ptr_tbl
.import alien_mouth_routine_ptr_tbl
.import white_blob_routine_ptr_tbl
.import alien_spider_routine_ptr_tbl
.import alien_spider_spawn_routine_ptr_tbl
.import boss_heart_routine_ptr_tbl

; bank 0 enemies that exist on multiple levels
.import enemy_bullet_routine_ptr_tbl
.import rotating_gun_routine_ptr_tbl
.import red_turret_routine_ptr_tbl
.import sniper_routine_ptr_tbl
.import soldier_routine_ptr_tbl
.import weapon_box_routine_ptr_tbl
.import weapon_item_routine_ptr_tbl
.import flying_capsule_routine_ptr_tbl

; bank 1 imports
.import draw_sprites, init_pulse_and_noise_channels
.import init_sound_code_vars, handle_sound_slots

; bank 2 imports
.import level_headers, graphic_data_02
.import alt_graphic_data_00, alt_graphic_data_01
.import alt_graphic_data_02, alt_graphic_data_03
.import alt_graphic_data_04
.import level_2_4_boss_supertiles_screen_ptr_table
.import load_screen_enemy_data
.import set_players_paused_sprite_attr
.import set_player_sprite_and_attrs
.import exe_soldier_generation

; bank 3 imports
.import level_1_nametable_update_supertile_data, level_1_nametable_update_palette_data
.import level_2_nametable_update_supertile_data, level_2_nametable_update_palette_data
.import level_3_nametable_update_supertile_data, level_3_nametable_update_palette_data
.import level_4_nametable_update_supertile_data, level_4_nametable_update_palette_data
.import level_5_nametable_update_supertile_data, level_5_nametable_update_palette_data
.import level_6_nametable_update_supertile_data, level_6_nametable_update_palette_data
.import level_7_nametable_update_supertile_data, level_7_nametable_update_palette_data
.import level_8_nametable_update_supertile_data, level_8_nametable_update_palette_data
.import level_2_4_nametable_update_supertile_data, level_2_4_boss_nametable_update_palette_data
.import level_2_4_boss_palette_data, run_end_level_sequence_routine
.import level_1_supertile_data, level_2_supertile_data, level_3_supertile_data
.import level_5_supertile_data, level_8_supertile_data
.import level_2_4_boss_supertile_data, level_2_4_tile_animation
.import level_6_tile_animation, level_7_tile_animation

; bank 4 imports
.import graphic_data_01, graphic_data_03
.import graphic_data_04, graphic_data_06
.import graphic_data_08, graphic_data_09
.import graphic_data_0a, graphic_data_0f
.import graphic_data_10, graphic_data_11
.import graphic_data_12, graphic_data_13
.import run_game_end_routine

; bank 5 imports
.import load_demo_input_table
.import graphic_data_05, graphic_data_07
.import graphic_data_0b, graphic_data_14
.import graphic_data_17, graphic_data_18
.import graphic_data_19, graphic_data_1a

; bank 6 imports
.import short_text_pointer_table
.import graphic_data_0c, graphic_data_0d
.import graphic_data_0e, graphic_data_15
.import graphic_data_16
.import run_player_bullet_routines, check_player_fire

; export labels for use by other banks
; labels need by bank 0
; - needed for enemy routines
.export load_bank_3_update_nametable_supertile
.export load_bank_3_update_nametable_tiles, load_palettes_color_to_cpu
.export get_cart_bg_collision, wall_core_routine_05, boss_defeated_routine
.export enemy_routine_init_explosion, mortar_shot_routine_03
.export set_enemy_delay_adv_routine, advance_enemy_routine, roller_routine_04
.export shared_enemy_routine_03, enemy_routine_explosion
.export enemy_routine_remove_enemy, shared_enemy_routine_clear_sprite
.export set_enemy_routine_to_a, update_enemy_pos
.export update_enemy_x_pos_rem_off_screen, set_enemy_y_vel_rem_off_screen
.export set_outdoor_weapon_item_vel, add_scroll_to_enemy_pos
.export set_enemy_velocity_to_0, set_enemy_y_velocity_to_0
.export set_enemy_x_velocity_to_0, reverse_enemy_x_direction
.export set_destroyed_enemy_routine, destroy_all_enemies
.export clear_supertile_bg_collision, set_supertile_bg_collision
.export set_supertile_bg_collisions, create_explosion_89
.export create_two_explosion_89, create_enemy_for_explosion, level_boss_defeated
.export set_delay_remove_enemy, disable_bullet_enemy_collision
.export disable_enemy_collision, enable_enemy_player_collision_check
.export enable_bullet_enemy_collision, enable_enemy_collision
.export add_a_to_enemy_y_pos, add_a_to_enemy_x_pos, set_08_09_to_enemy_pos
.export add_with_enemy_pos, add_10_to_enemy_y_fract_vel
.export add_a_to_enemy_y_fract_vel, generate_enemy_a, generate_enemy_at_pos
.export add_4_to_enemy_y_pos, add_a_with_vert_scroll_to_enemy_y_pos
.export update_nametable_tiles_set_delay, draw_enemy_supertile_a_set_delay
.export draw_enemy_supertile_a, update_2_enemy_supertiles
.export update_enemy_nametable_tiles_no_palette, update_enemy_nametable_tiles
.export check_enemy_collision_solid_bg, init_vars_get_enemy_bg_collision
.export add_y_to_y_pos_get_bg_collision, add_a_y_to_enemy_pos_get_bg_collision
.export set_flying_capsule_y_vel, set_flying_capsule_x_vel
.export red_turret_find_target_player, player_enemy_x_dist
.export find_far_segment_for_x_pos, find_far_segment_for_a
.export set_enemy_falling_arc_pos, set_weapon_item_indoor_velocity
.export find_next_enemy_slot, clear_sprite_clear_enemy_pt_3
.export clear_enemy_custom_vars, initialize_enemy, aim_and_create_enemy_bullet
.export bullet_generation, create_enemy_bullet_angle_a, set_bullet_velocities
.export aim_var_1_for_quadrant_aim_dir_01, aim_var_1_for_quadrant_aim_dir_00
.export get_rotate_00, get_rotate_01
.export get_rotate_dir, dragon_arm_orb_seek_should_move
.export get_quadrant_aim_dir_for_player, remove_enemy

; labels needed by bank 2
.export get_bg_collision, remove_all_enemies, find_next_enemy_slot_6_to_0
.export find_bullet_slot

; labels needed by bank 3
.export set_graphics_zero_mode, set_a_as_current_level_routine

; labels needed by bank 4
.export advance_graphic_read_addr, decrement_delay_timer
.export init_APU_channels, init_game_routine_reset_timer_low_byte
.export load_A_offset_graphic_data, load_alternate_graphics
.export load_palette_indexes, play_sound
.export reset_delay_timer, run_routine_from_tbl_below
.export zero_out_nametables

; labels needed by bank 6
.export set_vel_for_speed_vars, set_bullet_routine_to_2

; labels needed by multiple banks
.export run_routine_from_tbl_below ; bank 2, 3, 4, 6
.export init_APU_channels          ; bank 0, 4
.export get_bg_collision_far       ; bank 0, 6
.export play_sound                 ; bank 0, 1, 2, 4, 6

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $07 ; The PRG ROM bank number (7)

; interrupt called when the NES starts up, or the reset button is pressed
reset_vector:
    cld ; disable decimal mode (NES chip 2A03 doesn't use decimal mode)
    sei ; disable interrupts

wait_til_vblank:
    lda PPUSTATUS       ; read PPU status with the following bit layout -> VSO- ----
    bpl wait_til_vblank ; Wait until V is 1 (accumulator is negative), i.e. in vertical blank VBLANK

vertical_blank_entry:
    lda PPUSTATUS            ; read PPU status with bit layout -> VSO- ----
    bpl vertical_blank_entry ; ensure still in VBLANK
    lda #$00                 ; clear accumulator
    sta GAME_ROUTINE_INDEX   ; set the game routine index so that game is in game_routine_00
                             ; unnecessary because clear_memory below will also set the value to #$00
    jsr clear_ppu            ; initialize PPU
    ldx #$ff
    txs                      ; initialize stack pointer location to $01ff, stack range is from $01ff down to $0100 (descending stack)
                             ; clear (zero out) memory range $0000-$01bf and $0200-$07df
    lda #$01                 ; high byte of max memory address to clear
    ldx #$01                 ; number of #$ff-sized blocks of memory to clear
    ldy #$bf                 ; low byte of max memory address to clear
    jsr clear_memory         ; clear memory range $0000-$01bf
    lda #$07                 ; high byte of max memory address to clear
    ldx #$05                 ; number of #$ff-sized blocks of memory to clear
    ldy #$df                 ; low byte of max memory address to clear
    jsr clear_memory         ; clear memory range $0200-$07df
    ldx #$f0

@loop:
    txa
    cmp CPU_GRAPHICS_BUFFER,x        ; compare A (#$f0) to cpu memory $07f0
    bne init_07f0_through_high_score ; branch if is A #$f0 not equal to memory address $07f0
    inx                              ; !(OBS) not sure if this line is ever executed
    bne @loop                        ; !(OBS) not sure if this line is ever executed
    beq init_APU_and_PPU             ; !(OBS) not sure if this line is ever executed

; initialize memory $07f0-$07ff to be #$f0 to #$ff respectively
init_07f0_through_high_score:
    ldx #$f0

@loop:
    txa
    sta CPU_GRAPHICS_BUFFER,x ; initialize $07f0 to $f0, $07f1 to $f1, etc. until $07ff !(WHY?)
                              ; don't think this range is used ever $07f0-$07ff
    inx
    bne @loop
    lda #$c8                  ; default high score is 20,000
    sta HIGH_SCORE_LOW        ; store low byte of high score in HIGH_SCORE_LOW
    lda #$00
    sta HIGH_SCORE_HIGH       ; store high byte of high score (#$00)

init_APU_and_PPU:
    lda #$00
    sta CPU_GRAPHICS_BUFFER
    jsr init_APU
    jsr init_APU_channels
    jsr configure_PPU

; run between NMI interrupts after nmi_start code finishes
; loop forever updating RANDOM_NUM before NMI
forever_loop:
    lda FRAME_COUNTER ; load frame counter
    adc RANDOM_NUM    ; add the frame number to RANDOM_NUM
    sta RANDOM_NUM    ; update RANDOM_NUM to new result
    jmp forever_loop

; NMI entry point, beginning of vertical blanking interval. This happens once per video frame and is triggered by PPU.
; The PPU is available for graphics updates
; The NES will automatically clear the screen so you do not have to worry about trying to clear it with code.
; The end of all the game code will end at RTI (return from interrupt).
nmi_start:
    php                                  ; push processor status to stack #$02 bytes (NV--DIZC)
    pha                                  ; push A on to the stack
    txa                                  ; transfer X to A
    pha                                  ; push A on to the stack
    tya                                  ; transfer Y to A
    pha                                  ; push A on to the stack
    lda PPUSTATUS                        ; reset PPU latch
    ldy NMI_CHECK                        ; see if nmi interrupted previous frame's game loop
    bne handle_sounds_set_ppu_scroll_rti ; branch if nmi occurred before game loop was completed to skip game loop
                                         ; instead just continue playing sounds, set ppu scroll, and rti
                                         ; previously unfinished frame will finish after rti and then itself rti
    jsr clear_ppu                        ; re-init PPU
    sta OAMADDR                          ; set OAM address to #00 (DMA is used instead)
    ldy #>OAMDMA_CPU_BUFFER              ; setting OAMDMA to #$02 tells PPU to load sprite data from $0200-$02ff
    sty OAMDMA                           ; write #$100 (256 decimal) bytes ($0200 to $02ff) of data to PPU OAM (the entire screen)
    jsr write_palette_colors_to_ppu      ; writes the colors for all the palettes defined in CPU memory to the PPU $3f00 to $3f1f
    jsr write_cpu_graphics_buffer_to_ppu ; draw the graphic data in memory at CPU_GRAPHICS_BUFFER to the PPU
    lda PPUMASK_SETTINGS                 ; load settings for PPUMASK (#$1e)
    ldx PPU_READY                        ; every time configure_PPU is called, PPU_READY is set to #$05
                                         ; this confirms that at least 5 nmi interrupts have happened
                                         ; since the last configure_PPU was called
    beq @continue                        ; PPU_READY is #$00, so continue setup
    dec PPU_READY                        ; decrement PPU load loop (starts at #$05)
    beq @continue                        ; PPU_READY is now #$00, so continue setup
    lda #$00                             ; set PPUMASK to #$00 since PPU isn't ready

@continue:
    sta PPUMASK                        ; set PPU mask, either #$00 to clear or #$1e (from PPUMASK_SETTINGS) when PPU ready
    jsr set_ppu_addr_to_nametables     ; set the PPU write address to $2000 to write the pattern table tile data
    inc NMI_CHECK                      ; entering important part of game loop, set to #$01
                                       ; if next NMI occurs before set back to #$00, then game engine knows logic was
                                       ; interrupted before completing. This is not good but does regularly occur
                                       ; at beginning of levels when clearing memory
    ldy #$01
    jsr load_bank_number               ; load bank 1
    jsr handle_sound_slots             ; loop through sound slots and execute appropriate sound codes
    jsr load_controller_state          ; read controller for p1 and p2, stores results into memory
    jsr exe_game_routine               ; go into game routine loop
    ldy #$01
    jsr load_bank_number               ; load bank 1
    jsr draw_sprites                   ; bank 1
    jsr write_0_to_cpu_graphics_buffer
    lda #$00
    sta NMI_CHECK                      ; successfully rendered full frame before NMI, mark flag appropriately

remove_registers_from_stack_and_rti:
    pla ; remove byte from stack
    tay ; store in y
    pla ; remove byte from stack
    tax ; store in x
    pla ; remove byte stack
    plp ; set cpu flags from stack

; end of CPU code execution for the frame
irq:
    rti ; return to forever_loop until nmi is triggered again
        ; rti pops the processor flags and then the program counter
        ; then starts executing at that location

; NMI_CHECK is non-zero, meaning the previous frame's game loop was interrupted
handle_sounds_set_ppu_scroll_rti:
    lda PPUMASK_SETTINGS ; load settings for PPUMASK
    ldx PPU_READY        ; load PPU status (#$00 is ready)
    beq @handle_sound    ; if ready keep PPU mask setting of #$1e
    lda #$00             ; clear PPUMASK

@handle_sound:
    sta PPUMASK
    lda BANK_NUMBER        ; get currently loaded switchable bank number
    pha                    ; backup bank number
    lda NMI_CHECK          ; see if nmi interrupted while loading sound variables (play_sound)
    bmi @continue          ; jump if NMI_CHECK is negative to skip handling sound entry
    ldy #$01
    jsr set_rom_bank_to_y  ; swap PRG ROM bank to 01
    jsr handle_sound_slots ; loop through sound slots and execute appropriate sound codes

@continue:
    pla                                     ; pull previous bank from stack
    tay                                     ; store in y
    jsr set_rom_bank_to_y
    jsr set_ppu_scroll
    jmp remove_registers_from_stack_and_rti

; initialize the audio processing unit
; NES APU has 5 channels, Contra uses 4 of them
; * disable DMC (data modulation channel)
; * enable noise channel (static sound)
; * enable triangle channel (triangle wave)
; * enable pulse 1 channel (pulse wave)
; * enable pulse 2 channel (pulse wave)
init_APU:
    lda #$0f            ; 0000 1111 in binary
    sta APU_STATUS
    lda #$c0            ; 1100 0000 in binary
    sta APU_FRAME_COUNT ; set frame sequencer for frame counter to 5 step sequence (~192 Hz)
                        ; clear frame interrupt flag
    rts

; configures the PPU to the following settings
; base nametable address: $2000
; VRAM address increment: add 1 going across
; 8x8 sprite pattern table address (ignored since using 8x16 sprites)
; background pattern table address: $1000 (right pattern table)
; sprite size: 8x16 pixels
; generate NMI at start of VBLANK
; actually fills nametable with sprites and palettes
configure_PPU:
    lda #$05             ; set a to #$05
    sta PPU_READY        ; store into PPU_READY, prevents writes to PPUMASK until 5 nmi_start executions
    lda #$b0             ; set a to %1011 0000
    sta PPUCTRL_SETTINGS ; store a into $ff
    sta PPUCTRL
    lda #$05
    sta PPU_READY        ; set PPU_READY to #$05
    rts

; set PPU write address to $2000. This is the start of the nametables in the PPU
set_ppu_addr_to_nametables:
    lda PPUSTATUS ; read PPUSTATUS to reset PPU latch
                  ; setting the PPUADDR takes two writes, one for high byte and one for low
    lda #$20      ; load high byte of address
    sta PPUADDR
    lda #$00      ; load low byte of address
    sta PPUADDR

set_ppu_scroll:
    lda PPUSTATUS         ; clear bit 7 and address latch used by PPUSCROLL and PPUADDR
    lda HORIZONTAL_SCROLL ; load horizontal component of the PPUSCROLL [#$0 - #$ff]
    sta PPUSCROLL         ; write X position
    lda VERTICAL_SCROLL
    sta PPUSCROLL         ; write Y position
    lda PPUCTRL_SETTINGS  ; saved PPUCTRL settings (see configure_PPU)
    sta PPUCTRL
    rts

clear_ppu:
    lda #$00    ; setting the PPUADDR takes two writes, one for high byte and one for low
    sta PPUADDR ; write $00 high byte
    sta PPUADDR ; write $00 low byte
    sta PPUCTRL ; clear PPUCTRL
    sta PPUMASK ; clear PPUMASK
    rts

; clears blocks of CPU memory
; starts with a Y byte sized block of memory starting at A
; then clears #$ff * X byte-sized blocks of memory preceding A
clear_memory:
    sta $01  ; set pointer to beginning of addresses to clear
    lda #$00 ; set $00 to use to clear
    sta $00  ; store #$00 to $00

@loop:
    sta ($00),y ; clear memory address Y-bytes away from address stored in $00 and $01
    dey
    cpy #$ff    ; #FF is equivalent to -1 here, loop until Y is -1
    bne @loop
    dec $01     ; decrement to next #$ff-sized block of memory to clear
    dex         ; decrement number of blocks to clear counter
    bpl @loop   ; clear the next #$ff block of bytes
    rts

; ROM address $c139
; backs up the currently-loaded bank number into PREVIOUS_ROM_BANK ($07ec)
; updates the currently-loaded bank to Y
load_bank_number:
    lda BANK_NUMBER       ; load the currently-loaded bank number (address $8000)
                          ; first byte of every bank is the bank number
    sta PREVIOUS_ROM_BANK ; save bank number to $07ec

; updates the active PRG ROM bank to bank specified by y
; CPU address $c139
; swaps out the ROM available to CPU for addresses $8000 to $bfff
; this is because contra is a UxROM mapper, which swaps the active
; bank when detecting a write to CPU address between $8000 and $ffff inclusively
; the bank swapped in is the bank of the lowest 4 bits
set_rom_bank_to_y:
    lda prg_rom_banks,y ; grab the bank number (should match y)
    sta prg_rom_banks,y ; set the active bank number
    rts

; loads the previously-loaded ROM bank specified in $07ec (PREVIOUS_ROM_BANK)
load_previous_bank:
    ldy PREVIOUS_ROM_BANK
    jmp set_rom_bank_to_y

; loads bank 1 into switchable memory without losing values of A and Y
load_bank_1:
    pha                     ; save a to stack
    tya                     ; transfer y to a
    pha                     ; save a (y) to stack
    lda BANK_NUMBER         ; load currently loaded switchable rom number
    sta PREVIOUS_ROM_BANK_1 ; set PREVIOUS_ROM_BANK_1 to match loaded bank
    ldy #$01
    jsr set_rom_bank_to_y   ; load ROM BANK 1
    pla                     ; restore a (y) from stack
    tay                     ; move a to y
    pla                     ; restore a from stack
    rts

; loads the bank specified in PREVIOUS_ROM_BANK_1 without losing values of A and Y
; !(WHY?) not sure why there are 2 variables to store the previous bank, both used differently
local_previous_1_bank:
    pha                     ; save a to stack
    tya
    pha                     ; save y to stack
    ldy PREVIOUS_ROM_BANK_1
    jsr set_rom_bank_to_y
    pla                     ; pull y from stack
    tay
    pla                     ; pull a from stack
    rts

; CPU address $c16b
; input
;  * a - the sound code to play
play_sound:
    pha                       ; push sound code to stack
    lda NMI_CHECK             ; load NMI_CHECK flag, should always be #$01 here
    ora #$80                  ; ensure most significant bit is set (1)
    sta NMI_CHECK             ; while bank 1 is loaded and inside init_sound_code_vars
    pla                       ; pop sound code back from stack
    jsr load_bank_1
    jsr init_sound_code_vars  ; bank 1
    jsr local_previous_1_bank ; load PREVIOUS_ROM_BANK_1
    lda NMI_CHECK             ; load NMI_CHECK flag, should always be #$81 here
    and #$7f                  ; finished with init_sound_code_vars, clear bit 7
    sta NMI_CHECK             ; reset NMI_CHECK flag back to #$01
    rts

init_APU_channels:
    sty $f7                           ; backup Y in $f7
    ldy #$01
    jsr load_bank_1
    jsr init_pulse_and_noise_channels ; bank 1, sets pulse channel duty cycle, volume, and sweep data, mute noise channel
    jsr local_previous_1_bank         ; load PREVIOUS_ROM_BANK_1
    ldy $f7                           ; restore Y back from $f7
    rts

; draw super-tile $10 at position (a,y)
; redraws parts of the nametable for things like bridge explosions,
; nametable enemy explosions, animation (pill box sensor), etc.
; also used to draw palette colors for super-tiles
; input
;  * a is x position of nametable super-tile in pixels
;  * y is y position of nametable super-tile in pixels
;  * $10 is the super-tile or palette index to draw (level_x_nametable_update_supertile_data/level_x_nametable_update_palette_data offset)
;   If bit 7 clear, then update palette, if bit 7 set do not update palette
; output
;  * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
load_bank_3_update_nametable_supertile:
    sta $f3                        ; save a value before swapping banks
    sty $f7                        ; save y value before swapping banks
    ldy #$03                       ; y = #$03
    jsr load_bank_number           ; load bank y (03)
    lda $f3                        ; restore a value
    ldy $f7                        ; restore y value
    jsr update_nametable_supertile ; draw super-tile $10 at position (a,y)
    jmp load_previous_bank         ; load previous bank

; load bank 3 and update_nametable_tiles
; indoor/base levels for drawing wall turrets, and changing to explosion when destroyed
; input
;  * a is x position
;  * y is y position
;  * $10 (multiplied by #$05) is the index into the tile animation table to start drawing
;    if bit 7 clear, then update palette, if bit 7 set do not update palette
; output
;  * carry - clear when successful, set when CPU_GRAPHICS_BUFFER is full
load_bank_3_update_nametable_tiles:
    sta $f3                    ; backup a in $f3
    sty $f7                    ; backup y in $f7
    ldy #$03                   ; y = #$03
    jsr load_bank_number       ; switch to bank y (03)
    lda $f3                    ; restore a from $f3
    ldy $f7                    ; restore y from $f7
    jsr update_nametable_tiles
    jmp load_previous_bank

; various tasks with different banks
load_bank_6_run_player_bullet_routines:
    ldy #$06                       ; y = #$06
    jsr load_bank_number           ; switch bank to 06
    jmp run_player_bullet_routines ; CPU address $b94a

; switch to bank 6 and see if player is trying to shoot
; if so and player should be able to fire, then generate bullet
load_bank_6_check_player_fire:
    ldy #$06              ; y = #$06
    jsr load_bank_number  ; switch bank to 06
    jmp check_player_fire ; generate bullet if player is shooting and allowed to shoot

load_bank_0_exe_all_enemy_routine:
    ldy #$00                  ; y = #$00
    jsr load_bank_number      ; switch bank to 00
    jmp exe_all_enemy_routine

; enemy generation
load_bank_2_load_screen_enemy_data:
    ldy #$02                   ; y = #$02
    jsr load_bank_number       ; switch bank to 02
    jmp load_screen_enemy_data ; CPU address $b419

; get table pointer for level-specific enemy routines
; ensure enemy routines bank (bank 00) is loaded
load_bank_0_load_level_enemies_to_mem:
    ldy #$00                      ; y = #$00
    jsr load_bank_number          ; switch bank to 00
    jmp load_level_enemies_to_mem ; load the pointer to the level-specific enemy routines to $80

; soldier generation
load_bank_2_exe_soldier_generation:
    ldy #$02                   ; y = #$02
    jsr load_bank_number       ; switch bank to 02
    jmp exe_soldier_generation ; CPU address $b523

; handles scrolling for the level if currently scrolling
; including writing tiles to nametable, writing to the attribute table, and loading alternate graphics
; includes handling auto scroll from boss reveal or tank
load_bank_3_handle_scroll:
    ldy #$03             ; y = #$03
    jsr load_bank_number ; switch bank to 03
    jmp handle_scroll    ; handles scroll for level if currently scrolling

; load bank 3 and execute init_lvl_nametable_animation
; output
;  * zero flag - set when LEVEL_TRANSITION_TIMER has elapsed, clear otherwise
load_bank_3_init_lvl_nametable_animation:
    ldy #$03                         ; y = #$03
    jsr load_bank_number             ; switch bank to 03
    jmp init_lvl_nametable_animation ; animate initial level nametable drawing

; load alternate tiles if necessary
load_bank_2_alternate_tile_loading:
    ldy #$02                   ; y = #$02
    jsr load_bank_number       ; switch bank to 02
    jmp alternate_tile_loading ; alternate tiles loading code

load_level_graphics:
    jmp load_current_level_graphic_data

; loads the graphic data for the level specified by offset into level_graphic_data_tbl (A register)
load_A_offset_graphic_data:
    jmp load_level_graphic_data

load_bank_2_set_player_sprite:
    ldy #$02
    jsr load_bank_number
    jmp set_player_sprite_and_attrs ; set player sprite based on player state, level, and animation sequence

; game paused, jump set_players_paused_sprite_attr
load_bank_2_set_players_paused_sprite_attr:
    ldy #$02
    jsr load_bank_number               ; load bank 2
    jmp set_players_paused_sprite_attr ; ensure player sprite attributes continue while paused, e.g. flashing while invincible, electrocuted, etc.

; loaded from bank #6
; write pattern tile (text) or palette information (color) to CPU offset CPU_GRAPHICS_BUFFER
; this is used when GRAPHICS_BUFFER_MODE is #$00, which defines the CPU_GRAPHICS_BUFFER format for text and palette data
; input
;  * a - first six bits are index into the short_text_pointer_table
;  when bit 7 set, write all blank characters instead of actual characters. Used for flashing effect
load_bank_6_write_text_palette_to_mem:
    sta $f3                       ; store the specific text/palette to load into $f3
    ldy #$06
    jsr load_bank_number          ; load bank 6
    lda $f3                       ; load_bank_number sets A to the bank number, so reset it back to the item to load
    jmp write_text_palette_to_mem

; game routines - pointer 6
; runs at the end of the game after defeating the alien
; runs end of game routines, and end of game sequence routines
; melts screen, ending helicopter animation and credits
game_routine_06:
    ldy #$04                 ; y = #$04
    jsr load_bank_number     ; switch bank to y (04)
    jmp run_game_end_routine ; CPU address $b8b9

; loads bank five and execute procedure to simulate player input for demo
simulate_input_for_demo:
    ldy #$05                  ; y = #$05
    jsr load_bank_number      ; switch bank to y (05)
    jmp load_demo_input_table ; label from bank 5

load_bank_3_run_end_lvl_sequence_routine:
    ldy #$03                           ; y = #$03
    jsr load_bank_number               ; switch bank to y (03)
    jmp run_end_level_sequence_routine ; CPU address $bdfa

; determine which game routine to run and run it
; checks if player presses start to early exit animation
exe_game_routine:
    inc FRAME_COUNTER                    ; increment frame counter
    lda GAME_ROUTINE_INDEX               ; index into game_routine_pointer_table
    beq run_game_routine                 ; run game_routine_00 if GAME_ROUTINE_INDEX is 0, run only once to initialize intro
    cmp #$03
    bcs run_game_routine                 ; skip decrementing timer if GAME_ROUTINE_INDEX >= 3
                                         ; timer is used for only intro animation and when showing demos
    jsr dec_theme_delay_check_user_input ; decrements animation timers, checks for early exit, player mode change etc, if not fall through

; run game routine for specified GAME_ROUTINE_INDEX
run_game_routine:
    lda GAME_ROUTINE_INDEX         ; offset into game_routine_pointer_table to execute
    jsr run_routine_from_tbl_below ; run routine a in the following table (game_routine_pointer_table)

; pointer table to code to run for game routines ($0E bytes total)
; CPU address $c24d
game_routine_pointer_table:
    .addr game_routine_00 ; CPU address $c25b (initial intro scrolling)
    .addr game_routine_01 ; CPU address $c274 (play sound and load Bill and Lance, show menu, konami check)
    .addr game_routine_02 ; CPU address $c2b1 (wait for input until timer expires, then start demo)
    .addr game_routine_03 ; CPU address $c2c7 (player pressed start to start game (1p or 2p))
    .addr game_routine_04 ; CPU address $c2f4 (clears player state and sprite data)
    .addr game_routine_05 ; CPU address $ce30 (run level_routine execution, for actual playing of level, or demo)
    .addr game_routine_06 ; CPU address $c223 (runs at the end of the game after defeating the alien)

; The 1st game routine game_routine_pointer_table
; this label initializes the intro scrolling effect
game_routine_00:
    jsr zero_out_nametables         ; initialize nametables 0 and 1 to zeroes
    jsr load_intro_graphics         ; load the graphic data (pattern, nametable, and palette) to ppu, as well as palette data to cpu
    ldy #$00                        ; y = #$00
    sty KONAMI_CODE_NUM_CORRECT     ; initialize konami check to #$0 (see konami_input_check)
.ifdef Probotector
    sty HORIZONTAL_SCROLL           ; initialize the horizontal scroll offset to #$00
    ldy #$02
    sty DELAY_TIME_HIGH_BYTE        ; initialize delay high byte to #$02 (used for various delays)
    lda #$b0                        ; %1011 0000 (set nametable to $2000)
    sta PPUCTRL_SETTINGS            ; store PPUCTRL settings for next update of PPUCTRL
    jmp inc_routine_index_set_timer ; move to game_routine_01
.else
    iny
    sty HORIZONTAL_SCROLL           ; initialize the horizontal scroll offset to #$01
    iny
    sty DELAY_TIME_HIGH_BYTE        ; initialize delay high byte to #$02 (used for various delays)
    lda #$b1                        ; %1011 0001 (set nametable to $2400)
    sta PPUCTRL_SETTINGS            ; store PPUCTRL settings for next update of PPUCTRL
    jmp inc_routine_index_set_timer ; move to game_routine_01
.endif

; table for y positions of intro screen cursor
; same table is used for "CONTINUE"/"END" screen during game over
player_select_cursor_pos:
.ifdef Probotector
    .byte $9a,$aa
.else
    .byte $a2,$b2
.endif

; The 2nd game routine game_routine_pointer_table
; run once per frame for multiple frames while scrolling to right until intro screen is shown
; when scrolling complete, plays intro "explosion" sound and loads player select menu
game_routine_01:
    jsr konami_input_check                   ; check if current input is part of Konami code (30-lives code)
                                             ; if completed input successfully, sets KONAMI_CODE_STATUS to #$01
.ifdef Probotector
    ldx GAME_ROUTINE_INIT_FLAG               ; see if current game_routine has initialized
    bne game_routine_01_scroll_complete      ; no scrolling animation is done for Probotector
                                             ; skip to complete if sound has played and routine is 'initialized'
    jsr load_intro_palette2_play_intro_sound
    lda #$26                                 ; a = #$26 (game intro tune)
    jsr play_sound                           ; play sound_26 (game intro tune)
    inc GAME_ROUTINE_INIT_FLAG               ; mark game routine as initialized
    rts                                      ; exit
.else
    lda HORIZONTAL_SCROLL                    ; load horizontal component of the PPUSCROLL [#$0 - #$ff]
    beq game_routine_01_scroll_complete      ; if scroll complete, show Bill and Lance and play sound
    inc HORIZONTAL_SCROLL                    ; add 1 to the horizontal scroll offset
    bne game_routine_01_exit                 ; if scrolling animation isn't complete, continue scrolling next frame
    jsr load_intro_palette2_play_intro_sound ; scrolling complete, load 2nd intro background palette and play explosion sound
.endif

; write the text "PLAY SELECT", "1 PLAYER", player select cursor, etc
; move to next game_routine once timer elapses
game_routine_01_scroll_complete:
.ifdef Probotector
    lda #$58                       ; a = #$58 (x position of cursor in intro)
.else
    lda #$2c                       ; a = #$2c (x position of cursor in intro)
.endif
    sta SPRITE_X_POS               ; store x position of cursor for player select (first sprite)
    lda #$aa                       ; sprite_aa: player selector cursor (yellow falcon)
    sta CPU_SPRITE_BUFFER          ; store sprite number in CPU buffer
    ldx PLAYER_MODE                ; number of players (0 = 1 player)
    lda player_select_cursor_pos,x ; load y position of cursor for player select
    sta SPRITE_Y_POS               ; store y position of cursor for player select
    lda #$00                       ; a = #$00
    sta SPRITE_ATTR                ; reset sprite effect for player
    lda #$ab                       ; sprite_ab: Bill and Lance's hair and shirt
    sta CPU_SPRITE_BUFFER+1        ; store next sprite to load
.ifdef Probotector
    lda #$80                       ; a = #$80 (x position for sprite_ab)
    sta SPRITE_X_POS+1             ; store x position for sprite_ab
    lda #$5f                       ; a = #$5f (y position for sprite_ab)
    sta SPRITE_Y_POS+1             ; store y position for sprite_ab
.else
    lda #$b3                       ; a = #$b3 (x position for sprite_ab)
    sta SPRITE_X_POS+1             ; store x position for sprite_ab
    lda #$77                       ; a = #$77 (y position for sprite_ab)
    sta SPRITE_Y_POS+1             ; store y position for sprite_ab
.endif
    jsr decrement_delay_timer      ; decrease delay and check if it reaches 0
    bne game_routine_01_exit       ; timer not complete, wait
    jmp increment_game_routine     ; timer delay complete, increase game_routine to game_routine_02

game_routine_01_exit:
    rts

; The 3rd game routine (see game_routine_pointer_table)
;  * loads demo level and plays the level
;  * stops level when demo timer elapsed and loads next level to demo (only levels 0-2)
;  * resets GAME_ROUTINE_INDEX to #$0 between demo levels to reshow intro scroll and player select
game_routine_02:
    ldx GAME_ROUTINE_INIT_FLAG ; determine if game routine has been "initialized"
    bne @continue              ; if GAME_ROUTINE_INIT_FLAG is already 1, no need to load level, continue with demo level
    inc GAME_ROUTINE_INIT_FLAG ; set GAME_ROUTINE_INIT_FLAG to indicate that demo level is loaded
    jmp set_next_demo_level    ; set memory addresses in preparation for next demo level

@continue:
    jsr run_level_routine_for_demo  ; execute level routine with offset of current value of LEVEL_ROUTINE_INDEX
    lda DEMO_LEVEL_END_FLAG         ; whether or not the demo for the level is complete
    beq game_routine_02_exit        ; demo not complete, continue showing demo
    lda #$00                        ; demo of level complete, move to next level to demo
    sta GRAPHICS_BUFFER_MODE        ; start to read from beginning of CPU_GRAPHICS_BUFFER (see write_cpu_graphics_buffer_to_ppu)
    beq set_game_routine_index_to_a ; reset GAME_ROUTINE_INDEX 0 to replay scrolling effect and player selection

; The 4th game routine (see game_routine_pointer_table)
; player pressed start to start game (1p or 2p)
game_routine_03:
    ldx GAME_ROUTINE_INIT_FLAG     ; load whether game_routine_03 has been initialized
    bne @continue                  ; level 1 data already set, continue
    lda #$00
    sta DEMO_MODE                  ; set DEMO_MODE to off
    lda #$40
    bne set_game_routine_init_flag ; (always jump due to lda in previous line) set timer low byte to #$40

@continue:
    jsr dec_intro_theme_delay
    lda DELAY_TIME_LOW_BYTE   ; various delays (low byte)
    beq @intro_timer_elapsed  ; if the timer low byte is complete, jump
    dec DELAY_TIME_LOW_BYTE   ; various delays (low byte)

@intro_timer_elapsed:
    ora INTRO_THEME_DELAY                     ; combine DELAY_TIME_LOW_BYTE with the intro theme (with explosion) sound delay
    beq increment_game_routine                ; if both the intro theme and the delay timer are #$00 (elapsed), increment to next game routine #$04
    lda #$01                                  ; a = #$01 (text_1_player)
    clc                                       ; clear carry in preparation for addition
    adc PLAYER_MODE                           ; number of players (0 = 1 player)
                                              ; if 2 player mode, index is updated to text_2_players
    sta $00                                   ; store player mode in $00
    lda #$08                                  ; a = #$08
    and FRAME_COUNTER                         ; flash #$08 frames at a time
    asl
    asl
    asl
    asl                                       ; if FRAME_COUNTER bit 3 was set, then bit 7 is set here
                                              ; indicating to blank the text (flashing animation)
    ora $00                                   ; merge with short_text_pointer_table offset (#$01 or #$02)
    jmp load_bank_6_write_text_palette_to_mem ; flash "1 PLAYER" or "2 PLAYER" depending on PLAYER_MODE

; The 5th game routine (see game_routine_pointer_table)
game_routine_04:
    jsr init_score_player_lives ; clear memory addresses $0028 to $00f0 then CPU_SPRITE_BUFFER to CPU_GRAPHICS_BUFFER
    jmp increment_game_routine

init_game_routine_reset_timer_low_byte:
    lda #$80 ; a = #$80

set_game_routine_init_flag:
    sta DELAY_TIME_LOW_BYTE    ; various delays (low byte)
    inc GAME_ROUTINE_INIT_FLAG ; set that the routine has been initialized
                               ; for game over routines, increments GAME_END_ROUTINE_INDEX (same memory address)

; also fall through from game_routine_03
game_routine_02_exit:
    rts

; sets low byte of delay timer to #$80 and increments game routine
inc_routine_index_set_timer:
    lda #$80                ; set default delay (low byte) for next routine (game_routine_01 or level_routine_06)
    sta DELAY_TIME_LOW_BYTE ; various delays (low byte)

increment_game_routine:
    inc GAME_ROUTINE_INDEX ; move to the next game_routine

; called every time the game_routine index is incremented
init_game_routine_flags:
    lda #$00
    sta DEMO_LEVEL_END_FLAG    ; clear DEMO_LEVEL_END_FLAG
    sta GAME_ROUTINE_INIT_FLAG ; reset GAME_ROUTINE_INIT_FLAG to #$00
    rts

; update GAME_ROUTINE_INDEX to A
; reset delay timer to #$0240
set_game_routine_index_to_a:
    sta GAME_ROUTINE_INDEX
    jsr reset_delay_timer       ; reset 2-byte delay timer to #$0240
    bne init_game_routine_flags

; decrement delay timer
; zero flag set (checked) when the timer has elapsed, otherwise zero flag will not be set
decrement_delay_timer:
    lda DELAY_TIME_LOW_BYTE  ; load the low byte of the delay timer
    ora DELAY_TIME_HIGH_BYTE ; OR it together with high byte
    beq @exit                ; all bits both high and low byte are #$0, exit with #$0 in a register, zero flag set
    dec DELAY_TIME_LOW_BYTE  ; decrease delay (loops below #$00 to #$ff)
    bne @exit                ; low byte isn't #$0, exit with zero flag clear
    lda DELAY_TIME_HIGH_BYTE ; low byte was #$0, check high byte
    beq @exit_z_flag_clear   ; high byte is #$0 as well, exit with #$01 in a register, zero flag clear
    dec DELAY_TIME_HIGH_BYTE ; high byte wasn't #$0, subtract 1 from it

@exit_z_flag_clear:
    lda #$01 ; ensures the zero flag is clear

@exit:
    rts

; set or reset delay before demo begins
; only if the intro screen is forced by pressing start/select
; NTSC is about #3c frames per second
; PAL is close to #$32 frames per second
; delay timer is strange in that once the high byte goes from #$01 to #$00, the low byte isn't rest to #$ff
; this means that although the timer is set to #$0240, the delay is only ~5 seconds (#$140 frames) and not ~9 seconds
reset_delay_timer:
    ldx #$40
    stx DELAY_TIME_LOW_BYTE  ; set low byte of timer to #$40
    ldx #$02
    stx DELAY_TIME_HIGH_BYTE ;set high byte of timer to #$02
    rts

; checks if current input is part of Kazuhisa Hashimoto's famous Konami code (30-lives code)
; if completed input successfully, set KONAMI_CODE_STATUS to #$01
konami_input_check:
    ldy KONAMI_CODE_NUM_CORRECT    ; load the number of successful inputs of Konami code
    bmi konami_code_exit           ; if #$ff (invalid Konami input), exit
    lda CONTROLLER_STATE_DIFF      ; buttons pressed (only care on input change so held button doesn't affect code)
    and #$cf                       ; only care about input from d-pad and A/B buttons (not select nor start)
    beq konami_code_exit           ; if no input detected, exit
    cmp konami_code_lookup_table,y ; compare with Konami code sequence at index y
    beq konami_input_index_correct ; on success, goto konami_input_index_correct
    lda #$ff                       ; incorrect sequence for Konami code
    sta KONAMI_CODE_NUM_CORRECT    ; since incorrect set KONAMI_CODE_NUM_CORRECT (number of successful inputs) to $ff
    rts

konami_input_index_correct:
    iny                         ; add to number of successfully entered Konami code inputs
    sty KONAMI_CODE_NUM_CORRECT ; store in KONAMI_CODE_NUM_CORRECT
    cpy #$0a                    ; Konami code is 10 inputs, compare against how many successfully entered
    bcc konami_code_exit        ; Konami code not yet fully entered, exit
    lda #$01                    ; Konami code successfully entered, set flag to $01
    sta KONAMI_CODE_STATUS      ; store success flag in memory

konami_code_exit:
    rts

; table for Konami code (30-lives code) - up up down down ...
konami_code_lookup_table:
    .byte $08,$08,$04,$04,$02,$01,$02,$01,$40,$80

; reads the controller for p1 and p2
; ultimately stores results into CONTROLLER_STATE,x and CONTROLLER_STATE_DIFF,x
; due to DMC channel DPCM (Delta Pulse Coded Modulation) bug in the APU, input is read twice to confirm
; if the inputs match then it is assumed to be a valid read, otherwise, uses last known good read
load_controller_state:
    jsr read_controller_state
    lda $04
    sta $00                   ; store p1 input in $00 in CPU memory
    lda $05
    sta $01                   ; store p2 input in $01 in CPU memory
    jsr read_controller_state ; re-read input to confirm it was not affected by DMC channel DPCM bug
    ldx #$01                  ; start with player 2

ensure_input_valid:
    lda $04,x             ; read player's input from second attempt to read
    cmp $00,x             ; compare to 1st attempt to read input
    beq @continue         ; if input matches continue, the read input is valid
    lda CTRL_KNOWN_GOOD,x ; read input is invalid, load last good value into a register
    sta $04,x             ; store previous good input into $04, can't trust just-read player input

@continue:
    dex
    bpl ensure_input_valid ; move from p1 to p1 and ensure p1's input is valid
    lda PLAYER_MODE_1D     ; see player_mode_1d_table (#$01 or #$07)
    and #$04               ; see if 2 player or single player (#$07 will have #$04 bit set)
    bne write_input        ; jump to store input to cpu memory if 2 player (PLAYER_MODE = #$01)
    lda $04                ; single player mode, merge both controller inputs into single input
                           ; this allows the player to play 1 player with the 2nd controller port
                           ; or even have both players play as the same character!
    ora $05                ; combine with p2 input
    sta $04                ; store result into p1 input

; store controller input for both players
write_input:
    ldx #$01

; set the new input to memory for use in code
; also sets the differences between last input and new input for use in code
set_player_input:
    lda $04,x                   ; read player input
    tay                         ; move input into Y
    eor CTRL_KNOWN_GOOD,x       ; find the differences between previous known-good input and new input
    and $04,x                   ; set a to only have differences in input between last known-good and new input
    sta CONTROLLER_STATE_DIFF,x ; store input differences value into memory
    sty CONTROLLER_STATE,x      ; store new known-good input into $f1
    sty CTRL_KNOWN_GOOD,x       ; store new known-good input into CTRL_KNOWN_GOOD (used only for controller input code)
    dex                         ; move from player 2 to player 1
    bpl set_player_input        ; read player 1 input
    rts

; reads the p1 and p2 controllers
; stores the inputs in a bit field in $04 and $05 respectively
; from msb to lsb: A, B, select, start, up, down, left, right
; sets and immediately clears strobe bit to read from controllers
read_controller_state:
    ldx #$01
    stx CONTROLLER_1 ; set the strobe bit so controller input for both controllers can be read
    dex
    stx CONTROLLER_1 ; clear strobe bit before starting controller read
    ldy #$08         ; loop counter to go through #$08 inputs
                     ; A, B, select, start, up, down, left, right

; read controller input for individual button press
; pushing each entry into the resulting byte for each controller input
; this looks at both bit 0 and bit 1 from the NES to determine input
; this means the game supports both the standard controller as well as a Famicom expansion port controller
read_controller_button:
    lda CONTROLLER_1           ; read controller input to determine if button is pressed
                               ; Contra is concerned with the 2 least significant bits (NES and Famicom inputs)
    sta $07                    ; store input value in $07
    lsr                        ; move lsb specifying if button is pressed for a standard controller into carry flag
    ora $07                    ; or the original value with the shifted value
                               ; this is essentially also checking if bit 1 (Famicom expansion port controller) is set
    lsr                        ; move bit representing whether the button is pressed to the carry flag
    rol $04                    ; shift carry flag (button input flag) onto player 1 controller input bit-field
                               ; $04 by pushing the button state bit to the next bit
    lda CONTROLLER_2           ; do the same thing for player 2 controller
    sta $07                    ; store input value in $07
    lsr                        ; move lsb specifying if button is pressed for a standard controller into carry flag
    ora $07                    ; or the original value with the shifted value
                               ; this is essentially also checking if bit 1 (Famicom expansion port controller) is set
    lsr                        ; move bit representing whether the button is pressed to the carry flag
    rol $05                    ; shift carry flag (button input flag) onto player 1 controller input bit-field
                               ; $05 by pushing the button state bit to the next bit
    dey                        ; decrement button loop counter
    bne read_controller_button ; loop to see if next button is pressed
    rts                        ; finished reading controller inputs. $04 and $05 contain button state

; decrements intro theme delay timer, and checks if player pressed start or select
; if so, stop demo and show player select UI
dec_theme_delay_check_user_input:
    jsr dec_intro_theme_delay                ; decrement intro theme delay timer
    lda CONTROLLER_STATE_DIFF                ; controller 1 buttons pressed
    and #$30                                 ; select and start buttons
    beq timer_exit                           ; if neither start nor select pressed, exit to continue animation
    jsr reset_delay_timer                    ; reset 2-byte delay timer to #$0240
    ldx GAME_ROUTINE_INDEX
    cpx #$01                                 ; check if showing intro animation scroll (in game_routine_01)
    bne stop_demo_load_player_select_UI      ; branch if not in game_routine_01 (scrolling intro screen) to stop demo and show player select UI
    ldx HORIZONTAL_SCROLL                    ; player pressed start, skip scrolling animation and load player select UI
                                             ; load horizontal component of the PPUSCROLL [#$0 - #$ff]
    bne load_intro_palette2_play_intro_sound ; if intro animation scroll wasn't complete, load graphics palette and play intro theme
    and #$20                                 ; see if select button is pressed
    bne player_mode_change                   ; if select was pressed, update the cursor to point to either 1 PLAYER or 2 PLAYERS
    lda #$03                                 ; start button was pressed, set GAME_ROUTINE_INDEX to #$03 (start new game)
    jmp set_game_routine_index_to_a          ; go to next game routine

; swaps player mode from 1 PLAYER (#$00) to 2 PLAYER (#$01) or vice versa
player_mode_change:
    inc PLAYER_MODE ; add one to number of players (will correct if more than #$02 players below)
    lda #$02
    sec             ; set the carry flag for the next subtract statement
    sbc PLAYER_MODE ; subtract player mode from #$02
    bne timer_exit  ; player mode was #$00 and now is #$01, simply exit
    sta PLAYER_MODE ; player mode was #$02, set PLAYER_MODE so it is #$00 (#$01 player)

timer_exit:
    rts

; user has pressed start or select while a demo was playing
stop_demo_load_player_select_UI:
    lda #$00
    sta GRAPHICS_BUFFER_MODE
    jsr zero_out_nametables
    jsr load_intro_graphics
    jsr load_intro_palette2_play_intro_sound
    lda #$01
    jmp set_game_routine_index_to_a          ; set GAME_ROUTINE_INDEX to #$01

; loads the 2nd intro palette for when Bill and Lance are on screen
; also plays the intro explosion sound
load_intro_palette2_play_intro_sound:
    lda #$00
    sta HORIZONTAL_SCROLL                     ; set the scroll to #$00 (completed) for next frame so player select UI is shown
    lda #$b0
    sta PPUCTRL_SETTINGS                      ; set nametable to $2000 next update of PPUCTRL
    lda #$a4
    sta INTRO_THEME_DELAY                     ; set intro theme delay timer to #$a4 (~5 seconds)
    lda #$04                                  ; set background palettes for when Bill and Lance on screen (intro_background_palette2)
.ifdef Probotector
    jmp load_bank_6_write_text_palette_to_mem ; write the palette data to CPU_GRAPHICS_BUFFER in CPU memory
                                              ; sound already played in game_routine_01 for Probotector
                                              ; so no play_sound call
.else
    jsr load_bank_6_write_text_palette_to_mem ; write the palette data to CPU_GRAPHICS_BUFFER in CPU memory
    lda #$26                                  ; a = #$26 (game intro tune)
    jmp play_sound                            ; play sound_26 (game intro tune)
.endif

; delay INTRO_THEME_DELAY on odd frames
dec_intro_theme_delay:
    lda FRAME_COUNTER     ; load frame counter
    and #$01              ; only care about least significant bit
    bne timer_exit        ; if last bit is not 0 (even frame), jump to timer_exit
    lda INTRO_THEME_DELAY
    beq timer_exit        ; if INTRO_THEME_DELAY is #$0 then jump to timer_exit
    dec INTRO_THEME_DELAY ; decrement from delay
    rts                   ; exit

set_next_demo_level:
    jsr clear_memory_3 ; clear $0028 to $00f0 then CPU_SPRITE_BUFFER up to CPU_GRAPHICS_BUFFER
    lda #$07           ; see player_mode_1d_table
    sta PLAYER_MODE_1D ; set to #$07 for 2 player
    lda #$00           ; a = #$00
    sta FRAME_COUNTER  ; reset frame counter
    sta RANDOM_NUM     ; set randomizer to #$00
    lda DEMO_LEVEL     ; load level of demo to first level
    cmp #$03           ; compare against 4th demo level
    bcc @continue      ; branch if less than 3
    lda #$00           ; reset DEMO_LEVEL back to 0 if DEMO_LEVEL >= 3
                       ; only levels 0 to 2 are demoed

@continue:
    sta DEMO_LEVEL    ; level of demo mode
    sta CURRENT_LEVEL ; current level (0 = level 1)
    inc DEMO_LEVEL    ; increment level of demo mode
    lda #$62          ; a = #$62
    sta P1_NUM_LIVES  ; player 1 lives
    sta P2_NUM_LIVES  ; player 2 lives
    rts

; clears certain level and player data
; initializes player score and number of lives
init_score_player_lives:
    jsr clear_memory_3 ; clear $0028 to $00f0 then CPU_SPRITE_BUFFER up to CPU_GRAPHICS_BUFFER
    sta DEMO_LEVEL     ; level of demo mode
    lda #$03           ; a = #$03
    sta NUM_CONTINUES  ; continues remaining

reset_players_score:
    ldx #$03 ; x = #$03
    lda #$00 ; a = #$00

clear_score_byte:
    sta PLAYER_1_SCORE_LOW,x      ; clear player 1 and player 2 scores
    dex
    bpl clear_score_byte
    sta DEMO_MODE                 ; ensure demo mode is #$00 (not in demo mode)
    sta P1_GAME_OVER_STATUS       ; set game over status for p1 to #$0 (not in game over state)
    ldx PLAYER_MODE               ; load number of players #$00 is 1 player, #$01 is 2 player
    lda player_mode_1d_table,x    ; #$01 for 1 player, #$07 for 2 player
    sta PLAYER_MODE_1D
    lda p2_game_over_status_tbl,x ; load initial player 2 game over status
    sta P2_GAME_OVER_STATUS       ; set to 1 when 1 player game; set to 0 if 2 players are playing

init_player_lives:
    lda #$02                  ; start of with #$02 lives
    ldy KONAMI_CODE_STATUS    ; 30-lives code switch ($01 = code activated)
    beq init_player_num_lives ; if KONAMI_CODE_STATUS is not set, then just set 2 lives
    lda #$1d                  ; KONAMI_CODE_STATUS active so set lives to #$1d (29 decimal)

; set the player number of remaining lives to either #$02 or #$1d depending if Konami code used
; sets default score required for extra lives as well
init_player_num_lives:
    sta P1_NUM_LIVES,x          ; if X is 1, then set P2_NUM_LIVES to accumulator (a is either #$02 or #$1d)
    dex                         ; decrement player number
    bpl init_player_lives       ; if more another player to set score, jump
    lda #$c8                    ; set default high score. #$c8 is 200 decimal
    sta EXTRA_LIFE_SCORE_LOW    ; starting score for extra life (20,000)
    sta $3e                     ; player 2 default score for extra life
    lda #$00
    sta EXTRA_LIFE_SCORE_HIGH   ; clear high byte of score for extra life
    sta KONAMI_CODE_NUM_CORRECT ; clear number of successful inputs to Konami code
    rts

; a lookup of whether 1 player game or 2 player game
; first byte #$00 is when PLAYER_MODE = #$00 (1 player)
; second byte #$07 is when PLAYER_MODE = #$01 (2 player)
player_mode_1d_table:
    .byte $01,$07

; initial value for P2_GAME_OVER_STATUS
; set to #$01 for 1 player game
; set to #$00 for 2 player game
p2_game_over_status_tbl:
    .byte $01,$00

; clear memory addresses $0028 to $00f0 then CPU_SPRITE_BUFFER up to CPU_GRAPHICS_BUFFER (not including) [$300-$700)
clear_memory_3:
    ldx #$28

; clears memory [x-$f0) and [$300-$700]
; input
;  * x - starting memory address to clear (inclusive)
clear_memory_starting_at_x:
    lda #$00

@loop:
    sta $00,x
    inx
    cpx #$f0
    bne @loop
              ; clear memory from CPU_SPRITE_BUFFER ($300) up to CPU_GRAPHICS_BUFFER ($700)
    ldx #$07  ; ending high byte of CPU memory to clear (exclusive)
    ldy #$03  ; starting high byte of CPU memory to clear
    sty $01
    sta $00
    ldy #$00

; clear blocks of memory specified by the 2-byte $00 address
; clears until the memory address $X00, specified by the x register
; in this case clear memory from CPU_SPRITE_BUFFER to $06FF
clear_memory_block:
    sta ($00),y
    iny
    bne clear_memory_block
    inc $01
    cpx $01
    bne clear_memory_block

add_player_score_exit:
    rts

; add enemy points to player score in memory
; determines if extra life is awarded and awards if necessary
; determines if high score is met and updates if necessary
; y is player number: either $00 (player 1) or $01 (player 2)
; $00 (low byte) and $01 (high byte) contain the score to add
; $01 is always #$00
add_player_low_score:
    lda DEMO_MODE             ; #$00 not in demo mode, #$01 demo mode on
    bne add_player_score_exit ; exit when in demo mode
    lda #$00                  ; a = #$00
    sta $01                   ; set high byte of score to #$00

; add enemy points to player score in memory
; determines if extra life is awarded and awards if necessary
; determines if high score is met and updates if necessary
; y is player number: either $00 (player 1) or $01 (player 2)
; $00 (low byte) and $01 (high byte) contain the score to add
add_player_score:
    tya                       ; transfer player number to a
    sta $02                   ; store player number in $02
    asl                       ; double since each player has 2 bytes representing score
    tay                       ; transfer offset to y
    lda $00                   ; load low byte of score to add to player score
    adc PLAYER_1_SCORE_LOW,y  ; add low byte of score to add to player score (low byte)
    sta PLAYER_1_SCORE_LOW,y  ; store updated player score (low byte)
    lda $01                   ; load high byte of score to add to player score (always #$00 or #$50)
    adc PLAYER_1_SCORE_HIGH,y ; add high byte of score to add to player score (high byte)
    bcc @continue             ; continue if no overflow occurred
    lda #$ff                  ; overflow occurred in high byte, player maxed out score set low byte to #$ff
    sta PLAYER_1_SCORE_LOW,y  ; player score (low byte)

@continue:
    sta PLAYER_1_SCORE_HIGH,y         ; store updated player score (high byte)
    ldx $01                           ; load high byte of player score to add
    beq @set_if_extra_life            ; branch if not special #$a0 score (all other scores have #$00 for high byte)
    lda #$88                          ; #$88 will cause a subtraction of #$50 as the extra life score low add byte
    clc                               ; clear carry so always jump
    bcc @set_extra_life_inc_num_lives ; always jump

@set_if_extra_life:
    cmp EXTRA_LIFE_SCORE_HIGH,y ; player score for extra life - high byte
    bcc @set_if_new_high_score  ; player did not get extra life, skip to check if player got new high score
    bne @extra_life_logic       ; score greater than necessary to get extra life
    lda PLAYER_1_SCORE_LOW,y    ; load player score low byte
    cmp EXTRA_LIFE_SCORE_LOW,y  ; player score for extra life - low byte
    bcc @set_if_new_high_score  ; player score less than EXTRA_LIFE_SCORE_LOW, no need to check if extra life

; every time an extra life is obtained, #$12c is added to points required to get next extra life (300 decimal, 30,000 in game score)
; once score reaches #$7500 (2,995,200 in game score), no more extra lives are awarded
; if adding special score code #$0a, then the next extra life is given and number of points needed for next extra life is unchanged
; because #$1388 points are added to the extra life score, so distance until next 30,000 points is kept the same
@extra_life_logic:
    lda EXTRA_LIFE_SCORE_HIGH,y ; player score for extra life - high byte
    cmp #$75                    ; compare EXTRA_LIFE_SCORE_HIGH to #$75
    bcs @set_if_new_high_score  ; EXTRA_LIFE_SCORE_HIGH > #$75, score too high, don't give any more extra lives
    lda #$2c                    ; a = #$2c (12c = 300 decimal) (high byte will be set to #$01 a few lines down)

@set_extra_life_inc_num_lives:
    adc EXTRA_LIFE_SCORE_LOW,y  ; add 300 decimal to low byte of score required to get extra life
    sta EXTRA_LIFE_SCORE_LOW,y  ; player score for extra life - low byte
    lda #$01                    ; a = #$01
    ldx $01                     ; determine if high byte is set
    beq @continue_inc_num_lives ; branch if not special #$a0 score (all other scores have #$00 for high byte)
    lda #$13                    ; a = #$13

@continue_inc_num_lives:
    adc EXTRA_LIFE_SCORE_HIGH,y ; player score for extra life - high byte
    bcc @inc_num_lives
    lda #$ff                    ; a = #$ff
    sta EXTRA_LIFE_SCORE_LOW,y  ; maxed out extra life high score, max out low byte

@inc_num_lives:
    sta EXTRA_LIFE_SCORE_HIGH,y ; player score for extra life - high byte
    ldx $02                     ; load the player number
    inc P1_NUM_LIVES,x          ; if X is $01, then set P2 number of lives
    lda P1_NUM_LIVES,x          ; load incremented number into memory
    cmp #$63                    ; compare to #$99 lives
    bcc @set_num_lives          ; can't have more than 99 lives
    lda #$63                    ; a = #$63 (63 = 99 decimal)

@set_num_lives:
    sta P1_NUM_LIVES,x         ; number of lives
    lda $01
    bne @set_if_new_high_score ; don't play sound for special #$a0 score code
    lda #$20                   ; a = #$20 (sound_20)
    jsr play_sound             ; play extra life sound sound

@set_if_new_high_score:
    lda PLAYER_1_SCORE_HIGH,y ; player score (high byte)
    cmp HIGH_SCORE_HIGH       ; high score (high byte)
    bcc score_exit            ; exit if no need to update high score score
    bne @set_high_score       ; high byte high score is greater, update high score score
    lda PLAYER_1_SCORE_LOW,y  ; player score (low byte)
    cmp HIGH_SCORE_LOW        ; high score (low byte)
    bcc score_exit            ; don't update high score score if player score isn't bigger than high score

@set_high_score:
    lda PLAYER_1_SCORE_LOW,y  ; load player score low byte
    sta HIGH_SCORE_LOW        ; set new high score low byte to player score low byte
    lda PLAYER_1_SCORE_HIGH,y ; load player score high byte
    sta HIGH_SCORE_HIGH       ; set new high score high byte to player score high byte

score_exit:
    rts

; redraws parts of the nametable for things like bridge explosions,
; nametable enemy explosions, animation (pill box sensor), etc.
; also used to draw palette colors for super-tiles
; input
;  * a is x position of nametable super-tile in pixels
;  * y is y position of nametable super-tile in pixels
;  * $10 is the super-tile or palette index to draw (level_x_nametable_update_supertile_data/level_x_nametable_update_palette_data offset)
; output
;  * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_nametable_supertile:
    sta $11                      ; store the x position (in pixels) of the location to redraw the nametable in $11 (except bit 7)
    lda GRAPHICS_BUFFER_OFFSET   ; read current offset
    cmp #$40                     ; see if graphics buffer is already full
    bcs score_exit               ; exit if offset is greater than or equal to #$40
    jsr set_ppu_addresses_in_mem ; determines attribute table PPU address, $14 (low) and $15 (high)
                                 ; determines PPU nametable write address, $0c (low) and $0d (high)
                                 ; for x ($11), y (y) coordinates
                                 ; $00 is set to non zero if should update palette, #$00 for nametable update only
    ldx GRAPHICS_BUFFER_OFFSET
    lda CURRENT_LEVEL            ; current level
    ldy LEVEL_LOCATION_TYPE      ; 0 = outdoor; 1 = indoor
    bpl @continue                ; outdoor levels use level-specific super-tiles
    lda #$08                     ; indoor (base) levels use a shared super-tile set (level 2 and 4)

@continue:
    asl                                   ; each address is 2 bytes, so double
    asl                                   ; each level has both super tile data and pattern data, so double
    tay                                   ; transfer offset into y
    lda nametable_update_data_ptr_tbl,y   ; load low byte of super-tile data address
    sta $16                               ; store in $16
    lda nametable_update_data_ptr_tbl+1,y ; load high byte of super-tile data address
    sta $17                               ; store in $17
    lda $0f                               ; determines if need to update the palette (#$00 meaning palette update is required, and needs to be added to CPU_GRAPHICS_BUFFER)
    bne write_update_supertile_to_cpu     ; go ahead and write the entire new super-tile bytes to the CPU_GRAPHICS_BUFFER, with no palette update instructions
    lda nametable_update_data_ptr_tbl+2,y ; need to update palette, prep to write to CPU_GRAPHICS_BUFFER. load low byte of palette data address
    sta $0e                               ; store low byte in $0e
    lda nametable_update_data_ptr_tbl+3,y ; load high byte of palette data address
    sta $0f                               ; store high byte in $0f
    ldy $10                               ; load level_X_nametable_update_palette_data read offset
    lda $00
    bne update_supertile_palette          ; if $00 is not #$00, then branch, updates palette based on super-tile data for level instead of from nametable_update_data_ptr_tbl
    jsr set_graphics_buffer_header        ; set CPU_GRAPHICS_BUFFER to write one tile to PPU at PPU address specified in $14 and $15
    lda ($0e),y                           ; read palette data byte for the super-tile
    sta CPU_GRAPHICS_BUFFER,x             ; write palette data byte to CPU_GRAPHICS_BUFFER (palette for entire super-tile)
    inx

; updates/overwrites a single super-tile on the nametable
write_update_supertile_to_cpu:
    lda #$00                  ; a = #$00
    sta $11                   ; clear out address high byte overflow counter
    lda $10                   ; load level_X_nametable_update_supertile_data read offset
    asl                       ; each entry is #$10 bytes, multiply by #$10
    asl                       ; keeping track of overflow
    rol $11
    asl
    rol $11
    asl
    rol $11
    adc $16                   ; add to nametable_update_data_ptr_tbl high byte
    sta $16                   ; PPU write address low byte
    lda $11                   ; load any overflow
    adc $17                   ; add to high byte of level_x_nametable_update_supertile_data offset
    sta $17                   ; PPU write address high byte
    lda #$01
    sta CPU_GRAPHICS_BUFFER,x ; set VRAM address increment to 0, meaning to add #$1 every write to PPU (write horizontally)
    inx
    lda #$04                  ; a super-tile is 4 rows of 4 pattern table tiles, set pattern table tile size to #$04
    sta $14                   ; CPU_GRAPHICS_BUFFER graphic data group size
    sta CPU_GRAPHICS_BUFFER,x ; each group of graphic data is #$04 bytes (4 rows in super-tile)
    inx
    sta CPU_GRAPHICS_BUFFER,x ; #$04 groups of #$04-byte-sized entries
    inx
    ldy #$00                  ; initialize level_x_nametable_update_supertile_data entry offset to #$00 (beginning of data)

; write the PPU write address and then the graphics data
@write_graphic_group:
    lda $0d                   ; PPU write address high byte
    sta CPU_GRAPHICS_BUFFER,x ; set PPU write address high byte
    inx
    lda $0c                   ; PPU write address low byte
    sta CPU_GRAPHICS_BUFFER,x ; set PPU write address low byte
    inx

; write the #$04 bytes of the graphic group
@write_graphic_group_bytes:
    lda ($16),y                    ; load tile from the level_X_nametable_update_supertile_data
    sta CPU_GRAPHICS_BUFFER,x      ; store in CPU_GRAPHICS_BUFFER
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    iny                            ; increment level_x_nametable_update_supertile_data read offset
    tya
    and #$03                       ; keep bits .... ..xx
    bne @write_graphic_group_bytes
    lda $0c                        ; load PPU write address low byte
    clc                            ; clear carry in preparation for addition
    adc #$20                       ; move down a row on the nametable to prep for drawing the next 4 tiles
    sta $0c                        ; update PPU write address low byte
    lda $0d                        ; load PPU write address high byte
    adc #$00                       ; add any carry from previous adc
    sta $0d                        ; update PPU write address high byte
    dec $14                        ; decrement from group size counter
    bne @write_graphic_group
    stx GRAPHICS_BUFFER_OFFSET     ; update GRAPHICS_BUFFER_OFFSET
    clc                            ; clear any leftover carry
    rts

; level 2/4 boss screen, waterfall (red turret)
; input
;  * $00 - palette update mode (#$01 = 2 horizontally, #$02 = 2 vertically, #$03 = 4 (2x2))
update_supertile_palette:
    tax                                  ; transfer palette update mode to x
    lda ($0e),y                          ; load palette byte for super-tile
    dex                                  ; decrement palette update mode
    stx $01                              ; save in $01
    bne @update_palette_01               ; branch if palette command code was not #$01
    tax                                  ; update 2 super-tiles' palettes horizontally, move palette byte to x
    and #$33                             ; keep bits ..xx ..xx
    asl
    asl
    sta $08
    txa
    and #$cc                             ; keep bits xx.. xx..
    lsr
    lsr
    sta $09
    ldx $02                              ; load current screen super-tile offset (set in set_ppu_addresses_in_mem)
                                         ; e.g. level_2_4_boss_supertiles_screen_00
    ldy LEVEL_SCREEN_SUPERTILES,x        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load the palette data for the current super-tile
    and #$33                             ; keep left half of super-tile palette data
    ora $08                              ; merge with right half of super-tile palette
    sta $08                              ; set super-tile palette data
    ldy LEVEL_SCREEN_SUPERTILES+1,x      ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load the palette data for the current super-tile
    and #$cc                             ; keep right half of super-tile palette data
    ora $09                              ; merge with left half of super-tile palette
    sta $09                              ; set super-tile palette data
    jmp @update_palette_continue

; vertical two super-tiles
@update_palette_01:
    dex                                  ; decrement $00 value
    bne @update_palette_02
    ldx #$00                             ; x = #$00
    stx $09
    asl
    rol $09
    asl
    rol $09
    asl
    rol $09
    asl
    rol $09
    sta $08
    ldx $02
    ldy LEVEL_SCREEN_SUPERTILES,x        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; level_x_palette_data
    and #$0f                             ; keep bits .... xxxx
    ora $08
    sta $08                              ; store
    ldy LEVEL_SCREEN_SUPERTILES+8,x
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y
    and #$f0                             ; keep bits xxxx ....
    ora $09
    sta $09
    jmp @update_palette_continue

; boss screen 2/4
; loads 4 super-tile palette, 2x2
@update_palette_02:
    ldx #$00                             ; x = #$00
    stx $08
    stx $0b
    lsr
    ror $08
    lsr
    ror $08
    and #$0c                             ; keep bits .... xx..
    sta $0a
    lda ($0e),y
    asl
    rol $0b
    asl
    rol $0b
    and #$30                             ; keep bits ..xx ....
    sta $09
    ldx $02
    ldy LEVEL_SCREEN_SUPERTILES,x        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y
    and #$3f                             ; keep bits ..xx xxxx
    ora $08
    sta $08
    ldy LEVEL_SCREEN_SUPERTILES+1,x
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y
    and #$cf                             ; keep bits xx.. xxxx
    ora $09
    sta $09
    ldy LEVEL_SCREEN_SUPERTILES+8,x
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y
    and #$f3                             ; keep bits xxxx ..xx
    ora $0a
    sta $0a
    ldy LEVEL_SCREEN_SUPERTILES+9,x
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y
    and #$fc                             ; keep bits xxxx xx..
    ora $0b
    sta $0b

@update_palette_continue:
    lda $01                        ; load updated palette update mode (#$00 = 2 horizontally, #$01 = 2 vertically, #$02 = 4 (2x2))
    asl                            ; double since to determine how many super-tile palettes are being updated
    tay                            ; transfer number of super-tiles to update to offset register
    ldx GRAPHICS_BUFFER_OFFSET     ; load current offset into graphics buffer
    lda #$01                       ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x      ; set VRAM address increment to 0, meaning to add #$1 every write to PPU (write across)
    inx                            ; increment graphics buffer offset
    lda update_palette_cfg_tbl,y   ; load how many tiles to draw per graphics group
    sta CPU_GRAPHICS_BUFFER,x      ; set how many pattern table tiles to draw per group
    inx                            ; increment graphics buffer offset
    lda update_palette_cfg_tbl+1,y ; load how many graphics groups there are to draw
    sta CPU_GRAPHICS_BUFFER,x      ; set how many graphics groups to draw
    inx                            ; increment graphics buffer offset
    ldy #$00                       ; y = #$00

@write_palette_data:
    lda $15                   ; load PPU address (attribute table) high byte
    sta CPU_GRAPHICS_BUFFER,x ; set PPU address (attribute table) high byte
    inx                       ; increment graphics buffer offset
    lda $14                   ; load PPU address (attribute table) low byte
    sta CPU_GRAPHICS_BUFFER,x ; set PPU address (attribute table) low byte
    inx                       ; increment graphics buffer offset
    lda $08,y                 ; load super-tile palette data
    sta CPU_GRAPHICS_BUFFER,x ; set super-tile palette data
    inx                       ; increment graphics buffer offset
    lda $00                   ; load original palette update mode (#$01 = 2 horizontally, #$02 = 2 vertically, #$03 = 4 (2x2))
    cmp #$02                  ; compare to mode 2
    beq @mv_down_row          ; branch if mode #$02 (2 vertical)
    iny                       ; either mode #$01 or #$03 (mode contains 2 horizontal super-tiles)
                              ; increment number of super-tiles updated
    lda $08,y                 ; load 2nd super-tile palette data
    sta CPU_GRAPHICS_BUFFER,x ; set 2nd super-tile palette data
    inx                       ; increment graphics buffer offset

@mv_down_row:
    lda $01                     ; load updated palette update mode (#$00 = 2 horizontally, #$01 = 2 vertically, #$02 = 4 (2x2))
    beq @write_update_supertile ; finished writing super-tile palette data, move to update super-tile pattern tiles
    iny                         ; increment number of super-tiles updated
    lda $14                     ; load super-tile palette PPU address (attribute table) low byte
    clc                         ; clear carry in preparation for addition
    adc #$08                    ; move one super-tile row down
    sta $14                     ; set new super-tile palette PPU address (attribute table) low byte
    lda #$00                    ; a = #$00
    sta $01                     ; change palette update mode from #$02 to #$01, or from #$01 to #$00
    beq @write_palette_data     ; loop to write the next row (only for mode #$02 which has 4 super-tiles to update total)

@write_update_supertile:
    jmp write_update_supertile_to_cpu ; finished writing super-tile palette data, move to super-tile pattern tile data

; configuration based on palette update mode
; #$00 = 2 horizontally, #$02 = 2 vertically, #$04 = 4 (2x2)
; byte 0 - number of pattern table tiles per graphics group
; byte 1 - number of graphics groups
update_palette_cfg_tbl:
    .byte $02,$01
    .byte $01,$02
    .byte $02,$02

; bank 3 offsets
; pointer table for nametable super-tile nametable and palettes ($12 * $02 = $24 bytes)
; 2 pointers per level.
;  * pointer 1: super-tile tile definitions
;  * pointer 2: palette codes for the super-tile, values ultimately end up in attribute table
;               each byte from level_X_nametable_update_palette_data is a quarter of a super-tile
nametable_update_data_ptr_tbl:
    .addr level_1_nametable_update_supertile_data      ; bank 3 label - CPU address $83b1
    .addr level_1_nametable_update_palette_data        ; bank 3 label - CPU address $86ac
    .addr level_2_nametable_update_supertile_data      ; bank 3 label - CPU address $88a8
    .addr level_2_nametable_update_palette_data        ; bank 3 label - CPU address $8e91
    .addr level_3_nametable_update_supertile_data      ; bank 3 label - CPU address $9368
    .addr level_3_nametable_update_palette_data        ; bank 3 label - CPU address $965f
    .addr level_4_nametable_update_supertile_data      ; bank 3 label - CPU address $88a8
    .addr level_4_nametable_update_palette_data        ; bank 3 label - CPU address $8e91
    .addr level_5_nametable_update_supertile_data      ; bank 3 label - CPU address $9ba8
    .addr level_5_nametable_update_palette_data        ; bank 3 label - CPU address $9db9
    .addr level_6_nametable_update_supertile_data      ; bank 3 label - CPU address $a4ae
    .addr level_6_nametable_update_palette_data        ; bank 3 label - CPU address $a567
    .addr level_7_nametable_update_supertile_data      ; bank 3 label - CPU address $abea
    .addr level_7_nametable_update_palette_data        ; bank 3 label - CPU address $adae
    .addr level_8_nametable_update_supertile_data      ; bank 3 label - CPU address $b25a
    .addr level_8_nametable_update_palette_data        ; bank 3 label - CPU address $b543
    .addr level_2_4_nametable_update_supertile_data    ; bank 3 label - CPU address $ba1a
    .addr level_2_4_boss_nametable_update_palette_data ; bank 3 label - CPU address $bdc4

update_nametable_tiles_exit:
    rts

; updates #$02 columns of n rows (default #$02) of a nametable at position (a,y) with desired pattern table tiles
; bank 3 should be loaded
; input
;  * a is ENEMY_X_POS
;  * y is ENEMY_Y_POS
;  * $10 (multiplied by #$05) is the index into the tile animation table to start drawing
;    if bit 7 clear, then update palette, if bit 7 set do not update palette
; output
;  * carry - clear when successful, set when CPU_GRAPHICS_BUFFER is full
; for example, indoor/base levels for drawing wall turrets, and changing to explosion when destroyed
; claw animations, etc.
update_nametable_tiles:
    sta $11                              ; store enemy x position in $11
    lda GRAPHICS_BUFFER_OFFSET           ; load current GRAPHICS_BUFFER_OFFSET
    cmp #$50                             ; GRAPHICS_BUFFER_OFFSET goes from $700 to $750
    bcs update_nametable_tiles_exit      ; graphics buffer full, exit
    jsr set_ppu_addresses_in_mem         ; determines attribute table PPU address, $14 (low) and $15 (high)
                                         ; determines PPU nametable write address, $0c (low) and $0d (high)
                                         ; for x ($11), y (y) coordinates
    lda $10                              ; load the current level's super-tile read offset ($16 read offset)
    asl
    asl
    adc $10                              ; multiply by 5
    tay
    lda CURRENT_LEVEL                    ; load current level
    asl                                  ; each entry in level_tile_animation_ptr_tbl is a 2-byte address, so double
    tax
    lda level_tile_animation_ptr_tbl,x   ; read the address low byte
    sta $16                              ; store the address low byte
    lda level_tile_animation_ptr_tbl+1,x ; load the address high byte
    sta $17                              ; store the address high byte
    ldx #$02                             ; default to two tiles per read
    lda ($16),y                          ; read first byte of tile animation table
                                         ; #$00 means to update #$02 rows of #$02 pattern table tiles each row
    bpl @continue                        ; if the msb is not set draw default number of rows (#$02), jump
    and #$07                             ; first bit set, mask its least significant 3 bits to see how many rows to draw
    tax

@continue:
    stx $14                     ; $14 (total number of tile groups)
                                ; store masked first byte of ($16) if its msb was set, otherwise store #$02
    ldx GRAPHICS_BUFFER_OFFSET  ; load current GRAPHICS_BUFFER_OFFSET
    lda $0f                     ; loads whether palette needs to be updated (#$00 = yes, #$80 = no)
    bne @update_nametable_tiles ; branch if $0f is #$80
    lda ($16),y                 ; palette needs to be updated, re-read first byte of tile animation table
    sty $0e                     ; store update tile offset in $0e
    ldy $00                     ; load palette update mode (#$01 = 2 horizontally, #$02 = 2 vertically, #$03 = 4 (2x2))
    beq @set_supertile_palette
    dey
    beq @shift_2                ; branch if palette update mode is #$01 (2 horizontally)
    dey
    beq @shift_4                ; branch if palette update mode is #$02 (2 vertically)
    asl
    asl

@shift_4:
    asl
    asl

@shift_2:
    asl
    asl

@set_supertile_palette:
    sta $08
    ldx $02                              ; load the super tile to draw LEVEL_SCREEN_SUPERTILES offset
    ldy LEVEL_SCREEN_SUPERTILES,x        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load palette data for super-tile
    ldy $00
    and palette_mask_tbl,y               ; strip out the 2 bits that need to change
    ora $08                              ; merge with new palette entry for quadrant of super-tile
    sta $08                              ; set updated palette data for super-tile
    ldx GRAPHICS_BUFFER_OFFSET           ; load graphics buffer offset
    jsr set_graphics_buffer_header       ; create entry saying to write one byte to PPU at PPU address specified by $14 (low PPU write address) and $15 (high PPU write address)
    lda $08                              ; load super-tile palette
    sta CPU_GRAPHICS_BUFFER,x            ; set super-tile palette to graphics buffer
    inx                                  ; increment graphics buffer read offset
    ldy $0e                              ; restore tile animation offset

; specifies VRAM address increment, # of tiles groups and size of tile group
@update_nametable_tiles:
    iny
    lda #$01                  ; set VRAM address increment to 1 (write across)
    sta CPU_GRAPHICS_BUFFER,x
    inx
    lda #$02                  ; set number of tiles per group to #$02
    sta CPU_GRAPHICS_BUFFER,x
    inx
    lda $14                   ; set total number of tile groups to $14
    sta CPU_GRAPHICS_BUFFER,x
    inx

; specifies PPU write address in CPU_GRAPHICS_BUFFER
; specifies #$02 pattern table tiles per row
prep_overwrite_nametable_tiles:
    lda #$02                  ; a = #$02
    sta $15                   ; set number of tiles in each group in CPU_GRAPHICS_BUFFER
    lda $0d                   ; load low byte of PPU write address
    sta CPU_GRAPHICS_BUFFER,x ; store low byte of PPU write address
    inx                       ; increment PPU write offset
    lda $0c                   ; load PPU tile write address high byte
    sta CPU_GRAPHICS_BUFFER,x ; store high byte of PPU write address
    inx                       ; increment CPU_GRAPHICS_BUFFER write offset

write_overwrite_tile_to_cpu_buffer:
    lda ($16),y                            ; read tile from tile_animation_ptr data
    sta CPU_GRAPHICS_BUFFER,x              ; write tile to CPU_GRAPHICS_BUFFER
    inx                                    ; increment CPU_GRAPHICS_BUFFER offset
    iny                                    ; increment tile_animation_ptr read offset
    dec $15                                ; decrement tile read total
    bne write_overwrite_tile_to_cpu_buffer ; if we aren't done writing tiles, loop
    lda $0c                                ; load the low byte PPU write address
    clc                                    ; clear any previous carry
    adc #$20                               ; move next write address down by a row on the nametable (same column)
    sta $0c                                ; store updated PPU tile write address for next loop
    lda $0d                                ; load current PPU tile write address high byte
    adc #$00                               ; if there was a carry adding the #$20 to the low byte, add it to the high byte
    sta $0d                                ; store updated PPU tile write address for next loop
    dec $14                                ; finished writing tile group to CPU_GRAPHICS_BUFFER, move to next group of overwrite tiles
    bne prep_overwrite_nametable_tiles     ; loop to next set of tiles to write to CPU_GRAPHICS_BUFFER
    stx GRAPHICS_BUFFER_OFFSET             ; ensure graphics buffer offset is up to date
    clc                                    ; clear any carry
    rts

; bank 3 labels
; pointer table to pattern table tiles that are used to modify nametable after fully drawn for animations ($09 * $02 = $12 bytes)
level_tile_animation_ptr_tbl:
    .addr level_1_supertile_data        ; level 1 - CPU address $8001 (unused)
    .addr level_2_4_tile_animation      ; level 2 - CPU address $86e1
    .addr level_3_supertile_data        ; level 3 - CPU address $8ef8 (unused)
    .addr level_2_4_tile_animation      ; level 4 - CPU address $86e1
    .addr level_5_supertile_data        ; level 5 - CPU address $9698 (unused)
    .addr level_6_tile_animation        ; level 6 - CPU address $9dd8
    .addr level_7_tile_animation        ; level 7 - CPU address $a56e
    .addr level_8_supertile_data        ; level 8 - CPU address $adca (unused)
    .addr level_2_4_boss_supertile_data ; level 2/4 boss rooms - CPU address $b57a

; the following 3 tables are ppu addresses for the tile_animation tables entries
; used on all levels for animations
nametable_base_high_byte:
    .byte $20,$24

attribute_base_high_byte:
    .byte $23,$27

; the base offset into cpu graphics buffer where super-tile indexes are loaded (LEVEL_SCREEN_SUPERTILES)
; $0600 or $0640
level_screen_mem_offset_tbl_00:
    .byte $00,$40

palette_mask_tbl:
    .byte $fc ; 1111 1100
    .byte $f3 ; 1111 0011
    .byte $cf ; 1100 1111
    .byte $3f ; 0011 1111

; determines ppu nametable and attribute table addresses for given x, y coordinate
; input
;  * $10 - super-tile to draw, bit 7 used to load $0f (palette update marker)
;    (level_x_nametable_update_supertile_data/level_x_nametable_update_palette_data offset)
;    if bit 7 clear, then update palette, if bit 7 set do not update palette
;  * $11 - x offset
;  * y - y offset
; output
;  * PPU nametable write address: $0c (low) and $0d (high)
;  * PPU nametable collision address: $12 (low) and $13 (high)
;    * used for nametable collision removal
;    * always same as $0c and $0d
;  * PPU attribute table write address: $14 (low) and $15 (high)
;  * $00 - if set, then branch update_supertile_palette is executed
;    palette update modes (#$01 = 2 horizontally, #$02 = 2 vertically, #$03 = 4 (2x2))
;  * $10 - same as input but with bit 7 stripped
;  * $02 - super-tile index at location (level_x_supertiles_screen_xx offset)
;  * $0f - #$00 if palette needs to be updated, #$80 otherwise
set_ppu_addresses_in_mem:
    lda $10             ; load super-tile to draw
                        ; (offset into level_x_nametable_update_supertile_data/level_x_nametable_update_palette_data offset)
    and #$80            ; keep most significant bit (palette update flag)
    sta $0f             ; if #$00, then mark palette to updated as well as super-tile, #$80 means do not update palette
    lda $10             ; re-load super-tile to draw
    and #$7f            ; trim off most significant bit (palette update flag)
    sta $10             ; save updated super-tile to draw
    tya                 ; transfer y offset to a
    clc                 ; clear carry in preparation for addition
    adc VERTICAL_SCROLL ; add vertical scroll offset to y pixel offset, e.g. #$e0 (224 pixels/28 tiles) for outdoor levels
    bcs @round_up       ; branch if an overflow occurred to continue
    cmp #$f0            ; no overflow
    bcc @nametable

@round_up:
    adc #$0f

@nametable:
    and #$f8              ; keep bits xxxx x...
    sta $12               ; set PPU nametable address low byte
    lsr
    lsr
    tay
    lsr
    and #$02              ; keep bits .... ..x.
    sta $00
    tya
    and #$38              ; keep bits ..xx x...
    sta $14               ; set PPU attribute table write address low byte
    lda #$00              ; not used, next line overrides a
    asl $12               ; PPU nametable address low byte
    rol                   ; moves any carry from previous asl to bit 0
    asl $12               ; PPU nametable address low byte
    rol                   ; moves any carry from previous asl to bit 0
    sta $13               ; set PPU nametable address high byte
    lda $11               ; load x offset in pixels
    clc                   ; clear carry in preparation for addition
    adc HORIZONTAL_SCROLL ; add the horizontal scroll to the x position
    sta $11               ; update x offset to include horizontal scroll
    lda PPUCTRL_SETTINGS  ; pull part of base nametable address, used to determine high byte for nametable and attribute table
    and #$01              ; keep least significant bit (nametable base address 0 = $2000; 1 = $2400)
    bcc @continue         ; branch if no carry occurred on adc
    eor #$01              ; carry occurred flip bits .... ...x

@continue:
    tay                                  ; transfer nametable index offset to y (#$00 or #$01)
    lda attribute_base_high_byte,y       ; grab byte used to determine attribute table PPU address
    ora #$03                             ; ensure smallest 2 bits always set (.... ..xx)
    sta $15                              ; set PPU attribute table write address high byte
    lda nametable_base_high_byte,y       ; grab byte used to determine nametable PPU  address
    ora $13                              ; merge with value already in $13
    sta $13                              ; set PPU nametable collision address high byte
    sta $0d                              ; store PPU write address high byte
    lda level_screen_mem_offset_tbl_00,y ; load the base offset from LEVEL_SCREEN_SUPERTILES ($0600 or $0640)
    sta $02                              ; set base level screen supertile offset $0600 for nametable 0, $0640 for nametable 1
    lda $11                              ; load x offset in pixels including horizontal scroll
    and #$f8                             ; keep bits xxxx x...
    lsr
    lsr
    lsr
    tay
    lsr
    tax
    and #$01                             ; keep bits .... ...x
    ora $00
    sta $00
    txa
    lsr
    ora $14                              ; merge with PPU attribute table low write address high byte
    sta $03                              ; set LEVEL_SCREEN_SUPERTILES offset
    clc                                  ; clear carry in preparation for addition
    adc #$c0
    sta $14                              ; set PPU attribute table low write address high byte
    tya
    ora $12                              ; merge with PPU nametable collision address low byte
    sta $12                              ; set PPU nametable collision address low byte
    sta $0c                              ; PPU write address low byte
    lda $02                              ; load base level screen supertile offset $0600 for nametable 0, $0640 for nametable 1
    ora $03                              ; merge with offset into structure
    sta $02                              ; set super-tile index for current screen (level_x_supertiles_screen_xx offset)
    rts

; creates CPU_GRAPHICS_BUFFER entry to specify writing one byte to PPU
; at PPU address specified by $14 (low PPU write address) and $15 (high PPU write address)
set_graphics_buffer_header:
    lda #$01                  ; set VRAM address increment to 0, meaning to add #$1 every write to PPU (write horizontally)
    sta CPU_GRAPHICS_BUFFER,x
    inx
    sta CPU_GRAPHICS_BUFFER,x ; writing #$01-byte long groups of tiles
    inx
    sta CPU_GRAPHICS_BUFFER,x ; writing #$01 group of #$01 byte tiles, i.e. writing #$01 tile total
    inx
    lda $15
    sta CPU_GRAPHICS_BUFFER,x ; set PPU write address low byte to $15
    inx
    lda $14
    sta CPU_GRAPHICS_BUFFER,x ; set PPU write address high byte to $14
    inx
    rts

; execute the code at offset A from the pointer table underneath the jsr opcode that called this method
; this is done by reading with offset from the value of the stack before this call and adding 1
; which effectively allows this method to read from the pointer table below the calling code
; CPU address $c857
run_routine_from_tbl_below:
    asl         ; double A since each entry is a 2-byte label address
    sty $03     ; store y into $03 temporarily since this method overrides y
    tay         ; store offset into y
    iny         ; add one since the stack pointer points to one byte before table to offset into
    pla         ; pull the low byte of the stack pointer into a
    sta $00     ; store low byte of stack pointer address into $00
    pla         ; pull the high byte of the stack pointer memory address into a
    sta $01     ; store high byte into $01
    lda ($00),y ; read low byte of address of code to execute (offset into table)
    sta $02     ; store the low byte into $02
    iny         ; increment offset so high byte can be read
    lda ($00),y ; read the high byte of the address of the code to execute (offset into table)
    ldy $03     ; restore y register to what it was before the call to run_routine_from_tbl_below
    sta $03     ; store high byte into $03
    jmp ($0002) ; jump to the code specified by the address at offset A into the pointer table table

; dead code, never called !(UNUSED)
bank_7_unused_label_00:
    stx $00
    sty $01

; Calculate next digit of the score and put $02 and A register
;
; This logic converts from a binary to decimal, decimal digit by
; decimal digit by left shifting and keeping track of when the right-most digit
; is greater than 10 decimal.
;
; For example, for a score of 255, the first call to calculate the next digit to
; display will return 5, and store 25 into memory for the next call. On the
; second call to calculate the next digit to display, the subroutine will return
; 5, and store 2 into memory for the last call. On the final call, 2 is returned
; and 0 is stored, letting the calling code know the score is finished.
;
; CPU Memory used
; 0x00 - low byte of the current score being calculated
; 0x01 - high byte of the current score being calculated
; 0x02 - the next decimal digit to display
; 0x03 - hard-coded 10 in decimal
calculate_score_digit:
    lda #$00 ; set the accumulator register A to zero (#$00)
    sta $02  ; zero out any previously calculated digit
    ldy #$10 ; set the left-shift loop counter back to #$10 (16 decimal)
    rol $00  ; shift the score low byte to the left by one bit
             ; push the most significant bit (msb) to the carry flag
    rol $01  ; shift the score high byte to the left by one byte
             ; push the msb to the carry flag
             ; pull in carry flag to least significant bit (lsb)

shift_and_check_digit_carry:
    rol $02 ; shift score high byte to the left by one bit
            ; if the msb of the score high byte was 1, then carry into lsb
    lda $02 ; load current digit into the accumulator register A
    cmp $03 ; compare #$0a (10 decimal) to the current digit

                             ; branch if current digit is less than #$0a (10 decimal)
                             ;  - this means no subtraction and carry is needed
                             ; if greater than #$0a (10 decimal), don't jump
                             ;  - subtract 10 and carry
    bcc continue_shift_score
    sbc $03                  ; the current digit is greater than 10, subtract 10
                             ; this also sets the carry flag, which will be moved to the
                             ; low byte of the score, which is the "Rest" of the number
                             ; this carry represents adding 10 to the "Rest"
    sta $02                  ; store the difference (new current digit) back in $02

; $02 (current digit) is less than #$0a, or has just been subtracted
; continue algorithm by shifting score left
continue_shift_score:
    rol $00                         ; if just set $02 to digit by subtraction, this will put 1
                                    ; in $00's lsb, signifying adding 10 to "Rest"
    rol $01                         ; if $00's msb is 1, then it'll carry to the lsb of $01
    dey                             ; Y goes from $10 to $00, once Y is $00, the algorithm is done
    bne shift_and_check_digit_carry
    rts

; advance 2-byte read address $00,x by a bytes
; input
;  * a - the amount to add to the graphic read address
;  * x - the absolute index offset from $00 where the 2-byte read address exists, i.e. $00,x
advance_graphic_read_addr:
    clc       ; clear the carry bit
    adc $00,x ; set a to the value at $00,x plus a
    sta $00,x ; store result back into $00,x
    bcc @exit ; if a carry is required (>255), then increment the byte at $01,x
    inc $01,x ; increment high byte

@exit:
    rts

; dead code, never called !(UNUSED)
@handle_overflow:
    eor #$ff                  ; flip all bits
    sec                       ; set carry flag
    adc $00,x                 ; flip all bits add 1 to handle overflow
    sta $00,x                 ; store result back in $00,x
    bcs @handle_overflow_exit
    dec $01,x                 ; decrement high bight

@handle_overflow_exit:
    rts

; loads the pattern table (graphic_data_01), nametable (graphic_data_02), and palette data (transition_screen_palettes)
load_intro_graphics:
    jsr init_APU_channels
    jsr clear_memory_3                        ; clear $0028 to $00f0 then CPU_SPRITE_BUFFER up to CPU_GRAPHICS_BUFFER
    lda #$1e                                  ; %0001 1110 no RGB emphasis, show sprites, show background
                                              ; show sprites and background in leftmost 8 pixels of screen
                                              ; no grayscale
    sta PPUMASK_SETTINGS                      ; set PPUMASK setting to #$1e
    ldy #$00
    sty SPRITE_LOAD_TYPE                      ; if 0, load regular sprites to cpu, else load hud sprites
    iny
    sty DEMO_MODE                             ; set DEMO_MODE to true
    lda #$0b                                  ; offset into level_graphic_data_tbl pointing to intro_graphic_data_01 (intro graphics)
    jsr load_A_offset_graphic_data            ; load all of intro graphics specified: $01 (graphic_data_01), $02 (graphic_data_02)
    lda #$06                                  ; offset into short_text_pointer_table, which is transition_screen_palettes (bank 6 $b302)
    jsr load_bank_6_write_text_palette_to_mem ; load palette data to CPU memory CPU_GRAPHICS_BUFFER

exit_load_graphics_group:
    rts

; loads the graphic data for the current level
load_current_level_graphic_data:
    lda CURRENT_LEVEL

; loads the graphic data for the level specified by offset into level_graphic_data_tbl (A register) into the PPU
; most often the pattern table data, but can be nametable data (blank_nametables, graphic_data_02, graphic_data_18)
load_level_graphic_data:
    asl                            ; each entry is 2 bytes, so multiply offset by 2
    tay                            ; store offset into y
    lda level_graphic_data_tbl,y   ; load low byte of graphic data address
    sta $06                        ; store low byte in $06
    lda level_graphic_data_tbl+1,y ; load high byte of graphic data address
    sta $07                        ; store high byte in $07
    ldy #$00                       ; set graphic data index to 0
    sty $05                        ; store graphic data index in $05

; loop through each graphic data and load it in PPU memory
@loop:
    lda ($06),y                   ; read 2-byte memory address where graphics are located in memory for the current index (Y)
    bmi exit_load_graphics_group  ; if read #ff, then we are done with the graphic data
    jsr write_graphic_data_to_ppu ; load the graphics into the PPU
    inc $05                       ; increment graphics offset
    ldy $05
    bne @loop                     ; load next graphics

; pointer table for graphic data codes (#$0d * #$02 = $1a bytes) CPU address $c8e3
; each entry in this table points to a list of graphic data to load
level_graphic_data_tbl:
    .addr level_1_graphic_data      ; level 1 - CPU address $c8fd
    .addr level_2_graphic_data      ; level 2 - CPU address $c905
    .addr level_3_graphic_data      ; level 4 - CPU address $c916
    .addr level_4_graphic_data      ; level 3 - CPU address $c90d
    .addr level_5_graphic_data      ; level 5 - CPU address $c91e
    .addr level_6_graphic_data      ; level 6 - CPU address $c926
    .addr level_7_graphic_data      ; level 7 - CPU address $c92e
    .addr level_8_graphic_data      ; level 8 - CPU address $c936
    .addr level_2_boss_graphic_data ; level 2 boss room - CPU address $c93b
    .addr level_4_boss_graphic_data ; level 4 boss room - CPU address $c940
    .addr intro_graphic_data_00     ; intro graphics - CPU address $c946
    .addr intro_graphic_data_01     ; intro graphics and intro nametable - CPU address $c948
    .addr ending_graphic_data       ; ending scene - CPU address $c94b

; the following labels contains a list of bytes
; each byte is an offset into the graphic_data_ptr_tbl table
; each label ends in #$ff
; CPU memory $c8fd
level_1_graphic_data:
    .byte $03,$13,$19,$1a,$14,$16,$05,$ff ; level 1

; CPU memory $c905
level_2_graphic_data:
    .byte $03,$04,$06,$0a,$0f,$10,$11,$ff ; level 2

; CPU memory $c90d
level_4_graphic_data:
    .byte $03,$04,$06,$0a,$0f,$10,$11,$12,$ff ; level 4

level_3_graphic_data:
    .byte $03,$13,$19,$1a,$14,$16,$07,$ff ; level 3

level_5_graphic_data:
    .byte $03,$13,$19,$1a,$15,$16,$0b,$ff ; level 5

level_6_graphic_data:
    .byte $03,$13,$19,$1a,$15,$16,$0c,$ff ; level 6

level_7_graphic_data:
    .byte $03,$13,$19,$1a,$15,$16,$0d,$ff ; level 7

level_8_graphic_data:
    .byte $03,$13,$19,$0e,$ff ; level 8

level_2_boss_graphic_data:
    .byte $03,$04,$13,$08,$ff ; level 2 boss room

level_4_boss_graphic_data:
    .byte $03,$04,$13,$08,$09,$ff ; level 4 boss room

intro_graphic_data_00:
    .byte $01,$ff ; intro palette

; graphic_data_01, graphic_data_02
; #$01 - intro screen, level title screens, and game over screens pattern table tiles
; #$02 - game and level intro screen nametable data
intro_graphic_data_01:
    .byte $01,$02,$ff ; intro pattern table tiles, and intro nametable

ending_graphic_data:
    .byte $01,$03,$17,$18,$ff ; ending scene

; tables for graphic data data pointers (#$1b * #$03 = $51 bytes)
; contains nametable and pattern table data
; CPU address $c950
; first 2 bytes are the memory address to load
; last byte specifies 2 things
;   * bits 0-3 specify the rom bank to have loaded
;     the exception is 0 means bank 7 instead of bank 0)
;   * bit 7 is stored in $04, when set it means all tiles from
;     the graphic data must be flipped horizontally
graphic_data_ptr_tbl:
    ; reset both PPU nametables to zeros
    ; bank 7 (not bank 0)
    .addr blank_nametables ; CPU address $cb36
    .byte $00              ; bank 7 not bank 0

    ; bank 4 - intro, level title, game over screen pattern table
    .addr graphic_data_01 ; CPU address $c953
    .byte $04             ; bank where data located

    ; bank 2 - intro screen nametable
    .addr graphic_data_02
    .byte $02             ; bank where data located

    ; bank 4 - character, medals, power-ups, explosions
    .addr graphic_data_03
    .byte $04             ; bank where data located

    ; bank 4 - character facing up
    .addr graphic_data_04
    .byte $04             ; bank where data located

    ; bank 5 - level 1 bridge, mountain, and water tiles
    .addr graphic_data_05 ; CPU address $8001
    .byte $05             ; bank where data located

    ; bank 4 - most Base graphics
    .addr graphic_data_06
    .byte $04             ; bank where data located

    ; bank 5
    .addr graphic_data_07
    .byte $05             ; bank where data located

    ; bank 4
    .addr graphic_data_08
    .byte $04             ; bank where data located

    ; bank 4
    .addr graphic_data_09
    .byte $04             ; bank where data located

    ; bank 4
    .addr graphic_data_0a
    .byte $04             ; bank where data located

    ; bank 5
    .addr graphic_data_0b
    .byte $05             ; bank where data located

    ; bank 6
    .addr graphic_data_0c
    .byte $06             ; bank where data located

    ; bank 6
    .addr graphic_data_0d
    .byte $06             ; bank where data located

    ; bank 6
    .addr graphic_data_0e
    .byte $06             ; bank where data located

    ; bank 4
    .addr graphic_data_0f
    .byte $04             ; bank where data located

    ; bank 4
    ; horizontal flip
    .addr graphic_data_10
    .byte $84             ; bank where data located (with horizontal flip)

    ; bank 4
    .addr graphic_data_11
    .byte $04             ; bank where data located

    ; bank 4 - Base 2 Graphics
    .addr graphic_data_12
    .byte $04             ; bank where data located

    ; bank 4 - player top-half aiming up and aiming straight, also contains the laser sprites
    .addr graphic_data_13 ; CPU address $87a1
    .byte $04             ; bank where data located

    ; bank 5 - rotating gun and red turret
    .addr graphic_data_14 ; CPU address $a814
    .byte $05             ; bank where data located

    ; bank 6
    .addr graphic_data_15
    .byte $06             ; bank where data located

    ; bank 6 - weapon box
    .addr graphic_data_16 ; CPU address $b15c
    .byte $06             ; bank where data located

    ; bank 5
    .addr graphic_data_17
    .byte $05             ; bank where data located

    ; bank 5
    .addr graphic_data_18
    .byte $05             ; bank where data located

    ; bank 5 - player killed sprite tiles: recoil from hit and lying on ground
    .addr graphic_data_19 ; CPU address $a31b
    .byte $05             ; bank where data located

    ; bank 5 - soldier pattern table tiles
    .addr graphic_data_1a ; CPU address $a500
    .byte $05             ; bank where data located

; CPU address $c9a2
zero_out_nametables:
    lda #$00

; loads and decompresses the entire graphic data specified by the A register as offset into graphic_data_ptr_tbl
write_graphic_data_to_ppu:
    sta $04                      ; use $04 as a temp location so we can triple a
    asl                          ; double a data
    adc $04                      ; add $04 data to a (the previous 3 lines are simply multiplying by 3)
                                 ; lookup table is 3 bytes each, so multiply by 3 to get offset
    tax
    lda graphic_data_ptr_tbl,x
    sta $00                      ; store graphic address low byte in $00
    lda graphic_data_ptr_tbl+1,x
    sta $01                      ; store graphic address high byte in $01
    lda graphic_data_ptr_tbl+2,x ; load byte that stores bank number as well as whether or not to horizontally flip
    and #$80                     ; %1000 0000 (check the msb), if msb is 1, then block will be flipped horizontally
    sta $04                      ; store whether or not flip the entire graphic data horizontally into $04
                                 ; #$80 = flip, #$00 = no flip
    lda graphic_data_ptr_tbl+2,x ; re-read the bank number to load the graphics from
    and #$07                     ; clear out the flip horizontal bit (only care about the last 3 bits which specify the bank number)
    tay                          ; store the bank number where data is in Y
    jsr load_bank_number         ; store current bank in $07ec and load new bank
    jsr clear_ppu                ; resets A to #$00 as well
    sta GRAPHICS_BUFFER_OFFSET   ; set cpu graphics buffer offset
    sta VERTICAL_SCROLL          ; set vertical scroll offset to 0
    sta HORIZONTAL_SCROLL        ; set horizontal scroll offset to 0

; reads 2-bytes of memory starting at address $00,$01, which is a specific graphic_data
; and sets the PPUADDR to that address
; then begins decompressing the graphic data and starts writing to PPU
begin_ppu_graphics_block_write:
    lda PPUSTATUS               ; reset PPU latch to prep for writing
    ldy #$01
    lda ($00),y                 ; read high byte from ROM location specified by $00 and $01
    sta PPUADDR                 ; set high byte of PPU address location to write to
    dey                         ; move to low byte
    lda ($00),y                 ; read low byte from ROM location specified by $00 and $01
    sta PPUADDR                 ; set low byte of PPU address location to write to
    lda #$02                    ; a = #$02 (input to advance_graphic_read_addr, used to skip 2-byte PPU address)
    ldx $04                     ; load horizontal flip bit
    bpl init_graphic_data_index ; #$00 = no flip, #$80 = flip, if positive don't double since no horizontal flip
    asl                         ; $04 = #$80 so flipping horizontally, double a to be #$04 to skip 2 additional bytes
                                ; this skips the real PPU address as well as the PPU address specified in the referenced graphic data
                                ; for example, graphic_data_10 has PPU address of $1600 and is flipped from graphic_data_0a
                                ; must skip the 2 bytes at the start of graphic_data_0a

; increment the next address to use for the PPU
init_graphic_data_index:
    ldx #$00
    jsr advance_graphic_read_addr ; advance past the PPU address and start reading graphic data

; reads the next graphics byte compression sequence and writes it to the PPU
; multiple times depending on the number of repetitions specified
write_graphic_data_sequences_to_ppu:
    ldy #$00                       ; set offset so next line reads number of repetitions
    lda ($00),y                    ; read the byte of the graphic data
    cmp #$ff                       ; see if we are at the end of the graphic data
    beq end_graphic_code           ; loaded entire graphics data, restore previously loaded bank, re-init PPU
    cmp #$7f                       ; used to specify the PPU write address should change to the address specified in the next 2 bytes)
    beq change_ppu_write_address
    tay                            ; store command code byte in y
    bpl write_graphic_byte_a_times ; branch if byte is < #$7f to write the next byte multiple times (RLE-command)
    and #$7f                       ; byte has bit 7 set (negative), code is writing a string of bytes
                                   ; clear bit 7 to get number of bytes to write from compressed data
    sta $02                        ; store positive portion in $02, this is the number of bytes to write to PPU
    ldy #$01                       ; skip past size byte, prepare to read next n graphic bytes

; writes the next n bytes of the compressed graphic data to the PPU, starting at offset Y
; input
;  * $02 - the number of bytes to write (n)
;  * y - the graphic data read offset
write_next_n_sequence_bytes:
    lda ($00),y                      ; read graphic byte
    ldx $04                          ; load graphic data horizontal flip bit value
    bpl @write_byte_to_ppu           ; branch if not flipping graphic byte
    jsr horizontal_flip_graphic_byte ; flipping horizontally, flip data before writing to PPU

; writes value of a to the PPU
; then determines if done with the n-length byte sequence of graphic data
@write_byte_to_ppu:
    sta PPUDATA                           ; write graphic byte to PPU
    cpy $02                               ; see if written all n repetitions
    beq advance_graphic_read_addr_n_bytes ; written all n bytes, update base graphic read address
    iny                                   ; have not written $02 times, write next byte
    bne write_next_n_sequence_bytes       ; loop $02 times

; advances the address of the current graphic byte offset by n bytes
; where n is the value in $02 + #$1
; the #$01 is necessary to skip passed the command byte
advance_graphic_read_addr_n_bytes:
    lda #$01 ; advancing graphic byte read address by 1 (size of repetition string)
    clc      ; clear carry in preparation for addition
    adc $02  ; skip over the bytes just written the PPU
             ; a now has the number of bytes to skip

advance_ppu_write_addr:
    ldx #$00                                ; specifies that the 2-byte graphic read address is located at $00
    jsr advance_graphic_read_addr           ; advance graphic read address by a bytes
    jmp write_graphic_data_sequences_to_ppu

; write the next graphic byte to the PPU A times ($02)
write_graphic_byte_a_times:
    ldy #$01                         ; offset to read graphic data byte
    sta $02                          ; store number of repetitions of graphic byte to $02
    lda ($00),y                      ; load the graphic byte into a
    ldy $02                          ; load the number of repetitions into y
    ldx $04                          ; load whether or not to flip the graphic horizontally into x
    bpl write_a_to_ppu_y_times       ; write graphic byte to PPU Y times no horizontal flip needed
    jsr horizontal_flip_graphic_byte ; flip graphics byte horizontally

; writes the value of a to PPU repeatedly y times
write_a_to_ppu_y_times:
    sta PPUDATA                ; write PPU value address to PPU
    dey                        ; decrement counter
    bne write_a_to_ppu_y_times ; RLE loop Y times
    lda #$02                   ; prepare to read and write next graphic data byte
    bne advance_ppu_write_addr ; continue updating PPU with data

; horizontal flip routine
; swap bit 0 with 7, bit 1 with 6, bit 2 with 5, and bit 3 with 4
horizontal_flip_graphic_byte:
    sta $03
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    asl $03
    ror a
    rts

; changes the PPU address where the graphic data bytes are written to
change_ppu_write_address:
    lda #$01                           ; specifies to increment graphic read address by 1 byte
    ldx #$00                           ; specifies that the 2-byte graphic read address is located at $00
    jsr advance_graphic_read_addr      ; increment 2-byte graphic read address at $00 by 1 byte
    jmp begin_ppu_graphics_block_write ; start writing graphics block to PPU

; handle when entire graphic data code has been read
; restore previously-loaded bank and re-init the PPU
end_graphic_code:
    jsr load_previous_bank
    jmp configure_PPU

; input
;  * $1e - player index, #$00 = 1 player, #$01 = 2 player
;    specifies REST text location, and which scores to load
draw_player_num_lives:
    lda #$1e                                  ; a = #$1e
    sta $02                                   ; !(HUH) unused variable $02 set to #$1e
    lda #$07                                  ; a = #$07 (text_rest)
    clc                                       ; clear carry in preparation for addition
    adc $1e                                   ; add #$00 or #$01 to use either text_rest (higher location) or text_rest2 (lower location)
    jsr load_bank_6_write_text_palette_to_mem ; draw text string (REST)
    ldx $1e                                   ; #$00 = player 1, #$01 = player 2
    lda P1_GAME_OVER_STATUS,x                 ; load game over state for player x (1 = game over)
    eor #$01                                  ; flip bit 0 (adds #$01 to remaining lives when not in game over)
    clc                                       ; clear carry in preparation for addition
    adc P1_NUM_LIVES,x                        ; add the remaining player lives
    beq draw_game_over_tex                    ; draw game over if no lives remaining
                                              ; (for 2 player game when one of 2 players is game over)
    bpl @continue                             ; continue if more than #$00 lives remaining
    lda #$00                                  ; a = #$00 (remaining lives is negative, not sure if possible) !(WHY?)

@continue:
    ldx #$00 ; initialize 10s calculation 'multiplier' to #$00

; draws number of lives remaining left to right
; 10s digit is calculated in x by repeatedly subtracting 10
; max number of lives able to printed is #$63 (99)
@draw_num_lives:
    sta $00             ; store updated number of lives in $00
    cmp #$0a            ; see if new number of lives is greater than 10 (more than one digit)
    bcc @convert_digits ; branch if new amount is less than 10 lives to just draw the digit
    sbc #$0a            ; subtract 10 from remaining lives to draw 10s digit
    inx                 ; increment 10s digit
    cpx #$0a            ; see if 10 loops have happened, i.e. 10s digit more than 9
    bcc @draw_num_lives ; continue subtracting 10 if number is larger than 10
    ldx #$09            ; score 10s digit was larger than 9, reset it to 9, i.e. largest number to draw is 99
    txa                 ; transfer 10s score to a

; input
;  * a - ones digit
;  * x - 10s digit
@convert_digits:
    ldy GRAPHICS_BUFFER_OFFSET ; load the cpu graphics buffer offset
    ora #$30                   ; converting the ones digit to pattern tile offset
                               ; #$31 = 1, #$32 = 2, etc.
    cpx #$00                   ; see if 10s digit is 0
    bne @write_num_lives       ; branch to write 0 and exit if num lives is 0
    cmp #$30                   ; 10s digit non-zero, see if
    beq @exit                  ; exit if just drew a 0, meaning no more digits to draw

@write_num_lives:
    sta CPU_GRAPHICS_BUFFER-2,y ; set ones digit
    txa                         ; transfer 10s digit to a
    beq @exit                   ; exit without drawing 10s digit if #$00
    ora #$30                    ; converting number to pattern tile offset
                                ; #$31 = 1, #$32 = 2, etc.
    sta CPU_GRAPHICS_BUFFER-3,y ; set 10s digit of num lives

@exit:
    rts

draw_game_over_tex:
    txa
    clc                                       ; clear carry in preparation for addition
    adc #$0f
    jmp load_bank_6_write_text_palette_to_mem ; draw text string

; draw text "stage  " and the level's name
draw_stage_and_level_name:
    lda #$0c                                  ; a = $0c (text string "stage  ")
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda CURRENT_LEVEL                         ; current level number
    clc                                       ; clear carry in preparation for addition
    adc #$31
    sta CPU_GRAPHICS_BUFFER-2,x               ; draw current level
    lda CURRENT_LEVEL                         ; current level
    adc #$11                                  ; string id = level number + 11
    jmp load_bank_6_write_text_palette_to_mem ; draw text string

; draw the scores
draw_the_scores:
    lda #$09                                  ; a = #$09 (text string "hi")
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda HIGH_SCORE_LOW                        ; high score (low byte)
    sta $00
    lda HIGH_SCORE_HIGH                       ; high score (high byte)
    sta $01
    jsr @draw_score
    lda #$0a                                  ; a = $0a (text string "1p")
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda PLAYER_1_SCORE_LOW                    ; player 1 score (low byte)
    sta $00
    lda PLAYER_1_SCORE_HIGH                   ; player 1 score (high byte)
    sta $01
    jsr @draw_score
    lda PLAYER_MODE                           ; single player vs two player ($00 = 1 player)
    beq @exit                                 ; don't draw player 2 if no player 2
    lda #$0b                                  ; a = #$0b (text string "2p")
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda PLAYER_2_SCORE_LOW                    ; player 2 score (low byte)
    sta $00
    lda PLAYER_2_SCORE_HIGH                   ; player 2 score (high byte)
    sta $01

; prints the #$02-byte score stored in $01 and $02 on the screen
; $caf8
@draw_score:
    lda FRAME_COUNTER ; load frame counter
    and #$10          ; only interested in 5th bit
    bne @exit         ; don't print score if frame counter low (used for flashing effect)
    lda #$05          ; high score has a maximum of #$05 digits to print
    sta $04           ; store maximum number of digits into $04

; digits are calculated from right to left, then two 0s are tacked to end (unless the score is 0)
@draw_score_digit:
    lda #$0a                    ; ensuring the high score digits is below decimal 10
    sta $03                     ; store $0a into $03
    jsr calculate_score_digit   ; calculate next digit and store into $02
    lda $02                     ; load the digit of the score to display from $02
    ora #$30                    ; convert from number to character to display. In Contra 30 = 0, 31 = 1, etc.
    sta CPU_GRAPHICS_BUFFER-4,x ; draw digit
    dex                         ; move to the previous digit (score drawn right to left)
    lda $00                     ; load current low byte of score
    ora $01                     ; combine low byte with high byte
    beq @draw_score_end_zeros   ; if both high and low bytes are 0, printing of the score is finished, add two 0s to end
    dec $04                     ; decrement the digit counter, only #$05 decimal digits are used
    bne @draw_score_digit       ; draw the next digit if less than #05 digits have been drawn

@draw_score_end_zeros:
    ldx GRAPHICS_BUFFER_OFFSET  ; index int PPU character map
    lda $04                     ; load the number of digits remaining (starts at $05)
    sec                         ; set carry flag in preparation for subtraction
    sbc #$05                    ; subtract 5 from total digits used, used to know if no digits have been printed
    ora $02                     ; see if score is #$00
    beq @draw_zero_score        ; handle when the score is #$00 (don't tack on ending 00s)
    lda #$30                    ; set the character to display to 0
    sta CPU_GRAPHICS_BUFFER-3,x ; display the character '0'

@draw_final_0_exit:
    sta CPU_GRAPHICS_BUFFER-2,x ; display the character '0'

@exit:
    rts

; handle the case when player score is $00, i.e. no points were scored
@draw_zero_score:
    sta CPU_GRAPHICS_BUFFER-4,x ; this is the first decimal digit of the score, set it to '0'
    lda #$30                    ; display the character '0'
    bne @draw_final_0_exit      ; always branch, to exit out of @draw_score_digit

; graphic data to reset nametables (#$2a bytes)
; set nametable 0 ($2000) and nametable 1 ($2400) all to #$00
; #$400 bytes (1 KiB) each
; first #$2 bytes are the nametable address ($2000)
; then repeatedly write #$78 zeros, then finally #$40 zeros.
; #$7f signifies keep reading to clear the $2400 nametable
; nametable data - writes addresses [$2000-$2800)
; CPU address $cb36
graphic_data_00:
blank_nametables:
    .byte $00,$20,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00
    .byte $78,$00,$40,$00,$7f

; first #$2 bytes are the nametable address (#$2400)
blank_nametable_2:
    .byte $00,$24,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00
    .byte $78,$00,$40,$00,$ff

; write pattern tile (text) or palette information (color) to CPU offset CPU_GRAPHICS_BUFFER
; this is used when GRAPHICS_BUFFER_MODE is #$00, which defines the CPU_GRAPHICS_BUFFER format for text and palette data
; input
;  * a - first six bits are index into the short_text_pointer_table
;  when bit 7 set, write all blank characters instead of actual characters. Used for flashing effect
write_text_palette_to_mem:
    pha                                ; push a to stack (index into short_text_pointer_table)
    lda #$02                           ; a = #$02
    sta $03                            ; used when bit 7 of a is set, indicating to clear text
                                       ; since the first #$02 bytes are PPU address,
                                       ; $03 is used to prevent overwriting PPU address with #$00
    lda #$01                           ; a = #$01 (next #$02 bytes are PPU address)
    jsr write_a_to_cpu_graphics_buffer ; write #$01 to CPU_GRAPHICS_BUFFER,x
    pla                                ; restore the index into short_text_pointer_table to print
    sta $02                            ; store index into short_text_pointer_table $02
    asl                                ; double index, since short_text_pointer_table is 2 bytes per label address
    tax                                ; transfer index to x register
    lda short_text_pointer_table,x     ; read the low-byte memory address from pointer table
    sta $00                            ; store low byte of short_text_pointer_table address
    lda short_text_pointer_table+1,x   ; high byte of pointer table
    sta $01                            ; store high byte of short_text_pointer_table address
    ldx GRAPHICS_BUFFER_OFFSET         ; set X to store the next offset of CPU_GRAPHICS_BUFFER
    ldy #$00                           ; initialize character offset into string to 0

; read until #fe, #$fd, or #$ff and store CPU memory starting at CPU_GRAPHICS_BUFFER
@write_char_to_cpu_mem:
    lda ($00),y                 ; read character from string
    iny                         ; increment character offset
    cmp #$ff                    ; #$ff signifies end of string, the #$ff isn't stored in CPU memory
    beq set_x_to_offset_exit    ; if #ff, the string has been completely loaded, restore x to GRAPHICS_BUFFER_OFFSET and exit
    cmp #$fe                    ; like #$ff, #$fe is end of string, but #fe causes #$ff to be stored in CPU memory at end of string
    beq @write_ff_to_cpu_memory ; store #$ff in CPU memory at the end of the string
    cmp #$fd                    ; #fd specifies next two bytes are the PPU address, i.e. changing location on screen
    beq @handle_fd              ; branch if next two bytes are a new PPU address
    sta CPU_GRAPHICS_BUFFER,x   ; store character in CPU graphics buffer
    lda $02                     ; load the index into text string table into A, i.e. which string to print
    bpl @next_char              ; branch if text ins't being blanked (part of flashing animation)
    lda $03                     ; not writing characters, writing blanks to hide text
                                ; see if already written PPU address (#$02 bytes)
    bne @dec_blank_delay        ; branch if writing PPU address to CPU graphics buffer
    sta CPU_GRAPHICS_BUFFER,x   ; write #$00 character to cpu memory to blank the text for flashing animation
    beq @next_char              ; continue to next character to read

@dec_blank_delay:
    dec $03 ; decrement delay to allow writing PPU address before writing all #$00s for text

@next_char:
    inx                        ; move to next cpu graphics buffer write offset
    bne @write_char_to_cpu_mem ; loop to read next character

; #$fe encountered (end of string)
@write_ff_to_cpu_memory:
    lda #$ff                ; set the zero flag so next line jumps and #$ff is stored in CPU memory
    bne write_to_700_offset ; always branch to write #$ff to CPU graphics buffer and exit

; read next two bytes for PPU address
; used to write both CONTINUE and END together
@handle_fd:
    lda #$ff                           ; #$ff tells CPU graphics buffer reading logic to prepare to read next segment of text
    jsr write_to_700_offset            ; write #$ff to cpu buffer
    lda #$02                           ; set to #$02 to skip blanking (zeroing) the PPU address when writing to CPU memory
    sta $03                            ; reset delay before blanking text (flashing animation)
    lda #$01                           ; vram_address_increment offset (#$01 = write across)
    jsr write_to_700_offset            ; write vram_address_increment offset
    bne @write_char_to_cpu_mem         ; branch to write next PPU address and string of text
    lda #$ff                           ; not sure when this would execute !(WHY?)
    bne write_a_to_cpu_graphics_buffer

write_0_to_cpu_graphics_buffer:
    lda #$00
    beq write_a_to_cpu_graphics_buffer ; always jumps since lda loads #$0, also it's the next line of code !(HUH)

write_a_to_cpu_graphics_buffer:
    ldx GRAPHICS_BUFFER_OFFSET ; update X to next location to write to in CPU_GRAPHICS_BUFFER offset

; store A into string memory
write_to_700_offset:
    sta CPU_GRAPHICS_BUFFER,x
    inx

set_x_to_offset_exit:
    stx GRAPHICS_BUFFER_OFFSET

vram_address_increment:
    rts

; table for PPU VRAM address increment (#$03 bytes)
; used to set whether the the VRAM address increments by 1 (across) or #$20 (down)
.byte $00,$04,$00

; writes the graphics data loaded in CPU_GRAPHICS_BUFFER to the PPU for drawing
write_cpu_graphics_buffer_to_ppu:
    lda GRAPHICS_BUFFER_MODE       ; load flag to determine if we should write the CPU_GRAPHICS_BUFFER to the PPU
    bne @flush_cpu_graphics_buffer ; branch when non-zero. write CPU_GRAPHICS_BUFFER to the PPU
    ldy #$00                       ; GRAPHICS_BUFFER_MODE is #$00, zero out $08
    sty $08                        ; clear $08 address override flag so graphics buffer can be read

@read_cpu_mem_to_ppu:
    lda $08       ; read previous high byte of PPU write address
    cmp #$3f      ; compare $08 to #$3f (seeing if palette write)
    bne @continue ; skip ahead if $08 is not equal to #$3f (not writing palette)
    sta PPUADDR   ; !(OBS) I think this is attempting to prevent the NTSC NES palette corruption bug
    lda #$00      ; the palette can get corrupted after writes to it
                  ; the workaround is to update the PPUADDR twice after writing to palette memory
    sta PPUADDR   ; ref: https://www.nesdev.org/wiki/PPU_registers#Address_($2006)_%3E%3E_write_x2
    sta PPUADDR   ; (1) set PPUADDR to $3f00, then (2) set PPUADDR outside palette memory (in this case $0000)
    sta PPUADDR   ; these steps prevent palette corruption

; CPU address $cbe5
@continue:
    ldx CPU_GRAPHICS_BUFFER,y    ; read byte #$00 (used to set PPUCTRL)
    beq @reset_graphics_buffer   ; nothing to draw, exit
    lda PPUCTRL_SETTINGS         ; load PPUCTRL settings
    and #$18                     ; %0001 1000
    ora vram_address_increment,x ; include the VRAM increment offset
    sta PPUCTRL                  ; set background and sprite pattern table addresses
    iny
    lda PPUSTATUS                ; clear bit 7 and address latch used by PPUSCROLL and PPUADDR
    lda CPU_GRAPHICS_BUFFER,y
    sta $08                      ; store high byte of PPU data write address into $08
    sta PPUADDR                  ; store high byte of PPU address
    iny                          ; increment offset into CPU memory
    lda CPU_GRAPHICS_BUFFER,y    ; read next byte from CPU_GRAPHICS_BUFFER CPU memory address
    sta PPUADDR                  ; store low byte of PPU data write address
    iny                          ; increment CPU_GRAPHICS_BUFFER CPU read offset
    cpx #$03                     ; if vram_address_increment offset is 3
    bne @flush_graphics_buffer   ; write graphics data until #$ff
    lda CPU_GRAPHICS_BUFFER,y    ; 0.3 mode - read total number of tiles/bytes to write to PPU
    sta $09                      ; store value in $09

; writes a block of bytes to PPU
@loop:
    iny                       ; increment CPU_GRAPHICS_BUFFER read offset
    lda CPU_GRAPHICS_BUFFER,y ; read graphic byte
    sta PPUDATA               ; store in PPU
    dec $09                   ; decrement total number of tiles/bytes to write
    bne @loop                 ; loop if more tiles to write

; sets first byte of CPU_GRAPHICS_BUFFER to #$00 so no drawing takes place for frame
@reset_graphics_buffer:
    lda #$00
    sta CPU_GRAPHICS_BUFFER    ; set initial byte to 0
    sta GRAPHICS_BUFFER_OFFSET ; set PPU pattern table offset to 0
    lda PPUCTRL_SETTINGS       ; saved PPUCTRL settings (see configure_PPU)
    sta PPUCTRL                ; configure pattern table address, and sprite size
    rts

@write_ff_to_ppu:
    lda #$ff ; a = $ff

@write_byte_to_ppu:
    sta PPUDATA

; write to PPU until #$ff is encountered
@flush_graphics_buffer:
    lda CPU_GRAPHICS_BUFFER,y ; read next byte to write to PPU
    iny                       ; increment CPU_GRAPHICS_BUFFER read offset
    cmp #$ff                  ; compare to end of data byte #$ff
    bne @write_byte_to_ppu    ; if not #$ff, then write to PPU
    lda CPU_GRAPHICS_BUFFER,y ; byte was #$ff, see what next graphic byte is
    cmp #$04                  ; compare graphic byte to #$04
    bcs @write_ff_to_ppu      ; branch if byte is greater than or equal to #$04
    bcc @read_cpu_mem_to_ppu  ; continue writing CPU_GRAPHICS_BUFFER (0 mode or nonzero mode)

; writes the entire graphics buffer to the PPU
; GRAPHICS_BUFFER_MODE nonzero mode
@flush_cpu_graphics_buffer:
    ldx #$00             ; reset CPU_GRAPHICS_BUFFER read offset back to beginning
    lda PPUCTRL_SETTINGS
    and #$18             ; only care about nametable address and sprite pattern table address
    sta $02              ; store in $02 for future use in PPUCTRL

; every loop of this prints a few more columns of nametable
; every loop CPU_GRAPHICS_BUFFER is different
@write_to_ppu:
    ldy CPU_GRAPHICS_BUFFER,x    ; read first byte $700
    beq @reset_graphics_buffer   ; if #$00, done - clear CPU_GRAPHICS_BUFFER
    lda $02
    ora vram_address_increment,y
    sta PPUCTRL
    inx
    lda CPU_GRAPHICS_BUFFER,x    ; read first byte - length of data to write
    sta $00                      ; store length of data to write in group in $00
    inx                          ; increment CPU_GRAPHICS_BUFFER read offset
    lda CPU_GRAPHICS_BUFFER,x    ; read second byte - number of byte blocks to write
    sta $01                      ; set the number of blocks of memory to write

; set the PPU write address based on the CPU_GRAPHICS_BUFFER
@set_PPU_write_address:
    ldy $00
    inx
    lda CPU_GRAPHICS_BUFFER,x
    sta PPUADDR
    inx
    lda CPU_GRAPHICS_BUFFER,x
    sta PPUADDR

; loop through CPU_GRAPHICS_BUFFER block and write all bytes to PPU
@write_loop:
    inx                        ; increment cpu read offset
    lda CPU_GRAPHICS_BUFFER,x  ; read graphics buffer byte
    sta PPUDATA                ; write byte to PPU
    dey                        ; decrement PPU write byte count
    bne @write_loop            ; loop if not yet written entire block of bytes
    dec $01                    ; decrement number of byte blocks counter
    bne @set_PPU_write_address ; if more byte blocks to write, loop to read PPU write address
    inx                        ; no more data to write, increment cpu read offset
    bne @write_to_ppu          ; jump to see if another set of data to write, never fall through to line of code below

; writes the palette data in cpu memory PALETTE_CPU_BUFFER to the ppu
; in the $3f00 ppu address range (palette data)
write_palette_colors_to_ppu:
    ldx NUM_PALETTES_TO_LOAD   ; load the number of palettes to write to PPU memory
    beq graphics_loading_exit  ; exit if #$00
    lda GRAPHICS_BUFFER_OFFSET
    cmp #$30
    bcs graphics_loading_exit  ; exit if the offset is >= #$30
    lda PPUCTRL_SETTINGS
    and #$18                   ; keep ...x x...
    sta PPUCTRL                ; ensure sprite and background pattern tables are configured correctly
    lda #$3f                   ; set PPU write address to $3f00 (palette address range)
    sta PPUADDR
    lda #$00
    sta PPUADDR
    tay

; now write the palette data in the cpu buffer PALETTE_CPU_BUFFER
@loop:
    lda PALETTE_CPU_BUFFER,y ; load the current palette
    sta PPUDATA
    iny
    dex
    bne @loop
    lda #$3f
    sta PPUADDR              ; !(OBS) I think this is attempting to prevent the NTSC NES palette corruption bug
    stx PPUADDR              ; the palette can get corrupted after writes to it
                             ; the workaround is to update the PPUADDR twice after writing to palette memory
                             ; ref: https://www.nesdev.org/wiki/PPU_registers#Address_($2006)_%3E%3E_write_x2
    stx PPUADDR              ; (1) set PPUADDR to $3f00, then (2) set PPUADDR outside palette memory (in this case $0000)
    stx PPUADDR              ; these steps prevent palette corruption after writing to the palette memory
    stx NUM_PALETTES_TO_LOAD ; set number of palettes to load to #$3f
                             ; don't think this value is ever read when it's #$3f, overwritten later

graphics_loading_exit:
    rts

; load alternate tiles if necessary
alternate_tile_loading:
    lda ALT_GRAPHIC_DATA_LOADING_FLAG ; whether or not to start loading alternate graphics
    beq graphics_loading_exit         ; if not loading alternate graphics, then exit
    bmi set_alt_graphics_cpu_buffer   ; already initialized alt graphics loading, continue loading. ALT_GRAPHIC_DATA_LOADING_FLAG is $80
    lda CURRENT_LEVEL                 ; load current level
    asl
    asl
    adc CURRENT_LEVEL                 ; level = level * #$05 (each entry is #$05 bytes)
    tay
    lda alt_graphic_data_ptr_tbl,y    ; load PPU write address low byte
    sta $6c
    lda alt_graphic_data_ptr_tbl+1,y  ; load PPU write address high byte
    sta $6d
    lda alt_graphic_data_ptr_tbl+2,y  ; load graphics data read location low byte
    sta $6e
    lda alt_graphic_data_ptr_tbl+3,y  ; load graphics data read location high byte
    sta $6f
    lda alt_graphic_data_ptr_tbl+4,y  ; load the number of tiles to change
    beq alt_graphics_loading_complete ; if #$00 no data to change, so mark ALT_GRAPHIC_DATA_LOADING_FLAG as #$00 and exit
    sta $70
    lda #$80
    sta ALT_GRAPHIC_DATA_LOADING_FLAG ; set flag to specify alternate graphics are currently loading

set_alt_graphics_cpu_buffer:
    ldx GRAPHICS_BUFFER_OFFSET
    cpx #$10
    bcs graphics_loading_exit
    lda #$01                    ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x
    sta CPU_GRAPHICS_BUFFER+2,x
    inx
    lda #$20                    ; a = #$20
    sta CPU_GRAPHICS_BUFFER,x
    inx
    inx
    lda $6d                     ; PPU write address high byte
    sta CPU_GRAPHICS_BUFFER,x
    inx
    lda $6c                     ; PPU write address low byte
    sta CPU_GRAPHICS_BUFFER,x
    inx
    ldy #$00                    ; y = #$00

@loop:
    lda ($6e),y
    sta CPU_GRAPHICS_BUFFER,x
    iny
    inx
    cpy #$20
    bne @loop
    stx GRAPHICS_BUFFER_OFFSET
    dec $70
    beq alt_graphics_loading_complete
    lda #$20                          ; a = #$20
    ldx #$6e                          ; x = #$6e
    jsr advance_graphic_read_addr     ; advance 2-byte read address $6e by #$20 bytes
    lda #$20                          ; a = #$20
    ldx #$6c                          ; x = #$6c
    jmp advance_graphic_read_addr     ; advance 2-byte read address $6c by #$20 bytes

alt_graphics_loading_complete:
    lda #$00                          ; a = #$00
    sta ALT_GRAPHIC_DATA_LOADING_FLAG ; mark flag as #$00 to specify no more alternate graphics data to load
    rts

; alternate graphics table, $08 entries each entry is $05 bytes long
; bank 2
; Bytes 0-1: PPU address
; Bytes 2-3: CPU address
; Byte 4   : Number of Tiles to Change (x2)
alt_graphic_data_ptr_tbl:
    .byte $80,$1a
    .addr alt_graphic_data_00
    .byte $2c

    .byte $00,$10
    .addr alt_graphic_data_00
    .byte $00

    .byte $60,$14
    .addr alt_graphic_data_01
    .byte $5d

    .byte $00,$10
    .addr alt_graphic_data_00
    .byte $00

    .byte $a0,$16
    .addr alt_graphic_data_02
    .byte $1d

    .byte $80,$0a
    .addr alt_graphic_data_03
    .byte $22

    .byte $00,$10
    .addr alt_graphic_data_00
    .byte $00

    .byte $60,$1b
    .addr alt_graphic_data_04
    .byte $25

; create #$04 new pattern table tiles starting at PPU address $1fc0
; it takes #$0f bytes per pattern table tile or #$40 bytes total
; it does this by taking a 'background' drawing of the tile, and then drawing electricity on top
animate_indoor_fence:
    lda LEVEL_LOCATION_TYPE   ; 0 = outdoor; 1 = indoor
    bmi @exit                 ; exit for indoor boss screen
    lda INDOOR_SCREEN_CLEARED ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
    beq @draw_random_fence    ; wall cores haven't been destroyed, draw random fence based on FRAME_COUNTER
    lda #$80                  ; screen cleared, don't draw fence, only floor, a = #$80
    sta INDOOR_SCREEN_CLEARED ; flag (0 = not cleared; 1 = cleared, #$80 = cleared, fence removed)
    lda #$20                  ; a = #$20 (pattern_tile_fence_tbl offset for no fence)
    bne @continue             ; always branch

@draw_random_fence:
    lda FRAME_COUNTER ; load frame counter
    and #$03          ; random number [#$00-#$03]
    bne @exit         ; exit if not the 4th frame
    lda FRAME_COUNTER ; change tiles every 4 frames
    and #$0c          ; grab either #$00, #$04, #$08, or #$0c
    asl               ; double to get #$00, #$08, #$10, or #$18 (offset into pattern_tile_fence_tbl)

@continue:
    sta $14                     ; set pattern_tile_fence_tbl offset
    ldx GRAPHICS_BUFFER_OFFSET  ; load graphics buffer offset
    lda #$01                    ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x   ; set VRAM address increment to 0 (write across)
    sta CPU_GRAPHICS_BUFFER+2,x ; set number of groups to #$01 group
    inx                         ; increment graphics buffer write offset
    lda #$40                    ; a = #$40
    sta CPU_GRAPHICS_BUFFER,x   ; set to group size to #$40
    inx                         ; increment graphics buffer write offset
    inx                         ; increment graphics buffer write offset
    lda #$1f                    ; a = #$1f
    sta CPU_GRAPHICS_BUFFER,x   ; set ppu address high byte to #$1f
    inx                         ; increment graphics buffer write offset
    lda #$c0                    ; a = #$c0
    sta CPU_GRAPHICS_BUFFER,x   ; set ppu address low byte to #$c0
                                ; last #$04 bytes of pattern table 1 and then #$3c pattern tiles (PPU address $1fc0)
    inx                         ; increment graphics buffer write offset
    lda pattern_tile_bg_tbl     ; load low byte of pattern_tile_bg_00 address
    sta $10                     ; store low byte of pattern_tile_bg_00 address
    lda pattern_tile_bg_tbl+1   ; load high byte of pattern_tile_bg_00 address
    sta $11                     ; store high byte of pattern_tile_bg_00 address
    lda #$07                    ; a = #$07
    sta $13                     ; set base address to CPU_GRAPHICS_BUFFER ($0700)
    stx $12                     ; store graphics buffer write offset
                                ; use ($12),y in @write_to_graphics_buffer instead of CPU_GRAPHICS_BUFFER,x
                                ; because x will be used for something else
    ldx $14                     ; load pattern_tile_fence_tbl offset
    ldy #$00                    ; y = #$00

@write_to_graphics_buffer:
    lda ($10),y                   ; load pattern_tile_bg_00 byte
                                  ; this is the 'background' portion of the pattern tile with no electricity
    ora pattern_tile_fence_tbl,x  ; merge with the electricity part of the drawing
    sta ($12),y                   ; set graphics buffer byte
    inx                           ; increment pattern_tile_fence_tbl offset
    txa
    and #$07                      ; keep bits .... .xxx
    ora $14
    tax
    iny                           ; increment graphics buffer write offset used in this loop ($12),y
    cpy #$40                      ; see if written all #$40 pattern tile bytes (#$04 pattern tiles) to the graphics buffer
    bcc @write_to_graphics_buffer ; branch if more tiles to write
    tya
    clc                           ; clear carry in preparation for addition
    adc $12
    sta GRAPHICS_BUFFER_OFFSET

@exit:
    rts

; pointer for the table directly below
; !(OBS) no need for a single entry table
pattern_tile_bg_tbl:
    .addr pattern_tile_bg_00

; table for pattern tile backgrounds that will then have the electric fence drawn on top of (#$40 bytes)
; each #$f bytes is a single pattern table tile
pattern_tile_bg_00:
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00 ; solid square color 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; solid square color 2
    .byte $fe,$fc,$f8,$f0,$e0,$c0,$80,$00,$00,$01,$03,$07,$0f,$1f,$3f,$7f ; rising diagonal background (left side of fence)
    .byte $7f,$3f,$1f,$0f,$07,$03,$01,$00,$00,$80,$c0,$e0,$f0,$f8,$fc,$fe ; falling diagonal background (right side of fence)

; table for electric fence line that is drawn on top of the backgrounds
; in pattern_tile_bg_00 to create the pattern table tiles for the electric fence (#$28 bytes)
; first #$04 entries are squiggly electric fence, last is blank (no fence)
pattern_tile_fence_tbl:
    .byte $00,$00,$04,$44,$eb,$32,$20,$00
    .byte $00,$00,$10,$30,$eb,$6a,$44,$00
    .byte $00,$00,$08,$0c,$d7,$56,$22,$00
    .byte $00,$00,$20,$22,$d7,$4c,$04,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; no electric fence, just draw the ground/background part of the tile

run_level_routine_for_demo:
    lda LEVEL_ROUTINE_INDEX     ; load the offset into the instruction pointer table
    cmp #$04
    bne run_level_routine       ; 4th subroutine is different, if not #$04, immediately go to run_level_routine
    jsr simulate_input_for_demo ; if 4th subroutine (5th counting from 0), load bank 5 and run input simulation code

; game routines - pointer 5
; inside a level or in the demo. this routine runs the appropriate level_routine
game_routine_05:
    lda LEVEL_ROUTINE_INDEX ; intro finished loading, start showing demo or actual game

; runs the code specified at offset A in the level_routine_ptr_tbl
; run for all levels, but not for intro.  Intro loads from game_routine_pointer_table
run_level_routine:
    jsr run_routine_from_tbl_below ; run routine a in the following table (level_routine_ptr_tbl)

; pointer table for main game (#$0b * #$02 = #$16 bytes)
; CPU address $ce35
level_routine_ptr_tbl:
    .addr level_routine_00 ; CPU address $ce4b - init APU, zero nametables, load default palette, and load level headers
    .addr level_routine_01 ; CPU address $ce7e - display number of lives text for player(s) - REST xx
    .addr level_routine_02 ; CPU address $ce9b - flashes score until timer expires, loads the pattern data, sets the sprite palettes, starts level music
    .addr level_routine_03 ; CPU address $ced8 - animate nametable drawing, set sprite load type
    .addr level_routine_04 ; CPU address $cee3 - routine run repeatedly while playing level
    .addr level_routine_05 ; CPU address $cf2e - initialize level after finishing level, or game over
    .addr level_routine_06 ; CPU address $cf9d - no more lives screen - shows score and "continue"/"end" option
    .addr level_routine_07 ; CPU address $cfe1 - show game over screen until player presses start
    .addr level_routine_08 ; CPU address $cfea - check for game over, otherwise wait for delay and play end of level tune
    .addr level_routine_09 ; CPU address $d01f - run end of level sequence routines
    .addr level_routine_0a ; CPU address $d02e - show game over score until GAME_OVER_DELAY_TIMER elapses, then move to level_routine_05

; main game - pointer 0
; init APU, zero nametables, load default palette, and load level headers
level_routine_00:
    jsr init_APU_channels
    jsr zero_out_nametables                   ; reset both nametables to zeroes
    lda #$06                                  ; load transition_screen_palettes (#$06th entry in short_text_pointer_table table bank 6)
    jsr load_bank_6_write_text_palette_to_mem ; load palette for level name and hi score screen into PPU
    ldy #$02
    jsr load_bank_number                      ; switch to bank 2
    lda CURRENT_LEVEL                         ; load current level
    asl                                       ; each level header is #$20 bytes so multiply by #20
    asl
    asl
    asl
    asl
    tay                                       ; y is CPU memory read offset
    ldx #$00                                  ; x is CPU memory write offset
    stx BOSS_DEFEATED_FLAG                    ; set flag to false
    stx LEVEL_END_PLAYERS_ALIVE               ; clear players alive after defeating boss heart flag

; ROM address $ce6a
; stores the $20 byte level header data in CPU memory in addresses $40 to $60
; the level header is a $20 byte data structure containing information about the
; level. All 8 levels have their headers stored consecutively starting at
; $b319 in bank 2
;
; For example, Level 1 contains the following information
; - $40 Location Type: Indoor ($00)
; - $41 Scrolling Type: Horizontal ($00)
; - $42 Level Screen Super-Tile Data Location : $8001 (Bank 2)
; - $44 Level Super-Tile Data Location: $8001 (Bank 3)
; - $46 Palette Data Location: $8671 (Bank 3)
; - $48 Alternate Graphics Loading Section: $0b (how far into level before loading alternate graphic data)
; - $49 Tile Collision Limits: $06 $f9 $ff
; - $4c Cycling Background Tile Palette Codes: $05 $08 $05 $08
; - $50 Background Tile Palette Codes: $02 $03 $04 $05
; - $54 Sprite Palette Codes: $00 $01 $22 $07
; - $58 Stop Scrolling Section: $0b
; - $59 Mystery Byte: $00
; - $5a-$5f Unused Bytes: $00 $00 $00 $00 $00 $00
load_level_header:
    lda level_headers,y                       ; load level header offset y from bank 2
    sta LEVEL_LOCATION_TYPE,x                 ; store into cpu addresses $40-$60
    iny                                       ; increment CPU memory read offset
    inx                                       ; increment CPU memory write offset
    cpx #$20                                  ; level header is #$20 bytes, check if all bytes been read
    bne load_level_header                     ; read next byte if not complete
    jsr init_ppu_write_screen_supertiles      ; initialize PPU write addresses (nametable, attribute table), scroll,
                                              ; and load super-tile indexes for current screen into LEVEL_SCREEN_SUPERTILES
    jsr load_bank_0_load_level_enemies_to_mem ; load enemy routines bank (bank 0), and load level-specific enemies into $80

inc_level_routine_index:
    inc LEVEL_ROUTINE_INDEX ; increment current level routine index
    rts

; display number of lives text for player(s) - REST xx
; executed once so it doesn't flash like the score
level_routine_01:
    lda DEMO_MODE                 ; #$00 not in demo mode, #$01 demo mode on
    bne skip_level_routine_01     ; jump when in demo mode
    jsr draw_stage_and_level_name ; draw "STAGE" string
    lda #$00                      ; a = #$00
    sta $1e                       ; set PLAYER_MODE for use in draw_player_num_lives
    jsr draw_player_num_lives     ; draw player 1 number of lives (REST XX)
    lda PLAYER_MODE               ; number of players (0 = 1 player)
    beq @continue                 ; branch if only one player number of lives to draw
    sta $1e                       ; set player index to #$01, to draw number of lives for player 2
    jsr draw_player_num_lives     ; draw player 2 number of lives (REST XX)

@continue:
    lda #$c0 ; set delay for score display screen for non-demo mode

skip_level_routine_01:
    sta DELAY_TIME_LOW_BYTE     ; setup score display delays (only low byte used)
    bne inc_level_routine_index ; set $2a to 02 to skip score display screen

; flashes score until timer expires
; loads the pattern data for the level
; sets the sprite palettes
; starts level music
level_routine_02:
    jsr decrement_delay_timer          ; decrement timer (sets/clears zero flag)
    bne draw_the_scores_1              ; jump if the timer has elapsed, i.e. finished flashing score, move on to load level
    jsr zero_out_nametables            ; the timer has elapsed, reset nametables (blank screen)
    jsr load_level_graphics            ; load level graphics
    lda #$20                           ; a = #$20
    jsr load_palettes_color_to_cpu     ; load #$20 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    lda CURRENT_LEVEL                  ; current level
    asl
    tay
    lda level_vert_scroll_and_song,y
    sta VERTICAL_SCROLL                ; set initial vertical scroll
    lda DEMO_MODE                      ; #$00 not in demo mode, #$01 demo mode on
    bne @continue                      ; don't play level music/song when in demo mode
    lda level_vert_scroll_and_song+1,y
    jsr play_sound                     ; play level background music

@continue:
    lda #$ff                 ; a = #$ff
    sta GRAPHICS_BUFFER_MODE ; non-zero graphics mode
    inc LEVEL_ROUTINE_INDEX  ; increment level routine

level_routine_03_exit:
    rts

draw_the_scores_1:
    jmp draw_the_scores

; table for vertical adjustment and music theme ($08 * $02 = $10 bytes)
; first byte is the vertical adjustment
; second byte is the music theme code
level_vert_scroll_and_song:
    .byte $e0,$2a ; level 1 - show bottom nametables (#$2800 and #$2c00) - sound_2a
    .byte $e8,$3e ; level 2 - show bottom nametables (offset top #$8 pixels) (#$2800 and #$2c00) - sound_3e
    .byte $00,$2e ; level 3 - vertical scroll is variable throughout level - sound_2e
    .byte $e8,$3e ; level 4 - show bottom nametables (offset top #$8 pixels) (#$2800 and #$2c00) - sound_3e
    .byte $e0,$32 ; level 5 - show bottom nametables (#$2800 and #$2c00) - sound_32
    .byte $e0,$36 ; level 6 - show bottom nametables (#$2800 and #$2c00) - sound_36
    .byte $e0,$2a ; level 7 - show bottom nametables (#$2800 and #$2c00) - sound_2a
    .byte $e0,$3a ; level 8 - show bottom nametables (#$2800 and #$2c00) - sound_3a

; animate nametable drawing, set sprite load type
level_routine_03:
    jsr load_bank_3_init_lvl_nametable_animation ; load bank three and execute initial level nametable drawing animation
    bne level_routine_03_exit                    ; exit if LEVEL_TRANSITION_TIMER has elapsed
    lda #$ff                                     ; a = #$ff
    sta SPRITE_LOAD_TYPE                         ; set to load hud sprites
    bne inc_level_routine_index                  ; increase level routine to level_routine_04

; CPU address $cee3
; routine run repeatedly while playing level
level_routine_04:
    jsr check_for_pause         ; see if player is pausing or un-pausing
    lda PAUSE_STATE             ; #$00 for un-paused #$01 for paused
    bne level_routine_04_exit   ; exit level routine if the game is paused
    lda BOSS_DEFEATED_FLAG      ; 0 = boss not defeated, 1 = boss defeated
    bne set_to_level_routine_08 ; if boss defeated, skip to level_routine_08 to begin level over sequence

; level_routine_04 and level_routine_08 use this label
; checks to see if player(s) have game overed, if so, sets next level routine to
; be #$0a to begin game over sequence
; if not, then executes the various enemy logic
check_game_over_run_enemy_logic:
    jsr set_frame_scroll_draw_player_bullets ; draw sprites, handle input
    lda P1_GAME_OVER_STATUS                  ; player 1 game over state (1 = game over)
    and P2_GAME_OVER_STATUS                  ; player 2 game over state (1 = game over)
    bne init_game_over                       ; if both players have game over, show ending sequence

; run various enemy logic that exists in bank 0 and bank 7
; random enemies, all currently shown enemy logic, palette updates, etc.
; generate random soldiers if appropriate
; run in level_routine_04 and level_routine_0a
run_level_enemy_logic:
    jsr load_bank_3_handle_scroll          ; handles scrolling for the level if currently scrolling
                                           ; handles updating nametable, attribute table, and loading alternate graphics as appropriate
    jsr load_bank_0_exe_all_enemy_routine  ; execute all enemy routine logic
    jsr load_bank_2_load_screen_enemy_data
    jsr load_bank_2_exe_soldier_generation ; run soldier generation routine
    jsr load_palette_indexes
    jsr load_bank_2_alternate_tile_loading ; load alternate tiles if necessary

; also executed from level_routine_08
level_routine_04_exit:
    rts

; initializes the game over timer (delay before showing score)
; goes to level routine #$0a
init_game_over:
    lda #$60                           ; set timer to delay showing scores
    sta GAME_OVER_DELAY_TIMER          ; initialize timer to #$60
    lda #$0a
    bne set_a_as_current_level_routine ; set next level routine to #$0a to wait for delay

set_to_level_routine_05:
    lda #$00                           ; a = #$00
    sta BOSS_DEFEATED_FLAG             ; reset flag to false now that GAME_OVER_DELAY_TIMER has elapsed
    lda #$05                           ; a = #05 (level_routine_05)
    jsr set_a_as_current_level_routine ; change level routine to show high score

set_graphics_zero_mode:
    lda #$00                 ; a = #$00
    sta GRAPHICS_BUFFER_MODE ;
    sta CPU_GRAPHICS_BUFFER
    jmp init_APU_channels

set_to_level_routine_08:
    lda #$08 ; a = #$08

set_a_as_current_level_routine:
    sta LEVEL_ROUTINE_INDEX     ; set the next level routine to run
    lda #$00                    ; a = #$00
    sta END_LEVEL_ROUTINE_INDEX ; clear end of level routine index
    rts

; initialize level after finishing level, or game over
level_routine_05:
    lda #$00                        ; a = #$00
    sta SPRITE_LOAD_TYPE            ; set to load normal sprites
    sta INDOOR_SCREEN_CLEARED       ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
    lda P1_CURRENT_WEAPON
    sta $10                         ; temporarily store current weapon in $10
    lda P2_CURRENT_WEAPON           ; current weapon code (player 2)
    sta $11                         ; temporarily store current weapon in $11
    ldx #$40                        ; x = #$40 (set to 30 for game over after lvl 1)
    jsr clear_memory_starting_at_x  ; clear level header data, player data, sprite buffer, and super-tile buffer (memory [$40-$f0) and [$300-$700])
    lda BOSS_DEFEATED_FLAG          ; 0 = boss not defeated, 1 = boss defeated
    beq show_game_over_screen       ; in level_routine_05 and boss wasn't defeated, game over
                                    ; unless demo mode (shouldn't happen because demos don't reach end of level), then just set DEMO_LEVEL_END_FLAG and exit
    lda $10                         ; restore current weapon from $10 for player 1
    sta P1_CURRENT_WEAPON
    lda $11                         ; restore current weapon from $11 for player 2
    sta P2_CURRENT_WEAPON           ; current weapon code (player 2)
    inc CURRENT_LEVEL               ; increment current level
    lda CURRENT_LEVEL               ; current level
    cmp #$08                        ; if greater than last level, start game ending sequence
    bcc load_level_intro            ; jump if level is less than the last level
    jsr inc_routine_index_set_timer ; completed last level, start ending sequence
    inc GAME_COMPLETION_COUNT       ; increment game completion count, used mainly to increase enemy difficulty every play-through
    lda #$09
    sta CURRENT_LEVEL               ; set current level to #$09, this is interpreted as the ending sequence
    bne level_routine_05_exit       ; always jump since lda #$09 will set the Z flag #$00

; loads the pattern table tiles to the level intro screen
; shows player scores, number of lives, high score, stage number, and level name
load_level_intro:
    lda #$0a                       ; set offset to point to intro_graphic_data_00 -> graphic_data_01 -> (pattern table for screen)
    jsr load_A_offset_graphic_data ; load graphic data 0a

level_routine_05_exit:
    lda #$00
    sta LEVEL_ROUTINE_INDEX     ; go back to level_routine_00
    sta END_LEVEL_ROUTINE_INDEX ; clear end level routine
    sta SPRITE_LOAD_TYPE        ; set to load normal sprites
    rts

; game over, unless demo mode, then set DEMO_LEVEL_END_FLAG
show_game_over_screen:
    lda DEMO_MODE                             ; #$00 not in demo mode, #$01 demo mode on
    bne @set_demo_end_exit                    ; skip to end when in demo mode
    jsr zero_out_nametables                   ; reset nametables 0-1 to zeroes
    lda #$0a                                  ; set offset to point to intro_graphic_data_00 -> graphic_data_01 -> (pattern table for screen)
    jsr load_A_offset_graphic_data            ; load graphic_data_01
    lda #$06                                  ; a = #$06 transition_screen_palettes (palettes for intro screen)
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda #$0d                                  ; a = #$0d text_game_over (game over)
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    lda #$4e                                  ; a = #$4e (sound_4e)
    jsr play_sound                            ; play game over sound
    dec NUM_CONTINUES                         ; subtract from number of lives remaining
    bmi @no_continues_remaining               ; if run out of continues, jump
    lda #$0e                                  ; a = #$0e (continue  end)
    jsr load_bank_6_write_text_palette_to_mem ; draw text string
    jmp inc_level_routine_index

@no_continues_remaining:
    lda #$07                           ; a = #$07
    jmp set_a_as_current_level_routine

; in demo mode and
@set_demo_end_exit:
    inc DEMO_LEVEL_END_FLAG ; set value indicating demo for level is complete
    rts

; no more lives screen - shows score and "continue"/"end" option
; resets player score and goes back to level_routine_00 if player selects continue
; resets game routine back to #$00 if player selects end
level_routine_06:
    lda CONTROLLER_STATE_DIFF ; controller 1 buttons pressed
    and #$10                  ; keep bits ...x .... (start button)
    beq @check_select_button  ; if start button isn't pressed, jump
    jsr init_APU_channels
    lda CONT_END_SELECTION    ; determine cursor position between "CONTINUE" and "END"
    bne reset_game_routine    ; exit game if end was selected
    jsr reset_players_score   ; continue was selected, reset the player scores back to #$00
    lda #$00
    sta LEVEL_ROUTINE_INDEX   ; set to level_routine_00
    sta SPRITE_X_POS
    sta SPRITE_Y_POS
    sta CPU_SPRITE_BUFFER
    rts

@check_select_button:
    lda CONTROLLER_STATE_DIFF         ; controller 1 buttons pressed
    and #$20                          ; select button
    beq @set_cursor_sprite_and_scores ; jump if select isn't pressed
    lda CONT_END_SELECTION            ; load which option is current selected
    eor #$01                          ; swap selection between "CONTINUE"/"END", i.e. flip bits .... ...x
    sta CONT_END_SELECTION            ; save swapped setting

@set_cursor_sprite_and_scores:
    lda #$52                       ; hard-code the horizontal position of the cursor sprite
    sta SPRITE_X_POS
    lda #$aa                       ; sprite_aa: player selector cursor (yellow falcon)
    sta CPU_SPRITE_BUFFER          ; set cursor as first (and only) sprite to draw
    ldx CONT_END_SELECTION         ; load whether "CONTINUE" or "END" is selected
    lda player_select_cursor_pos,x ; load the vertical position on the screen for the cursor
    sta SPRITE_Y_POS               ; set Y position in CPU memory
    jmp draw_the_scores            ; draw the scores

; resets GAME_ROUTINE_INDEX to #$00 and resets delay timer
reset_game_routine:
    lda #$00
    jmp set_game_routine_index_to_a ; set GAME_ROUTINE_INDEX to #$00 and reset delay timer to #$0240

; show game over screen until player presses start
; once player presses start, game is reset
level_routine_07:
    lda CONTROLLER_STATE_DIFF ; controller 1 buttons pressed
    and #$10                  ; check for start button
    bne reset_game_routine    ; reset the game if start button was pressed
    jmp draw_the_scores       ; start button not pressed, continue to show score

; check for game over, otherwise wait for delay and play end of level tune
level_routine_08:
    jsr check_game_over_run_enemy_logic ; check to see if player(s) have game overed
                                        ; if so, sets next level routine to be #$0a to begin game over sequence
                                        ; otherwise, execute various enemy logic
    lda LEVEL_ROUTINE_INDEX
    cmp #$0a                            ; check_game_over_run_enemy_logic sets LEVEL_ROUTINE_INDEX to #$0a
                                        ; when both players are in game over state
    beq level_routine_exit              ; if game over, simply exit, next routine will be level_routine_0a
    ldy DELAY_TIME_LOW_BYTE             ; not game over, load delay
    beq @continue                       ; branch to continue if delay has elapsed
    iny                                 ; delay timer has not elapsed, increment
    beq level_routine_exit              ; exit if delay was #$ff
    jsr decrement_delay_timer           ; delay wasn't #$ff, decrement full #$02 byte delay
    bne level_routine_exit              ; exit if timer hasn't elapsed

@continue:
    ldx #$01 ; x = #$01
    ldy #$00 ; initialize number of alive players to #$00

@player_loop:
    lda P1_GAME_OVER_STATUS,x      ; load game over state for player x (1 = game over)
    bne @next_player_adv_lvl_index ; branch if game over
    lda PLAYER_STATE,x             ; game not over, load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    cmp #$01                       ; compare to normal state
    bne @next_player_adv_lvl_index ; branch if player not in normal state
    iny

@next_player_adv_lvl_index:
    dex                         ; decrement player index (0 = p1, 1 = p2)
    bpl @player_loop            ; branch if still need to evaluate player 1
    tya                         ; transfer number of alive players to a
    sta LEVEL_END_PLAYERS_ALIVE ; set total number of alive players at level end
    beq level_routine_exit
    lda #$46                    ; a = #$46 (sound_46)
    jsr play_sound              ; play end of level sound
    inc LEVEL_ROUTINE_INDEX     ; move to next level routine

level_routine_exit:
    rts

; run end of level sequence routines
level_routine_09:
    jsr load_bank_3_run_end_lvl_sequence_routine
    jsr set_frame_scroll_draw_player_bullets
    jsr load_bank_3_handle_scroll                ; handles scrolling for the level if currently scrolling
                                                 ; handles updating nametable, attribute table, and loading alternate graphics as appropriate
    jsr load_bank_0_exe_all_enemy_routine
    jmp load_palette_indexes

; waits for GAME_OVER_DELAY_TIMER to elapse and then move to level_routine_05
; to show game over score
level_routine_0a:
    jsr run_level_enemy_logic
    dec GAME_OVER_DELAY_TIMER   ; decrement timer (initialized to #$60)
    bne level_routine_exit      ; wait for GAME_OVER_DELAY_TIMER to elapse
    jmp set_to_level_routine_05 ; go to level_routine_05 to show game over high score

; checks for start button and sets pause status as appropriate
; plays sound if entering pause
check_for_pause:
    lda DEMO_MODE             ; #$00 not in demo mode, #$01 demo mode on
    ora $26
    ora PPU_READY             ; #$00 when PPU is ready, > #$00 otherwise
    bne pause_exit_00         ; if in demo, PPU isn't ready, or $26 > 0, then exit
    lda CONTROLLER_STATE_DIFF ; controller 1 buttons pressed
    ldy PAUSE_STATE           ; #$01 for paused, #$00 for not paused
    bne @game_paused          ; if game paused, jump
    and #$10                  ; keep bits ...x .... (check for start button)
    beq pause_exit_00         ; exit if start button isn't pressed
    lda #$01                  ; a = #$01
    sta PAUSE_STATE           ; #$01 for paused, #$00 for not paused
    lda #$54                  ; a = #$54 (54 = game pausing jingle sound)
    jmp play_sound            ; play game pausing jingle sound

; handle game paused state
; un-pauses if necessary
@game_paused:
    jsr draw_player_bullet_sprites                 ; draw half of the bullets in alternating frames
    jsr load_bank_2_set_players_paused_sprite_attr ; continue animating player sprite attributes while paused (electrocuted, invincible, etc.)
.ifdef Probotector
    jsr pause_exit                                 ; !(HUH) probably cut out code from the Japanese version
.endif
    lda CONTROLLER_STATE_DIFF                      ; controller 1 buttons pressed
    and #$10                                       ; keep bits ...x .... (check for start button)
    beq pause_exit_00                              ; exit if start button isn't pressed
    lda #$00                                       ; a = #$00
    sta PAUSE_STATE                                ; set game state to not paused

pause_exit_00:
.ifdef Probotector
    rts
.endif

pause_exit:
    rts

; load the alternate graphics
; CPU address $d064
load_alternate_graphics:
    lda #$ff                   ; a = #$ff
    sta LEVEL_ALT_GRAPHICS_POS ; prevent any further attempt to load alternate graphics
    lda CURRENT_LEVEL          ; prepare to determine index into lvl_alt_collision_and_palette_tbl, each level has #$f bytes
    asl
    asl
    asl
    asl
    sec                        ; set the carry flag in preparation for subtraction
    sbc CURRENT_LEVEL          ; multiply by 16 and subtract level to get 15 * level number, i.e. 16n - n == 15n
    tay
    ldx #$00                   ; set cpu mem write offset to #$00

; loop to overwrite level palette and collision info [$49-$57]
@loop:
    lda lvl_alt_collision_and_palette_tbl,y
    sta COLLISION_CODE_1_TILE_INDEX,x
    iny                                     ; increment read offset
    inx                                     ; increment write offset
    cpx #$0f                                ; see if all #$f bytes have been written to cpu buffer
    bne @loop                               ; if not yet finished, loop
    lda #$20                                ; set to reload #$20 palettes

; loads palette colors into PALETTE_CPU_BUFFER based on cpu memory LEVEL_PALETTE_INDEX
; a - the number of palette colors to load (including hard-coded black per palette)
;     #$10 (4 palettes) or #$20 (8 palettes) depending on loading nametable colors, or both nametable and sprite colors
load_palettes_color_to_cpu:
    sta $02                  ; store number of palette colors to load to CPU memory
    sta NUM_PALETTES_TO_LOAD ; set number of palette colors to load
    lda FRAME_COUNTER        ; load frame counter
    and #$30                 ; keep bits ..xx ....
    sta $03                  ; store the masked frame number in $03 (I don't believe this is used) !(WHY?)
    ldx #$00                 ; initialize colors written counter
    stx $00                  ; set LEVEL_PALETTE_INDEX read offset to #$00

; read $02 palette colors starting level palette index $00
; store actual palette colors from table game_palettes into cpu memory
; starting at PALETTE_CPU_BUFFER
; input
;  * x - number of colors already written
;  * $00 - current palette index to load (indexes into LEVEL_PALETTE_INDEX)
;  * $02 - total number of palette colors to load
; game_palette_ptr_tbl only has one entry, not sure why it was used in the first place !(HUH)
; it complicates loading the index from the game_palettes table
load_palette_colors_to_cpu:
    lda #$00                   ; a = #$00
    sta $07                    ; reset $07 to #$00
    ldy $00                    ; load LEVEL_PALETTE_INDEX read offset [#$00-#$08)
    lda LEVEL_PALETTE_INDEX,y  ; load background palette index into game_palette_ptr_tbl
    asl
    adc LEVEL_PALETTE_INDEX,y  ; double and add one (multiply by 3) - palettes are 3 (1-byte) colors
                               ; at this point, the relative offset is known, but now the address must be computed
    rol $07                    ; if there was a carry (relative offset >= #$80), push into high byte
    adc game_palette_ptr_tbl   ; add relative offset to low byte of game_palettes address (#$27)
    sta $06                    ; store low byte of offset into game_palettes into $06
    lda $07                    ; reload high byte (could be #$01 if relative palette was >= #$80)
    adc game_palette_ptr_tbl+1 ; add high byte of game_palettes pointer address to high byte of game_palettes address
    sta $07                    ; store offset into game_palettes into $07, know the exact address is stored in $(06)
    ldy #$00                   ; y = #$00
    lda #$0f                   ; a = #$0f (basic black for all palettes)
    sta PALETTE_CPU_BUFFER,x   ; store the universal background color in cpu buffer
                               ; every palette has black as its first color
    inx                        ; increment cpu buffer write offset

read_palette_loop:
    lda BG_PALETTE_ADJ_TIMER   ; see if a palette color shift timer was used
    bne shift_bg_palette_color ; adjust palette color if BG_PALETTE_ADJ_TIMER is non-zero

; reads the palette color from the game_palettes table
read_palette_color:
    lda ($06),y ; read the palette color

; store the palette color in A register to CPU memory
write_palette_color_a_to_cpu_mem:
    sta PALETTE_CPU_BUFFER,x       ; store palette color into CPU memory
    iny                            ; increment read offset
    inx                            ; increment cpu memory buffer write offset
    cpy #$03                       ; see if read all #$03 colors of the palette
    bne read_palette_loop          ; branch if haven't yet loaded entire palette (palettes are 3 colors)
    inc $00                        ; finished reading palette, increment level palette index read offset
    cpx $02                        ; see if written all the colors to the cpu buffer
    bne load_palette_colors_to_cpu ; if more palette colors to load, loop back and load them
    lda BG_PALETTE_ADJ_TIMER       ; load palette color shift timer
    beq @exit                      ; exit if #$00
    bmi @exit                      ; exit if < #$00
    dec BG_PALETTE_ADJ_TIMER       ; decrement palette color shift timer

@exit:
    rts

; adjust nametable palette color based on BG_PALETTE_ADJ_TIMER to create fading effect
; while timer is out of range [#$01-#$09] only black is drawn, but once in range colors will be adjusted
;  * for non-indoor boss screens, the first palette is not modified
;  * only nametable palettes are modified and not sprite palettes
;  * used on indoor levels between sections, dragon and boss ufo fade-in effect, and on boss mouth
; input
;  * y - LEVEL_PALETTE_INDEX read offset
;  * x - number of palette colors written (including hard-coded black)
shift_bg_palette_color:
    sty $03                 ; backup the read offset into y
    ldy LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    bmi @continue           ; branch if indoor (base) level boss screen shown (LEVEL_LOCATION_TYPE set to #$80)
    ldy $03                 ; for non-indoor boss screens, the first palette is not modified, restore the read offset from $03 to check
    cpx #$04                ; compare palette color offset to #$04
    bcc read_palette_color  ; branch if still reading the first palette, as that palette isn't modified for non-indoor boss screens

@continue:
    ldy $03                              ; load palette color read offset
    cpx #$10                             ; see if all of the nametable sprites have been written
    bcs read_palette_color               ; branch if loading a sprite palette, those aren't modified
    lda BG_PALETTE_ADJ_TIMER             ; load nametable palette modification timer for palette change
    bmi @write_black_to_cpu_mem          ; just write black if BG_PALETTE_ADJ_TIMER is negative
    cmp #$09                             ; see if BG_PALETTE_ADJ_TIMER is in valid range to start modifying palette color
    bcs @write_black_to_cpu_mem          ; just write black if BG_PALETTE_ADJ_TIMER isn't yet in range
    tay                                  ; transfer BG_PALETTE_ADJ_TIMER to offset register
    lda palette_shift_amount_tbl-1,y     ; load the amount to shift the palette color by (1-indexed)
    sta $04                              ; store palette color shift amount in $04
    ldy $03                              ; load the palette color read offset
    lda ($06),y                          ; read palette color
    sec                                  ; set carry flag in preparation for subtraction
    sbc $04                              ; subtract the amount specified in palette_shift_amount_tbl from palette color
    bcs write_palette_color_a_to_cpu_mem ; write modified palette color if result wasn't negative
                                         ; otherwise continue to just write black

@write_black_to_cpu_mem:
    lda #$0f                             ; a = #$0f
    bne write_palette_color_a_to_cpu_mem ; always jump

; amount to subtract from palette color when BG_PALETTE_ADJ_TIMER is between #$01 and #$09 (1-indexed)
palette_shift_amount_tbl:
    .byte $00,$00,$10,$10,$20,$20,$30,$30

; load the appropriate palette colors based on level and LEVEL_PALETTE_CYCLE
; stores appropriate game_palettes indexes into LEVEL_PALETTE_INDEX+2 and LEVEL_PALETTE_INDEX+3
load_palette_indexes:
    lda NUM_PALETTES_TO_LOAD          ; load the number of palette indexes to update
    cmp GAME_ROUTINE_INDEX            ; current game routine index
    bcs palette_mod_exit              ; exit if NUM_PALETTES_TO_LOAD >= GAME_ROUTINE_INDEX
    lda FRAME_COUNTER                 ; load frame counter
    and #$07                          ; keep bits .... .xxx
    cmp #$05                          ; see if the last 3 bits are #$05 (every #$8 frames)
    bne falcon_weapon_flash           ; branch if not equal to #$07 (do not increment LEVEL_PALETTE_CYCLE)
    lda PAUSE_PALETTE_CYCLE           ; see if palette cycling has been paused (ice field tanks pause palette cycling)
    bne falcon_weapon_flash
    inc LEVEL_PALETTE_CYCLE           ; move to next set of palette colors for the 4th background palette
    lda LEVEL_PALETTE_CYCLE
    ldy CURRENT_LEVEL                 ; current level
    cmp lvl_palette_animation_count,y ; see how many palette cycles there are for the level (level 3 only has 3, every other level has 4)
    bcc @continue                     ; branch if current cycle less than max (LEVEL_PALETTE_CYCLE < lvl_palette_animation_count,y)
    lda #$00                          ; a = #$00
    sta LEVEL_PALETTE_CYCLE           ; exceeded number of palettes in level animation, set back to #$00 for next loop

@continue:
    tay
    lda LEVEL_PALETTE_CYCLE_INDEXES,y       ; load current palette colors for cycling background tiles
    sta LEVEL_PALETTE_INDEX+3               ; store index into palette code 3 for background tiles
    lda LEVEL_LOCATION_TYPE                 ; see if have gotten to the indoor (base) level boss screen
    bmi set_indoor_boss_palette_2_animation ; player has gotten to indoor boss and value has been set to #$80, jump
    lda CURRENT_LEVEL                       ; current level
    beq load_palettes_color_to_cpu_2_index  ; skip ahead to load level 1 palette indexes for enemy flashing red
    cmp #$07                                ; check if level 8
    beq load_10_sprite_palettes
    cmp #$08                                ; check if ending
    beq set_ending_palette_animation
    lda LEVEL_ALT_GRAPHICS_POS              ; see status of loading alternate graphics
    bmi load_10_sprite_palettes             ; branch if alternate graphics are still being loaded (not yet done)

; update the 3rd nametable palette colors (flashing red lights effect)
load_palettes_color_to_cpu_2_index:
    lda level_palette_2_index,y

set_a_to_palette_2:
    sta LEVEL_PALETTE_INDEX+2

load_10_sprite_palettes:
    lda #$10                       ; a = #$10
    jsr load_palettes_color_to_cpu ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX

falcon_weapon_flash:
    lda FALCON_FLASH_TIMER        ; falcon weapon flash timer
    beq palette_mod_exit          ; exit if timer has elapsed
    dec FALCON_FLASH_TIMER        ; falcon weapon flash timer
    lda FALCON_FLASH_TIMER
    lsr
    bcs palette_mod_exit
    and #$03                      ; keep bits .... ..xx
    tay
    lda falcon_weapon_flash_tbl,y
    sta PALETTE_CPU_BUFFER+16
    sta PALETTE_CPU_BUFFER+20
    sta PALETTE_CPU_BUFFER+24
    sta PALETTE_CPU_BUFFER+28
    lda #$20                      ; offset #$20 into palette buffer
    sta NUM_PALETTES_TO_LOAD      ; number of palettes to write to cpu buffer

palette_mod_exit:
    rts

; updates the 3rd palette code based on LEVEL_PALETTE_CYCLE for indoor (base) level boss screen
set_indoor_boss_palette_2_animation:
    lda CURRENT_LEVEL                 ; current level (going to be either #$01 or #$03)
    and #$02                          ; differentiate which indoor level (#$00 for first base and #$02 for second base level)
    asl                               ; double since each level has #$4 entries allowing second base to start at #$04
    adc LEVEL_PALETTE_CYCLE           ; add to current palette cycle iteration
    tay
    lda indoor_boss_palette_2_index,y ;
    sta LEVEL_PALETTE_INDEX+2         ; palette code 2 for background tiles
    jmp load_10_sprite_palettes

set_ending_palette_animation:
    lda ending_palette_2_index,y
    bne set_a_to_palette_2

; number of palettes to cycle through per level (LEVEL_PALETTE_CYCLE)
; CPU address $d181
lvl_palette_animation_count:
    .byte $04,$04,$03,$04,$04,$04,$04,$04,$04

; the palette indexes for the indoor boss screens
indoor_boss_palette_2_index:
    .byte $13,$14,$15,$14 ; first indoor (base) palette code 2 animation cycle
    .byte $1b,$1c,$1d,$1c ; second indoor (base) palette code 2 animation cycle

; flashing effect color codes for falcon weapon ($04 bytes)
falcon_weapon_flash_tbl:
    .byte $0f,$30,$16,$11

; palette code 2 palette indexes into game_palettes shared among all levels
; animation for flashing red colors on enemies
level_palette_2_index:
    .byte $04,$5c,$04,$5d

ending_palette_2_index:
    .byte $66,$6a,$6b,$6a ; table for ending scene ($04 bytes)

; tables for alternate collision limits and palettes ($08 * $0f = $78 bytes)
; corresponds to [$49-$57]
lvl_alt_collision_and_palette_tbl:
    .byte $06,$a8,$a8,$23,$23,$23,$23,$02,$03,$04,$23,$00,$01,$22,$07 ; level 1
    .byte $00,$ff,$ff,$16,$17,$18,$17,$11,$12,$13,$16,$00,$01,$22,$21 ; level 2
    .byte $07,$ff,$ff,$27,$54,$55,$54,$0b,$25,$26,$27,$00,$01,$22,$07 ; level 3
    .byte $00,$ff,$ff,$1e,$1f,$20,$1f,$19,$1a,$1c,$1e,$00,$01,$22,$2b ; level 4
.ifdef Probotector
    .byte $20,$f0,$f0,$42,$42,$42,$42,$3d,$3e,$40,$42,$00,$01,$22,$07 ; level 5
    .byte $0c,$de,$de,$3a,$3b,$3a,$3c,$39,$39,$04,$3a,$00,$01,$22,$07 ; level 6
.else
    .byte $20,$f0,$f0,$42,$42,$42,$42,$3d,$3e,$40,$42,$00,$01,$22,$06 ; level 5
    .byte $0c,$de,$de,$3a,$3b,$3a,$3c,$39,$39,$04,$3a,$00,$01,$22,$56 ; level 6
.endif
    .byte $0e,$f1,$f1,$5a,$5f,$5a,$5b,$45,$46,$59,$5f,$00,$01,$22,$07 ; level 7
    .byte $05,$b6,$b6,$4b,$50,$4b,$50,$48,$49,$4a,$4b,$00,$01,$43,$44 ; level 8
    .byte $00,$00,$00,$67,$68,$69,$68,$25,$65,$66,$67,$6d,$6c,$22,$64 ; ending animation

; pointer for palettes table ($02 bytes)
; CPU address $d225
game_palette_ptr_tbl:
    .addr game_palettes ; CPU address $d227

; palettes ($6e * $03 = $14a bytes)
; CPU Address $d227
game_palettes:
.ifdef Probotector
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_BLACK_0f
    .byte COLOR_PALE_VIOLET_32      ,COLOR_MED_VIOLET_12        ,COLOR_BLACK_0f
.else
    .byte COLOR_PALE_ORANGE_37      ,COLOR_MED_VIOLET_12        ,COLOR_BLACK_0f
    .byte COLOR_PALE_RED_36         ,COLOR_MED_RED_16           ,COLOR_BLACK_0f
.endif
    .byte COLOR_MED_FOREST_GREEN_19 ,COLOR_LT_FOREST_GREEN_29   ,COLOR_DARK_OLIVE_08
    .byte COLOR_LT_OLIVE_28         ,COLOR_MED_OLIVE_18         ,COLOR_DARK_OLIVE_08
    .byte COLOR_MED_RED_16          ,COLOR_WHITE_30             ,COLOR_LT_GRAY_10
    .byte COLOR_MED_BLUE_11         ,COLOR_LT_BLUE_21           ,COLOR_WHITE_30
.ifdef Probotector
    .byte COLOR_PALE_GREEN_3a       ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_BLACK_0f
    .byte COLOR_PALE_RED_36         ,COLOR_MED_RED_16          ,COLOR_BLACK_0f
.else
    .byte COLOR_MED_RED_16          ,COLOR_WHITE_20             ,COLOR_DARK_GRAY_00
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_BLACK_0f
.endif
    .byte COLOR_MED_BLUE_11         ,COLOR_WHITE_30             ,COLOR_LT_BLUE_21
    .byte COLOR_LT_GRAY_10          ,COLOR_DARK_GRAY_00         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_DARK_GRAY_00        ,COLOR_DARK_TEAL_0c         ,COLOR_WHITE_20
    .byte COLOR_DARK_GREEN_0a       ,COLOR_MED_GREEN_1a         ,COLOR_DARK_GRAY_00
    .byte COLOR_LT_OLIVE_28         ,COLOR_MED_OLIVE_18         ,COLOR_DARK_ORANGE_07
    .byte COLOR_MED_TEAL_1c         ,COLOR_LT_TEAL_2c           ,COLOR_DARK_TEAL_0c
    .byte COLOR_DARK_TEAL_0c        ,COLOR_MED_TEAL_1c          ,COLOR_LT_TEAL_2c
    .byte COLOR_LT_TEAL_2c          ,COLOR_DARK_TEAL_0c         ,COLOR_MED_TEAL_1c
    .byte COLOR_LT_GRAY_10          ,COLOR_LT_BLUE_GREEN_2b     ,COLOR_BLACK_0f
    .byte COLOR_DARK_RED_06         ,COLOR_DARK_GRAY_00         ,COLOR_DARK_OLIVE_08
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_DARK_OLIVE_08
    .byte COLOR_DARK_RED_06         ,COLOR_DARK_GRAY_00         ,COLOR_DARK_OLIVE_08
    .byte COLOR_MED_RED_16          ,COLOR_DARK_GRAY_00         ,COLOR_DARK_OLIVE_08
    .byte COLOR_LT_RED_26           ,COLOR_DARK_GRAY_00         ,COLOR_DARK_OLIVE_08
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_DARK_RED_06
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_MED_RED_16
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_LT_RED_26
    .byte COLOR_DARK_TEAL_0c        ,COLOR_MED_OLIVE_18         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_WHITE_20            ,COLOR_MED_OLIVE_18         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_DARK_RED_06         ,COLOR_MED_OLIVE_18         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_MED_RED_16          ,COLOR_MED_OLIVE_18         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_LT_RED_26           ,COLOR_MED_OLIVE_18         ,COLOR_DARK_FOREST_GREEN_09
    .byte COLOR_WHITE_20            ,COLOR_MED_OLIVE_18         ,COLOR_DARK_RED_06
    .byte COLOR_WHITE_20            ,COLOR_MED_OLIVE_18         ,COLOR_MED_RED_16
    .byte COLOR_WHITE_20            ,COLOR_MED_OLIVE_18         ,COLOR_LT_RED_26
.ifdef Probotector
    .byte COLOR_WHITE_20            ,COLOR_LT_VIOLET_22         ,COLOR_DARK_TEAL_0c
.else
    .byte COLOR_WHITE_20            ,COLOR_LT_VIOLET_22         ,COLOR_DARK_VIOLET_02
.endif
    .byte COLOR_WHITE_20            ,COLOR_LT_RED_26            ,COLOR_MED_RED_16
    .byte COLOR_DARK_BLUE_01        ,COLOR_WHITE_30             ,COLOR_LT_GRAY_10
    .byte COLOR_PALE_RED_36         ,COLOR_DARK_RED_06          ,COLOR_DARK_VIOLET_02
    .byte COLOR_WHITE_30            ,COLOR_LT_GRAY_10           ,COLOR_DARK_GRAY_00
    .byte COLOR_LT_OLIVE_28         ,COLOR_MED_OLIVE_18         ,COLOR_DARK_OLIVE_08
    .byte COLOR_DARK_PINK_05        ,COLOR_MED_OLIVE_18         ,COLOR_DARK_OLIVE_08
    .byte COLOR_PALE_RED_36         ,COLOR_DARK_RED_06          ,COLOR_LT_VIOLET_22
    .byte COLOR_PALE_RED_36         ,COLOR_DARK_RED_06          ,COLOR_PALE_VIOLET_32
.ifdef Probotector
    .byte COLOR_PALE_RED_36         ,COLOR_MED_RED_16           ,COLOR_BLACK_0f
    .byte COLOR_WHITE_20            ,COLOR_LT_VIOLET_22         ,COLOR_DARK_TEAL_0c
.else
    .byte COLOR_WHITE_20            ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_BLACK_0f
    .byte COLOR_WHITE_20            ,COLOR_LT_VIOLET_22         ,COLOR_MED_TEAL_1c
.endif
    .byte COLOR_LT_GRAY_10          ,COLOR_DARK_GRAY_00         ,COLOR_DARK_TEAL_0c
    .byte COLOR_DARK_GRAY_00        ,COLOR_DARK_RED_06          ,COLOR_WHITE_20
    .byte COLOR_PALE_OLIVE_38       ,COLOR_DARK_FOREST_GREEN_09 ,COLOR_DARK_RED_06
    .byte COLOR_PALE_OLIVE_38       ,COLOR_DARK_FOREST_GREEN_09 ,COLOR_MED_RED_16
    .byte COLOR_PALE_OLIVE_38       ,COLOR_DARK_FOREST_GREEN_09 ,COLOR_LT_RED_26
    .byte COLOR_BLACK_0f            ,COLOR_WHITE_20             ,COLOR_LT_TEAL_2c
    .byte COLOR_BLACK_0f            ,COLOR_WHITE_20             ,COLOR_LT_RED_26
    .byte COLOR_DARK_GRAY_00        ,COLOR_WHITE_20             ,COLOR_MED_GREEN_1a
    .byte COLOR_DARK_BLUE_01        ,COLOR_WHITE_20             ,COLOR_DARK_GRAY_00
    .byte COLOR_WHITE_20            ,COLOR_LT_ORANGE_27         ,COLOR_MED_ORANGE_17
    .byte COLOR_WHITE_20            ,COLOR_LT_RED_26            ,COLOR_DARK_ORANGE_07
    .byte COLOR_WHITE_20            ,COLOR_LT_ORANGE_27         ,COLOR_MED_RED_16
    .byte COLOR_WHITE_20            ,COLOR_LT_RED_26            ,COLOR_DARK_RED_06
    .byte COLOR_DARK_GRAY_00        ,COLOR_LT_GRAY_10           ,COLOR_MED_PURPLE_13
    .byte COLOR_MED_RED_16          ,COLOR_WHITE_20             ,COLOR_DARK_GRAY_00
    .byte COLOR_DARK_RED_06         ,COLOR_WHITE_20             ,COLOR_DARK_GRAY_00
    .byte COLOR_LT_RED_26           ,COLOR_WHITE_20             ,COLOR_DARK_GRAY_00
    .byte COLOR_WHITE_20            ,COLOR_LT_GRAY_10           ,COLOR_MED_TEAL_1c
    .byte COLOR_WHITE_20            ,COLOR_LT_GRAY_10           ,COLOR_DARK_GREEN_0a
    .byte COLOR_WHITE_20            ,COLOR_DARK_GRAY_00         ,COLOR_MED_ORANGE_17
    .byte COLOR_WHITE_20            ,COLOR_MED_VIOLET_12        ,COLOR_DARK_GRAY_00
    .byte COLOR_DARK_ORANGE_07      ,COLOR_DARK_GRAY_00         ,COLOR_MED_ORANGE_17
    .byte COLOR_WHITE_20            ,COLOR_MED_RED_16           ,COLOR_DARK_GRAY_00
    .byte COLOR_WHITE_30            ,COLOR_LT_OLIVE_28          ,COLOR_MED_RED_16
    .byte COLOR_WHITE_30            ,COLOR_LT_PINK_25           ,COLOR_MED_MAGENTA_14
    .byte COLOR_LT_ORANGE_27        ,COLOR_MED_ORANGE_17        ,COLOR_DARK_RED_06
    .byte COLOR_WHITE_20            ,COLOR_LT_GRAY_10           ,COLOR_DARK_GRAY_00
    .byte COLOR_DARK_RED_06         ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_DARK_BLUE_GREEN_0b
    .byte COLOR_LT_GRAY_10          ,COLOR_DARK_GRAY_00         ,COLOR_DARK_ORANGE_07
    .byte COLOR_PALE_RED_36         ,COLOR_MED_PINK_15          ,COLOR_DARK_RED_06
    .byte COLOR_PALE_PINK_35        ,COLOR_MED_PINK_15          ,COLOR_DARK_MAGENTA_04
    .byte COLOR_PALE_PINK_35        ,COLOR_MED_RED_16           ,COLOR_MED_TEAL_1c
    .byte COLOR_MED_OLIVE_18        ,COLOR_MED_PURPLE_13        ,COLOR_DARK_PURPLE_03
    .byte COLOR_LT_RED_26           ,COLOR_MED_PURPLE_13        ,COLOR_DARK_PURPLE_03
    .byte COLOR_MED_MAGENTA_14      ,COLOR_MED_PURPLE_13        ,COLOR_DARK_PURPLE_03
    .byte COLOR_LT_BLUE_GREEN_2b    ,COLOR_MED_PURPLE_13        ,COLOR_DARK_PURPLE_03
    .byte COLOR_LT_RED_26           ,COLOR_MED_RED_16           ,COLOR_DARK_PURPLE_03
    .byte COLOR_WHITE_20            ,COLOR_MED_PURPLE_13        ,COLOR_LT_ORANGE_27
    .byte COLOR_WHITE_20            ,COLOR_MED_RED_16           ,COLOR_LT_ORANGE_27
    .byte COLOR_DARK_GRAY_00        ,COLOR_DARK_GRAY_00         ,COLOR_DARK_GRAY_00
    .byte COLOR_MED_PINK_15         ,COLOR_MED_OLIVE_18         ,COLOR_DARK_OLIVE_08
    .byte COLOR_PALE_PINK_35        ,COLOR_MED_OLIVE_18         ,COLOR_DARK_OLIVE_08
.ifdef Probotector
    .byte COLOR_PALE_GREEN_3a       ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_BLACK_0f
.else
    .byte COLOR_WHITE_20            ,COLOR_MED_VIOLET_12        ,COLOR_MED_ORANGE_17
.endif
    .byte COLOR_MED_PINK_15         ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_DARK_BLUE_GREEN_0b
    .byte COLOR_BLACK_0f            ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_DARK_BLUE_GREEN_0b
    .byte COLOR_LT_MAGENTA_24       ,COLOR_MED_PURPLE_13        ,COLOR_DARK_PURPLE_03
    .byte COLOR_LT_ORANGE_27        ,COLOR_MED_ORANGE_17        ,COLOR_DARK_RED_06
    .byte COLOR_MED_ORANGE_17       ,COLOR_DARK_RED_06          ,COLOR_BLACK_0f
    .byte COLOR_DARK_RED_06         ,COLOR_WHITE_30             ,COLOR_LT_GRAY_10
    .byte COLOR_LT_RED_26           ,COLOR_WHITE_30             ,COLOR_LT_GRAY_10
.ifdef Probotector
    .byte COLOR_WHITE_20            ,COLOR_MED_VIOLET_12        ,COLOR_MED_ORANGE_17
.else
    .byte COLOR_DARK_GRAY_00        ,COLOR_DARK_GRAY_00         ,COLOR_DARK_GRAY_00
.endif
    .byte COLOR_WHITE_20            ,COLOR_LT_ORANGE_27         ,COLOR_MED_ORANGE_17
    .byte COLOR_LT_GRAY_10          ,COLOR_LT_RED_26            ,COLOR_DARK_RED_06
    .byte COLOR_LT_GRAY_10          ,COLOR_MED_RED_16           ,COLOR_DARK_ORANGE_07
    .byte COLOR_WHITE_20            ,COLOR_LT_VIOLET_22         ,COLOR_DARK_VIOLET_02
    .byte COLOR_LT_VIOLET_22        ,COLOR_WHITE_20             ,COLOR_DARK_VIOLET_02
    .byte COLOR_WHITE_20            ,COLOR_LT_GRAY_10           ,COLOR_DARK_GRAY_00
    .byte COLOR_MED_OLIVE_18        ,COLOR_DARK_ORANGE_07       ,COLOR_MED_GREEN_1a
    .byte COLOR_MED_RED_16          ,COLOR_MED_OLIVE_18         ,COLOR_DARK_ORANGE_07
    .byte COLOR_WHITE_20            ,COLOR_LT_GRAY_10           ,COLOR_MED_BLUE_11
    .byte COLOR_WHITE_20            ,COLOR_MED_BLUE_11          ,COLOR_MED_BLUE_11
    .byte COLOR_WHITE_20            ,COLOR_LT_TEAL_2c           ,COLOR_MED_BLUE_11
    .byte COLOR_LT_RED_26           ,COLOR_MED_OLIVE_18         ,COLOR_DARK_ORANGE_07
    .byte COLOR_MED_RED_16          ,COLOR_MED_OLIVE_18         ,COLOR_DARK_ORANGE_07
    .byte COLOR_MED_RED_16          ,COLOR_DARK_GRAY_00         ,COLOR_DARK_GRAY_00
.ifdef Probotector
    .byte COLOR_PALE_BLUE_GREEN_3b  ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_DARK_BLUE_GREEN_0b
.else
    .byte COLOR_DARK_BLUE_GREEN_0b  ,COLOR_MED_BLUE_GREEN_1b    ,COLOR_PALE_BLUE_GREEN_3b
.endif

; executed for indoor and outdoor levels
set_frame_scroll_draw_player_bullets:
    jsr set_frame_scroll_weapon_strength ; set frame scroll, set weapon strength, update invincibility
    lda INDOOR_SCROLL                    ; see if scrolling (0 = not scrolling; 1 = scrolling, 2 = finished scrolling)
    cmp #$02                             ; see if finished advancing and new screen has been shown
    bcc @continue                        ; branch if still scrolling, or haven't started, or not indoor level
    lda #$00                             ; a = #$00

@continue:
    sta INDOOR_SCROLL               ; reset indoor scroll if completed, otherwise, keep its current value
    lda AUTO_SCROLL_TIMER_00
    ora AUTO_SCROLL_TIMER_01        ; merge two auto-scrolling values
    beq @run_player_bullet_routines ; branch if no auto-scrolling
    lda #$01                        ; a = #$01
    sta FRAME_SCROLL                ; set scroll amount for frame

@run_player_bullet_routines:
    jsr load_bank_6_run_player_bullet_routines ; run player bullet routines

; draw half the bullets, every other frame
; if only one bullet drawn every other frame
draw_player_bullet_sprites:
    ldy #$07 ; maximum of #$08 player bullets drawn per frame

; loads bullets to sprite buffer
; on even frames, loops through #$0e, #$0c, #$0a, #$08, #$06, #$04, #$02, #$00
; on odd frames, loops through #$0f, #$0d, #$0b, #$09, #$07, #$05, #$03, #$01
; double y then set bit 0 based on frame number
@player_bullet_loop:
    tya                             ; transfer bullet draw counter to a
    asl                             ; double to get bullet offset
    sta $08                         ; store shifted value into $08
    lda FRAME_COUNTER               ; load the frame counter
    and #$01                        ; only care about bit 0 (odd/even)
    ora $08                         ; merge shifted bullet offset with frame counter odd/even flag
                                    ; if even frame, bullet index doesn't change
                                    ; if odd frame, adds one to bullet index
    tax                             ; move specified bullet in memory into CPU_SPRITE_BUFFER so it can be drawn
    lda PLAYER_BULLET_SPRITE_CODE,x ; load sprite code for specified bullet
    sta PLAYER_SPRITES+2,y          ; update bullet sprite in PLAYER_SPRITES
    lda PLAYER_BULLET_SPRITE_ATTR,x ; load any bullet sprite attributes
    sta SPRITE_ATTR+2,y             ; set bullet sprite attributes
    lda PLAYER_BULLET_Y_POS,x       ; load player bullet y position
    sta SPRITE_Y_POS+2,y            ; set sprite bullet y position
    lda PLAYER_BULLET_X_POS,x       ; load player bullet x position
    sta SPRITE_X_POS+2,y            ; set sprite bullet x position
    dey                             ; decrement to next bullet offset
    bpl @player_bullet_loop         ; loop if y still greater than or equal 0
    rts

; initializes frame scroll, runs logic to set weapon strength, update invincibility
set_frame_scroll_weapon_strength:
    lda #$00                   ; a = #$00
    sta FRAME_SCROLL           ; how much to scroll the screen (#00 - no scroll)
    sta PLAYER_FRAME_SCROLL    ; clear player 1 FRAME_SCROLL amount
    sta PLAYER_FRAME_SCROLL+1  ; clear player 2 FRAME_SCROLL amount
    sta ENEMY_ATTACK_FLAG      ; stop enemies from attacking
    sta PLAYER_WEAPON_STRENGTH ; clear player weapon strength
    ldy P1_GAME_OVER_STATUS    ; game over state of player 1 (1 = game over)
    bne @p2_game_over_status   ; skip assignment of a to #01 player 1 is in game over
    ora #$01                   ; set a to #$01 when player 1 is not in game over

@p2_game_over_status:
    ldy P2_GAME_OVER_STATUS                          ; player 2 game over state (1 = game over)
    bne run_player_invincibility_and_weapon_strength ; branch if player 2 is in game over, or if this is a single player game
    ora #$02                                         ; set bit 1 to #$01 when player 2 is not in game over

; a will be #$00 when both players are in game over
; a will be #$01 when player 1 not game over, player 2 game over (or not playing)
; a will be #$02 when player 1 game over, player 2 not game over
; a will be #$03 when neither player 1 nor player 2 are in game over
run_player_invincibility_and_weapon_strength:
    tax                                          ; transfer game over statuses to x
    beq player_state_routine_03                  ; branch when both players are in game over
    dex                                          ; prep for setting in PLAYER_GAME_OVER_BIT_FIELD
    stx PLAYER_GAME_OVER_BIT_FIELD               ; #$00 = p1 not game over, p2 game over (or not playing)
                                                 ; #$01 = p1 game over, p2 not game over, #$02 = p1 nor p2 are in game over
    txa                                          ; transfer PLAYER_GAME_OVER_BIT_FIELD to a
    and #$01                                     ; used to determine if only one player is active, if so run logic on that player
                                                 ; otherwise run logic on p1 first
    tax                                          ; transfer whether p2 is game over to x, set as current player
    jsr handle_invincibility_and_weapon_strength ; run player state routine, checks invincibility, set weapon strength
    lda PLAYER_GAME_OVER_BIT_FIELD               ; #$00 = p1 not game over, p2 game over (or not playing)
                                                 ; #$01 = p1 game over, p2 not game over, #$02 = p1 nor p2 are in game over
    cmp #$02                                     ; see if both players are active
    bne player_state_routine_03                  ; if one of the players is game over (or not playing)
                                                 ; already ran logic on the only active player, branch
    inx                                          ; both players active, already handled player 1, run logic for player 2
    jsr handle_invincibility_and_weapon_strength ; run player state routine, checks invincibility, set weapon strength
    jsr scroll_player                            ; scroll player that isn't causing the screen to scroll if necessary

player_state_routine_03:
    lda LEVEL_ROUTINE_INDEX ; load current level routine
    cmp #$04
    bne @exit               ; jump if not level routine 4 (this code is call from level_routine_04 and level_routine_09)
    lda PLAYER_MODE         ; number of players (#$00 = 1 player)
    beq @exit
    ldx #$01                ; x = #$01

@player_loop:
    lda P1_GAME_OVER_STATUS,x ; load game over state for player x (1 = game over)
    bne @check_transfer_life
    dex
    bpl @player_loop
    bmi @exit

; related to lives transfer between players
; if game over player presses 'A', then a life is taken from the other player if possible
@check_transfer_life:
    lda CONTROLLER_STATE_DIFF,x ; controller x buttons pressed
    and #$80                    ; keep bits x... .... (check for a button)
    beq @exit                   ; if a isn't pressed, exit
    txa
    eor #$01                    ; swap to other player by flipping bit 0
    tay
    lda P1_NUM_LIVES,y          ; load other player's number of lives
    beq @exit                   ; if other player doesn't have any additional remaining lives, exit
    cmp #$01
    bne @subtract_life
    lda PLAYER_STATE,y          ; player has load other player's player state
    cmp #$01                    ; make sure other player isn't dying and about to be on their last life
    bne @exit                   ; if other player's player state isn't normal, exit

@subtract_life:
    lda P1_NUM_LIVES,y ; player x lives
    sec                ; set carry flag in preparation for subtraction
    sbc #$01           ; lose a life from player Y
    cmp #$ff           ; check if out of lives
    bne @revive_player
    lda #$00           ; a = #$00

@revive_player:
    sta P1_NUM_LIVES,y         ; set new, lowered number of lives for other player
    jsr init_player_and_weapon ; reset revived player's attributes and player weapon
    sta PLAYER_STATE,x         ; reset revived player's state to #$00 (normal)
    sta P1_GAME_OVER_STATUS,x  ; clear game over status

@exit:
    rts

; find if a player needs to be scrolled back if they aren't causing the scroll
; for horizontal levels, this means the player is scrolled to the left
; for the vertical level, this means the player is scrolled down
scroll_player:
    lda LEVEL_LOCATION_TYPE     ; 0 = outdoor; 1 = indoor
    bne @exit2                  ; exit for indoor level, or indoor boss screen
    lda LEVEL_SCROLLING_TYPE    ; outdoor level, load scrolling type 0 = horizontal, indoor/base; 1 = vertical
    bne @vertical_scroll_player ; exit on vertical level
    jsr find_scrolled_player    ; find the player that isn't causing scroll and needs to be scrolled
    beq @exit                   ; exit if both players are causing scroll, don't cause any player to be scrolled
    dec SPRITE_X_POS,x          ; move player that isn't causing scroll back
                                ; other player will remain at same relative position on screen

@exit:
    rts

@vertical_scroll_player:
    lda AUTO_SCROLL_TIMER_00 ; see if auto scroll is enabled
    bne @exit2               ; exit if auto scroll is enabled, both players scroll down for auto scroll
    jsr find_scrolled_player ; find player that should be scrolled down the screen,
                             ; since they aren't causing the screen to scroll
    beq @exit2               ; exit if both players are causing the screen to scroll
    lda SPRITE_Y_POS,x       ; load the player to scroll's y position
    clc                      ; clear carry in preparation for addition
    adc FRAME_SCROLL         ; add the amount the screen is about to scroll
    sta SPRITE_Y_POS,x       ; adjust player position by FRAME_SCROLL so they are scrolled down the screen
    bcc @exit2               ; exit if no overflow occurred adding to player position
    inc PLAYER_HIDDEN,x      ; overflow occurred, set player as hidden (off screen)
                             ; doesn't ever seem to happen as off screen player dies before they can be hidden

@exit2:
    rts

; determine player that is not causing scroll that should be moved in the opposite direction of the scroll
; output
;  * x - 0 for p1, 1 for p2
;  * zero flag - clear when both players are causing scroll, set when only one
find_scrolled_player:
    ldx #$00                  ; x = #$00
    lda PLAYER_FRAME_SCROLL   ; load player 1's frame scroll amount
    cmp PLAYER_FRAME_SCROLL+1 ; compare to player 2's frame scroll amount
    beq @exit                 ; exit if both are identical (default player 1 cause scroll, x = #$00)
    bcc @exit                 ; exit if player 2 is causing scroll (mark player 1 cause scroll, x = #$00)
    inx                       ; mark player 2 causing scroll (x = #$01)

@exit:
    rts

; runs player state routine, checks new life invincibility timer,
; sets enemies to attack, sets weapon strength
; input
;  * x - player offset
handle_invincibility_and_weapon_strength:
    jsr run_player_state_routine       ; run logic based on player's state (see PLAYER_STATE)
    lda NEW_LIFE_INVINCIBILITY_TIMER,x ; timer for invincibility (after dying or start of level)
    beq set_enemies_to_attack          ; if invincibility timer is #$00, set enemies to attack
    dec NEW_LIFE_INVINCIBILITY_TIMER,x ; decrement value
    jmp decrement_invincibility_effect ; handle B (barrier) weapon (invincibility)

; new life invincibility elapsed. Set enemies to attack
set_enemies_to_attack:
    lda PLAYER_STATE,x                 ; load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    cmp #$01                           ; see if player is in normal state
    bne decrement_invincibility_effect ; if not in normal state, jump
    lda #$01                           ; new life invincibility timer elapsed, set enemies to attack
    sta ENEMY_ATTACK_FLAG              ; set enemies to attack

; decrement b weapon effect (invincibility) every 8th frame if active
decrement_invincibility_effect:
    lda INVINCIBILITY_TIMER,x
    beq @continue             ; if no invincibility, jump
    lda FRAME_COUNTER         ; load frame counter
    and #$07                  ; clear all but last 3 bits
    bne @continue             ; only decrement every #$8 frames
    dec INVINCIBILITY_TIMER,x ; decrement invincibility (b weapon effect) timer for current player

@continue:
    lda PLAYER_RECOIL_TIMER,x      ; see if how many frames player will have recoil
    beq set_player_weapon_strength
    dec PLAYER_RECOIL_TIMER,x      ; decrement player recoil timer

; set the player weapon strength memory value based on current weapon
set_player_weapon_strength:
    lda #$00                      ; a = #$00
    sta PLAYER_FAST_X_VEL_BOOST,x ; clear x fast velocity boost from being on a non-dangerous moving enemy
    lda P1_CURRENT_WEAPON,x       ; get current player's weapon
    and #$07                      ; keep bits .... .xxx
    tay
    lda weapon_strength,y         ; load how strong the weapon is
    cmp PLAYER_WEAPON_STRENGTH    ; compare against current weapon strength
    bcc @exit                     ; exit and do not lower player's current weapon strength
    sta PLAYER_WEAPON_STRENGTH    ; store current weapon strength code (#$00-#$03)

@exit:
    rts

; table for weapon strength code (#$05 bytes)
weapon_strength:
    .byte $00 ; Regular = Weak
    .byte $02 ; M = Strong
    .byte $01 ; F = Medium
    .byte $03 ; S = Very Strong
    .byte $02 ; L = Strong

; run logic based on players current state
; #$00 falling into level
; #$01 normal state
; #$02 dead
; #$03 can't move
run_player_state_routine:
    ldy CURRENT_LEVEL                ; current level
    lda LEVEL_LOCATION_TYPE          ; 0 = outdoor; 1 = indoor
    asl                              ; double the location type, shifting msb to carry
    lda level_spawn_position_index,y ; load the spawn position offset into a
    bcc @continue                    ; jump if not indoor boss screen
    lda #$03                         ; indoor boss screen, set $08 to #$03

@continue:
    sta $08                        ; store the offset into the spawn location into $08
                                   ; for player_state_routine_01 used to calculate offset into d_pad_player_aim_tbl
    lda PLAYER_STATE,x             ; load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    jsr run_routine_from_tbl_below ; run routine a in the following table (player_state_routine)

; pointer table for unknown ($04 * $02 = $08 bytes)
player_state_routine:
    .addr player_state_routine_00 ; CPU address $d4c3 - finds location to 'drop in' the player, executed once
    .addr player_state_routine_01 ; CPU address $d534
    .addr player_state_routine_02 ; CPU address $d593 - player has died, animate player falling backwards
    .addr player_state_routine_03 ; CPU address $d3e6

; the offset into vertical_spawn_position and horizontal_spawn_position
; for player_state_routine_01 used to calculate offset into d_pad_player_aim_tbl
; based on the level
level_spawn_position_index:
    .byte $00,$01,$02,$01,$00,$00,$00,$00

; player falling into level logic
; only run once to set player position
player_state_routine_00:
    jsr init_player_attributes
    txa                                  ; set a to be current player
    asl
    asl
    clc                                  ; clear carry in preparation for addition
    adc $08                              ; offset index into spawn position tables
    tay
    lda vertical_spawn_position,y
    sta SPRITE_Y_POS,x                   ; set player y position on screen
    lda horizontal_spawn_position,y
    sta SPRITE_X_POS,x                   ; set player x position on screen
    lda #$01                             ; a = #$01
    sta PLAYER_JUMP_STATUS,x
    lda LEVEL_LOCATION_TYPE              ; 0 = outdoor; 1 = indoor
    bne @set_frame_invincible_timer_exit ; branch if indoor level
    jsr @check_if_floor_exit             ; outdoor level, check if something to land on
    bcc @set_frame_invincible_timer_exit ; branch if there is something to land on
    lda #$10                             ; nothing to land on at current position
                                         ; move from left of screen to right to find a spot (increments of #$10 pixels at a time)
    sta SPRITE_X_POS,x                   ; set x position to #$10

@find_landing:
    jsr @check_if_floor_exit             ; check if something to land on
    bcc @set_frame_invincible_timer_exit ; branch if nothing to land on at current position
    lda SPRITE_X_POS,x                   ; nothing to land on at current position, move to next position
    clc                                  ; clear carry in preparation for addition
    adc #$10                             ; add #$10 to player x position
    sta SPRITE_X_POS,x                   ; set new x position
    cmp #$e0                             ; see if at end of screen
    bcs @set_x_pos                       ; couldn't find a position with a place to land, just use #$30
    jmp @find_landing                    ; loop to see if next position to the right is appropriate for landing

; couldn't find a position with a place to land, just use x position #$30
@set_x_pos:
    lda #$30           ; a = #$30
    sta SPRITE_X_POS,x ; set initial x position when dropping in level

; sets PLAYER_ANIMATION_FRAME_INDEX to #$02, NEW_LIFE_INVINCIBILITY_TIMER to #$80, PLAYER_Y_FAST_VELOCITY to #$00
; and moves to next player state before exiting
@set_frame_invincible_timer_exit:
    lda #$02                           ; a = #$02
    sta PLAYER_ANIMATION_FRAME_INDEX,x ; set frame index to #$02 sprite_08 (offset into player_curled_sprite_code_tbl)
                                       ; see set_player_jump_sprite
    lda #$00                           ; a = #$00
    sta PLAYER_Y_FAST_VELOCITY,x       ; set fast velocity to #$00 (fractional velocity still #$23 (.137))
    lda #$80                           ; invincibility time in number of frames, 2 seconds for NTSC
    sta NEW_LIFE_INVINCIBILITY_TIMER,x ; set timer for invincibility (after dying)
    inc PLAYER_STATE,x                 ; finished initializing player, move to state #$01 (normal state)
    rts

; see if there is a place for the player
; output
;  * carry flag - set when only empty collision codes below player; clear when solid, water, or ground beneath player
@check_if_floor_exit:
    jsr get_player_bg_collision_code ; get player background collision code
    asl                              ; push msb to carry flag (whether or not solid collision)
    bcs @exit                        ; exit with carry set when collision code #$80 (solid)
                                     ; this means there is a solid object at the top of the screen
    lda SPRITE_Y_POS,x               ; still falling, load sprite y position
    clc                              ; clear carry in preparation for addition
    adc #$20                         ; add #$20 to sprite y position
    jmp check_collision_below        ; jump to check if bg collision below player

@exit:
    rts

; player spawn positions, according to level and player index
; table for spawn y positions ($08 bytes)
vertical_spawn_position:
    .byte $20,$60,$50,$60 ; player 1
    .byte $20,$60,$50,$60 ; player 2

; table for spawn x positions ($08 bytes)
horizontal_spawn_position:
    .byte $30,$70,$30,$70 ; player 1
    .byte $20,$90,$20,$90 ; player 2

; normal player state
player_state_routine_01:
    jsr player_state_routine_01_logic
    jsr load_bank_2_set_player_sprite ; set player sprite based on player state, level, and animation sequence
    lda PLAYER_AIM_DIR,x
    sta PLAYER_AIM_PREV_FRAME,x
    lda PLAYER_HIDDEN,x               ; 0 - visible; #$01/#$ff = invisible (any non-zero)
    bne @exit
    lda SPRITE_Y_POS,x
    cmp #$e8                          ; check if falling at the bottom of the screen
    bcs kill_player

@exit:
    rts

; x is the current player
kill_player:
    lda #$52                           ; a = #$52 (sound_52)
    jsr play_sound                     ; play player death sound
    jsr init_player_data               ; reset player data and set a to #$00
    sta PLAYER_WATER_STATE,x
    sta ELECTROCUTED_TIMER,x
    sta PLAYER_SPECIAL_SPRITE_TIMER,x
    sta PLAYER_ANIMATION_FRAME_INDEX,x
    sta PLAYER_ANIM_FRAME_TIMER,x
    lda #$01                           ; a = #$01
    sta PLAYER_DEATH_FLAG,x
    lda #$fd                           ; initiate jump by setting y velocity to #$fd80
    sta PLAYER_Y_FAST_VELOCITY,x       ; player y velocity
    lda #$80                           ; a = #$80
    sta PLAYER_Y_FRACT_VELOCITY,x
    inc PLAYER_STATE,x
    rts

; set player aim direction based on d-pad input
; check if player is on an edge and should fall
; check if player is firing and generate bullet if so
; calculate player x velocity
; auto scroll player
player_state_routine_01_logic:
    jsr set_player_aim_for_input       ; set PLAYER_AIM_DIR based on d-pad input, facing direction, and jump status
    jsr check_player_ledge             ; see if player should check for walking off ledge and if so, walk off it
    jsr load_bank_6_check_player_fire  ; generate bullet if player is shooting and allowed to shoot
    jsr handle_player_state_calc_x_vel

; auto scroll the player position if auto-scroll enabled
auto_scroll_player:
    lda AUTO_SCROLL_TIMER_00        ; load auto scroll timer
    ora AUTO_SCROLL_TIMER_01        ; merge with auto scroll timer 01
    beq @exit                       ; branch if no auto scroll happening
    lda LEVEL_SCROLLING_TYPE        ; auto scroll happening, load scrolling type (0 = horizontal, indoor/base; 1 = vertical)
    bne @inc_y_pos_exit             ; increment y position and exit if vertical level with auto scroll (boss reveal)
    lda SPRITE_X_POS,x              ; horizontal, indoor/base level, load sprite x position
    ldy #$00                        ; y = #$00
    cmp level_left_edge_x_pos_tbl,y ; compare player position to left edge
    bcc @exit                       ; exit if already at farthest left edge to keep the player there (push them)
    dec SPRITE_X_POS,x              ; otherwise decrement from x position to make scroll effect
    rts

@inc_y_pos_exit:
    inc SPRITE_Y_POS,x

@exit:
    rts

; player has died, animate player falling backwards
player_state_routine_02:
    jsr auto_scroll_player           ; auto scroll the player position if auto-scroll enabled
    jsr sty_level_screen_type        ; get screen type #$00 = outdoor, #$01 = indoor/base boss, #$02 = indoor/base
    lda player_sprite_sequence_tbl,y ; load which animation to show for the player, .e.g. (4 = dead animation, 6 = indoor dead animation)
    sta PLAYER_SPRITE_SEQUENCE,x     ; set sprite sequence
    lda PLAYER_ANIM_FRAME_TIMER,x    ; see if animation timer has elapsed for sprite sequence
    beq @animation_timer_elapsed     ; branch if timer has elapsed
    dec PLAYER_ANIM_FRAME_TIMER,x    ; timer hasn't elapsed, decrement animation timer
    bne @set_player_sprite_exit
    jmp init_player_dec_num_lives    ; init player variables to #$00, decrement number of lives, set game over if needed

@animation_timer_elapsed:
    lda player_died_x_velocity_tbl,y ; which direction the player flies when killed
    sta PLAYER_X_VELOCITY,x          ; set player x velocity
    lda PLAYER_AIM_DIR,x
    cmp #$05                         ; see if facing left or right
    bcc @continue                    ; branch if facing right
    lda PLAYER_DEATH_FLAG,x          ; facing left, set bit 1 of PLAYER_DEATH_FLAG
    ora #$02                         ; set bit 1, so that player dies with head towards right
    sta PLAYER_DEATH_FLAG,x          ; update PLAYER_DEATH_FLAG
    lda #$00                         ; a = #$00
    sec                              ; set carry flag in preparation for subtraction
    sbc PLAYER_X_VELOCITY,x
    sta PLAYER_X_VELOCITY,x

@continue:
    lda PLAYER_Y_FAST_VELOCITY,x     ; load player's fast y velocity
    bmi @set_pos_and_sprite          ; branch if negative y velocity (ascending/falling back)
    cmp #$02                         ; compare y fast velocity to #$02
    bcc @set_pos_and_sprite          ; branch if y fast velocity is less than #$02
    lda PLAYER_HIDDEN,x              ; 0 - visible; #$01/#$ff = invisible (any non-zero)
    cmp #$01                         ; see if player hidden
    beq @set_animation_timer         ; branch if player is hidden
    jsr get_player_bg_collision_code ; player not hidden, get player background collision code
    beq @set_pos_and_sprite          ; branch if collision code #$00 (empty)
    cmp #$02                         ; see if collision code is #$02 (water)
    beq @set_pos_and_sprite          ; branch if in water
    jsr set_player_landing_y_offset  ; set SPRITE_Y_POS,x

@set_animation_timer:
    lda #$40                      ; a = #$40
    sta PLAYER_ANIM_FRAME_TIMER,x ; set animation timer to #$40 frames

@set_pos_and_sprite:
    jsr apply_gravity_set_y_pos ; increments y fractional velocity by #$23 (applying gravity) and sets y position
    jsr calc_player_x_vel       ; runs a series of checks to see if player's x velocity can be applied, and applies if possible

@set_player_sprite_exit:
    jmp load_bank_2_set_player_sprite ; set player sprite based on player state, level, and animation sequence

; table for unknown ($03 bytes)
player_sprite_sequence_tbl:
    .byte $04,$04,$06

; table for x velocities when dying (#$03 bytes)
; get screen type #$00 = outdoor, #$01 = indoor/base boss, #$02 = indoor/base
player_died_x_velocity_tbl:
    .byte $ff ; outdoor
    .byte $00 ; indoor/base boss
    .byte $00 ; indoor/base

handle_player_state_calc_x_vel:
    lda INDOOR_PLAYER_ADV_FLAG,x        ; load whether player is walking between screens for indoor level
    bne @continue                       ; branch if player is advancing between screens for indoor level
    lda #$00                            ; a = #$00
    sta PLAYER_X_VELOCITY,x             ; clear player x velocity to recalculate
    sta INDOOR_TRANSITION_X_FRACT_VEL,x ; clear fractional x velocity for when walking between screens on indoor levels

@continue:
    jsr handle_player_state

; runs a series of checks to see if player's x velocity can be applied, and applies if it possible
; e.g. checks if colliding with solid object, checks if in exiting water animation, checks if stuck due to boss screen limit
calc_player_x_vel:
    lda PLAYER_X_VELOCITY,x             ; load player X velocity
    clc                                 ; clear carry in preparation for addition
    adc PLAYER_FAST_X_VEL_BOOST,x       ; add any additional boost to velocity by being on a non-dangerous moving enemy
    sta PLAYER_X_VELOCITY,x             ; update player x velocity
    lda PLAYER_WATER_STATE,x            ; load player in water state flags
    bmi @exit                           ; exit if player is walking out of water, don't want to stop animation
    lda PLAYER_X_VELOCITY,x             ; load player X velocity
    ora INDOOR_TRANSITION_X_FRACT_VEL,x ; merge with fractional x velocity for when walking between screens on indoor levels
    beq @exit                           ; exit if player isn't moving
    lda PLAYER_X_VELOCITY,x             ; player is moving, load player X velocity
    bmi @player_negative_x_vel          ; branch if player going left
    lda BOSS_DEFEATED_FLAG              ; player has positive velocity, see if currently executing post-boss defeated walking animation
    bmi @set_scroll_apply_x_vel         ; branch to apply velocity if part of end of level walk off screen animation
    lda #$08                            ; checking bg collision #$08 pixels to right of player
    jsr check_player_solid_bg_collision ; see if player is about to collide with solid background object
    bcs @exit                           ; exit if collided with solid background object, like lvl 1 boss screen plated door
    jsr sty_level_screen_type           ; get screen type #$00 = outdoor, #$01 = indoor/base boss, #$02 = indoor/base
    lda SPRITE_X_POS,x                  ; load player's x position
    cmp level_right_edge_x_pos_tbl,y    ; compare player position to right edge of screen
    bcs @exit                           ; don't apply velocity if player at the right edge
    ldy BOSS_AUTO_SCROLL_COMPLETE       ; see if boss reveal auto-scroll has completed (0 = not-complete, 1 = complete)
    beq @set_scroll_apply_x_vel         ; branch to apply velocity if auto scroll hasn't completed (or started)
    ldy CURRENT_LEVEL                   ; auto-scroll has completed, load current level
    cmp @lvl_boss_max_x_scroll_tbl,y    ; compare player x position to the maximum x position for boss screen
    bcs @exit                           ; exit if can't move past x position

; !(BUG?) for vertical waterfall level.  Player y velocity has already been applied this frame
; this allows for the platform skip technique that speedrunners utilize by carefully controlling PLAYER_JUMP_COEFFICIENT
; note that when facing left, this bug does not apply because @player_negative_x_vel doesn't check scroll
; since you can't scroll left in Contra
@set_scroll_apply_x_vel:
    jsr set_frame_scroll_if_appropriate ; set FRAME_SCROLL and PLAYER_FRAME_SCROLL if player is causing screen to scroll
                                        ; note this is called for the vertical level as well
    jmp @apply_vel_to_player_x_pos

; table for maximum x position on boss screen to allow player to walk ($08 bytes)
; each byte is for each level
; for lvl 1, the x position isn't possible due to a solid bg object at #$88
; if you remove the collision code, the player won't walk past #$90
@lvl_boss_max_x_scroll_tbl:
    .byte $90,$ff,$ff,$ff,$a0,$d0,$b0,$b0

; player is going left
@player_negative_x_vel:
    lda #$f8                            ; a = #$f8 (#$08 pixels to left of player)
    jsr check_player_solid_bg_collision ; see if player is about to collide with solid background object
    bcs @exit                           ; exit if collided with solid background object
    lda BOSS_DEFEATED_FLAG              ; 0 = boss not defeated, 1 = boss defeated
    bmi @apply_vel_to_player_x_pos      ; branch to apply velocity if part of end of level walk off screen animation
    jsr sty_level_screen_type           ; get screen type #$00 = outdoor, #$01 = indoor/base boss, #$02 = indoor/base
    lda SPRITE_X_POS,x                  ; load player's x position
    cmp level_left_edge_x_pos_tbl,y     ; compare player position to left edge
    bcc @exit                           ; exit if player too far to the left

@apply_vel_to_player_x_pos:
    lda INDOOR_TRANSITION_X_ACCUM,x     ; load the amount of x distance to move for single animation when moving between screens on indoor/base levels
    clc                                 ; clear carry in preparation for addition
    adc INDOOR_TRANSITION_X_FRACT_VEL,x ; add to the fractional x velocity
    sta INDOOR_TRANSITION_X_ACCUM,x     ; store result back in accumulator
    lda SPRITE_X_POS,x                  ; load player x position
    adc PLAYER_X_VELOCITY,x             ; add the player velocity (including any indoor transition velocity adjustment)
    sta SPRITE_X_POS,x                  ; set new player x position

@exit:
    rts

; table for x position of right edge of screen ($03 bytes)
; #$00 (outdoor) = #$e6
; #$01 (indoor/base boss) = #$e0
; #$02 (indoor/base) = #$d0
level_right_edge_x_pos_tbl:
    .byte $e6,$e0,$d0

; table for x position of left edge of screen ($03 bytes)
; #$00 (outdoor) = #$1a
; #$01 (indoor/base boss) = #$20
; #$02 (indoor/base) = #$30
level_left_edge_x_pos_tbl:
    .byte $1a,$20,$30

handle_player_state:
    lda #$03                           ; a = #$03
    sta PLAYER_SPRITE_SEQUENCE,x
    lda INDOOR_PLAYER_JUMP_FLAG,x      ; see if engine has commanded the player to jump (set when entering new indoor screen)
    beq @player_electrocution_check    ; branch if no jump command specified
    lda #$00                           ; reset player jump command and set player jumping velocities
    sta INDOOR_PLAYER_JUMP_FLAG,x      ; reset player jump command
    sta INDOOR_PLAYER_ADV_FLAG,x       ; player is no longer walking between screens for indoor level, clear flag
    jsr indoor_transition_end          ; end player transition animation restore player position
    jmp set_jump_status_and_y_velocity ; initialize PLAYER_JUMP_STATUS, animation frame index, and negative y velocity

@player_electrocution_check:
    lda ELECTROCUTED_TIMER,x
    beq @player_edge_fall_check
    jmp update_indoor_electrocution ; decrement electrocution; if screen is cleared, stops electrocution

@player_edge_fall_check:
    lda EDGE_FALL_CODE,x
    beq @player_jump_check
    jmp set_x_velocity_for_edge_fall_code

@player_jump_check:
    lda PLAYER_JUMP_STATUS,x          ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    beq @indoor_transition_anim_check ; branch if the player isn't jumping
    jmp handle_jump                   ; player is jumping, jump

@indoor_transition_anim_check:
    lda INDOOR_PLAYER_ADV_FLAG,x  ; load whether player is walking between screens for indoor level
    beq @handle_player_input
    jmp indoor_transition_set_pos ; player is advancing between indoor screens, update player position for animation

@handle_player_input:
    lda PLAYER_WATER_STATE,x           ; see if player in water
    bne handle_d_pad                   ; player not in water, read the controller input for d-pad input
    lda CONTROLLER_STATE_DIFF,x        ; load controller input
    and #$80                           ; check for A button pressed
    beq handle_d_pad                   ; branch if a button not pressed to read the controller input
    lda CONTROLLER_STATE,x             ; load controller input
    and #$07                           ; keep bits .... .xxx (d-pad down, left, right)
    cmp #$04                           ; see if pressing the down d-pad button
    bne set_jump_status_and_y_velocity ; branch if not only down is pressed
                                       ; to initialize PLAYER_JUMP_STATUS, animation frame index, and negative y velocity
    lda #$02                           ; only down button pressed,a = #$02 (sprite sequence to crouching)
    sta PLAYER_SPRITE_SEQUENCE,x       ; set sprite sequence to crouching
    jsr can_player_drop_down           ; determines if player can drop down (d-pad down and A)
    bcs player_sprite_animation_exit   ; branch if player cannot drop down (nothing below player to land on and not vertical level)
    lda #$81                           ; a = #$81
    bne set_edge_fall_code             ; always branch

; called when walked off ledge (not jumped)
; determine collision code and leave result in A
; collision code 0 - Empty
; collision code 1 - Floor
; collision code 2 - Water
; collision code 3 - Solid
walk_off_ledge:
    lda PLAYER_AIM_DIR,x
    cmp #$05               ; compare to crouched facing right
    lda #$21               ; player is falling right off a ledge
    bcc set_edge_fall_code ; branch if PLAYER_AIM_DIR,x is less than #$05, i.e. facing right
    lda #$41               ; player is falling left off ledge

set_edge_fall_code:
    sta EDGE_FALL_CODE,x
    lda SPRITE_Y_POS,x
    clc                  ; clear carry in preparation for addition
    adc #$14             ; add #$14 to Y position
    bcc @continue        ; branch if no overflow
    lda #$ff             ; if overflow, just set #$ff

@continue:
    sta PLAYER_FALL_X_FREEZE,x ; store updated Y position in $b8

player_sprite_animation_exit:
    rts

; sets PLAYER_JUMP_STATUS based on facing direction, initializes animation frame index, and y velocity
; input
;  * x - player index
set_jump_status_and_y_velocity:
    lda PLAYER_AIM_DIR,x ; player animation frame
    cmp #$05
    lda #$91             ; a = #$91 (jumping left)
    bcs @continue        ; branch if facing left
    lda #$11             ; a = #$11 (jumping right)

@continue:
    sta PLAYER_JUMP_STATUS,x
    lda #$00                           ; a = #$00
    sta PLAYER_ANIM_FRAME_TIMER,x      ; reset player sprite index
    sta PLAYER_ANIMATION_FRAME_INDEX,x
    lda LEVEL_LOCATION_TYPE            ; 0 = outdoor; 1 = indoor
    lsr
    lda #$fb                           ; a = #$fb (-5)
    ldy #$f0                           ; y = #$f0 (.94)
    bcc @set_y_velocity                ; branch if outdoor level (use y velocity -5.94)
    lda #$fc                           ; indoor level, (y velocity -4.56), set fast velocity to #$fc (-4)
    ldy #$90                           ; set fractional y velocity to #$90 (.56)

@set_y_velocity:
    sta PLAYER_Y_FAST_VELOCITY,x  ; set y fast velocity to a
    tya                           ; transfer fractional velocity to a
    sta PLAYER_Y_FRACT_VELOCITY,x ; set y fractional velocity to a
    rts

; reads the d-pad controller input and updates velocity appropriately
handle_d_pad:
    lda CONTROLLER_STATE,x
    lsr
    bcs set_player_positive_x_velocity ; branch if d-pad right is pressed
    lsr
    bcs set_player_negative_x_velocity ; branch if d-pad left is pressed
    ldy #$02                           ; y = #$02 (crouching sprite sequence)
    lsr
    bcs set_sprite_sequence_to_y       ; branch if down button is pressed to set sprite sequence to #$02
    dey                                ; gun pointing up sprite sequence
    lsr
    bcs d_pad_up_pressed               ; branch if up button is pressed
    dey

set_sprite_sequence_to_y:
    tya

; sets animation to show for the player
;  * #$00 standing (no animation)
;  * #$01 gun pointing up
;  * #$02 crouching
;  * #$03 walking or curled jump animation
;  * #$04 dead animation
set_sprite_sequence_to_a:
    sta PLAYER_SPRITE_SEQUENCE,x
    rts

; d pad up button pressed by itself while not jumping
; on outdoor levels
; on indoor levels, check for electrocution (depends on if screen is cleared)
d_pad_up_pressed:
    lda LEVEL_LOCATION_TYPE      ; 0 = outdoor; 1 = indoor
    lsr
    bcc set_sprite_sequence_to_y ; branch for outdoor level
    jsr set_sprite_sequence_to_y ; indoor level, set sprite sequence to y
    lda INDOOR_SCREEN_CLEARED    ; indoor level, check indoor screen cleared flag (0 = not cleared; 1 = cleared)
    bne @indoor_screen_cleared   ; branch if indoor screen is cleared
    lda #$30                     ; indoor screen not clear (has electric fence), set electrocution timer to #$30 frames
    sta ELECTROCUTED_TIMER,x     ; set timer for being electrocuted to #$30
    lda #$1c                     ; a = #$1c (sound_1c - sound of electrocution)
    jmp play_sound               ; play sound

@indoor_screen_cleared:
    stx $10                                 ; backup player index to $10
    txa                                     ; transfer player index to a
    eor #$01                                ; move to other player
    tax                                     ; transfer other player index to x
    lda P1_GAME_OVER_STATUS,x               ; load game over state for player x (1 = game over)
    bne @check_players_advancing            ; branch if other player is in game over to skip player state check
    lda PLAYER_STATE,x                      ; both players alive, load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    cmp #$01                                ; compare to normal state
    bne set_player_standing_sprite_sequence ; branch if not in normal state
    lda PLAYER_JUMP_STATUS,x                ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    bne set_player_standing_sprite_sequence ; branch if jumping

@check_players_advancing:
    ldx #$01 ; start loop with player 2

@check_player_x_advancing:
    lda #$05                           ; a = #$05
    sta PLAYER_SPRITE_SEQUENCE,x       ; player animation frame
    lda INDOOR_PLAYER_ADV_FLAG,x       ; load whether player is walking between screens for indoor level
    bne @check_next_player             ; branch to move to next player if player x isn't walking between screens
    lda #$01                           ; player is walking between screens, a = #$01
    sta INDOOR_SCROLL                  ; set indoor scroll to #$01
    sta INDOOR_PLAYER_ADV_FLAG,x       ; set flag indicating player is walking between screens for indoor level
    lda #$00                           ; a = #$00
    sta PLAYER_ANIMATION_FRAME_INDEX,x ; initialize animation for player walking into screen
    sta PLAYER_ANIM_FRAME_TIMER,x      ; initialize timer delay between frames of animation of walking into screen
    jsr set_player_advancing_vel       ; set the x and y velocities and other variables to initiate the player advancing into screen

@check_next_player:
    dex                           ; move to player 1
    bpl @check_player_x_advancing
    ldx $10                       ; restore current player index to x
    rts

set_player_standing_sprite_sequence:
    ldx $10                      ; load player index
    lda #$00                     ; a = #$00, standing (no animation)
    beq set_sprite_sequence_to_a ; sets player animation sequence to standing

; sets the player's X velocity to a
set_player_positive_x_velocity:
    lda #$01                  ; a = #$01
    bne set_player_x_vel_to_a ; always jump, set X velocity to #$01

; facing left
set_player_negative_x_velocity:
    lda #$ff ; a = #$ff

set_player_x_vel_to_a:
    ldy PLAYER_WATER_STATE,x ; see if player is in water
    beq @continue            ; branch if animation is #$00 (not in water)
    sta $08                  ; player in water, set player X velocity in $08 temporarily
    lda CONTROLLER_STATE,x   ; see what buttons are being pressed
    and #$04                 ; see if d-pad has down direction (among others) pressed (down, down right, down left)
    bne @exit                ; don't set x velocity if down button is pressed (don't allow moving in water while looking down)
    lda $08                  ; restore desired player X velocity

@continue:
    sta PLAYER_X_VELOCITY,x

@exit:
    rts

; set y to level screen type
; output
; y - screen type: #$00 = outdoor level, #$01 = indoor boss level screen, #$02 = indoor level
sty_level_screen_type:
    ldy #$00                ; y = #$00
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor/base
    beq @exit               ; y = #$0 for outdoor level, exit
    iny                     ; indoor level set y = #$01
    asl
    bcs @exit               ; exit if indoor boss screen with y = #$01
    iny                     ; indoor non-boss screen set y = #$02

@exit:
    rts

set_x_velocity_for_edge_fall_code:
    lda SPRITE_Y_POS,x
    cmp PLAYER_FALL_X_FREEZE,x       ; load #$14 from where player starting falling
    bcc @off_ledge_start             ; branch if beginning of fall off/through ledge
    jsr get_player_bg_collision_code ; get player background collision code
    beq @off_ledge_start             ; if collision code set was #$00 (empty), branch
    jsr set_player_landing_y_offset  ; set SPRITE_Y_POS,x
    jmp player_land_on_ground

; can't adjust x velocity for small amount of time after walking off ledge
@off_ledge_start:
    jsr apply_gravity_set_y_pos   ; increments y fractional velocity by #$23 (applying gravity) and sets y position
    lda SPRITE_Y_POS,x            ; load player y position
    cmp PLAYER_FALL_X_FREEZE,x
    bcc @set_x_velocity
    jsr get_x_velocity_d_pad_code ; see if left or right d-pad button is pressed
    beq @set_x_velocity           ; branch if neither were pressed
    sta $08                       ; store #$20 for left d-pad, #$40 for right d-pad in $08
    lda EDGE_FALL_CODE,x
    and #$9f                      ; keep bits x..x xxxx
    ora $08                       ; update EDGE_FALL_CODE based on d-pad input
    sta EDGE_FALL_CODE,x

@set_x_velocity:
    lda EDGE_FALL_CODE,x
    jmp set_x_velocity_from_a_code

handle_jump:
    lda PLAYER_Y_FAST_VELOCITY,x ; load player y fast velocity
    bmi @check_collision_above   ; branch if player is still ascending
    ldy LEVEL_LOCATION_TYPE      ; player descending, load location type (0 = outdoor; 1 = indoor)
    bne @check_collision         ; branch for indoor level
    cmp #$01                     ; outdoor level, see if fast velocity is #$01
    bcc @apply_gravity           ; branch if either at apex of jump, or just beginning descent
    lda PLAYER_Y_FAST_VELOCITY,x ; player y fast velocity >= #$01, reload y fast velocity value
                                 ; !(HUH) already in a register, lda instruction not needed
    cmp #$04                     ; related to ground collision test
    bcs @check_collision         ; branch if velocity is greater than or equal to #$04 (fast falling)
    lda SPRITE_Y_POS,x           ; y velocity less than #$04, load player y position on screen
    clc                          ; clear carry in preparation for addition
    adc VERTICAL_SCROLL          ; add vertical scroll offset
    and #$0f                     ; keep bits .... xxxx
    cmp #$08                     ; seeing if result is less than #$08
    bcs @apply_gravity           ; branch to check collision only when result is less than #$08

@check_collision:
    jsr get_player_bg_collision_code ; get player background collision code
    beq @apply_gravity               ; if collision code set was #$00 (empty), branch
    jsr set_player_landing_y_offset  ; set SPRITE_Y_POS,x
    jsr @set_jump_status_from_input
    jmp player_land_on_ground

@check_collision_above:
    lda BOSS_DEFEATED_FLAG        ; 0 = boss not defeated, 1 = boss defeated
    bmi @apply_gravity            ; branch if boss already defeated
    lda SPRITE_Y_POS,x
    clc                           ; clear carry in preparation for addition
    adc #$f6                      ; subtract #$0a from y position
    tay                           ; set y position for bg collision check
    lda SPRITE_X_POS,x            ; load x position for bg collision check
    jsr get_bg_collision          ; determine player background collision code at position (a,y)
    bpl @apply_gravity            ; branch if not solid collision
    lda #$00                      ; solid collision above player, set Y velocity to #$00
    sta PLAYER_Y_FAST_VELOCITY,x  ; gravity will then pull the player down
    sta PLAYER_Y_FRACT_VELOCITY,x

@apply_gravity:
    jsr apply_gravity                   ; increments y fractional velocity by #$23 (applying gravity)
    lda LEVEL_SCROLLING_TYPE            ; 0 = horizontal, indoor/base; 1 = vertical
    beq @set_y_pos                      ; branch if horizontal level to to set the y position based on velocity
    jsr set_frame_scroll_if_appropriate ; vertical level, set FRAME_SCROLL and PLAYER_FRAME_SCROLL if player is causing screen to scroll
                                        ; when scrolling occurs player y velocity sets scroll amount and player y position is unchanged
    bcs @set_jump_status_from_input     ; branch if vertical FRAME_SCROLL was set

; no vertical scroll, apply velocity to player position
@set_y_pos:
    jsr player_jumping_set_y_pos ; set player y position based on PLAYER_JUMP_COEFFICIENT and velocity

@set_jump_status_from_input:
    jsr get_x_velocity_d_pad_code ; see if left or right d-pad button is pressed
    beq @set_x_velocity           ; branch if neither were pressed
    sta $08                       ; store #$20 for right d-pad, #$40 for left d-pad in $08
    lda PLAYER_JUMP_STATUS,x      ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    and #$9f                      ; keep bits x..x xxxx
    ora $08                       ; update EDGE_FALL_CODE based on d-pad input
    sta PLAYER_JUMP_STATUS,x

@set_x_velocity:
    lda PLAYER_JUMP_STATUS,x ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction

; a is EDGE_FALL_CODE, or PLAYER_JUMP_STATUS
; bit 7 set specifies negative velocity
; bit 6 set specifies positive velocity
set_x_velocity_from_a_code:
    asl                                ; shift a left
    bpl @continue                      ; branch if a is not negative
    jmp set_player_negative_x_velocity ; result was negative, player facing left, jump

@continue:
    asl
    bpl x_velocity_exit                ; branch if a is not negative
    jmp set_player_positive_x_velocity ; set player X velocity to modified EDGE_FALL_CODE

; set a to #$20 (right), #$40 (left), or #$00 (neither) based on d-pad
get_x_velocity_d_pad_code:
    ldy #$00               ; y = #$00
    lda CONTROLLER_STATE,x ; load controller state
    lsr
    bcc @test_left_d_pad   ; branch if not pressing right d-pad button
    ldy #$20               ; y = #$20

@test_left_d_pad:
    lsr
    bcc @continue
    ldy #$40      ; y = #$40

@continue:
    tya

x_velocity_exit:
    rts

; decrements player electrocution
; if screen is cleared, stops electrocution
update_indoor_electrocution:
    lda #$01                     ; a = #$01
    sta PLAYER_SPRITE_SEQUENCE,x ; player animation frame
    dec ELECTROCUTED_TIMER,x     ; counter for electrocution
    lda INDOOR_SCREEN_CLEARED    ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
    beq @exit                    ; exit if indoor screen is not cleared
    lda #$00                     ; screen cleared; stop electrocution
    sta ELECTROCUTED_TIMER,x     ; counter for electrocution

@exit:
    rts

; indoor transition, update player position
indoor_transition_set_pos:
    lda #$05                            ; a = #$05
    sta PLAYER_SPRITE_SEQUENCE,x        ; player animation frame
    lda PLAYER_JUMP_COEFFICIENT,x       ; not used as player's jump modifier in indoor levels, instead
                                        ; used when animating walking into screen for indoor levels to keep track of overflows
                                        ; to adjust y position
    clc                                 ; clear carry in preparation for addition
    adc INDOOR_TRANSITION_Y_FRACT_VEL,x ; add fractional y velocity for animation to 'accumulator'
    sta PLAYER_JUMP_COEFFICIENT,x       ; set new 'accumulator' value
    lda SPRITE_Y_POS,x                  ; player y position on screen
    adc INDOOR_TRANSITION_Y_FAST_VEL,x  ; add (or subtract) y position fast velocity to y position for advancing animation
                                        ; including any overflow from the fractional velocity
    sta SPRITE_Y_POS,x                  ; set new y position
    lda INDOOR_SCROLL                   ; see if scrolling (0 = not scrolling; 1 = scrolling, 2 = finished scrolling)
    cmp #$02
    bcc indoor_transition_exit

; end player transition animation restore player position
indoor_transition_end:
    lda #$00                     ; a = #$00
    sta INDOOR_PLAYER_ADV_FLAG,x ; player is no longer walking between screens for indoor level, clear flag
    lda PLAYER_INDOOR_ANIM_Y,x   ; load y position when player started advancing into screen (#$a8)
    sta SPRITE_Y_POS,x           ; restore y position from beginning of advancing animation
    lda PLAYER_INDOOR_ANIM_X,x   ; load x position when player started advancing into screen
    sta SPRITE_X_POS,x           ; restore x position from beginning of advancing animation

indoor_transition_exit:
    rts

player_land_on_ground:
    lda PLAYER_JUMP_STATUS,x           ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    ora EDGE_FALL_CODE,x
    beq @check_aim_dir                 ; brach if both are #$00
    lda #$00                           ; a = #$00
    sta PLAYER_ANIMATION_FRAME_INDEX,x
    sta PLAYER_ANIM_FRAME_TIMER,x
    sta PLAYER_FALL_X_FREEZE,x
    lda #$03                           ; a = #$03 (sound_03)
    jsr play_sound                     ; play player landing sound

@check_aim_dir:
    lda PLAYER_AIM_DIR,x
    cmp #$05                 ; see if player is facing right
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    and #$3f                 ; reset sprite flip data (clear bits 6 and 7)
    bcc @continue            ; branch if player is facing right
    ora #$40                 ; player facing left, flip sprite horizontally

@continue:
    sta PLAYER_SPRITE_FLIP,x ; store whether sprite is flipped horizontally and/or vertically

init_player_data:
    lda #$00                            ; a = #$00
    sta PLAYER_JUMP_STATUS,x
    sta EDGE_FALL_CODE,x
    sta PLAYER_SPRITE_SEQUENCE,x
    lda #$00                            ; a = #$00
    sta PLAYER_Y_FRACT_VELOCITY,x
    sta PLAYER_Y_FAST_VELOCITY,x
    sta INDOOR_TRANSITION_Y_FRACT_VEL,x
    sta INDOOR_TRANSITION_Y_FAST_VEL,x
    rts

; set the x and y velocities and a few other variables to initiate the player advancing into screen
set_player_advancing_vel:
    lda #$00                            ; a = #$00
    sta $12                             ; negate the resulting velocities
    lda #$58                            ; a = #$58 (speed code - affects speed when walking up)
    jsr set_vel_for_speed_code_a        ; set fast ($0f) and fractional ($0e) y velocities for speed code a
    lda $0f                             ; load fast y velocity
    sta INDOOR_TRANSITION_Y_FAST_VEL,x  ; set indoor transition y fast velocity
    lda $0e                             ; load fractional y velocity
    sta INDOOR_TRANSITION_Y_FRACT_VEL,x ; set indoor transition y fractional velocity
    lda SPRITE_Y_POS,x                  ; load player y position
    sta PLAYER_INDOOR_ANIM_Y,x          ; set y position the player was at when started walking into screen
                                        ; pretty sure always #$a8 since y pos is hard-coded for indoor levels
    lda SPRITE_X_POS,x                  ; load player x position
    sta PLAYER_INDOOR_ANIM_X,x          ; set x position the player was at when started walking into screen
    sec                                 ; set carry flag in preparation for subtraction
    sbc #$80                            ; subtract #$80 from PLAYER_INDOOR_ANIM_X,x
    sta $12                             ; store whether to have negative velocity (walk left) based on x position
                                        ; when player on right half of screen, player will advance inward towards left
                                        ; when player on left half of screen, player will advance inward towards right
    bcs @continue                       ; branch if on right half of the screen
    eor #$ff                            ; player on left half of the screen, take negative x position and make positive
    adc #$01                            ; flip all bits and add #$01

@continue:
    jsr set_vel_for_speed_code_a        ; set fast ($0f) and fractional ($0e) x velocities for speed code a
    lda $0f                             ; load fast x velocity
    sta PLAYER_X_VELOCITY,x             ; set x fast velocity
    lda $0e                             ; load fractional x velocity
    sta INDOOR_TRANSITION_X_FRACT_VEL,x ; set indoor transition x fractional velocity
    rts

; for a given value a, set fast ($0f) and fractional ($0e) velocities
; (a is rotated #$07 times into $0e)
; negate final results if $12 is non-negative
;  * a - sort-of speed code, this value is split into fast and fractional velocity
;  * $12 - when greater than or equal to #$00, specifies to negate the resulting velocities
; output
;  * $0e - x or y fractional velocity
;  * $0f - x or y fast velocity
set_vel_for_speed_code_a:
    sta $0f  ; store speed code in $0f
    lda #$00 ; a = #$00
    sta $0e  ; set $0e to #$00
    ldy #$07 ; set number of bits to rotate speed code to #$07

; for a given value $0f, set fast ($0f) and fractional ($0e) velocities based on y
; negate final results if $12 is greater than or equal to #$00
; also used directly for indoor bullets
;  * $0f - a sort-of speed code, this value is split into fast and fractional velocity based on y
;  * y - number of bits to rotate $0f into fractional velocity $0e (#$05, #$06, or #$07)
;  * $12 - when greater than or equal to #$00, specifies to negate the resulting velocities
; output
;  * $0e - x or y fractional velocity
;  * $0f - x or y fast velocity
set_vel_for_speed_vars:
    lsr $0f                       ; shift bit 0 to carry
    ror $0e                       ; push bit 0 of $0f into bit 7
    dey                           ; decrement y
    bne set_vel_for_speed_vars    ; continue to shift the next bit into the fractional velocity
    lda $12                       ; load whether to negate calculated velocity
    bpl @negate_bullet_velocities ; branch when $12 is greater than or equal to #$00 to negative velocity
    rts

@negate_bullet_velocities:
    lda #$00 ; a = #$00
    sec      ; set carry flag in preparation for subtraction
    sbc $0e  ; subtract the fractional velocity from #$00 (negate)
    sta $0e  ; set negated fractional x or y bullet velocity
    lda #$00 ; a = #$00
    sbc $0f  ; subtract the fast velocity from #$00 (negate)
    sta $0f  ; set negated fast x or y bullet velocity
    rts

; when landing, sets the player sprite Y position
set_player_landing_y_offset:
    jsr sty_level_screen_type    ; determine if screen needs to account for vertical offset
    lda landing_y_position_tbl,y ; load vertical scroll offset
    bne @set_sprite_y            ; branch if hard-coded y landing position (indoor/base level, indoor/base boss screen)
    lda VERTICAL_SCROLL          ; load vertical scroll offset
    and #$0f                     ; only care about low nibble (vertical offset within the nametable)
    ora #$f0                     ; set bits xxxx ....
    sta $00
    clc                          ; clear carry in preparation for addition
    adc SPRITE_Y_POS,x           ; add offset to sprite position
    and #$f0                     ; keep bits xxxx ....
    sec                          ; set carry flag in preparation for subtraction
    sbc $00
    clc                          ; clear carry in preparation for addition
    adc #$04                     ; move player position down by #$04 since landing from fall/jump

@set_sprite_y:
    sta SPRITE_Y_POS,x ; set sprite position
    rts

; table for landing y position (#$03 bytes)
; when #$00 vertical offset and current position are taken into consideration
landing_y_position_tbl:
    .byte $00,$c9,$a8

; calculates the player aim direction based on d-pad input, facing direction, and jump status
set_player_aim_for_input:
    ldy #$20               ; y = #$20 (row 2 of d_pad_player_aim_tbl)
    lda PLAYER_JUMP_STATUS ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    beq @continue          ; branch if not jumping
    ldy #$30               ; jumping, set y = #$30 (row 3 of d_pad_player_aim_tbl)

@continue:
    lda $08                     ; load level_spawn_position_index value for level
    cmp #$03                    ; see if indoor boss screen
    beq @set_player_aim         ; branch if indoor boss screen
    ldy #$00                    ; assume player facing facing right
    lda PLAYER_AIM_PREV_FRAME,x ; see which direction was the last frame
    cmp #$05                    ; compare to player crouching facing left
    bcc @set_player_aim         ; branch if facing left
    ldy #$10                    ; y = #$10 (row 1 of d_pad_player_aim_tbl)

@set_player_aim:
    sty $08                    ; set $08 to #$00, #$10, #$20, or #$30 depending on facing direction and jump status
    lda CONTROLLER_STATE,x     ; read controller state
    and #$0f                   ; keep bits .... xxxx (d pad input)
    clc                        ; clear carry in preparation for addition
    adc $08                    ; add d-pad input to $08
    tay                        ; transfer
    lda d_pad_player_aim_tbl,y ; load the aim direction based on the d-pad input
    sta PLAYER_AIM_DIR,x       ; set new player aim direction
    rts

; table for player aim direction code (#$40 bytes)
; each row is a type of aiming depending on player state and level type
; each byte offset represents a d-pad direction
; below is an example for 0th row (facing right)
; * d-pad value #$00 - no input - #$02 - facing right aiming up
; * d-pad value #$01 - r - #$02 - facing right
; * d-pad value #$02 - l - #$07 - facing left
; * d-pad value #$03 - l and r - #$02 - facing right
; * d-pad value #$04 - d - #$05 - crouch facing right
; * d-pad value #$05 - d and r - #$03 - aim down right
; * d-pad value #$06 - d and l - #$06 - aim down left
; * d-pad value #$07 - d l and r - #$02 - facing right
; * d-pad value #$08 - u - #$00 - facing right aiming up
; * d-pad value #$09 - u and r - #$01 - aiming up and right
; * d-pad value #$0a - u and l - #$08 - aiming up and left
; * d-pad value #$0b - l r and u - #$02 - facing right
; * d-pad value #$0c - u and d - #$07 - facing left
; * d-pad value #$0d - u d and r - #$02 - facing right
; * d-pad value #$0e - u d and l - #$07 - facing left
; * d-pad value #$0f - u d l and r - #$02 - facing right
d_pad_player_aim_tbl:
    .byte $02,$02,$07,$02,$04,$03,$06,$02,$00,$01,$08,$02,$07,$02,$07,$02 ; standing facing right
    .byte $07,$02,$07,$02,$05,$03,$06,$02,$09,$01,$08,$02,$07,$02,$07,$02 ; facing left
    .byte $00,$02,$07,$00,$00,$02,$07,$02,$00,$01,$08,$02,$07,$02,$07,$02
    .byte $00,$02,$07,$00,$0a,$03,$06,$02,$00,$01,$08,$02,$07,$02,$07,$02 ; jumping and indoor boss

; see if player should check for walking off ledge and if so, walk off it
check_player_ledge:
    lda PLAYER_ON_ENEMY,x            ; see if player is on non-dangerous enemy, e.g. (#$14, #$15 - mining cart, #$10 - floating rock platform)
    bne @clear_edge_code_exit        ; branch if player is on top non-dangerous enemy
    lda PLAYER_WATER_STATE,x         ; player not on enemy, load player water state
    ora PLAYER_JUMP_STATUS,x         ; merge with player jump status
    ora EDGE_FALL_CODE,x             ; merge with edge fall code
    ora INDOOR_PLAYER_ADV_FLAG,x     ; merge with whether or not the  player is walking between screens for indoor level
    bne @exit                        ; exit if any of the previous variables were non-zero
    lda PLAYER_BG_FLAG_EDGE_DETECT,x ; see if should detect falling off ledge or skip
    lsr
    bcs @clear_edge_code_exit
    jsr get_player_bg_collision_code ; get player background collision code
    beq jmp_walk_off_ledge           ; collision code is #$00 (empty), player is not on ground, fall
    cmp #$02                         ; see if player is in water (collision code #$02)
    beq init_PLAYER_WATER_STATE      ; if in water, initialize player in water animation

@clear_edge_code_exit:
    lda #$00
    sta EDGE_FALL_CODE,x

@exit:
    rts

init_PLAYER_WATER_STATE:
    lda #$01
    sta PLAYER_WATER_STATE,x ; initialize player in water animation
    rts

jmp_walk_off_ledge:
    jmp walk_off_ledge

; retrieves the collision code of the player and sets it in register a
; output
;  * carry flag set when on floor
; #$00 - empty
; #$01 - floor
; #$02 - water
; #$80 - solid (not 3 like normal)
get_player_bg_collision_code:
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor; #$80 if indoor boss screen
    bmi @indoor_boss_level  ; branch if indoor boss level
    bne @indoor_floor       ; non-indoor boss level, determine max Y position
    lda SPRITE_Y_POS,x      ; outdoor level, load player y position on screen
    clc                     ; clear carry in preparation for addition
    adc #$10                ; add #$10 to player Y position
    bcs @exit_code_0        ; branch if overflow
    tay                     ; transfer player y position to the y register
    lda SPRITE_X_POS,x      ; player x position on screen
    jmp get_bg_collision    ; not indoor nor indoor boss level, use get_bg_collision to get collision code

@indoor_floor:
    lda #$a0             ; indoor non-boss levels have a hard-coded max Y value of #$a0
    bne @indoor_continue ; always branch

@indoor_boss_level:
    lda #$c8 ; lowest Y value for indoor boss level is hard-coded #$c8

@indoor_continue:
    cmp SPRITE_Y_POS,x ; compare max Y to y position on screen
    lda #$01           ; prep collision code to #$01 (floor) if object is not at bottom of screen (walking to next screen)
    bcc @exit          ; branch if not at bottom of screen

@exit_code_0:
    lda #$00 ; collision code #$00 (not colliding with anything, or bottom of screen)

@exit:
    rts

; increments y fractional velocity by #$23 (applying gravity) and then sets y position
; based on y velocity and PLAYER_JUMP_COEFFICIENT
apply_gravity_set_y_pos:
    jsr apply_gravity ; increments y fractional velocity by #$23 (applying gravity)

; player is jumping, set player y position based on PLAYER_JUMP_COEFFICIENT and velocity
player_jumping_set_y_pos:
    lda PLAYER_Y_FAST_VELOCITY,x ; load player's fast y velocity
    asl                          ; shift negative bit to carry flag
    lda #$00                     ; player falling downward, or not falling (0 velocity)
    bcc @continue                ; branch if player is moving down (down or #$00 y velocity)
    lda #$ff                     ; player moving up

@continue:
    sta $08                       ; store either #$00 (falling down or not falling) or #$ff (moving up) in $08
    lda PLAYER_JUMP_COEFFICIENT,x ; load player's jump modifier (alters height of jump)
    clc                           ; clear carry in preparation for addition
    adc PLAYER_Y_FRACT_VELOCITY,x ; add to player's fractional y velocity
    sta PLAYER_JUMP_COEFFICIENT,x ; update player's jump modifier (alters height of jump)
    lda SPRITE_Y_POS,x            ; load player's y position
    adc PLAYER_Y_FAST_VELOCITY,x  ; add (subtract) the fast y velocity (with jump coefficient overflow)
    sta SPRITE_Y_POS,x            ; set player's new y position
    lda PLAYER_HIDDEN,x           ; 0 - visible; #$01/#$ff = invisible (any non-zero)
    adc $08                       ; add or subtract #$01 to specify whether player is visible (with any overflow)
    sta PLAYER_HIDDEN,x           ; set whether to draw player sprite, not sure how this is really supposed to be used
    rts

; apply gravity by incrementing y fractional velocity by #$23 (.1367 in decimal)
apply_gravity:
    clc
    lda PLAYER_Y_FRACT_VELOCITY,x ; load player's y fractional velocity
    adc #$23                      ; add #$23 to y fractional velocity (.1367 decimal)
    sta PLAYER_Y_FRACT_VELOCITY,x ; update player's y fractional velocity
    lda PLAYER_Y_FAST_VELOCITY,x  ; load player's fast y velocity
    adc #$00                      ; add carry into high byte (any overflow when adding to fractional y velocity)
    sta PLAYER_Y_FAST_VELOCITY,x  ; update player's fast y velocity
    rts

; player death
init_player_dec_num_lives:
    jsr init_player_and_weapon ; initialize player variables to 0
    sta PLAYER_STATE,x         ; set player state to #$00 (falling into level)
    lda P1_NUM_LIVES,x         ; load player number of lives
    beq @set_game_over         ; branch if no more lives
    dec P1_NUM_LIVES,x         ; decrement player number of lives
    rts

@set_game_over:
    lda #$01                  ; a = #$01
    sta P1_GAME_OVER_STATUS,x ; game over state of player (1 = game over)
    rts

; sets FRAME_SCROLL and PLAYER_FRAME_SCROLL if player is causing screen to scroll
set_frame_scroll_if_appropriate:
    lda LEVEL_LOCATION_TYPE                ; 0 = outdoor; 1 = indoor
    ora AUTO_SCROLL_TIMER_00               ; merge with AUTO_SCROLL_TIMER_00
    ora AUTO_SCROLL_TIMER_01               ; merge with AUTO_SCROLL_TIMER_01
    bne @exit                              ; if indoor, or any auto scroll timer running, exit
    lda PLAYER_STATE,x                     ; load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    cmp #$01                               ; see if player in normal state
    bne @exit                              ; exit if in normal state
    lda LEVEL_SCROLLING_TYPE               ; 0 = horizontal, indoor/base; 1 = vertical
    bne set_vertical_level_frame_scroll    ; branch if vertical scrolling
    lda LEVEL_STOP_SCROLL                  ; horizontal, indoor/base level, load screen to stop scrolling at
    bmi @exit                              ; exit if boss auto scroll set (LEVEL_STOP_SCROLL is #$ff when boss auto scroll started)
    ldy PLAYER_GAME_OVER_BIT_FIELD         ; #$00 = p1 not game over, p2 game over (or not playing)
                                           ; #$01 = p1 game over, p2 not game over, #$02 = p1 nor p2 are in game over
    lda SPRITE_X_POS,x                     ; load player x position
    cmp horizontal_scroll_point_tbl,y      ; load horizontal scroll point position
    bcc @exit                              ; if not yet reached point to initiate horizontal scroll, exit
    cpy #$02                               ; see if both players are active
    bne @set_horizontal_level_frame_scroll ; if both players aren't active, begin setting scroll
    txa                                    ; both players active, see if other player is preventing screen scroll, transfer player index to a
    eor #$01                               ; swap to other player
    tay                                    ; transfer player index to y
    lda SPRITE_X_POS,y                     ; load other player's x position
    cmp #$21                               ; compare other player to left edge of screen
    bcc @stop_player_x_velocity            ; don't scroll if other player is preventing it by being too far to the left

; sets FRAME_SCROLL if needed on horizontal levels
; sees if player is causing scroll
; if so sets FRAME_SCROLL to the right value based on Y velocity and PLAYER_JUMP_COEFFICIENT
; output
;  * carry flag - #$01 set when scroll initiated
@set_horizontal_level_frame_scroll:
    jsr set_boss_auto_scroll            ; starts the auto scroll to reveal boss if at right screen, otherwise do nothing
    beq @exit                           ; branch if boss auto scroll started
    lda INDOOR_TRANSITION_X_FRACT_VEL,x ; load player's indoor x velocity (#$00 unless on indoor/base level)
    clc                                 ; clear carry in preparation for addition
    adc INDOOR_TRANSITION_X_ACCUM,x
    sta INDOOR_TRANSITION_X_ACCUM,x     ; update INDOOR_TRANSITION_X_ACCUM with increased velocity
    lda PLAYER_X_VELOCITY,x             ; load player X velocity
    adc #$00                            ; incorporate any velocity overflow from INDOOR_TRANSITION_X_ACCUM
    sta FRAME_SCROLL                    ; set screen scroll amount
    lda #$01                            ; a = #$01
    sta PLAYER_FRAME_SCROLL,x           ; set player scroll amount for player causing scroll
    lda #$00                            ; a = #$00
    sta INDOOR_TRANSITION_X_FRACT_VEL,x ; clear player indoor velocity
    sta PLAYER_X_VELOCITY,x             ; clear player x velocity
    sec                                 ; set carry flag
    rts

@stop_player_x_velocity:
    lda #$00                            ; a = #$00
    sta INDOOR_TRANSITION_X_FRACT_VEL,x
    sta PLAYER_X_VELOCITY,x

@exit:
    clc
    rts

; load the x point on horizontal levels to start scrolling the screen
; when 1 player mode, or only 1 player alive, it's the middle of the screen (#$80)
; for 2 active players, it's 70% of the screen (#$b0)
; byte 0 = p1 not game over, p2 game over (or not playing)
; byte 1 = p1 game over, p2 not game over
; byte 2 = p1 nor p2 are in game over
horizontal_scroll_point_tbl:
    .byte $80,$80,$b0

; sets FRAME_SCROLL if needed on vertical level (going up)
; sees if player is jumping up and high enough to cause scrolling
; if so sets FRAME_SCROLL to the right value based on Y velocity and PLAYER_JUMP_COEFFICIENT
; instead of moving player sprite based on velocity, moves scroll based on velocity
; output
;  * carry flag - set when scroll initiated, clear when scroll not initiated
set_vertical_level_frame_scroll:
    lda SPRITE_Y_POS,x            ; load player y position
    cmp #$50                      ; compare to #$50
    bcs @exit                     ; exit if player y position >= #$50, i.e. far down the screen
                                  ; once player is above #$50, scrolling up is initiated
    lda PLAYER_Y_FAST_VELOCITY,x  ; load player's y fast velocity byte
    bpl @exit                     ; exit if player falling down
    jsr set_boss_auto_scroll      ; starts the auto scroll to reveal boss if at right screen, otherwise do nothing
    beq @exit                     ; branch if boss auto scroll started
    lda PLAYER_JUMP_COEFFICIENT,x ; player is jumping up, load player's jump modifier (alters height of jump)
    clc                           ; clear carry in preparation for addition
    adc PLAYER_Y_FRACT_VELOCITY,x ; add the player's fractional velocity to the jump modifier
    sta PLAYER_JUMP_COEFFICIENT,x ; update player's jump modifier (randomizes height of jump)
    lda SPRITE_Y_POS,x            ; re-load player y position
    adc PLAYER_Y_FAST_VELOCITY,x  ; add (or subtract) player y fast velocity
                                  ; (with any possible carry from the fractional velocity)
    sta $08                       ; store sum in $08
    lda SPRITE_Y_POS,x            ; re-load player y position
    sec                           ; set carry flag in preparation for subtraction
    sbc $08                       ; subtract calculated position to get scroll distance
    sta FRAME_SCROLL              ; store scroll amount
    lda #$01                      ; a = #$01
    sta PLAYER_FRAME_SCROLL,x     ; set player scroll amount for player causing scroll
    sec                           ; set carry flag so calling method knows frame scroll happened
    rts

@exit:
    clc
    rts

; determines if player can drop down (d-pad down and A)
; player can drop down when solid, water, or floor bg collision below the current player
; vertical levels always allow drop down regardless if collision below player
; input
;  * x - player index
; output
;  * carry flag - clear when player can "drop down" (d-pad down + A)
;                 i.e. there is a solid, water, or floor collision below the player
;                 set when player cannot "drop down" (d-pad down + A)
can_player_drop_down:
    lda LEVEL_STOP_SCROLL      ; load the screen to stop scrolling on, set to #$ff when boss auto scroll starts
    cmp #$ff                   ; see if boss auto scroll has started
    beq @continue              ; branch if auto scroll has started
    lda LEVEL_SCROLLING_TYPE   ; 0 = horizontal, indoor/base; 1 = vertical
    bne collision_below_player ; clear carry and exit for vertical level, always can drop down

@continue:
    lda SPRITE_Y_POS,x ; load player y position
    clc                ; clear carry in preparation for addition
    adc #$10           ; prepare to move player down by #$10 pixels

; determines if solid, water, or floor bg collision below the player (all the way to the bottom of screen)
; input
;  * a - y position to test
;  * x - player offset
; output
;  * a - collision code
;  * carry flag - set when only empty collision codes below player, i.e. there is something to land on
;    set when solid, water, or ground beneath player
check_collision_below:
    tay                      ; transfer y position to y register
    lsr
    lsr
    lsr
    lsr
    sta $08                  ; store high nibble of player y position in $08
    lda SPRITE_X_POS,x       ; load player x position
    jsr get_bg_collision_far ; determine player background collision code for (a, y) position
    bmi set_carry_exit       ; exit if collision with solid bg element, can't drop down

; loops down to bottom of screen looking for a bg collision
@loop:
    inc $08                           ; increment y position high byte, i.e. bg collision row
    lda $08                           ; load y position high byte
    cmp #$0e                          ; compare to last bg collision row
    bcs can_player_drop_down_exit     ; exit if checked all rows below player
    lda $13                           ; load BG_COLLISION_DATA offset
    and #$c0                          ; keep bits xx.. ....
    sta $17
    lda $13                           ; re-load BG_COLLISION_DATA offset
    clc                               ; clear carry in preparation for addition
    adc #$04                          ; move down one row
    and #$3f                          ; keep bits ..xx xxxx
    ora $17                           ; determine final BG_COLLISION_DATA
    tay                               ; move to BG_COLLISION_DATA
    jsr read_bg_collision_byte_unsafe ; get collision code from BG_COLLISION_DATA byte
    beq @loop                         ; loop if no collision, collision code #$00 (empty)

collision_below_player:
    clc ; clear when found non-empty collision

can_player_drop_down_exit:
    rts

set_carry_exit:
    sec ; set carry flag
    rts

; initialize player variables to 0
; input
;  * x - player offset (0 = p1, 1 = p2)
init_player_and_weapon:
    lda #$00                ; a = #$00
    sta P1_CURRENT_WEAPON,x ; reset current player's weapon

init_player_attributes:
    lda #$00                            ; a = #$00
    sta CPU_SPRITE_BUFFER,x
    sta SPRITE_Y_POS,x
    sta SPRITE_X_POS,x
    sta SPRITE_ATTR,x
    sta INDOOR_TRANSITION_X_ACCUM,x
    sta PLAYER_JUMP_COEFFICIENT,x
    sta INDOOR_TRANSITION_X_FRACT_VEL,x
    sta PLAYER_X_VELOCITY,x
    sta INDOOR_TRANSITION_Y_FRACT_VEL,x
    sta INDOOR_TRANSITION_Y_FAST_VEL,x
    sta PLAYER_ANIM_FRAME_TIMER,x
    sta PLAYER_JUMP_STATUS,x
    sta PLAYER_FRAME_SCROLL,x
    sta EDGE_FALL_CODE,x
    sta PLAYER_ANIMATION_FRAME_INDEX,x
    sta PLAYER_INDOOR_ANIM_Y,x
    sta PLAYER_M_WEAPON_FIRE_TIME,x
    sta NEW_LIFE_INVINCIBILITY_TIMER,x
    sta INVINCIBILITY_TIMER,x
    sta PLAYER_WATER_STATE,x
    sta PLAYER_DEATH_FLAG,x
    sta PLAYER_ON_ENEMY,x
    sta PLAYER_FALL_X_FREEZE,x
    sta PLAYER_HIDDEN,x
    sta PLAYER_SPRITE_SEQUENCE,x
    sta PLAYER_INDOOR_ANIM_X,x
    sta PLAYER_AIM_PREV_FRAME,x
    sta PLAYER_AIM_DIR,x
    sta PLAYER_Y_FRACT_VELOCITY,x
    sta PLAYER_Y_FAST_VELOCITY,x
    sta ELECTROCUTED_TIMER,x
    sta INDOOR_PLAYER_JUMP_FLAG,x
    sta PLAYER_WATER_TIMER,x
    sta PLAYER_RECOIL_TIMER,x
    sta INDOOR_PLAYER_ADV_FLAG,x
    sta PLAYER_SPRITE_CODE,x
    sta PLAYER_SPRITE_FLIP,x
    sta PLAYER_BG_FLAG_EDGE_DETECT,x
    rts

; on player x position change
; input
;  * a - amount to add to player x position
;  * x - player offset
; output
;  * carry flag - set when collided with solid object
check_player_solid_bg_collision:
    clc                      ; clear carry in preparation for addition
    adc SPRITE_X_POS,x       ; add a to player x position
    sta $0a                  ; store x position in $0a
    ldy #$0b                 ; default amount to subtract from player y position
    lda PLAYER_SPRITE_CODE,x ; load player sprite
    cmp #$17                 ; compare to player prone sprite
    bne @continue            ; branch if player isn't prone
    ldy #$00                 ; player is prone, don't subtract from player y position

@continue:
    sty $08             ; set amount to subtract from player y position
    lda PLAYER_HIDDEN,x ; 0 = visible; #$01/#$ff = invisible (any non-zero)
    bne @continue_2     ; branch if invisible
    lda SPRITE_Y_POS,x  ; load player y position
    sec                 ; set carry flag in preparation for subtraction
    sbc $08             ; subtract either #$0b or #$00 from player y position
    bcc @continue_2     ; branch if underflow
    cmp #$10            ; compare calculated y position to #$10
    bcs @continue_3     ; branch if result is grater than #$10

@continue_2:
    lda #$0a ; a = #$0a

@continue_3:
    sta $09                          ; set calculated y position (position above player)
    jsr get_player_bg_collision_code ; get player background collision code, set result in a
    bne @player_bg_collision         ; branch if collision code is not #$00 (empty)
    lda PLAYER_JUMP_STATUS,x         ; collision code #$00 (empty) load jump status
                                     ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    lsr                              ; shift jump bit to carry flag
    lda #$1b                         ; a = #$1b
    bcs @find_bg_collision           ; branch if jumping

@player_bg_collision:
    lda #$0a ; a = #$0a
    clc      ; clear carry in preparation for addition
    adc $08  ; add #$0a to the amount subtracted from player y position

@find_bg_collision:
    sta $08                  ; store new y position distance
    lda $09                  ; load calculated y position (position above player)
    clc                      ; clear carry in preparation for addition
    adc VERTICAL_SCROLL      ; vertical scroll offset
    and #$0f                 ; keep bits .... xxxx
    sta $0b
    lda #$10                 ; a = #$10
    sec                      ; set carry flag in preparation for subtraction
    sbc $0b
    sta $0b
    lda $0a                  ; load x position
    ldy $09                  ; load y position
    jsr get_bg_collision_far ; determine player background collision code at position (a,y)
    bmi @set_carry_exit      ; branch if collision with solid bg element

; look at background collision tiles in front of player
@loop:
    lda $0b
    cmp $08                  ; compare to y position
    bcs @clear_carry_exit
    adc #$10
    sta $0b
    lda $13
    and #$c0                 ; keep bits xx.. ....
    sta $17
    lda $13
    clc                      ; clear carry in preparation for addition
    adc #$04
    and #$3f                 ; keep bits ..xx xxxx
    ora $17
    tay                      ; set BG_COLLISION_DATA offset
    jsr find_floor_collision ; get collision code at BG_COLLISION_DATA,y and if not floor
                             ; look down one collision row and get that collision code
    bpl @loop                ; loop if collision code is non-empty

@set_carry_exit:
    sec ; set carry flag
    rts

@clear_carry_exit:
    clc
    rts

; initializes PPU scroll offset, PPU write offsets
; then calls load_current_supertiles_screen_indexes to decompress super-tiles
; of the current level's current screen to load into CPU memory at LEVEL_SCREEN_SUPERTILES
init_ppu_write_screen_supertiles:
    lda LEVEL_SCROLLING_TYPE      ; load level scroll (horizontal or vertical)
    bne config_vertical_scrolling ; set-up level for vertical scrolling
    lda LEVEL_LOCATION_TYPE       ; 0 = outdoor; 1 = indoor
    bne continue_init_level       ; skip scrolling setup for indoor levels
    lda #$30

; initializes scrolling offsets and sets PPU write address to top left of nametable
; sets up the attribute table write address to the first attribute table
config_horizontal_scrolling:
    sta LEVEL_TRANSITION_TIMER                 ; set to a (either #$30 for indoor level or #$20 for outdoor level)
    lda #$00
    sta LEVEL_SCREEN_NUMBER
    sta LEVEL_SCREEN_SCROLL_OFFSET             ; scrolling offset in pixels within screen
    sta SUPERTILE_NAMETABLE_OFFSET             ; set to nametable 0 (#$00)
    sta PPU_WRITE_TILE_OFFSET
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    lda #$20
    sta PPU_WRITE_ADDRESS_HIGH_BYTE            ; set PPU write address to $2000
    lda #$c0
    sta ATTRIBUTE_TBL_WRITE_LOW_BYTE           ; since all attribute tables have #$c0 in their low byte, this is actually never read, just stored
    lda #$23
    sta ATTRIBUTE_TBL_WRITE_HIGH_BYTE          ; $23c0 is the first nametable attribute table
    jmp load_current_supertiles_screen_indexes ; load the super tile indexes for the screen into memory at LEVEL_SCREEN_SUPERTILES

; initializes scrolling offsets and sets PPU write address to bottom left of nametable
config_vertical_scrolling:
    lda #$00
    sta LEVEL_SCREEN_SCROLL_OFFSET             ; scrolling offset in pixels within screen
    sta LEVEL_SCREEN_NUMBER
    sta SUPERTILE_NAMETABLE_OFFSET             ; set to nametable 0 (#$00)
    lda #$1d
    sta PPU_WRITE_TILE_OFFSET                  ; vertical levels start with #$1d and are decremented as level scrolls up
    lda #$a0
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    lda #$23
    sta PPU_WRITE_ADDRESS_HIGH_BYTE            ; sets write address begin to #$23a0, which is the bottom left of the vertical level's nametable
    jmp load_current_supertiles_screen_indexes ; load the super tile indexes for the screen into memory at LEVEL_SCREEN_SUPERTILES

continue_init_level:
    lda #$10
    sta BG_PALETTE_ADJ_TIMER
    jsr load_palettes_color_to_cpu  ; load #$10 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX
    lda #$20
    bne config_horizontal_scrolling ; always jump since lda #$20 clears zero flag

; animate initial level nametable drawing
; output
;  * zero flag - set when LEVEL_TRANSITION_TIMER has elapsed, clear otherwise
init_lvl_nametable_animation:
    lda LEVEL_SCROLLING_TYPE                ; 0 = horizontal, indoor/base; 1 = vertical
    bne @vertical_level                     ; branch for vertical level
    lda LEVEL_LOCATION_TYPE                 ; 0 = outdoor; 1 = indoor
    bne @indoor_level                       ; branch for indoor level
    jsr load_column_of_tiles_to_cpu_buffer  ; outdoor horizontal level, load the next column of tiles to CPU for drawing
                                            ; set bg collision data in CPU memory
    jsr write_col_attribute_to_cpu_memory   ; write a column of attribute palette data (#$07 bytes) to the CPU graphics buffer
    inc PPU_WRITE_ADDRESS_LOW_BYTE          ; increment PPU write address low byte (move to next nametable column)
    inc PPU_WRITE_TILE_OFFSET
    dec LEVEL_TRANSITION_TIMER
    beq @exit                               ; exit with zero flag set when LEVEL_TRANSITION_TIMER is #$00
    lda PPU_WRITE_TILE_OFFSET               ; transition timer hasn't elapsed
    cmp #$20                                ; see if finished writing entire nametable with pattern table tiles
    bcc @set_a_exit                         ; branch if not finished with nametable
    lda #$00                                ; finished writing entire nametable, reset PPU write address low byte
    sta PPU_WRITE_ADDRESS_LOW_BYTE          ; set PPU write address low byte to #$00
    sta PPU_WRITE_TILE_OFFSET               ; reset ppu write tile column offset
    lda #$24                                ; set to top-right nametable
    sta PPU_WRITE_ADDRESS_HIGH_BYTE         ; move PPU write address to top right nametable
    lda #$27                                ; load attribute table to write to (top-right [$27c0-$27f8])
    sta ATTRIBUTE_TBL_WRITE_HIGH_BYTE       ; set attribute table write address to $27c0 (2nd attribute table)
    lda #$40                                ; load 2nd nametable offset into $0600 (LEVEL_SCREEN_SUPERTILES) for super-tile indexes
    sta SUPERTILE_NAMETABLE_OFFSET          ; set to nametable 1 (#$40)
    jsr load_next_supertiles_screen_indexes ; load the super tile indexes for the upcoming screen into memory at LEVEL_SCREEN_SUPERTILES

@set_a_exit:
    lda #$ff ; exit with zero flag clear

@exit:
    rts

@vertical_level:
    jsr set_vert_lvl_super_tiles
    jsr write_row_attribute_to_cpu_memory   ; write a row of attribute palette data (#$08 bytes) to the CPU graphics buffer
    lda PPU_WRITE_ADDRESS_LOW_BYTE
    sec                                     ; set carry flag in preparation for subtraction
    sbc #$20
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    lda PPU_WRITE_ADDRESS_HIGH_BYTE
    sbc #$00
    sta PPU_WRITE_ADDRESS_HIGH_BYTE
    dec PPU_WRITE_TILE_OFFSET
    bpl @set_a_exit
    jsr config_vertical_scrolling
    lda #$40                                ; a = #$40
    sta SUPERTILE_NAMETABLE_OFFSET          ; set to nametable 1 (#$40)
    jsr load_next_supertiles_screen_indexes ; load the super tile indexes for the upcoming screen into memory at LEVEL_SCREEN_SUPERTILES
    lda #$00                                ; a = #$00
    rts

; init_lvl_nametable_animation - indoor level
@indoor_level:
    jsr load_column_of_tiles_to_cpu_buffer
    jsr write_col_attribute_to_cpu_memory  ; write a column of attribute palette data (#$07 bytes) to the CPU graphics buffer
    inc PPU_WRITE_ADDRESS_LOW_BYTE
    inc PPU_WRITE_TILE_OFFSET
    dec LEVEL_TRANSITION_TIMER
    rts

; handles scrolling for the level if currently scrolling
; including writing tiles to nametable, writing to the attribute table, and loading alternate graphics
; includes handling auto scroll from boss reveal or tank
handle_scroll:
    lda LEVEL_SCROLLING_TYPE     ; 0 = horizontal, indoor/base; 1 = vertical
    beq @handle_horizontal_level ; handle horizontal level
    jmp handle_vertical_scroll   ; vertical level, jump

@handle_horizontal_level:
    lda LEVEL_LOCATION_TYPE   ; 0 = outdoor; 1 = indoor
    beq @handle_outdoor_level ; branch for outdoor level
    jmp handle_indoor_scroll  ; indoor level, handle scrolling while advancing to next screen
                              ; when not scrolling, this method animates the electric fence

@handle_outdoor_level:
    lda AUTO_SCROLL_TIMER_01   ; see if auto scrolling enabled to reveal boss
    beq @check_scroll_timer_00 ; branch if auto scrolling 01 not set, check boss reveal auto scroller
    dec AUTO_SCROLL_TIMER_01   ; decrement auto scrolling timer
    bne @set_scroll_frame      ; branch if timer still hasn't elapsed

@check_scroll_timer_00:
    lda AUTO_SCROLL_TIMER_00      ; see if auto scrolling enabled to reveal boss
    beq @include_tank_auto_scroll ; branch if auto scrolling not set
    dec AUTO_SCROLL_TIMER_00      ; decrement auto scrolling timer
    bne @set_scroll_frame         ; branch if timer still hasn't elapsed, to continue screen scroll
    inc BOSS_AUTO_SCROLL_COMPLETE ; set boss reveal auto-scroll completed

; scroll screen for this video frame
@set_scroll_frame:
    lda #$01         ; a = #$01
    sta FRAME_SCROLL ; how much to scroll the screen (#00 - no scroll)

@include_tank_auto_scroll:
    lda FRAME_SCROLL     ; how much to scroll the screen (#00 - no scroll)
    clc                  ; clear carry in preparation for addition
    adc TANK_AUTO_SCROLL ; auto scroll additional amount, always add this value to scroll
    beq @exit            ; exit if no scrolling is required
    sta $17              ; set in memory frame scroll value (including tank auto scroll)

; sets alternative graphics loading flag if on correct screen
; loads alternate graphics if necessary
; then checks if need to move to next screen
@set_scroll_graphics_data:
    inc LEVEL_SCREEN_SCROLL_OFFSET    ; scrolling offset in pixels within screen
    bne @inc_nametable_data           ; branch if camera has scrolled scrolled within frame
    inc LEVEL_SCREEN_NUMBER           ; new screen, increment screen number
    lda LEVEL_SCREEN_NUMBER           ; load current screen number within the level
    cmp LEVEL_ALT_GRAPHICS_POS        ; compare to screen where alternate graphics should start loading
    bne @change_screen                ; skip loading alternate graphics if not at location to load them
                                      ; start preparing the new nametable data
    lda #$01                          ; at position to load alternate graphics
    sta ALT_GRAPHIC_DATA_LOADING_FLAG ; set the alternate graphics loading flag so alternate graphics will be loaded
    jsr load_alternate_graphics       ; load alternate graphics

; initialize the new nametable data: enemy screen read offset, PPUCTRL, PPU write address, attribute write address
@change_screen:
    lda #$00                     ; a = #$00
    sta ENEMY_SCREEN_READ_OFFSET ; set offset into level_xx_enemy_screen_xx table
    lda PPUCTRL_SETTINGS         ; load current PPU controller settings
    eor #$01                     ; swap to other nametable ($2000 or $2400)
    sta PPUCTRL_SETTINGS         ; update base nametable address

; handle increment graphics data write offsets and if necessary load new data to cpu buffer
@inc_nametable_data:
    lda LEVEL_SCREEN_SCROLL_OFFSET               ; scrolling offset within screen in pixels
    and #$07                                     ; keep bits .... .xxx
    bne @check_attr_update                       ; branch if not a new nametable tile column
                                                 ; to check if need to update attribute table or just exit
    jsr load_column_of_tiles_to_cpu_buffer       ; new nametable column
    inc PPU_WRITE_ADDRESS_LOW_BYTE
    inc PPU_WRITE_TILE_OFFSET
    lda PPU_WRITE_TILE_OFFSET
    cmp #$20                                     ; super-tiles are #$20 (32 decimal) pixels wide
    bcc @inc_scroll_exit                         ; branch if PPU_WRITE_TILE_OFFSET < 20
    lda SUPERTILE_NAMETABLE_OFFSET               ; load offset into CPU graphics buffer where super-tile indexes are stored for current screen
    eor #$40                                     ; flip bits .x.. ....
    sta SUPERTILE_NAMETABLE_OFFSET               ; move to other nametable (#$00 = nametable 0, #$40 = nametable 1)
    jsr load_next_next_supertiles_screen_indexes ; load the super tile indexes for the screen 2 screens ahead into memory at LEVEL_SCREEN_SUPERTILES
    lda #$00                                     ; a = #$00
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    sta PPU_WRITE_TILE_OFFSET                    ; $60 was #$1f, set back to #$00
    lda PPU_WRITE_ADDRESS_HIGH_BYTE
    eor #$04                                     ; flip bits .... .x..
    sta PPU_WRITE_ADDRESS_HIGH_BYTE
    lda ATTRIBUTE_TBL_WRITE_HIGH_BYTE            ; load current attribute table write address
    eor #$04                                     ; flip bits .... .x..
    sta ATTRIBUTE_TBL_WRITE_HIGH_BYTE            ; switch attribute table write address between $27c0 and $23c0, or $2bc0 and $2fc0

@inc_scroll_exit:
    inc HORIZONTAL_SCROLL         ; increment horizontal component of the PPUSCROLL [#$0 - #$ff]
    dec $17                       ; decrement in memory frame scroll value (including tank auto scroll)
    bne @set_scroll_graphics_data ; branch if still has scroll, this will only happen when for tank auto scroll
                                  ; otherwise done handling scroll, exit

@exit:
    rts

@check_attr_update:
    lda LEVEL_SCREEN_SCROLL_OFFSET        ; load the number of pixels into LEVEL_SCREEN_NUMBER the level has scrolled
    and #$0f                              ; keep low nibble
    cmp #$03
    bne @inc_scroll_exit                  ; branch if scroll offset doesn't end in #$03, only update attribute table every #$f pixels
    jsr write_col_attribute_to_cpu_memory ; 16 frames have scrolled, write next column of attribute palette data (#$08 bytes) to the CPU graphics buffer
    jmp @inc_scroll_exit

; vertical level
handle_vertical_scroll:
    lda AUTO_SCROLL_TIMER_00      ; load scroll to reveal boss timer
    beq @init_loop                ; branch if scroll complete
    lda #$10                      ; a = #$10
    sta BG_PALETTE_ADJ_TIMER
    lda #$01                      ; a = #$01
    sta FRAME_SCROLL              ; how much to scroll the screen (#00 - no scroll)
    dec AUTO_SCROLL_TIMER_00      ; decrement boss reveal scroll
    bne @init_loop
    inc BOSS_AUTO_SCROLL_COMPLETE ; set boss reveal auto-scroll completed

@init_loop:
    lda FRAME_SCROLL ; how much to scroll the screen (#00 - no scroll)
    beq @exit        ; exit
    sta $17          ; store frame scroll in $17

@frame_scroll_loop:
    inc LEVEL_SCREEN_SCROLL_OFFSET    ; increment scrolling offset in pixels within screen
    lda LEVEL_SCREEN_SCROLL_OFFSET
    cmp #$f0
    bcc @continue                     ; branch if a < #$f0
    lda #$00                          ; a = #$00, scroll is >= #$f0, move to next screen
    sta LEVEL_SCREEN_SCROLL_OFFSET    ; reset scrolling offset in pixels within screen
    sta ENEMY_SCREEN_READ_OFFSET      ; offset for enemy data
    inc LEVEL_SCREEN_NUMBER
    lda LEVEL_SCREEN_NUMBER           ; load current screen number within the level
    cmp LEVEL_ALT_GRAPHICS_POS        ; compare to screen where alternate graphics should start loading
    bne @continue                     ; branch if not on the screen where alternate graphics should load
    lda #$01
    sta ALT_GRAPHIC_DATA_LOADING_FLAG ; reached screen where alternate graphics should start loading, set flag
    lda #$80                          ; a = #$80
    sta BG_PALETTE_ADJ_TIMER
    jsr load_alternate_graphics

@continue:
    lda LEVEL_SCREEN_SCROLL_OFFSET          ; scrolling offset in pixels within screen
    and #$07                                ; keep bits .... .xxx
    bne @write_attribute_continue
    jsr set_vert_lvl_super_tiles
    lda PPU_WRITE_ADDRESS_LOW_BYTE
    sec                                     ; set carry flag in preparation for subtraction
    sbc #$20
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    lda PPU_WRITE_ADDRESS_HIGH_BYTE
    sbc #$00
    sta PPU_WRITE_ADDRESS_HIGH_BYTE
    dec PPU_WRITE_TILE_OFFSET
    bpl @dec_scroll_continue                ; decrement vertical scroll and continue loop
    lda SUPERTILE_NAMETABLE_OFFSET          ; load offset into CPU graphics buffer where super-tile indexes are stored for current screen
    eor #$40                                ; move to other nametable of super-tile index data
    sta SUPERTILE_NAMETABLE_OFFSET          ; move to other nametable (#$00 = nametable 0, #$40 = nametable 1)
    jsr load_next_supertiles_screen_indexes ; load the super tile indexes for the upcoming screen into memory at LEVEL_SCREEN_SUPERTILES
    lda #$1d                                ; a = #$1d
    sta PPU_WRITE_TILE_OFFSET               ; $60 decremented to #$00, reset back to #$1d
    lda #$a0                                ; a = #$a0
    sta PPU_WRITE_ADDRESS_LOW_BYTE
    lda #$23                                ; a = #$23
    sta PPU_WRITE_ADDRESS_HIGH_BYTE

@dec_scroll_continue:
    dec VERTICAL_SCROLL ; vertical scroll offset
    lda VERTICAL_SCROLL ; vertical scroll offset
    cmp #$ff
    bne @continue_loop
    lda #$ef            ; a = #$ef
    sta VERTICAL_SCROLL ; vertical scroll offset

@continue_loop:
    dec $17                ; decrement FRAME_SCROLL
    bne @frame_scroll_loop

@exit:
    rts

@write_attribute_continue:
    lda LEVEL_SCREEN_SCROLL_OFFSET        ; scrolling offset in pixels within screen
    and #$0f                              ; keep bits .... xxxx
    cmp #$07
    bne @dec_scroll_continue
    jsr write_row_attribute_to_cpu_memory ; write a row of attribute palette data (#$08 bytes) to the CPU graphics buffer
    jmp @dec_scroll_continue

; handle_scroll - indoor level
; handle scrolling, including animating the electric fence
handle_indoor_scroll:
    lda INDOOR_SCREEN_CLEARED                  ; indoor screen cleared flag (0 = not cleared; 1 = cleared, #$80 = cleared and fence removed)
    bpl @animate_indoor_fence                  ; branch if flag is #$80, indicating that the electric fence needs to be animated/removed
    lda LEVEL_TRANSITION_TIMER                 ; load remaining animation timer for player advancing to next screen
    bmi @indoor_screen_transition              ; jump if LEVEL_TRANSITION_TIMER is negative (couldn't get this to happen)
    bne @write_column_tiles_exit               ; branch if the player is advancing and the background needs to update
    lda INDOOR_SCROLL                          ; player isn't advancing, see if scrolling (0 = not scrolling; 1 = scrolling, 2 = finished scrolling)
    beq @exit                                  ; exit if not scrolling
    lda #$00                                   ; player has pressed up and screen is now 'scrolling' as player advances
                                               ; begin advancing background animation
    sta PPU_WRITE_TILE_OFFSET                  ; initialize PPU_WRITE_TILE_OFFSET to #$00
    sta PPU_WRITE_ADDRESS_LOW_BYTE             ; initialize PPU_WRITE_ADDRESS_LOW_BYTE to #$00
    sta $66                                    ; !(UNUSED) not sure of use, only ever set to #$00 or #$c0, never read
    lda #$20
    sta LEVEL_TRANSITION_TIMER                 ; set initial advancing animation timer to #$20
    lda PPU_WRITE_ADDRESS_HIGH_BYTE
    eor #$04                                   ; flip bits .... .x..
    sta PPU_WRITE_ADDRESS_HIGH_BYTE
    lda ATTRIBUTE_TBL_WRITE_HIGH_BYTE          ; load current attribute table write address
    eor #$04                                   ; flip bits .... .x..
    sta ATTRIBUTE_TBL_WRITE_HIGH_BYTE          ; switch attribute table write address between $27c0 and $23c0, or $2bc0 and $2fc0
    lda LEVEL_SCREEN_NUMBER                    ; load current screen number within the level
    cmp LEVEL_ALT_GRAPHICS_POS                 ; compare to screen where alternate graphics should start loading
    bne @load_supertiles_screen_indexes_indoor
    lda LEVEL_SCREEN_SCROLL_OFFSET             ; on screen where alternate graphics should load, load scrolling offset in pixels within screen
    cmp #$03
    bne @load_supertiles_screen_indexes_indoor
    ldy #$00                                   ; y = #$00

; load the graphics data for the indoor boss screen
@loop:
    lda level_2_4_boss_graphics_data,y
    sta LEVEL_SCREEN_SUPERTILES_PTR,y    ; depending on Y offset actually offsets one of the 3
                                         ; LEVEL_SCREEN_SUPERTILES_PTR, LEVEL_SUPERTILE_DATA_PTR, LEVEL_SUPERTILE_PALETTE_DATA
    iny
    cpy #$06
    bne @loop
    lda CURRENT_LEVEL                    ; current level
    lsr
    bcs @load_screen_a_supertile_indexes ; branch if odd level, i.e. indoor/base, energy zone, or alien's lair
                                         ; I believe this is only called in indoor/base boss context, so this always branches

@load_supertiles_screen_indexes_indoor:
    lda LEVEL_SCREEN_NUMBER        ; load current screen number within the level
    asl
    asl
    sec                            ; set carry flag
    adc LEVEL_SCREEN_SCROLL_OFFSET ; scrolling offset in pixels within screen

; input
;  * a - index into the screen_supertile_ptr_table table
@load_screen_a_supertile_indexes:
    jsr load_supertiles_screen_indexes ; decompress and load super-tile indexes into LEVEL_SCREEN_SUPERTILES

@write_column_tiles_exit:
    jsr load_column_of_tiles_to_cpu_buffer
    jsr write_col_attribute_to_cpu_memory  ; write a column of attribute palette data (#$07 bytes) to the CPU graphics buffer
    inc PPU_WRITE_TILE_OFFSET
    inc PPU_WRITE_ADDRESS_LOW_BYTE
    dec LEVEL_TRANSITION_TIMER             ; subtract 1
    bne @exit                              ; exit if not #$00
    lda #$80
    sta LEVEL_TRANSITION_TIMER             ; reset LEVEL_TRANSITION_TIMER to #$80

@exit:
    rts

; update pattern table tiles to animate electric fence
@animate_indoor_fence:
    jmp animate_indoor_fence

; player has cleared the screen and finished advancing, swap active nametable
@indoor_screen_transition:
    lda #$00                       ; a = #$00
    sta LEVEL_TRANSITION_TIMER     ; init to #$00
    inc INDOOR_SCROLL              ; set INDOOR_SCROLL to #$02
    inc LEVEL_SCREEN_SCROLL_OFFSET ; increment which of the #$04 screens are showing while advancing
    lda LEVEL_SCREEN_SCROLL_OFFSET ; load which animation screen is being shown [#$00-#$03]
    cmp #$04                       ; see if have shown all #$04 of the backgrounds while advancing to next indoor screen
    bne @swap_base_nametable       ; swap to next screen for advancing animation
    inc INDOOR_PLAYER_JUMP_FLAG    ; finished advancing into next indoor screen, set player to jump
    inc INDOOR_PLAYER_JUMP_FLAG+1  ; set player 2 to jump (if no player 2, this isn't used)
    lda #$00                       ; a = #$00
    sta INDOOR_SCREEN_CLEARED      ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
    sta LEVEL_SCREEN_SCROLL_OFFSET ; scrolling offset in pixels within screen
    sta ENEMY_SCREEN_READ_OFFSET
    inc LEVEL_SCREEN_NUMBER
    lda LEVEL_SCREEN_NUMBER        ; load current screen number within the level
    cmp LEVEL_STOP_SCROLL          ; compare to the screen to stop scrolling on
    bne @continue
    lda #$80                       ; a = #$80
    sta LEVEL_LOCATION_TYPE        ; overwrite level location type with #$80 (no longer specifies indoor vs outdoor)
    jsr load_alternate_graphics
    jsr init_APU_channels
    lda CURRENT_LEVEL              ; current level
    lsr
    ora #$08                       ; set bits .... x...
    jsr load_A_offset_graphic_data ; load graphic data code 08 or 09
    lda #$42                       ; a = #$42 (sound_42)
    jsr play_sound                 ; play indoor/base boss screen music
    lda #$b1                       ; a = #$b1
    sta PPUCTRL_SETTINGS
    lda #$e0                       ; a = #$e0
    sta VERTICAL_SCROLL            ; set vertical scroll offset to match outdoor levels (#$e0)

@continue:
    lda #$0c                       ; a = #$0c
    sta BG_PALETTE_ADJ_TIMER       ; set fade-in effect timer for boss screen
    lda #$20                       ; a = #$20
    jsr load_palettes_color_to_cpu ; load #$20 palette colors into PALETTE_CPU_BUFFER based on LEVEL_PALETTE_INDEX

@swap_base_nametable:
    lda PPUCTRL_SETTINGS
    eor #$01             ; flip bits .... ...x
    sta PPUCTRL_SETTINGS
    rts

; pointer table for indoor level boss header changes ($03 * $02 = $06 bytes)
; bank 2 and 3 labels
level_2_4_boss_graphics_data:
    .addr level_2_4_boss_supertiles_screen_ptr_table ; bank 2 - super-tiles per screen (LEVEL_SCREEN_SUPERTILES_PTR) - CPU address $9013
    .addr level_2_4_boss_supertile_data              ; bank 3 - super-tile pattern table tiles (LEVEL_SUPERTILE_DATA_PTR) - CPU address $b57a
    .addr level_2_4_boss_palette_data                ; bank 3 - super-tile palette data (LEVEL_SUPERTILE_PALETTE_DATA) - CPU address $bd7a

; populates the CPU_GRAPHICS_BUFFER with #$1c pattern table tiles (one column) from the super-tiles
; since vram_address_increment is 1, this represents a single column of the nametable
; it takes multiple frames to write the entire nametable to the GPU
load_column_of_tiles_to_cpu_buffer:
    ldx GRAPHICS_BUFFER_OFFSET      ; load the offset into CPU_GRAPHICS_BUFFER
    lda #$02                        ;
    sta CPU_GRAPHICS_BUFFER,x       ; set vram_address_increment offset to #$02 (value #$04) (increment by #$20 (write nametable tiles in a column fashion top to bottom))
    lda #$1c                        ; #$1c (28 decimal) pattern table tiles (a full column of tiles for the screen)
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; set the size of graphics that will be written to PPU to #$1c (28 in decimal, one column of tiles)
    lda #$01                        ; a = #$01
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; set the number of #1c-sized blocks that will be written to #$01 (only writing one column)
    lda PPU_WRITE_ADDRESS_HIGH_BYTE ; load high byte of PPU write address
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; set high byte of PPU write address
    sta $12                         ; store high  byte into $12
    lda PPU_WRITE_ADDRESS_LOW_BYTE  ; load low byte of PPU write address
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; set low byte of PPU write address
    inx
    ldy #$ff                        ; y = #$ff
    lsr                             ; shift right the low byte of the PPU write address moving lsb to carry flag
    bcs @odd_nametable_column       ; branch if low byte of PPU write address is odd (collision is only set on every other column)
                                    ; setting up $12 and $13 to for later when configuring collision, which only looks at every other pattern tile column
    sta $13                         ; low byte was even, store shifted (halved) byte address in $13 directly
    lsr $12                         ; shift high byte right
    lsr $12                         ; shift high byte right
    lsr $12                         ; shift high byte right
    ror                             ; shift a register high byte right, pulling in carry if set
    lsr                             ; shift a register high byte right
    sta $12                         ; store new high byte back into $12, this is now the BG_COLLISION_DATA write offset
    lda $13                         ; load PPU write address low byte
    and #$03                        ; keep bits .... ..xx (0 to 3)
    sta $13                         ; numbering every other column (0 to 3 in a loop) since PPU write address was shifted to the right
    ldy #$00                        ; y = #$00

@odd_nametable_column:
    sty $11                        ; #$ff for odd nametable columns, #$00 for even, used to determine if collision setting is necessary
    lda PPU_WRITE_TILE_OFFSET
    and #$03                       ; keep bits .... ..xx
    sta $02
    lda PPU_WRITE_TILE_OFFSET
    lsr
    lsr
    ora SUPERTILE_NAMETABLE_OFFSET ; merge with nametable offset (#$00 = nametable 0, #$40 = nametable 1) where super-tile indexes are stored for current screen
    sta $10                        ; score LEVEL_SCREEN_SUPERTILES offset into $10
    tay                            ; y is the LEVEL_SCREEN_SUPERTILES offset

; * loads level super-tiles from PRG ROM bank 2 by CPU address LEVEL_SCREEN_SUPERTILES
;   - looped through until all tiles for a single column have been written
;   - ultimately is called 4 times for each super-tile because each time renders only 1 column of pattern table tiles for the super-tile
; * updates the in-memory background collision (BG_COLLISION_DATA) information (set_tile_collision)
; #$37 super-tiles per screen for horizontal levels
; #$40 super-tiles per screen for vertical levels
; input
;  * y - is the LEVEL_SCREEN_SUPERTILES offset (level_X_supertiles_screen_XX)
;  * $03 - is the column offset of the super-tile to write to CPU_GRAPHICS_BUFFER block (currently drawing column)
; CPU address #$df48
load_level_supertile_data:
    lda #$00                       ; initialize LEVEL_SUPERTILE_DATA_PTR read offset
    sta $08                        ; reset offset into level super-tile pointer table
    lda LEVEL_SCREEN_SUPERTILES,y  ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    asl                            ; each super-tile is #$10 in size so need to double offset 4 times
    asl
    rol $08                        ; keep track of how many times A overflows
    asl
    rol $08
    asl
    rol $08
    adc LEVEL_SUPERTILE_DATA_PTR   ; add read address into level_X_SUPERTILE_data to get to correct super-tile
    sta $00                        ; store the low byte to level super-tile data
    lda $08                        ; load read offset
    adc LEVEL_SUPERTILE_DATA_PTR+1 ; add number of overflows to the high byte of the pointer table address
    sta $01                        ; store high byte to level super-tile data
    ldy $02                        ; level the super-tile data byte offset of the tiles that will be drawn (which column of super-tile will be drawn)
    lda ($00),y                    ; load the level's super-tile y-th pattern table tile byte (level_X_SUPERTILE_data)
    sta CPU_GRAPHICS_BUFFER,x      ; write first pattern table tile from super-tile data to CPU memory
    jsr set_tile_collision         ; set the tile collision for the top portion of the entire super-tile in BG_COLLISION_DATA
    inx                            ; increment CPU write offset
    iny
    iny
    iny
    iny                            ; increment CPU read offset by 4 total
    lda ($00),y                    ; read next pattern table tile of the super-tile one row down (level_X_SUPERTILE_data)
    sta CPU_GRAPHICS_BUFFER,x      ; write first byte of second quadrant of super-tile to CPU memory
    inx                            ; increment CPU write offset
    iny
    iny
    iny
    iny
    lda ($00),y                    ; read next pattern table tile of the super-tile one row down (level_X_SUPERTILE_data)
    sta CPU_GRAPHICS_BUFFER,x      ; write to CPU memory
    jsr set_tile_collision         ; set tile collision data for middle row of super-tile
    inx                            ; increment CPU write offset
    iny
    iny
    iny
    iny
    lda ($00),y                    ; read one tile of last row of the super-tile (level_X_SUPERTILE_data)
    sta CPU_GRAPHICS_BUFFER,x      ; write first byte of last quadrant of super-tile to CPU memory
    inx                            ; increment CPU write offset
    lda $10                        ; load the number of horizontal pixels for the row that have been loaded
    clc                            ; clear carry in preparation for addition
    adc #$08                       ; add #$08 (each pattern table entry is #$08 pixels wide and tall)
    sta $10                        ; add updated
    tay                            ; A is nth super-tile to load for the column for the screen
    and #$3f                       ; keep bits ..xx xxxx
    cmp #$38
    bcc load_level_supertile_data  ; load next tile to CPU_GRAPHICS_BUFFER if < #$38 (horizontal levels have #$37 super-tiles)
    stx GRAPHICS_BUFFER_OFFSET     ; keep track of where in CPU_GRAPHICS_BUFFER buffer to write pattern table tiles
    rts                            ; go back to load_column_of_tiles_to_cpu_buffer

; vertical level - writing pattern tiles for super-tiles
set_vert_lvl_super_tiles:
    ldx GRAPHICS_BUFFER_OFFSET      ; index for PPU background tile
    lda #$01                        ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x       ; set vram_address_increment (write across)
    sta CPU_GRAPHICS_BUFFER+2,x     ; set length of data to #$01 byte
    lda #$20                        ; a = #$20
    inx                             ; increment graphics buffer write offset
    sta CPU_GRAPHICS_BUFFER,x       ; store #$20 #$01-byte groups
    inx                             ; increment graphics buffer write offset
    lda PPU_WRITE_ADDRESS_HIGH_BYTE ; load write address high byte
    inx                             ; increment graphics buffer write offset
    sta CPU_GRAPHICS_BUFFER,x       ; write the PPU write address high byte
    lda PPU_WRITE_ADDRESS_LOW_BYTE  ; load write address low byte
    inx                             ; increment graphics buffer write offset
    sta CPU_GRAPHICS_BUFFER,x       ; write the next byte of the PPU write low address
    inx                             ; increment graphics buffer write offset
    lda #$00                        ; a = #$00
    sta $11
    sta $13
    lda PPU_WRITE_TILE_OFFSET       ; load current super-tile data write offset
                                    ; starts with #$1d goes down to #$00 before looping
    and #$03                        ; keep bits .... ..xx
    asl
    asl
    sta $02                         ; byte offset into the super-tile
    lda PPU_WRITE_TILE_OFFSET
    and #$1c                        ; keep bits ...x xx..
    asl
    ora SUPERTILE_NAMETABLE_OFFSET  ; merge with nametable offset (#$00 = nametable 0, #$40 = nametable 1) where super-tile indexes are stored for current screen
    sta $10
    lda PPU_WRITE_TILE_OFFSET
    lsr
    ror $11
    asl
    asl
    sta $12                         ; store PPU write address high byte into $12
    ldy $10

@set_supertile_tiles:
    lda #$00                       ; a = #$00
    sta $08
    lda LEVEL_SCREEN_SUPERTILES,y  ; read byte specifying which super-tile to load
                                   ; decompressed level_X_supertiles_screen_XX data
    asl
    asl
    rol $08
    asl
    rol $08
    asl                            ; 4 total asl instructions since each super-tile is #$10 bytes
    rol $08
    adc LEVEL_SUPERTILE_DATA_PTR   ; (bank 3 pointer)
    sta $00
    lda $08
    adc LEVEL_SUPERTILE_DATA_PTR+1 ; add the high byte of the pointer address
    sta $01
    ldy $02
    lda ($00),y
    sta CPU_GRAPHICS_BUFFER,x
    jsr set_tile_collision         ; set BG_COLLISION_DATA to tile collision code (0-3) for the pattern table tile
    inx                            ; increment graphics buffer write offset
    iny                            ; increment graphics data read offset
    lda ($00),y
    sta CPU_GRAPHICS_BUFFER,x
    inx                            ; increment graphics buffer write offset
    iny                            ; increment graphics data read offset
    lda ($00),y
    sta CPU_GRAPHICS_BUFFER,x
    jsr set_tile_collision         ; set BG_COLLISION_DATA to tile collision code (0-3) for the pattern table tile
    inx                            ; increment graphics buffer write offset
    iny                            ; increment graphics data read offset
    lda ($00),y
    sta CPU_GRAPHICS_BUFFER,x
    inx                            ; increment graphics buffer write offset
    inc $10
    lda $10
    tay
    and #$07                       ; keep bits .... .xxx
    bne @set_supertile_tiles
    stx GRAPHICS_BUFFER_OFFSET
    rts

; write a column of attribute palette data (#$07 bytes) to the CPU graphics buffer
write_col_attribute_to_cpu_memory:
    ldx GRAPHICS_BUFFER_OFFSET     ; load the current tile to draw to the PPU
    lda #$01                       ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x      ; set vram_address_increment (write across)
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    sta CPU_GRAPHICS_BUFFER,x      ; set length of data to #$01 byte
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    lda #$07                       ; a = #$07
    sta CPU_GRAPHICS_BUFFER,x      ; specifying to store #$07 #$01-byte groups (the column of super-tile palette data)
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    lda PPU_WRITE_TILE_OFFSET      ; load the current PPU tile offset being written to CPU memory
    lsr
    lsr                            ; only care about which column of super-tile is active
    ora #$c0                       ; set bits xx.. ....
                                   ; e.g. #$08 -> #$c2, which means the 3rd attribute table column
    sta $00                        ; store current attribute table low byte to $00 in range from #$c0 up to #$ff inclusively
    and #$0f                       ; keep low nibble
    ora SUPERTILE_NAMETABLE_OFFSET ; merge with nametable offset (#$00 = nametable 0, #$40 = nametable 1) where super-tile indexes are stored for current screen
                                   ; e.g. #$c2 -> #$42
    sta $10                        ; set super-tile address into cpu graphics buffer that contains the attribute data to write (offset from $0600 (LEVEL_SCREEN_SUPERTILES))
    tay                            ; transfer super-tile index to render to y (level_X_supertiles_screen_XX)

; write palette data to CPU_GRAPHICS_BUFFER for use to write in attribute table
; writes an entire columned of super-tiles' palette attribute data (#$08 bytes)
@set_supertile_attribute_byte:
    lda ATTRIBUTE_TBL_WRITE_HIGH_BYTE    ; load current attribute table write address high byte
    sta CPU_GRAPHICS_BUFFER,x            ; set PPU high write address to correct attribute table
    inx                                  ; increment CPU_GRAPHICS_BUFFER write offset
    lda $00                              ; load the current attribute table low write byte (#$c0 up to #$ff inclusively)
    sta CPU_GRAPHICS_BUFFER,x            ; store low byte of PPU address
    inx                                  ; increment CPU_GRAPHICS_BUFFER write offset
    lda LEVEL_SCREEN_SUPERTILES,y        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    tay                                  ; transfer super-tile index into y register
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load the palette for the super-tile (one entry in attribute table)
    sta CPU_GRAPHICS_BUFFER,x            ; write the palette byte to graphics buffer, this will be written to the attribute table
    inx                                  ; increment CPU_GRAPHICS_BUFFER write offset
    lda $00                              ; load the current attribute table low write byte (#$c0 up to #$ff inclusively)
    clc                                  ; clear carry in preparation for addition
    adc #$08                             ; add #$08 to the current attribute table write low byte
                                         ; this moves to the next super-tile in the column (move down one row)
    sta $00                              ; set new attribute table write address low byte
    cmp #$f8                             ; see if on last attribute table entry
    bcs @exit                            ; branch if attribute entry >= #$f8
                                         ; contra doesn't write palette data for the last half super-tile attribute row (for non-vertical levels)
                                         ; this area isn't usually rendered on CRTs and when emulated
    lda $10                              ; load current super-tile to render
    adc #$08                             ; add #$08 to render the next supertile down
    sta $10                              ; store next super-tile to render
    tay
    bcc @set_supertile_attribute_byte    ; loop if more palette data in column to write to attribute table

@exit:
    stx GRAPHICS_BUFFER_OFFSET ; restore x to the graphics buffer write offset
    rts

; write a row of attribute palette data (#$08 bytes) to the CPU graphics buffer
; for vertical level (waterfall) only
write_row_attribute_to_cpu_memory:
    ldx GRAPHICS_BUFFER_OFFSET     ; load the current tile to draw to the PPU
    lda #$01                       ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x      ; set vram_address_increment to #$01
    sta CPU_GRAPHICS_BUFFER+2,x    ; set number of length of graphics blocks to #$01
    lda #$08                       ; a = #$08
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    sta CPU_GRAPHICS_BUFFER,x      ; set number of #01-byte-long groups to #$08
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    lda #$23                       ; a = #$23
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    sta CPU_GRAPHICS_BUFFER,x      ; set high byte of PPU write address to #$23
    lda PPU_WRITE_TILE_OFFSET
    asl
    and #$38                       ; keep bits ..xx x...
    ora SUPERTILE_NAMETABLE_OFFSET ; merge with nametable offset (#$00 = nametable 0, #$40 = nametable 1) where super-tile indexes are stored for current screen
    sta $10                        ; set super-tile address into cpu graphics buffer that contains the attribute data to write (offset from $0600 (LEVEL_SCREEN_SUPERTILES))
    and #$bf                       ; strip bit 6
    clc                            ; clear carry in preparation for addition
    adc #$c0                       ; attribute table low byte starts at #$c0, add #$c0 to get actual initial attribute address for row
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset
    sta CPU_GRAPHICS_BUFFER,x      ; set low byte of PPU write address
    inx                            ; increment CPU_GRAPHICS_BUFFER write offset

@set_supertile_attribute_byte:
    lda PPU_WRITE_TILE_OFFSET              ; load the current row being written
    and #$03                               ; keep bits .... ..xx
    cmp #$03                               ; every #$04 rows take the palette from the bottom super-tile and
                                           ; merge with top palette from other nametable super-tile
    beq @merge_supertiles_across_nametable
    lda $10                                ; load super-tile address into cpu graphics buffer that contains the attribute data to write (offset from $0600 (LEVEL_SCREEN_SUPERTILES))
    tay                                    ; transfer to offset register
    lda LEVEL_SCREEN_SUPERTILES,y          ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    tay                                    ; transfer super-tile index to offset register
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y   ; load the palette for the super-tile

@write_supertile_palette_to_cpu:
    sta CPU_GRAPHICS_BUFFER,x         ; set palette in attribute table for nametable
    inx                               ; increment CPU_GRAPHICS_BUFFER write offset
    inc $10                           ; move to next super-tile index
    lda $10
    and #$07                          ; strip to low nibble to see how many super-tile palette attribute bytes have been written
    bne @set_supertile_attribute_byte ; loop until all palette attribute table entries are written for the row
    stx GRAPHICS_BUFFER_OFFSET        ; finished writing attributes, restore x to the graphics buffer write offset
    rts

; used to get correct palette for supertile when it spreads across a nametable
@merge_supertiles_across_nametable:
    lda $10                              ; load super-tile address into cpu graphics buffer that contains the attribute data to write (offset from $0600 (LEVEL_SCREEN_SUPERTILES))
    tay                                  ; transfer to offset register
    lda LEVEL_SCREEN_SUPERTILES,y        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    tay                                  ; transfer super-tile index to offset register
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load the palette data for the super-tile
    and #$f0                             ; keep lower half palette data for the super-tile
    sta $11                              ; store lower half palette data of the super-tile
    lda $10                              ; load super-tile address into cpu graphics buffer that contains the attribute data to write (offset from $0600 (LEVEL_SCREEN_SUPERTILES))
    eor #$40                             ; move to other nametable
    tay                                  ; transfer super-tile index to offset register
    lda LEVEL_SCREEN_SUPERTILES,y        ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    tay                                  ; transfer super-tile index to offset register
    lda (LEVEL_SUPERTILE_PALETTE_DATA),y ; load the palette data for the super-tile
    and #$0f                             ; keep upper half palette data for the super-tile
    ora $11                              ; merge with lower half of super-tile palette data to get full super-tile palette data
    jmp @write_supertile_palette_to_cpu

; determine tile collision code (0-3) for the pattern table tile updates BG_COLLISION_DATA
; input
;  * a - nametable tile code from the super-tile
;  * y - level nametable tile offset (level_X_SUPERTILE_data offset)
; tile code 0 is always set to collision code 0
set_tile_collision:
    sty $14                         ; store super-tile tile data read offset in $14 (LEVEL_SUPERTILE_DATA_PTR offset)
    ldy $11                         ; if $11 is set, then odd number nametable column, and collision isn't considered
    bne tile_collision_exit         ; exit if $11 is set
    tay                             ; move the pattern table tile code to Y
    beq set_collision_code_0        ; tile index is #$00, set to collision code 0 (empty)
                                    ; tile index #$00 is always collision code #$0
    cmp COLLISION_CODE_1_TILE_INDEX ; compare against collision code 1 tile index
    bcs collision_code_0_check      ; branch if pattern table tile is not collision code 1, check to see if collision code 0
    lda #$01                        ; set collision code to 1 (floor)
    bne collision_continue          ; continue

; check if empty collision code
collision_code_0_check:
    cmp COLLISION_CODE_0_TILE_INDEX
    bcs collision_code_2_check      ; tile index is greater than collision code 0 limit, check if collision code 2

set_collision_code_0:
    lda #$00               ; set collision code to 0 (empty)
    beq collision_continue

; check if water collision code
collision_code_2_check:
    cmp COLLISION_CODE_2_TILE_INDEX
    bcs set_collision_code_03       ; tile index offset is greater than collision code 2 limit
    lda #$02                        ; set collision code to 2 (water)
    bne collision_continue

; check if solid collision code
set_collision_code_03:
    lda #$03 ; set collision code to 03 (solid)

; register a contains the collision code
; handles storing the collision 2-bits for the 1/4 of the super-tile in the correct memory address
collision_continue:
    ldy $13                      ; load low byte of PPU write address (masked to 0 to 3)
    bne set_collision_tile_col_2 ; jump if odd column of screen write address
    asl
    asl
    asl
    asl
    asl
    asl                          ; shift the collision code (2 bits) all the way to the left 2 bits
    sta $15                      ; store modified collision code for super-tile into $15
    ldy $12                      ; load BG_COLLISION_DATA write offset
    lda BG_COLLISION_DATA,y      ; load existing collision byte (each byte contains collision data for 2 super-tiles)
    and #$3f                     ; keep bits ..xx xxxx, which will be merged with the modified collision code in $15
    jmp set_collision_tile       ; save the updated collision information in CPU memory

set_collision_tile_col_2:
    dey                          ; see if second column by subtracting stored write offset
    bne set_collision_tile_col_3 ; if not the second column, branch to see if 3rd or 4th
    asl
    asl
    asl
    asl                          ; shift the collision code (2 bits) all the way to the bits 5 and 4 (..xx ....)
    sta $15                      ; store shifted collision code for super-tile into $15
    ldy $12                      ; load BG_COLLISION_DATA write offset
    lda BG_COLLISION_DATA,y      ; load existing collision byte (each byte contains collision data for 2 super-tiles)
    and #$cf                     ; keep bits xx.. xxxx, which will be merged with the modified collision code in $15
    jmp set_collision_tile       ; save the updated collision information in CPU memory

set_collision_tile_col_3:
    dey                          ; see if second column by subtracting stored write offset
    bne set_collision_tile_col_4 ; if not the second column, branch to see if 4th
    asl
    asl                          ; shift the collision code (2 bits) to the bits 2 and 2 (.... xx..)
    sta $15                      ; store collision code for super-tile into $15
    ldy $12                      ; load BG_COLLISION_DATA write offset
    lda BG_COLLISION_DATA,y      ; load existing collision byte (each byte contains collision data for 2 super-tiles)
    and #$f3                     ; keep bits xxxx ..xx, which will be merged with the modified collision code in $15
    jmp set_collision_tile       ; save the updated collision information in CPU memory

set_collision_tile_col_4:
    sta $15                 ; store collision code for super-tile into $15
    ldy $12                 ; load BG_COLLISION_DATA write offset
    lda BG_COLLISION_DATA,y ; load collision code for super-tile
    and #$fc                ; keep bits xxxx xx.., which will be merged with the modified collision code in $15

; sets the already-shifted collision code in a with the masked collision code in $15 and updates the CPU memory accordingly
set_collision_tile:
    ora $15                          ; combine the BG_COLLISION_DATA,y with the shifted collision code for the super-tile
    sta BG_COLLISION_DATA,y          ; save back into CPU memory
    lda LEVEL_SCROLLING_TYPE         ; 0 = horizontal, indoor/base; 1 = vertical
    bne vert_lvl_tile_collision_exit ; jump if vertical level
    tya
    clc                              ; clear carry in preparation for addition
    adc #$04                         ; move forward 4 bytes for next super-tile
    sta $12                          ; update BG_COLLISION_DATA write offset to next tile down

tile_collision_exit:
    ldy $14
    rts     ; go back to load_level_supertile_data

vert_lvl_tile_collision_exit:
    inc $13                 ; increment low byte of PPU write address
    lda $13
    cmp #$04                ; see if finished writing all four pattern table tiles in super-tile
    bcc tile_collision_exit
    lda #$00                ; a = #$00
    sta $13
    inc $12                 ; update BG_COLLISION_DATA write offset
    bne tile_collision_exit ; should always jump since inc $12 is non-zero

; gets the collision code for (a,y) and if collision code is the floor,
; look one row (half supertile) see if collision code one row below (half supertile) is solid,
; if so, use that collision code.
; input
;  * a - x pos
;  * y - y pos
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
get_bg_collision_far:
    jsr get_bg_collision ; determine player background collision code at position (a,y)

; determines the next half supertile row's collision code below the $13 offset
; if current collision code is a floor collision, otherwise, do nothing
; input
;  * a - collision code
;  * $13 - BG_COLLISION_DATA offset
; output
;  * a - collision code of half row down
;  * carry flag - set when collision code #$80 (solid)
floor_get_next_row_bg_collision:
    pha                               ; push collision code on to stack
    bcc @exit                         ; exit if current collision code is not a floor collision
    lda $13                           ; load current BG_COLLISION_DATA offset
    sta $16                           ; store in $16
    and #$c0                          ; keep bits 6 and 7
    sta $17                           ; save result in $17
    lda $16                           ; re-load BG_COLLISION_DATA offset
    clc                               ; clear carry in preparation for addition
    adc #$04                          ; move down to next supertile half-row
    and #$3f                          ; keep bits ..xx xxxx
    ora $17                           ; merge original bits 6 and 7 back
    tay                               ; transfer BG_COLLISION_DATA offset to y
    jsr read_bg_collision_byte_unsafe ; get collision code from BG_COLLISION_DATA byte
    asl
    lda $16                           ; load previous BG_COLLISION_DATA offset
    sta $13                           ; store value in $13
    bcc @exit                         ; exit if not a solid collision
    pla                               ; solid collision, set collision code to #$80
                                      ; pop old collision code from stack
    lda #$80                          ; a = #$80
    rts

@exit:
    pla ; pop collision code from stack
    rts

; get collision code at BG_COLLISION_DATA,y and if not floor, look down one collision row and get that collision code
; input
;  * y - BG_COLLISION_DATA offset
; output
;  * a - collision code of half row down
;  * carry flag - set when collision code #$80 (solid)
find_floor_collision:
    jsr read_bg_collision_byte_unsafe   ; get collision code from BG_COLLISION_DATA byte
    jmp floor_get_next_row_bg_collision ; if floor collision, get next half supertile row's collision code
                                        ; otherwise exit

; reads the specific bits of the BG_COLLISION_DATA byte and determines the collision code
; unsafe because it hard-codes a bypass of the bg collision row check, y must be correct here
; example usage is when checking below ground player is standing on to see if player can fall through (drop down)
; input
;  * y - BG_COLLISION_DATA offset
;  * $12 - specifies which 2 bits of the BG_COLLISION_DATA byte interested in (0, 1, 2, or 3)
;          each super-tile has 4 bg collision points, 2 per bg collision row
;          one byte contains 4 bg collision points on a single row of 2 super-tiles
; output
;  * $13 - BG_COLLISION_DATA offset
;  * $14 - collision code
;  * a - collision code
;  * zero flag - set when collision code #$00 (empty)
;  * negative flag - set when collision code #$03 (solid)
;  * carry flag - set when collision code #$01 (floor)
read_bg_collision_byte_unsafe:
    lda #$00                   ; a = #$00
    sta $15                    ; used by read_bg_collision_byte as a quick way to ensure not reading past last bg collision row
                               ; this method is confident y offset (BG_COLLISION_DATA offset) is correct
    beq read_bg_collision_byte ; always branch, get collision code from BG_COLLISION_DATA byte

; input
;  * a is x pos
;  * y is y pos
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
get_bg_collision:
    sta $13 ; store x position in $13

; input
;  * $13 - x position
;  * y - y position
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
get_enemy_bg_collision:
    lda #$00               ; a = #$00
    sta $10
    beq bg_collision_logic ; always jump because a is #$00

; used for the hangar mine cart
get_cart_bg_collision:
    sta $13 ; store sprite x position in $13

; input
;  * $13 - x position
;  * y - y pos
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
bg_collision_logic:
    tya                 ; transfer y pos to a
    sta $15             ; store y pos in $15
    clc                 ; clear carry in preparation for addition
    adc VERTICAL_SCROLL ; add vertical scroll offset
    bcs @vert_overflow  ; branch if overflow
    cmp #$f0            ; didn't overflow, compare VERTICAL_SCROLL + Y to #$f0
    bcc @continue       ; branch if VERTICAL_SCROLL + Y < #$f0

@vert_overflow:
    adc #$0f ; add #$0f to vertical scroll

@continue:
    sta $11                ; store VERTICAL_SCROLL + Y in $11
    lda $13                ; load sprite x position
    clc                    ; clear carry in preparation for addition
    adc HORIZONTAL_SCROLL  ; horizontal scroll offset
    sta $12                ; store HORIZONTAL_SCROLL + X in $12
    lda PPUCTRL_SETTINGS   ; load PPUCTRL, used to get nametable value
    eor $10                ; A XOR $10 (almost always #$00)
                           ; hangar moving carts (enemy type #$14) will use $10
                           ; when moving right and checking for bg collision in opposite nametable
    and #$01               ; see if base nametable address is $2400
    bcc @bg_collision_data ; jump if no carry when adding HORIZONTAL_SCROLL to X
    eor #$01               ; if carry occurred, flip bit 0 of a

; does math to determine correct offset into BG_COLLISION_DATA
@bg_collision_data:
    tay                                  ; set level_screen_mem_offset_tbl_01 index
    lda $11                              ; load VERTICAL_SCROLL + Y
    lsr
    lsr
    and #$3c                             ; keep bits ..xx xx..
    sta $11                              ; update VERTICAL_SCROLL + Y to include nametable offset
    lda $12                              ; load HORIZONTAL_SCROLL + X
    lsr
    lsr
    lsr
    lsr
    sta $12                              ; update HORIZONTAL_SCROLL + X to include nametable offset
    lsr
    lsr
    ora $11                              ; merge with adjusted VERTICAL_SCROLL + Y
    ora level_screen_mem_offset_tbl_01,y
    tay
    lda $12                              ; load HORIZONTAL_SCROLL + X nametable offset
    and #$03                             ; keep bits .... ..xx
    sta $12                              ; set HORIZONTAL_SCROLL + X nametable offset

; reads the specific bits of the BG_COLLISION_DATA byte and determines the collision code
; input
;  * y - BG_COLLISION_DATA offset
;  * $15 - bg collision row
;  * $12 - specifies which 2 bits of the BG_COLLISION_DATA byte interested in (0, 1, 2, or 3)
;          each super-tile has 4 bg collision points, 2 per bg collision row
;          one byte contains 4 bg collision points on a single row of 2 super-tiles
; output
;  * $13 - BG_COLLISION_DATA offset
;  * $14 - collision code
;  * a - collision code
;  * negative flag - set when solid collision code
;  * carry flag - set when collision code #$01 (floor)
read_bg_collision_byte:
    sty $13                 ; store BG_COLLISION_DATA offset in $13
    lda $15                 ; load bg collision row
    cmp #$e0                ; see if past last row
    lda #$00                ; a = #$00
    bcs @set_code_exit      ; set collision code to #$00 (empty) and exit if past last bg collision row
    lda BG_COLLISION_DATA,y ; load background collision code
    ldy $12                 ; load column offset (0, 1, 2, or 3)
    beq @shift_6_bits       ; collision code stored in bits 6 and 7, shift right to 2 least significant bits
    dey
    beq @shift_4_bits       ; collision code stored in bits 4 and 5, shift right to 2 least significant bits
    dey
    beq @shift_2_bits       ; collision code stored in bits 2 and 3, shift right to 2 least significant bits
    bne @no_shift           ; collision code already in least 2 significant bits, no shift required

@shift_6_bits:
    lsr
    lsr

@shift_4_bits:
    lsr
    lsr

@shift_2_bits:
    lsr
    lsr

@no_shift:
    and #$03                        ; store the collision code in a (it's been shifted to right most bits)
    tay                             ; transfer code offset to y
    lda collision_code_lookup_tbl,y ; load collision code

@set_code_exit:
    sta $14 ; store collision code in $14
    lsr     ; set carry if collision code is floor (#$01)
    lda $14 ; set a register to collision code
    rts

; the base offset into cpu graphics buffer where super-tile indexes are loaded (LEVEL_SCREEN_SUPERTILES)
; $0600 or $0640
level_screen_mem_offset_tbl_01:
    .byte $00,$40

collision_code_lookup_tbl:
    .byte $00,$01,$02,$80

; starts the auto scroll to reveal heart if at right screen, otherwise do nothing
; output
;  * a - LEVEL_SCREEN_NUMBER when boss auto scroll not set
;        #$00 when boss auto scroll already set, or just set
;        #$01 when boss already defeated
set_boss_auto_scroll:
    lda BOSS_DEFEATED_FLAG         ; 0 = boss not defeated, 1 = boss defeated
    bne @exit                      ; exit if boss is already defeated
    lda LEVEL_STOP_SCROLL          ; load the screen to stop scrolling on, set to #$ff when boss auto scroll starts
    bmi @exit_mark_scroll_enabled  ; exit if auto scroll has already started
    cmp LEVEL_SCREEN_NUMBER        ; screen number
    bne @exit                      ; exit if not on the appropriate screen to start auto scroll
    ldy LEVEL_SCROLLING_TYPE       ; 0 = horizontal, indoor/base; 1 = vertical
    lda LEVEL_SCREEN_SCROLL_OFFSET ; load the number of pixels into LEVEL_SCREEN_NUMBER the level has scrolled
    cmp scroll_trigger_tbl,y       ; compare to scroll trigger point
    bcc @exit                      ; exit if not yet at spot to trigger auto scroll
    lda auto_scroll_timer_tbl,y    ; load the appropriate auto scroll timer for the level
    sta AUTO_SCROLL_TIMER_00       ; start auto scroll to reveal the boss
    lda #$ff                       ; LEVEL_STOP_SCROLL is #$ff when auto scroll has started
    sta LEVEL_STOP_SCROLL          ; mark that boss auto scroll has started (LEVEL_STOP_SCROLL = #$ff)

@exit_mark_scroll_enabled:
    lda #$00 ; a = #$00

@exit:
    rts

; table for offset into screen before initiating auto scroll to show boss ($04 bytes)
; byte 0 - horizontal level
; byte 1 - vertical level
scroll_trigger_tbl:
    .byte $a0,$c0

; the amount of time to auto scroll for the end of level
; byte 0 - horizontal level
; byte 1 - vertical level
auto_scroll_timer_tbl:
    .byte $60,$40

; screen load
load_next_next_supertiles_screen_indexes:
    lda LEVEL_SCREEN_NUMBER            ; load current screen number within the level
    clc                                ; clear carry bit
    adc #$02                           ; add #$02 to load screen in the future
    bne load_supertiles_screen_indexes ; decompress and load super-tile indexes into LEVEL_SCREEN_SUPERTILES

; load the super tile indexes for the upcoming screen into memory at LEVEL_SCREEN_SUPERTILES
load_next_supertiles_screen_indexes:
    lda LEVEL_SCREEN_NUMBER            ; load current screen number within the level
    clc                                ; clear carry in preparation for addition
    adc #$01                           ; add #$01 to load screen in the future
    bne load_supertiles_screen_indexes ; decompress and load super-tile indexes into LEVEL_SCREEN_SUPERTILES

; decompresses super-tiles of the current level's current screen to load into CPU memory at LEVEL_SCREEN_SUPERTILES
load_current_supertiles_screen_indexes:
    lda LEVEL_SCREEN_NUMBER ; load current screen number within the level
                            ; to know which super-tiles to load

; CPU address $e16b
; decompresses and loads super-tile indexes into LEVEL_SCREEN_SUPERTILES (level_x_supertiles_screen_ptr_table)
; read
; input
;  * a - index into the screen_supertile_ptr_table table, i.e. the screen number to load
load_supertiles_screen_indexes:
    asl                                 ; double since each entry is a 2-byte address
    tax                                 ; save the index before jump to load_bank_number subroutine
    ldy #$02                            ; tell load_bank_number to load bank 2
    jsr load_bank_number                ; load bank 2
    txa                                 ; restore screen_supertile_ptr_table offset
    tay                                 ; move screen_supertile_ptr_table offset to Y
    lda (LEVEL_SCREEN_SUPERTILES_PTR),y ; grab low-byte of pointer to level screen super-tiles (from bank 2)
                                        ; level_x_supertiles_screen_ptr_table
    sta $00                             ; store in $00
    iny                                 ; increment LEVEL_SCREEN_SUPERTILES_PTR read offset
    lda (LEVEL_SCREEN_SUPERTILES_PTR),y ; grab high-byte of level graphic data location
    sta $01                             ; store in $01
    ldy #$00                            ; clear y
    ldx SUPERTILE_NAMETABLE_OFFSET      ; CPU graphic data write offset (LEVEL_SCREEN_SUPERTILES offset)

; decompresses encoded data specifying the super-tiles to display for nametable
read_supertiles_screen_ptr_table:
    lda ($00),y                   ; grab next graphic byte (encoded) (level_x_supertiles_screen_xx)
    iny                           ; increment level super tile graphic data read offset
    cmp #$80                      ; checking if most significant bit is a 1
    bcs load_rle_repeat_command   ; if A has msb set, then RLE command
    sta LEVEL_SCREEN_SUPERTILES,x ; bit 7 is not set, regular super-tile index. store index in CPU memory
    inx                           ; increment CPU write address offset

; input
;  * ($00) should point to the correct level_x_supertiles_screen_xx
;  * x - total number of tiles written to LEVEL_SCREEN_SUPERTILES memory location
;  * y - offset into specific level_x_supertiles_screen_xx to read
load_supertile_indexes_starting_at_y:
    lda LEVEL_SCROLLING_TYPE             ; load the current level scrolling type (horizontal or vertical)
    bne @vertical_level_section_end      ; if level is a vertical level, then jump
    cpx #$38                             ; screen_supertile_ptr_table data is #$38 bytes for horizontal levels
    beq @exit                            ; exit if read all #$38 super-tiles (horizontal level)
    cpx #$78                             ; 2 screens worth of super-tiles are loaded, so if started with second screen at offset #$40, stop at #$78
    bcc read_supertiles_screen_ptr_table ; jump if read less than #$78 tiles
    jmp load_previous_bank               ; read #$78 super-tiles, exit

@vertical_level_section_end:
    cpx #$40                             ; exit if read all #$40 super-tiles (horizontal level)
    beq @exit
    cpx #$80                             ; 2 screens worth of super-tiles are loaded, so if started with second screen at offset #$40, stop at #$80
    bcc read_supertiles_screen_ptr_table ; if not finished reading all super-tiles, move to next super-tile

@exit:
    jmp load_previous_bank

; read
load_rle_repeat_command:
    cmp #$f0
    bcs @set_nametable_supertile_indexes ; branch if >= #$f0
    and #$7f                             ; clear first bit
    sta $02                              ; store number of times to repeat next byte
    lda ($00),y                          ; load the byte that will be repeated
    iny                                  ; increment read offset

@repeat_level_data_byte:
    sta LEVEL_SCREEN_SUPERTILES,x            ; write level graphic byte to CPU memory
    inx                                      ; increment CPU memory write offset
    dec $02                                  ; decrement counter for number of times to repeat byte
    bne @repeat_level_data_byte              ; repeat while $02 > 0
    beq load_supertile_indexes_starting_at_y

@set_nametable_supertile_indexes:
    and #$0f                       ; grab least significant 4 bits
    asl
    asl
    asl
    ora SUPERTILE_NAMETABLE_OFFSET ; merge with nametable offset (#$00 = nametable 0, #$40 = nametable 1) where super-tile indexes are stored for current screen
    sty $03
    tay
    lda #$08                       ; load #$08 super-tiles indexes
    sta $02                        ; set super-tile index counter to $02

@supertile_index_loop:
    lda LEVEL_SCREEN_SUPERTILES,y            ; read byte specifying which super-tile to load (level_X_supertiles_screen_XX)
    sta LEVEL_SCREEN_SUPERTILES,x
    inx                                      ; increment write offset
    iny                                      ; increment read offset
    dec $02                                  ; decrement number of remaining super-tiles indexes to load
    bne @supertile_index_loop
    ldy $03
    bne load_supertile_indexes_starting_at_y

; checks if a player is colliding with the current enemy
check_players_collision:
    ldx #$01 ; x = #$01

; input
;  * x - current player to test
; loop through players and see if colliding with any enemy (including enemy bullets)
@check_player_x_collision:
    ldy ENEMY_CURRENT_SLOT       ; set y = #$enemy slot
    lda PLAYER_STATE,x           ; load player state (0 = dropping into level, 1 = normal, 2 = dead, 3 = can't move)
    cmp #$01                     ; compare to normal state
    bne @next_player             ; move to next player if current player not in normal state (falling, dead, stuck)
    lda LEVEL_LOCATION_TYPE      ; 0 = outdoor; 1 = indoor; #$80 = indoor/base boss screen
    lsr                          ; shift least significant bit into carry flag
    bcc @handle_outdoor_level    ; branch for outdoor level or indoor/base boss screen
    lda ENEMY_TYPE,y             ; indoor level, load current enemy type
    cmp #$01                     ; see if the enemy is a bullet
    bne @check_in_water_crouched ; branch if not a bullet
    lda PLAYER_SPRITE_SEQUENCE,x ; enemy is a bullet, load player animation frame
    cmp #$02                     ; see if player is crouching
    bne @check_in_water_crouched ; branch if player isn't crouched on indoor level
    beq @next_player             ; player crouching go to next player
                                 ; can't get hit by bullet when crouching on indoor level

@handle_outdoor_level:
    lda ENEMY_STATE_WIDTH,y      ; load enemy state width
    asl                          ; shift bit 7 to carry flag
    bpl @check_in_water_crouched ; branch if ENEMY_STATE_WIDTH,x bit 6 is clear (player can't land on enemy)
    asl                          ; shift bit 6 to carry flag
    bpl @check_player_jumping    ; branch if ENEMY_STATE_WIDTH,x bit 5 is clear (collision box code bit)
    lda ENEMY_Y_POS,y            ; ENEMY_STATE_WIDTH,x bit 5 set, load enemy y position on screen
    sec                          ; set carry flag in preparation for subtracting
    sbc SPRITE_Y_POS,x           ; player sprite y position on screen
    bcc @set_collision_box_code  ; branch if player below enemy
    cmp #$08                     ; player above enemy, see how close to enemy
    lda ENEMY_STATE_WIDTH,y      ; load enemy state width
    and #$ef                     ; clear bit 4 (collision box type)
    bcs @set_state_width         ; branch if farther than #$08 from enemy, to use cleared bit 4 collision code

@set_collision_box_code:
    lda ENEMY_STATE_WIDTH,y
    ora #$10                ; set bit 4 (collision box type)

@set_state_width:
    sta ENEMY_STATE_WIDTH,y
    bne @check_in_water_crouched

@check_player_jumping:
    lda PLAYER_JUMP_STATUS,x     ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    beq @check_in_water_crouched ; branch if player is not jumping
    lda PLAYER_Y_FAST_VELOCITY,x ; player is jumping, load y fast velocity
    bmi @next_player             ; move to next player if player ascending in jump for enemies with bit 5 clear of ENEMY_STATE_WIDTH
    cmp #$01                     ; player not ascending, compare y fast velocity to #$01
    bcc @next_player             ; move to next player if player y fast velocity #$00 for enemies with bit 5 clear of ENEMY_STATE_WIDTH
                                 ; !(OBS) not sure why didn't use beq here
    bcs @check_in_water_crouched ; !(OBS) conditionally branches to next line
                                 ; no matter value of condition @check_in_water_crouched will execute

@check_in_water_crouched:
    ldy #$00                       ; default collision box offset collision_box_codes_tbl (in water)
    lda PLAYER_WATER_STATE,x       ; load player in water state
    beq @set_collision_code_offset ; branch if player not in water
    lda CONTROLLER_STATE,x         ; player in water, load controller state to see if crouching
    and #$04                       ; bits .... .x.. (down button pressed)
    bne @next_player               ; player is invisible when crouching in water, don't test for collision
    beq @check_if_enemy_collision  ; player is in water, but not crouching, test collision

; player not in water
@set_collision_code_offset:
    iny                           ; y = #$1, player is jumping collision_box_codes_tbl
    lda PLAYER_JUMP_STATUS,x      ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    bne @check_if_enemy_collision ; branch if player is jumping
    iny                           ; player not jumping, increment collision box offset
    lda PLAYER_SPRITE_CODE,x      ; load player sprite
    cmp #$17                      ; compare to crouching
    beq @check_if_enemy_collision ; player animation frame is #$17 (crouching)
    iny                           ; increment if player animation frame isn't #$17

; test against correct enemy collision box depending on player state (register y)
@check_if_enemy_collision:
    jsr set_enemy_collision_box     ; set collision box in [$08-$0b] based off y register
    lda SPRITE_Y_POS,x              ; load current sprite Y position
    sec                             ; set the carry flag in preparation for subtraction
    sbc $08                         ; subtract from collision box top left y coordinate
    cmp $0a                         ; compare to height of collision box
    bcs @next_player                ; branch if player sprite is vertically outside of collision box [(SPRITE_Y_POX,x - $08) < $0a]
                                    ; this is a neat trick
                                    ;  * y is above collision box - subtraction result is negative and the carry is set since cmp thinks the value is positive
                                    ;  * y is below collision box - subtraction result is greater than height $0a and the carry is set
    lda SPRITE_X_POS,x              ; player sprite is in collision box vertically, now check horizontally
    sec                             ; set the carry flag in preparation for subtraction
    sbc $09                         ; subtract the top-left x coordinate of the collision box from the x position
    cmp $0b                         ; compare to the width of the collision box
                                    ; same neat trick applies here
                                    ;  * x is to the left of the collision box - subtraction result is negative and carry is set since cmp thinks value is positive
                                    ;  * x is to the right of the collision box - subtraction result is greater than width ($08) so carry is set
    bcc @inside_enemy_collision_box ; branch if inside of collision box (both horizontally and vertically) [(SPRITE_X_POX,x - $09) < $0b]

@next_player:
    dex                           ; decrement player index
    bmi @exit_00                  ; branch if finished looping through sprites
    jmp @check_player_x_collision ; loop to next player

@exit_00:
    ldx ENEMY_CURRENT_SLOT
    rts

; player landed on non-dangerous enemy, e.g. moving cart or floating rock in vertical level
; #$14 - mining cart, #$15 - stationary mining cart, #$10 - floating rock platform
; move the player as the enemy moves
@land_on_enemy:
    lda SPRITE_Y_POS,x            ; load the player's Y position
    cmp PLAYER_FALL_X_FREEZE,x
    bcc @next_player
    lda #$01                      ; a = #$01
    sta ENEMY_FRAME,y             ; enemy animation frame number to #$01, lets mining cart know to start moving
    lda ENEMY_X_VELOCITY_FRACT,y
    clc                           ; clear carry in preparation for addition
    adc ENEMY_X_VEL_ACCUM,y
    lda ENEMY_X_VELOCITY_FAST,y   ; load enemy fast velocity
    adc #$00                      ; add any fractional overflow
    clc                           ; clear carry in preparation for addition
    adc PLAYER_FAST_X_VEL_BOOST,x ; add any existing boost
                                  ; can support being on a moving enemy that is on a moving enemy
    sta PLAYER_FAST_X_VEL_BOOST,x ; set any boost to player's x velocity by being on a moving enemy
    lda ENEMY_STATE_WIDTH,y
    asl
    asl
    asl
    lda #$e4                      ; a = #$e4 (-28)
    bcc @set_landing_pos          ; branch if ENEMY_STATE_WIDTH,y bit 5 is 0
    lda #$e8                      ; a = #$e8 (-24)

@set_landing_pos:
    clc                       ; clear carry in preparation for addition
    adc ENEMY_Y_POS,y         ; subtract 24 or 28 from enemy y position on screen
    sta SPRITE_Y_POS,x        ; set player y position
    lda #$01                  ; a = #$01
    sta PLAYER_ON_ENEMY,x     ; set player on enemy flag
    jsr player_land_on_ground
    jmp @next_player

; player sprite collides with enemy, or enemy bullet
@inside_enemy_collision_box:
    ldy ENEMY_CURRENT_SLOT ; load slot index of enemy that is being collided with
    lda ENEMY_X_POS,y      ; load enemy x position on screen
    sec                    ; set the carry flag in preparation for subtraction
    sbc SPRITE_X_POS,x     ; subtract the x position of player sprite
    bcs @check_can_land_on ; branch if positive (player to left of enemy)
    eor #$ff               ; player to right of enemy - flip all bits
    adc #$01               ; add 1 for correction

@check_can_land_on:
    cmp #$80
    bcs @next_player
    lda ENEMY_STATE_WIDTH,y ; load ENEMY_STATE_WIDTH
    asl                     ; shift bit 7 to carry
    bpl @collide_with_enemy ; branch to collide with enemy if can't land on them
    and #$20                ; player can land on enemy, keep bit 5 (collision box code)
    beq @land_on_enemy      ; player can land on enemy (floating rock and moving cart)

@collide_with_enemy:
    lda ENEMY_TYPE,y                   ; load current enemy type
    beq pick_up_weapon_item            ; branch if weapon item enemy
    lda NEW_LIFE_INVINCIBILITY_TIMER,x ; timer for invincibility (after dying)
    bne @next_player                   ; when still invincibility after dying, player walks through enemy, skip
    lda INVINCIBILITY_TIMER,x
    bne @invincible_collision          ; branch if player is invincible (barrier weapon) to set enemy HP to #$00
    jsr kill_player                    ; player collided with enemy sprite, kill player
    lda ENEMY_TYPE,y                   ; load current enemy type
    cmp #$01                           ; compare to bullet
    beq remove_current_enemy           ; remove bullet after collision
    ldx ENEMY_CURRENT_SLOT
    rts

@invincible_collision:
    stx $17                               ; store current player number in $17
    ldx ENEMY_CURRENT_SLOT                ; load current enemy slot number
    lda ENEMY_HP,x                        ; load enemy hp
    beq @exit_01
    cmp #$f0
    bcs @exit_01
    lda #$00                              ; a = #$00
    sta ENEMY_HP,x                        ; set enemy hp
    jsr add_enemy_score_set_enemy_routine ; adds score amount to player score, sets enemy destroyed routine

@exit_01:
    rts

; player has collided with a weapon item, pick it up
pick_up_weapon_item:
    stx $10
    lda #$0a                     ; a = #$0a
    sta $00                      ; set score to add to player as #$0a (1,000 points)
    txa
    tay
    jsr add_player_low_score     ; add points to player score, check if new high score and extra life
    ldx $10
    ldy ENEMY_CURRENT_SLOT
    lda #$1f                     ; a = #$1f (sound_1f)
    jsr play_sound               ; play weapon item taken sound
    lda ENEMY_ATTRIBUTES,y       ; get weapon item attributes
    and #$07                     ; keep bits 0-3 (attributes)
    beq @set_rapid_flag          ; set rapid flag for weapon if attribute is #$00
    cmp #$05                     ; check for b weapon (barrier). Gives invincibility
    bcc @compare_and_set_weapon  ; branch if less than #$05 (MFSL)
    beq @set_invincibility_timer ; branch for barrier weapon
    jsr destroy_all_enemies      ; falcon weapon effect - destroy all enemies
    lda #$20                     ; a = #$20
    sta FALCON_FLASH_TIMER       ; set falcon weapon flash timer to #$20 frames
    bne remove_current_enemy

; b weapon effect (barrier). Gives invincibility
; decreases every 8 frames
; NTSC is about #3c frames per second
; PAL is close to #$32 frames per second
; NTSC: #$80 * #$8 = #$400 / #$3c = 17.06667 (decimal) seconds
; NTSC: #$90 * #$8 = #$480 / #$3c = 19.2 (decimal) seconds
@set_invincibility_timer:
    lda #$80          ; set duration of the b weapon effect
    ldy CURRENT_LEVEL ; current level
    cpy #$06          ; check if level 7 (hangar)
    bne @continue
    lda #$90          ; set duration for level 7

@continue:
    sta INVINCIBILITY_TIMER,x
    jmp remove_current_enemy

; r weapon
@set_rapid_flag:
    lda #$10               ; a = #$10
    sta $08
    ldy #$ff               ; y = #$ff
    bne @set_player_weapon

; default for MFSL Weapons
; compare weapon being picked up with current weapon
; if the same, rapid fire flag is kept; otherwise it is dropped
@compare_and_set_weapon:
    ldy #$f0                ; y = #$f0 (keep rapid fire flag)
    sta $08                 ; store weapon item attributes in $08
    eor P1_CURRENT_WEAPON,x ; test to see if current weapon matches weapon item (XOR)
    and #$0f                ; compare to weapon regardless of rapid fire flag
    beq @set_player_weapon  ; keep rapid fire flag (if set) when picking up same weapon
    ldy #$e0                ; remove rapid fire flag since picking up different weapon

@set_player_weapon:
    tya                     ; y = #$f0 or #$e0 depending if same weapon was picked up
    and P1_CURRENT_WEAPON,x ; strip/set rapid fire flag
    ora $08                 ; merge in rapid fire flag with weapon being picked up
    sta P1_CURRENT_WEAPON,x ; set current player's weapon

remove_current_enemy:
    ldx ENEMY_CURRENT_SLOT
    jmp remove_enemy       ; remove enemy

; loop through player bullets and see if they collide with current enemy
bullet_enemy_collision_test:
    lda ENEMY_STATE_WIDTH,x     ; load current enemy ENEMY_STATE_WIDTH
    and #$30                    ; keep bits 4 and 5 (collision box code)
    asl
    asl
    sta $10                     ; store enemy's original collision box code in $10
    ldy #$04                    ; override enemy collision box to box code #$04
    jsr set_enemy_collision_box ; set collision box in [$08-$0b] for box code #$04 (bullet collision box code)
    ldx #$0f                    ; loop through player bullets

@loop:
    lda PLAYER_BULLET_SPRITE_CODE,x ; load current player bullet sprite
    beq @next_bullet                ; move to next bullet if no bullet at current position
    lda PLAYER_BULLET_ROUTINE,x     ; load player bullet routine
    cmp #$01                        ; compare to #$01
    bne @next_bullet                ; move to next bullet if not routine 01
    lda LEVEL_LOCATION_TYPE         ; 0 = outdoor; 1 = indoor
    lsr
    bcc @test_collision             ; branch for outdoor level
    ldy $10                         ; indoor level, load collision box code
    bpl @bullet_delay               ; branch if collision box is positive, i.e. non-zero
    lda PLAYER_BULLET_SLOT,x        ; load bullet type + 1
    bmi @test_collision
    bpl @next_bullet                ; branch if bullet exists (PLAYER_BULLET_SLOT is non-zero)

@bullet_delay:
    lda PLAYER_BULLET_TIMER,x
    cmp #$02
    bcs @next_bullet

@test_collision:
    lda PLAYER_BULLET_Y_POS,x
    sbc $08
    cmp $0a
    bcs @next_bullet
    lda PLAYER_BULLET_X_POS,x
    sbc $09
    cmp $0b
    bcc @bullet_enemy_collision

@next_bullet:
    dex
    bpl @loop
    ldx ENEMY_CURRENT_SLOT
    rts

@bullet_enemy_collision:
    ldy ENEMY_CURRENT_SLOT    ; load the current enemy slot index
    lda ENEMY_X_POS,y         ; load enemy x position on screen
    sec                       ; set carry flag in preparation for subtraction
    sbc PLAYER_BULLET_X_POS,x ; ENEMY_X_POS - PLAYER_BULLET_X_POS
    bcs @continue             ; branch if bullet hits enemy from left
    eor #$ff                  ; flip all bits
    adc #$01                  ; add #$01 (convert to positive)

@continue:
    cmp #$80
    bcs @next_bullet
    lda PLAYER_BULLET_OWNER,x
    jsr bullet_collision_logic ; subtract enemy HP, play collision sound (if appropriate), award points
    lda PLAYER_BULLET_SLOT,x   ; load bullet type + 1
    cmp #$05                   ; see if laser
    bne @set_routine_exit      ; branch if not laser
    stx $08                    ; laser, store bullet slot number in $08
    txa                        ; move bullet slot number to a
    ldx #$00                   ; x = #$00
    cmp #$0a                   ; see if bullet slot number to #$0a
    bcc @continue_2
    ldx #$0a                   ; x = #$0a

@continue_2:
    lda PLAYER_BULLET_ROUTINE,x
    cmp #$01
    beq @set_routine_exit
    inx
    cpx $08
    bne @continue_2

@set_routine_exit:
    jsr set_bullet_routine_to_2 ; move to bullet routine 2, which destroys the bullet (player_bullet_collision_routine)
                                ; reset PLAYER_BULLET_TIMER to #$06
    ldx ENEMY_CURRENT_SLOT      ; restore x to the current enemy slot
    rts

; set PLAYER_BULLET_ROUTINE,x to #$02, which destroys the bullet (player_bullet_collision_routine)
; set bullet delay to #$06
set_bullet_routine_to_2:
    lda #$02                    ; used to specify the bullet routine, see player_bullet_routine_0X_ptr_tbl and player_bullet_routine_indoor_0X_ptr_tbl
    sta PLAYER_BULLET_ROUTINE,x ; move to last bullet routine for bullet (player_bullet_collision_routine), this handles destroying the bullet
    lda #$06                    ; a = #$06
    sta PLAYER_BULLET_TIMER,x
    rts

; subtract enemy HP, play collision sound (if appropriate), award points
; set enemy destroyed routine if HP is #$00
bullet_collision_logic:
    sta $17                ; store PLAYER_BULLET_OWNER in $17 0 = p1, 1 = p2
    stx $11                ; backup bullet index in $11 for logic
    ldy ENEMY_CURRENT_SLOT ; load current enemy slot
    lda ENEMY_HP,y         ; load enemy hp
    beq @exit              ; exit if enemy HP already #$00
    cmp #$f0
    bcs @exit              ; exit if enemy HP is between #$f0 and #$ff
    sbc #$00               ; subtract #$01 from enemy HP (carry is clear)
    bcs @continue
    lda #$00               ; a = #$00

@continue:
    sta ENEMY_HP,y                        ; update enemy hp
    bne @play_collision_sound             ; play collision sound if appropriate
    ldx ENEMY_CURRENT_SLOT
    jsr add_enemy_score_set_enemy_routine ; adds score amount to player score, sets enemy destroyed routine
    ldx $11                               ; restore bullet index back in x
    rts

@play_collision_sound:
    lda ENEMY_STATE_WIDTH,y
    and #$04                   ; keep bit 2 (play bullet collision sound bit)
    beq @exit                  ; exit if shouldn't play sound
    lda ENEMY_VAR_A,y          ; load appropriate sound index for current enemy
    tay
    lda bullet_hit_sound_tbl,y ; load sound code
    jsr play_sound             ; play bullet collision sound

@exit:
    rts

; table for bullet hit sound codes ($05 bytes)
; #$16 = Normal Hit (sound_16)
; #$18 = Heart Hit (sound_18)
; #$14 = Core Plating Hit (sound_14)
bullet_hit_sound_tbl:
    .byte $16,$16,$16,$18,$14

; determine enemy (including enemy bullets) collision box
; input
;  * y - the collision box table to use, depends on player state (is player crouching, etc)
;    * 0 - player is in water
;    * 1 - player is jumping
;    * 2 - player is crouching
;    * 3 - normal
;    * 4 - bullet collision box code
; stores collision corners for enemy in $08 (top left Y), $09 (top left X), $0a (width), $0b (height)
set_enemy_collision_box:
    stx $11                         ; temporarily save x into $11 for duration of method
    ldx ENEMY_CURRENT_SLOT          ; load current enemy slot index
    tya                             ; move y (desired collision box table) to a so it can be doubled with asl
    asl                             ; double since table is 2 bytes each
    tay                             ; move value back to y
    lda collision_box_codes_tbl,y   ; load low byte of desired collision box table
    sta $0e                         ; store low byte in $0e
    lda collision_box_codes_tbl+1,y ; load high byte of desired collision box table
    sta $0f                         ; store high byte in $0f
    lda ENEMY_SCORE_COLLISION,x     ; load specified score and collision codes for enemy
    and #$0f                        ; filter to only the collision code part of byte (low 4 bits)
    cmp #$0f                        ; compare to all ones
    beq @collision_code_f           ; branch if collision code f (fire beams and rising spiked walls)
    asl                             ; double collision code
    asl                             ; double again, since each collision box is 4 bytes
    tay                             ; transfer to offset register
    lda ENEMY_Y_POS,x               ; load enemy y position on screen
    adc ($0e),y                     ; add collision_box_codes_XX,y to y position (frequently this is actually subtraction)
    sta $08                         ; store y position on screen of top-left of collision box
    iny                             ; move to next byte to read
    lda ENEMY_X_POS,x               ; load enemy x position on screen
    clc                             ; clear carry in preparation for addition
    adc ($0e),y                     ; add (collision_box_codes_XX,y) from x position (frequently this is actually subtraction)
    sta $09                         ; store x position on screen of top-left of collision box
    iny                             ; move to next byte to read
    lda ($0e),y                     ; read height of collision box
    sta $0a                         ; store height in $0a
    iny                             ; move to next byte to read
    lda ($0e),y                     ; read width of collision box
    sta $0b                         ; store width in $0b
    ldx $11                         ; restore x back to value before set_enemy_collision_box was called
    rts

; used for fire beams and rising spiked walls, i.e. things with variable sized collision boxes
@collision_code_f:
    lda ENEMY_ATTRIBUTES,x ; load the enemy's attributes
    asl
    asl                    ; shift bit 6 of ENEMY_ATTRIBUTES into carry
    lda ENEMY_VAR_1,x      ; load collision_code_f_base_tbl offset stored in ENEMY_VAR_1
    bcc @continue          ; branch if bit 6 of ENEMY_ATTRIBUTES,x is 0
    eor #$ff               ; bit 6 set, negate the , flip all bits
    adc #$00               ; add 1

@continue:
    clc                               ; clear carry in preparation for addition
    adc #$08                          ; add #$08 to ENEMY_VAR_1,x
    sta $0c                           ; store result in $0c
    tya                               ; transfer which collision box table to use to y [#$00-#$04]
    asl                               ; double (already doubled y) since each entry is #$04 bytes
    tay                               ; transfer back to offset register
    lda collision_code_f_base_tbl,y   ; load initial y coordinate of top left of collision box
    sta $08                           ; store y coordinate of top left of collision box in $08
    lda collision_code_f_base_tbl+1,y ; load initial x coordinate of top left of collision box
    sta $09                           ; store x coordinate of top left of collision box in $09
    lda collision_code_f_base_tbl+2,y ; load initial height of top left of collision box
    sta $0a                           ; store height of collision box in $0a
    lda collision_code_f_base_tbl+3,y ; load initial width of top left of collision box
    sta $0b                           ; store width of collision box in $0b
    lda ENEMY_ATTRIBUTES,x            ; load enemy attributes
    lsr
    lsr
    lsr
    lsr                               ; move high nibble to low nibble
    and #$0c                          ; keep bits .... xx.. (0, 4, or 8, or 12)
    tay                               ; transfer to offset register
    lda collision_code_f_adj_tbl,y    ; load top-left y coordinate offset
    jsr @replace_placeholder          ; if placeholder value, replace it with $c0 (or its negative)
    clc                               ; clear carry in preparation for addition
    adc $08                           ; add to top-left y coordinate
    clc                               ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x                 ; add to enemy y position on screen
    sta $08                           ; set top-left y coordinate of collision box based
    lda collision_code_f_adj_tbl+1,y  ; load top-left x coordinate offset
    jsr @replace_placeholder          ; if placeholder value, replace it with $c0 (or its negative)
    clc                               ; clear carry in preparation for addition
    adc $09                           ; add to top-left x coordinate
    clc                               ; clear carry in preparation for addition
    adc ENEMY_X_POS,x                 ; add to enemy x position on screen
    sta $09                           ; set top-left x coordinate of collision box based
    lda collision_code_f_adj_tbl+2,y  ; load collision box height adjustment
    jsr @replace_placeholder          ; if placeholder value, replace it with $c0 (or its negative)
    clc                               ; clear carry in preparation for addition
    adc $0a                           ; add to base height
    sta $0a                           ; set new collision box height
    lda collision_code_f_adj_tbl+3,y  ; load collision box width
    jsr @replace_placeholder          ; if placeholder value, replace it with $c0 (or its negative)
    clc                               ; clear carry in preparation for addition
    adc $0b                           ; add to base collision box width
    sta $0b                           ; set new collision box width
    ldx $11                           ; restore x back to value before set_enemy_collision_box was called
    rts

; replaces the variable placeholder (#$fe, #$ff) with adjustment value $0c (or its negative)
; input
;  * a - value from collision_code_f_adj_tbl
; output
;  * a
;    * if input a < #$fe, a (not a placeholder)
;    * if input a == #$fe, negative value of $0c
;    * if input a == #$ff, $0c
; note: $0c is ENEMY_VAR_1 or negative ENEMY_VAR_1 depending on bit 6 of ENEMY_ATTRIBUTES
@replace_placeholder:
    cmp #$fe  ; compare collision box adjustment value to to #$fe
    bcc @exit ; exit if value less than #$fe. it is not a placeholder
    lsr       ; shift bit 0 of collision_code_f_adj_tbl value to the carry flag
    lda $0c   ; load adjustment control variable
    bcs @exit ; exit to $0c if placeholder is #$ff (odd)
    eor #$ff  ; placeholder is #$fe (event), return negative $0c, flip all bits
    adc #$01  ; add one

@exit:
    rts

; table for f collision code initial collision box rectangles depending on collision code  ($14 bytes)
; byte 0 - initial top left y coordinate
; byte 1 - initial top left x coordinate
; byte 2 - initial collision box height
; byte 3 - initial collision box width
collision_code_f_base_tbl:
    .byte $00,$fb,$0a,$0a ; (-5,   0 ) - player is in water
    .byte $f8,$fc,$10,$08 ; (-4,  -8 ) - player is jumping
    .byte $f4,$f5,$04,$16 ; (-11, -12) - player is crouching
    .byte $f1,$fc,$1d,$08 ; (-14, -15) - normal
    .byte $fe,$fe,$04,$04 ; (-2 , -2 ) - bullet collision box code

; table for adjustment of initial f code collision box based (indirectly) on ENEMY_VAR_1 ($10 bytes)
; these values will be overwritten if value is #$fe or #$ff
; byte 0 - top left y coordinate adjustment
; byte 1 - top left x coordinate adjustment
; byte 2 - collision box height adjustment
; byte 3 - collision box width adjustment
collision_code_f_adj_tbl:
    .byte $fa,$f8,$0c,$ff ; variable width fixed x (growing right)
    .byte $fa,$fe,$0c,$ff ; variable width variable x (growing left)
    .byte $f8,$fa,$ff,$0c ; variable height fixed y (growing downward)
    .byte $fe,$f6,$ff,$14 ; variable height variable y (growing upward)

; pointer table to list of collision box codes for each player state ($05 * $02 = $0a bytes)
; CPU address $e4e8
collision_box_codes_tbl:
    .addr collision_box_codes_00 ; CPU address $e4f2 - player in water
    .addr collision_box_codes_01 ; CPU address $e52e - player jumping
    .addr collision_box_codes_02 ; CPU address $e56a - player standing
    .addr collision_box_codes_03 ; CPU address $e5a6 - player crouching
    .addr collision_box_codes_04 ; CPU address $e5e2

; each 4 bytes is a a collision box code
; #$e different collision box codes
; player is in water
collision_box_codes_00:
    .byte $f1,$f7,$28,$12
    .byte $fe,$f9,$14,$14
    .byte $f8,$f3,$1a,$1a
    .byte $f2,$ed,$26,$26
    .byte $e0,$f0,$08,$20
    .byte $fd,$f8,$10,$10
    .byte $f5,$f7,$20,$12
    .byte $e7,$e2,$3c,$3c
    .byte $f1,$e2,$28,$3c
    .byte $e4,$d3,$48,$5a
    .byte $00,$f6,$16,$16
    .byte $08,$f1,$12,$1e
    .byte $f5,$f1,$20,$1e
    .byte $ea,$ec,$37,$28
    .byte $f3,$f3,$11,$1a

; each 4 bytes is a a collision box code
; player is jumping
collision_box_codes_01:
    .byte $ea,$f8,$1e,$10
    .byte $f6,$fa,$0c,$0c
    .byte $f1,$f5,$12,$16
    .byte $ea,$ee,$24,$24
    .byte $e0,$f0,$08,$20
    .byte $f5,$f9,$0e,$0e
    .byte $ed,$f8,$1e,$10
    .byte $df,$e3,$3a,$3a
    .byte $e9,$e3,$26,$3a
    .byte $dc,$d4,$46,$58
    .byte $f8,$f7,$14,$14
    .byte $00,$f2,$10,$1c
    .byte $ed,$f2,$1e,$1c
    .byte $e2,$ed,$35,$26
    .byte $f3,$f1,$12,$1e

; each 4 bytes is a a collision box code
; player is crouching
collision_box_codes_02:
    .byte $f4,$f1,$0d,$1e
    .byte $f3,$f4,$04,$18
    .byte $ec,$ed,$10,$26
    .byte $e6,$e7,$1c,$32
    .byte $e0,$f0,$08,$20
    .byte $f1,$f2,$06,$1c
    .byte $e9,$f1,$16,$1e
    .byte $db,$dc,$32,$48
    .byte $e5,$dc,$1e,$48
    .byte $d8,$cd,$3e,$66
    .byte $f4,$f0,$19,$22
    .byte $fc,$eb,$08,$2a
    .byte $e3,$f2,$1a,$1c
    .byte $de,$e6,$2d,$34
    .byte $e9,$ea,$0d,$2c

; each 4 bytes is a a collision box code
; player is standing on ground
collision_box_codes_03:
    .byte $f3,$f8,$24,$10
    .byte $f0,$fb,$1f,$0a
    .byte $ea,$f5,$2b,$16
    .byte $e3,$ee,$39,$24
    .byte $e0,$f0,$08,$20
    .byte $ee,$f9,$23,$0e
    .byte $e6,$f8,$33,$10 ; #$33, #$10 is the start of sound dpcm sound sample (length 385) !(BUG?)
    .byte $d8,$e3,$4f,$3a ; used on level 5 (snow field) after defeating the boss
    .byte $e2,$e3,$3b,$3a ; this DPCM sample does not occur in the Japanese version
    .byte $d5,$d4,$5b,$58
    .byte $f1,$f7,$29,$14
    .byte $f9,$f2,$25,$1c
    .byte $e4,$f2,$35,$1c
    .byte $da,$ed,$4a,$26
    .byte $e6,$f1,$2a,$1e

; each 4 bytes is a a collision box code
; bullet collision code
collision_box_codes_04:
    .byte $ee,$f5,$24,$16
    .byte $fc,$fc,$08,$08
    .byte $f5,$f5,$16,$16
    .byte $ef,$ef,$22,$22
    .byte $e0,$f0,$08,$20
    .byte $fa,$fa,$0c,$0c
    .byte $f3,$fa,$16,$0c
    .byte $e4,$e4,$38,$38
    .byte $ee,$e4,$24,$38
    .byte $e1,$d5,$44,$56
    .byte $fd,$f8,$12,$12
    .byte $05,$f3,$0e,$1a
    .byte $f3,$f3,$1a,$1a
    .byte $e7,$ee,$33,$24
    .byte $f2,$f2,$13,$1c

; execute all enemy routines
exe_all_enemy_routine:
    lda #$00            ; a = #$00
    sta PLAYER_ON_ENEMY ; clear player on non-dangerous enemy flag
    sta $b7
    ldx #$0f            ; x = #$0f

exe_enemy_routine_loop:
    lda ENEMY_ROUTINE,x     ; enemy routine index
    beq advance_enemy       ; no enemy loaded in slot, continue to next enemy
    stx ENEMY_CURRENT_SLOT  ; store current enemy slot offset into $83
    asl                     ; double enemy routine index since each entry in enemy routine table is 2 bytes
    sta $04                 ; save enemy routine index (enemy_routine_ptr_tbl or level_enemy_routine_ptr_tbl)
    jsr exe_enemy_routine   ; execute the xth (current) enemy routine's current sub-routine
    lda ENEMY_SPRITES,x     ; enemy sprite data: sprite code, attribute, etc.
    beq advance_enemy       ; no enemy tiles specified, continue to next enemy
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    lsr
    bcc @handle_outdoor     ; branch for outdoor level
    lda ENEMY_Y_POS,x       ; indoor level, load enemy y position on screen
    cmp #$9c
    bcc @continue

@handle_outdoor:
    lda ENEMY_STATE_WIDTH,x
    lsr                         ; shift bit 0 into the carry flag
    bcs @continue
    jsr check_players_collision ; check if players are colliding with current enemy

@continue:
    lda ENEMY_STATE_WIDTH,x         ; see if enemy is active by checking bit 7
    bmi advance_enemy               ; branch if bit 7 is set
    jsr bullet_enemy_collision_test ; enemy is active, check collision

; decrement x and if it's greater than #$00 jump back to execute enemy routine
advance_enemy:
    dex
    bpl exe_enemy_routine_loop
    rts

; executes the xth enemy routine
; if the enemy type (ENEMY_TYPE,x) is >= #$10, then it is a level-specific enemy routine, i.e. an enemy unique for the level
; each level uses different enemies for these values, they executed from this label as well
; input
;  * $04 - the enemy routine index (which sub-routine inside the enemy routine to execute)
; x has the current enemy slot number
exe_enemy_routine:
    lda ENEMY_TYPE,x              ; load current enemy type
    asl                           ; double since enemy type pointer is 2 bytes
    tay                           ; store offset into pointer table into y
    lsr                           ; undo the doubling to see the offset number
    cmp #$10                      ; compare offset to #$10
    bcs exec_level_enemy_routine  ; offset is greater than or equal to #$10 (level-specific enemy)
    lda enemy_routine_ptr_tbl,y   ; load low byte of the routine pointer
    sta $02                       ; store in $02
    lda enemy_routine_ptr_tbl+1,y ; load high byte of the enemy pointer

; $04 stores the enemy routine index (which sub-routine inside the enemy routine to execute)
exe_enemy_routine_subroutine:
    sta $03     ; store enemy routine high byte into $03
    ldy $04     ; load which sub-routine to execute
    lda ($02),y ; load the low byte of the enemy sub-routine to execute
    sta $04     ; store in $04
    iny         ; increment read offset
    lda ($02),y ; load the high byte of the enemy sub-routine to execute
    sta $05     ; store in $05
    jmp ($04)   ; jump to that sub-routine

; enemy type >= 10 (level specific)
exec_level_enemy_routine:
    tya                              ; move current (doubled) enemy type into a
    sbc #$20                         ; subtract #$20 (since we are indexing from level specific enemy types)
    tay                              ; store offset into y
    lda (ENEMY_LEVEL_ROUTINES),y     ; load current level-specific enemy routines low byte into a
    sta $02                          ; store into $02
    iny                              ; increment read offset
    lda (ENEMY_LEVEL_ROUTINES),y     ; load current level-specific enemy routines high byte into a
    jmp exe_enemy_routine_subroutine ; loads the current sub-routine for the current enemy

; stores the enemy routines table 2-byte address for the current level into ENEMY_LEVEL_ROUTINES ($80)
load_level_enemies_to_mem:
    lda CURRENT_LEVEL                   ; load the current level
    asl                                 ; double the number since each address is 2 bytes
    tay                                 ; transfer offset to y
    lda level_enemy_routine_ptr_tbl,y   ; load low byte of level-specific enemy table to y
    sta ENEMY_LEVEL_ROUTINES            ; store low byte into $80
    lda level_enemy_routine_ptr_tbl+1,y ; load high byte of level-specific enemy table to y
    sta ENEMY_LEVEL_ROUTINES+1          ; store high byte into $81
    rts

; pointer table for enemy routines by level ($08 * $02 = $10 bytes)
; each entry is an address pointing to another table listing the tables of
; routines for each enemy specific to the level
level_enemy_routine_ptr_tbl:
    .addr enemy_routine_level_1   ; CPU address $e6c8
    .addr enemy_routine_level_2_4 ; CPU address $e6ce
    .addr enemy_routine_level_3   ; CPU address $e6f0
    .addr enemy_routine_level_2_4 ; CPU address $e6ce
    .addr enemy_routine_level_5   ; CPU address $e6fc
    .addr enemy_routine_level_6   ; CPU address $e70a
    .addr enemy_routine_level_7   ; CPU address $e714
    .addr enemy_routine_level_8   ; CPU address $e726

; pointer table for common enemies routines - codes 00 to 0f
; bank 0 and bank 7 labels
; every entry is 2 bytes less than the actual label
enemy_routine_ptr_tbl:
    .addr weapon_item_routine_ptr_tbl-2       ; weapon item (00) - CPU address $8001 bank 0
    .addr enemy_bullet_routine_ptr_tbl-2      ; enemy bullet (01) - CPU address $8147 bank 0
    .addr weapon_box_routine_ptr_tbl-2        ; pill box sensor (02) - CPU address $8205 bank 0
    .addr flying_capsule_routine_ptr_tbl-2    ; flying capsule (03) - CPU address $8305 bank 0
    .addr rotating_gun_routine_ptr_tbl-2      ; rotating gun (04) - CPU address $8379 bank 0
    .addr soldier_routine_ptr_tbl-2           ; soldier (05) - CPU address $8608 bank 0
    .addr sniper_routine_ptr_tbl-2            ; sniper (06) - CPU address $8946 bank 0
    .addr red_turret_routine_ptr_tbl-2        ; red turret (07) - CPU address $84b8 bank 0
    .addr wall_cannon_routine_ptr_tbl-2       ; wall cannon (08) - CPU address $efb7
    .addr enemy_routine_do_nothing_ptr_tbl-2  ; unused (09) - CPU address $e734
    .addr wall_plating_routine_ptr_tbl-2      ; wall plating (0a) - CPU address $f077
    .addr mortar_shot_routine_ptr_tbl-2       ; mortar shot (0b) - CPU address $f1c4
    .addr scuba_soldier_routine_ptr_tbl-2     ; scuba diver (0c) - CPU address $f13b
    .addr enemy_routine_do_nothing_ptr_tbl-2  ; unused (0d) - CPU address $e734
    .addr turret_man_routine_ptr_tbl-2        ; turret man (0e) - CPU address $f0bd
    .addr turret_man_bullet_routine_ptr_tbl-2 ; turret man bullet (0f) - CPU address $f119

; pointer table for level 1 enemy routines (#$2 * #$3 = #$6 bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_1:
    .addr bomb_turret_routine_ptr_tbl-2           ; boss bomb turret (10) - CPU address $8b47
    .addr boss_wall_plated_door_routine_ptr_tbl-2 ; door plate with siren (11) - CPU address $8bc7
    .addr exploding_bridge_routine_ptr_tbl-2      ; exploding bridge (12) - CPU address $8c50

; pointer table for level 2/4 enemy routines (#$11 * #$2 = #$22 bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_2_4:
    .addr boss_eye_routine_ptr_tbl-2             ; Boss Eye (10) - CPU address $8e65
    .addr roller_routine_ptr_tbl-2               ; Rollers (11) - CPU address $8f80
    .addr grenade_routine_ptr_tbl-2              ; Grenades (12) - CPU address $8fc7
    .addr wall_turret_routine_ptr_tbl-2          ; Wall Turret (13) - CPU address $908a
    .addr wall_core_routine_ptr_tbl-2            ; Core (14) - CPU address $910e
    .addr indoor_soldier_routine_ptr_tbl-2       ; Running Guy (15) - CPU address $92b8
    .addr jumping_soldier_routine_ptr_tbl-2      ; Jumping Guy (16) - CPU address $936e
    .addr grenade_launcher_routine_ptr_tbl-2     ; Seeking Guy (17) - CPU address $9458
    .addr four_soldiers_routine_ptr_tbl-2        ; Group of 4 (18) - CPU address $952f
    .addr indoor_soldier_gen_routine_ptr_tbl-2   ; Indoor Soldier Generator (19) - CPU address $8d17
    .addr indoor_roller_gen_routine_ptr_tbl-2    ; Rollers Generator (1A) - CPU address $95c0
    .addr eye_projectile_routine_ptr_tbl-2       ; Sphere Projectile (1B) - CPU address $8f33
    .addr boss_gemini_routine_ptr_tbl-2          ; Boss Gemini (1C) - CPU address $9ef3
    .addr spinning_bubbles_routine_ptr_tbl-2     ; Spinning Bubbles (1D) - CPU address $a04f
    .addr blue_soldier_routine_ptr_tbl-2         ; Blue Jumping Guy (1E) - CPU address $a147
    .addr red_soldier_routine_ptr_tbl-2          ; Red Shooting Guy (1F) - CPU address $a258
    .addr red_blue_soldier_gen_routine_ptr_tbl-2 ; Red/Blue Guys Generator (20) - CPU address $a2fc

; pointer table for level 3 enemy routines (#$6 * #$2 = #$c bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_3:
    .addr floating_rock_routine_ptr_tbl-2  ; Rock Platform (10) - CPU address $97e3
    .addr moving_flame_routine_ptr_tbl-2   ; Moving Flame (11) - CPU address $983a
    .addr rock_cave_routine_ptr_tbl-2      ; Falling Rock Generator (12) - CPU address $9855
    .addr falling_rock_routine_ptr_tbl-2   ; Falling Rock (13) - CPU address $987b
    .addr boss_mouth_routine_ptr_tbl-2     ; Level 3 Boss Mouth (14) - CPU address $9916
    .addr dragon_arm_orb_routine_ptr_tbl-2 ; Level 3 Dragon Arm Orb (15) - CPU address $9a8a

; pointer table for level 5 enemy routines (#$7 * #$2 = #$e bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_5:
    .addr ice_grenade_generator_routine_ptr_tbl-2 ; Grenade Generator (10) - CPU address $a382
    .addr ice_grenade_routine_ptr_tbl-2           ; Grenade (11) - CPU address $a3a9
    .addr tank_routine_ptr_tbl-2                  ; Tank (12) - CPU address $a40c
    .addr ice_separator_routine_ptr_tbl-2         ; Pipe Joint (13) - CPU address $a981
    .addr boss_ufo_routine_ptr_tbl-2              ; Alien Carrier (Guldaf) (14) - CPU address $a698
    .addr mini_ufo_routine_ptr_tbl-2              ; Flying Saucer (15) - CPU address $a8ea
    .addr boss_ufo_bomb_routine_ptr_tbl-2         ; Drop Bomb (16) - CPU address $a96a

; pointer table for level 6 enemy routines (#$5 * #$2 = #$a bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_6:
    .addr fire_beam_down_routine_ptr_tbl-2        ; Energy Beam - Down (10) - CPU address $a997
    .addr fire_beam_left_routine_ptr_tbl-2        ; Energy Beam - Left (11) - CPU address $aa4b
    .addr fire_beam_right_routine_ptr_tbl-2       ; Energy Beam - Right (12) - CPU address $aa9a
    .addr boss_giant_soldier_routine_ptr_tbl-2    ; Giant Boss Robot (13) - CPU address $ab7d
    .addr boss_giant_projectile_routine_ptr_tbl-2 ; Spiked Disk Projectile (14) - CPU address $ae40

; pointer table for level 7 enemy routines (#$9 * #$2 = #$12 bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_7:
    .addr claw_routine_ptr_tbl-2                    ; Mechanical Claw (10) - CPU address $aeb9
    .addr rising_spiked_wall_routine_ptr_tbl-2      ; Raising Spiked Wall (11) - CPU address $afc8
    .addr spiked_wall_routine_ptr_tbl-2             ; Spiked Wall (12) - CPU address $b0f9
    .addr mine_cart_generator_routine_ptr_tbl-2     ; Cart Generator (13) - CPU address $b11c
    .addr moving_cart_routine_ptr_tbl-2             ; Cart - Moving (14) - CPU address $b178
    .addr immobile_cart_generator_routine_ptr_tbl-2 ; Cart - Immobile (15) - CPU address $b1d7
    .addr boss_door_routine_ptr_tbl-2               ; Armored Door with Siren (16) - CPU address $b201
    .addr boss_mortar_routine_ptr_tbl-2             ; Mortar Launcher (17) - CPU address $b272
    .addr boss_soldier_generator_routine_ptr_tbl-2  ; Boss Screen Soldier Generator (18) - CPU address $b32c

; pointer table for level 8 enemy routines (#$6 * #$2 = #$c bytes)
; every entry is 2 bytes less than the actual label
enemy_routine_level_8:
    .addr alien_guardian_routine_ptr_tbl-2     ; Alien Guardian (10) - CPU address $b422
    .addr alien_fetus_routine_ptr_tbl-2        ; Alien Fetus (11) - CPU address $b6e0
    .addr alien_mouth_routine_ptr_tbl-2        ; Alien Mouth (12) - CPU address $b7f4
    .addr white_blob_routine_ptr_tbl-2         ; White Sentient Blob (13) - CPU address $b866
    .addr alien_spider_routine_ptr_tbl-2       ; Alien Spider (14) - CPU address $ba29
    .addr alien_spider_spawn_routine_ptr_tbl-2 ; Spider Spawn (15) - CPU address $bbb5
    .addr boss_heart_routine_ptr_tbl-2         ; Heart (16) - CPU address $bc80

; enemy #$09 and #$0d, unused
enemy_routine_do_nothing_ptr_tbl:
    .addr enemy_routine_do_nothing_00 ; Do Nothing - CPU address $e736

enemy_routine_do_nothing_00:
    rts

wall_core_routine_05:
    jsr enemy_routine_init_explosion ; initialize explosion and play sound if specified in ENEMY_STATE_WIDTH
    lda #$00                         ; a = #$00
    sta ENEMY_FRAME,x                ; set enemy animation frame number
    rts

; door plate defeated
; various enemies use this routine, advanced to by enemy_destroyed_routine_ptr_tbl
; plays boss destroyed sound, destroys all enemies, destroys boss and advances enemy routine
boss_defeated_routine:
    jsr init_APU_channels
    lda #$57                ; a = #$57 (sound_57) - boss destroyed
    jsr level_boss_defeated ; play sound and initiate auto-move
    jsr destroy_all_enemies ; boss defeated, destroy all enemies

; initialize explosion and play sound if specified in ENEMY_STATE_WIDTH
; hide enemy and advance enemy routine
enemy_routine_init_explosion:
    lda ENEMY_STATE_WIDTH,x
    ora #$81                       ; set boss destroyed bits x... ...x
    bne explosion_sound_hide_enemy ; always branch

; also used by ice grenades (11)
; split mortar collide with ground routine
; play explosion sound, update collision, hide sprite
mortar_shot_routine_03:
    lda #$0d                    ; a = #$0d (score code 0, collision code d)
    sta ENEMY_SCORE_COLLISION,x ; set collision code for enemy
    lda ENEMY_STATE_WIDTH,x     ; load enemy state width
    and #$be                    ; strip bits 0 and 6 (player-enemy collision)
    ora #$80                    ; set bit 7 (allow bullets to travel through enemy)

explosion_sound_hide_enemy:
    sta ENEMY_STATE_WIDTH,x   ; set updated ENEMY_STATE_WIDTH to specify explosion triggered
    and #$02                  ; keep bit 1 .... ..x.
    beq @skip_explosion_sound ; skip explosion sound if bit 1 is set
    lda #$19                  ; a = #$19 (sound_19)
    jsr play_sound            ; play enemy destroyed sound

@skip_explosion_sound:
    lda ENEMY_SPRITE_ATTR,x ; load enemy sprite attributes
    and #$fc                ; strip sprite palette
    ora #$06                ; override sprite code palette with palette 2
    sta ENEMY_SPRITE_ATTR,x ; update sprite attribute with new palette
    lda ENEMY_SPRITES,x     ; read enemy sprite code from CPU buffer
    bne @continue           ; if enemy sprite present, don't remove enemy
    jmp remove_enemy        ; remove enemy

; hide enemy (show invisible sprite) before advancing to next routine
@continue:
    lda #$ff                    ; a = #$ff
    sta ENEMY_FRAME,x           ; set enemy animation frame number to #$ff
    lda #$01                    ; a = #$01
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer with invisible sprite (hide enemy)
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$01                    ; a = #$01

; set ENEMY_ANIMATION_DELAY counter and advance to next routine
set_enemy_delay_adv_routine:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

; advance to next routine
; input
;  * x - enemy slot index of the enemy routine to advance
advance_enemy_routine:
    lda ENEMY_ROUTINE,x ; enemy routine index
    beq set_sprite_0    ; if routine not set, exit
    inc ENEMY_ROUTINE,x ; increment enemy routine index
    rts

; dead code, never called !(UNUSED)
bank_7_unused_label_01:
    lda ENEMY_ROUTINE,x ; enemy routine index
    beq set_sprite_0
    inc ENEMY_ROUTINE,x ; enemy routine index
    lda #$24            ; a = #$24 (sound of explosion)
    jmp play_sound      ; play sound

roller_routine_04:
    lda #$03             ; explosion_type_03
    ldy #$02             ; show #$02 of the sprites of the explosion_type_03 sequence
    bne show_explosion_a

; generated indoor soldiers: indoor soldier, jumping soldier, grenade launcher, four soldiers
shared_enemy_routine_03:
    lda #$02             ; explosion_type_02
    ldy #$03             ; show #$02 of the sprites of the explosion_type_02 sequence
    bne show_explosion_a

enemy_routine_explosion:
    lda ENEMY_STATE_WIDTH,x ; load enemy state and width
    ldy #$03                ; y = #$03
    and #$08                ; kit bit 3
    beq @continue           ; branch if bit 3 wasn't set
    iny                     ; increment y to #$04

@continue:
    lda #$00 ; a = #$00

; enemy explosion
; input
;  * a - explosion type, if not specified #$00, grab explosion type from ENEMY_STATE_WIDTH bit 3
;  * y - the number of animations in the explosion to animate, e.g. number of sprites to draw in sequence
show_explosion_a:
    sty $08                          ; y is either #$03 or #$04
    sta $09                          ; a is #$00 for the first time through
    jsr add_scroll_to_enemy_pos      ; add scrolling to enemy position
    lda ENEMY_ROUTINE,x              ; load current enemy routine index
    beq enemy_routine_explosion_exit ; exit if still on first enemy routine is #$00
    dec ENEMY_ANIMATION_DELAY,x      ; decrement enemy animation frame delay counter
    bne enemy_routine_explosion_exit ; timer hasn't elapsed, wait another frame
    inc ENEMY_FRAME,x                ; increment explosion animation sprite
    ldy ENEMY_FRAME,x                ; load explosion animation sprite
    cpy $08                          ; compare ENEMY_FRAME,x to $08 (max number of sprites)
    bcs advance_enemy_routine        ; advance to next enemy-specific routine if shown all sprites
    iny                              ; haven't shown all sprites, increment to next sprite animation
    cpy $08                          ; re-compare ENEMY_FRAME,x to $08 (max number of sprites)
    bcc @continue                    ; branch if not on last sprite
    jsr disable_enemy_collision      ; showing last sprite, prevent player enemy collision

@continue:
    lda #$0a                    ; a = #$0a (delay between explosion frames)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    ldy $09                     ; load explosion type, if not specified #$00, grab explosion type from ENEMY_STATE_WIDTH bit 3
    bne @continue2
    lda ENEMY_STATE_WIDTH,x     ; load ENEMY_STATE_WIDTH to determine explosion type (bit 3)
    and #$08                    ; keep bit 3 (explosion type)
    beq @continue2              ; set ENEMY_FRAME if explosion type is #$00
    iny                         ; if explosion type is #$01 increment y to match

@continue2:
    tya
    asl
    tay
    lda explosion_type_ptr_tbl,y
    sta $0a
    lda explosion_type_ptr_tbl+1,y
    sta $0b
    ldy ENEMY_FRAME,x              ; enemy animation frame number
    lda ($0a),y
    sta ENEMY_SPRITES,x            ; write enemy sprite code to CPU buffer

enemy_routine_explosion_exit:
    rts

enemy_routine_remove_enemy:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position

; remove enemy
; CPU memory address $e809
remove_enemy:
    lda #$00            ; a = #$00
    sta ENEMY_ROUTINE,x ; enemy routine index

set_sprite_0:
    lda #$00            ; a = #$00
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer
    rts

; set tile sprite code to #$00 and advance routine
; level 1 boss wall plated door
; level 2 boss eye
; level 3 boss mouth
; level 4 boss gemini
shared_enemy_routine_clear_sprite:
    jsr set_sprite_0          ; set tile sprite code to 0
    jmp advance_enemy_routine ; advance to next routine

; set enemy routine index to a, unless index is #$0
; remember enemy routines are off by one, so setting ENEMY_ROUTINE to #$03, results in the 2nd routine being run
; ex: for exploding bridge, setting ENEMY_ROUTINE to #$02 causes exploding_bridge_routine_01 to run the next frame
set_enemy_routine_to_a:
    ldy ENEMY_ROUTINE,x ; enemy routine index
    beq set_sprite_0
    sta ENEMY_ROUTINE,x ; enemy routine index
    rts

; pointer table for explosion type sprites (#$4 * #$2 = #$8 bytes)
explosion_type_ptr_tbl:
    .addr explosion_type_00 ; CPU address $e82b
    .addr explosion_type_01 ; CPU address $e82e
    .addr explosion_type_02 ; CPU address $e832
    .addr explosion_type_03 ; CPU address $e835

; tables for explosion sprite codes (#$4 * #$3 = #$c bytes)
; larger circular ring explosion
; sprite_38, sprite_39, sprite_3a
explosion_type_00:
    .byte $38,$39,$3a

; cloudy explosion
; sprite_37, sprite_35, sprite_36, sprite_37
explosion_type_01:
    .byte $37,$35,$36,$37

; small ring explosion -
; used for generated indoor soldiers: indoor soldier, jumping soldier, grenade launcher, four soldiers
; sprite_9d, sprite_9e, sprite_9f
explosion_type_02:
    .byte $9d,$9e,$9f

; short cloudy explosion (used for rollers)
; sprite_36, sprite_37
explosion_type_03:
    .byte $36,$37

; apply velocities and scrolling adjust
; update enemy position
; remove if off screen
update_enemy_pos:
    lda LEVEL_SCROLLING_TYPE                 ; 0 = horizontal, indoor/base; 1 = vertical
    beq update_enemy_x_pos_rem_if_off_screen ; branch for non-vertical levels
    jsr update_enemy_y_pos_with_scroll       ; vertical level; apply y velocity and update y position
    cmp #$e8                                 ; compare enemy Y position to #$e8
    bcs jmp_remove_enemy                     ; remove enemy if Y position is >= #$e8 (fallen off bottom of screen)

; apply X velocity to enemy X velocity
; remove enemy if enemy's resulting X position is less than 8 (off screen to left)
update_enemy_x_pos_rem_off_screen:
    jsr update_enemy_x_pos ; apply velocity to X position
    cmp #$08
    bcc jmp_remove_enemy   ; remove enemy if resulting X position is less than #$08

apply_vel_exit:
    rts

; horizontal level, or indoor/base level
update_enemy_x_pos_rem_if_off_screen:
    jsr update_enemy_x_pos_with_scroll
    cmp #$08                           ; compare enemy X position to #$08
    bcc jmp_remove_enemy               ; if X position < #$08, remove enemy (fallen off from left of screen)

; apply Y velocity to enemy Y position
; remove enemy if enemy's resulting Y position is greater than or equal to #$e8 (off screen to bottom)
set_enemy_y_vel_rem_off_screen:
    jsr update_enemy_y_pos ; apply velocity to Y position
    cmp #$e8
    bcc apply_vel_exit     ; remove enemy if resulting X position is greater than or equal to #$e8 (off screen to bottom)

jmp_remove_enemy:
    jmp remove_enemy ; remove enemy

; sets the weapon item velocity for outdoor levels
set_outdoor_weapon_item_vel:
    lda LEVEL_SCROLLING_TYPE              ; 0 = horizontal, indoor/base; 1 = vertical
    beq @set_weapon_item_velocity         ; branch if horizontal or indoor/base level
    ldy #$00                              ; vertical level
    lda ENEMY_Y_VELOCITY_FAST,x           ; load Y velocity fast byte
    clc                                   ; clear carry in preparation for addition
    adc FRAME_SCROLL                      ; add FRAME_SCROLL to ENEMY_Y_VELOCITY_FAST
    jsr set_weapon_item_y_vel_enemy_frame ; apply y velocity to y position,
    beq jmp_remove_enemy                  ; remove weapon item if ENEMY_FRAME is #$01
    jmp update_enemy_x_pos_rem_off_screen ; add velocity to enemy X pos; remove enemy if X position < #$08 (off screen to left)

; horizontal levels
@set_weapon_item_velocity:
    jsr update_enemy_x_pos_with_scroll    ; update x position accounting for whether frame is scrolling
    cmp #$08                              ; compare the x position to the left side of the screen
    bcc remove_enemy_far                  ; remove weapon item if too far to the left (scrolled off screen)
    ldy #$00                              ; y = #$00
    lda ENEMY_Y_VELOCITY_FAST,x           ; load fast velocity so it is applied in next line
    jsr set_weapon_item_y_vel_enemy_frame ; apply y velocity to y position, don't adjust ENEMY_FRAME
    bne scroll_enemy_pos_exit             ; branch if weapon item, isn't off screen to bottom, otherwise remove

remove_enemy_far:
    jmp remove_enemy ; remove enemy

; adds y to ENEMY_FRAME and adjusts Y position for weapon item by a plus
; ENEMY_FRAME: #$ff is explosion, #$00 is weapon item
; input
;  * x - current enemy offset
;  * a - how much to move current enemy's Y position
;  * y - number of frames to advance ENEMY_FRAME (set to -1 when picked up by player)
; output
;  * compare ENEMY_FRAME to #$01, determines if y position overflow (off screen)
set_weapon_item_y_vel_enemy_frame:
    bpl @set_y_vel_enemy_frame
    dey                        ; subtract 1 from ENEMY_FRAME advance since enemy is moving in positive Y (accommodate overflow)

@set_y_vel_enemy_frame:
    sty $01
    sta $00
    lda ENEMY_Y_VEL_ACCUM,x      ; load current accumulated ENEMY_Y_VELOCITY_FRACT total
    clc                          ; clear carry in preparation for addition
    adc ENEMY_Y_VELOCITY_FRACT,x ; a = ENEMY_Y_VELOCITY_FRACT + ENEMY_Y_VEL_ACCUM
    sta ENEMY_Y_VEL_ACCUM,x      ; add another ENEMY_X_VELOCITY_FRACT to accumulator
    lda ENEMY_Y_POS,x            ; load enemy y position on screen
    adc $00                      ; add $00 units to Y position
                                 ; along with an additional 1 unit if ENEMY_Y_VEL_ACCUM rolled over
    sta ENEMY_Y_POS,x            ; set new Y position
    lda ENEMY_FRAME,x            ; load enemy animation frame number
    adc $01                      ; add ENEMY_FRAME to $01, carry could be set from adc $00 above
    sta ENEMY_FRAME,x            ; set new value
    cmp #$01                     ; if any carry from previous addition, then y position is > #$ff, so remove weapon item, it's off screen
    rts

; if the screen is scrolling add that amount to the enemy position
add_scroll_to_enemy_pos:
    lda LEVEL_SCROLLING_TYPE  ; 0 = horizontal, indoor/base; 1 = vertical
    beq add_horizontal_scroll
    lda ENEMY_Y_POS,x         ; vertical level, load enemy y position on screen
    clc                       ; clear carry in preparation for addition
    adc FRAME_SCROLL          ; how much to scroll the screen (#00 - no scroll)
    sta ENEMY_Y_POS,x         ; enemy y position on screen
    cmp #$e8
    bcs remove_enemy_far      ; remove enemy if far above screen for vertical level

scroll_enemy_pos_exit:
    rts

; add X scrolling to enemy X position
; horizontal scrolling level
add_horizontal_scroll:
    lda ENEMY_X_POS,x    ; load enemy x position on screen
    sec                  ; set carry flag in preparation for subtraction
    sbc FRAME_SCROLL     ; subtract the frame scroll amount
    sta ENEMY_X_POS,x    ; set new enemy x position
    cmp #$08             ; remove enemy if too far to the left
    bcc remove_enemy_far ; remove enemy if leaving the left of the screen
    rts

; dead code, never called !(UNUSED)
bank_7_unused_label_02:
    jsr update_enemy_x_pos_rem_off_screen ; add velocity to enemy X position; remove enemy if X position < #$08 (off screen to left)
    jmp set_enemy_y_vel_rem_off_screen    ; add velocity to enemy Y position; remove enemy if Y position >= #$e8 (off screen to bottom)

; set x/y velocities to zero
set_enemy_velocity_to_0:
    jsr set_enemy_x_velocity_to_0

; set y velocity to zero
set_enemy_y_velocity_to_0:
    lda #$00                     ; a = #$00
    sta ENEMY_Y_VELOCITY_FRACT,x
    sta ENEMY_Y_VELOCITY_FAST,x
    rts

; set x velocity to zero
set_enemy_x_velocity_to_0:
    lda #$00                     ; a = #$00
    sta ENEMY_X_VELOCITY_FRACT,x
    sta ENEMY_X_VELOCITY_FAST,x
    rts

update_enemy_y_pos_with_scroll:
    jsr update_enemy_y_pos ; apply velocity to y position
    clc                    ; clear carry in preparation for addition
    adc FRAME_SCROLL       ; how much to scroll the screen (#00 - no scroll)
    sta ENEMY_Y_POS,x      ; enemy y position on screen
    rts

; apply Y velocity and update enemy's Y position
; output
;  * a - ENEMY_Y_POS
update_enemy_y_pos:
    lda ENEMY_Y_VEL_ACCUM,x      ; load current accumulated ENEMY_Y_VELOCITY_FRACT total
    clc                          ; clear carry in preparation for addition
    adc ENEMY_Y_VELOCITY_FRACT,x ; a = ENEMY_Y_VELOCITY_FRACT + ENEMY_Y_VEL_ACCUM
    sta ENEMY_Y_VEL_ACCUM,x      ; add another ENEMY_X_VELOCITY_FRACT to accumulator
    lda ENEMY_Y_POS,x
    adc ENEMY_Y_VELOCITY_FAST,x  ; add ENEMY_Y_VELOCITY_FAST units to Y position
                                 ; along with an additional 1 unit if ENEMY_Y_VEL_ACCUM rolled over
    sta ENEMY_Y_POS,x            ; set new Y position
    rts

; updates enemy position based on velocity and adjusts when frame is scrolling
; input
;  * x - enemy to adjust x position
; output
;  * a - updated enemy x position
update_enemy_x_pos_with_scroll:
    jsr update_enemy_x_pos ; apply velocity to x position
    sec                    ; set carry flag in preparation for subtraction
    sbc FRAME_SCROLL       ; how much to scroll the screen (#00 - no scroll)
    sta ENEMY_X_POS,x      ; set enemy x position on screen
    rts

; apply X velocity and update enemy's X position
; output
;  * a - ENEMY_X_POS
update_enemy_x_pos:
    lda ENEMY_X_VEL_ACCUM,x      ; load current accumulated ENEMY_X_VELOCITY_FRACT total
    clc                          ; clear carry in preparation for addition
    adc ENEMY_X_VELOCITY_FRACT,x ; a = ENEMY_X_VELOCITY_FRACT + ENEMY_X_VEL_ACCUM
    sta ENEMY_X_VEL_ACCUM,x      ; add another ENEMY_X_VELOCITY_FRACT to accumulator
    lda ENEMY_X_POS,x            ; load current enemy x position
    adc ENEMY_X_VELOCITY_FAST,x  ; add ENEMY_X_VELOCITY_FAST units to X position
                                 ; along with an additional 1 unit if ENEMY_X_VEL_ACCUM rolled over
    sta ENEMY_X_POS,x            ; set new X position
    rts

; reverse x direction
reverse_enemy_x_direction:
    lda #$00                     ; a = #$00
    sec                          ; set carry flag in preparation for subtraction
    sbc ENEMY_X_VELOCITY_FRACT,x ; #$00 - ENEMY_X_VELOCITY_FRACT,x
    sta ENEMY_X_VELOCITY_FRACT,x
    lda #$00                     ; a = #$00
    sbc ENEMY_X_VELOCITY_FAST,x  ; #$00 - ENEMY_X_VELOCITY_FAST,x
    sta ENEMY_X_VELOCITY_FAST,x
    rts

; reverse y direction
; dead code, never called !(UNUSED)
bank_7_unused_label_03:
    lda #$00                     ; a = #$00
    sec                          ; set carry flag in preparation for subtraction
    sbc ENEMY_Y_VELOCITY_FRACT,x ; #$00 - ENEMY_Y_VELOCITY_FRACT,x
    sta ENEMY_Y_VELOCITY_FRACT,x
    lda #$00                     ; a = #$00
    sbc ENEMY_Y_VELOCITY_FAST,x  ; #$00 - ENEMY_Y_VELOCITY_FAST,x
    sta ENEMY_Y_VELOCITY_FAST,x
    rts

; get score of current enemy according to score code
; adds score amount to player score
; sets enemy destroyed routine
add_enemy_score_set_enemy_routine:
    lda ENEMY_SCORE_COLLISION,x     ; pull score bits from byte
    lsr
    lsr
    lsr
    lsr
    tay
    cpy #$0a                        ; score type a (500,000 points), not in score_codes_tbl since 2 bytes
    bne @add_y_code_to_player_score
    lda #$88                        ; custom score code #$0a - set a = #$88
    sta $00                         ; store in score to add low byte
    lda #$13                        ; a = #$13 (#$1388 = 5000 decimal = 500,000 points)
    sta $01                         ; store in score to add high byte
    ldy $17                         ; load current player number (0 or 1)
    jsr add_player_score            ; add $00 and $01 to player score, get extra life, check if high score
    jmp @continue

@add_y_code_to_player_score:
    lda score_codes_tbl,y
    beq @continue
    sta $00
    ldy $17                  ; load current player number (0 or 1)
    jsr add_player_low_score ; add enemy points ($00) to player score in memory, see if extra life and high score

@continue:
    ldx ENEMY_CURRENT_SLOT
    lda ENEMY_SCORE_COLLISION,x ; load to remove score code
    and #$0f                    ; keep bits .... xxxx (collision code)
    sta ENEMY_SCORE_COLLISION,x ; set score component to #$0

; set enemy routine to their appropriate destroyed routine
set_destroyed_enemy_routine:
    lda ENEMY_TYPE,x           ; load current enemy type
    cmp #$10                   ; see if common enemy type
    ldy #$10                   ; y = #$10 (common enemies)
    bcc @set_destroyed_routine ; if current enemy type is < #$10, use common enemy enemy logic
    lda CURRENT_LEVEL          ; level-specific enemy type, load current level
    asl                        ; double since each entry in enemy_destroyed_routine_ptr_tbl is #$02 bytes
    tay                        ; transfer offset to y

@set_destroyed_routine:
    lda enemy_destroyed_routine_ptr_tbl,y   ; load low byte of the routine pointer
    sta $08                                 ; store in $08
    lda enemy_destroyed_routine_ptr_tbl+1,y ; load high byte of the routine pointer
    sta $09                                 ; store in $09
    lda ENEMY_TYPE,x                        ; load current enemy type
    lsr                                     ; push enemy lsb to the carry flag (odd or even)
                                            ; and half the value since each byte is #$02 enemy types
    tay                                     ; transfer enemy type to y
    lda ($08),y                             ; load the byte specified by the table (enemy_destroyed_routine_XX)
    bcs @set_routine                        ; if enemy type loaded is odd, bits 0-3 is the routine number to set
    lsr                                     ; enemy type loaded was even, look at high 4 nibble
    lsr
    lsr
    lsr

@set_routine:
    and #$0f            ; keep bits .... xxxx
    cmp ENEMY_ROUTINE,x ; compare against current enemy routine being executed for the enemy
    bcc @exit           ; enemy destroyed routine is less than current enemy routine index, exit
    sta ENEMY_ROUTINE,x ; update enemy routine to new destroyed index

@exit:
    rts

; table for score codes (#$a bytes)
; type #$0a is hard-coded and gives 500,000 points
score_codes_tbl:
    .byte $00 ; type 0:      0 points
    .byte $01 ; type 1:    100 points
    .byte $03 ; type 2:    300 points
    .byte $05 ; type 3:    500 points
    .byte $0a ; type 4:  1,000 points
    .byte $14 ; type 5:  2,000 points
    .byte $1e ; type 6:  3,000 points
    .byte $32 ; type 7:  5,000 points
    .byte $64 ; type 8: 10,000 points
    .byte $96 ; type 9: 15,000 points

; pointer table for which enemy routine to execute when destroyed (#$9 * #$2 = #$12 bytes)
enemy_destroyed_routine_ptr_tbl:
    .addr enemy_destroyed_routine_00 ; CPU address $e9bf - Level 1
    .addr enemy_destroyed_routine_01 ; CPU address $e9c1 - Level 2
    .addr enemy_destroyed_routine_02 ; CPU address $e9ca - Level 3
    .addr enemy_destroyed_routine_01 ; CPU address $e9c1 - Level 4
    .addr enemy_destroyed_routine_03 ; CPU address $e9cd - Level 5
    .addr enemy_destroyed_routine_04 ; CPU address $e9d1 - Level 6
    .addr enemy_destroyed_routine_05 ; CPU address $e9d4 - Level 7
    .addr enemy_destroyed_routine_06 ; CPU address $e9d9 - Level 8
    .addr enemy_destroyed_routine_00 ; CPU address $e9bf - common enemies (enemy type < #$10)

; table for enemy routine index when destroyed
; also used for falcon item or when boss is destroyed to destroy all enemies
; #$4 bits per enemy, 2 enemies per byte
; if enemy type is odd, then smaller nibble is used
; if enemy type byte is even, then high nibble is used
; keep in mind that all routines are offset by -2
;  * e.g. #$03 for the boss bomb turret would be routine boss_bomb_turret_routine_02
enemy_destroyed_routine_00:
    .byte $04 ; weapon item (00) / enemy bullet (01)
    .byte $53 ; pill box sensor (02)  / weapon zeppelin (03)

enemy_destroyed_routine_01:
    .byte $75 ; rotating gun (04) / running man (05)
    .byte $56 ; rifle man (06) / red turret (07)
    .byte $50 ; wall cannon (08) / unused
    .byte $44 ; wall plating (0a) / mortar shot (0b)
    .byte $44 ; scuba diver (0c) / unused
    .byte $43 ; turret man (0e) / turret man bullet
    .byte $33 ; boss bomb turret (10) / door plate with siren (11)
    .byte $20 ; exploding bridge (12)
    .byte $43 ; boss eye (10) / rollers (11)

enemy_destroyed_routine_02:
    .byte $45 ; grenades (12) / wall turret (13)
    .byte $53 ; core (14) / indoor soldier (15)
    .byte $33 ; jumping guy (16) / seeking guy (17)

enemy_destroyed_routine_03:
    .byte $43 ; group of 4 (18) / indoor soldier generator (19)
    .byte $33 ; rollers generator (1a) / sphere projectile (1b)
    .byte $43 ; boss gemini (1c) / spinning bubbles projectile (1d)
    .byte $54 ; blue jumping guy (1e) / red shooting guy (1f)

enemy_destroyed_routine_04:
    .byte $30 ; red/blue guys generator (20)
    .byte $22 ; rock platform (10) / moving flame (11)
    .byte $24 ; falling rock generator (rock cave) (12) / falling rock (13)

enemy_destroyed_routine_05:
    .byte $65 ; level 3 boss mouth (14) / level 3 dragon arm orb (15)
    .byte $33 ; ice grenade generator (10) / ice grenade (11)
    .byte $50 ; tank (12) / pipe joint (13)
    .byte $a5 ; boss ufo (14) / flying saucer (15)
    .byte $20 ; bomb drop (16)

enemy_destroyed_routine_06:
    .byte $00 ; fire beam down (10) / fire beam left (11)
    .byte $07 ; fire beam right (12) / giant boss robot (13)
    .byte $30 ; spiked disk projectile (14)
    .byte $05 ; mechanical claw (10) / raising spiked wall (11)
    .byte $30 ; spiked wall (12) / cart generator (13)
    .byte $44 ; cart moving (14) / cart immobile (15)
    .byte $35 ; armored door (16) / mortar launcher (17)
    .byte $50 ; enemy generator (18)
    .byte $43 ; alien guardian (10) / alien fetus (11)
    .byte $34 ; alien mouth (12) / white sentient blob (13)
    .byte $63 ; alien spider (14) / spider spawn (15)
    .byte $40 ; heart (16)

; falcon weapon - Destroy All Enemies (with exceptions like for pill box sensor, weapon zeppelin)
; also used when boss is defeated to remove all enemies
destroy_all_enemies:
    stx $10  ; store value of x register in $10 temporarily
    ldx #$0f ; x = #$0f

@enemy_loop:
    lda ENEMY_ROUTINE,x             ; load the current enemy routine pointer
    beq @continue                   ; skip to next enemy when no routine set for enemy
    lda ENEMY_SPRITES,x             ; load enemy tile sprite code
    beq @continue                   ; skip to next enemy when no sprite set for enemy
    lda ENEMY_TYPE,x                ; load current enemy type
    cmp #$02                        ; see if pill box sensor
    beq @continue                   ; skip to next enemy when enemy is pill box sensor
    cmp #$03                        ; see if flying capsule (weapon zeppelin)
    beq @continue                   ; skip to next enemy when enemy is flying capsule
    lda ENEMY_HP,x                  ; load enemy hp
.ifdef Probotector
    beq @continue                   ; !(WHY?) exit if enemy HP is already #$00, not sure of game play changes
                                    ; to have such a change between versions
.endif
    cmp #$f0                        ; f0 = no hit
    beq @continue                   ; skip to next enemy when enemy hp is #$f0
    jsr set_destroyed_enemy_routine ; regular enemy, set it to use its destroy routine
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    ora #$80                        ; set bits bit 7 to flag enemy as destroyed
    sta ENEMY_ATTRIBUTES,x

@continue:
    dex             ; go to next enemy (enemy logic starts high and goes to #$00)
    bpl @enemy_loop
    ldx $10         ; restore x attribute from before destroy_all_enemies call
    rts

remove_all_enemies:
    stx $10  ; store value of x register in $10 temporarily
    ldx #$0f ; x = #$0f (total number of possible enemies)

@loop:
    jsr remove_enemy ; remove enemy
    dex
    bpl @loop
    ldx $10          ; restore x attribute from before remove_all_enemies call
    rts

; sets background collision code to #$00 (empty) for a single super-tile, or #$10 pattern table tiles (4 2x2 tiles)
; at PPU address $12 (low) $13 (high)
; input
;  * PPU nametable collision address: $12 (low) and $13 (high)
clear_supertile_bg_collision:
    lda #$00 ; a = #$00

; updates background collision code for a single super-tile, or #$10 pattern table tiles (4 2x2 tiles)
; at PPU address $12 (low) $13 (high)
; input
;  * a - the bg collision code for the entire super-tile (4 2x2 tiles) [#$00-#$0f]
;  * PPU nametable collision address: $12 (low) and $13 (high)
set_supertile_bg_collision:
    tay

; updates background collision codes for a single super-tile, or #$10 pattern table tiles (4 2x2 tiles)
; at PPU address $12 (low) $13 (high)
; input
;  * a - left two collision tiles [#$00-#$0f]
;    * bits 0 and 1 - the top-left collision code (1 2x2 nametable tile)
;    * bits 2 and 3 - the bottom-left collision code (1 2x2 nametable tile)
;  * a - right two collision tiles [#$00-#$0f]
;    * bits 0 and 1 - the top-right collision code (1 2x2 nametable tile)
;    * bits 2 and 3 - the bottom-right collision code (1 2x2 nametable tile)
;  * PPU nametable collision address: $12 (low) and $13 (high)
set_supertile_bg_collisions:
    sta $11  ; save first 2x2 bg collision code to $11
    sty $14  ; save second 2x2 bg collision code to $11
             ; start calculation BG_COLLISION_DATA offset from PPU address, e.g. $2190 goes to #$1a
    lda $12  ; load low byte of PPU nametable address
    lsr      ; shift value to the right
    and #$03 ; get bits 1 and 2 of $12 before shifting
    sta $00  ; store bitmask offset in $00 [#$00-#$03]
    lda $13  ; load high byte of PPU nametable address
    and #$07 ; strip leading #$02 from nametable address high byte
             ; not used when calculating BG_COLLISION_DATA offset
    asl $12
    rol
    asl $12
    rol
    asl $12  ; ignore bit 5 of address low byte
             ; this ensures each every 2nd nametable row has same bg collision tile offset as nametable row above
    asl $12
    rol
    asl $12
    rol
    sta $04  ; set the in memory bg collision byte offset (BG_COLLISION_DATA)
    lda #$02 ; set number of times to call @set_half_supertile_bg_collisions to #$02
             ; each call @set_half_supertile_bg_collisions will update 2 bg collision tiles (2 2x2 nametable tiles)
    sta $01  ; store @set_half_supertile_bg_collisions call counter

@loop:
    lda $00                               ; load calculated bitmask index
    sta $02                               ; set bitmask index (0 = 0011 1111, 1 = 1100 1111, 2 = 1111 0011, 3 = 1111 1100)
    jsr @set_half_supertile_bg_collisions ; set the bg collision for the #$08 tiles on one (horizontal) half of the super-tile
    lsr $11
    lsr $11                               ; shift the bottom-left collision code into the lower bits for use
    lsr $14
    lsr $14                               ; shift the bottom right collision code into the lower bits for use
    lda $04                               ; load in memory bg collision byte offset (BG_COLLISION_DATA)
    clc                                   ; clear carry in preparation for addition
    adc #$04                              ; add #$04 to the current calculated bg collision byte offset (BG_COLLISION_DATA)
    sta $04                               ; move one bg collision row down to next BG_COLLISION_DATA collision byte offset
    dec $01                               ; decrement @set_half_supertile_bg_collisions counter
    bne @loop
    rts

; sets #$08 nametable tile collision code (#$02 bg collision tiles)
; for either the top or bottom horizontal half of the super-tile
@set_half_supertile_bg_collisions:
    lda $04  ; load in memory bg collision byte offset (BG_COLLISION_DATA)
    sta $07  ; set in memory bg collision byte offset (BG_COLLISION_DATA)
    lda #$01 ; a = #$01
    sta $06  ; set to update #$02 bg collision tiles (2 2x2 nametable tiles)

; input
;  * $02 - bitmask index (0 = 0011 1111, 1 = 1100 1111, 2 = 1111 0011, 3 = 1111 1100)
@set_quadrant_bg_collision:
    ldy $02                         ; load bitmask index (0 = 0011 1111, 1 = 1100 1111, 2 = 1111 0011, 3 = 1111 1100)
    lda bg_collision_bit_mask_tbl,y ; load bitmask value, these are the bits to remain unchanged
    sta $05                         ; store background collision mask in $05
    lda $06                         ; load one less than the number of bg collision tiles to update, #$01 or #$00
    lsr                             ; shift bit
    lda $11                         ; updating
    bcs @continue
    lda $14

@continue:
    and #$03 ; keep bits .... ..xx

; determine location of the #$02 collision bits within the collision byte
; by counting up to #$04 from the bitmask index shifting a each time twice
@find_bit_offset:
    iny                  ; increment bitmask index
    cpy #$04             ; see if last index
    bcs @set_collision   ; branch if last index to continue
    asl
    asl                  ; shift #$02 collision bits to the next portion of the bg collision byte
    jmp @find_bit_offset ; jump to see if new bit position is correct

@set_collision:
    sta $03                 ; store the background section's collision code, all other bits are 0
    ldy $07                 ; load in memory bg collision byte offset (BG_COLLISION_DATA)
    lda BG_COLLISION_DATA,y ; load the current byte (a byte specifies bg collision for #$08 pattern table tiles)
    and $05                 ; keep all other background collision values except the #$02 bits to update
    ora $03                 ; merge in the new background collision value
    sta BG_COLLISION_DATA,y ; update background collision for the #$02 pattern table tiles
    inc $02                 ; increment bitmask index
    lda $02                 ; load new bitmask index (0 = 0011 1111, 1 = 1100 1111, 2 = 1111 0011, 3 = 1111 1100)
    and #$03                ; keep bits .... ..xx
    sta $02                 ; set new value
    bne @check_next_loop    ; branch if still have a bg collision code to update
    inc $07                 ; increment bg collision byte offset (BG_COLLISION_DATA)

@check_next_loop:
    dec $06                        ; decrement number of bg collision tiles to update
    bpl @set_quadrant_bg_collision ; branch if more bg collision tiles to update the next quadrant of the super-tile
    rts

; table for bit masks (#$4 bytes)
; each 2 bits encode 2 pattern table tiles (1/4 of a super-tile's collision information)
; 0011 1111
; 1100 1111
; 1111 0011
; 1111 1100
bg_collision_bit_mask_tbl:
    .byte $3f,$cf,$f3,$fc

; create explosion #$89 at location ($09, $08)
create_explosion_89:
    lda #$89                      ; a = #$89
    sta $0a                       ; set explosion type to #$89
    lda #$09                      ; set ENEMY_ROUTINE to #$09 (enemy_routine_init_explosion)
    bne create_explosion_sequence ; always branch to create explosion animation, by using the weapon box's enemy routines

; creates 2 sets of explosion #$89 at location ($09, $08)
; input
;  * $09 - x location
;  * $08 - y location
create_two_explosion_89:
    lda #$89               ; set ENEMY_STATE_WIDTH to #$89 (explosion type)
    bne create_explosion_a ; always jump

; create new pill box sensor set to routine enemy_routine_init_explosion
; pill box sensor isn't important, it's just an enemy that has the enemy_routine_init_explosion routine sequence
; input
;  * $09 - x position to create enemy at
;  * $08 - y position to create enemy at
create_enemy_for_explosion:
    lda #$08 ; set ENEMY_STATE_WIDTH to #$08 (explosion type)

; input
;  * $09 - x position to create enemy at
;  * $08 - y position to create enemy at
create_explosion_a:
    sta $0a  ; set explosion type
    lda #$06 ; a = #$06 (enemy_routine_init_explosion, 2 rounds of explosions)

; input
;  * $09 - x position to create enemy at
;  * $08 - y position to create enemy at
create_explosion_sequence:
    sta $0b                  ; set weapon box enemy routine
    stx $10                  ; save x to be restored after function call
    jsr find_next_enemy_slot ; find next available enemy slot, put result in x register
    bne @exit                ; branch if no enemy slot was found
    lda #$02                 ; a = #$02, pill box sensor (weapon box)
                             ; used for enemy_routine_init_explosion, enemy_routine_explosion, enemy_routine_remove_enemy sequence
    sta ENEMY_TYPE,x         ; set current enemy type to pill box sensor (weapon box)
    jsr initialize_enemy     ; initialize enemy attributes
    lda $0b                  ; load enemy routine (#$06 for 2 explosions or #$09 for one explosion)
    sta ENEMY_ROUTINE,x      ; enemy routine index
    lda #$01                 ; a = #$01 (blank sprite)
    sta ENEMY_SPRITES,x      ; write enemy sprite code to CPU buffer
    lda $0a                  ; load explosion type
    sta ENEMY_STATE_WIDTH,x  ; set explosion type
    lda $08                  ; load y position of explosions
    sta ENEMY_Y_POS,x        ; set explosion y position on screen
    lda $09                  ; load x position of explosions
    sta ENEMY_X_POS,x        ; set explosion x position on screen

@exit:
    ldx $10 ; restore x from before create_explosion_sequence call
    rts

; level-boss defeated
;  * play sound code a
;  * set auto-move delay to #$ff
;  * set BOSS_DEFEATED_FLAG level boss defeated flag
; input
;  * a - play sound code
level_boss_defeated:
    jsr play_sound          ; play sound a
    lda #$ff
    sta DELAY_TIME_LOW_BYTE ; set auto-move delay to #$ff
    lda #$01
    sta BOSS_DEFEATED_FLAG  ; set BOSS_DEFEATED_FLAG to true
    rts

; set delay to a and remove enemy
set_delay_remove_enemy:
    sta DELAY_TIME_LOW_BYTE    ; various delays (low byte)
    lda #$00                   ; a = #$00
    sta DELAY_TIME_HIGH_BYTE   ; various delays (high byte)
    jmp remove_enemy           ; remove enemy
    lda #$01                   ; dead code !(UNUSED)
    bne enemy_state_width_or_a ; dead code !(UNUSED)

; set bit 7 of ENEMY_STATE_WIDTH,x
; bit 7 set to allow bullets to travel through enemy, e.g. boss mouth
disable_bullet_enemy_collision:
    lda #$80                   ; a = #$80
    bne enemy_state_width_or_a

; prevent player enemy collision check and allow bullets to pass through enemy
; set bits 0 and 7 of ENEMY_STATE_WIDTH,x
; bit 7 set to allow bullets to travel through enemy, e.g. weapon item
; bit 0 - #$00 test player-enemy collision, #$01 means to skip player-enemy collision test
disable_enemy_collision:
    lda #$81 ; x... ...x (msb and lsb set)

enemy_state_width_or_a:
    ora ENEMY_STATE_WIDTH,x        ; set msb and lsb bits to 1
    bne set_enemy_state_width_to_a

; enable enemy-player collision checking, e.g. fire beam collision with player
; bit 0 - #$00 test player-enemy collision, #$01 means to skip player-enemy collision test
enable_enemy_player_collision_check:
    lda #$fe                    ; a = #$fe
    bne enemy_state_width_and_a ; always branch

; allow bullets to collide with enemy, some enemies have bullets pass through, e.g. weapon item
enable_bullet_enemy_collision:
    lda #$7f                    ; a = #$7f
    bne enemy_state_width_and_a

; enable bullet-enemy collision and player-enemy collision checks
enable_enemy_collision:
    lda #$7e ; a = #$7e

enemy_state_width_and_a:
    and ENEMY_STATE_WIDTH,x

set_enemy_state_width_to_a:
    sta ENEMY_STATE_WIDTH,x
    rts

; add a to enemy y position on screen
add_a_to_enemy_y_pos:
    clc               ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x
    sta ENEMY_Y_POS,x ; enemy y position on screen
    rts

; add a to enemy x position on screen
add_a_to_enemy_x_pos:
    clc               ; clear carry in preparation for addition
    adc ENEMY_X_POS,x ; add to enemy x position on screen
    sta ENEMY_X_POS,x ; set enemy x position on screen
    rts

; set memory $08 and $09 to enemy X's Y and X position respectively
; output
;  * $08 - enemy y position
;  * $09 - enemy x position
;  * a - enemy y position
;  * y - enemy y position
set_08_09_to_enemy_pos:
    lda #$00 ; a = #$00
    tay

; adds register a to the enemy x position, stores result in $09
; adds register y to the enemy y position, stores result in $08
; input
;  * a - distance to add to x position
;  * y - distance to add to y position
; output
;  * $08 - y to the enemy y position
;  * $09 - a to the enemy x position
add_with_enemy_pos:
    clc               ; clear carry in preparation for addition
    adc ENEMY_X_POS,x ; add a to enemy x position on screen
    sta $09           ; store result in $09
    tya
    clc               ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x ; add a to enemy y position on screen
    sta $08           ; store value in $08
    rts

; add .06 to y velocity
add_10_to_enemy_y_fract_vel:
    lda #$10 ; a = #$10

; add a to enemy y fractional velocity, incorporating carry into fast y velocity
add_a_to_enemy_y_fract_vel:
    clc                          ; clear carry in preparation for addition
    adc ENEMY_Y_VELOCITY_FRACT,x ; add a to enemy y fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x ; store updated result in enemy y fractional velocity
    lda ENEMY_Y_VELOCITY_FAST,x  ; load the y fast velocity
    adc #$00                     ; add any carry from adding to fractional velocity
    sta ENEMY_Y_VELOCITY_FAST,x  ; store updated fast velocity if any carry occurred
    rts

; generate enemy at relative position 0,0 to current enemy
; input
;  * a - enemy type
; output
;  * a - #$01 when no enemy created, #$00 when enemy created
;  * y - created enemy slot number
generate_enemy_a:
    sta $0a
    lda #$00 ; a = #$00
    tay

; generate enemy type $0a at relative position a,y
; input
;  * $0a - enemy type
;  * a - x position
;  * y - y position
; output
;  * a - #$01 when no enemy created, #$00 when enemy created
;  * y - created enemy slot number
generate_enemy_at_pos:
    sty $08
    sta $09
    txa
    tay
    jsr find_next_enemy_slot ; find next available enemy slot, put result in x register
    bne @exit                ; no enemy slot, exit (find_next_enemy_slot sets zero flag when found, clears when not found)
    lda $0a                  ; load enemy type
    sta ENEMY_TYPE,x         ; set enemy type
    jsr initialize_enemy
    lda ENEMY_Y_POS,y        ; enemy y position on screen
    clc                      ; clear carry in preparation for addition
    adc $08
    sta ENEMY_Y_POS,x
    lda ENEMY_X_POS,y        ; load enemy x position on screen
    clc                      ; clear carry in preparation for addition
    adc $09
    sta ENEMY_X_POS,x        ; set enemy x position on screen
    txa
    tay
    ldx ENEMY_CURRENT_SLOT
    lda #$00                 ; a = #$00
    rts

@exit:
    ldx ENEMY_CURRENT_SLOT
    lda #$01               ; a = #$01
    rts

; add #$04 to the enemy y position accounting for VERTICAL_SCROLL overflow on vertical levels
add_4_to_enemy_y_pos:
    lda #$04

; add a to the enemy y position accounting for VERTICAL_SCROLL overflow on vertical levels
add_a_with_vert_scroll_to_enemy_y_pos:
    sta $01
    lda VERTICAL_SCROLL ; vertical scroll offset
    and #$0f            ; keep bits .... xxxx
    ora #$f0            ; set bits xxxx ....
    sta $00
    clc                 ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x   ; add vertical scroll to enemy Y position
    and #$f0            ; keep bits xxxx ....
    sec                 ; set carry flag in preparation for subtraction
    sbc $00
    clc                 ; clear carry in preparation for addition
    adc $01
    sta ENEMY_Y_POS,x   ; enemy y position on screen
    rts

; draw the nametable tiles from level_xx_tile_animation (a) at the enemy position
; sets animation delay for enemy to #$01 if successful
; input
;  * a - offset into level-specific tile_animation table, e.g. level_2_4_tile_animation
;        does not update palette, i.e. leave existing palette
; output
; * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_nametable_tiles_set_delay:
    jsr update_enemy_nametable_tiles_no_palette ; draw the nametable tiles from level_2_4_tile_animation (a) at the enemy position
    jmp update_nametable_set_anim_delay_exit

; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
; input
;  * a - super-tile code (offset into level_xx_nametable_update_supertile_data)
; output
; * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
draw_enemy_supertile_a_set_delay:
    jsr draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)

update_nametable_set_anim_delay_exit:
    bcc @exit                   ; exit if updated nametable tiles
    lda #$01                    ; a = #$01, animation delay
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

@exit:
    rts

; draw super-tile a (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
; input
;  * a - nametable update super-tile code (offset into level_xx_nametable_update_supertile_data)
; output
; * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
draw_enemy_supertile_a:
    sta $10

; draw super-tile $10 (offset into level nametable update table) at position (ENEMY_X_POS, ENEMY_Y_POS)
; input
;  * $10 - is the super-tile or palette index to draw (level_x_nametable_update_supertile_data/level_x_nametable_update_palette_data offset)
;  If bit 7 clear, then update palette, if bit 7 set do not update palette
; output
; * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
draw_enemy_supertile_10:
    lda ENEMY_Y_POS,x                          ; load enemy y position on screen
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$0c                                   ; subtract #$0c from enemy y position
    bcc nametable_update_exit                  ; exit if negative (off screen to the top)
    tay                                        ; transfer y position to y
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$0c                                   ; subtract #$0c from enemy x position
    bcc nametable_update_exit                  ; exit if negative (off screen to the left)
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    ldx ENEMY_CURRENT_SLOT
    rts

; draw two super-tiles, one on top of the other
; bit 7 of $10 and a control whether ot update palette:
;  * if bit 7 clear, then update palette, if bit 7 set do not update palette
; input
;  * $10 - first nametable update super-tile code (offset into level_xx_nametable_update_supertile_data)
;  * a - second nametable update super-tile code (offset into level_xx_nametable_update_supertile_data)
;  * y - whether or not to assign collision (0 - yes, 1 - skip)
; output
;  * carry flag - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_2_enemy_supertiles:
    sty $07                         ; store whether or not to assign collision in $07
    pha                             ; save a copy of a on the stack
    jsr draw_enemy_supertile_10     ; draw nametable update super-tile index specified
    pla                             ; restore a from before the draw_enemy_supertile_10 call
    bcs @exit                       ; exit if CPU_GRAPHICS_BUFFER is full
    sta $10
    lda $07                         ; load whether or not to set collision
    bne @continue                   ; skip collision setting if $07 is set
    lda #$00                        ; left side of super-tile bg collision (#$00 = empty collision codes)
    ldy #$0f                        ; right side of super-tile bg collision (#$0f = solid collision codes)
    jsr set_supertile_bg_collisions ; update bg collision codes for a single super-tile at PPU address $12 (low) $13 (high)

@continue:
    lda ENEMY_Y_POS,x                          ; load enemy y position on screen
    clc                                        ; clear carry in preparation for addition
    adc #$14                                   ; add #$14 to enemy y position
    bcs nametable_update_exit                  ; exit if off screen to the bottom
    tay                                        ; set update super-tile y position
    lda ENEMY_X_POS,x                          ; load enemy x position on screen
    sec                                        ; set carry flag in preparation for subtraction
    sbc #$0c                                   ; subtract #$0c from enemy x position
    bcc nametable_update_exit                  ; exit if off screen to the left
    jsr load_bank_3_update_nametable_supertile ; draw super-tile $10 at position (a,y)
    bcs @set_slot_exit                         ; exit if CPU_GRAPHICS_BUFFER is full
    lda $07                                    ; load whether or not to set collision
    bne @set_slot_exit                         ; exit if collision shouldn't be set
    lda #$01                                   ; left side of super-tile bg collision (#$01 = empty then solid collision codes)
    ldy #$01                                   ; right side of super-tile bg collision (#$01 = empty then solid collision codes)
                                               ; sets a horizontal ground collision area to walk on under a row of empty collision tiles
    jsr set_supertile_bg_collisions            ; update bg collision codes for a single super-tile at PPU address $12 (low) $13 (high)

@set_slot_exit:
    ldx ENEMY_CURRENT_SLOT

@exit:
    rts

; draws the nametable pattern table tiles specified by a at the enemy position
; ultimately, a (multiplied by #$05) is an offset into the level-specific tile_animation table
; input
;  * a - offset into level-specific tile_animation table, e.g. level_2_4_tile_animation
;        does not update palette, i.e. leave existing palette
; output
;  * carry - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_enemy_nametable_tiles_no_palette:
    ora #$80 ; do not update palette on nametable tile update

; draws the nametable pattern table tiles specified by a at the enemy position
; only called by bank 0 for wall turret and wall core
; ultimately, a (multiplied by #$05) is an offset into the level-specific tile_animation table
; input
; a - offset into level-specific tile_animation table, e.g. level_2_4_tile_animation
;     if bit 7 clear, then update palette, if bit 7 set do not update palette
; output
;  * carry - clear when successful, set when CPU_GRAPHICS_BUFFER is full
update_enemy_nametable_tiles:
    sta $10                                ; store offset in $10
    lda ENEMY_Y_POS,x                      ; load enemy y position on screen
    sec                                    ; set carry flag in preparation for subtraction
    sbc #$04                               ; subtract #$04 from y position (top)
    bcc nametable_update_exit
    tay                                    ; set enemy y position for load_bank_3_update_nametable_tiles
    lda ENEMY_X_POS,x                      ; load enemy x position on screen
    sec                                    ; set carry flag in preparation for subtraction
    sbc #$04                               ; subtract #$04 from x position (left)
    bcc nametable_update_exit
    jsr load_bank_3_update_nametable_tiles ; draw tile code $10 to nametable at (a, y)
    ldx ENEMY_CURRENT_SLOT                 ; restore x to point to current enemy
    rts

nametable_update_exit:
    clc
    ldx ENEMY_CURRENT_SLOT
    rts

; gets enemy's bg collision code and look for solid collision
; if collision with floor, load collision code one row down (half supertile)
; to see if it's a floor collision on top of a solid object
; output
;  * a - collision code of half row down if floor collision, otherwise, current collision code
;  * carry flag - set when collision code #$80 (solid)
check_enemy_collision_solid_bg:
    ldy #$00                                  ; y = #$00
    lda #$00                                  ; a = #$00
    jsr add_a_y_to_enemy_pos_get_bg_collision ; add a to X position and y to Y position; get bg collision code
    jmp floor_get_next_row_bg_collision       ; if floor collision, get next half supertile row's collision code
                                              ; below the $13 BG_COLLISION_DATA offset

; initializes $13 to the enemy X position, and y to enemy Y position, then calls get_enemy_bg_collision
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
init_vars_get_enemy_bg_collision:
    ldy #$00 ; y = #$00

; adds y to enemy y position and gets bg collision code
; input
;  * y - added to enemy Y position
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
add_y_to_y_pos_get_bg_collision:
    lda #$00 ; a = #$00

; adds a to X position and y to Y position for use in determining background collision
; ENEMY_X_POS and ENEMY_Y_POS are unaffected
; returns the bg collision code for current enemy
; input
;  * a - added to enemy X position
;  * y - added to enemy Y position
; output
;  * a collision code #$00 (empty), #$01 (floor), #$02 (water), or #$80 (solid)
;  * carry set when collision is with floor (#$01)
;  * negative flag set when solid collision (#$80)
add_a_y_to_enemy_pos_get_bg_collision:
    clc                        ; clear carry in preparation for addition
    adc ENEMY_X_POS,x          ; add to enemy x position on screen
    sta $13                    ; store enemy x position in $13 for get_enemy_bg_collision
    tya                        ; transfer amount to add to y enemy y position into a
    clc                        ; clear carry in preparation for addition
    adc ENEMY_Y_POS,x          ; add to enemy y position on screen
    bcs @exit                  ; exit if overflow, i.e. enemy y position is off screen towards bottom
    tay                        ; set enemy y position in y for bg collision detection
    jmp get_enemy_bg_collision ; get bg collision code for position ($13, y)

@exit:
    lda #$00 ; a = #$00
    rts

; dead code, never called !(UNUSED)
bank_7_unused_label_04:
    ldy #$00 ; y = #$00

; flying_capsule_routine_01 horizontal level
set_flying_capsule_y_vel:
    lda ENEMY_Y_POS,x            ; load enemy y position on screen
    sta $01
    lda ENEMY_VAR_1,x
    sta $03
    lda ENEMY_Y_VELOCITY_FAST,x
    sta $04
    lda ENEMY_Y_VELOCITY_FRACT,x
    sta $05
    jsr set_flying_capsule_path
    lda $00
    sta ENEMY_Y_VELOCITY_FAST,x
    lda $01
    sta ENEMY_Y_VELOCITY_FRACT,x
    rts

; dead code, never called !(UNUSED)
bank_7_unused_label_05:
    ldy #$00 ; y = #$00

; flying_capsule_routine_01 vertical level
; set various local variables to x velocity
; output
;  * $01 - ENEMY_X_POS
;  * $03 - ENEMY_VAR_2
;  * $04 - ENEMY_X_VELOCITY_FAST
;  * $05 - ENEMY_X_VELOCITY_FRACT
set_flying_capsule_x_vel:
    lda ENEMY_X_POS,x            ; load enemy x position on screen
    sta $01
    lda ENEMY_VAR_2,x
    sta $03
    lda ENEMY_X_VELOCITY_FAST,x
    sta $04
    lda ENEMY_X_VELOCITY_FRACT,x
    sta $05
    jsr set_flying_capsule_path
    lda $00
    sta ENEMY_X_VELOCITY_FAST,x
    lda $01                      ; load new fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x ; save new fractional velocity
    rts

; dead code, never called !(UNUSED)
bank_7_unused_label_06:
    ldy #$00 ; y = #$00

; creates flight pattern for flying capsule
; input
;  * $01 - ENEMY_X_POS or ENEMY_Y_POS
;  * $03 - ENEMY_VAR_2 or ENEMY_VAR_1 (amount to subtract from $01)
;  * $04 - ENEMY_X_VELOCITY_FAST or ENEMY_Y_VELOCITY_FAST
;  * $05 - ENEMY_X_VELOCITY_FRACT or ENEMY_Y_VELOCITY_FRACT
set_flying_capsule_path:
    lda $01            ; load position point (x or y position)
    sec                ; set carry flag in preparation for subtraction
    sbc $03            ; subtract ENEMY_VAR_1 or ENEMY_VAR_2 from x or y position
    sta $01            ; store new x position back in $01
    lda #$00           ; a = #$00
    sbc #$00           ; subtract #$00 and any overflow
    sta $00            ; new fractional velocity in $00
    sta $07            ; store overflow in $07
    tya                ; move overflow to a
    beq @set_vars_exit
    bmi @loop2

@loop:
    asl $01            ; shift left the x or y position
    rol $00            ; rotate fractional velocity left, bringing in any bit 7 from $01
    dey
    bne @loop
    beq @set_vars_exit

@loop2:
    lsr $07
    ror $00
    ror $01
    iny
    bne @loop2

@set_vars_exit:
    lda $05
    sec     ; set carry flag in preparation for subtraction
    sbc $01
    sta $01
    lda $04
    sbc $00
    sta $00
    rts

; red turret
red_turret_find_target_player:
    jsr player_enemy_x_dist ; a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    tya                     ; set the closest player to a #$00 for p1, #$01 for p2
    eor #$01                ; flip to other player
    sta $0c                 ; store farther player in $0c
    lda $08                 ; load player 1 x distance to enemy
    sta $0a                 ; store player 1 x distance to enemy in $0a
    lda $09                 ; load player 2 x distance to enemy
    sta $0b                 ; store player 2 x distance to enemy in $0b
    jsr player_enemy_y_dist ; a = closest y distance to enemy from players, y = closest player (#$00 or #$01)
    tya                     ; set the closest player to a #$00 for p1, #$01 for p2
    eor #$01                ; flip to other player
    cmp $0c                 ; compare farther y player to farther x player
    bne @continue           ; branch if not the same player
    tya                     ; one player is farther in both x and y axises, transfer farther player to a
    sta $0c                 ; transfer farther player to $0c

@continue:
    tax       ; transfer farther y player to x
    tay       ; transfer farther y player to y
    lda $08,x ; load the farther y player's distance
    ldx $0c   ; load the farther player's y distance
    cmp $0a,x ; compare farther player's x distance
    bcc @exit ; branch if
    ldy $0c   ; set y to the player to target
    lda $0a,x ; load

@exit:
    ldx ENEMY_CURRENT_SLOT
    rts

; calculates x distance between p1 and the enemy and p2 and the enemy
; stores shortest distance in a, player number in y
; input
;  * x - the current enemy offset
; output
;  * a - the shortest x distance to current enemy (either p1 or p2)
;  * y - the player closest, #$00 for p1, #$01 for p2
;  * $08 - p1 x distance
;  * $09 - p2 x distance
; when player state is not #$01, #$fe is stored in $08 or #$ff in $09
player_enemy_x_dist:
    lda SPRITE_X_POS    ; load player 1 x position
    sec                 ; prepare for subtraction
    sbc ENEMY_X_POS,x   ; enemy x position on screen
    bcs @continue_to_p2 ; branch if no overflow occurred
    eor #$ff            ; overflow occurred, flip bits and add one (two's compliment)
    adc #$01

@continue_to_p2:
    sta $08                 ; store distance between player and enemy in $08
    lda SPRITE_X_POS+1      ; load player 2 x position
    sec                     ; prepare for subtraction
    sbc ENEMY_X_POS,x       ; enemy x position on screen
    jmp lda_closer_distance ; jump to determine smallest of $08 (p1) and $09 (p2) store in a

; calculates y distance between p1 and p2 with the current enemy (x register)
; input
;  * x - the current enemy offset
; output
;  * a - the shortest y distance to current enemy (either p1 or p2)
;    if both players are in non-normal state, a is set to #$fe
;  * y - the player closest, #$00 for p1, #$01 for p2
;  * $08 - p1 y distance
;  * $09 - p2 y distance
; when player state is not #$01, #$fe is stored in $08 or #$ff in $09
player_enemy_y_dist:
    lda SPRITE_Y_POS    ; load player 1 y position
    sec                 ; prepare for subtraction
    sbc ENEMY_Y_POS,x   ; enemy y position on screen
    bcs @continue_to_p2 ; branch if no overflow occurred
    eor #$ff            ; overflow occurred, flip bits and add one (two's compliment)
    adc #$01

@continue_to_p2:
    sta $08            ; store distance between player and enemy in $08
    lda SPRITE_Y_POS+1 ; load player 2 y position
    sec                ; prepare for subtraction
    sbc ENEMY_Y_POS,x  ; enemy y position on screen

; take the smallest of $08 (p1) and $09 (p2) and store in a accounting for overflow
; ignoring non-normal player state
lda_closer_distance:
    bcs @continue
    eor #$ff      ; overflow occurred, flip bits and add one (two's compliment)
    adc #$01

@continue:
    sta $09          ; store player 2 x or y distance from current enemy in $09
    ldy #$fe         ; y = #$fe
    lda PLAYER_STATE ; load player state (#$00 dropping into level, #$01 normal, #$02 dead, #$03 can't move)
    cmp #$01
    beq @continue_p1 ; branch if player state is #$01 (normal)
    sty $08          ; player 1 state not normal, store #$fe in $08

@continue_p1:
    ldy #$ff           ; y = #$ff
    lda PLAYER_STATE+1 ; load 2nd player state (#$00 dropping into level, #$01 normal, #$02 dead, #$03 can't move)
    cmp #$01
    beq @set_closest   ; branch if p2 state is normal
    sty $09            ; player 2 state not normal, set to #$ff

@set_closest:
    lda $09   ; load player 2 distance (or #$ff if not normal)
    ldy #$01
    cmp $08   ; compare player 1 distance to player 2 distance
    bcc @exit ; branch if $09 < $08 (p2 is closer)
    dey       ; p1 is closer, ensure player specified is p1
    lda $08   ; load the closest distance

@exit:
    rts

; gets a number from #$06 to #$00 indicating how far the enemy at position $09 is from the left of the screen
; starting from #$06 for farthest left, down to #$00 for farthest right
; very similar to find_close_segment in bank 0
; usually used together to compare player and enemy x positions on indoor levels
; input
;  * $09 - current enemy X position
; output
;  * a velocity code
find_far_segment_for_x_pos:
    lda $09 ; load enemy X position

; gets a number from #$06 to #$00 indicating how far the enemy is from the left of the screen
; starting from #$06 for farthest left, down to #$00 for farthest right
; very similar to find_close_segment in bank 0
; usually used together to compare player and enemy x positions on indoor levels
find_far_segment_for_a:
    ldy #$06 ; y = #$06

@loop:
    cmp far_segment_code_tbl,y ; compare a to far_segment_code_tbl,y
    bcc @exit                  ; branch if a < far_segment_code_tbl,y
    dey                        ; a >= far_segment_code_tbl,y move to next larger velocity value
    bmi @use_code_0            ; if y became negative (shouldn't happen), use largest velocity code
    bcs @loop

@use_code_0:
    lda #$00 ; safety code, use #$00 velocity code
    rts

@exit:
    tya ; move far_segment_code_tbl into a
    rts

; table for segment based on distance (#$7 bytes)
far_segment_code_tbl:
    .byte $ff,$94,$8c,$84,$7c,$74,$6c

; grenade_routine_01
; weapon_item_routine_01 (indoor/base level only)
; creates a falling arc pattern by using X and Y velocities to update X and Y positions
; used for grenades and for weapon items in indoor/base levels
set_enemy_falling_arc_pos:
    lda ENEMY_VAR_2,x                     ; load ENEMY_VAR_2,x
    clc                                   ; clear carry in preparation for addition
    adc ENEMY_VAR_4,x                     ; add ENEMY_VAR_2,x and ENEMY_VAR_4,x
    sta ENEMY_VAR_2,x                     ; store result back in ENEMY_VAR_2,x
    lda ENEMY_VAR_3,x                     ; load ENEMY_VAR_3,x
    adc ENEMY_VAR_B,x                     ; add ENEMY_VAR_3,x and ENEMY_VAR_B,x along with any overflow carry
    sta ENEMY_VAR_3,x                     ; store result back in ENEMY_VAR_3,x
    lda ENEMY_Y_VEL_ACCUM,x               ; load ENEMY_Y_VEL_ACCUM,x
    clc                                   ; clear carry in preparation for addition
    adc ENEMY_Y_VELOCITY_FRACT,x          ; ENEMY_Y_VEL_ACCUM,x + ENEMY_Y_VELOCITY_FRACT,x
    sta ENEMY_Y_VEL_ACCUM,x               ; update ENEMY_Y_VEL_ACCUM,x to sum
    lda ENEMY_VAR_1,x                     ; load ENEMY_VAR_1,x
    adc ENEMY_Y_VELOCITY_FAST,x           ; ENEMY_Y_VELOCITY_FAST,x + ENEMY_VAR_1,x along with any overflow carry
    sta ENEMY_VAR_1,x                     ; update ENEMY_VAR_1,x with the result
    cmp #$f0                              ; if the enemy has fallen below the screen, remove it
    bcs @remove_enemy
    clc                                   ; clear carry in preparation for addition
    adc ENEMY_VAR_3,x
    sta ENEMY_Y_POS,x                     ; enemy y position on screen
    jmp update_enemy_x_pos_rem_off_screen ; add velocity to enemy X position; remove enemy if X position < #$08 (off screen to left)

@remove_enemy:
    jmp remove_enemy ; remove enemy

; weapon_item_routine_00 indoor level
; sets initial velocities for indoor level based on X position
; sets Y velocity to #$01 for the high byte and #$00 for the low byte
; doesn't use weapon_item_init_vel_tbl like outdoor levels
set_weapon_item_indoor_velocity:
    lda ENEMY_X_POS,x                  ; load enemy x position on screen
    jsr find_far_segment_for_a         ; find the appropriate velocity code, given the X position
    asl                                ; double since each entry is #$02 bytes
    tay
    lda weapon_item_indoor_vel_tbl,y   ; load X fractional velocity byte for velocity code
    sta ENEMY_X_VELOCITY_FRACT,x       ; set X fractional velocity byte
    lda weapon_item_indoor_vel_tbl+1,y ; load X velocity fast value for velocity code
    sta ENEMY_X_VELOCITY_FAST,x        ; set X velocity fast value (number of units to move in the X direction per frame)
    lda #$00                           ; a = #$00
    sta ENEMY_Y_VELOCITY_FRACT,x       ; set Y fractional velocity byte to #$00
    lda #$01                           ; a = #$01
    sta ENEMY_Y_VELOCITY_FAST,x        ; set Y velocity fast value to #$01
    rts

; two-byte values for weapon item X velocity in indoor levels (#$e bytes)
; byte 0 - X fractional velocity value
; byte 1 - X velocity fast value
weapon_item_indoor_vel_tbl:
    .byte $aa,$00 ;  aa 170 170 / 256 = 0.66
    .byte $71,$00 ;  71 113 113 / 256 = 0.44
    .byte $38,$00 ;  38 56  56 / 256 = 0.22
    .byte $00,$00 ;  00 0
    .byte $c8,$ff ; -38 -56  -56 / 256 = -0.22
    .byte $8f,$ff ; -71 -113 -113 / 256 = -0.44
    .byte $56,$ff ; -aa -170 -170 / 256 = -0.66

; find next available enemy slot (between slots 0 and 6)
; slots 0 to 6 are reserved for soldiers
; slot number is stored in x register
; zero flag set when found, not set when no slots available
find_next_enemy_slot_6_to_0:
    ldx #$06                        ; x = #$06
    bne find_next_enemy_slot_x_to_0

; find next available enemy slot (all slots 0-f)
; slot number is stored in x register
; zero flag set when found, not set when no slots available
find_next_enemy_slot:
    ldx #$0f ; x = #$0f

; slot number is stored in x register
find_next_enemy_slot_x_to_0:
    lda ENEMY_ROUTINE,x
    beq find_enemy_routine_slot_exit
    dex                              ; decrement offset
    bpl find_next_enemy_slot_x_to_0  ; if not zero loop to see if a lower index is available

find_enemy_routine_slot_exit:
    rts

find_bullet_slot:
    ldx #$0f ; x = #$0f

@loop:
    lda ENEMY_TYPE,x                 ; load current enemy type
    cmp #$01                         ; is enemy type a bullet
    beq find_enemy_routine_slot_exit
    dex
    bpl @loop
    ldx #$00                         ; no bullet found, return slot 0
    rts

; dead code, never called !(UNUSED)
; runs clear_enemy on all enemies
bank_7_unused_label_07:
    ldx #$0f ; set loop counter for enemies

@clear_next_enemy:
    jsr clear_enemy       ; clear current enemy vars
    dex                   ; decrement enemy offset
    bpl @clear_next_enemy ; branch if more enemies to clear
    rts

clear_sprite_clear_enemy_pt_3:
    lda #$00             ; a = #$00
    sta ENEMY_SPRITES,x  ; write enemy sprite code to CPU buffer
    beq clear_enemy_pt_3

clear_enemy_custom_vars:
    lda #$00             ; a = #$00
    beq clear_enemy_pt_4 ; always jump

; clear many of the enemy variables
clear_enemy:
    lda #$00            ; a = #$00
    sta ENEMY_ROUTINE,x
    sta ENEMY_HP,x
    sta ENEMY_TYPE,x
    sta ENEMY_SPRITES,x

clear_enemy_pt_2:
    sta ENEMY_ATTRIBUTES,x
    sta ENEMY_Y_POS,x
    sta ENEMY_X_POS,x
    sta ENEMY_Y_VEL_ACCUM,x
    sta ENEMY_X_VEL_ACCUM,x

clear_enemy_pt_3:
    sta ENEMY_SPRITE_ATTR,x
    sta ENEMY_Y_VELOCITY_FRACT,x
    sta ENEMY_X_VELOCITY_FRACT,x
    sta ENEMY_Y_VELOCITY_FAST,x
    sta ENEMY_X_VELOCITY_FAST,x
    sta ENEMY_ANIMATION_DELAY,x
    sta ENEMY_VAR_A,x
    sta ENEMY_ATTACK_DELAY,x
    sta ENEMY_FRAME,x
    sta ENEMY_STATE_WIDTH,x
    sta ENEMY_SCORE_COLLISION,x

clear_enemy_pt_4:
    sta ENEMY_VAR_1,x
    sta ENEMY_VAR_2,x
    sta ENEMY_VAR_3,x
    sta ENEMY_VAR_4,x
    rts

; initialize enemy attributes
; initialize enemy_routine index
; initialize enemy tiles
; initialize enemy hp
; initialize enemy position
initialize_enemy:
    lda #$01             ; a = #$01
    sta ENEMY_ROUTINE,x  ; initialize enemy routine index to ..._routine_00 (always off by one)
    sta ENEMY_SPRITES,x  ; write enemy sprite code to CPU buffer
    lda #$00             ; a = #$00
    jsr clear_enemy_pt_2 ; set many variables to a
    tya                  ; save existing value of y to stack so it isn't overwritten
    pha                  ; push on stack
    lda ENEMY_TYPE,x     ; load current enemy type
    cmp #$10             ; see if shared enemy (used across levels)
    ldy #$10
    bcc @continue        ; set to use enemy_prop_00 when for common/shared enemies (ENEMY_TYPE < #$10)
    lda CURRENT_LEVEL    ; not shared enemy type, load current level to figure out offset
    asl                  ; double since each entry in enemy_prop_ptr_tbl is #$02 bytes
    tay                  ; set offset based on current level

; y is offset enemy_prop_ptr_tbl
@continue:
    lda enemy_prop_ptr_tbl,y    ; load low byte of enemy_prop_xx address
    sta $8c                     ; store in $8c
    lda enemy_prop_ptr_tbl+1,y  ; load high byte of enemy_prop_xx address
    sta $8d                     ; store in $8d
    lda ENEMY_TYPE,x            ; load current enemy type
    asl
    asl                         ; quadruple since each entry is #$04 bytes
    tay
    lda ($8c),y                 ; load first byte of enemy_prop_XX
    sta ENEMY_STATE_WIDTH,x     ; set ENEMY_STATE_WIDTH
    iny
    lda ($8c),y                 ; read next byte of enemy_prop_XX
    sta ENEMY_SCORE_COLLISION,x ; set ENEMY_SCORE_COLLISION
    iny
    lda ($8c),y                 ; read next byte of enemy_prop_XX
    sta ENEMY_HP,x              ; set ENEMY_HP
    iny
    lda ($8c),y                 ; read next byte of enemy_prop_XX
    sta ENEMY_VAR_A,x           ; set ENEMY_VAR_A
    pla                         ; pull saved value of y from stack
    tay                         ; restore previous value of y from stack
    rts

; pointer table for enemy properties (#$9 * #$2 = #$12 bytes)
; enemy width, enemy score code, enemy collision box code, enemy HP, and enemy hit sound
enemy_prop_ptr_tbl:
    .addr enemy_prop_00 ; Level 1 - CPU address $ee9f
    .addr enemy_prop_01 ; Level 2 - CPU address $eeab
    .addr enemy_prop_02 ; Level 3 - CPU address $eeef
    .addr enemy_prop_01 ; Level 4 - CPU address $eeab
    .addr enemy_prop_04 ; Level 5 - CPU address $ef07
    .addr enemy_prop_05 ; Level 6 - CPU address $ef23
    .addr enemy_prop_06 ; Level 7 - CPU address $ef37
    .addr enemy_prop_07 ; Level 8 - CPU address $ef5b
    .addr enemy_prop_00 ; shared enemies (ENEMY_TYPE < #$10)

; (#$46 * #$4 = #$118 bytes)
; byte 0: ENEMY_STATE_WIDTH - related to facing direction and/or enemy width
; byte 1: ENEMY_SCORE_COLLISION - score code (bits 4-7), explosion type (bit 3), collision box code
; byte 2: ENEMY_HP - enemy hp
; byte 3: ENEMY_VAR_A
; shared enemies and level 1 enemies
enemy_prop_00:
    .byte $82,$22,$01,$00 ; weapon item (00)
    .byte $80,$00,$01,$00 ; enemy bullet (01)
    .byte $0f,$32,$f0,$00 ; weapon box (02)

; indoor/base level enemies
enemy_prop_01:
    .byte $0b,$32,$01,$00 ; flying capsule/weapon zeppelin (03)
    .byte $8f,$22,$08,$00 ; rotating gun (04)
    .byte $83,$10,$01,$00 ; running man (05)
    .byte $83,$30,$01,$00 ; rifle man (06)
    .byte $8f,$30,$08,$00 ; red turret (07)
    .byte $0f,$52,$f1,$00 ; triple cannon (08)
    .byte $00,$00,$01,$00 ; ? (09)
    .byte $0f,$42,$f0,$00 ; wall plating (0a)
    .byte $8a,$05,$01,$00 ; mortar shot (0b)
    .byte $83,$42,$01,$00 ; scuba diver (0c)
    .byte $00,$00,$01,$00 ; ? (0d)
    .byte $0e,$33,$0a,$00 ; turret man (0e)
    .byte $80,$01,$01,$00 ; turret man bullet (0f)

; level 1 specific enemies
    .byte $0f,$42,$10,$00 ; boss bomb turret (10)
    .byte $0c,$82,$20,$00 ; door plate with siren (11)
    .byte $89,$00,$01,$00 ; exploding bridge (12)

; level 2/4 enemies
    .byte $8d,$02,$01,$00 ; boss eye (10)

enemy_prop_02:
    .byte $2f,$22,$05,$00 ; rollers (11)
    .byte $81,$03,$01,$00 ; grenades (12)
    .byte $9f,$35,$04,$00 ; wall cannon (13)
    .byte $9f,$05,$01,$00 ; core (14)
    .byte $13,$16,$01,$00 ; running guy (15)
    .byte $13,$16,$01,$00 ; jumping guy (16)

enemy_prop_04:
    .byte $13,$36,$01,$00 ; seeking guy (17)
    .byte $13,$16,$01,$00 ; group of 4 (18)
    .byte $89,$00,$f1,$00 ; green guys generator (19)
    .byte $81,$00,$f1,$00 ; rollers generator (1a)
    .byte $8f,$13,$02,$01 ; sphere projectile (1b)
    .byte $8f,$02,$01,$00 ; boss gemini (1c)
    .byte $0a,$15,$01,$00 ; spinning bubbles projectile (1d)

enemy_prop_05:
    .byte $03,$30,$01,$00 ; blue jumping guy (1e)
    .byte $03,$30,$01,$00 ; red shooting guy (1f)
    .byte $81,$00,$f1,$00 ; red/blue guys generator (20)

; level 3 enemies
    .byte $c0,$04,$f0,$00 ; floating rock platform (10)
    .byte $80,$02,$f0,$00 ; moving flame (11)

enemy_prop_06:
    .byte $81,$00,$f0,$00 ; falling rock generator (12)
    .byte $8f,$31,$05,$00 ; falling rock (13)
    .byte $8d,$83,$f1,$02 ; level 3 boss mouth (14)
    .byte $0e,$52,$f1,$00 ; level 3 dragon arm orb (15)

; level 5 enemies
    .byte $81,$00,$f0,$00 ; grenade generator (10)
    .byte $81,$02,$f1,$00 ; grenade (11)
    .byte $85,$79,$f0,$00 ; tank (12)
    .byte $81,$00,$f0,$00 ; pipe joint (13)
    .byte $8d,$93,$20,$00 ; alien carrier (14)

enemy_prop_07:
    .byte $02,$20,$01,$00 ; flying saucer (15)
    .byte $0a,$12,$01,$00 ; bomb drop (16)

; level 6 enemies
    .byte $81,$0f,$f0,$00 ; fire beam - down (10)
    .byte $81,$0f,$f0,$00 ; fire beam - left (11)
    .byte $81,$0f,$f0,$00 ; fire beam - right (12)
    .byte $04,$9d,$01,$02 ; boss robot (13)
    .byte $80,$05,$01,$00 ; spiked disk projectile (14)

; level 7 enemies
    .byte $80,$0a,$f0,$00 ; mechanical claw (10)
    .byte $8d,$0f,$10,$00 ; raising spiked wall (11)
    .byte $0c,$0f,$10,$00 ; spiked wall (12)
    .byte $81,$00,$f0,$00 ; cart generator (13)
    .byte $6e,$0c,$03,$00 ; cart - moving (14)
    .byte $6e,$0c,$03,$00 ; cart - immobile (15)
    .byte $0c,$93,$20,$00 ; armored door (16)
    .byte $8f,$72,$08,$00 ; mortar launcher (17)
    .byte $89,$00,$01,$00 ; enemy generator (18)

; level 8 enemies
    .byte $04,$78,$01,$02 ; alien guardian (10)
    .byte $06,$22,$01,$01 ; alien fetus (11)
    .byte $06,$42,$01,$01 ; alien mouth (12)
    .byte $02,$22,$01,$00 ; white sentient blob (13)
    .byte $06,$33,$01,$01 ; alien spider (14)
    .byte $06,$62,$10,$01 ; spider spawn (15)
    .byte $04,$a7,$01,$03 ; heart (16)

; pointer table for triple cannon (#$9 * #$2 = #$12 bytes)
wall_cannon_routine_ptr_tbl:
    .addr wall_cannon_routine_00       ; CPU address $efc7 - set hp to #$08, animation delay to #$50, advance routine
    .addr wall_cannon_routine_01       ; CPU address $efd4
    .addr wall_cannon_routine_02       ; CPU address $f007
    .addr wall_cannon_routine_03       ; CPU address $f048
    .addr wall_cannon_routine_04       ; CPU address $f06d
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

; set hp to #$08, animation delay to #$50, advance routine
wall_cannon_routine_00:
    lda #$08          ; a = #$08 (hp for triple cannon)
    sta ENEMY_VAR_1,x ; set hp
    lda #$50          ; a = #$50

; set the animation delay to a and advanced the ENEMY_ROUTINE
; input
;  * a - the ENEMY_ANIMATION_DELAY
; this label is identical to two other labels
;  * bank 0 - set_anim_delay_adv_enemy_routine_00
;  * bank 0 - set_anim_delay_adv_enemy_routine_01
set_anim_delay_adv_enemy_routine:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jmp advance_enemy_routine   ; advance to next routine

wall_cannon_routine_01:
    lda ENEMY_ATTACK_FLAG       ; see if enemies should attack
    beq wall_cannon_exit        ; exit if enemies shouldn't attack
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne wall_cannon_exit        ; exit if animation delay hasn't elapsed
    jsr animate_wall_cannon     ; animation delay elapsed, animate wall cannon
    bcs wall_cannon_exit        ; exit if unable to update the nametable to try again next frame
    lda ENEMY_FRAME,x           ; load enemy animation frame number
    cmp #$02
    bcs wall_cannon_set_delays
    inc ENEMY_FRAME,x           ; increment enemy animation frame number

wall_cannon_exit:
    rts

; used only by wall_cannon_routine_01
wall_cannon_set_delays:
    lda ENEMY_VAR_1,x                    ; load enemy hp
    sta ENEMY_HP,x                       ; store hp temporarily
    lda #$04                             ; a = #$04
    sta ENEMY_ATTACK_DELAY,x             ; set delay between attacks
    lda #$40                             ; a = #$40 (delay between attack and closing)
    bne set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to #$40 and advance enemy routine

animate_wall_cannon:
    lda #$06                             ; a = #$06 (delay between frames when open/close)
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    lda ENEMY_FRAME,x                    ; load enemy animation frame number
    jmp draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position

wall_cannon_routine_02:
    lda ENEMY_ATTACK_DELAY,x ; load delay between attacks
    beq @continue            ; skip creating bullet if delay is #$00
    dec ENEMY_ATTACK_DELAY,x ; decrement delay between attacks
    bne @continue            ; skip creating bullet if delay not #$00
    lda #$02                 ; delay has elapsed, a = #$02 (number of bullets to fire)
    sta $16                  ; set number of bullets to fire to #$02 (#$03 bullets)

@create_bullet_loop:
    ldy $16                                 ; load remaining number of bullets to fire
    lda wall_cannon_bullet_x_offset,y       ; set horizontal offset from enemy position (param for add_with_enemy_pos)
    ldy #$08                                ; set vertical offset from enemy position (param for add_with_enemy_pos)
    jsr add_with_enemy_pos                  ; stores absolute screen x position in $09, and y position in $08
    ldy $16                                 ; load remaining number of bullets to fire
    lda wall_cannon_bullet_type_and_angle,y ; load bullet type (xxx. ....) and angle index (...x xxxx)
    ldy #$07                                ; set bullet speed to #$07
    jsr create_enemy_bullet_angle_a         ; create a bullet with speed y, bullet type a, angle a at position ($09, $08)
    dec $16                                 ; decrement number of bullets to fire
    bpl @create_bullet_loop

@continue:
    dec ENEMY_ANIMATION_DELAY,x          ; decrement enemy animation frame delay counter
    bne wall_cannon_exit
    lda ENEMY_HP,x                       ; load enemy hp
    sta ENEMY_VAR_1,x                    ; store enemy hp while invulnerable
    lda #$f1                             ; a = #$f1 (f1 = hittable, no damage)
    sta ENEMY_HP,x                       ; set enemy hp
    lda #$06                             ; a = #$06
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to #$06 and advance enemy routine

; table for bullets starting x positions (#$3 bytes)
wall_cannon_bullet_x_offset:
    .byte $f8,$00,$08

; table for bullets type and angle (#$3 bytes)
wall_cannon_bullet_type_and_angle:
    .byte $48,$46,$44

wall_cannon_routine_03:
    dec ENEMY_ANIMATION_DELAY,x               ; decrement enemy animation frame delay counter
    bne wall_cannon_exit
    jsr animate_wall_cannon
    bcs wall_cannon_exit_01
    lda ENEMY_FRAME,x                         ; load enemy animation frame number
    beq wall_cannon_calc_delay_set_routine_01
    dec ENEMY_FRAME,x                         ; decrement enemy animation frame number

wall_cannon_exit_01:
    rts

wall_cannon_calc_delay_set_routine_01:
    lda PLAYER_WEAPON_STRENGTH
    cmp #$02                      ; if weapon strength < 2
    lda #$c0                      ; a = #$c0 (delay for weapon strength 0-1)
    bcc @set_delay_set_routine_01
    lda #$60                      ; a = #$60 (delay for weapon strength 2-3)

@set_delay_set_routine_01:
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to wall_cannon_routine_01

wall_cannon_routine_04:
    lda #$05                   ; a = #$05 (tile code after destruction)
    jsr draw_enemy_supertile_a ; draw super-tile a at position (ENEMY_X_POS, ENEMY_Y_POS)
    bcs wall_cannon_exit_01
    jmp advance_enemy_routine  ; advance to next routine

; pointer table for wall plating (#$7 * #$2 = #$e bytes)
; level 2/4 boss screen targets
;  * 4 exist on level 2 boss screen
;  * 3 exist on level 4 boss screen
wall_plating_routine_ptr_tbl:
    .addr wall_plating_routine_00      ; CPU address $f085
    .addr wall_plating_routine_01      ; CPU address $f08a
    .addr wall_plating_routine_02      ; CPU address $f0b0
    .addr wall_plating_routine_03      ; CPU address $f0b1
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

; wall plating - pointer 0
wall_plating_routine_00:
    lda #$80                             ; a = #$80 (delay before deployment)
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to #$80 and advance enemy routine

; wall plating - pointer 1
wall_plating_routine_01:
    dec ENEMY_ANIMATION_DELAY,x          ; decrement enemy animation frame delay counter
    bne wall_plating_routine_02
    lda #$04                             ; a = #$04 (delay between frames when deploying)
    sta ENEMY_ANIMATION_DELAY,x          ; set enemy animation frame delay counter
    lda ENEMY_FRAME,x                    ; load enemy animation frame number (#$00 to #$03)
    clc                                  ; clear carry in preparation for addition
    adc #$03                             ; draw the appropriate frame of the animation (level_2_4_nametable_update_supertile_data offset)
    jsr draw_enemy_supertile_a_set_delay ; draw pattern table tile specified in a at enemy position
    bcs wall_plating_routine_02
    inc ENEMY_FRAME,x                    ; increment enemy animation frame number
    lda ENEMY_FRAME,x                    ; load enemy animation frame number
    cmp #$02                             ; see if wall plating is now open
    bcc wall_plating_routine_02          ; exit if wall cannon is open
    lda #$0a                             ; a = #$0a (hp for wall plating)
    sta ENEMY_HP,x                       ; set enemy hp
    bcs wall_plating_adv_enemy_routine

; wall plating - pointer 2
wall_plating_routine_02:
    rts

; wall plating - pointer 3
; called when enemy is destroyed
wall_plating_routine_03:
    lda #$05                         ; a = #$05 (level_2_4_nametable_update_supertile_data offset)
    jsr draw_enemy_supertile_a       ; draw destroyed wall plating super-tile
    bcs wall_plating_routine_02      ; exit
    inc WALL_PLATING_DESTROYED_COUNT ; increment number of boss platings destroyed

wall_plating_adv_enemy_routine:
    jmp advance_enemy_routine ; advance to next routine

; pointer table for turret man (#$6 * #$2 = #$c bytes)
turret_man_routine_ptr_tbl:
    .addr turret_man_routine_00        ; CPU address $f0c9
    .addr turret_man_routine_01        ; CPU address $f0db
    .addr turret_man_routine_02        ; CPU address $f0ec
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

turret_man_routine_00:
    lda #$bd                             ; a = #$bd (sprite_bd)
    sta ENEMY_SPRITES,x                  ; write enemy sprite code to CPU buffer
    lda ENEMY_ATTRIBUTES,x               ; load enemy attributes
    asl
    asl
    asl
    asl                                  ; shift low nibble to high nibble
    clc                                  ; clear carry in preparation for addition
    adc #$01                             ; add one
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to a and advance enemy routine

turret_man_routine_01:
    jsr add_scroll_to_enemy_pos          ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x          ; decrement enemy animation frame delay counter
    bne turret_man_exit
    inc ENEMY_SPRITES,x                  ; increment enemy sprite code to CPU buffer
    lda #$05                             ; a = #$05 (recoil delay)
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to #$05 and advance enemy routine

turret_man_exit:
    rts

turret_man_routine_02:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne turret_man_exit
    lda #$0c                    ; a = #$0c (sound_0c)
    jsr play_sound              ; play machine gun (M weapon) sound
    lda #$0f                    ; a = #$0f (enemy code of projectile)
    sta $0a
    lda #$f0                    ; a = #$f0
    ldy #$fc                    ; y = #$fc
    jsr generate_enemy_at_pos   ; generate enemy type $0a at relative position a,y
    lda ENEMY_ATTRIBUTES,x      ; load enemy attributes
    asl
    asl
    asl
    asl
    clc                         ; clear carry in preparation for addition
    adc #$30                    ; delay between shots (attr. * 10 + 30)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    dec ENEMY_SPRITES,x         ; decrement enemy sprite code to CPU buffer
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to a

; pointer table for turret man bullet (#$3 * #$2 = #$6 bytes)
turret_man_bullet_routine_ptr_tbl:
    .addr turret_man_bullet_routine_00 ; CPU address $f11f
    .addr turret_man_bullet_routine_01 ; CPU address $f131
    .addr remove_enemy                 ; Remove Enemy - CPU address $e809

; turret man bullet - pointer 1
turret_man_bullet_routine_00:
    lda #$fd                     ; a = #$fd
    sta ENEMY_X_VELOCITY_FAST,x
    lda #$80                     ; a = #$80
    sta ENEMY_X_VELOCITY_FRACT,x
    lda #$1f                     ; a = #$1f (sprite_1f)
    sta ENEMY_SPRITES,x          ; write enemy sprite code to CPU buffer

turret_man_adv_routine:
    jmp advance_enemy_routine ; advance to next routine

; turret man bullet - pointer 2
turret_man_bullet_routine_01:
    lda ENEMY_X_POS,x          ; load enemy x position on screen
    cmp #$f0
    bcs turret_man_adv_routine
    jmp update_enemy_pos       ; apply velocities and scrolling adjust

; pointer table for scuba diver (#$6 * #$2 = #$c bytes)
scuba_soldier_routine_ptr_tbl:
    .addr scuba_soldier_routine_00     ; CPU address $f147
    .addr scuba_soldier_routine_01     ; CPU address $f14c
    .addr scuba_soldier_routine_02     ; CPU address $f183
    .addr enemy_routine_init_explosion ; CPU address $e74b
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

scuba_soldier_routine_00:
    lda #$80                             ; a = #$80 (delay before first attack)
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY counter to #$80; advance enemy routine

; hides in water, bumping up every #$08 frames until activated
;  * for vertical levels, scuba soldiers aren't activated until towards bottom 72% of screen
;  * snow field level has scuba soldiers at bottom of screen already so no scroll activation delay.
;    only timer delay
; if already activated from scuba_soldier_routine_02, simply wait for delay timer to elapse
scuba_soldier_routine_01:
    lda #$4b                    ; a = #$4b (sprite_4b scuba soldier hiding)
    sta ENEMY_SPRITES,x         ; write enemy sprite code to CPU buffer
    lda ENEMY_ANIMATION_DELAY,x ; load enemy animation frame delay counter
    asl                         ; first execution is #$00, but can be set from
    asl                         ; scuba_soldier_routine_02 after firing mortar
    asl
    asl
    lda #$08                    ; a = #$08
    bcc @continue               ; #$07 out of every #$08 frames use #$08, otherwise use #$00
    lda #$00                    ; a = #$00

@continue:
    sta ENEMY_SPRITE_ATTR,x     ; set gun recoil flag value
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    dec ENEMY_ANIMATION_DELAY,x ; decrement enemy animation frame delay counter
    bne @exit                   ; exit if animation delay hasn't elapsed
    lda ENEMY_Y_POS,x           ; load enemy y position on screen
    cmp #$b8                    ; if vertical, don't shoot until this height
    bcs @activate_scuba_soldier ; scuba soldier is at heigh #$b8 or higher (lower on screen), 'activate' enemy
    lda #$10                    ; wait another #$10 frames before checking again
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter

@exit:
    rts

; enable enemy collisions, set attack delay to #$10, set animation delay to #$30,
; advance routine to scuba_soldier_routine_02
@activate_scuba_soldier:
    jsr enable_enemy_collision           ; enable bullet-enemy collision and player-enemy collision checks
    lda #$10                             ; a = #$10 (delay between aim and fire)
    sta ENEMY_ATTACK_DELAY,x             ; set delay between attacks
    lda #$30                             ; a = #$30 (total delay of vulnerability)
    jmp set_anim_delay_adv_enemy_routine ; set ENEMY_ANIMATION_DELAY to #$30 and advance enemy routine

; scuba soldier activated, set sprite, and fire mortar shot, then go back to scuba_soldier_routine_01
scuba_soldier_routine_02:
    lda #$4c            ; a = #$4c (sprite_4c scuba soldier out of water shooting up)
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer
    lda #$00            ; a = #$00
    ldy ENEMY_VAR_1,x   ; load gun recoil delay timer
    beq @continue       ; continue to firing logic, if elapsed
    dec ENEMY_VAR_1,x   ; recoil delay timer elapsed, set gun recoil
    lda #$08            ; a = #$08 (gun recoil flag)

; create mortar shot (#$07) if timers have elapsed
@continue:
    sta ENEMY_SPRITE_ATTR,x            ; set/clear gun recoil flag
    dec ENEMY_ANIMATION_DELAY,x        ; decrement enemy animation frame delay counter
    beq @disable_and_dec_enemy_routine ; branch if animation delay has elapsed
    dec ENEMY_ATTACK_DELAY,x           ; decrement delay between attacks
    bne @add_scroll_exit               ; exit if attack delay hasn't elapsed
    lda #$07                           ; a = #$07 (recoil delay)
    sta ENEMY_VAR_1,x                  ; store recoil timer
    lda #$0b                           ; a = #$0b (mortar shot)
    sta $0a                            ; set enemy type to #$0b (mortar shot)
    ldy #$e8                           ; y = #$e8 (mortar initial relative y position)
    lda #$05                           ; a = #$05 (mortar initial relative x position)
    jsr generate_enemy_at_pos          ; generate enemy type #$0b at relative position (#$05,#$e8)

@add_scroll_exit:
    jmp add_scroll_to_enemy_pos ; add scrolling to enemy position

@disable_and_dec_enemy_routine:
    jsr add_scroll_to_enemy_pos ; add scrolling to enemy position
    lda #$c0                    ; a = #$c0 (delay hidden in water)
    sta ENEMY_ANIMATION_DELAY,x ; set enemy animation frame delay counter
    jsr disable_enemy_collision ; prevent player enemy collision check and allow bullets to pass through enemy
    lda #$02                    ; a = #$02
    jmp set_enemy_routine_to_a  ; set enemy routine index to scuba_soldier_routine_01

; pointer table for mortar shot (#$9 * #$2 = #$12 bytes)
mortar_shot_routine_ptr_tbl:
    .addr mortar_shot_routine_00       ; CPU address $f1d6 - set explosion sound, sprite, palette, and velocities
    .addr mortar_shot_routine_01       ; CPU address $f237
    .addr mortar_shot_routine_02       ; CPU address $f26e - mortar shot falling down, create 3 split mortar rounds
    .addr enemy_routine_init_explosion ; CPU address $e74b - mortar collide with player (enemy destroyed routine)
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806
    .addr mortar_shot_routine_03       ; CPU address $e752 - split mortar collide with ground routine, play explosion sound, update collision, hide sprite
    .addr enemy_routine_explosion      ; CPU address $e7b0
    .addr enemy_routine_remove_enemy   ; CPU address $e806

; set explosion sound, sprite, palette, and velocities
mortar_shot_routine_00:
    lda #$8a               ; a = #$8a (type of explosion for main shot)
                           ; explosion_type_01, with explosion noise 1
    ldy ENEMY_ATTRIBUTES,x ; load mortar shot enemy attributes
    beq @continue          ; branch if no attributes, using custom explosion
    lda #$80               ; default 0 explosion

@continue:
    sta ENEMY_STATE_WIDTH,x    ; set explosion and specify player bullets travel through enemy
    lda #$20                   ; a = #$20 (sprite_20) S bullet, mortar
    sta ENEMY_SPRITES,x        ; write enemy sprite code to CPU buffer
    lda #$06                   ; a = #$06 (use palette #$02)
    sta ENEMY_SPRITE_ATTR,x    ; set palette
    lda ENEMY_ATTRIBUTES,x     ; load enemy attributes
    bne @set_mortar_velocities ; branch if enemy attributes specified (hangar zone boss screen)
    lda ENEMY_VAR_1,x          ; load mortar_shot_velocity_tbl offset
    beq @set_mortar_velocities ; skip offset if using default mortar shot
    clc                        ; hangar zone boss screen specified initial aim direction,
                               ; use ENEMY_VAR_1 to get velocities
                               ; clear carry in preparation for addition
    adc #$03                   ; aimed enemy mortar shots start at offset 4
                               ; e.g. ENEMY_VAR_1 would be $00,$fb,$c0,$ff

@set_mortar_velocities:
    asl
    asl                              ; quadruple since each entry is #$04 bytes
    tay                              ; transfer to offset register
    lda mortar_shot_velocity_tbl,y   ; load mortar shot fractional y velocity
    sta ENEMY_Y_VELOCITY_FRACT,x     ; set mortar shot fractional y velocity
    lda mortar_shot_velocity_tbl+1,y ; load mortar shot fast y velocity
    sta ENEMY_Y_VELOCITY_FAST,x      ; set mortar shot fast y velocity
    lda mortar_shot_velocity_tbl+2,y ; load mortar shot fractional x velocity
    sta ENEMY_X_VELOCITY_FRACT,x     ; set mortar shot fractional x velocity
    lda mortar_shot_velocity_tbl+3,y ; load mortar shot fast x velocity
    sta ENEMY_X_VELOCITY_FAST,x      ; set mortar shot fast x velocity

mortar_shot_adv_routine:
    jmp advance_enemy_routine ; advance to next routine

; table for mortar velocities (#$20 bytes)
; byte 0 - mortar shot fractional y velocity
; byte 1 - mortar shot fast y velocity
; byte 2 - mortar shot fractional x velocity
; byte 3 - mortar shot fast x velocity
mortar_shot_velocity_tbl:
    .byte $00,$fb,$00,$00 ; ( -5 ,     0      ) default initial mortar shot (straight up fast)
    .byte $00,$fe,$00,$00 ; ( -2 ,     0      ) one of 3 split mortar shot (straight up slow)
    .byte $40,$fe,$90,$00 ; ( -1.75 ,  0.5625 ) right of 3 split mortar shot
    .byte $40,$fe,$70,$ff ; ( -1.75 , -0.5625 ) left of 3 split mortar shot

; values for initial launch velocity on hangar zone
    .byte $00,$fb,$c0,$ff ; ( -5    , -0.25   ) - ENEMY_VAR_1 - 1 (aim slight left)
    .byte $00,$fb,$80,$ff ; ( -5    , -0.5    ) - ENEMY_VAR_1 - 2 (aim farther left)
    .byte $00,$fb,$40,$ff ; ( -5    , -0.75   ) - ENEMY_VAR_1 - 3 (aim even farther left)
    .byte $00,$fb,$00,$ff ; ( -5    , -1      ) - ENEMY_VAR_1 - 4 (aim farthest left)

; apply gravity, apply velocity, advance routine if reached apex of initial mortar shot
mortar_shot_routine_01:
    jsr add_10_to_enemy_y_fract_vel ; add #$10 (gravity) to y fractional velocity (.06 faster)
    jsr update_enemy_pos            ; apply velocities and scrolling adjust
    lda ENEMY_ATTRIBUTES,x          ; load enemy attributes
    bne @split_mortar               ; branch if not initial mortar shot
    lda ENEMY_Y_VELOCITY_FAST,x     ; initial mortar shot, load y fast velocity
    bpl mortar_shot_adv_routine     ; advance to next routine if mortar falling down
    lda ENEMY_Y_POS,x               ; load enemy y position on screen
    cmp #$30                        ; height for mortar to divide
    bcc mortar_shot_adv_routine     ; branch if mortar shot has reached its apex to advance the routine

@mortar_shot_routine_01_exit:
    rts

; split mortar shot, e.g. ENEMY_ATTRIBUTES > 0, check collision if necessary if so
@split_mortar:
    lda ENEMY_Y_VELOCITY_FAST,x          ; load fast y velocity
    bmi @mortar_shot_routine_01_exit     ; exit if y split mortar is still shooting up
    jsr player_enemy_x_dist              ; split mortar falling, a = closest x distance to enemy from players, y = closest player (#$00 or #$01)
    lda ENEMY_Y_POS,x                    ; load enemy y position on screen
    cmp SPRITE_Y_POS,y                   ; compare closest player by x distance's y position to current enemy y position
    bcc @mortar_shot_routine_01_exit     ; exit if mortar shot y position is higher than closest player is
    jsr init_vars_get_enemy_bg_collision ; initialize required memory and call get_enemy_bg_collision to determine bg collision
    beq @mortar_shot_routine_01_exit     ; exit if no bg collision
    lda #$24                             ; bg collision, a = #$24 (sound_24)
    jsr play_sound                       ; play explosion sound
    lda #$07                             ; a = #$07
    jmp set_enemy_routine_to_a           ; set enemy routine index to mortar_shot_routine_03

; mortar shot falling down, create 3 split mortar rounds
mortar_shot_routine_02:
    jsr update_enemy_pos ; apply velocities and scrolling adjust
    lda #$03             ; a = #$03 (number of projectiles generated)
    sta $08              ; store enemy attributes for mortars to create
    txa                  ; transfer enemy slot offset to a
    tay                  ; transfer enemy slot offset to y

@generate_mortar_shot:
    jsr find_next_enemy_slot   ; find next available enemy slot, put result in x register
    bne @advance_enemy_routine ; branch if no enemy slot was found
    lda #$0b                   ; a = #$0b (#$0b = mortar)
    sta ENEMY_TYPE,x           ; set current enemy type to mortar
    jsr initialize_enemy       ; initialize enemy attributes
    lda ENEMY_X_POS,y          ; load created enemy x position on screen
    sta ENEMY_X_POS,x          ; set current mortar x position on screen to match
    lda ENEMY_Y_POS,y          ; load created enemy y position on screen
    sta ENEMY_Y_POS,x          ; set current mortar y position on screen to match
    lda $08                    ; load enemy attributes
    sta ENEMY_ATTRIBUTES,x     ; load appropriate enemy attribute (mortar velocities)
                               ; (see mortar_shot_velocity_tbl starting at 3rd entry)
    dec $08                    ; decrement mortar shot creation count
    bne @generate_mortar_shot  ; if haven't created 3 mortar shots loop to create next one

@advance_enemy_routine:
    ldx ENEMY_CURRENT_SLOT    ; restore enemy slot
    jmp advance_enemy_routine ; advance enemy x to next routine

; determines firing direction based on enemy position ($08, $09) and player position ($0b, $0a)
; and creates bullet if appropriate
; input
;  * a - bullet type
;  * y - bullet speed code
;  * $08 - enemy x position
;  * $09 - enemy y position
;  * $0b - player x position
;  * $0a - player y position
aim_and_create_enemy_bullet:
    sty $06                           ; store bullet speed code in $06
    sta $00                           ; store bullet type temporarily
    lda #$01                          ; a = #$01, use quadrant_aim_dir_01
    sta $0f                           ; quadrant_aim_dir_lookup_ptr_tbl offset (quadrant_aim_dir_01)
    lda $0a                           ; load player y position
    bpl @continue                     ; branch if >= #$00
    lda $0c                           ; load player y position
    sta $0a                           ; set target y position
    jsr get_quadrant_aim_dir          ; get aim direction code for target ($0b, $0a) from location ($08, $09) using table code $0f
    jmp @create_bullet_if_appropriate

@continue:
    jsr get_quadrant_aim_dir_for_player ; set a to the aim direction within a quadrant
                                        ; based on source position ($09, $08) targeting player index $0a

@create_bullet_if_appropriate:
    ora $00                                   ; merge enemy bullet quadrant aim dir with bullet type code
    sta $0a                                   ; store bullet type and bullet velocity in $0a
    jmp create_enemy_bullet_if_attack_enabled ; create enemy bullet (type $0a) at ($09, $08) in quadrant $07 and speed $06
                                              ; if ENEMY_ATTACK_FLAG is set or if level 1 boss cannonball

; create enemy bullet (ENEMY_TYPE #$02) of type a (and angle) with speed y at ($09, $08)
; input
;  * a = bullet type and angle
;  * y = bullet speed (enemy attributes)
;  * $08 = y position
;  * $09 = x position
bullet_generation:
    asl

; creates a bullet if attack enabled with speed y, bullet type a, angle a at position ($09, $08)
; input
;  * y - enemy bullet speed
;  * a - (xxx. ....) specifies enemy bullet type:
;    * #$00 - regular bullet
;    * #$01 - level 1 boss large cannonball
;    * #$02 - indoor large cannonball (boss screen)
;    * #$03 - indoor regular bullet
;    * #$04 - level 3 dragon boss fire ball (dragon arm orb projectile)
;  * a - (...x xxxx) specifies bullet angle value (see bullet_fract_vel_dir_lookup_tbl)
;    [#$00-#$17] is pointing right as value increments direction goes clockwise
;  * $08 - y position
;  * $09 - x position
; output
; zero flag - set when bullet created, clear when unable to create
create_enemy_bullet_angle_a:
    sty $06       ; store enemy bullet speed
    sta $0a       ; store bullet type and angle: regular, cannonball, indoor bullet, etc. (see create_enemy_bullet)
    and #$1f      ; keep bits ...x xxxx (keep angle value)
    ldy #$00      ; y = #$00
    cmp #$07      ; compare to left of straight down
    bcc @continue ; branch if creating bullet that is firing right or down and to the right
    cmp #$12      ; compare to firing straight up
    bcs @continue ; branch if firing up and to the right
    ldy #$02      ; firing left, set y to #$02

@continue:
    cmp #$0d                   ; compare to firing straight left
    bcc @set_dir_create_bullet ; branch if firing down (between 3 o'clock and 9 o'clock)
    iny                        ; #$01 or #$03

@set_dir_create_bullet:
    sty $07 ; set aim quadrant

; create enemy bullet (type $0a) at ($09, $08) in quadrant $07 with quadrant aim dir in $0a and speed $06
; if ENEMY_ATTACK_FLAG is set or if level 1 boss cannonball
; input
;  * $08 - y position
;  * $09 - x position
;  * $0a - (xxx. ....) specifies enemy bullet type:
;    * #$00 - regular bullet
;    * #$01 - level 1 boss large cannonball
;    * #$02 - indoor large cannonball (boss screen)
;    * #$03 - indoor regular bullet
;    * #$04 - level 3 dragon boss fire ball (dragon arm orb projectile)
;  * $0a - (...x xxxx) specifies bullet quadrant aim value (see bullet_fract_vel_dir_lookup_tbl)
;    [#$00-#$17] is pointing right as value increments direction goes clockwise
;  * $06 - enemy bullet speed code (see bullet_velocity_adjust_ptr_tbl)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
create_enemy_bullet_if_attack_enabled:
    lda $0a                 ; load bullet type and bullet angle
    and #$e0                ; keep bits xxx. .... (keep type value)
    cmp #$20                ; compare to level 1 large cannonball (boss screen) bullet type
    beq create_enemy_bullet ; always create bullet if bullet type #$01 (level 1 boss large cannonball)
    lda ENEMY_ATTACK_FLAG   ; see if enemies should attack
    beq bullet_gen_exit     ; don't shoot/create enemy bullet if ENEMY_ATTACK_FLAG is set

; create enemy bullet
; input
;  * $08 - y position
;  * $09 - x position
;  * $0a - (xxx. ....) specifies enemy bullet type:
;    * #$00 - regular bullet
;    * #$01 - level 1 boss large cannonball
;    * #$02 - indoor large cannonball (boss screen)
;    * #$03 - indoor regular bullet
;    * #$04 - level 3 dragon boss fire ball (dragon arm orb projectile)
;  * $0a - (...x xxxx) specifies bullet angle value (see bullet_fract_vel_dir_lookup_tbl)
;  * $06 - enemy bullet speed code (see bullet_velocity_adjust_ptr_tbl)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
; output
; zero flag - set when bullet created, clear when unable to create
create_enemy_bullet:
    jsr find_next_enemy_slot ; find next available enemy slot for bullet, put result in x register
    bne bullet_gen_exit      ; branch if no enemy slot was found
    lda #$01                 ; a = #$01 (bullet)
    sta ENEMY_TYPE,x         ; set current enemy type to bullet
    jsr initialize_enemy     ; initialize enemy attributes
    lda $0a                  ; load enemy bullet type
    lsr
    lsr
    lsr
    lsr
    lsr
    sta ENEMY_VAR_1,x        ; store enemy bullet type in ENEMY_VAR_1
    lda $06                  ; load enemy bullet speed code (see bullet_velocity_adjust_ptr_tbl)
    cmp #$07                 ; see if speed code is >= #$07
    bcc @continue            ; continue if not too high
    lda #$07                 ; can't have more than speed code #$07, set to #$07

@continue:
    sta $06           ; store speed code in $06
    lda $08           ; load created bullet enemy y position
    sta ENEMY_Y_POS,x ; set created bullet enemy y position
    lda $09           ; load created bullet enemy y position
    sta ENEMY_X_POS,x ; set created bullet enemy x position
    lda $0a
    and #$1f          ; keep bits ...x xxxx (quadrant aim dir)

; sets the bullet/projectile X and Y velocities (both high and low) based on register a and $07
; used by bullets, eye projectile, and spinning bubbles
; input
;  * a - bullet angle value (bullet_fract_vel_dir_lookup_tbl offset)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
; output
;  * a - #$00
set_bullet_velocities:
    jsr calc_bullet_velocities   ; determine the bullet velocities based on quadrant aim dir (a) and quadrant ($07)
    lda $05                      ; load enemy bullet y velocity fast
    sta ENEMY_Y_VELOCITY_FAST,x  ; set enemy bullet y velocity fast
    lda $04                      ; load enemy bullet y fractional velocity
    sta ENEMY_Y_VELOCITY_FRACT,x ; set enemy bullet y fractional velocity
    lda $0b                      ; load enemy bullet x velocity fast
    sta ENEMY_X_VELOCITY_FAST,x  ; set enemy bullet x velocity fast
    lda $0a                      ; load enemy bullet x fractional velocity
    sta ENEMY_X_VELOCITY_FRACT,x ; set enemy bullet x fractional velocity
    ldx ENEMY_CURRENT_SLOT       ; load enemy current slot (doesn't seem necessary)
    lda #$00                     ; clear a
    rts

; no enemy slot available
bullet_gen_exit:
    ldx ENEMY_CURRENT_SLOT
    lda #$01               ; a = #$01
    rts

; determine the bullet velocities based on quadrant aim dir (a) and quadrant ($07)
; input
;  * a - quadrant aim dir (see bullet_fract_vel_dir_lookup_tbl)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
; output
;  * $04 - bullet y fractional velocity value
;  * $05 - bullet y velocity fast value
;  * $0a - bullet x fractional velocity value
;  * $0b - bullet x velocity fast value
calc_bullet_velocities:
    tay                                   ; store quadrant aim direction in y
    lda bullet_fract_vel_dir_lookup_tbl,y
    tay
    lda bullet_fract_vel_tbl+1,y          ; load the bullet fractional x velocity
    sta $04                               ; store bullet x fractional velocity byte
    lda #$00                              ; set x velocity fast value to #$00
    sta $05                               ; store bullet x velocity fast value
    jsr adjust_bullet_velocity            ; adjust bullet x velocity based on speed code ($06)
    lda $04                               ; load bullet x fractional velocity byte
    sta $0a                               ; set bullet x fractional velocity byte
    lda $05                               ; load bullet x velocity fast value
    sta $0b                               ; set bullet x velocity fast value
    lda bullet_fract_vel_tbl,y            ; load bullet y fractional velocity
    sta $04                               ; set bullet y fractional velocity
    lda #$00                              ; load bullet y fast velocity
    sta $05                               ; set bullet y fast velocity
    jsr adjust_bullet_velocity            ; adjust bullet y velocity based on speed code ($06)
    lda $07                               ; load bullet direction
    lsr                                   ; puts bit 0 to carry (up down bit)
    bcc @set_x_vel                        ; branch if firing down
    lda #$00                              ; bullet firing up, flip y velocity so bullet travels up instead of down
    sec                                   ; set carry flag in preparation for subtraction
    sbc $04                               ; #$00 - $04
    sta $04                               ; update y fractional velocity to be negative
    lda #$00                              ; a = #$00
    sbc $05                               ; #$00 - $05
    sta $05                               ; update y velocity fast to be negative

@set_x_vel:
    lda $07   ; load bullet direction
    lsr
    lsr
    bcc @exit ; exit if firing right
    lda #$00  ; firing left, a = #$00
    sec       ; set carry flag in preparation for subtraction
    sbc $0a   ; negate bullet x fractional velocity
    sta $0a   ; set bullet x fractional velocity value
    lda #$00  ; a = #$00
    sbc $0b   ; negate bullet x fast velocity
    sta $0b   ; set bullet x velocity fast value

@exit:
    rts

; table of enemy bullet fractional velocity indexes based on quadrant aim direction (#$18 bytes)
; offsets into bullet_fract_vel_tbl
; [#$00-#$17] #$00 is pointing right as value increments direction goes clockwise
; #$00 right, #$03 is down, #$06 left, #$09 is straight up
bullet_fract_vel_dir_lookup_tbl:
    .byte $00,$02,$04,$06,$08,$0a ; quadrant IV
    .byte $0c,$0a,$08,$06,$04,$02 ; quadrant III
    .byte $00,$02,$04,$06,$08,$0a ; quadrant II
    .byte $0c,$0a,$08,$06,$04,$02 ; quadrant I

; table for bullet x and y fractional velocities, based on index specified from bullet_fract_vel_dir_lookup_tbl (#$d bytes)
; byte 0 - y fractional velocity
; byte 1 - x fractional velocity
bullet_fract_vel_tbl:
    .byte $00,$ff ; x velocity
    .byte $42,$f7
    .byte $80,$dd
    .byte $b5,$b5
    .byte $dd,$80
    .byte $f7,$42
    .byte $ff,$00 ; shooting horizontally

; adjusts bullet x or y velocity based on speed code (#$0-#$07)
; e.g. bullet speed code #$01 is .75 speed
; assumes fast velocity will always be #$00, otherwise, math won't work in all cases
; input
;  * $04 - bullet fractional velocity value (either x dir or y dir)
;  * $05 - bullet velocity fast value (either x dir or y dir)
;  * $06 - bullet speed code
; output
;  * $04 - bullet fractional velocity value (either x dir or y dir)
;  * $05 - bullet velocity fast value (either x dir or y dir)
adjust_bullet_velocity:
    lda $06                        ; bullet speed (0-7)
    and #$07                       ; keep bits .... .xxx
    jsr run_routine_from_tbl_below ; run routine a in the following table (bullet_velocity_adjust_ptr_tbl)

; pointer table for bullet speeds (#$9 * #$2 = #$12 bytes)
bullet_velocity_adjust_ptr_tbl:
    .addr bullet_velocity_adjust_00 ; CPU address $f3be (.5x speed)
    .addr bullet_velocity_adjust_01 ; CPU address $f3c3 (.75x speed)
    .addr bullet_velocity_adjust_02 ; CPU address $f3e4 (normal speed)
    .addr bullet_velocity_adjust_03 ; CPU address $f3ca (1.25x speed)
    .addr bullet_velocity_adjust_04 ; CPU address $f3d3 (1.5x speed)
    .addr bullet_velocity_adjust_05 ; CPU address $f3e5 (1.62x speed)
    .addr bullet_velocity_adjust_06 ; CPU address $f3f0 (1.75x speed)
    .addr bullet_velocity_adjust_07 ; CPU address $f3ff (1.87x speed)
    .addr bullet_velocity_adjust_08 ; CPU address $f415 (2x speed) impossible? !(HUH)

; bullet speed 0 (.5x speed)
; halves fast and slow velocity, e.g. #$03 #80 (3.5) becomes #$01 #$c0 (1.75)
bullet_velocity_adjust_00:
    lsr $05 ; half fast velocity
    ror $04 ; half fractional value, including carry from fast velocity
    rts

; bullet speed 1 (.75x speed)
; first half value, then half that again to add to the originally halved value
bullet_velocity_adjust_01:
    lsr $05                       ; half fast velocity
    ror $04                       ; half fractional value, including carry from fast velocity
    jmp bullet_velocity_adjust_04

; bullet speed 3 (1.25x speed)
; halves fast and fractional velocity, halves fractional again and adds it to original velocity
bullet_velocity_adjust_03:
    lda $05                          ; load fast velocity
    lsr                              ; half fast velocity
    lda $04                          ; load fractional velocity
    ror                              ; half fractional velocity, including carry from fast velocity
    lsr                              ; half fractional velocity again
    bpl bullet_velocity_adjust_add_a ; add .25 *  to original velocity

; bullet speed 4 (1.5x speed)
bullet_velocity_adjust_04:
    lda $05 ; load fast velocity
    lsr     ; half fast velocity
    lda $04 ; load original fractional velocity
    ror     ; half fractional velocity, including carry from fast velocity

bullet_velocity_adjust_add_a:
    clc      ; clear carry in preparation for addition
    adc $04  ; add to original value of $04
    sta $04  ; store value back in $04
    lda $05  ; re-load $05
    adc #$00 ; add any carry
    sta $05  ; update $05

; bullet speed 2 (normal speed)
bullet_velocity_adjust_02:
    rts

; bullet speed 5 (1.62x speed)
bullet_velocity_adjust_05:
    lda $05
    lsr
    lda $04
    ror
    sta $00
    lsr
    bpl bullet_dir_half_a_add_to_vel

; bullet speed 6 (1.75x speed) (for any value less than 1.14)
; doesn't work correctly when carry from fractional velocity, e.g. 1.5 becomes 1.62 and not 2.62
; however, 1.1 (#$01 #1a) correctly goes to (#$01 #$ed) (1.92)
bullet_velocity_adjust_06:
    lda $05
    lsr
    lda $04
    ror
    sta $00

bullet_dir_half_a_add_to_vel:
    lsr
    clc                              ; clear carry in preparation for addition
    adc $00
    jmp bullet_velocity_adjust_add_a

; bullet speed 7 (1.87x speed)
; doesn't work correctly when carry from fractional velocity, e.g. 1.5 becomes 1.81 and not 2.81
; however, 1.05 (#$01 #0d) correctly goes to (#$01 #$f7) (1.96)
bullet_velocity_adjust_07:
    lda $05
    lsr
    lda $04
    ror
    sta $00
    lsr
    sta $01
    clc                              ; clear carry in preparation for addition
    adc $00
    lsr $01
    clc                              ; clear carry in preparation for addition
    adc $01
    jmp bullet_velocity_adjust_add_a

; bullet speed 8 (2x speed) (impossible ?)
bullet_velocity_adjust_08:
    asl $04 ; double fast velocity
    rol $05
    rts

; either increments or decrements ENEMY_VAR_1 by 1 to aim towards the player using quadrant_aim_dir_01
; used by spinning bubbles (enemy type = #$1d), tank (enemy type = #$12), and white blob (enemy type = #$13)
; input
;  * $0a - player index
; output
;  * carry flag - set when enemy already aiming at player, clear when rotation happened
;  * minus flag
;  * zero flag - clear when clockwise direction, set when counterclockwise
aim_var_1_for_quadrant_aim_dir_01:
    jsr get_rotate_01      ; get enemy aim direction and rotation direction using quadrant_aim_dir_01
    jmp rotate_enemy_var_1 ; rotate the enemy's aim by one in a clockwise or counterclockwise direction if needed

; either increments or decrements ENEMY_VAR_1 by 1 to aim towards the player using quadrant_aim_dir_00
; used by rotating gun (enemy type = #$04) and alien fetus (enemy type = #$11)
; output
;  * ENEMY_VAR_1,x - enemy aim direction [#$00-#$0b] #$00 when facing right incrementing clockwise
;  * carry flag - set when enemy already aiming at player, clear when rotation happened
aim_var_1_for_quadrant_aim_dir_00:
    jsr get_rotate_00 ; get enemy aim direction and rotation direction using quadrant_aim_dir_00

; rotate the enemy's aim by one in a clockwise or counterclockwise direction
; input
;  * minus flag - set when enemy is already aiming at player and no rotation is required
;  * carry flag - set when enemy already aiming at player, clear when rotation happened
;  * zero flag - clear when clockwise direction, set when counterclockwise
rotate_enemy_var_1:
    bmi @set_carry_exit            ; exit if enemy is already aiming at the player
    bne @rotate_1_counterclockwise ; if a = #$01, then a counterclockwise rotation
    inc ENEMY_VAR_1,x              ; move enemy aim direction clockwise
    lda ENEMY_VAR_1,x              ; load enemy aim direction
    cmp $06                        ; compare maximum supported enemy aim dir, e.g. rotating gun is #$0b
    bcc @continue                  ; continue if not past last position
    lda #$00                       ; wrapped around, set to first aim direction #$00 (horizontal left)
    beq @set_var_1_continue

; rotate counter-clockwise
@rotate_1_counterclockwise:
    dec ENEMY_VAR_1,x ; update enemy aim direction
                      ; moves direction counter clockwise
    bpl @continue     ; branch if counter-clockwise doesn't cause underflow
    lda $06           ; load maximum number of the supported enemy aim dir, e.g. rotating gun is #$0c (left and slightly down)
    sec               ; set carry flag in preparation for subtraction
    sbc #$01          ; subtract one

@set_var_1_continue:
    sta ENEMY_VAR_1,x ; update enemy aim direction

@continue:
    lda ENEMY_VAR_1,x   ; load enemy aim direction
    cmp $0c             ; compare to new enemy position as determined by get_rotate_00
    beq @set_carry_exit ; set carry and exit
    clc                 ; not yet at desired direction, clear carry and exit
    rts

; rotating gun is at desired position, set carry and exit
@set_carry_exit:
    sec ; set carry flag
    rts

; determines which direction to rotate based on quadrant_aim_dir_00
; targeting player index ($0a)
; input
;  * $0a - player index to target, 0 = player 1, 1 = player 2
;  * $08 - source y position
;  * $09 - source x position
; output
;  * negative flag - set when enemy is already aiming at player and no rotation is needed
;  * a - rotation direction, #$00 clockwise, #$01 counterclockwise, #$80 no rotation needed
;  * $0c - new enemy aim direction
get_rotate_00:
    lda #$00                     ; a = #$00 (use quadrant_aim_dir_00)
    beq get_rotate_dir_for_index ; always branch, get enemy aim direction and rotation direction using quadrant_aim_dir_00

; determines which direction to rotate based on quadrant_aim_dir_01
; targeting player index ($0a)
; input
;  * $0a - player index to target, 0 = player 1, 1 = player 2
;  * $08 - source y position
;  * $09 - source x position
; output
;  * negative flag - set when enemy is already aiming at player and no rotation is needed
;  * a - rotation direction, #$00 clockwise, #$01 counterclockwise, #$80 no rotation needed
;  * $0c - new enemy aim direction
get_rotate_01:
    lda #$01 ; a = #$01 (use quadrant_aim_dir_01)

; determines which direction to rotate based on quadrant_aim_dir_lookup_ptr_tbl index offset (a)
; targeting player index ($0a)
; input
;  * a - quadrant_aim_dir_lookup_ptr_tbl offset table
;  * $0a - player index to target, 0 = player 1, 1 = player 2
;  * $08 - source y position
;  * $09 - source x position
; output
;  * negative flag - set when enemy is already aiming at player and no rotation is needed
;  * a - rotation direction, #$00 clockwise, #$01 counterclockwise, #$80 no rotation needed
;  * $0c - new enemy aim direction
get_rotate_dir_for_index:
    sta $0f                   ; set quadrant_aim_dir_lookup_ptr_tbl index offset
    lda $0a                   ; load player index
    bpl @get_quadrant_aim_dir ; branch if closest player has been determined
    lda $0c                   ; no player to target, not sure when this happens (see player_enemy_x_dist)
                              ; even when both player states are not normal, still targets player 1
    sta $0a                   ; set $0c as player index
    jsr get_quadrant_aim_dir  ; get aim direction code for target ($0b, $0a) from location ($08, $09) using table code $0f
                              ; depending on quadrant_aim_dir_xx, dir code will be [#$00-#$03], [#$00-#$06], or [#$00-#$0f]
    jmp get_rotate_dir        ; determine which direction to rotate
                              ; based on a (quadrant aim dir) and quadrant ($07)

@get_quadrant_aim_dir:
    jsr get_quadrant_aim_dir_for_player ; set a to the aim direction within a quadrant
                                        ; based on source position ($09, $08) targeting player index $0a

; determines which direction to rotate
; based on a (quadrant aim dir) and quadrant ($07)
; input
;  * a - quadrant aim direction (quadrant_aim_dir_xx value)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
;  * $0f - quadrant_aim_dir_lookup_ptr_tbl offset
; output
;  * negative flag - set when enemy is already aiming at player and no rotation is needed
;  * a - rotation direction, #$00 clockwise, #$01 counterclockwise, #$80 no rotation needed
;  * $0c - new enemy aim direction
get_rotate_dir:
    sta $0c       ; store quadrant aim direction code in $0c
    lda $0f       ; load quadrant_aim_dir_lookup_ptr_tbl offset (which quadrant_aim_dir_xx to use)
    lsr           ; move bit 0 to the carry
    lda #$06      ; using either quadrant_aim_dir_00, or quadrant_aim_dir_02
                  ; midway direction, i.e. 9 o'clock
    ldy #$0c      ; maximum aim direction (same as #$00 aim dir), i.e. 3 o'clock
    bcc @continue ; branch if aim type quadrant_aim_dir_00 or quadrant_aim_dir_02
    lda #$0c      ; using quadrant_aim_dir_01
                  ; midway direction, i.e. 9 o'clock
    ldy #$18      ; maximum aim direction (same as #$00 aim dir), i.e. 3 o'clock

@continue:
    sta $05               ; store either #$06 or #$0c into $06, which is the midway aim direction, i.e. 9 o'clock
    sty $06               ; store either #$0c or #$18 into $06, which is the maximum aim direction, i.e. 3 o'clock
    lda $07               ; load player position relative to enemy (left/right and above/below)
    and #$02              ; keep bit 1 (set when player to the left)
    beq @check_player_pos ; branch if player to the right of the enemy (#$00 or #$01)
    lda $05               ; player to left of enemy enemy, load mid way direction (either #$06 or #$0c)
    sec                   ; set carry flag in preparation for subtraction
    sbc $0c               ; subtract quadrant aim direction code from from midway direction point ($05 - $0c)
    sta $0c               ; store result back into $0c

@check_player_pos:
    lsr $07                 ; shift right the position relative to enemy (left/right and above/below)
    bcc @calc_reflected_dir ; branch if player below enemy
    lda $06                 ; player is above enemy, need to reflect aim dir ($0c) across x-axis
                            ; load max direction value (#$0c or #$18)
    sec                     ; set carry flag in preparation for subtraction
    sbc $0c                 ; subtract either the quadrant aim direction code directly from max aim direction (when player to right)
                            ; or subtract the offset amount from half-way (when player to left) from max aim direction (reflect across x-axis)
                            ; ($06 - $0c)
    cmp $06                 ; compare to max direction value
    bcc @continue2          ; branch if aim direction wasn't #$00
    lda #$00                ; direction result was #$00, set value to #$00 (right 3 o'clock)

@continue2:
    sta $0c ; set new aim direction

; calculates the aim direction reflected along the vertical axis
; e.g. if original aim direction #$00 is right and increment clockwise
; reflected aim direction #$00 is left increment clockwise
@calc_reflected_dir:
    lda #$00                ; a = #$00
    sta $0e                 ; initialize value of $0e to #$00
    lda ENEMY_VAR_1,x       ; load current enemy aim direction (#$00 facing right)
    clc                     ; clear carry in preparation for addition
    adc $05                 ; add either #$06 or #$0c to current enemy aim dir (halfway point)
    cmp $06                 ; see if current enemy aim direction is in first half or second half of aim directions
                            ; used for calculating 'reflected' aim direction
    bcc @determine_rotation ; branch if no wraparound, i.e. first half of aim directions
    inc $0e                 ; current aim direction is greater than half way point
                            ; set $0e to #$01
    sbc $06                 ; subtract max aim direction value to get correct reflected dir (modulus)

; check to see if need to rotate, and if so, which direction
; all examples assume quadrant_aim_dir_00 or quadrant_aim_dir_02
; $0c - new aim direction. Example: right is #$00, increment clockwise
; $0d - reflected new aim direction. Example: left is #$00, increment clockwise
; $0e - whether or not new direction has gone through the maximum direction, e.g. old value #$0a, new value #$03
; ENEMY_VAR_1 - previous enemy aim direction - (right is #$00, increment clockwise)
@determine_rotation:
    sta $0d                         ; store 'reflected' aim direction in $0d
    lda $0c                         ; load new enemy aim direction
    cmp ENEMY_VAR_1,x               ; compare to current enemy aim dir (#$00 is right)
    beq @no_dir_change              ; if the calculated enemy aim dir is the same, no need to move, set minus flag and exit
    ldy $0e                         ; need to rotate to new enemy aim dir, load prefered direction
    bne @wrapped_rotation_check_dir ; branch if new direction caused a 'wrap around'
    bcc @rotate_counterclockwise    ; no wrap occurred and new direction is less than current, rotate counterclockwise
    cmp $0d                         ; compare 'reflected' dir to current enemy aim dir, to find shortest direction
    bcs @rotate_counterclockwise    ; rotate counterclockwise if reflected enemy aim dir is > new aim dir
                                    ; e.g. no wrap occurred, $0c is #$09 (up) (this means $0d is #$03)
                                    ; and suppose ENEMY_VAR_1 is #$0a (up-right), rotate counter clockwise

; clockwise rotation
@rotate_clockwise:
    lda #$00  ; a = #$00
    beq @exit

; when determining the new aim direction for the enemy, the direction 'wrapped around' the max dir, e.g. #$0b
; so while the enemy aim direction may have gotten smaller, it doesn't necessarily imply a counterclockwise rotation
@wrapped_rotation_check_dir:
    bcs @rotate_clockwise ; rotate clockwise if new aim direction is greater than old aim direction
    cmp $0d               ; compare 'reflected' dir to current enemy aim dir, to find shortest direction
    bcc @rotate_clockwise ; rotate clockwise if reflected enemy aim dir is < new aim dir
                          ; e.g. wrap occurred, $0c is #$03 (down) (this means $0d is #$09)
                          ; and suppose ENEMY_VAR_1 is #$0a (up-right), rotate clockwise

@rotate_counterclockwise:
    lda #$01 ; a = #$01

@exit:
    rts

@no_dir_change:
    lda #$80  ; a = #$80
    bne @exit ; always exit

; determines whether dragon arm orb should move, and if so, in which direction
; dragon_arm_orb_routine_03 - related to dragon arm orb seeking/following the players (ENEMY_FRAME #$04)
; input
;  * x - current enemy slot index for for the dragon arm orb
; output
;  * minus flag - set when orb doesn't need to move, clear otherwise
;  * a - #$00, #$01 or #$80
dragon_arm_orb_seek_should_move:
    jsr set_08_09_to_enemy_pos          ; set $08 and $09 to enemy x's X and Y position
    lda #$02                            ; dragon arm orb is only enemy that uses quadrant_aim_dir_02
    sta $0f                             ; set quadrant_aim_dir_lookup_ptr_tbl offset to use quadrant_aim_dir_02
    jsr get_quadrant_aim_dir_for_player ; set a to the aim direction within a quadrant
                                        ; based on source position ($09, $08) targeting player index $0a
    sta $0c                             ; store enemy aim direction in $0c
    ldy ENEMY_VAR_3,x                   ; load next dragon arm orb (farther from body) enemy index
    lda $07                             ; load player position relative to enemy
    lsr
    lsr
    bcc @check_player_vert_pos          ; branch if player on right side enemy (and below)
    lda #$20                            ; player to the left, load a = #$20
    sec                                 ; set carry flag in preparation for subtraction
    sbc $0c                             ; subtract enemy aim direction from #$20 (#$20 - $0c)
    sta $0c                             ; update enemy aim direction to now point

@check_player_vert_pos:
    lsr $07                 ; move bit 0 to carry flag
    bcc @player_below_enemy ; branch if player below enemy
    lda #$40                ; player is above enemy, set a = #$40
                            ; this doesn't seem possible for dragon arm orb enemy
    sec                     ; set carry flag in preparation for subtraction
    sbc $0c                 ; subtract enemy aim direction from #$40 (#$40 - $0c)
    and #$3f                ; keep bits ..xx xxxx
    sta $0c                 ; update enemy aim direction

@player_below_enemy:
    lda #$00                    ; a = #$00
    sta $0e
    lda ENEMY_X_VELOCITY_FAST,y ; load next orb's enemy position index (see dragon_arm_orb_pos_tbl)
    clc                         ; clear carry in preparation for addition
    adc #$20                    ; add #$20 to next orb's position index (2 rows)
    cmp #$40                    ; see if position index is on the last row
    bcc @b3                     ; branch if not on last row of dragon_arm_orb_pos_tbl
    inc $0e                     ; on last row of dragon_arm_orb_pos_tbl, increment $0e
    sbc #$40                    ; set index into 0th row of dragon_arm_orb_pos_tbl

@b3:
    sta $0d                     ; store adjusted enemy position index in $0d
    lda $0c                     ; load enemy aim direction
    cmp ENEMY_X_VELOCITY_FAST,y ; compare enemy aim direction to next dragon arm orb's fast x velocity
    beq @set_negative_exit
    ldy $0e                     ; load whether or not the position index was on the last row
    bne @continue
    bcc @clear_zero_exit
    cmp $0d
    bcs @clear_zero_exit

@loop:
    lda #$00  ; a = #$00
    beq @exit ; always exit with zero flag set

@continue:
    bcs @loop
    cmp $0d
    bcc @loop

; exit with the zero flag clear
@clear_zero_exit:
    lda #$01 ; a = #$01

@exit:
    rts

; set negative flag, clear zero flag, exit
@set_negative_exit:
    lda #$80  ; a = #$80
    bne @exit ; always branch

; determines the aim direction within a quadrant based on source position ($09, $08) targeting player index $0a
; input
;  * $0f - quadrant_aim_dir_lookup_ptr_tbl offset [#$00-#$02]
;  * $0a - player index of player to target (#$00 for p1 or #$01 for p2)
;  * $08 - source y position
;  * $09 - source x position
; output
;  * a - player aim direction (for most things this is an offset into bullet_fract_vel_dir_lookup_tbl)
;        when called for dragon boss arm orbs, it is a reference to dragon_arm_orb_pos_tbl)
;  * $07 - player position relative to enemy (left/right and above/below)
;   * #$00 = player below enemy (or equal) and to the right
;   * #$01 = player above enemy and to the right
;   * #$02 = player to left of enemy and player below enemy (or equal)
;   * #$03 = player to left of enemy and player above enemy
get_quadrant_aim_dir_for_player:
    lda $0a                  ; load the player player index
    and #$01                 ; should only be #$00 or #$01 (p1 or p2)
    tay                      ; transfer to y
    lda PLAYER_STATE,y       ; load the closest player's PLAYER_STATE
    cmp #$01                 ; see if normal state
    beq @get_y_pos           ; branch if normal state
    tya                      ; not normal state, either falling, dead or can't move
    eor #$01                 ; flip to other player
    tay
    lda PLAYER_STATE,y       ; load other player's PLAYER_STATE
    cmp #$01                 ; see if normal state
    beq @get_y_pos           ; branch if normal state
    lda #$ff                 ; other player also not in normal state
    sta $0a                  ; set player y position to #$ff (bottom of screen)
    lda #$80                 ; a = #$80
    sta $0b                  ; set player x position to #$80 (center of screen)
    bne get_quadrant_aim_dir ; always branch, get aim direction code for target ($0b, $0a) from location ($08, $09) using table code $0f

@get_y_pos:
    lda LEVEL_LOCATION_TYPE ; 0 = outdoor; 1 = indoor
    lsr
    lda #$b0                ; player y position is set at #$a8 on indoor levels
                            ; note this means that enemies won't aim correctly at a player who is jumping on an indoor level
    bcs @get_x_pos          ; branch for indoor level
    lda SPRITE_Y_POS,y      ; outdoor level, load y position from memory

@get_x_pos:
    sta $0a            ; store player Y location in $0a
    lda SPRITE_X_POS,y ; load x position from memory
    sta $0b            ; store player X position in $0b

; determines the aim direction within a quadrant based on source position ($09, $08) targeting player location ($0b, $0a)
; input
;  * $08 - source y position
;  * $09 - source x position
;  * $0a - closest player y position
;  * $0b - closest player x position
;  * $0f - which of the #$03 tables from quadrant_aim_dir_lookup_ptr_tbl to use
; output
;  * a - quadrant aim direction (quadrant_aim_dir_xx value)
;  * $07 - specifies quadrant to aim in (0 = quadrant IV, 1 = quadrant I, 2 = quadrant III, 3 = quadrant II)
;    * bit 0 - 0 = bottom half of plane (quadrants III and IV), 1 = top half of plane (quadrants I and II)
;    * bit 1 - 0 = right half of the plan (quadrants I and IV), 1 = left half of plane (quadrants II and III)
get_quadrant_aim_dir:
    ldy #$00              ; default assume player is to the right and equal to or below enemy
    lda $0a               ; load closest player y position
    sec                   ; set carry flag in preparation for subtraction
    sbc $08               ; subtract enemy y position from player y position
    bcs @shift_get_x_diff ; branch if no overflow occurred (enemy above player or same vertical position)
    eor #$ff              ; enemy below player, handle overflow, flip all bits and add one
    adc #$01
    iny                   ; y used to keep track of where player is in relation to enemy, e.g. $07
                          ; mark that enemy was below player

@shift_get_x_diff:
    lsr           ; shift the difference between player and enemy y difference 5 bits
    lsr           ; (every #$20 pixels difference is a new horizontal direction)
    lsr
    lsr
    lsr
    sta $0a       ; store result in $0a (row offset for quadrant_aim_dir_xx)
    lda $0b       ; load player x position
    sec           ; set carry flag in preparation for subtraction
    sbc $09       ; subtract enemy x position from player x position
    bcs @continue ; branch if no overflow (player to right of enemy)
    eor #$ff      ; enemy to left of player, handle overflow, flip all bits and add one
    adc #$01
    iny           ; player to left of enemy, increment y by two to set correct relative position
    iny           ; if y was 0, now is 2, if y was 1, now is 3

@continue:
    lsr                                     ; shift the difference between player and enemy x difference 6 bits
    lsr                                     ; (every #$40 pixels difference is a new horizontal direction)
    lsr
    lsr
    lsr
    sty $07                                 ; store position of player relative to enemy in $07 (above/below, left/right)
    lsr                                     ; push bit 5 to the carry flag for use after plp instruction below
    sta $0b                                 ; overwrite player x position with shifted bits 6 and 7
                                            ; (values [#$00-#$03]) of horizontal distance
    php                                     ; backup CPU status flags on stack
    lda $0f                                 ; load which of the #$03 tables from quadrant_aim_dir_lookup_ptr_tbl to use
    asl                                     ; double since each entry is #$2 bytes
    tay                                     ; transfer to offset register
    lda quadrant_aim_dir_lookup_ptr_tbl,y   ; get low byte of quadrant_aim_dir_xx address
    sta $0c                                 ; store low byte of pointer address in $0c
    lda quadrant_aim_dir_lookup_ptr_tbl+1,y ; get high byte of quadrant_aim_dir_xx address
    sta $0d                                 ; store high byte of pointer address in $0d
    lda $0a                                 ; load y difference to determine row offset
    asl
    asl                                     ; quadruple since each entry is #$04 bytes to get correct row
    adc $0b                                 ; add the x distance between player and enemy as offset into the entry to load
                                            ; this gets the column of the aim direction
    tay                                     ; transfer to offset register
    lda ($0c),y                             ; load specific byte
    plp                                     ; restore CPU status flags from stack
    bcs @set_and_exit                       ; branch if bit 5 of difference between player and enemy was set
    lsr                                     ; this segments screen into bands for which nibble to use
    lsr
    lsr
    lsr

@set_and_exit:
    and #$0f ; keep low nibble
    rts

; pointer table for set of quadrant aim directions (#$3 * #$2 = #$6 bytes)
quadrant_aim_dir_lookup_ptr_tbl:
    .addr quadrant_aim_dir_00 ; CPU address $f5b2 (soldiers, weapon boxes, red turrets, wall core)
    .addr quadrant_aim_dir_01 ; CPU address $f5d2 (rotating gun, wall turrets, sniper, eye projectile, spinning bubbles, jumping soldier, white blob)
    .addr quadrant_aim_dir_02 ; CPU address $f5f2 (dragon arm seeking)

; table for where to aim within a quadrant that is split into 3 parts [#$00-#$03] (#$20 bytes)
; * used by soldiers, weapon boxes, red turrets, wall turrets,
;   wall core, and dragon arm orb projectiles
;   (not arm seeking, that's #$02)
; * which nibble used from byte depends on bit 5 of difference between player and enemy distance
; * each subsequent row is player farther away from enemy with respect to y (height)
; * each subsequent column is player farther away from enemy with respect to x (distance)
quadrant_aim_dir_00:
    .byte $00,$00,$00,$00 ; player at same height
    .byte $32,$11,$00,$00
    .byte $32,$11,$11,$11
    .byte $32,$22,$11,$11
    .byte $33,$22,$11,$11
    .byte $33,$22,$22,$11
    .byte $33,$22,$22,$11
    .byte $33,$22,$22,$22

; table for where to aim within a quadrant that is split into 6 parts [#$00-#$06] (#$20 bytes)
; when used indoors only one 'quadrant' so the quadrant aim dir is the same as the aim dir
; * indoor levels exclusively use this table: wall turret, eye projectile, spinning bubbles
;   jumping soldier, and wall core
; * also used by rotating gun, sniper, white blob, spinning bubbles, and tank
; * which nibble used from byte depends on bit 5 of difference between player and enemy distance
; * each subsequent row is player farther away from enemy with respect to y (height)
; * each subsequent column is player farther away from enemy with respect to x (distance)
quadrant_aim_dir_01:
    .byte $00,$00,$00,$00 ; player at same height
    .byte $63,$21,$11,$11
    .byte $64,$32,$21,$11
    .byte $65,$43,$22,$22
    .byte $65,$44,$33,$22
    .byte $65,$54,$33,$32
    .byte $65,$54,$43,$33
    .byte $65,$54,$44,$33

; table for where to aim within a quadrant that is split into #$0f parts [#$00-#$0f] (#$20 bytes)
; * used by dragon arm seeking (not projectile firing that's #$00)
; * which nibble used from byte depends on bit 5 of difference between player and enemy distance
; * each subsequent row is player farther away from enemy with respect to y (height)
; * each subsequent column is player farther away from enemy with respect to x (distance)
quadrant_aim_dir_02:
    .byte $80,$00,$00,$00
    .byte $f8,$53,$32,$21
    .byte $fb,$86,$54,$33
    .byte $fd,$a8,$75,$54
    .byte $fe,$b9,$87,$65
    .byte $fe,$cb,$98,$76
    .byte $fe,$db,$a9,$87
    .byte $ff,$dc,$ba,$98

; unused #$5ee bytes out of #$4,000 bytes total (90.73% full)
; unused 1,518 bytes out of 16,384 bytes total (90.73% full)
; filled with 1,518 #$ff bytes by contra.cfg configuration
bank_7_unused_space:

.segment "DPCM_SAMPLES"

; DPCM (differential pulse code modulation) audio sample used by DMC (delta modulation channel)
; CPU address $fc00 (#$51 bytes) See dpcm_sample_data_tbl
dpcm_sample_00:
    .incbin "assets/audio_data/dpcm_sample_00.bin"

; possibly unused DPCM sample, #$5f bytes (excluding #$ff)
; CPU address $fc51
; exists in Japanese version of game as well (I don't think it's used there either)
unknown_00:
    .byte $6b,$56,$ce,$b5,$5b,$5d,$59,$b6,$d5,$ab,$d6,$b5,$d7,$6b,$6d,$ad
    .byte $ae,$b6,$d6,$b5,$b5,$aa,$d6,$aa,$ac,$aa,$a9,$54,$a9,$94,$a4,$a9
    .byte $4a,$4a,$8a,$92,$54,$a5,$49,$29,$4a,$54,$a5,$29,$52,$a5,$4a,$a5
    .byte $54,$a9,$54,$aa,$95,$2a,$aa,$94,$95,$2a,$aa,$55,$55,$2a,$56,$66
    .byte $aa,$9a,$aa,$b5,$5a,$ad,$ab,$5a,$b5,$6b,$6b,$6b,$5a,$b5,$aa,$b5
    .byte $56,$aa,$d5,$55,$56,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$95,$55,$55,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

; DPCM (differential pulse code modulation) audio sample used by DMC (delta modulation channel)
; CPU address $fcc0 (#$251 bytes). See dpcm_sample_data_tbl
dpcm_sample_01:
    .incbin "assets/audio_data/dpcm_sample_01.bin"

; possibly unused DPCM sample, #$a8 bytes (excluding #$ff)
; CPU address $ff0b
; exists in Japanese version of game as well (I don't think it's used there either)
unknown_01:
    .byte $4c,$aa,$ca,$aa,$a5,$a6,$56,$55,$54,$d3,$2a,$c6,$aa,$6a,$96,$a6
    .byte $66,$aa,$aa,$b2,$b4,$d5,$55,$66,$9a,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa,$9a,$a6,$56,$55,$52,$b2,$aa,$aa,$aa,$96,$aa,$65,$aa
    .byte $aa,$aa,$b5,$55,$56,$6a,$6a,$aa,$aa,$aa,$6a,$72,$9a,$aa,$9a,$9a
    .byte $a9,$96,$59,$55,$55,$55,$52,$d2,$b2,$aa,$a9,$aa,$aa,$aa,$ac,$b2
    .byte $cc,$d5,$55,$55,$65,$96,$59,$aa,$aa,$9a,$9a,$9a,$aa,$6a,$56,$a5
    .byte $65,$95,$55,$55,$55,$54,$b5,$32,$aa,$aa,$b2,$aa,$b2,$aa,$ab,$55
    .byte $55,$55,$55,$55,$69,$aa,$aa,$96,$9a,$99,$5a,$59,$5a,$55,$65,$96
    .byte $59,$55,$55,$55,$55,$55,$52,$b4,$aa,$aa,$aa,$aa,$b2,$d3,$55,$55
    .byte $55,$55,$55,$56,$55,$66,$aa,$aa,$aa,$aa,$a6,$9a,$aa,$65,$55,$55
    .byte $55,$55,$55,$32,$cc,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

; NES footer area
; contains Konami production code, catalog number, game name, checksum,
; coumpany code, and country code.
; see https://forums.nesdev.org/viewtopic.php?p=56921 for more details
.segment "NES_FOOTER"

; a byte for each bank written when switching PRG ROM banks
; CPU address $ffd0
prg_rom_banks:
    .byte $00,$01,$02,$03,$04,$05,$06,$07

; Konami production code RD008
; RD008 would be later used as the name for Bill's replacement in Probotector (European Contra release)
; https://tcrf.net/User:Revenant/Konami_catalog_numbers
; > Incidentally, the NES version of Contra had the ID RD008 within its code.
; > RD008 would later be used as the codename for one of the robot protagonists
; > (alongside RC011) in the European version of the game titled Probotector,
; > released in 1990. 4/4
; -- https://twitter.com/Arc_Hound/status/1161732318740041729
konami_catalog_number:
    .byte $52,$44,$30,$30,$38,$ff,$ff,$ff ; RD008 in ASCII

; NES undocumented footer
; https://forums.nesdev.org/viewtopic.php?p=56921
; game name left-padded with zeros
nes_footer_rom_name:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $43,$4f,$4e,$54,$52,$41                 ; CONTRA in ASCII

; checksum of game bytes
;   * add all bytes together (setting checksum bytes to #$00)
;   * take smallest 2 bytes bytes of result
; actual sum of all bytes excluding checksum bytes is 14,256,747 (#$d98a6b)
nes_footer_checksum:
    .byte $8a,$6b

; CHR ROM checksum - the sum of all bytes in the CHR ROM
; no CHR ROM for game so #$00 #$00
nes_footer_chr_checksum:
    .byte $00,$00

; PRG and CHR size
; #$03 PRG ROM size - 128 KiB (8 banks each bank 16 KiB)
; #$08 CHR RAM size - 8 KiB
nes_footer_size:
    .byte $38

; #$02 vertical mirroring
;  * #$02 - vertical
;  * #$81 or #$82 - horizontal
;  * #$04 - mapper controlled
nes_footer_mirroring:
    .byte $02

; byte 0 - country code - #$01 - North America
; byte 1 - unknown, almost always #$01
; byte 2 - company code - #$a4 - Konami
; byte 3 - unknown (matches Japanese Contra ROM)
nes_footer_maker_code:
    .byte $01,$05,$a4,$1c

; locations of all 'vectors'. These are the 3 handles for NES interrupts
; stored in the .nes ROM as the last $06 bytes (CPU addresses $fffa-$ffff)
; these are stored at known locations so the NES can point the instruction
; pointer at known locations for triggering interrupts.
.segment "VECTORS"
  .addr nmi_start, reset_vector, irq