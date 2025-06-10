#!/bin/bash

# THEME REPO -------------------------------------------------------
gitTheme="${1:-https://github.com/soulhotel/FF-ULTIMA.git}"

clear
echo -e "\n\033[3m• 🔴 • gituserChrome (Linux, Mac Version).\033[0m"
echo -e "\033[3m• 🔴 • This script can be used to download any hosted Theme via the gitTheme variable.\033[0m"
echo -e "• 🟠 • gitTheme selected: $gitTheme"
echo -e "• 🟡 • These are the Profile Folders found in your firefox directory..\n"

# List all folders in ~/.mozilla/firefox/ --------------------------

profiles=()
index=1
for dir in ~/.mozilla/firefox/*/; do
    folder_name=$(basename "$dir")
    case "$folder_name" in
        "Crash Reports"|"Pending Pings"|"Profile Groups")
            continue
            ;;
    esac
    echo "$index) $folder_name"
    profiles+=("$folder_name")
    index=$((index + 1))
done
echo
read -p "• 🟡 • Which profile are we installing the theme into: " profile_choice
clear
selected_profile="${profiles[$((profile_choice - 1))]}"
profile_path="$HOME/.mozilla/firefox/$selected_profile"


# DOWNLOAD FF ULTIMA -----------------------------------------------

cd "$profile_path" || { echo "• 🔴 • Failed to cd into profile"; exit 1; }
if [ -d "chrome" ]; then
    echo "• 🔴 • There's already a chrome folder here. Renaming it to chrome-old."
    mv chrome chrome-old
fi
git clone "$gitTheme" chrome # git to chrome time
if [ -d "chrome/chrome" ]; then
    echo "• 🔴 • There's a chrome folder inside of the chrome folder."
    mv chrome/chrome chrome/chrome-double
    echo "• 🔴 • Moving everything inside of double chrome folder to chrome folder."
    mv chrome/chrome-double/.??* chrome/chrome-double/* chrome/ 2>/dev/null
    rm -rf chrome/chrome-double
fi
echo "• 🟢 • git clone complete"
if [ -f "user.js" ]; then
    cp "user.js" "../user.js"
    echo "• 🟢 • user.js has been copied to Profile"
fi
echo -e "\n• 🟢 • Restarting Firefox in 3.."
sleep 2 && echo "• 🟡 • Restarting Firefox in 2.."
sleep 2 && echo "• 🔴 • Restarting Firefox in ..."
sleep 1 && clear


# RESTART FIREFOX --------------------------------------------------

echo "• 🟡 • Which Firefox are we working with today?"
echo
echo "1 🟠 firefox"
echo "2 🔵 firefox developer edition"
echo "3 🟣 firefox nightly"
echo "4 ⚪ librewolf"
echo
read -p "Which Firefox is used with $selected_profile: " firefox_choice
clear
case "$firefox_choice" in
  1)  # default firefox
    pkill -9 -f "/usr/lib/firefox/firefox"
    while pgrep -f "/usr/lib/firefox/firefox" >/dev/null; do sleep 0.5; done
    nohup firefox >/dev/null 2>&1 &
    ;;
  2)  # dev edition
    pkill -9 -f "/usr/lib/firefox-developer-edition/firefox"
    while pgrep -f "/usr/lib/firefox-developer-edition/firefox" >/dev/null; do sleep 0.5; done
    nohup firefox-developer-edition >/dev/null 2>&1 &
    ;;
  3)  # nightly
    pkill -9 -f "/usr/lib/firefox-nightly/firefox"
    while pgrep -f "/usr/lib/firefox-nightly/firefox" >/dev/null; do sleep 0.5; done
    nohup firefox-nightly >/dev/null 2>&1 &
    ;;
  4)  # librewolf - assuming path or just name is enough
    pkill -9 -f librewolf
    while pgrep -f librewolf >/dev/null; do sleep 0.5; done
    nohup librewolf >/dev/null 2>&1 &
    ;;
  *)
    echo "• 🔴 • Invalid choice. Exiting."
    exit 1
    ;;
esac


# CLEANUP USER.JS --------------------------
read -rp $'\n• 🟡 • Cleanup user.js file from '"$profile_choice"'? [Y/n] ' apply_userjs
apply_userjs=${apply_userjs:-Y}

if [[ "$apply_userjs" =~ ^[Yy]$ ]]; then
    echo -e "\n• 🟡 • Waiting to clean up user.js (5 seconds).."
    sleep 5 && rm "$profile_path/user.js"
    echo -e "\n• 🟢 • Firefox restarted. user.js cleaned up. Enjoy the theme."
else
    echo -e "\n• 🟢 • Firefox restarted. No user.js applied. Enjoy the theme."
fi

echo
read -p "Press ENTER to close this script."

