# THEME REPO -------------------------------------------------------
param (
    [string]$gitTheme = "https://github.com/soulhotel/FF-ULTIMA.git"
)

function Invoke-gituserChrome {
Clear-Host
Write-Host "• • • gituserChrome (Windows Version)."
Write-Host "• • • This script can be used to download any userChrome Theme via the gitTheme variable."
Write-Host "• • • gitTheme selected: $gitTheme , now choose a profile..`n"

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
    Write-Host "• • • There's a chrome folder inside of the chrome folder."
    Rename-Item -Path "$profilePath\chrome\chrome" -NewName "chrome-double"

    Write-Host "• 🔴 • Moving everything inside of double chrome folder to chrome folder."
    # Move all files (including hidden) from chrome-double to chrome
    Get-ChildItem -Path "$profilePath\chrome\chrome-double" -Force | Move-Item -Destination "$profilePath\chrome"
    Remove-Item -Recurse -Force "$profilePath\chrome\chrome-double"
}
Write-Host "`n• 🟢 • git clone complete"
if (Test-Path "$profilePath\chrome\user.js") {
    Copy-Item "$profilePath\chrome\user.js" -Destination "$profilePath\user.js"
    Write-Host "• 🟢 • user.js copied to Profile"
}
Write-Host "`n• • • Restarting Firefox in 3.."
Start-Sleep -Seconds 3
Write-Host "• • • Restarting Firefox in 2.."
Start-Sleep -Seconds 3
Write-Host "• • • Restarting Firefox in ..."
Start-Sleep -Seconds 2
Clear-Host

# RESTART FIREFOX --------------------------------------------------

Write-Host "`n• • • Which Firefox are we working with today?"
Write-Host "`n1 🟠 firefox"
Write-Host "2 🔵 firefox developer edition"
Write-Host "3 🟣 firefox nightly"
Write-Host "4 ⚪ librewolf"
Write-Host "5 ⚫ custom location`n"
$firefoxChoice = Read-Host "• • • Which Firefox is used with $profileChoice $selectedProfile"
Clear-Host
$firefoxPaths = @{
    "1" = "C:\Program Files\Mozilla Firefox\firefox.exe"
    "2" = "C:\Program Files\Firefox Developer Edition\firefox.exe"
    "3" = "C:\Program Files\Firefox Nightly\firefox.exe"
    "4" = "C:\Program Files\LibreWolf\librewolf.exe"
}
if ($firefoxChoice -eq "5") {
    $chosenPath = Read-Host "• • • Enter the full path to your Firefox executable (e.g., C:\Path\To\firefox.exe)"
} else {
    $chosenPath = $firefoxPaths[$firefoxChoice]
}
if (-not (Test-Path $chosenPath)) {
    Write-Host "`n• 🔴 • Could not find Firefox executable at:"
    Write-Host "         $chosenPath"
    exit 1
}
Get-Process | Where-Object {
    $_.Path -like "*Mozilla Firefox\firefox.exe" -or
    $_.Path -like "*Firefox Developer Edition\firefox.exe" -or
    $_.Path -like "*Firefox Nightly\firefox.exe" -or
    $_.Path -like "*LibreWolf\librewolf.exe"
} | ForEach-Object { $_.Kill() }
# Wait until closed
while (
    Get-Process | Where-Object {
        $_.Path -like "*Mozilla Firefox\firefox.exe" -or
        $_.Path -like "*Firefox Developer Edition\firefox.exe" -or
        $_.Path -like "*Firefox Nightly\firefox.exe" -or
        $_.Path -like "*LibreWolf\librewolf.exe"
    }
) {
    Start-Sleep -Milliseconds 500
}
# And restart
Start-Process $chosenPath

# CLEANUP USER.JS --------------------------
$userInput = Read-Host "`n• • • Cleanup user.js file from $profileChoice ($selectedProfile)? [Y/n]"
if ([string]::IsNullOrWhiteSpace($userInput)) {
    $userInput = "Y"
}
if ($userInput -match '^[Yy]$') {
    Write-Host "`n• • • Waiting to delete up user.js (5 seconds).."
    Start-Sleep -Seconds 3
    Remove-Item "$profilePath\user.js" -Force
    Write-Host "`n• 🟢 • Firefox successfully restarted. user.js cleaned up. Enjoy the theme.`n"
} else {
    Write-Host "`n• 🟢 • Firefox successfully restarted. No user.js applied. Enjoy the theme.`n"
}

Read-Host "• • • Press ENTER to close this script."

}

Invoke-gituserChrome

