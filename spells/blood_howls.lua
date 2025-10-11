-- ============================================================
-- BLOOD HOWL
-- ============================================================
-- Defensive healing ability that restores health
-- Features automatic health threshold triggering (default: 80%)
-- Self-cast, no target required
-- ============================================================

local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local blood_howl_elements =
{
    main_tab                = tree_node:new(1),
    main_boolean            = checkbox:new(true, get_hash(my_utility.plugin_label .. "disable_enable_blood_howls")),
    use_health_threshold    = checkbox:new(true, get_hash(my_utility.plugin_label .. "blood_howls_use_health_threshold")),
    health_threshold        = slider_float:new(0.1, 1.0, 0.80, get_hash(my_utility.plugin_label .. "blood_howls_health_threshold")),
}

-- ============================================================
-- MENU CONFIGURATION
-- ============================================================
local function menu()
    if blood_howl_elements.main_tab:push("Blood Howl")then
        blood_howl_elements.main_boolean:render("Enable Spell", "")
        
        if blood_howl_elements.main_boolean:get() then
            blood_howl_elements.use_health_threshold:render("Use Health Threshold", "Only cast when health drops below threshold")
            if blood_howl_elements.use_health_threshold:get() then
                blood_howl_elements.health_threshold:render("Health Threshold", "Cast when health is below this percentage (default: 80%)", 2)
            end
        end
 
        blood_howl_elements.main_tab:pop()
    end
end

-- ============================================================
-- CASTING LOGIC
-- ============================================================
local function logics()
    -- Check if spell is enabled and available
    local menu_boolean = blood_howl_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                0, 
                spell_data.blood_howls.spell_id);

    if not is_logic_allowed then
        return false, 0;
    end;

    -- Health threshold check (only cast if HP is low enough)
    if blood_howl_elements.use_health_threshold:get() then
        local player_local = get_local_player();
        if player_local then
            local current_health = player_local:get_current_health();
            local max_health = player_local:get_max_health();
            local health_percentage = current_health / max_health;
            local threshold = blood_howl_elements.health_threshold:get();
            
            -- Don't cast if health is still above threshold
            if health_percentage > threshold then
                return false, 0;
            end
        end
    end

    -- Cast the healing ability
   if cast_spell.self(spell_data.blood_howls.spell_id, 0.1) then
        console.print("Druid Plugin, Casted Blood Howls");
        return true, 0.1;
    end;
    
    return false, 0;
end;

return
{
    menu = menu,
    logics = logics,   
}
