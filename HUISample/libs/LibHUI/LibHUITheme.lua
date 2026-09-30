--[[
  LibHUI - Modern UI Library for WoW Addons
  License: https://raw.githubusercontent.com/huchang47/LibHUI/main/LICENSE.md
  Do not remove this notice from redistributed copies.
]]

local addonName, addon = ...

local CreateFont = CreateFont
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

addon.LibHUI = addon.LibHUI or {}

local HUI = addon.LibHUI
local Theme = {}

HUI.Theme = Theme

Theme.colors = {
  background = { 0.01, 0.02, 0.04, 0.94 },
  panel = { 0.02, 0.06, 0.10, 0.88 },
  panelSoft = { 0.04, 0.09, 0.13, 0.82 },
  row = { 0.04, 0.11, 0.17, 0.90 },
  rowHover = { 0.08, 0.18, 0.25, 0.95 },
  toggleOff = { 0.20, 0.26, 0.32, 1.00 },
  accent = { 1.00, 0.78, 0.02, 1.00 },
  accentDark = { 0.65, 0.45, 0.00, 1.00 },
  text = { 0.95, 0.96, 0.98, 1.00 },
  textDark = { 0.06, 0.10, 0.18, 1.00 },  -- 重点色背景上用深色文字
  muted = { 0.55, 0.62, 0.70, 1.00 },
  disabled = { 0.28, 0.32, 0.36, 1.00 },
  danger = { 0.90, 0.20, 0.18, 1.00 },
  black = { 0, 0, 0, 1 },
}

Theme.sizes = {
  frameWidth = 980,
  frameHeight = 620,
  headerHeight = 54,
  footerHeight = 42,
  sidebarWidth = 560,
  detailWidth = 330,
  rowHeight = 28,  -- 从 32 降到 28，更紧凑
  gap = 10,
  inset = 18,
}

local function CreateThemeFont(role, size)
  local fontName = addonName .. "LibHUI" .. role .. "Font"
  local font = _G[fontName] or CreateFont(fontName)
  font:SetFont(STANDARD_TEXT_FONT, size, "")
  font:SetShadowColor(0, 0, 0, 1)
  font:SetShadowOffset(1, -1)
  return fontName
end

-- 使用私有字体对象，避免 NDUi 等界面插件改写 GameFont* 后污染 LibHUI 布局。
Theme.fonts = {
  title = CreateThemeFont("Title", 24),
  heading = CreateThemeFont("Heading", 18),
  body = CreateThemeFont("Body", 16),
  small = CreateThemeFont("Small", 14),
}

Theme.assets = {
  -- WoW 贴图路径不带扩展名
  rowNormal = "LibHUI_RowNormal",
  rowSelected = "LibHUI_RowSelected",
}

-- 缓存已检测的目录结构（大写Libs或小写libs）
local detectedLibsCase = nil

-- 自动检测实际使用的 Libs 目录大小写
local function DetectLibsCase()
  if detectedLibsCase then
    return detectedLibsCase
  end

  -- 创建临时纹理测试路径是否有效
  -- WoW 会在贴图加载失败时返回 0 宽度，可以用此判断文件是否存在
  local testFrame = CreateFrame("Frame")
  testFrame:SetSize(1, 1)
  local testTexture = testFrame:CreateTexture()
  
  -- 先尝试大写 Libs（推荐标准）
  local pathWithCapital = "Interface\\AddOns\\" .. addonName .. "\\Libs\\LibHUI\\Assets\\LibHUI_RowNormal"
  testTexture:SetTexture(pathWithCapital)
  testTexture:SetAllPoints()
  local capitalWorks = (testTexture:GetWidth() > 0)
  
  if capitalWorks then
    detectedLibsCase = "Libs"
  else
    -- 尝试小写 libs（兼容旧版本）
    local pathWithLower = "Interface\\AddOns\\" .. addonName .. "\\libs\\LibHUI\\Assets\\LibHUI_RowNormal"
    testTexture:SetTexture(pathWithLower)
    local lowerWorks = (testTexture:GetWidth() > 0)
    
    if lowerWorks then
      detectedLibsCase = "libs"
    else
      -- 都不存在，回退到大写（可能用户自定义了 assetRoot）
      detectedLibsCase = "Libs"
    end
  end
  
  -- 清理测试对象
  testFrame:Hide()
  testFrame = nil
  
  return detectedLibsCase
end

function Theme:GetAssetRoot(app)
  local opts = app and app.opts
  if opts and opts.assetRoot then
    return opts.assetRoot
  end

  -- 自动检测并缓存正确的目录大小写
  local libsCase = DetectLibsCase()
  return "Interface\\AddOns\\" .. addonName .. "\\" .. libsCase .. "\\LibHUI\\Assets\\"
end

function Theme:Asset(name, app)
  local file = self.assets[name]
  if not file then
    return nil
  end

  return self:GetAssetRoot(app) .. file
end

function Theme:Color(name)
  return self.colors[name] or self.colors.text
end

-- 重点色换色回调列表（界面可注册以即时刷新）
Theme._accentListeners = Theme._accentListeners or {}
Theme._accentListenerNextID = Theme._accentListenerNextID or 0

function Theme:OnAccentChanged(callback)
  if type(callback) ~= "function" then return end
  self._accentListenerNextID = self._accentListenerNextID + 1
  local id = self._accentListenerNextID
  self._accentListeners[id] = callback
  return id  -- 返回 ID，可用于后续注销
end

function Theme:OffAccentChanged(id)
  if id then
    self._accentListeners[id] = nil
  end
end

-- 仅更换重点色（原黄色），其余颜色不变。
-- r,g,b,a 取值 0-1；accentDark = 深色面板底色 + 30% 重点色混合，避免低亮度偏色
function Theme:SetAccentColor(r, g, b, a)
  a = a or 1
  self.colors.accent = { r, g, b, a }
  -- 深色底（与面板 bg 一致）+ 30% 重点色 → 看起来是"重点色调的深色区域"
  local base_r, base_g, base_b = 0.04, 0.10, 0.16
  local mix = 0.30
  self.colors.accentDark = {
    base_r + r * mix,
    base_g + g * mix,
    base_b + b * mix,
    a,
  }

  for _, callback in pairs(self._accentListeners) do
    callback(self.colors.accent)
  end
end

-- 便捷方法：用 0-255 或 #RRGGBB 形式设置重点色
function Theme:SetAccentColorHex(hex)
  if type(hex) ~= "string" then
    return
  end
  hex = hex:gsub("#", "")
  if #hex < 6 then
    return
  end
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  self:SetAccentColor(r, g, b, 1)
end
