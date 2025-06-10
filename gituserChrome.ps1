# THEME REPO -------------------------------------------------------
param (
    [string]$gitTheme = "https://github.com/soulhotel/FF-ULTIMA.git"
)

Clear-Host
Write-Host "• 🔴 • gituserChrome (Windows Version)."
Write-Host "• 🟠 • This script can be used to download any hosted Theme via the gitTheme variable."
Write-Host "• 🟡 • gitTheme: $gitTheme , now choose a profile..`n"

# Get Firefox profile directories
$profileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
$dirs = Get-ChildItem -Directory $profileRoot | Where-Object {
    $_.Name -notin @("Crash Reports", "Pending Pings", "Profile Groups")
}
$profiles = @()
$index = 1
foreach ($dir in $dirs) {
    Write-Host "$index) $($dir.Name)"
    $profiles += $dir.Name
    $index++
}

Write-Host ""
$profileChoice = Read-Host "• 🟡 • Which profile are we installing the theme into"
$selectedProfile = $profiles[$profileChoice - 1]
$profilePath = Join-Path $profileRoot $selectedProfile

Clear-Host

# DOWNLOAD FF ULTIMA -----------------------------------------------

Set-Location $profilePath
if (Test-Path "$profilePath\chrome") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $newName = "chrome-$timestamp"
    Write-Host "• 🔴 • There's already a chrome folder here. Renaming it to $newName."
    Rename-Item -Path "$profilePath\chrome" -NewName $newName
}
git clone $gitTheme chrome
if (Test-Path "$profilePath\chrome\chrome") {
    Write-Host "• 🔴 • There's a chrome folder inside of the chrome folder."
    Rename-Item -Path "$profilePath\chrome\chrome" -NewName "chrome-double"

    Write-Host "• 🔴 • Moving everything inside of double chrome folder to chrome folder."
    # Move all files (including hidden) from chrome-double to chrome
    Get-ChildItem -Path "$profilePath\chrome\chrome-double" -Force | Move-Item -Destination "$profilePath\chrome"
    Remove-Item -Recurse -Force "$profilePath\chrome\chrome-double"
}
Write-Host "`n• 🟢 • git clone complete"
if (Test-Path "$profilePath\chrome\user.js") {
    Copy-Item "$profilePath\chrome\user.js" -Destination "$profilePath\user.js"
    Write-Host "• 🟢 • user.js has been copied to Profile"
}
Write-Host "`n• 🟢 • Restarting Firefox in 3.."
Start-Sleep -Seconds 2
Write-Host "• 🟡 • Restarting Firefox in 2.."
Start-Sleep -Seconds 2
Write-Host "• 🔴 • Restarting Firefox in ..."
Start-Sleep -Seconds 1
Clear-Host

# RESTART FIREFOX --------------------------------------------------

Write-Host "`n• 🟡 • Which Firefox are we working with today?"
Write-Host "`n1 🟠 firefox"
Write-Host "2 🔵 firefox developer edition"
Write-Host "3 🟣 firefox nightly"
Write-Host "4 ⚪ librewolf`n"
$firefoxChoice = Read-Host "Which Firefox is used with $profileChoice $selectedProfile"
Clear-Host
Get-Process -Name firefox, firefox-developer-edition, firefox-nightly, librewolf -ErrorAction SilentlyContinue | ForEach-Object { $_.Kill() }
while (Get-Process -Name firefox, firefox-developer-edition, firefox-nightly, librewolf -ErrorAction SilentlyContinue) { Start-Sleep -Milliseconds 500 }
switch ($firefoxChoice) {
    "1" { Start-Process "firefox.exe" }
    "2" { Start-Process "firefox-developer-edition.exe" }
    "3" { Start-Process "firefox-nightly.exe" }
    "4" { Start-Process "librewolf.exe" }
    default {
        Write-Host "`n• 🔴 • Invalid choice. Exiting."
        exit 1
    }
}

# CLEANUP USER.JS --------------------------
$userInput = Read-Host "`n• 🟡 • Cleanup user.js file from $profileChoice ($selectedProfile)? [Y/n]"
if ([string]::IsNullOrWhiteSpace($userInput)) {
    $userInput = "Y"
}
if ($userInput -match '^[Yy]$') {
    Write-Host "`n• 🟡 • Waiting to delete up user.js (5 seconds).."
    Start-Sleep -Seconds 5
    Remove-Item "$profilePath\user.js" -Force
    Write-Host "`n• 🟢 • Firefox successfully restarted. user.js cleaned up. Enjoy the theme.`n"
} else {
    Write-Host "`n• 🟡 • Firefox successfully restarted. No user.js applied. Enjoy the theme.`n"
}

Read-Host "Press ENTER to close this script."
