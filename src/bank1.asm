; Contra US Disassembly - v1.3
; https://github.com/vermiceli/nes-contra-us
; Bank 1 is responsible for audio and sprites.  The audio code takes up about
; 3/4  of the bank. The remaining 1/4 of the bank is for sprite data and code to
; draw sprites.

.segment "BANK_1"

.include "constants.asm"

; import labels from bank 7
.import play_sound

; export labels used in other banks
.export draw_sprites
.export init_pulse_and_noise_channels
.export init_sound_code_vars
.export handle_sound_slots

; Every PRG ROM bank starts with a single byte specifying which number it is
.byte $01 ; The PRG ROM bank number (1)

; pointer table for music of level 1 (#$8 * #$2 = #$10 bytes)
; related to pulse channel config registers
; CPU address $8001
pulse_volume_ptr_tbl:
    .addr lvl_1_pulse_volume_00 ; CPU address $91dd
    .addr lvl_1_pulse_volume_01 ; CPU address $91e5
    .addr lvl_1_pulse_volume_02 ; CPU address $91ea
    .addr lvl_1_pulse_volume_03 ; CPU address $91f7
    .addr lvl_1_pulse_volume_04 ; CPU address $9204
    .addr lvl_1_pulse_volume_05 ; CPU address $9216
    .addr lvl_1_pulse_volume_06 ; CPU address $9229
    .addr lvl_1_pulse_volume_07 ; CPU address $923c

; music of level 2 (#$8 * #$2 = #$10 bytes)
    .addr lvl_2_pulse_volume_00 ; CPU address $a3db
    .addr lvl_2_pulse_volume_01 ; CPU address $a3e8
    .addr lvl_2_pulse_volume_02 ; CPU address $a3ee
    .addr lvl_2_pulse_volume_03 ; CPU address $a3f5
    .addr lvl_2_pulse_volume_04 ; CPU address $a402
    .addr lvl_2_pulse_volume_05 ; CPU address $a40f
    .addr lvl_2_pulse_volume_06 ; CPU address $a706
    .addr lvl_2_pulse_volume_07 ; CPU address $aa5f

; music of level 3 (#$8 * #$2 = #$10 bytes)
    .addr lvl_3_pulse_volume_00 ; CPU address $aa6c
    .addr lvl_3_pulse_volume_01 ; CPU address $aa73
    .addr lvl_3_pulse_volume_02 ; CPU address $ab04
    .addr lvl_3_pulse_volume_03 ; CPU address $ab11
    .addr lvl_3_pulse_volume_04 ; CPU address $ab1e
    .addr lvl_3_pulse_volume_05 ; CPU address $ab29
    .addr lvl_3_pulse_volume_06 ; CPU address $aa78
    .addr lvl_3_pulse_volume_07 ; CPU address $98ca

; music of level 4 (#$8 * #$2 = #$10 bytes)
    .addr lvl_4_pulse_volume_00 ; CPU address $98d5
    .addr lvl_4_pulse_volume_01 ; CPU address $98ea
    .addr lvl_4_pulse_volume_02 ; CPU address $98f1
    .addr lvl_4_pulse_volume_03 ; CPU address $98fd
    .addr lvl_4_pulse_volume_04 ; CPU address $9904
    .addr lvl_4_pulse_volume_05 ; CPU address $9909
    .addr lvl_4_pulse_volume_06 ; CPU address $9915
    .addr lvl_4_pulse_volume_07 ; CPU address $991c

; music of level 5 (#$8 * #$2 = #$10 bytes)
    .addr lvl_5_pulse_volume_00 ; CPU address $9928
    .addr lvl_5_pulse_volume_01 ; CPU address $9e71
    .addr lvl_5_pulse_volume_02 ; CPU address $9e7d
    .addr lvl_5_pulse_volume_03 ; CPU address $9c43
    .addr lvl_5_pulse_volume_04 ; CPU address $9c50
    .addr lvl_5_pulse_volume_05 ; CPU address $9c59
    .addr lvl_5_pulse_volume_06 ; CPU address $9c65
    .addr lvl_5_pulse_volume_07 ; CPU address $a064

; music of level 6 (#$8 * #$2 = #$10 bytes)
    .addr lvl_6_pulse_volume_00 ; CPU address $a072
    .addr lvl_6_pulse_volume_01 ; CPU address $a080
    .addr lvl_6_pulse_volume_02 ; CPU address $a088
    .addr lvl_6_pulse_volume_03 ; CPU address $9e84
    .addr lvl_6_pulse_volume_04 ; CPU address $9e90
    .addr lvl_6_pulse_volume_05 ; CPU address $9e9c
    .addr lvl_6_pulse_volume_06 ; CPU address $a713
    .addr lvl_6_pulse_volume_07 ; CPU address $a71b

; music of level 7 (#$6 * #$2 = #$c bytes)
    .addr lvl_7_pulse_volume_00 ; CPU address $a728
    .addr lvl_7_pulse_volume_01 ; CPU address $abd2
    .addr lvl_7_pulse_volume_02 ; CPU address $abda
    .addr lvl_7_pulse_volume_03 ; CPU address $abea
    .addr lvl_7_pulse_volume_04 ; CPU address $abeb
    .addr lvl_7_pulse_volume_05 ; CPU address $aa85

; silences pulse wave channel
; after pause or level end, or anytime need to silence pulse wave channel
; input
;  * x - sound register offset
;  * y - APU channel register offset
mute_pulse_channel:
    lda #$30                       ; a = #$30
    sta $4000,x                    ; set volume to 0 and duty cycle to 25%
    jsr wait                       ; execute #$0a nop instructions
    bne set_pulse_timer_and_length ; always branch to set pulse timer and length

; muse/unmutes pulse wave channel based on pause state
; input
;  * x - sound register offset
mute_unmute_pulse_channel:
    lda SOUND_FLAGS,x      ; load the current sound slot's sound flags
    and #$41               ; keep bits .x.. ...x
    ora PAUSE_STATE_01     ; merge with current game pause state (0 = unpaused, 1 = paused)
    bne mute_pulse_channel ; branch if paused

; input
;  * x - sound channel register config offset
;  * y - sound channel register offset
unmute_pulse_channel:
    lda PULSE_VOLUME,x   ; load current volume
    ora SOUND_CFG_HIGH,x
    sta $4000,y
    jsr wait             ; execute #$0a nop instructions

set_pulse_timer_and_length:
    lda SOUND_PULSE_PERIOD,x ; load in memory pulse period value
    sta APU_PULSE_PERIOD,y   ; set APU pulse period value
    jsr wait                 ; execute #$0a nop instructions
    lda SOUND_PULSE_LENGTH,x ; load in memory pulse length value
    sta APU_PULSE_LENGTH,y   ; set the APU pulse channel length
    jmp wait                 ; execute #$0a nop instructions

; see if pausing/unpausing
; if unpausing, turn off level music, otherwise play music
sound_check_pause:
    lda PAUSE_STATE      ; #$01 for paused, #$00 for not paused
    cmp PAUSE_STATE_01   ; compare to last frame pause state
    beq sound_check_exit ; pause already handled, exit
    sta PAUSE_STATE_01   ; set current pause value (0 = unpaused, 1 = paused)
    cmp #$00             ; see if unpausing
    beq @unpausing       ; if unpausing, continue to play level music
    jmp reset_channels   ; pausing, reset triangle, noise, and pulse channels to stop level music

@unpausing:
    lda SOUND_CODE+4          ; load sound code for sound slot 4
    beq @toggle_pulse_channel ; branch if not playing game pausing jingle
    lda SOUND_FLAGS+4         ; still playing game pausing jingle, load sound slot #$04 (pulse 1 channel) read index
                              ; this is the channel that the pause jingle uses
    bpl @unmute_pulse_2       ; branch if still playing the game pausing jingle
    lda $012d
    sta APU_PULSE_SWEEP

; unpausing in middle of pause jingle
@unmute_pulse_2:
    ldx #$04                 ; x = #$04 (pulse 2 channel config register)
    ldy #$00                 ; y = #$00 (pulse 1 channel register offset)
    jsr unmute_pulse_channel ; could have been optimized to a jmp call with no rts
    rts

@toggle_pulse_channel:
    lda SOUND_CODE                ; load sound slot 0's sound code (pulse 1 channel)
    beq sound_check_exit          ; exit if not playing anything
    ldx #$00                      ; x = #$00
    ldy #$00                      ; y = #$00
    jsr mute_unmute_pulse_channel ; mutes/unmutes pulse wave channel based on pause state

sound_check_exit:
    rts

; sound and music entry point, check each sound slot and if populated, execute
; that slot's sound command
handle_sound_slots:
    jsr sound_check_pause ; if unpausing, turn off level music, otherwise play music
    ldx #$00              ; initialize sound slot loop
    ldy #$00              ; initialize sound channel register offset to #$00 (pulse 1 channel)

; input
;  * x - sound slot index
;  * y - channel register offset, e.g. #$00 (pulse 1 channel), #$04 (pulse 2 channel), #$08 (triangle channel), #$0c (noise/dmc channel)
@sound_slot_loop:
    stx SOUND_CURRENT_SLOT    ; set the current sound slot to the current loop index
    sty SOUND_CHNL_REG_OFFSET ; set sound channel config register offset (#$00, #$04, #$08, or #$0c)
    lda SOUND_CODE,x          ; load sound code for sound slot
    beq @prep_next_loop       ; prep to move to next sound slot, or exit if looped through all slots
    tay                       ; sound slot has a sound code, transfer sound code to offset register y
    jsr handle_sound_code     ; read and interpret sound code in slot x

@prep_next_loop:
    inx                            ; increment sound slot index
    cpx #$06                       ; compare to after last sound slot
    beq sound_music_entry_exit     ; exit if looped through all sound slots
    cpx #$05                       ; see if last sound slot
    bne @load_sound_channel_offset ; branch if not the last sound slot
    lda #$0c                       ; sound slot #$05, set sound register offset to #$0c (noise channel)
    jmp @loop_next                 ; loop to last sound slot with the sound channel register to use being the noise channel

; all sound slots except #$05
; slot #$05 is always the noise channel
@load_sound_channel_offset:
    txa      ; transfer sound slot index to a
    asl      ; double sound slot index
    asl      ; double sound slot index again
    and #$0f ; keep low nibble, this is the new sound channel register offset
             ; (e.g. #$00 = pulse 1 channel, #$04 = pulse 2 channel)

@loop_next:
    tay                  ; set SOUND_CHNL_REG_OFFSET (e.g. #$00 = pulse 1 channel, #$04 = pulse 2 channel)
    jmp @sound_slot_loop

sound_music_entry_exit:
    rts

; read and interpret loaded sound code in slot x
; output
;  * x - sound slot with the sound code to handle
handle_sound_code:
    lda PAUSE_STATE_01         ; load current game pause state (0 = unpaused, 1 = paused)
    beq @check_sound_command   ; branch if game not paused
    lda SOUND_CODE,x           ; game paused, load sound code for current slot
    cmp #$54                   ; see if sound code is the pause jingle (sound_54)
    bne sound_music_entry_exit ; exit if not the game pausing jingle sound

@check_sound_command:
    jsr load_sound_code_addr   ; gets the sound_xx pointer for sound slot from SOUND_CMD_LOW_ADDR and stores in ($e0)
                               ; also sets y to point to beginning, i.e. #$00
    lda SOUND_FLAGS,x          ; load the current sound slot's sound flags
                               ; (0 = sound_xx command byte >= #$30, 1 = sound_xx command byte 0 < #$30)
    dec SOUND_CMD_LENGTH,x     ; decrement the number of video frames that the current sound code should execute for
                               ; before continuing to the next sound command
    bne @pulse_vol_and_vibrato ; branch if sound command hasn't finished executing
    jmp read_sound_command_00  ; finished with any previous sound command (or first command), read next/first sound command

@pulse_vol_and_vibrato:
    and #$41                      ; keep bit 0 and 6 of the sound slot's sound flags (mute flags)
    bne handle_sound_code_exit_00 ; exit if bit 0 or bit 6 is set (mute flags set)
    cpx #$02                      ; compare sound slot to #$02 (triangle channel)
    beq handle_sound_code_exit_00 ; exit if sound slot #$02 (triangle channel)
    cpx #$03                      ; compare sound slot to #$03 (noise/dmc channel)
    beq handle_sound_code_exit_00 ; exit if sound slot #$03 (noise/dmc channel)
    cpx #$02                      ; compare sound slot to #$02 (triangle channel)
    bcs @check_pulse_volume       ; branch if sound slot #$04 (pulse 1 channel), or #$05 (noise channel)
                                  ; not sure why developer didn't compare to #$04 here since they've already compared to #$02 and #$03 !(HUH)
    lda VIBRATO_CTRL,x            ; sound slot is #$00 (pulse 1 channel) or #$01 (pulse 2 channel)
                                  ; load VIBRATO_CTRL,x (#$80 = no vibrato)
    bmi @check_pulse_volume       ; skip incrementing SOUND_VOL_TIMER,x if VIBRATO_CTRL,x is negative
    inc SOUND_VOL_TIMER,x         ; VIBRATO_CTRL,x is [#$00-#$03], increment vibrato counter (increments up to VIBRATO_DELAY)
    lda VIBRATO_DELAY,x           ; load vibrato delay amount
    cmp SOUND_VOL_TIMER,x         ; see if vibrato timer has counted up to vibrato delay, if so, start checking vibrato
    bcs @check_pulse_volume       ; branch if SOUND_VOL_TIMER,x < VIBRATO_DELAY,x (vibrato hasn't started)
    jsr pulse_sustain_note        ; sustain the current pitch with optional vibrato (note: vibrato portion not used in Contra)
                                  ; SOUND_VOL_TIMER >= VIBRATO_DELAY

; see if volume is set or should be lowered
@check_pulse_volume:
    lda SOUND_FLAGS,x        ; load the current sound slot's sound flags
    and #$20                 ; see if volume decrescendo is complete by checking bit 5
    bne @check_volume_source ; branch if bit 5 set, indicating to no longer lower the volume (pause decrescendo)
                             ; bit 5 not set, check where volume should come from, and set volume
    lda SOUND_VOL_ENV,x      ; see if pulse volume range amount bit 7 is set (specifying to decrescendo)
    bmi lower_pulse_volume   ; branch when bit 7 set to lower the pulse volume by using and decrementing PULSE_VOLUME,x

; SOUND_VOL_ENV is greater than or equal to #$00 or decrescendo is complete
; pulse volume control override
@check_volume_source:
    lda SOUND_FLAGS,x               ; re-load the current sound slot's sound flags
    tay                             ; transfer sound flags to the y register
    and #$04                        ; keep bit 2
    bne handle_possible_decrescendo ; branch if bit 2 of the sound flags are set, indicating to use existing PULSE_VOLUME and not pulse_volume_ptr_tbl
                                    ; this method handles when decrescendo should pause and continue

; shapes volume envelope for note
; set new PULSE_VOLUME,x byte from lvl_x_pulse_volume_xx based on LVL_PULSE_VOL_INDEX,x and set pulse 1 and 2 configuration (volume)
; based on newly loaded PULSE_VOLUME,x, UNKNOWN_SOUND_01, and SOUND_CFG_HIGH,x
; called for simple sound commands as well
; CPU address $8154
; input
;  * x - sound channel offset
lvl_config_pulse:
    lda SOUND_VOL_ENV,x          ; pulse_volume_ptr_tbl offset, i.e. the current level music segment volume envelop to use (lvl_x_pulse_volume_xx)
    asl                          ; double since each entry is #$02 bytes
    tay                          ; transfer to offset register
    lda pulse_volume_ptr_tbl,y   ; read the low byte of the lvl_x_pulse_volume_xx address
    sta $e4                      ; set the low byte of the lvl_x_pulse_volume_xx address
    lda pulse_volume_ptr_tbl+1,y ; read the high byte of the lvl_x_pulse_volume_xx address
    sta $e5                      ; set the high byte of the lvl_x_pulse_volume_xx address

lvl_pulse_volume_byte:
    lda LVL_PULSE_VOL_INDEX,x      ; load read offset into lvl_x_pulse_volume_xx
    tay                            ; transfer to offset register
    lda ($e4),y                    ; read byte from lvl_x_pulse_volume_xx
    cmp #$fe                       ; see if reached end of data
    bcs lvl_pulse_volume_ctrl_code ; branch if lvl_x_pulse_volume_xx byte is greater than or equal to #$fe
                                   ; to handle control code
                                   ; #$fe means to set new offset based on next byte (not used in this game)
                                   ; #$ff means to set bit 2 of SOUND_FLAGS,x then exit
    inc LVL_PULSE_VOL_INDEX,x      ; increment lvl_x_pulse_volume_xx read offset
    and #$1f                       ; keep bits ...x xxxx of the lvl_x_pulse_volume_xx byte

; sets PULSE_VOLUME,x value to a, then updates APU_PULSE_CONFIG to one of
;  * (a - UNKNOWN_SOUND_01) | SOUND_CFG_HIGH,x
;  * #$00 | SOUND_CFG_HIGH,x
;  * a | SOUND_CFG_HIGH,x
; input
;  * a - the PULSE_VOLUME,x value
;  * x - current sound slot
set_pulse_config_a:
    sta PULSE_VOLUME,x ; set current lvl_x_pulse_volume_xx byte

; sets APU_PULSE_CONFIG value to one of the following
; only used when setting pulse channel 1 or 2 config register
;  * (PULSE_VOLUME,x - UNKNOWN_SOUND_01) | SOUND_CFG_HIGH,x
;  * #$00 | SOUND_CFG_HIGH,x
;  * PULSE_VOLUME,x | SOUND_CFG_HIGH,x
; input
;  * a - PULSE_VOLUME,x
;  * x - current sound slot
set_pulse_config:
    cmp #$02
    bcc @continue        ; branch if volume is less than #$02
    sec                  ; volume greater than #$02, set carry flag in preparation for subtraction
    sbc UNKNOWN_SOUND_01
    bpl @continue        ; branch if subtraction is a positive answer
    lda #$00             ; a = #$00 (negative volume, just use #$00)

@continue:
    ora SOUND_CFG_HIGH,x       ; merge with high nibble of pulse config value
    jsr ldx_pulse_triangle_reg ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @exit                  ; exit if there is already a sound playing on that channel that has priority
    sta APU_PULSE_CONFIG,x     ; set either pulse channel 1 or 2 config
                               ; a is either (PULSE_VOLUME,x - UNKNOWN_SOUND_01) | SOUND_CFG_HIGH,x
                               ; or #$00 | SOUND_CFG_HIGH,x
                               ; or PULSE_VOLUME,x | SOUND_CFG_HIGH,x

@exit:
    ldx SOUND_CURRENT_SLOT ; load current sound slot

handle_sound_code_exit_00:
    rts

; handle lvl_x_pulse_volume_xx byte control code
; #$fe means to set new offset based on next byte (unused in this game)
; #$ff means to set bit 2 of SOUND_FLAGS,x then exit
; input
;  * empty flag, set when lvl_x_pulse_volume_xx byte is #$fe
lvl_pulse_volume_ctrl_code:
    bne disable_lvl_pulse_ctrl_exit ; branch if #$ff, i.e. not #$fe to enable automatic decrescendo logic
                                    ; !(UNUSED) dead code, not ever executed in gameplay
                                    ; no lvl_x_pulse_volume_xx byte is #$fe
    iny                             ; byte is #$fe, increment offset into lvl_x_pulse_volume_xx
    lda ($e4),y                     ; load next byte from lvl_x_pulse_volume_xx
    sta LVL_PULSE_VOL_INDEX,x       ; set new offset
    jsr check_decrescendo_end_pause ; see if the decrescendo should resume and if so update SOUND_FLAGS,x
    jmp lvl_pulse_volume_byte       ; go back to read the next lvl_x_pulse_volume_xx byte

; set bit 2 of SOUND_FLAGS, which indicates to check handle_possible_decrescendo
; setting disables use of pulse_volume_ptr_tbl and instead use automatic decrescendo
disable_lvl_pulse_ctrl_exit:
    lda SOUND_FLAGS,x ; load the current sound slot's sound flags
    ora #$04          ; set bit 2
    sta SOUND_FLAGS,x
    rts

; bit 2 of SOUND_FLAGS,x indicating to grab volume from memory, handling when decrescendo should pause and continue
; input
;  * y - SOUND_FLAGS,x
handle_possible_decrescendo:
    tya                    ; transfer SOUND_FLAGS,x to a
    and #$02               ; keep bit 1
    bne resume_decrescendo ; branch if bit 1 set
                           ; this means both bit 1 and 2 are set, indicating DECRESCENDO_END_PAUSE has triggered
                           ; branching will resume the decrescendo

; pulse channel only
; see if the number of remaining frames in the sound command is less than the decrescendo pause end
; if so, decrescendo should resume, specify this by setting bits 1 and 2 in the SOUND_FLAGS,x
check_decrescendo_end_pause:
    lda SOUND_CMD_LENGTH,x      ; load the remaining length of the sound command
    cmp DECRESCENDO_END_PAUSE,x ; compare remaining length of the sound command to when decrescendo should resume
    bcs @exit                   ; exit if shouldn't resume decrescendo
    lda SOUND_FLAGS,x           ; resume decrescendo, load the current sound slot's sound flags
    ora #$06                    ; set bits 1 and 2
    sta SOUND_FLAGS,x           ; save sound flags now specify that decrescendo should resume

@exit:
    rts

; lowers the pulse volume by using and decrementing PULSE_VOLUME,x
; compare to resume_decrescendo
lower_pulse_volume:
    dec PULSE_VOL_DURATION,x      ; decrement pulse volume decrescendo duration (how many frames to lower the volume)
    bmi @pause_decrescendo        ; if volume decrescendo length elapsed, brach to pause decrescendo
    dec PULSE_VOLUME,x            ; decrement current volume
    bmi handle_sound_code_exit_01 ; branch if volume is negative
    lda PULSE_VOLUME,x            ; re-load volume
    jmp set_pulse_config          ; set pulse channel 1 or 2 config register based on PULSE_VOLUME,x, UNKNOWN_SOUND_01, and SOUND_CFG_HIGH,x

; set bit 5 and bit 2
@pause_decrescendo:
    lda SOUND_FLAGS,x               ; load the current sound slot's sound flags
    ora #$20                        ; set bit 5 (stop decrescendo)
    sta SOUND_FLAGS,x               ; store updated sound flags
    jmp disable_lvl_pulse_ctrl_exit

; set the pulse volume by using and decrementing PULSE_VOLUME,x
; called after DECRESCENDO_END_PAUSE has triggered and the decrescendo starts again
resume_decrescendo:
    dec PULSE_VOLUME,x            ; decrement volume
    beq handle_sound_code_exit_01 ; branch if volume is #$00
    lda PULSE_VOLUME,x            ; re-load  volume
    jmp set_pulse_config          ; set pulse channel 1 or 2 config register based on PULSE_VOLUME,x, UNKNOWN_SOUND_01, and SOUND_CFG_HIGH,x

handle_sound_code_exit_01:
    inc PULSE_VOLUME,x ; reset the previous volume level
    rts

; one of two modes (along with read_high_sound_cmd) of parsing sound commands.
; This mode is used for pulse channels only
; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03
; SOUND_FLAGS,x is odd, indicating initial sound code byte was < #$30
; CPU address $81e7
read_low_sound_cmd:
    lda ($e0),y               ; read sound_xx byte at current offset
    cmp #$fd                  ; compare to #$fd
    bcc @interpret_sound_byte ; branch if not #$fd, #$fe, nor #$ff
    and #$0f                  ; sound_xx byte is either #$fd, #$fe, or #$ff, keep low nibble
    jmp sound_cmd_routine_03

@interpret_sound_byte:
    jmp interpret_sound_byte ; interprets sound_xx byte

; sustains the current pitch (PULSE_NOTE,x) with optional vibrato (not used in Contra)
; input
;  * y - sound code read offset (always #$00 from handle_sound_code -> load_sound_code_addr) !(HUH)
;  * x - sound slot, either #$00 (pulse 1 channel) or #$01 (pulse 2 channel)
; jungle and hangar level music
pulse_sustain_note:
    tya                       ; transfer sound code read offset (#$00) to a
    pha                       ; backup y to the stack
    ldy SOUND_CHNL_REG_OFFSET ; load sound channel config register offset (#$00, #$04, #$08, or #$0c)
    sec                       ; set carry flag in preparation for subtraction
    sbc VIBRATO_DELAY,x       ; negate vibrato duration (or #$100 - vibrato duration)
                              ; y - VIBRATO_DELAY,x --> #$00 - VIBRATO_DELAY,x
    sta $e4                   ; store result in $e4
    lda VIBRATO_AMOUNT,x      ; load vibrato amount to apply
    and #$f0                  ; keep high nibble
    lsr
    lsr
    lsr
    lsr                       ; move to low nibble
    cmp $e4                   ; compare vibrato amount to negated VIBRATO_DELAY,x
    bne @check_vibrato_ctrl   ; branch if (negated $071e,x) is not equal to ($0180,x >> 4) to skip vibrato
    lda VIBRATO_DELAY,x       ; the following 8 lines of code are never executed in contra meaning no vibrato is used in contra !(UNUSED)
                              ; also not used in Japanese version which has one extra level track 'DEMO'
                              ; load period vibrato adjustment amount
    sta SOUND_VOL_TIMER,x     ; set vibrato counter; increments up to VIBRATO_DELAY before stopping
    inc VIBRATO_CTRL,x        ; increment vibrato control mode [#$00-#$03]
    lda VIBRATO_CTRL,x        ; load vibrato control mode [#$00-#$03]
    cmp #$04                  ; see if vibrato has gone more than #$03
    bcc @check_vibrato_ctrl   ; branch if vibrato control mode has not yet gone past max value (#$03)
    lda #$00                  ; a = #$00
    sta VIBRATO_CTRL,x        ; reset vibrato control mode back to #$00

@check_vibrato_ctrl:
    lda VIBRATO_CTRL,x ; load vibrato control mode [#$00-#$03]
    and #$01           ; keep bit 0
    bne @apply_vibrato ; branch if vibrato amount is odd (#$01 or #$03)
                       ; to add vibrato to note by pitching down (#$01) or up (#$03)
    lda PULSE_NOTE,x   ; vibrato amount is even, load existing pulse period value

; set pulse channel period to a
; pop a from stack
; input
;  * y - SOUND_CHNL_REG_OFFSET
@set_pulse_period:
    sta APU_PULSE_PERIOD,y
    jsr wait               ; execute #$0a nop instructions
    pla                    ; restore y value from stack (by loading into a)
    tay                    ; restore y value from before call
    rts

; VIBRATO_CTRL,x is #$01 or #$03 (odd), add vibrato to note by pitching up or down
@apply_vibrato:
    lda VIBRATO_AMOUNT,x  ; load vibrato amount adjust
    and #$0f              ; keep low nibble
    sta $e4
    lda VIBRATO_CTRL,x    ; reload vibrato amount
    and #$02              ; keep bit 1
    bne @pitch_up         ; branch if vibrato amount is #$03
    lda $e4               ; vibrato amount is #$01, pitching down
                          ; vibrato is #$01, add $e4 (low byte of VIBRATO_AMOUNT,x) to PULSE_NOTE,x (APU pulse period value)
    clc                   ; clear carry in preparation for addition
    adc PULSE_NOTE,x      ; add $e4 to APU pulse period value
    bcc @set_pulse_period ; set pulse channel period to a
    lda #$ff              ; overflow occurred, set maximum period (a = #$ff)
    jmp @set_pulse_period ; set pulse channel period to a

; VIBRATO_CTRL,x is #$03, subtract $e4 (low byte of VIBRATO_AMOUNT,x) from PULSE_NOTE,x (APU pulse period value)
@pitch_up:
    lda PULSE_NOTE,x      ; load note that is sustained or has the vibrato applied to, in Contra only ever sustained
    sec                   ; set carry flag in preparation for subtraction
    sbc $e4               ; subtract low byte of VIBRATO_AMOUNT,x from PULSE_NOTE,x
    jmp @set_pulse_period ; set pulse channel period to a

; called when SOUND_FLAGS,x is not zero
; input
;  * a - SOUND_FLAGS,x
;  * y - sound_xx byte read offset
read_sound_command_00:
    lsr                    ; shift bit 0 of SOUND_FLAGS,x to carry
                           ; (0 = sound_xx command byte >= #$30, 1 = sound_xx command byte 0 < #$30)
    bcs read_low_sound_cmd ; branch if byte 0 of sound_xx was less than #$30
                           ; reads sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03

; sound code starts with byte that is greater than or equal to #$30
; reads the sound byte and handles it
; input
;  * ($e0) - pointer to sound byte
;  * y - sound byte read offset
; output
;  * x - SOUND_CURRENT_SLOT [0-3]
read_high_sound_cmd:
    lda SOUND_CURRENT_SLOT   ; load sound slot index
    cmp #$03                 ; compare to sound slot #$03 (noise/dmc channel)
    beq parse_percussion_cmd ; branch if sound slot #$03 (noise/dmc channel)
    lda ($e0),y              ; not noise channel, load sound byte
    and #$f0                 ; keep high nibble
    cmp #$c0                 ; compare to #$c0
    bcs @regular_sound_cmd   ; branch if high nibble is greater than #$c0 to process the sound command
    jmp simple_sound_cmd     ; simple sound command, just a note and length multiplier

; sound byte < #$c0
@regular_sound_cmd:
    and #$30                  ; keep bits ..xx .... of high nibble
    lsr
    lsr
    lsr
    tax
    lda sound_cmd_ptr_tbl,x   ; load low byte of address pointer
    sta $e4                   ; set low byte of address pointer
    lda sound_cmd_ptr_tbl+1,x ; load high byte of address pointer
    sta $e5                   ; set high byte of address pointer
    ldx SOUND_CURRENT_SLOT    ; load current sound slot
    lda ($e0),y               ; load sound code byte
    and #$0f                  ; keep low nibble
    jmp ($e4)                 ; jump to sound_cmd_routine_xx

; only for sound slot #$03 (noise and dmc channel)
parse_percussion_cmd:
    lda ($e0),y              ; load sound code byte
    and #$f0                 ; keep high nibble
    cmp #$f0                 ; see if #$f
    bne @continue            ; branch if high nibble isn't #$f
    lda ($e0),y              ; high nibble is #$f
    and #$0f                 ; keep low nibble
    jmp sound_cmd_routine_03 ; high nibble #$f, go to sound_cmd_routine_03 with low nibble
                             ; either #$e or #$f
                             ; moves to next (child or parent) sound command
                             ; or finished with entire sound command and re-initialize channel

; high nibble isn't #$f
@continue:
    cmp #$d0
    beq @control_nibble_d            ; branch if sound command high nibble is #$d to determine SOUND_LENGTH_MULTIPLIER
                                     ; and then loop to actually play percussion sound
    jmp calc_cmd_len_play_percussion ; high nibble isn't #$f nor #$d
                                     ; play percussive sound (dpcm sample)

; high nibble is #$d (delay command)
; load low nibble and set it as SOUND_LENGTH_MULTIPLIER before looping to actually
; play the percussion sound sample
@control_nibble_d:
    lda ($e0),y                   ; read slot #$03 sound command byte
    and #$0f                      ; keep low nibble
    sta SOUND_LENGTH_MULTIPLIER,x ; set sound length multiplier
    iny                           ; increment sound_xx read offset
    jmp parse_percussion_cmd      ; recursively loop to read next byte of percussion command

; uses low nibble of sound_xx byte to determine sound code to play
; plays dmc sample for percussive track
; also will play sound_02 (bass drum/tom drum) for sound slots 0 and 1 (short percussive tick on noise channel)
play_percussive_sound:
    lda ($e0),y                 ; load sound_xx byte
    lsr
    lsr
    lsr
    lsr                         ; move high nibble to low nibble
    cmp #$0c                    ; see if high nibble was #$0c
    beq @exit                   ; exit if high nibble was #$0c
    tax                         ; transfer percussion_tbl offset to x
    sta PERCUSSION_INDEX_BACKUP ; backup percussion_tbl offset
    lda percussion_tbl,x        ; load sound code based on high nibble from sound_xx
    jsr play_sound              ; play percussion sound (sound_02, sound_25, sound_5a, sound_5b, sound_5c)
    lda PERCUSSION_INDEX_BACKUP ; restore percussion_tbl offset
    cmp #$03                    ; see if shifted sound nibble offset was less than #$03
    bcc @exit                   ; exit if index less than #$03
    lda #$02                    ; shifted sound nibble is greater than or equal to #$03, play sound_02 (bass drum/tom drum) as well
                                ; note that offset 5 (sound_25) is also slot #$05 and will cause sound_02 to not play
    jsr play_sound              ; play sound_02 (short percussive tick)

@exit:
    ldx SOUND_CURRENT_SLOT ; load current sound slot
    rts

; contains sound codes to play the intro theme (#$08 bytes)
; related to music tracks instruments
; CPU address $82cd
;  * sound_02 - percussive tick (bass drum/tom drum)
;  * sound_25 - game intro tune song noise explosion
;  * sound_5a - dmc sample (high hat)
;  * sound_5b - dmc sample (snare)
;  * sound_5c - dmc sample (high hat)
percussion_tbl:
    .byte $02,$5a,$5b,$5a,$5b,$25,$5c,$5d

; low sound command - interprets sound_xx byte
; input
;  * a - sound_xx byte
;  * y - sound code read offset
interpret_sound_byte:
    and #$f0               ; keep high nibble
    cmp #$20               ; see if high nibble is #$20, this is a control byte
    bne @high_nibble_not_2 ; branch if high nibble isn't #$20
    lda ($e0),y            ; high nibble is #$20, this is a control byte, reload sound byte
                           ; #$2 - sets the number of video frames to wait before reading the next sound
                           ; command (`SOUND_LENGTH_MULTIPLIER`) as well as the high nibble of the APU
                           ; configuration register for the sound channel (`SOUND_CFG_HIGH`).
    and #$0f               ; keep low nibble to see if using low nibble for SOUND_LENGTH_MULTIPLIER or the entire next byte
    bne @continue          ; branch if low nibble isn't #$f to use low nibble for SOUND_LENGTH_MULTIPLIER
    iny                    ; low nibble is #$f, i.e. sound_xx byte is #$2f, use next byte as full byte multiplier
    lda ($e0),y            ; increment sound_xx byte read offset

@continue:
    sta SOUND_LENGTH_MULTIPLIER,x ; store low nibble (or next full byte) in SOUND_LENGTH_MULTIPLIER,x
    iny                           ; increment sound_xx byte read offset
    lda ($e0),y                   ; load new sound byte
    sta SOUND_CFG_HIGH,x          ; store pulse config high nibble value
    iny                           ; increment sound_xx byte read offset
    beq @high_nibble_not_2        ; !(WHY?) I don't think this will branch as y wouldn't go up to #$ff
    jmp read_low_sound_cmd        ; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03

; high nibble wasn't 2, see if #$1 (flatten note or set sweep), or not #$1 (@high_nibble_not_1)
; - #$10 will set sweep, #$1x will flatten note
@high_nibble_not_2:
    cmp #$10                        ; see if sound code high nibble is #$10
    bne @high_nibble_not_1          ; branch if the high nibble isn't #$1
                                    ; branching sets command length, apu channel config, and note value
    lda ($e0),y                     ; high nibble is #$1, reload full byte, if #$10 set optional sweep and continue
                                    ; otherwise flatten note (not used in Contra)
    iny                             ; increment sound_xx read offset
    cmp #$10                        ; compare full byte to #$10
    bne @flatten_note               ; branch if full byte of sound_xx isn't #$10 to slightly flatten the note
    lda ($e0),y                     ; sound byte is #$10, load next sound_xx byte for setting optional sweep and continue
    bne @set_sweep                  ; branch if there is a sweep value to load it
    lda SOUND_FLAGS,x               ; no sweep, strip bit 7 (has sweep flag)
                                    ; load the current sound slot's sound flags
    and #$7f                        ; strip bit 7 (has sweep flag)
    sta SOUND_FLAGS,x               ; set new sound flags for sound slot (disable sweep)
    lda #$7f                        ; a = #$7f (pulse 1 channel disable sweep)
    bne @pulse_1_set_sweep_continue ; always branch to continue setting APU registers

; sound byte wasn't #$00, set sweep and pulse 1 decrescendo duration PULSE_VOL_DURATION if sound slot #$04
@set_sweep:
    lda SOUND_FLAGS,x ; load the current sound slot's sound flags
    ora #$80          ; set bit 7
    sta SOUND_FLAGS,x ; set bit 7 (sweep flag)
    lda ($e0),y       ; load APU_PULSE_SWEEP value

; sets the pulse 1 channel PULSE_VOL_DURATION if current sound slot is #$04 (pulse 1 channel)
@pulse_1_set_sweep_continue:
    cpx #$04                 ; see if sound slot 4 (pulse 1 channel)
    bne @set_sweep_continue  ; skip setting duration if not sound slot 4
    sta PULSE_VOL_DURATION+3 ; set slot 3's (noise/dcm channel) volume duration

@set_sweep_continue:
    jsr ldx_pulse_triangle_reg        ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @next_high_control_sound_byte ; branch if there is already a sound playing on that channel that has priority
    sta APU_PULSE_SWEEP,x             ; enable or disable sweep

@next_high_control_sound_byte:
    ldx SOUND_CURRENT_SLOT ; load current sound slot
    iny
    jmp read_low_sound_cmd ; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03

@flatten_note:
    lda SOUND_FLAGS,x      ; load the current sound slot's sound flags
    ora #$10               ; set bit 4 (slightly flatten note flat)
    sta SOUND_FLAGS,x      ; set new sound slot flag values
    jmp read_low_sound_cmd ; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03

; low sound command high nibble of sound code is not #$10
; now will set set command length, apu channel config, note value, and then exit
; to allow sound to play for expected duration
@high_nibble_not_1:
    lda SOUND_LENGTH_MULTIPLIER,x ; load sound command length
    sta SOUND_CMD_LENGTH,x        ; set loop counter
    lda ($e0),y                   ; load volume
    cmp #$f8
    bne @set_in_mem_cfg
    iny                           ; sound byte is #$f8, increment sound byte read offset
    lda ($e0),y                   ; load next sound byte

@set_in_mem_cfg:
    lsr
    lsr
    lsr
    lsr                  ; move high nibble to low nibble
    sta SOUND_CFG_LOW,x  ; set new PULSE_VOLUME value to high nibble of sound_xx byte
    lda SOUND_CFG_HIGH,x ; load configuration high byte
    and #$10             ; keep bit 4 (C - constant volume flag)
    beq @dont_set_volume ; branch to restore SOUND_CFG_HIGH,x to not include volume when setting configuration
    lda SOUND_CFG_LOW,x  ; reload high nibble of sound_xx byte
    ora SOUND_CFG_HIGH,x ; merge previous sound byte with high nibble of current sound byte

; set config register ($4000, $4004, or $400c) and period & length register
@set_cfg_period_length:
    jsr ldx_pulse_triangle_reg  ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @load_set_period_length ; branch if there is already a sound playing on that channel that has priority
    sta $4000,x                 ; set pulse, triangle, or noise channel configuration

@load_set_period_length:
    ldx SOUND_CURRENT_SLOT ; load current sound slot
    lda ($e0),y            ; read current sound_xx byte
    and #$0f               ; keep low nibble
    sta $ef                ; store high byte (3 bits) of note period ($4003/$4007)
    iny                    ; increment sound_xx read offset
    lda ($e0),y            ; load next sound_xx byte
    sta $ee                ; store low byte of note period ($4002/$4006)
    jmp set_note           ; set note value

; C is set on APU configuration, indicating constant volume, restore full high byte of configuration
@dont_set_volume:
    lda SOUND_CFG_HIGH,x       ; load high nibble for when storing in pulse config register
    jmp @set_cfg_period_length

cfg_triangle_channel:
    lda SOUND_TRIANGLE_CFG  ; load triangle config
    sta APU_TRIANGLE_CONFIG ; set triangle config
    jmp clear_mute_set_note

prep_pulse_set_note:
    lda SOUND_CFG_LOW,x      ; load new PULSE_VOLUME
    jsr set_pulse_config_a   ; sets PULSE_VOLUME,x value to a, then updates APU_PULSE_CONFIG
    lda SOUND_VOL_ENV,x      ; load the pulse volume range amount (low nibble) (how many frames to lower the volume)
    and #$0f                 ; keep low nibble
    sta PULSE_VOL_DURATION,x ; set the pulse volume decrescendo duration (how many frames to lower the volume)
    jmp clear_mute_set_note  ; set note (APU_PULSE_LENGTH) based on sound byte

; play a single note with a specified length change from previous note
; called from read_high_sound_cmd, sound byte high nibble less than #$0c
; sound_xx byte
;  * high nibble - indirect offset into note_period_tbl
;  * low nibble - multiplier to use with previous note's base length
;    for example, if the previous note was #$09 and #$04 and the low nibble is #$04, then note length will be the same
simple_sound_cmd:
    jsr calc_cmd_len_play_percussion ; calculates SOUND_CMD_LENGTH and DECRESCENDO_END_PAUSE
                                     ; doesn't play any percussion since simple_sound_cmd doesn't execute for sound slot #$03
    cpx #$02                         ; compare to sound slot #$02 (triangle channel)
    beq cfg_triangle_channel         ; branch if slot #$02 (triangle channel)
    lda SOUND_VOL_ENV,x              ; pulse_volume_ptr_tbl offset, i.e. the current level music segment to play (lvl_x_pulse_volume_xx)
    bmi prep_pulse_set_note
    lda #$00                         ; a = #$00
    sta LVL_PULSE_VOL_INDEX,x
    sty $e6                          ; backup sound_xx read offset
    jsr lvl_config_pulse             ; read lvl_x_pulse_volume_xx based on LVL_PULSE_VOL_INDEX,x and set pulse 1 and 2 configuration
    ldy $e6                          ; restore sound_xx read offset

clear_mute_set_note:
    lda SOUND_FLAGS,x      ; load the current sound slot's sound flags
    and #$99               ; keep bits x..x x..x, clearing volume and mute flags
    sta SOUND_FLAGS,x      ; update sound flags
    lda ($e0),y            ; load sound_xx byte
    and #$f0               ; keep high nibble
    lsr
    lsr
    lsr                    ; shift high nibble right 3 bits
    tax                    ; transfer to offset register
    tya                    ; transfer sound_xx read offset to a for backing up
    pha                    ; back up sound_xx read offset to stack
    ldy SOUND_CURRENT_SLOT ; load current sound slot
    lda SOUND_PITCH_ADJ,y  ; load sound period value for slot
    beq @continue          ; if loaded value is #$00 branch
    txa                    ; load the high nibble (now in low nibble) from the sound_xx byte
    clc                    ; clear carry in preparation for addition
    adc SOUND_PITCH_ADJ,y  ; add adjustment to offset current note_period_tbl offset
    tax                    ; set the note_period_tbl read offset

@continue:
    pla                       ; restore sound_xx read offset
    tay                       ; restore sound_xx read offset to y
    lda note_period_tbl,x     ; load low period byte music note
    sta $ee                   ; store low byte of note period ($4002/$4006)
    lda note_period_tbl+1,x   ; load high period byte music note
    sta $ef                   ; store high byte (3 bits) of note period ($4003/$4007)
    ldx SOUND_CURRENT_SLOT    ; load current sound slot (!(HUH) this value is overwritten two lines down)
    lda SOUND_PERIOD_ROTATE,x ; load pitch shifting amount
    tax                       ; transfer amount to x

@loop:
    cpx #$04       ; only shift if the value is not #$04
    beq @exit_loop ; exit if SOUND_PERIOD_ROTATE,x is #$04
    lsr $ef        ; shift right high byte (3 bits) of note period ($4003/$4007)
    ror $ee        ; rotate low byte of note period ($4002/$4006)
    inx            ; add one to the sound slot
    bne @loop      ; branch until reach #$00

@exit_loop:
    ldx SOUND_CURRENT_SLOT  ; load current sound slot
    cpx #$02                ; compare to sound slot #$02 (triangle channel)
    bcs set_note            ; branch if slot #$02 (triangle), #$03 (noise), #$04 (pulse 1), or #$05 (noise)
    lda VIBRATO_CTRL,x      ; sound slot is #$00 (pulse 1) or #$01 (pulse 2), load vibrato control #$80 = no vibrato
    bmi set_note            ; branch to set period and length directly if no vibrato
    lda $ee                 ; load low byte of note period ($4002/$4006)
    sta PULSE_NOTE,x        ; store low byte of note period in memory for later when checking for vibrato
    lda SOUND_FLAGS,x       ; load the current sound slot's sound flags
    and #$10                ; keep bit 4 (slightly flatten note flag)
    beq @load_slot_set_note ; branch if note should not be flattened slightly
    inc PULSE_NOTE,x        ; increase period, which lowers the frequency of the note

; load sound slot and set the period and length registers to specify the note to play
@load_slot_set_note:
    ldx SOUND_CURRENT_SLOT ; load current sound slot

; sets the period and length registers to specify the note to play
; input
;  * $ee - low byte of note period ($4002/$4006)
;  * $ef - high byte (3 bits) of note period ($4003/$4007)
set_note:
    lda SOUND_FLAGS,x ; load the current sound slot's sound flags
    and #$10          ; keep bit 4 (flatten note bit)
    beq @continue_00  ; branch if bit it clear, indicating to not flatten the specified note
    inc $ee           ; increment low byte of note period ($4002/$4006), slightly flattens a note
    bne @continue_00  ; branch if no overflow occurred
    inc $ef           ; increment high byte (3 bits) of note period ($4003/$4007)

@continue_00:
    lda $ef                  ; load high byte (3 bits) of note period ($4003/$4007)
    cpx #$02                 ; compare to sound slot #$02 (triangle channel)
    beq @set_length          ; branch if sound slot #$02 (triangle channel) to set APU_PULSE_LENGTH
    cpx #$05                 ; compare to sound slot #$05 (noise channel)
    beq @continue_01         ; branch if sound slot #$05 (noise channel) to set APU_PULSE_LENGTH
                             ; !(HUH) could have branched to @set_length directly, a already has $ef
    cmp SOUND_PULSE_LENGTH,x ; compare to the current pulse/noise length
    bne @set_length          ; set new length if not already set
    lda SOUND_FLAGS,x        ; load the current sound slot's sound flags
    bmi @continue_01         ; branch if sound flags negative to to set APU_PULSE_LENGTH
    lda SOUND_CFG_HIGH,x     ; load high nibble for when storing in pulse config register
    and #$10                 ; keep bits ...x ....
    bne @set_period          ; skip setting APU_PULSE_LENGTH if SOUND_CFG_HIGH,x bit 4 set

@continue_01:
    lda $ef

; set length and high 3 bits of timer
@set_length:
    sta SOUND_PULSE_LENGTH,x   ; set in memory copy of current pulse length
    ora #$08                   ; set bit 0 of high timer to be 1
    jsr ldx_pulse_triangle_reg ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @set_period            ; branch if there is already a sound playing on that channel that has priority
    sta APU_PULSE_LENGTH,x     ; set duration and high 3 bits of the pulse, or triangle channel

; set low period
@set_period:
    lda $ee                  ; load low byte of note period ($4002/$4006)
    ldx SOUND_CURRENT_SLOT   ; load current sound slot
    cpx #$02                 ; compare to sound slot #$02 (triangle channel)
    bcs @set_apu_period      ; branch if slot #$02 (triangle), #$03 (noise), #$04 (pulse 1), or #$05 (noise)
    sta SOUND_PULSE_PERIOD,x ; set in memory pulse period value

@set_apu_period:
    jsr ldx_pulse_triangle_reg   ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @restore_x_adv_sound_ptr ; branch if there is already a sound playing on that channel that has priority
                                 ; continue to restore x to the sound slot index, update SOUND_CMD_LOW_ADDR value, and exit
    sta APU_PULSE_PERIOD,x       ; update APU pulse period

@restore_x_adv_sound_ptr:
    ldx SOUND_CURRENT_SLOT ; load current sound slot

; simple_sound_cmd - finished parsing 'sound command' and next frame will pick up at new location
; which is just after parsed sound command.
; updates the sound_xx read offset, i.e. SOUND_CMD_LOW_ADDR to point to current read location + 1
; game logic uses load_sound_code_addr to know where to read
; input
;  * y - current sound_xx read offset
;  * $e0 - SOUND_CMD_LOW_ADDR (address low byte)
;  * $e1 - SOUND_CMD_HIGH_ADDR (address high byte)
adv_sound_cmd_addr:
    iny                       ; increment sound_xx sound command read offset
    tya                       ; transfer sound_xx sound command read offset to a
    clc                       ; clear carry in preparation for addition
    adc $e0                   ; add to current read offset address low byte
    sta SOUND_CMD_LOW_ADDR,x  ; set new starting position to read sound_xx data (low byte)
    lda #$00                  ; a = #$00
    adc $e1                   ; add any carry from previous addition to current read offset address high byte
    sta SOUND_CMD_HIGH_ADDR,x ; set new starting position to read sound_xx data (high byte)
    rts

; e.g. sound_1b - level 1 jungle boss siren
restore_parent_sound_cmd_addr:
    lda NEW_SOUND_CODE_LOW_ADDR,x  ; load new sound code address low byte
    sta $e0                        ; set new sound code address low byte
    lda NEW_SOUND_CODE_HIGH_ADDR,x ; load new sound code address high byte
    sta $e1                        ; set new sound code address high byte
    lda SOUND_FLAGS,x              ; load the current sound slot's sound flags
    and #$f7                       ; strip bit 7 (sweep flag)
    sta SOUND_FLAGS,x              ; set the sound slot's sound flags
    ldy #$00
    jmp read_sound_command_01

; sound_cmd_routine_03 - low nibble #$0f
; either initialize sound channel, or finished with 'sound_xx_part' go back to 'parent' sound command and parse it
low_nibble_f:
    lda SOUND_FLAGS,x                 ; load the current sound slot's sound flags
    and #$08
    bne restore_parent_sound_cmd_addr ; branch if bit 3 is set
    lda SOUND_CODE,x                  ; bit 3 not set, load sound code
    sta $e6                           ; backup sound code
    lda #$00

; input
;  * a - sound code (#$00 is always passed in)
;  * x - sound slot offset
exe_channel_init_ptr_tbl_routine:
    sta SOUND_CODE,x             ; clear sound code
    txa                          ; transfer sound slot offset to a for doubling
    asl                          ; double sound slot offset since each entry in channel_init_ptr_tbl is #$02 bytes
    tax                          ; transfer back to x
    lda channel_init_ptr_tbl,x   ; load low byte of address
    sta $e4                      ; store low byte in $e4
    lda channel_init_ptr_tbl+1,x ; load high byte of address
    sta $e5                      ; store high byte in $e5
    ldx SOUND_CURRENT_SLOT       ; restore current sound slot
    jmp ($e4)

; moves to next (child or parent) sound command, or finished with entire sound command and re-initialize channel
; - could be entering a shared sound command used for playing shared sound data across different sound_xx commands (#$fd)
; - could be entering a repeat subcommand used to repeat sound parts (#$fe)
; - could be exiting a shared sound command and need to return to parent sound command (#$ff)
; - could be finished reading entire sound (#$ff)
;  * a - low nibble of sound byte value
sound_cmd_routine_03:
    cmp #$0e                       ; compare low nibble of sound byte to #$e
    beq @repeat_cmd                ; branch if sound command is #$fe to allow repeating a shared sound part ($e0),y+1 times
    bcs low_nibble_f
    jsr move_sound_code_read_addr  ; sound command is #$fd, move to sound command address to shared sound part beginning
    iny                            ; increment sound code read offset from address byte
    tya                            ; transfer sound_xx read offset to a
    clc                            ; clear carry before updating ($e0)'s address
    adc $e0                        ; skip the 2 address bytes that specified SOUND_CMD_LOW_ADDR
    sta NEW_SOUND_CODE_LOW_ADDR,x  ; set sound command return location low byte once shared sound command part specified in move_sound_code_read_addr executes
    lda #$00
    tay
    adc $e1                        ; add any carry from low byte address to high byte
    sta NEW_SOUND_CODE_HIGH_ADDR,x ; set sound command return location high byte once shared sound command part specified in move_sound_code_read_addr executes
    lda SOUND_FLAGS,x              ; load the current sound slot's sound flags
    ora #$08                       ; set bit 3
    sta SOUND_FLAGS,x              ; save sound slot's flags
    jmp @load_sound_code_addr      ; gets the sound_xx pointer for sound slot from SOUND_CMD_LOW_ADDR and stores in ($e0)
                                   ; then begins reading that sound command

; #$fe command, i.e. a repeat command. Allows repeating a section of music a specified number of times
; .byte $fe,$03 ; repeat #$3 times
; .addr sound_3e
@repeat_cmd:
    inc SOUND_REPEAT_COUNT,x         ; increment sound part repeat counter
    lda SOUND_REPEAT_COUNT,x         ; load current sound part repeat counter
    iny                              ; increment sound code read byte offset
    cmp ($e0),y                      ; compare SOUND_REPEAT_COUNT,x to sound code byte
    beq skip_3_read_sound_command_01 ; looped ($e0),y times, don't loop any more, move to next sound command
    bmi @move_sound_code_read_addr   ; branch if SOUND_REPEAT_COUNT,x < number of times to repeat shared sound part
    dec SOUND_REPEAT_COUNT,x         ; not sure if ever executed, shouldn't go past ($e0),y, but if so, decrement and repeat !(WHY?)

@move_sound_code_read_addr:
    jsr move_sound_code_read_addr ; update the sound code read address based on the next two bytes of the sound code

@load_sound_code_addr:
    jsr load_sound_code_addr ; gets the sound_xx pointer for sound slot from SOUND_CMD_LOW_ADDR and stores in ($e0)
                             ; also sets y to point to beginning, i.e. #$00

read_sound_command_01:
    lda SOUND_FLAGS,x       ; load the current sound slot's sound flags
    lsr                     ; shift bit 0 to carry (0 = sound_xx byte >= #$30, 1 = sound_xx byte 0 < #$30)
    bcs @read_low_sound_cmd ; branch if byte 0 of sound_xx was less than #$30
                            ; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03
    jmp read_high_sound_cmd ; read sound_xx,y byte and handle it

@read_low_sound_cmd:
    jmp read_low_sound_cmd ; read sound byte and if not [#$fd-#$ff] interpret_sound_byte otherwise sound_cmd_routine_03

; skips the shared sound repeat loop counter (1 byte), and the specified address (2 bytes), then reads next sound command (read_sound_command_01)
; also resets shared sound part repeat counter
; input
;  * x - sound slot index
;  * y - sound byte read offset
skip_3_read_sound_command_01:
    lda #$00                  ; clear a register
    sta SOUND_REPEAT_COUNT,x  ; reset shared sound part repeat counter
    iny
    iny
    iny                       ; skip #$03 bytes of sound_xx code
    tya                       ; transfer sound_xx read offset to a
    clc                       ; clear carry in preparation for addition
    adc $e0                   ; add to sound byte read location's low byte
    sta $e0                   ; set new sound code read location's low byte
    lda #$00
    tay                       ; clear y register
    adc $e1                   ; add any carry from previous addition into high byte of sound byte read location
    sta $e1                   ; set any carry for new read location pointer address
    jmp read_sound_command_01 ; logically same as read_sound_command_00
                              ;  (except SOUND_FLAGS are loaded within read_sound_command_00)

; set sound channel configuration (mute), advance sound command address
; input
;  * a - amount to multiply SOUND_CMD_LENGTH by
;  * y - current sound_xx read offset
sound_cmd_routine_00:
    jsr calc_cmd_delay   ; multiply SOUND_CMD_LENGTH by a
    lda #$00             ; sound config low nibble = #$00 (mute sound channel)
    cpx #$02             ; see if sound slot #$02 (triangle channel)
    beq @continue
    lda SOUND_CFG_HIGH,x ; pulse/noise channels use SOUND_CFG_HIGH,x

@continue:
    jsr ldx_pulse_triangle_reg ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @adv_read_addr         ; branch if there is already a sound playing on that channel that has priority
    sta $4000,x                ; set pulse 1, pulse 2, or triangle configuration

@adv_read_addr:
    ldx SOUND_CURRENT_SLOT ; load current sound slot
    lda SOUND_FLAGS,x      ; load the current sound slot's sound flags
    ora #$40               ; set bit 6 (mute flag)
    sta SOUND_FLAGS,x
    jmp adv_sound_cmd_addr ; set the sound_xx command read offset to current read location + 1

; set in memory configuration for channel, set multiplier, and sometimes read_high_sound_cmd
; input
;  * a - low nibble of sound byte value
;  * y - current sound_xx read offset
sound_cmd_routine_01:
    sta SOUND_LENGTH_MULTIPLIER,x        ; store value used to calculate SOUND_CMD_LENGTH
    iny                                  ; increment sound code read offset
    lda ($e0),y                          ; load sound code byte
    cpx #$02                             ; compare current sound slot to sound slot #$02 (triangle channel)
    beq set_sound_triangle_config        ; branch if triangle channel to set triangle config in memory and read_high_sound_cmd
    and #$0f                             ; not triangle sound slot, get low nibble
    sec
    sbc UNKNOWN_SOUND_01
    bpl @set_cfg_read_sound_byte         ; if result is positive set full in memory apu config and read_high_sound_cmd
    lda #$00                             ; used to set SOUND_CODE,x to #$00
    jmp exe_channel_init_ptr_tbl_routine ; initialize sound channel

@set_cfg_read_sound_byte:
    sta SOUND_CFG_LOW,x     ; set result of sound_xx low nibble - UNKNOWN_SOUND_01
    lda ($e0),y             ; load sound code byte
    and #$f0                ; keep high nibble
    sta SOUND_CFG_HIGH,x    ; store high nibble of pulse config value (see set_pulse_config)
    iny                     ; increment sound code read offset
    lda ($e0),y             ; load sound volume envelop control byte
                            ; when bit 7 set, automatic decrescendo, otherwise, will follow pattern from pulse_volume_ptr_tbl
    sta SOUND_VOL_ENV,x     ; set indicator whether or not to lower the volume (see @check_pulse_volume)
    iny                     ; increment sound code read offset
    lda ($e0),y             ; load sound code byte
    and #$0f
    sta UNKNOWN_SOUND_00,x  ; see calc_cmd_len_play_percussion, amount to multiply to SOUND_CMD_LENGTH,x when calculating DECRESCENDO_END_PAUSE,x
    iny
    jmp read_high_sound_cmd ; reads sound_xx,y byte and handles it

; sets in-memory value for triangle configuration SOUND_TRIANGLE_CFG
; called only from sound_cmd_routine_01 for triangle sound slot
; input
;  * a - sound byte value that was the byte after the sound_cmd_routine_01 control byte
set_sound_triangle_config:
    sta SOUND_TRIANGLE_CFG  ; set in memory value for triangle config
    iny
    jmp read_high_sound_cmd ; reads sound_xx,y byte and handles it

; set/adjust pitch, and read_high_sound_cmd
; input
;  * a - low nibble of control byte
;  * y - sound byte read offset
sound_cmd_routine_02:
    cmp #$05                  ; compare low nibble of sound code to #$05
                              ; when less than #$05 it is referring to a sound slot
    bcs @high_val             ; branch if more than #$05
    sta SOUND_PERIOD_ROTATE,x ; when not #$04, the number of times to shift the high byte of note_period_tbl into the low byte
    iny                       ; increment read offset
    jmp read_high_sound_cmd   ; reads sound_xx,y byte and handles it

@high_val:
    cmp #$08
    beq @flip_flatten_note_adv
    cmp #$0b
    beq @set_vibrato_vars_adv
    cmp #$0c
    beq @set_pitch_adj_adv
    iny                        ; unknown low byte, move to next sound byte
    jmp read_high_sound_cmd    ; reads sound_xx,y byte and handles it

; low nibble of control byte is #$08, flip bit specifying whether to slightly flatten note
@flip_flatten_note_adv:
    lda SOUND_FLAGS,x       ; load the current sound slot's sound flags
    eor #$10                ; flip bit 4 (whether or not to slightly flatten note)
    sta SOUND_FLAGS,x
    iny                     ; increment sound_xx read offset
    jmp read_high_sound_cmd ; reads sound_xx,y byte and handles it

; sound_cmd_routine_02 -> low nibble #$b
; set vibrato variables, and move to next sound byte
; jungle and hangar music
@set_vibrato_vars_adv:
    iny                     ; increment sound_xx read offset
    lda ($e0),y             ; load sound_xx byte
    sta VIBRATO_DELAY,x     ; set delay until SOUND_VOL_TIMER has counted up to this value before checking vibrato
    cmp #$ff                ; see if sound_xx byte is #$ff
    beq @end_of_sound_code  ; branch if sound_xx byte is #$ff
    iny                     ; increment sound_xx read offset
    lda ($e0),y             ; load sound_xx byte
    sta VIBRATO_AMOUNT,x    ; set the amount of vibrato to apply
    lda #$00                ; a = #$00
    sta VIBRATO_CTRL,x      ; set vibrato mode to #$00
    iny                     ; increment sound_xx read offset
    jmp read_high_sound_cmd ; loop to read next sound_xx,y byte and handle it

; sound_xx byte is #$ff, read entire sound_xx code
@end_of_sound_code:
    lda #$80                ; disable vibrato check
    sta VIBRATO_CTRL,x      ; set to not use vibrato (0 = yes, #$80 = no)
    iny
    jmp read_high_sound_cmd ; read sound_xx,y byte and handle it

; sound_cmd_routine_02 -> low nibble #$c
; sets the pitch adjustment, and move to next sound byte
@set_pitch_adj_adv:
    iny                     ; increment sound_xx read offset
    lda ($e0),y             ; load sound_xx byte
    asl a                   ; double value since each entry in note_period_tbl is #$02 bytes
    sta SOUND_PITCH_ADJ,x   ; set sound period adjustment (adjusts note frequency/pitch)
    iny                     ; increment sound_xx read offset
    jmp read_high_sound_cmd ; reads sound_xx,y byte and handles it

; called from calc_cmd_len_play_percussion when sound slot is #$03 (noise/dmc channel)
; advance sound_xx read offset, and plays dpcm sample based on low nibble
adv_sound_play_percussive:
    jsr adv_sound_cmd_addr    ; advance the sound_xx read offset (SOUND_CMD_LOW_ADDR) to current read location + 1
    dey                       ; decrement sound_xx read offset (it was incremented by adv_sound_cmd_addr)
    jmp play_percussive_sound ; play appropriate intro sound code based on next sound_xx high nibble

; load sound_xx byte and calculate new SOUND_CMD_LENGTH and DECRESCENDO_END_PAUSE
; for simple_sound_cmd, high nibble is less than #$c
; for read_high_sound_cmd sound slot #$03, also play a percussion sound sample (adv_sound_play_percussive)
; input
;  * x - sound slot index [0-3]
calc_cmd_len_play_percussion:
    lda ($e0),y ; load sound byte
    and #$0f    ; keep low nibble

; input
;  * a - amount (+1) multiplied to SOUND_LENGTH_MULTIPLIER,x to get total delay
;        ex: a = #$03, SOUND_LENGTH_MULTIPLIER,x = #$09 => #$24 == #$04 * #$09
calc_cmd_delay:
    sta $e4                       ; set amount of times to add $0154 to itself
    beq @skip_loop                ; don't loop if multiplier is #$00
    lda SOUND_LENGTH_MULTIPLIER,x

@calc_delay_loop:
    clc                           ; clear carry in preparation for addition
    adc SOUND_LENGTH_MULTIPLIER,x ; add $0154 to itself
    dec $e4                       ; decrement loop counter
    bne @calc_delay_loop          ; loop if not finished adding to itself
    beq @loop_complete            ; break loop if added $0154 $e4 times

@skip_loop:
    lda SOUND_LENGTH_MULTIPLIER,x ; load new loop counter, i.e. SOUND_LENGTH_MULTIPLIER,x * $e4

@loop_complete:
    sta SOUND_CMD_LENGTH,x ; set new $0154 value in $0100
    cpx #$02               ; compare to sound slot #$02 (triangle channel)
    bcs @continue          ; branch if slot #$02 (triangle), #$03 (noise), #$04 (pulse 1), or #$05 (noise)
    lda VIBRATO_CTRL,x     ; load whether or not to use vibrato (0 = yes, #$80 = no)
    bmi @continue          ; skip resetting SOUND_VOL_TIMER,x if VIBRATO_CTRL,x has bit 7 set
    lda #$00
    sta SOUND_VOL_TIMER,x  ; clear SOUND_VOL_TIMER,x value

@continue:
    cpx #$02                        ; compare to sound slot #$02 (triangle channel)
    beq @exit                       ; exit if sound slot #$02 (triangle channel)
    cpx #$03                        ; compare to sound slot #$03 (noise/dmc channel)
    beq adv_sound_play_percussive   ; play dmc sample if sound slot #$03 (noise/dmc channel)
    lda UNKNOWN_SOUND_00,x          ; load sound byte low nibble
    jsr @calc_decrescendo_pause_end ; calculate the high #$02 nibbles of the #$03 nibble result of a * SOUND_CMD_LENGTH,x
    sta DECRESCENDO_END_PAUSE,x     ; set result in DECRESCENDO_END_PAUSE,x

@exit:
    rts

; calculate the high #$02 nibbles of the #$03 nibble multiplication result of a * SOUND_CMD_LENGTH,x
; if the result is less than #$02 nibbles, then #$00 will be returned
; ex: a = #$0a, SOUND_CMD_LENGTH,x = #$24 -> #$0a * #$24 -> #$168 -> #$16
; ex: a = #$06, SOUND_CMD_LENGTH,x = #$24 -> #$06 * #$24 -> #$0d8 -> #$d8
; result: #$16
; input
;  * a - sound byte low nibble
;  * SOUND_CMD_LENGTH,x
; output
;  * a - the high #$02 nibbles of the #$03 nibble multiplication result of a * SOUND_CMD_LENGTH,x
@calc_decrescendo_pause_end:
    and #$0f ; keep low nibble of UNKNOWN_SOUND_00,x
             ; (should already be stripped to low nibble)
    sta $e4  ; set low nibble in $e4
    lda #$00
    sta $e6
    sta $e7

@loop:
    dec $e4                ; decrement multiplier
    bmi @set_e7_exit       ; return high nibble of a
    clc
    lda SOUND_CMD_LENGTH,x
    adc $e6                ; add SOUND_CMD_LENGTH,x to total
    sta $e6                ; store result back in $e6
    bcc @loop              ; branch to loop if no overflow occurred
    inc $e7                ; carry occurred keep track in $e7
    bne @loop              ; always loop

; shift high nibble from a into low nibble of $e7
; any previous overflow is now in the high nibble of $e7
@set_e7_exit:
    asl
    rol $e7
    asl
    rol $e7
    asl
    rol $e7
    asl
    rol $e7
    lda $e7
    rts

; gets the sound_xx pointer for sound slot from SOUND_CMD_LOW_ADDR and stores in ($e0)
; also sets y to point to beginning, i.e. #$00
load_sound_code_addr:
    ldy #$00                  ; reset sound code read offset
    lda SOUND_CMD_LOW_ADDR,x  ; load sound_xx address low byte
    sta $e0                   ; set sound_xx address low byte
    lda SOUND_CMD_HIGH_ADDR,x ; load sound_xx address high byte
    sta $e1                   ; set sound_xx address high byte
    rts

; updates the sound code read address (SOUND_CMD_LOW_ADDR) based on the next two bytes of the sound code
move_sound_code_read_addr:
    iny                       ; increment sound code read offset
    lda ($e0),y               ; load new sound code location low byte read offset
    sta SOUND_CMD_LOW_ADDR,x  ; set new sound code location low byte read offset
    iny                       ; increment sound code read offset
    lda ($e0),y               ; load new sound code location high byte read offset
    sta SOUND_CMD_HIGH_ADDR,x ; set new sound code location high byte read offset
    rts

; get the APU configuration register offset (SOUND_CHNL_REG_OFFSET) for sound slot, e.g. #$01 --> #$04
; if 2 pulse channel 1 sounds are playing, this will set the carry to indicate no way to play sound
; input
;  * x - sound slot
; output
;  * x - sound channel configuration register offset
;  * carry flag - clear to update the apu register, set to not update apu register
;    when set, there is already a sound playing on that channel that has priority
ldx_pulse_triangle_reg:
    pha                    ; backup a on the stack
    cpx #$01               ; compare to sound slot #$02 (pulse channel 2)
    bcc @move_next_apu_reg ; branch if pulse channel 0

; requested register is not for sound slot 0
; exit with x set to SOUND_CHNL_REG_OFFSET and the carry clear
@clc_exit:
    clc                       ; clear carry to signal to update sound register
    ldx SOUND_CHNL_REG_OFFSET ; load sound channel config register offset (#$00, #$04, #$08, or #$0c)
    pla                       ; restore a from stack
    rts

; sound slot is #$00 (pulse channel 1), prefer sound slot #$04 (pulse 1) (higher priority)
@move_next_apu_reg:
    inx
    inx
    inx
    inx
    lda SOUND_CODE,x       ; load sound slot 4's sound code to see if a sound is playing for that slot
    beq @clc_exit          ; exit if no sound is playing in slot #$4, use that slot instead of #$0
                           ; carry will clear and x will be set to SOUND_CHNL_REG_OFFSET
    ldx SOUND_CURRENT_SLOT ; otherwise, load current sound slot, set carry, and exit
    sec                    ; set carry flag to signal to not update sound register
    pla

sound_exit_00:
    rts

; mutes the current sound channel, and for sound slot 1, see if playing boss heart destroyed sound
; if so, play end of level song
; input
;  * x - current sound slot
mute_channel:
    lda #$30                   ; a = #$30 (mute pulse channel register)
    jsr ldx_pulse_triangle_reg ; set x to apu channel register [0, 1, 4, 5, 8, #$c]
    bcs @continue              ; branch if there is already a sound playing on that channel that has priority
    sta $4000,x                ; update pulse channel config (mute pulse channel 1 or 2 register)

@continue:
    ldx SOUND_CURRENT_SLOT      ; load current sound slot
    cpx #$01                    ; compare to sound slot #$01 (pulse 2 channel)
    bne sound_exit_00           ; exit if not sound slot 01
    lda $e6                     ; sound slot #$01 (pulse 2 channel)
    cmp #$57                    ; see if boss heart destroyed - big blast with echo
    bne sound_exit_00           ; exit if not sound_57
    lda LEVEL_END_PLAYERS_ALIVE ; see if any players are alive still at after defeating boss heart
    beq sound_exit_00           ; exit if no players are alive
    lda #$46                    ; a = #$46 (sound_46)
    jsr play_sound              ; play end of level song
                                ; could have been optimized to a jmp and no rts !(OBS)
    rts

init_triangle_channel:
    lda #$0b                ; %0000 1011
    sta APU_STATUS          ; disable triangle channel (while also enabling noise, and pulse channels)
    lda #$00                ; a = #$00
    sta APU_TRIANGLE_CONFIG
    lda #$0f                ; a = #$0f
    sta APU_STATUS          ; re-enable triangle channel (enable noise, triangle, and pulse channels)
    rts

init_pulse_channel:
    ldx SOUND_CHNL_REG_OFFSET     ; load pulse waive channel register offset, i.e. #$04 for second pulse channel #$00 for first
    lda #$30                      ; a = #$30
    sta APU_PULSE_CONFIG,x        ; mute the pulse channel 0 register
    jsr wait                      ; execute #$0a nop instructions
    lda #$7f                      ; bit 7 set to 0 all other bits 1
    sta APU_PULSE_SWEEP,x         ; disable pulse 1 channel sweep
    txa
    lsr
    lsr
    tax
    lda SOUND_CODE,x
    beq sound_code_00             ; branch if sound code is #$00
    ldy SOUND_CHNL_REG_OFFSET     ; load sound channel config register offset (#$00, #$04, #$08, or #$0c)
    jsr mute_unmute_pulse_channel ; mutes/unmutes pulse wave channel based on pause state
    ldx SOUND_CURRENT_SLOT        ; load current sound slot
    rts

; mutes the noise channel
mute_noise_channel:
    lda #$30             ; a = #$30
    sta APU_NOISE_CONFIG ; initialize noise config with no volume
    lda $e6
    cmp #$4a             ; compare to the end credits music
    bne sound_exit_00    ;
    lda #$4e             ; end credits finished, load a = #$4e (sound_4e)
    jsr play_sound       ; play after credits music (presented by konami)
                         ; could have been optimized to jmp with no rts
    rts

sound_code_00:
    ldx SOUND_CURRENT_SLOT ; load current sound slot
    lda $e6
    jmp sound_exit_00

; pointer table for ? (#$7 * #$2 = e bytes)
channel_init_ptr_tbl:
    .addr mute_channel          ; CPU address $8651
    .addr mute_channel          ; CPU address $8651
    .addr init_triangle_channel ; CPU address $8673
    .addr mute_noise_channel    ; CPU address $86a6
    .addr init_pulse_channel    ; CPU address $8683
    .addr mute_noise_channel    ; CPU address $86a6
    .addr mute_channel          ; CPU address $8651 (not sure if possible, only #$06 sound slots) !(WHY?)

; pointer table for ? (#$4 * #$2 = #$8 bytes)
sound_cmd_ptr_tbl:
    .addr sound_cmd_routine_00 ; CPU address $8500 - set sound channel configuration, advance sound command address
    .addr sound_cmd_routine_01 ; CPU address $8522 - set in memory configuration for channel, set multiplier, and sometimes read_high_sound_cmd
    .addr sound_cmd_routine_02 ; CPU address $855c - set/adjust pitch, and read_high_sound_cmd
    .addr sound_cmd_routine_03 ; CPU address $84a2 - move to next (child or parent) sound command, or finished with entire sound command and re-initialize channel

; table for note period to use when writing notes to the APU (#$30 bytes)
; the frequency of the pulse channels is a division of the CPU Clock (1.789773MHz NTSC, 1.662607MHz PAL)
; the output frequency (f) of the generator can be determined by the 11-bit period value (f_pulse) written to $4002-$4003/$4006-$4007
; note that triangle channel is one octave lower
; frequency = cpu_speed / (#$0f * (f_pulse + 1))
; ex: 1789773 / (#$0f * (#$06ae + 1)) => 65.38 Hz
note_period_tbl:
    .byte $ae,$06 ; $06AE - 1,710 - 65.38 Hz (c 2/deep c)
    .byte $4e,$06 ; $064E - 1,614 - 69.26 Hz (c#/d flat 2)
    .byte $f4,$05 ; $05F4 - 1,524 - 73.35 Hz (d 2)
    .byte $9e,$05 ; $059E - 1,438 - 77.74 Hz (d#/e flat 2)
    .byte $4e,$05 ; $054E - 1,358 - 82.31 Hz (e 2)
    .byte $01,$05 ; $0501 - 1,281 - 87.25 Hz (f 2)
    .byte $b9,$04 ; $04B9 - 1,209 - 92.45 Hz (f#/g flat 2)
    .byte $76,$04 ; $0476 - 1,142 - 97.87 Hz (g 2)
    .byte $36,$04 ; $0436 - 1,078 - 103.67 Hz (g#/a flat 2)
    .byte $f9,$03 ; $03F9 - 1,017 - 109.88 Hz (a 2)
    .byte $c0,$03 ; $03C0 - 960 - 116.40 Hz (a#/b flat 2)
    .byte $8a,$03 ; $038A - 906 - 123.33 Hz (b 2)
    .byte $57,$03 ; $0357 - 855 - 130.68 Hz (c 3)
    .byte $27,$03 ; $0327 - 807 - 138.44 Hz (c#/d flat 3)
    .byte $fa,$02 ; $02FA - 762 - 146.61 Hz (d 3)
    .byte $cf,$02 ; $02CF - 719 - 155.36 Hz (d#/e flat 3)
    .byte $a7,$02 ; $02A7 - 679 - 164.50 Hz (e 3)
    .byte $81,$02 ; $0281 - 641 - 174.24 Hz (f 3)
    .byte $5d,$02 ; $025D - 605 - 184.59 Hz (f#/g flat 3)
    .byte $3b,$02 ; $023B - 571 - 195.56 Hz (g 3)
    .byte $1b,$02 ; $021B - 539 - 207.15 Hz (g#/a flat 3)
    .byte $fd,$01 ; $01FD - 509 - 219.33 Hz (a 3)
    .byte $e0,$01 ; $01E0 - 480 - 232.56 Hz (b 3)
    .byte $c5,$01 ; $01C5 - 453 - 246.39 Hz (c 4/middle c)

; 10 nop instructions
wait:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rts

; pointer for master lookup table (#$2 bytes)
sound_master_ptr_tbl:
    .addr sound_table_00 ; CPU address $88e8

; set pulse channel duty cycle, volume, and sweep data, mute noise channel
init_pulse_and_noise_channels:
    txa      ; temporarily save current value of x to be restored after function call
    pha      ; push a to stack
    tya      ; temporarily save current value of y to be restored after function call
    pha      ; push a to stack
    lda #$00
    tax

; write #$00 to all sound slots' sound code
@loop:
    sta SOUND_CODE,x
    inx
    cpx #$06
    bcc @loop
    sta $0140
    sta $013e
    sta UNKNOWN_SOUND_01      ; adjusts pulse channel control (see set_pulse_config)
    jsr init_triangle_channel ; re-initialize triangle channel
    lda #$30                  ; both duty cycle bits set to 1 (%0011 0000)
    sta APU_PULSE_CONFIG      ; set the duty cycle of pulse 1 channel to 75% high
                              ; duty affects the audio's tone
    jsr wait                  ; execute #$0a nop instructions
    sta APU_PULSE2_CONFIG     ; set the duty cycle of pulse 2 channel to 75% high
    jsr wait                  ; execute #$0a nop instructions
    sta APU_NOISE_CONFIG      ; mute noise channel
    jsr wait                  ; execute #$0a nop instructions
    ldx #$7f                  ; load disable pulse channel sweep value
    stx APU_PULSE_SWEEP       ; disable pulse 1 channel sweep
    jsr wait                  ; execute #$0a nop instructions
    stx APU_PULSE2_SWEEP      ; disable pulse 2 channel sweep
    pla                       ; pop saved value y back from stack
    tay                       ; restore y value from before init_pulse_and_noise_channels
    pla                       ; pop saved value x back from stack
    tax                       ; restore x value from before init_pulse_and_noise_channels
    rts

; reset triangle, pulse, and noise channels
reset_channels:
    jsr init_triangle_channel ; re-initialize triangle channel
    lda #$30                  ; a = #$30
    sta APU_PULSE_CONFIG      ; set constant volume and halt any envelope loops
    jsr wait                  ; execute #$0a nop instructions
    sta APU_PULSE2_CONFIG     ; set constant volume and halt any envelope loops
    jsr wait                  ; execute #$0a nop instructions
    sta APU_NOISE_CONFIG      ; set constant volume and halt any envelope loops
    jsr wait                  ; execute #$0a nop instructions
    ldx #$7f                  ; x = #$7f
    stx APU_PULSE_SWEEP       ; disable pulse 1 channel sweep
    jsr wait                  ; execute #$0a nop instructions
    stx APU_PULSE2_SWEEP      ; disable pulse 2 channel sweep
    rts

; dead code, never called !(UNUSED)
bank_1_unused_label_00:
    txa
    pha
    tya
    pha
    ldx #$00                  ; x = #$00
    stx $e6
    lda SOUND_CODE+4
    beq @pop_and_exit
    stx SOUND_CODE+4          ; set sound channel config register offset (#$00, #$04, #$08, or #$0c)
    stx SOUND_CHNL_REG_OFFSET ; set sound channel config register offset (#$00, #$04, #$08, or #$0c)
    jsr init_pulse_channel

@pop_and_exit:
    pla
    tay
    pla
    tax
    rts

; dead code, never called !(UNUSED)
bank_1_unused_label_01:
    sta $013e
    sta $0141
    lda #$00             ; a = #$00
    sta UNKNOWN_SOUND_01 ; reset pulse channel adjustment (see set_pulse_config)
    rts

; plays the specified sound
; input
;  * a - the sound code to play
init_sound_code_vars:
    sta INIT_SOUND_CODE               ; store the sound code to play
    cmp #$01
    bne @check_dmc_init               ; branch if sound code isn't #$01
    jmp init_pulse_and_noise_channels ; sound code #$01, init pulse and noise channels
                                      ; sets pulse channel duty cycle, volume, and sweep data, mute noise channel

@check_dmc_init:
    cmp #$5a                              ; compare sound code to #$5a
    bcc @check_boss_heart_destroyed_sound ; branch if sound code is less than #$5a
    jmp play_dpcm_sample                  ; sound code larger than or equal to #$5a, sound code is a DPCM sample
                                          ; jump to configure DMC (delta modulation channel) and play sample

@check_boss_heart_destroyed_sound:
    cmp #$57                          ; compare to #$57 (sound_57) (boss heart destroyed - big blast with echo)
    bne @check_end_level_sound        ; branch if not boss heart destroyed sound
    jsr init_pulse_and_noise_channels ; sound code #$57 - boss heart destroyed, initialize pulse and noise channels
                                      ; sets pulse channel duty cycle, volume, and sweep data, mute noise channel
    jmp @play_sound                   ; play sound boss heart destroyed - big blast with echo

@check_end_level_sound:
    cmp #$46                    ; compare to #$46 (sound_46) (end of level song)
    bne @check_dmc_play_sound   ; branch to play the sound if not end of level song
    lda SOUND_CODE+1            ; sound code is end of level sound, load sound code of next sound channel
    cmp #$57                    ; wait for SOUND_CODE of next sound channel to clear
    bne @play_end_of_level_tune ; play end of level tune if not already playing it
    rts                         ; SOUND_CODE+1 is #$57, exit

; play end of level tune if not already playing it
@play_end_of_level_tune:
    cmp #$46                  ; see if currently playing end of level song
    bne @check_dmc_play_sound ; continue to play end of level tune if not already playing it
    rts                       ; exit if already playing the end of level tune

; plays a sound from the sound table, but first checks for specific sounds to
; see if dmc counter needs to be cleared
; input
;  * a - sound code to play
@check_dmc_play_sound:
    cmp #$2a                   ; see if starting to play jungle/hangar song
    beq @init_dmc_sample_value ; branch to clear dmc counter before playing sound if jungle/hangar
    cmp #$2e                   ; see if starting to play waterfall waterfall
    bne @play_sound            ; branch to play sound without clearing dmc counter if not waterfall

; jungle, hangar, and waterfall
@init_dmc_sample_value:
    lda #$00            ; a = #$00
    sta APU_DMC_COUNTER ; reset DMC starting vale for sample

@play_sound:
    txa                        ; backup x to a
    pha                        ; push a to stack (backup)
    tya                        ; backup y to a
    pha                        ; push a to stack (backup)
    lda sound_master_ptr_tbl   ; load low byte of sound_table_00 (only one entry in sound_master_ptr_tbl)
    sta SOUND_TABLE_PTR        ; store low byte of sound_table_00
    lda sound_master_ptr_tbl+1 ; load high byte of sound_table_00 (only one entry in sound_master_ptr_tbl)
    sta SOUND_TABLE_PTR+1      ; store high byte of sound_table_00
    lda #$03                   ; read counter index (each entry is #$03 bytes)
    sta $ea                    ; set loop counter to 3 so that the entire entry is read

; each entry in sound_master_ptr_tbl is 3 bytes, find offset based on INIT_SOUND_CODE by looping
@loop:
    lda INIT_SOUND_CODE     ; load the sound code to play
    clc                     ; clear carry in preparation for addition
    adc SOUND_TABLE_PTR     ; add INIT_SOUND_CODE to the low byte of the of the sound_table_00 (keeping track of if a carry happens)
    sta SOUND_TABLE_PTR     ; store offset back to SOUND_TABLE_PTR
    lda #$00
    adc SOUND_TABLE_PTR+1   ; add 1 to the high byte if a carry happened when adding INIT_SOUND_CODE to low byte
    sta SOUND_TABLE_PTR+1   ; set new value if overflow
    dec $ea                 ; decrement read calculation counter (3 rounds to get actual offset into sound_table_00)
                            ; this is essentially multiplying INIT_SOUND_CODE by 3 and adding that result to SOUND_TABLE_PTR
    bne @loop               ; continue if haven't calculated final read index
    ldy #$00                ; y = #$00
    sty $eb                 ; set number of bytes read to #$00
    lda (SOUND_TABLE_PTR),y ; read first byte of sound_code entry in the sound_table_00
    lsr
    lsr
    lsr
    and #$03                ; keep bits ...x x... of original byte 0 (control byte) of sound_code entry
                            ; this is the total number of sound slots to fill for the specified sound code
    sta $ea                 ; set how many times to loop load_sound_code_entry

; read the sound code entry and load appropriate variables in memory as part of init_sound_code_vars
load_sound_code_entry:
    lda $eb                   ; load number of entries away from initial entry to read (can be #$00)
    asl                       ; double the value
    clc                       ; clear carry in preparation for addition
    adc $eb                   ; add entry to itself
                              ; since each entry is #$03 bytes, multiplied by #$03 to get new offset
    tay                       ; transfer sound_table_00 read offset to y
    lda (SOUND_TABLE_PTR),y   ; read first byte from sound_table_00 entry triple (control byte)
    and #$07                  ; keep bits .... .xxx (sound slot offset)
    tax                       ; transfer offset to x
    lda INIT_SOUND_CODE       ; load the sound code to play
    cmp SOUND_CODE,x          ; see if another sound code (sound effect) is playing for the current slot
    bcc play_sound_code_exit  ; exit if a existing sound gets priority
    lda #$00                  ; a = #$00
    sta SOUND_CODE,x          ; clear sound code slot value
    iny                       ; increment sound_table_00 read offset
    lda (SOUND_TABLE_PTR),y   ; read low byte of sound_xx address from sound_table_00 triple
    sta SOUND_CMD_LOW_ADDR,x  ; set low byte of sound_xx address
    sta $e8                   ; set low byte of sound_xx address
    iny                       ; increment read offset
    lda (SOUND_TABLE_PTR),y   ; load high byte of sound_xx address
    sta SOUND_CMD_HIGH_ADDR,x ; set high byte of sound_xx address
    sta $e9                   ; set high byte of sound_xx address
    lda #$f8                  ; a = #$f8
    sta SOUND_PULSE_LENGTH,x  ; set pulse length to #$f8 (note length 30)
    lda #$01                  ; a = #$01
    sta SOUND_CMD_LENGTH,x    ; initialize SOUND_CMD_LENGTH to #$01 so that when sound command is read for the first time
                              ; the data is parsed as a new sound and not a sound that's already playing (@check_sound_command)
    cpx #$03                  ; see if sound slot is #$03 or more
    bcs @continue             ; branch if sound slot is #$03 or greater
    cpx #$02                  ; see if sound slot is #$02
    beq @clear_pitch_adj      ; branch if sound slot #$02
    lda #$80                  ; sound slot #$00 or #$01 (pulse channel 1 or 2) set a = #$80
    sta VIBRATO_CTRL,x        ; set to not use vibrato (0 = yes, #$80 = no)

@clear_pitch_adj:
    lda #$00              ; a = #$00
    sta SOUND_PITCH_ADJ,x ; clear sound period adjustment value

@continue:
    lda #$00                 ; a = #$00
    sta SOUND_REPEAT_COUNT,x ; initialize shared sound part repeat counter to #$00
    tay                      ; set sound_xx read offset to #$00
    lda ($e8),y              ; read sound_xx byte 0
    iny                      ; increment sound_xx read offset
    cmp #$30
    bcc @config_channel
    dey                      ; control code greater than or equal to #$30
                             ; y will be #$00 for setting SOUND_FLAGS,x
                             ; indicating to use read_high_sound_cmd
    sty $013e
    sty UNKNOWN_SOUND_01

@config_channel:
    tya                        ; transfer sound_xx read offset to a
    sta SOUND_FLAGS,x          ; set to either #$00 or #$01 depending whether byte 0 is greater than #$30 of sound_xx
                               ; 0 when sound byte is greater than or equal to #$30, 1 is when sound byte is less than #$30
                               ; this specifies whether the sound commands in the code will be processed as a 'high code', or a 'low code'
    lda INIT_SOUND_CODE        ; load sound code to play
    sta SOUND_CODE,x           ; store sound code to play in sound slot x
    txa                        ; transfer sound slot index to a
    cmp #$01                   ; compare to #$01 (pulse 2 channel)
    bcc move_to_pulse_2        ; branch if pulse 1 channel
    cpx #$05                   ; see if sound slot #$05 (noise channel)
    bne convert_slot_to_offset ; branch if not sound slot #$05 (noise channel)
    lda #$0c                   ; sound slot #$05 (noise channel), set sound channel register offset to #$0c (noise/dmc channel)
    jmp cfg_channel

; converts the channel slot index to the channel register offset
;  * #$00: #$00 (pulse 1 channel)
;  * #$01: #$04 (pulse 2 channel)
;  * #$02: #$08 (triangle channel)
;  * #$03: #$0c (noise/dmc channel)
;  * #$04: #$00 (pulse 1 channel)
;  * #$05: do not call this method for sound slot #$05
; input
;  * a - sound slot index
; output
;  * a - sound channel register offset (#$00, #$04, #$08, or #$0c)
; note: does not work for sound slot #$05, must check if slot #$05 before calling this method
convert_slot_to_offset:
    asl
    asl
    and #$0f ; keep low nibble

; configure pulse or noise channel
cfg_channel:
    tax               ; transfer sound channel register offset to x
    lda #$00          ; a = #$00
    cpx #$08          ; see if sound channel register offset is triangle channel
    beq @set_cfg_exit ; exit if triangle channel
    lda #$30          ; set pulse channel or noise channel to play note indefinitely and that v bits will control volume
                      ; until another value is written to pulse to $4000/$4004

@set_cfg_exit:
    sta $4000,x           ; either set pulse channel or noise channel to #$30 or set triangle channel to #$00
    jsr wait              ; execute #$0a nop instructions
    lda #$7f              ; a = #$7f (disable sweep)
    sta APU_PULSE_SWEEP,x ; disable sweep

play_sound_code_exit:
    inc $eb         ; move to next entry in sound_table_00
    dec $ea         ; load number of additional slots required for sound code
    bpl @load_entry
    pla
    tay
    pla
    tax
    rts

@load_entry:
    jmp load_sound_code_entry

; update
; input
;  * a - sound slot index
;  * x - sound slot
; output
;  * a - sound slot index for pulse 2 channel (#$04)
move_to_pulse_2:
    ora #$04                   ; set bits .... .x..
    tay
    lda SOUND_CODE,y
    bne play_sound_code_exit
    txa                        ; transfer sound slot to a
    jmp convert_slot_to_offset ; determine sound channel register offset for slot

; configure DMC (delta modulation channel) and play DPCM sample from bank 7
; !(BUG?) special sound code #$ff (used by end of snow field level after boss defeated)
; sounds like door sliding opening
;  * dpcm_sample_data_tbl offset is #$94
;  * sampling rate #$03 (5593.04 Hz), no loop
;  * counter length #$77
;  * offset #$97 --> $c000 + (#$97 * #$40) --> $e5c0 --> (collision_box_codes_03)
;  * sample length #$19
play_dpcm_sample:
    sec                          ; set carry flag in preparation for subtraction
    sbc #$5a                     ; sound codes larger than #$5a are commands to initialize the DMC
                                 ; subtract #$5a to get actual initialization values (offset to dpcm_sample_data_tbl)
    sta INIT_SOUND_CODE          ; set dpcm_sample_data_tbl offset
    tya                          ; back up y register, transfer to a
    pha                          ; backup a by pushing to stack
    lda INIT_SOUND_CODE          ; load dpcm_sample_data_tbl offset
    asl
    asl                          ; quadruple since each entry is #$04 bytes
    tay                          ; transfer to offset register
    lda #$0f                     ; a = #$0f
    sta APU_STATUS               ; enable noise, triangle, and the 2 pulse channels
    lda dpcm_sample_data_tbl,y   ; load DMC configuration (max sampling rate, no looping)
    sta APU_DMC                  ; set DMC configuration (max sampling rate, no looping)
    lda dpcm_sample_data_tbl+1,y ; load DMC counter
    sta APU_DMC_COUNTER          ; set DMC counter
    lda dpcm_sample_data_tbl+2,y ; load address of DPCM sample data (this value * #$40) + $c000 is final address
    sta APU_DMC_SAMPLE_ADDR      ; set address of DPCM sample data
    lda dpcm_sample_data_tbl+3,y ; load length of sample
    sta APU_DMC_SAMPLE_LEN       ; set length of sample
    lda #$1f                     ; a = #$1f
    sta APU_STATUS               ; enable DMC, noise, triangle, and the 2 pulse channels
    pla                          ; restore a (backup of y)
    tay                          ; restore y
    rts

; table for APU configuration (#$d bytes)
; byte 0 - APU_DMC - sampling rate (how many CPU cycles happen between playback samples), no looping
;        - always $0f, highest sampling rate. NTSC 33,143.9 Hz, PAL 33,252.1 Hz
; byte 1 - APU_DMC_COUNTER
; byte 2 - APU_DMC_SAMPLE_ADDR
; byte 3 - APU_DMC_SAMPLE_LEN
dpcm_sample_data_tbl:
    .byte $0f,$2f,$f0,$05 ; #$5a - sample address $fc00 (dpcm_sample_00) (#$51 bytes)
    .byte $0f,$75,$f3,$25 ; #$5b - sample address $fcc0 (dpcm_sample_01) (#$251 bytes)
    .byte $0f,$00,$f0,$05 ; #$5c - sample address $fc00 (dpcm_sample_00) (end of level)
    .byte $0f

; CPU address $88e8
; main look-up table for sounds and music #$5E * #$3 = #$11a bytes)
; groups of #$03 bytes
; read by @play_sound
; byte 0 - ...y yxxx ->
;  * x - sound slot offset
;  * y - how many sound additional sound codes to play
;        note that subsequent sound codes don't read/use the y bits of their byte 0
; byte 1 and 2 - address to sound data
; see level_vert_scroll_and_song (bank 7)
sound_table_00:
    .byte $00,$f3,$25 ; these bytes are for dpcm_sample_data_tbl, lowest sound code is #$01
                      ; sample address $fcc0 (dpcm_sample_01)

    ; unused, empty/silence (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_01 ; CPU address $8a24

    ; percussive tick (bass drum/tom drum), used by other sound codes (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_02 ; CPU address $8a02

    ; player landing on ground or water (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_03 ; CPU address $8a25

    ; FOOT - player landing on ground or water (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_04 ; CPU address $8a36

    ; ROCK - waterfall rock landing on ground (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_05 ; CPU address $8a41

    ; TYPE 1 - unused, keyboard typing in Japanese version of game (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_06 ; CPU address $8a78

    ; TYPE 1 - unused, keyboard typing in Japanese version of game (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_07 ; CPU address $8a82

    ; unused, rumbling (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_08 ; CPU address $8a90

    ; FIRE - energy zone fire beam (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_09 ; CPU address $8c81

    ; SHOTGUN1 - regular bullet firing (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_0a ; CPU address $8ab3

    ; SHOTGUN1 - regular bullet firing (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_0b ; CPU address $8adc

    ; SHOTGUN2 - M weapon firing, turret man (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_0c ; CPU address $8b05

    ; SHOTGUN2 - M weapon firing, turret man (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_0d ; CPU address $8b32

    ; LASER - L weapon firing (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_0e ; CPU address $8b59

    ; LASER - L weapon firing (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_0f ; CPU address $8b90

    ; PL FIRE - f bullet firing (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_10 ; CPU address $8bf3

    ; PL FIRE - f bullet firing (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_11 ; CPU address $8c07

    ; SPREAD - s bullet firing (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_12 ; CPU address $8c19

    ; SPREAD - s bullet firing (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_13 ; CPU address $8c27

    ; HIBIWARE - bullet shielded wall plating ting (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_14 ; CPU address $8cba

    ; CHAKUCHI - energy zone boss landing (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_15 ; CPU address $8d49

    ; DAMEGE 1 - bullet to metal collision ting (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_16 ; CPU address $8cd4

    ; DAMEGE 1 - bullet to metal collision ting (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_17 ; CPU address $8cf7

    ; DAMEGE 2 - alien heart boss hit (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_18 ; CPU address $8d1c

    ; TEKI OUT - enemy destroyed (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_19 ; CPU address $8d33

    ; HIRAI 1 - ice grenade whistling noise (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_1a ; CPU address $8ddd

    ; SENSOR - level 1 jungle boss siren (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_1b ; CPU address $8d76

    ; KANDEN - electrocution sound (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_1c ; CPU address $8ea5

    ; KANDEN - electrocution sound (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_1d ; CPU address $8ec6

    ; CAR - tank advancing (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_1e ; CPU address $8e2f

    ; POWER UP - pick up weapon item (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_1f ; CPU address $8e47

    ; 1UP - extra life (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_20 ; CPU address $8e5e

    ; HERI - helicopter rotors (pulse 1 channel)
    ; #$02 additional sound code entries, sound slot #$04
    .byte $14
    .addr sound_21 ; CPU address $8ee3

    ; HERI - helicopter rotors (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_21 ; CPU address $8ee3

    ; HERI - helicopter rotors (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_23 ; CPU address $8f83

    ; BAKUHA 1 - explosion (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_24 ; CPU address $8fc2

    ; BAKUHA 2 - game intro explosion, indoor wall explosion, and island explosion (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_25 ; CPU address $9001

    ; TITLE - game intro tune (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_26 ; CPU address $9195

    ; TITLE - game intro tune (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_27 ; CPU address $91ab

    ; TITLE - game intro tune (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_28 ; CPU address $91c3

    ; TITLE - game intro tune (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_29 ; CPU address $91d3

    ; BGM 1 - level 1 jungle and level 7 hangar music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_2a ; CPU address $9428

    ; BGM 1 - level 1 jungle and level 7 hangar music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_2b ; CPU address $924e

    ; BGM 1 - level 1 jungle and level 7 hangar music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_2c ; CPU address $95c7

    ; BGM 1 - level 1 jungle and level 7 hangar music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_2d ; CPU address $9775

    ; BGM 2 - level 3 waterfall music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_2e ; CPU address $9985

    ; BGM 2 - level 3 waterfall music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_2f ; CPU address $9a71

    ; BGM 2 - level 3 waterfall music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_30 ; CPU address $9b67

    ; BGM 2 - level 3 waterfall music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_31 ; CPU address $9bce

    ; BGM 3 - level 5 snow field music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_32 ; CPU address $9ca4

    ; BGM 3 - level 5 snow field music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_33 ; CPU address $9d32

    ; BGM 3 - level 5 snow field music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_34 ; CPU address $9d9a

    ; BGM 3 - level 5 snow field music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_35 ; CPU address $9e1e

    ; BGM 4 - level 6 energy zone (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_36 ; CPU address $9ea8

    ; BGM 4 - level 6 energy zone (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_37 ; CPU address $9f46

    ; BGM 4 - level 6 energy zone (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_38 ; CPU address $9fb8

    ; BGM 4 - level 6 energy zone (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_39 ; CPU address $a003

    ; BGM 5 - level 8 alien's lair music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_3a ; CPU address $a092

    ; BGM 5 - level 8 alien's lair music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_3b ; CPU address $a1a7

    ; BGM 5 - level 8 alien's lair music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_3c ; CPU address $a295

    ; BGM 5 - level 8 alien's lair music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_3d ; CPU address $a32f

    ; 3D BGM - indoor/base level music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_3e ; CPU address $a468

    ; 3D BGM - indoor/base level music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_3f ; CPU address $a570

    ; 3D BGM - indoor/base level music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_40 ; CPU address $a5eb

    ; 3D BGM - indoor/base level music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_41 ; CPU address $a67a

    ; BOSS - indoor/base boss screen music (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_42 ; CPU address $a793

    ; BOSS - indoor/base boss screen music (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_43 ; CPU address $a878

    ; BOSS - indoor/base boss screen music (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_44 ; CPU address $a8fb

    ; BOSS - indoor/base boss screen music (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_45 ; CPU address $aa0e

    ; PCLR - end of level tune (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_46 ; CPU address $aa92

    ; PCLR - end of level tune (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_47 ; CPU address $aab3

    ; PCLR - end of level tune (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_48 ; CPU address $aad4

    ; PCLR - end of level tune (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_49 ; CPU address $aaef

    ; ENDING - end credits (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_4a ; CPU address $ac9f

    ; ENDING - end credits (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_4b ; CPU address $ad1a

    ; ENDING - end credits (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_4c ; CPU address $ae05

    ; ENDING - end credits (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_4d ; CPU address $ae87

    ; OVER - game over/after end credits, presented by konami (pulse 1 channel)
    ; #$03 additional sound code entries, sound slot #$00
    .byte $18
    .addr sound_4e ; CPU address $ab34

    ; OVER - game over/after end credits, presented by konami (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_4f ; CPU address $ab5c

    ; OVER - game over/after end credits, presented by konami (triangle channel)
    ; #$00 additional sound code entries, sound slot #$02
    .byte $02
    .addr sound_50 ; CPU address $ab86

    ; OVER - game over/after end credits, presented by konami (noise/dmc channel)
    ; #$00 additional sound code entries, sound slot #$03
    .byte $03
    .addr sound_51 ; CPU address $abb2

    ; PL OUT - player death (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_52 ; CPU address $9117

    ; PL OUT - player death (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_53 ; CPU address $916a

    ; game pausing jingle (pulse 1 channel)
    ; #$00 additional sound code entries, sound slot #$04
    .byte $04
    .addr sound_54 ; CPU address $8a0a

    ; BOSS BK - tank, boss ufo, boss giant, alien guardian destroyed (pulse 1 channel)
    ; #$01 additional sound code entry, sound slot #$04
    .byte $0c
    .addr sound_55 ; CPU address $903c

    ; BOSS BK - tank, boss ufo, boss giant, alien guardian destroyed (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_56 ; CPU address $9055

    ; BOSS OUT - boss destroyed (pulse 1 channel)
    ; #$02 additional sound code entries, sound slot #$04
    .byte $14
    .addr sound_57 ; CPU address $9094

    ; BOSS OUT - boss destroyed (pulse 2 channel)
    ; #$00 additional sound code entries, sound slot #$01
    .byte $01
    .addr sound_58 ; CPU address $9098

    ; BOSS OUT - boss destroyed (noise channel)
    ; #$00 additional sound code entries, sound slot #$05
    .byte $05
    .addr sound_59 ; CPU address $90dc

    ; #$00 additional sound code entries, sound slot #$03 (noise/dmc channel)
    .byte $03
    .addr sound_01 ; CPU address $8a24 - 5a

    ; #$00 additional sound code entries, sound slot #$03 (noise/dmc channel)
    .byte $03
    .addr sound_01 ; CPU address $8a24 - 5b

    ; #$00 additional sound code entries, sound slot #$03 (noise/dmc channel)
    .byte $03
    .addr sound_01 ; CPU address $8a24 - 5c

    ; #$00 additional sound code entries, sound slot #$03 (noise/dmc channel)
    .byte $03
    .addr sound_01 ; CPU address $8a24 - 5d

; percussive tick (bass drum/tom drum), used by other sound codes (noise channel)
; CPU address $8a02
sound_02:
    .incbin "assets/audio_data/sound_02.bin"

; game pausing jingle (pulse 1 channel)
sound_54:
    .incbin "assets/audio_data/sound_54.bin"

; CPU address $8a24
; unused, empty/silence
sound_01:
    .byte $ff

; player landing on ground or water (pulse 1 channel)
; CPU address $8a25
sound_03:
    .incbin "assets/audio_data/sound_03.bin"

; FOOT - player landing on ground or water (noise channel)
; CPU address $8a36
sound_04:
    .incbin "assets/audio_data/sound_04.bin"

; ROCK - waterfall rock landing on ground (pulse 1 channel)
; CPU address $8a41
sound_05:
    .incbin "assets/audio_data/sound_05.bin"

; TYPE 1 - unused, keyboard typing in Japanese version of game (pulse 1 channel)
; CPU address $8a78
sound_06:
    .incbin "assets/audio_data/sound_06.bin"

; TYPE 1 - unused, keyboard typing in Japanese version of game (noise channel)
; CPU address $8a82
sound_07:
    .incbin "assets/audio_data/sound_07.bin"

; unused, rumbling (noise/dmc channel)
; CPU address $8a90
sound_08:
    .incbin "assets/audio_data/sound_08.bin"
    .addr sound_08

sound_08_part_00:
    .incbin "assets/audio_data/sound_08_part_00.bin"

; SHOTGUN1 - regular bullet firing (pulse 1 channel)
; CPU address $8ab3
sound_0a:
    .incbin "assets/audio_data/sound_0a.bin"

; SHOTGUN1 - regular bullet firing (noise/dmc channel)
; CPU address $8adc
sound_0b:
    .incbin "assets/audio_data/sound_0b.bin"
    .addr sound_0b

; CPU address $8aee
sound_0b_part_00:
    .incbin "assets/audio_data/sound_0b_part_00.bin"

; SHOTGUN2 - M weapon firing, turret man (pulse 1 channel)
; CPU address $8b05
sound_0c:
    .incbin "assets/audio_data/sound_0c.bin"
    .addr sound_0c

sound_0c_part_00:
    .incbin "assets/audio_data/sound_0c_part_00.bin"

; SHOTGUN2 - M weapon firing, turret man (noise/dmc channel)
; CPU address $8b32
sound_0d:
    .incbin "assets/audio_data/sound_0d.bin"
    .addr sound_0d

; CPU address $8b42
sound_0d_part_00:
    .incbin "assets/audio_data/sound_0d_part_00.bin"

; LASER - L weapon firing (pulse 1 channel)
; CPU address $8b59
sound_0e:
    .incbin "assets/audio_data/sound_0e.bin"

; LASER - L weapon firing (noise/dmc channel)
; CPU address $8b90
sound_0f:
    .incbin "assets/audio_data/sound_0f.bin"

; PL FIRE - f bullet firing (pulse 1 channel)
; CPU address $8bf3
sound_10:
    .incbin "assets/audio_data/sound_10.bin"
    .addr sound_10

sound_10_part_00:
    .incbin "assets/audio_data/sound_10_part_00.bin"

; PL FIRE - f bullet firing (noise/dmc channel)
; CPU address $8c07
sound_11:
    .incbin "assets/audio_data/sound_11.bin"
    .addr sound_11

sound_11_part_00:
    .incbin "assets/audio_data/sound_11_part_00.bin"

; SPREAD - s bullet firing (pulse 1 channel)
; CPU address $8c19
sound_12:
    .incbin "assets/audio_data/sound_12.bin"

; SPREAD - s bullet firing (noise/dmc channel)
; CPU address $8c27
sound_13:
    .incbin "assets/audio_data/sound_13.bin"

; FIRE - energy zone fire beam (noise/dmc channel)
; CPU address $8c81
sound_09:
    .incbin "assets/audio_data/sound_09.bin"

; HIBIWARE - bullet shielded wall plating ting (pulse 1 channel)
; CPU address $8cba
sound_14:
    .incbin "assets/audio_data/sound_14.bin"
    .addr sound_14

sound_14_part_00:
    .incbin "assets/audio_data/sound_14_part_00.bin"

; DAMEGE 1 - bullet to metal collision ting (pulse 1 channel)
; CPU address $8cd4
sound_16:
    .incbin "assets/audio_data/sound_16.bin"

; DAMEGE 1 - bullet to metal collision ting (noise/dmc channel)
; CPU address $8cf7
sound_17:
    .incbin "assets/audio_data/sound_17.bin"

; DAMEGE 2 - alien heart boss hit (pulse 1 channel)
; CPU address $8d1c
sound_18:
    .incbin "assets/audio_data/sound_18.bin"
    .addr sound_25_part_01

sound_18_part_00:
    .incbin "assets/audio_data/sound_18_part_00.bin"

; TEKI OUT - enemy destroyed (pulse 1 channel)
; CPU address $8d33
sound_19:
    .incbin "assets/audio_data/sound_19.bin"

; CHAKUCHI - energy zone boss landing (pulse 1 channel)
; CPU address $8d49
sound_15:
    .incbin "assets/audio_data/sound_15.bin"

; SENSOR - level 1 jungle boss siren (pulse 1 channel)
; CPU address $8d76
sound_1b:
    .incbin "assets/audio_data/sound_1b.bin"
    .addr sound_1b_part_00
    .byte $fd
    .addr sound_1b_part_00
    .byte $fd
    .addr sound_1b_part_00
    .byte $ff

; CPU address $8d84
sound_1b_part_00:
    .incbin "assets/audio_data/sound_1b_part_00.bin"

; CPU address $8dae
sound_1b_part_01:
    .byte $e1,$40,$a1,$41,$fe,$0c
    .addr sound_1b_part_01

sound_1b_part_02:
    .incbin "assets/audio_data/sound_1b_part_02.bin"

; HIRAI 1 - ice grenade whistling noise (pulse 1 channel)
; CPU address $8ddd
sound_1a:
    .incbin "assets/audio_data/sound_1a.bin"

; CAR - tank advancing (pulse 1 channel)
; CPU address $8e2f
sound_1e:
    .incbin "assets/audio_data/sound_1e.bin"

; POWER UP - pick up weapon item (pulse 1 channel)
; CPU address $8e47
sound_1f:
    .incbin "assets/audio_data/sound_1f.bin"

; 1UP - extra life (pulse 1 channel)
; CPU address $8e5e
sound_20:
    .incbin "assets/audio_data/sound_20.bin"

; KANDEN - electrocution sound (pulse 1 channel)
; CPU address $8ea5
sound_1c:
    .incbin "assets/audio_data/sound_1c.bin"
    .addr sound_1c

sound_1c_part_00:
    .incbin "assets/audio_data/sound_1c_part_00.bin"

; KANDEN - electrocution sound (noise/dmc channel)
; CPU address $8ec6
sound_1d:
    .incbin "assets/audio_data/sound_1d.bin"
    .addr sound_1d

sound_1d_part_00:
    .incbin "assets/audio_data/sound_1d_part_00.bin"

; HERI - helicopter rotors (pulse 1 and pulse 2 channel)
; CPU address $8ee3
sound_21:
    .incbin "assets/audio_data/sound_21.bin"

; CPU address $8ef0
sound_21_part_00:
    .incbin "assets/audio_data/sound_21_part_00.bin"
    .addr sound_21_part_00

; CPU address $8efd
sound_21_part_01:
    .byte $83,$83,$43,$65,$33,$53,$f8,$13,$33,$fe,$10
    .addr sound_21_part_01

; CPU address $8f0a
sound_21_part_02:
    .incbin "assets/audio_data/sound_21_part_02.bin"
    .addr sound_21_part_02

; CPU address $8f17
sound_21_part_03:
    .incbin "assets/audio_data/sound_21_part_03.bin"
    .addr sound_21_part_03

; CPU address $8f24
sound_21_part_04:
    .incbin "assets/audio_data/sound_21_part_04.bin"
    .addr sound_21_part_04

; CPU address $8f31
sound_21_part_05:
    .incbin "assets/audio_data/sound_21_part_05.bin"
    .addr sound_21_part_05

; CPU address $8f3e
sound_21_part_06:
    .incbin "assets/audio_data/sound_21_part_06.bin"
    .addr sound_21_part_06

; CPU address $8f4b
sound_21_part_07:
    .incbin "assets/audio_data/sound_21_part_07.bin"
    .addr sound_21_part_07

; CPU address $8f58
sound_21_part_08:
    .incbin "assets/audio_data/sound_21_part_08.bin"
    .addr sound_21_part_08

; CPU address $8f66
sound_21_part_09:
    .incbin "assets/audio_data/sound_21_part_09.bin"
    .addr sound_21_part_09

; CPU address $8f74
sound_21_part_0a:
    .incbin "assets/audio_data/sound_21_part_0a.bin"
    .addr sound_21_part_0a
    .byte $ff

; HERI - helicopter rotors (noise/dmc channel)
; CPU address $8f83
sound_23:
    .incbin "assets/audio_data/sound_23.bin"

; CPU address $8f85
sound_23_part_00:
    .incbin "assets/audio_data/sound_23_part_00.bin"
    .addr sound_23_part_00

; CPU address $8f8f
sound_23_part_01:
    .incbin "assets/audio_data/sound_23_part_01.bin"
    .addr sound_23_part_01

; CPU address $8f97
sound_23_part_02:
    .incbin "assets/audio_data/sound_23_part_02.bin"
    .addr sound_23_part_02

; CPU address $8f9f
sound_23_part_03:
    .incbin "assets/audio_data/sound_23_part_03.bin"
    .addr sound_23_part_03

; CPU address $8fa7
sound_23_part_04:
    .incbin "assets/audio_data/sound_23_part_04.bin"
    .addr sound_23_part_04

; CPU address $8faf
sound_23_part_05:
    .incbin "assets/audio_data/sound_23_part_05.bin"
    .addr sound_23_part_05

; CPU address $8fb7
sound_23_part_06:
    .incbin "assets/audio_data/sound_23_part_06.bin"
    .addr sound_23_part_06
    .byte $ff

; BAKUHA 1 - explosion (noise/dmc channel)
; CPU address $8fc2
sound_24:
    .incbin "assets/audio_data/sound_24.bin"
    .addr sound_24

sound_24_part_00:
    .incbin "assets/audio_data/sound_24_part_00.bin"

; BAKUHA 2 - game intro explosion, indoor wall explosion, and island explosion (noise/dmc channel)
; CPU address $9001
sound_25:
    .incbin "assets/audio_data/sound_25.bin"
    .addr sound_25

sound_25_part_00:
    .incbin "assets/audio_data/sound_25_part_00.bin"

; CPU address $9035
sound_25_part_01:
    .incbin "assets/audio_data/sound_25_part_01.bin"

; BOSS BK - tank, boss ufo, boss giant, alien guardian destroyed (pulse 1 channel)
; CPU address $903c
sound_55:
    .incbin "assets/audio_data/sound_55.bin"

; BOSS BK - tank, boss ufo, boss giant, alien guardian destroyed (noise channel)
; CPU address $9055
sound_56:
    .incbin "assets/audio_data/sound_56.bin"
    .addr sound_56

sound_56_part_00:
    .incbin "assets/audio_data/sound_56_part_00.bin"

; BOSS OUT - boss destroyed (pulse 1 channel)
; CPU address $9094
sound_57:
    .incbin "assets/audio_data/sound_57.bin"

; BOSS OUT - boss destroyed (pulse 2 channel)
; CPU address $9098
sound_58:
    .incbin "assets/audio_data/sound_58.bin"

; BOSS OUT - boss destroyed (noise channel)
; CPU address $90dc
sound_59:
    .incbin "assets/audio_data/sound_59.bin"
    .addr sound_59

sound_59_part_00:
    .incbin "assets/audio_data/sound_59_part_00.bin"

; PL OUT - player death (pulse 1 channel)
; CPU address $9117
sound_52:
    .incbin "assets/audio_data/sound_52.bin"

; PL OUT - player death (noise channel)
; CPU address $916a
sound_53:
    .incbin "assets/audio_data/sound_53.bin"

; TITLE - game intro tune (pulse 1 channel)
; CPU address $9195
sound_26:
    .incbin "assets/audio_data/sound_26.bin"

; TITLE - game intro tune (pulse 2 channel)
; CPU address $91ab
sound_27:
    .incbin "assets/audio_data/sound_27.bin"

; TITLE - game intro tune (triangle channel)
; CPU address $91c3
sound_28:
    .incbin "assets/audio_data/sound_28.bin"

; TITLE - game intro tune (noise/dmc channel)
; CPU address $91d3
sound_29:
    .incbin "assets/audio_data/sound_29.bin"

; from pointer table at pulse_volume_ptr_tbl (level 1)
; volume envelop for pulse channel 2 on level 1
lvl_1_pulse_volume_00:
    .byte $05,$06,$07,$06,$05,$04,$03,$ff

; volume control 3, 4, 3, 2 loops
lvl_1_pulse_volume_01:
    .byte $03,$04,$03,$02,$ff

lvl_1_pulse_volume_02:
    .byte $07,$06,$05,$04,$03,$02,$01,$00,$00,$00,$02,$02,$ff

lvl_1_pulse_volume_03:
    .byte $06,$05,$04,$03,$02,$01,$00,$00,$00,$00,$01,$01,$ff

lvl_1_pulse_volume_04:
    .byte $07,$06,$05,$04,$03,$03,$02,$01,$00,$00,$00,$00,$00,$00,$00,$02
    .byte $02,$ff

lvl_1_pulse_volume_05:
    .byte $07,$06,$05,$04,$03,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
    .byte $01,$01,$ff

lvl_1_pulse_volume_06:
    .byte $05,$04,$03,$02,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
    .byte $01,$01,$ff

lvl_1_pulse_volume_07:
    .byte $06,$05,$04,$03,$02,$02,$02,$01,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$ff

; BGM 1 - level 1 jungle and level 7 hangar music (pulse 2 channel)
; CPU address $924e
sound_2b:
    .byte $ec,$01,$eb,$2a,$22,$d6,$f7,$84,$00,$e1,$40,$20,$e2,$b0,$90,$b0
    .byte $90,$70,$60,$70,$60,$40,$20,$40,$e3,$90,$b0,$e2,$20

; CPU address $926b
sound_2b_part_00:
    .incbin "assets/audio_data/sound_2b_part_00.bin"
    .addr sound_2b_part_00

sound_2b_part_01:
    .incbin "assets/audio_data/sound_2b_part_01.bin"
    .addr sound_2b_part_00

; BGM 1 - level 1 jungle and level 7 hangar music (pulse 1 channel)
; CPU address $9428
sound_2a:
    .incbin "assets/audio_data/sound_2a.bin"

; CPU address $9445
sound_2a_part_00:
    .incbin "assets/audio_data/sound_2a_part_00.bin"
    .addr sound_2a_part_00

sound_2a_part_01:
    .incbin "assets/audio_data/sound_2a_part_01.bin"
    .addr sound_2a_part_00

; BGM 1 - level 1 jungle and level 7 hangar music (triangle channel)
; CPU address $95c7 - jungle/hangar triangle
sound_2c:
    .incbin "assets/audio_data/sound_2c.bin"

; CPU address $95df
sound_2c_part_00:
    .incbin "assets/audio_data/sound_2c_part_00.bin"
    .addr sound_2c_part_00

sound_2c_part_01:
    .incbin "assets/audio_data/sound_2c_part_01.bin"

; CPU address $96bc
sound_2c_part_02:
    .incbin "assets/audio_data/sound_2c_part_02.bin"
    .addr sound_2c_part_02

; CPU address $96c3
sound_2c_part_03:
    .incbin "assets/audio_data/sound_2c_part_03.bin"
    .addr sound_2c_part_03

sound_2c_part_04:
    .incbin "assets/audio_data/sound_2c_part_04.bin"
    .addr sound_2c_part_00

; BGM 1 - level 1 jungle and level 7 hangar music (noise/dmc channel)
; CPU address $9775
sound_2d:
    .incbin "assets/audio_data/sound_2d.bin"
    .addr sound_2d

; CPU address $977e
sound_2d_part_00:
    .incbin "assets/audio_data/sound_2d_part_00.bin"

; CPU address $9782
sound_2d_part_01:
    .incbin "assets/audio_data/sound_2d_part_01.bin"
    .addr sound_2d_part_01

sound_2d_part_02:
    .incbin "assets/audio_data/sound_2d_part_02.bin"

; CPU address $9856
sound_2d_part_03:
    .incbin "assets/audio_data/sound_2d_part_03.bin"
    .addr sound_2d_part_03

sound_2d_part_04:
    .incbin "assets/audio_data/sound_2d_part_04.bin"

; CPU address $9877
sound_2d_part_05:
    .incbin "assets/audio_data/sound_2d_part_05.bin"
    .addr sound_2d_part_05

sound_2d_part_06:
    .incbin "assets/audio_data/sound_2d_part_06.bin"

; CPU address $989a
sound_2d_part_07:
    .incbin "assets/audio_data/sound_2d_part_07.bin"
    .addr sound_2d_part_07

sound_2d_part_08:
    .incbin "assets/audio_data/sound_2d_part_08.bin"

; CPU address $98b9
sound_2d_part_09:
    .incbin "assets/audio_data/sound_2d_part_09.bin"
    .addr sound_2d_part_09

sound_2d_part_0a:
    .incbin "assets/audio_data/sound_2d_part_0a.bin"
    .addr sound_2d_part_01

lvl_3_pulse_volume_07:
    .byte $07,$06,$05,$04,$03,$03,$00,$00,$00,$02,$ff

lvl_4_pulse_volume_00:
    .byte $03,$04,$05,$06,$07,$07,$07,$06,$06,$06,$06,$05,$05,$05,$05,$04
    .byte $04,$04,$04,$03,$ff

lvl_4_pulse_volume_01:
    .byte $06,$07,$06,$05,$04,$03,$ff

lvl_4_pulse_volume_02:
    .byte $06,$07,$06,$05,$04,$03,$00,$00,$00,$00,$01,$ff

lvl_4_pulse_volume_03:
    .byte $04,$05,$06,$05,$04,$03,$ff

lvl_4_pulse_volume_04:
    .byte $04,$05,$04,$03,$ff

lvl_4_pulse_volume_05:
    .byte $03,$04,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_4_pulse_volume_06:
    .byte $04,$05,$06,$05,$04,$03,$ff

lvl_4_pulse_volume_07:
    .byte $08,$07,$06,$05,$04,$03,$00,$00,$00,$00,$01,$ff

lvl_5_pulse_volume_00:
    .byte $ff

; CPU address $9929
sound_2e_part_00:
    .incbin "assets/audio_data/sound_2e_part_00.bin"
    .addr sound_2e_part_00

sound_2e_part_01:
    .incbin "assets/audio_data/sound_2e_part_01.bin"

; BGM 2 - level 3 waterfall music (pulse 1 channel)
; CPU address $9985
sound_2e:
    .incbin "assets/audio_data/sound_2e.bin"

; CPU address $9999
sound_2e_part_02:
    .byte $fd
    .addr sound_2e_part_00

sound_2e_part_03:
    .incbin "assets/audio_data/sound_2e_part_03.bin"
    .addr sound_2e_part_00

sound_2e_part_04:
    .incbin "assets/audio_data/sound_2e_part_04.bin"
    .addr sound_2e_part_02

; CPU address $9a2a
sound_2e_part_05:
    .incbin "assets/audio_data/sound_2e_part_05.bin"
    .addr sound_2e_part_05

sound_2e_part_06:
    .incbin "assets/audio_data/sound_2e_part_06.bin"

; BGM 2 - level 3 waterfall music (pulse 2 channel)
; CPU address $9a71
sound_2f:
    .incbin "assets/audio_data/sound_2f.bin"

; CPU address $9a75
sound_2f_part_00:
    .incbin "assets/audio_data/sound_2f_part_00.bin"
    .addr sound_2f_part_00

; CPU address $9a88
sound_2f_part_01:
    .byte $fd
    .addr sound_2e_part_05

; CPU address $9a8b
sound_2f_part_02:
    .incbin "assets/audio_data/sound_2f_part_02.bin"

; CPU address $9a8f
sound_2f_part_03:
    .incbin "assets/audio_data/sound_2f_part_03.bin"
    .addr sound_2f_part_03
    .byte $fd
    .addr sound_2e_part_05

sound_2f_part_04:
    .incbin "assets/audio_data/sound_2f_part_04.bin"
    .addr sound_2f_part_01

; CPU address $9b0c
sound_2f_part_05:
    .incbin "assets/audio_data/sound_2f_part_05.bin"
    .addr sound_2f_part_05

sound_2f_part_06:
    .incbin "assets/audio_data/sound_2f_part_06.bin"

; BGM 2 - level 3 waterfall music (triangle channel)
; CPU address $9b67
sound_30:
    .incbin "assets/audio_data/sound_30.bin"

; CPU address $9b6a
sound_30_part_00:
    .incbin "assets/audio_data/sound_30_part_00.bin"
    .addr sound_30_part_00

; CPU address $9b6f
sound_30_part_01:
    .byte $fd
    .addr sound_2f_part_05

; CPU address $9b72
sound_30_part_02:
    .incbin "assets/audio_data/sound_30_part_02.bin"
    .addr sound_30_part_02
    .byte $fd
    .addr sound_2f_part_05

sound_30_part_03:
    .incbin "assets/audio_data/sound_30_part_03.bin"
    .addr sound_30_part_01

; BGM 2 - level 3 waterfall music (noise/dmc channel)
; CPU address $9bce
sound_31:
    .byte $d6

; CPU address $9bcf
sound_31_part_00:
    .byte $00,$fe,$50
    .addr sound_31_part_00

; CPU address $9bd4
sound_31_part_01:
    .incbin "assets/audio_data/sound_31_part_01.bin"
    .addr sound_31_part_01

; CPU address $9bd9
sound_31_part_02:
    .incbin "assets/audio_data/sound_31_part_02.bin"
    .addr sound_31_part_02

sound_31_part_03:
    .incbin "assets/audio_data/sound_31_part_03.bin"
    .addr sound_31_part_02

lvl_5_pulse_volume_03:
    .byte $08,$07,$06,$05,$04,$00,$00,$00,$00,$00,$00,$01,$ff

lvl_5_pulse_volume_04:
    .byte $08,$07,$06,$05,$04,$03,$02,$01,$ff

lvl_5_pulse_volume_05:
    .byte $07,$06,$05,$04,$03,$02,$01,$00,$00,$00,$01,$ff

lvl_5_pulse_volume_06:
    .byte $04,$03,$02,$02,$02,$00,$00,$00,$00,$00,$01,$ff

; CPU address $9c71
sound_32_part_00:
    .incbin "assets/audio_data/sound_32_part_00.bin"

; CPU address $9c92
sound_32_part_01:
    .incbin "assets/audio_data/sound_32_part_01.bin"
    .addr sound_32_part_01

sound_32_part_02:
    .incbin "assets/audio_data/sound_32_part_02.bin"

; BGM 3 - level 5 snow field music (pulse 1 channel)
; CPU address $9ca4
sound_32:
    .incbin "assets/audio_data/sound_32.bin"

; CPU address $9caa
sound_32_part_03:
    .incbin "assets/audio_data/sound_32_part_03.bin"
    .addr sound_32_part_03

sound_32_part_04:
    .byte $e8

; CPU address $9cb0
sound_32_part_05:
    .incbin "assets/audio_data/sound_32_part_05.bin"
    .addr sound_32_part_05

sound_32_part_06:
    .incbin "assets/audio_data/sound_32_part_06.bin"

; CPU address $9cd7
sound_32_part_07:
    .incbin "assets/audio_data/sound_32_part_07.bin"
    .addr sound_32_part_07
    .byte $fd
    .addr sound_32_part_00

sound_32_part_08:
    .incbin "assets/audio_data/sound_32_part_08.bin"
    .addr sound_32_part_00

sound_32_part_09:
    .incbin "assets/audio_data/sound_32_part_09.bin"
    .addr sound_32_part_05

; CPU address $9d08
sound_32_part_0a:
    .incbin "assets/audio_data/sound_32_part_0a.bin"

; BGM 3 - level 5 snow field music (pulse 2 channel)
; CPU address $9d32
sound_33:
    .incbin "assets/audio_data/sound_33.bin"

; CPU address $9d37
sound_33_part_00:
    .incbin "assets/audio_data/sound_33_part_00.bin"
    .addr sound_33_part_00

; CPU address $9d3c
sound_33_part_01:
    .incbin "assets/audio_data/sound_33_part_01.bin"
    .addr sound_33_part_01

sound_33_part_02:
    .incbin "assets/audio_data/sound_33_part_02.bin"

; CPU address $9d65
sound_33_part_03:
    .incbin "assets/audio_data/sound_33_part_03.bin"
    .addr sound_33_part_03
    .byte $fd
    .addr sound_32_part_0a

sound_33_part_04:
    .incbin "assets/audio_data/sound_33_part_04.bin"
    .addr sound_32_part_0a

sound_33_part_05:
    .incbin "assets/audio_data/sound_33_part_05.bin"

; BGM 3 - level 5 snow field music (triangle channel)
; CPU address $9d9a
sound_34:
    .incbin "assets/audio_data/sound_34.bin"

; CPU address $9d9d
sound_34_part_00:
    .incbin "assets/audio_data/sound_34_part_00.bin"
    .addr sound_34_part_00

; CPU address $9da2
sound_34_part_01:
    .incbin "assets/audio_data/sound_34_part_01.bin"
    .addr sound_34_part_01

; CPU address $9db4
sound_34_part_02:
    .incbin "assets/audio_data/sound_34_part_02.bin"
    .addr sound_34_part_02

; CPU address $9dc6
sound_34_part_03:
    .incbin "assets/audio_data/sound_34_part_03.bin"
    .addr sound_34_part_03

sound_34_part_04:
    .incbin "assets/audio_data/sound_34_part_04.bin"

; CPU address $9de9
sound_34_part_05:
    .incbin "assets/audio_data/sound_34_part_05.bin"
    .addr sound_34_part_05

; CPU address $9dee
sound_34_part_06:
    .incbin "assets/audio_data/sound_34_part_06.bin"
    .addr sound_34_part_06

sound_34_part_07:
    .incbin "assets/audio_data/sound_34_part_07.bin"

; CPU address $9df7
sound_34_part_08:
    .incbin "assets/audio_data/sound_34_part_08.bin"
    .addr sound_34_part_08

; CPU address $9dfc
sound_34_part_09:
    .incbin "assets/audio_data/sound_34_part_09.bin"
    .addr sound_34_part_09
    .byte $fe,$ff
    .addr sound_34_part_01

; CPU address $9e06
sound_34_part_0a:
    .incbin "assets/audio_data/sound_34_part_0a.bin"
    .addr sound_34_part_0a

sound_34_part_0b:
    .incbin "assets/audio_data/sound_34_part_0b.bin"

; BGM 3 - level 5 snow field music (noise/dmc channel)
; CPU address $9e1e
sound_35:
    .byte $d6

; CPU address $9e1f
sound_35_part_00:
    .incbin "assets/audio_data/sound_35_part_00.bin"
    .addr sound_35_part_00

; CPU address $9e24
sound_35_part_01:
    .byte $fd
    .addr sound_34_part_0a
    .byte $fd
    .addr sound_34_part_0a

; CPU address $9e2a
sound_35_part_02:
    .incbin "assets/audio_data/sound_35_part_02.bin"
    .addr sound_35_part_02

sound_35_part_03:
    .incbin "assets/audio_data/sound_35_part_03.bin"

; CPU address $9e41
sound_35_part_04:
    .incbin "assets/audio_data/sound_35_part_04.bin"
    .addr sound_35_part_04

sound_35_part_05:
    .incbin "assets/audio_data/sound_35_part_05.bin"

; CPU address $9e57
sound_35_part_06:
    .incbin "assets/audio_data/sound_35_part_06.bin"
    .addr sound_35_part_06

sound_35_part_07:
    .incbin "assets/audio_data/sound_35_part_07.bin"
    .addr sound_35_part_01

lvl_5_pulse_volume_01:
    .byte $08,$07,$06,$05,$04,$03,$00,$00,$00,$00,$01,$ff

lvl_5_pulse_volume_02:
    .byte $06,$07,$06,$05,$04,$03,$ff

lvl_6_pulse_volume_03:
    .byte $05,$04,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_6_pulse_volume_04:
    .byte $08,$07,$06,$05,$04,$03,$03,$00,$00,$00,$01,$ff

lvl_6_pulse_volume_05:
    .byte $06,$05,$04,$03,$02,$00,$00,$00,$00,$00,$01,$ff

; BGM 4 - level 6 energy zone (pulse 1 channel)
; CPU address $9ea8
sound_36:
    .byte $e8,$d6,$f9,$87,$00,$e3,$c8

; CPU address $9eaf
sound_36_part_00:
    .incbin "assets/audio_data/sound_36_part_00.bin"

; CPU address $9ee5
sound_36_part_01:
    .incbin "assets/audio_data/sound_36_part_01.bin"
    .addr sound_36_part_01

; CPU address $9ef8
sound_36_part_02:
    .incbin "assets/audio_data/sound_36_part_02.bin"
    .addr sound_36_part_02

sound_36_part_03:
    .incbin "assets/audio_data/sound_36_part_03.bin"
    .addr sound_36_part_00

; BGM 4 - level 6 energy zone (pulse 2 channel)
; CPU address $9f46
sound_37:
    .incbin "assets/audio_data/sound_37.bin"

; CPU address $9f4c
sound_37_part_00:
    .incbin "assets/audio_data/sound_37_part_00.bin"

; CPU address $9f54
sound_37_part_01:
    .incbin "assets/audio_data/sound_37_part_01.bin"
    .addr sound_37_part_01

sound_37_part_02:
    .incbin "assets/audio_data/sound_37_part_02.bin"

; CPU address $9f6e
sound_37_part_03:
    .incbin "assets/audio_data/sound_37_part_03.bin"
    .addr sound_37_part_03

; CPU address $9f79
sound_37_part_04:
    .incbin "assets/audio_data/sound_37_part_04.bin"
    .addr sound_37_part_04

sound_37_part_05:
    .incbin "assets/audio_data/sound_37_part_05.bin"
    .addr sound_37_part_00

; BGM 4 - level 6 energy zone (triangle channel)
; CPU address $9fb8
sound_38:
    .incbin "assets/audio_data/sound_38.bin"

; CPU address $9fbc
sound_38_part_00:
    .incbin "assets/audio_data/sound_38_part_00.bin"

; CPU address $9fc2
sound_38_part_01:
    .incbin "assets/audio_data/sound_38_part_01.bin"
    .addr sound_38_part_01

sound_38_part_02:
    .incbin "assets/audio_data/sound_38_part_02.bin"

; CPU address $9fcc
sound_38_part_03:
    .incbin "assets/audio_data/sound_38_part_03.bin"
    .addr sound_38_part_03

sound_38_part_04:
    .incbin "assets/audio_data/sound_38_part_04.bin"

; CPU address $9fd8
sound_38_part_05:
    .incbin "assets/audio_data/sound_38_part_05.bin"
    .addr sound_38_part_05

; CPU address $9fe1
sound_38_part_06:
    .incbin "assets/audio_data/sound_38_part_06.bin"
    .addr sound_38_part_06

sound_38_part_07:
    .incbin "assets/audio_data/sound_38_part_07.bin"
    .addr sound_38_part_00

; BGM 4 - level 6 energy zone (noise/dmc channel)
; CPU address $a003
sound_39:
    .byte $d6

; CPU address $a004
sound_39_part_00:
    .incbin "assets/audio_data/sound_39_part_00.bin"
    .addr sound_39_part_00

; CPU address $a009
sound_39_part_01:
    .incbin "assets/audio_data/sound_39_part_01.bin"

; CPU address $a00d
sound_39_part_02:
    .incbin "assets/audio_data/sound_39_part_02.bin"
    .addr sound_39_part_02

sound_39_part_03:
    .incbin "assets/audio_data/sound_39_part_03.bin"

; CPU address $a025
sound_39_part_04:
    .incbin "assets/audio_data/sound_39_part_04.bin"
    .addr sound_39_part_04

sound_39_part_05:
    .incbin "assets/audio_data/sound_39_part_05.bin"

; CPU address $a03d
sound_39_part_06:
    .incbin "assets/audio_data/sound_39_part_06.bin"
   .addr sound_39_part_06

sound_39_part_07:
    .incbin "assets/audio_data/sound_39_part_07.bin"

; CPU address $a056
sound_39_part_08:
    .incbin "assets/audio_data/sound_39_part_08.bin"
    .addr sound_39_part_08

sound_39_part_09:
    .incbin "assets/audio_data/sound_39_part_09.bin"
    .addr sound_39_part_01

lvl_5_pulse_volume_07:
    .byte $07,$06,$05,$04,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_6_pulse_volume_00:
    .byte $05,$04,$03,$03,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_6_pulse_volume_01:
    .byte $05,$06,$07,$06,$05,$04,$03,$ff

lvl_6_pulse_volume_02:
    .byte $0b,$0a,$09,$08,$07,$06,$05,$04,$03,$ff

; BGM 5 - level 8 alien's lair music (pulse 1 channel)
; CPU address $a092
sound_3a:
    .byte $dc,$f7,$29,$02,$e1,$1d,$7d,$3d,$9d

; CPU address $a09b
sound_3a_part_00:
    .incbin "assets/audio_data/sound_3a_part_00.bin"
    .addr sound_3a_part_00

sound_3a_part_01:
    .incbin "assets/audio_data/sound_3a_part_01.bin"

; CPU address $a0c5
sound_3a_part_02:
    .incbin "assets/audio_data/sound_3a_part_02.bin"
    .addr sound_3a_part_02

sound_3a_part_03:
    .incbin "assets/audio_data/sound_3a_part_03.bin"

; CPU address $a0e6
sound_3a_part_04:
    .incbin "assets/audio_data/sound_3a_part_04.bin"
    .addr sound_3a_part_04

sound_3a_part_05:
    .incbin "assets/audio_data/sound_3a_part_05.bin"

; CPU address $a114
sound_3a_part_06:
    .incbin "assets/audio_data/sound_3a_part_06.bin"
    .addr sound_3a_part_06

sound_3a_part_07:
    .incbin "assets/audio_data/sound_3a_part_07.bin"

; CPU address $a143
sound_3a_part_08:
    .incbin "assets/audio_data/sound_3a_part_08.bin"
    .addr sound_3a_part_08

; CPU address $a14b
sound_3a_part_09:
    .incbin "assets/audio_data/sound_3a_part_09.bin"

; CPU address $a15a
sound_3a_part_0a:
    .incbin "assets/audio_data/sound_3a_part_0a.bin"
    .addr sound_3a_part_0a

sound_3a_part_0b:
    .incbin "assets/audio_data/sound_3a_part_0b.bin"
    .addr sound_3a_part_00

; BGM 5 - level 8 alien's lair music (pulse 2 channel)
; CPU address $a1a7
sound_3b:
    .incbin "assets/audio_data/sound_3b.bin"

; CPU address $a1b3
sound_3b_part_00:
    .incbin "assets/audio_data/sound_3b_part_00.bin"
    .addr sound_3b_part_00

; CPU address $a1d3
sound_3b_part_01:
    .incbin "assets/audio_data/sound_3b_part_01.bin"
    .addr sound_3b_part_01

sound_3b_part_02:
    .incbin "assets/audio_data/sound_3b_part_02.bin"
    .addr sound_3b_part_00

; BGM 5 - level 8 alien's lair music (triangle channel)
; CPU address $a295
sound_3c:
    .incbin "assets/audio_data/sound_3c.bin"
    .addr sound_3c

; CPU address $a2a2
sound_3c_part_00:
    .incbin "assets/audio_data/sound_3c_part_00.bin"
    .addr sound_3c_part_00

sound_3c_part_01:
    .incbin "assets/audio_data/sound_3c_part_01.bin"

; CPU address $a2c6
sound_3c_part_02:
    .incbin "assets/audio_data/sound_3c_part_02.bin"
    .addr sound_3c_part_02

sound_3c_part_03:
    .incbin "assets/audio_data/sound_3c_part_03.bin"

; CPU address $a30a
sound_3c_part_04:
    .incbin "assets/audio_data/sound_3c_part_04.bin"
    .addr sound_3c_part_04

sound_3c_part_05:
    .incbin "assets/audio_data/sound_3c_part_05.bin"
    .addr sound_3c_part_00

; BGM 5 - level 8 alien's lair music (noise/dmc channel)
; CPU address $a32f
sound_3d:
    .byte $d7

; CPU address $a330
sound_3d_part_00:
    .incbin "assets/audio_data/sound_3d_part_00.bin"

; CPU address $a333
sound_3d_part_01:
    .addr sound_3d_part_00

; CPU address $a335
sound_3d_part_02:
    .incbin "assets/audio_data/sound_3d_part_02.bin"

; CPU address $a33d
sound_3d_part_03:
    .incbin "assets/audio_data/sound_3d_part_03.bin"
    .addr sound_3d_part_03

; CPU address $a357
sound_3d_part_04:
    .incbin "assets/audio_data/sound_3d_part_04.bin"
    .addr sound_3d_part_04

sound_3d_part_05:
    .incbin "assets/audio_data/sound_3d_part_05.bin"

; CPU address $a36f
sound_3d_part_06:
    .incbin "assets/audio_data/sound_3d_part_06.bin"
    .addr sound_3d_part_06

sound_3d_part_07:
    .incbin "assets/audio_data/sound_3d_part_07.bin"
    .addr sound_3d_part_03

lvl_2_pulse_volume_00:
    .byte $07,$07,$06,$05,$04,$03,$00,$00,$00,$01,$01,$01,$ff

lvl_2_pulse_volume_01:
    .byte $07,$06,$05,$04,$03,$ff

lvl_2_pulse_volume_02:
    .byte $03,$04,$05,$04,$03,$02,$ff

lvl_2_pulse_volume_03:
    .byte $06,$07,$06,$05,$04,$03,$00,$00,$00,$00,$01,$01,$ff

lvl_2_pulse_volume_04:
    .byte $07,$06,$05,$04,$03,$00,$00,$00,$00,$00,$01,$01,$ff

lvl_2_pulse_volume_05:
    .byte $05,$04,$03,$03,$03,$00,$00,$00,$00,$00,$01,$01,$ff

; CPU address $a41c
sound_3e_part_00:
    .incbin "assets/audio_data/sound_3e_part_00.bin"
    .addr sound_3e_part_00

sound_3e_part_01:
    .incbin "assets/audio_data/sound_3e_part_01.bin"

; CPU address $a44a
sound_3e_part_02:
    .incbin "assets/audio_data/sound_3e_part_02.bin"
    .addr sound_3e_part_02

sound_3e_part_03:
    .incbin "assets/audio_data/sound_3e_part_03.bin"

; 3D BGM - indoor/base level music (pulse 1 channel)
; CPU address $a468
sound_3e:
    .incbin "assets/audio_data/sound_3e.bin"
    .addr sound_3e

sound_3e_part_04:
    .incbin "assets/audio_data/sound_3e_part_04.bin"

; CPU address $a48f
sound_3e_part_05:
    .incbin "assets/audio_data/sound_3e_part_05.bin"
    .addr sound_3e_part_05

sound_3e_part_06:
    .incbin "assets/audio_data/sound_3e_part_06.bin"

; CPU address $a4b5
sound_3e_part_07:
    .incbin "assets/audio_data/sound_3e_part_07.bin"
    .addr sound_3e_part_00

; CPU address $a4fb
sound_3e_part_08:
    .incbin "assets/audio_data/sound_3e_part_08.bin"
    .addr sound_3e_part_08

; CPU address $a508
sound_3e_part_09:
    .incbin "assets/audio_data/sound_3e_part_09.bin"
    .addr sound_3e_part_09
    .byte $fd
    .addr sound_3e_part_00
    .byte $fe,$ff
    .addr sound_3e_part_07

; CPU address $a51b
sound_3e_part_0a:
    .incbin "assets/audio_data/sound_3e_part_0a.bin"
    .addr sound_3e_part_0a

sound_3e_part_0b:
    .incbin "assets/audio_data/sound_3e_part_0b.bin"

; CPU address $a545
sound_3e_part_0c:
    .incbin "assets/audio_data/sound_3e_part_0c.bin"
    .addr sound_3e_part_0c

sound_3e_part_0d:
    .incbin "assets/audio_data/sound_3e_part_0d.bin"

; 3D BGM - indoor/base level music (pulse 2 channel)
; CPU address $a570
sound_3f:
    .incbin "assets/audio_data/sound_3f.bin"
    .addr sound_3e_part_0a

sound_3f_part_00:
    .incbin "assets/audio_data/sound_3f_part_00.bin"
    .addr sound_3e_part_0a

; CPU address $a5b9
sound_3f_part_01:
    .incbin "assets/audio_data/sound_3f_part_01.bin"
    .addr sound_3f_part_01

; CPU address $a5c9
sound_3f_part_02:
    .incbin "assets/audio_data/sound_3f_part_02.bin"
    .addr sound_3f_part_02
    .byte $fe,$ff
    .addr sound_3f

; CPU address $a5dd
sound_3f_part_03:
    .incbin "assets/audio_data/sound_3f_part_03.bin"

; CPU address $a5e0
sound_3f_part_04:
    .incbin "assets/audio_data/sound_3f_part_04.bin"
    .addr sound_3f_part_04

; CPU address $a5e5
sound_3f_part_05:
    .incbin "assets/audio_data/sound_3f_part_05.bin"
    .addr sound_3f_part_05
    .byte $ff

; 3D BGM - indoor/base level music (triangle channel)
; CPU address $a5eb
sound_40:
    .incbin "assets/audio_data/sound_40.bin"
    .addr sound_40

; CPU address $a5f7
sound_40_part_00:
    .incbin "assets/audio_data/sound_40_part_00.bin"
    .addr sound_40_part_00

; CPU address $a5fd
sound_40_part_01:
    .incbin "assets/audio_data/sound_40_part_01.bin"
    .addr sound_3f_part_03

; CPU address $a630
sound_40_part_02:
    .incbin "assets/audio_data/sound_40_part_02.bin"
    .addr sound_40_part_02

; CPU address $a63b
sound_40_part_03:
    .incbin "assets/audio_data/sound_40_part_03.bin"
    .addr sound_40_part_03
    .byte $fd
    .addr sound_3f_part_03
    .byte $fe,$ff
    .addr sound_40_part_01

; CPU address $a64e
sound_40_part_04:
    .incbin "assets/audio_data/sound_40_part_04.bin"
    .addr sound_40_part_04

sound_40_part_05:
    .incbin "assets/audio_data/sound_40_part_05.bin"

; CPU address $a663
sound_40_part_06:
    .incbin "assets/audio_data/sound_40_part_06.bin"
    .addr sound_40_part_06

sound_40_part_07:
    .incbin "assets/audio_data/sound_40_part_07.bin"

; 3D BGM - indoor/base level music (noise/dmc channel)
; CPU address $a67a
sound_41:
    .incbin "assets/audio_data/sound_41.bin"
    .addr sound_41

sound_41_part_00:
    .incbin "assets/audio_data/sound_41_part_00.bin"

; CPU address $a68b
sound_41_part_01:
    .incbin "assets/audio_data/sound_41_part_01.bin"
    .addr sound_41_part_01

sound_41_part_02:
    .incbin "assets/audio_data/sound_41_part_02.bin"

; CPU address $a6a0
sound_41_part_03:
    .incbin "assets/audio_data/sound_41_part_03.bin"
    .addr sound_41_part_03

sound_41_part_04:
    .incbin "assets/audio_data/sound_41_part_04.bin"
    .addr sound_40_part_04

sound_41_part_05:
    .incbin "assets/audio_data/sound_41_part_05.bin"

; CPU address $a6e4
sound_41_part_06:
    .incbin "assets/audio_data/sound_41_part_06.bin"
    .addr sound_41_part_06

; CPU address $a6ec
sound_41_part_07:
    .incbin "assets/audio_data/sound_41_part_07.bin"

; CPU address $a6f0
sound_41_part_08:
    .incbin "assets/audio_data/sound_41_part_08.bin"
    .addr sound_41_part_08

sound_41_part_09:
    .incbin "assets/audio_data/sound_41_part_09.bin"
    .addr sound_40_part_04
    .byte $fe,$ff
    .addr sound_41_part_03

lvl_2_pulse_volume_06:
    .byte $05,$06,$05,$04,$03,$02,$00,$00,$00,$00,$00,$01,$ff

lvl_6_pulse_volume_06:
    .byte $0c,$0b,$0a,$09,$08,$07,$06,$ff

lvl_6_pulse_volume_07:
    .byte $08,$07,$06,$05,$04,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_7_pulse_volume_00:
    .byte $0a,$09,$08,$07,$06,$05,$04,$00,$00,$00,$00,$01,$ff

; CPU address $a735
sound_43_part_00:
    .incbin "assets/audio_data/sound_43_part_00.bin"
    .addr sound_43_part_00

; CPU address $a746
sound_43_part_01:
    .incbin "assets/audio_data/sound_43_part_01.bin"
    .addr sound_43_part_01

; CPU address $a759
sound_43_part_02:
    .incbin "assets/audio_data/sound_43_part_02.bin"
    .addr sound_43_part_02

sound_43_part_03:
    .incbin "assets/audio_data/sound_43_part_03.bin"

; BOSS - indoor/base boss screen music (pulse 1 channel)
; CPU address $a793
sound_42:
    .incbin "assets/audio_data/sound_42.bin"
    .addr sound_42

sound_42_part_00:
    .incbin "assets/audio_data/sound_42_part_00.bin"
    .addr sound_42

; BOSS - indoor/base boss screen music (pulse 2 channel)
; CPU address $a878
sound_43:
    .incbin "assets/audio_data/sound_43.bin"
    .addr sound_43_part_00
    .byte $fd
    .addr sound_43_part_00

sound_43_part_04:
    .incbin "assets/audio_data/sound_43_part_04.bin"
    .addr sound_43

; BOSS - indoor/base boss screen music (triangle channel)
; CPU address $a8fb
sound_44:
    .incbin "assets/audio_data/sound_44.bin"
    .addr sound_44

sound_44_part_00:
    .incbin "assets/audio_data/sound_44_part_00.bin"
    .addr sound_44

; CPU address $a9fd
sound_45_part_00:
    .incbin "assets/audio_data/sound_45_part_00.bin"

; CPU address $aa03
sound_45_part_01:
    .incbin "assets/audio_data/sound_45_part_01.bin"
    .addr sound_45_part_01
    .byte $ff

; BOSS - indoor/base boss screen music (noise/dmc channel)
; CPU address $aa0e
sound_45:
    .incbin "assets/audio_data/sound_45.bin"
    .addr sound_45

sound_45_part_02:
    .incbin "assets/audio_data/sound_45_part_02.bin"
    .addr sound_45_part_00
    .byte $fd
    .addr sound_45_part_00
    .byte $fd
    .addr sound_45_part_00
    .byte $fd
    .addr sound_45_part_00

sound_45_part_03:
    .incbin "assets/audio_data/sound_45_part_03.bin"
    .addr sound_45

lvl_2_pulse_volume_07:
    .byte $08,$07,$06,$05,$04,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_3_pulse_volume_00:
    .byte $06,$07,$06,$05,$04,$03,$ff

lvl_3_pulse_volume_01:
    .byte $04,$05,$04,$03,$ff

lvl_3_pulse_volume_06:
    .byte $09,$08,$07,$06,$05,$04,$03,$00,$00,$00,$00,$01,$ff

lvl_7_pulse_volume_05:
    .byte $08,$07,$06,$05,$04,$03,$03,$00,$00,$00,$00,$01,$ff

; PCLR - end of level tune (pulse 1 channel)
; CPU address $aa92 - end of level tune
sound_46:
    .incbin "assets/audio_data/sound_46.bin"

; PCLR - end of level tune (pulse 2 channel)
; CPU address $aab3
sound_47:
    .incbin "assets/audio_data/sound_47.bin"

; PCLR - end of level tune (triangle channel)
; CPU address $aad4
sound_48:
    .incbin "assets/audio_data/sound_48.bin"

; PCLR - end of level tune (noise/dmc channel)
; CPU address $aaef
sound_49:
    .incbin "assets/audio_data/sound_49.bin"

lvl_3_pulse_volume_02:
    .byte $08,$07,$06,$05,$04,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_3_pulse_volume_03:
    .byte $06,$05,$04,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_3_pulse_volume_04:
    .byte $05,$04,$03,$02,$02,$02,$00,$00,$00,$01,$ff

lvl_3_pulse_volume_05:
    .byte $08,$07,$06,$05,$04,$03,$00,$00,$00,$01,$ff

; OVER - game over/after end credits, presented by konami (pulse 1 channel)
; CPU address $ab34
sound_4e:
    .incbin "assets/audio_data/sound_4e.bin"

; OVER - game over/after end credits, presented by konami (pulse 2 channel)
; CPU address $ab5c
sound_4f:
    .incbin "assets/audio_data/sound_4f.bin"

; OVER - game over/after end credits, presented by konami (triangle channel)
; CPU address $ab86
sound_50:
    .incbin "assets/audio_data/sound_50.bin"

; OVER - game over/after end credits, presented by konami (noise/dmc channel)
; CPU address $abb2
sound_51:
    .incbin "assets/audio_data/sound_51.bin"

lvl_7_pulse_volume_01:
    .byte $07,$08,$07,$06,$05,$04,$03,$ff

lvl_7_pulse_volume_02:
    .byte $07,$06,$05,$04,$03,$03,$03,$03,$03,$03,$00,$00,$00,$00,$01,$ff

lvl_7_pulse_volume_03:
    .byte $ff

lvl_7_pulse_volume_04:
    .byte $ff

; CPU address $abec
sound_4a_part_00:
    .incbin "assets/audio_data/sound_4a_part_00.bin"

; ENDING - end credits (pulse 1 channel)
; CPU address $ac9f
sound_4a:
    .incbin "assets/audio_data/sound_4a.bin"
    .addr sound_4a_part_00

sound_4a_part_01:
    .incbin "assets/audio_data/sound_4a_part_01.bin"
    .addr sound_4a_part_00

sound_4a_part_02:
    .incbin "assets/audio_data/sound_4a_part_02.bin"

; CPU address $acad
sound_4a_part_03:
    .incbin "assets/audio_data/sound_4a_part_03.bin"

; ENDING - end credits (pulse 2 channel)
; CPU address $ad1a
sound_4b:
    .byte $fd
    .addr sound_4a_part_03

sound_4b_part_00:
    .incbin "assets/audio_data/sound_4b_part_00.bin"
    .addr sound_4a_part_03

; CPU address $ad22
sound_4b_part_01:
    .incbin "assets/audio_data/sound_4b_part_01.bin"

; CPU address $ad25
sound_4b_part_02:
    .incbin "assets/audio_data/sound_4b_part_02.bin"
    .addr sound_4b_part_02

; CPU address $ad36
sound_4b_part_03:
    .incbin "assets/audio_data/sound_4b_part_03.bin"

; CPU address $ad59
sound_4b_part_04:
    .incbin "assets/audio_data/sound_4b_part_04.bin"
    .addr sound_4b_part_04

; CPU address $ad69
sound_4b_part_05:
    .incbin "assets/audio_data/sound_4b_part_05.bin"
    .addr sound_4b_part_05

; CPU address $ad7a
sound_4b_part_06:
    .incbin "assets/audio_data/sound_4b_part_06.bin"

; CPU address $ad9d
sound_4b_part_07:
    .incbin "assets/audio_data/sound_4b_part_07.bin"
    .addr sound_4b_part_07

sound_4b_part_08:
    .incbin "assets/audio_data/sound_4b_part_08.bin"

; ENDING - end credits (triangle channel)
; CPU address $ae05
sound_4c:
    .byte $fd
    .addr sound_4b_part_02

sound_4c_part_00:
    .incbin "assets/audio_data/sound_4c_part_00.bin"
    .addr sound_4b_part_02

sound_4c_part_01:
    .incbin "assets/audio_data/sound_4c_part_01.bin"

; CPU address $ae1e
sound_4c_part_02:
    .incbin "assets/audio_data/sound_4c_part_02.bin"
    .addr sound_4c_part_02

sound_4c_part_03:
    .incbin "assets/audio_data/sound_4c_part_03.bin"

; CPU address $ae36
sound_4c_part_04:
    .incbin "assets/audio_data/sound_4c_part_04.bin"
    .addr sound_4c_part_04

; CPU address $ae43
sound_4c_part_05:
    .incbin "assets/audio_data/sound_4c_part_05.bin"

; CPU address $ae4c
sound_4c_part_06:
    .incbin "assets/audio_data/sound_4c_part_06.bin"
    .addr sound_4c_part_06

sound_4c_part_07:
    .incbin "assets/audio_data/sound_4c_part_07.bin"

; CPU address $ae63
sound_4c_part_08:
    .incbin "assets/audio_data/sound_4c_part_08.bin"
    .addr sound_4c_part_08

; CPU address $ae70
sound_4c_part_09:
    .incbin "assets/audio_data/sound_4c_part_09.bin"

; CPU address $ae79
sound_4c_part_0a:
    .incbin "assets/audio_data/sound_4c_part_0a.bin"
    .addr sound_4c_part_0a
    .byte $ff

; ENDING - end credits (noise/dmc channel)
; CPU address $ae87
sound_4d:
    .byte $fd
    .addr sound_4c_part_02

sound_4d_part_00:
    .incbin "assets/audio_data/sound_4d_part_00.bin"
    .addr sound_4c_part_02

sound_4d_part_01:
    .incbin "assets/audio_data/sound_4d_part_01.bin"

; end of sound code logic, beginning of sprite code logic

; writes encoded sprite data into memory address $0200-$02ff
; which is later the address set for OAMDMA for display
; for non-hud sprites this label loads #$19 #$4-byte entries per call (#$4c bytes total)
; when SPRITE_LOAD_TYPE is #01, then the sprites on top of the screen (medals, game over)
; CPU address $ae97
draw_sprites:
    lda $35                      ; OAMDMA_CPU_BUFFER write offset
    clc                          ; clear carry in preparation for addition
    adc #$4c                     ; add #$4c to OAMDMA_CPU_BUFFER, this is to support "sprite cycling"/"sprite flickering"
                                 ; since the NES can draw a maximum of 8 sprites per scan line, Contra adjusts the starting locations
                                 ; so that sprites move around in PPU memory. This will allow different sprites to load each frame
                                 ; on the same scan line. Human eyes won't notice a sprite not visible for a single frame
    sta $35                      ; OAMDMA_CPU_BUFFER write offset
    sta $04                      ; store OAMDMA_CPU_BUFFER write offset to $04
    ldy #$3f                     ; y = #$3f (maximum number of sprite pattern tiles that NES supports)
    sty $07                      ; set maximum number of sprites in $07
    lda SPRITE_LOAD_TYPE         ; if 0, load regular sprites to cpu, else load hud sprites
    beq @load_sprites_to_cpu_mem ; load sprites to cpu
    jsr draw_hud_sprites         ; draw hud sprites

@load_sprites_to_cpu_mem:
    ldx #$19 ; up to #$19 sprites possible to load

; loops through the total number of possible sprites
@load_sprite_loop:
    stx $05                    ; store current sprite number offset into x
    lda CPU_SPRITE_BUFFER,x    ; load sprite offset into sprite_ptr_tbl
    beq @adv_sprite            ; move to next contra sprite if this current wasn't used
    ldy SPRITE_ATTR,x          ; load sprite attribute data
    sty $00                    ; set $00 to hold SPRITE_ATTR
    ldy SPRITE_Y_POS,x         ; sprite y position on screen
    sty $01                    ; set $01 to hold base y position of sprite (sprite tiles are positioned relative to this point)
    ldy SPRITE_X_POS,x         ; sprite x position on screen
    sty $02                    ; set $02 to hold base x position of sprite (sprite tiles are positioned relative to this point)
    jsr load_sprite_to_cpu_mem ; loads all the sprite pattern tiles to the OAMDMA buffer

@adv_sprite:
    ldy $07               ; load number of sprite tiles available to draw
    bmi draw_sprites_exit ; exit if the OAMDMA is full
    ldx $05               ; load the remaining number of contra sprites left to render (sprites, not tiles)
    dex                   ; decrement total sprites remaining
    bpl @load_sprite_loop ; if contra sprites left to drawn, loop to draw it
    ldx $04               ; load OAMDMA_CPU_BUFFER write offset

; take the remaining sprite tiles that are available in the OAMDMA and blank them
@fill_unused_OAM:
    lda #$f4                ; hide any sprite whose byte 0 is $ef-$ff is not displayed
    sta OAMDMA_CPU_BUFFER,x ; write y position as #$f4 (hidden)
    jsr adv_OAMDMA_addr     ; add #$c4 to x (move to next sprite tile location)
    dey                     ; decrement remaining sprite tiles counter
    bpl @fill_unused_OAM    ; loop to hide next sprite tile if haven't hidden all leftover tiles

draw_sprites_exit:
    rts

; write sprite data (OAM) to OAMDMA_CPU_BUFFER from CPU SPRITE buffer data
; if a >= #$80 offset is into sprite_ptr_tbl_1
; input
;  * a - sprite code, offset into sprite_ptr_tbl_0 or sprite_ptr_tbl_1
;  * $00 - sprite attribute
;  * $01 - sprite y position on screen
;  * $02 - sprite x position
; output
;  * $04 - the next starting position of the OAMDMA_CPU_BUFFER write offset
;  * $07 - lowers the number of remaining sprite tiles that can be drawn by the
;          NES based on how many tiles were in the sprite drawn
load_sprite_to_cpu_mem:
    asl                       ; double since each entry in sprite_ptr_tbl is 2 bytes
    tay
    bcs @load_sprite_tbl_1    ; offset is >= #$80, use second sprite table
    lda sprite_ptr_tbl_0-2,y  ; use first sprite table a < #$80
    sta $08                   ; store low byte of sprite address into $08
    lda sprite_ptr_tbl_0-1,y  ; load high byte of sprite address into a
    jmp @continue_load_sprite ; jump to store low byte and continue loading sprite

@load_sprite_tbl_1:
    lda sprite_ptr_tbl_1,y   ; load low byte of sprite address
    sta $08                  ; store low byte of sprite address into $08
    lda sprite_ptr_tbl_1+1,y ; load high byte of sprite address

@continue_load_sprite:
    sta $09                  ; store high byte of sprite address into $09
    ldy #$00                 ; y = #$00
    lda ($08),y              ; load number of tiles first byte from sprite
    beq draw_sprites_exit    ; if #$00, exit
    iny                      ; increment sprite_xx read offset
    cmp #$fe                 ; check if "small" sprite
    bne @load_regular_sprite
    jmp @load_small_sprite   ; handle #$fe

@load_regular_sprite:
    sta $03                     ; store number of pattern tiles in sprite into $03
    lda $00                     ; load SPRITE_ATTR
    and #$c8                    ; keep bits xx.. x..., keep horizontal and vertical flip bits
                                ; bit 3 signals whether to add 1 to y position for regular sprites (not small sprites)
    sta $0b                     ; store in $0b, this is later used when rendering the sprite tile
                                ; e.g. if the sprite tile within the sprite is defined as flipped vertically or horizontally,
                                ; and the SPRITE_ATTR specifies flipping the entire sprite, then we have to 'flip the flip', i.e. change from a 1 to a 0
    lda $00                     ; reload SPRITE_ATTR, looking to see if bit 2 is set
    lsr
    lsr
    lsr
    ldx #$fc                    ; x = #$fc (1111 1100) used to strip palette from sprite code's sprite tile definition
    lda #$23                    ; a = #$23 (0010 0011) used to keep palette and background priority from SPRITE_ATTR
    bcs @prep_sprite_attributes ; branch if bit 2 of SPRITE_ATTR is 1
                                ; this means bg priority and sprite palette will be from SPRITE_ATTR and not sprite code byte 2 definition
    ldx #$ff                    ; x = #$ff (1111 1111) used to keep palette and flip bits from sprite code byte 2 definition
    lda #$20                    ; a = #$20 (0010 0000) used to strip palette from SPRITE_ATTR and instead use sprite code byte 2 definition

@prep_sprite_attributes:
    and $00 ; keep/strip the sprite palette and bg priority from SPRITE_ATTR depending on bit 2 of SPRITE_ATTR
    sta $00 ; update $00 with new value
    stx $0d ; store palette and flip bits from sprite code byte 2 definition if not overwritten by SPRITE_ATTR
    ldx $04 ; load OAMDMA_CPU_BUFFER write offset

@write_sprite_tile:
    lda ($08),y   ; load first byte of sprite (y position), or #$80 for shared sprite
    cmp #$80      ; see if using shared sprite
    bne @continue ; not using shared sprite, continue like normal
                  ; using shared sprite, need to update cpu read address
    lda $0b       ; load sprite effect
    and #$f7      ; strip bit 3 to prevent adding #$01 to y position
    sta $0b       ; save sprite effect
    iny           ; increment sprite_xx read offset
    lda ($08),y   ; load low byte of new sprite read address
    sta $06       ; store low byte into $06
    iny           ; increment sprite_xx read offset
    lda ($08),y   ; load high byte of new sprite read address
    sta $09       ; replace existing read high byte in $09 with new address
    lda $06       ; load low byte
    sta $08       ; replace existing read low byte in $08 with new address
    ldy #$00      ; clear sprite_xx read offset since starting at new address

@continue:
    lda ($08),y          ; read sprite relative y position (Byte 0)
    sta $0c              ; store sprite tile relative y offset
    lda $0b
    asl                  ; shift sprite effect left
    and #$10             ; keep bits ...x ....
    beq @prep_y_position ; see if bit 3 of SPRITE_ATTR is set
    inc $0c              ; bit 3 was set, add #$01 to relative y position
                         ; used for creating recoil effect when firing gun

@prep_y_position:
    lda $0c                     ; load sprite tile relative offset
    bcc @write_sprite_tile_data ; branch bit 7 of $0b is 0
    sta $0c                     ; store sprite tile relative y offset
    lda #$f0                    ; a = #$f0
    sbc $0c                     ; #$f0 minus sprite tile relative y offset
    clc

@write_sprite_tile_data:
    adc $01                   ; add SPRITE_Y_POS to sprite y offset (sets tile's absolute position)
    sta OAMDMA_CPU_BUFFER,x   ; write y position to CPU buffer
    iny                       ; increment sprite_xx read offset
    lda ($08),y               ; read 2nd byte, which specifies pattern table tile (Byte 1)
    sta OAMDMA_CPU_BUFFER+1,x ; write pattern tile number to CPU buffer
    iny                       ; increment sprite data read offset
    lda ($08),y               ; read 3rd byte (sprite tile attributes) (Byte 2)
    and $0d                   ; keep/strip sprite palette from sprite tile byte 2, based on bit 2 of SPRITE_ATTR
    ora $00                   ; merge sprite code tile byte 2 with attribute data from SPRITE_ATTR
    eor $0b                   ; exclusive or to handle flipping a flipped sprite tile, e.g. flip + flip = no flip
    sta OAMDMA_CPU_BUFFER+2,x ; write sprite attributes to CPU buffer
    iny                       ; increment sprite_xx read offset
    lda $0b
    asl
    asl
    lda ($08),y               ; read next byte of sprite_xx
    bcc @continue2            ; branch if no horizontal flip
    sta $0c                   ; horizontal flip, store x position
    lda #$f8                  ; a = #$f8
    sbc $0c
    clc

@continue2:
    bmi @set_sprite_tile_x_adv_addr
    adc $02                         ; add to sprite x position
    bcs @move_next_sprite_tile      ; increment read offset, set next write offset, decrement total sprite tiles

@set_x_adv_addr:
    jsr set_x_adv_OAMDMA_addr ; set sprite tile x position (a) in OAMDMA and advance OAMDMA write address

@move_next_sprite_tile:
    iny                    ; increment sprite_xx read offset
    dec $03                ; decrement remaining sprite tiles in sprite that is being drawn
    bne @write_sprite_tile ; move to the next tile in the sprite to move into OAMDMA
    stx $04                ; write next OAMDMA write offset to $04
    rts

; set sprite tile's relative x position, and set next OAMDMA write address
; input
;  a - the x offset of the sprite tile from the SPRITE_X_POS
@set_sprite_tile_x_adv_addr:
    adc $02                    ; add to sprite x base position
    bcs @set_x_adv_addr        ; set sprite tile x position (a) in OAMDMA and advance OAMDMA write address
    bcc @move_next_sprite_tile ; increment read offset, set next write offset, decrement total sprite tiles

; sprite code is made of a single #$03-byte entry (including #$fe)
; the second byte is the pattern table tile, and the third byte is the sprite attributes
; the X position is set to #$fc (-4 decimal) and the Y position is set to #$f8 (-8 decimal) from SPRITE_Y_POS.
@load_small_sprite:
    ldx $04                   ; load OAM write offset
    lda #$f8                  ; a = -#$08
    clc                       ; clear carry in preparation for addition
    adc $01                   ; subtract #$08 from y position
    sta OAMDMA_CPU_BUFFER,x   ; set y position of small sprite
    lda ($08),y               ; load pattern tile of sprite
    sta OAMDMA_CPU_BUFFER+1,x ; set pattern tile of small sprite
    iny                       ; increment sprite_xx read offset
    lda ($08),y               ; load SPRITE_ATTR
    ora $00                   ; merge with $00
    sta OAMDMA_CPU_BUFFER+2,x ; store SPRITE_ATTR of small sprite
    lda $02                   ; load sprite's base x position
    sec                       ; set carry flag in preparation for subtraction
    sbc #$04                  ; subtract #$04
    bcc @exit                 ; exit if overflow
    jsr set_x_adv_OAMDMA_addr ; set sprite tile x position (a) in OAMDMA and advance OAMDMA write address
    stx $04                   ; store next OAMDMA write address in $04

@exit:
    iny ; increment sprite_xx read offset
    rts

; places the "heads up display" (HUD) sprites in the correct locations in memory $0200-$02ff
; so they are on the screen when written by OAMDMA
draw_hud_sprites:
    lda PLAYER_MODE ; #$00 single player, #$01 for 2nd player
    ldy DEMO_MODE   ; #$00 not in demo mode, #$01 demo mode on
    beq @continue
    lda #$01        ; start with player 2 when not in demo mode

@continue:
    sta $00 ; store current player number (used for HUD sprite palette)
    ldx $04

draw_player_hud_sprites:
    ldy #$04                  ; y = #$04
    lda DEMO_MODE             ; #$00 not in demo mode, #$01 demo mode on
    bne @four_sprites         ; demo mode always shows GAME OVER
    ldy $00                   ; load current player
    lda P1_GAME_OVER_STATUS,y ; player y game over state (1 = game over)
    ldy #$04                  ; set hud_sprites base offset to show GAME OVER
    lsr
    bcs @four_sprites         ; branch if in game over
    ldy $00                   ; not in game over, load number of lives remaining for current player
    lda P1_NUM_LIVES,y        ; player y lives
    ldy #$00                  ; set hud_sprites base offset to show medals
    cmp #$04
    bcc @draw_sprites         ; if less than #$04 lives, show that number of medals

@four_sprites:
    lda #$04 ; show 4 medals on player HUD

@draw_sprites:
    sta $01 ; store number of medals to draw in $01

@draw_p_sprite:
    dec $01                     ; decrement number of medals to draw
    bmi @move_to_next_player    ; if done drawing all sprites, move to next player
    lda #$10                    ; a = #$10
    sta OAMDMA_CPU_BUFFER,x     ; set y position of medal/game over hud sprite to #$10
    lda hud_sprites,y           ; load HUD sprite (either medal, or game over text)
    sta OAMDMA_CPU_BUFFER+1,x   ; write tile number to OAM
    lda $00
    sta OAMDMA_CPU_BUFFER+2,x   ; write the tile attributes (blue palette for p1, red palette for p2)
    lsr                         ; set carry flag if on player 2
    lda sprite_medal_x_offset,y ; load x offset based on sprite number
    bcc @continue
    adc #$af                    ; add #$af to sprite x offset if on player 2 (see previous lsr)

@continue:
    jsr set_x_adv_OAMDMA_addr ; set sprite tile x position (a) in OAMDMA and advance OAMDMA write address
    iny                       ; increment medal sprite number (#$00 to #$04)
    jmp @draw_p_sprite

@move_to_next_player:
    dec $00                     ; decrement player number
    bpl draw_player_hud_sprites ; load player 1 HUD if we were on player 2
    stx $04
    rts

; table for hud sprites, references pattern table tiles (#$10 bytes)
; medals for number of lives or
; GAME
; OVER
hud_sprites:
    .byte $0a,$0a,$0a,$0a ; medals
    .byte $02,$04,$06,$08 ; game over text

sprite_medal_x_offset:
    .byte $10,$1c,$28,$34
    .byte $10,$1c,$28,$34

; set sprite tile x position (a) in OAMDMA and advance OAMDMA write address
set_x_adv_OAMDMA_addr:
    sta OAMDMA_CPU_BUFFER+3,x ; set X position of sprite
    dec $07                   ; decrement number of remaining sprite tiles that NES can draw

; adds #$c4 to x for next write location of OAMDMA sprite data
adv_OAMDMA_addr:
    txa      ; move current write offset to a
    clc      ; clear carry in preparation for addition
    adc #$c4 ; add #$c4 to current write offset
    tax      ; move new offset back to x
    rts

; enormous pointer table for sprites (#$cf * #$2 = #$19e bytes)
sprite_ptr_tbl_0:
    .addr sprite_01 ; CPU address $b1ce - blank
    .addr sprite_02 ; CPU address $b1cf - player walking (frame 1)
    .addr sprite_03 ; CPU address $b1e4 - player walking (frame 2)
    .addr sprite_04 ; CPU address $b1f9 - player walking (frame 3)
    .addr sprite_05 ; CPU address $b20e - player walking (frame 4)
    .addr sprite_06 ; CPU address $b21a - player walking (frame 5)
    .addr sprite_07 ; CPU address $b226 - enemy bullet (snow field)
    .addr sprite_08 ; CPU address $b229 - player curled up (frame 1)
    .addr sprite_09 ; CPU address $b23a - player curled up (frame 2)
    .addr sprite_0a ; CPU address $b247 - player hit (frame 1)
    .addr sprite_0b ; CPU address $b258 - player hit (frame 2)
    .addr sprite_0c ; CPU address $b269 - player lying on ground
    .addr sprite_0d ; CPU address $b27a - player walking holding weapon out (frame 1)
    .addr sprite_0e ; CPU address $b28a - player walking holding weapon out (frame 2)
    .addr sprite_0f ; CPU address $b29a - player walking holding weapon out (frame 3)
    .addr sprite_10 ; CPU address $b2aa - player aiming angled up (frame 1)
    .addr sprite_11 ; CPU address $b2b6 - player aiming angled up (frame 2)
    .addr sprite_12 ; CPU address $b2c2 - player aiming angled up (frame 3)
    .addr sprite_13 ; CPU address $b2ce - player aiming angled down (frame 1)
    .addr sprite_14 ; CPU address $b2de - player aiming angled down (frame 2)
    .addr sprite_15 ; CPU address $b2ee - player aiming angled down (frame 3)
    .addr sprite_16 ; CPU address $b2fe - player aiming straight up
    .addr sprite_17 ; CPU address $b30e - player prone
    .addr sprite_18 ; CPU address $b31f - water splash/puddle (shown after sprite_73)
    .addr sprite_19 ; CPU address $b328 - player in water
    .addr sprite_1a ; CPU address $b331 - player climbing out of water
    .addr sprite_1b ; CPU address $b33a - player in water aiming straight up
    .addr sprite_1c ; CPU address $b34a - player in water aiming angled up
    .addr sprite_1d ; CPU address $b356 - player in water aiming forward
    .addr sprite_1e ; CPU address $b366 - default bullet
    .addr sprite_1f ; CPU address $b369 - M bullet
    .addr sprite_20 ; CPU address $b36c - S bullet, mortar
    .addr sprite_21 ; CPU address $b36f - boss turret bullet
    .addr sprite_22 ; CPU address $b372 - F bullet and snow field level boss ufo bomb
    .addr sprite_23 ; CPU address $b375 - L bullet (up)
    .addr sprite_24 ; CPU address $b378 - L bullet
    .addr sprite_25 ; CPU address $b381 - L bullet (angled)
    .addr sprite_26 ; CPU address $b384 - soldier crouched shooting
    .addr sprite_27 ; CPU address $b395 - soldier running 1
    .addr sprite_28 ; CPU address $b3a6 - soldier running 2
    .addr sprite_29 ; CPU address $b3b2 - soldier shooting angled up
    .addr sprite_2a ; CPU address $b3c3 - hangar mine cart (frame 1)
    .addr sprite_2b ; CPU address $b3dc - hangar mine cart (frame 2)
    .addr sprite_2c ; CPU address $b3e8 - soldier shooting
    .addr sprite_2d ; CPU address $b3fd - soldier shooting angled down
    .addr sprite_2e ; CPU address $b412 - unknown (doesn't seem to be used)
    .addr sprite_2f ; CPU address $b423 - S weapon item
    .addr sprite_30 ; CPU address $b430 - B weapon item
    .addr sprite_31 ; CPU address $b438 - F weapon item
    .addr sprite_32 ; CPU address $b440 - L weapon item
    .addr sprite_33 ; CPU address $b448 - R weapon item
    .addr sprite_34 ; CPU address $b450 - M weapon item
    .addr sprite_35 ; CPU address $b458 - big explosion
    .addr sprite_36 ; CPU address $b479 - explosion
    .addr sprite_37 ; CPU address $b48e - small explosion
    .addr sprite_38 ; CPU address $b497 - round explosion
    .addr sprite_39 ; CPU address $b4b0 - thick explosion ring
    .addr sprite_3a ; CPU address $b4d1 - wide explosion ring
    .addr sprite_3b ; CPU address $b4f2 - soldier running
    .addr sprite_3c ; CPU address $b503 - soldier running
    .addr sprite_3d ; CPU address $b514 - soldier running
    .addr sprite_3e ; CPU address $b525 - soldier running
    .addr sprite_3f ; CPU address $b531 - soldier running
    .addr sprite_40 ; CPU address $b53d - soldier shooting
    .addr sprite_41 ; CPU address $b54d - soldier shooting downward
    .addr sprite_42 ; CPU address $b562 - soldier shooting up angled
    .addr sprite_43 ; CPU address $b572 - rifle man shooting
    .addr sprite_44 ; CPU address $b582 - rifle man behind bush (frame 1)
    .addr sprite_45 ; CPU address $b587 - rifle man behind bush (frame 2)
    .addr sprite_46 ; CPU address $b594 - rifle man behind bush (frame 3)
    .addr sprite_47 ; CPU address $b598 - small ring explosion
    .addr sprite_48 ; CPU address $b59b - floating rock (waterfall level)
    .addr sprite_49 ; CPU address $b5b8 - bridge fire (waterfall level)
    .addr sprite_4a ; CPU address $b5c1 - boulder (waterfall level)
    .addr sprite_4b ; CPU address $b5da - scuba soldier hiding
    .addr sprite_4c ; CPU address $b5e3 - scuba soldier out of water shooting up
    .addr sprite_4d ; CPU address $b5f0 - weapon zeppelin
    .addr sprite_4e ; CPU address $b5fd - flashing falcon weapon
    .addr sprite_4f ; CPU address $b605 - unused blank sprite
    .addr sprite_50 ; CPU address $b606 - indoor player facing up
    .addr sprite_51 ; CPU address $b623 - indoor player strafing (frame 1)
    .addr sprite_52 ; CPU address $b633 - indoor player strafing (frame 2)
    .addr sprite_53 ; CPU address $b643 - indoor player strafing (frame 3)
    .addr sprite_54 ; CPU address $b653 - indoor player crouch
    .addr sprite_55 ; CPU address $b670 - indoor player electrocuted
    .addr sprite_56 ; CPU address $b691 - indoor player lying dead
    .addr sprite_57 ; CPU address $b6b2 - indoor player running
    .addr sprite_58 ; CPU address $b6cb - indoor player running
    .addr sprite_59 ; CPU address $b6e4 - unused blank sprite
    .addr sprite_59 ; CPU address $b6e4 - unused blank sprite
    .addr sprite_59 ; CPU address $b6e4 - unused blank sprite
    .addr sprite_59 ; CPU address $b6e4 - unused blank sprite
    .addr sprite_5d ; CPU address $b6e5 - boss eye
    .addr sprite_5e ; CPU address $b706 - boss eye
    .addr sprite_5f ; CPU address $b71a - boss eye
    .addr sprite_60 ; CPU address $b72e - boss eye
    .addr sprite_61 ; CPU address $b742 - boss eye
    .addr sprite_62 ; CPU address $b74e - boss eye
    .addr sprite_63 ; CPU address $b756 - small boss eye projectile (unused)
    .addr sprite_64 ; CPU address $b75f - boss eye projectile
    .addr sprite_65 ; CPU address $b780 - unused blank sprite
    .addr sprite_65 ; CPU address $b780 - unused blank sprite
    .addr sprite_65 ; CPU address $b780 - unused blank sprite
    .addr sprite_68 ; CPU address $b781 - base 2 boss metal helmet (Godomuga) (frame 1)
    .addr sprite_69 ; CPU address $b7a2 - base 2 boss metal helmet (Godomuga) (frame 2)
    .addr sprite_6a ; CPU address $b7be - base 2 boss metal helmet (Godomuga) (frame 3)
    .addr sprite_6b ; CPU address $b7d2 - base 2 boss metal helmet (Godomuga) (frame 4)
    .addr sprite_6c ; CPU address $b7de - base 2 boss metal helmet (Godomuga) (frame 5)
    .addr sprite_6d ; CPU address $b7ea - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_6e ; CPU address $b7f3 - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_6f ; CPU address $b7fc - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_70 ; CPU address $b7ff - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_71 ; CPU address $b808 - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_72 ; CPU address $b811 - base 2 boss metal helmet (Godomuga) bubble projectile
    .addr sprite_73 ; CPU address $b814 - water splash
    .addr sprite_74 ; CPU address $b81d - ice grenade
    .addr sprite_75 ; CPU address $b826 - ice grenade
    .addr sprite_76 ; CPU address $b82f - ice grenade
    .addr sprite_77 ; CPU address $b838 - ice grenade (vertical)
    .addr sprite_78 ; CPU address $b841 - !(UNUSED) duplicate of sprite_74 (ice grenade lean right), unused in game
    .addr sprite_79 ; CPU address $b84a - dragon boss projectile
    .addr sprite_7a ; CPU address $b853 - dragon arm interior orb (gray)
    .addr sprite_7b ; CPU address $b85c - dragon arm hand orb (red)
    .addr sprite_7c ; CPU address $b865 - snow field boss mini UFO
    .addr sprite_7d ; CPU address $b872 - snow field boss mini UFO
    .addr sprite_7e ; CPU address $b87f - snow field boss mini UFO
    .addr sprite_7f ; CPU address $b88c - unknown (doesn't seem to be used)

sprite_ptr_tbl_1:
    .addr sprite_80 ; (offset 00) CPU address $b88c - unknown (doesn't seem to be used)
    .addr sprite_81 ; (offset 01) CPU address $b895 - unknown (doesn't seem to be used)
    .addr sprite_82 ; (offset 02) CPU address $b89e - l bullet indoor level
    .addr sprite_83 ; (offset 03) CPU address $b8a3 - l bullet indoor level
    .addr sprite_84 ; (offset 04) CPU address $b8a8 - l bullet indoor level
    .addr sprite_85 ; (offset 05) CPU address $b8ad - base boss level 4 blue soldier
    .addr sprite_86 ; (offset 06) CPU address $b8c2 - base boss level 4 blue soldier
    .addr sprite_87 ; (offset 07) CPU address $b8d3 - base boss level 4 blue soldier
    .addr sprite_88 ; (offset 08) CPU address $b8e0 - base boss level 4 blue soldier facing out (frame 1)
    .addr sprite_89 ; (offset 09) CPU address $b8f1 - base boss level 4 blue soldier facing out (frame 2)
    .addr sprite_8a ; (offset 0a) CPU address $b902 - base boss level 4 blue soldier flying (frame 1)
    .addr sprite_8b ; (offset 0b) CPU address $b917 - base boss level 4 blue soldier flying (frame 2)
    .addr sprite_8c ; (offset 0c) CPU address $b934 - base boss level 4 base 2 red soldier
    .addr sprite_8d ; (offset 0d) CPU address $b93c - base boss level 4 base 2 red soldier
    .addr sprite_8e ; (offset 0e) CPU address $b944 - base boss level 4 base 2 red soldier
    .addr sprite_8f ; (offset 0f) CPU address $b94c - base boss level 4 base 2 red soldier facing player
                    ; Probotector uses sprite_88 rather than separately defining a sprite_8f
    .addr sprite_90 ; (offset 10) CPU address $b954 - base boss level 4 base 2 red soldier facing player with weapon
    .addr sprite_91 ; (offset 11) CPU address $b965 - indoor boss defeated elevator with player on top
    .addr sprite_92 ; (offset 12) CPU address $b975 - l bullet indoor level
    .addr sprite_93 ; (offset 13) CPU address $b97a - jumping man
    .addr sprite_94 ; (offset 14) CPU address $b98b - jumping man
    .addr sprite_95 ; (offset 15) CPU address $b99c - jumping man
    .addr sprite_96 ; (offset 16) CPU address $b9ad - indoor soldier hit by bullet (indoor soldier, jumping man, grenade launcher, group of four soldiers)
    .addr sprite_97 ; (offset 17) CPU address $b9be - jumping man in air
    .addr sprite_98 ; (offset 18) CPU address $b9d3 - jumping man facing player
    .addr sprite_99 ; (offset 19) CPU address $b9e0 - small indoor rolling grenade
    .addr sprite_9a ; (offset 1a) CPU address $b9e9 - closer indoor rolling grenade
    .addr sprite_9b ; (offset 1b) CPU address $b9f2 - even closer indoor rolling grenade
    .addr sprite_9c ; (offset 1c) CPU address $b9ff - closest indoor rolling grenade
    .addr sprite_9d ; (offset 1d) CPU address $ba0c - indoor base enemy kill explosion (frame 1)
    .addr sprite_9e ; (offset 1e) CPU address $ba0f - indoor base enemy kill explosion (frame 2)
    .addr sprite_9f ; (offset 1f) CPU address $ba18 - indoor base enemy kill explosion (frame 3)
    .addr sprite_a0 ; (offset 20) CPU address $ba21 - indoor hand grenade
    .addr sprite_a1 ; (offset 21) CPU address $ba2a - indoor hand grenade
    .addr sprite_a2 ; (offset 22) CPU address $ba2f - indoor hand grenade
    .addr sprite_a3 ; (offset 23) CPU address $ba32 - indoor hand grenade
    .addr sprite_a4 ; (offset 24) CPU address $ba37 - indoor hand grenade
    .addr sprite_a5 ; (offset 25) CPU address $ba3c - indoor hand grenade
    .addr sprite_a6 ; (offset 26) CPU address $ba41 - indoor hand grenade
    .addr sprite_a7 ; (offset 27) CPU address $ba44 - indoor hand grenade
    .addr sprite_a8 ; (offset 28) CPU address $ba49 - indoor hand grenade
    .addr sprite_a9 ; (offset 29) CPU address $ba4c - indoor hand grenade
    .addr sprite_aa ; (offset 2a) CPU address $ba50 - falcon (player select icon)
    .addr sprite_ab ; (offset 2b) CPU address $ba59 - Bill and Lance's hair and shirt (for Probotector - red splash behind Probotector title)
    .addr sprite_ac ; (offset 2c) CPU address $bab2 - alien's lair bundle (crustacean-like alien)
    .addr sprite_ad ; (offset 2d) CPU address $bacb - alien's lair bundle (crustacean-like alien) mouth open
    .addr sprite_ae ; (offset 2e) CPU address $bad7 - alien's lair bundle (crustacean-like alien)
    .addr sprite_af ; (offset 2f) CPU address $baf0 - alien's lair bundle (crustacean-like alien)
    .addr sprite_b0 ; (offset 30) CPU address $bafc - poisonous insect gel
    .addr sprite_b1 ; (offset 31) CPU address $bb05 - poisonous insect gel (frame 1)
    .addr sprite_b2 ; (offset 32) CPU address $bb0e - poisonous insect gel (frame 2)
    .addr sprite_b3 ; (offset 33) CPU address $bb17 - boss alien bugger insect/spider (frame 1)
    .addr sprite_b4 ; (offset 34) CPU address $bb30 - boss alien bugger insect/spider (frame 2)
    .addr sprite_b5 ; (offset 35) CPU address $bb51 - boss alien bugger insect/spider (frame 3)
    .addr sprite_b6 ; (offset 36) CPU address $bb6e - boss alien eggron (alien egg)
    .addr sprite_b7 ; (offset 37) CPU address $bb77 - energy zone boss giant armored soldier gordea
    .addr sprite_b7 ; (offset 38) CPU address $bb77 - energy zone boss giant armored soldier gordea (sprite_b8)
    .addr sprite_b9 ; (offset 39) CPU address $bbd0 - energy zone boss giant armored soldier gordea (legs together)
    .addr sprite_ba ; (offset 3a) CPU address $bc19 - energy zone boss giant armored soldier gordea (running, jumping)
    .addr sprite_bb ; (offset 3b) CPU address $bc45 - energy zone boss projectile (spiked disk)
    .addr sprite_bc ; (offset 3c) CPU address $bc4e - energy zone boss projectile (spiked disk)
    .addr sprite_bd ; (offset 3d) CPU address $bc57 - turret man (basquez)
    .addr sprite_be ; (offset 3e) CPU address $bc74 - turret man (basquez)
    .addr sprite_bf ; (offset 3f) CPU address $bc91 - energy zone wall fire
    .addr sprite_c0 ; (offset 40) CPU address $bc96 - energy zone wall fire
    .addr sprite_c1 ; (offset 41) CPU address $bc9b - energy zone ceiling fire
    .addr sprite_c2 ; (offset 42) CPU address $bca0 - energy zone ceiling fire
    .addr sprite_c3 ; (offset 43) CPU address $bca5 - energy zone boss giant armored soldier gordea (throwing)
    .addr sprite_c4 ; (offset 44) CPU address $bccd - snow field ground separator
    .addr sprite_c5 ; (offset 45) CPU address $bcd2 - green helicopter ending scene (frame 1)
    .addr sprite_c6 ; (offset 46) CPU address $bcdb - green helicopter ending scene (frame 2)
    .addr sprite_c7 ; (offset 47) CPU address $bce8 - green helicopter ending scene (frame 3)
    .addr sprite_c8 ; (offset 48) CPU address $bcf1 - green helicopter ending scene (frame 4)
    .addr sprite_c9 ; (offset 49) CPU address $bcfe - green helicopter facing forward (frame 1)
    .addr sprite_ca ; (offset 4a) CPU address $bd13 - green helicopter facing forward (frame 2)
    .addr sprite_cb ; (offset 4b) CPU address $bd30 - green helicopter facing forward (frame 3)
    .addr sprite_cc ; (offset 4c) CPU address $bd59 - green helicopter facing forward (frame 4)
    .addr sprite_cd ; (offset 4d) CPU address $bd7e - green helicopter facing forward (frame 5)
    .addr sprite_ce ; (offset 4e) CPU address $bdab - green helicopter facing forward (frame 6)
    .addr sprite_cf ; (offset 4f) CPU address $bdd0 - ending sequence mountains

; each sprite entry is defined as follows
; first byte (n) is number of tiles for sprite
; followed by n 4-byte groups
; each 4-byte group defines a block that is 2 tiles tall (8x16 pixels)
; * byte 0: Y position in pixels (relative to sprite base position (SPRITE_Y_POS), can be negative)
; * byte 1: pattern table tile index/code
;   * if even, tile is pulled from 0x0000 (sprite section) (left pattern table)
;   * if odd, tile is pulled from 0x1000 (background section) (right pattern table)
;   * one byte is for both tiles (8x16)
;     * 1st tile is byte specified
;     * 2nd tile is (byte + 1), i.e. the tile immediately after the one specified
; * byte 2: palette code, flipping, drawing priority (foreground or background)
;     * x... .... - Vertical flip
;     * .x.. .... - Horizontal flip
;     * ..x. .... - Drawing priority (whether to draw behind background or not)
;     * .... ..xx - Palette code
; * byte 3: X position in pixels (relative to sprite position (SPRITE_X_POS), can be negative)

; EXCEPTIONS
; if first byte of sprite sequence is #$fe (e.g. sprite_07), then the sprite is considered a "small sprite"
; in this case, the sprite is made of a single entry. The entire byte sequence is 3 bytes long (including #$fe)
; the second byte is the pattern table tile, and the third byte is the sprite attributes
; the X position is set to #$fc (-4 decimal) and the Y position is set to #$f8 (-8 decimal).

; if the first byte of a group sequence is #$80 (shared sprite), then the next two bytes are a CPU address to continue reading at.
; this address is then read to get the sprite CPU read address.
; this allows sprites to share parts of each other

; blank
sprite_01:
    .byte $00

; player walking (frame 1)
sprite_02:
.ifdef Probotector
    .byte $05
    .byte $ee,$28,$00,$fa
    .byte $ee,$2a,$00,$02
.else
    .byte $05
    .byte $ee,$28,$01,$fb
    .byte $ee,$2a,$01,$03
.endif

; no sprite code, only part of other sprite codes
player_walking_1_bottom:
.ifdef Probotector
    .byte $fe,$34,$00,$f6
    .byte $fe,$36,$00,$fe
    .byte $0e,$3e,$00,$f8
.else
    .byte $fe,$34,$00,$f8
    .byte $fe,$36,$00,$00
    .byte $0e,$40,$00,$f8
.endif

; player walking (frame 2)
sprite_03:
.ifdef Probotector
    .byte $05
    .byte $ef,$2c,$00,$fa
    .byte $ef,$2e,$00,$02
.else
    .byte $05
    .byte $ef,$2c,$01,$fc
    .byte $ef,$2e,$01,$04
.endif

; no sprite code, only part of other sprite codes
player_walking_2_bottom:
.ifdef Probotector
    .byte $ff,$38,$00,$f5
    .byte $ff,$3a,$00,$fd
    .byte $09,$40,$00,$02
.else
    .byte $fd,$38,$00,$f8
    .byte $fd,$3a,$00,$00
    .byte $0d,$42,$00,$04
.endif

; player walking (frame 3)
sprite_04:
.ifdef Probotector
    .byte $04
    .byte $ee,$30,$00,$f8
    .byte $ee,$32,$00,$00
.else
    .byte $05
    .byte $ee,$30,$01,$fa
    .byte $ee,$32,$01,$02
.endif

; no sprite code, only part of other sprite codes
player_bottom:
.ifdef Probotector
    .byte $fe,$3c,$00,$fb
    .byte $0e,$42,$00,$fb
.else
    .byte $fe,$3c,$00,$f7
    .byte $fe,$3e,$00,$ff
    .byte $0e,$42,$00,$fe
.endif

; player walking (frame 4)
; player falling through floor, or walk off ledge
sprite_05:
.ifdef Probotector
    .byte $05
    .byte $ee,$30,$00,$f8
    .byte $ee,$32,$00,$00
    .byte $80
    .addr player_walking_1_bottom
.else
    .byte $05
    .byte $ee,$30,$01,$fa
    .byte $ee,$32,$01,$02
    .byte $80
    .addr player_walking_1_bottom
.endif

; player walking (frame 5)
sprite_06:
.ifdef Probotector
    .byte $04
    .byte $ee,$28,$00,$fa
    .byte $ee,$2a,$00,$02
    .byte $80
    .addr player_bottom
.else
    .byte $05
    .byte $ee,$28,$01,$fb
    .byte $ee,$2a,$01,$03
    .byte $80
    .addr player_bottom
.endif

; enemy bullet (snow field)
sprite_07:
    .byte $fe,$ec,$02

; player curled up (frame 1)
sprite_08:
.ifdef Probotector
    .byte $02
    .byte $f8,$44,$00,$f8
    .byte $f8,$46,$00,$00
.else
    .byte $04
    .byte $f2,$44,$01,$f8
    .byte $f2,$48,$01,$00
    .byte $02,$46,$00,$f8
    .byte $02,$4a,$00,$00
.endif

; player curled up (frame 2)
sprite_09:
.ifdef Probotector
    .byte $02
    .byte $f7,$48,$00,$f8
    .byte $f7,$4a,$00,$00
.else
    .byte $03
    .byte $f8,$4c,$00,$f6
    .byte $f8,$4e,$01,$fe
    .byte $f8,$50,$01,$06
.endif

; player hit (frame 1)
sprite_0a:
.ifdef Probotector
    .byte $04
    .byte $f0,$68,$00,$f7
    .byte $00,$6c,$00,$f9
    .byte $f0,$6a,$00,$ff
    .byte $00,$6e,$00,$01
.else
    .byte $04
    .byte $f3,$68,$01,$f6
    .byte $03,$6a,$00,$f6
    .byte $f7,$6c,$00,$fe
    .byte $f7,$6e,$00,$06
.endif

; player hit (frame 2)
sprite_0b:
.ifdef Probotector
    .byte $03
    .byte $f9,$70,$00,$f5
    .byte $fb,$72,$00,$fd
    .byte $f7,$74,$00,$05
.else
    .byte $04
    .byte $f9,$70,$00,$f8
    .byte $fa,$74,$00,$ff
    .byte $ea,$72,$00,$fc
    .byte $ff,$76,$01,$fa
.endif

; player lying on ground
sprite_0c:
.ifdef Probotector
    .byte $04
    .byte $00,$78,$00,$f0
    .byte $07,$7a,$00,$f8
    .byte $01,$7c,$00,$00
    .byte $08,$7e,$00,$08
.else
    .byte $04
    .byte $00,$78,$01,$f0
    .byte $00,$7a,$01,$f8
    .byte $00,$7c,$00,$00
    .byte $00,$7e,$00,$08
.endif

; player walking holding weapon out (frame 1)
sprite_0d:
.ifdef Probotector
    .byte $06
    .byte $ee,$94,$00,$f8
    .byte $ee,$96,$00,$00
    .byte $ee,$98,$00,$08
    .byte $80
    .addr player_walking_1_bottom
.else
    .byte $06
    .byte $ee,$94,$01,$f9
    .byte $ee,$96,$01,$01
    .byte $ee,$98,$01,$09
    .byte $80
    .addr player_walking_1_bottom
.endif

; player walking holding weapon out (frame 2)
sprite_0e:
.ifdef Probotector
    .byte $06
    .byte $ed,$94,$00,$f8
    .byte $ed,$96,$00,$00
    .byte $ed,$98,$00,$08
    .byte $80
    .addr player_walking_2_bottom
.else
    .byte $06
    .byte $ef,$94,$01,$f9
    .byte $ef,$96,$01,$01
    .byte $ef,$98,$01,$09
    .byte $80
    .addr player_walking_2_bottom
.endif

; player walking holding weapon out (frame 3)
sprite_0f:
.ifdef Probotector
    .byte $05
.else
    .byte $06
.endif

player_facing_side:
.ifdef Probotector
    .byte $ee,$94,$00,$f8
    .byte $ee,$96,$00,$00
    .byte $ee,$98,$00,$08
.else
    .byte $ee,$94,$01,$f9
    .byte $ee,$96,$01,$01
    .byte $ee,$98,$01,$09
.endif
    .byte $80
    .addr player_bottom

; player aiming angled up (frame 1)
sprite_10:
.ifdef Probotector
    .byte $05
    .byte $ee,$8c,$00,$fa
    .byte $ee,$8e,$00,$02
    .byte $80
    .addr player_walking_1_bottom
.else
    .byte $05
    .byte $ee,$8c,$01,$fb
    .byte $ee,$8e,$01,$03
    .byte $80
    .addr player_walking_1_bottom
.endif

; player aiming angled up (frame 2)
sprite_11:
.ifdef Probotector
    .byte $05
    .byte $ed,$8c,$00,$fa
    .byte $ed,$8e,$00,$02
    .byte $80
    .addr player_walking_2_bottom
.else
    .byte $05
    .byte $ef,$8c,$01,$fb
    .byte $ef,$8e,$01,$03
    .byte $80
    .addr player_walking_2_bottom
.endif

; player aiming angled up (frame 3)
sprite_12:
.ifdef Probotector
    .byte $04
    .byte $ee,$8c,$00,$fa
    .byte $ee,$8e,$00,$02
    .byte $80
    .addr player_bottom
.else
    .byte $05
    .byte $ee,$8c,$01,$fb
    .byte $ee,$8e,$01,$03
    .byte $80
    .addr player_bottom
.endif

; player aiming angled down (frame 1)
sprite_13:
.ifdef Probotector
    .byte $06
    .byte $ee,$86,$00,$f7
    .byte $ee,$88,$00,$ff
    .byte $fe,$8a,$00,$03
    .byte $80
    .addr player_walking_1_bottom
.else
    .byte $06
    .byte $ee,$86,$01,$f8
    .byte $ee,$88,$01,$00
    .byte $f3,$8a,$01,$05
    .byte $80
    .addr player_walking_1_bottom
.endif

; player aiming angled down (frame 2)
sprite_14:
.ifdef Probotector
    .byte $06
    .byte $ed,$86,$00,$f7
    .byte $ed,$88,$00,$ff
    .byte $fd,$8a,$00,$03
    .byte $80
    .addr player_walking_2_bottom
.else
    .byte $06
    .byte $ef,$86,$01,$f8
    .byte $ef,$88,$01,$00
    .byte $f4,$8a,$01,$05
    .byte $80
    .addr player_walking_2_bottom
.endif

; player aiming angled down (frame 3)
sprite_15:
.ifdef Probotector
    .byte $05
    .byte $ee,$86,$00,$f7
    .byte $ee,$88,$00,$ff
    .byte $fe,$8a,$00,$03
    .byte $80
    .addr player_bottom
.else
    .byte $06
    .byte $ee,$86,$01,$f8
    .byte $ee,$88,$01,$00
    .byte $f3,$8a,$01,$05
    .byte $80
    .addr player_bottom
.endif

; player aiming straight up
sprite_16:
.ifdef Probotector
    .byte $05
    .byte $de,$82,$00,$00
    .byte $ee,$80,$00,$f8
    .byte $ee,$84,$00,$00
    .byte $80
    .addr player_bottom
.else
    .byte $06
    .byte $de,$82,$01,$01
    .byte $ee,$80,$01,$f9
    .byte $ee,$84,$01,$01
    .byte $80
    .addr player_bottom
.endif

; player prone
sprite_17:
.ifdef Probotector
    .byte $04
    .byte $ff,$9c,$00,$f0
    .byte $00,$9e,$00,$f8
    .byte $00,$a0,$00,$00
    .byte $00,$a2,$00,$08
.else
    .byte $04
    .byte $00,$9c,$00,$f0
    .byte $00,$9e,$00,$f8
    .byte $00,$a0,$01,$00
    .byte $00,$a2,$01,$08
.endif

; water splash/puddle
sprite_18:
    .byte $02

water_splash:
.ifdef Probotector
    .byte $fa,$dc,$00,$f8
    .byte $fa,$dc,$40,$00
.else
    .byte $fa,$dc,$01,$f8
    .byte $fa,$dc,$41,$00
.endif

; player in water
sprite_19:
.ifdef Probotector
    .byte $02
    .byte $f2,$de,$00,$fa
    .byte $f2,$e0,$00,$02
.else
    .byte $02
    .byte $f2,$de,$01,$f8
    .byte $f2,$e0,$01,$00
.endif

; player climbing out of water
sprite_1a:
.ifdef Probotector
    .byte $03
    .byte $f9,$e2,$00,$f7
    .byte $f7,$e4,$00,$ff
    .byte $f5,$e8,$00,$07
.else
    .byte $02
    .byte $fa,$e2,$01,$f8
    .byte $fa,$e4,$01,$00
.endif

; player in water aiming straight up
sprite_1b:
.ifdef Probotector
    .byte $05
    .byte $df,$82,$00,$00
    .byte $ef,$80,$00,$f8
    .byte $ef,$84,$00,$00

water_splash_00:
    .byte $fa,$f8,$00,$f8
    .byte $fa,$fa,$40,$00
.else
    .byte $05
    .byte $df,$82,$01,$01
    .byte $ef,$80,$01,$f9
    .byte $ef,$84,$01,$01
    .byte $80
    .addr water_splash
.endif

; player in water aiming angled up
sprite_1c:
.ifdef Probotector
    .byte $04
    .byte $ef,$8c,$00,$fa
    .byte $ef,$8e,$00,$02
    .byte $80
    .addr water_splash_00
.else
    .byte $04
    .byte $ef,$8c,$01,$fb
    .byte $ef,$8e,$01,$03
    .byte $80
    .addr water_splash
.endif

; player in water aiming forward
sprite_1d:
.ifdef Probotector
    .byte $05
    .byte $ef,$94,$00,$f8
    .byte $ef,$96,$00,$00
    .byte $ef,$98,$00,$08
    .byte $80
    .addr water_splash_00
.else
    .byte $05
    .byte $ef,$94,$01,$f9
    .byte $ef,$96,$01,$01
    .byte $ef,$98,$01,$09
    .byte $80
    .addr water_splash
.endif

; default bullet
sprite_1e:
    .byte $fe,$0e,$02

; M bullet
sprite_1f:
    .byte $fe,$10,$02

; S bullet, mortar
sprite_20:
    .byte $fe,$12,$02

; boss turret bullet
sprite_21:
    .byte $fe,$14,$02

; F bullet and snow field level boss ufo bomb
sprite_22:
    .byte $fe,$16,$02

; L bullet (up)
sprite_23:
    .byte $fe,$18,$02

; L bullet
sprite_24:
    .byte $02
    .byte $f8,$92,$02,$f4
    .byte $f8,$92,$02,$fc

; L bullet (angled)
sprite_25:
    .byte $fe,$90,$02

; soldier crouching shooting
sprite_26:
.ifdef Probotector
    .byte $03
    .byte $01,$dc,$43,04
    .byte $00,$de,$43,$fc
    .byte $fb,$e0,$43,$f4
.else
    .byte $04
    .byte $00,$dc,$03,$f0
    .byte $00,$de,$01,$f8
    .byte $00,$e0,$01,$00
    .byte $00,$e2,$03,$08
.endif

; soldier running 1
sprite_27:
.ifdef Probotector
sprite_28:
    .byte $04
    .byte $ee,$be,$43,$01
    .byte $f0,$c6,$43,$f9
.else
    .byte $04
    .byte $f0,$d6,$01,$f8
    .byte $f0,$d8,$01,$00
.endif

soldier_bottom_0:
.ifdef Probotector
    .byte $00,$c8,$43,$00
    .byte $00,$ca,$43,$f8
.else
    .byte $00,$ce,$03,$f8
    .byte $00,$cc,$03,$00
.endif

; soldier running 2
.ifdef Probotector
.else
sprite_28:
    .byte $04
    .byte $f0,$be,$01,$f8
    .byte $f0,$c0,$01,$00
    .byte $80
    .addr soldier_bottom_0
.endif

; soldier shooting angled up
sprite_29:
.ifdef Probotector
    .byte $05
    .byte $f0,$ae,$01,$f8
    .byte $f0,$b0,$01,$00
    .byte $e0,$b2,$01,$01
    .byte $00,$ba,$01,$f8
    .byte $00,$bc,$01,$00
.else
    .byte $04
    .byte $f0,$ae,$01,$f8
    .byte $f0,$b0,$01,$00
    .byte $00,$ba,$01,$f8
    .byte $00,$bc,$01,$00
.endif

; hangar mine cart (frame 1)
sprite_2a:
    .byte $06

hangar_mine_cart:
    .byte $f6,$e4,$02,$f0
    .byte $f6,$e6,$02,$f8
    .byte $f6,$e8,$02,$00
    .byte $f6,$fc,$02,$08
    .byte $04,$ea,$00,$f9 ; wheel
    .byte $04,$ea,$00,$05 ; wheel

; hangar mine cart (frame 2)
sprite_2b:
    .byte $06
    .byte $04,$ec,$00,$f9
    .byte $04,$ec,$00,$05
    .byte $80
    .addr hangar_mine_cart

; sniper type #$04 shooting (boss rifle man), compare sprite_43
sprite_2c:
.ifdef Probotector
    .byte $05
    .byte $f0,$f2,$41,$f8
    .byte $f0,$b6,$41,$00
    .byte $f0,$b8,$01,$08
    .byte $00,$f4,$41,$f8
    .byte $00,$bc,$01,$00
.else
    .byte $05
    .byte $f0,$f2,$41,$f8
    .byte $f0,$b6,$01,$00
    .byte $f0,$b8,$01,$08
    .byte $00,$f4,$41,$f8
    .byte $00,$bc,$01,$00
.endif

; soldier shooting angled down
sprite_2d:
.ifdef Probotector
    .byte $05
    .byte $e2,$aa,$01,$00
    .byte $f2,$ac,$01,$00
    .byte $f0,$f6,$41,$f8
    .byte $00,$bc,$01,$00
    .byte $00,$f4,$41,$f8
.else
    .byte $05
    .byte $f0,$f6,$41,$f8
    .byte $f0,$aa,$01,$00
    .byte $f8,$ac,$01,$08
    .byte $00,$f4,$41,$f8
    .byte $00,$bc,$01,$00
.endif

; unknown (doesn't seem to be used)
sprite_2e:
.ifdef Probotector
    .byte $04
    .byte $f0,$fa,$01,$f8
    .byte $f0,$f8,$01,$00
    .byte $00,$f4,$01,$f8
    .byte $00,$fc,$01,$00
.else
    .byte $04
    .byte $f0,$fa,$41,$f8
    .byte $f0,$f8,$41,$00
    .byte $00,$f4,$41,$f8
    .byte $00,$fc,$41,$00
.endif

; S weapon item
sprite_2f:
.ifdef Probotector
    .byte $03
    .byte $f8,$1c,$03,$fc
.else
    .byte $03
    .byte $f8,$1c,$01,$fc
.endif

weapon_wings:
.ifdef Probotector
    .byte $f8,$1a,$03,$f4
    .byte $f8,$1a,$43,$04
.else
    .byte $f8,$1a,$01,$f4
    .byte $f8,$1a,$41,$04
.endif

; B weapon item
sprite_30:
.ifdef Probotector
    .byte $03
    .byte $f8,$1e,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$1e,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; F weapon item
sprite_31:
.ifdef Probotector
    .byte $03
    .byte $f8,$20,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$20,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; L weapon item
sprite_32:
.ifdef Probotector
    .byte $03
    .byte $f8,$22,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$22,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; R weapon item
sprite_33:
.ifdef Probotector
    .byte $03
    .byte $f8,$24,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$24,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; M weapon item
sprite_34:
.ifdef Probotector
    .byte $03
    .byte $f8,$26,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$26,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; big explosion
sprite_35:
    .byte $08
    .byte $f0,$54,$02,$f0
    .byte $f0,$56,$02,$f8
    .byte $f0,$58,$02,$00
    .byte $f0,$5a,$02,$08
    .byte $00,$5a,$c2,$f0
    .byte $00,$58,$c2,$f8
    .byte $00,$56,$c2,$00
    .byte $00,$54,$c2,$08

; explosion
sprite_36:
    .byte $05
    .byte $f0,$56,$02,$fc
    .byte $f0,$5a,$02,$04
    .byte $f8,$52,$02,$f4
    .byte $00,$56,$c2,$fc
    .byte $00,$54,$c2,$04

; small explosion
sprite_37:
    .byte $02
    .byte $f8,$52,$82,$f8
    .byte $f4,$5a,$02,$00

; round explosion
sprite_38:
    .byte $06
    .byte $f0,$5e,$02,$f8
    .byte $f0,$5e,$42,$00
    .byte $f8,$5c,$02,$f0
    .byte $f8,$5c,$c2,$08
    .byte $00,$5e,$82,$f8
    .byte $00,$5e,$c2,$00

; thick explosion ring
sprite_39:
    .byte $08
    .byte $f0,$60,$02,$f0
    .byte $f0,$62,$02,$f8
    .byte $f0,$62,$42,$00
    .byte $f0,$60,$42,$08
    .byte $00,$60,$82,$f0
    .byte $00,$62,$82,$f8
    .byte $00,$62,$c2,$00
    .byte $00,$60,$c2,$08

; wide explosion ring
sprite_3a:
    .byte $08
    .byte $f0,$64,$02,$f0
    .byte $f0,$66,$02,$f8
    .byte $f0,$66,$42,$00
    .byte $f0,$64,$42,$08
    .byte $00,$64,$82,$f0
    .byte $00,$66,$82,$f8
    .byte $00,$66,$c2,$00
    .byte $00,$64,$c2,$08

; soldier running
sprite_3b:
.ifdef Probotector
sprite_3f:
    .byte $04
    .byte $ef,$be,$43,$01
    .byte $f0,$c0,$43,$f9
    .byte $07,$c4,$43,$01
    .byte $00,$c2,$43,$f9
.else
    .byte $04
    .byte $f0,$be,$01,$f8
    .byte $f0,$c0,$01,$00

soldier_bottom_1:
    .byte $00,$ca,$03,$f8
    .byte $00,$cc,$03,$00
.endif

; soldier running
sprite_3c:
.ifdef Probotector
    .byte $04
    .byte $ee,$be,$43,$01
    .byte $f0,$c6,$43,$f9
    .byte $00,$c8,$43,$00
    .byte $00,$ca,$43,$f8
.else
    .byte $04
    .byte $f0,$c2,$01,$f8
    .byte $f0,$c4,$01,$00
    .byte $00,$ce,$03,$f8
    .byte $00,$d0,$03,$00
.endif

; soldier running
sprite_3d:
.ifdef Probotector
sprite_3e:
    .byte $05
    .byte $e7,$cc,$43,$f9
    .byte $ef,$be,$43,$01
    .byte $f7,$ce,$43,$fa
    .byte $00,$d0,$43,$02
    .byte $07,$d2,$43,$f9
.else
    .byte $04
    .byte $f0,$c6,$01,$f8
    .byte $f0,$c8,$01,$00

soldier_bottom_3:
    .byte $00,$d2,$03,$f8
    .byte $00,$d4,$03,$00
.endif

.ifdef Probotector
.else
sprite_3e:
    .byte $04
    .byte $f0,$be,$01,$f8
    .byte $f0,$c0,$01,$00
    .byte $80
    .addr soldier_bottom_3
.endif

.ifdef Probotector
.else
sprite_3f:
    .byte $04
    .byte $f0,$c6,$01,$f8
    .byte $f0,$c8,$01,$00
    .byte $80
    .addr soldier_bottom_1
.endif

; soldier running
sprite_40:
.ifdef Probotector
    .byte $05
    .byte $ed,$d4,$43,$02
    .byte $ee,$d6,$43,$fa
    .byte $f4,$d8,$43,$f7
    .byte $00,$da,$43,$f9
    .byte $07,$c4,$43,$01
.else
    .byte $05
    .byte $f0,$d6,$01,$f8
    .byte $f0,$d8,$01,$00
    .byte $f0,$da,$03,$08
    .byte $80
    .addr soldier_bottom_3
.endif

; soldier shooting downward
sprite_41:
.ifdef Probotector
    .byte $05
    .byte $f0,$a8,$01,$f8
    .byte $e2,$aa,$01,$00
    .byte $f2,$ac,$01,$00
.else
    .byte $05
    .byte $f0,$a8,$01,$f8
    .byte $f0,$aa,$01,$00
    .byte $f8,$ac,$01,$08
.endif

soldier_bottom_2:
    .byte $00,$ba,$01,$f8
    .byte $00,$bc,$01,$00

; soldier shooting up angled
sprite_42:
.ifdef Probotector
    .byte $05
    .byte $f0,$ae,$01,$f8
    .byte $f0,$b0,$01,$00
    .byte $e0,$b2,$01,$01
    .byte $80
    .addr soldier_bottom_2
.else
    .byte $05
    .byte $f0,$ae,$01,$f8
    .byte $f0,$b0,$01,$00
    .byte $e0,$b2,$01,$02
    .byte $80
    .addr soldier_bottom_2
.endif

; rifle man shooting (sniper type #$00 and #$01)
sprite_43:
    .byte $05

rifle_man_top:
    .byte $f0,$b4,$01,$f8
    .byte $f0,$b6,$01,$00
    .byte $f0,$b8,$01,$08
    .byte $80
    .addr soldier_bottom_2

; rifle man behind bush (frame 1)
sprite_44:
.ifdef Probotector
    .byte $02
    .byte $f0,$ec,$41,$f8
    .byte $f0,$ea,$41,$00
.else
    .byte $01
    .byte $f0,$ea,$41,$fc
.endif

; rifle man behind bush (frame 2)
sprite_45:
.ifdef Probotector
    .byte $02
    .byte $f0,$f0,$41,$f8
    .byte $f0,$ee,$41,$00
.else
    .byte $03
    .byte $f0,$f0,$41,$f8
    .byte $f0,$ee,$41,$00
    .byte $f0,$ec,$41,$08
.endif

; rifle man behind bush (frame 3)
; by specifying #$03 entries, only top half of soldier is drawn
; soldier_bottom_2 isn't used
sprite_46:
.ifdef Probotector
    .byte $03
    .byte $f0,$b4,$01,$f8
    .byte $f0,$b6,$01,$00
    .byte $f0,$b8,$01,$08
.else
    .byte $03
    .byte $80
    .addr rifle_man_top
.endif

; small ring explosion
sprite_47:
    .byte $fe,$0c,$02

; floating rock (waterfall level)
sprite_48:
.ifdef Probotector
    .byte $07
    .byte $f0,$ee,$00,$f0
    .byte $f0,$f0,$00,$f8
    .byte $f0,$f0,$40,$00
    .byte $f0,$ee,$40,$08
    .byte $00,$f2,$00,$f4
    .byte $00,$fc,$00,$fc
    .byte $00,$f2,$40,$04
.else
    .byte $07
    .byte $f0,$ee,$03,$f0
    .byte $f0,$f0,$03,$f8
    .byte $f0,$f0,$43,$00
    .byte $f0,$ee,$43,$08
    .byte $00,$f2,$03,$f4
    .byte $00,$fc,$03,$fc
    .byte $00,$f2,$43,$04
.endif

; bridge fire (waterfall level)
sprite_49:
    .byte $02
    .byte $f8,$ea,$02,$f8
    .byte $f8,$ec,$02,$00

; boulder (waterfall level)
sprite_4a:
.ifdef Probotector
    .byte $06
    .byte $f0,$e6,$00,$f4
    .byte $f0,$e8,$00,$fc
    .byte $f0,$d7,$00,$04
    .byte $00,$d9,$00,$f4
    .byte $00,$db,$00,$fc
    .byte $00,$dd,$00,$04
.else
    .byte $06
    .byte $f0,$e6,$03,$f4
    .byte $f0,$e8,$03,$fc
    .byte $f0,$d7,$03,$04
    .byte $00,$d9,$03,$f4
    .byte $00,$db,$03,$fc
    .byte $00,$dd,$03,$04
.endif

; scuba soldier hiding
sprite_4b:
.ifdef Probotector
    .byte $02
    .byte $f8,$dc,$03,$f8
    .byte $f8,$de,$03,$00
.else
    .byte $02
    .byte $f8,$dc,$01,$f8
    .byte $f8,$de,$01,$00
.endif

; scuba soldier out of water shooting up
sprite_4c:
.ifdef Probotector
    .byte $03
    .byte $e9,$e2,$03,$00
    .byte $f5,$e0,$03,$f9
    .byte $f9,$e4,$03,$00
.else
    .byte $03
    .byte $e8,$e2,$03,$00
    .byte $f8,$e0,$01,$f8
    .byte $f8,$e4,$01,$00
.endif

; weapon zeppelin
sprite_4d:
.ifdef Probotector
    .byte $03
    .byte $f8,$a4,$03,$f4
    .byte $f8,$a6,$03,$fc
    .byte $f8,$a4,$43,$04
.else
    .byte $03
    .byte $f8,$a4,$01,$f4
    .byte $f8,$a6,$01,$fc
    .byte $f8,$a4,$41,$04
.endif

; flashing falcon weapon
sprite_4e:
.ifdef Probotector
    .byte $03
    .byte $f8,$00,$03,$fc
    .byte $80
    .addr weapon_wings
.else
    .byte $03
    .byte $f8,$00,$01,$fc
    .byte $80
    .addr weapon_wings
.endif

; unused blank sprite
sprite_4f:
    .byte $00

; indoor player facing up
sprite_50:
.ifdef Probotector
    .byte $07
    .byte $de,$7c,$00,$fa
    .byte $ee,$7e,$00,$f8
    .byte $ee,$80,$00,$00
    .byte $fe,$78,$00,$f7
    .byte $fe,$78,$40,$ff
    .byte $0e,$7a,$00,$f7
    .byte $0e,$7a,$40,$ff
.else
    .byte $07
    .byte $de,$7c,$01,$fa
    .byte $ee,$7e,$01,$f8
    .byte $ee,$80,$01,$00
    .byte $fe,$78,$00,$f8
    .byte $fe,$78,$40,$ff
    .byte $0e,$7a,$00,$f6
    .byte $0e,$7a,$40,$01
.endif

; indoor player strafing (frame 1)
sprite_51:
.ifdef Probotector
    .byte $05
    .byte $de,$7c,$00,$fb
    .byte $ee,$8c,$00,$f8
    .byte $ee,$8e,$00,$00
    .byte $80
    .addr player_walking_1_bottom
.else
    .byte $05
    .byte $de,$7c,$01,$fb
    .byte $ee,$8c,$01,$fa
    .byte $ee,$8e,$01,$02
    .byte $80
    .addr player_walking_1_bottom
.endif

; indoor player strafing (frame 2)
sprite_52:
.ifdef Probotector
    .byte $06
    .byte $df,$7c,$00,$fb
    .byte $ef,$8c,$00,$f8
    .byte $ef,$8e,$00,$00
    .byte $80
    .addr player_walking_2_bottom
.else
    .byte $06
    .byte $df,$7c,$01,$fb
    .byte $ef,$8c,$01,$fa
    .byte $ef,$8e,$01,$02
    .byte $80
    .addr player_walking_2_bottom
.endif

; indoor player strafing (frame 3)
sprite_53:
.ifdef Probotector
    .byte $05
    .byte $de,$7c,$00,$fb
    .byte $ee,$8c,$00,$f8
    .byte $ee,$8e,$00,$00
    .byte $80
    .addr player_bottom
.else
    .byte $06
    .byte $de,$7c,$01,$fb
    .byte $ee,$8c,$01,$fa
    .byte $ee,$8e,$01,$02
    .byte $80
    .addr player_bottom
.endif

; indoor player crouch
sprite_54:
.ifdef Probotector
    .byte $05
    .byte $f4,$82,$00,$f8
    .byte $f4,$84,$00,$00
    .byte $04,$86,$00,$f4
    .byte $04,$86,$40,$04
    .byte $04,$88,$00,$fc
.else
    .byte $07
    .byte $f4,$82,$01,$f8
    .byte $f4,$84,$01,$00
    .byte $0a,$86,$00,$f4
    .byte $0a,$86,$40,$04
    .byte $04,$88,$00,$f8
    .byte $04,$88,$40,$00
    .byte $fa,$8a,$00,$fc
.endif

; indoor player electrocuted
; indoor player hit by bullet frame #$01
sprite_55:
.ifdef Probotector
    .byte $08
    .byte $e0,$76,$00,$f8
    .byte $ea,$74,$00,$00
    .byte $f0,$72,$00,$fc
    .byte $f4,$70,$00,$f4
    .byte $00,$78,$00,$f7
    .byte $00,$78,$40,$ff
    .byte $10,$7a,$00,$f7
    .byte $10,$7a,$40,$ff
.else
    .byte $08
    .byte $e2,$70,$01,$01
    .byte $f5,$72,$01,$f0
    .byte $ed,$74,$01,$f8
    .byte $ed,$76,$01,$00
    .byte $fd,$78,$00,$f8
    .byte $fd,$78,$40,$ff
    .byte $0d,$7a,$00,$f6
    .byte $0d,$7a,$40,$01
.endif

; indoor player lying dead (frame #$02)
sprite_56:
.ifdef Probotector
    .byte $06
    .byte $ec,$68,$00,$f4
    .byte $ec,$68,$40,$04
    .byte $fc,$6a,$00,$f4
    .byte $fc,$6c,$00,$fc
    .byte $fc,$6e,$00,$04
    .byte $0c,$8a,$00,$00
.else
    .byte $08
    .byte $fa,$68,$00,$f0
    .byte $fa,$6a,$00,$f8
    .byte $fa,$6a,$40,$00
    .byte $fa,$68,$40,$08
    .byte $0a,$6c,$01,$f0
    .byte $0a,$6e,$01,$f8
    .byte $0a,$6e,$41,$00
    .byte $0a,$6c,$41,$08
.endif

; indoor player running
sprite_57:
.ifdef Probotector
    .byte $06
    .byte $f1,$94,$00,$f6
    .byte $f0,$96,$00,$fc
    .byte $ea,$98,$00,$02
    .byte $00,$90,$00,$f8
    .byte $00,$92,$00,$00
    .byte $10,$be,$00,$fc
.else
    .byte $06
    .byte $f4,$94,$01,$f4
    .byte $ef,$96,$01,$fc
    .byte $ef,$98,$01,$04
    .byte $ff,$be,$00,$f8
    .byte $ff,$90,$00,$00
    .byte $0f,$92,$00,$00
.endif

; indoor player running
sprite_58:
.ifdef Probotector
    .byte $06
    .byte $f0,$9a,$00,$f5
    .byte $f0,$9c,$00,$fd
    .byte $ed,$9e,$00,$00
    .byte $00,$92,$40,$f5
    .byte $00,$90,$40,$fd
    .byte $10,$be,$40,$f9
.else
    .byte $06
    .byte $f1,$9a,$01,$f4
    .byte $f1,$9c,$01,$fc
    .byte $f2,$9e,$01,$04
    .byte $01,$90,$40,$fa
    .byte $01,$be,$40,$02
    .byte $11,$92,$40,$fa
.endif

; unused blank sprite
sprite_59:
    .byte $00

; boss eye
sprite_5d:
    .byte $08
    .byte $fe,$a6,$02,$f8
    .byte $fe,$a6,$42,$00
    .byte $fe,$9e,$03,$f8
    .byte $fe,$9e,$43,$00

boss_eye_top:
    .byte $ee,$9a,$03,$f8
    .byte $ee,$9a,$43,$00
    .byte $f6,$9c,$03,$f0
    .byte $f6,$9c,$43,$08

; boss eye
sprite_5e:
    .byte $08
    .byte $fe,$a6,$02,$f8
    .byte $fe,$a6,$42,$00
    .byte $fe,$a0,$03,$f8
    .byte $fe,$a0,$43,$00
    .byte $80
    .addr boss_eye_top

; boss eye
sprite_5f:
    .byte $08

boss_eye_part:
    .byte $f6,$a8,$02,$f0
    .byte $f6,$a8,$42,$08
    .byte $fe,$a2,$03,$f8
    .byte $fe,$a2,$43,$00
    .byte $80
    .addr boss_eye_top

; boss eye
sprite_60:
    .byte $08
    .byte $fe,$aa,$02,$f8
    .byte $fe,$aa,$42,$00

boss_eye_int:
    .byte $fe,$a4,$03,$f8
    .byte $fe,$a4,$43,$00
    .byte $80
    .addr boss_eye_top

; boss eye
sprite_61:
    .byte $08
    .byte $fe,$ac,$02,$f8
    .byte $fe,$ac,$42,$00
    .byte $80
    .addr boss_eye_int

; boss eye
sprite_62:
    .byte $09
    .byte $fe,$ae,$02,$fc
    .byte $80
    .addr boss_eye_part

; small boss eye projectile (unused)
sprite_63:
.ifdef Probotector
    .byte $02
    .byte $f8,$b0,$02,$f8
    .byte $f8,$b2,$02,$00
.else
    .byte $02
    .byte $f8,$b0,$03,$f8
    .byte $f8,$b2,$03,$00
.endif

; boss eye projectile
sprite_64:
.ifdef Probotector
    .byte $08
    .byte $f0,$b4,$02,$f0
    .byte $f0,$b6,$02,$f8
    .byte $f0,$b8,$02,$00
    .byte $f0,$ba,$02,$08
    .byte $00,$bc,$02,$f0
    .byte $00,$be,$02,$f8
    .byte $00,$c0,$02,$00
    .byte $00,$c2,$02,$08
.else
    .byte $08
    .byte $f0,$b4,$03,$f0
    .byte $f0,$b6,$03,$f8
    .byte $f0,$b8,$03,$00
    .byte $f0,$ba,$03,$08
    .byte $00,$bc,$03,$f0
    .byte $00,$be,$03,$f8
    .byte $00,$c0,$03,$00
    .byte $00,$c2,$03,$08
.endif

; unused blank sprite
sprite_65:
    .byte $00

; base 2 boss metal helmet (Godomuga) (frame 1)
sprite_68:
    .byte $08
    .byte $f0,$dc,$03,$f8
    .byte $f0,$dc,$43,$00
    .byte $00,$d2,$03,$f8
    .byte $00,$d2,$43,$00
    .byte $00,$d0,$03,$f0
    .byte $00,$d0,$43,$08

metal_helmet_ears:
    .byte $f0,$da,$03,$f0
    .byte $f0,$da,$43,$08

; base 2 boss metal helmet (Godomuga) (frame 2)
sprite_69:
    .byte $08
    .byte $f0,$de,$03,$f8
    .byte $f0,$de,$43,$00

metal_helmet_part:
    .byte $00,$d6,$03,$f8
    .byte $00,$d6,$43,$00

metal_helmet_mouth:
    .byte $00,$d4,$03,$f0
    .byte $00,$d4,$43,$08
    .byte $80
    .addr metal_helmet_ears

; base 2 boss metal helmet (Godomuga) (frame 3)
sprite_6a:
    .byte $08
    .byte $f0,$e0,$03,$f8
    .byte $f0,$e0,$43,$00

metal_helmet_mouth_inside:
    .byte $00,$d8,$03,$f8
    .byte $00,$d8,$43,$00
    .byte $80
    .addr metal_helmet_mouth

; base 2 boss metal helmet (Godomuga) (frame 4)
sprite_6b:
    .byte $08
    .byte $f0,$e2,$02,$f8
    .byte $f0,$e2,$42,$00
    .byte $80
    .addr metal_helmet_part

; base 2 boss metal helmet (Godomuga) (frame 5)
sprite_6c:
    .byte $08
    .byte $f0,$e4,$02,$f8
    .byte $f0,$e4,$42,$00
    .byte $80
    .addr metal_helmet_mouth_inside

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_6d:
    .byte $02
    .byte $f8,$e8,$03,$f8
    .byte $f8,$e6,$02,$fe

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_6e:
    .byte $02
    .byte $f8,$ec,$03,$fa
    .byte $f8,$ea,$02,$01

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_6f:
    .byte $fe,$ec,$03

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_70:
    .byte $02
    .byte $f8,$ea,$42,$f7
    .byte $f8,$ec,$43,$fe

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_71:
    .byte $02
    .byte $f8,$e6,$42,$fa
    .byte $f8,$e8,$43,$00

; base 2 boss metal helmet (Godomuga) bubble projectile
sprite_72:
    .byte $fe,$ec,$02

; water splash
sprite_73:
    .byte $02
    .byte $f8,$e6,$00,$f8
    .byte $f8,$e6,$40,$00

; ice grenade lean right
sprite_74:
    .byte $02
    .byte $f8,$e6,$00,$f8
    .byte $f8,$e6,$c0,$00

; ice grenade horizontal
sprite_75:
    .byte $02
    .byte $f8,$e8,$00,$f8
    .byte $f8,$e8,$40,$00

; ice grenade tipping downward
sprite_76:
    .byte $02
    .byte $f8,$e6,$80,$f8
    .byte $f8,$e6,$40,$00

; ice grenade vertical
sprite_77:
    .byte $02
    .byte $f8,$ea,$80,$f8
    .byte $f8,$ea,$40,$00

; !(UNUSED) duplicate of sprite_74 (ice grenade lean right), unused in game
sprite_78:
    .byte $02
    .byte $f8,$e6,$00,$f8
    .byte $f8,$e6,$c0,$00

; dragon boss projectile
sprite_79:
    .byte $02
    .byte $f8,$f4,$02,$f8
    .byte $f8,$f6,$02,$00

; dragon arm interior orb (gray)
sprite_7a:
    .byte $02
    .byte $f8,$f8,$03,$f8
    .byte $f8,$f8,$43,$00

; dragon arm hand orb (red)
sprite_7b:
    .byte $02
    .byte $f8,$fa,$01,$f8
    .byte $f8,$fa,$41,$00

; snow field boss mini UFO
sprite_7c:
.ifdef Probotector
    .byte $03
    .byte $f8,$fc,$02,$f4
    .byte $f8,$33,$02,$fc
    .byte $f8,$35,$02,$04
.else
    .byte $03
    .byte $f8,$fc,$03,$f4
    .byte $f8,$33,$03,$fc
    .byte $f8,$35,$03,$04
.endif

; snow field boss mini UFO
sprite_7d:
.ifdef Probotector
    .byte $03
    .byte $f8,$37,$02,$f4
    .byte $f8,$39,$02,$fc
    .byte $f8,$3b,$02,$04
.else
    .byte $03
    .byte $f8,$37,$03,$f4
    .byte $f8,$39,$03,$fc
    .byte $f8,$3b,$03,$04
.endif

; snow field boss mini UFO
sprite_7e:
.ifdef Probotector
    .byte $03
    .byte $f8,$3d,$02,$f4
    .byte $f8,$3f,$02,$fc
    .byte $f8,$41,$02,$04
.else
    .byte $03
    .byte $f8,$3d,$03,$f4
    .byte $f8,$3f,$03,$fc
    .byte $f8,$41,$03,$04
.endif

; unknown (doesn't seem to be used)
sprite_7f:
sprite_80:
    .byte $02
    .byte $f8,$ca,$02,$f8
    .byte $f8,$ca,$42,$00

; unknown (doesn't seem to be used)
sprite_81:
    .byte $02
    .byte $f8,$cc,$02,$f8
    .byte $f8,$cc,$42,$00

; l bullet indoor level shot from
;  * 27%-43% horizontal portion of the playable screen
;  * 58%-70% horizontal portion of the playable screen
sprite_82:
    .byte $01
    .byte $f8,$a2,$02,$fc

; l bullet indoor level shot from
;  * 20%-27% horizontal portion of the playable screen
;  * 70%-80% horizontal portion of the playable screen
; same as sprite_92
sprite_83:
    .byte $01
    .byte $f8,$a0,$02,$fc

; l bullet indoor level shot from
;  * 10%-20% horizontal portion of the playable screen
;  * 80%-90% horizontal portion of the playable screen
sprite_84:
    .byte $01
    .byte $f8,$a2,$02,$fc

; base 2 boss blue soldier
sprite_85:
.ifdef Probotector
    .byte $04
    .byte $f0,$fa,$00,$01
.else
    .byte $05
    .byte $f0,$f2,$03,$08
.endif

base_2_soldier_part:
.ifdef Probotector
    .byte $f0,$c4,$00,$f9
    .byte $00,$c8,$00,$f6
    .byte $00,$ca,$00,$fe
.else
    .byte $f0,$ee,$03,$f8
    .byte $f0,$f0,$03,$00
    .byte $00,$f4,$03,$f6
    .byte $00,$f6,$03,$fe
.endif

; base 2 boss blue soldier
sprite_86:
.ifdef Probotector
    .byte $05
    .byte $f5,$fc,$00,$00
.else
    .byte $04
.endif

base_2_soldier_bottom:
.ifdef Probotector
    .byte $e8,$cc,$00,$f8
    .byte $f8,$ce,$00,$f2
    .byte $f8,$ee,$00,$fa
    .byte $05,$f2,$00,$04
.else
    .byte $e8,$f8,$03,$fe
    .byte $f8,$fa,$03,$f6
    .byte $f8,$ce,$03,$fe
    .byte $08,$dd,$03,$03
.endif

; base 2 boss blue soldier
sprite_87:
.ifdef Probotector
    .byte $03
    .byte $f4,$dd,$00,$f8
base_2_soldier_bottom_2:
    .byte $f4,$f6,$00,$00
    .byte $04,$f8,$00,$fb
.else
    .byte $03

base_2_soldier_bottom_2:
    .byte $f0,$df,$03,$f8
    .byte $f0,$e1,$03,$00
    .byte $00,$e3,$03,$fc
.endif

; base 2 blue soldier facing out (frame 1)
.ifdef Probotector
sprite_8f:
.endif
sprite_88:
    .byte $04

blue_soldier_facing_out:
.ifdef Probotector
    .byte $f0,$e5,$00,$f9
    .byte $f0,$e5,$40,$00
    .byte $00,$e7,$00,$f9
    .byte $00,$e7,$40,$00
.else
    .byte $f0,$e5,$43,$f9
    .byte $f0,$e5,$03,$00
    .byte $00,$e7,$43,$f9
    .byte $00,$e7,$03,$00
.endif

; base 2 blue soldier facing out (frame 2)
sprite_89:
.ifdef Probotector
    .byte $04
    .byte $f0,$e9,$00,$f9
    .byte $f0,$e9,$40,$00
    .byte $00,$eb,$00,$f9
    .byte $00,$eb,$40,$00
.else
    .byte $04
    .byte $f0,$e9,$43,$f9
    .byte $f0,$e9,$03,$00
    .byte $00,$eb,$43,$f9
    .byte $00,$eb,$03,$00
.endif

; base 2 blue soldier flying (frame 1)
sprite_8a:
.ifdef Probotector
    .byte $05
    .byte $f0,$ed,$00,$f5
    .byte $f0,$ef,$00,$fd
    .byte $f0,$ed,$40,$04
    .byte $00,$f1,$00,$f8
    .byte $00,$f3,$00,$00
.else
    .byte $05
    .byte $f0,$ed,$03,$f4
    .byte $f0,$ef,$03,$fc
    .byte $f0,$ed,$43,$04
    .byte $00,$f1,$03,$f8
    .byte $00,$f3,$03,$00
.endif

; base 2 blue soldier flying (frame 2)
sprite_8b:
.ifdef Probotector
    .byte $07
    .byte $f2,$f5,$00,$f4
    .byte $f2,$f7,$00,$fc
    .byte $f2,$f5,$40,$04
    .byte $02,$f9,$00,$f8
    .byte $02,$fb,$00,$00
    .byte $0f,$b0,$00,$f6
    .byte $12,$b2,$00,$fe
.else
    .byte $07
    .byte $f2,$f5,$03,$f4
    .byte $f2,$f7,$03,$fc
    .byte $f2,$f5,$43,$04
    .byte $02,$f9,$03,$f8
    .byte $02,$fb,$03,$00
    .byte $12,$b0,$03,$f7
    .byte $12,$b2,$03,$00
.endif

; base boss level 4 base 2 red soldier
sprite_8c:
.ifdef Probotector
    .byte $04
    .byte $f0,$c6,$00,$01
    .byte $80
    .addr base_2_soldier_part
.else
    .byte $05
    .byte $f0,$fc,$02,$08
    .byte $80
    .addr base_2_soldier_part
.endif

; base boss level 4 base 2 red soldier
sprite_8d:
.ifdef Probotector
    .byte $05
    .byte $f5,$f0,$00,$00
    .byte $80
    .addr base_2_soldier_bottom
.else
    .byte $05
    .byte $f8,$a6,$02,$04
    .byte $80
    .addr base_2_soldier_bottom
.endif

; base boss level 4 base 2 red soldier
sprite_8e:
.ifdef Probotector
    .byte $03
    .byte $f4,$f4,$00,$f8
    .byte $80
    .addr base_2_soldier_bottom_2
.else
    .byte $04
    .byte $ff,$c4,$02,$00
    .byte $80
    .addr base_2_soldier_bottom_2
.endif

; base boss level 4 base 2 red soldier facing player
.ifdef Probotector
; Probotector uses sprite_88 instead separately defining sprite_8f
.else
sprite_8f:
    .byte $05
    .byte $00,$c6,$02,$f4
    .byte $80
    .addr blue_soldier_facing_out
.endif

; base boss level 4 base 2 red soldier facing player with weapon
sprite_90:
.ifdef Probotector
    .byte $04
    .byte $f4,$df,$00,$f9
    .byte $f5,$e1,$00,$00
    .byte $05,$e3,$00,$f8
    .byte $05,$e3,$40,$00
.else
    .byte $04
    .byte $f0,$c8,$42,$f9
    .byte $f0,$c8,$02,$00
    .byte $00,$ca,$02,$f8
    .byte $00,$cc,$02,$00
.endif

; indoor boss defeated elevator with player on top
sprite_91:
.ifdef Probotector
    .byte $08
    .byte $0e,$fd,$02,$f4
    .byte $0e,$fd,$02,$fc
    .byte $0e,$fd,$02,$04
    .byte $80
    .addr player_facing_side
.else
    .byte $08
    .byte $0c,$fd,$02,$f4
    .byte $0c,$fd,$02,$fc
    .byte $0c,$fd,$02,$04
    .byte $80
    .addr player_facing_side
.endif

; l bullet indoor level shot from
;  * <= 10% horizontal portion of the playable screen
;  * >= 90% horizontal portion of the playable screen
; same as sprite_83
sprite_92:
    .byte $01
    .byte $f8,$a0,$02,$fc

; jumping man
sprite_93:
.ifdef Probotector
    .byte $03
    .byte $f0,$a8,$01,$01
    .byte $f5,$aa,$01,$fb
    .byte $05,$ac,$01,$fb
.else
    .byte $04
    .byte $eb,$ce,$01,$ff
    .byte $ec,$a8,$03,$fb
    .byte $fc,$aa,$03,$f6
    .byte $fb,$ac,$03,$fe
.endif

; jumping man
sprite_94:
.ifdef Probotector
    .byte $04
    .byte $ef,$a8,$01,$01
    .byte $f4,$ae,$01,$f9
    .byte $00,$b2,$01,$00
    .byte $04,$b0,$01,$f8
.else
    .byte $04
    .byte $ed,$ae,$01,$fe
    .byte $ed,$b0,$03,$fb
    .byte $fd,$b2,$03,$f7
    .byte $fd,$b4,$03,$ff
.endif

; jumping man
sprite_95:
.ifdef Probotector
    .byte $04
    .byte $f0,$a8,$01,$01
    .byte $f5,$b4,$01,$f9
    .byte $00,$b8,$01,$01
    .byte $05,$b6,$01,$f9
.else
    .byte $04
    .byte $ed,$b6,$01,$ff
    .byte $ed,$b8,$03,$fb
    .byte $fd,$ba,$03,$f4
    .byte $fd,$bc,$03,$fc
.endif

; indoor soldier hit by bullet sprite
; indoor soldier, jumping man, grenade launcher, group of four soldiers firing at player
sprite_96:
.ifdef Probotector
    .byte $03
    .byte $f0,$ba,$01,$f8
    .byte $f0,$ba,$41,$00
    .byte $00,$bc,$01,$fc
.else
    .byte $04
    .byte $eb,$da,$01,$ff
    .byte $ed,$c0,$03,$fc
    .byte $fd,$c2,$43,$f9
    .byte $fd,$c2,$03,$00
.endif

; jumping man in air
sprite_97:
.ifdef Probotector
    .byte $03
    .byte $eb,$d2,$01,$03
    .byte $f2,$d0,$01,$fb
    .byte $02,$d4,$01,$fb
.else
    .byte $05
    .byte $e8,$d0,$01,$fa
    .byte $e8,$d2,$03,$fc
    .byte $f8,$d4,$03,$f4
    .byte $f8,$d6,$03,$fc
    .byte $f8,$d8,$03,$04
.endif

; jumping man facing player
sprite_98:
.ifdef Probotector
    .byte $03
    .byte $fb,$c2,$01,$ff
    .byte $fc,$c0,$01,$f8
    .byte $0b,$ce,$01,$fc
.else
    .byte $03
    .byte $f0,$da,$01,$ff
    .byte $fc,$dc,$03,$fb
    .byte $00,$de,$03,$03
.endif

; small indoor rolling grenade
sprite_99:
.ifdef Probotector
    .byte $02
    .byte $fe,$e0,$03,$f8
    .byte $fe,$e0,$43,$00
.else
    .byte $02
    .byte $fe,$e0,$01,$f8
    .byte $fe,$e0,$41,$00
.endif

; closer indoor rolling grenade
sprite_9a:
.ifdef Probotector
    .byte $02
    .byte $fe,$e2,$03,$f8
    .byte $fe,$e2,$43,$00
.else
    .byte $02
    .byte $fe,$e2,$01,$f8
    .byte $fe,$e2,$41,$00
.endif

; even closer indoor rolling grenade
sprite_9b:
.ifdef Probotector
    .byte $03
    .byte $fd,$e4,$03,$f4
    .byte $fd,$e6,$03,$fc
    .byte $fd,$e4,$43,$04
.else
    .byte $03
    .byte $fd,$e4,$01,$f4
    .byte $fd,$e6,$01,$fc
    .byte $fd,$e4,$41,$04
.endif

; closest indoor rolling grenade
sprite_9c:
.ifdef Probotector
    .byte $03
    .byte $fc,$e8,$03,$f4
    .byte $fc,$ea,$43,$fc
    .byte $fc,$e8,$43,$04
.else
    .byte $03
    .byte $fc,$e8,$01,$f4
    .byte $fc,$ea,$41,$fc
    .byte $fc,$e8,$41,$04
.endif

; indoor base enemy kill explosion (frame 1)
sprite_9d:
    .byte $fe,$c8,$02

; indoor base enemy kill explosion (frame 2)
sprite_9e:
    .byte $02
    .byte $f8,$ca,$02,$f8
    .byte $f8,$ca,$c2,$00

; indoor base enemy kill explosion (frame 3)
sprite_9f:
    .byte $02
    .byte $f8,$cc,$02,$f8
    .byte $f8,$cc,$c2,$00

; indoor hand grenade
sprite_a0:
.ifdef Probotector
    .byte $02
    .byte $f8,$ec,$03,$f8
    .byte $f8,$ee,$03,$00
.else
    .byte $02
    .byte $f8,$ec,$01,$f8
    .byte $f8,$ee,$01,$00
.endif

; indoor hand grenade
sprite_a1:
.ifdef Probotector
    .byte $01
    .byte $f8,$f0,$03,$fd
.else
    .byte $01
    .byte $f8,$f0,$01,$fd
.endif

; indoor hand grenade
sprite_a2:
.ifdef Probotector
    .byte $fe,$f2,$03
.else
    .byte $fe,$f2,$01
.endif

; indoor hand grenade
sprite_a3:
.ifdef Probotector
    .byte $01
    .byte $f8,$f4,$03,$fb
.else
    .byte $01
    .byte $f8,$f4,$01,$fb
.endif

; indoor hand grenade
sprite_a4:
.ifdef Probotector
    .byte $01
    .byte $f8,$f6,$03,$fd
.else
    .byte $01
    .byte $f8,$f6,$01,$fd
.endif

; indoor hand grenade
sprite_a5:
.ifdef Probotector
    .byte $01
    .byte $f8,$f8,$03,$fd
.else
    .byte $01
    .byte $f8,$f8,$01,$fd
.endif

; indoor hand grenade
sprite_a6:
.ifdef Probotector
    .byte $fe,$fa,$03
.else
    .byte $fe,$fa,$01
.endif

; indoor hand grenade
sprite_a7:
.ifdef Probotector
    .byte $01
    .byte $f8,$fc,$03,$fd
.else
    .byte $01
    .byte $f8,$fc,$01,$fd
.endif

; indoor hand grenade
sprite_a8:
.ifdef Probotector
    .byte $fe,$c4,$03
.else
    .byte $fe,$c4,$01
.endif

; indoor hand grenade
sprite_a9:
.ifdef Probotector
    .byte $fe,$c6,$03,$00
.else
    .byte $fe,$c6,$01,$00
.endif

; falcon (player select icon)
sprite_aa:
    .byte $02
    .byte $f8,$ce,$01,$f8
    .byte $f8,$d0,$01,$00

; Bill and Lance's hair and shirt
; For Probotector - red splash behind Probotector title
sprite_ab:
.ifdef Probotector
    .byte $13
    .byte $e3,$de,$00,$c0
    .byte $d4,$e0,$00,$cf
    .byte $d1,$e2,$00,$de
    .byte $d7,$e4,$00,$e6
    .byte $d4,$e0,$00,$f3
    .byte $d3,$e6,$00,$1e
    .byte $d3,$e6,$00,$40
    .byte $d4,$e0,$00,$48
    .byte $e0,$e8,$00,$5e
    .byte $e9,$ea,$00,$65
    .byte $f9,$ec,$00,$63
    .byte $00,$f0,$00,$38
    .byte $f0,$ee,$00,$28
    .byte $00,$fc,$00,$f6
    .byte $08,$fa,$00,$e7
    .byte $0d,$f8,$00,$df
    .byte $0c,$f6,$00,$d0
    .byte $0d,$f4,$00,$c8
    .byte $00,$f2,$00,$ab
.else
    .byte $16
    .byte $00,$da,$01,$00
    .byte $00,$de,$01,$08
    .byte $00,$e2,$01,$10
    .byte $10,$dc,$02,$00
    .byte $10,$e0,$02,$08
    .byte $10,$e4,$02,$10
    .byte $20,$ea,$00,$05
    .byte $20,$f4,$00,$15
    .byte $30,$ec,$00,$05
    .byte $30,$f6,$00,$15
    .byte $40,$ee,$00,$05
    .byte $40,$f8,$00,$15
    .byte $fd,$d6,$02,$f8
    .byte $02,$d4,$02,$f0
    .byte $04,$d2,$02,$e8
    .byte $0c,$d8,$02,$f8
    .byte $1f,$e6,$00,$f5
    .byte $1f,$e8,$00,$fd
    .byte $24,$f0,$00,$0d
    .byte $24,$fa,$00,$1d
    .byte $34,$f2,$00,$0d
    .byte $34,$fc,$00,$1d
.endif

; alien's lair bundle (crustacean-like alien)
sprite_ac:
    .byte $06

alien_bundle:
    .byte $00,$b0,$c2,$04
    .byte $00,$b2,$c2,$fc
    .byte $00,$b4,$c2,$f4
    .byte $f0,$b6,$c2,$04
    .byte $f0,$b8,$c2,$fc
    .byte $f0,$ba,$c2,$f4

; alien's lair bundle (crustacean-like alien) mouth open
sprite_ad:
    .byte $06
    .byte $f0,$ea,$c2,$fc
    .byte $f0,$ec,$c2,$f4
    .byte $80
    .addr alien_bundle

; alien's lair bundle (crustacean-like alien)
sprite_ae:
    .byte $06

alien_bundle_2:
    .byte $00,$f0,$c2,$04
    .byte $00,$f2,$c2,$fc
    .byte $00,$f4,$c2,$f4
    .byte $f0,$aa,$c2,$f4
    .byte $f0,$ac,$c2,$fc
    .byte $f0,$ae,$c2,$fc

; alien's lair bundle (crustacean-like alien)
sprite_af:
    .byte $06
    .byte $f0,$f6,$c2,$04
    .byte $f0,$a8,$c2,$fc
    .byte $80
    .addr alien_bundle_2

; alien pink blob
sprite_b0:
    .byte $02
    .byte $f8,$fa,$03,$f8
    .byte $f8,$fa,$43,$00

; small alien boss spider (poisonous insect gel) (frame 1)
sprite_b1:
    .byte $02
    .byte $f8,$fc,$03,$f8
    .byte $f8,$fc,$43,$00

; small alien boss spider (poisonous insect gel) (frame 2)
sprite_b2:
    .byte $02
    .byte $f8,$f8,$03,$f8
    .byte $f8,$f8,$43,$00

; boss alien bugger insect/spider (frame 1)
sprite_b3:
    .byte $06
    .byte $f0,$c0,$03,$f8
    .byte $f0,$c2,$03,$00
    .byte $00,$c4,$03,$f0
    .byte $00,$c6,$03,$f8
    .byte $00,$c8,$03,$00
    .byte $00,$ca,$03,$08

; boss alien bugger insect/spider (frame 2)
sprite_b4:
    .byte $08
    .byte $f1,$cc,$03,$f0
    .byte $f1,$ce,$03,$f8
    .byte $f1,$d0,$03,$00
    .byte $f1,$d2,$03,$08
    .byte $01,$d4,$03,$f0
    .byte $01,$d6,$03,$f8
    .byte $01,$d8,$03,$00
    .byte $01,$da,$03,$08

; boss alien bugger insect/spider (frame 3)
sprite_b5:
    .byte $07
    .byte $f0,$dc,$03,$f8
    .byte $f0,$de,$03,$00
    .byte $f0,$e0,$03,$08
    .byte $00,$e2,$03,$f0
    .byte $00,$e4,$03,$f8
    .byte $00,$e6,$03,$00
    .byte $00,$e8,$03,$08

; boss alien eggron (alien egg)
sprite_b6:
    .byte $02
    .byte $f8,$bc,$03,$f8
    .byte $f8,$be,$03,$00

; energy zone boss giant armored soldier
sprite_b7:
.ifdef Probotector
    .byte $13
.else
    .byte $16
.endif

giant_soldier_top:
.ifdef Probotector
    .byte $e7,$b0,$03,$e5
    .byte $e3,$b2,$03,$ed
    .byte $d8,$a8,$02,$f3
    .byte $d8,$aa,$02,$fb
    .byte $d8,$ac,$02,$03
    .byte $e8,$b4,$02,$f4
    .byte $d2,$ae,$02,$0b
    .byte $de,$ba,$03,$0c
    .byte $ee,$bc,$03,$0b
    .byte $e8,$b6,$02,$fc
    .byte $e8,$b8,$02,$04
.else
    .byte $d8,$dc,$02,$f0
    .byte $d8,$de,$02,$f8
    .byte $d8,$e0,$02,$00
    .byte $d8,$e2,$02,$08
    .byte $e4,$fd,$03,$e8
    .byte $e8,$e4,$03,$e0
    .byte $e8,$e6,$02,$f0
    .byte $e8,$e8,$02,$f8
    .byte $e8,$ea,$02,$00
    .byte $e7,$a8,$03,$06
    .byte $e7,$aa,$03,$0e
    .byte $f7,$b4,$03,$0b
.endif

giant_soldier_bottom:
.ifdef Probotector
    .byte $f8,$c0,$03,$f4
    .byte $fb,$be,$03,$ef
    .byte $08,$c6,$03,$f3
    .byte $0b,$c4,$03,$eb
    .byte $f8,$c2,$03,$02
    .byte $08,$c8,$03,$02
    .byte $04,$ca,$03,$0a
    .byte $08,$cc,$03,$0d
.else
    .byte $f8,$ac,$03,$e8
    .byte $f8,$ae,$03,$f0
    .byte $f8,$b0,$03,$f8
    .byte $f8,$b2,$03,$00
    .byte $08,$b8,$03,$e8
    .byte $08,$ba,$03,$f0
    .byte $08,$bc,$03,$f8
    .byte $08,$be,$03,$00
    .byte $08,$c0,$03,$08
    .byte $08,$c2,$03,$10
.endif

; energy zone boss giant armored soldier (legs together)
sprite_b9:
.ifdef Probotector
    .byte $0f
    .byte $e8,$b0,$03,$e5
    .byte $e4,$b2,$03,$ed
    .byte $d9,$a8,$02,$f3
    .byte $d9,$aa,$02,$fb
    .byte $d9,$ac,$02,$03
    .byte $e9,$b4,$02,$f4
    .byte $d3,$ae,$02,$0b
    .byte $df,$ba,$03,$0c
    .byte $ef,$bc,$03,$0b
    .byte $e9,$b6,$02,$fc
    .byte $e9,$b8,$02,$04
    .byte $f8,$ce,$03,$f8
    .byte $f8,$d0,$03,$00
    .byte $08,$d2,$03,$fb
    .byte $08,$d4,$03,$03
.else
    .byte $12
    .byte $f9,$d8,$03,$f0
    .byte $f9,$da,$03,$f8
    .byte $f9,$ff,$03,$00
    .byte $09,$b6,$03,$f0
    .byte $09,$07,$03,$f8
    .byte $09,$09,$03,$00
    .byte $da,$dc,$02,$f0
    .byte $da,$de,$02,$f8
    .byte $da,$e0,$02,$00
    .byte $da,$e2,$02,$08
    .byte $e6,$fd,$03,$e8
    .byte $ea,$e4,$03,$e0
    .byte $ea,$e6,$02,$f0
    .byte $ea,$e8,$02,$f8
    .byte $ea,$ea,$02,$00
    .byte $e9,$a8,$03,$06
    .byte $e9,$aa,$03,$0e
    .byte $f9,$b4,$03,$0b
.endif

; energy zone boss giant armored soldier (running, jumping)
sprite_ba:
.ifdef Probotector
    .byte $13
    .byte $e8,$09,$02,$fc
    .byte $e8,$0b,$02,$04
    .byte $f8,$9d,$03,$ec
    .byte $f8,$9f,$03,$f4
    .byte $f8,$d7,$03,$fc
    .byte $f8,$d9,$03,$04
    .byte $fc,$db,$03,$07
    .byte $08,$dd,$03,$f0
    .byte $08,$fd,$03,$f8
    .byte $09,$ff,$03,$05
    .byte $80
    .addr giant_soldier_top
.else
    .byte $15
    .byte $f8,$ca,$03,$e8
    .byte $f8,$cc,$03,$f0
    .byte $f8,$ce,$03,$f8
    .byte $f8,$d0,$03,$00
    .byte $f7,$d4,$03,$08
    .byte $f7,$d6,$03,$10
    .byte $08,$c4,$03,$d8
    .byte $08,$c6,$03,$e0
    .byte $08,$c8,$03,$e8
    .byte $08,$d2,$03,$00
    .byte $80
    .addr giant_soldier_top
.endif

; energy zone boss projectile (spiked disk)
sprite_bb:
    .byte $02
    .byte $f8,$df,$00,$f8
    .byte $f8,$df,$40,$00

; energy zone boss projectile (spiked disk)
sprite_bc:
    .byte $02
    .byte $f8,$fb,$00,$f8
    .byte $f8,$fb,$40,$00

; mounted soldier (basquez)
sprite_bd:
.ifdef Probotector
    .byte $07
    .byte $f4,$ee,$01,$f0
    .byte $f4,$f0,$01,$f8
    .byte $f4,$f2,$01,$00
    .byte $f4,$f4,$01,$08
    .byte $04,$f6,$01,$f8
    .byte $04,$f8,$01,$00
    .byte $04,$fa,$01,$08
.else
    .byte $07
    .byte $f4,$ee,$03,$f0
    .byte $f4,$f2,$03,$f8
    .byte $04,$f0,$03,$f0
    .byte $04,$f4,$03,$f8
    .byte $04,$f8,$00,$00
    .byte $f4,$f6,$01,$00
    .byte $f4,$fa,$01,$08
.endif

; mounted soldier (basquez)
sprite_be:
.ifdef Probotector
    .byte $07
    .byte $f4,$ee,$01,$f2
    .byte $f4,$f0,$01,$fa
    .byte $f4,$f2,$01,$02
    .byte $f4,$f4,$01,$0a
    .byte $04,$f6,$01,$fa
    .byte $04,$f8,$01,$02
    .byte $04,$fa,$01,$0a
.else
    .byte $07
    .byte $f4,$ee,$03,$f2
    .byte $f4,$f2,$03,$fa
    .byte $04,$f0,$03,$f2
    .byte $04,$f4,$03,$fa
    .byte $04,$f8,$00,$01
    .byte $f4,$f6,$01,$01
    .byte $f4,$fa,$01,$09
.endif

; energy zone wall fire
sprite_bf:
    .byte $01
    .byte $ef,$33,$02,$ff

; energy zone wall fire
sprite_c0:
    .byte $01
    .byte $ef,$35,$02,$ff

; energy zone ceiling fire
sprite_c1:
    .byte $01
    .byte $ef,$37,$02,$fc

; energy zone ceiling fire
sprite_c2:
    .byte $01
    .byte $ef,$39,$02,$fc

; energy zone boss giant armored soldier (throwing)
sprite_c3:
.ifdef Probotector
    .byte $14
    .byte $df,$d6,$03,$e0
    .byte $d7,$d8,$03,$e8
    .byte $df,$dc,$03,$ee
    .byte $e8,$e8,$03,$01
    .byte $e8,$ea,$03,$09
    .byte $f4,$06,$03,$04
    .byte $cf,$da,$02,$ee
    .byte $d8,$de,$02,$f6
    .byte $d8,$e0,$02,$fe
    .byte $d8,$e2,$02,$06
    .byte $e8,$e4,$02,$f5
    .byte $e8,$e6,$02,$fd
    .byte $80
    .addr giant_soldier_bottom
.else
    .byte $13
    .byte $d8,$9d,$02,$f0
    .byte $d8,$d7,$02,$f8
    .byte $d8,$d9,$02,$00
    .byte $e0,$3d,$03,$e0
    .byte $e0,$47,$03,$e8
    .byte $e8,$0b,$03,$d8
    .byte $e8,$9f,$02,$f0
    .byte $e8,$db,$03,$f8
    .byte $e8,$dd,$03,$00
    .byte $80
    .addr giant_soldier_bottom
.endif

; snow field ground separator
sprite_c4:
    .byte $01
    .byte $ff,$fd,$00,$fc

; green helicopter ending scene (frame 1)
sprite_c5:
.ifdef Probotector
    .byte $01
    .byte $f8,$d6,$00,$fd
.else
    .byte $02
    .byte $f8,$a8,$00,$f8
    .byte $f8,$aa,$00,$00
.endif

; green helicopter ending scene (frame 2)
sprite_c6:
.ifdef Probotector
    .byte $02
    .byte $f8,$d8,$00,$f8
    .byte $f8,$da,$00,$00
.else
    .byte $03
    .byte $f8,$ac,$00,$f8
    .byte $f8,$ae,$00,$00
    .byte $f8,$a6,$01,$07
.endif

; green helicopter ending scene (frame 3)
sprite_c7:
.ifdef Probotector
    .byte $01
    .byte $f8,$dc,$00,$fc
.else
    .byte $02
    .byte $f8,$b0,$00,$f8
    .byte $f8,$b2,$00,$00
.endif

; green helicopter ending scene (frame 4)
sprite_c8:
.ifdef Probotector
    .byte $02
    .byte $f8,$de,$00,$f8
    .byte $f8,$e0,$00,$00
.else
    .byte $03
    .byte $f8,$b4,$00,$f8
    .byte $f8,$b6,$00,$00
    .byte $f8,$a6,$01,$05
.endif

; green helicopter facing forward (frame 1)
sprite_c9:
.ifdef Probotector
    .byte $03
    .byte $ef,$e2,$00,$f6
    .byte $f8,$e4,$00,$fc
    .byte $f9,$e6,$00,$04
.else
    .byte $05
    .byte $f8,$b8,$00,$f3
    .byte $f8,$ba,$00,$fb
    .byte $f8,$bc,$00,$03
    .byte $03,$a6,$01,$fb
    .byte $03,$a6,$01,$05
.endif

; green helicopter facing forward (frame 2)
sprite_ca:
.ifdef Probotector
    .byte $05
    .byte $ef,$e8,$00,$f1
    .byte $f3,$ea,$00,$f9
    .byte $f6,$ec,$00,$01
    .byte $fe,$ee,$00,$08
    .byte $06,$f0,$00,$00
.else
    .byte $07
    .byte $f0,$be,$40,$08
    .byte $f0,$c0,$40,$00
    .byte $f0,$c2,$40,$f8
    .byte $f0,$c4,$40,$f0
    .byte $00,$c6,$40,$08
    .byte $00,$c8,$40,$00
    .byte $00,$ca,$40,$f8
.endif

; green helicopter facing forward (frame 3)
sprite_cb:
.ifdef Probotector
    .byte $06
    .byte $ee,$f2,$00,$ed
    .byte $f2,$f4,$00,$f5
    .byte $f5,$f6,$00,$fd
    .byte $f2,$f8,$00,$05
    .byte $02,$fa,$00,$03
    .byte $02,$fc,$00,$0b
.else
    .byte $0a
    .byte $f0,$cc,$00,$e8
    .byte $f0,$ce,$00,$f0
    .byte $f0,$d0,$00,$f8
    .byte $f0,$d2,$00,$00
    .byte $f0,$d4,$00,$08
    .byte $f0,$d6,$00,$10
    .byte $00,$d8,$00,$f8
    .byte $00,$da,$00,$00
    .byte $04,$a6,$01,$f8
    .byte $04,$a6,$01,$07
.endif

.ifdef Probotector
.else
; green helicopter facing forward (frame 4)
sprite_cc:
    .byte $09
    .byte $f0,$dc,$40,$14
    .byte $f0,$de,$40,$0c
    .byte $f0,$e0,$40,$04
    .byte $f0,$e2,$40,$fc
    .byte $f0,$e4,$40,$f4
    .byte $f0,$e6,$40,$ec
    .byte $00,$e8,$40,$04
    .byte $00,$ea,$40,$fc
    .byte $00,$ec,$40,$f4

; green helicopter facing forward (frame 5)
sprite_cd:
    .byte $0b
    .byte $f0,$ee,$40,$14
    .byte $f0,$f0,$40,$0c
    .byte $f0,$f2,$40,$04
    .byte $f0,$e2,$40,$fc
    .byte $f0,$e4,$40,$f4
    .byte $f0,$f4,$40,$ec
    .byte $00,$e8,$40,$04
    .byte $00,$ea,$40,$fc
    .byte $00,$ec,$40,$f4
    .byte $0a,$a6,$01,$08
    .byte $02,$a6,$01,$f7

; green helicopter facing forward (frame 6)
sprite_ce:
    .byte $09
    .byte $f0,$f6,$40,$14
    .byte $f0,$de,$40,$0c
    .byte $f0,$e0,$40,$04
    .byte $f0,$f8,$40,$fc
    .byte $f0,$fa,$40,$f4
    .byte $f0,$fc,$40,$ec
    .byte $00,$e8,$40,$04
    .byte $00,$ea,$40,$fc
    .byte $00,$ec,$40,$f4
.endif

; ending sequence mountains
sprite_cf:
.ifdef Probotector
sprite_cc:
sprite_cd:
sprite_ce:
    .byte $05
    .byte $00,$81,$03,$00
    .byte $00,$83,$03,$08
    .byte $00,$83,$03,$10
    .byte $00,$83,$03,$18
    .byte $00,$85,$03,$20
.else
    .byte $05
    .byte $00,$63,$03,$00
    .byte $00,$65,$03,$08
    .byte $00,$65,$03,$10
    .byte $00,$65,$03,$18
    .byte $00,$89,$03,$20
.endif

; unused #$21b bytes out of #$4,000 bytes total (96.71% full)
; unused 539 bytes out of 16,384 bytes total (96.71% full)
; filled with 539 #$ff bytes by contra.cfg configuration
bank_1_unused_space: