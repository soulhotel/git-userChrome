//go:build windows
// +build windows

package platforms

import (
	"os/exec"
	gruntime "runtime"
	"syscall"
)

func HideSystemConsole(cmd *exec.Cmd) {
	if gruntime.GOOS != "windows" {
		return
	}
	cmd.SysProcAttr = &syscall.SysProcAttr{
		HideWindow:    true,
		CreationFlags: 0x08000000,
	}
}
