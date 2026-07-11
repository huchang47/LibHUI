# LibHUI - Modern UI Library for WoW Addons

LibHUI is a modern UI framework for World of Warcraft addon developers. With minimal Lua configuration, you can generate a consistent, polished, and reusable settings panel and UI components.

## ✨ Features

- **Zero learning curve**: Replace hundreds of `CreateFrame` lines with structured config
- **Modern visuals**: Dark semi-transparent panels + runtime accent color system
- **Ready to use**: Full coverage of toggle, slider, input, dropdown, and more
- **Self-contained**: Each addon ships its own LibHUI copy — no version conflicts
- **Fully themed**: Switch between blue, red, green and any custom accent color at runtime
- **Flexible**: Supports conditional visibility, custom validators, formatters, and more

## 🚀 Quick Start

### 1. Installation

Copy the `LibHUI` directory into your addon's `libs/` folder:

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

Load LibHUI in your `.toc` file (loads all modules via LibHUI.xml):

```
libs\LibHUI\LibHUI.xml
```

### 2. Minimal Example

```lua
local addonName, addon = ...
local HUI = addon.LibHUI
local Config = HUI.Config
local UI = HUI.UI

-- Register addon
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return MyAddonDB.profile end,
})

-- Register category
app:RegisterCategory({ id = "general", title = "GENERAL", order = 100 })

-- Register page
app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "CORE SETTINGS",
  order = 100,
})

-- Register a toggle control
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "ENABLE ADDON",
  description = "Master switch for this addon.",
  default = true,
})

-- Open settings panel
UI:Toggle(app)
```

That's it — five config blocks generate a full settings UI.

## 📦 Control Types

| Type | Description | Appearance |
|------|-------------|------------|
| `toggle` | On/Off switch | ✓ On/Off |
| `slider` | Value slider | ▬▬▬●▬ 0-100 |
| `input` | Text input box | text field |
| `dropdown` | Single select | Medium ▼ |
| `multidropdown` | Multi-select | 2 selected ▼ |
| `colorpicker` | Color picker | ■ #4da6ff |
| `keybind` | Key binding | ALT-F |
| `iconpicker` | Icon picker | click to select |
| `button` | Action button | click to trigger |
| `label` | Plain text note | full-width text |
| `divider` | Separator line | ─────── |

## 🎨 Accent Color Theming

LibHUI supports runtime accent color changes — switch from yellow to any color:

```lua
-- Via slash command (built into the sample addon)
/hui color blue
/hui color red
/hui color #4da6ff   -- custom hex

-- Via code
local Theme = HUI.Theme
Theme:SetAccentColorHex("4da6ff")
```

All accent-colored elements (selected state, borders, slider thumb, button hover) update instantly.

## 📚 Full Documentation

- **[API Reference](./docs/API_EN.md)** - Complete API docs
- **[中文 API 文档](./docs/API_CN.md)** - 中文 API 文档
- **[Sample Addon](./HUISample/)** - Demo of all control types

## 🛠️ Advanced Features

### Conditional Visibility / Disable

```lua
app:RegisterControl("general.core", {
  id = "advancedOption",
  key = "advanced",
  type = "slider",
  label = "ADVANCED",
  min = 1,
  max = 10,
  -- Only visible when enabled = true
  visibleWhen = function(db) return db.enabled == true end,
})
```

### Custom Formatter

```lua
app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  type = "slider",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  -- Display as percentage
  formatter = function(value)
    return string.format("%.0f%%", value * 100)
  end,
})
```

### Custom Get/Set

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

## 📖 Control Fields

Common fields for all controls:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier |
| `key` | string | SavedVariables key name (optional, for auto read/write) |
| `type` | string | Control type |
| `label` | string | Left-side label text |
| `description` | string | Right-panel description text |
| `default` | any | Default value |
| `order` | number | Sort weight (lower = first) |
| `groupID` | string | Group ID to belong to |
| `visibleWhen` | function | Show condition function |
| `hiddenWhen` | function | Hide condition function |
| `isEnabled` | function | Enable condition function |
| `getValue` | function | Custom read function |
| `setValue` | function | Custom write function |

Control-specific fields:

**slider**
- `min`, `max`, `step` - value range and step size
- `formatter` - display format function

**dropdown / multidropdown**
- `options` - option array `{ { value="id", label="Display Name" }, ... }`
- `multidropdown` value type: `{ "id1", "id2", ... }` string array

**colorpicker**
- Value type: `{ r, g, b, a }` table (0-1 float) or `"#rrggbb"` string

**keybind**
- Value type: key string like `"ALT-F"`, `"CTRL-SHIFT-1"`
- Special keys: `"ESCAPE"` cancels, `"DELETE"` clears binding

**iconpicker**
- `icons` - optional array of icon paths `{ "Interface\\Icons\\...", ... }`
- Value type: icon path string

**input**
- `multiline` - multi-line input (planned)

## 🤝 Contributing

LibHUI is a continuously evolving project. Contributions welcome:
- Bug reports and usage feedback
- Visual improvement suggestions
- New control type implementations

## 📄 License

MIT License — free to use in your WoW addon projects

---

**Start your first LibHUI addon**: See [HUISample](./HUISample/) for a complete working example.
