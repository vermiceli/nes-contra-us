# Overview

_Contra_ is already a challenging game.  However, it gets even more difficult
the more times you beat the game.  This documents the ways in which beating the
game affects the behavior of subsequent playthroughs.

The game keeps track of the number of times the player(s) beat the game in the
variable `GAME_COMPLETION_COUNT`, located at CPU memory address `$31`.

Many of the HP modifications are also based on the player's "weapon strength".
This variable, called `PLAYER_WEAPON_STRENGTH`, is stored at CPU memory address
`$2f` and depends on which weapon player 1 has.

| Weapon  | Strength |
|---------|----------|
| Default | 0        |
| M       | 2        |
| F       | 1        |
| S       | 3        |
| L       | 2        |

# Soldier Generation

Random soldiers are generated more quickly the more you beat the game up until
you've beaten the game 3 times.  The actual delay depends on the level.  Each
time you beat the game, the delay is lowered by 40 (assuming the weapon player
1 has is the same).

Soldier generation delay is calculated by the following formula

```
DELAY = INITIAL_LEVEL_DELAY - (40 * GAME_COMPLETION_COUNT) - (5 * PLAYER_WEAPON_STRENGTH)
```

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$81         | 129              |
| 1                | #$59         | 89               |
| 2                | #$31         | 49               |
| 3                | #$09         | 9                |
| 4                | #$09         | 9                |

All sample results assume the player's `PLAYER_WEAPON_STRENGTH` is 3 (S weapon)
and the level is 1 where the initial delay is 144.  The initial level delays are
as follows (defined in `level_soldier_generation_timer`)

| Level | Delay (decimal) |
|-------|-----------------|
| 1     | 144             |
| 2     | n/a             |
| 3     | 216             |
| 4     | n/a             |
| 5     | 208             |
| 6     | 200             |
| 7     | 192             |
| 8     | n/a             |

# Red Turret Attack Delay

Red turret attack delay is shorter if you've beaten the game once. It doesn't
get any short for subsequent wins.

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$28         | 40               |
| 1                | #$08         | 8                |

# Alien Fetus (Bundle) HP

The level 8 alien fetus (bundle) HP goes up as you beat the game more and more.
It is the number of times you've beaten the game + 2, so the HP goes up by 1
every time the game is beaten (until max 255 due to memory limit).

```
GAME_COMPLETION_COUNT + 2
```

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$02         | 2                |
| 1                | #$03         | 3                |
| 2                | #$04         | 4                |
| 3                | #$05         | 5                |
| 4                | #$06         | 6                |
| 5                | #$07         | 7                |
| ...              | ...          | ...              |
| 253              | #$ff         | 255              |
| 254              | #$00         | 0 (invincible)   |
| 255              | #$01         | 1                |

# Alien Mouth (Wadder) HP

The level 8 alien mouth (wadder) HP goes up as you beat the game more and more.
The HP is calculated by the following formula

```
(2 * GAME_COMPLETION_COUNT) + PLAYER_WEAPON_STRENGTH + 4
```

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$07         | 7                |
| 1                | #$09         | 9                |
| 2                | #$0b         | 11               |
| 3                | #$0d         | 13               |
| 4                | #$0f         | 15               |
| 5                | #$11         | 17               |
| ...              | ...          | ...              |
| 124              | #$ff         | 255              |
| 125              | #$01         | 1                |
| ...              | ...          | ...              |
| 252              | #$00         | 0 (invincible)   |

All sample results assume the player's `PLAYER_WEAPON_STRENGTH` is 3 (S weapon).

# Alien Spider (Bugger) HP

Level 8 alien spiders (buggers) HP goes up as you beat the game more and more.
The HP is calculated by the following formula

```
PLAYER_WEAPON_STRENGTH + GAME_COMPLETION_COUNT + 2
```

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$05         | 5                |
| 1                | #$06         | 6                |
| 2                | #$07         | 7                |
| 3                | #$08         | 8                |
| 4                | #$09         | 9                |
| 5                | #$0a         | 11               |
| ...              | ...          | ...              |
| 250              | #$ff         | 255              |
| 251              | #$00         | 0 (invincible)   |
| 252              | #$02         | 2                |

All sample results assume the player's `PLAYER_WEAPON_STRENGTH` is 3 (S weapon).

# Alien Spider Spawn (Eggron) HP

```
(GAME_COMPLETION_COUNT * 2) + (PLAYER_WEAPON_STRENGTH * 2) + 24
```

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$1e         | 30               |
| 1                | #$20         | 32               |
| 2                | #$22         | 34               |
| 3                | #$24         | 36               |
| 4                | #$26         | 38               |
| 5                | #$28         | 40               |
| ...              | ...          | ...              |
| 112              | #$fe         |                  |
| 113              | #$00         | 0 (invincible)   |
| 114              | #$02         | 2                |

All sample results assume the player's `PLAYER_WEAPON_STRENGTH` is 3 (S weapon).

# Alien Guardian & Boss Heart HP

The level 8 alien guardian and boss heart (final boss) HP are both calculated
according to the same formula below until the calculated HP is greater than or
equal to #$a0 (160 decimal).  160 is the max HP the alien guardian and boss
heart can be.

```
(PLAYER_WEAPON_STRENGTH * 16) + 55 + (GAME_COMPLETION_COUNT * 16)
```

Note if `PLAYER_WEAPON_STRENGTH * 16` is larger than 255, then the results will
wrap around. So sometimes the HP is actually lower than a previous playthrough
where `GAME_COMPLETION_COUNT` was lower.  This occurs every 16 loops.

| Completion Count | Result (hex) | Result (decimal) |
|------------------|--------------|------------------|
| 0                | #$67         | 103              |
| 1                | #$77         | 119              |
| 2                | #$87         | 135              |
| 3                | #$97         | 151              |
| 4                | #$a0         | 160              |
| 5                | #$a0         | 160              |
| ...              | ...          | ...              |
| 15               | #$a0         | 160              |
| 16               | #$67         | 103              |
| 17               | #$77         | 119              |
| 18               | #$87         | 135              |
| 19               | #$97         | 151              |
| 20               | #$a0         | 160              |
| 21               | #$a0         | 160              |

All sample results assume the player's `PLAYER_WEAPON_STRENGTH` is 3 (S weapon).