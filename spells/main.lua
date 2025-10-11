local local_player = get_local_player();
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_druid = character_id == 5;
if not is_druid then
     return
end;

local menu = require("menu");
local spell_priority = require("spell_priority");
local spell_data = require("my_utility/spell_data");

local spells =
{
    tornado         = require("spells/tornado"),
    wind_shear      = require("spells/wind_shear"),
    hurricane       = require("spells/hurricane"),
    grizzly_rage    = require("spells/grizzly_rage"),
    cyclone_armor   = require("spells/cyclone_armor"),
    blood_howls     = require("spells/blood_howls"),
    storm_strike    = require("spells/storm_strike"),
    earth_spike     = require("spells/earth_spike"),
    landslide       = require("spells/landslide"),
    lightningstorm  = require("spells/lightningstorm"),
    earthen_bulwark = require("spells/earthen_bulwark"),
    wolves          = require("spells/wolves"),
    poison_creeper  = require("spells/poison_creeper"),
    ravens          = require("spells/ravens"),
    boulder         = require("spells/boulder"),
    petrify         = require("spells/petrify"),
    cataclysm       = require("spells/cataclysm"),
    claw            = require("spells/claw"),
    maul            = require("spells/maul"),
    pulverize       = require("spells/pulverize"),
    debilitating_roar = require("spells/debilitating_roar"),
    shred               = require("spells/shred"),
    rabies              = require("spells/rabies"),
    lacerate            = require("spells/lacerate"),
    stone_burst         = require("spells/stone_burst"),
    trample             = require("spells/trample"),
}

on_render_menu(function ()

    if not menu.main_tree:push("Druid: Salad Edition") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
      -- plugin not enabled, stop rendering menu elements
      menu.main_tree:pop();
      return;
    end;
    
    -- Get equipped spells
    local equipped_spells = get_equipped_spell_ids()
    
    -- Create a lookup table for equipped spells
    local equipped_lookup = {}
    for _, spell_id in ipairs(equipped_spells) do
        equipped_lookup[spell_id] = true
    end
    
    -- Weighted Targeting System menu
    if menu.weighted_targeting_tree:push("Weighted Targeting System") then
        menu.weighted_targeting_debug:render("Debug Mode", "Enable high-verbosity console logging for weighted targeting decisions")
        menu.weighted_targeting_enabled:render("Enable Weighted Targeting", "Enables the weighted targeting system that prioritizes targets based on type and proximity")
        
        -- Only show configuration if weighted targeting is enabled
        if menu.weighted_targeting_enabled:get() then
            -- Scan settings
            menu.scan_radius:render("Scan Radius", "Radius around character to scan for targets (1-30)")
            menu.scan_refresh_rate:render("Refresh Rate", "How often to refresh target scanning in seconds (0.1-1.0)", 1)
            menu.min_targets:render("Minimum Targets", "Minimum number of targets required to activate weighted targeting (1-10)")
            menu.comparison_radius:render("Comparison Radius", "Radius to check for nearby targets when calculating weights (0.1-6.0)", 1)
            
            -- Custom Enemy Sliders toggle
            menu.custom_enemy_sliders_enabled:render("Custom Enemy Sliders", "Enable to customize target counts and weights for different enemy types")
            
            -- Only show sliders if custom enemy sliders are enabled
            if menu.custom_enemy_sliders_enabled:get() then
                -- Normal Enemy
                menu.normal_target_count:render("Normal Target Count", "Target count value for normal enemies (1-10)")
                menu.any_weight:render("Normal Weight", "Weight assigned to normal targets (1-100)")
                
                -- Elite Enemy
                menu.elite_target_count:render("Elite Target Count", "Target count value for elite enemies (1-10)")
                menu.elite_weight:render("Elite Weight", "Weight assigned to elite targets (1-100)")
                
                -- Champion Enemy
                menu.champion_target_count:render("Champion Target Count", "Target count value for champion enemies (1-10)")
                menu.champion_weight:render("Champion Weight", "Weight assigned to champion targets (1-100)")
                
                -- Boss Enemy
                menu.boss_target_count:render("Boss Target Count", "Target count value for boss enemies (1-10)")
                menu.boss_weight:render("Boss Weight", "Weight assigned to boss targets (1-100)")
            end
            
            -- Custom Buff Weights section
            menu.custom_buff_weights_enabled:render("Custom Buff Weights", "Enable to customize weights for special buff-related targets")
            if menu.custom_buff_weights_enabled:get() then
                menu.damage_resistance_provider_weight:render("Damage Resistance Provider Bonus", "Weight bonus for enemies providing damage resistance aura (1-100)")
                menu.damage_resistance_receiver_penalty:render("Damage Resistance Receiver Penalty", "Weight penalty for enemies receiving damage resistance (0-20)")
                menu.horde_objective_weight:render("Horde Objective Bonus", "Weight bonus for infernal horde objective targets (1-100)")
                menu.vulnerable_debuff_weight:render("Vulnerable Debuff Bonus", "Weight bonus for targets with VulnerableDebuff (1-5)")
            end
        end
        
        menu.weighted_targeting_tree:pop()
    end;
    
    -- Active spells menu (spells that are currently equipped)
    if menu.active_spells_tree:push("Active Spells") then
        -- Iterate through spell_priority to maintain the defined order
        for _, spell_name in ipairs(spell_priority) do
            -- Check if the spell exists in spells table, spell_data, and if it's equipped
            if spells[spell_name] and spell_data[spell_name] and spell_data[spell_name].spell_id and equipped_lookup[spell_data[spell_name].spell_id] then
                spells[spell_name].menu()
            end
        end
        menu.active_spells_tree:pop()
    end
    
    -- Inactive spells menu (spells that are not currently equipped)
    if menu.inactive_spells_tree:push("Inactive Spells") then
        -- Iterate through spell_priority to maintain the defined order
        for _, spell_name in ipairs(spell_priority) do
            -- Check if the spell exists in spells table, spell_data, and if it's not equipped
            if spells[spell_name] and spell_data[spell_name] and spell_data[spell_name].spell_id and not equipped_lookup[spell_data[spell_name].spell_id] then
                spells[spell_name].menu()
            end
        end
        menu.inactive_spells_tree:pop()
    end;
    
    menu.main_tree:pop();

end)

local cast_end_time = 0.0;

local claw_buff_name = "legendary_druid_100"
local claw_buff_name_hash = claw_buff_name
local claw_buff_name_hash_c = 1206403

local bear_buff_name = "druid_maul"
local bear_buff_name_hash = bear_buff_name
local bear_buff_name_hash = 309070

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

-- on_update callback
on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        -- if plugin is disabled dont do any logic
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end  

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local is_auto_play_active = auto_play.is_active();
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;

    -- Apply weighted targeting if enabled
    if menu.weighted_targeting_enabled:get() then
        -- Get configuration values
        local scan_radius = menu.scan_radius:get()
        local refresh_rate = menu.scan_refresh_rate:get()
        local min_targets = menu.min_targets:get()
        local comparison_radius = menu.comparison_radius:get()
        
        -- Use either custom weights or default weights based on toggle
        local boss_weight, elite_weight, champion_weight, any_weight
        local damage_resistance_provider_weight, damage_resistance_receiver_penalty, horde_objective_weight, vulnerable_debuff_weight
        
        -- Custom Enemy Sliders
        local normal_target_count, champion_target_count, elite_target_count, boss_target_count
        if menu.custom_enemy_sliders_enabled:get() then
            -- Get target count values
            normal_target_count = menu.normal_target_count:get()
            champion_target_count = menu.champion_target_count:get()
            elite_target_count = menu.elite_target_count:get()
            boss_target_count = menu.boss_target_count:get()
            
            -- Get weight values
            boss_weight = menu.boss_weight:get()
            elite_weight = menu.elite_weight:get()
            champion_weight = menu.champion_weight:get()
            any_weight = menu.any_weight:get()
        else
            -- Default target count values
            normal_target_count = 1
            champion_target_count = 5
            elite_target_count = 5
            boss_target_count = 5
            
            -- Default weight values
            boss_weight = 50
            elite_weight = 10
            champion_weight = 15
            any_weight = 2
        end

        -- Custom Buff Weights
        if menu.custom_buff_weights_enabled:get() then
            damage_resistance_provider_weight = menu.damage_resistance_provider_weight:get()
            damage_resistance_receiver_penalty = menu.damage_resistance_receiver_penalty:get()
            horde_objective_weight = menu.horde_objective_weight:get()
            vulnerable_debuff_weight = menu.vulnerable_debuff_weight:get()
        else
            damage_resistance_provider_weight = 30
            damage_resistance_receiver_penalty = 5
            horde_objective_weight = 50
            vulnerable_debuff_weight = 1
        end
        
        -- Get debug setting
        local debug_enabled = menu.weighted_targeting_debug:get()
        
        -- Get weighted target
        local weighted_target = my_target_selector.get_weighted_target(
            player_position,
            scan_radius,
            min_targets,
            comparison_radius,
            boss_weight,
            elite_weight,
            champion_weight,
            any_weight,
            refresh_rate,
            damage_resistance_provider_weight,
            damage_resistance_receiver_penalty,
            horde_objective_weight,
            vulnerable_debuff_weight,
            min_targets,
            normal_target_count,
            champion_target_count,
            elite_target_count,
            boss_target_count,
            debug_enabled
        )
        
        -- Only use weighted target if found, no fallback
        if weighted_target then
            best_target = weighted_target
        else
            -- If no weighted target found, set best_target to nil to prevent casting
            -- This respects the minimum target count setting
            best_target = nil
        end
    else
        -- Traditional targeting (if weighted targeting is disabled)
        if target_selector_data.has_elite then
            local unit = target_selector_data.closest_elite;
            local unit_position = unit:get_position();
            local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
            if distance_sqr < (max_range * max_range) then
                best_target = unit;
            end        
        end

        if target_selector_data.has_boss then
            local unit = target_selector_data.closest_boss;
            local unit_position = unit:get_position();
            local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
            if distance_sqr < (max_range * max_range) then
                best_target = unit;
            end
        end

        if target_selector_data.has_champion then
            local unit = target_selector_data.closest_champion;
            local unit_position = unit:get_position();
            local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
            if distance_sqr < (max_range * max_range) then
                best_target = unit;
            end
        end
    end

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local distance_sqr = best_target_position:squared_dist_to_ignore_z(player_position);

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end

    -- Helper function to check minimum weighted targets for AoE spells
    local function check_minimum_weight(spell_menu_elements)
        if not spell_menu_elements.use_minimum_weight:get() then
            return true  -- Feature disabled, always allow cast
        end
        
        local minimum_weight = spell_menu_elements.minimum_weight:get()
        
        -- Get current weights from menu (respect custom weights if enabled)
        local boss_weight, elite_weight, champion_weight, any_weight
        if menu.custom_enemy_sliders_enabled:get() then
            boss_weight = menu.boss_weight:get()
            elite_weight = menu.elite_weight:get()
            champion_weight = menu.champion_weight:get()
            any_weight = menu.any_weight:get()
        else
            -- Default weights
            boss_weight = 50
            elite_weight = 10
            champion_weight = 15
            any_weight = 2
        end
        
        -- Scan for enemies within 8 yards
        local scan_range = 8.0
        local collision_table = {is_enabled = false}
        local floor_table = {is_enabled = false}
        local angle_table = {is_enabled = false}
        local target_list = my_target_selector.get_target_list(player_position, scan_range, collision_table, floor_table, angle_table)
        
        -- Calculate weighted count
        local total_weight = 0
        for _, unit in ipairs(target_list) do
            if unit:is_boss() then
                total_weight = total_weight + boss_weight
            elseif unit:is_elite() then
                total_weight = total_weight + elite_weight
            elseif unit:is_champion() then
                total_weight = total_weight + champion_weight
            else
                total_weight = total_weight + any_weight
            end
        end
        
        return total_weight >= minimum_weight
    end
    
    -- Define spell parameters for consistent argument passing based on spell type
    local spell_params = {
        earthen_bulwark = { args = {} },
        cyclone_armor = { args = {} },
        blood_howls = { args = {} },
        debilitating_roar = { args = {}, custom_check = function()
            if spells.debilitating_roar and spells.debilitating_roar.menu_elements then
                return check_minimum_weight(spells.debilitating_roar.menu_elements)
            end
            return true
        end },
        petrify = { args = {}, custom_check = function()
            if spells.petrify and spells.petrify.menu_elements then
                return check_minimum_weight(spells.petrify.menu_elements)
            end
            return true
        end },
        grizzly_rage = { args = {}, custom_check = function()
            if spells.grizzly_rage and spells.grizzly_rage.menu_elements then
                return check_minimum_weight(spells.grizzly_rage.menu_elements)
            end
            return true
        end },
        wolves = { args = {best_target} },
        ravens = { args = {best_target} },
        poison_creeper = { args = {} },
        hurricane = { args = {player_position}, custom_check = function()
            if spells.hurricane and spells.hurricane.menu_elements then
                return check_minimum_weight(spells.hurricane.menu_elements)
            end
            return true
        end },
        earth_spike = { args = {best_target} },
        wind_shear = { args = {best_target} },
        storm_strike = { args = {best_target} },
        tornado = { args = {best_target} },
        lightningstorm = { args = {best_target} },
        landslide = { args = {best_target} },
        stone_burst = { args = {best_target} },
        boulder = { args = {best_target} },
        pulverize = { args = {best_target} },
        claw = { args = {best_target} },
        shred = { args = {best_target} },
        trample = { args = {best_target} },
        rabies = { args = {best_target} },
        cataclysm = { args = {} },
        lacerate = { args = {} },
        maul = { args = {best_target} },
    }
    
    -- Get equipped spells for spell casting logic
    local equipped_spells = get_equipped_spell_ids()
    
    -- Create a lookup table for equipped spells
    local equipped_lookup = {}
    for _, spell_id in ipairs(equipped_spells) do
        equipped_lookup[spell_id] = true
    end
    
    -- Loop through spells in priority order defined in spell_priority.lua
    for _, spell_name in ipairs(spell_priority) do
        local spell = spells[spell_name]
        -- Only process spells that are equipped
        if spell and spell_data[spell_name] and spell_data[spell_name].spell_id and equipped_lookup[spell_data[spell_name].spell_id] then
            local params = spell_params[spell_name]
            
            if params then
                -- Check any custom pre-conditions if defined
                local should_cast = true
                if params.custom_check ~= nil then
                    should_cast = params.custom_check()
                end
                
                if should_cast then
                    -- Check if this is a melee spell that requires move-to-cast
                    local spell_classification = spell_data[spell_name].classification
                    if spell_classification == "melee" and spell_data[spell_name].data then
                        local spell_range = spell_data[spell_name].data.range
                        local target_distance = math.sqrt(distance_sqr)
                        
                        -- If target is out of range, move towards it
                        if target_distance > spell_range then
                            if pathfinder.move_to_cpathfinder(best_target_position) then
                                -- Successfully issued movement command, wait for next frame
                                return
                            end
                        end
                    end
                    
                    -- Call spell's logics function with appropriate arguments
                    local cast_successful, cooldown = spell.logics(unpack(params.args))
                    if cast_successful then
                        cast_end_time = current_time + cooldown
                        return
                    end
                end
            end
        end
    end

end)

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            graphics.circle_3d(position, 1, color_white(100));

            local future_position = prediction.get_future_unit_position(obj, 0.4);
            graphics.circle_3d(future_position, 0.5, color_yellow(100));
        end;
    end

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end
 
    local is_auto_play_active = auto_play.is_active();
    local max_range = 10.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end

    if best_target and best_target:is_enemy()  then
        local glow_target_position = best_target:get_position();
        local glow_target_position_2d = graphics.w2s(glow_target_position);
        graphics.line(glow_target_position_2d, player_screen_position, color_red(180), 2.5)
        graphics.circle_3d(glow_target_position, 0.80, color_red(200), 2.0);
    end

end);

console.print("Lua Plugin - Druid: Salad Edition - Version 3.0 (Phase 3 Refactor Complete)");
