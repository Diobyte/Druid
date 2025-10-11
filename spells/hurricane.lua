local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local hurricane_menu_elements_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "hurricane_boolean")),
    enemy_type_filter   = combo_box:new(0, get_hash(my_utility.plugin_label .. "hurricane_enemy_type_filter")),
    use_minimum_weight  = checkbox:new(false, get_hash(my_utility.plugin_label .. "hurricane_use_minimum_weight")),
    minimum_weight      = slider_int:new(2, 15, 2, get_hash(my_utility.plugin_label .. "hurricane_minimum_weight")),
}

local function menu()
    if hurricane_menu_elements_base.tree_tab:push("Hurricane")then
        hurricane_menu_elements_base.main_boolean:render("Enable Spell", "")
        
        if hurricane_menu_elements_base.main_boolean:get() then
            hurricane_menu_elements_base.enemy_type_filter:render("Enemy Type", my_utility.aoe_enemy_filters, "Filter which enemy types can trigger this spell")
            
            -- Only show minimum targets options if filter is set to "Any"
            if hurricane_menu_elements_base.enemy_type_filter:get() == 0 then
                hurricane_menu_elements_base.use_minimum_weight:render("Minimum Targets in Area", "Enable minimum target count requirement")
                if hurricane_menu_elements_base.use_minimum_weight:get() then
                    hurricane_menu_elements_base.minimum_weight:render("Target Count", "Minimum target count required to cast (2-15)")
                end
            end
        end
 
        hurricane_menu_elements_base.tree_tab:pop()
    end
end

local function logics(player_position)

    local menu_boolean = hurricane_menu_elements_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.hurricane.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Hurricane is a self-cast buff (PBAoE)
    if cast_spell.self(spell_data.hurricane.spell_id, 0.2) then
        console.print("Druid Plugin, Casted Hurricane");
        return true, 0.2;
    end;
            
    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,
    menu_elements = hurricane_menu_elements_base,
}