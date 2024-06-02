# Overview
A song or sound can be composed of multiple instruments or channels.  The NES
has 5 channels: 2 pulse (square wave) channels, 1 triangle channel, 1 noise
channel, and 1 delta modulation channel.  _Contra_ maintains 6 slots of data in
memory that are used in priority order to play sounds.  Higher slots are played
before the lower slots.  Each slot is linked to an NES sound channel.

  * #$00 = pulse 1 channel
  * #$01 = pulse 2 channel
  * #$02 = triangle channel
  * #$03 = noise and dmc channel
  * #$04 = pulse 1
  * #$05 = noise channel

For example, if a sound is loaded in slot #$00 and slot #$04 (both pulse 1
channel), then the sound in slot #$04 will be played since it is higher.  The
code that converts from sound slot to channel is `@load_sound_channel_offset`.

When the game loads a sound to play, it first determines which slots are needed
by loading data from `sound_table_00`. This table specifies the number of slots
needed to play the sound and where the instructions to play the sound exists,
i.e. the 2 byte cpu address where the sound channel instructions are.

# Sound Codes

Below is a table of all the sounds that exist in _Contra_, including unused
sounds.  The Japanese names were obtained from the "sound mode" feature in the
Famicom version of the game.  Each sound is related to one or more sound codes.
For example, the level 3 waterfall music uses 4 sound codes, which means that
sound uses 4 sound channels.

At the bottom of the table are the DPCM samples that are used throughout the
game by various other sounds.

| Sound | Japanese Name | Description                                          | sound_code(s) | Slot | Command Type | Channel          |
|-------|---------------|------------------------------------------------------|---------------|------|--------------|------------------|
| #$01  |               | empty/silence, used to initialize channel            | `sound_01`    |      |              |                  |
| #$02  |               | percussive tick (bass drum/tom drum)                 | `sound_02`    | 5    | low          | noise            |
| #$03  | FOOT          | player landing on ground or water                    | `sound_03`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_04`    | 5    | low          | noise            |
| #$05  | ROCK          | waterfall rock landing on ground                     | `sound_05`    | 4    | low          | pulse 1          |
| #$06  | TYPE 1        | unused, keyboard typing in Japanese version of game  | `sound_06`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_07`    | 5    | low          | noise            |
| #$08  |               | unused, rumbling                                     | `sound_08`    | 5    | low          | noise            |
| #$09  | FIRE          | energy zone fire beam                                | `sound_09`    | 5    | low          | noise            |
| #$0a  | SHOTGUN1      | default weapon                                       | `sound_0a`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_0b`    | 5    | low          | noise            |
| #$0c  | SHOTGUN2      | M weapon, turret man                                 | `sound_0c`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_0d`    | 5    | low          | noise            |
| #$0e  | LASER         | L weapon                                             | `sound_0e`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_0f`    | 5    | low          | noise            |
| #$10  | PL FIRE       | F weapon                                             | `sound_10`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_11`    | 5    | low          | noise            |
| #$12  | SPREAD        | S weapon                                             | `sound_12`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_13`    | 5    | low          | noise            |
| #$14  | HIBIWARE      | bullet shielded wall plating ting                    | `sound_14`    | 4    | low          | pulse 1          |
| #$15  | CHAKUCHI      | energy zone boss landing                             | `sound_15`    | 4    | low          | pulse 1          |
| #$16  | DAMEGE 1      | bullet to metal collision ting                       | `sound_16`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_17`    | 5    | low          | noise            |
| #$18  | DAMEGE 2      | alien heart boss hit                                 | `sound_18`    | 4    | low          | pulse 1          |
| #$19  | TEKI OUT      | enemy destroyed                                      | `sound_19`    | 4    | low          | pulse 1          |
| #$1a  | HIRAI 1       | ice grenade whistling noise                          | `sound_1a`    | 4    | low          | pulse 1          |
| #$1b  | SENSOR        | level 1 jungle boss siren                            | `sound_1b`    | 4    | low          | pulse 1          |
| #$1c  | KANDEN        | electrocution sound                                  | `sound_1c`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_1d`    | 5    | low          | noise            |
| #$1e  | CAR           | tank advancing                                       | `sound_1e`    | 4    | low          | noise            |
| #$1f  | POWER UP      | pick up weapon item                                  | `sound_1f`    | 4    | low          | pulse 1          |
| #$20  | 1UP           | extra life                                           | `sound_20`    | 4    | low          | pulse 1          |
| #$21  | HERI          | helicopter rotors                                    | `sound_21`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_21`    | 1    | low          | pulse 2          |
|       |               |                                                      | `sound_23`    | 5    | low          | noise            |
| #$24  | BAKUHA 1      | explosion                                            | `sound_24`    | 5    | low          | noise            |
| #$25  | BAKUHA 2      | game intro, indoor wall, and island explosion        | `sound_25`    | 5    | low          | noise            |
| #$26  | TITLE         | game intro tune                                      | `sound_26`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_27`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_28`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_29`    | 3    | high         | noise            |
| #$2a  | BGM 1         | level 1 jungle and level 7 hangar music              | `sound_2a`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_2b`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_2c`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_2d`    | 3    | high         | noise            |
| #$2e  | BGM 2         | level 3 waterfall music                              | `sound_2e`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_2f`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_30`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_31`    | 3    | high         | noise            |
| #$32  | BGM 3         | level 5 snow field music                             | `sound_32`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_33`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_34`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_35`    | 3    | high         | noise            |
| #$36  | BGM 4         | level 6 energy zone                                  | `sound_36`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_37`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_38`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_39`    | 3    | high         | noise            |
| #$3a  | BGM 5         | level 8 alien's lair music                           | `sound_3a`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_3b`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_3c`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_3d`    | 3    | high         | noise            |
| #$3e  | 3D BGM        | indoor/base level music                              | `sound_3e`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_3f`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_40`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_41`    | 3    | high         | noise            |
| #$42  | BOSS          | indoor/base boss screen music                        | `sound_42`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_43`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_44`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_45`    | 3    | high         | noise            |
| #$46  | PCLR          | end of level tune                                    | `sound_46`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_47`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_48`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_49`    | 3    | high         | noise            |
| #$4a  | ENDING        | end credits                                          | `sound_4a`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_4b`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_4c`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_4d`    | 3    | high         | noise            |
| #$4e  | OVER          | game over/after end credits, presented by Konami     | `sound_4e`    | 0    | high         | pulse 1          |
|       |               |                                                      | `sound_4f`    | 1    | high         | pulse 2          |
|       |               |                                                      | `sound_50`    | 2    | high         | triangle         |
|       |               |                                                      | `sound_51`    | 3    | high         | noise            |
| #$52  | PL OUT        | player death                                         | `sound_52`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_53`    | 5    | low          | noise            |
| #$54  |               | game pausing                                         | `sound_54`    | 4    | low          | pulse 1          |
| #$55  | BOSS BK       | tank, boss ufo, boss giant, alien guardian destroyed | `sound_55`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_56`    | 5    | low          | noise            |
| #$57  | BOSS OUT      | boss destroyed                                       | `sound_57`    | 4    | low          | pulse 1          |
|       |               |                                                      | `sound_58`    | 1    | low          | pulse 2          |
|       |               |                                                      | `sound_59`    | 5    | low          | noise            |
| #$5a  | n/a           | high hat                                             | n/a           | n/a  | low          | delta modulation |
| #$5b  | n/a           | snare                                                | n/a           | n/a  | low          | delta modulation |
| #$5c  | n/a           | high hat                                             | n/a           | n/a  | low          | delta modulation |
| #$ff  | n/a           | snowfield boss defeated door open (bug)              | n/a           | n/a  | low          | delta modulation |

The sound for pausing the game is not in the sound mode menu, presumably to not
confuse players into thinking the game is paused.  As for names, I can guess at
some of the abbreviations and name meanings.

  * BAKUHA - ばくはつ (爆発) - Japanese for explosion
  * BGM - background music
  * BK - BAKUHA, i.e. explosion
  * CHAKUCHI - ちゃくち (着地) - Japanese for landing/touching the ground
  * HIBIWARE - ひびわれ (罅割れ, ひび割れ) - Japanese for crack; crevice; fissure
  * PCLR - player clear, or pattern clear
  * PL - player
  * TYPE - keyboard typing

# sound_code Parsing

Every video frame, the game loops through each sound slot to see if a sound is
currently playing, see `@sound_slot_loop`.  If a sound slot is populated, i.e.
a sound is playing, then `handle_sound_code` will be called on that slot.
`handle_sound_code` will first check if the game is paused, as the music and
sound effects are paused when the game is paused. If the game isn't paused, the
`handle_sound_code` will decrement the current sound slot's sound length
(`SOUND_CMD_LENGTH`) and if the sound is finished, move to read the next command
(`read_sound_command_00`).  If the sound isn't finished, then
`@pulse_vol_and_vibrato` is called to possibly adjust the volume and frequency
of the current playing sound. Note frequency adjustments, i.e. vibrato isn't
used by _Contra_.

A `sound_code` is composed of 1 or more sound commands.  Each sound command will
configure variables or set APU registers. Not every sound command will make a
sound.  Some just configure variables for the subsequent sound code, for example
setting `SOUND_LENGTH_MULTIPLIER` for use by a subsequent sound command.  The
sound commands are parsed according to the following logic.

The first byte of the entire sound code determines how the rest of the commands
for the sound code will be parsed.  When the byte is less than #$30, the the
sound code is considered a 'low sound' code.  Otherwise, the code will be parsed
as a 'high sound' code.

## sound_code Sharing

All sound command types can reference addresses to other sound commands.  When a
sound command moves to another command, once that command is finished executing,
then the sound read pointer goes back to the next bytes in the original command.

  * #$fd - move to child sound command for playing shared sound data across
    different `sound_xx` commands, or shared parts within the same sound code.
    Move to execute sound command at address specified by next 2 bytes.
  * #$fe - repeat the next sound command at address `a` `n` times, where `a` is
    the next byte and `n` is the 2nd and 3rd byte.
  * #$ff - finished reading sound command, exit to previous command if child
    sound command, otherwise, finished entire sound code

## Low Sound Command

In _Contra_, low sound commands are used by sound slots #$01 (pulse 1), #$04
(pulse 2) and #$05 (noise).  Low sound commands are used for sound effects.
The method in code for parsing low sound commands is `read_low_sound_cmd`.  In
general, low sound commands set the length, decrescendo start, pitch, and duty.

The first byte of the sound command dictates how the subsequent bytes are
interpreted.  The command is read recursively until the note period is set, then
the parsing exits.

  * **Case 1** - #$2x - sets the number of video frames to wait before reading
    the next sound command (`SOUND_LENGTH_MULTIPLIER`) as well as the high
    nibble of the APU configuration register for the sound channel
    (`SOUND_CFG_HIGH`).
    * when low nibble is not #$f, then `SOUND_LENGTH_MULTIPLIER` is set to low
      nibble.
    * when low nibble is #$f, then the next full byte is used to set
      `SOUND_LENGTH_MULTIPLIER`
    * the following byte is then used to set high nibble of the APU
      configuration register for the sound channel (`SOUND_CFG_HIGH`)
  * **Case 2** - #$10 - enable/disable sweep and set volume decrescendo.  What
    is set is based on the next byte.  Additionally, if the sound slot is #$04,
    then the pulse 1 channel `PULSE_VOL_DURATION` will also be set to the sweep
    value.
    * non-zero - sweep will be enabled and set to the value of the byte.
    * #$00 - if the byte after #$10 is #$00, then sweep will be disabled by
    setting the APU register $4001 to #$7f.
    be set to #$7f.
  * **Case 3** - #$1x - slightly flatten the note that will be played by less
    than 1Hz by setting bit 4 of `SOUND_FLAGS`.  The low nibble is not used.
    This case is not used in _Contra_. However, notes are flattened in another
    flow, see `@flip_flatten_note_adv`.
  * **Case 4** - #$xx - if not #2x, or #$1x, then byte high nibble is used as
    the low nibble (volume) for APU channel config.  The high nibble and low
    nibble from memory are merged (`SOUND_CFG_HIGH` and `SOUND_CFG_LOW`
    respectively), unless volume is constant, then only the high nibble is used
    when setting the sound channel configuration ($4000). Also, the sound length
    (`SOUND_CMD_LENGTH`), value is set based on `SOUND_LENGTH_MULTIPLIER`.
    Finally, the note frequency/counter/pitch is set based off the next two
    bytes and then the parsing is complete.

After case 4 is parsed, the read low sound command method exits.  Then the game
logic will continue.  The next frame, a standard `@sound_slot_loop` will pick up
the sound slot is populated and play possibly modify the sound's volume and
frequency for vibrato (not used in _Contra_).  Every video frame, the game logic
repeats this until the sound is completed, the game logic will then continue
by reading the next byte of the next low sound code.  This entire process
repeats until a #$ff is read.

## High Sound Command

In _Contra_, high sound commands are used by sound slots #$00 (pulse 1), #$01
(pulse 2), #$02 (triangle) and #$03 (noise & dmc channel).  High sound commands
are used for the 'music' of the game: the level background music, the intro
tune, end credits song, and after credits/game over music. The method in code
for parsing low sound commands is `read_high_sound_cmd`.

The first byte of the sound command dictates how the subsequent bytes are
interpreted.

  * **Case 1** - if the sound slot is #$03 (noise and dmc channel), then
    `parse_percussion_cmd` is called to handle the percussion.  See notes below
    in section titled `Percussion Command`.
  * **Case 2** - if byte 0 high nibble is less than #$c, then `simple_sound_cmd`
    is used.  This plays a single note with a specified length change from
    previous note with a volume envelope specified by `lvl_config_pulse`.
  * **Case 3** - if byte 0 high nibble is greater than or equal to #$0c, then
  `@regular_sound_cmd` is used.  `@regular_sound_cmd` looks at bits 4 and 5 to
  know which entry in `sound_cmd_ptr_tbl` to use to handle the sound command.
  For details of what each method does, see section `sound_cmd_routine_xx`.

### sound_cmd_routine_xx
  * `sound_cmd_routine_00` - sets sound channel config to mute, marks channel
    as muted by setting bit 6 of `SOUND_FLAGS`.
  * `sound_cmd_routine_01` - sets sound length multiplier
    (`SOUND_LENGTH_MULTIPLIER`) to low nibble. Sets in memory low nibble of
    sound channel.  Can initialize channel by calling
  `exe_channel_init_ptr_tbl_routine`.  Otherwise, recursively calls back to
  `read_high_sound_cmd` to handle next byte.
  * `sound_cmd_routine_02`
    * If the low nibble is less than #$5, then sets note adjustment flag
    (`SOUND_PERIOD_ROTATE`) and recursively calls back to `read_high_sound_cmd`.
    * If the low nibble is #$8, set bit 4 of `SOUND_FLAGS` to mark note as
      slightly flattened from original value.
    * If the low nibble is #$b, set vibrato variables and recursively call
      `read_high_sound_cmd`.
    * If the low nibble is #$c, set the pitch based on next sound byte, which
      (when doubled) is an offset into `note_period_tbl`.
    * If the low nibble isn't any known value, just ignore it and recursively
      call `read_high_sound_cmd`.
  * `sound_cmd_routine_03` - this function handles the end of a sound command
    and determines where to go next based on the byte value.  See section
    above titled `sound_code Sharing`.

### Percussion Command

Percussion commands are recursively read until Case 1 or Case 3 is reached.

  * **Case 1** - The byte's high nibble is #$f. This is an end of sound command,
    the sound command will either end, repeat, or move back to parent sound
    command.  See the section titled `sound_code Sharing`.
  * **Case 2** - The byte's high nibble is #$d. The low nibble is used to set
    the sound length multiplier (`SOUND_LENGTH_MULTIPLIER`).
  * **Case 3** - The byte high nibble isn't #$f, nor #$d.  In this case, call
    `calc_cmd_len_play_percussion` to determine sound command length
    (`SOUND_CMD_LENGTH`) based on the low nibble and the value determined from
    Case 2.  Then call `play_percussive_sound`.  This method will use the high
    nibble (shifted into low nibble) of the byte value to get offset into
    `percussion_tbl`, which specifies which DMC sound sample code to play.  This
    value is passed to `play_sound` to play the sound code. Then, if the value
    was greater than or equal to #$3, `sound_02` is also played with other sound
    code.  The offsets are defined and which sound(s) is/are played are below.
    Note that in offset 5, `sound_02` is not played because there is a check in
    `load_sound_code_entry` and `sound_25` is already playing in slot #$05.
      * 0 - `sound_02`
      * 1 - `sound_5a`
      * 2 - `sound_5b`
      * 3 - `sound_5a` and `sound_02`
      * 4 - `sound_5b` and `sound_02`
      * 5 - `sound_25`
      * 6 - `sound_5c` and `sound_02`
      * 7 - `sound_5d` and `sound_02`