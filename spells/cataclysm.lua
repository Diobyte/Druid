local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local cataclysm_menu_elements =
{
    main_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_cataclysm")),
    only_cast_if_not_active = checkbox:new(true, get_hash(my_utility.plugin_label .. "cataclysm_only_cast_if_not_active")),
}

local function menu()

    if cataclysm_menu_elements.main_tab:push("Cataclysm")then
        cataclysm_menu_elements.main_boolean:render("Enable Spell", "")
        cataclysm_menu_elements.only_cast_if_not_active:render("Only cast if not active", "Only cast if the Cataclysm buff is not active")
 
        cataclysm_menu_elements.main_tab:pop()
    end
end

local function logics()

    local menu_boolean = cataclysm_menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.cataclysm.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Check if we should only cast when buff is not active
    local only_cast_if_not_active = cataclysm_menu_elements.only_cast_if_not_active:get();
    if only_cast_if_not_active then
        local local_player = get_local_player();
        if local_player then
            local buffs = local_player:get_buffs();
            for _, buff in ipairs(buffs or {}) do
                if buff.name_hash == 266570 then
                    -- Cataclysm buff is active, don't cast
                    return false, 0;
                end
            end
        end
    end

   if cast_spell.self(spell_data.cataclysm.spell_id, 0.1) then
        console.print("Druid Plugin, Casted Cataclysm");
        return true, 0.1;
    end;
    
    return false, 0;
end;

return
{
    menu = menu,
    logics = logics,   
}
