local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")
local menu_manager = require("menu");

local menu_elements_shred =
{
    tree_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "_shred_main_boolean")),
    targeting_mode        = combo_box:new(0, get_hash(my_utility.plugin_label .. "shred_targeting_mode")),
    track_buff_stacks       = checkbox:new(false, get_hash(my_utility.plugin_label .. "_shred_track_buff")),
}

local function menu()
    if menu_elements_shred.tree_tab:push("Shred")then
        menu_elements_shred.main_boolean:render("Enable Spell", "")
  
        if menu_elements_shred.main_boolean:get() then
            menu_manager.render_targeting_dropdown("shred", menu_elements_shred.targeting_mode)
            menu_elements_shred.track_buff_stacks:render("Track Buff Stacks", "Display console info about Shred buff stacks")
        end
    
        menu_elements_shred.tree_tab:pop()
     end
end

local function logics(target)

    local menu_boolean = menu_elements_shred.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.shred.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Track Shred buff stacks if enabled
    if menu_elements_shred.track_buff_stacks:get() then
        local local_player = get_local_player()
        if local_player then
            local has_buff = my_utility.has_buff(local_player, spell_data.shred.buff_id)
            if has_buff then
                console.print("Shred buff is active")
            end
        end
    end

    if cast_spell.target(target, spell_data.shred.data, false) then
        console.print("Druid Plugin, Casted Shred");
        return true, spell_data.shred.data.cast_delay;
    end;

    return false, 0;
end

return 
{
    menu = menu,
    logics = logics,   
    menu_elements = menu_elements_shred,
}

       