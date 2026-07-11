local addonName, addon = ...

local L = addon.L or {}

HUISampleDB = HUISampleDB or {}
HUISampleDB.profile = HUISampleDB.profile or {}

addon.DB = function()
  local profile = HUISampleDB.profile
  if profile.enabled == nil then
    profile.enabled = true
  end
  if profile.scale == nil then
    profile.scale = 1
  end
  if profile.alpha == nil then
    profile.alpha = 0.9
  end
  if profile.title == nil then
    profile.title = L["addonTitle"] or "HUI Sample"
  end
  return profile
end
