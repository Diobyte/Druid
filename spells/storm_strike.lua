-- ============================================================
-- STORM STRIKE
-- ============================================================
-- Lightning-infused melee ability (A-tier Stormclaw build)
-- Range: 3.5 (melee)
-- Can be configured to only cast when low on spirit (generator mode)
-- Pairs well with Claw for burst combo
-- ============================================================

local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")
local menu_manager = require("menu");

local menu_elements_storm_strike = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_storm_strike")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "storm_strike_targeting_mode")),
    only_cast_for_spirit  = checkbox:new(false, get_hash(my_utility.plugin_label .. "storm_strike_only_cast_for_spirit")),
    max_spirit_threshold  = slider_float:new(0.0, 1.0, 0.40, get_hash(my_utility.plugin_label .. "storm_strike_max_spirit_threshold")),
}

-- ============================================================
-- MENU CONFIGURATION
-- ============================================================
local function menu()
    if menu_elements_storm_strike.tree_tab:push("Storm Strike")then
        menu_elements_storm_strike.main_boolean:render("Enable Spell", "")
        
        if menu_elements_storm_strike.main_boolean:get() then
            -- Targeting mode dropdown (melee options)
            menu_manager.render_targeting_dropdown("storm_strike", menu_elements_storm_strike.targeting_mode)
            
            -- Resource management options
            menu_elements_storm_strike.only_cast_for_spirit:render("Only cast for spirit", "Only cast when spirit is below threshold")
            if menu_elements_storm_strike.only_cast_for_spirit:get() then
                menu_elements_storm_strike.max_spirit_threshold:render("Max Spirit Threshold", "Cast only when spirit is below this percentage", 2)
            end
        end
 
        menu_elements_storm_strike.tree_tab:pop()
    end
end

-- ============================================================
-- CASTING LOGIC
-- ============================================================
local function logics(target)
    -- Check if spell is enabled and available
    local menu_boolean = menu_elements_storm_strike.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.storm_strike.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    local player_local = get_local_player();

    -- Resource management: only cast if spirit is below threshold
    -- This prevents wasting spenders when spirit is already high
    if menu_elements_storm_strike.only_cast_for_spirit:get() then
        local current_spirit = player_local:get_primary_resource_current();
        local max_spirit = player_local:get_primary_resource_max();
        local spirit_percentage = current_spirit / max_spirit;
        local threshold = menu_elements_storm_strike.max_spirit_threshold:get();
        
        -- Don't cast if spirit is already above threshold
        if spirit_percentage > threshold then
            return false, 0;
        end
    end
    
    -- Cast at target
    if cast_spell.target(target, spell_data.storm_strike.data, false) then
        console.print("Druid Plugin, Casted Storm Strike");
        return true, spell_data.storm_strike.data.cast_delay;
    end;
            
    return false, 0;
end


return 
{
    menu = menu,
    logics = logics,   
    menu_elements = menu_elements_storm_strike,
}