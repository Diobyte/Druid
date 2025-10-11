local my_utility = require("my_utility/my_utility");
local spell_data = require("my_utility/spell_data");
local menu_manager = require("menu");

local menu_elements_pulverize = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_pulverize")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "pulverize_targeting_mode")),
    blt_aspect_toggle     = checkbox:new(false, get_hash(my_utility.plugin_label .. "pulverize_blt_aspect")),
}

local function menu()
    
    if menu_elements_pulverize.tree_tab:push("Pulverize")then
        menu_elements_pulverize.main_boolean:render("Enable Spell", "")
        
        if menu_elements_pulverize.main_boolean:get() then
            menu_manager.render_targeting_dropdown("pulverize", menu_elements_pulverize.targeting_mode)
            menu_elements_pulverize.blt_aspect_toggle:render("BLT Aspect", "Only cast if spirit is 275 or higher")
        end
 
        menu_elements_pulverize.tree_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end

local function logics(target)
    
    local menu_boolean = menu_elements_pulverize.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0,
                spell_data.pulverize.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Check BLT Aspect spirit requirement if enabled
    if menu_elements_pulverize.blt_aspect_toggle:get() then
        local player_local = get_local_player();
        local current_spirit = player_local:get_primary_resource_current();
        
        if current_spirit < 275 then
            return false, 0;
        end
    end

    if cast_spell.target(target, spell_data.pulverize.data, false) then
        return true, spell_data.pulverize.data.cast_delay;
    end;

    return false, 0;
end

return
{
    menu = menu,
    logics = logics,
    menu_elements = menu_elements_pulverize,
}

