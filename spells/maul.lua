local my_utility = require("my_utility/my_utility");
local spell_data = require("my_utility/spell_data");
local menu_manager = require("menu");

local menu_elements_maul = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_maul")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "maul_targeting_mode")),
    only_cast_for_spirit  = checkbox:new(false, get_hash(my_utility.plugin_label .. "maul_only_cast_for_spirit")),
    max_spirit_threshold  = slider_float:new(0.0, 1.0, 0.40, get_hash(my_utility.plugin_label .. "maul_max_spirit_threshold")),
}

local function menu()
    
    if menu_elements_maul.tree_tab:push("Maul") then
        menu_elements_maul.main_boolean:render("Enable Spell", "")

        if  menu_elements_maul.main_boolean:get() then
            menu_manager.render_targeting_dropdown("maul", menu_elements_maul.targeting_mode)
            
            menu_elements_maul.only_cast_for_spirit:render("Only cast for spirit", "Only cast when spirit is below threshold")
            if menu_elements_maul.only_cast_for_spirit:get() then
                menu_elements_maul.max_spirit_threshold:render("Max Spirit Threshold", "Cast only when spirit is below this percentage", 2)
            end
        end
 
        menu_elements_maul.tree_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end

local function logics(target)
    
    local menu_boolean = menu_elements_maul.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0,
                spell_data.maul.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    local player_local = get_local_player();

    -- Check spirit threshold if enabled
    if menu_elements_maul.only_cast_for_spirit:get() then
        local current_spirit = player_local:get_primary_resource_current();
        local max_spirit = player_local:get_primary_resource_max();
        local spirit_percentage = current_spirit / max_spirit;
        local threshold = menu_elements_maul.max_spirit_threshold:get();
        
        if spirit_percentage > threshold then
            return false, 0;
        end
    end

    if cast_spell.target(target, spell_data.maul.data, false) then
        return true, spell_data.maul.data.cast_delay;
    end;

    return false, 0;
end

return
{
    menu = menu,
    logics = logics,
    menu_elements = menu_elements_maul,
}
