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
    evade               = require("spells/evade"),
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
    
    -- Cursor Targeting
    menu.cursor_targeting_enabled:render("Enable Cursor Targeting", "Enable cursor-based targeting for better manual control")
    if menu.cursor_targeting_enabled:get() then
        menu.cursor_targeting_radius:render("Cursor Targeting Radius", "Area size for selecting targets around cursor (0.1-6.0)", 1)
        menu.cursor_targeting_angle:render("Cursor Targeting Angle", "Maximum angle between cursor and target (20-50 degrees)")
    end
    
    -- Debug Options
    menu.melee_debug_mode:render("Melee Debug Mode", "Enable detailed console logging for melee spell movement and casting decisions")
    
    -- Manual Play Mode
    menu.manual_play:render("Manual Play", "When enabled, disables automatic movement for melee spells - you control positioning manually")
    
    -- Evade compatibility (PREVENTS SPINNING/STUTTERING)
    menu.disable_melee_movement_during_evade:render("Stop Movement During Evade [ON = Evade Control, OFF = Script Control]", "RECOMMENDED: ON (checked) - When enabled, allows evade to control movement and prevents spinning/stuttering. When disabled, Druid script controls movement even during evade.")
    
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
            -- Check if the spell exists in spells table, spell_data, and if it's equipped (or is evade which should always be active)
            if spells[spell_name] and spell_data[spell_name] and spell_data[spell_name].spell_id and (equipped_lookup[spell_data[spell_name].spell_id] or spell_name == "evade") then
                spells[spell_name].menu()
            end
        end
        menu.active_spells_tree:pop()
    end
    
    -- Inactive spells menu (spells that are not currently equipped)
    if menu.inactive_spells_tree:push("Inactive Spells") then
        -- Iterate through spell_priority to maintain the defined order
        for _, spell_name in ipairs(spell_priority) do
            -- Check if the spell exists in spells table, spell_data, and if it's not equipped (exclude evade as it's always active)
            if spells[spell_name] and spell_data[spell_name] and spell_data[spell_name].spell_id and not equipped_lookup[spell_data[spell_name].spell_id] and spell_name ~= "evade" then
                spells[spell_name].menu()
            end
        end
        menu.inactive_spells_tree:pop()
    end;
    
    menu.main_tree:pop();

end)

local cast_end_time = 0.0;
local next_move_time = 0.0;  -- Timer to prevent spamming movement commands
local last_movement_target_position = nil;  -- Track last movement destination
local movement_stuck_counter = 0;  -- Detect if we're stuck spinning
local spell_last_cast_times = {}  -- Per-spell internal cooldown tracking
local evade_system_initialized = false;  -- Track if we've shown the evade system status

local claw_buff_name = "legendary_druid_100"
local claw_buff_name_hash = claw_buff_name
local claw_buff_name_hash_c = 1206403

local bear_buff_name = "druid_maul"
local bear_buff_name_hash = bear_buff_name
local bear_buff_name_hash_c = 309070

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

-- Caching variables for performance optimization
local cached_area_analysis = nil
local cached_area_analysis_time = 0
local area_analysis_cache_duration = 0.1  -- Cache for 100ms

local cached_target_data = nil
local cached_target_data_time = 0
local target_data_cache_duration = 0.05  -- Cache for 50ms

-- Cursor targeting variables
local best_cursor_target = nil
local closest_cursor_target = nil

-- Cached data for performance optimization
local cached_target_selector_data = nil
local cached_best_target = nil
local cached_enemy_npcs = nil
on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        -- if plugin is disabled dont do any logic
        return;
    end;

    -- Wire global debug flag and orb-mode override when plugin is enabled
    _G.__druid_debug__ = menu.melee_debug_mode:get()
    -- Allow casting in any orb mode when the plugin is enabled to avoid gating issues
    _G.__druid_allow_any_orb_mode__ = true

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end
    
    -- One-time initialization message for evade system status
    if not evade_system_initialized then
        evade_system_initialized = true
        local evade_protection_enabled = menu.disable_melee_movement_during_evade:get()
        if evade_protection_enabled then
            console.print("[DRUID] Evade System Integration: ENABLED ✓ - Smooth movement with danger avoidance")
        else
            console.print("[DRUID] Evade System Integration: DISABLED ✗ - WARNING: May cause spinning near ground AoE!")
        end
    end
    
    -- Out of combat evade (faster exploration)
    if spells.evade and spells.evade.out_of_combat then
        spells.evade.out_of_combat()
    end

    local screen_range = 16.0;
    local player_position = get_player_position();
    local enemy_npcs = actors_manager.get_enemy_npcs()
    cached_enemy_npcs = enemy_npcs
    local melee_range = my_utility.get_melee_range();  -- Use dynamic melee range
    local ranged_range = 12.0;
    local collision_width = 2.0;
    local floor_height = 5.0;    -- Target data structures that will be populated based on weighted targeting state
    local all_melee_data, visible_melee_data, all_ranged_data, visible_ranged_data, all_targets_data, visible_all_data
    local prioritized_target_list = nil

    -- Determine the best overall target for movement (highest priority target)
    local best_overall_target = nil
    local max_range = 10.0;
    local is_auto_play_active = auto_play.is_active();
    if is_auto_play_active then
        max_range = 12.0;
    end

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
        
        -- Get prioritized target list from weighted targeting system
        prioritized_target_list = my_target_selector.get_weighted_target(
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
            collision_width,
            floor_height,
            debug_enabled
        )
        
        -- If we have a valid prioritized list, use it to create categorized target data
        if prioritized_target_list and #prioritized_target_list > 0 then
            -- CRITICAL: Filter out targets in dangerous zones BEFORE selecting best target
            -- This prevents the target selector from repeatedly picking enemies standing in fire
            if menu.disable_melee_movement_during_evade:get() then
                local safe_targets = {}
                for _, unit in ipairs(prioritized_target_list) do
                    local unit_position = unit:get_position()
                    local is_in_danger = evade.is_dangerous_position(unit_position)
                    local path_dangerous = evade.is_position_passing_dangerous_zone(unit_position, player_position)
                    
                    -- Only include targets that are safe to approach
                    if not is_in_danger and not path_dangerous then
                        table.insert(safe_targets, unit)
                    elseif menu.melee_debug_mode:get() then
                        if is_in_danger then
                            console.print("[MELEE DEBUG] Target selector filtered out enemy - standing in danger zone")
                        elseif path_dangerous then
                            console.print("[MELEE DEBUG] Target selector filtered out enemy - path crosses danger")
                        end
                    end
                end
                prioritized_target_list = safe_targets
            end
            
            -- Set movement target to the highest priority target (first in filtered list)
            best_overall_target = prioritized_target_list[1]
            
            -- Filter the prioritized list into categorized lists for spell targeting
            local melee_list = {}
            local ranged_list = {}
            local melee_range_sqr = melee_range * melee_range
            local ranged_range_sqr = ranged_range * ranged_range
            
            for _, unit in ipairs(prioritized_target_list) do
                local unit_position = unit:get_position()
                local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
                
                -- Add to appropriate range category
                if distance_sqr <= melee_range_sqr then
                    table.insert(melee_list, unit)
                end
                if distance_sqr <= ranged_range_sqr then
                    table.insert(ranged_list, unit)
                end
            end
            
            -- Generate target selector data from the filtered prioritized lists
            -- Note: All targets in prioritized_target_list are already verified as visible/reachable
            all_melee_data = my_target_selector.get_target_selector_data(player_position, melee_list)
            visible_melee_data = my_target_selector.get_target_selector_data(player_position, melee_list)
            all_ranged_data = my_target_selector.get_target_selector_data(player_position, ranged_list)
            visible_ranged_data = my_target_selector.get_target_selector_data(player_position, ranged_list)
            all_targets_data = my_target_selector.get_target_selector_data(player_position, prioritized_target_list)
            visible_all_data = my_target_selector.get_target_selector_data(player_position, prioritized_target_list)
        else
            -- No valid targets from weighted system
            best_overall_target = nil
        end
    else
        -- Weighted targeting is disabled - use traditional proximity-based system
        -- Get comprehensive target analysis with categorized lists
        local categorized_targets = my_target_selector.get_analyzed_targets(
            player_position,
            melee_range,
            ranged_range,
            collision_width,
            floor_height
        )
        
        -- CRITICAL: Filter out dangerous targets from all categorized lists
        -- This prevents repeatedly targeting enemies in danger zones
        if menu.disable_melee_movement_during_evade:get() then
            local function filter_safe_targets(target_list)
                local safe_list = {}
                for _, unit in ipairs(target_list) do
                    local unit_position = unit:get_position()
                    local is_in_danger = evade.is_dangerous_position(unit_position)
                    local path_dangerous = evade.is_position_passing_dangerous_zone(unit_position, player_position)
                    
                    if not is_in_danger and not path_dangerous then
                        table.insert(safe_list, unit)
                    end
                end
                return safe_list
            end
            
            categorized_targets.all_melee = filter_safe_targets(categorized_targets.all_melee)
            categorized_targets.visible_melee = filter_safe_targets(categorized_targets.visible_melee)
            categorized_targets.all_ranged = filter_safe_targets(categorized_targets.all_ranged)
            categorized_targets.visible_ranged = filter_safe_targets(categorized_targets.visible_ranged)
            categorized_targets.all = filter_safe_targets(categorized_targets.all)
            categorized_targets.visible_all = filter_safe_targets(categorized_targets.visible_all)
            
            if menu.melee_debug_mode:get() then
                console.print("[MELEE DEBUG] Traditional targeting - filtered out dangerous targets from all lists")
            end
        end

        -- Generate target selector data for different categories
        all_melee_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.all_melee)
        visible_melee_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.visible_melee)
        all_ranged_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.all_ranged)
        visible_ranged_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.visible_ranged)
        all_targets_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.all)
        visible_all_data = my_target_selector.get_target_selector_data(player_position, categorized_targets.visible_all)
        
        -- Traditional targeting priority: Boss > Elite > Champion > Closest
        if all_targets_data and all_targets_data.is_valid then
            best_overall_target = all_targets_data.closest_unit
            
            if all_targets_data.has_boss then
                local unit = all_targets_data.closest_boss
                local unit_position = unit:get_position()
                local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
                if distance_sqr < (max_range * max_range) then
                    best_overall_target = unit
                end
            end

            if all_targets_data.has_elite then
                local unit = all_targets_data.closest_elite
                local unit_position = unit:get_position()
                local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
                if distance_sqr < (max_range * max_range) then
                    best_overall_target = unit
                end        
            end

            if all_targets_data.has_champion then
                local unit = all_targets_data.closest_champion
                local unit_position = unit:get_position()
                local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
                if distance_sqr < (max_range * max_range) then
                    best_overall_target = unit
                end
            end
        end
    end
    
    -- Cache target data for on_render optimization
    cached_target_selector_data = all_targets_data
    cached_best_target = best_overall_target
    
    -- Cursor Targeting (if enabled)
    if menu.cursor_targeting_enabled:get() and all_targets_data and all_targets_data.is_valid then
        local cursor_position = get_cursor_position()
        local cursor_targeting_radius = menu.cursor_targeting_radius:get()
        local cursor_targeting_angle = menu.cursor_targeting_angle:get()
        local cursor_targeting_radius_sqr = cursor_targeting_radius * cursor_targeting_radius
        
        best_cursor_target = nil
        closest_cursor_target = nil
        local best_cursor_score = 0
        local closest_cursor_distance = math.huge
        
        -- Scan all targets for cursor targeting
        local target_list = prioritized_target_list or cached_enemy_npcs
        
        for _, unit in ipairs(target_list) do
            if unit and unit:is_enemy() and not unit:is_untargetable() and not unit:is_immune() then
                local unit_position = unit:get_position()
                local cursor_distance_sqr = unit_position:squared_dist_to_ignore_z(cursor_position)
                
                -- Check if within cursor radius
                if cursor_distance_sqr <= cursor_targeting_radius_sqr then
                    -- Check angle to cursor
                    local angle_to_cursor = unit_position:get_angle(cursor_position, player_position)
                    
                    if angle_to_cursor <= cursor_targeting_angle then
                        -- Calculate score (prioritize elites/bosses)
                        local score = 1
                        if unit:is_boss() then
                            score = 50
                        elseif unit:is_champion() then
                            score = 15
                        elseif unit:is_elite() then
                            score = 10
                        end
                        
                        -- Best cursor target (highest score)
                        if score > best_cursor_score then
                            best_cursor_score = score
                            best_cursor_target = unit
                        end
                        
                        -- Closest cursor target
                        if cursor_distance_sqr < closest_cursor_distance then
                            closest_cursor_distance = cursor_distance_sqr
                            closest_cursor_target = unit
                        end
                    end
                end
            end
        end
    end

    -- If no valid target at all, exit
    if not best_overall_target then
        if menu.melee_debug_mode:get() then
            console.print("[DRUID DEBUG] No valid target after selection; skipping rotation")
        end
        return;
    end

    -- ============================================================
    -- EVADE SYSTEM INTEGRATION - HOW IT WORKS
    -- ============================================================
    -- The "Stop Movement During Evade" checkbox controls whether this script cooperates with the evade script.
    -- 
    -- EVADE API FUNCTIONS USED:
    --   • evade.is_dangerous_position(pos) - Returns true if the position is inside a danger zone (AoE spell)
    --   • evade.is_position_passing_dangerous_zone(dest, source) - Returns true if path from source to dest crosses danger
    --
    -- FOUR-LAYER PROTECTION SYSTEM (when checkbox is ON/checked):
    --
    -- LAYER 0 - TARGET SELECTOR FILTERING (Line ~350 & ~410):
    --   MOST IMPORTANT: Filter dangerous targets BEFORE they enter the target selection system.
    --   This prevents the script from repeatedly picking the same dangerous enemy every frame.
    --   Applies to both weighted and traditional targeting modes.
    --   If target is in danger OR path crosses danger → Remove from target pool entirely
    --   Result: Target selector only sees safe targets, automatically picks different enemy
    --
    -- LAYER 1 - GLOBAL TARGET FILTER (Line ~620):
    --   Before starting rotation, check if the primary movement target is standing in danger.
    --   If YES → Skip entire rotation cycle, let evade move us to safety
    --   If NO → Continue with rotation
    --
    -- LAYER 2 - PER-SPELL TARGET FILTER (Line ~880):
    --   For each melee spell about to be cast, check if that specific spell's target is in danger.
    --   If YES → Skip this spell, try next spell in priority list
    --   If NO → Continue with casting logic for this spell
    --
    -- LAYER 3 - MOVEMENT COMMAND INTELLIGENCE (Line ~910):
    --   When movement is needed (target out of range), check THREE conditions:
    --     a) Is player currently standing in danger? (let evade move us out first)
    --     b) Is the destination (movement target) in danger? (don't walk into fire)
    --     c) Would the path from player to destination cross danger? (don't walk through fire)
    --   If ANY are true → Block movement command, let evade handle it
    --   If ALL are false → Allow movement command
    --
    --   ANTI-SPAM PROTECTION:
    --     - Track last movement destination (last_movement_target_position)
    --     - Only send new command if destination changed by >1 yard OR stuck counter >10
    --     - Movement interval: 0.5 seconds (prevents command spam that overrides evade)
    --     - Reset tracking when: spell cast successful, target reached, or new target acquired
    --
    -- EXAMPLE SCENARIO - Enemy on fire patch:
    --   1. Target selector picks enemy on fire as best target
    --   2. Layer 1: evade.is_dangerous_position(enemy_pos) returns TRUE
    --   3. Script skips entire rotation, prints "[MELEE DEBUG] Primary movement target is in dangerous zone"
    --   4. Next frame: evade has (hopefully) picked different target OR moved us to better position
    --   5. Layer 1 check passes, rotation continues
    --
    -- EXAMPLE SCENARIO - Path crosses fire:
    --   1. Target is safe, but fire between us and target
    --   2. Layer 1 & 2: Pass (target not in danger)
    --   3. Spell out of range, need to move
    --   4. Layer 3: evade.is_position_passing_dangerous_zone(target, player) returns TRUE
    --   5. Movement blocked, prints "[MELEE DEBUG] movement blocked - path dangerous"
    --   6. Evade system moves us around the fire
    --   7. Next frame: Path clear, movement allowed
    --
    -- WHEN CHECKBOX IS OFF (unchecked):
    --   All three layers are bypassed. Script always issues movement commands regardless of danger.
    --   This causes "spinning" because: Script says "move forward" → Evade says "move back" → Script says "move forward"...
    --
    -- ============================================================
    
    -- The movement target is always the best overall target
    local movement_target = best_overall_target
    local movement_target_position = movement_target:get_position()
    
    -- LAYER 1: GLOBAL TARGET FILTER
    -- If the primary movement target is in a dangerous zone, skip the entire rotation cycle
    if menu.disable_melee_movement_during_evade:get() then
        local movement_target_in_danger = evade.is_dangerous_position(movement_target_position)
        if movement_target_in_danger then
            if menu.melee_debug_mode:get() then
                console.print("[MELEE DEBUG] Primary movement target is in dangerous zone - skipping rotation cycle")
            end
            return;
        end
    end

    -- Perform area analysis with caching for AoE spell conditions
    local area_analysis
    if cached_area_analysis and (current_time - cached_area_analysis_time) < area_analysis_cache_duration then
        area_analysis = cached_area_analysis
    else
        local normal_target_count, elite_target_count, champion_target_count, boss_target_count
        if menu.custom_enemy_sliders_enabled:get() then
            normal_target_count = menu.normal_target_count:get()
            elite_target_count = menu.elite_target_count:get()
            champion_target_count = menu.champion_target_count:get()
            boss_target_count = menu.boss_target_count:get()
        else
            normal_target_count = 1
            elite_target_count = 5
            champion_target_count = 5
            boss_target_count = 5
        end
        
        area_analysis = my_target_selector.analyze_target_area(
            player_position,
            menu.scan_radius:get(),
            normal_target_count,
            elite_target_count,
            champion_target_count,
            boss_target_count
        )
        
        cached_area_analysis = area_analysis
        cached_area_analysis_time = current_time
    end

    -- Helper function to check AoE conditions for buff/debuff spells
    local function check_aoe_conditions(spell_menu_elements, area_analysis)
        -- Check enemy type filter first
        local enemy_type_filter = spell_menu_elements.enemy_type_filter:get()
        
        -- Filter: 0 = Any, 1 = Elite/Champ/Boss, 2 = Elite/Boss, 3 = Boss
        if enemy_type_filter == 3 then
            -- Boss only
            return area_analysis.num_bosses > 0
        elseif enemy_type_filter == 2 then
            -- Elite/Boss
            return area_analysis.num_elites > 0 or area_analysis.num_bosses > 0
        elseif enemy_type_filter == 1 then
            -- Elite/Champ/Boss
            return area_analysis.num_elites > 0 or area_analysis.num_champions > 0 or area_analysis.num_bosses > 0
        end
        
        -- Filter is "Any" - check minimum targets in area if enabled
        if not spell_menu_elements.use_minimum_weight:get() then
            return true  -- Feature disabled, always allow cast
        end
        
        local minimum_targets = spell_menu_elements.minimum_weight:get()
        return area_analysis.total_target_count >= minimum_targets
    end
    
    -- Helper function to select casting target based on targeting mode
    local function select_casting_target(targeting_mode, spell_classification)
        -- Targeting mode indices (0-indexed from combo_box)
        -- Melee spells: 0=Melee Target, 1=Melee Target (in sight), 2=Closest Target, 3=Closest Target (in sight)
        -- Ranged spells: 0=Ranged Target, 1=Ranged Target (in sight), 2=Closest Target, 3=Closest Target (in sight)
        -- Universal: 0=Melee Target, 1=Melee Target (in sight), 2=Ranged Target, 3=Ranged Target (in sight), 4=Closest Target, 5=Closest Target (in sight)
        
        local is_melee_spell = spell_classification == "melee"
        local is_ranged_spell = spell_classification == "ranged" or spell_classification == "ranged_channeled"
        
        if is_melee_spell then
            if targeting_mode == 0 then
                -- Melee Target
                return all_melee_data.closest_unit
            elseif targeting_mode == 1 then
                -- Melee Target (in sight)
                return visible_melee_data.closest_unit
            elseif targeting_mode == 2 then
                -- Closest Target
                return all_targets_data.closest_unit
            elseif targeting_mode == 3 then
                -- Closest Target (in sight)
                return visible_all_data.closest_unit
            elseif targeting_mode == 4 then
                -- Best Cursor Target
                return best_cursor_target
            elseif targeting_mode == 5 then
                -- Closest Cursor Target
                return closest_cursor_target
            end
        elseif is_ranged_spell then
            if targeting_mode == 0 then
                -- Ranged Target
                return all_ranged_data.closest_unit
            elseif targeting_mode == 1 then
                -- Ranged Target (in sight)
                return visible_ranged_data.closest_unit
            elseif targeting_mode == 2 then
                -- Closest Target
                return all_targets_data.closest_unit
            elseif targeting_mode == 3 then
                -- Closest Target (in sight)
                return visible_all_data.closest_unit
            elseif targeting_mode == 4 then
                -- Best Cursor Target
                return best_cursor_target
            elseif targeting_mode == 5 then
                -- Closest Cursor Target
                return closest_cursor_target
            end
        else
            -- Universal (buff, debuff, ultimate, etc.)
            if targeting_mode == 0 then
                -- Melee Target
                return all_melee_data.closest_unit
            elseif targeting_mode == 1 then
                -- Melee Target (in sight)
                return visible_melee_data.closest_unit
            elseif targeting_mode == 2 then
                -- Ranged Target
                return all_ranged_data.closest_unit
            elseif targeting_mode == 3 then
                -- Ranged Target (in sight)
                return visible_ranged_data.closest_unit
            elseif targeting_mode == 4 then
                -- Closest Target
                return all_targets_data.closest_unit
            elseif targeting_mode == 5 then
                -- Closest Target (in sight)
                return visible_all_data.closest_unit
            elseif targeting_mode == 6 then
                -- Best Cursor Target
                return best_cursor_target
            elseif targeting_mode == 7 then
                -- Closest Cursor Target
                return closest_cursor_target
            end
        end
        
        return nil
    end
    
    -- Define spell parameters for consistent argument passing based on spell type
    local spell_params = {
        earthen_bulwark = { args = {} },
        cyclone_armor = { args = {} },
        blood_howls = { args = {} },
        debilitating_roar = { args = {}, custom_check = function()
            if spells.debilitating_roar and spells.debilitating_roar.menu_elements then
                return check_aoe_conditions(spells.debilitating_roar.menu_elements, area_analysis)
            end
            return true
        end },
        petrify = { args = {}, custom_check = function()
            if spells.petrify and spells.petrify.menu_elements then
                return check_aoe_conditions(spells.petrify.menu_elements, area_analysis)
            end
            return true
        end },
        grizzly_rage = { args = {}, custom_check = function()
            if spells.grizzly_rage and spells.grizzly_rage.menu_elements then
                return check_aoe_conditions(spells.grizzly_rage.menu_elements, area_analysis)
            end
            return true
        end },
        wolves = { args = {}, needs_target = true },
        ravens = { args = {}, needs_target = true },
        poison_creeper = { args = {} },
        hurricane = { args = {player_position}, custom_check = function()
            if spells.hurricane and spells.hurricane.menu_elements then
                return check_aoe_conditions(spells.hurricane.menu_elements, area_analysis)
            end
            return true
        end },
        earth_spike = { args = {}, needs_target = true },
        wind_shear = { args = {}, needs_target = true },
        storm_strike = { args = {}, needs_target = true },
        tornado = { args = {}, needs_target = true },
        lightningstorm = { args = {}, needs_target = true },
        landslide = { args = {}, needs_target = true },
        stone_burst = { args = {}, needs_target = true },
        boulder = { args = {}, needs_target = true },
        pulverize = { args = {}, needs_target = true },
        claw = { args = {}, needs_target = true },
        shred = { args = {}, needs_target = true },
        trample = { args = {}, needs_target = true },
        rabies = { args = {}, needs_target = true },
        cataclysm = { args = {} },
        lacerate = { args = {} },
        maul = { args = {}, needs_target = true },
        evade = { args = {}, needs_target = true },
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
                -- Check internal cooldown for this spell
                local internal_cooldown = spell_data[spell_name].internal_cooldown or 0
                if internal_cooldown > 0 then
                    local last_cast_time = spell_last_cast_times[spell_name] or 0
                    local time_since_last_cast = current_time - last_cast_time
                    if time_since_last_cast < internal_cooldown then
                        -- Spell is still on internal cooldown, skip it
                        goto continue
                    end
                end
                
                -- Check any custom pre-conditions if defined
                local should_cast = true
                if params.custom_check ~= nil then
                    should_cast = params.custom_check()
                end
                
                if should_cast then
                    -- Determine the casting target for this spell
                    local casting_target = nil
                    
                    if params.needs_target then
                        -- Get the spell's targeting mode from its menu
                        local targeting_mode = 0  -- Default to first option
                        if spell.menu_elements and spell.menu_elements.targeting_mode then
                            targeting_mode = spell.menu_elements.targeting_mode:get()
                        end
                        
                        -- Select the appropriate target based on the mode
                        local classification = spell_data[spell_name].classification or "ranged"
                        casting_target = select_casting_target(targeting_mode, classification)
                        
                        -- If no valid target for this spell, skip it
                        if not casting_target then
                            goto continue
                        end
                        
                        -- Update params.args to include the casting target
                        params.args = {casting_target}
                    end
                    
                    -- Melee range check: Handle movement if target is too far away
                    local is_melee = spell_data[spell_name].classification == "melee"
                    
                    if is_melee and casting_target and spell_data[spell_name].data then
                        local melee_spell_range = spell_data[spell_name].data.range
                        local target_position = casting_target:get_position()
                        local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)
                        local distance = math.sqrt(distance_sqr)  -- For debug logging
                        
                        -- LAYER 2: PER-SPELL TARGET FILTER
                        -- Even if global target is safe, this specific spell's target might be in danger
                        -- (example: AoE spell targeting cluster where one enemy is on fire)
                        if menu.disable_melee_movement_during_evade:get() then
                            local target_in_danger = evade.is_dangerous_position(target_position)
                            if target_in_danger then
                                if menu.melee_debug_mode:get() then
                                    console.print("[MELEE DEBUG] " .. spell_name .. " skipped - target is standing in dangerous zone")
                                end
                                goto continue
                            end
                        end
                        
                        if distance_sqr > melee_spell_range * melee_spell_range then
                            -- Target is out of range for melee spell
                            local manual_play_enabled = menu.manual_play:get()
                            
                            if manual_play_enabled then
                                -- Manual play mode: skip spell and let user control movement
                                if menu.melee_debug_mode:get() then
                                    console.print("[MELEE DEBUG] " .. spell_name .. " skipped (Manual Play) - target distance: " .. string.format("%.2f", distance) .. " > " .. string.format("%.2f", melee_spell_range))
                                end
                                goto continue
                            else
                                -- Auto movement mode: move towards the MOVEMENT TARGET (not casting target)
                                local should_move = true
                                
                                -- LAYER 3: MOVEMENT COMMAND INTELLIGENCE
                                -- This is the most critical layer - prevents spinning during transit
                                if menu.disable_melee_movement_during_evade:get() then
                                    -- Check THREE danger conditions before allowing movement:
                                    local player_in_danger = evade.is_dangerous_position(player_position)
                                    local movement_position_dangerous = evade.is_dangerous_position(movement_target_position)
                                    local path_dangerous = evade.is_position_passing_dangerous_zone(movement_target_position, player_position)
                                    
                                    if player_in_danger or movement_position_dangerous or path_dangerous then
                                        should_move = false
                                        if menu.melee_debug_mode:get() then
                                            if player_in_danger then
                                                console.print("[MELEE DEBUG] " .. spell_name .. " movement blocked - player in dangerous area (letting evade handle it)")
                                            elseif movement_position_dangerous then
                                                console.print("[MELEE DEBUG] " .. spell_name .. " movement blocked - target position dangerous")
                                            elseif path_dangerous then
                                                console.print("[MELEE DEBUG] " .. spell_name .. " movement blocked - path dangerous")
                                            end
                                        end
                                    end
                                end
                                
                                if should_move and current_time >= next_move_time then
                                    -- ANTI-SPIN: Check if we're trying to move to the same position repeatedly
                                    local is_same_destination = false
                                    if last_movement_target_position then
                                        local position_distance_sqr = movement_target_position:squared_dist_to_ignore_z(last_movement_target_position)
                                        is_same_destination = position_distance_sqr < 1.0  -- Within 1 yard of last destination
                                    end
                                    
                                    -- Only send movement command if destination changed OR enough time passed
                                    if not is_same_destination or movement_stuck_counter > 10 then
                                        pathfinder.request_move(movement_target_position)
                                        last_movement_target_position = movement_target_position
                                        next_move_time = current_time + 0.5  -- Increased to 0.5s for less aggressive movement
                                        movement_stuck_counter = 0
                                        
                                        if menu.melee_debug_mode:get() then
                                            console.print("[MELEE DEBUG] " .. spell_name .. " moving to movement target - distance: " .. string.format("%.2f", distance) .. " > " .. string.format("%.2f", melee_spell_range))
                                        end
                                    else
                                        -- Same destination, increment counter (might be stuck)
                                        movement_stuck_counter = movement_stuck_counter + 1
                                        if menu.melee_debug_mode:get() and movement_stuck_counter == 5 then
                                            console.print("[MELEE DEBUG] " .. spell_name .. " same destination, waiting for evade/movement to complete")
                                        end
                                    end
                                end
                                -- Skip casting this out-of-range spell and check the next one
                                goto continue
                            end
                        end
                        
                        -- Reset movement tracking when in range (successful approach)
                        last_movement_target_position = nil
                        movement_stuck_counter = 0
                        
                        if menu.melee_debug_mode:get() then
                            console.print("[MELEE DEBUG] " .. spell_name .. " in range - distance: " .. string.format("%.2f", distance) .. " <= " .. string.format("%.2f", melee_spell_range))
                        end
                    end
                    
                    -- Call spell's logics function with appropriate arguments
                    -- Lua 5.1 safe dispatch (Druid spells expect 0 or 1 argument)
                    local args = params.args or {}
                    local cast_successful, cooldown
                    if #args == 0 then
                        cast_successful, cooldown = spell.logics()
                    else
                        cast_successful, cooldown = spell.logics(args[1])
                    end
                    if cast_successful then
                        cast_end_time = current_time + cooldown
                        -- Update internal cooldown tracking for this spell
                        spell_last_cast_times[spell_name] = current_time
                        -- Reset movement tracking on successful cast
                        last_movement_target_position = nil
                        movement_stuck_counter = 0
                        return
                    end
                end
                
                ::continue::
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

    if not cached_target_selector_data or not cached_target_selector_data.is_valid then
        return;
    end

    local target_selector_data = cached_target_selector_data
    local best_target = cached_best_target

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

console.print("Lua Plugin - Druid: Salad Edition - Version 0.8 (Beta 0.8 nearly almost there edition)");
