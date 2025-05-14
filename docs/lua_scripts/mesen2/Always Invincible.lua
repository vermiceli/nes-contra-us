function Main()
    -- 0xb0/b1 in memory store the amount of time the B weapon (barrier) lasts.
    -- By continually overwriting the timer to the max value (FF), the players
    -- will always be invincible
    emu.write(0x00b0, 0xff, emu.memType.nesMemory) -- player 1
    emu.write(0x00b1, 0xff, emu.memType.nesMemory) -- player 1
end

emu.addEventCallback(Main, emu.eventType.endFrame)