# LibHUI Changelog

## [Unreleased]

## [0.2.0] - 2026-09-29

### Fixed
- Fixed asset path case sensitivity issue - now using `Libs` (uppercase) as standard directory name
- Improved directory detection logic - using `GetWidth() > 0` to verify texture loading success instead of unreliable `GetTexture()`
- Removed incorrect `.tga` extension from `Theme.assets` (WoW texture paths should not include extensions)
- `LibHUIWidgets.lua` now uses `Theme:GetAssetRoot()` to inherit case-sensitivity auto-detection

### Added
- Added `DetectLibsCase()` auto-detection function to support both uppercase `Libs` and lowercase `libs` directories
- Prefers uppercase `Libs` (recommended standard), falls back to lowercase `libs` (legacy compatibility)

### Changed
- `LibHUIWidgets.lua` `ASSET_ROOT` now dynamically resolves via `Theme:GetAssetRoot()` instead of hardcoded path

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
