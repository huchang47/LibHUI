--[[
  LibHUI - Modern UI Library for WoW Addons
  License: https://raw.githubusercontent.com/huchang47/LibHUI/main/LICENSE.md
  Do not remove this notice from redistributed copies.
]]

local addonName, addon = ...

addon.LibHUI = addon.LibHUI or {}

local HUI = addon.LibHUI
local Config = HUI.Config
local Theme = HUI.Theme
local Widgets = HUI.Widgets
local UI = {}

local CreateFrame = CreateFrame
local UIParent = UIParent
local ipairs = ipairs
local pairs = pairs
local type = type
local tonumber = tonumber
local tostring = tostring
local wipe = wipe

HUI.UI = UI

local L = HUI.L

local function ClearChildren(frame)
  if not frame or not frame.children then
    return
  end

  for _, child in ipairs(frame.children) do
    child:Hide()
    child:SetParent(nil)
    -- 注销换色监听器，防止泄漏
    if child._huiListenerID then
      Theme:OffAccentChanged(child._huiListenerID)
      child._huiListenerID = nil
    end
    if child._huiListenerIDs then
      for _, id in ipairs(child._huiListenerIDs) do
        Theme:OffAccentChanged(id)
      end
      child._huiListenerIDs = nil
    end
  end

  wipe(frame.children)
end

local function Track(parent, child)
  parent.children = parent.children or {}
  parent.children[#parent.children + 1] = child
  return child
end

-- 将子控件的换色监听 ID 注册到父 row，确保 row 被清理时一并注销
local function CollectListener(row, widget)
  if widget and widget._huiListenerID then
    row._huiListenerIDs = row._huiListenerIDs or {}
    row._huiListenerIDs[#row._huiListenerIDs + 1] = widget._huiListenerID
  end
end

function UI:GetFrame()
  if self.frame then
    return self.frame
  end

  local frame = Widgets:CreatePanel(UIParent, "LibHUISettingsFrame")
  frame:SetSize(Theme.sizes.frameWidth, Theme.sizes.frameHeight)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:SetScript("OnHide", function()
    Widgets:CloseManagedPopups()
  end)
  frame:Hide()

  frame._HUIState = {
    rows = {},
  }

  -- Logo（可选，由 app.opts.logo 指定贴图路径），默认隐藏
  frame.logo = frame:CreateTexture(nil, "ARTWORK")
  frame.logo:SetSize(28, 28)
  frame.logo:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -12)
  frame.logo:Hide()

  frame.title = Widgets:CreateText(frame, Theme.fonts.title, "LibHUI", "text")
  frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -14)

  frame.close = Widgets:CreateActionButton(frame, "×", 28, 24, function()
    frame:Hide()
  end)
  frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)

  frame.nav = CreateFrame("Frame", nil, frame)
  frame.nav:SetPoint("TOPLEFT", frame, "TOPLEFT", 190, -14)
  frame.nav:SetPoint("TOPRIGHT", frame.close, "TOPLEFT", -12, 0)
  frame.nav:SetHeight(28)
  frame.nav.children = {}

  frame.subnav = CreateFrame("Frame", nil, frame)
  frame.subnav:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -56)
  frame.subnav:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -56)
  frame.subnav:SetHeight(28)
  frame.subnav.children = {}

  frame.listScroll = Widgets:CreateScrollFrame(frame, Theme.sizes.sidebarWidth, 460)
  frame.listScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -96)
  frame.listScroll.children = {}
  -- 兼容旧代码：frame.list 指向可写入内容的子容器
  frame.list = frame.listScroll.content
  frame.list.children = {}

  frame.detail = Widgets:CreatePanel(frame)
  frame.detail:SetPoint("TOPLEFT", frame.listScroll, "TOPRIGHT", 18, 0)
  frame.detail:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 58)

  frame.detailTitle = Widgets:CreateText(frame.detail, Theme.fonts.heading, "", "text")
  frame.detailTitle:SetPoint("TOPLEFT", frame.detail, "TOPLEFT", 20, -28)
  frame.detailTitle:SetPoint("TOPRIGHT", frame.detail, "TOPRIGHT", -20, -28)
  frame.detailTitle:SetJustifyH("CENTER")

  frame.detailDesc = Widgets:CreateText(frame.detail, Theme.fonts.body, "", "muted")
  frame.detailDesc:SetPoint("TOPLEFT", frame.detailTitle, "BOTTOMLEFT", 0, -18)
  frame.detailDesc:SetPoint("TOPRIGHT", frame.detailTitle, "BOTTOMRIGHT", 0, -18)
  frame.detailDesc:SetJustifyH("CENTER")
  frame.detailDesc:SetWordWrap(true)

  -- 详情区自定义内容容器：control 可提供 detailRenderer(container, control) 在此渲染任意控件（如可勾选列表、图标画廊）
  frame.detailContent = CreateFrame("Frame", nil, frame.detail)
  frame.detailContent:SetPoint("TOPLEFT", frame.detailDesc, "BOTTOMLEFT", 0, -16)
  frame.detailContent:SetPoint("BOTTOMRIGHT", frame.detail, "BOTTOMRIGHT", -20, 20)
  frame.detailContent.children = {}

  frame.footer = CreateFrame("Frame", nil, frame)
  frame.footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 14)
  frame.footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 14)
  frame.footer:SetHeight(30)

  frame.reloadUI = Widgets:CreateActionButton(frame.footer, L.reloadUI, 110, 26, function()
    ReloadUI()
  end)
  frame.reloadUI:SetPoint("RIGHT", frame.footer, "RIGHT", -118, 0)

  frame.closeBottom = Widgets:CreateActionButton(frame.footer, L.close, 100, 26, function()
    frame:Hide()
  end)
  frame.closeBottom:SetPoint("RIGHT")

  self.frame = frame

  -- 重点色变化时，若界面已打开则重渲染当前页以应用新色
  Theme:OnAccentChanged(function()
    if self.frame and self.frame:IsShown() then
      local state = self.frame._HUIState
      if state and state.app and state.page then
        self:Render(state.app, state.page.id)
      end
    end
  end)

  return frame
end

function UI:SetDetail(control)
  local frame = self:GetFrame()

  -- 每次切换详情前清理上一控件的自定义内容，避免残留
  ClearChildren(frame.detailContent)

  if not control then
    frame.detailTitle:SetText("")
    frame.detailDesc:SetText("")
    return
  end

  frame.detailTitle:SetText(control.label or control.title or control.id or "")

  -- description/desc 支持函数形式：运行时求值，便于显示随选项变化的动态文本（如歌词）
  local desc = control.description or control.desc or ""
  if type(desc) == "function" then
    desc = desc(control) or ""
  end
  frame.detailDesc:SetText(desc)

  -- detailRenderer(container, control)：control 可在详情区渲染任意自定义控件（如可勾选曲目列表、图标画廊）
  if type(control.detailRenderer) == "function" then
    control.detailRenderer(frame.detailContent, control)
  end
end

function UI:RenderNav(app, currentPage)
  local frame = self:GetFrame()
  ClearChildren(frame.nav)

  local currentCategoryID = currentPage and currentPage.category
  local lastButton
  for _, category in ipairs(app.categoryList) do
    local button = Track(frame.nav, Widgets:CreateButton(frame.nav, category.title or category.id, 100, 26))
    if button.SetSelected then
      button:SetSelected(category.id == currentCategoryID)
    end
    if lastButton then
      button:SetPoint("LEFT", lastButton, "RIGHT", 8, 0)
    else
      button:SetPoint("LEFT")
    end

    button:SetScript("OnClick", function()
      local page = category.pages and category.pages[1]
      if page then
        self:Render(app, page.id)
      end
    end)

    lastButton = button
  end
end

function UI:RenderSubNav(app, currentPage)
  local frame = self:GetFrame()
  ClearChildren(frame.subnav)

  local currentCategory = currentPage and currentPage.category and app.categories[currentPage.category]
  if not currentCategory then
    return
  end

  local lastButton
  for _, page in ipairs(currentCategory.pages) do
    local button = Track(frame.subnav, Widgets:CreateButton(frame.subnav, page.title or page.id, 128, 24))
    if button.SetSelected then
      button:SetSelected(page.id == currentPage.id)
    end
    if lastButton then
      button:SetPoint("LEFT", lastButton, "RIGHT", 8, 0)
    else
      button:SetPoint("LEFT")
    end

    button:SetScript("OnClick", function()
      self:Render(app, page.id)
    end)

    lastButton = button
  end
end

function UI:RenderControl(app, parent, control, yOffset)
  local controlType = control.type

  -- divider：只渲染一条分割线，不创建 row
  if controlType == "divider" then
    -- 占位 frame 供 yOffset 计算用，并纳入 Track 以便重绘时清理
    local placeholder = Track(parent, CreateFrame("Frame", nil, parent))
    placeholder:SetHeight(8)
    placeholder:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    placeholder:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)
    -- 分割线挂在占位 frame 上，随其一起隐藏，避免残留
    local line = placeholder:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetColorTexture(0x25/255, 0x33/255, 0x42/255, 0.9)
    line:SetPoint("TOPLEFT", placeholder, "TOPLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", placeholder, "TOPRIGHT", 0, 0)
    placeholder.SetSelected = function() end
    return placeholder
  end

  -- label：跨行显示文本，无左侧标签
  if controlType == "label" then
    local row = Track(parent, CreateFrame("Frame", nil, parent))
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)
    row:SetHeight(Theme.sizes.rowHeight)
    local lbl = Widgets:CreateLabel(row, control.label or control.text or "", "muted")
    lbl:SetPoint("LEFT", row, "LEFT", 14, 0)
    lbl:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    row.SetSelected = function() end
    return row
  end

  local row = Track(parent, Widgets:CreateRow(parent, Theme.sizes.rowHeight))
  row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
  row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)

  local label = Widgets:CreateText(row, Theme.fonts.small, control.label or control.id, app:IsControlEnabled(control) and "text" or "disabled")
  label:SetPoint("LEFT", row, "LEFT", 14, 0)
  label:SetPoint("RIGHT", row, "CENTER", -8, 0)
  label:SetJustifyH("LEFT")

  -- 注册 label 到 row，让 SetSelected 时更新文字颜色
  row._labels = row._labels or {}
  row._labels[#row._labels + 1] = label

  local value = app:GetValue(control)

  if controlType == "button" then
    local btn = Widgets:CreateActionButton(row, control.buttonText or control.label or control.id, 100, 22, function()
      if type(control.onClick) == "function" then
        control.onClick(control)
      end
    end)
    btn:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    -- 绑定 widget 到 control，供外部调用 :SetText 更新按钮文字（如试听/停止切换）
    control.widget = btn
  elseif controlType == "toggle" then
    local toggle = Widgets:CreateToggle(row, value, function(checked)
      app:SetValue(control, checked)
      self:SetDetail(control)
    end)
    toggle:SetPoint("RIGHT", row, "RIGHT", -12, 0)
  elseif controlType == "slider" then
    local slider = Widgets:CreateSlider(row, value, control.min, control.max, control.step, function(currentValue)
      app:SetValue(control, currentValue)
    end)
    CollectListener(row, slider)

    local function FormatValue(v)
      return control.formatter and control.formatter(v) or tostring(tonumber(v) or v)
    end

    local valueText = Widgets:CreateText(row, Theme.fonts.small, FormatValue(value), "text")
    -- 数值文本固定宽度并右对齐到行右缘，slider 锚到其左缘
    -- 固定宽度可避免文本宽度随数值变化导致 slider 长度抖动
    valueText:SetWidth(52)
    valueText:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    valueText:SetJustifyH("RIGHT")
    slider:SetSize(150, 16)
    slider:SetPoint("RIGHT", valueText, "LEFT", -8, 0)

    slider:HookScript("OnValueChanged", function(_, currentValue)
      valueText:SetText(FormatValue(currentValue))
    end)
  elseif controlType == "input" then
    local input = Widgets:CreateInput(row, value, function(text)
      app:SetValue(control, text)
    end)
    input:SetSize(180, 22)
    input:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, input)
  elseif controlType == "dropdown" then
    local opts = control.options or {}
    local dropdown = Widgets:CreateDropdown(row, opts, value, function(selected)
      app:SetValue(control, selected)
      -- 选中变化后刷新详情区，便于动态 description（如随曲目变化的歌词）实时更新
      self:SetDetail(control)
      -- 重渲染当前页，使依赖该值的 visibleWhen 控件即时显示/隐藏
      local frame = self:GetFrame()
      local state = frame._HUIState
      if state and state.app and state.page then
        self:Render(state.app, state.page.id)
      end
    end)
    dropdown:SetSize(180, 22)
    dropdown:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, dropdown)
  elseif controlType == "colorpicker" then
    local initColor = value
    if type(initColor) == "string" then
      local hex = initColor:gsub("#", "")
      if hex:match("^%x%x%x%x%x%x$") then
        initColor = {
          tonumber(hex:sub(1,2), 16) / 255,
          tonumber(hex:sub(3,4), 16) / 255,
          tonumber(hex:sub(5,6), 16) / 255,
          1,
        }
      end
    end
    local picker = Widgets:CreateColorPicker(row, initColor, function(c)
      app:SetValue(control, c)
    end)
    picker:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, picker)
  elseif controlType == "keybind" then
    local keybind = Widgets:CreateKeybind(row, value, function(key)
      app:SetValue(control, key)
    end)
    keybind:SetSize(180, 22)
    keybind:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, keybind)
  elseif controlType == "multidropdown" then
    local opts = control.options or {}
    local multiDropdown = Widgets:CreateMultiDropdown(row, opts, value, function(selected)
      app:SetValue(control, selected)
    end)
    multiDropdown:SetSize(180, 22)
    multiDropdown:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, multiDropdown)
  elseif controlType == "iconpicker" then
    local picker = Widgets:CreateIconPicker(row, value, control.icons, function(icon)
      app:SetValue(control, icon)
    end)
    picker:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    CollectListener(row, picker)
  elseif controlType == "reorderlist" then
    local items = control.items or value or {}
    local list = Widgets:CreateReorderList(row, items, function(newOrder)
      app:SetValue(control, newOrder)
    end)
    list:SetPoint("TOPLEFT", row, "TOPRIGHT", 8, 0)
    list:SetWidth(280)
  else
    local valueText = Widgets:CreateText(row, Theme.fonts.small, tostring(value or ""), "muted")
    valueText:SetPoint("RIGHT", row, "RIGHT", -12, 0)
  end

  row:SetScript("OnClick", function(self)
    local frame = UI:GetFrame()
    for _, existingRow in ipairs(frame._HUIState.rows) do
      existingRow:SetSelected(existingRow == self)
    end
    UI:SetDetail(control)
  end)

  local frame = self:GetFrame()
  frame._HUIState.rows[#frame._HUIState.rows + 1] = row

  return row
end

function UI:Render(appOrID, pageID)
  local app = Config:GetAddOn(appOrID)
  if not app then
    return
  end

  local frame = self:GetFrame()
  frame._HUIState.app = app
  frame._HUIState.rows = {}
  frame._HUIState.selectedControl = nil

  local page = pageID and app.pages[pageID] or app:GetFirstPage()
  if not page then
    frame.title:SetText(app.opts.title or app.id or "HUI")
    return
  end
  frame._HUIState.page = page

  frame.title:SetText(app.opts.settingsTitle or app.opts.title or app.id or "HUI")

  -- 应用 logo：有则显示贴图并把标题右移，无则隐藏并复位标题
  if app.opts.logo then
    frame.logo:SetTexture(app.opts.logo)
    frame.logo:Show()
    frame.title:ClearAllPoints()
    frame.title:SetPoint("TOPLEFT", frame.logo, "TOPRIGHT", 8, 2)
  else
    frame.logo:Hide()
    frame.title:ClearAllPoints()
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -14)
  end

  ClearChildren(frame.list)
  self:RenderNav(app, page)
  self:RenderSubNav(app, page)

  local yOffset = 0
  local renderedGroups = {}

  for _, control in ipairs(page.controls) do
    if app:IsControlVisible(control) then
      if control.groupID and not renderedGroups[control.groupID] then
        local group = app.groups[control.groupID]
        if group then
          local groupHeader = Track(frame.list, Widgets:CreateGroupHeader(frame.list, group.title or group.id, 20))
          groupHeader:SetPoint("TOPLEFT", frame.list, "TOPLEFT", 0, yOffset)
          groupHeader:SetPoint("TOPRIGHT", frame.list, "TOPRIGHT", 0, yOffset)
          yOffset = yOffset - 28
          renderedGroups[control.groupID] = true
        end
      end

      local row = self:RenderControl(app, frame.list, control, yOffset)
      if not frame._HUIState.selectedControl then
        frame._HUIState.selectedControl = control
        row:SetSelected(true)
        self:SetDetail(control)
      end
      yOffset = yOffset - Theme.sizes.rowHeight - 4
    end
  end

  -- 渲染完成后更新内容高度，让滚动条正确计算范围
  local totalHeight = -yOffset
  frame.list:SetHeight(math.max(totalHeight, frame.listScroll.scrollFrame:GetHeight() or 460))
  -- 重置滚动位置到顶部
  frame.listScroll.scrollFrame:SetVerticalScroll(0)
end

function UI:Open(appOrID, pageID)
  local frame = self:GetFrame()
  frame._HUIState.selectedControl = nil
  self:Render(appOrID, pageID)
  frame:Show()
end

function UI:Toggle(appOrID, pageID)
  local frame = self:GetFrame()
  if frame:IsShown() then
    frame:Hide()
  else
    self:Open(appOrID, pageID)
  end
end
