-- one table to rule them all!
local Global = require 'utils.global'
local Spells = require 'rpg.spells'
local Gui = require 'utils.gui'

local this = {
    rpg_extra = {
        debug = false,
        breached_walls = 1,
        reward_new_players = 0,
        level_limit_enabled = false,
        global_pool = 0,
        personal_tax_rate = 0.3,
        leftover_pool = 0,
        turret_kills_to_global_pool = true,
        difficulty = false,
        surface_name = 'nauvis',
        enable_health_and_mana_bars = true,
        enable_mana = true,
        mana_limit = 1500,
        enable_wave_defense = false,
        enable_flame_boots = true,
        mana_per_tick = 0.1,
        force_mana_per_tick = false,
        enable_stone_path = true,
        enable_one_punch = true,
        enable_one_punch_globally = true,
        rpg_xp_yield = {
            ['behemoth-biter'] = 16,
            ['behemoth-spitter'] = 16,
            ['behemoth-worm-turret'] = 64,
            ['big-biter'] = 8,
            ['big-spitter'] = 8,
            ['big-worm-turret'] = 48,
            ['biter-spawner'] = 64,
            ['character'] = 16,
            ['gun-turret'] = 8,
            ['laser-turret'] = 16,
            ['medium-biter'] = 4,
            ['medium-spitter'] = 4,
            ['medium-worm-turret'] = 32,
            ['small-biter'] = 1,
            ['small-spitter'] = 1,
            ['small-worm-turret'] = 16,
            ['spitter-spawner'] = 64
        }
    },
    rpg_t = {},
    rpg_spells = Spells.conjure_items()
}

--! Gui Frames
local settings_frame_name = Gui.uid_name()
local save_button_name = Gui.uid_name()
local discard_button_name = Gui.uid_name()
local draw_main_frame_name = Gui.uid_name()
local main_frame_name = Gui.uid_name()
local settings_button_name = Gui.uid_name()

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

local Public = {}

Public.rpg_frame_icons = {
    'entity/small-worm-turret',
    'entity/medium-worm-turret',
    'entity/big-worm-turret',
    'entity/behemoth-worm-turret',
    'entity/small-biter',
    'entity/small-biter',
    'entity/small-spitter',
    'entity/medium-biter',
    'entity/medium-biter',
    'entity/medium-spitter',
    'entity/big-biter',
    'entity/big-biter',
    'entity/big-spitter',
    'entity/behemoth-biter',
    'entity/behemoth-biter',
    'entity/behemoth-spitter'
}

Public.points_per_level = 5

Public.experience_levels = {0}
for a = 1, 9999, 1 do
    Public.experience_levels[#Public.experience_levels + 1] =
        Public.experience_levels[#Public.experience_levels] + a * 8
end

Public.die_cause = {
    ['ammo-turret'] = true,
    ['electric-turret'] = true,
    ['fluid-turret'] = true
}

Public.nth_tick = 18001
Public.visuals_delay = 1800
Public.xp_floating_text_color = {157, 157, 157}

Public.teller_global_pool = '[color=blue]Global Pool Reward:[/color] \n'
Public.teller_level_limit = '[color=blue]Level Limit:[/color] \n'

Public.enemy_types = {
    ['unit'] = true,
    ['unit-spawner'] = true,
    ['turret'] = true
}

Public.classes = {
    ['engineer'] = 'ENGINEER',
    ['strength'] = 'MINER',
    ['magicka'] = 'SCIENTIST',
    ['dexterity'] = 'BEASTMASTER',
    ['vitality'] = 'SOLDIER'
}

--- Gets value from table
---@param key <string>
function Public.get(key)
    if key then
        return this[key]
    else
        return this
    end
end

--- Sets value to table
---@param key <string>
function Public.set(key)
    if key then
        return this[key]
    else
        return this
    end
end

--- Toggle debug - when you need to troubleshoot.
function Public.toggle_debug()
    if this.rpg_extra.debug then
        this.rpg_extra.debug = false
    else
        this.rpg_extra.debug = true
    end

    return this.rpg_extra.debug
end

--- Debug only - when you need to troubleshoot.
---@param str <string>
function Public.debug_log(str)
    if not this.rpg_extra.debug then
        return
    end
    print(str)
end

--- Sets surface name for rpg_v2 to use
---@param name <string>
function Public.set_surface_name(name)
    if name then
        this.rpg_extra.surface_name = name
    else
        return error('No surface name given.', 2)
    end

    return this.rpg_extra.surface_name
end

--- Enables the bars that shows above the player character.
--- If you disable mana but enable <enable_health_and_mana_bars> then only health will be shown
---@param value <boolean>
function Public.enable_health_and_mana_bars(value)
    if value then
        this.rpg_extra.enable_health_and_mana_bars = value
    else
        this.rpg_extra.enable_health_and_mana_bars = false
    end

    return this.rpg_extra.enable_health_and_mana_bars
end

--- Enables the mana feature that allows players to spawn entities.
---@param value <boolean>
function Public.enable_mana(value)
    if value then
        this.rpg_extra.enable_mana = value
    else
        this.rpg_extra.enable_mana = false
    end

    return this.rpg_extra.enable_mana
end

--- This should only be enabled if wave_defense is enabled.
--- It boosts the amount of xp the players get after x amount of waves.
---@param value <boolean>
function Public.enable_wave_defense(value)
    if value then
        this.rpg_extra.enable_wave_defense = value
    else
        this.rpg_extra.enable_wave_defense = false
    end

    return this.rpg_extra.enable_wave_defense
end

--- Enables/disabled flame boots.
---@param value <boolean>
function Public.enable_flame_boots(value)
    if value then
        this.rpg_extra.enable_flame_boots = value
    else
        this.rpg_extra.enable_flame_boots = false
    end

    return this.rpg_extra.enable_flame_boots
end

--- Enables/disabled personal tax.
---@param value <boolean>
function Public.personal_tax_rate(value)
    if value then
        this.rpg_extra.personal_tax_rate = value
    else
        this.rpg_extra.personal_tax_rate = false
    end

    return this.rpg_extra.personal_tax_rate
end

--- Enables/disabled stone-path-tile creation on mined.
---@param value <boolean>
function Public.enable_stone_path(value)
    if value then
        this.rpg_extra.enable_stone_path = value
    else
        this.rpg_extra.enable_stone_path = false
    end

    return this.rpg_extra.enable_stone_path
end

--- Enables/disabled stone-path-tile creation on mined.
---@param value <boolean>
function Public.enable_one_punch(value)
    if value then
        this.rpg_extra.enable_one_punch = value
    else
        this.rpg_extra.enable_one_punch = false
    end

    return this.rpg_extra.enable_one_punch
end

--- Enables/disabled stone-path-tile creation on mined.
---@param value <boolean>
function Public.enable_one_punch_globally(value)
    if value then
        this.rpg_extra.enable_one_punch_globally = value
    else
        this.rpg_extra.enable_one_punch_globally = false
    end

    return this.rpg_extra.enable_one_punch_globally
end

--- Retrieves the spells table or a given spell.
---@param key <string>
function Public.get_spells(key)
    if this.rpg_spells[key] then
        return this.rpg_spells[key]
    else
        return this.rpg_spells
    end
end

--- Disables a spell.
---@param key <string/table>
-- Table would look like:
-- Public.disable_spell({1, 2, 3, 4, 5, 6, 7, 8})
function Public.disable_spell(key)
    if type(key) == 'table' then
        for _, k in pairs(key) do
            this.rpg_spells[k].enabled = false
        end
    elseif this.rpg_spells[key] then
        this.rpg_spells[key].enabled = false
    end
end

--- Clears the spell table.
function Public.clear_spell_table()
    this.rpg_spells = {}
end

--- Adds a spell to the rpg_spells
---@param tbl <table>
function Public.set_new_spell(tbl)
    if tbl then
        if not tbl.name then
            return error('A spell requires a name. <string>', 2)
        end
        if not tbl.obj_to_create then
            return error('A spell requires an object to create. <string>', 2)
        end
        if not tbl.target then
            return error('A spell requires position. <boolean>', 2)
        end
        if not tbl.amount then
            return error('A spell requires an amount of creation. <integer>', 2)
        end
        if not tbl.range then
            return error('A spell requires a range. <integer>', 2)
        end
        if not tbl.damage then
            return error('A spell requires damage. <damage-area=true/false>', 2)
        end
        if not tbl.force then
            return error('A spell requires a force. <string>', 2)
        end
        if not tbl.level then
            return error('A spell requires a level. <integer>', 2)
        end
        if not tbl.type then
            return error('A spell requires a type. <item/entity/special>', 2)
        end
        if not tbl.mana_cost then
            return error('A spell requires mana_cost. <integer>', 2)
        end
        if not tbl.tick then
            return error('A spell requires tick. <integer>', 2)
        end
        if not tbl.enabled then
            return error('A spell requires enabled. <boolean>', 2)
        end

        this.rpg_spells[#this.rpg_spells + 1] = tbl
    end
end

--- This rebuilds all spells. Make sure to make changes on_init if you don't
--  want all spells enabled.
function Public.rebuild_spells()
    local spells = this.rpg_spells

    local new_spells = {}
    local spell_names = {}

    for i = 1, #spells do
        if spells[i].enabled then
            new_spells[#new_spells + 1] = spells[i]
            spell_names[#spell_names + 1] = spells[i].name
        end
    end

    this.rpg_spells = new_spells

    return new_spells, spell_names
end

--- This will disable the cooldown of all spells.
function Public.disable_cooldowns_on_spells()
    local spells = this.rpg_spells

    local new_spells = {}

    for i = 1, #spells do
        if spells[i].enabled then
            spells[i].tick = 0
            new_spells[#new_spells + 1] = spells[i]
        end
    end

    this.rpg_spells = new_spells

    return new_spells
end

Public.get_projectiles = Spells.projectile_types
Public.settings_frame_name = settings_frame_name
Public.save_button_name = save_button_name
Public.discard_button_name = discard_button_name
Public.draw_main_frame_name = draw_main_frame_name
Public.main_frame_name = main_frame_name
Public.settings_button_name = settings_button_name

return Public
