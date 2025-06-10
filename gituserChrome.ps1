# THEME REPO -------------------------------------------------------
param (
    [string]$gitTheme = "https://github.com/soulhotel/FF-ULTIMA.git"
)

Clear-Host
Write-Host "• 🔴 • gituserChrome (Windows Version)."
Write-Host "• 🔴 • This script can be used to download any hosted Theme via the gitTheme variable."
Write-Host "• 🟠 • gitTheme selected: $gitTheme"
Write-Host "• 🟡 • These are the Profile Folders found in your Firefox directory..`n"

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
git clone $gitTheme chrome
Copy-Item "$profilePath\chrome\user.js" -Destination "$profilePath\user.js"

Write-Host "`n• 🟢 • git clone complete"
Write-Host "• 🟢 • user.js has been copied to Profile"
Write-Host "• 🟢 • Restarting Firefox in 3.."
Start-Sleep -Seconds 1
Write-Host "• 🟡 • Restarting Firefox in 2.."
Start-Sleep -Seconds 1
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
$userInput = Read-Host "`n• 🟡 • Apply user.js file to $profileChoice ($selectedProfile)? [Y/n]"
if ([string]::IsNullOrWhiteSpace($userInput)) {
    $userInput = "Y"
}
if ($userInput -match '^[Yy]$') {
    Write-Host "`n• 🟡 • Waiting to clean up user.js (5 seconds).."
    Start-Sleep -Seconds 5
    Remove-Item "$profilePath\user.js" -Force
    Write-Host "`n• 🟢 • Firefox successfully restarted, user.js has been cleaned up. Enjoy the theme.`n"
} else {
    Write-Host "`n• 🟡 • No user.js applied. Enjoy the theme.`n"
}

Read-Host "Press ENTER to close this script."
