-- dynamic typechecking submodule
-- produces error on fail and true on success, so it can be used as pattern matching for types
-- recognizes simple types, tables of simple types and values satisfying predicate
-- to accept any value for value, set pattern to nil
-- to check for string pattern do 'R:pattern' - it matches against whole string
-- to check one of patterns use {'ANY', pattern1[, ...]} or for simple types "type[|...]"
-- for complex table types use pattern = {key1=subpattern1[, ...]}
local Typeassert = {}

local function TP_tostr(pattern, key)
    local str = ""
    if key then
        str = key .. ":"
    end
    if type(pattern) == "function" then
        str = str .. "(lambda: val -> boolean)"
    elseif type(pattern) == "table" and pattern[1] == "ANY" then
        local p = {}
        for k, v in pairs(pattern) do
            if k ~= 1 then
                if type(k) == "number" then
                    p[k - 1] = TP_tostr(v)
                else
                    p[k] = TP_tostr(v)
                end
            end
        end
        str = str .. "[" .. table.concat(p, "  |  ") .. "]"
    elseif type(pattern) == "table" then
        local t = {}
        for k, v in pairs(pattern) do
            t[#t + 1] = TP_tostr(v, k)
        end
        str = str .. "{" .. table.concat(t, ", ") .. "}"
    else
        str = str .. pattern
    end
    --[[
        if #str > 140 then
            return string.sub(s, 1, 100) .. "..."
        end
        --]]
    return str
end

local function TP_errmsg(expected, val, key)
    return string.format("Typeassert: got '%s' expected '%s'", type(val), TP_tostr(expected, key))
end

local function TP_assert(val, pattern, key)
    if pattern == nil then
        return nil
    elseif type(pattern) == "string" then
        if string.sub(pattern, 1, 2) == "R:" and type(val) == "string" then -- pattern match
            if string.match(val, string.sub(pattern, 3)) == val then
                return nil
            end
            return TP_errmsg(pattern, val, key)
        elseif not string.match(pattern, type(val)) then -- shorthand version for 'ANY'
            return TP_errmsg(pattern, val, key)
        end
    elseif type(pattern) == "function" then -- lambda predicate
        local ok, ret = pcall(pattern, val)
        if not (ok and ret) then
            return TP_errmsg(pattern, val, key)
        end
    elseif type(pattern) == "table" then -- pattern as table:
        if pattern[1] == "ANY" then --- any of specified in table
            for i = 2, #pattern do
                local err = TP_assert(val, pattern[i])
                if not err then
                    return nil
                end
            end
            return TP_errmsg(TP_tostr(pattern), val, key)
        elseif type(val) == "table" then --- recurrent typechecking
            for k, v in pairs(pattern) do
                local err = TP_assert(rawget(val, k), v, k)
                if err then
                    return err
                end
            end
        else
            return TP_errmsg(pattern, val, key)
        end
    else -- malformed (pattern can be table, string or function)
        error("Typecheck: malformed pattern.")
    end
end

return setmetatable(
    Typeassert,
    {
        __call = function(_, ...)
            local ok, err = pcall(TP_assert, ...)
            if not ok or err then
                error(err, 2)
            end
            return true
        end
    }
)
