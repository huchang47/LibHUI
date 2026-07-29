std = "lua51"

exclude_files = {
  "项目参考/**/*.lua",
}

read_globals = {
  -- WoW API Globals
  "GetLocale",
  "UIParent",
  "CreateFrame",
  "CreateFont",
  "STANDARD_TEXT_FONT",
  "GetCursorPosition",
  "IsShiftKeyDown",
  "IsControlKeyDown",
  "IsAltKeyDown",
  
  -- WoW UI Templates
  "BackdropTemplate",
  
  -- WoW Font Objects
  "GameFontNormalHuge",
  "GameFontNormalLarge",
  "GameFontNormal",
  "GameFontHighlightSmall",
  
  -- Slash Command System
  "SlashCmdList",
  "SLASH_HUISAMPLE1",
  "SLASH_HUISAMPLE2",
}

globals = {
  -- HUI Sample SavedVariables
  "HUISampleDB",
}

max_line_length = false
