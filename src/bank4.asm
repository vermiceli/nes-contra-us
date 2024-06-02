; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 4 mostly contains compressed graphic data. The rest of bank 4 is the code
; for the ending scene animation and the ending credits, including the ending
; credits text data.

.segment "BANK_4"

.include "constants.asm"

; import labels from bank 7
.import advance_graphic_read_addr, decrement_delay_timer
.import init_APU_channels, init_game_routine_reset_timer_low_byte
.import load_A_offset_graphic_data, load_alternate_graphics
.import load_palette_indexes, play_sound
.import reset_delay_timer, run_routine_from_tbl_below
.import zero_out_nametables

; export labels used by bank 7
.export graphic_data_01, graphic_data_03
.export graphic_data_04, graphic_data_06
.export graphic_data_08, graphic_data_09
.export graphic_data_0a, graphic_data_0f
.export graphic_data_10, graphic_data_11
.export graphic_data_12, graphic_data_13
.export run_game_end_routine

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $04 ; The PRG ROM bank number (4)

; compressed graphics data - code 03 (#$5ad bytes)
; used in every level, except intro and ending scenes
; pattern table data - writes addresses [$0000-$0680)
; * bill and lance blocks
; * game over letters
; * lives medals
; * power-ups (SBFLRM)
; * explosions
; CPU address $8001
graphic_data_03:
    .incbin "assets/graphic_data/graphic_data_03.bin"

; compressed graphics data - code 04 (#$1f3 bytes)
; character facing up
; pattern table data - writes addresses [$0680-$08c0)
; CPU address $85ae
graphic_data_04:
    .incbin "assets/graphic_data/graphic_data_04.bin"

; compressed graphics data - code 13 (#$cb bytes)
; left pattern table data - writes addresses [$08c0-$09a0)
; player top-half aiming up and aiming straight, also contains the laser sprites
; CPU address $87a1
graphic_data_13:
    .incbin "assets/graphic_data/graphic_data_13.bin"

; compressed graphics data - code 08 (#$1161 bytes)
; pattern table data - writes addresses [$09a0-$2000)
; CPU address $886c
graphic_data_08:
    .incbin "assets/graphic_data/graphic_data_08.bin"

; compressed graphics data - code 09 (#$2f bytes)
; left pattern table data - writes addresses [$0b00-$0b40)
; CPU address $99cd
graphic_data_09:
    .incbin "assets/graphic_data/graphic_data_09.bin"

; compressed graphics data - code 06 (#$607 bytes)
; most Base graphics
; pattern table data - writes addresses [$08c0-$1100)
; CPU address $99fc
graphic_data_06:
    .incbin "assets/graphic_data/graphic_data_06.bin"

; compressed graphics data - code 10 (#$343 bytes)
; horizontal flip, different location in right pattern table
; CPU address $a003
graphic_data_10:
    .byte $00,$16 ; PPU write address

; compressed graphics data - code 0a (#$341 bytes)
; right pattern table data - writes addresses [$1100-$1520)
; CPU address $a005
graphic_data_0a:
    .incbin "assets/graphic_data/graphic_data_0a.bin"

; compressed graphics data - code 0f (#$a1 bytes)
; right pattern table data - writes addresses [$1520-$1600)
; CPU address $a346
graphic_data_0f:
    .incbin "assets/graphic_data/graphic_data_0f.bin"

; compressed graphics data - code 11 (#$559 bytes)
; right pattern table data - writes addresses [$a120-$2000)
; CPU address $a3e7
graphic_data_11:
    .incbin "assets/graphic_data/graphic_data_11.bin"

; compressed graphics data - code 12 (#$ed bytes)
; Base 2 Graphics
; right pattern table data - writes addresses [$1b90-$1ca0)
; CPU Address $a940
graphic_data_12:
    .incbin "assets/graphic_data/graphic_data_12.bin"

; compressed graphics data - code 01 (#$e8c bytes)
; Used for intro screen, level title screens, and game over screens.
; Contains Contra logo, Bill and Lance (both sprite and pattern)
; all the letters and numbers, as well as falcon selector cursor tiles.
; used by graphic_data_02 nametable data
; pattern table data - writes addresses [$0ce0-$1f80)
; last #$80 bytes of pattern table not used
; CPU address $aa2d
graphic_data_01:
    .incbin "assets/graphic_data/graphic_data_01.bin"

run_game_end_routine:
    lda GAME_END_ROUTINE_INDEX
    jsr run_routine_from_tbl_below ; run routine a in the following table (game_end_routine_tbl)

; pointer table for ending (6 * 2 = c bytes)
; CPU address $b8be
game_end_routine_tbl:
    .addr game_end_routine_00 ; CPU address $b8ca (fade away)
    .addr game_end_routine_01 ; CPU address $b8d3 (screen melt and init for game_end_routine_02)
    .addr game_end_routine_02 ; CPU address $b93e (helicopter flying away and island exploding)
    .addr game_end_routine_03 ; CPU address $b941 (congratulations text scrolling and credits)
    .addr game_end_routine_04 ; CPU address $bae3 (music change and presented by Konami)
    .addr game_end_routine_05 ; CPU address $bb87

; set level to #$08 (ending routine)
game_end_routine_00:
    lda #$08                                   ; a = #$08
    sta CURRENT_LEVEL                          ; set current level to 'level 9' (special ending level)
    dec GRAPHICS_BUFFER_MODE                   ; set GRAPHICS_BUFFER_MODE to #$ff to prepare writing tile data
    jmp init_game_routine_reset_timer_low_byte ; set timer and increment GAME_END_ROUTINE_INDEX

game_end_routine_01:
    lda $40                         ; for end of game sequence, this is used to know which part of screen to blank
    asl                             ; and no longer means location type
    tay
    ldx GRAPHICS_BUFFER_OFFSET      ; load graphics buffer offset
    lda #$02                        ; a = #$02
    sta CPU_GRAPHICS_BUFFER,x       ; vram_address_increment offset #$02, set VRAM address increment to 1 (write down)
    lda #$20                        ; a = #$20
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; #$20 tiles to be written per group
    lda #$01                        ; a = #$01
    inx
    sta CPU_GRAPHICS_BUFFER,x       ; #$01 group of tiles to write
    lda screen_melt_ppu_add_tbl+1,y ; load PPU write address low byte
    inx
    sta CPU_GRAPHICS_BUFFER,x
    lda screen_melt_ppu_add_tbl,y   ; load PPU write address high byte
    clc                             ; clear carry in preparation for addition
    adc $41                         ; add to byte offset into pattern table tile to write
    inx
    sta CPU_GRAPHICS_BUFFER,x
    ldy #$20                        ; number of tiles to write
    lda #$00                        ; a = #$00
    inx

; writes a blank tile #$20 tiles to CPU_GRAPHICS_BUFFER
@write_tile_to_buffer:
    sta CPU_GRAPHICS_BUFFER,x
    inx
    dey
    bne @write_tile_to_buffer
    stx GRAPHICS_BUFFER_OFFSET  ; update graphics buffer write offset
    lda $40                     ; load current screen_melt_ppu_add_tbl offset
    clc                         ; clear carry in preparation for addition
    adc #$01
    cmp #$08
    bne @set_screen_melt_offset
    inc $41                     ; increment byte offset into pattern table tile to write
    lda $41
    cmp #$10
    beq @load_alt_graphics
    lda #$00                    ; set screen_melt_ppu_add_tbl offset to #$00

@set_screen_melt_offset:
    sta $40 ; update screen_melt_ppu_add_tbl offset
    rts

@load_alt_graphics:
    lda #$40                                   ; a = #$40
    sta DELAY_TIME_LOW_BYTE                    ; various delays (low byte)
    jsr init_game_routine_reset_timer_low_byte ; set timer and increment GAME_END_ROUTINE_INDEX
    jsr load_alternate_graphics
    lda #$0c                                   ; level_graphic_data_tbl offset (ending_graphic_data)
    jmp load_A_offset_graphic_data             ; load ending_graphic_data

; a list of PPU write addresses for use to clear the screen a portion at a time
; PPU write low byte, then high (#$8 items * #$02 = #$10 bytes)
screen_melt_ppu_add_tbl:
    .byte $00,$10
    .byte $00,$14
    .byte $00,$18
    .byte $00,$1c
    .byte $10,$10
    .byte $10,$14
    .byte $10,$18
    .byte $10,$1c

game_end_routine_02:
    jmp init_game_routine_reset_timer_low_byte

game_end_routine_03:
    jsr load_palette_indexes       ; load the palette colors
    lda END_LEVEL_ROUTINE_INDEX    ; routine index for ending scene
    jsr run_routine_from_tbl_below ; run routine a in the following table (end_game_sequence_ptr_tbl)

; pointer table for ending scenes (#$03 * #$02 = #06 bytes)
; analogous to end_level_sequence_ptr_tbl, but for end of game
; CPU address $b949
end_game_sequence_ptr_tbl:
    .addr end_game_sequence_00 ; CPU address $b94f
    .addr end_game_sequence_01 ; CPU address $b98f
    .addr end_game_sequence_02 ; CPU address $bac8

; ending scene - pointer 0
end_game_sequence_00:
    lda #$cf                     ; a = #$cf (3 mountains)
    sta ENEMY_SPRITES+8          ; enemy 8 sprite code
    lda #$c5                     ; a = #$c5 (green helicopter frame 1)
    sta ENEMY_SPRITES+9          ; helicopter sprite code
    lda #$ff                     ; a = #$ff
    sta ENEMY_X_VELOCITY_FAST+9  ; helicopter x velocity (high byte)
    sta ENEMY_Y_VELOCITY_FAST+9  ; helicopter y velocity (high byte)
    lda #$60                     ; a = #$60
    sta ENEMY_X_VELOCITY_FRACT+9 ; helicopter x velocity (low byte)
    lda #$70                     ; a = #$70
    sta ENEMY_Y_VELOCITY_FRACT+9 ; helicopter y velocity (low byte)
    ldx #$09                     ; x = #$09
    ldy #$00                     ; y = #$00

@set_ending_sprite_animations:
    lda end_scene_sprite_anim_tbl,y
    sta ENEMY_ANIMATION_DELAY,x       ; set enemy animation frame delay counter
    lda end_scene_sprite_anim_tbl+1,y
    sta ENEMY_X_POS,x                 ; set enemy x position on screen
    lda end_scene_sprite_anim_tbl+2,y
    sta ENEMY_Y_POS,x                 ; enemy y position on screen
    iny
    iny
    iny
    dex
    bpl @set_ending_sprite_animations
.ifdef Probotector
                                      ; don't play helicopter sound for Probotector, ending animation uses jet
.else
    lda #$21                          ; a = #$21 (sound_21)
    jsr play_sound                    ; play helicopter rotors sound
.endif
    inc END_LEVEL_ROUTINE_INDEX       ; increment ending scene index (end_game_sequence_ptr_tbl)
    rts

; ending scene - pointer 1
end_game_sequence_01:
    lda ENEMY_SPRITES+9             ; helicopter sprite code
    cmp #$01                        ; see if helicopter is hidden
    beq start_ending_seq_enemy_loop ; branch if helicopter is hidden
    lda ENEMY_X_VEL_ACCUM+9
    clc                             ; clear carry in preparation for addition
    adc ENEMY_X_VELOCITY_FRACT+9
    sta ENEMY_X_VEL_ACCUM+9
    lda ENEMY_X_POS+9
    adc ENEMY_X_VELOCITY_FAST+9
    sta ENEMY_X_POS+9
    lda ENEMY_Y_VEL_ACCUM+9
    clc                             ; clear carry in preparation for addition
    adc ENEMY_Y_VELOCITY_FRACT+9
    sta ENEMY_Y_VEL_ACCUM+9
    lda ENEMY_Y_POS+9
    adc ENEMY_Y_VELOCITY_FAST+9
    sta ENEMY_Y_POS+9
    bcs @continue
    lda #$01                        ; a = #$01
    sta ENEMY_SPRITES+9             ; helicopter sprite code (blank sprite)
    bne start_ending_seq_enemy_loop

@continue:
    lda ENEMY_X_VELOCITY_FRACT+9
    clc                              ; clear carry in preparation for addition
    adc #$02
    sta ENEMY_X_VELOCITY_FRACT+9
    lda ENEMY_X_VELOCITY_FAST+9
    adc #$00
    sta ENEMY_X_VELOCITY_FAST+9
    lda ENEMY_X_POS+9
    lda ENEMY_ANIMATION_DELAY+9
    lsr
    lsr
    tay
    lda helicopter_sprite_anim_tbl,y ; load  appropriate sprite for helicopter
    sta ENEMY_SPRITES+9              ; update helicopter animation sprite
    lda FRAME_COUNTER                ; load frame counter
    and #$01                         ; keep bits .... ...x
    bne sequence_01_exit
    inc ENEMY_ANIMATION_DELAY+9      ; helicopter animation frame delay counter

; #$08 enemies on screen for ending sequence
start_ending_seq_enemy_loop:
    ldx #$07 ; x = #$07 (volcano)

; loop through enemies
ending_seq_enemy_loop:
    lda ENEMY_ANIMATION_DELAY,x ; load current enemy animation frame delay counter
    bne @continue               ; branch if delay hasn't elapsed
    txa                         ; animation delay has elapsed for enemy, advance to next routine
    beq adv_routine_exit

@continue:
    dec ENEMY_ANIMATION_DELAY,x         ; decrement enemy animation frame delay counter
    cmp #$60
    bcc @set_sprite_00_next_enemy       ; branch if animation delay is less than #$60
    cmp #$80
    bcs @play_explosion                 ; branch if animation delay is between #$60 and #$80
    lsr
    lsr
    lsr
    and #$03                            ; keep bits .... ..xx
    tay
    lda ending_sequence_explosion_tbl,y
    bne @set_sprite_a_next_enemy

@play_explosion:
    bne @set_sprite_00_next_enemy
    lda #$25                      ; a = #$25 (sound_25)
    jsr play_sound                ; play big island explosion sound
    cpx #$03
    beq draw_destroyed_island     ; draw destroyed and burned island

@set_sprite_00_next_enemy:
    lda #$00 ; a = #$00

@set_sprite_a_next_enemy:
    sta ENEMY_SPRITES,x ; write enemy sprite code to CPU buffer

sequence_01_next_enemy:
    dex
    bpl ending_seq_enemy_loop

sequence_01_exit:
    rts

draw_destroyed_island:
    lda #$00                   ; a = #$00
    sta ENEMY_SPRITES+8        ; blank sprite code
    stx $00
    ldx GRAPHICS_BUFFER_OFFSET ; load graphics buffer offset
    ldy #$00                   ; y = #$00

; draw the #$43 pattern table tiles
@loop:
    lda destroyed_island_tile_tbl,y
    sta CPU_GRAPHICS_BUFFER,x
    inx
    iny
    cpy #$43
    bne @loop
    stx GRAPHICS_BUFFER_OFFSET
    ldx $00
    jmp sequence_01_next_enemy      ; go to next enemy in ending sequence

adv_routine_exit:
    inc END_LEVEL_ROUTINE_INDEX ; increment ending scene offset (end_game_sequence_ptr_tbl)
    rts

; table for explosions sprite codes (#$4 bytes)
ending_sequence_explosion_tbl:
    .byte $37,$36,$35,$37

; table for helicopter sprite codes for animation (#$20 bytes)
; each byte is a sprite code, e.g. sprite_c5, sprite_c6, etc.
.ifdef Probotector
helicopter_sprite_anim_tbl:
    .byte $c5,$c5,$c5,$c5,$c5,$c5,$c5,$c5,$c5,$c6,$c7,$c8,$c9,$ca,$cb,$cb
    .byte $cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb,$cb

; pattern table tile codes and palette codes - after destruction (#$43 bytes)
destroyed_island_tile_tbl:
    .byte $01,$0e,$04,$22,$29,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$22,$49,$00,$00,$00,$00,$00,$00,$00,$00,$00,$71,$72
    .byte $73,$00,$00,$22,$69,$6f,$00,$00,$71,$00,$6f,$75,$7c,$75,$7e,$7f
    .byte $75,$74,$7d,$23,$da,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa
.else
helicopter_sprite_anim_tbl:
    .byte $c5,$c6,$c7,$c5,$c6,$c7,$c5,$c6,$c7,$c5,$c8,$c9,$ca,$cb,$cc,$cd
    .byte $ce,$cc,$cd,$ce,$cc,$cd,$ce,$cc,$cd,$ce,$cc,$cd,$ce,$cc,$cd,$ce

; pattern table tile codes and palette codes - after destruction (#$43 bytes)
destroyed_island_tile_tbl:
    .byte $01,$0e,$04,$22,$29,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$22,$49,$00,$00,$00,$00,$00,$00,$00,$00,$00,$70,$71
    .byte $72,$00,$00,$22,$69,$7c,$00,$00,$70,$00,$7c,$74,$7e,$74,$80,$81
    .byte $74,$73,$7f,$23,$da,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa
.endif

; tables for ending scene sprites (#$a * #$3 = #$1e bytes)
; byte 0: delay
; byte 1: x position
; byte 2: y position
end_scene_sprite_anim_tbl:
    .byte $00,$80,$90 ; helicopter
    .byte $00,$50,$86 ; mountain peaks
    .byte $a8,$60,$8c ; explosion 0
    .byte $b4,$98,$8a ; explosion 1
    .byte $b8,$70,$94 ; explosion 2
    .byte $d0,$50,$96 ; explosion 3
    .byte $d3,$a8,$98 ; explosion 4
    .byte $d6,$78,$94 ; explosion 5
    .byte $db,$68,$96 ; explosion 6
    .byte $ef,$88,$94 ; explosion 7

; ending scene - pointer 2
end_game_sequence_02:
    jsr decrement_delay_timer
    bne game_end_routine_exit
    lda #$20                                   ; a = #$20
    sta LEVEL_SUPERTILE_DATA_PTR
    jsr init_APU_channels
    jsr reset_delay_timer                      ; reset 2-byte delay timer to #$0240
    lda #$4a                                   ; a = #$4a (sound_4a)
    jsr play_sound                             ; play end credits music
    jsr zero_out_nametables                    ; erase name tables 0-1
    jmp init_game_routine_reset_timer_low_byte

game_end_routine_exit:
    rts

game_end_routine_04:
    lda FRAME_COUNTER         ; load frame counter
    and #$03                  ; keep bits .... ..xx (speed of credits text)
    bne game_end_routine_exit ; exit if not the 8th frame (scroll every 8 frames)
    inc VERTICAL_SCROLL       ; vertical scroll offset
    lda VERTICAL_SCROLL
    cmp #$f0                  ; see if the view window needs to be set back to $2000 (scroll reached bottom of $2800 nametable)
    bne @continue             ; branch if no need to reset base nametable write address and vertical scroll
    lda #$20                  ; initialize PPU write address to #$200 and set/reset VERTICAL_SCROLL
    sta $44                   ; write nametable address high byte for PPU address #$2000
    lda #$00                  ; a = #$00
    sta $43                   ; write nametable address low byte for PPU address #$2000
    sta VERTICAL_SCROLL       ; set vertical scroll offset back to #$00

@continue:
    and #$0f                    ; keep bits .... xxxx of VERTICAL_SCROLL
    cmp #$04                    ; see if we need to draw the line of text
    beq @draw_next_line         ; if scroll offset ends in #$4, write next line of credits text
    cmp #$0c                    ; check to see if need to draw blank line between text when VERTICAL_SCROLL ends in #$0c
    bne game_end_routine_exit_2 ; exit until scroll offset ends in #$c
    ldy #$00                    ; y = #$00 (first line of ending credits)
    beq load_credits_line_text  ; always branch to draw blank line of tiles (ending_credits_00)

@draw_next_line:
    lda $42 ; load line credits text offset (initialized to 0 in level_routine_05 clear_memory_starting_at_x)
    inc $42 ; increment credits line offset
    asl     ; double since each entry is #$02 bytes
    tay

load_credits_line_text:
    lda ending_credits_ptr_tbl,y      ; read low byte of the end credits address
    sta $00                           ; store low byte into $00
    lda ending_credits_ptr_tbl+1,y    ; read high byte of the end credits address
    beq end_credits_text              ; last entry, finished reading credits
    sta $01                           ; store high byte of the end credits address
    ldy #$00                          ; set read index to #$00
    lda ($00),y                       ; read number of characters in line text
    sta $03                           ; store into $03
    iny                               ; increment line text read offset
    lda ($00),y                       ; read the horizontal offset of the line of text
    sta $02                           ; store distance from left side of screen
    lda #$20                          ; text line width is #$20 characters
    sec                               ; set the carry in preparation for sbc
    sbc $02                           ; #$20 minus horizontal offset
    sbc $03                           ; and then subtract line's total number of characters
    sta $04                           ; store the remaining spaces after text tiles
    ldx GRAPHICS_BUFFER_OFFSET        ; load graphics buffer offset
    lda #$01                          ; a = #$01
    sta CPU_GRAPHICS_BUFFER,x         ; set VRAM address increment to write across horizontally
    sta CPU_GRAPHICS_BUFFER+2,x       ; set number of graphics groups to write to 1
    lda #$20                          ; a = #$20
    inx
    sta CPU_GRAPHICS_BUFFER,x         ; set number of pattern tiles in group to #$20 (writing #$20 tiles)
    inx
    lda $44                           ; load PPU write address high byte
    inx
    sta CPU_GRAPHICS_BUFFER,x         ; set PPU address write high byte
    lda $43                           ; load PPU write address low byte
    inx
    sta CPU_GRAPHICS_BUFFER,x         ; set PPU address write low byte
    inx
    jsr draw_credits_space_characters

@draw_credits_line_text:
    lda $03                     ; number of tiles to draw
    beq @draw_right_padding     ; if no characters to draw, draw right padding space
    iny                         ; increment credits text character read offset
    lda ($00),y                 ; read next credits text character to draw
    sta CPU_GRAPHICS_BUFFER,x   ; write value in CPU_GRAPHICS_BUFFER
    dec $03                     ; decrement number of tiles to draw
    inx                         ; increment CPU_GRAPHICS_BUFFER write offset
    bne @draw_credits_line_text

@draw_right_padding:
    lda $04
    sta $02
    jsr draw_credits_space_characters
    stx GRAPHICS_BUFFER_OFFSET        ; update graphics buffer offset
    ldx #$43                          ; x = #$43
    lda #$20                          ; a = #$20
    jsr advance_graphic_read_addr     ; advance 2-byte read address $43 by #$20 bytes

game_end_routine_exit_2:
    rts

; delay before returning to intro screen
; 300 = 768 frames / 60 = 12.8 seconds
; the timer starts roughly 1 second before the text stops scrolling
end_credits_text:
    sta DELAY_TIME_LOW_BYTE                    ; various delays (low byte)
    lda #$03                                   ; a = #$03
    sta DELAY_TIME_HIGH_BYTE                   ; various delays (high byte)
    jmp init_game_routine_reset_timer_low_byte

; draw either the left or right spaces for padding of credits text (tile #$00)
draw_credits_space_characters:
    lda $02                           ; load the horizontal offset of the line of text
    beq game_end_routine_exit_2       ; if completed drawing blank space, exit
    lda #$00                          ; a = #$00
    sta CPU_GRAPHICS_BUFFER,x         ; specify buffer to draw blank space (empty char) for left padding
    dec $02                           ; decrement horizontal offset of text
    inx                               ; increment loop value
    bne draw_credits_space_characters ; always loop

game_end_routine_05:
    jsr decrement_delay_timer   ; decrease delay by 1 (return 1 when delay is 0)
    bne game_end_routine_exit_2 ; exit if timer hasn't elapsed
    lda #$00                    ; a = #$00
    sta GRAPHICS_BUFFER_MODE    ; set GRAPHICS_BUFFER_MODE to #$00 to prepare writing text to screen (write_text_palette_to_mem)
    sta CURRENT_LEVEL           ; set current level to #$00
    dec GAME_ROUTINE_INDEX      ; set game routine to be game_routine_05 to start the first level
    rts

; pointer table for ending credits text (#$49 * #$2 = #$90 bytes)
ending_credits_ptr_tbl:
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_01 ; CPU address $bd55: CONGRATULATIONS!
    .addr ending_credits_02 ; CPU address $bd67: YOU'VE DESTROYED THE VILE RED
    .addr ending_credits_03 ; CPU address $bd86: FALCON AND SAVED THE UNIVERSE.
    .addr ending_credits_04 ; CPU address $bda6: CONSIDER YOURSELF A HERO
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_05 ; CPU address $bc29: S T A F F
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_06 ; CPU address $bc34: PROGRAMMERS
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_07 ; CPU address $bc41: S.UMEZAKI
    .addr ending_credits_08 ; CPU address $bc4c: S.KISHIWADA
    .addr ending_credits_09 ; CPU address $bc59: K.YAMASHITA
    .addr ending_credits_0a ; CPU address $bc66: T.DANJYO
    .addr ending_credits_0b ; CPU address $bc70: M.OGAWA
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_0c ; CPU address $bc79: GRAPHIC DESIGNERS
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_0d ; CPU address $bc8c: T.UEYAMA
    .addr ending_credits_0e ; CPU address $bc96: S.MURAKI
    .addr ending_credits_0f ; CPU address $bca0: M.FUJIWARA
    .addr ending_credits_10 ; CPU address $bcac: T.NISHIKAWA
    .addr ending_credits_11 ; CPU address $bcb9: C.OZAWA
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_12 ; CPU address $bce4: SOUND CREATORS
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_13 ; CPU address $bcf4: H.MAEZAWA
    .addr ending_credits_14 ; CPU address $bcff: K.SADA
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_15 ; CPU address $bd07: SPECIAL THANKS TO
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_16 ; CPU address $bd1a: K.SHIMONETA
    .addr ending_credits_17 ; CPU address $bd27: N.SATO
    .addr ending_credits_18 ; CPU address $bd2f: AC CONTRA TEAM
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_19 ; CPU address $bcc2: DIRECTED BY
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_1a ; CPU address $bccf: UMECHAN
    .addr ending_credits_1b ; CPU address $bcd8: S.KITAMOTO
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_1c ; CPU address $bd3f: PRESENTED BY
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_1d ; CPU address $bd4d: KONAMI
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .addr ending_credits_00 ; CPU address $bc27: blank line
    .byte $00,$00

; blank line
ending_credits_00:
    .byte $00,$20

; Text Table
; Same for Intro and Ending, except 87 (!) unique to Ending
; $00 = Space
; $30 = 0
; $31 = 1
; $32 = 2
; $33 = 3
; $34 = 4
; $35 = 5
; $36 = 6
; $37 = 7
; $38 = 8
; $39 = 9
; $40 = .
; $41 = A
; $42 = B
; $43 = C
; $44 = D
; $45 = E
; $46 = F
; $47 = G
; $48 = H
; $49 = I
; $4a = J
; $4b = K
; $4c = L
; $4d = M
; $4e = N
; $4f = O
; $50 = P
; $51 = Q
; $52 = R
; $53 = S
; $54 = T
; $55 = U
; $56 = V
; $57 = W
; $58 = X
; $59 = Y
; $5a = Z
; $87 = !
; $b0 = ,
; $c3 = ©
; $f7 = '
; ending credits text data
; byte 0: number of bytes to process after byte 1
; byte 1: starting x position
; S T A F F
ending_credits_05:
    .byte $09,$0b,$53,$00,$54,$00,$41,$00,$46,$00,$46

; PROGRAMMERS
ending_credits_06:
    .byte $0b,$09,$50,$52,$4f,$47,$52,$41,$4d,$4d,$45,$52,$53

; S.UMEZAKI
ending_credits_07:
    .byte $09,$0b,$53,$40,$55,$4d,$45,$5a,$41,$4b,$49

; S.KISHIWADA
ending_credits_08:
    .byte $0b,$0b,$53,$40,$4b,$49,$53,$48,$49,$57,$41,$44,$41

; K.YAMASHITA
ending_credits_09:
    .byte $0b,$0b,$4b,$40,$59,$41,$4d,$41,$53,$48,$49,$54,$41

; T.DANJYO
ending_credits_0a:
    .byte $08,$0b,$54,$40,$44,$41,$4e,$4a,$59,$4f

; M.OGAWA
ending_credits_0b:
    .byte $07,$0b,$4d,$40,$4f,$47,$41,$57,$41

; GRAPHIC DESIGNERS
ending_credits_0c:
    .byte $11,$09,$47,$52,$41,$50,$48,$49,$43,$00,$44,$45,$53,$49,$47,$4e
    .byte $45,$52,$53

; T.UEYAMA
ending_credits_0d:
    .byte $08,$0b,$54,$40,$55,$45,$59,$41,$4d,$41

; S.MURAKI
ending_credits_0e:
    .byte $08,$0b,$53,$40,$4d,$55,$52,$41,$4b,$49

; M.FUJIWARA
ending_credits_0f:
    .byte $0a,$0b,$4d,$40,$46,$55,$4a,$49,$57,$41,$52,$41

; T.NISHIKAWA
ending_credits_10:
    .byte $0b,$0b,$54,$40,$4e,$49,$53,$48,$49,$4b,$41,$57,$41

; C.OZAWA
ending_credits_11:
    .byte $07,$0b,$43,$40,$4f,$5a,$41,$57,$41

; DIRECTED BY
ending_credits_19:
    .byte $0b,$09,$44,$49,$52,$45,$43,$54,$45,$44,$00,$42,$59

; UMECHAN
ending_credits_1a:
    .byte $07,$0b,$55,$4d,$45,$43,$48,$41,$4e

; S.KITAMOTO
ending_credits_1b:
    .byte $0a,$0b,$53,$40,$4b,$49,$54,$41,$4d,$4f,$54,$4f

; SOUND CREATORS
ending_credits_12:
    .byte $0e,$09,$53,$4f,$55,$4e,$44,$00,$43,$52,$45,$41,$54,$4f,$52,$53

; H.MAEZAWA
ending_credits_13:
    .byte $09,$0b,$48,$40,$4d,$41,$45,$5a,$41,$57,$41

; K.SADA
ending_credits_14:
    .byte $06,$0b,$4b,$40,$53,$41,$44,$41

; SPECIAL THANKS TO
ending_credits_15:
    .byte $11,$09,$53,$50,$45,$43,$49,$41,$4c,$00,$54,$48,$41,$4e,$4b,$53
    .byte $00,$54,$4f

; K.SHIMONETA
ending_credits_16:
    .byte $0b,$0b,$4b,$40,$53,$48,$49,$4d,$4f,$4e,$45,$54,$41

; N.SATO
ending_credits_17:
    .byte $06,$0b,$4e,$40,$53,$41,$54,$4f

.ifdef Probotector
; AC TEAM
ending_credits_18:
    .byte $07,$0b,$41,$43,$00,$54,$45,$41,$4d
.else
; AC CONTRA TEAM
ending_credits_18:
    .byte $0e,$0b,$41,$43,$00,$43,$4f,$4e,$54,$52,$41,$00,$54,$45,$41,$4d
.endif

; PRESENTED BY
ending_credits_1c:
    .byte $0c,$0a,$50,$52,$45,$53,$45,$4e,$54,$45,$44,$00,$42,$59

; KONAMI
ending_credits_1d:
    .byte $06,$0d,$4b,$4f,$4e,$41,$4d,$49

; CONGRATULATIONS!
ending_credits_01:
    .byte $10,$01,$43,$4f,$4e,$47,$52,$41,$54,$55,$4c,$41,$54,$49,$4f,$4e
    .byte $53,$87

; YOU'VE DESTROYED THE VILE RED
ending_credits_02:
    .byte $1d,$01,$59,$4f,$55,$f7,$56,$45,$00,$44,$45,$53,$54,$52,$4f,$59
    .byte $45,$44,$00,$54,$48,$45,$00,$56,$49,$4c,$45,$00,$52,$45,$44

; FALCON AND SAVED THE UNIVERSE.
ending_credits_03:
    .byte $1e,$01,$46,$41,$4c,$43,$4f,$4e,$00,$41,$4e,$44,$00,$53,$41,$56
    .byte $45,$44,$00,$54,$48,$45,$00,$55,$4e,$49,$56,$45,$52,$53,$45,$40

; CONSIDER YOURSELF A HERO
ending_credits_04:
    .byte $19,$01,$43,$4f,$4e,$53,$49,$44,$45,$52,$00,$59,$4f,$55,$52,$53
    .byte $45,$4c,$46,$00,$41,$00,$48,$45,$52,$4f,$40

; unused #$23f bytes out of #$4,000 bytes total (96.50% full)
; unused 575 bytes out of 16,384 bytes total (96.50% full)
; filled with 575 #$ff bytes by contra.cfg configuration
bank_4_unused_space: