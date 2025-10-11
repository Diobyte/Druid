local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local cyclone_menu_lecerate =
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_lacerate")),
    min_max_targets    = slider_int:new(0, 30, 5, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_lacerate"))
}

local function menu()

    if cyclone_menu_lecerate.main_tab:push("Lacerate") then
        cyclone_menu_lecerate.main_boolean:render("Enable Spell", "")
 
         if cyclone_menu_lecerate.main_boolean:get() then
            cyclone_menu_lecerate.min_max_targets:render("Min hits", "Amount of targets to cast the spell")
         end

         cyclone_menu_lecerate.main_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end
local function logics()
    
    local menu_boolean = cyclone_menu_lecerate.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.lacerate.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    local area_data = target_selector.get_most_hits_target_circular_area_light(get_player_position(), 5, 5, false)
    local units = area_data.n_hits

    if units < cyclone_menu_lecerate.min_max_targets:get() then
        return false, 0;
    end;

    if cast_spell.self(spell_data.lacerate.spell_id, 0.1) then
        console.print("Druid Plugin, Casted Lacerate");
        return true, 0.1;
    end;
        
    return false, 0;
end

return
{
    menu = menu,
    logics = logics,
}
