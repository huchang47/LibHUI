# LibHUI - Modern UI Library for WoW Addons

LibHUI 是一个面向《魔兽世界》插件开发者的现代化界面底层库，让你通过少量 Lua 配置即可生成统一、酷炫、可复用的设置界面和基础 UI 组件。

## ✨ 特性

- **零学习成本**：用结构化配置代替大量 `CreateFrame` 代码
- **现代视觉**：深色半透明面板 + 可换色重点色系统 + 平滑动效
- **开箱即用**：toggle/slider/input/dropdown 等常用控件全覆盖
- **独立副本**：每个插件携带自己的 LibHUI 副本，避免版本冲突
- **完整主题化**：支持运行时换色，一键切换蓝/红/绿等主题色
- **灵活扩展**：支持条件显示、自定义校验、格式化器等高级功能

## 🚀 快速开始

### 1. 安装

将 `LibHUI` 目录复制到你的插件 `libs/` 内：

```
YourAddon/
├── YourAddon.toc
├── Core.lua
└── libs/
    └── LibHUI/
        ├── LibHUI.xml
        ├── LibHUIConfig.lua
        ├── LibHUILocales.lua
        ├── LibHUITheme.lua
        ├── LibHUIWidgets.lua
        ├── LibHUISettingsUI.lua
        └── Assets/
```

在 `.toc` 文件中加载 LibHUI（通过 LibHUI.xml 一次性加载全部模块）：

```
libs\LibHUI\LibHUI.xml
```

### 2. 最小示例

```lua
local addonName, addon = ...
local HUI = addon.LibHUI
local Config = HUI.Config
local UI = HUI.UI

-- 注册插件
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return MyAddonDB.profile end,
})

-- 注册分类
app:RegisterCategory({ id = "general", title = "GENERAL", order = 100 })

-- 注册页面
app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "CORE SETTINGS",
  order = 100,
})

-- 注册开关控件
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "ENABLE ADDON",
  description = "Master switch for this addon.",
  default = true,
})

-- 打开设置界面
UI:Toggle(app)
```

就这样！五个配置块生成完整设置界面。

## 📦 控件类型

| 类型 | 说明 | 效果 |
|------|------|------|
| `toggle` | 开关 | ✓ 开/关 |
| `slider` | 滑块 | ▬▬▬●▬ 0-100 |
| `input` | 文本输入 | 文本框 |
| `dropdown` | 下拉选择 | Medium ▼ |
| `multidropdown` | 多选下拉 | 2 selected ▼ |
| `colorpicker` | 颜色选择器 | ■ #4da6ff |
| `keybind` | 按键绑定 | ALT-F |
| `iconpicker` | 图标选择器 | 🛡️ 点击选择 |
| `button` | 动作按钮 | 点击触发回调 |
| `label` | 纯文本说明 | 跨行显示 |
| `divider` | 分割线 | ─────── |

## 🎨 主题换色

LibHUI 支持运行时换色，从黄色切换到任意颜色：

```lua
-- 通过命令换色（示例插件已内置）
/hui color blue      -- 蓝色
/hui color red       -- 红色
/hui color #4da6ff   -- 自定义十六进制色

-- 通过代码换色
local Theme = HUI.Theme
Theme:SetAccentColorHex("4da6ff")
```

所有重点色元素（选中态、边框、滑块、按钮 hover）会即时响应换色。

## 📚 完整文档

- **[API Reference](./docs/API_CN.md)** - 完整 API 文档
- **[English API Reference](./docs/API_EN.md)** - English API documentation
- **[示例插件](./HUISample/)** - 包含所有控件类型的演示

## 🛠️ 高级功能

### 条件显示/禁用

```lua
app:RegisterControl("general.core", {
  id = "advancedOption",
  key = "advanced",
  type = "slider",
  label = "ADVANCED",
  min = 1,
  max = 10,
  -- 仅当 enabled = true 时显示
  visibleWhen = function(db) return db.enabled == true end,
})
```

### 自定义格式化

```lua
app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  type = "slider",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  -- 显示为百分比
  formatter = function(value)
    return string.format("%.0f%%", value * 100)
  end,
})
```

### 自定义读写

```lua
app:RegisterControl("general.core", {
  id = "customValue",
  type = "toggle",
  label = "CUSTOM",
  getValue = function()
    return MyAddon:GetSpecialFlag()
  end,
  setValue = function(value)
    MyAddon:SetSpecialFlag(value)
    MyAddon:Refresh()
  end,
})
```

## 📖 控件选项

所有控件通用字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一标识 |
| `key` | string | SavedVariables 键名（可选，用于自动读写） |
| `type` | string | 控件类型 |
| `label` | string | 左侧标签文字 |
| `description` | string | 右侧说明文字 |
| `default` | any | 默认值 |
| `order` | number | 排序权重（小的在前） |
| `groupID` | string | 所属分组 ID |
| `visibleWhen` | function | 显示条件函数 |
| `hiddenWhen` | function | 隐藏条件函数 |
| `isEnabled` | function | 启用条件函数 |
| `getValue` | function | 自定义读值 |
| `setValue` | function | 自定义写值 |

控件特定字段：

**slider**
- `min`, `max`, `step` - 数值范围和步进
- `formatter` - 格式化函数

**dropdown**
- `options` - 选项数组 `{ { value="id", label="显示名" }, ... }`

**multidropdown**
- `options` - 选项数组 `{ { value="id", label="显示名" }, ... }`
- 值类型：`{ "id1", "id2", ... }` 字符串数组

**colorpicker**
- 值类型：`{ r, g, b, a }` 表（0-1浮点）或 `"#rrggbb"` 字符串

**keybind**
- 值类型：`"ALT-F"`、`"CTRL-SHIFT-1"` 等按键字符串
- 特殊键：`"ESCAPE"` 取消，`"DELETE"` 清除绑定

**iconpicker**
- `icons` - 可选图标路径数组 `{ "Interface\\Icons\\...", ... }`
- 值类型：图标路径字符串

**input**
- `multiline` - 多行输入（计划中）

## 🤝 贡献

HUI 是一个持续进化的项目，欢迎：
- 报告 Bug 和使用反馈
- 提交视觉优化建议
- 贡献新控件类型

## 📄 许可

MIT License - 自由使用于你的 WoW 插件项目

---

**开始你的第一个 HUI 插件**：查看 [HUISample](./HUISample/) 获取完整示例代码。
