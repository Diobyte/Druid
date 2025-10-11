local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local grizzly_rage_menu_elements_base = 
{
    main_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_grizzly")),
    enemy_type_filter  = combo_box:new(0, get_hash(my_utility.plugin_label .. "grizzly_rage_enemy_type_filter")),
    use_minimum_weight = checkbox:new(false, get_hash(my_utility.plugin_label .. "grizzly_rage_use_minimum_weight")),
    minimum_weight     = slider_int:new(2, 15, 2, get_hash(my_utility.plugin_label .. "grizzly_rage_minimum_weight")),
}
local function menu()                                                                              
    if grizzly_rage_menu_elements_base.main_tab:push("Grizzly Rage")then
        grizzly_rage_menu_elements_base.main_boolean:render("Enable Spell", "")
        
        if grizzly_rage_menu_elements_base.main_boolean:get() then
            grizzly_rage_menu_elements_base.enemy_type_filter:render("Enemy Type", my_utility.aoe_enemy_filters, "Filter which enemy types can trigger this spell")
            
            -- Only show minimum targets options if filter is set to "Any"
            if grizzly_rage_menu_elements_base.enemy_type_filter:get() == 0 then
                grizzly_rage_menu_elements_base.use_minimum_weight:render("Minimum Targets in Area", "Enable minimum target count requirement")
                if grizzly_rage_menu_elements_base.use_minimum_weight:get() then
                    grizzly_rage_menu_elements_base.minimum_weight:render("Target Count", "Minimum target count required to cast (2-15)")
                end
            end
        end
 
        grizzly_rage_menu_elements_base.main_tab:pop()
    end
end

local function logics()

    local menu_boolean = grizzly_rage_menu_elements_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.grizzly_rage.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    if cast_spell.self(spell_data.grizzly_rage.spell_id, 0.0) then
        console.print("Druid Plugin, Casted Grizzly Rage");
        return true, 0.1;
    end;
            
    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,
    menu_elements = grizzly_rage_menu_elements_base,
}