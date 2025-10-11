local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")
local menu_manager = require("menu")

local max_spell_range = 19
local menu_elements_trample =
{
    tree_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_trample")),
    targeting_mode          = combo_box:new(0, get_hash(my_utility.plugin_label .. "trample_targeting_mode")),
    mobility_only           = checkbox:new(false, get_hash(my_utility.plugin_label .. "_trample_mobility_only")),
    min_target_range        = slider_float:new(3, max_spell_range - 1, 3,
        get_hash(my_utility.plugin_label .. "_trample_min_target_range")),
    require_min_spirit      = checkbox:new(false, get_hash(my_utility.plugin_label .. "trample_require_spirit")),
    min_spirit_threshold    = slider_float:new(0.0, 1.0, 0.25, get_hash(my_utility.plugin_label .. "trample_min_spirit_threshold")),
}

local function menu()
    if menu_elements_trample.tree_tab:push("Trample") then
        menu_elements_trample.main_boolean:render("Enable Spell", "")

        if menu_elements_trample.main_boolean:get() then
            menu_manager.render_targeting_dropdown("trample", menu_elements_trample.targeting_mode)
            menu_elements_trample.mobility_only:render("Only use for mobility", "")
            if menu_elements_trample.mobility_only:get() then
                menu_elements_trample.min_target_range:render("Minimum Target Range",
                    "\n     Must be lower than Max Targeting Range     \n\n", 1)
            end
            menu_elements_trample.require_min_spirit:render("Require Minimum Spirit", "Only cast when spirit is above threshold")
            if menu_elements_trample.require_min_spirit:get() then
                menu_elements_trample.min_spirit_threshold:render("Min Spirit Threshold", "Cast only when spirit is above this percentage", 2)
            end
        end

        menu_elements_trample.tree_tab:pop()
    end
end

local function logics(target)
    if not target then return false, 0 end;
    
    local menu_boolean = menu_elements_trample.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        0,
        spell_data.trample.spell_id);

    if not is_logic_allowed then return false, 0 end;

    -- Check spirit threshold if enabled
    if menu_elements_trample.require_min_spirit:get() then
        local player_local = get_local_player();
        if player_local then
            local current_spirit = player_local:get_primary_resource_current();
            local max_spirit = player_local:get_primary_resource_max();
            local spirit_percentage = current_spirit / max_spirit;
            local threshold = menu_elements_trample.min_spirit_threshold:get();
            
            if spirit_percentage < threshold then
                return false, 0;
            end
        end
    end

    local mobility_only = menu_elements_trample.mobility_only:get();
    if mobility_only then
        local player_pos = get_player_position()
        local target_pos = target:get_position()
        local distance = player_pos:dist_to(target_pos)
        
        if distance > max_spell_range or distance < menu_elements_trample.min_target_range:get() then
            return false, 0
        end
    end

    if cast_spell.target(target, spell_data.trample.data, false) then
        console.print("Cast Trample");
        return true, spell_data.trample.data.cast_delay;
    end;

    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,   
    menu_elements = menu_elements_trample
}
