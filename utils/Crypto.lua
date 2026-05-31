--[[
  File: Crypto.lua
  Layer: Utils
  Responsibility: Lightweight XOR cipher and
  hash utilities for key storage obfuscation.
  Not cryptographically secure — designed to
  prevent casual file editing, not expert attacks.
  Dependencies: none
  Public API: Crypto.XORCipher, Crypto.Hash,
  Crypto.Encode, Crypto.Decode, Crypto.Sign,
  Crypto.Verify, Crypto.TimeToken
]]

local Crypto = {}

-- Internal salt — change this per project deployment
local SALT = "LuxwareUI_2024_Secure_Salt_XK92"

-- XOR a string with a key string
-- Used for light obfuscation of stored data
local function XOR(data, key)
    local result = {}
    local keyLen = #key
    for i = 1, #data do
        local dataByte = data:byte(i)
        local keyByte  = key:byte((i - 1) % keyLen + 1)
        table.insert(result, string.char(bit32.bxor(dataByte, keyByte)))
    end
    return table.concat(result)
end

-- Simple non-cryptographic hash function
-- Returns a consistent numeric hash for a string
-- Based on djb2 algorithm
local function DJB2(str)
    local hash = 5381
    for i = 1, #str do
        hash = bit32.band(
            bit32.bxor(
                bit32.lshift(hash, 5) + hash,
                str:byte(i)
            ),
            0xFFFFFFFF
        )
    end
    return hash
end

-- Hash a string to a fixed-length hex string
function Crypto.Hash(input)
    local salted = SALT .. input .. SALT
    local h1 = DJB2(salted)
    local h2 = DJB2(salted:reverse())
    local h3 = DJB2(SALT .. tostring(h1))
    local h4 = DJB2(tostring(h2) .. SALT)
    return string.format("%08X%08X%08X%08X", h1, h2, h3, h4)
end

-- Encode a string (XOR + hex encoding)
function Crypto.Encode(data, key)
    key = key or SALT
    local xored = XOR(data, key)
    local hex = {}
    for i = 1, #xored do
        table.insert(hex, string.format("%02X", xored:byte(i)))
    end
    return table.concat(hex)
end

-- Decode a string encoded with Crypto.Encode
function Crypto.Decode(encoded, key)
    key = key or SALT
    local chars = {}
    for i = 1, #encoded, 2 do
        local byte = tonumber(encoded:sub(i, i + 1), 16)
        if byte then
            table.insert(chars, string.char(byte))
        end
    end
    local xored = table.concat(chars)
    return XOR(xored, key)
end

-- XOR cipher shorthand
function Crypto.XORCipher(data, key)
    return XOR(data, key or SALT)
end

-- Generate a signature for data using HWID
-- Used to bind a key to a specific player
function Crypto.Sign(data, hwid)
    return Crypto.Hash(data .. hwid .. SALT)
end

-- Verify a signature matches
function Crypto.Verify(data, hwid, signature)
    return Crypto.Sign(data, hwid) == signature
end

-- Generate a time-based token that changes every
-- interval seconds (for periodic revalidation)
function Crypto.TimeToken(key, intervalSeconds)
    intervalSeconds = intervalSeconds or 1800
    local window = math.floor(os.time() / intervalSeconds)
    return Crypto.Hash(key .. tostring(window))
end

return Crypto
