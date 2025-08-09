<div align="center">

# Git userChrome..

###### . . . a tool to get userChrome Themes from anywhere.

</div>

## How it Works:

- With just <ins>**one**</ins> command. It can automate the installation of any userChrome theme.
- Using a themes Homepage as the argument/flag allows you to grab any theme via github, codeberg, etc.
- This process is well tested through users of my FF Ultima theme.
###### *LINUX & MAC (BASH)*
```
bash <(curl -s https://raw.githubusercontent.com/soulhotel/git-userChrome/main/gituserChrome.sh) https://github.com/soulhotel/ff-ultima.git
```
```
./gituserChrome.sh https://github.com/soulhotel/ff-ultima.git
```
###### *WINDOWS (POWERSHELL)*
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://raw.githubusercontent.com/soulhotel/git-userChrome/main/gituserChrome.ps1' | iex; Invoke-gituserChrome -gitTheme 'https://github.com/soulhotel/ff-ultima.git'"
```
```
.\gituserChrome.ps1 -gitTheme "https://github.com/soulhotel/ff-ultima.git"
```

## What That Script Do?:

The script will fully automate the installation process by:
- Finding the Profile Folder.
- Backing up any `existing chrome` folder into `chrome-datetime`.
- Downloading the CSS Theme into `chrome/`
- Properly handle weird formats like `chrome/chrome` (double folders) from the downloaded theme.
- Applying user.js if applicable.
- Restarting Firefox.
- Cleaning up user.is if applicable.

## Don't have Git? (open a terminal and paste the command):

<ins>Git for Mac</ins>
```
xcode-select --install
git --version
```
<ins>Git for Arch</ins>
```
sudo pacman -S git
```
<ins>Git for Deb derivatives</ins>
```
sudo apt install git
```
<ins>Git for Windows</ins>
```
https://gitforwindows.org/
```

## Previews

###### *WINDOWS PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=yc3xRjVgR8A&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=2))
https://github.com/user-attachments/assets/f93c548e-54f4-4e9e-96db-15753e60171c

###### *LINUX PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=Cb350ZcjUu0&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=1))
https://github.com/user-attachments/assets/1306eedf-f1ec-400d-8e0d-9e0021b4a5e5

##### *MAC PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=jDK7I6Ph3gU))

- https://www.youtube.com/watch?v=jDK7I6Ph3gU

######  *INSTALLING ANY THEME PREVIEW* (better quality [on youtube](https://www.youtube.com/watch?v=lrBIZQqGGdU&list=PLTVs0Y4lTV55tEwbkGwlooQinDbge3a6O&index=2))
https://github.com/user-attachments/assets/9ce82177-08f5-4a50-9dfa-2f8a222b8fa5
