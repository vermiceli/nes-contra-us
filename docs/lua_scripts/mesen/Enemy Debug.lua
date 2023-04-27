-- used for testing to show enemy data

function display_enemy_data()
    for i = 0,0xf do
        local ENEMY_X_POS = emu.read(0x033e + i, emu.memType.cpu)
        local ENEMY_Y_POS = emu.read(0x0324 + i, emu.memType.cpu)
        local ENEMY_ANIMATION_DELAY = emu.read(0x0538 + i, emu.memType.cpu)
        local ENEMY_ATTRIBUTES = emu.read(0x05a8 + i, emu.memType.cpu)
        local ENEMY_FRAME = emu.read(0x0568 + i, emu.memType.cpu)
        local ENEMY_HP = emu.read(0x0578 + i, emu.memType.cpu)
        local ENEMY_STATE_WIDTH = emu.read(0x0598 + i, emu.memType.cpu)
        local ENEMY_VAR_A = emu.read(0x0548 + i, emu.memType.cpu)
        local ENEMY_VAR_B = emu.read(0x0558 + i, emu.memType.cpu)
        local ENEMY_VAR_1 = emu.read(0x05b8 + i, emu.memType.cpu)
        local ENEMY_VAR_2 = emu.read(0x05c8 + i, emu.memType.cpu)
        local ENEMY_VAR_3 = emu.read(0x05d8 + i, emu.memType.cpu)
        local ENEMY_VAR_4 = emu.read(0x05e8 + i, emu.memType.cpu)
        local ENEMY_SPRITES = emu.read(0x030a + i, emu.memType.cpu)
        local ENEMY_ROUTINE = emu.read(0x04b8 + i, emu.memType.cpu)
        local ENEMY_ATTACK_DELAY = ENEMY_VAR_B
        local ENEMY_X_VELOCITY_FAST = emu.read(0x0508 + i, emu.memType.cpu)
        local ENEMY_X_VELOCITY_FRACT = emu.read(0x0518 + i, emu.memType.cpu)
        local ENEMY_X_VEL_ACCUM = emu.read(0x04d8 + i, emu.memType.cpu)
        local ENEMY_Y_VELOCITY_FAST = emu.read(0x04e8 + i, emu.memType.cpu)
        local ENEMY_Y_VELOCITY_FRACT = emu.read(0x04f8 + i, emu.memType.cpu)
        local ENEMY_Y_VEL_ACCUM = emu.read(0x04c8 + i, emu.memType.cpu)

        -- change variable to interested variable for studying
        emu.drawString(ENEMY_X_POS, ENEMY_Y_POS, string.format("%x", ENEMY_HP))
    end
end

function Main()
    display_enemy_data()
end

emu.addEventCallback(Main, emu.eventType.endFrame)