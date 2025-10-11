-- ============================================================
-- SPELL PRIORITY SYSTEM
-- ============================================================
-- This list determines the casting order when multiple spells are ready.
-- Spells are evaluated from top to bottom - the first valid spell will be cast.
-- 
-- Optimized for Season 10 endgame builds including:
--   • Fleshrender (Shout-based)
--   • Poison Pulverize (S-tier)
--   • Ravens (Companion build)
--   • Boulder (AoE damage)
--   • Earth Spike (Basic skill)
--   • Stormclaw (Burst combo)
-- ============================================================

local spell_priority = {
    -- ========================================
    -- TIER 1: SURVIVAL
    -- ========================================
    -- Always cast defensive abilities first to stay alive
    "evade",                -- Emergency dodge
    "petrify",              -- CC immunity ultimate
    "earthen_bulwark",      -- Damage shield
    "cyclone_armor",        -- Damage reduction
    "blood_howls",          -- Healing (auto-casts at 80% HP)
    
    -- ========================================
    -- TIER 2: ULTIMATES
    -- ========================================
    -- High-impact abilities for burst windows
    "cataclysm",            -- AoE ultimate
    "grizzly_rage",         -- Werebear transformation
    
    -- ========================================
    -- TIER 3: DEBUFFS
    -- ========================================
    -- Apply debuffs before dealing damage for maximum effectiveness
    "debilitating_roar",    -- Enemy damage reduction (Fleshrender build)
    "rabies",               -- Poison DoT spreader (Poison Pulverize synergy)
    
    -- ========================================
    -- TIER 4: COMPANIONS
    -- ========================================
    -- Keep summons active for consistent damage and utility
    "wolves",               -- Spirit wolves (Ravens build)
    "ravens",               -- Swarm of ravens (Ravens build)
    "poison_creeper",       -- Poison vine (synergy with Rabies)
    
    -- ========================================
    -- TIER 5: PRIMARY DAMAGE DEALERS
    -- ========================================
    -- Main rotation spells for each build archetype
    "pulverize",            -- Werebear AoE slam (S-tier Poison Pulverize)
    "storm_strike",         -- Lightning melee (A-tier Stormclaw combo)
    "claw",                 -- Spirit generator (pairs with Storm Strike)
    "landslide",            -- Earth spender
    "boulder",              -- Rolling stone (A-tier Boulder build)
    "earth_spike",          -- Basic attack (A-tier build + spirit gen)
    
    -- ========================================
    -- TIER 6: SECONDARY SPENDERS
    -- ========================================
    -- Situational damage abilities
    "hurricane",            -- Self-cast wind AoE
    "wind_shear",           -- Wind projectile
    "tornado",              -- Twister projectile
    "lightningstorm",       -- Channeled lightning
    "stone_burst",          -- Channeled earth
    
    -- ========================================
    -- TIER 7: NICHE MELEE ABILITIES
    -- ========================================
    -- Lower priority melee skills for specific builds
    "shred",                -- Werewolf bleed
    "trample",              -- Werebear charge
    "lacerate",             -- Werewolf AoE
    "maul",                 -- Basic Werebear attack
}

return spell_priority
