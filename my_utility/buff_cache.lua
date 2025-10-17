-- Lightweight buff cache to reduce repeated get_buffs() calls on hot paths
-- Usage:
--   local buff_cache = require("my_utility/buff_cache")
--   local buffs = buff_cache.get(unit) -- returns {} if unit invalid or no buffs
--   buff_cache.invalidate(unit) -- optional: invalidate cached entry for a specific unit
--   buff_cache.set_ttl(0.2) -- optional: change default TTL seconds

local cache = {}
local DEFAULT_TTL = 0.2 -- seconds
local ttl_seconds = DEFAULT_TTL

local function get_unit_id(unit)
    if not unit then return nil end
    -- Use the object pointer if available; fallback to handle/id if exposed
    if unit.get_address then
        return unit:get_address()
    end
    if unit.get_id then
        return unit:get_id()
    end
    -- Last resort: tostring (less stable)
    return tostring(unit)
end

local function now()
    return get_time_since_inject()
end

local function get(unit)
    local id = get_unit_id(unit)
    if not id then return {} end

    local entry = cache[id]
    local t = now()
    if entry and (t - entry.time) <= ttl_seconds then
        return entry.buffs or {}
    end

    local buffs = {}
    if unit and unit.get_buffs then
        local ok, res = pcall(unit.get_buffs, unit)
        if ok and res then
            buffs = res
        end
    end

    cache[id] = { time = t, buffs = buffs }
    return buffs
end

local function invalidate(unit)
    local id = get_unit_id(unit)
    if id then cache[id] = nil end
end

local function set_ttl(seconds)
    if type(seconds) == "number" and seconds >= 0 then
        ttl_seconds = seconds
    end
end

return {
    get = get,
    invalidate = invalidate,
    set_ttl = set_ttl,
}
