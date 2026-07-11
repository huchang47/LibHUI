--[[
  LibHUI - Modern UI Library for WoW Addons
  License: https://raw.githubusercontent.com/huchang47/LibHUI/main/LICENSE.md
  Do not remove this notice from redistributed copies.
]]

local _, addon = ...

addon.LibHUI = addon.LibHUI or {}

local L = {}
addon.LibHUI.L = L

local locale = GetLocale()

if locale == "zhCN" then
  -- 多选下拉
  L.noneSelected  = "未选择"
  L.countSelected = "已选择 %d 项"
  -- 按键绑定
  L.notBound      = "未绑定"
  L.pressKey      = "请按一个键..."
  -- 底部按钮
  L.resetPage     = "重置页面"
  L.reloadUI      = "重载界面"
  L.close         = "关闭"
else
  -- 多选下拉
  L.noneSelected  = "None selected"
  L.countSelected = "%d selected"
  -- 按键绑定
  L.notBound      = "Not Bound"
  L.pressKey      = "Press a key..."
  -- 底部按钮
  L.resetPage     = "Reset Page"
  L.close         = "Close"
end
