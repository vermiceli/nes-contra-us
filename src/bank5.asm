; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 5 mostly contains compressed graphic data.  The rest of bank 5 is the
; code and lookup tables for automated input for the 3 demo (attract) levels.

.segment "BANK_5"

.include "constants.asm"

; export labels used by bank 7
.export load_demo_input_table
.export graphic_data_05, graphic_data_07
.export graphic_data_0b, graphic_data_14
.export graphic_data_17, graphic_data_18
.export graphic_data_19, graphic_data_1a

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $05 ; The PRG ROM bank number (5)

; compressed graphics data - Code 05 (#$A60 bytes)
; Level 1 bridge, mountain, and water tiles
; writes to same PPU addresses as graphic_data_07 and graphic_data_0b
; pattern table data - writes addresses
; * [$09a0-$0a80)
; * [$0dc0-$1200)
; * [$1320-$1600)
; * [$1bd0-$2000)
; CPU address $8001
graphic_data_05:
    .incbin "assets/graphic_data/graphic_data_05.bin"

; compressed graphics data - Code 07 (#$97F bytes)
; level 3
; writes to same PPU addresses as graphic_data_05 and graphic_data_0b
; pattern table data - writes addresses
; * [$09a0-$0a80)
; * [$0dc0-$1200)
; * [$1320-$1600)
; * [$1bd0-$2000)
; CPU address $8a61
graphic_data_07:
    .incbin "assets/graphic_data/graphic_data_07.bin"

; compressed graphics data - Code 0B (#$f3b bytes)
; CPU address $93e0
; pattern table data - writes addresses
; * [$09a0-$0a80)
; * [$0dc0-$1200)
; * [$1320-$1600)
; * [$1bd0-$2000)
graphic_data_0b:
    .incbin "assets/graphic_data/graphic_data_0b.bin"

; compressed graphics data - Code 19 (#$1e5 bytes)
; left pattern table data - writes addresses [$0680-$08c0)
; player killed sprite tiles: recoil from hit and lying on ground
; CPU address $a31b
graphic_data_19:
    .incbin "assets/graphic_data/graphic_data_19.bin"

; compressed graphics data - Code 1A (#$314 bytes)
; left pattern table data - writes addresses [$0a80-$0dc0)
; CPU address $a500
graphic_data_1a:
    .incbin "assets/graphic_data/graphic_data_1a.bin"

; compressed graphics data - Code 14 (#$5cb bytes)
; rotating gun and red turret
; right pattern table data - writes addresses [$1600-$1bd0)
; CPU address $a814
graphic_data_14:
    .incbin "assets/graphic_data/graphic_data_14.bin"

; compressed graphics data - Code 17 (#$52e bytes)
; End Scene
; pattern table data - writes addresses
; * [$0a60-$0fe0)
; * [$15b0-$18a0)
; CPU address $addf
graphic_data_17:
    .incbin "assets/graphic_data/graphic_data_17.bin"

; compressed graphics data - Code 18 (#$51 bytes)
; nametable data - writes addresses [$2000-$2400)
; CPU address $b30d
graphic_data_18:
    .incbin "assets/graphic_data/graphic_data_18.bin"

; simulates player input for demo levels for both players
; begins firing after #$e0 frames (see DEMO_FIRE_DELAY_TIMER)
load_demo_input_table:
    lda CONTROLLER_STATE_DIFF ; get player input
    and #$30                  ; start and select button
    bne end_demo_level        ; exit demo if player has pressed start or select
    inc DEMO_FIRE_DELAY_TIMER ; starts at 0 increments to #$ff and stops
                              ; used by demo logic to wait #$e0 frames until begin firing
    bne @player_loop          ; branch when DEMO_FIRE_DELAY_TIMER is not 0 (hasn't wrapped around)
    dec DEMO_FIRE_DELAY_TIMER ; wrapped around, pin to #$ff

@player_loop:
    ldx #$01 ; initialize X to 1 (player loop starting at player 2)

; sets values specific for demo player input
; x is player number, starts at 1 and goes to 0
; $2c stores the temporary value of A before
set_player_demo_input:
    lda FRAME_COUNTER                ; frame counter
    lsr                              ; shift right, pushing lsb (0th bit) to carry flag
    bcc @continue                    ; skip for even-numbered frames, don't decrement DEMO_INPUT_NUM_FRAMES
    lda DEMO_INPUT_NUM_FRAMES,x      ; load into accumulator the number of frames for the demo input table
    bne @dec_input_frame_count       ; if number of frames from previous input hasn't completed, then skip reading next input instruction
    lda CURRENT_LEVEL                ; current the current level
    asl                              ; each entry in demo_input_pointer_table is 2 bytes, so double
    asl                              ; since each level has 2 entries (1 for each player), double again. This determines the player 1 entry for the level
    sta $08                          ; store demo_input_pointer_table entry offset into $08
    txa                              ; move player number to A
    asl                              ; if player 1, nothing happens, but if player 2, then double offset since each entry is #$2 bytes
    adc $08                          ; add result to demo_input_pointer_table entry offset into $08 to get player-specific offset
    tay                              ; move result to Y
    lda demo_input_pointer_table,y   ; read low byte of input pointer table
    sta $08                          ; store pointer address value in $08
    lda demo_input_pointer_table+1,y ; load high byte of input pointer table (demo_input_pointer_table + 1)
    sta $09                          ; store pointer address value in $09
    ldy DEMO_INPUT_TBL_INDEX,x       ; the offset into demo_input_tbl_lX_pX of to read
    lda ($08),y                      ; load the 1-byte controller input from the 2-byte address
                                     ; ($08 and $09) from the input table offset by Y
                                     ; this is indirect indexed addressing mode
    cmp #$ff                         ; #$ff signals end of demo input
    beq end_demo_level               ; set DEMO_LEVEL_END_FLAG to #$01 and exit if we've read $ff byte (end of code)
    sta DEMO_INPUT_VAL,x             ; store the controller input for the demo input table
    iny                              ; increment 1 to get the number of frames
    lda ($08),y                      ; load the 1-byte number of frames to use input from the 2-byte address
                                     ; ($08 and $09) from the input table offset by Y
                                     ; this is indirect indexed addressing mode
    sta DEMO_INPUT_NUM_FRAMES,x      ; store the number of frames for the input
    iny                              ; increment table read offset
    tya
    sta DEMO_INPUT_TBL_INDEX,x       ; increment byte read offset into demo_input_tbl_lX_pX

@dec_input_frame_count:
    dec DEMO_INPUT_NUM_FRAMES,x ; decrement number of frames to press input

@continue:
    lda DEMO_INPUT_VAL,x             ; read controller input to execute
    sta CONTROLLER_STATE_DIFF,x      ; store controller input as new input
    sta CONTROLLER_STATE,x           ; store controller input
    lda DEMO_FIRE_DELAY_TIMER        ; load delay timer before firing weapon
    cmp #$50                         ; wait #$50 frames before firing weapon
    bcc player_demo_input_chg_player ; move to next player if DEMO_FIRE_DELAY_TIMER < #$50
    lda P1_CURRENT_WEAPON,x          ; get current player's weapon
    and #$0f                         ; strip out rapid fire flag
    cmp #$01                         ; see if current weapon is machine gun
    beq @m_or_laser                  ; branch if M weapon
    cmp #$04                         ; see if laser
    bne @fire_weapon_input           ; branch if not laser

; hold down b button for m or laser weapon during demo
@m_or_laser:
    lda CONTROLLER_STATE,x
    ora #$40                         ; set 6th bit to 1 (b button), this is used later in run_create_bullet_routine (bank 6)
    sta CONTROLLER_STATE,x           ; save toggled flag back to CONTROLLER_STATE
    bne player_demo_input_chg_player ; go to next player (always jumps due to ora instruction)

; for non M, nor L weapon, press b button every #$07 frames
@fire_weapon_input:
    lda FRAME_COUNTER                ; load frame counter
    and #$07                         ; checking every 8th frame
    bne player_demo_input_chg_player ; move to next player without firing weapon
    lda CONTROLLER_STATE_DIFF,x      ; load current controller input
    ora #$40                         ; press b button
    sta CONTROLLER_STATE_DIFF,x      ; store input

player_demo_input_chg_player:
    dex                       ; go from player 2 to player 1
    bpl set_player_demo_input ; continue loop until x is 0
    rts                       ; x is 0, done

; finished reading all of demo data, end demo for level
end_demo_level:
    inc DEMO_LEVEL_END_FLAG ; set demo end flag to #$01
    rts

; pointer table for demo inputs #$06 * #$02 = #$0c bytes
; contains the memory addresses of the demo input tables
; CPU memory address $b3d2
demo_input_pointer_table:
    .addr demo_input_tbl_l1_p1 ; CPU address $b3de
    .addr demo_input_tbl_l1_p2 ; CPU address $b438
    .addr demo_input_tbl_l2_p1 ; CPU address $b48a
    .addr demo_input_tbl_l2_p2 ; CPU address $b4fc
    .addr demo_input_tbl_l3_p1 ; CPU address $b540
    .addr demo_input_tbl_l3_p2 ; CPU address $b5b2

; the following area contains the automated input for the demo levels
;  * first byte is input code (up, down, left, right, b, a, start, select)
;  * second byte is number of even-numbered frames to apply the input for
; while possible, player firing isn't specified in these input tables
; instead, that is handled automatically as part of running the demo
;  * m or l weapons are always firing, other weapons fire every #$08 frames
; $00, $00 is filler so the demo level doesn't end by reading a #$ff
; input table for level 1 player 1 for demo (#$5A bytes)
demo_input_tbl_l1_p1:
    .byte $00,$21,$01,$03,$00,$0e,$01,$3d,$04,$06,$05,$33,$00,$0e,$04,$0a
    .byte $05,$01,$01,$29,$09,$01,$08,$02,$09,$08,$08,$0f,$09,$18,$01,$05
    .byte $00,$04,$01,$02,$00,$1f,$01,$24,$05,$33,$01,$05,$81,$15,$01,$0b
    .byte $09,$02,$01,$22,$81,$11,$89,$02,$81,$03,$01,$70,$09,$1c,$01,$25
    .byte $09,$2f,$01,$03,$05,$06,$01,$0a,$08,$14,$09,$01,$01,$12,$09,$06
    .byte $08,$05,$00,$00,$00,$00,$00,$00,$ff,$ff

; input table for level 1 player 2 for demo (#$52 bytes)
demo_input_tbl_l1_p2:
    .byte $01,$76,$05,$1f,$00,$03,$80,$04,$84,$0a,$05,$02,$01,$86,$00,$0b
    .byte $01,$0b,$81,$0b,$85,$06,$84,$06,$04,$07,$00,$02,$01,$39,$81,$0d
    .byte $01,$13,$81,$09,$01,$17,$81,$06,$01,$31,$00,$3e,$01,$19,$81,$0b
    .byte $01,$14,$81,$08,$01,$17,$81,$0d,$01,$25,$00,$01,$80,$03,$84,$08
    .byte $04,$0a,$05,$01,$01,$08,$00,$03,$02,$04,$00,$07,$01,$17,$00,$06
    .byte $ff,$ff

; input table for level 2 player 1 for demo (#$72 bytes)
demo_input_tbl_l2_p1:
    .byte $00,$49,$02,$16,$00,$1f,$01,$0a,$00,$0d,$04,$2a,$00,$0b,$01,$0b
    .byte $00,$1b,$02,$13,$82,$0a,$80,$03,$00,$04,$01,$1c,$00,$14,$08,$05
    .byte $00,$4b,$02,$15,$00,$24,$04,$0b,$05,$01,$01,$18,$00,$07,$02,$0f
    .byte $00,$01,$01,$13,$00,$01,$02,$0c,$82,$04,$80,$03,$00,$05,$01,$0a
    .byte $00,$01,$02,$05,$08,$01,$01,$01,$00,$01,$08,$01,$0a,$03,$02,$04
    .byte $0a,$06,$02,$0c,$04,$0a,$00,$27,$01,$0f,$81,$0a,$01,$07,$00,$08
    .byte $02,$1e,$00,$90,$01,$09,$81,$0a,$01,$04,$00,$03,$02,$1e,$00,$00
    .byte $ff,$ff

; input table for level 2 player 2 for demo (#$44 bytes)
demo_input_tbl_l2_p2:
    .byte $00,$41,$02,$04,$00,$2b,$04,$19,$00,$16,$04,$16,$00,$1d,$04,$2a
    .byte $00,$3a,$08,$4b,$00,$17,$01,$1c,$00,$23,$04,$12,$00,$1f,$02,$19
    .byte $00,$01,$01,$02,$81,$0d,$01,$04,$00,$07,$02,$10,$82,$0e,$02,$02
    .byte $00,$1e,$02,$15,$00,$06,$02,$04,$00,$0b,$04,$19,$00,$3a,$08,$03
    .byte $00,$2e,$ff,$ff

;input table for level 3 player 1 for demo (#$72 bytes)
demo_input_tbl_l3_p1:
    .byte $00,$17,$01,$29,$81,$05,$01,$13,$00,$1b,$80,$0d,$00,$13,$80,$0b
    .byte $00,$1a,$80,$12,$00,$0d,$80,$12,$00,$0b,$80,$0a,$81,$03,$01,$0d
    .byte $00,$09,$01,$0d,$00,$03,$02,$02,$00,$4d,$02,$0e,$82,$11,$02,$10
    .byte $00,$08,$08,$03,$88,$12,$08,$03,$0a,$04,$02,$05,$00,$02,$80,$0e
    .byte $00,$08,$02,$0e,$82,$0e,$02,$02,$00,$0e,$80,$08,$00,$06,$01,$02
    .byte $00,$17,$80,$0a,$00,$16,$80,$0b,$00,$17,$80,$0c,$00,$20,$80,$0d
    .byte $00,$0f,$80,$06,$81,$03,$01,$09,$00,$22,$01,$0b,$81,$0f,$01,$25
    .byte $ff,$ff

; input table for level 3 player 2 for demo (#$82 bytes)
demo_input_tbl_l3_p2:
    .byte $00,$23,$01,$2c,$81,$0d,$01,$0a,$00,$07,$80,$0d,$00,$10,$80,$07
    .byte $82,$05,$02,$0f,$82,$0a,$02,$0f,$00,$0f,$80,$0a,$00,$35,$04,$09
    .byte $00,$05,$80,$01,$82,$07,$02,$02,$00,$10,$01,$01,$81,$0c,$01,$0c
    .byte $00,$1f,$80,$04,$00,$14,$01,$0b,$00,$0a,$04,$24,$05,$01,$85,$02
    .byte $81,$06,$80,$01,$00,$07,$02,$04,$00,$03,$01,$0c,$00,$07,$01,$08
    .byte $81,$0d,$01,$0f,$00,$04,$80,$0c,$02,$08,$00,$2d,$02,$14,$82,$11
    .byte $80,$03,$01,$0a,$00,$02,$02,$02,$82,$0f,$02,$0c,$00,$03,$80,$05
    .byte $82,$0f,$02,$04,$00,$4a,$81,$0b,$01,$04,$00,$11,$80,$0d,$00,$00
    .byte $ff,$ff

; unused #$9cc bytes out of #$4,000 bytes total (84.70% full)
; unused 2,508 bytes out of 16,384 bytes total (84.70% full)
; filled with 2,508 #$ff bytes by contra.cfg configuration
bank_5_unused_space: