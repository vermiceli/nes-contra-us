-- shows the background collision codes
-- floor, water, solid, or empty

function get_bg_collision(x, y)
    local VERTICAL_SCROLL = emu.read(0xfc, emu.memType.cpu)
    local HORIZONTAL_SCROLL = emu.read(0xfd, emu.memType.cpu)
    local PPUCTRL_SETTINGS = emu.read(0xff, emu.memType.cpu)
    local adjusted_y = y + VERTICAL_SCROLL
    local adjusted_x = x + HORIZONTAL_SCROLL

    if adjusted_y >= 0xf0 then
        adjusted_y = adjusted_y + 0x0f
        adjusted_y = adjusted_y - 255
    end

    -- $10 is always #$00, except when moving cart is calling get_bg_collision
    local nametable_number = (PPUCTRL_SETTINGS ~ 0x00) & 0x01
    if adjusted_x > 255 then
        nametable_number = nametable_number ~ 1
        adjusted_x = adjusted_x - 255
    end

    adjusted_y = (adjusted_y >> 2) & 0x3c
    adjusted_x = adjusted_x >> 4
    local bg_collision_offset = (adjusted_x >> 2) | adjusted_y
    if nametable_number == 1 then
        bg_collision_offset = bg_collision_offset | 0x40;
    end

    local collisionCodeByte = emu.read(0x680 + bg_collision_offset, emu.memType.cpu)
    adjusted_x = adjusted_x & 0x03;
    local collisionCode = 0
    if adjusted_x == 0 then
        collisionCode = collisionCodeByte >> 6
    elseif adjusted_x == 1 then
        collisionCode = collisionCodeByte >> 4
    elseif adjusted_x == 2 then
        collisionCode = collisionCodeByte >> 2
    else
        collisionCode = collisionCodeByte
    end

    collisionCode = collisionCode & 0x03;

    local floorColor = 0x508fbc8f
    local waterColor = 0x500096FF
    local solidColor = 0x50A9A9A9
    local tileColor = 0x0
    if collisionCode == 0x01 then
        tileColor = floorColor
    elseif collisionCode == 0x02 then
        tileColor = waterColor
    elseif collisionCode == 0x03 then
        tileColor = solidColor
    end

    if collisionCode ~= 0 then
      emu.drawRectangle(x, y, 16, 16, tileColor, true)
    end
end

function Main()
    local VERTICAL_SCROLL = emu.read(0xfc, emu.memType.cpu)
    local HORIZONTAL_SCROLL = emu.read(0xfd, emu.memType.cpu)
    for i = 0,300,16 do
        for j = 0,300,16 do
           get_bg_collision(i - math.fmod(HORIZONTAL_SCROLL, 16), j - math.fmod(VERTICAL_SCROLL, 16))
        end
    end
end

emu.addEventCallback(Main, emu.eventType.endFrame)