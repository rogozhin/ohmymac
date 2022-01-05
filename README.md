# Oh! My Mac!

Initialize new Mac or new user easily. Set macos settings (Dock appearance, trackpad behavior, keyboard setting, etc.). Pack of developer and other applications coming soon.

## Installation

**Note:** It's good idea to check settings and application pack and tune it before installation. Reboot required after installation.

To set git author name and email provide it in `GIT_USER_NAME` and `GIT_USER_EMAIL`.

### Macos Requirements
- A 64-bit Intel CPU or Apple Silicon
- Macos Catalina (10.15) or higher
- Command Line Tools for Xcode (xcode-select --install) or Xcode 3

### Using Git

Clone repository and execute `ohmymac.sh`

```bash
git clone https://github.com/rogozhin/ohmymac.git && cd ohmymac && ./ohmymac.sh
```

## What's include

Macos preferences:
- Require password immediately after sleep or screen saver begins;
- Trackpad: tap to click with one finger, fast cursor, drag and select with tree fingers;
- Keyboard: do nothing on fn key press, turn on automatically switch to document's input source, disable automatic capitalization, disable automatic period substitution, disable auto-correct;
- Keyboard shortcuts: switch shortcuts for language source and Spotlight;
- Finder: set home folder as the default location for new Finder windows, do not show volume icons on desktop, show all filename extensions, disable the warning when changing a file extension
- Dock: do not autohide, set size and magnification of icons, don’t automatically rearrange Spaces, don’t show recent applications in Dock.

Coming soon:
- brew
- dev applications
- applications
