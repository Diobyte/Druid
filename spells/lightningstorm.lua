local my_utility = require("my_utility/my_utility");
local spell_data = require("my_utility/spell_data");
local menu_manager = require("menu");

local menu_elements_lightningstorm = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_lightningstorm")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "lightningstorm_targeting_mode")),
}

local function menu()
    
    if menu_elements_lightningstorm.tree_tab:push("Lightning Storm")then
        menu_elements_lightningstorm.main_boolean:render("Enable Spell", "")
        
        if menu_elements_lightningstorm.main_boolean:get() then
            menu_manager.render_targeting_dropdown("lightningstorm", menu_elements_lightningstorm.targeting_mode)
        end
 
        menu_elements_lightningstorm.tree_tab:pop()
    end
end

local function logics(target)
    
    local menu_boolean = menu_elements_lightningstorm.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.lightningstorm.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Use prediction for skillshot accuracy
    local future_position = prediction.get_future_unit_position(target, 0.5); -- Predict 0.5 seconds ahead for channeled spell
    
    if future_position then
        if cast_spell.position(spell_data.lightningstorm.spell_id, future_position, spell_data.lightningstorm.data.cast_delay) then
            console.print("Druid Plugin, Casted Lightning Storm with prediction");
            return true, spell_data.lightningstorm.data.cast_delay;
        end;
    else
        -- Fallback to direct cast if prediction fails
        local target_position = target:get_position();
        if cast_spell.position(spell_data.lightningstorm.spell_id, target_position, spell_data.lightningstorm.data.cast_delay) then
            console.print("Druid Plugin, Casted Lightning Storm (fallback)");
            return true, spell_data.lightningstorm.data.cast_delay;
        end;
    end

    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,
    menu_elements = menu_elements_lightningstorm,
}