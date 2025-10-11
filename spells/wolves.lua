local my_utility = require("my_utility/my_utility");
local spell_data = require("my_utility/spell_data");
local menu_manager = require("menu");

local menu_elements_wolves = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_wolves")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "wolves_targeting_mode")),
}

local function menu()
    
    if menu_elements_wolves.tree_tab:push("Wolves")then
        menu_elements_wolves.main_boolean:render("Enable Spell", "")
        
        if menu_elements_wolves.main_boolean:get() then
            menu_manager.render_targeting_dropdown("wolves", menu_elements_wolves.targeting_mode)
        end
 
        menu_elements_wolves.tree_tab:pop()
    end
end

local function logics(target)
    
    local menu_boolean = menu_elements_wolves.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.wolves.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    if cast_spell.target(target, spell_data.wolves.data, false) then
        console.print("Druid Plugin, Casted Wolves");
        return true, spell_data.wolves.data.cast_delay;
    end;

    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,
    menu_elements = menu_elements_wolves,
}