#!/bin/bash

gitTheme="$1"
profile_path="$2"
apply_userjs="$3"
allow_restart="$4"
backup_chrome="$5"
firefox_choice="$6"

if [[ -z "$gitTheme" ]]; then
    missing_params+=("gitTheme")
fi
if [[ -z "$profile_path" ]]; then
    missing_params+=("profile_path")
fi
if [[ -z "$apply_userjs" ]]; then
    missing_params+=("apply_userjs")
fi
if [[ -z "$allow_restart" ]]; then
    missing_params+=("allow_restart")
fi
if [[ -z "$backup_chrome" ]]; then
    missing_params+=("backup_chrome")
fi
if [[ -z "$firefox_choice" ]]; then
    missing_params+=("firefox_choice")
fi
if (( ${#missing_params[@]} > 0 )); then
    echo "$0 needs ${missing_params[*]}"
    exit 1
fi

echo
echo -e "
selected_theme=$gitTheme
selected_profile=$profile_path
firefox_choice=$firefox_choice
backup_chrome=$backup_chrome
apply_userjs=$apply_userjs
allow_restart=$allow_restart
"

cd "$profile_path" || { echo "Failed to cd into profile path, it ended before it began.."; exit 1; }

if [ -d "chrome" ]; then
    timestamp=$(date +%Y%m%d-%H%M%S)
    newname="chrome-$timestamp"
    if [[ "$backup_chrome" == "yes" ]]; then
        echo -e "Backing up existing chrome folder to $newname...\n"
        mv chrome "$newname"
    else
        echo -e "Discarding existing chrome folder...\n"
        rm -rf chrome
    fi
fi

echo "Cloning repo..."
git clone "$gitTheme" chrome

if [ -d "chrome/chrome" ]; then
    echo "Fixing nested chrome folder.."
    mv chrome/chrome chrome/chrome-double
    mv chrome/chrome-double/.??* chrome/ 2>/dev/null || true
    mv chrome/chrome-double/* chrome/ 2>/dev/null || true
    rm -rf chrome/chrome-double
fi

echo "Clone complete."
echo

if [[ "$apply_userjs" == "yes" && -f "chrome/user.js" ]]; then
    echo "Copying user.js to profile path..."
    cp "chrome/user.js" "user.js"
fi

if [[ "$allow_restart" == "yes" ]]; then
    echo "Restarting Firefox..."

    case "$firefox_choice" in
      "Firefox"|"firefox")
        if [[ "$OSTYPE" == "darwin"* ]]; then
          pkill -9 -f "Firefox.app"
          while pgrep -f "Firefox.app" >/dev/null; do sleep 0.5; done
          open -a "Firefox"
        else
          pkill -9 -f "/usr/lib/firefox/firefox"
          while pgrep -f "/usr/lib/firefox/firefox" >/dev/null; do sleep 0.5; done
          nohup firefox >/dev/null 2>&1 &
        fi
        ;;
      "Firefox Developer Edition"|"firefox developer edition")
        if [[ "$OSTYPE" == "darwin"* ]]; then
          pkill -9 -f "Firefox Developer Edition.app"
          while pgrep -f "Firefox Developer Edition.app" >/dev/null; do sleep 0.5; done
          open -a "Firefox Developer Edition"
        else
          pkill -9 -f "/usr/lib/firefox-developer-edition/firefox"
          while pgrep -f "/usr/lib/firefox-developer-edition/firefox" >/dev/null; do sleep 0.5; done
          nohup firefox-developer-edition >/dev/null 2>&1 &
        fi
        ;;
      "Firefox Nightly"|"firefox nightly")
        if [[ "$OSTYPE" == "darwin"* ]]; then
          pkill -9 -f "Firefox Nightly.app"
          while pgrep -f "Firefox Nightly.app" >/dev/null; do sleep 0.5; done
          open -a "Firefox Nightly"
        else
          pkill -9 -f "/usr/lib/firefox-nightly/firefox"
          while pgrep -f "/usr/lib/firefox-nightly/firefox" >/dev/null; do sleep 0.5; done
          nohup firefox-nightly >/dev/null 2>&1 &
        fi
        ;;
      "Librewolf"|"librewolf")
        if [[ "$OSTYPE" == "darwin"* ]]; then
          pkill -9 -f "LibreWolf.app"
          while pgrep -f "LibreWolf.app" >/dev/null; do sleep 0.5; done
          open -a "LibreWolf"
        else
          pkill -9 -f librewolf
          while pgrep -f librewolf >/dev/null; do sleep 0.5; done
          nohup librewolf >/dev/null 2>&1 &
        fi
        ;;
      *)
        echo "Error Handling: $firefox_choice. Skipping restart."
        ;;
    esac

    echo "Firefox should have restarted..."
fi

# Cleanup
if [[ "$apply_userjs" == "yes" ]]; then
    echo -e "\nWaiting to cleanup user.js (5 seconds)..."
    sleep 4
    echo "Removing user.js..."
    rm -f "$profile_path/user.js"
fi

echo -e "\nDone."
exit 0
