# HUI API Reference

## Config API

### `Config:RegisterAddOn(addonName, opts)`

Registers an addon and returns an `app` instance used for all subsequent registration calls.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `addonName` | string | Addon name (usually pass the `addonName` variable) |
| `opts.title` | string | Settings panel title |
| `opts.settingsTitle` | string | Optional, overrides the large header title |
| `opts.db` | function | Function that returns the SavedVariables profile |
| `opts.assetRoot` | string | Optional, custom texture path root |

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = function() return MyAddonDB.profile end,
})
```

---

### `app:RegisterCategory(data)`

Registers a top-level navigation category.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique ID |
| `title` | string | Display name |
| `order` | number | Sort weight |

```lua
app:RegisterCategory({ id = "general", title = "GENERAL", order = 100 })
```

---

### `app:RegisterPage(data)`

Registers a sub-page under a category.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique ID (suggested format: `category.pageName`) |
| `category` | string | Parent category ID |
| `title` | string | Tab label text |
| `description` | string | Optional page description |
| `order` | number | Sort weight |

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

Registers a group header to visually organize controls on a page.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique ID |
| `title` | string | Group header text |
| `order` | number | Sort weight |

```lua
app:RegisterGroup("general.core", {
  id = "display",
  title = "DISPLAY",
  order = 100,
})
```

---

### `app:RegisterControl(pageID, data)`

Registers a control onto a page.

**Common fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✓ | Unique control ID |
| `type` | string | ✓ | Control type (see below) |
| `label` | string | | Left-side label text |
| `description` | string | | Right-panel description text |
| `key` | string | | db read/write key name |
| `default` | any | | Default value |
| `order` | number | | Sort weight |
| `groupID` | string | | Group to belong to |
| `getValue` | function | | Custom read function |
| `setValue` | function | | Custom write function |
| `visibleWhen` | function(db) | | Show when returns true |
| `hiddenWhen` | function(db) | | Hide when returns true |
| `isEnabled` | function(db) | | Disable when returns false |

**Control types:**

#### `toggle` - On/Off Switch

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

#### `slider` - Value Slider

Extra fields: `min`, `max`, `step`, `formatter`

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

#### `input` - Text Input

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

#### `dropdown` - Single Select Dropdown

Extra field: `options`

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

#### `button` - Action Button

```lua
app:RegisterControl("general.core", {
  id = "myBtn",
  type = "button",
  label = "DO SOMETHING",
  onClick = function()
    -- Note: button type currently renders as read-only text in RenderControl.
    -- For a clickable button, use HUI.Widgets:CreateActionButton directly in custom UI.
  end,
})
```

#### `multidropdown` - Multi-Select Dropdown

Extra field: `options`

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
  default = { "core", "ui" },  -- array of selected values
})
```

#### `colorpicker` - Color Picker

Value format: `{ r, g, b, a }` (0-1 float) or `"#rrggbb"` hex string.

```lua
app:RegisterControl("general.core", {
  id = "accentColor",
  key = "accentColor",
  type = "colorpicker",
  label = "ACCENT COLOR",
  default = { 1.0, 0.78, 0.02, 1.0 },  -- yellow
})
```

#### `keybind` - Key Binding

Value format: key string like `"ALT-F"`, `"CTRL-SHIFT-1"`.

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

#### `iconpicker` - Icon Picker

Extra field: `icons` (optional, custom icon path list).

```lua
app:RegisterControl("general.core", {
  id = "icon",
  key = "icon",
  type = "iconpicker",
  label = "ICON",
  -- optional: specify available icons
  icons = {
    "Interface\\Icons\\Spell_Fire_Fireball",
    "Interface\\Icons\\Spell_Frost_Frostbolt",
  },
  default = "Interface\\Icons\\INV_Misc_QuestionMark",
})
```

#### `label` - Plain Text Note

```lua
app:RegisterControl("general.core", {
  id = "note",
  type = "label",
  label = "This text spans the full row width, useful for notes.",
})
```

#### `divider` - Separator Line

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

Opens the settings panel if closed, closes it if open.

```lua
UI:Toggle(app)
UI:Toggle(app, "general.core") -- open to a specific page
```

### `UI:Open(app, pageID)`

Force-opens the settings panel.

```lua
UI:Open(app, "appearance.style")
```

---

## Theme API

### `Theme:SetAccentColor(r, g, b, a)`

Sets the accent color. r/g/b/a are in 0-1 range.

```lua
Theme:SetAccentColor(0.30, 0.65, 1.0, 1.0) -- blue
```

### `Theme:SetAccentColorHex(hex)`

Sets the accent color using a hex string.

```lua
Theme:SetAccentColorHex("4da6ff")   -- blue
Theme:SetAccentColorHex("#e5b836")  -- gold
```

### `Theme:OnAccentChanged(callback)`

Registers a callback that fires whenever the accent color changes. Returns a listener ID for later unregistration.

```lua
local id = Theme:OnAccentChanged(function(accent)
  -- accent is the new { r, g, b, a } table
  myFrame:SetBackdropBorderColor(accent[1], accent[2], accent[3])
end)
```

### `Theme:OffAccentChanged(id)`

Unregisters an accent change callback. Call this when your UI element is destroyed to prevent listener accumulation and memory leaks.

```lua
Theme:OffAccentChanged(id)
```

### `Theme:Color(name)`

Returns a color token as a `{ r, g, b, a }` table.

Available color names: `accent` `accentDark` `panel` `panelSoft` `row` `rowHover` `toggleOff` `text` `textDark` `muted` `disabled` `danger` `black`

```lua
local color = Theme:Color("accent")
texture:SetColorTexture(color[1], color[2], color[3], color[4])
```

### `Theme:Asset(name, app)`

Returns a texture file path.

```lua
local path = Theme:Asset("rowNormal") -- returns full path string
```

---

## Widgets API

All widget factories return the corresponding Frame or Texture object.

### `Widgets:CreatePanel(parent, name)`

Creates a themed dark panel (corner decorations + border).

### `Widgets:CreateText(parent, template, text, colorName)`

Creates a font string. `template` accepts WoW font template names; `colorName` uses a Theme color token.

### `Widgets:CreateButton(parent, text, width, height)`

Creates a tab navigation button (includes `SetSelected` method).

### `Widgets:CreateActionButton(parent, text, width, height, onClick)`

Creates an action button (accent color on hover + corner decorations).

### `Widgets:CreateRow(parent, height)`

Creates a settings row (textured background + border + `SetSelected` method).

### `Widgets:CreateGroupHeader(parent, text, height)`

Creates a group header (light label block + right-side divider line).

### `Widgets:CreateToggle(parent, checked, onChanged)`

Creates an on/off toggle. `onChanged(checked)` fires on state change.

### `Widgets:CreateCapsuleToggle(parent, checked, onChanged, width, height)`

Creates a capsule toggle with sliding animation: rounded track + circular knob; on click the knob glides to the other end over 0.14s (easeOutQuad) while the track and knob colors crossfade. On = accent track + white knob, off = dark track + gray knob; follows accent color changes instantly.

- `width` / `height`: optional, default `40 × 20` (knob = height - 6)
- Same API as `CreateToggle`: `SetChecked(value, animate)` / `GetValue()` / `SetValue(value, animate)`; programmatic `SetChecked(v)` snaps instantly, pass `true` as the second argument to animate
- Textures resolve to `<embedding addon>/libs/LibHUI/Assets/` by default; set `HUI.WidgetAssetRoot` before loading to override non-standard install paths

The settings panel's `toggle` control type uses this widget by default.

### `Widgets:CreateSlider(parent, value, minValue, maxValue, step, onChanged)`

Creates a slider. `onChanged(currentValue)` fires on value change.

### `Widgets:CreateDropdown(parent, options, currentValue, onChanged)`

Creates a single-select dropdown. `onChanged(value)` fires when selection changes.

`options` format: `{ { value = "id", label = "Display Name" }, ... }`

### `Widgets:CreateInput(parent, value, onChanged)`

Creates a text input box. `onChanged(text)` fires on focus loss or Enter.

### `Widgets:CreateMultiDropdown(parent, options, value, onChanged)`

Creates a multi-select dropdown. `onChanged(selectedValues)` fires when selection changes.

- `options` format: `{ { value = "id", label = "Display Name" }, ... }`
- `value` format: `{ "id1", "id2", ... }` string array

### `Widgets:CreateColorPicker(parent, color, onChanged)`

Creates a color picker. `onChanged(color)` fires when color changes.

- `color` format: `{ r, g, b, a }` table (0-1 float)

### `Widgets:CreateKeybind(parent, value, onChanged)`

Creates a key binding control. `onChanged(keyString)` fires when binding changes.

- `value` format: key string like `"ALT-F"`, `"CTRL-SHIFT-1"`

### `Widgets:CreateIconPicker(parent, value, options, onChanged)`

Creates an icon picker. `onChanged(iconPath)` fires when icon is selected.

- `value`: currently selected icon path string
- `options`: optional array of icon paths (has built-in defaults if omitted)

### `Widgets:CreateScrollFrame(parent, width, height)`

Creates a scrollable container with a themed scrollbar.

- Add content to `container.content`
- Supports mouse wheel and drag scrolling

### `Widgets:CreateLabel(parent, text, colorName)`

Creates a plain text label.

### `Widgets:CreateDivider(parent)`

Creates a 1px horizontal separator texture.

---

## Common Patterns

### SavedVariables Structure

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

### Slash Command Integration

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
