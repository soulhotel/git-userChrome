<div align="center">

# Git userChrome..

###### ...A cross-platform tool to git userChrome themes from anywhere.

![prev3](https://github.com/user-attachments/assets/43bd768c-8588-47c7-9e6a-1dccf5ad6d2b)

</div>

>[!NOTE]
> **As of August 16, 2025. gituserChrome is available as both a standalone script or a GUI.** The Application is still in it's early stages, while operations are successfully tested on Windows & Linux, it won't be the forefront until all platforms verified.


## Overview

gituserChrome automates the installation of userChrome themes. It handles downloading, saving themes, and managing them between profiles and different flavors of Firefox (Firefox variants, Librewolf, Zen, FLoorp). With just <ins>**one**</ins> command (or 1 click) it will automate the installation process. Both the script and app can work with github, codeberg, etc. The full configuration process is safe and smart ([see more](https://github.com/soulhotel/git-userChrome?tab=readme-ov-file#previews) about the order of operations below). The full script process is also well tested & vetted through users of my [FF Ultima](https://github.com/soulhotel/FF-ULTIMA) theme. You can find usage for the script below, or for the application, there's a version for each platform in the 1.0 Release ➜

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

###### *NEED GIT? (CLICK HERE)*
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

## Previews

###### *WINDOWS PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=yc3xRjVgR8A&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=2))
<!-- https://github.com/user-attachments/assets/f93c548e-54f4-4e9e-96db-15753e60171c -->

###### *LINUX PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=Cb350ZcjUu0&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=1))
<!-- https://github.com/user-attachments/assets/1306eedf-f1ec-400d-8e0d-9e0021b4a5e5 -->

###### *MAC PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=jDK7I6Ph3gU))

###### *GUI on WINDOWS*

<img width="1561" height="725" alt="Screenshot_20250815_212950" src="https://github.com/user-attachments/assets/203de812-cdda-4c51-b867-1ba43bebff16" />


