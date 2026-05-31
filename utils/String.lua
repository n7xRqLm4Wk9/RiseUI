--[[
  File: String.lua
  Layer: Utils
  Responsibility: String manipulation and
  formatting utilities used across components.
  Dependencies: none
  Public API: String.Truncate, String.Trim,
  String.StartsWith, String.EndsWith,
  String.Capitalize, String.FormatNumber,
  String.PadLeft, String.PadRight,
  String.Split, String.IsEmpty
]]

local String = {}

-- Truncate string to maxLen, appending suffix
-- e.g. Truncate("Hello World", 7, "...") → "Hell..."
function String.Truncate(str, maxLen, suffix)
    suffix = suffix or "..."
    if #str <= maxLen then return str end
    return str:sub(1, maxLen - #suffix) .. suffix
end

-- Remove leading and trailing whitespace
function String.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Remove leading whitespace only
function String.TrimLeft(str)
    return str:match("^%s*(.+)$") or ""
end

-- Remove trailing whitespace only
function String.TrimRight(str)
    return str:match("(.-)%s*$")
end

-- Returns true if str starts with prefix
function String.StartsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Returns true if str ends with suffix
function String.EndsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Capitalize the first letter of a string
function String.Capitalize(str)
    if #str == 0 then return str end
    return str:sub(1, 1):upper() .. str:sub(2)
end

-- Capitalize first letter of every word
function String.TitleCase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- Format a number with comma separators
-- e.g. FormatNumber(1234567) → "1,234,567"
function String.FormatNumber(n)
    local s = tostring(math.floor(n))
    local result = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if result:sub(1, 1) == "," then
        result = result:sub(2)
    end
    return result
end

-- Pad string on the left to reach length
-- e.g. PadLeft("5", 3, "0") → "005"
function String.PadLeft(str, length, char)
    char = char or " "
    str  = tostring(str)
    while #str < length do
        str = char .. str
    end
    return str
end

-- Pad string on the right to reach length
function String.PadRight(str, length, char)
    char = char or " "
    str  = tostring(str)
    while #str < length do
        str = str .. char
    end
    return str
end

-- Split string by delimiter
-- e.g. Split("a,b,c", ",") → {"a","b","c"}
function String.Split(str, delimiter)
    delimiter = delimiter or ","
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

-- Returns true if string is nil or empty
function String.IsEmpty(str)
    return str == nil or String.Trim(str) == ""
end

-- Returns true if string contains substring
function String.Contains(str, substring)
    return str:find(substring, 1, true) ~= nil
end

-- Count occurrences of substring in string
function String.Count(str, substring)
    local count = 0
    local start = 1
    while true do
        local i = str:find(substring, start, true)
        if not i then break end
        count = count + 1
        start = i + #substring
    end
    return count
end

-- Replace all occurrences of old with new
function String.Replace(str, old, new)
    return str:gsub(old:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1"), new)
end

-- Convert any value to a display string safely
function String.Stringify(value)
    if type(value) == "table" then
        return "{table}"
    end
    return tostring(value)
end

return String
