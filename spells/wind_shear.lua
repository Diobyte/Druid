local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")
local menu_manager = require("menu");

local menu_elements_wind_shear = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_wind_shear")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "wind_shear_targeting_mode")),
    only_cast_for_spirit  = checkbox:new(false, get_hash(my_utility.plugin_label .. "wind_shear_only_cast_for_spirit")),
    max_spirit_threshold  = slider_float:new(0.0, 1.0, 0.40, get_hash(my_utility.plugin_label .. "wind_shear_max_spirit_threshold")),
}

local function menu()
    
    if menu_elements_wind_shear.tree_tab:push("Wind Shear")then
        menu_elements_wind_shear.main_boolean:render("Enable Spell", "")
        
        if menu_elements_wind_shear.main_boolean:get() then
            menu_manager.render_targeting_dropdown("wind_shear", menu_elements_wind_shear.targeting_mode)
            
            menu_elements_wind_shear.only_cast_for_spirit:render("Only cast for spirit", "Only cast when spirit is below threshold")
            if menu_elements_wind_shear.only_cast_for_spirit:get() then
                menu_elements_wind_shear.max_spirit_threshold:render("Max Spirit Threshold", "Cast only when spirit is below this percentage", 2)
            end
        end
 
        menu_elements_wind_shear.tree_tab:pop()
    end
end

local function logics(target)
    
    local menu_boolean = menu_elements_wind_shear.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.wind_shear.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    local player_local = get_local_player();

    -- Check spirit threshold if enabled
    if menu_elements_wind_shear.only_cast_for_spirit:get() then
        local current_spirit = player_local:get_primary_resource_current();
        local max_spirit = player_local:get_primary_resource_max();
        local spirit_percentage = current_spirit / max_spirit;
        local threshold = menu_elements_wind_shear.max_spirit_threshold:get();
        
        if spirit_percentage > threshold then
            return false, 0;
        end
    end
    
    -- Use prediction for skillshot accuracy
    local future_position = prediction.get_future_unit_position(target, 0.2); -- Predict 0.2 seconds ahead for fast projectile
    
    if future_position then
        if cast_spell.position(spell_data.wind_shear.spell_id, future_position, spell_data.wind_shear.data.cast_delay) then
            console.print("Druid Plugin, Casted Wind Shear with prediction");
            return true, spell_data.wind_shear.data.cast_delay;
        end;
    else
        -- Fallback to direct cast if prediction fails
        local target_position = target:get_position();
        if cast_spell.position(spell_data.wind_shear.spell_id, target_position, spell_data.wind_shear.data.cast_delay) then
            console.print("Druid Plugin, Casted Wind Shear (fallback)");
            return true, spell_data.wind_shear.data.cast_delay;
        end;
    end
            
    return false, 0;
end


return 
{
    menu = menu,
    logics = logics,   
    menu_elements = menu_elements_wind_shear,
}