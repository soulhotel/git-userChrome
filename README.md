<div align="center">

# Git userChrome..

###### . . . a tool to get userChrome Themes from anywhere.

![preview]()

</div>

## How it Works:

- It can download any CSS theme by running <ins>**one**</ins> command (locally or online).
- Using a themes repo as the argument/flag allows you to grab any theme via github, codeberg, etc.

###### *LINUX & MAC (BASH)*
```
bash <(curl -s https://raw.githubusercontent.com/soulhotel/git-userChrome/main/gituserChrome.sh) https://github.com/soulhotel/ff-ultima.git
```
```
./gituserChrome.sh https://github.com/soulhotel/ff-ultima.git
```

###### *WINDOWS (POWERSHELL)*
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://raw.githubusercontent.com/soulhotel/git-userChrome/main/gituserChrome.ps1') -gitTheme 'https://github.com/soulhotel/FF-ULTIMA.git'"
```
```
.\gituserChrome.ps1 -gitTheme "https://github.com/soulhotel/ff-ultima.git"
```

## What That Script Do?:

The script will automate:
- Finding the Profile Folder
- Downloading a CSS Theme into it (`chrome/`)
- Applying user.js if applicable.
- Restarting Firefox
- Cleaning up user.is if applicable

It waits for running commands to finish before moving on to the next. Fully automating the Installation Process.
