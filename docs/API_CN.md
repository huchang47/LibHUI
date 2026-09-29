# HUI API Reference

## Config API

### `Config:RegisterAddOn(addonName, opts)`

注册一个插件，返回 `app` 实例，后续所有注册操作都通过 `app` 进行。

**参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `addonName` | string | 插件名（通常传 `addonName` 变量） |
| `opts.title` | string | 设置界面标题 |
| `opts.settingsTitle` | string | 可选，覆盖设置界面大标题 |
| `opts.db` | function | 返回 SavedVariables profile 的函数 |
| `opts.assetRoot` | string | 可选，自定义贴图路径 |

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return MyAddonDB.profile end,
})
```

---

### `app:RegisterCategory(data)`

注册顶部导航分类。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一 ID |
| `title` | string | 显示名称 |
| `order` | number | 排序权重 |

```lua
app:RegisterCategory({ id = "general", title = "GENERAL", order = 100 })
```

---

### `app:RegisterPage(data)`

注册二级页面。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一 ID（建议格式：`category.pageName`） |
| `category` | string | 所属分类 ID |
| `title` | string | 标签文字 |
| `description` | string | 可选，页面描述 |
| `order` | number | 排序权重 |

```lua
app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "CORE",
  order = 100,
})
```

---

### `app:RegisterGroup(pageID, data)`

注册分组标题，用于将控件归类显示。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一 ID |
| `title` | string | 分组标题文字 |
| `order` | number | 排序权重 |

```lua
app:RegisterGroup("general.core", {
  id = "display",
  title = "DISPLAY",
  order = 100,
})
```

---

### `app:RegisterControl(pageID, data)`

注册一个控件到指定页面。

**通用字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | ✓ | 控件唯一 ID |
| `type` | string | ✓ | 控件类型（见下方） |
| `label` | string | | 左侧标签文字 |
| `description` | string | | 右侧说明面板文字 |
| `key` | string | | db 读写键名 |
| `default` | any | | 默认值 |
| `order` | number | | 排序权重 |
| `groupID` | string | | 所属分组 ID |
| `getValue` | function | | 自定义读取函数 |
| `setValue` | function | | 自定义写入函数 |
| `visibleWhen` | function(db) | | 返回 true 时显示 |
| `hiddenWhen` | function(db) | | 返回 true 时隐藏 |
| `isEnabled` | function(db) | | 返回 false 时禁用 |
| `parentCheck` | function(db) | | 同 isEnabled |

**控件类型：**

#### `toggle` - 开关

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "ENABLE",
  description = "Master switch.",
  default = true,
})
```

#### `slider` - 滑块

额外字段：`min`, `max`, `step`, `formatter`

```lua
app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  type = "slider",
  label = "SCALE",
  min = 0.5,
  max = 2.0,
  step = 0.05,
  default = 1.0,
  formatter = function(v)
    return string.format("%.0f%%", v * 100)
  end,
})
```

#### `input` - 文本输入

```lua
app:RegisterControl("general.core", {
  id = "prefix",
  key = "prefix",
  type = "input",
  label = "PREFIX",
  description = "Message prefix text.",
  default = "[MyAddon]",
})
```

#### `dropdown` - 下拉选择

额外字段：`options`

```lua
app:RegisterControl("general.core", {
  id = "mode",
  key = "mode",
  type = "dropdown",
  label = "MODE",
  options = {
    { value = "auto",   label = "Auto" },
    { value = "manual", label = "Manual" },
    { value = "off",    label = "Off" },
  },
  default = "auto",
})
```

#### `button` - 动作按钮

```lua
app:RegisterControl("general.core", {
  id = "myBtn",
  type = "button",
  label = "DO SOMETHING",
  onClick = function()
    -- 注意：button 类型在 RenderControl 中目前显示为只读文本。
    -- 如需可点击按钮，建议用 HUI.Widgets:CreateActionButton 在自定义 UI 中直接创建。
  end,
})
```

#### `multidropdown` - 多选下拉

额外字段：`options`

```lua
app:RegisterControl("general.core", {
  id = "modules",
  key = "modules",
  type = "multidropdown",
  label = "ENABLED MODULES",
  options = {
    { value = "core",  label = "Core" },
    { value = "ui",    label = "UI" },
    { value = "data",  label = "Data" },
  },
  default = { "core", "ui" },  -- 默认选中的值列表
})
```

#### `colorpicker` - 颜色选择器

值格式：`{ r, g, b, a }`（0-1 浮点），也可以用 `"#rrggbb"` 字符串。

```lua
app:RegisterControl("general.core", {
  id = "accentColor",
  key = "accentColor",
  type = "colorpicker",
  label = "ACCENT COLOR",
  default = { 1.0, 0.78, 0.02, 1.0 },  -- 黄色
})
```

#### `keybind` - 按键绑定

值格式：`"ALT-F"`、`"CTRL-SHIFT-1"` 等字符串。

```lua
app:RegisterControl("general.core", {
  id = "toggleKey",
  key = "toggleKey",
  type = "keybind",
  label = "TOGGLE KEY",
  description = "Press Escape to cancel, Delete to clear.",
  default = "ALT-H",
})
```

#### `iconpicker` - 图标选择器

额外字段：`icons`（可选，自定义图标路径列表）。

```lua
app:RegisterControl("general.core", {
  id = "icon",
  key = "icon",
  type = "iconpicker",
  label = "ICON",
  -- 可选：指定可选图标列表
  icons = {
    "Interface\\Icons\\Spell_Fire_Fireball",
    "Interface\\Icons\\Spell_Frost_Frostbolt",
  },
  default = "Interface\\Icons\\INV_Misc_QuestionMark",
})
```

#### `label` - 纯文本说明

```lua
app:RegisterControl("general.core", {
  id = "note",
  type = "label",
  label = "这段文字会跨全行显示，适合说明信息。",
})
```

#### `divider` - 分割线

```lua
app:RegisterControl("general.core", {
  id = "sep1",
  type = "divider",
  order = 150,
})
```

---

## UI API

### `UI:Toggle(app, pageID)`

如果界面已打开则关闭，否则打开。

```lua
UI:Toggle(app)
UI:Toggle(app, "general.core") -- 打开到指定页面
```

### `UI:Open(app, pageID)`

强制打开界面。

```lua
UI:Open(app, "appearance.style")
```

---

## Theme API

### `Theme:SetAccentColor(r, g, b, a)`

设置主题重点色，r/g/b/a 取值 0-1。

```lua
Theme:SetAccentColor(0.30, 0.65, 1.0, 1.0) -- 蓝色
```

### `Theme:SetAccentColorHex(hex)`

用十六进制设置主题重点色。

```lua
Theme:SetAccentColorHex("4da6ff")   -- 蓝色
Theme:SetAccentColorHex("#e5b836")  -- 金黄色
```

### `Theme:OnAccentChanged(callback)`

注册换色回调，每次换色时触发。返回一个监听器 ID，可用于后续注销。

```lua
local id = Theme:OnAccentChanged(function(accent)
  -- accent 是新的 { r, g, b, a } 表
  myFrame:SetBackdropBorderColor(accent[1], accent[2], accent[3])
end)
```

### `Theme:OffAccentChanged(id)`

注销换色回调。当 UI 元素销毁时应调用，避免监听器累积导致内存泄漏。

```lua
Theme:OffAccentChanged(id)
```

### `Theme:Color(name)`

获取颜色 token，返回 `{ r, g, b, a }` 表。

可用颜色名：`accent` `accentDark` `panel` `panelSoft` `row` `rowHover` `toggleOff` `text` `textDark` `muted` `disabled` `danger` `black`

```lua
local color = Theme:Color("accent")
texture:SetColorTexture(color[1], color[2], color[3], color[4])
```

### `Theme:Asset(name, app)`

获取贴图路径。

```lua
local path = Theme:Asset("rowNormal") -- 返回完整路径字符串
```

---

## Widgets API

所有 Widget 都是工厂方法，返回对应的 Frame/Texture。

### `Widgets:CreatePanel(parent, name)`

创建主题化深色面板（四角装饰 + 边框）。

### `Widgets:CreateText(parent, template, text, colorName)`

创建字体对象。`template` 可用 WoW 字体模板名，`colorName` 用 Theme color token。

### `Widgets:CreateButton(parent, text, width, height)`

创建 tab 导航按钮（带 SetSelected 方法）。

### `Widgets:CreateActionButton(parent, text, width, height, onClick)`

创建动作按钮（hover 时重点色 + 四角装饰）。

### `Widgets:CreateRow(parent, height)`

创建设置行（带贴图背景 + 边框 + SetSelected 方法）。

### `Widgets:CreateGroupHeader(parent, text, height)`

创建分组标题（浅色标签 + 右侧分割线）。

### `Widgets:CreateToggle(parent, checked, onChanged)`

创建开关控件。`onChanged(checked)` 在状态变化时触发。

### `Widgets:CreateCapsuleToggle(parent, checked, onChanged, width, height)`

创建胶囊动效开关：圆角轨道 + 圆形把手，点击时把手 0.14s 缓动滑到另一端，轨道与把手颜色同步渐变。开 = 重点色轨道 + 白把手，关 = 深色轨道 + 灰把手；主题换色即时跟随。

- `width` / `height`：可选，默认 `40 × 20`（把手 = 高度 - 6）
- API 与 `CreateToggle` 一致：`SetChecked(value, animate)` / `GetValue()` / `SetValue(value, animate)`；程序化调用 `SetChecked(v)` 默认瞬移，传第二个参数 `true` 走动画
- 贴图默认按「嵌入插件的 `libs/LibHUI/Assets/`」解析；非标准安装路径可在加载前设置 `HUI.WidgetAssetRoot` 覆盖

设置面板的 `toggle` 控件类型已默认使用本控件。

### `Widgets:CreateSlider(parent, value, minValue, maxValue, step, onChanged)`

创建滑块控件。`onChanged(currentValue)` 在值变化时触发。

### `Widgets:CreateDropdown(parent, options, currentValue, onChanged)`

创建下拉选择控件。`onChanged(value)` 在选项变化时触发。

`options` 格式：`{ { value = "id", label = "显示名" }, ... }`

### `Widgets:CreateInput(parent, value, onChanged)`

创建文本输入框。`onChanged(text)` 在失去焦点或按 Enter 时触发。

### `Widgets:CreateMultiDropdown(parent, options, value, onChanged)`

创建多选下拉控件。`onChanged(selectedValues)` 在选项变化时触发。

- `options` 格式：`{ { value = "id", label = "显示名" }, ... }`
- `value` 格式：`{ "id1", "id2", ... }` 字符串数组

### `Widgets:CreateColorPicker(parent, color, onChanged)`

创建颜色选择器。`onChanged(color)` 在颜色变化时触发。

- `color` 格式：`{ r, g, b, a }` 表（0-1浮点）

### `Widgets:CreateKeybind(parent, value, onChanged)`

创建按键绑定控件。`onChanged(keyString)` 在绑定变化时触发。

- `value` 格式：`"ALT-F"`、`"CTRL-SHIFT-1"` 等字符串

### `Widgets:CreateIconPicker(parent, value, options, onChanged)`

创建图标选择器。`onChanged(iconPath)` 在图标变化时触发。

- `value`: 当前选中图标路径字符串
- `options`: 可选图标路径数组（可选，有默认图标）

### `Widgets:CreateScrollFrame(parent, width, height)`

创建可滚动容器，返回带主题化滚动条的Frame。

- 使用 `container.content` 添加内容
- 支持鼠标滚轮和拖动滚动条

### `Widgets:CreateLabel(parent, text, colorName)`

创建纯文本标签。

### `Widgets:CreateDivider(parent)`

创建分割线纹理。

---

## 推荐用法模式

### SavedVariables 标准结构

```lua
-- Core.lua
MyAddonDB = MyAddonDB or {}
MyAddonDB.profile = MyAddonDB.profile or {}

addon.DB = function()
  local profile = MyAddonDB.profile
  if profile.enabled == nil then profile.enabled = true end
  if profile.scale == nil then profile.scale = 1.0 end
  return profile
end
```

### 斜杠命令集成

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(input)
  input = strtrim(input or "")
  if input == "" then
    UI:Toggle(app)
    return
  end
  local cmd, arg = input:match("^(%S+)%s*(.*)$")
  if cmd == "color" then
    Theme:SetAccentColorHex(strtrim(arg))
    return
  end
end
```
