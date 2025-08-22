//go:build linux
// +build linux

package platforms

import (
	"os/exec"
)

func HideSystemConsole(cmd *exec.Cmd) {}
