# 快速开始

本指南说明如何从零开始把 LibHUI 接入到一个新的或已有的魔兽世界插件中。

## 第 1 步：复制库文件

将根目录的 `LibHUI` 文件夹复制到你的插件 `libs/` 目录下：

```text
MyAddon/
  MyAddon.toc
  Core.lua
  Settings.lua
  libs/
    LibHUI/
      LibHUI.xml
      LibHUIConfig.lua
      LibHUILocales.lua
      LibHUITheme.lua
      LibHUIWidgets.lua
      LibHUISettingsUI.lua
      Assets/
        LibHUI_RowNormal.tga
        LibHUI_RowSelected.tga
```

## 第 2 步：在 TOC 中加载 LibHUI

在你的业务 Lua 文件之前加载 `LibHUI.xml`：

```toc
## Interface: 120007
## Title: My Addon
## SavedVariables: MyAddonDB

libs\LibHUI\LibHUI.xml
Core.lua
Settings.lua
```

## 第 3 步：初始化数据库

在 `Core.lua` 中初始化 SavedVariables，并暴露一个 `DB()` 访问函数：

```lua
local addonName, addon = ...

MyAddonDB = MyAddonDB or {}
MyAddonDB.profile = MyAddonDB.profile or {}

addon.DB = function()
  return MyAddonDB.profile
end
```

## 第 4 步：注册设置界面

在 `Settings.lua` 中注册分类、页面和控件：

```lua
local addonName, addon = ...

local HUI = addon.LibHUI
local Config = HUI and HUI.Config
local UI = HUI and HUI.UI

if not Config or not UI then return end

local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return addon.DB() end,
})

app:RegisterCategory({
  id = "general",
  title = "通用",
  order = 100,
})

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "核心",
  order = 100,
})

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "启用插件",
  description = "插件的总开关。",
  default = true,
  order = 100,
})
```

## 第 5 步：添加斜杠命令

在 `Settings.lua` 底部添加打开设置界面的命令：

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function()
  UI:Toggle(app)
end
```

## 第 6 步：进游戏测试

```text
/reload
/myaddon
```

设置窗口应该会打开。修改控件值后再次 `/reload`，确认设置能够持久化。

---

## 控件类型速查

| 类型 | 说明 |
|------|------|
| `toggle` | 开关 |
| `slider` | 数值滑块，支持 `formatter` 格式化显示 |
| `input` | 文本输入框 |
| `dropdown` | 单选下拉菜单 |
| `multidropdown` | 多选下拉菜单 |
| `colorpicker` | 颜色选择器，支持 RGB 和 HEX 输入 |
| `keybind` | 按键绑定 |
| `iconpicker` | 图标选择器 |
| `reorderlist` | 可拖拽排序列表 |
| `button` | 动作按钮 |
| `label` | 只读文本行 |
| `divider` | 分割线 |

完整字段说明见 [API_CN.md](./API_CN.md)。

---

## 运行时主题换色

```lua
local Theme = addon.LibHUI.Theme
Theme:SetAccentColorHex("4da6ff") -- 蓝色
Theme:SetAccentColorHex("ff4d4d") -- 红色
Theme:SetAccentColorHex("ffc702") -- 默认黄色
```

示例插件也内置了换色命令：

```text
/hui color blue
/hui color #4da6ff
```

---

## 条件显示与条件禁用

```lua
app:RegisterControl("general.core", {
  id = "advancedScale",
  key = "scale",
  type = "slider",
  label = "缩放",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  visibleWhen = function()
    return addon.DB().enabled == true
  end,
})

app:RegisterControl("general.core", {
  id = "alpha",
  key = "alpha",
  type = "slider",
  label = "透明度",
  min = 0.1,
  max = 1,
  step = 0.05,
  default = 0.9,
  isEnabled = function()
    return addon.DB().enabled == true
  end,
})
```

`visibleWhen` 返回 `false` 时控件不会显示；`isEnabled` 返回 `false` 时控件仍显示，但会进入禁用状态。

---

## 自定义读写

嵌套表、派生值或需要触发刷新逻辑时，使用 `getValue` 和 `setValue`：

```lua
app:RegisterControl("general.core", {
  id = "myFlag",
  type = "toggle",
  label = "特殊开关",
  getValue = function()
    return MyAddon:GetFlag()
  end,
  setValue = function(value)
    MyAddon:SetFlag(value)
    MyAddon:Refresh()
  end,
})
```

---

## 发布结构说明

LibHUI 的官方运行时源位于仓库根目录的 `LibHUI/`。宿主插件接入时，将该目录复制到自己的 `libs/LibHUI/` 下即可。

```text
LibHUI/                 -- 官方运行时源
HUISample/libs/LibHUI/  -- 示例插件内嵌副本
```
