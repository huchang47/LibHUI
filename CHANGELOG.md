# LibHUI Changelog

## [Unreleased]

### Added
- `Widgets:CreateCapsuleToggle(parent, checked, onChanged, width, height)` - capsule toggle with
  sliding knob animation (0.14s easeOutQuad), rounded track + circular knob, track/knob color
  crossfade, instant accent-color follow; default 40×20, optional size
- New assets: `LibHUI_CornerTL/TR/BL/BR.tga` (quarter-disc capsule corners), `LibHUI_Circle.tga`
  (knob); texture root resolves to `<embedding addon>/libs/LibHUI/Assets/`, overridable via
  `HUI.WidgetAssetRoot`
- Slider supports mouse-wheel adjustment

### Changed
- Settings panel `toggle` control type now renders with `CreateCapsuleToggle`
- Toggle (flat) border color follows state on both on/off (previously accent-only when on)

## [0.1.0] - 2026-07-01

### Added
- Initial release of LibHUI - Modern UI Library for WoW Addons
- Complete settings center framework with category/page/group/control architecture
- Full widget library with 13 control types:
  - `toggle` - Switch control
  - `slider` - Slider with custom formatting support
  - `input` - Text input field
  - `dropdown` - Single-select dropdown
  - `multidropdown` - Multi-select dropdown with checkbox list
  - `colorpicker` - RGB color picker with hex input
  - `keybind` - Key binding control
  - `iconpicker` - Icon grid selector
  - `reorderlist` - Drag-and-drop reorderable list
  - `button` - Action button
  - `label` - Text label
  - `divider` - Visual separator line
  - `groupHeader` - Group title header
- Dynamic accent color system with runtime theme switching (`/hui color <preset|#RRGGBB>`)
- Conditional visibility and enabled state support (`visibleWhen`, `hiddenWhen`, `isEnabled`, `parentCheck`)
- Custom value getter/setter support for complex data structures
- Dual-language localization (zhCN/enUS)
- Complete sample addon demonstrating all control types
- Modern sci-fi inspired visual design with dark translucent panels and yellow accent
- Comprehensive API documentation (docs/API_CN.md, docs/API_EN.md)
- Vendored architecture - each host addon ships its own LibHUI copy

### Features
- Zero-learning configuration-based UI generation
- Pixel-perfect layouts with automatic scrolling support
- Memory-efficient widget cleanup with theme listener management
- Smooth hover/selected/pressed state transitions
- Edge decorative corner elements for panels
- 1px custom row textures with color tinting support
- Consistent naming conventions following WoW addon best practices

### Technical
- Lua 5.1 compatible
- Local caching for global functions
- No global pollution
- Proper addon namespace pattern (`local addonName, addon = ...`)
- Frame state tracking via `_HUIState` field
- Theme listener registration/deregistration to prevent memory leaks
