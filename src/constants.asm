; Contra US Disassembly - v1.2
; https://github.com/vermiceli/nes-contra-us
; constants.asm contains the list of constants with meaningful names for the
; memory addresses used by the game. It also contains constants for the various
; palette colors.

BANK_NUMBER                    = $8000
GAME_ROUTINE_INDEX             = $18   ; which part of the game routine to execute (see game_routine_pointer_table)
GAME_END_ROUTINE_INDEX         = $19   ; used after beating the game to know which part of the ending sequence to execute for sequencing the animations, credits, restart, etc. (see game_end_routine_tbl)
GAME_ROUTINE_INIT_FLAG         = $19   ; (same address as above) used to determine if the current game_routine has been initialized, used in game_routine_02 and game_routine_03
FRAME_COUNTER                  = $1a   ; the frame counter loops from #$00 to #$ff increments once per frame. Also known as the global timer
NMI_CHECK                      = $1b   ; set to #$01 at start of nmi and #$00 at end
                                       ; used to track if nmi occurred during game loop
                                       ; bit 7 is set when inside play_sound, i.e. init_sound_code_vars
DEMO_MODE                      = $1c   ; #$00 not in demo mode, #$01 demo mode on
PLAYER_MODE_1D                 = $1d   ; #$01 for 1 player, #$07 for 2 player. Not sure why developer just didn't use PLAYER_MODE instead
DEMO_LEVEL_END_FLAG            = $1f   ; whether or not demo for the level is complete and new demo level should play
PPU_READY                      = $20   ; #$00 when at least 5 executions of nmi_start have happened since last configure_PPU call
GRAPHICS_BUFFER_OFFSET         = $21   ; current write offset into CPU_GRAPHICS_BUFFER (CPU_GRAPHICS_BUFFER contains pattern table tiles that are written to PPU)
PLAYER_MODE                    = $22   ; #$00 = single player, #$01 = 2 player
GRAPHICS_BUFFER_MODE           = $23   ; defines the format of the CPU_GRAPHICS_BUFFER. #$ff is for super-tile data, #$00 is for text strings and palette data
KONAMI_CODE_STATUS             = $24   ; #$00 not entered, #$01 entered, (30 lives code)
PAUSE_STATE                    = $25   ; #$00 when not paused, #$01 when paused
DEMO_LEVEL                     = $27   ; the current level when in DEMO mode
                                       ; only ever 0, 1 or 2 as those are the only levels demoed
INTRO_THEME_DELAY              = $28   ; timer to prevent starting a level until the intro theme is complete (including explosion sound).
                                       ; initialized to #a4, decrements every other frame for ~5 seconds for NTSC
GAME_OVER_DELAY_TIMER          = $29   ; goes from #$60 to #$00, timer after dying before showing score
DELAY_TIME_LOW_BYTE            = $2a   ; the low byte of the delay
DELAY_TIME_HIGH_BYTE           = $2b   ; the high byte of the delay
LEVEL_ROUTINE_INDEX            = $2c   ; the index into level_routine_ptr_tbl of the routine to run
END_LEVEL_ROUTINE_INDEX        = $2d   ; offset into either end_level_sequence_ptr_tbl or end_game_sequence_ptr_tbl
DEMO_FIRE_DELAY_TIMER          = $2e   ; the number of frames to delay before starting to fire when demoing
PLAYER_WEAPON_STRENGTH         = $2f   ; the damage strength of the player's current weapon (see weapon_strength) based on bits 0-2 of P1_CURRENT_WEAPON,x
                                       ; Default = #$00, M = #$02, F = #$01, S = #$03, L = #$02
CURRENT_LEVEL                  = $30   ; #$00-#$09, #$00 to #$07 represent levels 1 through 8. #$9 is interpreted as game over sequence
GAME_COMPLETION_COUNT          = $31   ; the number of times the game has been completed (final boss defeated)
P1_NUM_LIVES                   = $32   ; P1 number of lives, #$00 is last life, on game over stays #$00, but P1_GAME_OVER_STATUS becomes #$01
P2_NUM_LIVES                   = $33   ; P2 number of lives, #$00 is last life, on game over stays #$00, but P2_GAME_OVER_STATUS becomes #$01
RANDOM_NUM                     = $34   ; random number increased in forever_loop
NUM_PALETTES_TO_LOAD           = $36   ; the number of palettes to load into CPU memory
INDOOR_SCREEN_CLEARED          = $37   ; whether indoor screen has had all cores destroyed (0 = not cleared, 1 = cleared, #$80 = cleared and fence removed)
P1_GAME_OVER_STATUS            = $38   ; #$00 not game over, #$01 game over
P2_GAME_OVER_STATUS            = $39   ; #$00 not game over, #$01 game over or player 2 not playing (1 player game)
NUM_CONTINUES                  = $3a   ; the number of continues remaining
BOSS_DEFEATED_FLAG             = $3b   ; whether or not the level boss has been defeated (0 = no, 1 = yes)
                                       ; after set to 1, end level sequence logic uses this value as well using values #$81 and #$02
EXTRA_LIFE_SCORE_LOW           = $3c   ; the low byte of the score required for the next extra life
EXTRA_LIFE_SCORE_HIGH          = $3d   ; the high byte of the score required for the next extra life
                                       ; $3e is the EXTRA_LIFE_SCORE_LOW for player 2
KONAMI_CODE_NUM_CORRECT        = $3f   ; the number of successful inputs of the Konami code sequence #$0a for all correct
                                       ; also used as player 2's EXTRA_LIFE_SCORE_HIGH byte during game play

; level header data
LEVEL_LOCATION_TYPE            = $40 ; current level type #$00 outdoor, #$01 indoor (base level); #$80 on indoor/base boss screen and indoor/base levels when players advancing to next screen
LEVEL_SCROLLING_TYPE           = $41 ; current level scrolling type #$00 horizontal (and indoor/base level) #$01 vertical
LEVEL_SCREEN_SUPERTILES_PTR    = $42 ; $42,$43 stores 2-byte address to bank 2 containing which super-tiles to use for each screen of the level (level_x_supertiles_screen_ptr_table)
LEVEL_SUPERTILE_DATA_PTR       = $44 ; current level 2-byte pointer to super-tile data, which defines pattern table tiles of the super-tiles that are used to make level blocks
LEVEL_SUPERTILE_PALETTE_DATA   = $46 ; current level 2-byte pointer address to the palettes used for each super-tile, each byte describes the 4 palettes for a single super-tile
LEVEL_ALT_GRAPHICS_POS         = $48 ; how far into level (in number of screens) before loading alternate graphic data
COLLISION_CODE_1_TILE_INDEX    = $49 ; pattern table tiles below this tile index (but not #$00) are considered Collision Code 1 (floor)
COLLISION_CODE_0_TILE_INDEX    = $4a ; pattern table tiles >= $49 and less than this tile index are considered Collision Code 0 (empty)
COLLISION_CODE_2_TILE_INDEX    = $4b ; pattern table tiles >= $4a and less than this tile index are considered Collision Code 2 (water)

LEVEL_PALETTE_CYCLE_INDEXES    = $4c ; palette indexes into game_palettes to cycle through for the level for the 4th nametable palette index [$4c-4f]
LEVEL_PALETTE_INDEX            = $50 ; the level's initial background palettes [$50 to $54) and sprite palettes [$54 to $58). Offsets into game_palettes table

LEVEL_STOP_SCROLL              = $58 ; the screen of the level to stop scrolling, set to #$ff when boss auto scroll starts
LEVEL_SOLID_BG_COLLISION_CHECK = $59 ; used to determine whether to check for bullet and weapon item solid bg collisions
                                     ; 1. When non-zero, specifies weapon item should check for solid bg collisions (weapon_item_check_bg_collision)
                                     ; 2. When negative, used to let bullet (player and enemy) collision detection code to know to look for bullet-solid background collisions
                                     ;    This is for levels 6 - energy zone and 7 - hangar. (see check_bullet_solid_bg_collision and enemy_bullet_routine_01)

DEMO_INPUT_NUM_FRAMES           = $5a ; used to determine how many even-numbered frames to continue pressing the button specified in $5c for demo
                                      ; $5b the DEMO_INPUT_NUM_FRAMES for player 2
DEMO_INPUT_VAL                  = $5c ; the current controller input pressed during a demo
                                      ; $5d is DEMO_INPUT_VAL for player 2
DEMO_INPUT_TBL_INDEX            = $5e ; when in demo, this stores the offset into specific demo_input_tbl_lX_pX table
                                      ; $5f is for player 2
PPU_WRITE_TILE_OFFSET           = $60 ; the current write offset of the super-tile data, number of tiles outside the current view
                                      ; horizontal levels loops #$00 to #$1f, vert starts with #$1d goes down to #$00 before looping
LEVEL_TRANSITION_TIMER          = $61 ; used in vertical levels to time animation between sections for every 'up' input
                                      ; used in indoor levels between screens to animate moving forward
PPU_WRITE_ADDRESS_LOW_BYTE      = $62 ; used to populate the PPU write address in the CPU_GRAPHICS_BUFFER
PPU_WRITE_ADDRESS_HIGH_BYTE     = $63 ; used to populate the PPU write address in the CPU_GRAPHICS_BUFFER
LEVEL_SCREEN_NUMBER             = $64 ; the screen number of the current level (how many screens into the level)
LEVEL_SCREEN_SCROLL_OFFSET      = $65 ; the number of pixels into LEVEL_SCREEN_NUMBER the level has scrolled. Goes from #$00-#$ff for each screen (256 pixels)
                                      ; for horizontal levels, this is how many pixels scrolled to the right
                                      ; for vertical levels, this is how many pixels up scrolled, note this value is equal to #$f0 - VERTICAL_SCROLL
                                      ; for indoor levels, after defeating a wall, increases from #$00 to #03
ATTRIBUTE_TBL_WRITE_LOW_BYTE    = $66 ; the low byte of the attribute table write address to write to (always #$c0, never read)
ATTRIBUTE_TBL_WRITE_HIGH_BYTE   = $67 ; the high byte of the attribute table write address to write to
FRAME_SCROLL                    = $68 ; how much to scroll the screen this frame based on player velocity (usually #$00 or #$01), for vertical levels, up to #$04
                                      ; note that this is not the scroll distance within the screen
SUPERTILE_NAMETABLE_OFFSET      = $69 ; base nametable offset into memory address into CPU graphics buffer starting at $0600 (LEVEL_SCREEN_SUPERTILES)
                                      ; always either #$00 (nametable 0) or #$40 (nametable 1), points to area that contains the super-tile indexes for screen
SPRITE_LOAD_TYPE                = $6a ; which sprites to load #$0 for normal sprites, #$1 for HUD sprites
CONT_END_SELECTION              = $6b ; #$00 when "CONTINUE" is selected, #$01 when "END" is selected, used only in game over screen (level_routine_06)
ALT_GRAPHIC_DATA_LOADING_FLAG   = $71 ; #$00 means that the alternate graphics data should not be loaded, #$01 means it should be #$02 means it currently is being loaded
LEVEL_PALETTE_CYCLE             = $72 ; the current iteration of the palette animation loop #$00 up to entry for level in lvl_palette_animation_count
INDOOR_SCROLL                   = $73 ; scrolling on indoor level changes (#$00 = not scrolling; #$01 = scrolling, #$02 = finished scrolling)
BG_PALETTE_ADJ_TIMER            = $74 ; timer used for adjusting background palette colors (not sprite palettes). Used for fade-in effect of dragon and boss ufo as well as indoor transitions
AUTO_SCROLL_TIMER_00            = $75 ; used when completing scroll to show a boss, e.g. vertical level dragon screen
AUTO_SCROLL_TIMER_01            = $76 ; used when completing scroll to show a boss, e.g. alien guardian
TANK_AUTO_SCROLL                = $77 ; amount to scroll every frame, regardless of AUTO_SCROLL_TIMER_xx, used for snow field tanks (dogras), breaks levels if used on other levels
PAUSE_PALETTE_CYCLE             = $78 ; #$00 - nametable palettes #$03 and #$04 will cycle through colors like normal. Non-zero values will pause palette color cycling (ice field tank pauses palette cycle)
SOLDIER_GENERATION_ROUTINE      = $79 ; which routine is currently in use for generating soldiers (index into soldier_generation_ptr_tbl)
SOLDIER_GENERATION_TIMER        = $7a ; a timer between soldier generation. #$00 means no generation. see level_soldier_generation_timer. When used in a level, every frame decrements by 2 (unless scrolling, then only by 1)
SOLDIER_GENERATION_X_POS        = $7b ; the initial x position of the generated soldier
SOLDIER_GENERATION_Y_POS        = $7c ; the initial y position of the generated soldier
FALCON_FLASH_TIMER              = $7d ; the number of frames to flash the screen for falcon weapon item
TANK_ICE_JOINT_SCROLL_FLAG      = $7f ; whether or not to have the ice joint enemy move left while player walks right to simulate being on the background
ENEMY_LEVEL_ROUTINES            = $80 ; two byte address to the correct enemy_routine_level_XX for the current level, used to retrieve enemy routines for the level-specific enemies
ENEMY_SCREEN_READ_OFFSET        = $82 ; read offset into level_xx_enemy_screen_xx table, which specifies the enemies on each screen of a level
ENEMY_CURRENT_SLOT              = $83 ; when in use, specifies the current enemy slot that is being executed, used to be able to restore x register after method has used it
BOSS_AUTO_SCROLL_COMPLETE       = $84 ; set when boss reveal auto-scrolling has completed, see AUTO_SCROLL_TIMER_00 and AUTO_SCROLL_TIMER_01
BOSS_SCREEN_ENEMIES_DESTROYED   = $85 ; used on level 3 and level 7 boss screens to keep track of how many dragon arm orbs or mortar launchers have been destroyed respectively
WALL_CORE_REMAINING             = $86 ; remaining wall cores/wall platings to destroy until can advance to next screen. For level 4 boss, used to count remaining boss gemini
WALL_PLATING_DESTROYED_COUNT    = $87 ; used in indoor/base boss levels to keep track of how many wall platings (ENEMY_TYPE #$0a) have been destroyed
INDOOR_ENEMY_ATTACK_COUNT       = $88 ; used in indoor/base levels to specify how many 'rounds' of attack have happened per screen, max #$07 before certain enemies no longer generate
                                      ; indoor soldiers, jumping soldiers, indoor rollers, and wall core check this value
INDOOR_RED_SOLDIER_CREATED      = $89 ; used in indoor/base levels to indicate if a red jumping soldier has been created, to prevent creation of another
GRENADE_LAUNCHER_FLAG           = $8a ; used in indoor/base levels to indicate that a grenade launcher enemy (ENEMY_TYPE #$17) is on the screen. Prevents other indoor enemies from being generated
ALIEN_FETUS_AIM_TIMER_INDEX     = $8b ; used to keep track of the index into alien_fetus_aim_timer_tbl to set the delay between re-aiming towards the player
ENEMY_ATTACK_FLAG               = $8e ; whether or not enemies will fire at player, also whether or not random enemies are generated, bosses ignore this value
PLAYER_STATE                    = $90 ; #$00 falling into level (only run once to init fall), #$01 normal state, #$02 when dead, #$03 can't move
                                      ; $91 is for p2, if p2 not playing, set to #$00
INDOOR_TRANSITION_X_ACCUM       = $92 ; a variable to store INDOOR_TRANSITION_X_FRACT_VEL being added to itself to account for overflow before adding to player x velocity when moving between screens on indoor/base levels
                                      ; $93 is for p2
PLAYER_JUMP_COEFFICIENT         = $94 ; related to jump height (used by speed runners to jump higher) (https://www.youtube.com/watch?v=K7MjxHvWof8 and https://www.youtube.com/watch?v=yrnW9yQXa9I)
                                      ; used to keep track of fractional y velocity on vertical levels for overflowing fractional velocity. It isn't cleared between jumps
                                      ; also used when walking into screen for indoor screen changes to keep track of overflow of animation y fractional velocity
                                      ; $95 is for player 2
INDOOR_TRANSITION_X_FRACT_VEL   = $96 ; indoor animation transition when walking into screen x fractional velocity
                                      ; $97 is for player 2
PLAYER_X_VELOCITY               = $98 ; the player's fast x velocity (#$00, #$01, or #$ff)
                                      ; $99 is for p2
INDOOR_TRANSITION_Y_FRACT_VEL   = $9a ; indoor animation transition when walking into screen y fractional velocity
                                      ; $9b is for player 2
INDOOR_TRANSITION_Y_FAST_VEL    = $9c ; indoor animation transition when walking into screen y fast velocity
                                      ; $9d is for player 2
PLAYER_ANIM_FRAME_TIMER         = $9e ; value that is incremented every frame when player is walking, used to wait #$08 frames before incrementing PLAYER_ANIMATION_FRAME_INDEX for animating player walking
                                      ; $9f is for player 2
PLAYER_JUMP_STATUS              = $a0 ; the status of the player jump (facing direction); similar to EDGE_FALL_CODE
                                      ; high nibble is for facing direction
                                      ; bit 7 - set when jumping left
                                      ; low nibble is #$01 when jumping, #$00 when not
                                      ; $a1 is for player 2
PLAYER_FRAME_SCROLL             = $a2 ; how much player 1 is causing the frame to scroll by, see FRAME_SCROLL
                                      ; $a3 is for player 2, larger of the 2 is set to FRAME_SCROLL
EDGE_FALL_CODE                  = $a4 ; similar to PLAYER_JUMP_STATUS. Used to initiate gravity pulling player down
                                      ; if bit 7 set, then falling through platform
                                      ; if bit 6 is set, then walking left off edge
                                      ; if bit 5 is set, then walking right off ledge
                                      ; can change if change direction during fall, bit 0 always set when EDGE_FALL_CODE non-zero
                                      ; $a5 is for player 2
PLAYER_ANIMATION_FRAME_INDEX    = $a6 ; which frame of the player animation. Depends on player state. For example, if player is running, this cycles from #$00 to #$05
                                      ; $a7 is for player 2
PLAYER_INDOOR_ANIM_Y            = $a8 ; the y position the player was at when they started walking into screen after clearing an indoor level. I believe it's always #$a8 since y pos is hard-coded for indoor levels
                                      ; $a9 is player 2
P1_CURRENT_WEAPON               = $aa ; low nibble is what weapon P1 has, high nibble 1 is rapid fire flag, commonly abbreviated MFSL
                                      ; #$00 - Regular, #$01 - Machine Gun, #$02 - Flame Thrower, #$03 - Spray, #$04 - Laser, bit 4 set for rapid fire
P2_CURRENT_WEAPON               = $ab ; byte 0 is what weapon P2 has, byte 1 is rapid fire flag
PLAYER_M_WEAPON_FIRE_TIME       = $ac ; used when holding down the B button with the m weapon.  High nibble is number of bullets generated (up to #$06), low nibble is counter before next bullet is generated (up to #$07)
                                      ; $ad is for player 2
NEW_LIFE_INVINCIBILITY_TIMER    = $ae ; timer for invincibility after dying
                                      ; $af is for player 2
INVINCIBILITY_TIMER             = $b0 ; timer for player invincibility (b (barrier) weapon) (decreases every 8 frames), usually set to #$80 except level 7 when set to #$90
                                      ; $b1 is for player 2
PLAYER_WATER_STATE              = $b2 ; bit 1 - horizontal sprite flip flag
                                      ; bit 2 - set when player in water, or exiting water
                                      ; bit 3 - player is walking out of water
                                      ; bit 4 - finished initialization for entering water
                                      ; bit 7 - player is walking out of water
                                      ; $b3 is for player 2
PLAYER_DEATH_FLAG               = $b4 ; bit 0 specifies whether player has died, bit 1 specifies player was facing left when hit, used so player dies lying in appropriate direction
                                      ; $b5 is for player 2
PLAYER_ON_ENEMY                 = $b6 ; whether or not the player is on top of another enemy (#$14 - mining cart, #$15 - stationary mining cart, #$10 - floating rock platform)
                                      ; $b7 is for player 2
PLAYER_FALL_X_FREEZE            = $b8 ; used to prevent changing X velocity shortly after walking off/falling through ledge, set to Y post of ledge + #$14
                                      ; $b9 is for player 2
PLAYER_HIDDEN                   = $ba ; #$00 player visible, #$01/#$ff player invisible (any non-zero). I believe it is meant to track distance off screen the player is
                                      ; $bb is for player 2
PLAYER_SPRITE_SEQUENCE          = $bc ; which animation to show for the player
                                      ; outdoor - #$00 standing (no animation), #$01 gun pointing up, #$02 crouching, #$03 walking or curled jump animation, #$04 dead animation
                                      ; indoor - (see indoor_player_sprite_tbl), #$00 standing facing back wall, #$01 electrocuted, #$02 crouching, #$03 walking left/right animation, #$05 walking into screen (advancing), #$06 dead animation
                                      ; $bd is for player 2
PLAYER_INDOOR_ANIM_X            = $be ; the x position the player was at when they started walking into screen after clearing an indoor level
                                      ; $bf is player 2
PLAYER_AIM_PREV_FRAME           = $c0 ; backup of PLAYER_AIM_DIR
                                      ; $c1 is for player 2
PLAYER_AIM_DIR                  = $c2 ; which direction the player is aiming [#$00-#$0a] depends on level and jump status (00 up facing right, 1 up-right, 2 right, 3 right-down, 4 crouching facing right, 5 crouching facing left, etc)
                                      ; there are #$02 up and #$02 down values depending on facing direction
                                      ; $c3 is for player 2
PLAYER_Y_FRACT_VELOCITY         = $c4 ; the fractional portion of the player's y velocity
                                      ; $c5 is for player 2
PLAYER_Y_FAST_VELOCITY          = $c6 ; the integer portion of the player's y velocity. Positive pulls down, negative pulls up
                                      ; $c7 is for player 2
ELECTROCUTED_TIMER              = $c8 ; timer for player being electrocuted, used to freeze player and modify look after touching electricity
                                      ; $c9 is for player 2
INDOOR_PLAYER_JUMP_FLAG         = $ca ; used when entering new screen to tell the engine to cause the player to jump
                                      ; $cb is player 2
PLAYER_WATER_TIMER              = $cc ; timer used for getting into and out of water
                                      ; $cd is for player 2
PLAYER_RECOIL_TIMER             = $ce ; how many frames to be pushed back/down from recoil
                                      ; $cf is for player 2
INDOOR_PLAYER_ADV_FLAG          = $d0 ; whether or not the player is walking into screen when advancing between screens on indoor levels, used for animating player
                                      ; $d1 is for player 2
PLAYER_SPECIAL_SPRITE_TIMER     = $d2 ; used to track animation for player death animation
                                      ; outdoor is a timer that increments once player hit, every #$08 frames updates to next animation frame until #$04
                                      ; also used to track jumping curl animation (loops from #$00-#$04)
                                      ; $d3 is for player 2
PLAYER_FAST_X_VEL_BOOST         = $d4 ; the x fast velocity boost from landing on a non-dangerous enemy, e.g. moving cart or floating rock in vertical level
                                      ; $d5 is for player 2
PLAYER_SPRITE_CODE              = $d6 ; sprite code of the player
                                      ; $d7 is for player 2
PLAYER_SPRITE_FLIP              = $d8 ; stores player sprite horizontal (bit 6) and vertical (bit 7) flip flags before saving into SPRITE_ATTR, other bits are used
                                      ; bit 3 specifies whether the PLAYER_ANIMATION_FRAME_INDEX is even or odd (see @check_anim_frame_and_collision)
                                      ; $d9 is for player 2
PLAYER_BG_FLAG_EDGE_DETECT      = $da ; bit 7 specifies the player's sprite attribute for background priority, allows player to walk behind opaque background (OAM byte 2 bit 5)
                                      ; 0 (clear) sprite in foreground, 1 (set) sprite is background
                                      ; bit 0 allows the player to keep walking horizontally off a ledge without falling
                                      ; $db is for player 2
PLAYER_GAME_OVER_BIT_FIELD      = $df ; combination of both players game over status
                                      ; #$00 = p1 not game over, p2 game over (or not playing), #$01 = p1 game over, p2 not game over, #$02 = p1 nor p2 are in game over
SOUND_TABLE_PTR                 = $ec ; low byte of address pointing of index into sound_table_00 offset INIT_SOUND_CODE
CONTROLLER_STATE                = $f1 ; stores the currently-pressed buttons for player 1
                                      ; bit 7 - A, bit 6 - B, bit 5 - select, bit 4 - start
                                      ; bit 3 - up, bit 2 - down, bit 1 - left, bit 0 - right
                                      ; $f2 stores the currently-pressed buttons for player 2
CONTROLLER_STATE_DIFF           = $f5 ; stores the difference between the controller input between reads. Useful for events that should only trigger on first button press
                                      ; $f6 is for player 2
CTRL_KNOWN_GOOD                 = $f9 ; used in input-reading code to know the last known valid read of controller input (similar to CONTROLLER_STATE)
                                      ; $fa is for player 2
VERTICAL_SCROLL                 = $fc ; the number of pixels to vertically scroll down
                                      ; (y component of PPUSCROLL) (see level_vert_scroll_and_song for initial values)
                                      ; horizontal levels are always #$e0 (224 pixels or 28 tiles down), indoor/base are always #$e8 (232 or 29 tiles down)
                                      ; waterfall level (vertical level) starts at #$00 and decrements as players move up screen (wrapping)
HORIZONTAL_SCROLL               = $fd ; the horizontal scroll component of the PPUSCROLL, [#$00 - #$ff]
PPUMASK_SETTINGS                = $fe ; used to store value of PPUMASK before writing to PPU
PPUCTRL_SETTINGS                = $ff ; used to set PPUCTRL value for next frame

SOUND_CMD_LENGTH            = $0100 ; how many video frames the sound count should last for, i.e. the time to wait before reading next sound command
                                    ; #$06 bytes, one for each sound slot
SOUND_CODE                  = $0106 ; the sound code for the sound slot, #$06 slots
SOUND_PULSE_LENGTH          = $010c ; APU_PULSE_LENGTH, #$06 slots
SOUND_CMD_LOW_ADDR          = $0112 ; low byte of address to current sound command in sound_xx data. #$06 slots, one per sound slot
SOUND_CMD_HIGH_ADDR         = $0118 ; high byte of address to current sound command in sound_xx data. #$06 slots, one per sound slot
SOUND_VOL_ENV               = $011e ; either an offset into pulse_volume_ptr_tbl (c.f. LVL_PULSE_VOL_INDEX) which specifies the volume for the frame
                                    ; or a specific volume to use. When bit 7 is set, then the volume will auto decrescendo
SOUND_CURRENT_SLOT          = $0120 ; the current sound slot [#$00-#$05]
PERCUSSION_INDEX_BACKUP     = $0121 ; backup location for percussion_tbl index to restore after call to play_sound
INIT_SOUND_CODE             = $0122 ; the sound code to load; sound codes greater than #$5a are dmc sounds
SOUND_CHNL_REG_OFFSET       = $0123 ; sound channel configuration register offset, i.e. #$00 for first pulse channel, #$04 for second, #$08 for triangle, #$0c for noise
SOUND_FLAGS                 = $0124 ; sound channel flags
                                    ; bit 0 - 0 = sound_xx command byte >= #$30 (read_low_sound_cmd), 1 = sound_xx command byte 0 < #$30 (read_high_sound_cmd)
                                    ; bit 1 - 1 = DECRESCENDO_END_PAUSE has triggered and decrescendo can resume, 0 = keep volume constant
                                    ; bit 2 - 0 = use lvl_config_pulse to set volume for frame, 1 = automatic decrescendo logic (handling DECRESCENDO_END_PAUSE)
                                    ; bit 3 - used in sound_cmd_routine_03, signifies that a shared (child) sound command (sound_xx_part) is executing, specified by #$fd, or #$fe in sound command
                                    ;         used to know, after finishing parsing a sound command, whether or not to done or should return to parent sound command
                                    ; bit 4 - slightly flatten note (see @flatten_note and @flip_flatten_note_adv)
                                    ; bit 5 - 1 = PULSE_VOL_DURATION has counted down and decrescendo should be paused until DECRESCENDO_END_PAUSE
                                    ;         set to ignore SOUND_VOL_ENV negative check, i.e. override to decrescendo
                                    ; bit 6 - mute flag (1 = muted, 0 = not muted)
                                    ; bit 7 - sweep flag
LVL_PULSE_VOL_INDEX         = $012a ; index into lvl_x_pulse_volume_xx to read
PULSE_VOL_DURATION          = $012a ; the number of video frames to decrement the volume for, before stopping decrescendo and keeping final volume
PAUSE_STATE_01              = $012f ; whether or not the game is paused, used for sound logic
DECRESCENDO_END_PAUSE       = $0130 ; number of video frames before end of sound command in which the decrescendo will resume
                                    ; $0131 is for pulse channel 2
SOUND_PITCH_ADJ             = $0132 ; the amount added to the sound byte low nibble before loading the correct note_period_tbl values
UNKNOWN_SOUND_00            = $0136 ; amount to multiply to SOUND_CMD_LENGTH,x when calculating DECRESCENDO_END_PAUSE,x
UNKNOWN_SOUND_01            = $013c ; used to adjust volume amount when setting volume
SOUND_CFG_LOW               = $0142 ; the value to merge with the high nibble before storing in apu channel config register
SOUND_TRIANGLE_CFG          = $0144 ; in memory value for APU_TRIANGLE_CONFIG
SOUND_REPEAT_COUNT          = $0148 ; used for #$fe sound commands to specify how many times to repeat a shared sound part, e.g. .byte $fe, $03, .addr sound_xx_part to loop 3 times. #$06 slots
SOUND_CFG_HIGH              = $014e ; the value to merge with the volume when saving the pulse config
SOUND_LENGTH_MULTIPLIER     = $0154 ; value used when determining how many video frames to wait before reading next sound command, #$06 bytes, one for each sound slot
                                    ; ultimately used when calculating SOUND_CMD_LENGTH, and kept around between sound commands so subsequent notes can be the same length
                                    ; for low sound codes, SOUND_LENGTH_MULTIPLIER is set to SOUND_CMD_LENGTH directly with no multiplication (see @high_nibble_not_1)
SOUND_PERIOD_ROTATE         = $015a ; when not #$04, the number of times to shift the high byte of note_period_tbl into the low byte
PULSE_VOLUME                = $0160 ; low nibble only, stores the volume for the pulse channels
NEW_SOUND_CODE_LOW_ADDR     = $0166 ; sound command return location low byte once sound command specified in move_sound_code_read_addr executes, e.g. jungle boss siren
NEW_SOUND_CODE_HIGH_ADDR    = $016c ; sound command return location high byte once sound command specified in move_sound_code_read_addr executes, e.g. jungle boss siren
SOUND_PULSE_PERIOD          = $0172 ; APU_PULSE_PERIOD
VIBRATO_CTRL                = $0178 ; vibrato control mode [#$00-#$03], #$80 = no vibrato
                                    ; even values cause the note to stay the same, odd values cause vibrato #$03 = pitch up, #$01 = pitch down
                                    ; $0178 is for sound slot #$00 and $0719 is for sound slot #$01
SOUND_VOL_TIMER             = $017a ; sound command counter; increments up to VIBRATO_DELAY, at which vibrato will be checked
                                    ; only increments when VIBRATO_CTRL is non-negative, i.e. not #$80
PULSE_NOTE                  = $017c ; the note that is sustained or has the vibrato applied to for pulse channels (in Contra only ever sustained no vibrato)
                                    ; $017c is for sound slot #$00 and $071d is for sound slot #$01
VIBRATO_DELAY               = $017e ; used to delay start of vibrato until SOUND_VOL_TIMER has counted up to this value
                                    ; if a note isn't as long as VIBRATO_DELAY, i.e. SOUND_CMD_LENGTH < VIBRATO_DELAY, then vibrato won't be considered for a note
                                    ; $017e is for sound slot #$00 and $071f is for sound slot #$01
VIBRATO_AMOUNT              = $0180 ; the amount of vibrato to apply
LEVEL_END_DELAY_TIMER       = $0190 ; a delay timer before beginning level end animation sequence
LEVEL_END_SQ_1_TIMER        = $0191 ; a delay timer specifying the duration of end_level_sequence_01, decremented every other frame
LEVEL_END_LVL_ROUTINE_STATE = $0192 ; used by level end routines (end_of_lvl_routine_...) for managing animation state.
                                    ; for example, indoor level end animations have 4 states: walk to elevator, initialize elevator sprite, ride elevator
                                    ; $0193 is for player 2
LEVEL_END_PLAYERS_ALIVE     = $0194 ; the number of players alive at the end of the level, used to know if should play level end music
SOLDIER_GEN_SCREEN          = $0195 ; the current screen that soldiers are being generated for
SCREEN_GEN_SOLDIERS         = $0196 ; the total number of soldiers that have been generated for the current screen (exe_soldier_generation)
OAMDMA_CPU_BUFFER           = $0200 ; $0200-$02ff OAMDMA (sprite) read data, read once per frame, populated by load_sprite_to_CPU_mem, draw_hud_sprites, or draw_player_hud_sprites

CPU_SPRITE_BUFFER = $0300 ; sprites on screen, each byte is an entry into sprite_ptr_tbl [$0300-$0387], memory is segmented as defined below
PLAYER_SPRITES    = $0300 ; player sprites, p1 and p2 sprite, then player bullets, each byte is an entry into sprite_ptr_tbl (#$0a bytes)
ENEMY_SPRITES     = $030a ; enemy sprites to load on screen, each byte is an entry into sprite_ptr_tbl (#$0f bytes)
SPRITE_Y_POS      = $031a ; y position on screen of each player sprite. First 2 bytes are for player sprites. Starts at #$00 for top increases downward (#$0a bytes)
ENEMY_Y_POS       = $0324 ; y position on screen of each enemy sprite. Starts at #$00 for top increases downward (#$0f bytes)
SPRITE_X_POS      = $0334 ; x position of screen of each player sprite. First 2 bytes are for player sprites (#$0a bytes)
ENEMY_X_POS       = $033e ; x position on screen of each enemy sprite (#$0f bytes)
SPRITE_ATTR       = $034e ; sprite attribute, specifies palette, vertical flip, horizontal flip (#$0a bytes)
                          ; and whether to adjust y position
                          ; bit 0 and 1 - sprite palette
                          ; bit 2 - 0 to use default palette as specified in sprite code
                          ;       - 1 to use palette specified in bits 0 and 1
                          ; bit 3 - whether to add #$01 to sprite y position, used for recoil effect firing weapon
                          ; bit 5 - bg priority
                          ; bit 6 - whether to flip the sprite horizontally
                          ; bit 7 - whether to flip the sprite vertically
                          ; bytes 0 and 1 are p1 and p2 sprite attributes, then each byte is the player bullet sprite attributes
                          ; examples: player being electrocuted or invincible (flashes various colors)
ENEMY_SPRITE_ATTR = $0358 ; enemy sprite attribute. See specification above (#$0f bytes)

PLAYER_BULLET_SPRITE_CODE    = $0368 ; The sprite codes to load for the bullet, eventually copied into CPU_SPRITE_BUFFER starting at offset 2
PLAYER_BULLET_SPRITE_ATTR    = $0378 ; The sprite attributes for the bullet (see SPRITE_ATTR for specification)
                                     ; used for L bullets for flipping the angled sprites depending on direction
PLAYER_BULLET_SLOT           = $0388 ; #$00 when no bullet, otherwise stores bullet type + 1, i.e. #$01 basic, #$02 M, #$03 F bullet, #$04 S, #$05 L, can be negative sometimes
PLAYER_BULLET_VEL_Y_ACCUM    = $0398 ; an accumulator to keep track of PLAYER_BULLET_Y_VEL_FRACT being added to itself have elapsed before adding 1 to PLAYER_BULLET_Y_POS
PLAYER_BULLET_VEL_X_ACCUM    = $03a8 ; an accumulator to keep track of PLAYER_BULLET_X_VEL_FRACT being added to itself have elapsed before adding 1 to PLAYER_BULLET_X_POS
PLAYER_BULLET_Y_POS          = $03b8 ; the bullet's sprite y position
PLAYER_BULLET_X_POS          = $03c8 ; the bullet's sprite x position
                                     ; for F bullets, PLAYER_BULLET_FS_X and PLAYER_BULLET_X_POS together determine x position
PLAYER_BULLET_Y_VEL_FRACT    = $03d8 ; percentage out of 0-255 set number of frames until Y position is incremented by an additional 1 unit
PLAYER_BULLET_X_VEL_FRACT    = $03e8 ; percentage out of 0-255 set number of frames until X position is incremented by an additional 1 unit
PLAYER_BULLET_Y_VEL_FAST     = $03f8 ; player bullet velocity y integer portion
PLAYER_BULLET_VEL_X_FAST     = $0408 ; player bullet velocity x integer portion
PLAYER_BULLET_TIMER          = $0418 ; 'timer' starts at #$00. Used by F, S (indoor only) and L
                                     ; for indoor S, used to specify size of bullet
                                     ; For F, used to set x and y pos when traveling to create swirl (see f_bullet_outdoor_x_swirl_amt_tbl, and f_bullet_outdoor_y_swirl_amt_tbl)
                                     ; increments or decrements every frame depending on firing direction (left decrement, right increment)
                                     ; For L used to spread out 4 lasers for one shot
PLAYER_BULLET_AIM_DIR        = $0428 ; the direction of the bullet #$00 for up facing right, incrementing clockwise up to #09 for up facing left
PLAYER_BULLET_ROUTINE        = $0438 ; #$00, #$01, or #$03, offset into player_bullet_routine_XX_(indoor_)ptr_tbl
PLAYER_BULLET_OWNER          = $0448 ; #$00 player 1 bullet, #$01 player 2 bullet, each byte is for a bullet
PLAYER_BULLET_F_RAPID        = $0458 ; #$01 for player indoor bullets for F weapon when rapid fire is enabled
PLAYER_BULLET_S_INDOOR_ADJ   = $0458 ; (same address as previous) for indoor S bullets, specifies whether to adjust PLAYER_BULLET_X_POS by an additional -1 (#$ff) every frame (see s_bullet_pos_mod_tbl)
PLAYER_BULLET_DIST           = $0468 ; represents how far a bullet has traveled
                                     ; For S outdoor bullets, used to determine the size (scale) of the bullet
                                     ; For F on indoor levels, used to determine spiraling position based on distance from player
PLAYER_BULLET_S_ADJ_ACCUM    = $0468 ; (same address as previous) for indoor S weapons, stores accumulated fractional velocity where overflow affects PLAYER_BULLET_S_INDOOR_ADJ (see update_s_bullet_indoor_pos)
PLAYER_BULLET_FS_X           = $0478 ; Used to offset from general x direction of bullet for swirl effect in F bullet and spread effect in S bullet (indoor)
                                     ; Specifies center x position on screen f bullet swirls around. Used when firing f bullet either left, right, or at an angle
PLAYER_BULLET_F_Y            = $0488 ; Specifies center y position on screen f bullet swirls around. Used when firing f bullet either up, down, or at an angle.
PLAYER_BULLET_S_RAPID        = $0488 ; (same address as previous) for S weapon in indoor levels, specifies whether weapon is rapid fire or not, not sure why $09 wasn't used like other bullet routines
PLAYER_BULLET_VEL_FS_X_ACCUM = $0498 ; (for F weapon only) an accumulator to keep track of PLAYER_BULLET_X_VEL_FRACT being added to itself have elapsed before adding 1 to PLAYER_BULLET_X_POS
PLAYER_BULLET_VEL_F_Y_ACCUM  = $04a8 ; (for F weapon only) an accumulator to keep track of PLAYER_BULLET_Y_VEL_FRACT being added to itself have elapsed before adding 1 to PLAYER_BULLET_Y_POS
PLAYER_BULLET_S_BULLET_NUM   = $04a8 ; (same address as previous) for S weapon only, specifies the number the bullet in the current 'spray' for the shot
                                     ; per shot of S weapon, #$05 bullets are generated. If no other bullets exist then
                                     ; $04a8 would have #$00, $04a9 would have #$01, $04a9 would have #$02, etc.

; each enemy property is #$10 bytes, one byte per enemy
ENEMY_ROUTINE            = $04b8 ; enemy routine indexes starting at offset #$f ($04c7) going to #$0 ($04b8)
                                 ; subtract 1 to get real routine, since all offsets are off by 1 (...routine_ptr_tbl -2)
                                 ; ex: for exploding bridge, setting ENEMY_ROUTINE to #$02 causes exploding_bridge_routine_01 to run the next frame

; the following 6 address ranges control the change in position of the enemy
; every frame the position is moved by VELOCITY_FAST units
; VELOCITY_FRACT can enable only moving by 1 unit every n frames
; for example, if ENEMY_Y_VELOCITY_FAST is #$00 and ENEMY_Y_VELOCITY_FRACT is #$c0, (#$c0/#$ff = 75%),
; then the enemy will move one position to the right 3 out of every 4 frames
ENEMY_Y_VEL_ACCUM      = $04c8 ; an accumulator to keep track of ENEMY_Y_VELOCITY_FRACT being added to itself have elapsed before adding 1 to ENEMY_Y_POS
ENEMY_X_VEL_ACCUM      = $04d8 ; an accumulator to keep track of ENEMY_X_VELOCITY_FRACT being added to itself have elapsed before adding 1 to ENEMY_X_POS
ENEMY_Y_VELOCITY_FAST  = $04e8 ; the number of units to add to ENEMY_Y_POS every frame
ENEMY_Y_VELOCITY_FRACT = $04f8 ; percentage out of 0-255 of a unit to add, e.g. if #$80 (#$80/#$ff = 50%), then every other frame will cause Y pos to increment by 1
ENEMY_X_VELOCITY_FAST  = $0508 ; the number of units to add to ENEMY_X_POS every frame
ENEMY_X_VELOCITY_FRACT = $0518 ; percentage out of 0-255 of a unit to add, e.g. if #$80 (#$80/#$ff = 50%), then every other frame will cause X pos to increment by 1

ENEMY_TYPE               = $0528 ; enemy type, e.g. #$03 = flying capsule
ENEMY_ANIMATION_DELAY    = $0538 ; used for various delays by enemy logic
ENEMY_VAR_A              = $0548 ; the sound code to play when enemy hit by player bullet, also used for other logic
                                 ; dragon arm orb uses it for adjusting enemy position, fire beam uses it for animation delay
ENEMY_ATTACK_DELAY       = $0558 ; the delay before an enemy attacks, for weapon items and grenades this is used for helping calculate falling arc trajectory instead of enemy delay
ENEMY_VAR_B              = $0558 ; for weapon items and grenades this is used for helping calculate falling arc trajectory
ENEMY_FRAME              = $0568 ; animation frame the enemy is in, typically indexes into an enemy type-specific table of sprite codes
ENEMY_SCORE_COLLISION    = $0588 ; represents 3 things for an enemy
                                 ; SSSS CCCC - score code (see `score_codes_tbl`), and collision type (entry in collision_box_codes_XX)
                                 ; also explosion type
ENEMY_HP                 = $0578 ; the HP of the enemy
ENEMY_STATE_WIDTH        = $0598 ; loaded from enemy_prop_ptr_tbl
                                 ; bit 7 set to allow bullets to travel through enemy, e.g. weapon item
                                 ; bit 6 specifies whether player can land on enemy (floating rock and moving cart), bit 4 also has to be 0 (see `beq @land_on_enemy`)
                                 ; bit 4 and 5 specify the collision box type (see collision_box_codes_tbl)
                                 ; bit 3 determines the explosion type (explosion_type_ptr_tbl), either explosion_type_00 or explosion_type_01
                                 ; bit 2 for bullets specifies whether to play sound on collision
                                 ; bit 1 specifies whether to play explosion noise; also specifies width of enemy
                                 ; bit 0 - #$00 test player-enemy collision, #$01 means to skip player-enemy collision test
ENEMY_ATTRIBUTES         = $05a8 ; enemy type-specific attributes that define how an enemy behaves and/or looks
ENEMY_VAR_1              = $05b8 ; a byte available to each enemy for whatever they want to use it for (#$f bytes, 1 per enemy)
ENEMY_VAR_2              = $05c8 ; a byte available to each enemy for whatever they want to use it for (#$f bytes, 1 per enemy)
ENEMY_VAR_3              = $05d8 ; a byte available to each enemy for whatever they want to use it for (#$f bytes, 1 per enemy)
ENEMY_VAR_4              = $05e8 ; a byte available to each enemy for whatever they want to use it for (#$f bytes, 1 per enemy)
LEVEL_SCREEN_SUPERTILES  = $0600 ; CPU memory address where super tiles indexes for the screens of the level are loaded (level_X_supertiles_screen_XX data)
                                 ; 2 screens are stored in the CPU buffer.  The second screen loaded at $0640. Indexes are into level_x_supertile_data
                                 ; This data specifies the super-tiles (indexes) to load for the screens
BG_COLLISION_DATA        = $0680 ; map of collision types for each of the super-tiles for both nametables, each 2 bits encode 1/4 of a super-tile's collision information
                                 ; first 8 nibbles are a row of the top of super-tile, the next 8 are the middle middle. Not used on base (indoor) levels
CPU_GRAPHICS_BUFFER      = $0700 ; used to store data that will be then moved to the PPU later on. $700 to $750, repeating structure
                                 ; * byte $700 is multifaceted
                                 ;     * if $700 is #$0, then done writing graphics buffer to PPU
                                 ;     * if $700 is greater than #$0, then there is data to write, this byte is the offset into vram_address_increment
                                 ;       * both #$01, and #$03 signify VRAM address increment to 0, meaning to add #$1 every write to PPU (write across)
                                 ;       * #$02 signifies VRAM address increment is 1, meaning add #$20 (32 in decimal) every write to PPU (write down)
                                 ; if GRAPHICS_BUFFER_MODE is #$ff
                                 ; * byte $701 is length of the tiles being written per group
                                 ; * byte $702 is the number of $701-sized blocks to write to the PPU
                                 ;   * for each block, the block prefixed with 2 bytes specifying PPU address (high byte, then low byte)
                                 ; if GRAPHICS_BUFFER_MODE is #$00
                                 ; * if byte #$00 is #$00, then no drawing takes place for frame
                                 ; * blocks of text/palette data prefixed with 2 bytes specifying PPU address (high byte, then low byte)
                                 ; the block of text is ended with a #$ff, if the byte after #$ff is the vram_address_increment offset
                                 ; then the the process continues, i.e. read #$02 PPU address bytes, read next text

PALETTE_CPU_BUFFER     = $07c0 ; [$07c0-$07df] the CPU memory address of the palettes eventually loaded into the PPU $3f00 to $3f1f

HIGH_SCORE_LOW         = $07e0 ; the low byte of the high score score
HIGH_SCORE_HIGH        = $07e1 ; the high byte of the high score score
PLAYER_1_SCORE_LOW     = $07e2 ; the low byte of player 1 high score
PLAYER_1_SCORE_HIGH    = $07e3 ; the high byte of player 1 high score
PLAYER_2_SCORE_LOW     = $07e4 ; the low byte of player 1 high score
PLAYER_2_SCORE_HIGH    = $07e5 ; the high byte of player 1 high score
PREVIOUS_ROM_BANK      = $07ec ; the previously-loaded PRG BANK ($8000-$bfff)
PREVIOUS_ROM_BANK_1    = $07ed ; the previously-loaded PRG BANK, but used only for load_bank_1 (from play_sound)

; PPU (picture processing unit)
PPUCTRL       = $2000
PPUMASK       = $2001
PPUSTATUS     = $2002
OAMADDR       = $2003
PPUSCROLL     = $2005
PPUADDR       = $2006
PPUDATA       = $2007

; APU (audio processing unit)
APU_PULSE_CONFIG    = $4000 ; config - DDLC VVVV duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
APU_PULSE_SWEEP     = $4001 ; sweep  - EPPP NSSS enabled (E), period (P), negate (N), shift (S)
APU_PULSE_PERIOD    = $4002 ; timer  - TTTT TTTT timer low (T). Controls note frequency
APU_PULSE_LENGTH    = $4003 ; length - LLLL LTTT length counter load (L), timer high (T)
APU_PULSE2_CONFIG   = $4004 ; config - DDLC VVVV duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
APU_PULSE2_SWEEP    = $4005 ; config - DDLC VVVV duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
APU_TRIANGLE_CONFIG = $4008 ; config - CRRR RRRR length counter halt / linear counter control (C), linear counter load (R)
APU_NOISE_CONFIG    = $400c ; config - --LC VVVV envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
APU_DMC             = $4010 ; APU delta modulation channel
APU_DMC_COUNTER     = $4011 ; APU delta modulation channel load counter
APU_DMC_SAMPLE_ADDR = $4012 ; APU delta modulation channel sample address (location of sample)
APU_DMC_SAMPLE_LEN  = $4013 ; APU delta modulation channel sample length
OAMDMA              = $4014
APU_STATUS          = $4015 ; ---D NT21 - enable DMC (D), noise (N), triangle (T), and pulse channels (2/1)
APU_FRAME_COUNT     = $4017

; controller input addresses
CONTROLLER_1 = $4016
CONTROLLER_2 = $4017

; colors
COLOR_DARK_GRAY_00          = $00
COLOR_DARK_BLUE_01          = $01
COLOR_DARK_VIOLET_02        = $02
COLOR_DARK_PURPLE_03        = $03
COLOR_DARK_MAGENTA_04       = $04
COLOR_DARK_PINK_05          = $05
COLOR_DARK_RED_06           = $06
COLOR_DARK_ORANGE_07        = $07
COLOR_DARK_OLIVE_08         = $08
COLOR_DARK_FOREST_GREEN_09  = $09
COLOR_DARK_GREEN_0a         = $0a
COLOR_DARK_BLUE_GREEN_0b    = $0b
COLOR_DARK_TEAL_0c          = $0c
COLOR_BLACK_0f              = $0f
COLOR_LT_GRAY_10            = $10
COLOR_MED_BLUE_11           = $11
COLOR_MED_VIOLET_12         = $12
COLOR_MED_PURPLE_13         = $13
COLOR_MED_MAGENTA_14        = $14
COLOR_MED_PINK_15           = $15
COLOR_MED_RED_16            = $16
COLOR_MED_ORANGE_17         = $17
COLOR_MED_OLIVE_18          = $18
COLOR_MED_FOREST_GREEN_19   = $19
COLOR_MED_GREEN_1a          = $1a
COLOR_MED_BLUE_GREEN_1b     = $1b
COLOR_MED_TEAL_1c           = $1c
COLOR_BLACK_1d              = $1d ; not used
COLOR_MED_1e                = $1e ; not used
COLOR_BLACK_1f              = $1f ; not used
COLOR_WHITE_20              = $20
COLOR_LT_BLUE_21            = $21
COLOR_LT_VIOLET_22          = $22
COLOR_LT_PURPLE_23          = $23 ; not used
COLOR_LT_MAGENTA_24         = $24
COLOR_LT_PINK_25            = $25
COLOR_LT_RED_26             = $26
COLOR_LT_ORANGE_27          = $27
COLOR_LT_OLIVE_28           = $28
COLOR_LT_FOREST_GREEN_29    = $29
COLOR_LT_GREEN_2a           = $2a ; not used
COLOR_LT_BLUE_GREEN_2b      = $2b
COLOR_LT_TEAL_2c            = $2c
COLOR_GRAY_2D               = $2d ; not used
COLOR_BLACK_2e              = $2e ; not used
COLOR_BLACK_2f              = $2f ; not used
COLOR_WHITE_30              = $30
COLOR_PALE_BLUE_31          = $31 ; not used
COLOR_PALE_VIOLET_32        = $32
COLOR_PALE_PURPLE_33        = $33 ; not used
COLOR_PALE_MAGENTA_34       = $34 ; not used
COLOR_PALE_PINK_35          = $35
COLOR_PALE_RED_36           = $36
COLOR_PALE_ORANGE_37        = $37
COLOR_PALE_OLIVE_38         = $38
COLOR_PALE_FOREST_GREEN_39  = $39 ; not used
COLOR_PALE_GREEN_3a         = $3a ; not used
COLOR_PALE_BLUE_GREEN_3b    = $3b
COLOR_PALE_TEAL_3c          = $3c ; not used
COLOR_PALE_GRAY_3d          = $3d ; not used
COLOR_BLACK_3e              = $3e ; not used
COLOR_BLACK_3f              = $3f ; not used