; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 2 starts with RLE-encoded level data (graphic super tiles for the level
; screens).  It then contains compressed tile data and alternate tile data and
; occasional attribute table data.  Then, bank 2 contains logic for setting the
; players' sprite based on player state.  Next, bank 2 contains the level
; headers, which define specifics about each level. Bank 2 then has the data
; that specifies which enemies are on which screen and their attributes.  Bank
; 2 also contains the soldier enemy generation code.

.segment "BANK_2"

.include "constants.asm"

; import labels from bank 7
.import find_next_enemy_slot_6_to_0, get_bg_collision_far, remove_all_enemies
.import initialize_enemy, find_bullet_slot, find_next_enemy_slot, play_sound
.import run_routine_from_tbl_below, get_bg_collision

; import labels from bank 3
.import level_1_supertile_data, level_2_supertile_data
.import level_3_supertile_data, level_4_supertile_data
.import level_5_supertile_data, level_6_supertile_data
.import level_7_supertile_data, level_8_supertile_data

.import level_1_palette_data, level_2_palette_data
.import level_3_palette_data, level_4_palette_data
.import level_5_palette_data, level_6_palette_data
.import level_7_palette_data, level_8_palette_data

; export labels for bank 7
.export level_headers, graphic_data_02
.export alt_graphic_data_00, alt_graphic_data_01
.export alt_graphic_data_02, alt_graphic_data_03
.export alt_graphic_data_04
.export load_screen_enemy_data
.export exe_soldier_generation
.export set_players_paused_sprite_attr
.export set_player_sprite_and_attrs
.export level_2_4_boss_supertiles_screen_ptr_table

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $02 ; The PRG ROM bank number (2)

; pointer table for level 1 super tile data (#$e * #$2 = #$1c bytes)
; each entry is a screen (256 pixels wide) worth of super-tile indexes
; CPU address $8001
level_1_supertiles_screen_ptr_table:
    .addr level_1_supertiles_screen_00 ; CPU address $801d
    .addr level_1_supertiles_screen_01 ; CPU address $8048
    .addr level_1_supertiles_screen_02 ; CPU address $8079
    .addr level_1_supertiles_screen_03 ; CPU address $80a7
    .addr level_1_supertiles_screen_04 ; CPU address $80cf
    .addr level_1_supertiles_screen_05 ; CPU address $80fc
    .addr level_1_supertiles_screen_06 ; CPU address $8118
    .addr level_1_supertiles_screen_07 ; CPU address $8132
    .addr level_1_supertiles_screen_08 ; CPU address $8149
    .addr level_1_supertiles_screen_09 ; CPU address $8169
    .addr level_1_supertiles_screen_0a ; CPU address $8191
    .addr level_1_supertiles_screen_0b ; CPU address $81b0
    .addr level_1_supertiles_screen_0c ; CPU address $81d6
    .addr level_1_supertiles_screen_00 ; CPU address $801d

; beginning of level 1 data table
; each label is a screen of the level
; each byte is a super-tile block number (a block of 4x4 tiles)
; bit 7 set means the next byte is repeated by the amount of bits 0-6 of current byte
; each label expands to #$38 bytes for horizontal levels
; each label expands to #$40 bytes for vertical levels
; 8x = make x consecutive units of the following byte
; ef = make 6f consecutive units (max)
; fx = ?
level_1_supertiles_screen_00:
    .byte $21,$20,$21,$2b,$23,$22,$23,$2a,$20,$54,$54,$2f,$27,$26,$27,$2e
    .byte $54,$1c,$1d,$1e,$1c,$1e,$1c,$1c,$54,$87,$00,$0c,$84,$51,$83,$00
    .byte $0d,$83,$09,$0a,$83,$51,$84,$10,$11,$83,$12

level_1_supertiles_screen_01:
    .byte $21,$20,$2b,$23,$22,$23,$22,$23,$54,$54,$2f,$27,$26,$27,$26,$27
    .byte $83,$1d,$1e,$1c,$1d,$1d,$1e,$88,$00,$51,$51,$3b,$51,$51,$00,$00
    .byte $51,$00,$51,$51,$00,$0b,$51,$51,$08,$17,$39,$39,$16,$14,$12,$12
    .byte $13

level_1_supertiles_screen_02:
    .byte $22,$23,$22,$23,$2a,$54,$21,$54,$26,$27,$26,$27,$2e,$21,$20,$54
    .byte $1e,$1c,$1d,$1d,$1c,$1d,$1d,$1e,$88,$00,$84,$51,$83,$04,$51,$09
    .byte $0a,$51,$51,$83,$07,$08,$10,$11,$17,$39,$39,$16,$12,$13

level_1_supertiles_screen_03:
    .byte $21,$20,$54,$21,$20,$20,$54,$21,$54,$54,$21,$20,$21,$21,$83,$54
    .byte $20,$54,$54,$1c,$83,$1d,$03,$29,$29,$37,$84,$00,$84,$0c,$84,$51
    .byte $0e,$0c,$0c,$0d,$84,$09,$88,$10

level_1_supertiles_screen_04:
    .byte $83,$54,$20,$21,$54,$20,$2b,$20,$20,$54,$21,$83,$54,$2f,$1e,$84
    .byte $54,$1c,$1d,$1d,$00,$03,$29,$29,$37,$83,$00,$51,$84,$0c,$51,$51
    .byte $3e,$09,$0e,$0c,$0c,$0d,$09,$0a,$51,$86,$10,$11,$12

level_1_supertiles_screen_05:
    .byte $23,$2a,$20,$2d,$84,$2c,$27,$2e,$21,$85,$52,$1d,$1d,$1e,$8a,$00
    .byte $8a,$51,$04,$87,$51,$07,$83,$12,$17,$83,$39,$16

level_1_supertiles_screen_06:
    .byte $88,$2c,$88,$52,$88,$00,$83,$51,$3e,$84,$51,$04,$3b,$86,$00,$07
    .byte $0b,$86,$51,$12,$14,$83,$12,$17,$39,$18

level_1_supertiles_screen_07:
    .byte $88,$2c,$83,$52,$85,$28,$83,$00,$85,$52,$51,$3e,$87,$00,$8b,$51
    .byte $00,$00,$51,$85,$00,$84,$51

level_1_supertiles_screen_08:
    .byte $88,$2c,$85,$52,$83,$28,$85,$00,$28,$52,$52,$00,$84,$51,$52,$00
    .byte $00,$51,$51,$04,$51,$83,$00,$51,$00,$51,$07,$84,$51,$3b,$88,$51

level_1_supertiles_screen_09:
    .byte $88,$2c,$86,$28,$52,$52,$85,$28,$52,$00,$00,$28,$52,$52,$28,$28
    .byte $00,$00,$51,$28,$00,$00,$52,$52,$51,$51,$04,$28,$51,$83,$00,$51
    .byte $51,$07,$28,$00,$84,$51,$00,$51

level_1_supertiles_screen_0a:
    .byte $2c,$87,$24,$28,$38,$86,$2c,$28,$52,$52,$86,$28,$00,$00,$84,$52
    .byte $28,$28,$51,$85,$00,$28,$28,$86,$51,$52,$28,$84,$51,$83,$00

level_1_supertiles_screen_0b:
    .byte $88,$24,$88,$2c,$86,$28,$52,$52,$84,$28,$52,$52,$00,$00,$28,$52
    .byte $52,$28,$00,$00,$51,$04,$28,$00,$00,$28,$51,$3e,$51,$07,$28,$51
    .byte $51,$28,$51,$51,$00,$00

level_1_supertiles_screen_0c:
    .byte $83,$24,$25,$84,$54,$84,$2c,$19,$1a,$02,$1b,$52,$52,$28,$28,$01
    .byte $05,$06,$32,$00,$00,$52,$28,$61,$64,$06,$32,$04,$04,$00,$52,$30
    .byte $31,$33,$36,$07,$3e,$51,$00,$34,$35,$06,$32,$85,$00,$15,$3a,$32

; pointer table for level 2 (#$18 * #$2 = #$30 bytes)
level_2_supertiles_screen_ptr_table:
    .addr level_2_supertiles_screen_00 ; CPU address $8276 (0) Normal Room
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

    .addr level_2_supertiles_screen_00 ; CPU address $8276 (0) Normal Room
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

    .addr level_2_supertiles_screen_00 ; CPU address $8276 (0) Normal Room
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

    .addr level_2_supertiles_screen_04 ; CPU address $82d2 (4) Room with Holes for Roller Rows
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

    .addr level_2_supertiles_screen_05 ; CPU address $82a4 (5) Room with Big Core
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

    .addr level_2_supertiles_screen_00 ; CPU address $8276 (0) First Room again
    .addr level_2_supertiles_screen_01 ; CPU address $8300 (1)
    .addr level_2_supertiles_screen_02 ; CPU address $832e (2)
    .addr level_2_supertiles_screen_03 ; CPU address $835c (3)

; pointer table for level 4 (#$20 * #$2 = #$40 bytes)
level_4_supertiles_screen_ptr_table:
    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_04 ; CPU address $83f6 (4)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_00 ; CPU address $838a (0)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

    .addr level_4_supertiles_screen_05 ; CPU address $83c0 (5)
    .addr level_4_supertiles_screen_01 ; CPU address $842c (1)
    .addr level_4_supertiles_screen_02 ; CPU address $8462 (2)
    .addr level_4_supertiles_screen_03 ; CPU address $8498 (3)

level_2_supertiles_screen_00:
    .byte $62,$86,$61,$63,$60,$04,$05,$06,$07,$01,$02,$5e,$60,$08,$09,$69
    .byte $0c,$0b,$03,$5e,$60,$10,$0d,$6a,$6f,$0f,$10,$5e,$60,$15,$16,$14
    .byte $14,$12,$13,$5e,$60,$18,$84,$11,$17,$5e,$5d,$86,$5f,$5d

level_2_supertiles_screen_05:
    .byte $62,$86,$61,$63,$60,$04,$05,$06,$07,$01,$02,$5e,$60,$08,$09,$6b
    .byte $6e,$0b,$03,$5e,$60,$10,$0d,$6c,$6d,$0f,$10,$5e,$60,$15,$16,$14
    .byte $14,$12,$13,$5e,$60,$18,$84,$11,$17,$5e,$5d,$86,$5f,$5d

level_2_supertiles_screen_04:
    .byte $62,$86,$61,$63,$60,$04,$05,$06,$07,$01,$02,$5e,$60,$08,$09,$69
    .byte $0c,$0b,$03,$5e,$60,$10,$0d,$70,$71,$0f,$10,$5e,$60,$15,$16,$14
    .byte $14,$12,$13,$5e,$60,$18,$84,$11,$17,$5e,$5d,$86,$5f,$5d

level_2_supertiles_screen_01:
    .byte $62,$86,$61,$63,$60,$5c,$1d,$1e,$1f,$20,$5b,$5e,$60,$08,$21,$22
    .byte $22,$24,$03,$5e,$60,$10,$25,$26,$26,$27,$10,$5e,$60,$28,$29,$2a
    .byte $2a,$2b,$2c,$5e,$60,$2d,$84,$2e,$23,$5e,$5d,$86,$5f,$5d

level_2_supertiles_screen_02:
    .byte $62,$86,$61,$63,$60,$2f,$30,$31,$32,$33,$34,$5e,$60,$35,$36,$37
    .byte $38,$39,$3a,$5e,$60,$3b,$3c,$3d,$3e,$3f,$40,$5e,$60,$41,$42,$43
    .byte $43,$44,$45,$5e,$60,$46,$84,$11,$47,$5e,$5d,$86,$5f,$5d

level_2_supertiles_screen_03:
    .byte $62,$86,$61,$63,$60,$48,$58,$49,$4a,$59,$5a,$5e,$60,$4b,$4c,$4d
    .byte $4e,$4f,$50,$5e,$60,$4b,$4c,$51,$52,$4f,$50,$5e,$60,$53,$54,$55
    .byte $55,$56,$57,$5e,$60,$46,$84,$11,$47,$5e,$5d,$86,$5f,$5d

level_4_supertiles_screen_00:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$04,$05,$06,$07,$01,$02,$74
    .byte $68,$08,$09,$69,$0c,$0b,$03,$75,$67,$10,$0d,$6a,$6f,$0f,$10,$74
    .byte $68,$15,$16,$14,$14,$12,$13,$75,$67,$18,$84,$11,$17,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

level_4_supertiles_screen_05:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$04,$05,$06,$07,$01,$02,$74
    .byte $68,$08,$09,$6b,$6e,$0b,$03,$75,$67,$10,$0d,$6c,$6d,$0f,$10,$74
    .byte $68,$15,$16,$14,$14,$12,$13,$75,$67,$18,$84,$11,$17,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

level_4_supertiles_screen_04:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$04,$05,$06,$07,$01,$02,$74
    .byte $68,$08,$09,$69,$0c,$0b,$03,$75,$67,$10,$0d,$70,$71,$0f,$10,$74
    .byte $68,$15,$16,$14,$14,$12,$13,$75,$67,$18,$84,$11,$17,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

level_4_supertiles_screen_01:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$5c,$1d,$1e,$1f,$20,$5b,$74
    .byte $68,$08,$21,$22,$22,$24,$03,$75,$67,$10,$25,$26,$26,$27,$10,$74
    .byte $68,$28,$29,$2a,$2a,$2b,$2c,$75,$67,$2d,$84,$2e,$23,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

level_4_supertiles_screen_02:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$2f,$30,$31,$32,$33,$34,$74
    .byte $68,$35,$36,$37,$38,$39,$3a,$75,$67,$3b,$3c,$3d,$3e,$3f,$40,$74
    .byte $68,$41,$42,$43,$43,$44,$45,$75,$67,$46,$84,$11,$47,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

level_4_supertiles_screen_03:
    .byte $64,$65,$66,$65,$66,$65,$66,$64,$67,$48,$58,$49,$4a,$59,$5a,$74
    .byte $68,$4b,$4c,$4d,$4e,$4f,$50,$75,$67,$4b,$4c,$51,$52,$4f,$50,$74
    .byte $68,$53,$54,$55,$55,$56,$57,$75,$67,$46,$84,$11,$47,$74,$64,$72
    .byte $73,$72,$73,$72,$73,$64

; pointer table for level 3 (#$a * #$2 = #$14 bytes)
level_3_supertiles_screen_ptr_table:
    .addr level_3_supertiles_screen_00 ; CPU address $8667
    .addr level_3_supertiles_screen_01 ; CPU address $8635
    .addr level_3_supertiles_screen_02 ; CPU address $860d
    .addr level_3_supertiles_screen_03 ; CPU address $85d2
    .addr level_3_supertiles_screen_04 ; CPU address $8599
    .addr level_3_supertiles_screen_05 ; CPU address $855c
    .addr level_3_supertiles_screen_06 ; CPU address $8531
    .addr level_3_supertiles_screen_07 ; CPU address $8515
    .addr level_3_supertiles_screen_08 ; CPU address $84e4
    .addr level_3_supertiles_screen_09 ; CPU address $84e2

; level data blocks are stored in reverse order
; first pointer for top screen
level_3_supertiles_screen_09:
    .byte $c0,$60

level_3_supertiles_screen_08:
    .byte $60,$60,$35,$36,$37,$38,$84,$60,$39,$3a,$3b,$3c,$83,$60,$3d,$3e
    .byte $70,$71,$41,$42,$60,$43,$44,$45,$46,$22,$10,$02,$03,$40,$40,$30
    .byte $31,$32,$33,$40,$40,$3f,$3f,$30,$34,$6f,$33,$3f,$3f,$88,$04,$88
    .byte $06

level_3_supertiles_screen_07:
    .byte $88,$04,$84,$06,$84,$05,$06,$05,$05,$8a,$06,$83,$05,$84,$04,$87
    .byte $06,$83,$04,$06,$06,$83,$04,$06,$84,$05,$88,$06

level_3_supertiles_screen_06:
    .byte $87,$04,$83,$06,$1e,$20,$1f,$83,$04,$1e,$20,$84,$60,$23,$04,$87
    .byte $60,$1f,$83,$1d,$24,$84,$1b,$5d,$4a,$18,$2a,$84,$5e,$47,$83,$00
    .byte $25,$83,$12,$5d,$5b,$18,$0b,$0e,$5b,$01,$5b

level_3_supertiles_screen_05:
    .byte $4a,$0b,$0c,$5e,$5e,$0d,$00,$5d,$18,$0e,$83,$00,$27,$00,$00,$2e
    .byte $19,$01,$21,$0b,$5e,$0d,$4a,$28,$16,$01,$21,$11,$12,$12,$15,$5e
    .byte $26,$83,$5d,$47,$18,$2a,$5e,$28,$16,$5d,$00,$00,$2f,$5e,$00,$27
    .byte $83,$00,$18,$2a,$5e,$5b,$0f,$0d,$5b,$5b,$00,$00,$0f

level_3_supertiles_screen_04:
    .byte $5d,$0f,$28,$16,$01,$01,$5d,$0f,$4a,$0f,$5e,$2d,$16,$5d,$18,$2a
    .byte $18,$2a,$5e,$5e,$26,$00,$2f,$5e,$2e,$84,$5e,$0c,$5e,$5e,$83,$00
    .byte $0f,$84,$5e,$16,$83,$00,$27,$83,$00,$26,$5d,$18,$0c,$28,$16,$01
    .byte $21,$00,$00,$2f,$5c,$5c,$2d,$16,$5b

level_3_supertiles_screen_03:
    .byte $4a,$01,$11,$1a,$5e,$5e,$0c,$0c,$01,$01,$18,$17,$83,$00,$0f,$16
    .byte $18,$2e,$28,$16,$83,$00,$2d,$2e,$5e,$5e,$2d,$16,$84,$00,$07,$08
    .byte $08,$09,$00,$00,$01,$21,$0f,$5e,$5e,$28,$16,$4a,$5d,$21,$11,$12
    .byte $1a,$5e,$2d,$16,$83,$5b,$18,$0f,$5c,$5c,$2d

level_3_supertiles_screen_02:
    .byte $84,$5d,$84,$00,$16,$00,$00,$18,$84,$0c,$2d,$16,$8a,$00,$18,$16
    .byte $18,$16,$01,$21,$0b,$0c,$2e,$2d,$2e,$2d,$5d,$5d,$14,$85,$13,$88
    .byte $00,$5b,$5b,$01,$01,$5b,$83,$00

level_3_supertiles_screen_01:
    .byte $84,$00,$0a,$83,$5d,$16,$00,$00,$5d,$47,$18,$16,$18,$26,$00,$0a
    .byte $5d,$84,$00,$19,$01,$83,$5d,$0a,$01,$21,$5d,$85,$01,$0a,$18,$84
    .byte $01,$47,$5d,$5d,$2f,$16,$0a,$83,$01,$5d,$18,$2a,$26,$16,$84,$5d
    .byte $00,$00

level_3_supertiles_screen_00:
    .byte $00,$00,$5d,$5d,$83,$01,$21,$5d,$00,$00,$5d,$5d,$18,$16,$5d,$84
    .byte $00,$5d,$83,$00,$16,$5d,$5d,$84,$00,$5d,$26,$83,$5d,$83,$00,$18
    .byte $28,$16,$83,$5d,$8b,$00,$88,$5d

; pointer table for level 5 (#$16 * #$2 = #$2c bytes)
level_5_supertiles_screen_ptr_table:
    .addr level_5_supertiles_screen_00 ; CPU address $86bb
    .addr level_5_supertiles_screen_01 ; CPU address $86e1
    .addr level_5_supertiles_screen_02 ; CPU address $8700
    .addr level_5_supertiles_screen_03 ; CPU address $8733
    .addr level_5_supertiles_screen_04 ; CPU address $8763
    .addr level_5_supertiles_screen_05 ; CPU address $8792
    .addr level_5_supertiles_screen_06 ; CPU address $87c6
    .addr level_5_supertiles_screen_07 ; CPU address $87fa
    .addr level_5_supertiles_screen_08 ; CPU address $882a
    .addr level_5_supertiles_screen_09 ; CPU address $8851
    .addr level_5_supertiles_screen_0a ; CPU address $8855
    .addr level_5_supertiles_screen_09 ; CPU address $8851
    .addr level_5_supertiles_screen_0b ; CPU address $8863
    .addr level_5_supertiles_screen_09 ; CPU address $8851
    .addr level_5_supertiles_screen_0a ; CPU address $8855
    .addr level_5_supertiles_screen_09 ; CPU address $8851
    .addr level_5_supertiles_screen_0c ; CPU address $8890
    .addr level_5_supertiles_screen_0d ; CPU address $88c4
    .addr level_5_supertiles_screen_0e ; CPU address $88eb
    .addr level_5_supertiles_screen_09 ; CPU address $8851
    .addr level_5_supertiles_screen_0f ; CPU address $890e
    .addr level_5_supertiles_screen_00 ; CPU address $86bb

level_5_supertiles_screen_00:
    .byte $00,$00,$3c,$00,$3b,$3c,$83,$00,$3c,$00,$83,$3c,$3b,$00,$00,$3c
    .byte $83,$3b,$3c,$85,$00,$3c,$00,$00,$3c,$00,$01,$02,$01,$02,$01,$02
    .byte $01,$02,$88,$23,$88,$38

level_5_supertiles_screen_01:
    .byte $00,$3c,$3b,$3c,$00,$3b,$00,$00,$05,$86,$18,$44,$06,$86,$19,$45
    .byte $87,$07,$43,$01,$02,$01,$02,$01,$02,$01,$02,$88,$23,$88,$38

level_5_supertiles_screen_02:
    .byte $00,$00,$3b,$00,$00,$3c,$3b,$84,$00,$3c,$3b,$3b,$3c,$00,$00,$3c
    .byte $3b,$83,$00,$3c,$83,$00,$28,$01,$01,$0f,$00,$00,$01,$3e,$2a,$51
    .byte $03,$14,$00,$22,$23,$24,$0c,$04,$04,$13,$30,$46,$38,$42,$29,$83
    .byte $16,$11,$08

level_5_supertiles_screen_03:
    .byte $00,$3b,$3c,$3c,$00,$3b,$3c,$83,$00,$83,$3c,$84,$00,$3b,$00,$3b
    .byte $00,$00,$2f,$09,$86,$00,$29,$16,$01,$01,$2b,$00,$00,$28,$01,$01
    .byte $23,$2c,$2e,$09,$09,$0c,$25,$23,$38,$50,$29,$16,$16,$11,$41,$38

level_5_supertiles_screen_04:
    .byte $00,$3b,$3c,$3b,$3c,$00,$05,$44,$00,$3c,$00,$3b,$00,$00,$06,$45
    .byte $09,$30,$00,$00,$17,$09,$0e,$47,$16,$0a,$00,$00,$12,$16,$0d,$0d
    .byte $02,$01,$02,$01,$02,$3e,$25,$2c,$85,$23,$2c,$00,$00,$88,$38

level_5_supertiles_screen_05:
    .byte $3c,$00,$3b,$05,$18,$44,$00,$00,$3b,$3c,$00,$06,$19,$45,$00,$00
    .byte $30,$00,$2f,$0e,$0e,$47,$30,$00,$0a,$00,$29,$83,$16,$0a,$00,$22
    .byte $02,$01,$02,$01,$02,$3e,$00,$25,$83,$23,$24,$2a,$3d,$00,$84,$38
    .byte $42,$25,$24,$22

level_5_supertiles_screen_06:
    .byte $00,$3b,$3c,$00,$00,$3c,$3b,$00,$00,$3c,$00,$00,$3b,$3b,$3c,$00
    .byte $00,$2f,$09,$09,$30,$84,$00,$2a,$51,$0d,$33,$2f,$30,$22,$00,$25
    .byte $23,$23,$0a,$29,$11,$46,$00,$22,$02,$01,$02,$01,$3e,$46,$3e,$46
    .byte $84,$03,$3d,$46

level_5_supertiles_screen_07:
    .byte $00,$00,$3b,$3c,$00,$3b,$00,$3c,$00,$3b,$3c,$3c,$00,$3c,$3b,$3c
    .byte $00,$3c,$86,$00,$3e,$86,$00,$22,$3d,$00,$22,$3e,$00,$40,$00,$46
    .byte $3d,$36,$46,$3d,$36,$46,$36,$46,$3d,$3f,$37,$37,$3a,$37,$3f,$37

level_5_supertiles_screen_08:
    .byte $85,$00,$3c,$83,$00,$3c,$00,$00,$3c,$87,$00,$3c,$83,$00,$3e,$87
    .byte $00,$3d,$00,$22,$02,$01,$02,$3e,$00,$3d,$36,$46,$83,$03,$3d,$1a
    .byte $37,$3a,$46,$83,$34,$3d,$1a

level_5_supertiles_screen_09:
    .byte $a8,$00,$90,$1a

level_5_supertiles_screen_0a:
    .byte $98,$00,$60,$1c,$1d,$85,$00,$1e,$61,$62,$85,$00,$90,$1a

level_5_supertiles_screen_0b:
    .byte $84,$00,$3c,$00,$3b,$83,$00,$3b,$00,$3c,$00,$3c,$00,$00,$3b,$3c
    .byte $00,$3b,$85,$00,$2f,$09,$30,$85,$00,$29,$16,$11,$00,$22,$3e,$22
    .byte $02,$01,$02,$01,$3e,$46,$3d,$25,$84,$23,$2c,$46,$3d

level_5_supertiles_screen_0c:
    .byte $3c,$00,$3c,$3b,$00,$3b,$3c,$00,$00,$3b,$05,$83,$18,$44,$3c,$00
    .byte $3c,$06,$83,$19,$45,$00,$3b,$00,$84,$07,$43,$00,$00,$28,$02,$01
    .byte $02,$01,$2b,$00,$1a,$0c,$0b,$21,$23,$23,$2c,$2f,$1a,$46,$26,$10
    .byte $38,$38,$50,$27

level_5_supertiles_screen_0d:
    .byte $83,$00,$3b,$3c,$00,$3c,$00,$3b,$00,$3b,$3c,$89,$00,$3b,$00,$00
    .byte $28,$01,$02,$01,$02,$01,$2b,$00,$2a,$03,$51,$83,$03,$2d,$22,$0c
    .byte $85,$04,$32,$46,$87,$11,$08

level_5_supertiles_screen_0e:
    .byte $00,$3b,$3c,$84,$00,$3c,$83,$00,$3b,$00,$3b,$84,$00,$3b,$00,$3c
    .byte $3c,$8a,$00,$02,$01,$02,$01,$02,$01,$3e,$00,$86,$23,$2c,$1a,$86
    .byte $38,$50,$1a

level_5_supertiles_screen_0f:
    .byte $95,$00,$4d,$4e,$4f,$85,$00,$4a,$4b
    .byte $4c,$85,$00,$31,$48,$49,$84,$1a,$15,$1b,$1f,$20,$88,$1a

; pointer table for level 6 (#$e * #$2 = #$1c bytes)
level_6_supertiles_screen_ptr_table:
    .addr level_6_supertiles_screen_00 ; CPU address $8941
    .addr level_6_supertiles_screen_01 ; CPU address $8973
    .addr level_6_supertiles_screen_02 ; CPU address $89a3
    .addr level_6_supertiles_screen_03 ; CPU address $89d5
    .addr level_6_supertiles_screen_04 ; CPU address $8a07
    .addr level_6_supertiles_screen_05 ; CPU address $8a3d
    .addr level_6_supertiles_screen_06 ; CPU address $8a71
    .addr level_6_supertiles_screen_07 ; CPU address $8aa7
    .addr level_6_supertiles_screen_08 ; CPU address $8ada
    .addr level_6_supertiles_screen_09 ; CPU address $8b0e
    .addr level_6_supertiles_screen_0a ; CPU address $8b40
    .addr level_6_supertiles_screen_0b ; CPU address $8b64
    .addr level_6_supertiles_screen_0c ; CPU address $8b6a
    .addr level_6_supertiles_screen_00 ; CPU address $8941

level_6_supertiles_screen_00:
    .byte $1d,$30,$31,$1d,$30,$31,$1d,$30,$3f,$31,$49,$3f,$31,$49,$3f,$31
    .byte $60,$32,$4d,$40,$32,$4d,$40,$32,$57,$3e,$3f,$57,$3e,$3f,$60,$3e
    .byte $57,$60,$60,$00,$60,$00,$57,$00,$00,$57,$00,$60,$00,$57,$00,$00
    .byte $88,$01

level_6_supertiles_screen_01:
    .byte $31,$1d,$30,$31,$1d,$30,$31,$1d,$49,$3f,$4d,$40,$3f,$4d,$40,$3f
    .byte $4d,$40,$3f,$57,$00,$3d,$60,$57,$30,$28,$02,$85,$03,$32,$02,$06
    .byte $4c,$61,$69,$63,$4c,$02,$06,$4c,$4c,$65,$62,$64,$4c,$14,$87,$22

level_6_supertiles_screen_02:
    .byte $30,$31,$1d,$3f,$40,$1d,$3f,$4d,$31,$40,$3f,$60,$40,$3f,$57,$3e
    .byte $00,$57,$00,$00,$57,$00,$00,$60,$0b,$08,$0c,$51,$83,$58,$59,$05
    .byte $57,$15,$0e,$57,$12,$10,$53,$05,$00,$60,$00,$00,$09,$17,$13,$24
    .byte $87,$01

level_6_supertiles_screen_03:
    .byte $1d,$3f,$40,$1d,$4d,$3f,$4a,$4a,$3f,$60,$57,$3e,$3f,$57,$3e,$3f
    .byte $00,$60,$60,$57,$00,$60,$00,$57,$38,$57,$08,$0c,$51,$58,$58,$59
    .byte $54,$33,$12,$53,$54,$10,$33,$15,$17,$23,$09,$17,$13,$17,$23,$28
    .byte $88,$01

level_6_supertiles_screen_04:
    .byte $4a,$4b,$4a,$29,$4a,$4b,$4a,$29,$32,$00,$57,$3e,$3f,$00,$3e,$3f
    .byte $57,$00,$60,$60,$57,$00,$57,$60,$38,$00,$0f,$03,$04,$34,$34,$03
    .byte $0e,$69,$00,$11,$52,$12,$10,$18,$28,$3f,$60,$00,$57,$09,$17,$17
    .byte $01,$68,$00,$50,$84,$01

level_6_supertiles_screen_05:
    .byte $4b,$4a,$43,$66,$4a,$29,$4a,$43,$00,$3d,$67,$2d,$0a,$0a,$3c,$1b
    .byte $00,$60,$1b,$4e,$00,$20,$66,$1b,$47,$57,$67,$2d,$1c,$1a,$4e,$2f
    .byte $46,$60,$2f,$2e,$0a,$1f,$2d,$00,$23,$60,$83,$00,$20,$4e,$00,$85
    .byte $01,$1e,$42,$01

level_6_supertiles_screen_06:
    .byte $66,$29,$4a,$29,$4b,$29,$4a,$29,$4e,$3e,$3f,$3d,$00,$21,$0a,$0a
    .byte $2d,$1c,$0d,$4f,$83,$00,$1b,$2e,$0a,$1f,$4e,$00,$00,$2b,$5d,$00
    .byte $00,$20,$2d,$69,$00,$21,$1f,$00,$02,$2c,$4e,$41,$00,$00,$5e,$01
    .byte $14,$25,$42,$83,$01,$1e

level_6_supertiles_screen_07:
    .byte $29,$4a,$43,$66,$2a,$29,$4a,$29,$3c,$00,$20,$4e,$39,$3e,$3d,$3e
    .byte $66,$1c,$1a,$2d,$44,$83,$00,$4e,$0a,$1f,$2e,$39,$00,$0f,$03,$2d
    .byte $83,$00,$39,$12,$10,$18,$4e,$03,$0b,$00,$39,$09,$17,$17,$42,$25
    .byte $24,$85,$01

level_6_supertiles_screen_08:
    .byte $4a,$2a,$4b,$29,$2a,$29,$4b,$29,$3f,$36,$00,$3e,$36,$3d,$00,$3d
    .byte $00,$39,$00,$00,$39,$83,$00,$04,$84,$34,$03,$47,$08,$46,$45,$00
    .byte $00,$39,$11,$52,$12,$23,$39,$00,$00,$44,$00,$00,$09,$01,$01,$68
    .byte $00,$50,$83,$01

level_6_supertiles_screen_09:
    .byte $4a,$29,$2a,$29,$4a,$29,$2a,$29,$3e,$3f,$39,$3e,$3f,$00,$39,$3e
    .byte $00,$00,$44,$83,$00,$44,$00,$0c,$51,$59,$38,$00,$0f,$03,$34,$53
    .byte $54,$37,$54,$10,$10,$18,$10,$17,$13,$48,$83,$35,$3b,$17,$86,$01
    .byte $16,$00

level_6_supertiles_screen_0a:
    .byte $4a,$29,$4b,$29,$4a,$83,$00,$3f,$3d,$00,$3e,$3f,$8b,$00,$34,$03
    .byte $47,$85,$00,$33,$11,$52,$85,$00,$23,$00,$00,$02,$84,$03,$00,$50
    .byte $01,$14,$84,$22

level_6_supertiles_screen_0b:
    .byte $a8,$00,$88,$03,$88,$22

level_6_supertiles_screen_0c:
    .byte $8e,$00,$19,$27,$86,$00,$3a,$55,$86,$00,$56,$5b,$86,$00,$56,$5a
    .byte $86,$03,$5f,$5a,$87,$22,$5c

; pointer table for level 7 (10 * 2 = 20 bytes)
level_7_supertiles_screen_ptr_table:
    .addr level_7_supertiles_screen_00 ; CPU address $8ba1
    .addr level_7_supertiles_screen_01 ; CPU address $8bd2
    .addr level_7_supertiles_screen_02 ; CPU address $8bf8
    .addr level_7_supertiles_screen_03 ; CPU address $8c27
    .addr level_7_supertiles_screen_04 ; CPU address $8c58
    .addr level_7_supertiles_screen_05 ; CPU address $8c8a
    .addr level_7_supertiles_screen_06 ; CPU address $8ca7
    .addr level_7_supertiles_screen_07 ; CPU address $8cd7
    .addr level_7_supertiles_screen_08 ; CPU address $8d03
    .addr level_7_supertiles_screen_09 ; CPU address $8d2a
    .addr level_7_supertiles_screen_0a ; CPU address $8d58
    .addr level_7_supertiles_screen_0b ; CPU address $8d82
    .addr level_7_supertiles_screen_0c ; CPU address $8db6
    .addr level_7_supertiles_screen_0d ; CPU address $8dea
    .addr level_7_supertiles_screen_0e ; CPU address $8e10
    .addr level_7_supertiles_screen_00 ; CPU address $8ba1

level_7_supertiles_screen_00:
    .byte $05,$05,$43,$43,$09,$17,$0e,$0e,$05,$43,$05,$3f,$09,$1b,$23,$23
    .byte $3f,$43,$3f,$3f,$30,$30,$6d,$6d,$6e,$38,$6f,$6f,$34,$34,$6d,$6d
    .byte $84,$11,$13,$13,$11,$47,$87,$45,$37,$49,$4a,$49,$4a,$49,$4a,$49
    .byte $32

level_7_supertiles_screen_01:
    .byte $83,$0e,$02,$84,$0e,$83,$23,$0d,$0f,$0f,$23,$23,$83,$6d,$4d,$6f
    .byte $6f,$54,$6d,$10,$11,$11,$13,$11,$11,$12,$6d,$3e,$85,$3d,$2c,$6d
    .byte $87,$6f,$40,$87,$20,$48

level_7_supertiles_screen_02:
    .byte $0e,$02,$85,$0e,$02,$23,$09,$23,$22,$0f,$22,$23,$0d,$6d,$30,$6d
    .byte $6d,$6e,$6d,$3c,$4d,$6d,$34,$6d,$3c,$6f,$54,$10,$13,$6d,$34,$6d
    .byte $10,$11,$12,$3e,$0f,$11,$13,$47,$85,$6f,$45,$45,$32,$85,$20

level_7_supertiles_screen_03:
    .byte $87,$0e,$1d,$05,$05,$3f,$05,$43,$05,$05,$50,$39,$3f,$05,$43,$3f
    .byte $3f,$43,$50,$12,$3f,$6e,$6e,$3f,$38,$6f,$3b,$2c,$38,$83,$6f,$40
    .byte $11,$3a,$6f,$40,$83,$11,$31,$45,$45,$20,$48,$49,$4a,$49,$4a,$49
    .byte $4a

level_7_supertiles_screen_04:
    .byte $0e,$1d,$0e,$1d,$84,$0e,$43,$50,$05,$50,$83,$23,$6e,$05,$50,$3f
    .byte $50,$6d,$6d,$3c,$6f,$6f,$3b,$6f,$3b,$33,$54,$10,$11,$11,$3a,$11
    .byte $3a,$11,$47,$3e,$3d,$85,$45,$37,$6f,$6f,$49,$4a,$49,$4a,$49,$32
    .byte $20,$20

level_7_supertiles_screen_05:
    .byte $88,$0e,$83,$3d,$6e,$84,$23,$84,$6f,$54,$83,$6d,$84,$11,$12,$83
    .byte $6d,$84,$3d,$2c,$6d,$6d,$10,$85,$6f,$83,$33,$88,$20

level_7_supertiles_screen_06:
    .byte $0e,$02,$86,$0e,$23,$35,$83,$23,$3d,$3d,$23,$64,$09,$83,$6d,$6e
    .byte $6e,$24,$10,$1c,$83,$6d,$38,$6f,$41,$0c,$30,$6d,$3c,$33,$40,$11
    .byte $47,$33,$36,$33,$40,$11,$31,$45,$37,$83,$20,$48,$49,$4a,$49,$32

level_7_supertiles_screen_07:
    .byte $83,$0e,$02,$84,$0e,$83,$23,$35,$84,$23,$25,$25,$26,$09,$24,$25
    .byte $25,$26,$29,$29,$2a,$09,$28,$29,$29,$2a,$27,$2b,$6d,$1f,$27,$2b
    .byte $27,$2b,$2e,$2f,$6d,$34,$2e,$2f,$2e,$2f,$88,$20

level_7_supertiles_screen_08:
    .byte $0e,$02,$86,$0e,$23,$35,$84,$23,$21,$2d,$6d,$09,$6d,$27,$2b,$6d
    .byte $2e,$2f,$6d,$09,$6d,$2e,$2f,$6d,$10,$11,$6d,$1f,$6d,$10,$11,$0c
    .byte $83,$6d,$34,$86,$6d,$88,$20

level_7_supertiles_screen_09:
    .byte $83,$0e,$1d,$0e,$1d,$0e,$1d,$23,$23,$04,$50,$6e,$50,$6e,$50,$6d
    .byte $6d,$38,$3b,$6f,$3b,$6f,$3b,$0c,$6d,$10,$3a,$11,$3a,$11,$3a,$6d
    .byte $6d,$3e,$85,$3d,$6d,$6d,$38,$85,$6f,$00,$6d,$1e,$85,$20

level_7_supertiles_screen_0a:
    .byte $88,$0e,$84,$23,$83,$04,$23,$54,$83,$6d,$83,$6e,$6d,$12,$6d,$6d
    .byte $3c,$83,$6f,$54,$2c,$3c,$33,$40,$83,$11,$47,$6f,$40,$11,$31,$83
    .byte $45,$37,$20,$48,$49,$4a,$49,$4a,$49,$32

level_7_supertiles_screen_0b:
    .byte $0e,$0e,$02,$01,$84,$03,$23,$23,$35,$17,$44,$06,$07,$14,$6d,$6d
    .byte $09,$1b,$08,$0a,$0b,$18,$6d,$6d,$09,$09,$6d,$6d,$4f,$4f,$6d,$6d
    .byte $30,$30,$6d,$6d,$6e,$6e,$33,$33,$36,$36,$33,$33,$6f,$6f,$11,$11
    .byte $13,$13,$84,$11

level_7_supertiles_screen_0c:
    .byte $83,$03,$01,$01,$05,$43,$43,$15,$16,$44,$17,$17,$3f,$05,$43,$19
    .byte $1a,$08,$1b,$1b,$05,$43,$43,$4f,$6d,$6d,$09,$09,$3f,$43,$3f,$6e
    .byte $6e,$6d,$30,$0d,$43,$3f,$43,$6f,$6f,$33,$36,$4d,$83,$6f,$83,$11
    .byte $13,$13,$83,$11

level_7_supertiles_screen_0d:
    .byte $43,$3f,$3f,$6e,$83,$3f,$6e,$86,$3f,$43,$3f,$6e,$84,$3f,$6e,$83
    .byte $3f,$6e,$3f,$6e,$3f,$6e,$6e,$3f,$3f,$38,$87,$6f,$40,$87,$11,$31
    .byte $4a,$49,$4a,$49,$4a,$49

level_7_supertiles_screen_0e:
    .byte $43,$6e,$3f,$3f,$6e,$51,$52,$53,$6e,$3f,$3f,$6e,$3f,$55,$56,$57
    .byte $3f,$6e,$3f,$3f,$58,$59,$5a,$5b,$6e,$3f,$6e,$6e,$5c,$5d,$5e,$5f
    .byte $83,$6f,$39,$4e,$60,$67,$61,$11,$11,$42,$46,$42,$46,$76,$62,$4a
    .byte $49,$4c,$4b,$4c,$4b,$4a,$63

; pointer table for level 8 (#$c * #$2 = #$18 bytes)
level_8_supertiles_screen_ptr_table:
    .addr level_8_supertiles_screen_00 ; CPU address $8e5f
    .addr level_8_supertiles_screen_01 ; CPU address $8e8e
    .addr level_8_supertiles_screen_02 ; CPU address $8eb4
    .addr level_8_supertiles_screen_03 ; CPU address $8ee7
    .addr level_8_supertiles_screen_04 ; CPU address $8f0b
    .addr level_8_supertiles_screen_05 ; CPU address $8f31
    .addr level_8_supertiles_screen_06 ; CPU address $8f59
    .addr level_8_supertiles_screen_07 ; CPU address $8f88
    .addr level_8_supertiles_screen_08 ; CPU address $8fac
    .addr level_8_supertiles_screen_09 ; CPU address $8fd9
    .addr level_8_supertiles_screen_0a ; CPU address $8fef
    .addr level_8_supertiles_screen_00 ; CPU address $8e5f

level_8_supertiles_screen_00:
    .byte $83,$4c,$2b,$84,$27,$4c,$4c,$2b,$85,$26,$4c,$4c,$3e,$26,$26,$23
    .byte $32,$32,$4c,$4c,$3e,$26,$26,$43,$00,$02,$4c,$4c,$3e,$2e,$04,$35
    .byte $12,$15,$4c,$4c,$47,$43,$24,$83,$11,$83,$01,$02,$24,$83,$11

level_8_supertiles_screen_01:
    .byte $88,$27,$88,$26,$42,$44,$85,$32,$42,$3e,$08,$84,$01,$02,$3e,$47
    .byte $0c,$83,$10,$13,$12,$05,$4c,$07,$47,$0a,$0b,$0e,$11,$24,$3a,$11
    .byte $3a,$37,$36,$37,$11,$11

level_8_supertiles_screen_02:
    .byte $27,$27,$2c,$4c,$61,$62,$63,$64,$26,$26,$2e,$4c,$65,$66,$67,$68
    .byte $26,$26,$2e,$4c,$5a,$59,$69,$2b,$26,$26,$2f,$41,$3d,$4c,$2b,$26
    .byte $06,$47,$2e,$40,$3c,$4c,$3e,$26,$24,$72,$35,$3f,$3c,$35,$05,$05
    .byte $24,$87,$11

level_8_supertiles_screen_03:
    .byte $88,$11,$2b,$27,$1c,$1b,$20,$49,$49,$11,$26,$26,$2f,$1f,$2b,$27
    .byte $2c,$20,$83,$26,$2a,$83,$26,$29,$88,$26,$06,$42,$44,$85,$32,$11
    .byte $3a,$39,$85,$01

level_8_supertiles_screen_04:
    .byte $90,$11,$49,$49,$84,$11,$49,$49,$83,$27,$2c,$1f,$31,$2b,$27,$26
    .byte $26,$44,$32,$2a,$83,$26,$43,$07,$4c,$03,$47,$0a,$05,$06,$02,$24
    .byte $3a,$11,$3a,$37,$11,$24

level_8_supertiles_screen_05:
    .byte $8b,$11,$21,$31,$30,$1b,$33,$21,$31,$1f,$2b,$26,$2f,$1f,$2b,$28
    .byte $32,$45,$83,$32,$45,$42,$08,$85,$01,$02,$3e,$2d,$84,$48,$14,$12
    .byte $05,$00,$83,$01,$02,$24,$49,$49

level_8_supertiles_screen_06:
    .byte $88,$11,$2b,$1c,$1f,$2b,$84,$27,$26,$29,$2a,$2e,$04,$05,$05,$06
    .byte $26,$44,$32,$43,$11,$11,$49,$49,$26,$08,$83,$01,$02,$2b,$27,$05
    .byte $16,$12,$15,$48,$48,$47,$32,$49,$11,$11,$24,$00,$01,$01,$02

level_8_supertiles_screen_07:
    .byte $88,$11,$88,$27,$42,$0a,$86,$05,$3e,$0e,$85,$11,$49,$46,$29,$27
    .byte $27,$30,$1f,$31,$2b,$43,$04,$83,$05,$34,$44,$32,$3a,$11,$11,$49
    .byte $49,$36,$3a,$00

level_8_supertiles_screen_08:
    .byte $88,$11,$27,$27,$2c,$20,$84,$11,$05,$06,$42,$2c,$20,$83,$11,$49
    .byte $22,$3e,$26,$29,$1c,$1f,$4c,$27,$27,$46,$83,$26,$29,$30,$32,$32
    .byte $43,$04,$83,$05,$35,$01,$38,$3a,$11,$11,$49,$49,$11

level_8_supertiles_screen_09:
    .byte $87,$11,$22,$84,$11,$25,$4c,$33,$1b,$11,$49,$49,$25,$83,$4c,$1f
    .byte $90,$4c,$88,$35,$88,$11

level_8_supertiles_screen_0a:
    .byte $88,$18,$33,$83,$4c,$19,$6a,$6a,$18,$84,$4c,$1d,$4e,$4d,$18,$85
    .byte $4c,$50,$4f,$18,$84,$4c,$1a,$17,$17,$18,$84,$35,$1e,$6e,$6e,$18
    .byte $18,$49,$86,$18

; pointer table for indoor levels boss rooms (#$2 * #$2 = #$4 bytes)
level_2_4_boss_supertiles_screen_ptr_table:
    .addr level_2_4_boss_supertiles_screen_00 ; CPU address $9017
    .addr level_2_4_boss_supertiles_screen_01 ; CPU address $9057

; table for level 2 boss room (#$40 bytes)
; indexes into level_2_4_boss_supertile_data
level_2_4_boss_supertiles_screen_00:
    .byte $01,$02,$03,$09,$0e,$0f,$10,$11,$04,$05,$06,$00,$00,$12,$0b,$13
    .byte $07,$08,$4a,$53,$56,$4a,$0d,$0c,$07,$05,$59,$71,$65,$59,$0b,$0a
    .byte $07,$14,$5c,$6e,$6b,$5c,$1d,$0a,$16,$15,$17,$19,$1c,$18,$1e,$1f
    .byte $1a,$1b,$21,$22,$23,$24,$1b,$20,$00,$00,$00,$00,$00,$00,$00,$00

; table for level 4 boss room (#$40 bytes)
; indexes into level_2_4_boss_supertile_data
level_2_4_boss_supertiles_screen_01:
    .byte $2c,$2d,$2e,$2f,$3b,$3c,$3d,$3e,$30,$31,$32,$62,$5f,$40,$41,$42
    .byte $30,$34,$35,$50,$68,$35,$44,$42,$37,$38,$4a,$53,$56,$4a,$46,$47
    .byte $30,$48,$49,$28,$39,$39,$3a,$42,$29,$2a,$2b,$45,$36,$33,$27,$26
    .byte $43,$3f,$3f,$3f,$3f,$3f,$3f,$25,$00,$00,$00,$00,$00,$00,$00,$00

; intro screen nametable layout (#$1bb bytes)
; nametable entries point to pattern table data in graphic_data_01
; CPU address $9097
; nametable and attribute table used for intro screen
; nametable data - writes addresses [$2000-$2400)
; "1 PLAYER"
; "2 PLAYERS"
; "TM AND © 1988"
; "KONAMI INDUSTRY"
; "CO.,LTD"
; "LICENSED BY"
; "NINTENDO OF"
; "AMERICA INC"
graphic_data_02:
    .incbin "assets/graphic_data/graphic_data_02.bin"

; compressed alternate graphics data for level 1 (length ?)
; CPU address $9252
alt_graphic_data_00:
    .incbin "assets/graphic_data/alt_graphic_data_00.bin"

; CPU address $97d2
alt_graphic_data_01:
    .incbin "assets/graphic_data/alt_graphic_data_01.bin"

; CPU address $a372
alt_graphic_data_02:
    .incbin "assets/graphic_data/alt_graphic_data_02.bin"

; CPU address $a712
alt_graphic_data_03:
    .incbin "assets/graphic_data/alt_graphic_data_03.bin"

; CPU address $ab52
alt_graphic_data_04:
    .incbin "assets/graphic_data/alt_graphic_data_04.bin"

; ensure player sprite attributes continue to animate while paused
set_players_paused_sprite_attr:
    ldx #$01 ; x = #$01

@loop:
    jsr set_player_paused_sprite_attr
    dex
    bpl @loop
    rts

; set player sprite based on player state, level, and animation sequence
; input
;  * x - current player
set_player_sprite_and_attrs:
    jsr set_player_sprite

; ensure player sprite attributes continue to animate while paused
set_player_paused_sprite_attr:
    lda PLAYER_HIDDEN,x                ; 0 - visible; #$01/#$ff = invisible (any non-zero)
    bne @continue                      ; branch if player is hidden
    ldy PLAYER_SPRITE_CODE,x           ; player not hidden, load the player's sprite code
    lda NEW_LIFE_INVINCIBILITY_TIMER,x ; load timer for invincibility after dying
    beq @set_y_to_player_sprite        ; branch if timer is #$00
    lda FRAME_COUNTER                  ; load frame counter
    lsr
    bcc @set_y_to_player_sprite        ; branch if even frame

@continue:
    ldy #$00 ; init player sprite attr to #$00 (player is either hidden, or odd frame flashing having just spawned)

@set_y_to_player_sprite:
    tya                         ; move player sprite code to a register
    sta PLAYER_SPRITES,x        ; update PLAYER_SPRITES with sprite from PLAYER_SPRITE_CODE
    lda sprite_attr_start_tbl,x ; load sprite palette based on player index
    ldy ELECTROCUTED_TIMER,x    ; counter for being electrocuted
    beq @invincibility_check    ; jump if not being electrocuted
    lda #$02                    ; set sprite attr bit for player being electrocuted
    bne @continue2              ; always jump

@invincibility_check:
    ldy INVINCIBILITY_TIMER,x
    beq @set_player_recoil_and_bg_priority ; jump if not invincible
    lda #$04                               ; a = #$04 (sprite code palette override bit)

@continue2:
    sta $00                          ; store sprite code for player in $00
.ifdef Probotector
    lda probotector_sprite_palette,X ; player 2 sprite palette alternates between red and gray
                                     ; instead of red and blue like player 1 (and like player 2 in Contra)
    tay                              ; transfer sprite palette to y
    lda FRAME_COUNTER                ; load frame counter
    eor player_effect_xor_tbl,x
.else
    lda FRAME_COUNTER                ; load frame counter
    eor player_effect_xor_tbl,x
    ldy #$04                         ; sprite palette #$00 (red and blue)
.endif
    and $00                          ; see if sprite code palette override is set
    beq @continue3                   ; branch if sprite attribute is still #$00
.ifdef Probotector
    ldy #$06                         ; y = #$06 (override sprite code palette with palette 2)
.else
    ldy #$05                         ; y = #$05 (override sprite code palette with palette 1)
.endif

@continue3:
    tya ; transfer sprite attribute to a

@set_player_recoil_and_bg_priority:
    ldy PLAYER_BG_FLAG_EDGE_DETECT,x ; determine if player's sprite should be behind the background
    bpl @check_sprite_recoil         ; branch if sprite is front of background
    ora #$20                         ; set bit 5, the SPRITE_ATTR for background priority

@check_sprite_recoil:
    ldy PLAYER_RECOIL_TIMER,x   ; see if there is any recoil effect
    beq @set_player_sprite_attr ; skip if no recoil
    cpy #$0c                    ; weapon still out/still handing recoil compare time left to #$0c
    bcc @set_player_sprite_attr ; branch if PLAYER_RECOIL_TIMER,x < #$0c
    ora #$08                    ; set bit 3, this moves the player torso down 1 pixel to simulate recoil (see SPRITE_ATTR documentation)

@set_player_sprite_attr:
    sta $00
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    and #$c8                 ; keep bits xx.. x...
    ora $00
    sta SPRITE_ATTR,x        ; set the sprite modifier for player (if invincible or have electrocution effect, blink)
    rts

; determine sprite palette based on player index
; first byte is player 1
; second byte is player 2
sprite_attr_start_tbl:
    .byte $00,$05

; first byte is player 1 effect xor value
; second byte is player 2 effect xor value
player_effect_xor_tbl:
    .byte $00,$ff

.ifdef Probotector
; first byte is player 1
; second byte is player 2
probotector_sprite_palette:
    .byte $04,$05
.endif

set_player_sprite:
    lda PLAYER_WATER_STATE,x
    beq @set_out_of_water_sprite
    jmp set_player_water_sprite_and_state

@set_out_of_water_sprite:
    lda EDGE_FALL_CODE,x
    beq @set_non_falling_player_sprite ; branch if player isn't falling through floor or walking off ledge
    jmp set_player_sprite_05           ; sprite_05 (player falling through floor, or walk off ledge)

@set_non_falling_player_sprite:
    lda PLAYER_JUMP_STATUS,x     ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    beq @set_sprite_for_sequence ; set sprite when player isn't jumping
    jmp set_player_jump_sprite   ; player jumping, set appropriate sprite

@set_sprite_for_sequence:
    lda LEVEL_LOCATION_TYPE                     ; 0 = outdoor; 1 = indoor
    beq @set_outdoor_player_sprite_for_sequence ; branch for outdoor level
    bmi @indoor_boss_set_player_sprite          ; branch if indoor boss screen
    jmp set_indoor_player_sprite_for_sequence   ; indoor level, set the player sprite
                                                ; based on PLAYER_SPRITE_SEQUENCE and which frame for indoor levels

@indoor_boss_set_player_sprite:
    jmp indoor_boss_set_player_sprite

@set_outdoor_player_sprite_for_sequence:
    ldy PLAYER_SPRITE_SEQUENCE,x      ; player animation frame
    cpy #$03
    bcs big_seq_sprite                ; branch if PLAYER_SPRITE_SEQUENCE >= #$03
    lda player_small_seq_sprite_tbl,y ; player sprite sequence is (#$00-#$03) load sprite
    jmp set_player_sprite_to_a

; sprite_0f - player walking holding weapon out
; sprite_16 - player aiming straight up
; sprite_17 - player prone
player_small_seq_sprite_tbl:
    .byte $0f,$16,$17

big_seq_sprite:
    bne set_outdoor_player_death_sprite ; branch if PLAYER_SPRITE_SEQUENCE > #$03

set_player_frame_sprite:
    ldy PLAYER_AIM_DIR,x               ; which direction the player is aiming/looking
    lda player_frame_sprite_type_tbl,y
    bne set_player_frame_sprite_from_a
    ldy PLAYER_RECOIL_TIMER,x          ; player_frame_sprite_type_tbl was #$00, see if player has recoil still
    beq set_player_frame_sprite_from_a ; branch if no recoil
    lda #$01                           ; player has recoil, use player_frame_sprite_tbl_01

; sets the player sprite based on walking direction and aim direction
; input
;  * a - which player sprite animation to use (see player_frame_sprite_ptr_tbl)
set_player_frame_sprite_from_a:
    asl
    tay
    lda player_frame_sprite_ptr_tbl,y
    sta $01
    lda player_frame_sprite_ptr_tbl+1,y
    sta $02
    lda PLAYER_ANIMATION_FRAME_INDEX,x
    tay
    lda ($01),y
    sta PLAYER_SPRITE_CODE,x
    inc PLAYER_ANIM_FRAME_TIMER,x       ; increment #$08 player moving frame delay before moving to next animation frame
    lda PLAYER_ANIM_FRAME_TIMER,x       ; load delay between frames
    and #$07                            ; see if #$08 frames have elapsed
    bne @set_player_horizontal_flip     ; branch if #$08 frames haven't elapsed
                                        ; to set PLAYER_SPRITE_FLIP bit 6 (horizontal flip) if facing left
    inc PLAYER_ANIMATION_FRAME_INDEX,x  ; #$08 frames have elapsed move to next player animation sprite
    lda PLAYER_ANIMATION_FRAME_INDEX,x  ; load player animation sprite index
    cmp #$06                            ; see if past last sprite in animation
    bcc @set_player_horizontal_flip     ; branch if not past last sprite to continue
    lda #$00                            ; reset player sprite index
    sta PLAYER_ANIMATION_FRAME_INDEX,x  ; reset player sprite index

@set_player_horizontal_flip:
    jmp set_player_horizontal_flip ; set PLAYER_SPRITE_FLIP bit 6 (horizontal flip) if facing left

; player aim direction offsets, specify which sprite table to use based on aim direction
; #$00 means to use player_frame_sprite_tbl_00 (walking with gun in hand)
;      unless there is still recoil from a shot, then use player_frame_sprite_tbl_01
player_frame_sprite_type_tbl:
    .byte $00,$02,$00,$03,$00,$00,$03,$00,$02,$00

; pointer table for which sprite to load for player based on aim direction and whether there is gun recoil  (#$5 * #$2 = #$a bytes)
player_frame_sprite_ptr_tbl:
    .addr player_frame_sprite_tbl_00 ; CPU address $b0d1 - walking with gun in hand
    .addr player_frame_sprite_tbl_01 ; CPU address $b0d7 - walking with gun and recoil
    .addr player_frame_sprite_tbl_02 ; CPU address $b0dd - outdoor walking aiming up
    .addr player_frame_sprite_tbl_03 ; CPU address $b0e3 - outdoor walking aiming down
    .addr player_frame_sprite_tbl_04 ; CPU address $b0e9 - indoor level

; walking with gun in hand
player_frame_sprite_tbl_00:
    .byte $02,$03,$04,$05,$03,$06

; outdoor walking aiming in walking direction
; sprite_0d, sprite_0e, sprite_0f
player_frame_sprite_tbl_01:
    .byte $0d,$0e,$0f,$0d,$0e,$0f

; outdoor walking aiming up
; sprite_10, sprite_11, sprite_12
player_frame_sprite_tbl_02:
    .byte $10,$11,$12,$10,$11,$12

; outdoor walking aiming down
; sprite_13, sprite_14, sprite_15
player_frame_sprite_tbl_03:
    .byte $13,$14,$15,$13,$14,$15

; indoor level
; sprite_51, sprite_52, sprite_53
player_frame_sprite_tbl_04:
    .byte $51,$52,$53,$51,$52,$53

set_outdoor_player_death_sprite:
    inc PLAYER_SPECIAL_SPRITE_TIMER,x  ; increment player death sprite timer
    lda PLAYER_SPECIAL_SPRITE_TIMER,x  ; load player death sprite timer
    and #$07                           ; move to next animation, every #$08 frames
    bne @continue                      ; don't move to next frame, timer isn't divisible by #$08
    inc PLAYER_ANIMATION_FRAME_INDEX,x ; #$08th frame move to next sprite in animation
    lda PLAYER_ANIMATION_FRAME_INDEX,x ; load sprite animation number
    cmp #$05                           ; see if past the last frame of the animation
    bcc @continue                      ; continue if not the last frame of animation
    lda #$04                           ; went past last frame, show last frame of sprite (sprite_0c)
    sta PLAYER_ANIMATION_FRAME_INDEX,x ; set sprite frame number to #$04 (sprite_0c)

@continue:
    lda PLAYER_ANIMATION_FRAME_INDEX,x ; load sprite animation frame number
    asl                                ; double since each entry in player_death_sprite_tbl is #$02 bytes
    tay                                ; transfer to y for offset
    lda player_death_sprite_tbl,y      ; load sprite_code
    sta PLAYER_SPRITE_CODE,x           ; set sprite code
    lda player_death_sprite_tbl+1,y    ; load sprite attributes
    sta PLAYER_SPRITE_FLIP,x           ; store whether sprite is flipped horizontally and/or vertically
    lda PLAYER_DEATH_FLAG,x            ; player death flag
    and #$02                           ; keep bit 1 (player facing left when hit flag)
    beq @exit                          ; branch to not flip sprite if player was facing right when hit
    lda PLAYER_SPRITE_FLIP,x           ; facing left when hit, load player sprite horizontal and vertical flip flags
    eor #$40                           ; flip bit 6 (swap horizontal flip direction)
    sta PLAYER_SPRITE_FLIP,x           ; save updated horizontal flip information

@exit:
    rts

; PLAYER_SPRITE_CODE and sprite horizontal/vertical flip data (#$0a bytes)
; byte 0 - PLAYER_SPRITE_CODE
; byte 1 - SPRITE_ATTR
player_death_sprite_tbl:
    .byte $0a,$00 ; sprite_0a - player hit (frame 1) (sprite_0a)
    .byte $0b,$00 ; sprite_0b - player hit (frame 2) (sprite_0b)
    .byte $0a,$c0 ; sprite_0a - player hit (frame 1) (sprite_0a) - flip vertically and horizontally
    .byte $0b,$c0 ; sprite_0b - player hit (frame 2) (sprite_0b) - flip vertically and horizontally
    .byte $0c,$00 ; sprite_0c - player lying on ground (sprite_0c)

set_player_sprite_05:
    lda #$05 ; a = #$05 (sprite_05) - player walking (frame 4)

set_player_sprite_to_a:
    sta PLAYER_SPRITE_CODE,x ; load player sprite (sprite code)

set_player_horizontal_flip:
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    and #$3f                 ; keep bits 6 and 7 (horizontal and vertical flip bits respectively)
    ldy PLAYER_AIM_DIR,x     ; which direction the player is aiming/looking
    cpy #$05                 ; compare to crouching facing left
    bcc @continue            ; branch if player facing right
    ora #$40                 ; player is facing left, set horizontal flip bit (bit 6)

@continue:
    sta PLAYER_SPRITE_FLIP,x ; store whether sprite is flipped horizontally and/or vertically
    rts

; sets appropriate curled up player sprite for jumping
set_player_jump_sprite:
    lda PLAYER_JUMP_STATUS,x ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    asl                      ; shift bit 7 to carry (jumping left flag)
    lda #$00                 ; a = #$00 (no horizontal sprite flip)
    bcc @continue            ; continue if jumping right
    lda #$40                 ; jumping left, set bit 6 (sprite horizontal flip bit)

@continue:
    sta $08                            ; set sprite flip bit information in $08
    lda PLAYER_SPRITE_FLIP,x           ; load player sprite horizontal and vertical flip flags
    and #$3f                           ; clear PLAYER_SPRITE_FLIP horizontal and vertical flip bits
    ldy PLAYER_ANIMATION_FRAME_INDEX,x ; load which frame of the player animation
    cpy #$02                           ;
    bcc @set_sprite_inc_frame
    ora #$c0                           ; flip vertically and horizontally

@set_sprite_inc_frame:
    eor $08                             ; merge with sprite bit flip information, use eor in case a flip of a flip is needed
    sta PLAYER_SPRITE_FLIP,x            ; store whether sprite is flipped horizontally and/or vertically
    ldy PLAYER_ANIMATION_FRAME_INDEX,x  ; load the current animation frame of the jumping curl
    lda player_curled_sprite_code_tbl,y ; load specific curled player sprite
    sta PLAYER_SPRITE_CODE,x            ; set player sprite curl (sprite code)
    inc PLAYER_SPECIAL_SPRITE_TIMER,x
    lda PLAYER_SPECIAL_SPRITE_TIMER,x
    cmp #$05
    bcc @exit
    lda #$00                            ; a = #$00
    sta PLAYER_SPECIAL_SPRITE_TIMER,x
    inc PLAYER_ANIMATION_FRAME_INDEX,x
    lda PLAYER_ANIMATION_FRAME_INDEX,x
    cmp #$04
    bcc @set_anim_frame_exit
    lda #$00                            ; a = #$00

@set_anim_frame_exit:
    sta PLAYER_ANIMATION_FRAME_INDEX,x

@exit:
    rts

; table for player animation frames when spinning during a jump (#$4 bytes)
; sprite_08, sprite_09
player_curled_sprite_code_tbl:
    .byte $08,$09,$08,$09

set_player_water_sprite_and_state:
    lda PLAYER_WATER_STATE,x
    and #$04                           ; keep bits .... .x..
    bne set_player_in_water_sprite     ; branch if set player fully in water or walking out of water
    lda PLAYER_WATER_STATE,x           ; bit 2 clear, player entering water, load player water state
    and #$10                           ; keep bit 4
    bne @set_enter_water_sprite        ; branch if bit 4 set
    lda #$00                           ; branch 4 clear, entering water for first time, set a = #$00
    sta PLAYER_ANIMATION_FRAME_INDEX,x ; initialize frame index to #$00
    lda #$05                           ; a = #$05 (sprite_05) - player walking (frame 4)
    sta PLAYER_SPRITE_CODE,x           ; set player sprite code, player standing for #$08 frames before splash
    lda SPRITE_Y_POS,x                 ; player y position on screen
    clc                                ; clear carry in preparation for addition
    adc #$10                           ; move down #$10 pixels
    sta SPRITE_Y_POS,x                 ; update player y position on screen
    lda PLAYER_AIM_DIR,x               ; which direction the player is aiming/looking
    cmp #$05                           ; see if facing left or right
    bcc @continue                      ; branch if facing right
    lda PLAYER_WATER_STATE,x           ; player facing left, load current PLAYER_WATER_STATE
    ora #$02                           ; set bit 1 to signify sprite flip needed during animation
    sta PLAYER_WATER_STATE,x           ; update PLAYER_WATER_STATE

@continue:
    lda #$10                 ; a = #$10
    sta PLAYER_WATER_TIMER,x ; set entering water animation timer to #$10
    lda PLAYER_WATER_STATE,x ; load player water state
    ora #$90                 ; set bits x..x ...., specifies initialized water entrance animation
    sta PLAYER_WATER_STATE,x ; update player water state

@set_enter_water_sprite:
    lda #$00                         ; a = #$00
    sta PLAYER_X_VELOCITY,x          ; stop player x velocity
    lda PLAYER_WATER_TIMER,x         ; load water animation timer
    beq set_player_in_water_sprite   ; if timer has elapsed, branch to set the correct sprite
    cmp #$0c                         ; see if timer is greater than or equal to #$0c
    bcs set_player_water_sprite_flip ; branch if timer >= #$0c to set player sprite flip (horizontal flip) for standing up above water
    lda #$73                         ; PLAYER_WATER_TIMER less than #$0c, set splash sprite
    sta PLAYER_SPRITE_CODE,x         ; set player sprite (sprite_73) water splash
    cmp #$08                         ; !(BUG?) always branch, doesn't compare to PLAYER_WATER_TIMER, but instead compares against #$73
                                     ; no lda PLAYER_WATER_TIMER,x before this line, so part of splash animation is missing
                                     ; same issue appears in Probotector and Japanese version of game
    bcs set_player_water_sprite_flip ; always branch, branch to set player sprite attribute to ensure horizontal direction is correct
    lda #$18                         ; dead code - a = #$18 (sprite_18) water splash/puddle
    sta PLAYER_SPRITE_CODE,x         ; dead code - set player animation frame to water splash/puddle

set_player_water_sprite_flip:
    dec PLAYER_WATER_TIMER,x ; decrement water animation timer
    lda PLAYER_WATER_STATE,x ; load player water state
    and #$02                 ; keep bit 1 (horizontal flip flag)
    beq @exit                ; exit if no horizontal flip
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    ora #$40                 ; set horizontal flip (bit 6)
    sta PLAYER_SPRITE_FLIP,x ; set sprite horizontal flip

@exit:
    rts

; set sprite for player in water or walking out of water
set_player_in_water_sprite:
    lda PLAYER_WATER_STATE,x               ; load player water state
    and #$08                               ; keep bit 3 (player walking out of water flag)
    beq @set_player_water_sprite_and_state ; branch if player is not walking out of water
    jmp player_walk_out_of_water           ; jump if player is walking out of water

@set_player_water_sprite_and_state:
    lda PLAYER_WATER_STATE,x               ; load player water state
    ora #$04                               ; set bit 2
    and #$7f                               ; strip bit 7
    sta PLAYER_WATER_STATE,x               ; update player water state
    lda PLAYER_AIM_DIR,x                   ; which direction the player is aiming/looking
    asl                                    ; double since each entry is #$02 bytes
    tay                                    ; transfer offset to y
    lda PLAYER_RECOIL_TIMER,x              ; load current player recoil timer
    beq @in_water_not_firing               ; branch if no recoil timer
    lda player_water_firing_sprite_tbl,y   ; player is firing, show firing sprite code
    sta PLAYER_SPRITE_CODE,x               ; load player sprite (sprite code)
    lda player_water_firing_sprite_tbl+1,y ; load PLAYER_SPRITE_FLIP flag (whether to flip the sprite horizontally)
    jmp @set_sprite_flip_check_collision   ; set PLAYER_SPRITE_FLIP, check if collision with ground

@in_water_not_firing:
    lda player_water_sprite_tbl,y   ; load non-firing player in water sprite code
    sta PLAYER_SPRITE_CODE,x        ; load player sprite (sprite code)
    lda player_water_sprite_tbl+1,y ; load non-firing player in water sprite attribute

; input
;  * a - PLAYER_SPRITE_FLIP horizontal and vertical flip values (bit 6 and 7)
@set_sprite_flip_check_collision:
    sta $01                             ; set to whether to flip the sprite horizontally or vertically
    lda PLAYER_SPRITE_FLIP,x            ; load current player sprite horizontal and vertical flip flags
    and #$0f                            ; strip high nibble
    ora $01                             ; merge updated horizontal and vertical flip bits
    sta PLAYER_SPRITE_FLIP,x            ; set whether sprite is flipped horizontally and/or vertically
    lda FRAME_COUNTER                   ; load frame counter
    and #$0f                            ; keep bits .... xxxx
    bne @check_anim_frame_and_collision ; continue if not the #$fth frame
    inc PLAYER_ANIMATION_FRAME_INDEX,x  ; move to next animation every #$f frames

@check_anim_frame_and_collision:
    lda PLAYER_ANIMATION_FRAME_INDEX,x     ; load frame of the player animation
    and #$01                               ; keep bit 0
    bne @clear_sprite_flip_check_collision ; branch if odd player animation frame
    lda PLAYER_SPRITE_FLIP,x               ; load player sprite horizontal and vertical flip flags
    ora #$08                               ; set bit 3
    bne @check_ground_collision            ; always branch, see if player has collided with the ground
                                           ; and should begin animation to step out of water

@clear_sprite_flip_check_collision:
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    and #$f7                 ; strip bit 3

@check_ground_collision:
    sta PLAYER_SPRITE_FLIP,x           ; store whether sprite is flipped horizontally and/or vertically
    lda SPRITE_Y_POS,x                 ; load player y position on screen
    tay                                ; transfer y position to y
    lda SPRITE_X_POS,x                 ; load player x position on screen
    jsr get_bg_collision               ; determine player background collision code at position (a,y)
    cmp #$02                           ; see if collision code #$02 (water)
    beq @exit                          ; exit if in water
    lda PLAYER_WATER_STATE,x           ; player colliding with land, set transition to start walking out of water
    ora #$88                           ; set bits 3 and 7 to signal walking out of water
    sta PLAYER_WATER_STATE,x           ; update player water state
    lda #$0c                           ; set timer to animate player walking out of water
    sta PLAYER_WATER_TIMER,x           ; update timer
    lda #$1a                           ; a = #$1a (sprite_1a) player climbing out of water
    sta PLAYER_SPRITE_CODE,x           ; set player sprite to be climbing out of water
    lda PLAYER_AIM_DIR,x               ; which direction the player is aiming/looking
    cmp #$05                           ; determine facing direction
    bcc @clear_horizontal_flip_exit    ; branch if player is facing right
    lda PLAYER_WATER_STATE,x           ; player is facing left, flip player sprite horizontally
    ora #$02                           ; set bit 1 (horizontal flip flag)
    bne @set_horizontal_flip_flag_exit ; set bit 1 in PLAYER_WATER_STATE and exit

@clear_horizontal_flip_exit:
    lda PLAYER_WATER_STATE,x ; load player water transition data
    and #$fd                 ; strip bit 1 (horizontal flip flag)

@set_horizontal_flip_flag_exit:
    sta PLAYER_WATER_STATE,x ; set horizontal flip flag

@exit:
    rts

; logic when player is walking out of water
; moves player forward and sets appropriate sprite
; executed repeatedly until PLAYER_WATER_TIMER,x is #$00
player_walk_out_of_water:
    lda #$06                         ; !(OBS) unnecessary, because overwritten to #$00 by handle_player_state_calc_x_vel
    sta PLAYER_X_VELOCITY,x          ; unnecessary, set player x velocity to #$06
    lda PLAYER_WATER_TIMER,x         ; load animation timer
    beq clear_water_vars_set_y_pos   ; timer elapsed, player is now out of water
    cmp #$05                         ; timer not elapsed, see if less than #$05
    bcc @almost_out_of_water         ; branch if timer is almost elapsed to set player standing sprite
    jmp set_player_water_sprite_flip ; set player sprite attribute to ensure horizontal direction is correct

@almost_out_of_water:
    lda #$05                         ; a = #$05 (sprite_05) player walking (frame 4)
    sta PLAYER_SPRITE_CODE,x         ; set player sprite to walking frame
    jmp set_player_water_sprite_flip ; set player sprite attribute to ensure horizontal direction is correct
    dec PLAYER_WATER_TIMER,x         ; decrement animation timer
    rts

; player out of water, clear water variables and adjust y position to be on land
clear_water_vars_set_y_pos:
    lda #$00                           ; a = #$00
    sta PLAYER_WATER_STATE,x           ; clear player in water animation
    sta PLAYER_ANIMATION_FRAME_INDEX,x ; set player frame to first frame of walking
    lda SPRITE_Y_POS,x                 ; player y position on screen
    sec                                ; set carry flag in preparation for subtraction
    sbc #$10                           ; move player up so that they are on the ground and out of the water
    sta SPRITE_Y_POS,x
    rts

; table for sprites and sprite flip values for player in water when not firing (#$14 bytes)
; (cf. player_water_firing_sprite_tbl)
; each entry is for a specific PLAYER_AIM_DIR [#$00-#$09]
; sprite_19, sprite_18
player_water_sprite_tbl:
    .byte $19,$00 ; up facing right   - sprite_19 - player in water
    .byte $19,$00 ; up right          - sprite_19 - player in water
    .byte $19,$00 ; right             - sprite_19 - player in water
    .byte $18,$00 ; down right        - sprite_18 - water splash/puddle
    .byte $18,$00 ; down facing right - sprite_18 - water splash/puddle
    .byte $18,$40 ; down facing left  - sprite_18 - water splash/puddle (flipped horizontally)
    .byte $18,$40 ; down left         - sprite_18 - water splash/puddle (flipped horizontally)
    .byte $19,$40 ; left              - sprite_19 - player in water (flipped horizontally)
    .byte $19,$40 ; left up           - sprite_19 - player in water (flipped horizontally)
    .byte $19,$40 ; left facing up    - sprite_19 - player in water (flipped horizontally)

; table for sprites and sprite flip values for player in water and firing (#$14 bytes)
; (cf. player_water_sprite_tbl)
; each entry is for a specific PLAYER_AIM_DIR [#$00-#$09]
; sprite_18, sprite_1b, sprite_1c, sprite_1d
player_water_firing_sprite_tbl:
    .byte $1b,$00 ; up facing right   - sprite_1b - player in water aiming straight up
    .byte $1c,$00 ; up right          - sprite_1c - player in water aiming angled up
    .byte $1d,$00 ; right             - sprite_1d - player in water aiming forward
    .byte $18,$00 ; down right        - sprite_18 - water splash/puddle
    .byte $18,$00 ; down facing right - sprite_18 - water splash/puddle
    .byte $18,$40 ; down facing left  - sprite_18 - water splash/puddle (flipped horizontally)
    .byte $18,$40 ; down left         - sprite_18 - water splash/puddle (flipped horizontally)
    .byte $1d,$40 ; left              - sprite_1d - player in water aiming forward (flipped horizontally)
    .byte $1c,$40 ; left up           - sprite_1c - player in water aiming angled up (flipped horizontally)
    .byte $1b,$40 ; left facing up    - sprite_1b - player in water aiming straight up (flipped horizontally)

; sets the appropriate player sprite based on which sequence and which frame for indoor levels
set_indoor_player_sprite_for_sequence:
    lda PLAYER_SPRITE_SEQUENCE,x
    jsr run_routine_from_tbl_below ; run routine a in the following table (indoor_player_sprite_tbl)

; pointer table for setting appropriate player sprite (#$8 * #$2 = #$10 bytes)
indoor_player_sprite_tbl:
    .addr player_sprite_indoor_facing_up         ; CPU address $b2c6
    .addr player_sprite_indoor_electrocuted      ; CPU address $b2ca
    .addr player_sprite_indoor_crouch            ; CPU address $b2ce
    .addr player_sprite_indoor_walking_animation ; CPU address $b2b9
    .addr player_sprite_indoor_walking_animation ; CPU address $b2b9
    .addr player_sprite_indoor_walking_to_back   ; CPU address $b2d3
    .addr player_sprite_indoor_dead              ; CPU address $b2ec
    .addr player_sprite_indoor_elevator          ; CPU address $b2c2 !(UNUSED)

player_sprite_indoor_walking_animation:
    lda PLAYER_RECOIL_TIMER,x
    beq @continue
    lda #$04                  ; a = #$04

; indoor level, set player sprite based on aim direction
@continue:
    jmp set_player_frame_sprite_from_a ; player_frame_sprite_tbl_04

; unused !(UNUSED)
; elevator sprite is set with (set_player_on_elevator_sprite)
; sprite elevator isn't used on non-boss indoor level
player_sprite_indoor_elevator:
    lda #$91                        ; a = #$91 (sprite_91) indoor boss defeated elevator with player on top
    bne set_player_sprite_code_to_a

player_sprite_indoor_facing_up:
    lda #$50                        ; a = #$50 (sprite_50) indoor player facing up
    bne set_player_sprite_code_to_a

player_sprite_indoor_electrocuted:
    lda #$55                        ; a = #$55 (sprite_55) indoor player electrocuted
    bne set_player_sprite_code_to_a

player_sprite_indoor_crouch:
    lda #$54 ; a = #$54 (sprite_54) indoor player crouch

set_player_sprite_code_to_a:
    sta PLAYER_SPRITE_CODE,x ; load player sprite (sprite code)
    rts

player_sprite_indoor_walking_to_back:
    dec PLAYER_ANIM_FRAME_TIMER,x
    bpl @continue
    lda #$03                           ; a = #$03 (sound_03)
    jsr play_sound                     ; play player landing on ground or water sound
    lda #$0a                           ; a = #$0a
    sta PLAYER_ANIM_FRAME_TIMER,x
    inc PLAYER_ANIMATION_FRAME_INDEX,x

@continue:
    lda PLAYER_ANIMATION_FRAME_INDEX,x
    and #$01                           ; keep bits .... ...x
    clc                                ; clear carry in preparation for addition
    adc #$57                           ; a = #$57 (sprite_57) indoor player running
    sta PLAYER_SPRITE_CODE,x           ; load player sprite (sprite code)
    rts

player_sprite_indoor_dead:
    lda PLAYER_SPECIAL_SPRITE_TIMER,x
    cmp #$1b
    lda #$56                          ; a = #$56 (sprite_56) indoor player lying dead (frame #$02)
    bcs @continue
    inc PLAYER_SPECIAL_SPRITE_TIMER,x
    lda #$55                          ; a = #$55 (sprite_55) indoor player hit by bullet frame #$01

@continue:
    sta PLAYER_SPRITE_CODE,x ; load player sprite (sprite code) sprite_55, or sprite_56
    lda #$00                 ; a = #$00
    sta PLAYER_SPRITE_FLIP,x ; store whether sprite is flipped horizontally and/or vertically
    rts

indoor_boss_set_player_sprite:
    lda PLAYER_SPRITE_SEQUENCE,x
    jsr run_routine_from_tbl_below ; run routine a in the following table (indoor_boss_player_sprite_tbl)

; pointer table for ? (#$5 * #$2 = #$a bytes)
indoor_boss_player_sprite_tbl:
    .addr indoor_boss_player_aiming_up_sprite ; CPU address $b30e
    .addr indoor_boss_player_aiming_up_sprite ; CPU address $b30e
    .addr indoor_boss_player_aiming_up_sprite ; CPU address $b30e
    .addr set_player_frame_sprite             ; CPU address $b086
    .addr player_sprite_indoor_dead           ; CPU address $b2ec

indoor_boss_player_aiming_up_sprite:
    lda PLAYER_SPRITE_FLIP,x ; load player sprite horizontal and vertical flip flags
    and #$3f                 ; keep bits ..xx xxxx
    sta PLAYER_SPRITE_FLIP,x ; store whether sprite is flipped horizontally and/or vertically
    lda #$50                 ; a = #$50 (sprite_50) indoor player facing up
    sta PLAYER_SPRITE_CODE,x ; load player sprite (sprite code)
    rts

; Level Headers - A description of each level
; loaded into memory by load_level_header in bank 7
; Level 1 - jungle
level_headers:
level_1_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $00                                 ; outdoor scrolling type: horizontal scroll (0 = horizontal ; 1 = vertical)
    .addr level_1_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_1_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_1_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $0b                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $06,$f9,$ff                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $05,$08,$05,$08                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $02,$03,$04,$05                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$07                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $0b                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $00                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 2 - base 1
level_2_header:
    .byte $01                                 ; location type: indoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room)
    .byte $00                                 ; outdoor scrolling type: not used for indoor level
    .addr level_2_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_2_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_2_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $04                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $00,$ff,$ff                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX) (all tiles are empty collision code for indoor/base levels)
    .byte $24,$28,$29,$28                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $09,$0a,$04,$24                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$2a                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $05                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $00                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 3 - waterfall
level_3_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $01                                 ; scrolling type: vertical scroll (0 = horizontal ; 1 = vertical)
    .addr level_3_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_3_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_3_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $07                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $07,$ff,$ff                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $0d,$0e,$0f,$00                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $0b,$0c,$04,$0d                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$07                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $07                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $00                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 4 - base 2
level_4_header:
    .byte $01                                 ; location type: indoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room)
    .byte $00                                 ; outdoor scrolling type: not used for indoor level
    .addr level_4_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_4_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR) (same as level 2)
    .addr level_4_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA) (same as level 2)
    .byte $07                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $00,$ff,$ff                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX) (all tiles are empty collision code for indoor/base levels)
    .byte $2e,$2f,$30,$2f                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $2c,$2d,$04,$2e                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$2a                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $08                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $00                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 5 - snow field
level_5_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $00                                 ; outdoor scrolling type: horizontal scroll (0 = horizontal ; 1 = vertical)
    .addr level_5_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_5_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_5_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $13                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $20,$f0,$f0                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $62,$63,$62,$63                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $3d,$3e,$04,$62                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$07                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $13                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $01                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 6 - energy zone
level_6_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $00                                 ; outdoor scrolling type: horizontal scroll (0 = horizontal ; 1 = vertical)
    .addr level_6_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_6_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_6_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $0b                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $0c,$de,$de                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $35,$36,$37,$38                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $33,$34,$04,$35                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$07                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $0b                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $81                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 7 - hangar
level_7_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $00                                 ; outdoor scrolling type: horizontal scroll (0 = horizontal ; 1 = vertical)
    .addr level_7_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_7_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_7_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $0d                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $0e,$f1,$f1                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $47,$57,$47,$58                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $45,$46,$04,$47                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$22,$07                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $0d                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $81                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

; header for level 8 - alien's lair
level_8_header:
    .byte $00                                 ; location type: outdoor level (0 = outdoor ; 1 = indoor ; ff = indoor boss room) (LEVEL_LOCATION_TYPE)
    .byte $00                                 ; outdoor scrolling type: horizontal scroll (0 = horizontal ; 1 = vertical)
    .addr level_8_supertiles_screen_ptr_table ; pointer to which super-tiles are on each screen (bank 2 memory address) (see LEVEL_SCREEN_SUPERTILES_PTR)
    .addr level_8_supertile_data              ; composition of super-tiles (bank 3 memory address) (see LEVEL_SUPERTILE_DATA_PTR)
    .addr level_8_palette_data                ; super-tile palette data (bank 3 memory address) (see LEVEL_SUPERTILE_PALETTE_DATA)
    .byte $09                                 ; alternate graphics loading (+2) (screen where they start loading) (see LEVEL_ALT_GRAPHICS_POS)
    .byte $05,$ef,$ef                         ; tile collision limits (see COLLISION_CODE_X_TILE_INDEX)
    .byte $4c,$4d,$4e,$4f                     ; palette indexes into game_palettes for cycling the 4th nametable palette index (see LEVEL_PALETTE_CYCLE_INDEXES)
    .byte $48,$49,$4a,$4c                     ; indexes into game_palettes specifying initial background tile palette colors (see LEVEL_PALETTE_INDEX)
    .byte $00,$01,$43,$44                     ; indexes into game_palettes specifying sprite palette colors (see LEVEL_PALETTE_INDEX)
    .byte $09                                 ; section to stop scrolling at (+2) (level length) (see LEVEL_STOP_SCROLL)
    .byte $00                                 ; specifies whether to check for bullet and/or weapon item solid bg collisions (LEVEL_SOLID_BG_COLLISION_CHECK)
    .byte $00,$00,$00,$00,$00,$00             ; unused

load_screen_enemy_data:
    lda CURRENT_LEVEL                      ; current level
    asl                                    ; double since each entry in level_enemy_screen_ptr_ptr_tbl is 2 bytes
    tay
    lda level_enemy_screen_ptr_ptr_tbl,y   ; levels enemy type table for level (low byte)
    sta $08
    lda level_enemy_screen_ptr_ptr_tbl+1,y ; levels enemy type table for level (high byte)
    sta $09
    lda LEVEL_SCREEN_NUMBER                ; load current screen number within the level
    asl                                    ; double since each address is 2 bytes
    tay
    lda ($08),y                            ; load the low byte of the pointer to the screen enemy type data (level_x_enemy_screen_xx)
    sta $0a
    iny
    lda ($08),y                            ; load the high byte of the pointer to the screen enemy type data (level_x_enemy_screen_xx)
    sta $0b
    lda LEVEL_LOCATION_TYPE                ; 0 = outdoor; 1 = indoor
    beq load_enemy_outdoor_level           ; branch for outdoor level to load enemies for current screen
    jmp load_enemy_indoor_level            ; branch for indoor level to load enemies for current screen

; outdoor
load_enemy_outdoor_level:
    ldy ENEMY_SCREEN_READ_OFFSET    ; current read offset for screen enemy data
    lda ($0a),y                     ; load first byte of screen enemy data (level_x_enemy_screen_xx)
    cmp #$ff                        ; if #$ff no more data to read
    beq load_screen_enemy_data_exit ; just read #$ff, exit
    sta $0f                         ; store x position of enemy into $0f
    and #$fe                        ; look at the last bit
    sec                             ; set the carry flag in preparation for subtraction
    sbc LEVEL_SCREEN_SCROLL_OFFSET  ; subtract scrolling offset in pixels within screen, vertical scroll for indoor levels
    beq @continue                   ; if the player is at the horizontal position specified, create enemy
    bcs load_screen_enemy_data_exit ; exit if haven't reached position
    eor #$ff                        ; past the horizontal position for enemy type flip all bits and add one to get how far past
    adc #$01

@continue:
    sta $0e     ; store distance past the from enemy load position (usually #$0, but can be positive if player was past position)
                ; this happens on the vertical level when jumping
    iny
    lda ($0a),y ; read the enemy type and the enemy repeat data
    tax         ; temporary save a so that we can pull out the ENEMY_TYPE
    and #$3f    ; keep the enemy type bits ..xx xxxx
    sta $08     ; store enemy type into $08
    txa         ; restore full value for a
    rol
    rol
    rol         ; previous 3 rol operations moved the high 2 bits to low to bits
    and #$03    ; keep only the last 2 bits, which is the repeat value
    sta $09     ; store the number of times to repeat the enemy in $09

; read the 3rd byte of the enemy triple, which is the y position and the enemy attribute data
; also used when enemies are repeated to load repeat enemy data y position
read_enemy_data_byte_3:
    iny
    lda ($0a),y                ; load vertical offset and enemy attributes
    sta $0c                    ; store vertical offset and enemy attributes into $0c
    jsr find_next_enemy_slot   ; find next available enemy slot, put result in x register
    beq set_enemy_slot_data    ; found enemy slot to use
    lda $0f                    ; no enemy slot available, load enemy x position
    lsr                        ; shift least significant bit to carry flat
    bcc load_enemy_repeat_data ; if carry flag clear, jump
    jsr find_bullet_slot

; updates enemy slot based on CPU memory values $08, $0c, $0e, etc.
set_enemy_slot_data:
    lda $08
    sta ENEMY_TYPE,x           ; store current enemy type
    jsr initialize_enemy       ; initialize enemy attributes
    lda $0c                    ; load vertical position and enemy attributes
    and #$0f                   ; keep the least significant 4 bits (enemy attributes)
    sta ENEMY_ATTRIBUTES,x     ; store enemy attributes
    lda LEVEL_SCROLLING_TYPE   ; 0 = horizontal, indoor/base; 1 = vertical
    beq @handle_horizontal     ; handle horizontal level
    lda $0c                    ; load vertical position and enemy attributes
    and #$f0                   ; keep most significant 4 bits xxxx ....
    sta ENEMY_X_POS,x          ; set enemy x position on screen
    lda $0e
    sta ENEMY_Y_POS,x          ; enemy y position on screen
    jmp load_enemy_repeat_data ; if enemy is repeated, handle that

@handle_horizontal:
    lda $0c
    and #$f0          ; keep bits xxxx ....
    sta ENEMY_Y_POS,x ; enemy y position on screen
    lda #$f0          ; a = #$f0
    sec               ; set carry flag in preparation for subtraction
    sbc $0e
    sta ENEMY_X_POS,x ; set enemy x position on screen

load_enemy_repeat_data:
    dec $09                      ; decrement enemy repeat value
    bpl read_enemy_data_byte_3   ; read y offset and attributes for next repetition
    iny                          ; increment read offset
    sty ENEMY_SCREEN_READ_OFFSET

load_screen_enemy_data_exit:
    rts

; indoor
; input
;  * $08 - 2 byte memory address pointing to level_enemy_screen_ptr_ptr_tbl at correct offset
;  * $a0 - 2 byte memory address pointing to correct level_x_enemy_screen_ptr_tbl offset
;          (e.g. level_x_enemy_screen_xx) for the current screen
load_enemy_indoor_level:
    lda ENEMY_SCREEN_READ_OFFSET     ; offset for enemy data
    bne load_screen_enemy_data_exit
    inc ENEMY_SCREEN_READ_OFFSET     ; offset for enemy data
    lda #$00                         ; a = #$00
    sta INDOOR_ENEMY_ATTACK_COUNT    ; clear the number of enemy 'rounds' of attack
    sta WALL_PLATING_DESTROYED_COUNT ; clear the number of boss platings destroyed
    sta INDOOR_RED_SOLDIER_CREATED   ; clear flag indicating that a red jumping soldier has been generated
    sta GRENADE_LAUNCHER_FLAG        ; clear the flag indicating there is a grenade launcher on screen
    jsr remove_all_enemies
    ldy #$00                         ; y = #$00
    lda ($0a),y                      ; read first byte of level_x_enemy_screen_xx
                                     ; i.e. the number of cores to destroy to advance to the next room
    cmp #$ff                         ; see if end of data marker
    beq load_screen_enemy_data_exit  ; exit if read all of the data
    sta WALL_CORE_REMAINING          ; set remaining cores to destroy for screen
                                     ; for level 4 boss, used to count remaining boss gemini
    cmp #$00                         ; see if number of cores is #$00 (no indoor screens are configured this way)
    bne @continue                    ; continue if there are cores to destroy before marking screen clear
    lda #$01                         ; !(UNUSED) every screen in contra has at least one core, so this code is never executed
    sta INDOOR_SCREEN_CLEARED        ; indoor screen cleared flag (0 = not cleared; 1 = cleared)
                                     ; immediately marks screen as cleared

@continue:
    iny      ; increment level_x_enemy_screen_xx read offset
    ldx #$0f ; x = #$0f

; loop through enemy data in level_x_enemy_screen_xx
@load_indoor_enemy:
    lda ($0a),y                     ; load enemy position
    cmp #$ff                        ; see if end of data byte
    beq load_screen_enemy_data_exit ; exit if read all of the data
    sta $0f                         ; store enemy position in $0f
    iny                             ; increment enemy data read offset
    lda ($0a),y                     ; load enemy type (and enemy pos adjustment flags)
    sta $08                         ; store in $08
    and #$3f                        ; strip bits 6 and 7 (pos adjustment flags) to get enemy type
    sta ENEMY_TYPE,x                ; set current enemy type
    jsr initialize_enemy            ; initialize enemy attributes
    lda $0f                         ; load enemy position
    and #$f0                        ; keep high nibble (y position)
    asl $08                         ; see enemy y pos adjustment flag set
    bcc @get_x_pos                  ; branch if no y adjustment
    adc #$07                        ; enemy y pos adjustment flag set, adjust y position by #$07

@get_x_pos:
    sta ENEMY_Y_POS,x         ; set enemy y position on screen
    lda $0f                   ; load enemy position
    asl
    asl
    asl
    asl                       ; shift low nibble to high nibble
    asl $08                   ; see enemy x pos adjustment flag set
    bcc @set_y_attrs_continue ; branch if no x adjustment
    adc #$07                  ; enemy x pos adjustment flag set, adjust y position by #$07

@set_y_attrs_continue:
    sta ENEMY_X_POS,x      ; set enemy x position on screen
    iny                    ; increment enemy data read offset
    lda ($0a),y            ; load enemy attributes
    sta ENEMY_ATTRIBUTES,x ; set enemy attributes
    iny                    ; increment enemy data read offset
    dex                    ; decrement enemy slot
    bpl @load_indoor_enemy ; continue to load next enemy if slots available
    rts

; levels enemy groups pointers (#$8 * #$2 = #$10 bytes)
level_enemy_screen_ptr_ptr_tbl:
    .addr level_1_enemy_screen_ptr_tbl ; CPU address $b82b
    .addr level_2_enemy_screen_ptr_tbl ; CPU address $b8aa
    .addr level_3_enemy_screen_ptr_tbl ; CPU address $b90d
    .addr level_4_enemy_screen_ptr_tbl ; CPU address $b9af
    .addr level_5_enemy_screen_ptr_tbl ; CPU address $ba48
    .addr level_6_enemy_screen_ptr_tbl ; CPU address $bb24
    .addr level_7_enemy_screen_ptr_tbl ; CPU address $bbb7
    .addr level_8_enemy_screen_ptr_tbl ; CPU address $bca9

exe_soldier_generation:
    lda LEVEL_SCREEN_NUMBER      ; load current screen number within the level
    cmp SOLDIER_GEN_SCREEN       ; compare it to the screen the soldiers are being generated for
    beq @run_soldier_gen_routine ; already reset the SOLDIER_GEN_SCREEN memory, skip initialization
    sta SOLDIER_GEN_SCREEN       ; update current soldier generation screen number
    lda #$00                     ; a = #$00
    sta SCREEN_GEN_SOLDIERS      ; init the number of soldiers that have been generated for the screen

@run_soldier_gen_routine:
    lda SOLDIER_GENERATION_ROUTINE ; soldier generation routine index
    jsr run_routine_from_tbl_below ; run routine a in the following table (soldier_generation_ptr_tbl)

; pointer table for soldier generation (#$3 * #$2 = #$6 bytes)
; CPU address $b537
soldier_generation_ptr_tbl:
    .addr soldier_generation_00 ; CPU address $b53d
    .addr soldier_generation_01 ; CPU address $b581
    .addr soldier_generation_02 ; CPU address $b657

; determines if should generate, and if so sets SOLDIER_GENERATION_TIMER
soldier_generation_00:
    jsr get_soldier_gen_timer_for_lvl ; get the initial timer for the level
    beq soldier_generation_00_exit    ; exit if timer is #$00, don't generate soldier (indoor/base levels)
    jsr adjust_generation_timer       ; update timer based on how many times player beat game and weapon strength
    inc SOLDIER_GENERATION_ROUTINE    ; set to soldier_generation_01

soldier_generation_00_exit:
    rts

; get level's initial value for the soldier generation timer and store in a
get_soldier_gen_timer_for_lvl:
    lda CURRENT_LEVEL                    ; load current level
    tay                                  ; move current level into y
    lda level_soldier_generation_timer,y ; load soldier generation timer for level
    rts

; update timer based on how many times player beat game and weapon strength
adjust_generation_timer:
    jsr get_soldier_gen_timer_for_lvl
    sta SOLDIER_GENERATION_TIMER      ; soldier generation timer
    ldy GAME_COMPLETION_COUNT         ; load the number of times the game has been completed
    beq @adjust_timer_for_weapon      ; branch if haven't yet beat the game any times
    tya
    cmp #$04                          ; compare GAME_COMPLETION_COUNT to #$04
    bcc @continue                     ; branch if GAME_COMPLETION_COUNT < #$04
    ldy #$03                          ; maximum multiplier of increase chance for generating soldier is #$03

@continue:
    lda #$28          ; lower soldier generation timer
    jsr @adjust_timer ; subtract #$28 * GAME_COMPLETION_COUNT from SOLDIER_GENERATION_TIMER

; lower timer based on how strong the player's weapon is (#05 * PLAYER_WEAPON_STRENGTH)
@adjust_timer_for_weapon:
    ldy PLAYER_WEAPON_STRENGTH ; load player weapon strength (damage strength)
    beq @exit                  ; don't generate if player's weapon strength is #$00
    lda #$05                   ; subtract #$05 * PLAYER_WEAPON_STRENGTH from SOLDIER_GENERATION_TIMER

; SOLDIER_GENERATION_TIMER = SOLDIER_GENERATION_TIMER - (a*y)
@adjust_timer:
    sta $08
    lda SOLDIER_GENERATION_TIMER ; soldier generation timer

@loop:
    sec                          ; set carry flag in preparation for subtraction
    sbc $08                      ; SOLDIER_GENERATION_TIMER - $08
    bcc @exit                    ; exit when overflow
    sta SOLDIER_GENERATION_TIMER
    dey
    bne @loop

@exit:
    rts

; table for soldier generation initial timer values (#$8 bytes)
; current level value stored in SOLDIER_GENERATION_TIMER
; the lower the value, the quicker a soldier is generated
; #$36 = lots of soldiers
; #$08 = insane
; #$00 = no soldier generation (indoor/base levels, and alien's lair)
level_soldier_generation_timer:
    .byte $90,$00,$d8,$00,$d0,$c8,$c0,$00

soldier_generation_01:
    lda FRAME_COUNTER    ; load frame counter
    ror
    bcc @continue        ; every other frame look at the FRAME_SCROLL to see if should only subtract by #$01
    lda FRAME_SCROLL     ; odd frame, load whether or not the screen is scrolling (#00 or #01)
    bne @frame_scrolling ; branch if frame is scrolling

@continue:
    lda SOLDIER_GENERATION_TIMER ; soldier generation timer
    sec                          ; set carry flag in preparation for subtraction
    sbc #$02
    sta SOLDIER_GENERATION_TIMER ; soldier generation timer
    bcc gen_soldier_find_pos
    rts                          ; exit soldier_generation_01

; only subtract one from SOLDIER_GENERATION_TIMER when scrolling
@frame_scrolling:
    dec SOLDIER_GENERATION_TIMER ; soldier generation timer
    beq gen_soldier_find_pos     ; timer is now #$00
    rts                          ; exit soldier_generation_01

; find the appropriate position to generate the soldier
gen_soldier_find_pos:
    jsr adjust_generation_timer ; reset the soldier generation timer for later
    lda FRAME_COUNTER           ; load frame counter
    adc RANDOM_NUM              ; add random number to frame counter
    and #$01                    ; just care about if result is even or odd
    tay
    lda SPRITE_Y_POS,y          ; get player 1 or player 2's Y position
    bne @search_for_position    ; branch if player sprite exists
    tya                         ; no player sprite (probably player 2), transfer y to a
    eor #$01                    ; flip least significant bit (0 to 1, or 1 to 0)
    lda SPRITE_Y_POS,y          ; reload #$00, !(BUG?)
                                ; the developers may have meant to do a tay before this instruction
                                ; to switch to use the other player's y position, but since
                                ; they didn't, the same #$00 is read

@search_for_position:
    sta $08                            ; store player y position in $08
    sta $0a                            ; set stopping y position of search
    lda FRAME_COUNTER                  ; load frame counter
    and #$03                           ; keep bits .... ..xx
    tay
    beq top_down_find_gen_soldier_pos  ; 1/3 chance to start with y = #$00 (top)
    dey
    beq bottom_up_find_gen_soldier_pos ; 1/3 chance to start with y = #$f0 (bottom)
    jsr get_x_pos_check_bg_collision   ; 1/3 chance to start with y = player y position (then search up)

; look at every #$10 pixels to see if can place a soldier at position
; start at player y position and move up
@find_y_pos:
    lda $08                            ; load previous soldier generation test y position
    sec                                ; set carry flag in preparation for subtraction
    sbc #$10                           ; subtract #$10 pixels from soldier generation test y position (move up)
    sta $08                            ; update soldier generation test y position
    cmp $0a                            ; compare to the player y position
    beq gen_soldier_find_pos_exit      ; exit if reached player y position (wrapped around screen)
    jsr check_gen_soldier_bg_collision ; check if soldier can be generated at location
    bcc @find_y_pos                    ; didn't have a ground. loop to next y test position.

gen_soldier_find_pos_exit:
    rts

; look at every #$10 pixels to see if can place a soldier at position
; start at top of screen down until player y position
top_down_find_gen_soldier_pos:
    lda #$00                         ; a = #$00
    sta $08                          ; set start y position (top of screen)
    sta $0a                          ; set stopping y position of search
    jsr get_x_pos_check_bg_collision ; determine the x position (don't bother with carry flag result)

; look at every #$10 pixels to see if can place a soldier at position
; start at the top of the screen down to bottom
@find_y_pos:
    lda $08                            ; load previous soldier generation test y position
    clc                                ; clear carry in preparation for addition
    adc #$10                           ; add #$10 pixels from soldier generation test y position (move down)
    sta $08                            ; update soldier generation test y position
    cmp $0a                            ; compare to the top of the screen #$00
    beq gen_soldier_find_pos_exit      ; exit if reached top of screen (wrapped around)
    jsr check_gen_soldier_bg_collision ; check if soldier can be generated at location
    bcc @find_y_pos                    ; didn't have a ground. loop to next y test position.
    bcs gen_soldier_find_pos_exit      ; always jump, found ground and possibly generated soldier

; look at every #$10 pixels to see if can place a soldier at position
; start at the bottom of the screen up to top
bottom_up_find_gen_soldier_pos:
    lda #$f0                         ; a = #$f0
    sta $08                          ; set start y position (bottom of screen)
    sta $0a                          ; set stopping position of search
    jsr get_x_pos_check_bg_collision ; determine the x position (don't bother with carry flag result)

@find_y_pos:
    lda $08                            ; load previous soldier generation test y position
    sec                                ; set carry flag in preparation for subtraction
    sbc #$10                           ; subtract #$10 pixels from soldier generation test y position (move up)
    sta $08                            ; update soldier generation test y position
    cmp $0a                            ; compare to the bottom of the screen #$00
    beq gen_soldier_find_pos_exit      ; exit if reached bottom of screen (wrapped around)
    jsr check_gen_soldier_bg_collision ; check if soldier can be generated at location
    bcc @find_y_pos                    ; didn't have a ground. loop to next y test position.
    bcs gen_soldier_find_pos_exit      ; always jump, found ground and possibly generated soldier

; determine appropriate x position for soldier to generate and then
; see if there is a ground collision
get_x_pos_check_bg_collision:
    lda FRAME_COUNTER                 ; load frame counter
    adc RANDOM_NUM                    ; a = FRAME_COUNTER + RANDOM_NUM
    and #$0f                          ; keep low nibble of FRAME_COUNTER + RANDOM_NUM
    tay
    lda gen_soldier_initial_x_pos,y   ; load possible initial x position of generated soldier
    ldy GAME_COMPLETION_COUNT         ; load the number of times the game has been completed
    bne @check_bg_collision           ; player(s) have completed game at least once
    ldy CURRENT_LEVEL                 ; current level
    bne @check_bg_collision           ; branch if not the first level
    pha                               ; push gen_soldier_initial_x_pos value to stack
    lda SCREEN_GEN_SOLDIERS           ; load the number of soldiers that have been generated for the level
    cmp #$1e
    bcs @pop_x_pos_check_bg_collision ; branch if the number of soldiers generated for frame >= #$1e
    pla                               ; pop a from stack, not going to use gen_soldier_initial_x_pos value
    lda #$fc                          ; set soldier generation test x position to right edge of screen
    bne @check_bg_collision           ; always branch

@pop_x_pos_check_bg_collision:
    pla ; pop a from stack

@check_bg_collision:
    sta $09 ; put gen_soldier_initial_x_pos value, or #$fc into $09

check_gen_soldier_bg_collision:
    lda $09                  ; generated soldier possible x position
    ldy $08                  ; generated soldier possible y position
    jsr get_bg_collision     ; determine player background collision code at position (a,y)
    bcs @set_pos_adv_routine ; floor collision, mark that soldier can be generated
    rts                      ; exit soldier_generation_01

; soldier background collision
@set_pos_adv_routine:
    lda $09                        ; load generated soldier x position
    sta SOLDIER_GENERATION_X_POS   ; store generated soldier initial x position
    lda $08                        ; load generated soldier initial y position
    sec                            ; set carry flag in preparation for subtraction
    sbc #$10                       ; subtract #$10 from generated soldier initial y position
    sta SOLDIER_GENERATION_Y_POS   ; store initial y position
    lda SOLDIER_GENERATION_ROUTINE
    cmp #$02                       ; see if routine is set to soldier_generation_02
    beq @mark_and_exit             ; see if still on soldier_generation_02
                                   ; check_gen_soldier_bg_collision is called initially and the result
                                   ; is ignored. Don't want to advance routine multiple times
    inc SOLDIER_GENERATION_ROUTINE ; move to soldier_generation_02

@mark_and_exit:
    sec ; set carry flag, mark that a soldier can be generated at position
    rts

; table for possible initial x positions of generated soldiers (#$10 bytes)
; always either left edge (#$0a) or right edge (#$fa)
; level 1 doesn't use this table until at least #$1e (36 decimal) enemies have been
; generated for the screen. Instead soldiers always come from the right.
; Presumably this is to make the game easier in the beginning.
gen_soldier_initial_x_pos:
    .byte $fa,$0a,$fa,$fa,$0a,$fa,$0a,$fa,$0a,$0a,$0a,$fa,$fa,$0a,$0a,$fa

soldier_generation_02:
    lda CURRENT_LEVEL            ; current level
    cmp #$02                     ; compare current level to #$02 (level 3 - waterfall)
    beq generate_soldier         ; don't prevent top %25 from generating soldiers for level 3 waterfall (vertical level)
    lda SOLDIER_GENERATION_Y_POS ; load soldier initial y position
    cmp #$40                     ; compare to 25% of the vertical space, don't generate top 25% of screen
    bcs generate_soldier         ; branch if in bottom 3/4 of the screen

soldier_gen_exit_far:
    jmp soldier_gen_exit

generate_soldier:
    lda SOLDIER_GENERATION_Y_POS    ; generated soldier initial y position on screen
    cmp #$e0                        ; compare y position to bottom extremity of screen
    bcs soldier_gen_exit_far        ; exit if soldier generation position is too low
    lda ENEMY_ATTACK_FLAG           ; see if enemies should attack
    beq soldier_gen_exit_far        ; don't generate soldier if ENEMY_ATTACK_FLAG is #$00
    lda CURRENT_LEVEL               ; current level
    cmp #$04                        ; check if level 5 (snow field)
    bne @continue                   ; check if in the last screens of level 5 (snow field)
    lda LEVEL_SCREEN_NUMBER         ; load current screen number within the level
    cmp #$11                        ; screen #$11 of snow field
    bcc @continue                   ; check for last screen of snow field
    jsr get_soldier_gen_screen_side ; see which horizontal half of the screen soldier is being generated on
    bcc soldier_gen_exit_far        ; exit if from left half. don't generate soldiers from left

@continue:
    lda SOLDIER_GENERATION_X_POS    ; load generated soldier initial x position
    ldy SOLDIER_GENERATION_Y_POS    ; load generated soldier initial y position
    jsr get_bg_collision_far        ; determine player background collision code at position (a,y)
    bmi soldier_gen_exit_far        ; exit if collision with solid object (#$80)
    jsr get_soldier_gen_screen_side ; see which horizontal half of the screen soldier is being generated on
    bcc @load_gen_soldier_attr      ; branch if generating on left half of the screen
    sbc #$10                        ; soldier generation on right half of screen, subtract #$10 from x position

@load_gen_soldier_attr:
    clc                                      ; clear carry in preparation for addition
    adc #$08                                 ; subtract #$08 from soldier generation x position
    ldy SOLDIER_GENERATION_Y_POS
    jsr get_bg_collision_far                 ; determine player background collision code at position (a,y)
    bmi soldier_gen_exit_far                 ; branch if collision with solid object
    jsr find_next_enemy_slot_6_to_0          ; find next available enemy slot (0-6), put result in x register
    bne soldier_gen_exit_far                 ; branch if no slot was found
    lda CURRENT_LEVEL                        ; current level
    asl
    tay
    lda soldier_level_attributes_ptr_tbl,y   ; load the low byte of the address
    sta $08
    lda soldier_level_attributes_ptr_tbl+1,y ; load the high byte of the address
    sta $09
    lda LEVEL_SCREEN_NUMBER                  ; load current screen number within the level
    beq soldier_gen_exit_far                 ; first screen never has enemies, skip
    tay
    dey                                      ; subtract 1 since there is no screen 0 enemy
    lda ($08),y                              ; load the yth screen's soldier's behavior
    cmp #$ff                                 ; see if #$ff, which means don't generate soldiers for screen
    beq soldier_gen_exit_far                 ; exit
    and #$80                                 ; keep bits msb
    beq @cont_load_gen_soldier_attr          ; branch if msb is 0
    lda FRAME_COUNTER                        ; when bit 7 is set there is a 50% probability of no generation
    ror
    bcc @cont_load_gen_soldier_attr          ; branch if even frame number
    bcs soldier_gen_exit                     ; don't generate if odd frame

@cont_load_gen_soldier_attr:
    lda ($08),y          ; reload soldier generation attribute byte for screen
    and #$40             ; keep bit 6. When bit 6 set there is a 25% probability of no generation
    beq @gen_soldier     ; bit 6 not set, continue
    lda FRAME_COUNTER    ; load frame counter
    and #$03             ; keep bits .... ..xx
    beq @gen_soldier     ; if bit 0 or bit 1 is not 0, then don't generate soldier (25% chance)
    bne soldier_gen_exit

@gen_soldier:
    lda SCREEN_GEN_SOLDIERS
    cmp #$1e
    bcs init_and_generate_soldier ; branch if more than #$1e (30 dec) soldiers have already been generated on screen
    lda GAME_COMPLETION_COUNT     ; load the number of times the game has been completed
    bne init_and_generate_soldier ; branch if player(s) have completed game at least once
                                  ; this skips preventing a soldier from being generated near a player
                                  ; at the edge of the screen
    jmp player_edge_check         ; player(s) haven't completed game and less than #$1e soldiers
                                  ; have been generated for screen, so jump

init_and_generate_soldier:
    lda CURRENT_LEVEL           ; current level
    cmp #$02                    ; compare level to level 3 (waterfall)
    beq @init_generated_soldier ; initialize generated soldier without checking FRAME_SCROLL for waterfall
    lda FRAME_SCROLL            ; how much to scroll the screen (#00 - no scroll)
    beq @init_generated_soldier ; initialize generated soldier if not scrolling
    lda RANDOM_NUM              ; load a random number
    and #$03                    ; keep bits .... ..xx
    beq create_default_soldiers ; 1/3 chance of branching to create a soldier for each player

; initializes the ENEMY_TYPE to #$05
; initializes ENEMY_ATTRIBUTES based on slightly random value from gen_soldier_initial_attr_tbl
@init_generated_soldier:
    lda #$05                           ; a = #$05 (soldier)
    sta ENEMY_TYPE,x                   ; set current enemy type to soldier
    jsr initialize_enemy               ; initialize enemy attributes
    lda ($08),y                        ; load soldier_level_attributes_xx (attributes for current level soldiers)
    and #$3f                           ; strip bits 6 and 7 (soldier generation probably bits)
    asl
    asl
    sta $0a                            ; start to determine random position into gen_soldier_initial_attr_tbl to load
    lda FRAME_COUNTER                  ; load frame counter
    and #$03                           ; keep bits .... ..xx
    clc                                ; clear carry in preparation for addition
    adc $0a                            ; randomly add a value from 0 to 3 to soldier_level_attributes_xx value
    tay                                ; move to be gen_soldier_initial_attr_tbl index
    lda gen_soldier_initial_attr_tbl,y ; load initial ENEMY_ATTRIBUTES value for generated soldier
    sta ENEMY_ATTRIBUTES,x
    lda RANDOM_NUM                     ; load random number
    adc FRAME_COUNTER                  ; add to the frame counter
    and #$02                           ; keep bits .... ..x.
    beq @set_gen_soldier_pos_and_dir   ; randomly skip setting how soldiers handle ledges to 1
    ora ENEMY_ATTRIBUTES,x             ; set bit 1 of ENEMY_ATTRIBUTES (ledge handling behavior)
    sta ENEMY_ATTRIBUTES,x             ; save new ENEMY_ATTRIBUTES value

@set_gen_soldier_pos_and_dir:
    lda SOLDIER_GENERATION_Y_POS    ; load the computed y position of the generated soldier
    sta ENEMY_Y_POS,x               ; copy the computed generated soldier y position to the enemy y position
    jsr get_soldier_gen_screen_side ; see which horizontal half of the screen soldier is being generated on
    sta ENEMY_X_POS,x               ; copy the computed generated soldier x position to the enemy x position
    bcs @inc_soldier_cnt_exit       ; branch if right horizontal half of the screen
    inc ENEMY_ATTRIBUTES,x          ; left half of the screen, set soldier direction to run towards the right

@inc_soldier_cnt_exit:
    inc SCREEN_GEN_SOLDIERS ; increment the total number of generated soldiers for the current screen

soldier_gen_exit:
    lda #$00                       ; a = #$00
    sta SOLDIER_GENERATION_ROUTINE ; reset soldier generation routine index to reset SOLDIER_GENERATION_TIMER
    rts

; compares SOLDIER_GENERATION_X_POS to the middle of the screen (#$80)
; clears carry if on left half of the screen, sets carry for right half of screen
get_soldier_gen_screen_side:
    lda SOLDIER_GENERATION_X_POS ; generated soldier initial x position on screen
    cmp #$80
    rts

; 1/3 chance of happening on a screen with generating soldiers
; generates a 'default' soldier for each player, i.e. not using gen_soldier_initial_attr_tbl
create_default_soldiers:
    lda #$00                        ; a = #$00
    sta $07                         ; initial soldier x direction is to the left
    jsr get_soldier_gen_screen_side ; see which horizontal half of the screen soldier is being generated on
    bcs @create_soldier             ; branch if soldier is generated from the right side
    inc $07                         ; generated soldier generated from left side, have them run to the right

@create_soldier:
    ldy #$02 ; y = #$02

@loop:
    inc $06                         ; increment ENEMY_ATTRIBUTES value
    tya                             ; save y in stack so it can be restored after logic
    pha                             ; push a to the stack
    jsr find_next_enemy_slot_6_to_0 ; find next available enemy slot, put result in x register
    bne @pop_a_soldier_gen_exit     ; can't generate soldier, clean up pushed a from stack and exit
    lda #$05                        ; a = #$05 (soldier)
    sta ENEMY_TYPE,x                ; set current enemy type to soldier
    jsr initialize_enemy            ; initialize enemy attributes
    jsr @set_enemy_pos              ; set SOLDIER_GENERATION_X_POS to ENEMY_POS_X and SOLDIER_GENERATION_Y_POS to ENEMY_POS_Y
    lda $06
    and #$02                        ; keep bits .... ..x.
    sta ENEMY_ATTRIBUTES,x
    pla                             ; pop a from stack to restore y
    tay                             ; restore y value
    asl
    asl
    asl
    asl
    clc                             ; clear carry in preparation for addition
    adc ENEMY_ATTRIBUTES,x          ;
    ora $07                         ; set soldier x direction
    sta ENEMY_ATTRIBUTES,x          ; save soldier direction back in ENEMY_ATTRIBUTES
    jsr @set_enemy_pos              ; seems redundant, already was set above
    dey                             ; move to player 1
    bmi soldier_gen_exit            ; finished player loop, exit
    bpl @loop

@pop_a_soldier_gen_exit:
    pla
    jmp soldier_gen_exit

@set_enemy_pos:
    lda SOLDIER_GENERATION_Y_POS ; generated soldier initial y position on screen
    sta ENEMY_Y_POS,x            ; enemy y position on screen
    lda SOLDIER_GENERATION_X_POS ; generated soldier initial x position on screen
    sta ENEMY_X_POS,x            ; set enemy x position on screen
    rts

; player(s) haven't completed game and less than #$1e soldiers
; see if player is close to the edge where the soldier will be generated
; if so, don't generate soldier
player_edge_check:
    tya                             ; need to save current value of y temporarily to restore after method
    pha                             ; temporarily save current value of a to stack
    ldy #$01                        ; set y to start with player 2 for gen_soldier_right_side
    jsr get_soldier_gen_screen_side ; see which horizontal half of the screen soldier is being generated on
    bcs gen_soldier_right_side      ; branch if soldier is to be generated on right half of the screen

; soldier to be generated from left side of screen
@player_loop:
    lda P1_GAME_OVER_STATUS,y      ; game over state (1 = game over)
    bne @move_next_player          ; skip player if in game over state
    lda SPRITE_X_POS,y             ; player x position on screen
    cmp #$40                       ; left 25% of screen
    bcc restore_y_soldier_gen_exit ; exit if player is close to the left
                                   ; where the soldier would have been generated

@move_next_player:
    dey
    bpl @player_loop

restore_y_init_and_generate_soldier:
    pla                           ; pop value a from stack
    tay                           ; restore value of y from before jmp to player_edge_check
    jmp init_and_generate_soldier

restore_y_soldier_gen_exit:
    pla
    tay
    jmp soldier_gen_exit

; check players GAME_OVER_STATUS
; generated soldier on the right half of the screen
gen_soldier_right_side:
    lda P1_GAME_OVER_STATUS,y      ; game over state (1 = game over)
    bne @next_player               ; branch if game over for player
    lda SPRITE_X_POS,y             ; load player's x position
    cmp #$c0                       ; compare x position to 3/4 (75%) of the horizontal screen
    bcs restore_y_soldier_gen_exit ; exit if player is close to the right
                                   ; where the soldier would have been generated

@next_player:
    dey
    bpl gen_soldier_right_side              ; check player 1's game over status
    bmi restore_y_init_and_generate_soldier

; pointer table for soldier random generation (#$8 * #$2 = #$10 bytes)
soldier_level_attributes_ptr_tbl:
    .addr soldier_level_attributes_00 ; CPU address $b7cb
    .addr soldier_level_attributes_00 ; CPU address $b7cb
    .addr soldier_level_attributes_01 ; CPU address $b7d7
    .addr soldier_level_attributes_00 ; CPU address $b7cb
    .addr soldier_level_attributes_02 ; CPU address $b7e0
    .addr soldier_level_attributes_03 ; CPU address $b7f4
    .addr soldier_level_attributes_04 ; CPU address $b800
    .addr soldier_level_attributes_00 ; CPU address $b7cb

; related to soldier generation according to level and screen number
; each byte represents a screen of a level and how the soldier's will
; be generated on that screen
; #$ff = don't generate soldier
; #$80 = random right/left, no shooting, freq. 1 on screen
; #$40 = random right/left, no shooting, freq. 50% of 80
; #$00 = random right/left, no shooting, freq. 1 per 1.5s
; #$01 = random right/left, shoot 1-2 bullets ratio 75-25, freq. like 00
; #$02 = random right/left, shoot 1-2 bullets ratio 67-33, freq. like 00
; #$03 = random right/left, shoot 1-2 bullets ratio 67-33, freq. like 00

; #$c bytes
soldier_level_attributes_00:
    .byte $80,$80,$80,$80,$80,$80,$80,$40,$40,$80,$ff,$ff

; #$9 bytes
soldier_level_attributes_01:
    .byte $00,$00,$00,$01,$00,$ff,$01,$ff,$ff

; #$14 bytes
soldier_level_attributes_02:
    .byte $01,$02,$03,$04,$03,$03,$03,$02,$ff,$04,$02,$03,$ff,$02,$03,$04
    .byte $02,$ff,$ff,$ff

; #$c bytes
soldier_level_attributes_03:
    .byte $00,$05,$02,$ff,$ff,$80,$05,$03,$82,$ff,$ff,$ff

; #$f bytes
soldier_level_attributes_04:
    .byte $80,$05,$06,$80,$80,$05,$07,$80,$80,$04,$ff,$04,$04,$ff,$ff

; table for generated soldiers initial ENEMY_ATTRIBUTES value (#$1c bytes)
; bit 0 = running direction - 0 is left, 1 is right
; bit 1 = affects whether the soldier turns around on ledges ?
; bit 2 = whether or not the enemy shoots bullets
gen_soldier_initial_attr_tbl:
    .byte $00,$00,$00,$00
    .byte $00,$00,$00,$04
    .byte $00,$00,$04,$04
    .byte $00,$04,$04,$04
    .byte $04,$04,$04,$04
    .byte $00,$00,$00,$08
    .byte $00,$00,$04,$08

; pointer table for level 1 enemy groups (d * 2 = 1a bytes)
level_1_enemy_screen_ptr_tbl:
    .addr level_1_enemy_screen_00 ; CPU address $b845
    .addr level_1_enemy_screen_01 ; CPU address $b858
    .addr level_1_enemy_screen_02 ; CPU address $b85c
    .addr level_1_enemy_screen_03 ; CPU address $b860
    .addr level_1_enemy_screen_04 ; CPU address $b864
    .addr level_1_enemy_screen_05 ; CPU address $b871
    .addr level_1_enemy_screen_06 ; CPU address $b87b
    .addr level_1_enemy_screen_07 ; CPU address $b87f
    .addr level_1_enemy_screen_08 ; CPU address $b886
    .addr level_1_enemy_screen_09 ; CPU address $b88d
    .addr level_1_enemy_screen_0a ; CPU address $b895
    .addr level_1_enemy_screen_0b ; CPU address $b899
    .addr level_1_enemy_screen_0c ; CPU address $b8a9

; enemy format
;
; xx tt yy
;
; xx = x position
; xxxxxxxx x position
;
; tt = enemy type + repeat
; xx.. .... repeat
; ..xx xxxx enemy type
;
; yy = y position + attributes
; xxxx x... y position
; .... .xxx attributes
level_1_enemy_screen_00:
    .byte $10,$05,$60 ; soldier - runs left, doesn't shoot
    .byte $40,$05,$60 ; soldier - runs left, doesn't shoot
    .byte $50,$06,$c0 ; sniper - standing, shoots once per attack
    .byte $60,$02,$a1 ; pill box sensor - machine gun inside
    .byte $80,$05,$60 ; soldier - runs left, doesn't shoot
    .byte $f0,$03,$40 ; flying capsule - rapid fire
    .byte $ff

level_1_enemy_screen_01:
    .byte $90,$06,$c0 ; sniper - standing, shoots one bullet at a time
    .byte $ff

level_1_enemy_screen_02:
    .byte $20,$12,$80 ; exploding bridge
    .byte $ff

level_1_enemy_screen_03:
    .byte $40,$12,$80 ; exploding bridge
    .byte $ff

level_1_enemy_screen_04:
    .byte $00,$04,$a0 ; rotating gun, shoots once per attack
    .byte $10,$06,$60 ; sniper - standing, shoots once per attack
    .byte $50,$06,$61 ; sniper - crouching, shoots once per attack
    .byte $60,$03,$43 ; flying capsule - spray gun
    .byte $ff

level_1_enemy_screen_05:
    .byte $20,$06,$41 ; sniper (enemy type #$06), attribute: 001 (crouch and shoot one bullet at a time), location: (#$20, #$40)
    .byte $40,$02,$a2 ; pill box sensor (enemy type #$02), attribute: 010 (F), location: (#$40, #$a0)
    .byte $80,$04,$80 ; rotating gun (enemy type #$04), attribute: 000, location: (#$80, #$80)
    .byte $ff

level_1_enemy_screen_06:
    .byte $40,$04,$80 ; rotating gun (enemy type #$04), attribute: 000, location: (#$40, #$80)
    .byte $ff

level_1_enemy_screen_07:
    .byte $20,$07,$a0 ; red turret (enemy type #$07), attribute: 000, location: (#$20, #$a0)
    .byte $a0,$07,$41 ; red turret (enemy type #$07), attribute: 001, location: (#$a0, #$40)
    .byte $ff

level_1_enemy_screen_08:
    .byte $00,$02,$c3 ; pill box sensor (enemy type #$02), attribute: 011 (S), location: (#$00, #$c0)
    .byte $50,$06,$80 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$50, #$80)
    .byte $ff

level_1_enemy_screen_09:
    .byte $10,$43,$40,$b4 ; flying capsule (enemy type #$03), attribute: 000 (R), location: (#$10, #$40)
                          ; repeat: 1 [(y = #$b0, attr = 100)]
    .byte $e0,$07,$81     ; red turret (enemy type #$07), attribute: 001, location: (#$e0, #$80)
    .byte $ff

level_1_enemy_screen_0a:
    .byte $c0,$04,$c0 ; rotating gun (enemy type #$04), attribute: 000, location: (#$c0, #$c0)
    .byte $ff

level_1_enemy_screen_0b:
    .byte $40,$04,$c3 ; rotating gun (enemy type #$04), attribute: 011, location: (#$40, #$c0)
    .byte $a8,$10,$81 ; bomb turret (enemy type #$10), attribute: 001, location: (#$a8, #$80)
    .byte $b1,$11,$b0 ; plated door (enemy type #$11), attribute: 000, location: (#$b1, #$b0)
    .byte $b4,$06,$52 ; sniper (enemy type #$06), attribute: 010 (boss screen sniper), location: (#$b4, #$50)
    .byte $c0,$10,$80 ; bomb turret (enemy type #$10), attribute: 000, location: (#$c0, #$80)
    .byte $ff

level_1_enemy_screen_0c:
    .byte $ff

; pointer table for level 2 enemy groups (#$6 * #$2 = #$c bytes)
level_2_enemy_screen_ptr_tbl:
    .addr level_2_enemy_screen_00 ; CPU address $b8b6
    .addr level_2_enemy_screen_01 ; CPU address $b8be
    .addr level_2_enemy_screen_02 ; CPU address $b8c9
    .addr level_2_enemy_screen_03 ; CPU address $b8d7
    .addr level_2_enemy_screen_04 ; CPU address $b8e5
    .addr level_2_enemy_screen_05 ; CPU address $b8f6

; level 2 enemy data
; first byte specifies number of wall cores to destroy
; then enemies are described
; byte 0 = location of object
;  * xxxx .... - y position * #$10
;  * .... xxxx - x position * #$10
; byte 1 = enemy type and position adjustment
;  * x... .... - y position + #$07
;  * .x.. .... - x position + #$07
;  * ..xx xxxx object type
; byte 2 = enemy attributes
;  * xxxx .... - y position of enemy
;  * .... xxxx - x position of enemy
level_2_enemy_screen_00:
    .byte $01         ; number of cores to destroy to advance to next room, if set to #$00 no electric barrier, can't advance
    .byte $11,$19,$00 ; enemy type #$19 (indoor soldier generator)
    .byte $68,$94,$03 ; enemy type #$14 (core), not plated, #$f0 opening delay
    .byte $ff

level_2_enemy_screen_01:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$59,$00 ; enemy type #$19 (indoor soldier generator)
    .byte $66,$d4,$03 ; enemy type #$14 (core), not plated, #$f0 opening delay
    .byte $69,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_2_enemy_screen_02:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$59,$00 ; enemy type #$19 (indoor soldier generator)
    .byte $78,$14,$03 ; enemy type #$14 (core), not plated, #$f0 opening delay
    .byte $66,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $69,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_2_enemy_screen_03:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$59,$00 ; enemy type #$19 (indoor soldier generator)
    .byte $11,$1a,$00 ; enemy type #$1a (indoor roller generator)
    .byte $58,$93,$00 ; enemy type #$13 (wall turret)
    .byte $68,$94,$03 ; enemy type #$14 (core), not plated, #$f0 opening delay
    .byte $ff

level_2_enemy_screen_04:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$59,$00 ; enemy type #$19 (indoor soldier generator)
    .byte $68,$94,$0b ; enemy type #$14 (core), larger sized core
    .byte $66,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $69,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $58,$13,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_2_enemy_screen_05:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $48,$10,$00 ; enemy type #$10 (boss eye)
    .byte $65,$08,$00 ; enemy type #$08 (wall cannon)
    .byte $68,$0a,$01 ; enemy type #$0a (wall plating)
    .byte $6b,$08,$00 ; enemy type #$08 (wall cannon)
    .byte $95,$0a,$00 ; enemy type #$0a (wall plating)
    .byte $98,$0a,$00 ; enemy type #$0a (wall plating)
    .byte $9b,$0a,$00 ; enemy type #$0a (wall plating)
    .byte $ff

; pointer table for level 3 enemy groups (#$a * #$2 = #$14 bytes)
; xx = x position
; xxxxxxxx x position
;
; tt = enemy type + repeat
; xx...... repeat
; ..xxxxxx enemy type
;
; yy = y position + attributes
; xxxxx... y position
; .....xxx attributes
level_3_enemy_screen_ptr_tbl:
    .addr level_3_enemy_screen_00 ; CPU address $b921
    .addr level_3_enemy_screen_01 ; CPU address $b941
    .addr level_3_enemy_screen_02 ; CPU address $b948
    .addr level_3_enemy_screen_03 ; CPU address $b95a
    .addr level_3_enemy_screen_04 ; CPU address $b96a
    .addr level_3_enemy_screen_05 ; CPU address $b984
    .addr level_3_enemy_screen_06 ; CPU address $b994
    .addr level_3_enemy_screen_07 ; CPU address $b9a4 (boss)
    .addr level_3_enemy_screen_08 ; CPU address $b9ae (no enemy)
    .addr level_3_enemy_screen_08 ; CPU address $b9ae (no enemy)

; level 3 enemy data - section 1 (#$20 bytes)
level_3_enemy_screen_00:
    .byte $08,$05,$21     ; soldier (enemy type #$05), attribute: 001, location: (#$08, #$20)
    .byte $22,$12,$35     ; rock cave (enemy type #$12), attribute: 101, location: (#$22, #$30)
    .byte $40,$02,$92     ; pill box sensor (enemy type #$02), attribute: 010 (F), location: (#$40, #$90)
    .byte $48,$05,$23     ; soldier (enemy type #$05), attribute: 011, location: (#$48, #$20)
    .byte $62,$12,$d1     ; rock cave (enemy type #$12), attribute: 001, location: (#$62, #$d0)
    .byte $68,$45,$33,$96 ; soldier (enemy type #$05), attribute: 011, location: (#$68, #$30)
                          ; repeat: 1 [(y = #$90, attr = 110)]
    .byte $82,$12,$b5     ; rock cave (enemy type #$12), attribute: 101, location: (#$82, #$b0)
    .byte $a2,$12,$55     ; rock cave (enemy type #$12), attribute: 101, location: (#$a2, #$50)
    .byte $c0,$02,$94     ; pill box sensor (enemy type #$02), attribute: 100 (L), location: (#$c0, #$90)
    .byte $e2,$12,$95     ; rock cave (enemy type #$12), attribute: 101, location: (#$e2, #$90)
    .byte $ff

level_3_enemy_screen_01:
    .byte $38,$06,$e0 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$38, #$e0)
    .byte $60,$0c,$a0 ; scuba diver (enemy type #$0c), attribute: 000, location: (#$60, #$a0)
    .byte $ff

level_3_enemy_screen_02:
    .byte $40,$04,$f5     ; rotating gun (enemy type #$04), attribute: 101, location: (#$40, #$f0)
    .byte $73,$51,$53,$b2 ; moving flame (enemy type #$11), attribute: 011, location: (#$73, #$50), repeat: 1 [(y = #$b0, attr = 010)]
    .byte $80,$06,$e0     ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$80, #$e0)
    .byte $d0,$43,$35,$a0 ; flying capsule (enemy type #$03), attribute: 101 (B), location: (#$d0, #$30), repeat: 1 [(y = #$a0, attr = 000)]
    .byte $e0,$04,$10     ; rotating gun (enemy type #$04), attribute: 000, location: (#$e0, #$10)
    .byte $ff

level_3_enemy_screen_03:
    .byte $11,$10,$50 ; floating rock (enemy type #$10), attribute: 000, location: (#$11, #$50)
    .byte $20,$06,$20 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$20, #$20)
    .byte $81,$10,$71 ; floating rock (enemy type #$10), attribute: 001, location: (#$81, #$70)
    .byte $c0,$04,$10 ; rotating gun (enemy type #$04), attribute: 000, location: (#$c0, #$10)
    .byte $d0,$0c,$50 ; scuba diver (enemy type #$0c), attribute: 000, location: (#$d0, #$50)
    .byte $ff

level_3_enemy_screen_04:
    .byte $38,$05,$72     ; soldier (enemy type #$05), attribute: 010, location: (#$38, #$70)
    .byte $50,$0c,$e0     ; scuba diver (enemy type #$0c), attribute: 000, location: (#$50, #$e0)
    .byte $60,$02,$b3     ; pill box sensor (enemy type #$02), attribute: 011 (S), location: (#$60, #$b0)
    .byte $88,$05,$a6     ; soldier (enemy type #$05), attribute: 110, location: (#$88, #$a0)
    .byte $a0,$04,$f0     ; rotating gun (enemy type #$04), attribute: 000, location: (#$a0, #$f0)
    .byte $a8,$05,$46     ; soldier (enemy type #$05), attribute: 110, location: (#$a8, #$40)
    .byte $d8,$45,$85,$e4 ; soldier (enemy type #$05), attribute: 101, location: (#$d8, #$80), repeat: 1 [(y = #$e0, attr = 100)]
    .byte $e0,$04,$10     ; rotating gun (enemy type #$04), attribute: 000, location: (#$e0, #$10)
    .byte $ff

level_3_enemy_screen_05:
    .byte $20,$02,$11 ; pill box sensor (enemy type #$02), attribute: 001 (M), location: (#$20, #$10)
    .byte $30,$07,$e1 ; red turret (enemy type #$07), attribute: 001, location: (#$30, #$e0)
    .byte $38,$05,$66 ; soldier (enemy type #$05), attribute: 110, location: (#$38, #$60)
    .byte $40,$04,$30 ; rotating gun (enemy type #$04), attribute: 000, location: (#$40, #$30)
    .byte $79,$10,$81 ; floating rock (enemy type #$10), attribute: 001, location: (#$79, #$80)
    .byte $ff

level_3_enemy_screen_06:
    .byte $28,$05,$c6 ; soldier (enemy type #$05), attribute: 110, location: (#$28, #$c0)
    .byte $40,$05,$15 ; soldier (enemy type #$05), attribute: 101, location: (#$40, #$10)
    .byte $58,$05,$95 ; soldier (enemy type #$05), attribute: 101, location: (#$58, #$90)
    .byte $78,$06,$20 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$78, #$20)
    .byte $e8,$05,$65 ; soldier (enemy type #$05), attribute: 101, location: (#$e8, #$60)
    .byte $ff

level_3_enemy_screen_07:
    .byte $08,$05,$e4     ; soldier (enemy type #$05), attribute: 100, location: (#$08, #$e0)
    .byte $a8,$55,$51,$b0 ; dragon orb (enemy type #$15), attribute: 001, location: (#$a8, #$50)
                          ; repeat: 1 [(y = #$b0, attr = 000)]
    .byte $c1,$14,$80     ; dragon (enemy type #$14), attribute: 000, location: (#$c1, #$80)

level_3_enemy_screen_08:
    .byte $ff

; pointer table for level 4 enemy groups (#$9 * #$2 = #$12 bytes)
level_4_enemy_screen_ptr_tbl:
    .addr level_4_enemy_screen_00 ; CPU address $b9c1
    .addr level_4_enemy_screen_01 ; CPU address $b9cf
    .addr level_4_enemy_screen_02 ; CPU address $b9e0
    .addr level_4_enemy_screen_03 ; CPU address $b9ee
    .addr level_4_enemy_screen_04 ; CPU address $b9fc
    .addr level_4_enemy_screen_05 ; CPU address $ba0a
    .addr level_4_enemy_screen_06 ; CPU address $ba15
    .addr level_4_enemy_screen_07 ; CPU address $ba20
    .addr level_4_enemy_screen_08 ; CPU address $ba31

; level 4 enemy data (#$87 bytes)
; first byte specifies number of wall cores to destroy
; then enemies are described
; byte 0 = location of object
;  * xxxx .... - y position * #$10
;  * .... xxxx - x position * #$10
; byte 1 = enemy type and position adjustment
;  * x... .... - y position + #$07
;  * .x.. .... - x position + #$07
;  * ..xx xxxx object type
; byte 2 = enemy attributes
;  * xxxx .... - y position of enemy
;  * .... xxxx - x position of enemy
level_4_enemy_screen_00:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $68,$94,$04 ; enemy type #$14 (core)
    .byte $66,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $69,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_4_enemy_screen_01:
    .byte $04         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $76,$54,$03 ; enemy type #$14 (core)
    .byte $77,$54,$01 ; enemy type #$14 (core)
    .byte $78,$54,$01 ; enemy type #$14 (core)
    .byte $79,$54,$03 ; enemy type #$14 (core)
    .byte $ff

level_4_enemy_screen_02:
    .byte $02         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $67,$d4,$04 ; enemy type #$14 (core)
    .byte $68,$d4,$04 ; enemy type #$14 (core)
    .byte $58,$93,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_4_enemy_screen_03:
    .byte $02         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $68,$13,$00 ; enemy type #$13 (wall turret)
    .byte $77,$54,$03 ; enemy type #$14 (core)
    .byte $78,$54,$03 ; enemy type #$14 (core)
    .byte $ff

level_4_enemy_screen_04:
    .byte $02         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $66,$d4,$03 ; enemy type #$14 (core)
    .byte $68,$93,$00 ; enemy type #$13 (wall turret)
    .byte $69,$d4,$03 ; enemy type #$14 (core)
    .byte $ff

level_4_enemy_screen_05:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$1a,$01 ; enemy type #$1a (indoor roller generator)
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $68,$94,$03 ; enemy type #$14 (core)
    .byte $ff

level_4_enemy_screen_06:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $58,$94,$03 ; enemy type #$14 (core)
    .byte $68,$93,$00 ; enemy type #$13 (wall turret)
    .byte $ff

level_4_enemy_screen_07:
    .byte $01         ; number of cores to destroy to advance to next room
    .byte $11,$19,$01 ; enemy type #$19 (indoor soldier generator)
    .byte $58,$13,$00 ; enemy type #$13 (wall turret)
    .byte $66,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $68,$94,$0b ; enemy type #$14 (core)
    .byte $69,$d3,$00 ; enemy type #$13 (wall turret)
    .byte $ff

; boss screen
level_4_enemy_screen_08:
    .byte $02         ; number of cores to destroy to advance to next room
    .byte $11,$20,$00 ; enemy type #$20 (red and blue soldier generator)
    .byte $36,$5c,$00 ; enemy type #$1c (boss gemini)
    .byte $39,$5c,$00 ; enemy type #$1c (boss gemini)
    .byte $58,$08,$00 ; enemy type #$08 (wall turret)
    .byte $85,$0a,$00 ; enemy type #$0a (wall plating)
    .byte $88,$0a,$01 ; enemy type #$0a (wall plating)
    .byte $8b,$0a,$00 ; enemy type #$0a (wall plating)
    .byte $ff

; pointer table for level 5 enemy groups (#$16 * #$2 = #$2c bytes)
level_5_enemy_screen_ptr_tbl:
    .addr level_5_enemy_screen_00 ; CPU address $ba74
    .addr level_5_enemy_screen_01 ; CPU address $ba81
    .addr level_5_enemy_screen_02 ; CPU address $ba8b
    .addr level_5_enemy_screen_03 ; CPU address $ba92
    .addr level_5_enemy_screen_04 ; CPU address $ba9f
    .addr level_5_enemy_screen_05 ; CPU address $baa9
    .addr level_5_enemy_screen_06 ; CPU address $baad
    .addr level_5_enemy_screen_07 ; CPU address $bab6
    .addr level_5_enemy_screen_08 ; CPU address $babd
    .addr level_5_enemy_screen_09 ; CPU address $baca
    .addr level_5_enemy_screen_0a ; CPU address $bad1
    .addr level_5_enemy_screen_0b ; CPU address $bad8
    .addr level_5_enemy_screen_0c ; CPU address $badc
    .addr level_5_enemy_screen_0d ; CPU address $bae6
    .addr level_5_enemy_screen_0e ; CPU address $baed
    .addr level_5_enemy_screen_0f ; CPU address $baf7
    .addr level_5_enemy_screen_10 ; CPU address $bb01
    .addr level_5_enemy_screen_11 ; CPU address $bb05
    .addr level_5_enemy_screen_12 ; CPU address $bb12
    .addr level_5_enemy_screen_13 ; CPU address $bb1f
    .addr level_5_enemy_screen_14 ; CPU address $bb20
    .addr level_5_enemy_screen_15 ; CPU address $bb23

level_5_enemy_screen_00:
    .byte $20,$10,$60 ; ice grenade generator (enemy type #$10), attribute: 000, location: (#$20, #$60)
    .byte $50,$10,$61 ; ice grenade generator (enemy type #$10), attribute: 001, location: (#$50, #$60)
    .byte $60,$0e,$82 ; turret man (enemy type #$0e), attribute: 010, location: (#$60, #$80)
    .byte $d8,$10,$60 ; ice grenade generator (enemy type #$10), attribute: 000, location: (#$d8, #$60)
    .byte $ff

level_5_enemy_screen_01:
    .byte $00,$0e,$81 ; turret man (enemy type #$0e), attribute: 001, location: (#$00, #$80)
    .byte $08,$10,$63 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$08, #$60)
    .byte $80,$02,$a1 ; pill box sensor (enemy type #$02), attribute: 001 (M), location: (#$80, #$a0)
    .byte $ff

level_5_enemy_screen_02:
    .byte $60,$0e,$82 ; turret man (enemy type #$0e), attribute: 010, location: (#$60, #$80)
    .byte $c0,$0e,$b2 ; turret man (enemy type #$0e), attribute: 010, location: (#$c0, #$b0)
    .byte $ff

level_5_enemy_screen_03:
    .byte $20,$0e,$51 ; turret man (enemy type #$0e), attribute: 001, location: (#$20, #$50)
    .byte $60,$03,$30 ; flying capsule (enemy type #$03), attribute: 000 (R), location: (#$60, #$30)
    .byte $d8,$10,$43 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$d8, #$40)
    .byte $f0,$10,$43 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$f0, #$40)
    .byte $ff

level_5_enemy_screen_04:
    .byte $80,$10,$53 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$80, #$50)
    .byte $c0,$10,$53 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$c0, #$50)
    .byte $d0,$0e,$81 ; turret man (enemy type #$0e), attribute: 001, location: (#$d0, #$80)
    .byte $ff

level_5_enemy_screen_05:
    .byte $60,$02,$82 ; pill box sensor (enemy type #$02), attribute: 010 (F), location: (#$60, #$80)
    .byte $ff

level_5_enemy_screen_06:
    .byte $40,$83,$30,$76,$b3 ; flying capsule (enemy type #$03), attribute: 000 (R), location: (#$40, #$30)
                              ; repeat: 2 [(y = #$70, attr = 110 (Falcon)), (y = #$b0, attr = 011 (S))]
    .byte $40,$0c,$d8         ; scuba diver (enemy type #$0c), attribute: 000, location: (#$40, #$d8)
    .byte $ff

level_5_enemy_screen_07:
    .byte $10,$0c,$d8 ; scuba diver (enemy type #$0c), attribute: 000, location: (#$10, #$d8)
    .byte $a0,$06,$80 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$a0, #$80)
    .byte $ff

level_5_enemy_screen_08:
    .byte $00,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$00, #$b0)
    .byte $40,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$40, #$b0)
    .byte $80,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$80, #$b0)
    .byte $c0,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$c0, #$b0)
    .byte $ff

level_5_enemy_screen_09:
    .byte $01,$12,$32 ; tank (enemy type #$12), attribute: 010, location: (#$01, #$30)
    .byte $00,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$00, #$b0)
    .byte $ff

level_5_enemy_screen_0a:
    .byte $80,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$80, #$b0)
    .byte $c0,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$c0, #$b0)
    .byte $ff

level_5_enemy_screen_0b:
    .byte $a8,$0e,$a1 ; turret man (enemy type #$0e), attribute: 001, location: (#$a8, #$a0)
    .byte $ff

level_5_enemy_screen_0c:
    .byte $40,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$40, #$b0)
    .byte $80,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$80, #$b0)
    .byte $c0,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$c0, #$b0)
    .byte $ff

level_5_enemy_screen_0d:
    .byte $01,$12,$33 ; tank (enemy type #$12), attribute: 011, location: (#$01, #$30)
    .byte $00,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$00, #$b0)
    .byte $ff

level_5_enemy_screen_0e:
    .byte $80,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$80, #$b0)
    .byte $c0,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$c0, #$b0)
    .byte $d0,$0e,$a1 ; turret man (enemy type #$0e), attribute: 001, location: (#$d0, #$a0)
    .byte $ff

level_5_enemy_screen_0f:
    .byte $60,$10,$52 ; ice grenade generator (enemy type #$10), attribute: 010, location: (#$60, #$50)
    .byte $a0,$10,$53 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$a0, #$50)
    .byte $e8,$10,$53 ; ice grenade generator (enemy type #$10), attribute: 011, location: (#$e8, #$50)
    .byte $ff

level_5_enemy_screen_10:
    .byte $60,$02,$a4 ; pill box sensor (enemy type #$02), attribute: 100 (L), location: (#$60, #$a0)
    .byte $ff

level_5_enemy_screen_11:
    .byte $00,$10,$80 ; ice grenade generator (enemy type #$10), attribute: 000, location: (#$00, #$80)
    .byte $60,$10,$81 ; ice grenade generator (enemy type #$10), attribute: 001, location: (#$60, #$80)
    .byte $b0,$0e,$81 ; turret man (enemy type #$0e), attribute: 001, location: (#$b0, #$80)
    .byte $c0,$10,$82 ; ice grenade generator (enemy type #$10), attribute: 010, location: (#$c0, #$80)
    .byte $ff

level_5_enemy_screen_12:
    .byte $00,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$00, #$b0)
    .byte $40,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$40, #$b0)
    .byte $80,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$80, #$b0)
    .byte $c0,$13,$b0 ; ice pipe (enemy type #$13), attribute: 000, location: (#$c0, #$b0)
    .byte $ff

level_5_enemy_screen_13:
    .byte $ff

level_5_enemy_screen_14:
    .byte $01,$14,$30 ; alien carrier/boss ufo (enemy type #$14), attribute: 000, location: (#$01, #$30)

level_5_enemy_screen_15:
    .byte $ff

level_6_enemy_screen_ptr_tbl:
    .addr level_6_enemy_screen_00
    .addr level_6_enemy_screen_01
    .addr level_6_enemy_screen_02
    .addr level_6_enemy_screen_03
    .addr level_6_enemy_screen_04
    .addr level_6_enemy_screen_05
    .addr level_6_enemy_screen_06
    .addr level_6_enemy_screen_07
    .addr level_6_enemy_screen_08
    .addr level_6_enemy_screen_09
    .addr level_6_enemy_screen_0a
    .addr level_6_enemy_screen_0b
    .addr level_6_enemy_screen_0c

level_6_enemy_screen_00:
    .byte $40,$05,$84 ; soldier (enemy type #$05), attribute: 100, location: (#$40, #$80)
    .byte $60,$05,$68 ; soldier (enemy type #$05), attribute: 000, location: (#$60, #$68)
    .byte $c0,$02,$a1 ; pill box sensor (enemy type #$02), attribute: 001 (M), location: (#$c0, #$a0)
    .byte $e0,$06,$60 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$e0, #$60)
    .byte $ff

level_6_enemy_screen_01:
    .byte $80,$0e,$61 ; turret man (enemy type #$0e), attribute: 001, location: (#$80, #$60)
    .byte $e0,$0e,$61 ; turret man (enemy type #$0e), attribute: 001, location: (#$e0, #$60)
    .byte $f0,$0e,$c1 ; turret man (enemy type #$0e), attribute: 001, location: (#$f0, #$c0)
    .byte $ff

level_6_enemy_screen_02:
    .byte $a0,$0e,$c1 ; turret man (enemy type #$0e), attribute: 001, location: (#$a0, #$c0)
    .byte $a0,$06,$90 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$a0, #$90)
    .byte $ff

level_6_enemy_screen_03:
    .byte $40,$02,$ac ; pill box sensor (enemy type #$02), attribute: 100 (L), location: (#$40, #$a8)
    .byte $48,$10,$26 ; fire beam down (enemy type #$10), attribute: 110, location: (#$48, #$20)
    .byte $c8,$10,$25 ; fire beam down (enemy type #$10), attribute: 101, location: (#$c8, #$20)
    .byte $e0,$0e,$91 ; turret man (enemy type #$0e), attribute: 001, location: (#$e0, #$90)
    .byte $f0,$0e,$c1 ; turret man (enemy type #$0e), attribute: 001, location: (#$f0, #$c0)
    .byte $ff

level_6_enemy_screen_04:
    .byte $28,$10,$27         ; fire bean down (enemy type #$10), attribute: 111, location: (#$28, #$20)
    .byte $b8,$91,$58,$84,$b2 ; fire bean left (enemy type #$11), attribute: 000, location: (#$b8, #$58)
                              ; repeat: 2 [(y = #$80, attr = 100), (y = #$b0, attr = 010)]
    .byte $ff

level_6_enemy_screen_05:
    .byte $58,$51,$6c,$99 ; fire bean left (enemy type #$11), attribute: 100, location: (#$58, #$68), repeat: 1 [(y = #$98, attr = 001)]
    .byte $a8,$10,$26     ; fire bean down (enemy type #$10), attribute: 110, location: (#$a8, #$20)
    .byte $a0,$02,$ad     ; pill box sensor (enemy type #$02), attribute: 101 (B), location: (#$a0, #$a8)
    .byte $c8,$06,$30     ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$c8, #$30)
    .byte $f8,$11,$c2     ; fire bean left (enemy type #$11), attribute: 010, location: (#$f8, #$c0)
    .byte $ff

level_6_enemy_screen_06:
    .byte $58,$51,$39,$64 ; fire bean left (enemy type #$11), attribute: 001, location: (#$58, #$38), repeat: 1 [(y = #$60, attr = 100)]
    .byte $a8,$12,$6e     ; fire bean right (enemy type #$12), attribute: 110, location: (#$a8, #$68)
    .byte $ff

level_6_enemy_screen_07:
    .byte $40,$0e,$61 ; turret man (enemy type #$0e), attribute: 001, location: (#$40, #$60)
    .byte $48,$12,$99 ; fire bean right (enemy type #$12), attribute: 001, location: (#$48, #$98)
    .byte $68,$10,$25 ; fire bean down (enemy type #$10), attribute: 101, location: (#$68, #$20)
    .byte $a8,$12,$c0 ; fire bean right (enemy type #$12), attribute: 000, location: (#$a8, #$c0)
    .byte $e8,$10,$27 ; fire bean down (enemy type #$10), attribute: 111, location: (#$e8, #$20)
    .byte $ff

level_6_enemy_screen_08:
    .byte $60,$4e,$91,$c1 ; turret man (enemy type #$0e), attribute: 001, location: (#$60, #$90), repeat: 1 [(y = #$c0, attr = 001)]
    .byte $68,$52,$6a,$ca ; fire bean right (enemy type #$12), attribute: 010, location: (#$68, #$68), repeat: 1 [(y = #$c8, attr = 010)]
    .byte $e8,$12,$64     ; fire bean right (enemy type #$12), attribute: 100, location: (#$e8, #$60)
    .byte $f0,$0e,$91     ; turret man (enemy type #$0e), attribute: 001, location: (#$f0, #$90)
    .byte $ff

level_6_enemy_screen_09:
    .byte $68,$10,$23 ; fire bean down (enemy type #$10), attribute: 011, location: (#$68, #$20)
    .byte $ff

level_6_enemy_screen_0a:
    .byte $ff

level_6_enemy_screen_0b:
    .byte $b1,$13,$a0 ; giant boss soldier (enemy type #$13), attribute: 000, location: (#$b1, #$a0)
    .byte $ff

level_6_enemy_screen_0c:
    .byte $ff

; pointer table for level 7 enemy data (#$f * #$2 = #$1e bytes)
; enemy format
; xx tt yy
; xx = x position
; xxxxxxxx x position
;
; tt = enemy type + repeat
; xx...... repeat
; ..xxxxxx enemy type
;
; yy = y position + attributes
; xxxxx... y position
; .....xxx attributes
level_7_enemy_screen_ptr_tbl:
    .addr level_7_enemy_screen_00 ; CPU address $bbd5
    .addr level_7_enemy_screen_01 ; CPU address $bbed
    .addr level_7_enemy_screen_02 ; CPU address $bbfd
    .addr level_7_enemy_screen_03 ; CPU address $bc0d
    .addr level_7_enemy_screen_04 ; CPU address $bc17
    .addr level_7_enemy_screen_05 ; CPU address $bc36
    .addr level_7_enemy_screen_06 ; CPU address $bc40
    .addr level_7_enemy_screen_07 ; CPU address $bc44
    .addr level_7_enemy_screen_08 ; CPU address $bc4b
    .addr level_7_enemy_screen_09 ; CPU address $bc67
    .addr level_7_enemy_screen_0a ; CPU address $bc77
    .addr level_7_enemy_screen_0b ; CPU address $bc81
    .addr level_7_enemy_screen_0c ; CPU address $bc91
    .addr level_7_enemy_screen_0d ; CPU address $bc9b
    .addr level_7_enemy_screen_0e ; CPU address $bca8

level_7_enemy_screen_00:
    .byte $47,$10,$a1 ; mechanical claw (lower level)
    .byte $67,$10,$a5 ; mechanical claw (lower level)
    .byte $87,$10,$a9 ; mechanical claw (lower level)
    .byte $97,$10,$40 ; mechanical claw (top level)
    .byte $a7,$50,$44 ; mechanical claw (top level)
    .byte $ad,$b7,$10 ; mechanical claw (repeat once)
    .byte $48         ; repeated mechanical claw top
    .byte $c7,$50,$4c ; mechanical claw (repeat once)
    .byte $a1         ; repeated mechanical claw (bottom)
    .byte $ff

level_7_enemy_screen_01:
    .byte $00,$03,$a2 ; flying capsule
    .byte $80,$15,$c0 ; mining cart (stationary)
    .byte $97,$10,$42 ; mechanical claw
    .byte $a7,$10,$46 ; mechanical claw
    .byte $f7,$10,$ac ; mechanical claw
    .byte $ff

level_7_enemy_screen_02:
    .byte $07,$10,$a8 ; mechanical claw
    .byte $18,$0e,$60 ; turret man
    .byte $64,$11,$b0 ; spiked wall
    .byte $84,$11,$b1 ; spiked wall
    .byte $90,$03,$b0 ; flying capsule
    .byte $ff

level_7_enemy_screen_03:
    .byte $04,$12,$92 ; tall spiked wall
    .byte $44,$12,$92 ; tall spiked wall
    .byte $84,$12,$92 ; tall spiked wall
    .byte $ff

level_7_enemy_screen_04:
    .byte $04,$11,$72     ; rising spiked wall (enemy type #$11), attribute: 010, location: (#$04, #$70)
    .byte $07,$10,$ad     ; mechanical claw (enemy type #$10), attribute: 101, location: (#$07, #$a8)
    .byte $27,$50,$48,$a9 ; mechanical claw (enemy type #$10), attribute: 000, location: (#$27, #$48), repeat: 1 [(y = #$a8, attr = 001)]
    .byte $47,$50,$44,$a5 ; mechanical claw (enemy type #$10), attribute: 100, location: (#$47, #$40), repeat: 1 [(y = #$a0, attr = 101)]
    .byte $67,$50,$40,$a1 ; mechanical claw (enemy type #$10), attribute: 000, location: (#$67, #$40), repeat: 1 [(y = #$a0, attr = 001)]
    .byte $70,$13,$40     ; mining cart generator (enemy type #$13), attribute: 000, location: (#$70, #$40)
    .byte $84,$11,$73     ; rising spiked wall (enemy type #$11), attribute: 011, location: (#$84, #$70)
    .byte $87,$10,$ad     ; mechanical claw (enemy type #$10), attribute: 101, location: (#$87, #$a8)
    .byte $a0,$15,$c0     ; stationary mining cart (enemy type #$15), attribute: 000, location: (#$a0, #$c0)
    .byte $ff

level_7_enemy_screen_05:
    .byte $20,$02,$65 ; pill box sensor (enemy type #$02), attribute: 101 (B), location: (#$20, #$60)
    .byte $c7,$10,$4a ; mechanical claw (enemy type #$10), attribute: 010, location: (#$c7, #$48)
    .byte $e7,$10,$42 ; mechanical claw (enemy type #$10), attribute: 010, location: (#$e7, #$40)
    .byte $ff

level_7_enemy_screen_06:
    .byte $30,$15,$c0 ; stationary mining cart (enemy type #$15), attribute: 000, location: (#$30, #$c0)
    .byte $ff

level_7_enemy_screen_07:
    .byte $10,$13,$40 ; mining cart generator (enemy type #$13), attribute: 000, location: (#$10, #$40)
    .byte $f0,$06,$60 ; sniper (enemy type #$06), attribute: 000 (stand shoot bullets 3 at a time), location: (#$f0, #$60)
    .byte $ff

level_7_enemy_screen_08:
    .byte $00,$03,$31 ; flying capsule (enemy type #$03), attribute: 001 (M), location: (#$00, #$30)
    .byte $58,$15,$c0 ; stationary mining cart (enemy type #$15), attribute: 000, location: (#$58, #$c0)
    .byte $80,$03,$c3 ; flying capsule (enemy type #$03), attribute: 011 (S), location: (#$80, #$c0)
    .byte $84,$12,$70 ; tall spiked wall (enemy type #$12), attribute: 000, location: (#$84, #$70)
    .byte $87,$10,$ab ; mechanical claw (enemy type #$10), attribute: 011, location: (#$87, #$a8)
    .byte $a7,$10,$ab ; mechanical claw (enemy type #$10), attribute: 011, location: (#$a7, #$a8)
    .byte $c4,$12,$70 ; tall spiked wall (enemy type #$12), attribute: 000, location: (#$c4, #$70)
    .byte $c7,$10,$a7 ; mechanical claw (enemy type #$10), attribute: 111, location: (#$c7, #$a0)
    .byte $e7,$10,$a7 ; mechanical claw (enemy type #$10), attribute: 111, location: (#$e7, #$a0)
    .byte $ff

level_7_enemy_screen_09:
    .byte $04,$12,$70 ; tall spiked wall (enemy type #$12), attribute: 000, location: (#$04, #$70)
    .byte $07,$10,$a3 ; mechanical claw (enemy type #$10), attribute: 011, location: (#$07, #$a0)
    .byte $a4,$11,$93 ; rising spiked wall (enemy type #$11), attribute: 011, location: (#$a4, #$90)
    .byte $c4,$11,$97 ; rising spiked wall (enemy type #$11), attribute: 111, location: (#$c4, #$90)
    .byte $e4,$11,$9b ; rising spiked wall (enemy type #$11), attribute: 011, location: (#$e4, #$98)
    .byte $ff

level_7_enemy_screen_0a:
    .byte $d7,$10,$86 ; mechanical claw (enemy type #$10), attribute: 110, location: (#$d7, #$80)
    .byte $e7,$10,$8e ; mechanical claw (enemy type #$10), attribute: 110, location: (#$e7, #$88)
    .byte $f7,$10,$86 ; mechanical claw (enemy type #$10), attribute: 110, location: (#$f7, #$80)
    .byte $ff

level_7_enemy_screen_0b:
    .byte $07,$10,$8e ; mechanical claw (enemy type #$10), attribute: 110, location: (#$07, #$88)
    .byte $17,$10,$86 ; mechanical claw (enemy type #$10), attribute: 110, location: (#$17, #$80)
    .byte $27,$10,$8e ; mechanical claw (enemy type #$10), attribute: 110, location: (#$27, #$88)
    .byte $44,$11,$df ; rising spiked wall (enemy type #$11), attribute: 111, location: (#$44, #$d8)
    .byte $f0,$0e,$c0 ; turret man (enemy type #$0e), attribute: 000, location: (#$f0, #$c0)
    .byte $ff

level_7_enemy_screen_0c:
    .byte $20,$0e,$c0 ; turret man (enemy type #$0e), attribute: 000, location: (#$20, #$c0)
    .byte $a8,$0e,$a0 ; turret man (enemy type #$0e), attribute: 000, location: (#$a8, #$a0)
    .byte $fe,$0e,$a0 ; turret man (enemy type #$0e), attribute: 000, location: (#$fe, #$a0)
    .byte $ff

level_7_enemy_screen_0d:
    .byte $69,$17,$d1 ; mortar launcher (enemy type #$17), attribute: 001, location: (#$69, #$d0)
    .byte $a9,$17,$d0 ; mortar launcher (enemy type #$17), attribute: 000, location: (#$a9, #$d0)
    .byte $d9,$16,$80 ; armored door (enemy type #$16), attribute: 000, location: (#$d9, #$80)
    .byte $e1,$18,$a0 ; soldier generator (enemy type #$18), attribute: 000, location: (#$e1, #$a0)
    .byte $ff

level_7_enemy_screen_0e:
    .byte $ff

; pointer table for level 8 enemy groups (#$b * #$2 = #$16 bytes)
level_8_enemy_screen_ptr_tbl:
    .addr level_8_enemy_screen_00 ; CPU address $bcc0
    .addr level_8_enemy_screen_01 ; CPU address $bcc8
    .addr level_8_enemy_screen_02 ; CPU address $bcd5
    .addr level_8_enemy_screen_03 ; CPU address $bcdc
    .addr level_8_enemy_screen_04 ; CPU address $bcec
    .addr level_8_enemy_screen_05 ; CPU address $bcf3
    .addr level_8_enemy_screen_06 ; CPU address $bcfd
    .addr level_8_enemy_screen_07 ; CPU address $bd07
    .addr level_8_enemy_screen_08 ; CPU address $bd11
    .addr level_8_enemy_screen_09 ; CPU address $bd21
    .addr level_8_enemy_screen_0a ; CPU address $bd3c

level_8_enemy_screen_ptr_tbl_end:
    .byte $ff ; unused byte

level_8_enemy_screen_00:
    .byte $40,$43,$31,$c5 ; flying capsule (enemy type #$03), attribute: 001 (M), location: (#$40, #$30), repeat: 1 [(y = #$c0, attr = 101)]
    .byte $f0,$11,$a1     ; alien fetus (enemy type #$11), attribute: 001, location: (#$f0, #$a0)
    .byte $ff

level_8_enemy_screen_01:
    .byte $60,$11,$51 ; alien fetus (enemy type #$11), attribute: 001, location: (#$60, #$50)
    .byte $a0,$11,$61 ; alien fetus (enemy type #$11), attribute: 001, location: (#$a0, #$60)
    .byte $a8,$11,$61 ; alien fetus (enemy type #$11), attribute: 001, location: (#$a8, #$60)
    .byte $b0,$10,$60 ; alien guardian (enemy type #$10), attribute: 000, location: (#$b0, #$60)
    .byte $ff

level_8_enemy_screen_02:
    .byte $be,$12,$40 ; alien mouth (enemy type #$12), attribute: 000, location: (#$be, #$40)
    .byte $de,$12,$40 ; alien mouth (enemy type #$12), attribute: 000, location: (#$de, #$40)
    .byte $ff

level_8_enemy_screen_03:
    .byte $1e,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$1e, #$60)
    .byte $3e,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$3e, #$60)
    .byte $de,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$de, #$60)
    .byte $e0,$03,$c3 ; flying capsule (enemy type #$03), attribute: 011 (S), location: (#$e0, #$c0)
    .byte $fe,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$fe, #$60)
    .byte $ff

level_8_enemy_screen_04:
    .byte $de,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$de, #$e0)
    .byte $fe,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$fe, #$e0)
    .byte $ff

level_8_enemy_screen_05:
    .byte $1e,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$1e, #$e0)
    .byte $de,$12,$80 ; alien mouth (enemy type #$12), attribute: 000, location: (#$de, #$80)
    .byte $fe,$12,$80 ; alien mouth (enemy type #$12), attribute: 000, location: (#$fe, #$80)
    .byte $ff

level_8_enemy_screen_06:
    .byte $7e,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$7e, #$e0)
    .byte $9e,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$9e, #$e0)
    .byte $fe,$12,$80 ; alien mouth (enemy type #$12), attribute: 000, location: (#$fe, #$80)
    .byte $ff

level_8_enemy_screen_07:
    .byte $1e,$12,$80 ; alien mouth (enemy type #$12), attribute: 000, location: (#$1e, #$80)
    .byte $be,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$be, #$e0)
    .byte $de,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$de, #$e0)
    .byte $ff

level_8_enemy_screen_08:
    .byte $3e,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$3e, #$60)
    .byte $5e,$12,$60 ; alien mouth (enemy type #$12), attribute: 000, location: (#$5e, #$60)
    .byte $a0,$14,$c8 ; alien spider (enemy type #$14), attribute: 000, location: (#$a0, #$c8)
    .byte $c0,$14,$c8 ; alien spider (enemy type #$14), attribute: 000, location: (#$c0, #$c8)
    .byte $f0,$14,$c8 ; alien spider (enemy type #$14), attribute: 000, location: (#$f0, #$c8)
    .byte $ff

level_8_enemy_screen_09:
    .byte $30,$14,$c8 ; alien spider (enemy type #$14), attribute: 000, location: (#$30, #$c8)
    .byte $3e,$12,$e0 ; alien mouth (enemy type #$12), attribute: 000, location: (#$3e, #$e0)
    .byte $70,$14,$20 ; alien spider (enemy type #$14), attribute: 000, location: (#$70, #$20)
    .byte $b8,$14,$c8 ; alien spider (enemy type #$14), attribute: 000, location: (#$b8, #$c8)
    .byte $c0,$15,$40 ; spider spawn (enemy type #$15), attribute: 000, location: (#$c0, #$40)
    .byte $c2,$15,$c0 ; spider spawn (enemy type #$15), attribute: 000, location: (#$c2, #$c0)
    .byte $d1,$16,$70 ; alien heart (enemy type #$16), attribute: 000, location: (#$d1, #$70)
    .byte $e0,$15,$40 ; spider spawn (enemy type #$15), attribute: 000, location: (#$e0, #$40)
    .byte $e2,$15,$c0 ; spider spawn (enemy type #$15), attribute: 000, location: (#$e2, #$c0)

; unused #$2c4 bytes out of #$4,000 bytes total (95.68% full)
; unused 708 bytes out of 16,384 bytes total (95.68% full)
; filled with 708 #$ff bytes by contra.cfg configuration
level_8_enemy_screen_0a:
bank_2_unused_space: