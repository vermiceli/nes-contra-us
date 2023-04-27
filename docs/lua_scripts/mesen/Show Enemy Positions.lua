-- shows the player - enemy collision boxes
-- does not show the player bullet - enemy collision boxes
-- doesn't currently handle collision code f (rising spiked walls and fire beams)

function check_player_x_collision(player_index)
    local PLAYER_STATE = emu.read(0x90 + player_index, emu.memType.cpu)
    if PLAYER_STATE ~= 0x01 then
        -- exit if player not in normal state
        return nil
    end

    -- @check_in_water_crouched
    local collision_box = 0x00
    local LEVEL_LOCATION_TYPE = emu.read(0x40 + player_index, emu.memType.cpu)
    local PLAYER_WATER_STATE = emu.read(0xb2 + player_index, emu.memType.cpu)
    if LEVEL_LOCATION_TYPE & 0xfe == 0x00 then
        -- outdoor
        local PLAYER_SPRITE_SEQUENCE = emu.read(0xbc + player_index, emu.memType.cpu)
        if PLAYER_WATER_STATE ~= 0x00 and PLAYER_SPRITE_SEQUENCE == 0x02 then
            -- exit if player crouched in water, no collision can happen with player
            return nil
        end
    end
    
    if PLAYER_WATER_STATE == 0x00 then
        collision_box = collision_box + 1
    end
    
    -- not checking for crouched while on indoor level, because non-bullets can
    -- collide when crouching player on indoor levels

    local PLAYER_JUMP_STATUS = emu.read(0xa0 + player_index, emu.memType.cpu)
    local PLAYER_SPRITE_CODE = emu.read(0xd6 + player_index, emu.memType.cpu)
    if PLAYER_JUMP_STATUS == 0x00 then
        -- player not jumping
        collision_box = collision_box + 1
        if PLAYER_SPRITE_CODE ~= 0x17 then
            collision_box = collision_box + 1
        end
    end

    -- draw player collision point
    local SPRITE_Y_POS = emu.read(0x031a + player_index, emu.memType.cpu)
    local SPRITE_X_POS = emu.read(0x0334 + player_index, emu.memType.cpu)
    emu.drawRectangle(SPRITE_X_POS, SPRITE_Y_POS, 1, 1, 0x0000ff, false)

    for i = 0,0xf do
        local ENEMY_ROUTINE = emu.read(0x04b8 + i, emu.memType.cpu)
        local ENEMY_ROUTINE = emu.read(0x04b8 + i, emu.memType.cpu)
        local ENEMY_STATE_WIDTH = emu.read(0x0598 + i, emu.memType.cpu)
        local should_test_collision = ENEMY_STATE_WIDTH & 0x01 == 0x00
        if ENEMY_ROUTINE ~= 0x00 and should_test_collision then
            set_enemy_collision_box(player_index, i, collision_box)
        end
    end
end

function set_enemy_collision_box(player_index, i, collision_box)
    local ENEMY_SCORE_COLLISION = emu.read(0x0588 + i, emu.memType.cpu) & 0x0f

    if ENEMY_SCORE_COLLISION == 0x0f then
        -- todo handle (fire beam and rising spiked wall)
        return
    end

    local collision_box_addr = emu.readWord(0xe4e8 + (collision_box * 2), emu.memType.cpu) -- collision_box_codes_tbl
    local offset = ENEMY_SCORE_COLLISION * 4
    local y0 = emu.read(collision_box_addr + offset, emu.memType.cpu)
    local x0 = emu.read(collision_box_addr + offset + 1, emu.memType.cpu)
    local height = emu.read(collision_box_addr + offset + 2, emu.memType.cpu)
    local width = emu.read(collision_box_addr + offset + 3, emu.memType.cpu)
    local ENEMY_Y_POS = emu.read(0x0324 + i, emu.memType.cpu)
    local ENEMY_X_POS = emu.read(0x033e + i, emu.memType.cpu)

    local topY = ENEMY_Y_POS
    if y0 > 0x80 then
        y0 = negateInt(y0)
        topY = ENEMY_Y_POS - y0
    else
        topY = ENEMY_Y_POS + y0
    end
    
    local topX = ENEMY_X_POS
    if x0 > 0x80 then
        x0 = negateInt(x0)
        topX = ENEMY_X_POS - x0
    else
        topX = ENEMY_X_POS + x0
    end

    emu.drawRectangle(topX, topY, width, height, 0x0000ff, false)
end

function negateInt(num)
    if(num > 0x80) then
        num = (~num + 1) & 0xff
    end

    return num
end

function Main()
    check_player_x_collision(0)
end

emu.addEventCallback(Main, emu.eventType.endFrame)