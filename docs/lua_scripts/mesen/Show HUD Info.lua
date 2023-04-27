-- shows information about weapon on head-up-display area

function Main()
    local p1score1 = emu.read(0x07e2, emu.memType.cpu)
    local p1score2 = emu.read(0x07e3, emu.memType.cpu)
    p1score = ((p1score2 << 8) + p1score1) * 100

    local weapon_hex = emu.read(0x00aa, emu.memType.cpu)
    local rapid_fire = ""
    if weapon_hex & 0x10 == 0x10 then
        rapid_fire = " Rapid "
    else
        rapid_fire = " "
    end

    weapon_hex = weapon_hex & 0x0f
    local weapon_name = ""

    if weapon_hex == 0 then weapon_name = "Default Gun"
    elseif weapon_hex == 1 then weapon_name = "Machine Gun"
    elseif weapon_hex == 2 then weapon_name = "Flame Thrower"
    elseif weapon_hex == 3 then weapon_name = "Spray"
    elseif weapon_hex == 4 then weapon_name = "Laser" end
    emu.drawString(5,40, "P1: " .. p1score .. rapid_fire .. weapon_name)
end

emu.addEventCallback(Main, emu.eventType.endFrame)