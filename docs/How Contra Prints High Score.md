# How Contra Prints the High Score

## Overview
There are 3 scores stored in CPU memory for _Contra_: high score, player 1
score, and player 2 score. Each score is 2 bytes and stored in addresses
0x07e0-0x07e1, 0x07e2-0x07e3, and 0x07e4-0x07e5 respectively. These 2-byte
scores are little-endian, i.e. the least significant byte is the lower-addressed
byte. All scores have 00 appended when displayed, for example a score of 100
will show as 10000 on the screen. The default initial high score stored in
0x07e2 is 0xc8, or 200 in decimal. This will show as 20000. The exception to
this is a score of 0. 0 points will show as 0 and not 000.

The logic to display the score on the screen is non-trivial and worth properly
documenting. To display the score on the screen, the code needs to convert an
in-memory hexadecimal number to a decimal number.

At a high level, _Contra_ recursively calculates each decimal digit to display
one at a time from right to left. If the player's score is 123 in decimal, or
0111 1011 in binary. _Contra_ will call the same routine 3 times, each time
producing the next digit in the score from right to left: 3, then 2, then 1.

|Call # | Rest | Right Digit |
|-------|------|-------------|
| 1     | 12   | 3           |
| 2     | 1    | 2           |
| 3     | 0    | 1           |

As you can see, each row can be read as Score = (10 * Rest) + Right_Digit
The Rest column can be conceptually though of as 10 times larger than what is
stored in memory. So 12 really means 120, and 1 really means 10. This will make
conceptualizing the algorithm easier.

## Examples
This document's examples are simplified slightly in that these examples are
using 1-byte scores and not 2-byte scores like _Contra_.  The source code shown
works against 2-byte scores.

### Example of Routine
As shown above, the routine is called a number of times, each time retrieving
the next digit of the score to display. Below is a step-by-step walk through of
calculating a single digit of the score to display.

  Score (0x01): 0x7b 0111 1011 (123 in decimal)

  Right Digit (0x02): 0x00 0000 0000 (0)

|Shift # | Rest      | Right Digit | Input    | Explanation                  |
|--------|-----------|-------------|----------|------------------------------|
| 1      |           |   0         | 111 1011 | left shift                   |
| 2      |           |   01        | 111 011  | left shift                   |
| 3      |           |   011       | 11 011   | left shift                   |
| 4      |           |   0111      | 1 011    | left shift                   |
| 5      |           |   1111      | 011      | left shift                   |
|        |           |   0101      | 011      | subtract 10 from right digit |
| 6      |         1 |   1010      | 11       | shift left, mark 1 into Rest |
|        |         1 |   0000      | 11       | subtract 10                  |
| 7      |        11 |   0001      | 1        | shift left, mark 1 into Rest |
| 8      |       110 |   0011      |          | shift left                   |
| 9      |      1100 |   0011      |          | shift left Rest only         |

  Rest (0x01):  0000 1100 (12 decimal)

  Right Digit (0x02): 0000 0011 (3 decimal)

The way _Contra_ determines the right-most digit recursively is very
interesting. Every time the algorithm shifts left, the input is passed through
the "Right Digit" column which will track when the single-digit is more than 10.
Every time the right digit's column is more than 10, 10 is subtracted. On the
subsequent left shift, 1 is placed on the right-most bit of the Rest column.
That 1 signifies that a subtraction of 10 was performed. Remember that the Rest
column's value is actually 10 times larger, e.g. 12 really means 120. So when
the 1 is carried to the "Rest" column, it is really a 10 being carried, which
matches what was subtracted from the "Right Digit" column.

### Memory-accurate Example With a 1-byte Score
While the previous example helps understand at a conceptual level, it hides some
of the technical ingenuity. _Contra_ doesn't split the score ("Input") into
"Right Digit" and "Rest". _Contra_ actually shifts the "Rest" back into the
"Input".  This is useful because it allows the routine to be called
consecutively until there are no more digits to display.

Again, _Contra_ uses 2-byte scores, but if _Contra_ had 1-byte scores, this is
how the algorithm would work, while being memory accurate. 0x01 is shifted into
0x02.  Right Digit (0x02) is always initialized to zero.

  Score (0x01): 0x7b 0111 1011 (123)

  Right Digit (0x02): 0x00 0000 0000 (0)

|Shift # |  0x01       |  0x02       | Explanation                  |
|--------|-------------|-------------|------------------------------|
| 1      |  1111 0110  |  0000 0000  | left shift 0x01 only         |
| 2      |  1110 1100  |  0000 0001  | left shift 0x02, 0x01        |
| 3      |  1101 1000  |  0000 0011  | left shift 0x02, 0x01        |
| 4      |  1011 0000  |  0000 0111  | left shift 0x02, 0x01        |
| 5      |  0110 0000  |  0000 1111  | left shift 0x02, 0x01        |
|        |  0110 0000  |  0000 0101  | subtract 10                  |
| 6      |  1100 0001  |  0000 1010  | shift left, mark 1 into Rest |
|        |  1100 0001  |  0000 0000  | subtract 10                  |
| 7      |  1000 0011  |  0000 0001  | shift left, mark 1 into Rest |
| 8      |  0000 0110  |  0000 0011  | shift left 0x02, 0x01        |
| 9      |  0000 1100  |  0000 0011  | shift left 0x01 only         |

  Rest (0x01):  0000 1100 (12 decimal)

  Right Digit (0x02): 0000 0011 (3 decimal)

You can see that after this routine is called, it can be called again
immediately to determine the next right-most digit since the score address
(0x01) is overwritten with the new score. 0x02 is never more than 4-bits, and no
additional memory locations are needed. I believe this is the reason this
algorithm was used over other algorithms that can convert from hexadecimal to
decimal with a fixed number of steps.

## _Contra_'s Score Display Algorithm in Assembly from Source
The code for converting the scores for display is in the last (8th) PRG ROM
bank, bank 7. The logic begins at address $caf8 in CPU memory. _Contra_ will
recursively determine the value of the "Right Digit" place, which is then
displayed on the screen to the player.

CPU memory addresses used
  * 0x00 - low byte of the current score being calculated
  * 0x01 - high byte of the current score being calculated
  * 0x02 - the next decimal digit to display
  * 0x03 - hard-coded 10 in decimal

```
calculate_score_digit:
    lda #$00     ; set the accumulator register A to zero (#$00)
    sta $02      ; zero out any previously calculated digit
    ldy #$10     ; set the left-shift loop counter back to #$10 (16 decimal)
    rol $00      ; shift the score low byte to the left by one bit
                 ; push the most significant bit (msb) to the carry flag
    rol $01      ; shift the score high byte to the left by one byte
                 ; push the msb to the carry flag
                 ; pull in carry flag to least significant bit (lsb)

shift_and_check_digit_carry:
    rol $02      ; shift score high byte to the left by one bit
                 ; if the msb of the score high byte was 1, then carry into lsb
    lda $02      ; load current digit into the accumulator register A
    cmp $03      ; compare #$0a (10 decimal) to the current digit

                 ; branch if current digit is less than #$0a (10 decimal)
                 ;  - this means no subtraction and carry is needed
                 ; if greater than #$0a (10 decimal), don't jump
                 ;  - subtract 10 and carry
    bcc continue_shift_score
    sbc $03      ; the current digit is greater than 10, subtract 10
                 ; this also sets the carry flag, which will be moved to the
                 ; low byte of the score, which is the "Rest" of the number
                 ; this carry represents adding 10 to the "Rest"
    sta $02      ; store the difference (new current digit) back in $02

; $02 (current digit) is less than #$0a, or has just been subtracted
; continue algorithm by shifting score left
continue_shift_score:
    rol $00      ; if just set $02 to digit by subtraction, this will put 1
                 ; in $00's lsb, signifying adding 10 to "Rest"
    rol $01      ; if $00's msb is 1, then it'll carry to the lsb of $01
    dey          ; Y goes from $10 to $00, once Y is $00, the algorithm is done
    bne shift_and_check_digit_carry
    rts
```

### See Also
Converting a hexadecimal number to decimal can be done in multiple ways. A
common algorithm for doing this is
[double dabble algorithm](https://en.wikipedia.org/wiki/Double_dabble). _Contra_
does not use this method. This is probably because the double dabble algorithm
requires more CPU memory space, whereas _Contra_'s algorithm uses the same,
fixed 2 bytes of CPU memory (0x01 and 0x02) for all score calculation.
Consequently, instead of a fixed number of operations like double dabble,
_Contra_ uses recursion, which requires a variable number of CPU cycle at the
benefit of fixed memory usage.

Another interesting and related concept is the
[binary-coded decimal](https://en.wikipedia.org/wiki/Binary-coded_decimal).