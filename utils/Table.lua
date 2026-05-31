--[[
  File: Table.lua
  Layer: Utils
  Responsibility: Table manipulation utilities
  including deep copy, merge, search, and
  functional helpers.
  Dependencies: none
  Public API: Table.DeepCopy, Table.Merge,
  Table.ShallowCopy, Table.Find, Table.Filter,
  Table.Map, Table.Keys, Table.Values,
  Table.Length, Table.Contains, Table.Reverse,
  Table.Flatten, Table.Each
]]

local Table = {}

-- Deep copy a table (handles nested tables)
-- Does not copy metatables
function Table.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Table.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Shallow copy (top level only)
function Table.ShallowCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = v
    end
    return copy
end

-- Merge t2 into t1 (t2 values overwrite t1)
-- Returns a new table, does not mutate inputs
function Table.Merge(t1, t2)
    local result = Table.ShallowCopy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = Table.Merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- Find a value in an array table
-- Returns index or nil
function Table.Find(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

-- Find using a predicate function
-- Returns first matching value or nil
function Table.FindWhere(t, fn)
    for i, v in ipairs(t) do
        if fn(v, i) then return v, i end
    end
    return nil
end

-- Filter array table using predicate
-- Returns new table with matching values
function Table.Filter(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        if fn(v, i) then
            table.insert(result, v)
        end
    end
    return result
end

-- Map array table using transform function
-- Returns new table with transformed values
function Table.Map(t, fn)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = fn(v, i)
    end
    return result
end

-- Get all keys of a table as an array
function Table.Keys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- Get all values of a table as an array
function Table.Values(t)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

-- Get true length of a table (including non-integer keys)
function Table.Length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Returns true if table contains value
function Table.Contains(t, value)
    return Table.Find(t, value) ~= nil
end

-- Reverse an array table
function Table.Reverse(t)
    local result = {}
    for i = #t, 1, -1 do
        table.insert(result, t[i])
    end
    return result
end

-- Flatten one level of nested arrays
function Table.Flatten(t)
    local result = {}
    for _, v in ipairs(t) do
        if type(v) == "table" then
            for _, inner in ipairs(v) do
                table.insert(result, inner)
            end
        else
            table.insert(result, v)
        end
    end
    return result
end

-- Iterate array with callback (no return)
function Table.Each(t, fn)
    for i, v in ipairs(t) do
        fn(v, i)
    end
end

-- Remove a value from array table in place
-- Returns true if found and removed
function Table.Remove(t, value)
    local idx = Table.Find(t, value)
    if idx then
        table.remove(t, idx)
        return true
    end
    return false
end

-- Returns true if table is empty
function Table.IsEmpty(t)
    return next(t) == nil
end

-- Reduce array to a single value
function Table.Reduce(t, fn, initial)
    local acc = initial
    for i, v in ipairs(t) do
        acc = fn(acc, v, i)
    end
    return acc
end

return Table
