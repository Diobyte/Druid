-- ============================================================
-- DRUID ROTATION - MENU SYSTEM
-- ============================================================
-- Defines all configuration options for the Druid rotation script
-- Each menu element requires a unique hash ID to prevent conflicts
-- ============================================================

local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local menu_elements =
{
    -- Main plugin toggle
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean")),
    
    -- Menu structure (tree depth: 0=main, 1=submenu, etc.)
    main_tree           = tree_node:new(0),
    
    -- Spell organization trees
    active_spells_tree = tree_node:new(1),      -- Currently equipped spells
    inactive_spells_tree = tree_node:new(1),    -- Unequipped spells (still configurable)
    
    -- ========================================
    -- TARGETING SYSTEM
    -- ========================================
    targeting_refresh_interval = slider_float:new(0.1, 1.0, 0.2, get_hash(my_utility.plugin_label .. "targeting_refresh_interval")),
    
    -- Cursor-based targeting (manual aim)
    cursor_targeting_enabled = checkbox:new(false, get_hash(my_utility.plugin_label .. "cursor_targeting_enabled")),
    cursor_targeting_radius = slider_float:new(0.1, 6.0, 3.0, get_hash(my_utility.plugin_label .. "cursor_targeting_radius")),
    cursor_targeting_angle = slider_int:new(20, 50, 30, get_hash(my_utility.plugin_label .. "cursor_targeting_angle")),
    
    -- Advanced weighted targeting system
    weighted_targeting_tree = tree_node:new(1),
    weighted_targeting_enabled = checkbox:new(true, get_hash(my_utility.plugin_label .. "weighted_targeting_enabled")),
    weighted_targeting_debug = checkbox:new(false, get_hash(my_utility.plugin_label .. "weighted_targeting_debug")),
    
    -- ========================================
    -- DEBUG & CONTROL OPTIONS
    -- ========================================
    melee_debug_mode = checkbox:new(false, get_hash(my_utility.plugin_label .. "melee_debug_mode")),
    manual_play = checkbox:new(false, get_hash(my_utility.plugin_label .. "manual_play")),
    disable_melee_movement_during_evade = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_melee_movement_during_evade")),
    
    -- ========================================
    -- WEIGHTED TARGETING CONFIGURATION
    -- ========================================
    -- Scan area settings
    scan_radius = slider_int:new(1, 30, 16, get_hash(my_utility.plugin_label .. "scan_radius")),
    scan_refresh_rate = slider_float:new(0.1, 1.0, 0.2, get_hash(my_utility.plugin_label .. "scan_refresh_rate")),
    min_targets = slider_int:new(1, 10, 1, get_hash(my_utility.plugin_label .. "min_targets")),
    comparison_radius = slider_float:new(0.1, 6.0, 3.0, get_hash(my_utility.plugin_label .. "comparison_radius")),
    
    -- Enemy type configuration toggle
    custom_enemy_sliders_enabled = checkbox:new(false, get_hash(my_utility.plugin_label .. "custom_enemy_sliders_enabled")),
    
    -- Target count values (for cluster validation)
    normal_target_count = slider_int:new(1, 10, 1, get_hash(my_utility.plugin_label .. "normal_target_count")),
    champion_target_count = slider_int:new(1, 10, 5, get_hash(my_utility.plugin_label .. "champion_target_count")),
    elite_target_count = slider_int:new(1, 10, 5, get_hash(my_utility.plugin_label .. "elite_target_count")),
    boss_target_count = slider_int:new(1, 10, 5, get_hash(my_utility.plugin_label .. "boss_target_count")),
    
    -- Target priority weights (within valid clusters)
    boss_weight = slider_int:new(1, 100, 50, get_hash(my_utility.plugin_label .. "boss_weight")),
    elite_weight = slider_int:new(1, 100, 10, get_hash(my_utility.plugin_label .. "elite_weight")),
    champion_weight = slider_int:new(1, 100, 15, get_hash(my_utility.plugin_label .. "champion_weight")),
    any_weight = slider_int:new(1, 100, 2, get_hash(my_utility.plugin_label .. "any_weight")),
    
    -- Special buff/debuff targeting weights
    custom_buff_weights_enabled = checkbox:new(false, get_hash(my_utility.plugin_label .. "custom_buff_weights_enabled")),
    damage_resistance_provider_weight = slider_int:new(1, 100, 30, get_hash(my_utility.plugin_label .. "damage_resistance_provider_weight")),
    damage_resistance_receiver_penalty = slider_int:new(0, 20, 5, get_hash(my_utility.plugin_label .. "damage_resistance_receiver_penalty")),
    horde_objective_weight = slider_int:new(1, 100, 50, get_hash(my_utility.plugin_label .. "horde_objective_weight")),
    vulnerable_debuff_weight = slider_int:new(1, 5, 1, get_hash(my_utility.plugin_label .. "vulnerable_debuff_weight")),
}

-- ============================================================
-- TARGETING MODE DEFINITIONS
-- ============================================================
-- Different spell types get different targeting options:
--   • Melee spells: 6 options (melee-focused)
--   • Ranged spells: 6 options (ranged-focused)
--   • Universal spells: 8 options (all modes available)
-- ============================================================

local targeting_modes = {
    melee_options = {
        "Melee Target",                 -- Closest enemy within melee range
        "Melee Target (in sight)",      -- Closest visible melee enemy
        "Closest Target",               -- Closest enemy regardless of range
        "Closest Target (in sight)",    -- Closest visible enemy
        "Best Cursor Target",           -- Highest priority near cursor
        "Closest Cursor Target"         -- Nearest to cursor position
    },
    ranged_options = {
        "Ranged Target",                -- Closest enemy within ranged range
        "Ranged Target (in sight)",     -- Closest visible ranged enemy
        "Closest Target",               -- Closest enemy regardless of range
        "Closest Target (in sight)",    -- Closest visible enemy
        "Best Cursor Target",           -- Highest priority near cursor
        "Closest Cursor Target"         -- Nearest to cursor position
    },
    universal_options = {
        "Melee Target",                 -- Closest enemy within melee range
        "Melee Target (in sight)",      -- Closest visible melee enemy
        "Ranged Target",                -- Closest enemy within ranged range
        "Ranged Target (in sight)",     -- Closest visible ranged enemy
        "Closest Target",               -- Closest enemy regardless of range
        "Closest Target (in sight)",    -- Closest visible enemy
        "Best Cursor Target",           -- Highest priority near cursor
        "Closest Cursor Target"         -- Nearest to cursor position
    }
}

-- ============================================================
-- TARGETING HELPER FUNCTIONS
-- ============================================================

-- Determines which targeting options to show based on spell type
-- Melee spells get melee options, ranged get ranged, others get all
local function get_targeting_options_for_spell(spell_name)
    local spell_info = spell_data[spell_name]
    if not spell_info or not spell_info.classification then
        return targeting_modes.universal_options
    end
    
    local classification = spell_info.classification
    
    if classification == "melee" then
        return targeting_modes.melee_options
    elseif classification == "ranged" or classification == "ranged_channeled" then
        return targeting_modes.ranged_options
    else
        -- Buff/debuff/ultimate/utility spells get all options
        return targeting_modes.universal_options
    end
end

-- Renders the targeting dropdown for a spell with appropriate options
local function render_targeting_dropdown(spell_name, targeting_mode_element)
    local options = get_targeting_options_for_spell(spell_name)
    targeting_mode_element:render("Targeting Mode", options, "Select which target to cast this spell on")
end

menu_elements.targeting_modes = targeting_modes
menu_elements.get_targeting_options_for_spell = get_targeting_options_for_spell
menu_elements.render_targeting_dropdown = render_targeting_dropdown

return menu_elements;