local my_utility = require("my_utility/my_utility");
local spell_data = require("my_utility/spell_data");
local menu_manager = require("menu");

local menu_elements_rabies = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_rabies")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "rabies_targeting_mode")),
}

local function menu()
    
    if menu_elements_rabies.tree_tab:push("Rabies")then
        menu_elements_rabies.main_boolean:render("Enable Spell", "")
        
        if menu_elements_rabies.main_boolean:get() then
            menu_manager.render_targeting_dropdown("rabies", menu_elements_rabies.targeting_mode)
        end
 
        menu_elements_rabies.tree_tab:pop()
    end
end

local function logics(target)
    
    local menu_boolean = menu_elements_rabies.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.rabies.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    if cast_spell.target(target, spell_data.rabies.data, false) then
        console.print("Druid Plugin, Casted Rabies");
        return true, spell_data.rabies.data.cast_delay;
    end;

    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,   
    menu_elements = menu_elements_rabies,
}