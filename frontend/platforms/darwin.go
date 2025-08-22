//go:build darwin
// +build darwin

package platforms

import (
	"os/exec"
)

func HideSystemConsole(cmd *exec.Cmd) {}
