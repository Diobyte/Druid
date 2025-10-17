-- ============================================================
-- AUTO PLAY DETECTION
-- ============================================================
-- Checks if the game's auto-play system is active and in combat mode
-- This allows spells to be cast without requiring orbwalker input
-- Default global flags for debug and orb override (set each frame in main)
_G.__druid_debug__ = _G.__druid_debug__ or false
_G.__druid_allow_any_orb_mode__ = _G.__druid_allow_any_orb_mode__ or false

local function is_auto_play_enabled()
    local is_auto_play_active = auto_play.is_active();
    local auto_play_objective = auto_play.get_objective();
    local is_auto_play_fighting = auto_play_objective == objective.fight;
    if is_auto_play_active and is_auto_play_fighting then
        return true;
    end

    return false;
end

-- ============================================================
-- BUFF/STATE TRACKING
-- ============================================================
-- These buffs block all spell casting when active
local blood_mist_buff_name = "Necromancer_BloodMist";
local blood_mist_buff_name_hash = blood_mist_buff_name;
local blood_mist_buff_name_hash_c = 493422;

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

local shrine_conduit_buff_name = "Shine_Conduit";
local shrine_conduit_buff_name_hash = shrine_conduit_buff_name;
local shrine_conduit_buff_name_hash_c = 421661;

-- ============================================================
-- INFERNAL HORDE OBJECTIVES
-- ============================================================
-- Target skin names that should be prioritized during Infernal Horde events
-- These enemies provide bonus rewards or are critical objectives
local horde_objectives = {
    "BSK_HellSeeker",
    "MarkerLocation_BSK_Occupied",
    "S05_coredemon",
    "S05_fallen",
    "BSK_Structure_BonusAether",
    "BSK_Miniboss",
    "BSK_elias_boss",
    "BSK_cannibal_brute_boss",
    "BSK_skeleton_boss"
}

-- ============================================================
-- ACTION PERMISSION CHECK
-- ============================================================
-- Validates whether any action can be performed at this moment
-- Returns false if player is in evade, mounted, or in restricted state
local function is_action_allowed()
    -- Ensure player exists
   local local_player = get_local_player();
   if not local_player then
       return false
   end

   -- Block all actions if standing in dangerous area (evade system)
   local player_position = local_player:get_position();
   if evade.is_dangerous_position(player_position) then
       return false;
   end

   -- Block during certain channeled abilities
   local busy_spell_id_1 = 197833
   local active_spell_id = local_player:get_active_spell_id()
   if active_spell_id == busy_spell_id_1 then
       return false
   end

    -- Check for blocking buffs/states
    local is_mounted = false;
    local is_blood_mist = false;
    local is_shrine_conduit = false;
    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
          if buff.name_hash == blood_mist_buff_name_hash_c then
              is_blood_mist = true;
              break;
          end

          if buff.name_hash == mount_buff_name_hash_c then
            is_mounted = true;
              break;
          end

          if buff.name_hash == shrine_conduit_buff_name_hash_c then
            is_shrine_conduit = true;
              break;
          end
    end

      -- Block actions while mounted, in blood mist, or interacting with shrine
      if is_blood_mist or is_mounted or is_shrine_conduit then
          return false;
      end

    return true

end

-- ============================================================
-- SPELL PERMISSION CHECK
-- ============================================================
-- Comprehensive validation for whether a specific spell can be cast
-- Checks: menu toggle, cooldown, resources, evade, orbwalker mode
local function is_spell_allowed(spell_enable_check, next_cast_allowed_time, spell_id)
    -- Check if spell is enabled in menu
    if not spell_enable_check then
        return false;
    end;

    -- Respect global cast delay timer
    local current_time = get_time_since_inject();
    if current_time < next_cast_allowed_time then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: global cast delay active") end
        return false;
    end;

    -- Verify spell is off cooldown
    if utility.is_spell_ready and not utility.is_spell_ready(spell_id) then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: spell not ready " .. tostring(spell_id)) end
        return false;
    end
    
    -- Verify player has enough resources (spirit/fury)
    if utility.is_spell_affordable and not utility.is_spell_affordable(spell_id) then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: not enough resource for " .. tostring(spell_id)) end
        return false;
    end

    -- Additional cast validation (silenced, stunned, etc.)
    if not utility.can_cast_spell(spell_id) then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: utility.can_cast_spell=false") end
        return false;
    end;

    -- Block casting if player is in dangerous position (evade system)
    local local_player = get_local_player();
    if local_player then
        local player_position = local_player:get_position();
        if evade.is_dangerous_position(player_position) then
            if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: player in dangerous position") end
            return false;
        end
    end

    -- Allow casting if auto-play is active and in combat mode
    if is_auto_play_enabled() then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Allow: auto-play combat mode") end
        return true;
    end

    -- Check orbwalker mode (must be PvP or Clear, not None)
    local current_orb_mode = orbwalker.get_orb_mode()

    -- Allow override to cast in any orb mode (including none) when plugin enabled
    if _G.__druid_allow_any_orb_mode__ then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Allow: orb-mode override active (mode=" .. tostring(current_orb_mode) .. ")") end
        return true
    end

    if current_orb_mode == orb_mode.none then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: orb mode none") end
        return false
    end

    local is_current_orb_mode_pvp = current_orb_mode == orb_mode.pvp
    local is_current_orb_mode_clear = current_orb_mode == orb_mode.clear

    -- Require either PvP or Clear mode to be active
     if not is_current_orb_mode_pvp and not is_current_orb_mode_clear then
        if _G.__druid_debug__ then console.print("[DRUID DEBUG] Block: orb mode not pvp/clear (mode=" .. tostring(current_orb_mode) .. ")") end
        return false;
    end

    -- All checks passed - spell is allowed to cast
    if _G.__druid_debug__ then console.print("[DRUID DEBUG] Allow: all checks passed for spell " .. tostring(spell_id)) end
    return true

end

-- ============================================================
-- AOE POSITIONING HELPERS
-- ============================================================
-- Generate optimal casting positions around a target for circular AoE abilities

-- Creates a ring of points around the target at equal angles
local function generate_points_around_target(target_position, radius, num_points)
    local points = {};
    for i = 1, num_points do
        local angle = (i - 1) * (2 * math.pi / num_points);
        local x = target_position:x() + radius * math.cos(angle);
        local y = target_position:y() + radius * math.sin(angle);
        table.insert(points, vec3.new(x, y, target_position:z()));
    end
    return points;
end

-- Finds the best position to cast a circular AoE around a target
-- Returns the point that hits the most enemies without wall collisions
local function get_best_point(target_position, circle_radius, current_hit_list)
    local points = generate_points_around_target(target_position, circle_radius * 0.75, 8);
    local hit_table = {};

    local player_position = get_player_position();
    for _, point in ipairs(points) do
        local hit_list = utility.get_units_inside_circle_list(point, circle_radius);

        local hit_list_collision_less = {};
        for _, obj in ipairs(hit_list) do
            local is_wall_collision = target_selector.is_wall_collision(player_position, obj, 2.0);
            if not is_wall_collision then
                table.insert(hit_list_collision_less, obj);
            end
        end

        table.insert(hit_table, {
            point = point,
            hits = #hit_list_collision_less,
            victim_list = hit_list_collision_less
        });
    end

    -- sort by the number of hits
    table.sort(hit_table, function(a, b) return a.hits > b.hits end);

    local current_hit_list_amount = #current_hit_list;
    if hit_table[1].hits > current_hit_list_amount then
        return hit_table[1]; -- returning the point with the most hits
    end

    return {point = target_position, hits = current_hit_list_amount, victim_list = current_hit_list};
end

function is_target_within_angle(origin, reference, target, max_angle)
    local to_reference = (reference - origin):normalize();
    local to_target = (target - origin):normalize();
    local dot_product = to_reference:dot(to_target);
    if dot_product > 1 then dot_product = 1 elseif dot_product < -1 then dot_product = -1 end
    local angle = math.deg(math.acos(dot_product));
    return angle <= max_angle;
end

local function generate_points_around_target_rec(target_position, radius, num_points)
    local points = {}
    local angles = {}
    for i = 1, num_points do
        local angle = (i - 1) * (2 * math.pi / num_points)
        local x = target_position:x() + radius * math.cos(angle)
        local y = target_position:y() + radius * math.sin(angle)
        table.insert(points, vec3.new(x, y, target_position:z()))
        table.insert(angles, angle)
    end
    return points, angles
end

local function get_best_point_rec(target_position, rectangle_radius, width, current_hit_list)
    local points, angles = generate_points_around_target_rec(target_position, rectangle_radius, 8)
    local hit_table = {}

    for i, point in ipairs(points) do
        local angle = angles[i]
        -- Calculate the destination point based on width and angle
        local destination = vec3.new(point:x() + width * math.cos(angle), point:y() + width * math.sin(angle), point:z())

        local hit_list = utility.get_units_inside_rectangle_list(point, destination, width)
        table.insert(hit_table, {point = point, hits = #hit_list, victim_list = hit_list})
    end

    table.sort(hit_table, function(a, b) return a.hits > b.hits end)

    local current_hit_list_amount = #current_hit_list
    if hit_table[1].hits > current_hit_list_amount then
        return hit_table[1] -- returning the point with the most hits
    end

    return {point = target_position, hits = current_hit_list_amount, victim_list = current_hit_list}
end

-- Helper function to check if target is in range (reduces code duplication)
local function is_in_range(target, range)
    if not target then
        return false
    end
    
    local target_position = target:get_position()
    local player_position = get_player_position()
    local target_distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    local range_sqr = (range * range)
    return target_distance_sqr < range_sqr
end

-- Enhanced buff tracking with duration and type checking
local function is_buff_active(unit, spell_id, buff_type, min_stack_count)
    -- set default stack count to 1 if not passed
    min_stack_count = min_stack_count or 1
    
    if not unit then
        return false
    end
    
    local buffs = unit:get_buffs()
    if not buffs then
        return false
    end
    
    for _, buff in ipairs(buffs) do
        -- Match by spell_id and optionally by buff type
        local spell_match = buff.name_hash == spell_id
        local type_match = (buff_type == nil) or (buff.type == buff_type)
        
        if spell_match and type_match then
            -- Check if buff has enough stacks OR has more than 0.2 seconds remaining
            if buff.stacks >= min_stack_count or (buff.get_remaining_time and buff:get_remaining_time() > 0.2) then
                return true
            end
        end
    end
    
    return false
end

-- Get dynamic melee range based on active buffs
local function get_melee_range()
    local melee_range = 3.5  -- Base druid melee range
    
    local local_player = get_local_player()
    if not local_player then
        return melee_range
    end
    
    -- Check for Trample buff (extended range during dash)
    if is_buff_active(local_player, 258243) then  -- Trample spell_id
        melee_range = 7.0  -- Extended range during dash
    end
    
    -- Check for other range-extending buffs as needed
    -- Add more buff checks here for Season 10 mechanics
    
    return melee_range
end

-- Spell delay constants for optimized casting
local spell_delays = {
    instant_cast = 0.01,  -- Instant cast abilities (buffs, etc.)
    regular_cast = 0.1    -- Regular abilities with animations
}


-- Buff tracking utility function
local buff_cache = require("my_utility/buff_cache")

local function has_buff(unit, buff_id)
    if not unit then
        return false
    end
    
    local buffs = buff_cache.get(unit)
    if not buffs then
        return false
    end
    
    for _, buff in ipairs(buffs) do
        if buff.name_hash == buff_id then
            return true
        end
    end
    
    return false
end

-- Get buff stack count
local function get_buff_stacks(unit, buff_id, buff_type)
    if not unit then
        return 0
    end
    
    local buffs = buff_cache.get(unit)
    if not buffs then
        return 0
    end
    
    for _, buff in ipairs(buffs) do
        local spell_match = buff.name_hash == buff_id
        local type_match = (buff_type == nil) or (buff.type == buff_type)
        
        if spell_match and type_match then
            -- Return actual stack count from buff
            return buff.stacks or 1
        end
    end
    
    return 0
end

-- Get buff remaining time
local function get_buff_remaining_time(unit, buff_id, buff_type)
    if not unit then
        return 0
    end
    
    local buffs = buff_cache.get(unit)
    if not buffs then
        return 0
    end
    
    for _, buff in ipairs(buffs) do
        local spell_match = buff.name_hash == buff_id
        local type_match = (buff_type == nil) or (buff.type == buff_type)
        
        if spell_match and type_match then
            if buff.get_remaining_time then
                return buff:get_remaining_time()
            end
            return 0
        end
    end
    
    return 0
end

-- Check for specific druid form (werebear, werewolf, human)
-- Form buff IDs (these are placeholders - verify actual IDs)
local druid_forms = {
    werebear = 309070,      -- Maul buff ID as proxy for werebear form
    werewolf = 1206403,     -- Claw buff ID as proxy for werewolf form
}

local function get_current_form(player)
    if not player then
        return "human"
    end
    
    -- Check for werebear form
    if has_buff(player, druid_forms.werebear) then
        return "werebear"
    end
    
    -- Check for werewolf form
    if has_buff(player, druid_forms.werewolf) then
        return "werewolf"
    end
    
    return "human"
end

local plugin_label = "BASE_DRUID_PLUGIN_"

-- AoE spell enemy type filters
local aoe_enemy_filters = {
    "Any",
    "Elite/Champ/Boss",
    "Elite/Boss",
    "Boss"
}

return
{
    plugin_label = plugin_label,
    is_spell_allowed = is_spell_allowed,
    is_action_allowed = is_action_allowed,

    is_auto_play_enabled = is_auto_play_enabled,

    -- decrepify & bone_prision
    get_best_point = get_best_point,
    generate_points_around_target = generate_points_around_target,

    -- blight
    is_target_within_angle = is_target_within_angle,

    -- bone spear rect
    get_best_point_rec = get_best_point_rec,
    
    -- infernal horde objectives
    horde_objectives = horde_objectives,
    
    -- aoe spell filters
    aoe_enemy_filters = aoe_enemy_filters,
    
    -- buff tracking utilities
    has_buff = has_buff,
    is_buff_active = is_buff_active,
    get_buff_stacks = get_buff_stacks,
    get_buff_remaining_time = get_buff_remaining_time,
    get_current_form = get_current_form,
    druid_forms = druid_forms,
    
    -- helper utilities
    is_in_range = is_in_range,
    get_melee_range = get_melee_range,
    spell_delays = spell_delays,
}