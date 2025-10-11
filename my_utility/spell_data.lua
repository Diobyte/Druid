-- ============================================================
-- DRUID ROTATION - SPELL DATA CONFIGURATION
-- ============================================================
-- Central database for all Druid spell properties
-- Includes: range, radius, cast delays, collision, classifications
-- ============================================================

-- Import the spell_data class from the global API
local spell_data_class = _G.spell_data

-- Helper function to create spell data objects with standardized parameters
local function create_spell_data(radius, range, cast_delay, projectile_speed, has_wall_collision, spell_id, geometry_type, targeting_type)
    return spell_data_class:new(
        radius,
        range,
        cast_delay,
        projectile_speed,
        has_wall_collision,
        spell_id,
        geometry_type or spell_geometry.rectangular,
        targeting_type or targeting_type.skillshot
    )
end

local spell_data = {
    -- ========================================
    -- MELEE ABILITIES (Range: 3.5)
    -- ========================================
    -- Basic melee attacks requiring close proximity
    
    claw = {
        spell_id = 439581,
        classification = "melee",
        internal_cooldown = 0,
        data = create_spell_data(
            1.0,           -- Hit radius
            3.5,           -- Melee range
            0.1,           -- Cast delay
            0.2,           -- Projectile speed
            true,          -- Blocked by walls
            439581,        -- Spell ID
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    storm_strike = {
        spell_id = 309320,
        classification = "melee",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            3.5,           -- range (melee)
            0.1,           -- cast_delay
            1.2,           -- projectile_speed
            true,          -- has_collision
            309320,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    maul = {
        spell_id = 309070,
        classification = "melee",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            3.5,           -- range (melee)
            0.1,           -- cast_delay
            0.2,           -- projectile_speed
            true,          -- has_collision
            309070,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    pulverize = {
        spell_id = 272138,
        classification = "melee",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            2.0,           -- radius
            3.5,           -- range (melee)
            0.1,           -- cast_delay
            0.2,           -- projectile_speed
            false,         -- has_collision
            272138,        -- spell_id
            spell_geometry.circular,
            targeting_type.targeted
        )
    },
    rabies = {
        spell_id = 416337,
        classification = "melee",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            0.3,           -- radius
            3.5,           -- range (melee)
            0.1,           -- cast_delay
            0.2,           -- projectile_speed
            true,          -- has_collision
            416337,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    shred = {
        spell_id = 1256958,
        buff_id = 1256958,
        classification = "melee",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            0.2,           -- radius
            3.5,           -- range (melee)
            0.1,           -- cast_delay
            0.4,           -- projectile_speed
            true,         -- has_collision
            1256958,       -- spell_id
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    petrify = {
        spell_id = 351722,
        spell_ids = {351722},
        classification = "melee_self",
        internal_cooldown = 0,
    },
    
    -- ========================================
    -- SELF-CAST ABILITIES (No targeting)
    -- ========================================
    -- Point-blank AoE and self-buffs
    
    poison_creeper = {
        spell_id = 314601,
        classification = "buff",
        internal_cooldown = 0,
    },
    hurricane = {
        spell_id = 258990,
        classification = "buff",
        internal_cooldown = 0,
    },
    
    -- ========================================
    -- RANGED ABILITIES (Range: 15.0)
    -- ========================================
    -- Long-range projectiles and targeted abilities
    
    earth_spike = {
        spell_id = 543387,
        classification = "ranged",
        internal_cooldown = 0,
        data = create_spell_data(
            1.0,           -- Hit radius
            15.0,          -- Ranged distance
            0.1,           -- Cast delay
            3.0,           -- Projectile speed
            true,          -- Blocked by walls
            543387,        -- Spell ID
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    wind_shear = {
        spell_id = 356587,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            0.5,           -- radius
            15.0,          -- range (ranged)
            0.1,          -- cast_delay
            4.0,           -- projectile_speed
            true,         -- has_collision
            356587,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    landslide = {
        spell_id = 313893,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            15.0,          -- range (ranged)
            0.1,           -- cast_delay
            0.2,           -- projectile_speed
            true,          -- has_collision
            313893,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.targeted
        )
    },
    tornado = {
        spell_id = 304065,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            15.0,          -- range (ranged)
            0.1,           -- cast_delay
            2.0,           -- projectile_speed
            false,         -- has_collision
            304065,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    lightningstorm = {
        spell_id = 548399,
        classification = "ranged_channeled",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            2.0,           -- radius
            15.0,          -- range (ranged)
            0.1,          -- cast_delay
            0.0,           -- projectile_speed
            false,         -- has_collision
            548399,        -- spell_id
            spell_geometry.circular,
            targeting_type.skillshot
        )
    },
    stone_burst = {
        spell_id = 1473878,
        classification = "ranged_channeled",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.5,           -- radius
            12.0,          -- range (ranged)
            1.0,           -- cast_delay
            0.0,           -- projectile_speed
            false,         -- has_collision
            1473878,       -- spell_id
            spell_geometry.circular,
            targeting_type.skillshot
        )
    },
    ravens = {
        spell_id = 281516,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            25.0,          -- range (ranged)
            0.1,          -- cast_delay
            2.0,           -- projectile_speed
            false,         -- has_collision
            281516,        -- spell_id
            spell_geometry.circular,
            targeting_type.skillshot
        )
    },
    wolves = {
        spell_id = 265663,
        classification = "ranged",
        internal_cooldown = 0.5,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.0,           -- radius
            25.0,          -- range (ranged)
            0.1,           -- cast_delay
            2.0,           -- projectile_speed
            false,         -- has_collision
            265663,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    trample = {
        spell_id = 258243,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            1.5,           -- radius
            15.0,          -- range (ranged)
            0.1,           -- cast_delay
            3.0,           -- projectile_speed
            true,         -- has_collision
            258243,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    boulder = {
        spell_id = 238345,
        classification = "ranged",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
        data = create_spell_data(
            0.7,           -- radius
            15.0,          -- range (ranged)
            0.1,           -- cast_delay
            4.0,           -- projectile_speed
            true,         -- has_collision
            238345,        -- spell_id
            spell_geometry.rectangular,
            targeting_type.skillshot
        )
    },
    lacerate = {
        spell_id = 394251,
        spell_ids = {394251},
        classification = "ultimate",  -- self-cast ultimate with AoE check
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    
    -- Buffs (self-cast, no target needed)
    earthen_bulwark = {
        spell_id = 333421,
        buff_id = 333421,
        classification = "buff",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    cyclone_armor = {
        spell_id = 280119,
        buff_id = 280119,
        classification = "buff",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    blood_howls = {
        spell_id = 566517,
        buff_id = 566517,
        classification = "buff",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    
    -- Debuffs (self-cast, no target needed)
    debilitating_roar = {
        spell_id = 336238,
        buff_id = 336238,
        classification = "debuff",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    
    -- Ultimates
    cataclysm = {
        spell_id = 266570,
        spell_ids = {266570},
        classification = "ultimate",  -- self-cast
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },
    grizzly_rage = {
        spell_id = 267021,
        spell_ids = {267021},
        classification = "ultimate",  -- self-cast
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },

    -- Evade
    evade = {
        spell_id = 337031,
        classification = "utility",
        internal_cooldown = 0,  -- Internal cooldown in seconds (0 = no ICD)
    },

    -- New buff tracking for enhanced rotation
    quickshift = {
        spell_id = 290969,
        buff_id = 290969
    },
    heightened_senses = {
        spell_id = 289513,
        buff_id = 289513
    },

    -- passives
    in_combat_area = {
        spell_id = 1271767,
        buff_id = 844134919
    },

    -- enemies
    enemies = {
        damage_resistance = {
            spell_id = 1094180,
            buff_ids = {
                provider = 2771801864,
                receiver = 2182649012
            }
        }
    },
}

return spell_data