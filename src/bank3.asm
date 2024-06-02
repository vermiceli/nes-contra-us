; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 3 starts with the data that specifies which pattern table tiles comprises
; super-tiles along with the color palettes.  This bank also has the routines
; to manage the end of levels.

.segment "BANK_3"

.include "constants.asm"

; import labels from bank 7
.import run_routine_from_tbl_below, set_graphics_zero_mode, set_a_as_current_level_routine

; export labels used by bank 2
.export level_4_supertile_data, level_6_supertile_data
.export level_7_supertile_data

; export labels used by bank 7
.export level_1_nametable_update_supertile_data, level_1_nametable_update_palette_data
.export level_2_nametable_update_supertile_data, level_2_nametable_update_palette_data
.export level_3_nametable_update_supertile_data, level_3_nametable_update_palette_data
.export level_4_nametable_update_supertile_data, level_4_nametable_update_palette_data
.export level_5_nametable_update_supertile_data, level_5_nametable_update_palette_data
.export level_6_nametable_update_supertile_data, level_6_nametable_update_palette_data
.export level_7_nametable_update_supertile_data, level_7_nametable_update_palette_data
.export level_8_nametable_update_supertile_data, level_8_nametable_update_palette_data
.export level_2_4_nametable_update_supertile_data, level_2_4_boss_nametable_update_palette_data
.export level_2_4_boss_palette_data, run_end_level_sequence_routine
.export level_2_4_boss_supertile_data, level_2_4_tile_animation
.export level_6_tile_animation, level_7_tile_animation

; export labels used by bank 2 and bank 7
.export level_1_supertile_data, level_2_supertile_data
.export level_3_supertile_data, level_5_supertile_data
.export level_8_supertile_data

.export level_1_palette_data, level_2_palette_data
.export level_3_palette_data, level_4_palette_data
.export level_5_palette_data, level_6_palette_data
.export level_7_palette_data, level_8_palette_data

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $03 ; The PRG ROM bank number (3)

; level 1 super-tiles (#$3b * #$10 = #$3b0 bytes)
; background nametable data for level 1
; #$10 bytes per super-tile
; each entry is a pattern table tile
; CPU address $8001
level_1_supertile_data:
    .byte $02,$03,$04,$05,$12,$13,$14,$15,$58,$59,$5a,$5b,$1c,$1d,$1e,$1f
    .byte $4c,$4d,$c4,$b5,$4c,$4d,$c4,$b3,$4c,$4d,$d4,$c6,$4c,$4d,$d5,$d6
    .byte $00,$00,$00,$00,$c7,$c8,$c8,$c8,$d7,$e7,$d8,$e7,$d7,$e7,$e8,$e7
    .byte $01,$01,$01,$01,$bf,$f1,$f8,$bf,$16,$17,$c0,$33,$f6,$f7,$bd,$be
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$02,$03,$04,$05,$12,$13,$14,$15
    .byte $c3,$c4,$b8,$c9,$d3,$d4,$b8,$c9,$e3,$e4,$e5,$c9,$b7,$ae,$af,$c9
    .byte $d7,$e7,$e8,$e7,$d7,$e7,$e8,$e7,$d7,$e7,$e8,$e7,$d7,$e7,$e8,$e7
    .byte $48,$49,$4a,$4b,$18,$19,$1a,$1b,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$ca,$eb,$ec,$ed,$ef,$c3,$c3,$c3
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$ea,$eb,$ec,$ed,$c3,$c3,$c3,$c3
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$ea,$eb,$ec,$c9,$c3,$c3,$c3,$d8
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$ca,$eb,$ec,$c9,$ef,$c3,$c3,$d8
    .byte $c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $c3,$c3,$c3,$cd,$c3,$c3,$c3,$d8,$c3,$c3,$c3,$e9,$c3,$c3,$c3,$c3
    .byte $ce,$c3,$c3,$c3,$ef,$c3,$c3,$c3,$ee,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$cd,$c3,$c3,$c3,$d8
    .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $fe,$fe,$fe,$ff,$fe,$fe,$fe,$fe,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $f9,$fa,$fb,$fc,$fe,$fe,$fe,$fe,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $fd,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $fd,$fe,$fe,$ff,$fe,$fe,$fe,$fe,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3
    .byte $02,$03,$c7,$c8,$12,$13,$d7,$e7,$58,$59,$d7,$e7,$1c,$1d,$d7,$e7
    .byte $f9,$fa,$fb,$fc,$ce,$fe,$fe,$fe,$fd,$fe,$fe,$fe,$fe,$fe,$fe,$fe
    .byte $f9,$fa,$fb,$fc,$fe,$fe,$fe,$cd,$fe,$fe,$fe,$ff,$fe,$fe,$fe,$fe
    .byte $02,$03,$04,$05,$12,$13,$14,$15,$ed,$c9,$5a,$5b,$c3,$d8,$1e,$1f
    .byte $36,$00,$00,$00,$34,$35,$ff,$ba,$3a,$34,$b4,$b5,$5c,$5d,$c4,$b5
    .byte $00,$da,$a8,$a9,$ca,$c4,$b8,$b9,$b6,$c4,$b8,$c9,$b6,$c4,$b8,$c9
    .byte $00,$00,$00,$00,$c8,$c8,$c8,$c8,$d8,$e7,$d8,$e7,$e8,$e7,$e8,$e7
    .byte $06,$34,$35,$34,$37,$38,$39,$38,$3b,$3c,$3d,$3d,$5e,$5f,$32,$5f
    .byte $35,$34,$35,$34,$39,$38,$39,$3a,$3d,$3c,$3d,$3b,$32,$32,$5f,$32
    .byte $35,$34,$35,$36,$39,$38,$39,$3a,$3d,$3c,$3d,$3e,$32,$5f,$5e,$5f
    .byte $c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$ce,$c3,$c3,$c3,$ef,$c3,$c3,$c3
    .byte $00,$00,$00,$4f,$00,$4f,$00,$00,$4f,$00,$00,$00,$00,$00,$00,$4f
    .byte $00,$00,$00,$00,$00,$4f,$00,$4f,$4f,$00,$4f,$00,$00,$00,$00,$4f ; first super-tile of level 1 (stars in sky)
    .byte $4f,$00,$00,$00,$00,$00,$4f,$00,$00,$00,$00,$00,$10,$00,$c6,$c7
    .byte $4f,$00,$00,$00,$00,$4f,$00,$00,$00,$00,$cb,$cc,$d9,$da,$db,$dc
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$44,$45,$46,$47,$54,$55,$56,$57
    .byte $36,$00,$00,$00,$57,$36,$00,$00,$45,$57,$3a,$00,$55,$55,$57,$36
    .byte $e0,$00,$d6,$d7,$f0,$e5,$e6,$e7,$e1,$e2,$e3,$e4,$00,$00,$f2,$00
    .byte $f4,$dd,$de,$df,$e8,$c8,$e2,$cf,$f3,$00,$f2,$f3,$00,$00,$00,$00
    .byte $4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d
    .byte $01,$01,$01,$01,$bf,$f1,$f8,$bf,$c0,$33,$c0,$33,$bd,$be,$bd,$be
    .byte $00,$00,$00,$00,$00,$00,$4f,$00,$00,$00,$00,$00,$10,$00,$00,$4f
    .byte $00,$4f,$00,$00,$00,$00,$4f,$00,$4f,$00,$00,$00,$00,$00,$c6,$c7
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$44,$45,$46,$47,$5c,$5d,$3f,$4d
    .byte $11,$41,$42,$43,$06,$51,$52,$53,$07,$45,$46,$47,$5c,$5d,$3f,$4d
    .byte $e0,$00,$00,$00,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$d6,$d7,$00,$e5,$e6,$e7,$e1,$e2,$e3,$e4,$00,$00,$00,$00
    .byte $4c,$4d,$ab,$ac,$4c,$4d,$bb,$bc,$4c,$4d,$bb,$b0,$4c,$4d,$bb,$c0
    .byte $ac,$ac,$ad,$b9,$bc,$bc,$bd,$d9,$b1,$b2,$bd,$aa,$c1,$c2,$bd,$b9
    .byte $e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7
    .byte $c7,$c8,$c8,$c8,$d7,$e7,$d8,$e7,$d7,$e7,$e8,$e7,$d7,$e7,$e8,$e7
    .byte $4c,$4d,$bb,$d0,$4c,$4d,$bb,$e0,$4c,$4d,$bb,$bc,$5e,$5f,$e9,$ea
    .byte $d1,$d2,$bd,$d9,$e1,$e2,$bd,$aa,$bc,$bc,$bd,$b9,$eb,$ec,$bd,$d9
    .byte $c8,$c8,$c8,$c8,$d8,$e7,$d8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7
    .byte $01,$01,$01,$01,$bf,$f1,$f8,$bf,$c0,$33,$c0,$c1,$bd,$be,$d0,$d1
    .byte $3a,$41,$42,$43,$4c,$51,$52,$53,$4c,$37,$46,$47,$4c,$4d,$4e,$4d
    .byte $02,$03,$04,$05,$12,$13,$14,$15,$f9,$fa,$fb,$fc,$c3,$c3,$c3,$c3
    .byte $c8,$e7,$e8,$e7,$d8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7,$e8,$e7

; level 1 enemy super-tiles (#$2c * #$10 = #$2c0 bytes)
; rotating gun, pill box sensor, and gulcan (buried surfacing cannon) super-tiles
; #$10 tiles for each super-tile, each byte is an offset into pattern table
; background nametable data for enemies in level 1
level_1_nametable_update_supertile_data:
    .byte $20,$21,$21,$22,$26,$30,$31,$27,$26,$30,$31,$27,$23,$24,$24,$25 ; #$00 - pill box sensor closed
    .byte $20,$21,$21,$22,$26,$2c,$2d,$27,$26,$2e,$2f,$27,$23,$24,$24,$25 ; #$01 - pill box sensor partially open
    .byte $20,$21,$21,$22,$26,$28,$29,$27,$26,$2a,$2b,$27,$23,$24,$24,$25 ; #$02 - pill box sensor open
    .byte $20,$21,$21,$22,$26,$96,$97,$27,$26,$97,$96,$27,$23,$24,$24,$25 ; #$03 - rotating gun closed
    .byte $20,$21,$21,$22,$26,$94,$95,$27,$26,$95,$94,$27,$23,$24,$24,$25 ; #$04 - rotating gun opening
    .byte $20,$21,$21,$22,$8d,$8e,$8f,$27,$9d,$9e,$9f,$27,$23,$24,$24,$25 ; #$05 - rotating gun facing left
    .byte $20,$21,$21,$22,$8a,$8b,$8c,$27,$26,$9b,$9c,$27,$23,$24,$24,$25 ; #$06 - rotating gun facing left-up
    .byte $20,$82,$21,$22,$26,$92,$93,$27,$26,$a2,$a3,$27,$23,$24,$24,$25 ; #$07 - rotating gun facing left-up (closer to up)
    .byte $20,$66,$67,$22,$26,$76,$77,$27,$26,$86,$87,$27,$23,$24,$24,$25 ; #$08 - rotating gun facing up
    .byte $20,$21,$81,$22,$26,$90,$91,$27,$26,$a0,$a1,$27,$23,$24,$24,$25 ; #$09 - rotating gun facing up up right (closer to up)
    .byte $20,$21,$21,$22,$26,$68,$69,$6a,$26,$78,$79,$27,$23,$24,$24,$25 ; #$0a - rotating gun facing up right
    .byte $20,$21,$21,$22,$26,$6d,$6e,$6f,$26,$7d,$7e,$7f,$23,$24,$24,$25 ; #$0b - rotating gun facing right
    .byte $20,$21,$21,$22,$26,$88,$89,$27,$26,$98,$99,$9a,$23,$24,$24,$25 ; #$0c - rotating gun facing right down
    .byte $20,$21,$21,$22,$26,$62,$63,$27,$26,$72,$73,$27,$23,$24,$83,$25 ; #$0d - rotating gun facing right down down (closer to down)
    .byte $20,$21,$21,$22,$26,$64,$65,$27,$26,$74,$75,$27,$23,$84,$85,$25 ; #$0e - rotating gun facing down
    .byte $20,$21,$21,$22,$26,$60,$61,$27,$26,$70,$71,$27,$23,$80,$24,$25 ; #$0f - rotating gun facing down left
    .byte $20,$21,$21,$22,$26,$6b,$6c,$27,$7a,$7b,$7c,$27,$23,$24,$24,$25 ; #$10 - rotating gun facing down left left (closer to left)
    .byte $a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7,$b0,$b1,$b2,$b3,$ac,$ad,$ae,$af ; #$11 - red turret facing left
    .byte $bc,$a5,$a6,$a7,$a8,$a9,$b6,$b7,$b8,$b9,$b2,$b3,$ac,$ad,$ae,$af ; #$12 - red turret facing up left
    .byte $aa,$ab,$a6,$a7,$ba,$bb,$b6,$b7,$b8,$b9,$b2,$b3,$ac,$ad,$ae,$af ; #$13 - red turret facing up up left (almost straight up)
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7 ; #$14 - red turret 1/2 rising from ground rocky background
    .byte $4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7 ; #$15 - red turret 1/2 rising from ground metal background
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f ; #$16 - red turret and rotating gun rock background
    .byte $4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d,$4c,$4d,$4e,$4d,$5e,$5f,$32,$5f ; #$17 - red turret metal background, green grass
    .byte $00,$00,$00,$00,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7,$b0,$b1,$b2,$b3 ; #$18 - red turret 3/4 rising from ground black background
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$19 - blank super-tile, used for destroyed bridges
    .byte $c2,$00,$00,$c4,$d2,$00,$00,$d4,$00,$00,$00,$c5,$d3,$00,$00,$d5 ; #$1a - exploding bridge partially destroyed both ends still exist
    .byte $c2,$00,$00,$00,$d2,$00,$00,$00,$00,$00,$00,$00,$d3,$00,$00,$00 ; #$1b - exploding bridge partially destroyed left only
    .byte $00,$00,$00,$c4,$00,$00,$00,$d4,$00,$00,$00,$c5,$00,$00,$00,$d5 ; #$1c - exploding bridge partially destroyed right only
    .byte $00,$00,$00,$c4,$00,$00,$00,$d4,$00,$00,$00,$00,$00,$00,$00,$00 ; #$1d - exploding bridge partially destroyed right only (more destroyed)
    .byte $4c,$4d,$ab,$ac,$4c,$4d,$bb,$bc,$4c,$4d,$bb,$f4,$4c,$4d,$f3,$00
    .byte $ac,$ac,$ad,$b9,$bc,$bc,$bd,$d9,$f5,$f6,$f7,$f8,$00,$00,$00,$00
    .byte $c7,$c8,$c8,$c8,$d7,$e7,$d8,$e7,$f8,$f8,$f8,$f8,$00,$00,$00,$00
    .byte $c8,$c8,$c8,$c8,$d8,$e7,$d8,$e7,$f8,$f8,$f8,$f8,$00,$00,$00,$00
    .byte $4c,$4d,$fb,$00,$4c,$4d,$fa,$f2,$4c,$4d,$bb,$bc,$5e,$5f,$e9,$ea
    .byte $00,$00,$00,$00,$f9,$f9,$f9,$f9,$fc,$f2,$fd,$fe,$eb,$ec,$bd,$d9
    .byte $00,$00,$00,$00,$f9,$f9,$f9,$f9,$fe,$fe,$fe,$fe,$d7,$e7,$e8,$e7
    .byte $00,$00,$00,$00,$f9,$f9,$f9,$f9,$fe,$fe,$fe,$fe,$e8,$e7,$e8,$e7
    .byte $4c,$4d,$fb,$e6,$4c,$4d,$fb,$e6,$4c,$4d,$cb,$cc,$4c,$4d,$fb,$db ; jungle bg boss bomb turret frame #$00 (boss_bomb_turret_supertile_tbl)
    .byte $4c,$4d,$fb,$e6,$4c,$4d,$fb,$e6,$4c,$4d,$ed,$ee,$4c,$4d,$fb,$db ; jungle bg boss bomb turret frame #$01 (boss_bomb_turret_supertile_tbl)
    .byte $4c,$4d,$fb,$e6,$4c,$4d,$fb,$e6,$4c,$4d,$fb,$f0,$4c,$4d,$fb,$db ; jungle bg boss bomb turret destroy (boss_bomb_turret_supertile_tbl)
    .byte $b7,$be,$bf,$c9,$b7,$be,$bf,$d9,$b7,$cd,$ce,$cf,$dc,$dd,$de,$df ; wall bg boss bomb turret frame #$00 (boss_bomb_turret_supertile_tbl)
    .byte $b7,$be,$bf,$c9,$b7,$be,$bf,$d9,$b7,$cb,$ef,$cf,$dc,$dd,$de,$df ; wall bg boss bomb turret frame #$01 (boss_bomb_turret_supertile_tbl)
    .byte $b7,$be,$bf,$c9,$b7,$be,$bf,$d9,$b7,$be,$f1,$f2,$dc,$dd,$de,$df ; wall bg boss bomb turret destroy (boss_bomb_turret_supertile_tbl)

; palette data - level 1 (#$70 bytes)
; 1 byte per super-tile
; xx.. .... color for lower-right corner
; ..xx .... color for lower-left corner
; .... xx.. color for upper-right corner
; .... ..xx color for upper-left corner
level_1_palette_data:
    .byte $50,$cc,$ff,$aa,$05,$ff,$ff,$55,$f5,$f5,$f5,$f5,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$dc,$ff,$ff,$70,$cc,$ff,$ff,$00,$00,$00,$ff
    .byte $ff,$ff,$af,$ab,$00,$08,$aa,$aa,$00,$aa,$ee,$bf,$00,$00,$aa,$aa
    .byte $8c,$ef,$ff,$ff,$c8,$fe,$ff,$aa,$00,$f0,$ff

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_1_nametable_update_palette_data:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa,$aa,$a5,$a0,$55,$00,$aa,$aa,$aa,$aa,$aa,$aa,$cc,$ff
    .byte $ff,$ff,$cc,$ff,$ff,$ff,$cc,$cc,$cc,$ff,$ff,$ff,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa,$aa,$aa

; nametable animation pattern table tiles - level 2/4 (#$b * #$5 = #$37 bytes)
; byte 0 clear specifies to use the default of #$02 rows of #$02 pattern table tiles each row
; bytes 1 - 4 are the pattern table tiles to draw
; CPU address $86e1
level_2_4_tile_animation:
    .byte $00,$e2,$e3,$e4,$e5 ; #$80 core plating
    .byte $00,$e6,$e7,$e8,$e9 ; #$81 core plating - cracked
    .byte $00,$ea,$eb,$ec,$ed ; #$82 core plating - more cracks
    .byte $00,$de,$df,$e0,$e1 ; #$83 core - destroyed
    .byte $00,$ee,$ef,$f0,$f1 ; #$84 wall turret / core - closed
    .byte $00,$f2,$f3,$f4,$f5 ; #$85 wall turret / core - opening frame 1
    .byte $00,$f6,$f7,$f8,$f9 ; #$86 core - opening frame 2
    .byte $00,$ca,$cb,$cc,$cd ; #$87 core - open
    .byte $00,$fa,$fb,$53,$54 ; #$88 wall turret - opening frame 2
    .byte $00,$ce,$cf,$d0,$d1 ; #$89 wall turret - open
    .byte $00,$d2,$d3,$d4,$d5 ; #$8a big core

; super-tile data - level 2/4 (#$76 * #$10 = #$760 bytes)
level_2_supertile_data:
level_4_supertile_data:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; blank super-tile
    .byte $00,$00,$00,$00,$0a,$0a,$0a,$0a,$0b,$00,$68,$60,$69,$60,$7f,$01
    .byte $00,$00,$68,$61,$68,$60,$01,$62,$01,$01,$01,$62,$13,$14,$15,$16
    .byte $17,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $11,$18,$00,$00,$12,$01,$10,$18,$12,$01,$01,$01,$66,$65,$64,$63
    .byte $00,$00,$00,$00,$0a,$0a,$0a,$0a,$10,$18,$00,$0b,$01,$2f,$10,$19
    .byte $00,$00,$00,$3b,$0a,$0a,$0a,$3c,$0b,$0b,$0b,$3d,$0d,$0d,$0d,$3e
    .byte $8b,$00,$00,$00,$8c,$0a,$0a,$0a,$8d,$0b,$0b,$0b,$8e,$0d,$0d,$0d
    .byte $01,$01,$01,$67,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $66,$1d,$1e,$1f,$01,$2e,$01,$31,$01,$30,$01,$31,$01,$30,$01,$31
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $6f,$6e,$6d,$16,$81,$01,$7e,$01,$81,$01,$80,$01,$81,$01,$80,$01
    .byte $02,$02,$02,$02,$a2,$a7,$02,$02,$02,$a9,$02,$02,$02,$a9,$02,$02
    .byte $01,$30,$01,$31,$01,$30,$77,$70,$01,$72,$78,$35,$74,$73,$33,$02
    .byte $02,$02,$02,$02,$06,$06,$06,$06,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $81,$01,$80,$01,$20,$27,$80,$01,$85,$28,$22,$01,$02,$83,$23,$24
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$09,$09
    .byte $04,$04,$83,$01,$fd,$fd,$fd,$ff,$05,$05,$05,$05,$fd,$fd,$fd,$fd
    .byte $26,$27,$01,$01,$fc,$40,$90,$01,$84,$01,$89,$24,$fd,$40,$90,$62
    .byte $04,$04,$04,$04,$fd,$fd,$fd,$fd,$05,$05,$05,$05,$fd,$fd,$fd,$fd
    .byte $01,$01,$77,$76,$01,$40,$90,$fc,$74,$39,$01,$34,$12,$40,$90,$fd
    .byte $01,$33,$04,$04,$fe,$fd,$fd,$fd,$05,$05,$05,$05,$fd,$fd,$fd,$fd
    .byte $02,$02,$8a,$62,$02,$02,$02,$86,$02,$02,$02,$02,$09,$09,$09,$09
    .byte $12,$3a,$02,$02,$36,$02,$02,$02,$02,$02,$02,$02,$09,$09,$09,$09

level_2_nametable_update_supertile_data:
level_4_nametable_update_supertile_data:
    .byte $5a,$5b,$5b,$5b,$5d,$00,$00,$00,$5d,$00,$00,$00,$5d,$00,$00,$00 ; #$00 - top left back wall destroyed
    .byte $5b,$5b,$5b,$5c,$00,$00,$00,$5e,$00,$00,$00,$5e,$00,$00,$00,$5e ; #$01 - top right back wall destroyed
    .byte $5d,$00,$00,$00,$4b,$5f,$5f,$5f,$03,$03,$03,$03,$02,$02,$02,$02 ; #$02 - bottom left back wall destroyed
    .byte $00,$00,$00,$5e,$5f,$5f,$5f,$9b,$03,$03,$03,$03,$02,$02,$02,$02 ; #$03 - bottom right back wall destroyed
    .byte $0a,$0a,$0a,$0a,$00,$00,$00,$00,$1b,$18,$0c,$0c,$2f,$01,$10,$0e
    .byte $0a,$0a,$0a,$3b,$00,$00,$00,$3c,$0c,$0c,$0c,$3d,$0e,$0e,$0e,$3f
    .byte $8b,$0a,$0a,$0a,$8c,$00,$00,$00,$8d,$0c,$0c,$0c,$8f,$0e,$0e,$0e
    .byte $0a,$0a,$0a,$0a,$00,$00,$00,$00,$0c,$0c,$68,$6b,$0e,$60,$01,$7f
    .byte $1c,$65,$64,$4c,$2e,$01,$01,$4c,$30,$01,$01,$4c,$30,$01,$01,$4c
    .byte $59,$59,$59,$59,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $02,$02,$83,$62,$02,$02,$02,$86,$04,$04,$04,$04,$09,$09,$09,$09
    .byte $9c,$14,$15,$6c,$9c,$01,$01,$7e,$9c,$01,$01,$80,$9c,$01,$01,$80
    .byte $30,$01,$01,$4c,$30,$01,$77,$4c,$30,$79,$78,$4d,$7b,$7a,$34,$05
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$ac,$ac,$ac,$ac,$05,$05,$05,$05
    .byte $9c,$01,$01,$80,$9c,$27,$01,$80,$9d,$28,$29,$80,$05,$84,$2a,$2b
    .byte $01,$01,$77,$76,$01,$79,$78,$01,$74,$7a,$01,$33,$12,$01,$33,$02
    .byte $2f,$33,$02,$02,$33,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$04,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$83,$7f,$04,$04,$04,$83,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $26,$27,$01,$01,$01,$28,$29,$01,$83,$01,$2a,$24,$02,$83,$01,$62
    .byte $12,$33,$02,$02,$36,$02,$02,$02,$04,$04,$04,$04,$09,$09,$09,$09
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$04,$04,$04,$04,$09,$09,$09,$09
    .byte $11,$18,$00,$00,$12,$01,$1b,$18,$12,$01,$2f,$01,$66,$65,$1a,$63
    .byte $00,$00,$00,$00,$00,$0b,$0b,$0b,$10,$18,$00,$00,$01,$01,$02,$ae
    .byte $00,$00,$00,$3b,$0b,$0b,$0b,$3c,$00,$00,$00,$3d,$ad,$ae,$ad,$ae
    .byte $8b,$00,$00,$00,$8c,$0b,$0b,$0b,$8d,$00,$00,$00,$ad,$ae,$ad,$ae
    .byte $00,$00,$00,$00,$0b,$0b,$0b,$00,$00,$00,$68,$60,$ae,$02,$01,$01
    .byte $00,$00,$68,$61,$68,$6b,$01,$62,$01,$7f,$01,$62,$13,$6a,$15,$16
    .byte $01,$01,$2e,$67,$01,$01,$2e,$01,$01,$01,$30,$01,$01,$01,$30,$01
    .byte $66,$65,$4e,$00,$01,$01,$4f,$00,$01,$01,$4e,$00,$01,$01,$4f,$00
    .byte $00,$41,$00,$00,$00,$00,$43,$52,$00,$00,$45,$00,$00,$00,$44,$58
    .byte $00,$00,$91,$00,$52,$93,$00,$00,$00,$95,$00,$00,$58,$94,$00,$00
    .byte $00,$9e,$15,$16,$00,$9e,$01,$01,$00,$9f,$01,$01,$00,$9f,$01,$01
    .byte $17,$7e,$01,$01,$01,$7e,$01,$01,$01,$80,$01,$01,$01,$80,$01,$01
    .byte $01,$01,$30,$01,$01,$01,$30,$01,$01,$01,$30,$01,$01,$01,$30,$01
    .byte $01,$01,$4e,$00,$01,$01,$4f,$00,$01,$79,$4e,$00,$74,$7a,$02,$b1
    .byte $00,$42,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b0,$b1,$b0,$b2
    .byte $00,$00,$92,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b0,$b1,$b0,$b2
    .byte $00,$9e,$01,$01,$00,$9f,$01,$01,$00,$9e,$29,$01,$b1,$02,$2a,$24
    .byte $01,$80,$01,$01,$01,$80,$01,$01,$01,$80,$01,$01,$01,$80,$01,$01
    .byte $01,$01,$7d,$76,$01,$79,$7c,$01,$74,$7a,$2f,$34,$12,$01,$33,$02
    .byte $01,$33,$07,$07,$33,$02,$02,$02,$05,$05,$05,$05,$02,$02,$02,$02
    .byte $07,$07,$07,$07,$02,$02,$02,$02,$05,$05,$05,$05,$02,$02,$02,$02
    .byte $07,$07,$83,$01,$02,$02,$02,$83,$05,$05,$05,$05,$02,$02,$02,$02
    .byte $26,$2d,$01,$01,$01,$2c,$29,$01,$84,$7f,$2a,$24,$02,$83,$01,$62
    .byte $12,$33,$02,$02,$36,$02,$02,$02,$02,$02,$02,$02,$09,$09,$09,$09
    .byte $02,$02,$83,$62,$02,$02,$02,$86,$02,$02,$02,$02,$09,$09,$09,$09
    .byte $11,$18,$00,$00,$12,$01,$10,$37,$12,$01,$01,$38,$66,$65,$64,$38
    .byte $00,$00,$00,$3b,$0f,$0f,$0f,$3c,$b3,$b4,$b5,$b3,$00,$00,$00,$00
    .byte $8b,$00,$00,$00,$8c,$0f,$0f,$0f,$b3,$b4,$b5,$b3,$00,$00,$00,$00
    .byte $01,$01,$01,$38,$01,$01,$01,$38,$01,$01,$01,$38,$01,$01,$01,$38
    .byte $51,$00,$00,$00,$50,$00,$00,$00,$25,$00,$00,$00,$51,$00,$00,$00
    .byte $46,$47,$57,$57,$48,$49,$00,$00,$48,$49,$00,$00,$48,$49,$00,$00
    .byte $57,$57,$97,$96,$00,$00,$99,$98,$00,$00,$99,$98,$00,$00,$99,$98
    .byte $00,$00,$00,$a1,$00,$00,$00,$a0,$00,$00,$00,$75,$00,$00,$00,$a1
    .byte $88,$01,$01,$01,$88,$01,$01,$01,$88,$01,$01,$01,$88,$01,$01,$01
    .byte $48,$4a,$52,$52,$4a,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $52,$52,$9a,$98,$00,$00,$00,$9a,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $01,$01,$77,$38,$01,$79,$71,$38,$74,$7a,$01,$32,$12,$01,$33,$02
    .byte $51,$00,$00,$00,$02,$b7,$b8,$b6,$08,$08,$08,$08,$02,$02,$02,$02
    .byte $00,$00,$00,$00,$b8,$b6,$b7,$b8,$08,$08,$08,$08,$02,$02,$02,$02
    .byte $00,$00,$00,$a1,$b6,$b7,$b8,$02,$08,$08,$08,$08,$02,$02,$02,$02
    .byte $88,$27,$01,$01,$88,$21,$29,$01,$82,$01,$2a,$24,$02,$83,$01,$62
    .byte $00,$00,$00,$00,$0f,$0f,$0f,$0f,$02,$b3,$b3,$b4,$50,$00,$00,$00
    .byte $00,$00,$00,$00,$0f,$0f,$0f,$0f,$b4,$b5,$b5,$02,$00,$00,$00,$a0
    .byte $00,$00,$68,$61,$87,$60,$01,$62,$88,$01,$01,$62,$88,$14,$15,$16
    .byte $0a,$0a,$68,$61,$68,$60,$01,$62,$01,$01,$01,$62,$13,$14,$15,$16
    .byte $11,$18,$0a,$0a,$12,$01,$10,$18,$12,$01,$01,$01,$66,$65,$64,$63
    .byte $bf,$b9,$ba,$bb,$c0,$bc,$bd,$be,$bf,$c0,$c1,$c6,$c0,$ba,$bd,$c0
    .byte $c8,$bc,$bd,$be,$c8,$c0,$c1,$bb,$c9,$ba,$bd,$ba,$c8,$c0,$bf,$c0
    .byte $c4,$b9,$c5,$c4,$c0,$bc,$bd,$be,$bf,$c0,$c1,$c6,$c1,$ba,$bd,$c0
    .byte $bf,$b9,$ba,$c6,$c5,$bc,$bd,$c7,$bb,$c0,$c1,$c6,$c0,$ba,$bd,$c7
    .byte $bf,$b9,$ba,$bb,$c0,$bc,$bd,$be,$bf,$c0,$c1,$bb,$c3,$c2,$c3,$c2
    .byte $bf,$b9,$ba,$bb,$c0,$bc,$bd,$be,$bf,$c0,$c1,$bb,$c0,$ba,$bd,$c1
    .byte $bf,$b9,$ba,$bb,$c0,$bc,$bd,$be,$bf,$c0,$b9,$c1,$c9,$bf,$bc,$bb
    .byte $b9,$be,$c8,$c9,$bd,$00,$c2,$bd,$c6,$c7,$bf,$bd,$c8,$c9,$bf,$be
    .byte $bd,$be,$be,$bc,$bb,$be,$be,$bf,$c8,$c9,$c5,$c0,$c1,$c1,$c1,$c1
    .byte $c0,$bd,$bf,$b9,$c9,$bd,$bf,$bd,$c0,$bb,$be,$bc,$c1,$c1,$c1,$c1
    .byte $c7,$c0,$c0,$c4,$c5,$bd,$00,$c4,$c9,$c0,$c0,$c4,$00,$bb,$be,$c4
    .byte $be,$ba,$00,$c4,$c2,$bd,$c0,$c4,$bf,$bd,$c0,$c4,$bf,$bd,$00,$c4
    .byte $02,$02,$02,$02,$02,$02,$a6,$a2,$02,$02,$a8,$02,$02,$02,$a8,$02
    .byte $02,$02,$a8,$02,$06,$06,$aa,$06,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$d6,$02,$02,$da,$d2
    .byte $02,$02,$db,$d4,$06,$06,$06,$d8,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $d5,$dd,$02,$02,$d9,$06,$06,$06,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$d7,$02,$02,$02,$d3,$dc,$02,$02
    .byte $02,$a9,$02,$02,$06,$ab,$06,$06,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $06,$06,$aa,$06,$55,$a4,$56,$a3,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $06,$ab,$06,$06,$a4,$56,$a3,$a5,$03,$03,$03,$03,$02,$02,$02,$02
    .byte $c1,$c1,$c1,$c1,$b9,$be,$ba,$be,$c6,$c7,$bd,$c2,$c8,$c9,$bb,$bf
    .byte $c1,$c1,$c1,$c1,$be,$ba,$c5,$00,$c0,$bd,$c0,$c0,$be,$bb,$be,$be
    .byte $c3,$c6,$c7,$c0,$c3,$c8,$c9,$c5,$c3,$be,$be,$ba,$c3,$00,$c2,$bd
    .byte $c3,$c5,$bf,$bb,$c3,$be,$bf,$be,$c3,$00,$bf,$bf,$c3,$c0,$c0,$c0

; palette data - level 2/4 (#$76 bytes)
; 1 byte per block
; xx.. .... color for lower-right corner
; ..xx .... color for lower-left corner
; .... xx.. color for upper-right corner
; .... ..xx color for upper-left corner
level_2_palette_data:
level_4_palette_data:
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$ff,$55,$55,$55
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_2_nametable_update_palette_data:
level_4_nametable_update_palette_data:
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$55,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$5f,$ff,$5f,$5f,$ff,$5f,$5f,$5f,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00

; CPU address $8ef8
level_3_supertile_data:
    .byte $01,$02,$01,$02,$11,$12,$11,$12,$44,$45,$46,$47,$54,$55,$56,$57
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $00,$00,$7c,$7d,$00,$8b,$8c,$00,$8b,$9b,$9c,$00,$aa,$ab,$00,$8b
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$7c,$7d,$00,$00,$8c,$00,$00,$00
    .byte $01,$02,$01,$02,$11,$12,$11,$12,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f
    .byte $03,$04,$04,$04,$d1,$d2,$d2,$d2,$be,$3f,$3e,$3f,$d4,$5f,$5e,$5f
    .byte $04,$05,$05,$04,$d2,$32,$32,$d2,$3e,$3f,$3e,$3f,$5e,$5f,$5e,$5f
    .byte $04,$04,$04,$06,$d2,$d2,$d2,$33,$3e,$3f,$3e,$bd,$5e,$5f,$5f,$c3
    .byte $10,$00,$07,$38,$00,$00,$00,$00,$00,$00,$00,$3a,$39,$00,$00,$d5
    .byte $be,$35,$36,$37,$d4,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $34,$35,$36,$37,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $34,$35,$36,$bd,$5e,$5f,$5e,$c3,$4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3
    .byte $4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3,$4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3
    .byte $d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $ea,$eb,$aa,$ab,$ff,$98,$da,$d6,$fc,$70,$ea,$eb,$c6,$dc,$ff,$98
    .byte $d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $4a,$4b,$4c,$4d,$5a,$5b,$5c,$5d,$d0,$bf,$cc,$cd,$ca,$cb,$ce,$cf
    .byte $49,$4b,$4c,$4d,$59,$5b,$5c,$5d,$48,$bf,$cc,$cd,$58,$cb,$ce,$cf
    .byte $34,$35,$36,$37,$5e,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $40,$41,$42,$43,$3b,$51,$52,$53,$c4,$00,$3c,$47,$5e,$c5,$3d,$57
    .byte $d3,$4f,$4e,$c9,$d4,$5f,$5e,$c3,$4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3
    .byte $40,$41,$42,$43,$50,$51,$52,$c2,$44,$c1,$00,$c8,$54,$c0,$c7,$5f
    .byte $4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $3e,$3f,$3e,$3f,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3
    .byte $3e,$3f,$3e,$3f,$5e,$5f,$5e,$5f,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$15,$0c,$0d,$14,$00,$1c,$13,$00,$00
    .byte $08,$09,$0a,$0b,$00,$19,$1a,$1b,$00,$16,$17,$0f,$00,$00,$00,$1f
    .byte $08,$09,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $40,$41,$42,$43,$50,$51,$52,$c2,$01,$02,$01,$02,$11,$12,$11,$12
    .byte $e6,$e7,$e8,$e9,$f7,$f7,$f6,$d9,$f7,$f7,$fa,$fb,$62,$f7,$f7,$9f
    .byte $01,$02,$01,$02,$11,$12,$11,$12,$00,$16,$17,$0f,$00,$00,$00,$1f
    .byte $3e,$3f,$3e,$3f,$5e,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f,$d3,$4f,$4e,$c9,$d4,$5f,$5e,$c3
    .byte $4e,$4f,$c4,$c6,$5e,$5f,$5e,$c3,$4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3
    .byte $d3,$4f,$4e,$c9,$d4,$5f,$5e,$c3,$d3,$4f,$4e,$c9,$d4,$5f,$5e,$c3
    .byte $4e,$4f,$4e,$c9,$5e,$5f,$5e,$c3,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $40,$41,$42,$43,$50,$51,$52,$c2,$34,$35,$36,$37,$5e,$5f,$5e,$5f
    .byte $d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$be,$35,$36,$37,$d4,$5f,$5e,$5f
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$34,$35,$36,$bd,$5e,$5f,$5e,$c3
    .byte $4e,$4f,$c4,$c6,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $c4,$c6,$4e,$4f,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f
    .byte $c4,$c6,$4e,$4f,$d4,$5f,$5e,$5f,$d3,$4f,$4e,$4f,$d4,$5f,$5e,$5f
    .byte $08,$09,$dc,$c3,$18,$19,$dc,$c3,$0c,$0d,$dc,$c3,$1c,$1d,$dc,$c3
    .byte $b8,$f7,$f7,$62,$b8,$f7,$f7,$f7,$4c,$4d,$f7,$72,$fa,$70,$70,$82
    .byte $62,$f7,$f7,$9f,$f7,$f7,$f7,$9f,$79,$f7,$4e,$4f,$89,$70,$70,$f3
    .byte $c6,$dc,$0a,$0b,$c6,$dc,$1a,$1b,$c6,$dc,$0e,$0f,$c6,$dc,$1e,$1f
    .byte $f7,$dc,$dc,$92,$f7,$dc,$dc,$69,$f7,$dc,$dc,$f7,$f7,$dc,$dc,$f7
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$91,$9a,$00,$00,$50,$5a
    .byte $00,$f4,$f5,$51,$c8,$c5,$c5,$55,$51,$cd,$93,$6d,$52,$53,$54,$55
    .byte $49,$f8,$f9,$00,$56,$6e,$6e,$6f,$46,$47,$48,$49,$56,$57,$58,$59
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$4a,$4b,$00,$00,$5a,$5b,$00,$00
    .byte $00,$00,$00,$00,$60,$61,$00,$00,$00,$71,$80,$00,$00,$81,$90,$80
    .byte $f0,$63,$64,$65,$00,$f0,$74,$75,$00,$00,$84,$85,$00,$c8,$94,$95
    .byte $66,$67,$63,$98,$76,$77,$98,$00,$86,$87,$00,$00,$96,$97,$6f,$00
    .byte $00,$00,$00,$00,$00,$00,$7c,$7d,$00,$8b,$8c,$00,$8b,$9b,$9c,$00
    .byte $00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$00,$71,$00,$00,$00,$81
    .byte $73,$b0,$b1,$a1,$83,$c0,$c1,$db,$80,$00,$ea,$eb,$90,$80,$d5,$d1
    .byte $08,$09,$0a,$0b,$18,$19,$1a,$1b,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f
    .byte $08,$09,$fd,$fe,$18,$19,$1a,$1b,$0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f
    .byte $aa,$ba,$b0,$bb,$d0,$ca,$c0,$cb,$e0,$e1,$00,$8b,$da,$d6,$8b,$9b
    .byte $00,$00,$00,$00,$7c,$7d,$00,$00,$8c,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$00,$71
    .byte $60,$61,$00,$00,$00,$71,$80,$00,$00,$81,$90,$80,$80,$00,$a0,$a1
    .byte $a0,$a1,$e0,$e1,$d5,$d1,$f0,$5c,$e0,$e1,$70,$f1,$f0,$5c,$dc,$c3
    .byte $e2,$e3,$e4,$e5,$b3,$68,$f7,$f7,$f2,$f3,$f7,$f7,$b8,$f7,$f7,$62

level_3_nametable_update_supertile_data:
    .byte $20,$21,$21,$22,$26,$30,$31,$27,$26,$30,$31,$27,$23,$24,$24,$25 ; #$00 - pill box sensor closed
    .byte $20,$21,$21,$22,$26,$2c,$2d,$27,$26,$2e,$2f,$27,$23,$24,$24,$25 ; #$01 - pill box sensor partially open
    .byte $20,$21,$21,$22,$26,$28,$29,$27,$26,$2a,$2b,$27,$23,$24,$24,$25 ; #$02 - pill box sensor open
    .byte $20,$21,$21,$22,$26,$96,$97,$27,$26,$97,$96,$27,$23,$24,$24,$25 ; #$03 - rotating gun closed
    .byte $20,$21,$21,$22,$26,$94,$95,$27,$26,$95,$94,$27,$23,$24,$24,$25 ; #$04 - rotating gun opening
    .byte $20,$21,$21,$22,$8d,$8e,$8f,$27,$9d,$9e,$9f,$27,$23,$24,$24,$25 ; #$05 - rotating gun facing left
    .byte $20,$21,$21,$22,$8a,$8b,$8c,$27,$26,$9b,$9c,$27,$23,$24,$24,$25 ; #$06 - rotating gun facing left-up
    .byte $20,$82,$21,$22,$26,$92,$93,$27,$26,$a2,$a3,$27,$23,$24,$24,$25 ; #$07 - rotating gun facing left-up (closer to up)
    .byte $20,$66,$67,$22,$26,$76,$77,$27,$26,$86,$87,$27,$23,$24,$24,$25 ; #$08 - rotating gun facing up
    .byte $20,$21,$81,$22,$26,$90,$91,$27,$26,$a0,$a1,$27,$23,$24,$24,$25 ; #$09 - rotating gun facing up up right (closer to up)
    .byte $20,$21,$21,$22,$26,$68,$69,$6a,$26,$78,$79,$27,$23,$24,$24,$25 ; #$0a - rotating gun facing up right
    .byte $20,$21,$21,$22,$26,$6d,$6e,$6f,$26,$7d,$7e,$7f,$23,$24,$24,$25 ; #$0b - rotating gun facing right
    .byte $20,$21,$21,$22,$26,$88,$89,$27,$26,$98,$99,$9a,$23,$24,$24,$25 ; #$0c - rotating gun facing right down
    .byte $20,$21,$21,$22,$26,$62,$63,$27,$26,$72,$73,$27,$23,$24,$83,$25 ; #$0d - rotating gun facing right down down (closer to down)
    .byte $20,$21,$21,$22,$26,$64,$65,$27,$26,$74,$75,$27,$23,$84,$85,$25 ; #$0e - rotating gun facing down
    .byte $20,$21,$21,$22,$26,$60,$61,$27,$26,$70,$71,$27,$23,$80,$24,$25 ; #$0f - rotating gun facing down left
    .byte $20,$21,$21,$22,$26,$6b,$6c,$27,$7a,$7b,$7c,$27,$23,$24,$24,$25 ; #$10 - rotating gun facing down left left (closer to left)
    .byte $a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7,$b0,$b1,$b2,$b3,$ac,$ad,$ae,$af ; #$11 - red turret facing left
    .byte $bc,$a5,$a6,$a7,$a8,$a9,$b6,$b7,$b8,$b9,$b2,$b3,$ac,$ad,$ae,$af ; #$12 - red turret facing up left
    .byte $aa,$ab,$a6,$a7,$ba,$bb,$b6,$b7,$b8,$b9,$b2,$b3,$ac,$ad,$ae,$af ; #$13 - red turret facing up up left (almost straight up)
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7 ; #$14 - red turret 1/2 rising from ground rocky background
    .byte $4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7 ; #$15 - red turret 1/2 rising from ground waterfall background
    .byte $40,$41,$42,$43,$50,$51,$52,$53,$44,$45,$46,$47,$54,$55,$56,$57 ; #$16 - red turret and rotating gun rock background
    .byte $4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f,$4e,$4f,$4e,$4f,$5e,$5f,$5e,$5f ; #$17 - red turret waterfall background
    .byte $00,$00,$00,$00,$a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7,$b0,$b1,$b2,$b3 ; #$18 - red turret 3/4 rising from ground black background
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$19 - blank super-tile
    .byte $00,$00,$00,$00,$00,$00,$00,$be,$00,$00,$be,$dd,$00,$00,$ec,$ed
    .byte $be,$00,$00,$00,$ce,$00,$00,$00,$de,$df,$00,$00,$ee,$ef,$00,$00
    .byte $e2,$e3,$5d,$00,$b3,$8f,$5f,$00,$f2,$8f,$5d,$00,$b8,$af,$00,$00
    .byte $5d,$5e,$e8,$e9,$00,$8f,$5f,$d9,$00,$7f,$5f,$fb,$00,$00,$7f,$9f
    .byte $b8,$5d,$00,$00,$b8,$00,$00,$00,$4c,$5e,$00,$00,$fa,$70,$6c,$00
    .byte $00,$00,$5f,$9f,$00,$00,$00,$9f,$00,$00,$5d,$4f,$00,$00,$6c,$f3
    .byte $64,$65,$66,$67,$74,$75,$76,$77,$84,$85,$86,$87,$94,$95,$96,$97 ; #$20 - boss mouth closed (top half)
    .byte $a4,$a5,$a6,$a7,$b4,$b5,$b6,$b7,$c4,$b5,$b6,$c7,$d4,$a6,$a5,$d7 ; #$21 - boss mouth closed (bottom half)
    .byte $64,$6a,$6b,$67,$74,$7a,$7b,$77,$78,$00,$00,$7e,$88,$8a,$8d,$8e ; #$22 - boss mouth partially open (top half)
    .byte $9d,$9e,$ad,$ae,$b4,$b5,$b6,$b7,$c4,$b5,$b6,$c7,$d4,$a6,$a5,$d7 ; #$23 - boss mouth partially open (bottom half)
    .byte $64,$bc,$bd,$67,$74,$7a,$7b,$77,$78,$00,$00,$7e,$ac,$00,$00,$bf ; #$24 - boss mouth fully open (top half)
    .byte $88,$8a,$8d,$8e,$cc,$9e,$ad,$cf,$c4,$b5,$b6,$c7,$d4,$a6,$a5,$d7 ; #$25 - boss mouth fully open (bottom half)
    .byte $f7,$dc,$dc,$af,$f7,$dc,$dc,$69,$f7,$dc,$dc,$f7,$f7,$dc,$dc,$f7
    .byte $6c,$6c,$dc,$f7,$69,$dc,$dc,$f7,$f7,$dc,$dc,$f7,$f7,$dc,$dc,$f7
    .byte $99,$dc,$dc,$f7,$69,$dc,$dc,$f7,$f7,$dc,$dc,$f7,$f7,$dc,$dc,$f7
    .byte $a2,$a3,$a4,$a5,$b2,$a4,$b4,$b5,$c2,$b4,$c4,$b5,$d2,$d3,$d4,$a6
    .byte $a6,$a7,$a8,$a9,$b6,$b7,$a7,$b9,$b6,$c7,$b7,$c9,$a5,$d7,$d8,$d2

level_3_palette_data:
    .byte $50,$05,$aa,$20,$00,$00,$00,$fa,$fa,$fa,$55,$ff,$ff,$ff,$ff,$ff
    .byte $9a,$0f,$0f,$ff,$ff,$ff,$75,$ff,$d5,$0f,$ff,$ff,$ff,$0f,$00,$00
    .byte $00,$05,$55,$00,$ff,$ff,$ff,$ff,$ff,$f5,$ff,$f5,$f5,$ff,$ff,$ff
    .byte $55,$55,$55,$55,$55,$aa,$ba,$ea,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$55
    .byte $55,$aa,$aa,$aa,$aa,$6a,$55

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_3_nametable_update_palette_data:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa,$aa,$a5,$af,$55,$ff,$aa,$00,$88,$22,$55,$55,$51,$44
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$55,$55,$55,$aa,$aa,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00

; CPU address $9698
level_5_supertile_data:
    .byte $69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69
    .byte $02,$03,$03,$12,$0c,$0d,$0e,$0f,$42,$43,$44,$45,$46,$47,$48,$49
    .byte $05,$12,$04,$0b,$0c,$0d,$0e,$0f,$42,$43,$44,$45,$46,$47,$48,$49
    .byte $4a,$4b,$4c,$4d,$4e,$4f,$50,$51,$4d,$52,$4c,$4f,$49,$4d,$4e,$48
    .byte $48,$4c,$4e,$4f,$aa,$a9,$aa,$a9,$05,$12,$04,$0b,$0c,$0d,$0e,$0f
    .byte $69,$69,$69,$69,$69,$69,$69,$b6,$69,$bb,$5e,$b7,$5f,$bc,$60,$b8
    .byte $61,$be,$62,$b9,$bf,$b0,$b2,$b3,$61,$be,$62,$b9,$bf,$b0,$b2,$b3
    .byte $69,$b4,$67,$ac,$00,$ab,$67,$ac,$69,$ab,$67,$ac,$00,$ab,$00,$ac
    .byte $a9,$aa,$69,$b6,$69,$69,$69,$b7,$69,$bb,$5e,$b8,$5f,$bc,$60,$b9
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$02,$03,$03,$12,$0c,$0d,$0e,$0f
    .byte $42,$43,$4e,$5d,$46,$47,$50,$5b,$4a,$4b,$4a,$a8,$a9,$aa,$aa,$00
    .byte $4a,$4b,$4c,$4d,$a9,$aa,$a9,$aa,$02,$03,$03,$12,$0c,$0d,$0e,$0f
    .byte $58,$4b,$4c,$4d,$69,$a9,$a9,$aa,$05,$03,$03,$12,$0c,$0d,$0e,$0f
    .byte $42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$51
    .byte $69,$b4,$67,$ac,$69,$ab,$67,$ac,$05,$12,$04,$0b,$0c,$0d,$0e,$0f
    .byte $03,$57,$69,$69,$0e,$0f,$69,$69,$44,$59,$69,$69,$4c,$5a,$69,$69
    .byte $f5,$5d,$69,$b6,$50,$5b,$bb,$b8,$f3,$5c,$66,$64,$52,$59,$65,$62
    .byte $42,$43,$44,$49,$46,$47,$4c,$5a,$4a,$4b,$4e,$5d,$a9,$aa,$a9,$a8
    .byte $69,$69,$54,$4d,$69,$69,$55,$4f,$69,$69,$56,$52,$69,$69,$a9,$aa
    .byte $4c,$5d,$69,$69,$a9,$a8,$69,$69,$02,$03,$03,$12,$0c,$0d,$0e,$0f
    .byte $4e,$5d,$00,$00,$50,$5b,$00,$00,$4a,$5c,$00,$00,$52,$59,$00,$00
    .byte $06,$06,$06,$1a,$11,$11,$11,$11,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2
    .byte $42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$a9,$aa,$a9,$aa
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$69,$00,$01,$03,$00,$00,$0c,$0d
    .byte $69,$00,$69,$00,$63,$00,$00,$b6,$64,$bb,$5e,$b7,$65,$bc,$60,$b8
    .byte $66,$be,$62,$b9,$ba,$b0,$b2,$b3,$66,$be,$62,$b9,$ba,$b0,$b2,$b3
    .byte $06,$06,$06,$06,$11,$11,$11,$11,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2
    .byte $17,$1b,$16,$1c,$11,$11,$d8,$d9,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2
    .byte $00,$6a,$6a,$6a,$7b,$7c,$6b,$6c,$6d,$7f,$6e,$80,$84,$85,$86,$87
    .byte $6a,$6a,$69,$00,$6b,$6c,$7d,$00,$6f,$81,$70,$00,$6f,$88,$89,$00
    .byte $71,$8a,$72,$85,$71,$8a,$8d,$8e,$71,$8a,$75,$94,$71,$8a,$00,$95
    .byte $15,$19,$14,$13,$1d,$18,$18,$18,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2
    .byte $13,$e4,$13,$e4,$18,$18,$18,$18,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2
    .byte $4a,$4b,$4c,$4d,$a9,$aa,$50,$51,$03,$57,$58,$4f,$0e,$0f,$00,$a9
    .byte $01,$03,$03,$12,$0c,$0d,$0e,$0f,$f0,$0d,$f1,$0f,$50,$4c,$48,$49
    .byte $4a,$4b,$4c,$4d,$4e,$4f,$50,$51,$4d,$52,$4c,$4f,$aa,$a9,$aa,$a9
    .byte $f3,$4b,$f5,$5d,$4b,$4c,$50,$5b,$4c,$4d,$f4,$5c,$a9,$aa,$52,$59
    .byte $54,$4b,$4c,$4d,$55,$4f,$4d,$51,$58,$52,$4a,$4f,$00,$a9,$aa,$a9
    .byte $f0,$43,$f1,$45,$46,$47,$48,$49,$f3,$4b,$f4,$4d,$4e,$4f,$50,$51
    .byte $f0,$43,$f1,$5d,$55,$47,$48,$5b,$58,$4b,$f4,$5a,$00,$a9,$aa,$aa
    .byte $01,$12,$04,$0b,$0c,$0d,$0e,$0f,$55,$43,$44,$45,$50,$4c,$48,$49
    .byte $42,$43,$44,$45,$46,$47,$48,$49,$58,$4b,$4c,$4d,$00,$a9,$a9,$aa
    .byte $54,$4b,$4c,$4d,$55,$4f,$50,$51,$56,$52,$4c,$4f,$55,$4d,$4e,$48
    .byte $02,$03,$03,$57,$0c,$0d,$0e,$0f,$42,$43,$44,$59,$46,$47,$4c,$5a
    .byte $4a,$4b,$4e,$5d,$4e,$4f,$50,$5b,$4d,$52,$4a,$a8,$aa,$a9,$aa,$00
    .byte $4a,$4b,$4e,$5d,$4e,$4f,$50,$5b,$4d,$52,$4c,$5c,$49,$4d,$52,$59
    .byte $4a,$4b,$4e,$a8,$a9,$aa,$aa,$00,$02,$03,$03,$12,$0c,$0d,$0e,$0f
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$01,$12,$04,$0b,$0c,$0d,$0e,$0f
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$02,$03,$03,$57,$0c,$0d,$0e,$0f
    .byte $c6,$d7,$c0,$c0,$c6,$d7,$c0,$c0,$c6,$d7,$c0,$c0,$c6,$d7,$c0,$c0
    .byte $48,$4c,$4e,$4f,$aa,$a9,$aa,$a9,$02,$03,$03,$57,$0c,$0d,$0e,$0f
    .byte $42,$43,$44,$59,$46,$47,$4c,$5a,$4a,$4b,$4e,$5d,$4e,$4f,$50,$5b
    .byte $48,$4c,$47,$4d,$4a,$4a,$4b,$4c,$4e,$4b,$4c,$50,$a9,$aa,$a9,$aa
    .byte $c0,$c1,$c1,$c0,$c1,$c1,$c0,$c1,$c0,$c1,$c0,$c0,$c0,$c0,$c0,$c0
    .byte $c2,$c2,$c2,$c2,$c8,$c8,$c8,$c8,$c0,$c0,$c0,$c0,$c0,$c1,$c0,$c1
    .byte $ed,$ec,$ed,$ec,$c0,$c0,$c0,$c1,$c1,$c0,$c0,$c0,$c0,$c0,$c1,$c0
    .byte $63,$00,$00,$bb,$64,$bb,$5e,$b7,$65,$bc,$60,$b8,$66,$be,$64,$b0
    .byte $69,$bb,$5e,$00,$5f,$bc,$60,$bd,$61,$be,$62,$b1,$61,$b0,$b2,$b1
    .byte $c0,$c0,$c0,$c0,$ee,$af,$ef,$c0,$c0,$c0,$c0,$c1,$c1,$c0,$c0,$c0
    .byte $69,$00,$69,$68,$00,$ae,$00,$00,$69,$00,$69,$00,$00,$00,$00,$00
    .byte $68,$00,$69,$00,$00,$00,$00,$68,$69,$68,$69,$00,$00,$00,$00,$ae
    .byte $f3,$4b,$f5,$5d,$4e,$4f,$50,$5b,$4d,$52,$f4,$5c,$49,$4d,$52,$59
    .byte $05,$03,$03,$57,$0c,$0d,$0e,$0f,$f0,$0d,$f1,$0f,$46,$47,$48,$59
    .byte $ee,$af,$ef,$c0,$c1,$c0,$c0,$c0,$c0,$c0,$c1,$c0,$c0,$c0,$c0,$c0
    .byte $01,$03,$03,$57,$0c,$0d,$0e,$0f,$f0,$43,$f1,$45,$46,$47,$48,$49
    .byte $00,$00,$69,$b6,$00,$bb,$5e,$b7,$ba,$b0,$5e,$b8,$61,$b0,$60,$b9
    .byte $63,$00,$a9,$aa,$64,$bd,$00,$00,$62,$bb,$5e,$00,$b2,$bc,$60,$bd
    .byte $69,$b4,$69,$00,$00,$ab,$b5,$00,$69,$ab,$69,$00,$00,$ab,$b5,$00
    .byte $69,$00,$69,$00,$63,$00,$00,$00,$64,$bb,$5e,$00,$65,$bc,$60,$bd
    .byte $66,$be,$62,$b1,$ba,$b0,$b2,$b3,$66,$be,$62,$b1,$ba,$b0,$b2,$b3
    .byte $f6,$4b,$f4,$4d,$55,$4f,$50,$51,$f7,$52,$f4,$4f,$55,$4d,$4e,$48
    .byte $69,$ac,$69,$00,$00,$ac,$00,$00,$05,$12,$04,$0b,$0c,$0d,$0e,$0f
    .byte $ea,$c6,$c5,$c0,$ea,$c6,$c5,$c0,$ea,$c6,$c5,$c0,$ea,$c6,$e3,$c0
    .byte $c7,$e8,$c0,$c0,$c3,$e7,$c7,$e8,$c0,$e4,$c3,$e7,$c0,$e4,$c0,$e4
    .byte $69,$d4,$cd,$ce,$de,$d3,$0a,$eb,$cc,$d6,$09,$eb,$c6,$d7,$c0,$c0
    .byte $ce,$ce,$cf,$db,$eb,$1f,$e0,$e1,$e9,$cc,$ca,$c0,$ea,$c6,$e3,$c0
    .byte $fa,$c4,$fe,$69,$e6,$fb,$c4,$fe,$c0,$e6,$fb,$c4,$c0,$c0,$e6,$fb
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$69,$69,$f8,$e2,$00,$d1,$d2,$d2
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$f9,$f9,$f9,$f9,$d2,$d2,$d2,$da
    .byte $69,$00,$69,$00,$00,$00,$00,$00,$c9,$69,$69,$69,$e5,$fe,$69,$69
    .byte $63,$69,$00,$00,$64,$b6,$63,$00,$65,$be,$62,$b1,$65,$bc,$b2,$b3

level_5_nametable_update_supertile_data:
    .byte $20,$21,$21,$22,$26,$30,$31,$27,$26,$30,$31,$27,$23,$24,$24,$25 ; #$00 - pill box sensor closed
    .byte $20,$21,$21,$22,$26,$2c,$2d,$27,$26,$2e,$2f,$27,$23,$24,$24,$25 ; #$01 - pill box sensor partially open
    .byte $20,$21,$21,$22,$26,$28,$29,$27,$26,$2a,$2b,$27,$23,$24,$24,$25 ; #$02 - pill box sensor open
    .byte $6c,$6d,$69,$69,$71,$72,$73,$69,$78,$76,$97,$95,$78,$99,$98,$96 ; #$03 - boss ufo top closing (right) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $6c,$6d,$69,$69,$71,$72,$73,$69,$78,$76,$9a,$69,$78,$9b,$98,$96 ; #$04 - boss ufo top closing (right) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $6c,$6d,$69,$69,$71,$72,$9c,$69,$78,$9d,$69,$69,$78,$9e,$98,$96 ; #$05 - boss ufo top closing (right) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $7f,$7e,$7e,$80,$84,$82,$81,$69,$a1,$9f,$85,$69,$a3,$69,$69,$69 ; #$06 - boss ufo - bottom thruster half throttle (right) (boss_ufo_supertile_update_ptr_tbl_3)
    .byte $7d,$7e,$7e,$7f,$69,$81,$82,$83,$69,$85,$86,$87,$69,$69,$69,$89 ; #$07 - boss ufo - bottom thruster full throttle (left) (boss_ufo_supertile_update_ptr_tbl/boss_ufo_supertile_update_ptr_tbl_3)
    .byte $7f,$7e,$7e,$80,$84,$82,$81,$69,$88,$86,$85,$69,$8a,$69,$69,$69 ; #$08 - boss ufo - bottom thruster full throttle (right) (boss_ufo_supertile_update_ptr_tbl/boss_ufo_supertile_update_ptr_tbl_3)
    .byte $69,$69,$6a,$6b,$69,$6e,$6f,$70,$8b,$8d,$76,$77,$8c,$8e,$8f,$77 ; #$09 - boss ufo top closing (left) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $69,$69,$6a,$6b,$69,$6e,$6f,$70,$69,$90,$76,$77,$8c,$8e,$91,$77 ; #$0a - boss ufo top closing (left) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $69,$69,$6a,$6b,$69,$92,$6f,$70,$69,$69,$93,$77,$8c,$8e,$94,$77 ; #$0b - boss ufo top closing (left) (boss_ufo_supertile_update_ptr_tbl_2)
    .byte $7d,$7e,$7e,$7f,$69,$81,$82,$83,$69,$85,$9f,$a0,$69,$69,$69,$a2 ; #$0c - boss ufo - bottom thruster half throttle (left) (boss_ufo_supertile_update_ptr_tbl_3)
    .byte $69,$69,$6a,$6b,$69,$6e,$6f,$70,$74,$75,$76,$77,$74,$7b,$7c,$77 ; #$0d - boss ufo - blue top fully open (left) (boss_ufo_supertile_update_ptr_tbl/boss_ufo_supertile_update_ptr_tbl_2)
    .byte $6c,$6d,$69,$69,$71,$72,$73,$69,$78,$76,$79,$7a,$78,$7c,$7b,$7a ; #$0e - boss ufo - blue top fully open (right) (boss_ufo_supertile_update_ptr_tbl/boss_ufo_supertile_update_ptr_tbl_2)
    .byte $69,$00,$69,$00,$9a,$9b,$9c,$7b,$69,$00,$69,$7e,$00,$00,$82,$83 ; #$0f - tank turret aim code #$0c (straight left)
    .byte $73,$8b,$69,$87,$91,$92,$8f,$87,$76,$77,$78,$6c,$96,$97,$98,$99 ; #$10 - tank wheel
    .byte $74,$8c,$6c,$00,$90,$91,$92,$93,$6b,$76,$77,$78,$99,$96,$97,$98 ; #$11 - tank wheel
    .byte $69,$00,$69,$00,$00,$00,$9f,$7b,$9d,$9e,$a0,$7e,$00,$00,$82,$83 ; #$12 - tank turret aim code #$0b (down to the left)
    .byte $69,$00,$69,$00,$00,$00,$a1,$7b,$69,$a2,$a3,$7e,$00,$a4,$82,$83 ; #$13 - tank turret aim code #$0a (far down as possible)
    .byte $73,$8b,$69,$87,$91,$92,$8f,$87,$79,$77,$7a,$6c,$a5,$a6,$a7,$99 ; #$14 - tank wheel
    .byte $74,$8c,$6c,$00,$90,$91,$92,$93,$6b,$79,$77,$7a,$99,$a5,$a6,$a7 ; #$15 - tank wheel
    .byte $cd,$ce,$ce,$ce,$d5,$dc,$dd,$de,$cb,$69,$69,$cc,$69,$69,$00,$c6 ; #$16 - boss screen open door top
    .byte $69,$69,$69,$c6,$69,$69,$69,$c6,$69,$69,$69,$c6,$69,$69,$69,$c6 ; #$17 - boss screen open door
    .byte $07,$19,$14,$14,$1d,$18,$18,$18,$f2,$f2,$f2,$f2,$f2,$f2,$f2,$f2 ; #$18 - boss screen open door bottom
    .byte $4a,$4b,$4c,$4d,$4e,$4f,$50,$51,$4d,$52,$4c,$4f,$49,$4d,$4e,$48 ; #$19 - snowy rock tile
    .byte $42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$51 ; #$1a - snowy rock tile
    .byte $69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69,$69 ; #$1b - all black (used to make boss ufo invisible, and tank)

level_5_palette_data:
    .byte $55,$00,$00,$00,$00,$55,$55,$55,$54,$00,$00,$00,$00,$00,$05,$00
    .byte $44,$00,$00,$00,$00,$00,$00,$00,$55,$55,$00,$00,$ea,$ba,$ea,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$ff,$ff,$ff,$55,$55,$ff,$00,$00,$00,$00,$ff
    .byte $00,$55,$51,$55,$55,$55,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $55

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_5_nametable_update_palette_data:
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$aa,$aa,$aa,$ff,$aa,$aa,$8a
    .byte $ae,$ab,$a8,$a8,$ae,$ab,$00,$11,$00,$00,$00,$00,$00,$00,$00

; nametable animation pattern table tiles - level 6 (#$e * #$5 = #$46 bytes)
; bytes 1 - 4 are the pattern table tiles to draw
; byte 0 specifies to use the default of #$02 rows of #$02 pattern table tiles each row
; byte 0 specifies only #$01 row of #$02 tiles is updated instead of the default of #$02
; CPU address $9dd8
level_6_tile_animation:
    .byte $01,$00,$00,$00,$00 ; 80 beam - nothing (black tiles)
    .byte $01,$1a,$0c,$1b,$1c ; 81 beam right - beam origin
    .byte $01,$0e,$0c,$1e,$1c ; 82 beam right - beam middle
    .byte $01,$0c,$00,$1c,$00 ; 83 beam right - beam end
    .byte $01,$0d,$0f,$1d,$1f ; 84 beam left - beam origin
    .byte $01,$0d,$0e,$1d,$1e ; 85 beam left - beam middle
    .byte $01,$00,$0d,$00,$1d ; 86 beam left - beam end
    .byte $01,$18,$19,$14,$15 ; 87 beam down - beam origin
    .byte $01,$16,$17,$14,$15 ; 88 beam down - beam middle
    .byte $01,$14,$15,$00,$00 ; 89 beam down - beam end
    .byte $01,$01,$a8,$76,$77 ; 8a boss screen door opening bottom (blank opening and floor)
    .byte $01,$c9,$f8,$c9,$a9 ; 8b boss screen door
    .byte $01,$c9,$a9,$c9,$00 ; 8c boss screen door (blank opening and top of door)
    .byte $01,$c9,$00,$c9,$00 ; 8d boss screen door (side wall and blank opening)

; super-tile data - level 6 (#$750 bytes)
level_6_supertile_data:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$00 - blank super-tile
    .byte $02,$02,$02,$02,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $70,$43,$02,$02,$7a,$7b,$7c,$7d,$72,$73,$e9,$6a,$67,$74,$7e,$48
    .byte $02,$02,$02,$02,$75,$76,$76,$77,$41,$5c,$5d,$5e,$4b,$4d,$4e,$4f
    .byte $02,$02,$02,$02,$75,$76,$76,$77,$41,$5c,$5d,$5e,$4b,$b9,$3e,$3f
    .byte $e5,$85,$00,$00,$e5,$85,$00,$00,$e5,$85,$00,$00,$e5,$85,$00,$00
    .byte $01,$79,$40,$48,$75,$76,$76,$77,$41,$5c,$5d,$5e,$4b,$4d,$4e,$4f
    .byte $71,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $00,$00,$70,$43,$00,$00,$7a,$7b,$00,$00,$72,$84,$00,$00,$00,$78
    .byte $72,$84,$58,$6a,$00,$78,$40,$48,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$63,$63,$63,$63
    .byte $01,$04,$00,$00,$75,$77,$00,$00,$e0,$57,$00,$00,$e5,$85,$00,$00
    .byte $02,$02,$02,$02,$7c,$7d,$75,$76,$58,$6a,$41,$5c,$40,$48,$4b,$4d
    .byte $02,$02,$02,$02,$63,$63,$63,$63,$00,$00,$e4,$54,$00,$00,$82,$64
    .byte $5b,$5b,$71,$00,$6b,$6b,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $70,$43,$02,$02,$7a,$7b,$7c,$7d,$72,$84,$58,$6a,$00,$78,$40,$48
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $4a,$5b,$5b,$5b,$44,$6b,$6b,$6b,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$70,$43,$02,$02,$7a,$7b,$7c,$7d
    .byte $41,$5c,$5d,$5e,$4b,$b9,$3e,$3f,$71,$00,$00,$00,$00,$00,$00,$00
    .byte $01,$79,$40,$48,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $00,$00,$4a,$5b,$00,$00,$44,$6b,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $02,$02,$01,$04,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $41,$5c,$5d,$5e,$4b,$4d,$4e,$4f,$4a,$5b,$5b,$5b,$44,$6b,$6b,$6b
    .byte $4a,$5b,$5b,$5b,$44,$6b,$6b,$6b,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$aa,$ae,$ab,$ac,$ad,$f8
    .byte $02,$02,$e1,$80,$63,$63,$63,$63,$00,$00,$e4,$54,$00,$00,$82,$64
    .byte $00,$00,$e3,$54,$00,$00,$e3,$64,$00,$00,$e3,$64,$00,$00,$e3,$64
    .byte $02,$02,$02,$02,$63,$63,$63,$63,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $64,$60,$63,$63,$63,$63,$51,$63,$64,$64,$64,$00,$64,$64,$54,$00
    .byte $02,$02,$e1,$80,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $00,$00,$e3,$54,$00,$00,$e3,$64,$02,$02,$e1,$80,$63,$63,$63,$63
    .byte $00,$00,$e4,$54,$00,$00,$82,$64,$00,$00,$e3,$64,$00,$00,$e3,$64
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$42,$00,$00,$49,$53
    .byte $96,$00,$68,$69,$63,$63,$63,$6f,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $41,$57,$00,$00,$4b,$85,$00,$00,$71,$00,$00,$00,$00,$00,$00,$00
    .byte $96,$97,$02,$02,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $4b,$5b,$5b,$5b,$4b,$6b,$6b,$6b,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $4a,$5b,$5b,$5b,$44,$6b,$6b,$6b,$70,$43,$02,$02,$7a,$7b,$7c,$7d
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$ae,$af,$b0,$b1,$b2,$b3,$b4,$b5
    .byte $00,$00,$00,$00,$63,$63,$62,$63,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $66,$66,$66,$66,$5f,$5f,$5f,$5f,$54,$00,$64,$00,$64,$63,$63,$62
    .byte $4c,$56,$66,$66,$4c,$56,$5f,$5f,$4c,$56,$00,$00,$4c,$56,$63,$63
    .byte $00,$00,$03,$42,$00,$00,$49,$53,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $02,$02,$e1,$80,$75,$76,$76,$77,$41,$5c,$5d,$5e,$4b,$4d,$4e,$4f
    .byte $f7,$8e,$f0,$8f,$e8,$ed,$ee,$ef,$f3,$f4,$f4,$8a,$62,$63,$63,$63
    .byte $f1,$f2,$f2,$89,$f3,$f4,$f4,$8a,$f5,$f6,$f6,$93,$94,$87,$88,$92
    .byte $00,$00,$e3,$54,$00,$00,$e3,$64,$00,$00,$e3,$64,$00,$00,$45,$80
    .byte $64,$64,$64,$00,$63,$50,$64,$62,$64,$00,$64,$00,$64,$00,$64,$00
    .byte $64,$00,$64,$00,$64,$63,$50,$63,$64,$00,$00,$00,$64,$00,$00,$00
    .byte $54,$00,$00,$00,$64,$00,$00,$00,$64,$00,$00,$00,$64,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$01,$04,$00,$00,$75,$77,$00,$00
    .byte $02,$02,$02,$02,$75,$76,$76,$77,$41,$5c,$5d,$5e,$6e,$3e,$3e,$3f
    .byte $41,$5c,$5d,$5e,$6e,$3e,$3e,$3f,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $4c,$56,$64,$00,$4c,$56,$64,$00,$4c,$56,$64,$00,$4c,$56,$64,$00
    .byte $4c,$56,$4a,$5b,$4c,$56,$44,$6b,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $02,$02,$01,$04,$76,$77,$75,$77,$5d,$5e,$41,$57,$4e,$4f,$4b,$85
    .byte $4c,$56,$00,$00,$4c,$56,$00,$00,$4c,$56,$00,$00,$4c,$56,$00,$00
    .byte $b6,$b7,$b8,$f8,$b6,$ba,$bb,$bc,$c3,$c4,$c5,$c6,$c7,$e2,$c9,$f8
    .byte $41,$5c,$5d,$5e,$6e,$3e,$3e,$3f,$4c,$56,$00,$00,$4c,$56,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$01,$04,$63,$63,$63,$63
    .byte $54,$00,$64,$00,$64,$00,$64,$00,$64,$00,$64,$00,$00,$00,$64,$00
    .byte $64,$00,$00,$00,$61,$63,$63,$63,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $64,$64,$64,$00,$63,$52,$64,$00,$54,$00,$54,$00,$00,$00,$64,$00
    .byte $62,$63,$63,$63,$62,$63,$63,$63,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $63,$52,$64,$00,$62,$63,$52,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $f5,$f6,$f6,$93,$62,$63,$63,$63,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $66,$66,$e3,$54,$5f,$5f,$e3,$64,$00,$00,$e3,$64,$00,$00,$e3,$64
    .byte $4c,$56,$00,$00,$4c,$56,$00,$00,$4c,$55,$00,$00,$4c,$65,$00,$00
    .byte $4c,$55,$00,$00,$4c,$65,$00,$00,$4c,$56,$00,$00,$4c,$56,$00,$00
    .byte $71,$00,$00,$00,$00,$00,$00,$00,$01,$04,$00,$00,$75,$77,$00,$00
    .byte $01,$04,$00,$00,$75,$77,$00,$00,$41,$57,$00,$00,$4b,$85,$00,$00
    .byte $41,$5c,$5d,$5e,$6e,$3e,$3e,$3f,$4c,$55,$00,$00,$4c,$65,$00,$00
    .byte $54,$00,$00,$00,$63,$63,$63,$63,$64,$00,$00,$00,$64,$00,$00,$00
    .byte $66,$66,$66,$66,$5f,$5f,$5f,$5f,$64,$00,$00,$64,$64,$63,$63,$52
    .byte $66,$66,$66,$66,$5f,$5f,$6c,$6d,$00,$00,$00,$00,$63,$62,$00,$00
    .byte $4b,$3a,$3a,$3a,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b
    .byte $54,$63,$51,$63,$64,$60,$64,$63,$64,$64,$64,$00,$64,$64,$64,$00
    .byte $eb,$ea,$ea,$8b,$8c,$ec,$ec,$8d,$f5,$f6,$f6,$93,$f1,$f2,$f2,$89
    .byte $02,$02,$01,$04,$63,$63,$63,$63,$e6,$95,$e7,$91,$f1,$f2,$f2,$89
    .byte $03,$42,$02,$02,$81,$9a,$63,$63,$83,$86,$90,$90,$98,$99,$63,$63
    .byte $02,$02,$02,$02,$76,$77,$75,$76,$5d,$5e,$41,$5c,$4e,$4f,$4b,$b9
    .byte $71,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$4a,$5b,$00,$00,$44,$6b,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $5b,$5b,$71,$00,$6b,$6b,$00,$00,$02,$02,$02,$02,$75,$76,$76,$77
    .byte $bd,$be,$bf,$c0,$c1,$c2,$f8,$b6,$ca,$cb,$f8,$b6,$cc,$b6,$f8,$b6
    .byte $cd,$cf,$c9,$f8,$b6,$cc,$c9,$f8,$d4,$cc,$c9,$f8,$c7,$e2,$c9,$f8
    .byte $5a,$00,$00,$00,$00,$00,$00,$5a,$00,$00,$00,$00,$00,$59,$00,$00
    .byte $02,$02,$02,$02,$76,$77,$75,$76,$5d,$5e,$41,$5c,$3e,$3f,$6e,$3e
    .byte $02,$02,$02,$02,$76,$77,$75,$76,$5d,$5e,$41,$5c,$3e,$3f,$4b,$4d
    .byte $e2,$d4,$f8,$b6,$cf,$c7,$a3,$a4,$cc,$cd,$c8,$a0,$cc,$b6,$a1,$a2
    .byte $e2,$d0,$d1,$d2,$cf,$c7,$d3,$a0,$cc,$cd,$c8,$a0,$cc,$b6,$a1,$a2
    .byte $a5,$a6,$f8,$b6,$11,$9b,$a5,$a7,$90,$90,$90,$90,$63,$63,$62,$63
    .byte $02,$02,$e1,$80,$63,$63,$63,$63,$00,$00,$e3,$64,$00,$00,$e3,$64
    .byte $00,$00,$e3,$64,$00,$00,$e3,$64,$00,$00,$e4,$54,$00,$00,$82,$64
    .byte $02,$02,$01,$ce,$75,$76,$76,$77,$41,$5c,$5d,$5e,$4b,$4d,$4e,$4f
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$5a,$00,$00,$00,$00,$00,$00
    .byte $4b,$3a,$3a,$60,$4b,$3b,$3b,$64,$4b,$3b,$3b,$64,$4b,$3b,$3b,$64
    .byte $62,$63,$63,$63,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b
    .byte $13,$3a,$3a,$3a,$64,$3b,$3b,$3b,$64,$3b,$3b,$3b,$64,$3b,$3b,$3b
    .byte $52,$3a,$3a,$3a,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b
    .byte $4b,$3a,$3a,$61,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b,$4b,$3b,$3b,$3b
    .byte $e6,$95,$e7,$91,$f1,$f2,$f2,$89,$f3,$f4,$f4,$8a,$f5,$f6,$f6,$93
    .byte $00,$00,$e3,$64,$00,$00,$e3,$64,$59,$00,$e3,$64,$00,$00,$e3,$64
    .byte $01,$04,$00,$00,$62,$63,$00,$00,$90,$90,$00,$00,$63,$63,$00,$00

level_6_nametable_update_supertile_data:
    .byte $20,$21,$21,$22,$26,$30,$31,$27,$26,$30,$31,$27,$23,$24,$24,$25 ; pill box sensor closed
    .byte $20,$21,$21,$22,$26,$2c,$2d,$27,$26,$2e,$2f,$27,$23,$24,$24,$25 ; pill box sensor partially open
    .byte $20,$21,$21,$22,$26,$28,$29,$27,$26,$2a,$2b,$27,$23,$24,$24,$25 ; pill box sensor open
    .byte $12,$60,$63,$51,$60,$64,$62,$64,$64,$10,$00,$64,$54,$63,$63,$52
    .byte $00,$60,$63,$12,$60,$51,$13,$00,$64,$64,$64,$00,$54,$64,$64,$00

level_6_palette_data:
    .byte $ff,$00,$00,$a0,$a0,$22,$a0,$01,$00,$00,$05,$20,$80,$30,$05,$00
    .byte $0f,$05,$00,$1a,$00,$04,$00,$5a,$05,$ff,$30,$00,$f0,$55,$00,$00
    .byte $03,$00,$00,$de,$00,$05,$05,$ff,$05,$55,$55,$00,$a0,$55,$55,$00
    .byte $55,$55,$55,$0f,$a0,$fa,$55,$05,$a0,$11,$ff,$1a,$0f,$55,$55,$55
    .byte $55,$f5,$05,$01,$d5,$1d,$cd,$ec,$da,$15,$55,$d5,$55,$55,$55,$50
    .byte $00,$a0,$cd,$04,$05,$ff,$ff,$d0,$a0,$a0,$ff,$ff,$0f,$00,$30,$a0
    .byte $00,$55,$55,$55,$55,$55,$55,$10,$00

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_6_nametable_update_palette_data:
    .byte $aa,$aa,$aa,$55,$55,$00,$00

; nametable animation tiles codes - level 7 (#$c * #$5 = #$3c bytes)
; first byte is number of groups of length 2 to update of data being written
; e.g. byte 0 (#$83) means to draw three rows of two tiles each
; $0c $0d store the ppu write address
; CPU address $a56e
level_7_tile_animation:
    .byte $83,$de,$df,$ee,$ef ; 80 mechanical claw
    .byte $00,$00,$00,$00,$00 ; 81 mechanical claw - nothing (black tiles)
    .byte $83,$de,$df,$ee,$ef ; 82 mechanical claw
    .byte $47,$48,$00,$00,$00 ; 83 safety rail - top
    .byte $83,$de,$df,$ee,$ef ; 84 mechanical claw
    .byte $57,$58,$00,$00,$00 ; 85 safety rail - bottom
    .byte $83,$ce,$cf,$de,$df ; 86 mechanical claw - top
    .byte $ee,$ef,$00,$00,$00 ; 87 mechanical claw - bottom
    .byte $00,$30,$31,$30,$31 ; 88 mortar launcher - frame 0 (closed)
    .byte $00,$c5,$c6,$c7,$c8 ; 89 mortar launcher - frame 1 (partially open/partially closed)
    .byte $00,$ea,$eb,$ec,$ed ; 8a mortar launcher - frame 2 (opened)
    .byte $00,$4a,$4f,$4a,$52 ; 8b mortar launcher - destroyed

; super-tile data - level 7
level_7_supertile_data:
    .byte $04,$05,$70,$70,$cd,$dd,$61,$61,$af,$af,$0e,$0f,$b1,$b2,$72,$73
    .byte $74,$75,$f9,$a7,$66,$67,$f8,$a7,$76,$89,$f8,$a7,$76,$89,$f8,$a7
    .byte $76,$89,$f7,$a7,$76,$89,$f7,$a7,$af,$53,$f7,$a7,$b1,$b2,$f7,$a7
    .byte $74,$75,$74,$75,$66,$67,$66,$67,$76,$89,$76,$89,$76,$89,$76,$89
    .byte $5c,$5d,$5c,$5d,$6c,$6d,$6c,$6d,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$42,$43,$00,$42,$43,$00,$42,$00,$00,$43,$42,$42,$43,$00,$43
    .byte $af,$af,$af,$53,$a1,$a1,$a1,$a3,$a1,$a1,$a1,$a2,$a1,$a2,$69,$b3
    .byte $af,$af,$af,$53,$89,$89,$a0,$a1,$a1,$a1,$a2,$a3,$89,$89,$b0,$b3
    .byte $a1,$a1,$a1,$a2,$00,$00,$00,$00,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7
    .byte $a1,$a1,$89,$a2,$00,$00,$98,$75,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $a3,$a0,$a2,$a2,$4d,$4d,$4d,$4d,$5c,$5d,$5c,$5d,$44,$45,$44,$45
    .byte $0b,$0c,$70,$70,$bd,$be,$61,$61,$af,$af,$0e,$0f,$b1,$b2,$72,$73
    .byte $a4,$a5,$f7,$a7,$a4,$b5,$b6,$b7,$a4,$a7,$00,$00,$a4,$a7,$00,$00
    .byte $76,$89,$76,$89,$76,$89,$76,$89,$af,$53,$af,$af,$b1,$b2,$b1,$b2
    .byte $5c,$5d,$5c,$5d,$44,$45,$44,$45,$de,$df,$de,$df,$ee,$ef,$ee,$ef
    .byte $06,$07,$08,$08,$7f,$9e,$be,$bd,$7f,$00,$af,$53,$ad,$ae,$b1,$b2
    .byte $08,$08,$08,$08,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2
    .byte $08,$08,$0b,$0c,$bd,$bd,$bd,$be,$af,$af,$af,$53,$b1,$b2,$b1,$b2
    .byte $09,$0a,$08,$08,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2
    .byte $af,$af,$af,$53,$a1,$a3,$a0,$a1,$00,$a0,$a3,$00,$a0,$b0,$b3,$a3
    .byte $af,$af,$af,$53,$a1,$a3,$89,$89,$a0,$a2,$a1,$a1,$b0,$b3,$89,$89
    .byte $af,$af,$af,$53,$a0,$a1,$a1,$a2,$a2,$a1,$a1,$a2,$b0,$68,$a2,$a2
    .byte $af,$af,$f8,$a7,$9c,$7a,$f8,$a7,$9c,$8a,$f9,$a7,$9c,$9b,$9f,$a7
    .byte $a3,$b0,$b3,$a0,$4d,$4d,$4d,$4d,$5c,$5d,$5c,$5d,$44,$45,$44,$45
    .byte $a2,$a2,$a3,$a0,$4d,$4d,$4d,$4d,$5c,$5d,$5c,$5d,$44,$45,$44,$45
    .byte $a2,$89,$a1,$a2,$af,$99,$00,$00,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $9c,$9a,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7
    .byte $09,$f0,$f7,$a7,$bd,$be,$f7,$a7,$af,$af,$f7,$a7,$b1,$b2,$f7,$a7
    .byte $76,$89,$f7,$cc,$76,$89,$f7,$cc,$af,$53,$f7,$cc,$b1,$b2,$f7,$cc
    .byte $01,$02,$03,$03,$7f,$9e,$dd,$cd,$fe,$00,$af,$53,$bf,$ae,$b1,$b2
    .byte $a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$b5,$b6,$b7
    .byte $03,$03,$03,$03,$cd,$cd,$cd,$cd,$af,$af,$af,$53,$b1,$b2,$b1,$b2
    .byte $5c,$5d,$5c,$5d,$6c,$6d,$6c,$6d,$62,$63,$4b,$4c,$72,$5a,$5b,$00
    .byte $5c,$5d,$5c,$5d,$44,$45,$44,$45,$54,$55,$54,$55,$00,$00,$00,$00
    .byte $5c,$5d,$5c,$5d,$6c,$6d,$6c,$6d,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $60,$70,$6e,$6f,$70,$71,$7f,$74,$62,$63,$bf,$67,$72,$73,$7f,$89
    .byte $6f,$6f,$6f,$6f,$af,$75,$74,$75,$66,$67,$66,$67,$76,$89,$76,$89
    .byte $6f,$7e,$70,$70,$74,$75,$61,$61,$66,$67,$0e,$0f,$76,$89,$72,$73
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$62,$63,$4b,$4c,$72,$5a,$5b,$00
    .byte $60,$70,$bf,$89,$70,$71,$ad,$4d,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $76,$89,$76,$89,$4d,$4d,$4d,$4d,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $76,$89,$70,$70,$4d,$4d,$61,$61,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$4c,$4e,$0e,$0f,$00,$5e,$5f,$73
    .byte $5c,$5d,$5c,$5d,$44,$45,$6c,$6d,$54,$55,$00,$00,$00,$00,$00,$00
    .byte $5c,$5d,$5c,$5d,$6c,$6d,$6c,$6d,$4c,$4e,$0e,$0f,$00,$5e,$5f,$73
    .byte $60,$6a,$00,$00,$70,$6a,$00,$00,$62,$6a,$00,$00,$72,$6a,$8c,$8c
    .byte $00,$00,$6a,$70,$00,$00,$6a,$61,$00,$00,$6a,$0f,$8c,$8d,$6a,$73
    .byte $a4,$a5,$f7,$a7,$a4,$b5,$b6,$b7,$a4,$a7,$0e,$0f,$a4,$a7,$72,$73
    .byte $0b,$0c,$89,$10,$bd,$be,$88,$b4,$af,$af,$99,$11,$b1,$b2,$b1,$b2
    .byte $12,$12,$fa,$89,$b4,$b4,$b4,$88,$13,$13,$fb,$98,$b1,$b2,$b1,$b2
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$47,$48,$47,$48,$57,$58,$57,$58
    .byte $a4,$a7,$70,$70,$a4,$a7,$61,$61,$a4,$a7,$0e,$0f,$a4,$a7,$72,$73
    .byte $5c,$5d,$f7,$a7,$6c,$6d,$f7,$a7,$a4,$a5,$f7,$a7,$a4,$a5,$f7,$a7
    .byte $a4,$a7,$70,$70,$a4,$a7,$61,$61,$a4,$a7,$47,$48,$a4,$a7,$57,$58
    .byte $12,$12,$fa,$89,$b4,$b4,$b4,$88,$13,$13,$fb,$89,$b1,$b2,$b1,$89
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$46,$48,$47,$48,$56,$58,$57,$58
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$48,$49,$00,$00,$58,$59,$00,$00
    .byte $08,$da,$0d,$cc,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2
    .byte $b9,$ba,$fd,$cc,$b9,$ba,$fd,$cc,$b8,$ba,$fd,$cc,$c9,$ca,$fd,$cc
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$46,$48,$47,$48,$56,$58,$57,$58
    .byte $5c,$5d,$5c,$5d,$44,$45,$44,$45,$54,$55,$de,$df,$00,$00,$ee,$ef
    .byte $00,$00,$5c,$5d,$00,$00,$6c,$6d,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$42,$00,$00,$00,$00,$00,$43,$00,$00,$00,$00,$42,$00,$00,$00
    .byte $06,$07,$08,$08,$7f,$9e,$be,$bd,$fe,$00,$78,$53,$bf,$ae,$89,$b2
    .byte $60,$70,$bf,$89,$70,$71,$ad,$4d,$48,$49,$0e,$0f,$58,$59,$72,$73
    .byte $08,$08,$08,$08,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$20,$21,$21
    .byte $43,$42,$00,$00,$00,$00,$43,$00,$00,$42,$00,$00,$00,$00,$42,$00
    .byte $af,$af,$af,$53,$a1,$a1,$a1,$a2,$a1,$a1,$a1,$a2,$a1,$a1,$a1,$a2
    .byte $12,$12,$12,$10,$b4,$b4,$b4,$b4,$13,$13,$13,$11,$b1,$b2,$b1,$b2
    .byte $08,$08,$08,$08,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$22,$b2,$b1,$b2
    .byte $08,$08,$0b,$0c,$bd,$bd,$bd,$be,$af,$af,$fc,$79,$b1,$b2,$b1,$89
    .byte $04,$05,$89,$10,$cd,$dd,$88,$b4,$af,$af,$99,$11,$b1,$b2,$b1,$b2
    .byte $14,$15,$15,$15,$15,$a6,$12,$10,$16,$16,$13,$11,$b1,$b2,$b1,$b2
    .byte $17,$18,$19,$10,$1a,$1b,$1c,$b4,$1d,$32,$33,$11,$b1,$b2,$b1,$b2
    .byte $27,$15,$15,$15,$27,$a6,$12,$10,$25,$16,$13,$11,$b1,$b2,$b1,$b2
    .byte $14,$26,$30,$31,$15,$26,$30,$31,$16,$23,$24,$24,$b1,$b2,$b1,$b2
    .byte $a4,$a7,$00,$00,$a4,$a7,$00,$00,$a4,$a7,$47,$48,$a4,$a7,$57,$58
    .byte $00,$a0,$40,$89,$00,$b0,$b0,$89,$00,$41,$41,$88,$a0,$40,$40,$89
    .byte $ce,$cf,$ce,$cf,$ce,$cf,$ce,$cf,$de,$df,$de,$df,$ee,$ef,$ee,$ef
    .byte $b9,$ba,$fd,$cc,$b9,$ba,$fd,$cc,$b9,$ba,$fd,$cc,$b9,$ba,$fd,$cc
    .byte $00,$87,$8b,$00,$00,$80,$81,$00,$00,$97,$8b,$00,$00,$87,$8b,$00
    .byte $f6,$b4,$b4,$88,$f5,$35,$36,$88,$f6,$b4,$b4,$88,$f6,$b4,$b4,$88
    .byte $87,$7c,$7c,$8b,$87,$7b,$7c,$8b,$97,$7c,$7b,$8b,$97,$7c,$ff,$8b
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$48,$49,$0e,$0f,$58,$59,$72,$73
    .byte $a0,$97,$8b,$00,$b0,$87,$8b,$00,$41,$90,$91,$00,$b0,$97,$8b,$00
    .byte $f6,$b4,$b4,$88,$f6,$b4,$b4,$88,$f4,$36,$37,$88,$f6,$b4,$b4,$88
    .byte $87,$7b,$7c,$d6,$90,$d4,$d5,$e6,$97,$7c,$7b,$8b,$87,$7c,$7c,$8b
    .byte $00,$00,$00,$78,$00,$00,$00,$88,$00,$00,$00,$89,$00,$00,$00,$89
    .byte $af,$97,$8b,$00,$41,$87,$8b,$00,$b0,$82,$84,$00,$b0,$92,$94,$00
    .byte $f6,$b4,$b4,$88,$f6,$b4,$b4,$88,$7d,$53,$53,$99,$b1,$b1,$b1,$b1
    .byte $87,$ff,$7c,$8b,$87,$7c,$7b,$8b,$82,$83,$83,$84,$92,$93,$93,$94
    .byte $00,$00,$00,$88,$00,$00,$00,$89,$00,$00,$a0,$89,$00,$00,$41,$88
    .byte $41,$87,$8b,$00,$b0,$97,$8b,$00,$40,$87,$8b,$00,$41,$85,$86,$00
    .byte $f2,$34,$38,$39,$3a,$3b,$3c,$3d,$f3,$3e,$3f,$cb,$e0,$e1,$e2,$e3
    .byte $87,$7b,$7c,$8b,$87,$7c,$7b,$8b,$97,$7c,$7c,$8b,$87,$7b,$ff,$8b
    .byte $40,$97,$8b,$00,$b0,$87,$8b,$00,$41,$87,$8b,$00,$40,$95,$96,$00
    .byte $85,$e7,$e8,$e9,$87,$7c,$7c,$8b,$97,$7c,$7b,$8b,$87,$7b,$7c,$8b
    .byte $f1,$7c,$ff,$8b,$95,$e4,$e5,$8b,$97,$7b,$d7,$d8,$87,$7b,$7c,$8b
    .byte $87,$7c,$7b,$8b,$97,$7c,$ff,$8b,$97,$7b,$7c,$8b,$87,$7c,$7c,$8b

level_7_nametable_update_supertile_data:
    .byte $20,$21,$21,$22,$26,$30,$31,$27,$26,$30,$31,$27,$23,$24,$24,$25 ; #$00 - pill box sensor closed
    .byte $20,$21,$21,$22,$26,$2c,$2d,$27,$26,$2e,$2f,$27,$23,$24,$24,$25 ; #$01 - pill box sensor partially open
    .byte $20,$21,$21,$22,$26,$28,$29,$27,$26,$2a,$2b,$27,$23,$24,$24,$25 ; #$02 - pill box sensor open
    .byte $f6,$30,$31,$27,$f6,$30,$31,$27,$f6,$30,$31,$27,$f6,$30,$31,$27 ; #$03 - closed armored door (boss_soldier_nametable_update_tbl)
    .byte $50,$51,$51,$52,$bd,$9d,$9d,$9d,$af,$af,$af,$53,$b1,$b2,$b1,$b2 ; #$04 - spiked wall destroyed floor
    .byte $4a,$4f,$4f,$4f,$4a,$00,$00,$00,$4a,$00,$00,$00,$4a,$00,$00,$00
    .byte $00,$d9,$db,$dc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$06 - tall spiked wall destroyed top (parting hanging from ceiling)
    .byte $f6,$00,$00,$27,$f6,$00,$00,$27,$f6,$00,$00,$27,$f6,$00,$00,$27 ; #$07 - open armored door (see #$12) (boss_soldier_nametable_update_tbl)
    .byte $4a,$00,$00,$00,$4a,$00,$00,$00,$4a,$00,$00,$00,$4a,$00,$00,$00
    .byte $60,$70,$70,$70,$70,$71,$61,$61,$62,$63,$0e,$0f,$72,$73,$72,$73
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$0a - blank super-tile
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$47,$48,$47,$48,$57,$58,$57,$58 ; #$0b - fence
    .byte $47,$48,$47,$48,$c0,$c1,$57,$58,$08,$c2,$c3,$c4,$bd,$bd,$bd,$bd ; #$0c - rising wall (frame 0) (barely out of ground)
    .byte $47,$48,$47,$48,$d0,$d1,$d2,$8f,$08,$da,$d3,$bc,$bd,$bd,$bd,$bd ; #$0d - rising wall (frame 1) (slightly out of ground)
    .byte $a8,$aa,$ab,$8e,$c9,$ca,$bb,$bc,$08,$da,$0d,$cc,$bd,$bd,$bd,$bd ; #$0e - rising wall (frame 2) (first row of spikes visible)
    .byte $00,$00,$00,$00,$a9,$aa,$ab,$ac,$b8,$ba,$bb,$bc,$c9,$ca,$fd,$cc ; #$0f - rising wall (frame 3) (two rows of spikes visible)
    .byte $a9,$aa,$ab,$ac,$b9,$ba,$bb,$bc,$b8,$ba,$fd,$cc,$c9,$ca,$fd,$cc ; #$10 - rising wall (frame 4) (three rows of spikes visible)
    .byte $a9,$aa,$ab,$ac,$b9,$ba,$bb,$bc,$b9,$ba,$fd,$cc,$b9,$ba,$fd,$cc ; #$11 - rising wall (frame 5) (four rows of spikes visible)
    .byte $08,$1e,$1f,$27,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2 ; #$12 - closed armored door floor (boss_soldier_nametable_update_tbl)
    .byte $f6,$64,$65,$27,$f6,$64,$65,$27,$f6,$64,$65,$27,$f6,$64,$65,$27 ; #$13 - partial open armored door (boss_soldier_nametable_update_tbl)
    .byte $08,$08,$6b,$27,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2 ; #$14 - partial open armored door floor (boss_soldier_nametable_update_tbl)
    .byte $08,$08,$08,$27,$bd,$bd,$bd,$bd,$af,$af,$af,$53,$b1,$b2,$b1,$b2 ; #$15 - open armored door floor (boss_soldier_nametable_update_tbl)

level_7_palette_data:
    .byte $de,$11,$01,$55,$05,$ff,$00,$00,$f0,$00,$f0,$00,$dc,$00,$05,$00
    .byte $40,$50,$50,$50,$00,$00,$00,$00,$00,$00,$f0,$00,$10,$01,$5a,$00
    .byte $5a,$f5,$55,$f5,$77,$55,$dd,$ff,$f7,$f5,$fd,$ff,$55,$f5,$ff,$ff
    .byte $c0,$54,$55,$0f,$cc,$01,$0c,$55,$00,$00,$50,$00,$0f,$11,$04,$ff
    .byte $40,$c7,$50,$ff,$00,$55,$50,$50,$56,$55,$55,$55,$59,$00,$55,$00
    .byte $00,$55,$aa,$55,$cf,$55,$aa,$55,$55,$55,$aa,$55,$55,$55,$ff,$55
    .byte $55,$55,$55,$55

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_7_nametable_update_palette_data:
    .byte $aa,$aa,$aa,$00,$50,$00,$00,$00,$00,$ff,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$50,$00,$50,$50,$00,$00,$00,$00,$00,$00

; CPU address $adca
level_8_supertile_data:
    .byte $01,$03,$02,$03,$11,$13,$12,$13,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$3f
    .byte $02,$03,$02,$03,$12,$13,$12,$13,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$3f
    .byte $02,$03,$02,$04,$12,$13,$12,$14,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$4c
    .byte $01,$03,$02,$04,$11,$13,$12,$14,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$4c
    .byte $9b,$9b,$89,$89,$00,$00,$00,$00,$01,$03,$02,$03,$11,$13,$12,$13
    .byte $00,$9c,$9b,$89,$00,$00,$00,$00,$02,$03,$02,$03,$12,$13,$12,$13
    .byte $00,$9c,$9c,$9c,$00,$00,$00,$00,$02,$03,$02,$04,$12,$13,$12,$14
    .byte $9b,$89,$9c,$9c,$00,$00,$00,$00,$01,$03,$02,$04,$11,$13,$12,$14
    .byte $9b,$00,$01,$03,$a8,$00,$11,$13,$a8,$00,$2e,$2f,$a8,$00,$3e,$3f
    .byte $02,$04,$00,$9c,$12,$14,$00,$a9,$2c,$2d,$00,$a9,$3c,$3d,$00,$a9
    .byte $8e,$8f,$9b,$89,$9e,$9b,$00,$00,$9b,$00,$01,$03,$00,$00,$11,$13
    .byte $89,$9c,$8e,$8f,$00,$00,$9c,$9f,$02,$04,$00,$9c,$12,$14,$00,$ac
    .byte $a8,$00,$0e,$0f,$ab,$00,$10,$1f,$ae,$ab,$00,$00,$8c,$8d,$99,$99
    .byte $0c,$0d,$00,$a9,$1c,$1d,$00,$a9,$00,$00,$00,$ac,$99,$ac,$ac,$8d
    .byte $ab,$00,$0e,$0f,$9b,$00,$10,$1f,$a8,$00,$2e,$2f,$ab,$00,$90,$3f
    .byte $0c,$0d,$00,$9c,$1c,$1d,$00,$a9,$2c,$2d,$00,$a9,$3c,$b1,$00,$ac
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$10,$1f,$00,$00,$00,$00,$99,$99,$99,$99
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$3f
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$10,$1f,$02,$03,$02,$03,$12,$13,$12,$13
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$00,$00,$01,$03,$ab,$00,$11,$13
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$10,$1f,$01,$03,$02,$03,$11,$13,$12,$13
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$02,$03,$02,$04,$12,$13,$12,$14
    .byte $9b,$00,$0e,$0f,$00,$00,$10,$1f,$02,$03,$02,$03,$12,$13,$12,$13
    .byte $fb,$81,$a3,$a0,$00,$91,$b2,$b0,$fb,$a1,$82,$81,$b0,$00,$92,$93
    .byte $f2,$41,$f1,$43,$50,$51,$52,$53,$f0,$61,$ef,$63,$70,$71,$72,$73
    .byte $00,$82,$00,$92,$00,$92,$93,$a0,$00,$00,$91,$b0,$00,$a0,$a1,$a3
    .byte $00,$00,$00,$a0,$00,$00,$b0,$b0,$00,$a0,$a1,$81,$00,$a3,$00,$91
    .byte $83,$83,$83,$85,$83,$83,$83,$85,$83,$83,$84,$85,$84,$83,$94,$95
    .byte $00,$00,$83,$85,$ab,$00,$84,$85,$ae,$a8,$94,$95,$8c,$a8,$a4,$a5
    .byte $00,$00,$00,$81,$00,$00,$00,$92,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$b2,$a0,$a1,$00,$82,$b0,$00,$02,$03,$02,$03,$12,$13,$12,$13
    .byte $94,$83,$a4,$a5,$a4,$84,$85,$00,$00,$94,$95,$00,$00,$a4,$a5,$00
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$00,$80,$2e,$2f,$00,$00,$90,$3f
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$2c,$2d,$a2,$00,$3c,$b1,$00,$00
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$1e,$1f,$2c,$2d,$2e,$2f,$3c,$3d,$3e,$4c
    .byte $8e,$8f,$8e,$8f,$9e,$9f,$9e,$9f,$ae,$af,$9b,$89,$8c,$8d,$a8,$00
    .byte $f7,$0d,$f9,$0f,$1c,$1d,$1e,$1f,$f8,$2d,$fa,$2f,$3c,$3d,$3e,$3f
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$10,$1f,$2c,$2d,$a2,$00,$3c,$b1,$00,$00
    .byte $8e,$8f,$8e,$8f,$9e,$9f,$9e,$9f,$ae,$af,$ae,$af,$8c,$8d,$8c,$8d
    .byte $00,$00,$00,$00,$99,$ac,$ab,$99,$ae,$af,$ae,$af,$8c,$8d,$8c,$8d
    .byte $00,$00,$00,$ac,$99,$99,$ac,$9f,$ae,$9b,$89,$89,$9b,$00,$00,$00
    .byte $ab,$00,$00,$00,$9e,$ab,$99,$99,$ae,$af,$ae,$af,$8c,$8d,$8c,$8d
    .byte $00,$00,$00,$ac,$99,$99,$ac,$9f,$ae,$af,$ae,$af,$9c,$8d,$8c,$8d
    .byte $00,$00,$00,$00,$00,$00,$ac,$99,$00,$ac,$ae,$af,$00,$ac,$8c,$8d
    .byte $00,$00,$00,$00,$99,$00,$00,$00,$ae,$ab,$99,$00,$8c,$8d,$8c,$ab
    .byte $9b,$00,$0e,$0f,$00,$00,$10,$1f,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $8e,$8f,$a8,$00,$9e,$9f,$a8,$00,$ae,$af,$9b,$00,$8c,$9b,$00,$00
    .byte $8e,$8f,$a8,$00,$9e,$9f,$ab,$00,$ae,$af,$ae,$ab,$8c,$8d,$8c,$ab
    .byte $00,$00,$00,$00,$ac,$ab,$00,$00,$a9,$af,$ab,$00,$8c,$8d,$a8,$00
    .byte $00,$00,$84,$85,$00,$00,$94,$95,$ac,$00,$a4,$a5,$8c,$ab,$00,$00
    .byte $8e,$8f,$8e,$8f,$9e,$9f,$9e,$9f,$9b,$89,$89,$9c,$00,$00,$00,$00
    .byte $83,$85,$94,$95,$84,$85,$a4,$a5,$94,$95,$00,$00,$a4,$a5,$00,$00
    .byte $00,$00,$ac,$8f,$00,$00,$9c,$9f,$02,$04,$00,$9c,$12,$14,$00,$a9
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$02,$03,$12,$13,$12,$13
    .byte $0c,$0d,$00,$00,$1c,$1d,$00,$00,$2c,$2d,$9d,$9d,$3c,$3d,$ad,$ad
    .byte $00,$00,$0e,$0f,$00,$00,$10,$1f,$9d,$9d,$2e,$2f,$ad,$ad,$90,$3f
    .byte $02,$04,$00,$00,$12,$14,$00,$00,$2c,$2d,$9d,$9d,$3c,$3d,$ad,$ad
    .byte $00,$00,$01,$03,$00,$00,$11,$13,$9d,$9d,$2e,$2f,$ad,$ad,$90,$3f
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$9d,$9d,$9d,$9d,$ad,$ad,$ad,$ad
    .byte $ef,$63,$f0,$61,$72,$73,$70,$71,$02,$03,$02,$03,$12,$13,$12,$13
.ifdef Probotector
    ; Probotector's super-tiles match the Japanese version of the game
    .byte $ef,$63,$f0,$61,$72,$73,$70,$71,$f1,$43,$f2,$86,$52,$53,$50,$96 ; alien guardian wall shells
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$f1,$43,$fc,$86,$52,$53,$50,$96 ; alien guardian wall shells
.else
    ; Contra modified the shells to be more decrepit
    .byte $ef,$63,$f0,$61,$72,$73,$70,$71,$f1,$43,$f2,$fd,$52,$53,$50,$fe ; alien guardian wall shells
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$f1,$43,$fc,$fd,$52,$53,$50,$fe ; alien guardian wall shells
.endif
    .byte $00,$ac,$8e,$8f,$00,$9c,$9e,$9f,$00,$a9,$ae,$af,$00,$ac,$8c,$8d
.ifdef Probotector
    ; Probotector's super-tiles match the Japanese version of the game
    .byte $00,$00,$f0,$61,$00,$00,$70,$71,$02,$03,$f2,$41,$12,$13,$50,$51 ; alien guardian wall shells
.else
    ; Contra modified the shells to be more decrepit
    .byte $00,$00,$f0,$61,$00,$00,$70,$71,$02,$03,$f2,$fd,$12,$13,$50,$fe ; alien guardian wall shells
.endif
    .byte $00,$00,$f0,$61,$00,$00,$70,$71,$00,$00,$f2,$41,$00,$00,$50,$51
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fc,$41,$00,$00,$50,$51
    .byte $8e,$8f,$8e,$8f,$9e,$9f,$9e,$9f,$9c,$9c,$ae,$af,$00,$a9,$8c,$8d
    .byte $8e,$8f,$a8,$00,$9e,$9f,$9b,$00,$89,$a8,$00,$00,$00,$00,$00,$00
    .byte $8e,$8f,$8e,$8f,$9e,$9f,$9e,$9f,$ae,$9b,$89,$89,$9b,$00,$00,$00
    .byte $ab,$00,$00,$ac,$9e,$ab,$ac,$9f,$89,$89,$89,$89,$00,$00,$00,$00
    .byte $00,$a9,$8e,$8f,$00,$ac,$9e,$9f,$99,$af,$ae,$af,$8c,$8d,$8c,$8d
    .byte $00,$9c,$8e,$8f,$00,$a9,$9e,$9f,$00,$00,$89,$9c,$00,$00,$00,$00
    .byte $0c,$0d,$0e,$0f,$1c,$1d,$10,$1f,$00,$00,$00,$00,$00,$00,$00,$00

level_8_nametable_update_supertile_data:
    .byte $44,$45,$46,$47,$54,$55,$56,$57,$64,$65,$66,$67,$74,$75,$76,$77 ; #$00 - alien mouth (wadder) closed
    .byte $48,$49,$4a,$4b,$58,$59,$5a,$5b,$68,$69,$6a,$6b,$78,$79,$7a,$7b ; #$01 - alien mouth (wadder) open
    .byte $8e,$8f,$8e,$8f,$9e,$9b,$9c,$9f,$8e,$ab,$ac,$8f,$9e,$9f,$9e,$9f ; #$02 - alien mouth (wadder) destroyed
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$03 - blank super-tile
    .byte $cc,$a3,$ce,$cf,$dc,$dd,$de,$00,$ec,$ed,$ee,$b6,$bc,$bd,$be,$bf
    .byte $f3,$a3,$b0,$d9,$93,$d9,$da,$e9,$fb,$e9,$ea,$eb,$00,$c2,$c3,$bb
    .byte $d5,$d6,$d7,$00,$d6,$e6,$e7,$e8,$fe,$ff,$c0,$c1,$91,$92,$b9,$bf
    .byte $f3,$d2,$d3,$d4,$a0,$e2,$bb,$bc,$fb,$b9,$fe,$fd,$91,$92,$93,$00
    .byte $cc,$a3,$ce,$cf,$dc,$dd,$de,$00,$ec,$ed,$ee,$b6,$bc,$bd,$c8,$bf
    .byte $f3,$81,$b0,$d0,$93,$d0,$da,$e0,$fb,$e0,$ea,$eb,$00,$b7,$ba,$bb
    .byte $e5,$d6,$d8,$00,$d6,$e6,$c9,$e8,$c4,$c6,$c7,$c1,$91,$92,$b9,$bf
    .byte $f3,$d1,$e3,$e4,$a0,$e1,$bb,$bc,$fb,$b8,$c4,$c5,$82,$92,$a3,$00
    .byte $f3,$a3,$ce,$cf,$f3,$f3,$ca,$f3,$f3,$f3,$cb,$b6,$f3,$f3,$db,$bf
    .byte $f3,$a3,$b0,$f3,$93,$81,$f3,$f3,$fb,$f3,$f3,$f3,$f3,$f3,$f3,$f3
    .byte $f3,$f3,$f3,$f3,$f3,$f3,$cd,$e8,$f3,$f3,$df,$c1,$91,$92,$b9,$bf
    .byte $f3,$f3,$f3,$f3,$a0,$f3,$f3,$f3,$fb,$b0,$f3,$f3,$91,$92,$93,$f3
    .byte $e3,$d4,$d5,$c4,$aa,$e4,$e5,$cd,$b3,$b4,$b5,$b6,$c3,$db,$dc,$00 ; #$10 - alien guardian jaw mouth closed (top right)
    .byte $00,$e0,$e1,$e1,$00,$60,$40,$40,$00,$00,$8a,$8b,$00,$00,$c1,$c2 ; #$11 - alien guardian top teeth and lower left jaw mouth closed (top-left)
    .byte $e3,$d4,$d5,$c4,$df,$00,$62,$cd,$00,$dd,$de,$b6,$ec,$ed,$ee,$d2 ; #$12 - alien guardian jaw mouth open (top right)
    .byte $00,$e0,$e1,$e1,$00,$60,$40,$40,$00,$00,$00,$00,$00,$00,$00,$00 ; #$13 - alien guardian top teeth mouth open (top left)
    .byte $5c,$6c,$4d,$08,$bc,$bd,$be,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$14 - alien guardian lower jaw mouth open
    .byte $ca,$cb,$cc,$cd,$cb,$cc,$cd,$c5,$a7,$b9,$c5,$c6,$00,$00,$00,$00 ; #$15 - alien guardian body destroyed
    .byte $00,$c7,$c8,$c9,$00,$d6,$c9,$ca,$00,$00,$e6,$98,$00,$00,$00,$00 ; #$16 - alien guardian body destroyed
    .byte $b9,$bf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$17 - alien guardian body destroyed
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$c7,$00,$da,$c7,$c8
    .byte $00,$c7,$c8,$c9,$c7,$c8,$c9,$ca,$c8,$c9,$ca,$cb,$c9,$d8,$d9,$cc ; #$19 - alien guardian body
    .byte $ca,$cb,$cc,$cd,$cb,$cc,$cd,$c5,$cc,$cd,$c5,$c6,$cd,$c5,$c6,$00
    .byte $ce,$cf,$cd,$0f,$c6,$c6,$d7,$1f,$00,$00,$e7,$2f,$00,$e7,$c3,$3f
    .byte $00,$ea,$eb,$c9,$00,$97,$87,$ca,$00,$ba,$bb,$bb,$00,$d0,$d1,$d1
    .byte $ca,$e8,$e9,$cd,$d8,$b7,$00,$c5,$b7,$b8,$00,$c6,$d3,$c4,$c6,$00
    .byte $c5,$c6,$00,$00,$c6,$00,$00,$e7,$00,$00,$e7,$bf,$00,$e7,$d2,$00
    .byte $e7,$bf,$00,$00,$bf,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $e7,$c0,$e2,$00,$c0,$c3,$9a,$00,$dc,$00,$00,$00,$00,$00,$00,$00
    .byte $20,$21,$22,$23,$30,$31,$32,$33,$fb,$00,$92,$91,$92,$93,$a0,$a1 ; #$21 - alien spider spawn on ceiling closed (frame 1)
    .byte $24,$25,$26,$27,$34,$35,$36,$37,$fb,$f3,$92,$91,$92,$93,$a0,$a1 ; #$22 - alien spider spawn on ceiling open (frame 2)
    .byte $28,$29,$2a,$2b,$38,$39,$3a,$3b,$fb,$f3,$92,$91,$92,$93,$a0,$a1 ; #$23 - alien spider spawn on ceiling open (frame 3)
    .byte $20,$4e,$4f,$23,$00,$00,$00,$00,$fb,$f3,$92,$91,$92,$93,$a0,$a1 ; #$24 - destroyed alien spider spawn on ceiling
    .byte $f6,$09,$0a,$0b,$18,$19,$1a,$1b,$02,$03,$02,$03,$12,$13,$12,$13 ; #$25 - alien spider spawn on ground closed (frame 1)
    .byte $f5,$05,$06,$07,$5d,$15,$16,$17,$02,$03,$02,$03,$12,$13,$12,$13 ; #$26 - alien spider spawn on ground open (frame 2)
    .byte $f4,$6d,$6e,$6f,$7c,$7d,$7e,$7f,$02,$03,$02,$03,$12,$13,$12,$13 ; #$27 - alien spider spawn on ground open (frame 3)
    .byte $00,$00,$00,$00,$18,$5e,$5f,$1b,$02,$03,$02,$03,$12,$13,$12,$13 ; #$28 - destroyed alien spider spawn on ground
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$02,$03,$12,$13,$12,$13 ; #$29 - empty ground

; palette data - level 8 (#$73 bytes) ?? (not #$80 bytes)
level_8_palette_data:
    .byte $05,$05,$05,$05,$5f,$5f,$5f,$5f,$37,$cd,$7f,$df,$f3,$fc,$33,$cc
    .byte $f0,$00,$50,$70,$50,$50,$53,$ff,$00,$ff,$ff,$00,$33,$ff,$5f,$00
    .byte $00,$00,$00,$ff,$00,$00,$ff,$ff,$ff,$ff,$ff,$fc,$f3,$03,$ff,$ff
    .byte $f3,$30,$ff,$00,$dc,$50,$c0,$30,$c1,$34,$f0,$50,$00,$00,$ff,$10
    .byte $00,$00,$ff,$3f,$ff,$ff,$ff,$cf,$00

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_8_nametable_update_palette_data:
    .byte $aa,$aa,$00,$55,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$cf,$3f,$fc,$f3
    .byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$fa,$fa,$fa,$fa,$5a,$5a,$5a,$5a,$50,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00

; super-tile data - level 2/4 boss room
; CPU address $b57a
level_2_4_boss_supertile_data:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; #$00 - blank super-tile
    .byte $33,$07,$00,$00,$34,$07,$00,$09,$35,$07,$36,$00,$00,$07,$37,$00
    .byte $00,$20,$21,$01,$09,$20,$21,$01,$00,$20,$21,$01,$00,$20,$21,$02
    .byte $00,$08,$00,$a3,$a2,$a3,$a3,$a2,$00,$a3,$a2,$08,$30,$04,$04,$04
    .byte $00,$07,$38,$33,$00,$07,$00,$34,$00,$07,$00,$35,$00,$07,$00,$00
    .byte $00,$20,$21,$05,$00,$20,$21,$06,$00,$20,$21,$01,$00,$20,$21,$01
    .byte $31,$00,$00,$00,$31,$00,$00,$00,$31,$00,$00,$00,$31,$00,$00,$00
    .byte $00,$07,$00,$00,$00,$07,$00,$00,$00,$07,$00,$00,$00,$07,$00,$00
    .byte $00,$20,$21,$02,$00,$20,$21,$01,$0a,$20,$21,$01,$00,$20,$21,$02
    .byte $a2,$a3,$08,$a3,$00,$a3,$a3,$a2,$08,$a2,$a3,$00,$04,$04,$04,$04
    .byte $00,$00,$07,$00,$00,$00,$07,$00,$00,$00,$07,$00,$00,$00,$07,$00
    .byte $05,$51,$50,$00,$06,$51,$50,$00,$01,$51,$50,$00,$01,$51,$50,$00
    .byte $00,$00,$07,$00,$09,$00,$07,$00,$00,$00,$07,$00,$00,$00,$07,$00
    .byte $02,$51,$50,$00,$01,$51,$50,$09,$01,$51,$50,$00,$02,$51,$50,$00
    .byte $00,$08,$a2,$08,$a3,$a3,$00,$a3,$a3,$a2,$08,$a3,$04,$04,$04,$04
    .byte $a2,$a3,$00,$a2,$a3,$08,$a3,$08,$a2,$a3,$08,$00,$04,$04,$04,$60
    .byte $01,$51,$50,$00,$01,$51,$50,$00,$01,$51,$50,$00,$02,$51,$50,$00
    .byte $00,$00,$07,$63,$00,$00,$07,$64,$00,$66,$07,$65,$00,$67,$07,$00
    .byte $00,$00,$00,$61,$00,$00,$00,$61,$00,$00,$00,$61,$00,$00,$00,$61
    .byte $63,$68,$07,$00,$64,$00,$07,$00,$65,$00,$07,$00,$00,$00,$07,$00
    .byte $00,$20,$21,$01,$22,$23,$24,$02,$25,$26,$27,$9a,$28,$29,$2a,$9b
    .byte $2b,$2c,$2d,$10,$0c,$2e,$2f,$10,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$0e
    .byte $00,$07,$00,$00,$0c,$07,$0c,$0c,$0d,$07,$0d,$0d,$0e,$07,$0e,$0e
    .byte $10,$10,$10,$10,$10,$10,$10,$10,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$4a
    .byte $10,$10,$10,$10,$10,$10,$10,$10,$0d,$0d,$0d,$0d,$7a,$0e,$0e,$0e
    .byte $10,$10,$10,$10,$32,$03,$03,$03,$4b,$4d,$98,$98,$80,$81,$82,$83
    .byte $0f,$07,$0f,$0f,$0f,$07,$0f,$0f,$0f,$0f,$0f,$0f,$11,$11,$11,$11
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$11,$11,$11,$11
    .byte $10,$10,$10,$10,$03,$03,$03,$62,$98,$98,$7d,$7b,$84,$85,$85,$86
    .byte $01,$51,$50,$00,$02,$54,$53,$52,$9a,$57,$56,$55,$9b,$5a,$59,$58
    .byte $10,$5d,$5c,$5b,$10,$5f,$5e,$0c,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$0e
    .byte $00,$00,$07,$00,$0c,$0c,$07,$0c,$0d,$0d,$07,$0d,$0e,$0e,$07,$0e
    .byte $0f,$0f,$07,$0f,$0f,$0f,$07,$0f,$0f,$0f,$0f,$0f,$11,$11,$11,$11
    .byte $0f,$0f,$49,$87,$0f,$49,$4d,$98,$49,$4d,$98,$98,$11,$11,$11,$11
    .byte $88,$89,$8a,$8b,$98,$98,$90,$91,$98,$98,$94,$95,$11,$11,$11,$11
    .byte $8c,$8d,$8e,$8f,$92,$93,$98,$98,$95,$96,$98,$98,$11,$11,$11,$11
    .byte $7d,$79,$0f,$0f,$98,$7d,$79,$0f,$98,$98,$7d,$79,$11,$11,$11,$11
    .byte $0f,$7c,$07,$00,$0f,$0f,$07,$00,$0f,$0f,$0f,$7c,$0f,$0f,$0f,$0f
    .byte $9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$6d,$00,$07,$00
    .byte $97,$97,$7e,$7f,$a0,$9e,$9e,$6c,$09,$09,$09,$9d,$9e,$9e,$9e,$9f
    .byte $a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7,$a4,$a5,$a4,$a5,$a1,$45,$a1,$a1
    .byte $00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$3d
    .byte $7e,$7f,$97,$97,$3c,$9e,$9e,$a0,$9d,$09,$09,$09,$9f,$9e,$9e,$9e
    .byte $05,$97,$3c,$a0,$06,$97,$9d,$7e,$09,$09,$9d,$97,$9e,$9e,$9f,$9e
    .byte $00,$07,$00,$3c,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d
    .byte $9e,$9e,$9e,$9e,$97,$39,$3a,$3a,$97,$3b,$00,$00,$97,$3b,$00,$00
    .byte $4f,$4e,$9e,$a0,$3a,$3a,$3a,$3a,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $a0,$9e,$9e,$a0,$3a,$3a,$3a,$9c,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d
    .byte $97,$3b,$00,$00,$97,$3b,$00,$00,$39,$3a,$3a,$3a,$3b,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$3a,$3a,$3a,$3a,$00,$00,$00,$00
    .byte $a0,$6c,$97,$05,$9e,$9f,$97,$06,$7e,$7f,$09,$09,$9e,$9e,$9e,$9e
    .byte $46,$00,$a4,$a5,$43,$00,$a6,$a7,$43,$00,$a4,$a5,$43,$00,$a6,$a7
    .byte $a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $9e,$9e,$a0,$9e,$a0,$3c,$9e,$9e,$09,$9d,$7e,$7f,$9e,$6d,$97,$a0
    .byte $00,$07,$00,$3e,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d
    .byte $9e,$9e,$9e,$47,$3f,$48,$48,$40,$42,$00,$00,$41,$43,$00,$00,$00
    .byte $a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7,$a4,$a5,$a4,$a5,$a1,$a1,$75,$a1
    .byte $a4,$a5,$00,$73,$a6,$a7,$00,$73,$a4,$a5,$00,$73,$a1,$a1,$a1,$74
    .byte $a0,$9e,$9e,$a0,$9c,$6a,$6a,$6a,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $a0,$9e,$4f,$4e,$6a,$6a,$6a,$6a,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $9e,$9e,$9e,$9e,$6a,$6a,$69,$97,$00,$00,$6b,$97,$00,$00,$6b,$97
    .byte $6c,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00
    .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$6a,$6a,$6a,$6a,$00,$00,$00,$00
    .byte $00,$00,$6b,$97,$00,$00,$6b,$97,$6a,$6a,$6a,$69,$00,$00,$00,$6b
    .byte $9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00
    .byte $00,$07,$4c,$0f,$00,$07,$0f,$0f,$4c,$0f,$0f,$0f,$0f,$0f,$0f,$0f
    .byte $a4,$a5,$00,$76,$a6,$a7,$00,$73,$a4,$a5,$00,$73,$a6,$a7,$00,$73
    .byte $9e,$a0,$9e,$9e,$7f,$97,$a0,$9d,$7e,$7f,$09,$9d,$a0,$97,$9e,$9f
    .byte $77,$9e,$9e,$9e,$70,$78,$78,$6f,$71,$00,$00,$76,$00,$00,$00,$73
    .byte $6e,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00,$9d,$00,$07,$00
    .byte $43,$00,$a4,$a5,$43,$00,$a6,$a7,$43,$00,$a4,$a5,$44,$a1,$a1,$a1
    .byte $a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7,$a4,$a5,$a4,$a5,$a1,$45,$a1,$a1

level_2_4_nametable_update_supertile_data:
    .byte $12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$a8,$a9 ; closed wall cannon
    .byte $12,$aa,$ab,$15,$c1,$ae,$af,$c2,$b2,$b3,$b4,$b5,$b9,$ba,$bb,$bc ; partial open wall cannon
    .byte $12,$ac,$ad,$15,$c1,$b0,$b1,$c2,$b2,$b6,$b7,$b8,$bd,$be,$bf,$c0 ; fully open wall cannon
    .byte $12,$aa,$ab,$15,$c1,$c3,$c4,$c2,$c7,$c8,$c9,$ca,$b9,$ba,$bb,$bc ; wall plating #$01
    .byte $12,$ac,$ad,$15,$c1,$c5,$c6,$c2,$c7,$cb,$cc,$cd,$bd,$be,$bf,$c0 ; wall plating #$02
    .byte $ce,$cf,$d0,$d1,$d2,$00,$00,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db ; destroyed wall plating
    .byte $a4,$a5,$1a,$1b,$a6,$a7,$1e,$1f,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $a4,$a5,$b2,$b3,$a6,$a7,$b9,$ba,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $a4,$a5,$b2,$b6,$a6,$a7,$bd,$be,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $9e,$9e,$12,$13,$9e,$47,$16,$17,$48,$40,$1a,$1b,$00,$41,$1e,$1f
    .byte $9e,$9e,$12,$aa,$9e,$47,$c1,$c3,$48,$40,$c7,$c8,$00,$41,$b9,$ba
    .byte $9e,$9e,$12,$ac,$9e,$47,$c1,$c5,$48,$40,$c7,$cb,$00,$41,$bd,$be
    .byte $14,$15,$9e,$9e,$18,$19,$77,$9e,$1c,$1d,$70,$78,$a8,$a9,$71,$00
    .byte $ab,$15,$9e,$9e,$c4,$c2,$77,$9e,$c9,$ca,$70,$78,$bb,$bc,$71,$00
    .byte $ad,$15,$9e,$9e,$c6,$c2,$77,$9e,$cc,$cd,$70,$78,$bf,$c0,$71,$00
    .byte $0b,$0b,$0b,$0b,$09,$09,$09,$09,$12,$13,$14,$15,$16,$17,$18,$19
    .byte $0b,$0b,$0b,$0b,$09,$09,$09,$09,$12,$aa,$ab,$15,$c1,$c3,$c4,$c2
    .byte $0b,$0b,$0b,$0b,$09,$09,$09,$09,$12,$ac,$ad,$15,$c1,$c5,$c6,$c2
    .byte $1a,$1b,$1c,$1d,$1e,$1f,$a8,$a9,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $c7,$c8,$c9,$ca,$b9,$ba,$bb,$bc,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $c7,$cb,$cc,$cd,$bd,$be,$bf,$c0,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$14,$15,$6a,$6a,$18,$19,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$ab,$15,$6a,$6a,$af,$19,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$ad,$15,$6a,$6a,$b1,$19,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$3a,$3a,$12,$13,$00,$00,$16,$17
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$3a,$3a,$12,$aa,$00,$00,$16,$ae
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$3a,$3a,$12,$ac,$00,$00,$16,$b0
    .byte $0b,$0b,$0b,$0b,$09,$09,$7e,$7f,$14,$15,$9e,$9e,$18,$19,$01,$01
    .byte $0b,$0b,$0b,$0b,$09,$09,$7e,$7f,$ab,$15,$9e,$9e,$c4,$c2,$01,$01
    .byte $0b,$0b,$0b,$0b,$09,$09,$7e,$7f,$ad,$15,$9e,$9e,$c6,$c2,$01,$01
    .byte $1c,$1d,$a4,$a5,$a8,$a9,$a6,$a7,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $b4,$b5,$a4,$a5,$bb,$bc,$a6,$a7,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $b7,$b8,$a4,$a5,$bf,$c0,$a6,$a7,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $1c,$1d,$a0,$a0,$a8,$a9,$0a,$0a,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $c9,$ca,$a0,$a0,$bb,$bc,$0a,$0a,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $cc,$cd,$a0,$a0,$bf,$c0,$0a,$0a,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $a0,$a0,$1a,$1b,$0a,$0a,$1e,$1f,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $a0,$a0,$c7,$c8,$0a,$0a,$b9,$ba,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $a0,$a0,$c7,$cb,$0a,$0a,$bd,$be,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $0b,$0b,$0b,$0b,$7e,$7f,$09,$09,$9e,$9e,$12,$13,$01,$01,$16,$17
    .byte $0b,$0b,$0b,$0b,$7e,$7f,$09,$09,$9e,$9e,$12,$aa,$00,$00,$c1,$c3
    .byte $0b,$0b,$0b,$0b,$7e,$7f,$09,$09,$9e,$9e,$12,$ac,$00,$00,$c1,$c5
    .byte $a4,$a5,$d4,$d5,$a6,$a7,$d8,$d9,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $9e,$9e,$ce,$cf,$9e,$47,$d2,$00,$48,$40,$d4,$d5,$00,$41,$d8,$d9
    .byte $d0,$d1,$9e,$9e,$00,$d3,$77,$9e,$d6,$d7,$70,$00,$da,$db,$71,$00
    .byte $0b,$0b,$0b,$0b,$09,$09,$09,$09,$ce,$cf,$d0,$d1,$d2,$00,$00,$d3
    .byte $d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$d0,$d1,$6a,$6a,$00,$d3,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$3a,$3a,$ce,$cf,$00,$00,$d2,$00
    .byte $0b,$0b,$0b,$0b,$09,$09,$7e,$7f,$d0,$d1,$9e,$9e,$00,$d3,$01,$01
    .byte $d6,$d7,$a4,$a5,$da,$db,$a6,$a7,$a4,$a5,$a4,$a5,$a6,$a7,$a6,$a7
    .byte $d6,$d7,$a0,$a0,$da,$db,$0a,$0a,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $a0,$a0,$d4,$d5,$0a,$0a,$d8,$d9,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b
    .byte $0b,$0b,$0b,$0b,$7e,$7f,$09,$09,$9e,$9e,$ce,$cf,$01,$01,$d2,$00

; color data for level 2 boss room (#$80 bytes)
level_2_4_boss_palette_data:
    .byte $00,$04,$55,$5f,$11,$55,$11,$11,$55,$5e,$44,$55,$45,$55,$5e,$5b
    .byte $55,$00,$44,$44,$55,$04,$00,$05,$05,$45,$00,$00,$15,$55,$01,$00
    .byte $00,$00,$05,$05,$00,$04,$55,$55,$00,$55,$55,$55,$55,$15,$05,$05
    .byte $55,$55,$50,$55,$11,$00,$55,$55,$55,$00,$00,$05,$05,$45,$55,$00
    .byte $50,$54,$55,$01,$44,$55,$55,$55,$01,$00

; each byte is the palette for an entire super-tile
; updates values in the attribute table
level_2_4_boss_nametable_update_palette_data:
    .byte $af,$af,$af,$af,$af,$55,$08,$08,$08,$9d,$9d,$9d,$67,$67,$67,$f5
    .byte $f5,$f5,$5a,$5a,$5a,$70,$70,$70,$d0,$d0,$d0,$75,$75,$75,$02,$02
    .byte $02,$56,$56,$56,$59,$59,$59,$d5,$d5,$d5,$04,$55,$55,$55,$55,$50
    .byte $50,$55,$01,$55,$55,$55

run_end_level_sequence_routine:
    lda #$00                       ; a = #$00
    sta CONTROLLER_STATE           ; clear player 1 input
    sta CONTROLLER_STATE+1         ; clear player 2 input
    sta CONTROLLER_STATE_DIFF      ; clear player 1 input difference
    sta CONTROLLER_STATE_DIFF+1    ; clear player 2 input difference
    lda END_LEVEL_ROUTINE_INDEX    ; load end_level_sequence_ptr_tbl index to jump to
    jsr run_routine_from_tbl_below ; run routine a in the following table (end_level_sequence_ptr_tbl)

; pointer table for end of level sequences (#$3 * #$2 = #$6 bytes)
; CPU address $be09
end_level_sequence_ptr_tbl:
    .addr end_level_sequence_00 ; CPU address $be0f
    .addr end_level_sequence_01 ; CPU address $be3c
    .addr end_level_sequence_02 ; CPU address $bf78

; wait for both players to land from jumping to initiate sequence
end_level_sequence_00:
    lda #$00 ; a = #$00
    sta $08  ; initialize jump status check
    ldx #$01 ; start with player 2

@player_loop:
    lda #$00                  ; a = #$00
    ldy P1_GAME_OVER_STATUS,x ; game over state (1 = game over)
    bne @move_next_player     ; skip player if in game over state
    lda PLAYER_JUMP_STATUS,x  ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    ora $08                   ; merge players' jump status
    sta $08                   ; update with merged jump status
    lda #$01                  ; a = #$01

@move_next_player:
    sta LEVEL_END_LVL_ROUTINE_STATE,x ; set to #$01
    dex                               ; decrement player index
    bpl @player_loop                  ; if not already on player 1, move to player 1
    lda $08                           ; load merged jump status
    beq @continue                     ; if 0, neither player is jumping, branch
    rts                               ; one of the players is jumping, don't begin ending sequence

; players are on the ground, move to end_level_sequence_01
@continue:
    lda #$81                  ; a = #$81
    sta BOSS_DEFEATED_FLAG
    lda #$f0                  ; a = #$f0
    sta LEVEL_END_SQ_1_TIMER
    lda #$20                  ; a = #$20
    jmp set_delay_adv_routine ; set LEVEL_END_DELAY_TIMER to #$20 and advance to end_level_sequence_01

; CPU address $be3c
end_level_sequence_01:
    lda LEVEL_END_DELAY_TIMER ; load level ending sequence delay timer
    beq @continue             ; continue if elapsed
    dec LEVEL_END_DELAY_TIMER ; timer hasn't elapsed, decrement and exit
    rts

@continue:
    ldx #$01 ; x = #$01

@player_lvl_routine_loop:
    ldy LEVEL_END_LVL_ROUTINE_STATE,x
    beq @continue2
    dey                                       ; decrement level routine state index
    sty $08                                   ; store LEVEL_END_LVL_ROUTINE_STATE in $08
    jsr run_end_of_lvl_lvl_routine
    jsr make_off_screen_player_invisible_exit ; make invisible if necessary and exit

@continue2:
    dex
    bpl @player_lvl_routine_loop
    lda FRAME_COUNTER                ; load frame counter
    lsr
    bcc @set_0192_exit
    dec LEVEL_END_SQ_1_TIMER
    beq @set_level_delay_adv_routine

@set_0192_exit:
    lda LEVEL_END_LVL_ROUTINE_STATE
    ora LEVEL_END_LVL_ROUTINE_STATE+1 ; set player 2 value
    bne end_level_sequence_01_exit

@set_level_delay_adv_routine:
    ldy CURRENT_LEVEL                     ; current level
    lda level_end_level_delay_timer_tbl,y

set_delay_adv_routine:
    sta LEVEL_END_DELAY_TIMER
    inc END_LEVEL_ROUTINE_INDEX ; go to next method in end_level_sequence_ptr_tbl

end_level_sequence_01_exit:
    rts

; table for delay timer used in level-specif ending routines (#$8 bytes)
; waterfall is the only different value at #$e0
level_end_level_delay_timer_tbl:
    .byte $a0,$a0,$e0,$a0,$a0,$a0,$a0,$a0

; runs the routines for handling end of level
; input
;  * $08 - LEVEL_END_LVL_ROUTINE_STATE
run_end_of_lvl_lvl_routine:
    lda CURRENT_LEVEL              ; current level
    jsr run_routine_from_tbl_below ; run routine a in the following table (end_of_lvl_lvl_routine_ptr_tbl)

; end of level routines (#$8 * #$2 = #$10 bytes)
end_of_lvl_lvl_routine_ptr_tbl:
    .addr end_of_lvl_routine_lvl_1  ; CPU address $be92
    .addr end_of_lvl_routine_indoor ; CPU address $bec4
    .addr end_of_lvl_routine_lvl_3  ; CPU address $bf13
    .addr end_of_lvl_routine_indoor ; CPU address $bec4
    .addr end_of_lvl_routine_lvl_5  ; CPU address $bf4c
    .addr end_of_lvl_routine_lvl_6  ; CPU address $bf63
    .addr end_of_lvl_routine_lvl_7  ; CPU address $bf67
    .addr end_of_lvl_routine_lvl_8  ; CPU address $bf6b

; end of level 1
; animate moving player right until enter tunnel
; 3 states
; * #$00 - walk to the right
; * #$01 - jump to the right
; * #$02 - walk to the right
end_of_lvl_routine_lvl_1:
    lda SPRITE_X_POS,x ; player x position on screen
    cmp #$98           ; see where the player is at horizontally
    lda #$00           ; a = #$00
    bcc @continue      ; branch if player is in the left 60% of the screen
    lda #$80           ; player close to right edge, set background priority for player sprite

@continue:
    sta PLAYER_BG_FLAG_EDGE_DETECT,x ; set player sprite attribute so background takes priority
    ldy $08                          ; load LEVEL_END_LVL_ROUTINE_STATE
    bne end_of_lvl_routine_lvl_1_01  ; branch if player should jump into the tunnel (state #$01)
    jsr press_d_pad_right            ; press the d-pad right button to move the player to the right
    lda SPRITE_X_POS,x               ; player x position on screen
    cmp #$90                         ; trigger point to jump into tunnel
    bcc routine_lvl_1_exit           ; branch if not yet reached jump trigger point

routine_lvl_1_adv_lvl_state_exit:
    inc LEVEL_END_LVL_ROUTINE_STATE,x

routine_lvl_1_exit:
    rts

end_of_lvl_routine_lvl_1_01:
    dey
    bne press_d_pad_right                ; branch to press the d-pad right button to move the player to the right (state #$02)
    lda PLAYER_JUMP_STATUS,x             ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    bne routine_lvl_1_adv_lvl_state_exit ; exit if jump already started
    lda #$81                             ; need to jump, set controller input A button and right arrow button pressed
    sta CONTROLLER_STATE,x               ; store this value into player input
    sta $f5,x                            ; store this value into player input
    rts

; press the d-pad right button to move the player to the right
press_d_pad_right:
    lda #$01               ; controller input D-pad right arrow
    sta CONTROLLER_STATE,x ; store this value into player input
    rts

; indoor/base (level 2 and 4) end of level routine
end_of_lvl_routine_indoor:
    ldy $08                           ; load current LEVEL_END_LVL_ROUTINE_STATE
    bne end_of_lvl_routine_indoor_01  ; see if in state #$01
    lda indoor_lvl_end_input_tbl,x    ; state #$00 - load the appropriate d-pad input based on current player (left or right)
    sta CONTROLLER_STATE,x            ; controller buttons held
    lda SPRITE_X_POS,x                ; player x position on screen
    sec                               ; set carry flag in preparation for subtraction
    sbc indoor_lvl_elevator_pos_tbl,x ; subtract elevator x position from player x position
    bcs @cmp_elevator_distance        ; branch if player to the right of the elevator
    eor #$ff                          ; to the left of the elevator (negative result), flip all bits and add 1 (two's complement)
    adc #$01                          ; to get a positive number (the distance to the elevator)

@cmp_elevator_distance:
    cmp #$02                    ; see if within 2 pixels of elevator
    bcs routine_indoor_lvl_exit ; not near elevator, exit

routine_indoor_lvl_adv_lvl_state_exit:
    inc LEVEL_END_LVL_ROUTINE_STATE,x

routine_indoor_lvl_exit:
    rts

end_of_lvl_routine_indoor_01:
    dey                                       ; test next LEVEL_END_LVL_ROUTINE_STATE
    bne end_of_lvl_routine_indoor_02          ; branch if not in state #$01
    lda #$03                                  ; state #$01 - load a = #$03
    sta PLAYER_STATE,x                        ; set player can't move state
    lda indoor_lvl_elevator_attr_tbl,x        ; load the correct sprite attribute (color) for the player
    sta SPRITE_ATTR,x                         ; set the sprite attribute in the sprite cpu buffer
    jsr set_player_on_elevator_sprite         ; set the elevator sprite code in the sprite cpu buffer
    bne routine_indoor_lvl_adv_lvl_state_exit ; always jump, move to next level state and then exit

; wait for other player to get on elevator
end_of_lvl_routine_indoor_02:
    dey                                       ; test next LEVEL_END_LVL_ROUTINE_STATE
    bne end_of_lvl_routine_indoor_03          ; branch if not in state #$02
    stx $10                                   ; state #$02, see which LEVEL_END_LVL_ROUTINE_STATE the other player is in, backup current x
    txa                                       ; move x to a so can flip bit 0
    eor #$01                                  ; swap to other player's state
    tax                                       ; move other player offset to x
    lda LEVEL_END_LVL_ROUTINE_STATE,x         ; load other player's LEVEL_END_LVL_ROUTINE_STATE
    ldx $10                                   ; restore player offset back to original player
    tay                                       ; move other player LEVEL_END_LVL_ROUTINE_STATE to y
    beq routine_indoor_lvl_adv_lvl_state_exit ; branch if other player is in state #$00, i.e. player 2 not playing
    cmp #$03                                  ; compare other player's state to #$03
    bcs routine_indoor_lvl_adv_lvl_state_exit ; branch and move to state #$03 if other player is also on elevator (in state #$02)
    rts

; ride the elevator up
end_of_lvl_routine_indoor_03:
    dec SPRITE_Y_POS,x ; move player and elevator up

; set player on elevator sprite in cpu sprite memory
set_player_on_elevator_sprite:
    lda #$91                ; player on elevator sprite code sprite_91
    sta CPU_SPRITE_BUFFER,x ; ensure sprite code is set
    rts

; end of level 3
; 2 states
; * walk to middle of screen (dragon gate)
; * jump into gate
end_of_lvl_routine_lvl_3:
    ldy $08                         ; load current LEVEL_END_LVL_ROUTINE_STATE
    bne end_of_lvl_routine_lvl_3_01
    lda #$01                        ; controller input D-pad right arrow
    ldy SPRITE_X_POS,x              ; load player horizontal position
    cpy #$80                        ; see where player is in relation to middle of screen
    bcc @continue                   ; branch if player to the left of the middle
    lda #$02                        ; player to the right or in middle of screen, set controller input D-pad left arrow

@continue:
    sta CONTROLLER_STATE,x ; set controller input (eight left or right)
    tya                    ; move player x position to a
    sec                    ; set carry flag in preparation for subtraction
    sbc #$80               ; subtract #$80 to get distance from middle of screen
    bcs @cmp_dist          ; result is not negative, continue to compare distance to middle of screen
    eor #$ff               ; player to left of middle, (negative result), flip all bits and add 1 (two's complement)
    adc #$01               ; to get a positive number (the distance to the middle)

@cmp_dist:
    cmp #$08                          ; see if within 8 pixels of the middle of the screen horizontally
    bcs routine_lvl_3_exit            ; not yet close to center, exit
    inc LEVEL_END_LVL_ROUTINE_STATE,x ; can now jump into dragon gate

routine_lvl_3_exit:
    rts

; jump into dragon gate
end_of_lvl_routine_lvl_3_01:
    lda #$80                     ; controller A button pressed (jump)
    sta CONTROLLER_STATE_DIFF,x  ; store as new input
    lda PLAYER_JUMP_STATUS,x     ; low nibble 1 = jumping, 0 not jumping; high nibble = facing direction
    beq routine_lvl_3_exit       ; exit if just starting the jump
    lda PLAYER_Y_FAST_VELOCITY,x ; get current jump velocity
    bmi routine_lvl_3_exit       ; exit if still jumping up (not falling back down)
    lda SPRITE_Y_POS,x           ; falling back down, see if should hide player behind wall yet
    cmp #$b0                     ; compare to height of wall below dragon gate
    bcc routine_lvl_3_exit       ; exit if not yet fallen down to the top of the wall
    jmp make_player_invisible    ; falling 'behind' wall, make player invisible to simulate effect

; end of level 5
end_of_lvl_routine_lvl_5:
    ldy #$00 ; y = #$00

; move the player right and set PLAYER_BG_FLAG_EDGE_DETECT appropriate based on x position
; x trigger position based on x_pos_bg_priority_trigger_tbl,y
; input
;  * y - offset into x_pos_bg_priority_trigger_tbl
move_right_set_bg_priority:
    jsr press_d_pad_right               ; press the d-pad right button to move the player to the right
    lda SPRITE_X_POS,x                  ; load player's x position
    cmp x_pos_bg_priority_trigger_tbl,y ; see if player has crossed trigger point to put player in background
    lda #$01                            ; always set bit 0 (player continues walking off horizontally off ledge)
    bcc @set_bg_priority_exit           ; branch if player x position is to left of x_pos_bg_priority_trigger_tbl position
    ora #$80                            ; set bit 7 to specify sprite draws behind background

@set_bg_priority_exit:
    sta PLAYER_BG_FLAG_EDGE_DETECT,x
    rts

; table for horizontal trigger points for setting PLAYER_BG_FLAG_EDGE_DETECT (#$3 bytes)
; byte 0 - level 5 (snow field)
; byte 1 - level 6 (energy zone)
; byte 2 - level 7 (hangar)
x_pos_bg_priority_trigger_tbl:
    .byte $b8,$d0,$d0

; end of level 6
end_of_lvl_routine_lvl_6:
    ldy #$01                       ; y = #$01
    bne move_right_set_bg_priority

; end of level 7
end_of_lvl_routine_lvl_7:
    ldy #$02                       ; y = #$02
    bne move_right_set_bg_priority

; end of level 8
end_of_lvl_routine_lvl_8:
    ldy $08
    bne @exit
    lda #$40                          ; a = #$40
    sta LEVEL_END_SQ_1_TIMER
    inc LEVEL_END_LVL_ROUTINE_STATE,x

@exit:
    rts

; mark end of level routines as complete and move to level_routine_05
end_level_sequence_02:
    lda #$02                           ; a = #$02
    sta BOSS_DEFEATED_FLAG
    dec LEVEL_END_DELAY_TIMER
    bne @exit                          ; exit if level end delay timer hasn't elapsed
    jsr set_graphics_zero_mode         ; set GRAPHICS_BUFFER_MODE to #$00 to prepare writing text to screen (write_text_palette_to_mem)
    lda #$05                           ; a = #$05
    jmp set_a_as_current_level_routine ; set current level_routine to level_routine_05

@exit:
    rts

; make the player invisible if off the screen to the right, or off screen to the top
make_off_screen_player_invisible_exit:
    lda SPRITE_Y_POS,x
    cmp #$08
    bcc make_player_invisible      ; branch if player at top of screen
    lda SPRITE_X_POS,x
    cmp #$f8
    bcs make_player_invisible      ; branch if player at right edge of screen
    cmp #$04
    bcs end_level_sequence_02_exit ; exit if player not at left edge of screen

make_player_invisible:
    lda #$ff                          ; a = #$ff
    sta PLAYER_HIDDEN,x               ; set player to be invisible
    lda #$00
    sta LEVEL_END_LVL_ROUTINE_STATE,x
    sta PLAYER_SPRITES,x              ; clear player sprite

end_level_sequence_02_exit:
    rts

; tables for end of indoor/base level 2/4
; player 1 walks to the left elevator - d-pad left (#$02)
; player 2 walks to the right elevator - d-pad right right (#$01)
; controller input - player 1/2 (#$2 bytes)
indoor_lvl_end_input_tbl:
    .byte $02,$01

; x position for elevator (#$02 bytes)
indoor_lvl_elevator_pos_tbl:
    .byte $0c,$f4

; table for sprite attribute for being on elevator (#$2 bytes)
; sprite_91 - indoor boss defeated elevator with player on top
; byte 0 is for player 1, byte 1 is for player 2
indoor_lvl_elevator_attr_tbl:
    .byte $00,$45

; unused #$51 bytes out of #$4,000 bytes total (99.51% full)
; unused 81 bytes out of 16,384 bytes total (99.51% full)
; filled with 81 #$ff bytes by contra.cfg configuration
bank_3_unused_space: