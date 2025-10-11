local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local petrify_menu_elements =
{
    tree_tab           = tree_node:new(1),
    main_boolean       = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_petrify")),
    enemy_type_filter  = combo_box:new(0, get_hash(my_utility.plugin_label .. "petrify_enemy_type_filter")),
    use_minimum_weight = checkbox:new(false, get_hash(my_utility.plugin_label .. "petrify_use_minimum_weight")),
    minimum_weight     = slider_int:new(2, 15, 2, get_hash(my_utility.plugin_label .. "petrify_minimum_weight")),
}

local function menu()
    if petrify_menu_elements.tree_tab:push("Petrify") then
        petrify_menu_elements.main_boolean:render("Enable Spell", "")
 
        if petrify_menu_elements.main_boolean:get() then
            petrify_menu_elements.enemy_type_filter:render("Enemy Type", my_utility.aoe_enemy_filters, "Filter which enemy types can trigger this spell")
            
            -- Only show minimum targets options if filter is set to "Any"
            if petrify_menu_elements.enemy_type_filter:get() == 0 then
                petrify_menu_elements.use_minimum_weight:render("Minimum Targets in Area", "Enable minimum target count requirement")
                if petrify_menu_elements.use_minimum_weight:get() then
                    petrify_menu_elements.minimum_weight:render("Target Count", "Minimum target count required to cast (2-15)")
                end
            end
        end

        petrify_menu_elements.tree_tab:pop()
    end
end

local function logics()
    local menu_boolean = petrify_menu_elements.main_boolean:get()
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.petrify.spell_id)

    if not is_logic_allowed then
        return false, 0
    end

    if cast_spell.self(spell_data.petrify.spell_id, 0.2) then
        console.print("Druid Plugin, Petrify")
        return true, 0.2
    end
    
    return false, 0
end

return
{
    menu = menu,
    logics = logics,
    menu_elements = petrify_menu_elements,
}
