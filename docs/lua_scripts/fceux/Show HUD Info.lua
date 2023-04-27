while (true) do
    local p1score1 = memory.readbyte(0x07e2)
    local p1score2 = memory.readbyte(0x07e3)
    p1score = (bit.lshift(p1score2, 8) + p1score1) * 100
    
    local weapon_hex = memory.readbyte(0x00aa)
    local rapid_fire = ""
    if bit.band(weapon_hex, 0x10) == 0x10 then
        rapid_fire = " Rapid "
    else
        rapid_fire = " "
    end

    weapon_hex = bit.band(weapon_hex, 0x0f)
    local weapon_name = ""

    if weapon_hex == 0 then weapon_name = "Default Gun"
    elseif weapon_hex == 1 then weapon_name = "Machine Gun"
    elseif weapon_hex == 2 then weapon_name = "Flame Thrower"
    elseif weapon_hex == 3 then weapon_name = "Spray"
    elseif weapon_hex == 4 then weapon_name = "Laser" end
    gui.text(5, 40, "P1: " .. p1score .. rapid_fire .. weapon_name);
    emu.frameadvance();
end;