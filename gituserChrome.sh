#!/bin/bash

# THEME REPO -------------------------------------------------------

gitTheme="${1:-https://github.com/soulhotel/FF-ULTIMA.git}"

clear
echo -e "\n\033[3m• • • gituserChrome (Linux, Mac Version).\033[0m"
echo -e "\033[3m• • • This script can be used to download any userChrome Theme via the gitTheme variable.\033[0m"
echo -e "• • • gitTheme selected: $gitTheme, now choose a profile..\n"

# List all folders in typical OS directory -------------------------

# Profile locations
if [[ "$OSTYPE" == "darwin"* ]]; then
    profile_base="$HOME/Library/Application Support/Firefox/Profiles"
else
    profile_base="$HOME/.mozilla/firefox"
    profile_base_snap="$HOME/snap/firefox/common/.mozilla/firefox"
fi
# Filter Profiles
profiles=()
profile_paths=()
index=1
for base in "$profile_base" "$profile_base_snap"; do
    [[ -d "$base" ]] || continue
    for dir in "$base"/*/; do
        folder_name=$(basename "$dir")
        case "$folder_name" in
            "Crash Reports"|"Pending Pings"|"Profile Groups")
                continue
                ;;
        esac
        echo "$index) $folder_name"
        profiles+=("$folder_name")
        profile_paths+=("$base")
        index=$((index + 1))
    done
done
# Select profile
echo
read -p "• 🟡 • Which profile are we installing the theme into: " profile_choice
clear
selected_profile="${profiles[$((profile_choice - 1))]}"
profile_base="${profile_paths[$((profile_choice - 1))]}"
profile_path="$profile_base/$selected_profile"
# Snap Check
is_snap=0
if [[ "$profile_base" == *"/snap/firefox/"* ]]; then
    is_snap=1
fi

# DOWNLOAD FF ULTIMA -----------------------------------------------

cd "$profile_path" || { echo "• 🔴 • Failed to cd into profile"; exit 1; }
if [ -d "chrome" ]; then
    timestamp=$(date +%Y%m%d-%H%M%S)
    newname="chrome-$timestamp"
    echo "• 🔴 • There's already a chrome folder here. Renaming it to $newname."
    mv chrome "$newname"
fi
git clone "$gitTheme" chrome # git to chrome time
if [ -d "chrome/chrome" ]; then
    echo "• • • There's a chrome folder inside of the chrome folder."
    mv chrome/chrome chrome/chrome-double
    echo "• 🔴 • Moving everything inside of double chrome folder to chrome folder."
    mv chrome/chrome-double/.??* chrome/ 2>/dev/null
    mv chrome/chrome-double/* chrome/ 2>/dev/null
    rm -rf chrome/chrome-double
fi
echo "• 🔵 • git clone complete"
if [ -f "chrome/user.js" ]; then
    cp "chrome/user.js" "user.js"
    echo "• • • user.js found, copying user.js to profile."
fi
echo -e "\n• • • Restarting Firefox in 3.."
sleep 3 && echo "• • • Restarting Firefox in 2.."
sleep 3 && echo "• • • Restarting Firefox in ..."
sleep 2 && clear


# RESTART FIREFOX --------------------------------------------------

echo "• • • Which Firefox are we restarting?"
echo
echo "1 🟠 firefox"
echo "2 🔵 firefox developer edition"
echo "3 🟣 firefox nightly"
echo "4 ⚪ librewolf"
echo
read -p "• • • Which Firefox is used with $selected_profile: " firefox_choice
clear
case "$firefox_choice" in
  1)  # default firefox
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pkill -9 -f "Firefox.app"
        while pgrep -f "Firefox.app" >/dev/null; do sleep 0.5; done
        open -a "Firefox"
    else
        if [[ "$is_snap" -eq 1 ]]; then
            echo "• • • Restarting Snap Firefox..."
            pkill -9 firefox
            while pgrep -f firefox >/dev/null; do sleep 0.5; done
            nohup firefox >/dev/null 2>&1 &
        else
            echo "• • • Restarting regular Firefox..."
            pkill -9 -f "/usr/lib/firefox/firefox"
            while pgrep -f "/usr/lib/firefox/firefox" >/dev/null; do sleep 0.5; done
            nohup firefox >/dev/null 2>&1 &
        fi
    fi
    ;;
  2)  # dev edition
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pkill -9 -f "Firefox Developer Edition.app"
        while pgrep -f "Firefox Developer Edition.app" >/dev/null; do sleep 0.5; done
        open -a "Firefox Developer Edition"
    else
        if [[ "$is_snap" -eq 1 ]]; then
            echo "• • • There is no snap for Firefox Developer Edition."
            echo "• • • Restarting default Dev Edition instead..."
            pkill -9 firefox-developer-edition
            while pgrep -f firefox-developer-edition >/dev/null; do sleep 0.5; done
            nohup firefox-developer-edition >/dev/null 2>&1 &
        else
            pkill -9 -f "/usr/lib/firefox-developer-edition/firefox"
            while pgrep -f "/usr/lib/firefox-developer-edition/firefox" >/dev/null; do sleep 0.5; done
            nohup firefox-developer-edition >/dev/null 2>&1 &
        fi
    fi
    ;;
  3)  # nightly
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pkill -9 -f "Firefox Nightly.app"
        while pgrep -f "Firefox Nightly.app" >/dev/null; do sleep 0.5; done
        open -a "Firefox Nightly"
    else
        if [[ "$is_snap" -eq 1 ]]; then
            echo "• • • There is no snap for Firefox Nightly."
            echo "• • • Restarting regular Firefox instead..."
            pkill -9 firefox
            while pgrep -f firefox >/dev/null; do sleep 0.5; done
            nohup firefox >/dev/null 2>&1 &
        else
            pkill -9 -f "/usr/lib/firefox-nightly/firefox"
            while pgrep -f "/usr/lib/firefox-nightly/firefox" >/dev/null; do sleep 0.5; done
            nohup firefox-nightly >/dev/null 2>&1 &
        fi
    fi
    ;;
  4)  # librewolf
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
    echo "• 🔴 • Invalid choice. Exiting."
    exit 1
    ;;
esac

# CLEANUP USER.JS --------------------------
echo
echo "• • • Note: If your browser did not shutdown and restart, it is most likely installed in an unusual place. Just restart your browser before cleaning up the user.js..."
read -rp $'\n• • • Cleanup the user.js file from '"$selected_profile"'? [Y/n] ' apply_userjs
apply_userjs=${apply_userjs:-Y}

if [[ "$apply_userjs" == "" || "$apply_userjs" == "Y" || "$apply_userjs" == "y" ]]; then
    echo -e "\n• • • Waiting to remove user.js (5 seconds).."
    sleep 3 && echo "• • • Waiting just in case (3 seconds)..."
    sleep 1 && echo "• • • A copy of the user.js can be found in the chrome folder, if you ever need it..."
    sleep 1 && rm "$profile_path/user.js"
    echo -e "\n• 🟢 • Firefox restarted. user.js cleaned up. Enjoy the theme."
else
    echo -e "\n• 🟢 • Firefox restarted. No user.js applied. Enjoy the theme.\n"
fi

echo
read -p "• • • You can press ENTER or Close this script."

