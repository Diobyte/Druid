local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local menu_elements_pois_creep = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_poison_creeper")),
}
local function menu()                                                                              
    if menu_elements_pois_creep.main_tab:push("Poison Creeper")then
        menu_elements_pois_creep.main_boolean:render("Enable Spell", "")
 
        menu_elements_pois_creep.main_tab:pop()
    end
end

local function logics()

    local menu_boolean = menu_elements_pois_creep.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.poison_creeper.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    if cast_spell.self(spell_data.poison_creeper.spell_id, 0.0) then
        console.print("Druid Plugin, Casted Poison Creeper");
        return true, 0.1;
    end;
        
    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,   
}