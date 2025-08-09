param (
    [Parameter(Mandatory = $true)] [string]$gitTheme,
    [Parameter(Mandatory = $true)] [string]$profile_path,
    [Parameter(Mandatory = $true)] [string]$apply_userjs,
    [Parameter(Mandatory = $true)] [string]$allow_restart,
    [Parameter(Mandatory = $true)] [string]$backup_chrome,
    [Parameter(Mandatory = $true)] [string]$firefox_choice
)

Write-Host "gitTheme=$gitTheme, profile_path=$profile_path, apply_userjs=$apply_userjs, allow_restart=$allow_restart, backup_chrome=$backup_chrome, firefox_choice=$firefox_choice"

if (-Not (Test-Path $profile_path)) {
    Write-Host "Error: Profile path '$profile_path' does not exist."
    exit 1
}

Set-Location -Path $profile_path

if (Test-Path "chrome") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $newName = "chrome-$timestamp"
    if ($backup_chrome -eq "yes") {
        Write-Host "Backing up existing chrome folder to $newName"
        Rename-Item -Path "chrome" -NewName $newName
    }
    else {
        Write-Host "Discarding existing chrome folder"
        Remove-Item -Recurse -Force "chrome"
    }
}

Write-Host "Cloning theme repo..."
git clone $gitTheme chrome

if (Test-Path "chrome\chrome") {
    Write-Host "Fixing nested chrome folder..."
    Rename-Item -Path "chrome\chrome" -NewName "chrome-double"
    Get-ChildItem -Path "chrome\chrome-double" -Force | ForEach-Object {
        Move-Item -Path $_.FullName -Destination "chrome"
    }
    Remove-Item -Recurse -Force "chrome\chrome-double"
}

Write-Host "Clone complete."

if (($apply_userjs -eq "yes") -and (Test-Path "chrome\user.js")) {
    Write-Host "Copying user.js to profile path"
    Copy-Item -Path "chrome\user.js" -Destination "$profile_path\user.js" -Force
}

if ($allow_restart -eq "yes") {
    Write-Host "Restarting Firefox..."

    $firefoxPaths = @{
        "Firefox" = "C:\Program Files\Mozilla Firefox\firefox.exe"
        "firefox" = "C:\Program Files\Mozilla Firefox\firefox.exe"
        "Firefox Developer Edition" = "C:\Program Files\Firefox Developer Edition\firefox.exe"
        "firefox developer edition" = "C:\Program Files\Firefox Developer Edition\firefox.exe"
        "Firefox Nightly" = "C:\Program Files\Firefox Nightly\firefox.exe"
        "firefox nightly" = "C:\Program Files\Firefox Nightly\firefox.exe"
        "Librewolf" = "C:\Program Files\LibreWolf\librewolf.exe"
        "librewolf" = "C:\Program Files\LibreWolf\librewolf.exe"
    }

    if (-Not $firefoxPaths.ContainsKey($firefox_choice)) {
        Write-Host "Error: Unknown firefox_choice '$firefox_choice'. Skipping restart."
    }
    else {
        $exePath = $firefoxPaths[$firefox_choice]
        if (-Not (Test-Path $exePath)) {
            Write-Host "Error: Firefox executable not found at $exePath"
        }
        else {
            Get-Process | Where-Object { $_.Path -eq $exePath } | ForEach-Object { $_.Kill() }
            while (Get-Process | Where-Object { $_.Path -eq $exePath }) {
                Start-Sleep -Milliseconds 500
            }
            Start-Process $exePath
            Write-Host "Firefox restarted."
        }
    }
}

if ($apply_userjs -eq "yes") {
    Write-Host "Waiting to cleanup user.js (5 seconds)..."
    Start-Sleep -Seconds 5
    if (Test-Path "$profile_path\user.js") {
        Remove-Item "$profile_path\user.js" -Force
        Write-Host "user.js removed."
    }
}

Write-Host "Done."
exit 0
