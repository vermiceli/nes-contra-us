; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; constants.asm contains the list of constants with meaningful names for the
; memory addresses used by the game. It also contains constants for the various
; palette colors.

.importzp GAME_ROUTINE_INDEX             ; $18
.importzp GAME_END_ROUTINE_INDEX         ; $19
.importzp GAME_ROUTINE_INIT_FLAG         ; $19
.importzp FRAME_COUNTER                  ; $1a
.importzp NMI_CHECK                      ; $1b
.importzp DEMO_MODE                      ; $1c
.importzp PLAYER_MODE_1D                 ; $1d
.importzp DEMO_LEVEL_END_FLAG            ; $1f
.importzp PPU_READY                      ; $20
.importzp GRAPHICS_BUFFER_OFFSET         ; $21
.importzp PLAYER_MODE                    ; $22
.importzp GRAPHICS_BUFFER_MODE           ; $23
.importzp KONAMI_CODE_STATUS             ; $24
.importzp PAUSE_STATE                    ; $25
.importzp DEMO_LEVEL                     ; $27
.importzp INTRO_THEME_DELAY              ; $28
.importzp GAME_OVER_DELAY_TIMER          ; $29
.importzp DELAY_TIME_LOW_BYTE            ; $2a
.importzp DELAY_TIME_HIGH_BYTE           ; $2b
.importzp LEVEL_ROUTINE_INDEX            ; $2c
.importzp END_LEVEL_ROUTINE_INDEX        ; $2d
.importzp DEMO_FIRE_DELAY_TIMER          ; $2e
.importzp PLAYER_WEAPON_STRENGTH         ; $2f
.importzp CURRENT_LEVEL                  ; $30
.importzp GAME_COMPLETION_COUNT          ; $31
.importzp P1_NUM_LIVES                   ; $32
.importzp P2_NUM_LIVES                   ; $33
.importzp RANDOM_NUM                     ; $34
.importzp NUM_PALETTES_TO_LOAD           ; $36
.importzp INDOOR_SCREEN_CLEARED          ; $37
.importzp P1_GAME_OVER_STATUS            ; $38
.importzp P2_GAME_OVER_STATUS            ; $39
.importzp NUM_CONTINUES                  ; $3a
.importzp BOSS_DEFEATED_FLAG             ; $3b
.importzp EXTRA_LIFE_SCORE_LOW           ; $3c
.importzp EXTRA_LIFE_SCORE_HIGH          ; $3d
.importzp KONAMI_CODE_NUM_CORRECT        ; $3f
.importzp LEVEL_LOCATION_TYPE            ; $40
.importzp LEVEL_SCROLLING_TYPE           ; $41
.importzp LEVEL_SCREEN_SUPERTILES_PTR    ; $42
.importzp LEVEL_SUPERTILE_DATA_PTR       ; $44
.importzp LEVEL_SUPERTILE_PALETTE_DATA   ; $46
.importzp LEVEL_ALT_GRAPHICS_POS         ; $48
.importzp COLLISION_CODE_1_TILE_INDEX    ; $49
.importzp COLLISION_CODE_0_TILE_INDEX    ; $4a
.importzp COLLISION_CODE_2_TILE_INDEX    ; $4b
.importzp LEVEL_PALETTE_CYCLE_INDEXES    ; $4c
.importzp LEVEL_PALETTE_INDEX            ; $50
.importzp LEVEL_STOP_SCROLL              ; $58
.importzp LEVEL_SOLID_BG_COLLISION_CHECK ; $59
.importzp DEMO_INPUT_NUM_FRAMES          ; $5a
.importzp DEMO_INPUT_VAL                 ; $5c
.importzp DEMO_INPUT_TBL_INDEX           ; $5e
.importzp PPU_WRITE_TILE_OFFSET          ; $60
.importzp LEVEL_TRANSITION_TIMER         ; $61
.importzp PPU_WRITE_ADDRESS_LOW_BYTE     ; $62
.importzp PPU_WRITE_ADDRESS_HIGH_BYTE    ; $63
.importzp LEVEL_SCREEN_NUMBER            ; $64
.importzp LEVEL_SCREEN_SCROLL_OFFSET     ; $65
.importzp ATTRIBUTE_TBL_WRITE_LOW_BYTE   ; $66
.importzp ATTRIBUTE_TBL_WRITE_HIGH_BYTE  ; $67
.importzp FRAME_SCROLL                   ; $68
.importzp SUPERTILE_NAMETABLE_OFFSET     ; $69
.importzp SPRITE_LOAD_TYPE               ; $6a
.importzp CONT_END_SELECTION             ; $6b
.importzp ALT_GRAPHIC_DATA_LOADING_FLAG  ; $71
.importzp LEVEL_PALETTE_CYCLE            ; $72
.importzp INDOOR_SCROLL                  ; $73
.importzp BG_PALETTE_ADJ_TIMER           ; $74
.importzp AUTO_SCROLL_TIMER_00           ; $75
.importzp AUTO_SCROLL_TIMER_01           ; $76
.importzp TANK_AUTO_SCROLL               ; $77
.importzp PAUSE_PALETTE_CYCLE            ; $78
.importzp SOLDIER_GENERATION_ROUTINE     ; $79
.importzp SOLDIER_GENERATION_TIMER       ; $7a
.importzp SOLDIER_GENERATION_X_POS       ; $7b
.importzp SOLDIER_GENERATION_Y_POS       ; $7c
.importzp FALCON_FLASH_TIMER             ; $7d
.importzp TANK_ICE_JOINT_SCROLL_FLAG     ; $7f
.importzp ENEMY_LEVEL_ROUTINES           ; $80
.importzp ENEMY_SCREEN_READ_OFFSET       ; $82
.importzp ENEMY_CURRENT_SLOT             ; $83
.importzp BOSS_AUTO_SCROLL_COMPLETE      ; $84
.importzp BOSS_SCREEN_ENEMIES_DESTROYED  ; $85
.importzp WALL_CORE_REMAINING            ; $86
.importzp WALL_PLATING_DESTROYED_COUNT   ; $87
.importzp INDOOR_ENEMY_ATTACK_COUNT      ; $88
.importzp INDOOR_RED_SOLDIER_CREATED     ; $89
.importzp GRENADE_LAUNCHER_FLAG          ; $8a
.importzp ALIEN_FETUS_AIM_TIMER_INDEX    ; $8b
.importzp ENEMY_ATTACK_FLAG              ; $8e
.importzp PLAYER_STATE                   ; $90
.importzp INDOOR_TRANSITION_X_ACCUM      ; $92
.importzp PLAYER_JUMP_COEFFICIENT        ; $94
.importzp INDOOR_TRANSITION_X_FRACT_VEL  ; $96
.importzp PLAYER_X_VELOCITY              ; $98
.importzp INDOOR_TRANSITION_Y_FRACT_VEL  ; $9a
.importzp INDOOR_TRANSITION_Y_FAST_VEL   ; $9c
.importzp PLAYER_ANIM_FRAME_TIMER        ; $9e
.importzp PLAYER_JUMP_STATUS             ; $a0
.importzp PLAYER_FRAME_SCROLL            ; $a2
.importzp EDGE_FALL_CODE                 ; $a4
.importzp PLAYER_ANIMATION_FRAME_INDEX   ; $a6
.importzp PLAYER_INDOOR_ANIM_Y           ; $a8
.importzp P1_CURRENT_WEAPON              ; $aa
.importzp P2_CURRENT_WEAPON              ; $ab
.importzp PLAYER_M_WEAPON_FIRE_TIME      ; $ac
.importzp NEW_LIFE_INVINCIBILITY_TIMER   ; $ae
.importzp INVINCIBILITY_TIMER            ; $b0
.importzp PLAYER_WATER_STATE             ; $b2
.importzp PLAYER_DEATH_FLAG              ; $b4
.importzp PLAYER_ON_ENEMY                ; $b6
.importzp PLAYER_FALL_X_FREEZE           ; $b8
.importzp PLAYER_HIDDEN                  ; $ba
.importzp PLAYER_SPRITE_SEQUENCE         ; $bc
.importzp PLAYER_INDOOR_ANIM_X           ; $be
.importzp PLAYER_AIM_PREV_FRAME          ; $c0
.importzp PLAYER_AIM_DIR                 ; $c2
.importzp PLAYER_Y_FRACT_VELOCITY        ; $c4
.importzp PLAYER_Y_FAST_VELOCITY         ; $c6
.importzp ELECTROCUTED_TIMER             ; $c8
.importzp INDOOR_PLAYER_JUMP_FLAG        ; $ca
.importzp PLAYER_WATER_TIMER             ; $cc
.importzp PLAYER_RECOIL_TIMER            ; $ce
.importzp INDOOR_PLAYER_ADV_FLAG         ; $d0
.importzp PLAYER_SPECIAL_SPRITE_TIMER    ; $d2
.importzp PLAYER_FAST_X_VEL_BOOST        ; $d4
.importzp PLAYER_SPRITE_CODE             ; $d6
.importzp PLAYER_SPRITE_FLIP             ; $d8
.importzp PLAYER_BG_FLAG_EDGE_DETECT     ; $da
.importzp PLAYER_GAME_OVER_BIT_FIELD     ; $df
.importzp SOUND_TABLE_PTR                ; $ec
.importzp CONTROLLER_STATE               ; $f1
.importzp CONTROLLER_STATE_DIFF          ; $f5
.importzp CTRL_KNOWN_GOOD                ; $f9
.importzp VERTICAL_SCROLL                ; $fc
.importzp HORIZONTAL_SCROLL              ; $fd
.importzp PPUMASK_SETTINGS               ; $fe
.importzp PPUCTRL_SETTINGS               ; $ff

.import SOUND_CMD_LENGTH             ; $0100
.import SOUND_CODE                   ; $0106
.import SOUND_PULSE_LENGTH           ; $010c
.import SOUND_CMD_LOW_ADDR           ; $0112
.import SOUND_CMD_HIGH_ADDR          ; $0118
.import SOUND_VOL_ENV                ; $011e
.import SOUND_CURRENT_SLOT           ; $0120
.import PERCUSSION_INDEX_BACKUP      ; $0121
.import INIT_SOUND_CODE              ; $0122
.import SOUND_CHNL_REG_OFFSET        ; $0123
.import SOUND_FLAGS                  ; $0124
.import LVL_PULSE_VOL_INDEX          ; $012a
.import PULSE_VOL_DURATION           ; $012a
.import PAUSE_STATE_01               ; $012f
.import DECRESCENDO_END_PAUSE        ; $0131
.import SOUND_PITCH_ADJ              ; $0132
.import UNKNOWN_SOUND_00             ; $0136
.import UNKNOWN_SOUND_01             ; $013c
.import SOUND_CFG_LOW                ; $0142
.import SOUND_TRIANGLE_CFG           ; $0144
.import SOUND_REPEAT_COUNT           ; $0148
.import SOUND_CFG_HIGH               ; $014e
.import SOUND_LENGTH_MULTIPLIER      ; $0154
.import SOUND_PERIOD_ROTATE          ; $015a
.import PULSE_VOLUME                 ; $0160
.import NEW_SOUND_CODE_LOW_ADDR      ; $0166
.import NEW_SOUND_CODE_HIGH_ADDR     ; $016c
.import SOUND_PULSE_PERIOD           ; $0172
.import VIBRATO_CTRL                 ; $0178
.import SOUND_VOL_TIMER              ; $017a
.import PULSE_NOTE                   ; $017c
.import VIBRATO_DELAY                ; $017e
.import VIBRATO_AMOUNT               ; $0180
.import LEVEL_END_DELAY_TIMER        ; $0190
.import LEVEL_END_SQ_1_TIMER         ; $0191
.import LEVEL_END_LVL_ROUTINE_STATE  ; $0193
.import LEVEL_END_PLAYERS_ALIVE      ; $0194
.import SOLDIER_GEN_SCREEN           ; $0195
.import SCREEN_GEN_SOLDIERS          ; $0196
.import OAMDMA_CPU_BUFFER            ; $0200
.import CPU_SPRITE_BUFFER            ; $0300
.import PLAYER_SPRITES               ; $0300
.import ENEMY_SPRITES                ; $030a
.import SPRITE_Y_POS                 ; $031a
.import ENEMY_Y_POS                  ; $0324
.import SPRITE_X_POS                 ; $0334
.import ENEMY_X_POS                  ; $033e
.import SPRITE_ATTR                  ; $034e
.import ENEMY_SPRITE_ATTR            ; $0358
.import PLAYER_BULLET_SPRITE_CODE    ; $0368
.import PLAYER_BULLET_SPRITE_ATTR    ; $0378
.import PLAYER_BULLET_SLOT           ; $0388
.import PLAYER_BULLET_Y_VEL_ACCUM    ; $0398
.import PLAYER_BULLET_X_VEL_ACCUM    ; $03a8
.import PLAYER_BULLET_Y_POS          ; $03b8
.import PLAYER_BULLET_X_POS          ; $03c8
.import PLAYER_BULLET_Y_VEL_FRACT    ; $03d8
.import PLAYER_BULLET_X_VEL_FRACT    ; $03e8
.import PLAYER_BULLET_Y_VEL_FAST     ; $03f8
.import PLAYER_BULLET_X_VEL_FAST     ; $0408
.import PLAYER_BULLET_TIMER          ; $0418
.import PLAYER_BULLET_AIM_DIR        ; $0428
.import PLAYER_BULLET_ROUTINE        ; $0438
.import PLAYER_BULLET_OWNER          ; $0448
.import PLAYER_BULLET_F_RAPID        ; $0458
.import PLAYER_BULLET_S_INDOOR_ADJ   ; $0458
.import PLAYER_BULLET_DIST           ; $0468
.import PLAYER_BULLET_S_ADJ_ACCUM    ; $0468
.import PLAYER_BULLET_FS_X           ; $0478
.import PLAYER_BULLET_F_Y            ; $0488
.import PLAYER_BULLET_S_RAPID        ; $0488
.import PLAYER_BULLET_VEL_FS_X_ACCUM ; $0498
.import PLAYER_BULLET_VEL_F_Y_ACCUM  ; $04a8
.import PLAYER_BULLET_S_BULLET_NUM   ; $04a8
.import ENEMY_ROUTINE                ; $04b8
.import ENEMY_Y_VEL_ACCUM            ; $04c8
.import ENEMY_X_VEL_ACCUM            ; $04d8
.import ENEMY_Y_VELOCITY_FAST        ; $04e8
.import ENEMY_Y_VELOCITY_FRACT       ; $04f8
.import ENEMY_X_VELOCITY_FAST        ; $0508
.import ENEMY_X_VELOCITY_FRACT       ; $0518
.import ENEMY_TYPE                   ; $0528
.import ENEMY_ANIMATION_DELAY        ; $0538
.import ENEMY_VAR_A                  ; $0548
.import ENEMY_ATTACK_DELAY           ; $0558
.import ENEMY_VAR_B                  ; $0558
.import ENEMY_FRAME                  ; $0568
.import ENEMY_HP                     ; $0578
.import ENEMY_SCORE_COLLISION        ; $0588
.import ENEMY_STATE_WIDTH            ; $0598
.import ENEMY_ATTRIBUTES             ; $05a8
.import ENEMY_VAR_1                  ; $05b8
.import ENEMY_VAR_2                  ; $05c8
.import ENEMY_VAR_3                  ; $05d8
.import ENEMY_VAR_4                  ; $05e8
.import LEVEL_SCREEN_SUPERTILES      ; $0600
.import BG_COLLISION_DATA            ; $0680
.import CPU_GRAPHICS_BUFFER          ; $0700
.import PALETTE_CPU_BUFFER           ; $07c0
.import HIGH_SCORE_LOW               ; $07e0
.import HIGH_SCORE_HIGH              ; $07e1
.import PLAYER_1_SCORE_LOW           ; $07e2
.import PLAYER_1_SCORE_HIGH          ; $07e3
.import PLAYER_2_SCORE_LOW           ; $07e4
.import PLAYER_2_SCORE_HIGH          ; $07e5
.import PREVIOUS_ROM_BANK            ; $07ec
.import PREVIOUS_ROM_BANK_1          ; $07ed

BANK_NUMBER                    = $8000

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