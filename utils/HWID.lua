--[[
  File: HWID.lua
  Layer: Utils
  Responsibility: Hardware/player fingerprint
  generation for key binding. Ties a validated
  key to a specific Roblox player account so
  keys cannot be freely shared.
  Dependencies: utils/Crypto.lua
  Public API: HWID.Generate, HWID.GetUserId,
  HWID.GetFingerprint, HWID.Matches,
  HWID.BindKey, HWID.VerifyBoundKey
]]

local Players = game:GetService("Players")
local Crypto  = require(script.Parent.Crypto)
local HWID    = {}

local LocalPlayer = Players.LocalPlayer

-- Get the local player's UserId as string
function HWID.GetUserId()
    return tostring(LocalPlayer.UserId)
end

-- Get the local player's username
function HWID.GetUsername()
    return LocalPlayer.Name
end

-- Get account age in days (adds entropy)
function HWID.GetAccountAge()
    return tostring(LocalPlayer.AccountAge)
end

-- Generate a fingerprint unique to this player
-- Combines multiple stable identifiers
-- Returns a hex string
function HWID.Generate()
    local userId     = HWID.GetUserId()
    local username   = HWID.GetUsername()
    local accountAge = HWID.GetAccountAge()

    local raw = table.concat({
        "LUX",
        userId,
        username,
        accountAge,
    }, "_")

    return Crypto.Hash(raw)
end

-- Get a stable fingerprint
-- Cached after first call
local _fingerprint = nil
function HWID.GetFingerprint()
    if not _fingerprint then
        _fingerprint = HWID.Generate()
    end
    return _fingerprint
end

-- Check if a stored fingerprint matches current player
function HWID.Matches(storedFingerprint)
    return HWID.GetFingerprint() == storedFingerprint
end

-- Generate a bound key hash
-- This is what gets stored, not the raw key
function HWID.BindKey(keyString)
    return Crypto.Sign(keyString, HWID.GetFingerprint())
end

-- Verify a stored bound key matches
-- current key + current player
function HWID.VerifyBoundKey(keyString, storedHash)
    return Crypto.Verify(
        keyString,
        HWID.GetFingerprint(),
        storedHash
    )
end

return HWID
