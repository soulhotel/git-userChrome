<div align="center">

# Git userChrome..

###### ...A cross-platform tool to git userChrome themes from anywhere.

![prev3](https://github.com/user-attachments/assets/43bd768c-8588-47c7-9e6a-1dccf5ad6d2b)

</div>

>[!NOTE]
> **As of August 16, 2025. gituserChrome is available as both a standalone script or a GUI**


## Overview

gituserChrome automates the installation of userChrome themes in several ways. It handles downloading Themes, saving them, and managing them between Profiles, Firefoxs (Firefox variants, Librewolf, Zen, Floorp), and Operating Systems. Both the script and app can work with github, codeberg, etc, backups of existing chrome, user.js and restarts. And all of this can be done with just <ins>**one**</ins> command (or click). The full configuration process is safe and smart (see the [order of operations](https://github.com/soulhotel/git-userChrome?tab=readme-ov-file#previews) below). The original script is also well tested & vetted through users of my [FF Ultima](https://github.com/soulhotel/FF-ULTIMA) theme. You can find usage for the script below, or for the application, there's a version for each platform on the Releases Page ➜

## Scripts

The automation script does not need to be downloaded (but they can be). You can simply run the first command for your operating system. And the script will assist you in automating the installation of any userChrome theme. In these examples below, I fetch the script globally, then add the link to the userChrome theme: "gituserChrome github.com/someones/theme.git".

###### *LINUX & MAC (BASH)*
```
bash <(curl -s https://raw.githubusercontent.com/soulhotel/git-userChrome/main/scripts/gituserChrome.sh) https://github.com/soulhotel/ff-ultima.git
```
```
./gituserChrome.sh https://github.com/soulhotel/ff-ultima.git
```
###### *WINDOWS (POWERSHELL)*
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://raw.githubusercontent.com/soulhotel/git-userChrome/main/scripts/gituserChrome.ps1' | iex; Invoke-gituserChrome -gitTheme 'https://github.com/soulhotel/ff-ultima.git'"
```
```
.\gituserChrome.ps1 -gitTheme "https://github.com/soulhotel/ff-ultima.git"
```

###### *NEED GIT? (SOURCE BELOW)*
```
sudo pacman -S git                        # ARCH
sudo apt install git                      # DEBIAN/UBUNTU
xcode-select --install && git --version   # MAC
https://gitforwindows.org/                # WINDOWS
```

###### *SCRIPT OPERATIONS*

The standalone script fully automates the installation process by:
- Finding the Profile Folder(s).
- Backing up any `existing chrome` folder into `chrome-datetime`.
- Downloading the CSS Theme into `chrome/`
- Properly handle weird formats like `chrome/chrome` (double folders) from the downloaded theme.
- Applying user.js if applicable.
- Restarting Firefox.
- Cleaning up user.is if applicable.

> Note: The application expands on this experience with the ability to specify firefox binaries, profile locations, and such.

## Previews

###### Script Previews: The full script operation put on youtube for better quality ([windows](https://www.youtube.com/watch?v=yc3xRjVgR8A&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=2), [linux](https://www.youtube.com/watch?v=Cb350ZcjUu0&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=1), [mac](https://www.youtube.com/watch?v=jDK7I6Ph3gU))

###### App Previews: For Windows 11, Arch Linux (kde), Mac Sonoma (VM)

<img width="1561" height="725" alt="Screenshot_20250815_212950" src="https://github.com/user-attachments/assets/203de812-cdda-4c51-b867-1ba43bebff16" />

![1 2](https://github.com/user-attachments/assets/f5b874ff-13a4-468a-a261-cdd33b2815c0)

<img width="1369" height="880" alt="b" src="https://github.com/user-attachments/assets/fb6d1828-335f-44b5-bd84-fcc374756632" />
