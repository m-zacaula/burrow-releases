#!/bin/bash
# Installs (or updates) Burrow in /Applications and opens it. Run in Terminal:
#   curl -fsSL https://raw.githubusercontent.com/m-zacaula/burrow-releases/main/install.sh | bash
# Downloading with curl instead of a browser means macOS doesn't block the app on first open,
# and there's no disk image to mount or eject.
set -e
URL="https://github.com/m-zacaula/burrow-releases/releases/latest/download/Burrow.zip"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading the latest Burrow..."
curl -fsSL "$URL" -o "$TMP/Burrow.zip"
ditto -x -k "$TMP/Burrow.zip" "$TMP"
[ -d "$TMP/Burrow.app" ] || { echo "The download didn't contain Burrow.app. Try again in a minute."; exit 1; }

# Replace a copy that's already installed (quit it first if it's running)
osascript -e 'tell application "Burrow" to quit' >/dev/null 2>&1 || true
sleep 1
rm -rf /Applications/Burrow.app
ditto "$TMP/Burrow.app" /Applications/Burrow.app
echo "Installed Burrow $(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/Burrow.app/Contents/Info.plist) in Applications."

if [ ! -x /opt/homebrew/bin/wg-quick ] && [ ! -x /usr/local/bin/wg-quick ]; then
  echo
  echo "Burrow also needs the WireGuard command-line tools. Install them with:"
  echo "  brew install wireguard-tools"
fi
open /Applications/Burrow.app
