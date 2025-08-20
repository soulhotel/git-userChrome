
# 1.1.1

- Sidebar state (collapsed) restoration
- todo Testing for GPUondemand instead of always
- todo port site


potential solution to Windows cmd
``
cmd.SysProcAttr = &syscall.SysProcAttr{
	HideWindow:    true,
	CreationFlags: 0x08000000,
}
cmd.Start()
``

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

