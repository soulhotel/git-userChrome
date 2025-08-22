
# 1.2 Calm before the storm

- Config; firefox profiles are now stored as a map including the profiles path, this was needed to properly interact with profiles for other firefox variants
- Config; this also adds another level of verification based on a selected_profiles dynamic path when comparing librewolf path to floorp to zen, etc
- Config; profiles on initiation, are now populated by scanning for these 4 firefox variant potential paths
- Config; Window remembers sidebar state on close
- Settings; folder dialog for adding profile folder correction
- Runtime; runtime now has a more leniant gpu acceleration policy, Arch packages now include a _nvidia.desktop file to counteract ongoing issues with webkit2gtk hardware acceleration
- Runtime; Finally figured out proper way to hide console executions on Windows. No more console popups! **thank you stackoverflow**

# 1.1 Tested on all 3 major platforms

- First launch now starts off with no theme selected
- Setup, now also has a "no theme selected" indicator
- Setup, now has a warning indicator for cases where git is not installed
- Settings, now has open profiles location button
- Settings, Specifying firefox binaries & specific profile locations with open file/folder dialogs are good to go.
- Tooltips, subtle but useful tooltips have been added where needed
- As before, debugging and state clarity is present in the git console
- Fixed issue where the app icon was not packaged with the debian package
- And Mac, now has a binary


# 1.0 Go for windows & linux

- packaged for arch, deb, rpm, exe, appimage

