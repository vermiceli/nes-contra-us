while (true) do
    memory.writebyte(0x00b0, 0xff) -- player 1
    memory.writebyte(0x00b1, 0xff) -- player 2

    -- 0xb0/b1 in memory store the amount of time the B weapon (barrier) lasts.
    -- By continually overwriting the timer to the max value (FF), the players
    -- will always be invincible
    emu.frameadvance();
end;