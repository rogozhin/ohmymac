# Macos shortcuts

System shortcuts are placed in `~/Library/Preferences/com.apple.symbolichotkeys.plist`.

```bash
  # Print existing version of shortcut
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Print :AppleSymbolicHotKeys:60"

  # Delete existing shortcut
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:60" \
    2>/dev/null

  # force macos to read plists
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  # add new shortcut
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:60:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 1048576" \
    -c "Add :AppleSymbolicHotKeys:60:value:type string standard"

  # force macos to read plists
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

Description:
- 60 is for id of shortcut (see bellow)
- Integers 32, 49, 1048576 - are describing keys for shortcuts

List of shortcut ids:
- 7: Move focus to the menu bar
- 8: Move focus to the Dock
- 9: Move focus to active or next window
- 10: Move focus to window toolbar
- 11: Move focus to floating window
- 13: Change the way Tab moves focus
- 15: Turn zoom on or off - Command, Option, 8
- 17: Zoom in
- 19: Zoom out
- 21: Reverse Black and White
- 23: Turn image smoothing on or off
- 25: Increase Contrast
- 26: Decrease Contrast
- 27: Move focus to the next window in application
- 28: Save picture of screen as file
- 29: Copy picture of screen to clipboard
- 30: Save picture of selected area as file
- 31: Copy picture of selected area to clipboard
- 32: All Windows
- 33: Application Windows
- 34: All Windows (Slow)
- 35: Application Windows (Slow)
- 36: Desktop
- 37: Desktop (Slow)
- 51: Move focus to the window drawer
- 52: Turn Dock Hiding On/Off
- 57: Move focus to the status menus
- 59: Turn VoiceOver on / off
- 60: Select the previous input source
- 61: Select the next source in the Input Menu
- 62: Dashboard
- 63: Dashboard (Slow)
- 64: Show Spotlight search field
- 65: Show Spotlight window
- 70: Dictionary MouseOver
- 73: Hide and show Front Row
- 75: Activate Spaces
- 76: Activate Spaces (Slow)
- 79: Spaces Left
- 81: Spaces Right
- 83: Spaces Down
- 85: Spaces Up

Some of keys:
- 50: ~
- 52: Enter
- 53: Escape
- 122: F1
- 120: F2
- 99: F3
- 118: F4
- 96: F5
- 97: F6
- 98: F7
- 100: F8
- 101: F9
- 109: F10
- 103: F11
- 111: F12
- 105: F13
- 107: F14
- 113: F15
- 131072: Shift
- 262144: Control
- 524288: Option
- 1048576: Command

## Credits
- [Defaults & symbolic hotkeys in Mac OS X](https://krypted.com/mac-os-x/defaults-symbolichotkeys/)
- [Helpful comment on StackExchange][https://apple.stackexchange.com/a/91680]
