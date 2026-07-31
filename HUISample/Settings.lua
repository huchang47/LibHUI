--[[
  HUI Sample - Settings Configuration

  这个文件演示如何用 HUI 配置完整的设置界面，包含所有控件类型。
  通过少量配置即可生成现代化、主题化的设置中心。
]]

local addonName, addon = ...

local L = addon.L or {}

-- 获取 HUI 接口
local HUI = addon.LibHUI
local Config = HUI and HUI.Config
local UI = HUI and HUI.UI

if not Config or not UI then
  return
end

-- DB 访问函数：返回 SavedVariables profile
local function DB()
  return addon.DB()
end

-- ============================================================
-- 第一步：注册插件
-- ============================================================
-- RegisterAddOn 返回 app 实例，后续所有注册都通过它进行
local app = Config:RegisterAddOn(addonName, {
  title = L["addonTitle"],           -- 插件名（用于界面标题）
  settingsTitle = L["settingsTitle"],  -- 可选：自定义设置大标题
  addonFolder = addonName,        -- 插件文件夹名
  assetRoot = "Interface\\AddOns\\HUISample\\libs\\LibHUI\\Assets\\",  -- 贴图路径
  db = DB,-- SavedVariables 访问函数
})

-- ============================================================
-- 第二步：注册顶部导航分类
-- ============================================================
-- 分类会在界面顶部显示为横向标签（GENERAL | APPEARANCE）
app:RegisterCategory({
  id = "general",-- 唯一 ID
  title = L["categoryGeneral"],    -- 显示名称
  order = 100,          -- 排序权重，数值小的在前
})

app:RegisterCategory({
  id = "appearance",
  title = L["categoryAppearance"],
  order = 200,
})

-- ============================================================
-- 第三步：注册二级页面
-- ============================================================
-- 页面会在分类下显示为二级标签（CONTROLS | INTERFACE）
app:RegisterPage({
  id = "general.core",           -- 唯一 ID，建议格式：category.pageName
  category = "general",          -- 所属分类 ID
  title = L["pageControls"],            -- 标签文字
  description = L["pageControlsDesc"],  -- 可选：页面描述
  order = 100,
})

app:RegisterPage({
  id = "appearance.style",
  category = "appearance",
  title = L["pageInterface"],
  description = L["pageInterfaceDesc"],
  order = 100,
})

-- ============================================================
-- 第四步：注册控件分组（可选）
-- ============================================================
-- 分组标题会在控件列表中以独特样式显示，用于归类
app:RegisterGroup("general.core", {
  id = "general",
  title = L["groupGeneral"],
  order = 100,
})

app:RegisterGroup("appearance.style", {
  id = "style",
  title = L["groupStyle"],
  order = 100,
})

-- ============================================================
-- 第五步：注册控件
-- ============================================================
-- 下面演示所有控件类型及常见用法

-- ──────────────────────────────────────
-- toggle - 开关控件
-- ──────────────────────────────────────
app:RegisterControl("general.core", {
  id = "enabled",              -- 唯一 ID
  key = "enabled",             -- SavedVariables 键名（自动读写）
  groupID = "general",         -- 所属分组 ID
  type = "toggle",             -- 控件类型
  label = L["enableSampleLabel"], -- 左侧标签文字
  description = L["enableSampleDesc"],  -- 右侧说明
  default = true,              -- 默认值
  order = 100,                 -- 在分组内的排序
})

-- ──────────────────────────────────────
-- input - 文本输入控件
-- ──────────────────────────────────────
app:RegisterControl("general.core", {
  id = "title",
  key = "title",
  groupID = "general",
  type = "input",
  label = L["displayTitleLabel"],
  description = L["displayTitleDesc"],
  default = L["addonTitle"],
  order = 200,
})

-- ──────────────────────────────────────
-- dropdown - 下拉选择控件
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "quality",
  key = "quality",
  groupID = "style",
  type = "dropdown",
  label = L["qualityLabel"],
  description = L["qualityDesc"],
  options = {
    { value = "low", label = L["qualityLow"] },
    { value = "medium", label = L["qualityMedium"] },
    { value = "high", label = L["qualityHigh"] },
    { value = "ultra", label = L["qualityUltra"] },
  },
  default = "medium",
  order = 50,
})

-- ──────────────────────────────────────
-- slider - 滑块控件（带自定义格式化）
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "scale",
  key = "scale",
  groupID = "style",
  type = "slider",
  label = L["uiScaleLabel"],
  description = L["uiScaleDesc"],
  min = 0.5,               -- 最小值
  max = 2,                 -- 最大值
  step = 0.05,             -- 步进
  default = 1,
  formatter = function(value)  -- 自定义显示格式（将 0-2 显示为百分比）
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
  order = 100,
})

-- ──────────────────────────────────────
-- 条件显示示例：alpha 滑块仅在 enabled=true 时可用
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "alpha",
  key = "alpha",
  groupID = "style",
  type = "slider",
  label = L["panelAlphaLabel"],
  description = L["panelAlphaDesc"],
  min = 0.2,
  max = 1,
  step = 0.05,
  default = 0.9,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 0.9) * 100)
  end,
  parentCheck = function()  -- 条件启用：返回 false 时控件禁用
    return DB().enabled == true
  end,
  order = 200,
})

-- ──────────────────────────────────────
-- divider - 分割线（视觉分隔）
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "divider1",
  type = "divider",
  order = 250,
})

-- ──────────────────────────────────────
-- label - 纯文本说明
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "note1",
  type = "label",
  label = L["scrollNote1"],
  order = 260,
})

-- ──────────────────────────────────────
-- 额外的测试控件（用于触发滚动条）
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "test_toggle1",
  key = "test_toggle1",
  groupID = "style",
  type = "toggle",
  label = L["testOption1Label"],
  description = L["testOption1Desc"],
  default = false,
  order = 300,
})

app:RegisterControl("appearance.style", {
  id = "test_slider1",
  key = "test_slider1",
  groupID = "style",
  type = "slider",
  label = L["testSlider1Label"],
  description = L["testSlider1Desc"],
  min = 0,
  max = 100,
  step = 1,
  default = 50,
  order = 310,
})

app:RegisterControl("appearance.style", {
  id = "test_dropdown1",
  key = "test_dropdown1",
  groupID = "style",
  type = "dropdown",
  label = L["testDropdown1Label"],
  description = L["testDropdown1Desc"],
  options = {
    { value = "opt1", label = L["option1"] },
    { value = "opt2", label = L["option2"] },
    { value = "opt3", label = L["option3"] },
  },
  default = "opt1",
  order = 320,
})

app:RegisterControl("appearance.style", {
  id = "divider2",
  type = "divider",
  order = 330,
})

app:RegisterControl("appearance.style", {
  id = "test_input1",
  key = "test_input1",
  groupID = "style",
  type = "input",
  label = L["testInput1Label"],
  description = L["testInput1Desc"],
  default = L["sampleText"],
  order = 340,
})

app:RegisterControl("appearance.style", {
  id = "test_toggle2",
  key = "test_toggle2",
  groupID = "style",
  type = "toggle",
  label = L["testOption2Label"],
  description = L["testOption2Desc"],
  default = true,
  order = 350,
})

app:RegisterControl("appearance.style", {
  id = "test_slider2",
  key = "test_slider2",
  groupID = "style",
  type = "slider",
  label = L["testSlider2Label"],
  description = L["testSlider2Desc"],
  min = 0,
  max = 10,
  step = 0.1,
  default = 5,
  formatter = function(v)
    return string.format("%.1f", v)
  end,
  order = 360,
})

app:RegisterControl("appearance.style", {
  id = "divider3",
  type = "divider",
  order = 370,
})

app:RegisterControl("appearance.style", {
  id = "note2",
  type = "label",
  label = L["scrollNote2"],
  order = 380,
})

app:RegisterControl("appearance.style", {
  id = "test_toggle3",
  key = "test_toggle3",
  groupID = "style",
  type = "toggle",
  label = L["testOption3Label"],
  description = L["testOption3Desc"],
  default = false,
  order = 390,
})

-- ──────────────────────────────────────
-- colorpicker - 颜色选择器（同步强调色主题）
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "accentColor",
  key = "accentColor",
  groupID = "style",
  type = "colorpicker",
  label = L["accentColorLabel"],
  description = L["accentColorDesc"],
  default = { 1.0, 0.78, 0.02, 1.0 },  -- 默认黄色
  order = 400,
  setValue = function(value)
    -- 保存到 DB
    DB().accentColor = value
    -- 同步更新主题强调色
    local Theme = HUI.Theme
    if Theme and value and type(value) == "table" then
      Theme:SetAccentColor(value[1] or 1, value[2] or 1, value[3] or 1, value[4] or 1)
    end
  end,
})

-- ──────────────────────────────────────
-- keybind - 按键绑定
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "toggleKey",
  key = "toggleKey",
  groupID = "style",
  type = "keybind",
  label = L["toggleKeyLabel"],
  description = L["toggleKeyDesc"],
  default = "ALT-H",
  order = 410,
})

-- ──────────────────────────────────────
-- multidropdown - 多选下拉
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "enabledModules",
  key = "enabledModules",
  groupID = "style",
  type = "multidropdown",
  label = L["enabledModulesLabel"],
  description = L["enabledModulesDesc"],
  options = {
    { value = "core", label = L["moduleCore"] },
    { value = "ui", label = L["moduleUI"] },
    { value = "data", label = L["moduleData"] },
    { value = "sync", label = L["moduleSync"] },
    { value = "debug", label = L["moduleDebug"] },
  },
  default = { "core", "ui" },
  order = 420,
})

-- ──────────────────────────────────────
-- iconpicker - 图标选择器
-- ──────────────────────────────────────
app:RegisterControl("appearance.style", {
  id = "icon",
  key = "icon",
  groupID = "style",
  type = "iconpicker",
  label = L["iconLabel"],
  description = L["iconDesc"],
  default = "Interface\\Icons\\INV_Misc_QuestionMark",
  order = 430,
})

-- ============================================================
-- 斜杠命令集成
-- ============================================================
SLASH_HUISAMPLE1 = "/hui"
SLASH_HUISAMPLE2 = "/huisample"
SlashCmdList.HUISAMPLE = function(input)
  input = strtrim(input or "")

  -- /hui style - 直接打开样式页面
  if input == "style" then
    UI:Open(app, "appearance.style")
    return
  end

  -- /hui color <preset|#RRGGBB> - 换色命令
  local cmd, arg = input:match("^(%S+)%s*(.*)$")
  if cmd == "color" then
    arg = strtrim(arg or "")
    local Theme = HUI.Theme
    if not Theme or not Theme.SetAccentColorHex then
      print("|cffff0000[HUI]|r " .. L["themeModuleMissing"])
      return
    end

    -- 预设颜色快捷名
    local presets = {
      yellow = "ffc702",
      blue = "4da6ff",
      red = "ff4d4d",
      green = "4dff88",
      purple = "b84dff",
      cyan = "4dffff",
      orange = "ff9933",
      pink = "ff80c0",
    }

    -- 支持预设名和自定义十六进制色值
    if presets[arg:lower()] then
      Theme:SetAccentColorHex(presets[arg:lower()])
      print("|cffffc702[HUI]|r " .. string.format(L["themeColorChanged"], arg:upper()))
    elseif arg:match("^#?%x%x%x%x%x%x$") then
      Theme:SetAccentColorHex(arg)
      print("|cffffc702[HUI]|r " .. string.format(L["themeColorChanged"], arg:upper()))
    else
      print("|cffffc702[HUI]|r " .. L["colorUsage"])
      print(L["colorPresets"])
    end
    return
  end

  -- 默认：切换设置界面
  UI:Toggle(app)
end
