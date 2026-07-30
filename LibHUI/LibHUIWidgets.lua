--[[
  LibHUI - Modern UI Library for WoW Addons
  License: https://raw.githubusercontent.com/huchang47/LibHUI/main/LICENSE.md
  Do not remove this notice from redistributed copies.
]]

local addonName, addon = ...

addon.LibHUI = addon.LibHUI or {}

local HUI = addon.LibHUI
local Theme = HUI.Theme
local Widgets = {}

local CreateFrame = CreateFrame
local type = type
local tonumber = tonumber
local tostring = tostring

HUI.Widgets = Widgets

local L = HUI.L

Widgets.POPUP_STRATA = "TOOLTIP"
Widgets.POPUP_FRAME_LEVEL = 100
Widgets.POPUP_BACKDROP_LEVEL = 99

local function ConfigureManagedPopup(frame, level)
  frame:SetFrameStrata(Widgets.POPUP_STRATA)
  frame:SetFrameLevel(level or Widgets.POPUP_FRAME_LEVEL)
end

local function SetColor(texture, color)
  texture:SetColorTexture(color[1], color[2], color[3], color[4])
end

local function AddLine(parent, layer, r, g, b, a, width, height, point, relativePoint, x, y)
  local texture = parent:CreateTexture(nil, layer)
  texture:SetColorTexture(r, g, b, a)
  texture:SetSize(width, height)
  texture:SetPoint(point, parent, relativePoint or point, x or 0, y or 0)
  return texture
end

local function AddCornerDecor(panel, color)
  -- 外侧取景框式小角标：白色细线，位于面板四角外缘，开口朝内
  local r, g, b, a = 1, 1, 1, 0.95
  local length = 8     -- 每段长度
  local thickness = 1  -- 线宽
  local out = 2        -- 向外偏移量
  local corners = {}

  -- 左上：横向向右、纵向向下，拐角在左上外侧
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, length, thickness, "TOPLEFT", "TOPLEFT", -out, out)
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, thickness, length, "TOPLEFT", "TOPLEFT", -out, out)

  -- 右上
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, length, thickness, "TOPRIGHT", "TOPRIGHT", out, out)
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, thickness, length, "TOPRIGHT", "TOPRIGHT", out, out)

  -- 左下
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, length, thickness, "BOTTOMLEFT", "BOTTOMLEFT", -out, -out)
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, thickness, length, "BOTTOMLEFT", "BOTTOMLEFT", -out, -out)

  -- 右下
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, length, thickness, "BOTTOMRIGHT", "BOTTOMRIGHT", out, -out)
  corners[#corners+1] = AddLine(panel, "OVERLAY", r, g, b, a, thickness, length, "BOTTOMRIGHT", "BOTTOMRIGHT", out, -out)

  return corners
end

function Widgets:CreatePanel(parent, name)
  local panel = CreateFrame("Frame", name, parent, "BackdropTemplate")
  local panelColor = Theme:Color("panel")

  panel:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
  })
  panel:SetBackdropColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4])

  local function ApplyAccent()
    local accent = Theme:Color("accent")
    panel:SetBackdropBorderColor(accent[1] * 0.55, accent[2] * 0.55, accent[3] * 0.55, 0.70)
  end
  ApplyAccent()
  Theme:OnAccentChanged(ApplyAccent)

  local inner = panel:CreateTexture(nil, "BACKGROUND", nil, 1)
  inner:SetColorTexture(0, 0, 0, 0.24)
  inner:SetPoint("TOPLEFT", 1, -1)
  inner:SetPoint("BOTTOMRIGHT", -1, 1)

  AddCornerDecor(panel, Theme:Color("accent"))

  return panel
end

function Widgets:CreateTexture(parent, color)
  local texture = parent:CreateTexture(nil, "BACKGROUND")
  SetColor(texture, color)
  return texture
end

function Widgets:CreateText(parent, template, text, colorName)
  local fontString = parent:CreateFontString(nil, "OVERLAY", template or Theme.fonts.body)
  fontString:SetText(text or "")

  local color = Theme:Color(colorName or "text")
  fontString:SetTextColor(color[1], color[2], color[3], color[4])

  return fontString
end

function Widgets:CreateButton(parent, text, width, height)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(width or 120, height or 28)

  button.bg = self:CreateTexture(button, Theme:Color("row"))
  button.bg:SetAllPoints()

  button.accent = button:CreateTexture(nil, "OVERLAY")
  -- 底部强调条：向黑色混合（accent * 0.4），在重点色选中背景上形成暗色对比
  local function ApplyAccentBar()
    local a = Theme:Color("accent")
    button.accent:SetColorTexture(a[1] * 0.4, a[2] * 0.4, a[3] * 0.4, 1)
  end
  ApplyAccentBar()
  button.accent:SetPoint("BOTTOMLEFT")
  button.accent:SetPoint("BOTTOMRIGHT")
  button.accent:SetHeight(3)

  button.text = self:CreateText(button, Theme.fonts.body, text, "text")
  button.text:SetPoint("LEFT", button, "LEFT", 2, 0)
  button.text:SetPoint("RIGHT", button, "RIGHT", -2, 0)
  button.text:SetJustifyH("CENTER")
  button.text:SetWordWrap(false)

  button._huiListenerID = Theme:OnAccentChanged(ApplyAccentBar)

  function button:SetSelected(selected)
    self.selected = selected and true or false
    self.accent:SetShown(self.selected)
    if self.selected then
      SetColor(self.bg, Theme:Color("accent"))
      local textColor = Theme:Color("textDark")
      self.text:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
      self.text:SetShadowColor(0, 0, 0, 0)
    else
      SetColor(self.bg, Theme:Color("row"))
      local textColor = Theme:Color("text")
      self.text:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
      self.text:SetShadowColor(0, 0, 0, 1)
      self.text:SetShadowOffset(1, -1)
    end
  end

  button:SetScript("OnEnter", function(self)
    if not self.selected then
      SetColor(self.bg, Theme:Color("rowHover"))
    end
  end)
  button:SetScript("OnLeave", function(self)
    if self.selected then
      SetColor(self.bg, Theme:Color("accent"))
    else
      SetColor(self.bg, Theme:Color("row"))
    end
  end)
  button:SetScript("OnMouseDown", function(self)
    SetColor(self.bg, Theme:Color("accent"))
  end)
  button:SetScript("OnMouseUp", function(self)
    if not self.selected then
      SetColor(self.bg, Theme:Color("rowHover"))
    end
  end)

  button:SetSelected(false)
  return button
end

function Widgets:CreateActionButton(parent, text, width, height, onClick)
  -- 动作按钮：复用 row 素材 + 1px 边框 + 四角小装饰；hover 用 row 选中素材（重点色染色）
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(width or 120, height or 28)

  local normalAsset = Theme:Asset("rowNormal")
  local selectedAsset = Theme:Asset("rowSelected")

  -- 背景
  button.bg = button:CreateTexture(nil, "BACKGROUND")
  button.bg:SetAllPoints()
  if normalAsset then
    button.bg:SetTexture(normalAsset, "CLAMP", "CLAMP")
    button.bg:SetVertexColor(1, 1, 1, 1)
  else
    SetColor(button.bg, Theme:Color("row"))
  end

  -- 1px 四边边框
  button.borderTop = button:CreateTexture(nil, "BORDER")
  button.borderTop:SetPoint("TOPLEFT")
  button.borderTop:SetPoint("TOPRIGHT")
  button.borderTop:SetHeight(1)

  button.borderBottom = button:CreateTexture(nil, "BORDER")
  button.borderBottom:SetPoint("BOTTOMLEFT")
  button.borderBottom:SetPoint("BOTTOMRIGHT")
  button.borderBottom:SetHeight(1)

  button.borderLeft = button:CreateTexture(nil, "BORDER")
  button.borderLeft:SetPoint("TOPLEFT")
  button.borderLeft:SetPoint("BOTTOMLEFT")
  button.borderLeft:SetWidth(1)

  button.borderRight = button:CreateTexture(nil, "BORDER")
  button.borderRight:SetPoint("TOPRIGHT")
  button.borderRight:SetPoint("BOTTOMRIGHT")
  button.borderRight:SetWidth(1)

  -- 四角白色小装饰（外侧取景框式），常态低透明度显示，hover 时高亮
  button.corners = AddCornerDecor(button, Theme:Color("accent"))
  for _, corner in ipairs(button.corners) do
    corner:SetAlpha(0.5)
  end

  button.text = self:CreateText(button, Theme.fonts.body, text, "text")
  button.text:SetPoint("LEFT", button, "LEFT", 2, 0)
  button.text:SetPoint("RIGHT", button, "RIGHT", -2, 0)
  button.text:SetJustifyH("CENTER")
  button.text:SetWordWrap(false)

  local function SetBorder(color)
    SetColor(button.borderTop, color)
    SetColor(button.borderBottom, color)
    SetColor(button.borderLeft, color)
    SetColor(button.borderRight, color)
  end

  local function ApplyState(self)
    local accent = Theme:Color("accent")
    if self.hovered then
      -- 直接平涂标准重点色，避免贴图顶点色相乘导致偏暗偏脏
      self.bg:SetColorTexture(accent[1], accent[2], accent[3], accent[4] or 1)
      SetBorder(accent)
      for _, corner in ipairs(self.corners) do
        corner:SetAlpha(0.95)
      end
      local textColor = Theme:Color("textDark")
      self.text:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
      self.text:SetShadowColor(0, 0, 0, 0)
    else
      if normalAsset then
        self.bg:SetTexture(normalAsset, "CLAMP", "CLAMP")
        self.bg:SetVertexColor(1, 1, 1, 1)
      else
        SetColor(self.bg, Theme:Color("row"))
      end
      SetBorder({0x15/255, 0x1f/255, 0x29/255, 1})
      for _, corner in ipairs(self.corners) do
        corner:SetAlpha(0.5)
      end
      local textColor = Theme:Color("text")
      self.text:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
      self.text:SetShadowColor(0, 0, 0, 1)
      self.text:SetShadowOffset(1, -1)
    end
  end

  button:SetScript("OnEnter", function(self)
    self.hovered = true
    ApplyState(self)
  end)
  button:SetScript("OnLeave", function(self)
    self.hovered = false
    ApplyState(self)
  end)
  button:SetScript("OnClick", function(self)
    if type(onClick) == "function" then
      onClick(self)
    end
  end)

  -- 换色时刷新（用于 hover 态与边框）
  button._huiListenerID = Theme:OnAccentChanged(function()
    ApplyState(button)
  end)

  function button:SetText(value)
    self.text:SetText(value or "")
  end

  ApplyState(button)
  return button
end

function Widgets:CreateGroupHeader(parent, text, height)
  -- 组标题：左侧浅色标签底块 + 大写文字，右侧贯穿到最右的细分隔线
  local header = CreateFrame("Frame", nil, parent)
  header:SetHeight(height or 20)

  local label = (text or ""):upper()

  -- 文字（浅底深字）
  header.text = self:CreateText(header, Theme.fonts.small, label, "text")
  header.text:SetPoint("LEFT", header, "LEFT", 8, 0)
  header.text:SetJustifyH("LEFT")
  header.text:SetTextColor(0x08/255, 0x13/255, 0x24/255, 1)
  header.text:SetShadowColor(0, 0, 0, 0)
  header.text:SetShadowOffset(0, 0)

  -- 左侧标签底块（重点色提亮版，与 row 左侧强调条一致）
  header.tag = header:CreateTexture(nil, "BACKGROUND")
  header.tag:SetPoint("LEFT", header, "LEFT", 0, 0)
  header.tag:SetPoint("TOP", header, "TOP", 0, 0)
  header.tag:SetPoint("BOTTOM", header, "BOTTOM", 0, 0)
  header.tag:SetPoint("RIGHT", header.text, "RIGHT", 8, 0)

  -- 右侧分隔线
  header.line = header:CreateTexture(nil, "ARTWORK")
  header.line:SetHeight(1)
  header.line:SetPoint("LEFT", header.tag, "RIGHT", 6, 0)
  header.line:SetPoint("RIGHT", header, "RIGHT", -2, 0)

  local function ApplyAccent()
    local accent = Theme:Color("accent")
    -- 与 row 左侧强调条一致：向白色混合 55%
    header.tag:SetColorTexture(
      accent[1] + (1 - accent[1]) * 0.55,
      accent[2] + (1 - accent[2]) * 0.55,
      accent[3] + (1 - accent[3]) * 0.55,
      0.95)
    header.line:SetColorTexture(accent[1], accent[2], accent[3], 0.9)
  end
  ApplyAccent()
  header._huiListenerID = Theme:OnAccentChanged(ApplyAccent)

  function header:SetText(value)
    self.text:SetText((value or ""):upper())
  end

  return header
end

function Widgets:CreateRow(parent, height)
  local row = CreateFrame("Button", nil, parent)
  row:SetHeight(height or Theme.sizes.rowHeight)

  local normalAsset = Theme:Asset("rowNormal")
  local selectedAsset = Theme:Asset("rowSelected")

  row.bg = row:CreateTexture(nil, "BACKGROUND")
  row.bg:SetAllPoints()
  if normalAsset then
    -- 1px 宽素材，横向拉伸填充
    row.bg:SetTexture(normalAsset, "CLAMP", "CLAMP")
    row.bg:SetVertexColor(1, 1, 1, 1)
  else
    SetColor(row.bg, Theme:Color("row"))
  end

  row.borderTop = row:CreateTexture(nil, "BORDER")
  row.borderTop:SetColorTexture(0x15/255, 0x1f/255, 0x29/255, 1)
  row.borderTop:SetPoint("TOPLEFT")
  row.borderTop:SetPoint("TOPRIGHT")
  row.borderTop:SetHeight(1)

  row.borderBottom = row:CreateTexture(nil, "BORDER")
  row.borderBottom:SetColorTexture(0x15/255, 0x1f/255, 0x29/255, 1)
  row.borderBottom:SetPoint("BOTTOMLEFT")
  row.borderBottom:SetPoint("BOTTOMRIGHT")
  row.borderBottom:SetHeight(1)

  row.borderLeft = row:CreateTexture(nil, "BORDER")
  row.borderLeft:SetColorTexture(0x15/255, 0x1f/255, 0x29/255, 1)
  row.borderLeft:SetPoint("TOPLEFT")
  row.borderLeft:SetPoint("BOTTOMLEFT")
  row.borderLeft:SetWidth(1)

  row.borderRight = row:CreateTexture(nil, "BORDER")
  row.borderRight:SetColorTexture(0x15/255, 0x1f/255, 0x29/255, 1)
  row.borderRight:SetPoint("TOPRIGHT")
  row.borderRight:SetPoint("BOTTOMRIGHT")
  row.borderRight:SetWidth(1)

  row.accent = row:CreateTexture(nil, "OVERLAY")
  local accent = Theme:Color("accent")
  -- 暗条：向黑色混合（accent * 0.4），在重点色选中背景上形成暗色对比
  row.accent:SetColorTexture(accent[1] * 0.4, accent[2] * 0.4, accent[3] * 0.4, 1)
  row.accent:SetPoint("TOPLEFT")
  row.accent:SetPoint("BOTTOMLEFT")
  row.accent:SetWidth(4)
  row.accent:Hide()

  local function ApplyState(self)
    local accent = Theme:Color("accent")
    local borderColor
    local useDarkText = false
    if self.selected then
      -- 直接平涂标准重点色，避免贴图顶点色相乘导致偏暗偏脏
      self.bg:SetColorTexture(accent[1], accent[2], accent[3], accent[4] or 1)
      borderColor = accent
      useDarkText = true
    elseif self.hovered then
      if normalAsset then
        self.bg:SetTexture(normalAsset, "CLAMP", "CLAMP")
        self.bg:SetVertexColor(1.25, 1.25, 1.25, 1)
      else
        SetColor(self.bg, Theme:Color("rowHover"))
      end
      borderColor = {0x15/255, 0x1f/255, 0x29/255, 1}
    else
      if normalAsset then
        self.bg:SetTexture(normalAsset, "CLAMP", "CLAMP")
        self.bg:SetVertexColor(1, 1, 1, 1)
      else
        SetColor(self.bg, Theme:Color("row"))
      end
      borderColor = {0x15/255, 0x1f/255, 0x29/255, 1}
    end

    SetColor(self.borderTop, borderColor)
    SetColor(self.borderBottom, borderColor)
    SetColor(self.borderLeft, borderColor)
    SetColor(self.borderRight, borderColor)

    -- 更新标签文字颜色
    if self._labels then
      local textColor = useDarkText and Theme:Color("textDark") or Theme:Color("text")
      for _, lbl in ipairs(self._labels) do
        lbl:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
        -- 深色文字去掉阴影，浅色文字保留阴影
        if useDarkText then
          lbl:SetShadowColor(0, 0, 0, 0)
        else
          lbl:SetShadowColor(0, 0, 0, 1)
          lbl:SetShadowOffset(1, -1)
        end
      end
    end
  end

  row:SetScript("OnEnter", function(self)
    self.hovered = true
    ApplyState(self)
  end)
  row:SetScript("OnLeave", function(self)
    self.hovered = false
    ApplyState(self)
  end)

  function row:SetSelected(selected)
    self.selected = selected and true or false
    self.accent:SetShown(self.selected)
    ApplyState(self)
  end

  row._huiListenerID = Theme:OnAccentChanged(function()
    local updated = Theme:Color("accent")
    row.accent:SetColorTexture(updated[1] * 0.4, updated[2] * 0.4, updated[3] * 0.4, 1)
    ApplyState(row)
  end)

  row:SetSelected(false)
  return row
end

function Widgets:CreateToggle(parent, checked, onChanged)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(52, 22)

  -- 轨道始终为深色，避免落在重点色选中行（金色背景）上时与背景撞色
  button.bg = self:CreateTexture(button, Theme:Color("toggleOff"))
  button.bg:SetAllPoints()

  -- 1px 边框：在任何背景上都能勾勒出开关轮廓
  local function MakeEdge() return button:CreateTexture(nil, "BORDER") end
  button.edgeTop = MakeEdge(); button.edgeTop:SetPoint("TOPLEFT"); button.edgeTop:SetPoint("TOPRIGHT"); button.edgeTop:SetHeight(1)
  button.edgeBottom = MakeEdge(); button.edgeBottom:SetPoint("BOTTOMLEFT"); button.edgeBottom:SetPoint("BOTTOMRIGHT"); button.edgeBottom:SetHeight(1)
  button.edgeLeft = MakeEdge(); button.edgeLeft:SetPoint("TOPLEFT"); button.edgeLeft:SetPoint("BOTTOMLEFT"); button.edgeLeft:SetWidth(1)
  button.edgeRight = MakeEdge(); button.edgeRight:SetPoint("TOPRIGHT"); button.edgeRight:SetPoint("BOTTOMRIGHT"); button.edgeRight:SetWidth(1)

  button.thumb = self:CreateTexture(button, Theme:Color("accent"))
  button.thumb:SetDrawLayer("OVERLAY")
  button.thumb:SetSize(18, 18)

  local function ApplyAccent()
    local accent = Theme:Color("accent")
    -- 轨道恒定深色，用滑块位置 + 颜色表达开关状态
    SetColor(button.bg, Theme:Color("toggleOff"))
    local edgeColor = { accent[1], accent[2], accent[3], 0.8 }
    for _, e in ipairs({ button.edgeTop, button.edgeBottom, button.edgeLeft, button.edgeRight }) do
      SetColor(e, edgeColor)
    end
    if button.checked then
      -- 开启：滑块为高亮重点色
      SetColor(button.thumb, accent)
    else
      -- 关闭：滑块为亮灰色（比轨道 toggleOff 明显更亮，保证可辨）
      SetColor(button.thumb, Theme:Color("muted"))
    end
  end

  function button:SetChecked(value)
    self.checked = value and true or false
    self.thumb:ClearAllPoints()

    if self.checked then
      self.thumb:SetPoint("RIGHT", self, "RIGHT", -2, 0)
    else
      self.thumb:SetPoint("LEFT", self, "LEFT", 2, 0)
    end

    ApplyAccent()
  end

  button._huiListenerID = Theme:OnAccentChanged(ApplyAccent)

  -- 别名：兼容以 value 语义调用的场景（如 MultiDropdown）
  button.SetValue = button.SetChecked
  function button:GetValue()
    return self.checked
  end

  button:SetScript("OnClick", function(self)
    self:SetChecked(not self.checked)
    if type(onChanged) == "function" then
      onChanged(self.checked)
    end
  end)

  button:SetChecked(checked)
  return button
end

function Widgets:CreateSlider(parent, value, minValue, maxValue, step, onChanged)
  -- 现代滑块：重点色细轨道 + 重点色方块 thumb（支持换色）
  local slider = CreateFrame("Slider", nil, parent)
  slider:SetOrientation("HORIZONTAL")
  slider:SetMinMaxValues(minValue or 0, maxValue or 100)
  slider:SetValueStep(step or 1)
  slider:SetObeyStepOnDrag(true)
  slider:SetHeight(16)

  -- 轨道底色（暗），3px 加粗
  slider.track = slider:CreateTexture(nil, "BACKGROUND")
  slider.track:SetHeight(3)
  slider.track:SetPoint("LEFT")
  slider.track:SetPoint("RIGHT")
  slider.track:SetColorTexture(0x20/255, 0x2a/255, 0x36/255, 1)

  -- 已填充部分（重点色）
  slider.fill = slider:CreateTexture(nil, "ARTWORK")
  slider.fill:SetHeight(3)
  slider.fill:SetPoint("LEFT", slider.track, "LEFT", 0, 0)

  -- thumb 方块（加高加宽）
  local thumbW, thumbH = 12, 22
  slider.thumbTex = slider:CreateTexture(nil, "OVERLAY")
  slider.thumbTex:SetSize(thumbW, thumbH)
  slider:SetThumbTexture(slider.thumbTex)

  -- thumb 顶部白色高光条（动态跟随 thumb 位置）
  slider.thumbCap = slider:CreateTexture(nil, "OVERLAY", nil, 1)
  slider.thumbCap:SetColorTexture(1, 1, 1, 0.55)
  slider.thumbCap:SetSize(thumbW, 2)

  -- thumb 底部暗色边缘（增强立体感）
  slider.thumbBase = slider:CreateTexture(nil, "OVERLAY", nil, 1)
  slider.thumbBase:SetColorTexture(0, 0, 0, 0.45)
  slider.thumbBase:SetSize(thumbW, 2)

  local function ApplyAccent()
    local accent = Theme:Color("accent")
    -- 与 row 左侧强调条一致：向白色混合 55%，
    -- 使滑块在选中行（亮金背景）上仍清晰可辨，不与背景糊成一片
    local br = accent[1] + (1 - accent[1]) * 0.55
    local bg = accent[2] + (1 - accent[2]) * 0.55
    local bb = accent[3] + (1 - accent[3]) * 0.55
    slider.fill:SetColorTexture(br, bg, bb, 1)
    slider.thumbTex:SetColorTexture(br, bg, bb, 1)
  end
  ApplyAccent()
  slider._huiListenerID = Theme:OnAccentChanged(ApplyAccent)

  local function UpdateFill(self, currentValue)
    local minV, maxV = self:GetMinMaxValues()
    local range = maxV - minV
    local pct = range > 0 and ((currentValue - minV) / range) or 0
    local width = self:GetWidth()
    if width and width > 0 then
      self.fill:SetWidth(math.max(1, width * pct))
      -- 定位 thumb 高光条和底边
      local xOff = pct * (width - thumbW)
      local yTop = -(self:GetHeight() - thumbH) / 2
      self.thumbCap:SetPoint("TOPLEFT", self, "TOPLEFT", xOff, yTop)
      self.thumbBase:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", xOff, (self:GetHeight() - thumbH) / 2)
    end
  end

  slider:SetValue(tonumber(value) or minValue or 0)
  
  -- 初始化时宽度可能为 0，延迟到布局完成后再更新填充
  slider:SetScript("OnShow", function(self)
    UpdateFill(self, self:GetValue())
  end)
  slider:SetScript("OnSizeChanged", function(self)
    UpdateFill(self, self:GetValue())
  end)
  slider:SetScript("OnValueChanged", function(self, currentValue)
    UpdateFill(self, currentValue)
    if type(onChanged) == "function" then
      onChanged(currentValue)
    end
  end)

  return slider
end

-- 全局追踪当前打开的下拉，保证同时只有一个展开
local _openDropdown = nil
local _managedPopups = {}
local _registeredNativeColorPicker = nil

local function RegisterManagedPopup(...)
  local frames = {...}
  for i = 1, #frames do
    local frame = frames[i]
    if frame then
      _managedPopups[#_managedPopups + 1] = frame
    end
  end
end

local function ClearFrameList(list)
  for i = 1, #list do
    local frame = list[i]
    if frame then
      frame:Hide()
      frame:SetParent(nil)
    end
  end
  wipe(list)
end

function Widgets:CloseManagedPopups()
  for i = 1, #_managedPopups do
    local frame = _managedPopups[i]
    if frame and frame.Hide and frame:IsShown() then
      frame:Hide()
    end
  end
  _openDropdown = nil
end

function Widgets:CreateDropdown(parent, options, currentValue, onChanged)
  -- options: { { value = "id", label = "显示名" }, ... }
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(180, 24)

  -- 背景
  local bg = container:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.92)

  local selectedPreview = container:CreateTexture(nil, "BACKGROUND", nil, 1)
  selectedPreview:SetAllPoints()
  selectedPreview:SetVertexColor(0.55, 0.58, 0.62, 0.78)
  selectedPreview:Hide()

  -- 四边边框
  local function MakeEdge() return container:CreateTexture(nil, "BORDER") end
  local et = MakeEdge(); et:SetPoint("TOPLEFT"); et:SetPoint("TOPRIGHT"); et:SetHeight(1)
  local eb = MakeEdge(); eb:SetPoint("BOTTOMLEFT"); eb:SetPoint("BOTTOMRIGHT"); eb:SetHeight(1)
  local el = MakeEdge(); el:SetPoint("TOPLEFT"); el:SetPoint("BOTTOMLEFT"); el:SetWidth(1)
  local er = MakeEdge(); er:SetPoint("TOPRIGHT"); er:SetPoint("BOTTOMRIGHT"); er:SetWidth(1)
  local edges = {et, eb, el, er}

  local function ApplyBorder(focused)
    local accent = Theme:Color("accent")
    local a = focused and 1 or 0.6
    for _, e in ipairs(edges) do e:SetColorTexture(accent[1], accent[2], accent[3], a) end
  end
  ApplyBorder(false)
  container._huiListenerID = Theme:OnAccentChanged(function() ApplyBorder(container._open) end)

  -- 当前值文本
  local displayText = container:CreateFontString(nil, "OVERLAY", Theme.fonts.body)
  displayText:SetPoint("LEFT", container, "LEFT", 8, 0)
  displayText:SetPoint("RIGHT", container, "RIGHT", -22, 0)
  displayText:SetJustifyH("LEFT")
  displayText:SetTextColor(0.95, 0.96, 0.98, 1)

  -- 箭头：使用 WoW 内置箭头贴图
  local arrowSize = 10
  local arrow = container:CreateTexture(nil, "OVERLAY")
  arrow:SetSize(arrowSize, arrowSize)
  arrow:SetPoint("RIGHT", container, "RIGHT", -7, 0)
  arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
  arrow:SetVertexColor(0.75, 0.78, 0.82, 1)

  local function ApplySelection(option)
    container._value = option and option.value or nil
    displayText:SetText(option and (option.label or option.value) or "")
    if option and option.texture then
      selectedPreview:SetTexture(option.texture)
      selectedPreview:Show()
    else
      selectedPreview:Hide()
    end
  end

  -- 弹层必须高于设置页自身的 FULLSCREEN_DIALOG 子控件。
  local popup = CreateFrame("Frame", nil, UIParent)
  ConfigureManagedPopup(popup)
  popup:SetClampedToScreen(true)
  popup:Hide()
  RegisterManagedPopup(popup)
  popup.bg = popup:CreateTexture(nil, "BACKGROUND")
  popup.bg:SetAllPoints()
  popup.bg:SetColorTexture(0x06/255, 0x0e/255, 0x16/255, 0.98)
  popup.border = CreateFrame("Frame", nil, popup, "BackdropTemplate")
  popup.border:SetAllPoints()
  popup.border:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
  popup.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

  local function ClosePopup()
    popup:Hide()
    container._open = false
    arrow:SetRotation(0) -- 向下
    ApplyBorder(false)
    if _openDropdown == container then _openDropdown = nil end
  end

  local function BuildPopup()
    -- 清空旧选项
    for _, child in ipairs(popup._items or {}) do child:Hide(); child:SetParent(nil) end
    popup._items = {}

    local rowH = 22
    local w = container:GetWidth()
    popup:SetWidth(w)

    for i, opt in ipairs(options) do
      local row = CreateFrame("Button", nil, popup)
      row:SetSize(w, rowH)
      row:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, -(i-1)*rowH)

      local rowBg = row:CreateTexture(nil, "BACKGROUND")
      rowBg:SetAllPoints()
      rowBg:SetColorTexture(0, 0, 0, 0)

      if opt.texture then
        local preview = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        preview:SetAllPoints()
        preview:SetTexture(opt.texture)
        preview:SetVertexColor(0.58, 0.60, 0.64, 0.82)
      end

      local lbl = row:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
      lbl:SetPoint("LEFT", row, "LEFT", 10, 0)
      lbl:SetTextColor(0.90, 0.92, 0.95, 1)
      lbl:SetText(opt.label or opt.value or "")

      if opt.value == container._value then
        lbl:SetTextColor(Theme:Color("accent")[1], Theme:Color("accent")[2], Theme:Color("accent")[3], 1)
      end

      row:SetScript("OnEnter", function()
        rowBg:SetColorTexture(0.10, 0.20, 0.32, 0.85)
      end)
      row:SetScript("OnLeave", function()
        rowBg:SetColorTexture(0, 0, 0, 0)
      end)
      row:SetScript("OnClick", function()
        ApplySelection(opt)
        ClosePopup()
        if type(onChanged) == "function" then onChanged(opt.value) end
      end)

      popup._items[i] = row
    end

    popup:SetHeight(#options * rowH)
  end

  local function OpenPopup()
    if _openDropdown and _openDropdown ~= container then
      _openDropdown:CloseDropdown()
    end
    BuildPopup()
    -- 定位：默认在控件下方，若下方空间不足则在上方
    local _, y = container:GetCenter()
    popup:ClearAllPoints()
    if y and y < popup:GetHeight() + 40 then
      popup:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 2)
    else
      popup:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 0, -2)
    end
    popup:Show()
    container._open = true
    arrow:SetRotation(math.pi) -- 向上（旋转180度）
    ApplyBorder(true)
    _openDropdown = container
  end

  -- 点击控件本体切换展开/收起
  local clickArea = CreateFrame("Button", nil, container)
  clickArea:SetAllPoints()
  clickArea:SetScript("OnClick", function()
    if container._open then ClosePopup() else OpenPopup() end
  end)

  -- 点击其他地方关闭
  popup:SetScript("OnHide", function()
    container._open = false
    arrow:SetRotation(0)
    ApplyBorder(false)
  end)

  -- 关闭接口（供外部调用）
  container.CloseDropdown = ClosePopup

  -- 设置初始值
  local function SetValue(self, value)
    for _, opt in ipairs(options) do
      if opt.value == value then
        ApplySelection(opt)
        return
      end
    end
    ApplySelection(nil)
  end
  SetValue(container, currentValue)
  container.SetValue = SetValue
  container.GetValue = function() return container._value end

  return container
end

function Widgets:CreateMultiDropdown(parent, options, value, onChanged)
  -- options: { { value="id", label="Name" }, ... }
  -- value: { "id1", "id2", ... } 或 nil

  local selectedValues = value or {}
  if type(selectedValues) ~= "table" then
    selectedValues = {}
  end

  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(180, 24)

  -- 背景
  local bg = container:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.92)

  -- 边框
  local function MakeEdge() return container:CreateTexture(nil, "BORDER") end
  local et = MakeEdge(); et:SetPoint("TOPLEFT"); et:SetPoint("TOPRIGHT"); et:SetHeight(1)
  local eb = MakeEdge(); eb:SetPoint("BOTTOMLEFT"); eb:SetPoint("BOTTOMRIGHT"); eb:SetHeight(1)
  local el = MakeEdge(); el:SetPoint("TOPLEFT"); el:SetPoint("BOTTOMLEFT"); el:SetWidth(1)
  local er = MakeEdge(); er:SetPoint("TOPRIGHT"); er:SetPoint("BOTTOMRIGHT"); er:SetWidth(1)
  local edges = {et, eb, el, er}

  local function ApplyBorder(focused)
    local accent = Theme:Color("accent")
    local a = focused and 1 or 0.6
    for _, e in ipairs(edges) do e:SetColorTexture(accent[1], accent[2], accent[3], a) end
  end
  ApplyBorder(false)
  container._huiListenerID = Theme:OnAccentChanged(function() ApplyBorder(container._open) end)

  -- 显示文本
  local displayText = container:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
  displayText:SetPoint("LEFT", container, "LEFT", 10, 0)
  displayText:SetPoint("RIGHT", container, "RIGHT", -24, 0)
  displayText:SetJustifyH("LEFT")
  displayText:SetTextColor(0.90, 0.92, 0.95, 1)

  local function UpdateDisplay()
    local count = #selectedValues
    if count == 0 then
      displayText:SetText("|cff666666" .. L.noneSelected .. "|r")
    elseif count == 1 then
      for _, opt in ipairs(options) do
        if opt.value == selectedValues[1] then
          displayText:SetText(opt.label or opt.value)
          return
        end
      end
      displayText:SetText(selectedValues[1])
    else
      displayText:SetText(string.format(L.countSelected, count))
    end
  end

  UpdateDisplay()

  -- 箭头
  local arrowSize = 8
  local arrow = container:CreateTexture(nil, "OVERLAY")
  arrow:SetSize(arrowSize, arrowSize)
  arrow:SetPoint("RIGHT", container, "RIGHT", -8, 0)
  arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
  arrow:SetVertexColor(0.75, 0.78, 0.82, 1)

  -- 弹出列表
  local popup = CreateFrame("Frame", nil, UIParent)
  ConfigureManagedPopup(popup)
  popup:SetSize(200, 200)
  popup:Hide()

  local popupBg = popup:CreateTexture(nil, "BACKGROUND")
  popupBg:SetAllPoints()
  popupBg:SetColorTexture(0x06/255, 0x0e/255, 0x16/255, 0.98)

  local popupBorder = CreateFrame("Frame", nil, popup, "BackdropTemplate")
  popupBorder:SetAllPoints()
  popupBorder:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
  local accent = Theme:Color("accent")
  popupBorder:SetBackdropBorderColor(accent[1], accent[2], accent[3], 0.8)

  -- 滚动内容区
  local scrollChild = CreateFrame("Frame", nil, popup)
  scrollChild:SetPoint("TOPLEFT", 8, -8)
  scrollChild:SetPoint("BOTTOMRIGHT", -8, 8)

  local rowHeight = 24
  local rows = {}

  local function IsSelected(val)
    for _, v in ipairs(selectedValues) do
      if v == val then return true end
    end
    return false
  end

  local function ToggleValue(val)
    local found = false
    for i, v in ipairs(selectedValues) do
      if v == val then
        table.remove(selectedValues, i)
        found = true
        break
      end
    end
    if not found then
      selectedValues[#selectedValues + 1] = val
    end
    UpdateDisplay()
    if type(onChanged) == "function" then
      onChanged(selectedValues)
    end
  end

  local function BuildRows()
    for _, row in ipairs(rows) do row:Hide() end
    wipe(rows)

    for i, opt in ipairs(options) do
      local row = CreateFrame("Button", nil, scrollChild)
      row:SetSize(180, rowHeight)
      row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i-1) * rowHeight)

      local rowBg = row:CreateTexture(nil, "BACKGROUND")
      rowBg:SetAllPoints()
      rowBg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.5)

      local check = self:CreateToggle(row, IsSelected(opt.value), function(checked)
        if checked ~= IsSelected(opt.value) then
          ToggleValue(opt.value)
          -- 更新所有checkbox状态
          for _, r in ipairs(rows) do
            if r.check and r.optValue then
              r.check:SetValue(IsSelected(r.optValue))
            end
          end
        end
      end)
      check:SetPoint("LEFT", row, "LEFT", 6, 0)
      row.check = check
      row.optValue = opt.value

      local label = row:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
      label:SetPoint("LEFT", check, "RIGHT", 8, 0)
      label:SetText(opt.label or opt.value)
      label:SetTextColor(0.90, 0.92, 0.95, 1)

      row:SetScript("OnEnter", function(self)
        rowBg:SetColorTexture(0x15/255, 0x1d/255, 0x27/255, 0.8)
      end)
      row:SetScript("OnLeave", function(self)
        rowBg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.5)
      end)

      row:SetScript("OnClick", function()
        check:SetValue(not check:GetValue())
      end)

      rows[#rows + 1] = row
    end

    scrollChild:SetHeight(#options * rowHeight)

    popup:SetHeight(#options * rowHeight + 16)
  end

  BuildRows()

  -- 全屏透明拦截层
  local backdrop = CreateFrame("Frame", nil, UIParent)
  ConfigureManagedPopup(backdrop, Widgets.POPUP_BACKDROP_LEVEL)
  backdrop:SetAllPoints(UIParent)
  backdrop:EnableMouse(true)
  backdrop:Hide()
  RegisterManagedPopup(popup, backdrop)

  local function ClosePopup()
    popup:Hide()
    backdrop:Hide()
    container._open = false
    arrow:SetRotation(0)
    ApplyBorder(false)
  end

  local function OpenPopup()
    popup:ClearAllPoints()
    local _, py = container:GetCenter()
    if py and py < 220 then
      popup:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 0, -4)
    else
      popup:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 4)
    end
    backdrop:Show()
    popup:Show()
    container._open = true
    arrow:SetRotation(math.pi)
    ApplyBorder(true)
  end

  backdrop:SetScript("OnMouseDown", function()
    ClosePopup()
  end)

  local button = CreateFrame("Button", nil, container)
  button:SetAllPoints()
  button:SetScript("OnClick", function()
    if container._open then ClosePopup() else OpenPopup() end
  end)

  popup:SetScript("OnHide", function()
    container._open = false
    arrow:SetRotation(0)
    ApplyBorder(false)
  end)

  container.SetValue = function(self, v)
    selectedValues = v or {}
    if type(selectedValues) ~= "table" then selectedValues = {} end
    UpdateDisplay()
    for _, row in ipairs(rows) do
      if row.check and row.optValue then
        row.check:SetValue(IsSelected(row.optValue))
      end
    end
  end

  container.GetValue = function(self)
    return selectedValues
  end

  return container
end

function Widgets:CreateDivider(parent)
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetHeight(1)
  line:SetColorTexture(0x25/255, 0x33/255, 0x42/255, 0.9)
  return line
end

function Widgets:CreateLabel(parent, text, colorName)
  local label = parent:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
  label:SetText(text or "")
  local color = Theme:Color(colorName or "muted")
  label:SetTextColor(color[1], color[2], color[3], color[4] or 1)
  label:SetJustifyH("LEFT")
  label:SetWordWrap(true)
  return label
end

function Widgets:CreateKeybind(parent, value, onChanged)
  -- value: 按键字符串，如 "ALT-F"，nil 表示未绑定

  local container = CreateFrame("Button", nil, parent)
  container:SetSize(180, 24)

  -- 背景
  local bg = container:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.92)

  -- 四边边框
  local function MakeEdge() return container:CreateTexture(nil, "BORDER") end
  local et = MakeEdge(); et:SetPoint("TOPLEFT"); et:SetPoint("TOPRIGHT"); et:SetHeight(1)
  local eb = MakeEdge(); eb:SetPoint("BOTTOMLEFT"); eb:SetPoint("BOTTOMRIGHT"); eb:SetHeight(1)
  local el = MakeEdge(); el:SetPoint("TOPLEFT"); el:SetPoint("BOTTOMLEFT"); el:SetWidth(1)
  local er = MakeEdge(); er:SetPoint("TOPRIGHT"); er:SetPoint("BOTTOMRIGHT"); er:SetWidth(1)
  local edges = {et, eb, el, er}

  local function ApplyBorder(focused)
    local accent = Theme:Color("accent")
    local a = focused and 1 or 0.6
    for _, e in ipairs(edges) do e:SetColorTexture(accent[1], accent[2], accent[3], a) end
  end
  ApplyBorder(false)
  container._huiListenerID = Theme:OnAccentChanged(function() ApplyBorder(container._listening) end)

  -- 显示文本
  local keyText = container:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
  keyText:SetPoint("CENTER")
  keyText:SetTextColor(0.90, 0.92, 0.95, 1)

  local currentValue = value or ""

  local function FormatKey(key)
    if not key or key == "" then
      return "|cff555555" .. L.notBound .. "|r"
    end
    return key
  end

  keyText:SetText(FormatKey(currentValue))

  -- 监听状态
  container._listening = false

  local function StopListening(save)
    container._listening = false
    container:EnableKeyboard(false)
    container:SetScript("OnKeyDown", nil)
    ApplyBorder(false)
    bg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.92)
    keyText:SetText(FormatKey(currentValue))
    if save and type(onChanged) == "function" then
      onChanged(currentValue)
    end
  end

  local function StartListening()
    container._listening = true
    container:EnableKeyboard(true)
    ApplyBorder(true)
    bg:SetColorTexture(0x0a/255, 0x18/255, 0x2c/255, 0.96)
    keyText:SetText("|cffffc702" .. L.pressKey .. "|r")

    container:SetScript("OnKeyDown", function(self, key)
      if key == "ESCAPE" then
        StopListening(false) -- 取消
        return
      end
      if key == "DELETE" or key == "BACKSPACE" then
        currentValue = ""
        StopListening(true) -- 清除绑定
        return
      end

      -- 跳过单独的修饰键
      if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL"
        or key == "LALT" or key == "RALT" or key == "LMETA" or key == "RMETA" then
        return
      end

      -- 组合修饰键前缀
      local prefix = ""
      if IsShiftKeyDown and IsShiftKeyDown() then prefix = "SHIFT-" .. prefix end
      if IsControlKeyDown and IsControlKeyDown() then prefix = "CTRL-" .. prefix end
      if IsAltKeyDown and IsAltKeyDown() then prefix = "ALT-" .. prefix end

      currentValue = prefix .. key
      StopListening(true)
    end)
  end

  container:SetScript("OnClick", function(self)
    if self._listening then
      StopListening(false)
    else
      StartListening()
    end
  end)

  -- 失去焦点时取消监听
  container:SetScript("OnHide", function()
    if container._listening then StopListening(false) end
  end)

  -- 接口
  container.SetValue = function(self, v)
    currentValue = v or ""
    keyText:SetText(FormatKey(currentValue))
  end

  container.GetValue = function(self)
    return currentValue
  end

  return container
end

function Widgets:CreateIconPicker(parent, value, options, onChanged)
  -- value: 当前选中的图标路径字符串
  -- options: { "Interface\\Icons\\icon1", ... } 或 nil（使用默认图标）

  local defaultIcons = {
    "Interface\\Icons\\INV_Misc_QuestionMark",
    "Interface\\Icons\\Spell_Fire_Fireball",
    "Interface\\Icons\\Spell_Frost_Frostbolt",
    "Interface\\Icons\\Spell_Nature_Lightning",
    "Interface\\Icons\\Spell_Holy_PowerWordShield",
    "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    "Interface\\Icons\\Ability_Warrior_Charge",
    "Interface\\Icons\\Ability_Rogue_Vanish",
    "Interface\\Icons\\Ability_Hunter_SteadyShot",
    "Interface\\Icons\\Spell_Druid_Moonfire",
    "Interface\\Icons\\Spell_Arcane_Arcane01",
    "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
  }
  options = options or defaultIcons

  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(72, 24)

  -- 当前图标预览
  local current = value or ""
  local iconSize = 24

  local iconBtn = CreateFrame("Button", nil, container)
  iconBtn:SetSize(iconSize, iconSize)
  iconBtn:SetPoint("LEFT", 0, 0)

  local iconTex = iconBtn:CreateTexture(nil, "ARTWORK")
  iconTex:SetAllPoints()
  iconTex:SetTexture(current ~= "" and current or "Interface\\Icons\\INV_Misc_QuestionMark")
  iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- 裁切边缘

  -- 边框
  local function MakeEdge(f) return f:CreateTexture(nil, "BORDER") end
  local et = MakeEdge(iconBtn); et:SetPoint("TOPLEFT"); et:SetPoint("TOPRIGHT"); et:SetHeight(1)
  local eb = MakeEdge(iconBtn); eb:SetPoint("BOTTOMLEFT"); eb:SetPoint("BOTTOMRIGHT"); eb:SetHeight(1)
  local el = MakeEdge(iconBtn); el:SetPoint("TOPLEFT"); el:SetPoint("BOTTOMLEFT"); el:SetWidth(1)
  local er = MakeEdge(iconBtn); er:SetPoint("TOPRIGHT"); er:SetPoint("BOTTOMRIGHT"); er:SetWidth(1)
  local btnEdges = {et, eb, el, er}

  local function ApplyBorder(active)
    local accent = Theme:Color("accent")
    local a = active and 1 or 0.5
    for _, e in ipairs(btnEdges) do e:SetColorTexture(accent[1], accent[2], accent[3], a) end
  end
  ApplyBorder(false)
  container._huiListenerID = Theme:OnAccentChanged(function() ApplyBorder(container._open) end)

  -- 弹出面板
  local cols, rows = 6, 2
  local cellSize = 32
  local padding = 6
  local popW = cols * cellSize + padding * 2
  local popH = math.ceil(#options / cols) * cellSize + padding * 2

  local popup = CreateFrame("Frame", nil, UIParent)
  ConfigureManagedPopup(popup)
  popup:SetSize(popW, popH)
  popup:Hide()

  local popBg = popup:CreateTexture(nil, "BACKGROUND")
  popBg:SetAllPoints()
  popBg:SetColorTexture(0x06/255, 0x0e/255, 0x16/255, 0.98)

  local popBorder = CreateFrame("Frame", nil, popup, "BackdropTemplate")
  popBorder:SetAllPoints()
  popBorder:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
  local accent = Theme:Color("accent")
  popBorder:SetBackdropBorderColor(accent[1], accent[2], accent[3], 0.8)

  -- 全屏拦截层（需在 BuildGrid 之前声明，供 cell 的 OnClick 闭包捕获）
  local backdrop = CreateFrame("Frame", nil, UIParent)
  ConfigureManagedPopup(backdrop, Widgets.POPUP_BACKDROP_LEVEL)
  backdrop:SetAllPoints(UIParent)
  backdrop:EnableMouse(true)
  backdrop:Hide()
  RegisterManagedPopup(popup, backdrop)

  -- 图标网格
  local cells = {}

  local function BuildGrid()
    ClearFrameList(cells)

    for i, iconPath in ipairs(options) do
      local col = (i-1) % cols
      local row = math.floor((i-1) / cols)

      local cell = CreateFrame("Button", nil, popup)
      cell:SetSize(cellSize - 2, cellSize - 2)
      cell:SetPoint("TOPLEFT", popup, "TOPLEFT",
        padding + col * cellSize,
        -(padding + row * cellSize))

      local tex = cell:CreateTexture(nil, "ARTWORK")
      tex:SetAllPoints()
      tex:SetTexture(iconPath)
      tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

      local highlight = cell:CreateTexture(nil, "HIGHLIGHT")
      highlight:SetAllPoints()
      highlight:SetColorTexture(1, 1, 1, 0.25)

      cell:SetScript("OnClick", function()
        current = iconPath
        iconTex:SetTexture(iconPath)
        popup:Hide()
        backdrop:Hide()
        container._open = false
        ApplyBorder(false)
        if type(onChanged) == "function" then onChanged(iconPath) end
      end)

      cell:SetScript("OnEnter", function()
        highlight:SetColorTexture(1, 1, 1, 0.3)
      end)
      cell:SetScript("OnLeave", function()
        highlight:SetColorTexture(1, 1, 1, 0.25)
      end)

      cells[#cells + 1] = cell
    end
    -- 修正面板高度
    local totalRows = math.ceil(#options / cols)
    popup:SetHeight(totalRows * cellSize + padding * 2)
  end

  BuildGrid()

  local function ClosePopup()
    popup:Hide()
    backdrop:Hide()
    container._open = false
    ApplyBorder(false)
  end

  backdrop:SetScript("OnMouseDown", ClosePopup)

  iconBtn:SetScript("OnClick", function()
    if container._open then
      ClosePopup()
    else
      popup:ClearAllPoints()
      local _, py = iconBtn:GetCenter()
      if py and py < 160 then
        popup:SetPoint("TOPLEFT", iconBtn, "BOTTOMLEFT", 0, -4)
      else
        popup:SetPoint("BOTTOMLEFT", iconBtn, "TOPLEFT", 0, 4)
      end
      backdrop:Show()
      popup:Show()
      container._open = true
      ApplyBorder(true)
    end
  end)

  popup:SetScript("OnHide", function()
    container._open = false
    ApplyBorder(false)
  end)

  container.SetValue = function(self, v)
    current = v or ""
    iconTex:SetTexture(current ~= "" and current or "Interface\\Icons\\INV_Misc_QuestionMark")
  end
  container.GetValue = function(self) return current end

  return container
end

function Widgets:CreateReorderList(parent, items, onChanged)
  -- items: { { id="id", label="Name" }, ... }
  -- 拖拽排序列表

  local order = {}
  for i, item in ipairs(items) do
    order[i] = item
  end

  local rowH = 28
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(300, #order * rowH)

  local rowFrames = {}
  local dragItem = nil
  local dragIndex = nil

  local function Rebuild()
    ClearFrameList(rowFrames)
    container:SetHeight(#order * rowH)

    for i, item in ipairs(order) do
      local row = CreateFrame("Frame", nil, container)
      row:SetSize(container:GetWidth(), rowH)
      row:SetPoint("TOPLEFT", 0, -(i-1) * rowH)

      local bg = row:CreateTexture(nil, "BACKGROUND")
      bg:SetAllPoints()
      bg:SetColorTexture(0x06/255, 0x0f/255, 0x1a/255, 0.85)

      -- 拖拽手柄（左侧三条横线）
      local handle = CreateFrame("Button", nil, row)
      handle:SetSize(16, rowH)
      handle:SetPoint("LEFT", 4, 0)

      for j = 1, 3 do
        local line = handle:CreateTexture(nil, "ARTWORK")
        line:SetSize(10, 1)
        line:SetPoint("CENTER", 0, (j-2)*5)
        line:SetColorTexture(0.55, 0.60, 0.65, 0.75)
      end

      local accent = Theme:Color("accent")
      local label = row:CreateFontString(nil, "OVERLAY", Theme.fonts.small)
      label:SetPoint("LEFT", handle, "RIGHT", 6, 0)
      label:SetText(item.label or item.id)
      label:SetTextColor(0.90, 0.92, 0.95, 1)

      -- 拖拽逻辑
      local rowIndex = i
      handle:SetScript("OnMouseDown", function()
        dragIndex = rowIndex
        dragItem = item
        bg:SetColorTexture(accent[1] * 0.3, accent[2] * 0.3, accent[3] * 0.3, 0.95)
        row:StartMoving()
        row:SetMovable(true)
      end)
      handle:SetScript("OnMouseUp", function()
        if not dragItem then return end
        row:StopMovingOrSizing()
        row:SetMovable(false)

        -- 计算放置位置
        local _, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        local cy = select(2, container:GetCenter())
        local ch = container:GetHeight()
        local relY = (y / scale) - (cy - ch / 2)
        local newIndex = math.min(#order, math.max(1, math.ceil((ch - relY) / rowH)))

        if newIndex ~= dragIndex then
          local moved = table.remove(order, dragIndex)
          table.insert(order, newIndex, moved)
          if type(onChanged) == "function" then onChanged(order) end
        end

        dragItem = nil
        dragIndex = nil
        Rebuild()
      end)

      row:SetScript("OnEnter", function()
        if not dragItem then
          bg:SetColorTexture(0x10/255, 0x1c/255, 0x2c/255, 0.9)
        end
      end)
      row:SetScript("OnLeave", function()
        if not dragItem then
          bg:SetColorTexture(0x06/255, 0x0f/255, 0x1a/255, 0.85)
        end
      end)

      -- 上下移按钮
      if i > 1 then
        local upBtn = self:CreateActionButton(row, "▲", 20, 20, function()
          local moved = table.remove(order, i)
          table.insert(order, i - 1, moved)
          if type(onChanged) == "function" then onChanged(order) end
          Rebuild()
        end)
        upBtn:SetPoint("RIGHT", row, "RIGHT", -24, 0)
      end

      if i < #order then
        local downBtn = self:CreateActionButton(row, "▼", 20, 20, function()
          local moved = table.remove(order, i)
          table.insert(order, i + 1, moved)
          if type(onChanged) == "function" then onChanged(order) end
          Rebuild()
        end)
        downBtn:SetPoint("RIGHT", row, "RIGHT", -2, 0)
      end

      rowFrames[i] = row
    end
  end

  Rebuild()

  container:SetScript("OnHide", function()
    ClearFrameList(rowFrames)
  end)

  container.SetValue = function(self, v)
    order = v or {}
    Rebuild()
  end
  container.GetValue = function(self) return order end

  return container
end

function Widgets:CreateColorPicker(parent, color, onChanged)
  color = type(color) == "table" and color or {1, 1, 1, 1}
  local currentColor = {color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1}
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(28, 24)

  local swatch = CreateFrame("Button", nil, container)
  swatch:SetSize(24, 24)
  swatch:SetPoint("LEFT")

  local checkers = swatch:CreateTexture(nil, "BACKGROUND")
  checkers:SetPoint("TOPLEFT", 2, -2)
  checkers:SetPoint("BOTTOMRIGHT", -2, 2)
  checkers:SetTexture(188523)
  checkers:SetTexCoord(0.25, 0, 0.5, 0.25)
  checkers:SetDesaturated(true)
  checkers:SetVertexColor(1, 1, 1, 0.75)

  local swatchColor = swatch:CreateTexture(nil, "ARTWORK")
  swatchColor:SetPoint("TOPLEFT", 3, -3)
  swatchColor:SetPoint("BOTTOMRIGHT", -3, 3)
  container.swatchBg = swatchColor

  local swatchBorder = swatch:CreateTexture(nil, "OVERLAY")
  swatchBorder:SetAllPoints()
  swatchBorder:SetTexture(130939)

  local function UpdateColor(value, notify)
    currentColor = {value[1] or 1, value[2] or 1, value[3] or 1, value[4] or 1}
    swatchColor:SetColorTexture(currentColor[1], currentColor[2], currentColor[3], currentColor[4])
    if notify and type(onChanged) == "function" then
      onChanged({currentColor[1], currentColor[2], currentColor[3], currentColor[4]})
    end
  end
  UpdateColor(currentColor, false)

  swatch:SetScript("OnClick", function()
    local picker = rawget(_G, "ColorPickerFrame")
    if not picker then return end
    picker:Hide()
    ConfigureManagedPopup(picker)
    picker:SetClampedToScreen(true)
    if _registeredNativeColorPicker ~= picker then
      RegisterManagedPopup(picker)
      _registeredNativeColorPicker = picker
    end

    local original = {currentColor[1], currentColor[2], currentColor[3], currentColor[4]}
    local opening = true
    local function ApplyPickerColor()
      if opening then return end
      local r, g, b = picker:GetColorRGB()
      local opacitySlider = rawget(_G, "OpacitySliderFrame")
      local opacity = picker.GetColorAlpha and picker:GetColorAlpha()
        or (opacitySlider and opacitySlider:GetValue()) or 0
      UpdateColor({r, g, b, 1 - opacity}, true)
    end
    local function RestoreOriginal()
      opening = false
      UpdateColor(original, true)
    end

    if picker.SetupColorPickerAndShow then
      picker:SetupColorPickerAndShow({
        r = original[1], g = original[2], b = original[3],
        hasOpacity = true, opacity = 1 - original[4],
        swatchFunc = ApplyPickerColor,
        opacityFunc = ApplyPickerColor,
        cancelFunc = RestoreOriginal,
      })
      opening = false
    else
      picker.func = ApplyPickerColor
      picker.swatchFunc = ApplyPickerColor
      picker.opacityFunc = ApplyPickerColor
      picker.cancelFunc = RestoreOriginal
      picker.hasOpacity = true
      picker.opacity = 1 - original[4]
      picker:SetColorRGB(original[1], original[2], original[3])
      opening = false
      picker:Show()
    end
  end)

  container.SetValue = function(self, value) UpdateColor(value, false) end
  container.GetValue = function(self)
    return {currentColor[1], currentColor[2], currentColor[3], currentColor[4]}
  end
  return container
end

function Widgets:CreateScrollFrame(parent, width, height)
  -- 可滚动容器：ScrollFrame + 主题化滚动条
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(width or 400, height or 300)

  -- 滚动区域（左侧，留出右侧滚动条空间）
  local scrollFrame = CreateFrame("ScrollFrame", nil, container)
  scrollFrame:SetPoint("TOPLEFT", 0, 0)
  scrollFrame:SetPoint("BOTTOMRIGHT", -12, 0)
  scrollFrame:EnableMouseWheel(true)
  container.scrollFrame = scrollFrame

  -- 内容容器（开发者把内容放这里）
  local contentWidth = (width or 400) - 12  -- 减去滚动条宽度
  local content = CreateFrame("Frame", nil, scrollFrame)
  content:SetWidth(contentWidth)
  content:SetHeight(1) -- 初始高度，实际由内容决定
  scrollFrame:SetScrollChild(content)
  container.content = content

  -- 滚动条轨道
  local trackBg = container:CreateTexture(nil, "BACKGROUND")
  trackBg:SetWidth(8)
  trackBg:SetColorTexture(0x0f/255, 0x17/255, 0x21/255, 0.85)
  trackBg:SetPoint("TOPRIGHT", container, "TOPRIGHT", -2, -2)
  trackBg:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -2, 2)

  -- 滚动条 thumb（可拖动）
  local thumb = CreateFrame("Button", nil, container)
  thumb:SetWidth(8)
  thumb:SetPoint("TOP", trackBg, "TOP", 0, 0)
  
  local thumbTex = thumb:CreateTexture(nil, "OVERLAY")
  thumbTex:SetAllPoints()
  container.thumbTex = thumbTex

  local function ApplyThumbColor()
    local accent = Theme:Color("accent")
    thumbTex:SetColorTexture(accent[1], accent[2], accent[3], 0.9)
  end
  ApplyThumbColor()
  scrollFrame._huiListenerID = Theme:OnAccentChanged(ApplyThumbColor)

  -- 计算 thumb 高度和位置
  local function UpdateThumb()
    local contentHeight = content:GetHeight() or 1
    local viewHeight = scrollFrame:GetHeight() or 1
    if contentHeight <= viewHeight then
      thumb:Hide()
      return
    end
    thumb:Show()

    local ratio = viewHeight / contentHeight
    local thumbHeight = math.max(20, viewHeight * ratio)
    thumb:SetHeight(thumbHeight)

    local scrollRange = contentHeight - viewHeight
    local scrollPos = scrollFrame:GetVerticalScroll()
    local scrollPct = scrollRange > 0 and (scrollPos / scrollRange) or 0
    local trackHeight = trackBg:GetHeight() or viewHeight
    local maxOffset = trackHeight - thumbHeight
    thumb:ClearAllPoints()
    thumb:SetPoint("TOP", trackBg, "TOP", 0, -scrollPct * maxOffset)
  end

  -- 容器尺寸变化时同步内容宽度
  scrollFrame:SetScript("OnSizeChanged", function(self, w, h)
    content:SetWidth(w) -- scrollFrame 已经比 container 窄了 12px
    UpdateThumb()
  end)

  scrollFrame:SetScript("OnScrollRangeChanged", UpdateThumb)
  scrollFrame:SetScript("OnVerticalScroll", UpdateThumb)
  scrollFrame:SetScript("OnSizeChanged", UpdateThumb)
  content:SetScript("OnSizeChanged", UpdateThumb)

  -- 鼠标滚轮
  scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local step = 20
    local newScroll = current - delta * step
    local maxScroll = (content:GetHeight() or 0) - (self:GetHeight() or 0)
    newScroll = math.max(0, math.min(newScroll, maxScroll))
    self:SetVerticalScroll(newScroll)
  end)

  -- thumb 拖动
  thumb:EnableMouse(true)
  thumb:SetScript("OnMouseDown", function(self)
    self.dragging = true
    self.startY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
    self.startScroll = scrollFrame:GetVerticalScroll()
  end)
  thumb:SetScript("OnMouseUp", function(self)
    self.dragging = false
  end)
  thumb:SetScript("OnUpdate", function(self)
    if not self.dragging then return end
    local currentY = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
    local deltaY = self.startY - currentY
    local trackHeight = trackBg:GetHeight() or 1
    local thumbHeight = self:GetHeight() or 20
    local maxOffset = trackHeight - thumbHeight
    local contentHeight = content:GetHeight() or 1
    local viewHeight = scrollFrame:GetHeight() or 1
    local scrollRange = contentHeight - viewHeight
    if maxOffset > 0 and scrollRange > 0 then
      local scrollDelta = (deltaY / maxOffset) * scrollRange
      local newScroll = math.max(0, math.min(self.startScroll + scrollDelta, scrollRange))
      scrollFrame:SetVerticalScroll(newScroll)
    end
  end)

  UpdateThumb()
  return container
end

function Widgets:CreateInput(parent, value, onChanged)
  -- 现代直角输入框：深色底 + 重点色边框（支持换色）
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(180, 24)

  -- 背景
  container.bg = container:CreateTexture(nil, "BACKGROUND")
  container.bg:SetAllPoints()
  container.bg:SetColorTexture(0x0a/255, 0x12/255, 0x1c/255, 0.92)

  -- 四边重点色边框
  local function MakeEdge()
    local t = container:CreateTexture(nil, "BORDER")
    return t
  end
  container.edgeTop = MakeEdge()
  container.edgeTop:SetPoint("TOPLEFT")
  container.edgeTop:SetPoint("TOPRIGHT")
  container.edgeTop:SetHeight(1)

  container.edgeBottom = MakeEdge()
  container.edgeBottom:SetPoint("BOTTOMLEFT")
  container.edgeBottom:SetPoint("BOTTOMRIGHT")
  container.edgeBottom:SetHeight(1)

  container.edgeLeft = MakeEdge()
  container.edgeLeft:SetPoint("TOPLEFT")
  container.edgeLeft:SetPoint("BOTTOMLEFT")
  container.edgeLeft:SetWidth(1)

  container.edgeRight = MakeEdge()
  container.edgeRight:SetPoint("TOPRIGHT")
  container.edgeRight:SetPoint("BOTTOMRIGHT")
  container.edgeRight:SetWidth(1)

  -- 输入框本体
  local editBox = CreateFrame("EditBox", nil, container)
  editBox:SetPoint("TOPLEFT", container, "TOPLEFT", 8, -1)
  editBox:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -8, 1)
  editBox:SetAutoFocus(false)
  editBox:SetFontObject(Theme.fonts.body)
  editBox:SetTextColor(0.95, 0.96, 0.98, 1)
  editBox:SetText(tostring(value or ""))
  editBox:SetCursorPosition(0)
  container.editBox = editBox

  -- 边框换色（聚焦时高亮，普通时半透明）
  local function ApplyBorder(focused)
    local accent = Theme:Color("accent")
    local a = focused and 1 or 0.6
    local edges = { container.edgeTop, container.edgeBottom, container.edgeLeft, container.edgeRight }
    for _, edge in ipairs(edges) do
      edge:SetColorTexture(accent[1], accent[2], accent[3], a)
    end
  end
  ApplyBorder(false)
  container._huiListenerID = Theme:OnAccentChanged(function()
    ApplyBorder(editBox:HasFocus())
  end)

  editBox:SetScript("OnEditFocusGained", function()
    ApplyBorder(true)
  end)
  editBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    if type(onChanged) == "function" then
      onChanged(self:GetText())
    end
  end)
  editBox:SetScript("OnEditFocusLost", function(self)
    ApplyBorder(false)
    if type(onChanged) == "function" then
      onChanged(self:GetText())
    end
  end)

  -- 兼容旧接口：把常用方法代理到 editBox
  function container:SetText(text)
    self.editBox:SetText(tostring(text or ""))
    self.editBox:SetCursorPosition(0)
  end
  function container:GetText()
    return self.editBox:GetText()
  end

  return container
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 矢量图标系统：纯代码绘制、跟随重点色换色、可扩展
--
-- 用法：
--   local icon = Widgets:CreateVectorIcon(parent, "play", 20)   -- 默认跟随 accent
--   icon:SetPoint("CENTER")
--   icon:SetIconColor("muted")  -- 可选：改用其它主题色（仍随该色实时刷新）
--
-- 扩展（其他作者可注册自定义形状）：
--   Widgets:RegisterIconShape("myShape", function(pen)
--     pen:Line(0.2, 0.2, 0.8, 0.8)     -- 比例坐标 0-1，原点在左下角
--     pen:Rect(0.4, 0.4, 0.2, 0.2)
--     pen:Curve(function(t) return t, 0.5 + math.sin(t*math.pi)*0.3 end)
--   end)
-- ═══════════════════════════════════════════════════════════════════════════

Widgets.IconShapes = Widgets.IconShapes or {}

function Widgets:RegisterIconShape(name, drawer)
  if type(name) == "string" and type(drawer) == "function" then
    self.IconShapes[name] = drawer
  end
end

function Widgets:CreateVectorIcon(parent, shapeName, size, colorName)
  size = size or 16
  local icon = CreateFrame("Frame", nil, parent)
  icon:SetSize(size, size)

  icon._parts = {}          -- 每个图元的染色函数
  icon._colorName = colorName or "accent"

  local defaultThickness = math.max(1.5, size * 0.1)

  -- 绘图笔：所有坐标使用 0-1 比例，原点在左下角；图元自动纳入换色管理
  local pen = { size = size }

  function pen:Line(x1, y1, x2, y2, thickness)
    local line = icon:CreateLine(nil, "OVERLAY")
    line:SetThickness(thickness or defaultThickness)
    line:SetStartPoint("BOTTOMLEFT", x1 * size, y1 * size)
    line:SetEndPoint("BOTTOMLEFT", x2 * size, y2 * size)
    icon._parts[#icon._parts + 1] = function(c) line:SetColorTexture(c[1], c[2], c[3], c[4] or 1) end
    return line
  end

  function pen:Rect(x, y, w, h)
    local tex = icon:CreateTexture(nil, "OVERLAY")
    tex:SetSize(w * size, h * size)
    tex:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", x * size, y * size)
    icon._parts[#icon._parts + 1] = function(c) tex:SetColorTexture(c[1], c[2], c[3], c[4] or 1) end
    return tex
  end

  function pen:Dot(x, y, d)
    return self:Rect(x - d / 2, y - d / 2, d, d)
  end

  -- 曲线：fn(t) 返回比例坐标 (x, y)，t ∈ [0,1]，采样 segments 段连线
  function pen:Curve(fn, segments, thickness)
    segments = segments or 24
    local px, py = fn(0)
    for i = 1, segments do
      local t = i / segments
      local x, y = fn(t)
      self:Line(px, py, x, y, thickness)
      px, py = x, y
    end
  end

  -- 绘制形状
  local drawer = Widgets.IconShapes[shapeName]
  if drawer then
    drawer(pen)
  end

  local function ApplyColor()
    local c = Theme:Color(icon._colorName)
    for _, paint in ipairs(icon._parts) do
      paint(c)
    end
  end
  ApplyColor()
  icon._huiListenerID = Theme:OnAccentChanged(ApplyColor)

  function icon:SetIconColor(name)
    self._colorName = name or "accent"
    ApplyColor()
  end

  return icon
end

-- ─── 预置图标形状 ───────────────────────────────────────────────────────────

-- 停止：实心方块
Widgets:RegisterIconShape("stop", function(pen)
  pen:Rect(0.25, 0.25, 0.5, 0.5)
end)

-- 暂停：两条竖条
Widgets:RegisterIconShape("pause", function(pen)
  pen:Rect(0.28, 0.22, 0.16, 0.56)
  pen:Rect(0.56, 0.22, 0.16, 0.56)
end)

-- 播放：三角形轮廓（三条线）
Widgets:RegisterIconShape("play", function(pen)
  pen:Line(0.30, 0.20, 0.30, 0.80)
  pen:Line(0.30, 0.80, 0.78, 0.50)
  pen:Line(0.78, 0.50, 0.30, 0.20)
end)

-- 加号
Widgets:RegisterIconShape("plus", function(pen)
  pen:Rect(0.44, 0.18, 0.12, 0.64)
  pen:Rect(0.18, 0.44, 0.64, 0.12)
end)

-- 对勾
Widgets:RegisterIconShape("check", function(pen)
  pen:Line(0.20, 0.50, 0.42, 0.28)
  pen:Line(0.42, 0.28, 0.80, 0.74)
end)

-- 关闭（叉）
Widgets:RegisterIconShape("close", function(pen)
  pen:Line(0.24, 0.24, 0.76, 0.76)
  pen:Line(0.24, 0.76, 0.76, 0.24)
end)

-- 圆环
Widgets:RegisterIconShape("circle", function(pen)
  pen:Curve(function(t)
    local a = t * 2 * math.pi
    return 0.5 + math.cos(a) * 0.32, 0.5 + math.sin(a) * 0.32
  end, 32)
end)

-- 正弦波
Widgets:RegisterIconShape("wave", function(pen)
  pen:Curve(function(t)
    return 0.1 + t * 0.8, 0.5 + math.sin(t * math.pi * 2) * 0.28
  end, 36)
end)

-- 音符：符头（圆点）+ 符干 + 符尾
Widgets:RegisterIconShape("note", function(pen)
  pen:Curve(function(t)
    local a = t * 2 * math.pi
    return 0.32 + math.cos(a) * 0.12, 0.26 + math.sin(a) * 0.12
  end, 20)
  pen:Rect(0.42, 0.26, 0.05, 0.52)
  pen:Line(0.44, 0.78, 0.72, 0.66)
end)

-- 向上箭头
Widgets:RegisterIconShape("arrowUp", function(pen)
  pen:Rect(0.46, 0.20, 0.08, 0.60)
  pen:Line(0.50, 0.80, 0.28, 0.56)
  pen:Line(0.50, 0.80, 0.72, 0.56)
end)
