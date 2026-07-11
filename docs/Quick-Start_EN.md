# Quick Start

This guide walks you through adding LibHUI to a new or existing addon from scratch.

## Step 1: Copy the library

Copy the `LibHUI` directory into your addon's `libs/` folder:

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

## Step 2: Load LibHUI in your TOC

Add a single line **before** your own Lua files:

```toc
## Interface: 120007
## Title: My Addon
## SavedVariables: MyAddonDB

libs\LibHUI\LibHUI.xml
Core.lua
Settings.lua
```

## Step 3: Initialize your database

In `Core.lua`, set up your SavedVariables and expose a `DB()` accessor:

```lua
local addonName, addon = ...

MyAddonDB = MyAddonDB or {}
MyAddonDB.profile = MyAddonDB.profile or {}

addon.DB = function()
  return MyAddonDB.profile
end
```

## Step 4: Register your settings

In `Settings.lua`, register categories, pages, and controls:

```lua
local addonName, addon = ...

local HUI = addon.LibHUI
local Config = HUI and HUI.Config
local UI = HUI and HUI.UI

if not Config or not UI then return end

-- Register the addon
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return addon.DB() end,
})

-- Top navigation category
app:RegisterCategory({
  id = "general",
  title = "GENERAL",
  order = 100,
})

-- Sub-page under that category
app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "CORE",
  order = 100,
})

-- A toggle control
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enable Addon",
  description = "Master switch for this addon.",
  default = true,
  order = 100,
})
```

## Step 5: Add a slash command

At the bottom of `Settings.lua`, wire up a slash command:

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function()
  UI:Toggle(app)
end
```

## Step 6: Test in game

```
/reload
/myaddon
```

The settings window should open. Toggle the control and `/reload` again to confirm the value persists.

---

## Control Types Reference

| Type | Description |
|------|-------------|
| `toggle` | On/off switch |
| `slider` | Numeric slider with optional `formatter` |
| `input` | Text input field |
| `dropdown` | Single-select dropdown |
| `multidropdown` | Multi-select dropdown with checkboxes |
| `colorpicker` | RGB color picker with hex input |
| `keybind` | Key binding capture |
| `iconpicker` | Icon grid selector |
| `reorderlist` | Drag-and-drop list |
| `button` | Action button (no value) |
| `label` | Read-only text row |
| `divider` | Visual separator line |

See [API_EN.md](./API_EN.md) for full field documentation.

---

## Runtime Theme Switching

```lua
-- Switch accent color at runtime
local Theme = addon.LibHUI.Theme
Theme:SetAccentColorHex("4da6ff")   -- blue
Theme:SetAccentColorHex("ff4d4d")   -- red
Theme:SetAccentColorHex("ffc702")   -- default yellow
```

Or via the built-in slash command in HUISample:

```
/hui color blue
/hui color #4da6ff
```

---

## Conditional Controls

```lua
-- Only visible when enabled = true
app:RegisterControl("general.core", {
  id = "advancedScale",
  key = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5, max = 2, step = 0.05,
  default = 1,
  visibleWhen = function() return addon.DB().enabled == true end,
})

-- Visible but greyed out when enabled = false
app:RegisterControl("general.core", {
  id = "alpha",
  key = "alpha",
  type = "slider",
  label = "Alpha",
  min = 0.1, max = 1, step = 0.05,
  default = 0.9,
  isEnabled = function() return addon.DB().enabled == true end,
})
```

---

## Custom Read / Write

Use `getValue` and `setValue` for nested tables or derived values:

```lua
app:RegisterControl("general.core", {
  id = "myFlag",
  type = "toggle",
  label = "Special Flag",
  getValue = function()
    return MyAddon:GetFlag()
  end,
  setValue = function(value)
    MyAddon:SetFlag(value)
    MyAddon:Refresh()
  end,
})
```
