package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	gruntime "runtime"
	"sort"
	"strings"
	"time"

	wruntime "github.com/wailsapp/wails/v2/pkg/runtime"
)

// gruntime is an alias
// wruntime package had some interesting runtime components

// App struct
type App struct {
	ctx  context.Context
	cfg  Config
	wcfg Window
}

// NewApp creates a new App application struct
func InitApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
	fmt.Println("Hi")
}

func (a *App) SendtoApp() error {
	wruntime.WindowExecJS(a.ctx, "window.location.href = './app.html';")
	// too many errors, reference "routing" later
	return nil
}

// Init checklist

type Config struct {
	GitIs           bool              `json:"git_is"`
	OSIs            string            `json:"os_is"`
	FirefoxIs       string            `json:"firefox_is"`
	Firefoxs        map[string]string `json:"firefoxs"`
	ProfileBase     string            `json:"profile_base"`
	FirefoxProfiles []string          `json:"firefox_profiles"`
	SelectedProfile string            `json:"selected_profile"`
	SavedThemes     map[string]string `json:"saved_themes"`
	SelectedTheme   string            `json:"selected_theme"`
	ApplyUserJS     bool              `json:"apply_userjs"`
	AllowRestart    bool              `json:"allow_restart"`
	BackupChrome    bool              `json:"backup_chrome"`
}

type Window struct {
	Width        string          `json:"width"`
	Height       string          `json:"height"`
	ColorScheme  map[string]bool `json:"color-scheme"`
	SidebarState string          `json:"sidebar-state"`
}

var ignoredFolders = map[string]struct{}{
	"Crash Reports":  {},
	"Pending Pings":  {},
	"Profile Groups": {},
}

func (a *App) GetOS() string {
	return gruntime.GOOS
}

func (a *App) IsGitInstalled() bool {
	_, err := exec.LookPath("git")
	return err == nil
}

func getConfigDir() string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	switch gruntime.GOOS {
	case "windows":
		appData := os.Getenv("APPDATA")
		if appData != "" {
			return filepath.Join(appData, "gituserChrome")
		}
		return filepath.Join(homeDir, "AppData", "Roaming", "gituserChrome")
	case "darwin":
		return filepath.Join(homeDir, "Library", "Application Support", "gituserChrome")
	default:
		return filepath.Join(homeDir, ".config", "gituserChrome")
	}
}

func (a *App) CheckConfigExists() bool {
	configDir := getConfigDir()
	configPath := filepath.Join(configDir, "config.json")
	_, err := os.Stat(configPath)
	return err == nil
}

func (a *App) LoadWindowConfig() Window {
	configDir := getConfigDir()
	wconfigPath := filepath.Join(configDir, "window.json")
	if _, err := os.Stat(configDir); os.IsNotExist(err) {
		if err := os.MkdirAll(configDir, 0755); err != nil {
			fmt.Println("Failed to create config dir:", err)
			return Window{}
		}
	}
	if _, err := os.Stat(wconfigPath); os.IsNotExist(err) {
		defaultConfig := Window{
			Width:  "1600px",
			Height: "1000px",
			ColorScheme: map[string]bool{
				"system":      true,
				"translucent": false,
			},
			SidebarState: "",
		}
		data, err := json.MarshalIndent(defaultConfig, "", "  ")
		if err != nil {
			fmt.Println("Failed to marshal default config:", err)
			return Window{}
		}
		if err := os.WriteFile(wconfigPath, data, 0644); err != nil {
			fmt.Println("Failed to write config to user dir:", err)
			return Window{}
		}
	}
	data, err := os.ReadFile(wconfigPath)
	if err != nil {
		fmt.Println("Failed to read user config:", err)
		return Window{}
	}
	var wcfg Window
	if err := json.Unmarshal(data, &wcfg); err != nil {
		fmt.Println("Failed to unmarshal config:", err)
		return Window{}
	}
	a.wcfg = wcfg
	return wcfg
}

func (a *App) UpdateWindowConfig(updated Window) error {
	a.wcfg = updated
	configDir := getConfigDir()
	wconfigPath := filepath.Join(configDir, "window.json")
	data, err := json.MarshalIndent(a.wcfg, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(wconfigPath, data, 0644)
}

func (a *App) CreateConfig() error {
	configDir := getConfigDir()
	err := os.MkdirAll(configDir, 0755)
	if err != nil {
		return err
	}
	configPath := filepath.Join(configDir, "config.json")
	osIs := gruntime.GOOS
	gitIs := a.IsGitInstalled()
	firefoxs := findFirefoxs()
	firefoxIs := ""
	for name, path := range firefoxs {
		if path != "" {
			firefoxIs = name
			break
		}
	}
	if firefoxIs == "" {
		firefoxIs = "None detected"
	}
	// Find profiles and base path
	profileBase, profiles, err := findFirefoxProfiles()
	if err != nil {
		profileBase = ""
		profiles = []string{}
	}
	// Select most recent profile
	selectedProfile := ""
	if len(profiles) > 0 {
		selectedProfile = profiles[0]
	}
	savedThemes := map[string]string{
		"cascade":             "https://github.com/cascadefox/cascade",
		"ff-ultima":           "https://github.com/soulhotel/ff-ultima",
		"gwfox":               "https://github.com/akkva/gwfox",
		"firefox-gnome-theme": "https://github.com/rafaelmardojai/firefox-gnome-theme",
		"firefox-gx":          "https://github.com/Godiesc/firefox-gx",
		"firefox-one":         "https://github.com/Godiesc/firefox-one",
		"Firefox-Mod-Blur":    "https://github.com/datguypiko/Firefox-Mod-Blur",
		"FirefoxCSS":          "https://github.com/Bali10050/FirefoxCSS",
	}
	cfg := Config{
		GitIs:           gitIs,
		OSIs:            osIs,
		FirefoxIs:       firefoxIs,
		Firefoxs:        firefoxs,
		ProfileBase:     profileBase,
		FirefoxProfiles: profiles,
		SelectedProfile: selectedProfile,
		SavedThemes:     savedThemes,
		SelectedTheme:   "",
		ApplyUserJS:     true,
		AllowRestart:    true,
		BackupChrome:    true,
	}
	data, err := json.MarshalIndent(cfg, "", "  ")
	a.cfg = cfg

	if err != nil {
		return err
	}
	return os.WriteFile(configPath, data, 0644)
}

func (a *App) ValidateConfig() *Config {
	configDir := getConfigDir()
	configPath := filepath.Join(configDir, "config.json")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil
	}
	var cfg Config
	err = json.Unmarshal(data, &cfg)
	if err != nil {
		return nil
	}
	a.cfg = cfg
	return &a.cfg
}

// CONFIG BUILDING

func findFirefoxs() map[string]string {
	firefoxBrowsers := map[string][]string{
		"Firefox":                   {"firefox"},
		"Firefox Developer Edition": {"firefox-developer-edition", "firefoxdeveloperedition", "firefox-dev"},
		"Firefox Nightly":           {"firefox-nightly", "firefoxnightly"},
		"Librewolf":                 {"librewolf"},
		"Zen Browser":               {"zen"},
		"Floorp":                    {"floorp"},
	}
	linuxPath := map[string][]string{
		"Firefox":                   {"firefox.desktop"},
		"Firefox Developer Edition": {"firefox-developer-edition.desktop", "firefox_developer_edition.desktop", "firefox developer edition.desktop"},
		"Firefox Nightly":           {"firefox-nightly.desktop", "firefox_nightly.desktop", "firefox nightly.desktop"},
		"Librewolf":                 {"librewolf.desktop", "Librewolf.desktop"},
		"Zen Browser":               {"zen.desktop", "Zen.desktop"},
		"Floorp":                    {"floorp.desktop"},
	}
	detected := make(map[string]string)
	for browser, names := range firefoxBrowsers {
		detected[browser] = ""
		found := false
		switch gruntime.GOOS {
		case "linux":
			// the desktop files will provide the most accurate executable path
			desktopDirs := []string{
				"/usr/share/applications",
				"/usr/local/share/applications",
				filepath.Join(os.Getenv("HOME"), ".local/share/applications"),
			}
			for _, dir := range desktopDirs {
				entries, err := os.ReadDir(dir)
				if err != nil {
					continue
				}
				for _, candidate := range linuxPath[browser] {
					for _, entry := range entries {
						if entry.IsDir() {
							continue
						}
						if strings.EqualFold(entry.Name(), candidate) {
							path := filepath.Join(dir, entry.Name())
							data, err := os.ReadFile(path)
							if err != nil {
								continue
							}
							lines := strings.Split(string(data), "\n")
							for _, line := range lines {
								if strings.HasPrefix(line, "Exec=") {
									execPath := strings.Fields(strings.TrimPrefix(line, "Exec="))[0]
									detected[browser] = execPath
									found = true
									break
								}
							}
						}
						if found {
							break
						}
					}
					if found {
						break
					}
				}
				if found {
					break
				}
			}
			// otherwise, just default to common places, lib first
			if !found {
				possiblePaths := []string{}
				for _, name := range names {
					possiblePaths = append(possiblePaths,
						"/usr/lib/"+name+"/firefox",
						"/usr/bin/"+name,
						"/usr/local/bin/"+name,
						filepath.Join(os.Getenv("HOME"), "bin", name),
					)
				}
				for _, p := range possiblePaths {
					if fi, err := os.Stat(p); err == nil && !fi.IsDir() {
						detected[browser] = p
						found = true
						break
					}
				}
			}

		case "darwin":
			possiblePaths := []string{}
			for _, name := range names {
				appName := strings.Title(strings.ReplaceAll(name, "-", " "))
				possiblePaths = append(possiblePaths,
					filepath.Join("/Applications", appName+".app", "Contents", "MacOS", name),
					filepath.Join(os.Getenv("HOME"), "Applications", appName+".app", "Contents", "MacOS", name),
				)
			}
			for _, p := range possiblePaths {
				if fi, err := os.Stat(p); err == nil && !fi.IsDir() {
					detected[browser] = p
					found = true
					break
				}
			}

		case "windows":
			programFiles := []string{
				os.Getenv("PROGRAMFILES"),
				os.Getenv("PROGRAMFILES(X86)"),
			}
			possiblePaths := []string{}
			for _, pf := range programFiles {
				if pf == "" {
					continue
				}
				switch browser {
				case "Firefox":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Mozilla Firefox", "firefox.exe"),
					)
				case "Firefox Developer Edition":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Firefox Developer Edition", "firefox.exe"),
					)
				case "Firefox Nightly":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Firefox Nightly", "firefox.exe"),
					)
				case "Librewolf":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Librewolf", "librewolf.exe"),
					)
				case "Zen Browser":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Zen Browser", "zen.exe"),
					)
				case "Floorp":
					possiblePaths = append(possiblePaths,
						filepath.Join(pf, "Floorp", "floorp.exe"),
					)
				}
			}
			for _, p := range possiblePaths {
				if fi, err := os.Stat(p); err == nil && !fi.IsDir() {
					detected[browser] = p
					found = true
					break
				}
			}
		}
		// Only if not found yet, fall back to exec.LookPath for all OS
		if !found {
			for _, name := range names {
				path, err := exec.LookPath(name)
				if err == nil {
					detected[browser] = path
					break
				}
			}
		}
	}
	return detected
}

func findFirefoxProfiles() (profileBase string, profiles []string, err error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", nil, err
	}
	switch gruntime.GOOS {
	case "windows":
		appData := os.Getenv("APPDATA")
		if appData == "" {
			return "", nil, os.ErrNotExist
		}
		profileBase = filepath.Join(appData, "Mozilla", "Firefox", "Profiles")
	case "darwin":
		profileBase = filepath.Join(homeDir, "Library", "Application Support", "Firefox", "Profiles")
	default:
		profileBase = filepath.Join(homeDir, ".mozilla", "firefox")
	}
	info, err := os.Stat(profileBase)
	if err != nil || !info.IsDir() {
		return profileBase, nil, os.ErrNotExist
	}
	entries, err := os.ReadDir(profileBase)
	if err != nil {
		return profileBase, nil, err
	}
	type profileInfo struct {
		name    string
		modTime time.Time
	}
	var validProfiles []profileInfo

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		if _, ignored := ignoredFolders[entry.Name()]; ignored {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			continue
		}
		validProfiles = append(validProfiles, profileInfo{name: entry.Name(), modTime: info.ModTime()})
	}
	// Sort by modification date
	sort.Slice(validProfiles, func(i, j int) bool {
		return validProfiles[i].modTime.After(validProfiles[j].modTime)
	})
	profiles = make([]string, len(validProfiles))
	for i, p := range validProfiles {
		profiles[i] = p.name
	}
	return profileBase, profiles, nil
}

// WRITE TO CONFIG (UPDATE)

func (a *App) WriteToConfig(key string, value interface{}) error {
	configDir := getConfigDir()
	configPath := filepath.Join(configDir, "config.json")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("read config: %w", err)
	}

	// pain
	var config map[string]interface{}
	if err := json.Unmarshal(data, &config); err != nil {
		return fmt.Errorf("parse config: %w", err)
	}
	parts := strings.Split(key, ".")
	current := config
	for i := 0; i < len(parts)-1; i++ {
		part := parts[i]
		if _, exists := current[part]; !exists {
			current[part] = make(map[string]interface{})
		}
		if m, ok := current[part].(map[string]interface{}); ok {
			current = m
		} else {
			return fmt.Errorf("key %s is not a map", part)
		}
	}
	current[parts[len(parts)-1]] = value

	// save
	newData, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("encode config: %w", err)
	}
	if err := os.WriteFile(configPath, newData, 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}
	var newCfg Config
	if err := json.Unmarshal(newData, &newCfg); err != nil {
		return fmt.Errorf("update in-memory config: %w", err)
	}
	a.cfg = newCfg
	return nil
}

func (a *App) RemoveFromConfig(key string) error {
	configDir := getConfigDir()
	configPath := filepath.Join(configDir, "config.json")
	// 1. Read current config
	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("read config: %w", err)
	}

	var config map[string]interface{}
	if err := json.Unmarshal(data, &config); err != nil {
		return fmt.Errorf("parse config: %w", err)
	}

	// 2. Navigate nested keys via dot notation
	parts := strings.Split(key, ".")
	current := config
	for i := 0; i < len(parts)-1; i++ {
		part := parts[i]
		if m, ok := current[part].(map[string]interface{}); ok {
			current = m
		} else {
			return fmt.Errorf("key %s is not a map", part)
		}
	}

	// 3. Delete the final key
	delete(current, parts[len(parts)-1])

	// 4. Save back to file
	newData, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("encode config: %w", err)
	}
	if err := os.WriteFile(configPath, newData, 0644); err != nil {
		return fmt.Errorf("write config: %w", err)
	}

	// 5. Update in-memory config
	var newCfg Config
	if err := json.Unmarshal(newData, &newCfg); err != nil {
		return fmt.Errorf("update in-memory config: %w", err)
	}
	a.cfg = newCfg

	return nil
}

func (a *App) OpenConfig() error {
	configPath := filepath.Join(getConfigDir(), "config.json")
	var cmd *exec.Cmd
	switch gruntime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/C", "start", "", configPath)
	case "darwin":
		cmd = exec.Command("open", configPath)
	default: // Linux and others
		cmd = exec.Command("xdg-open", configPath)
	}
	return cmd.Start()
}
func (a *App) ResetConfig() error {
	configPath := filepath.Join(getConfigDir(), "config.json")
	if _, err := os.Stat(configPath); err == nil {
		if err := os.Remove(configPath); err != nil {
			return err
		}
	}
	return nil
}
func (a *App) DeleteConfig() error {
	configPath := filepath.Join(getConfigDir(), "config.json")
	if _, err := os.Stat(configPath); err == nil {
		if err := os.Remove(configPath); err != nil {
			return err
		}
	}
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	cmd := exec.Command(exe)
	cmd.Start()
	os.Exit(0)
	return nil
}
func (a *App) OpenProfiles() error {
	profileBase, _, err := findFirefoxProfiles()
	if err != nil {
		return err
	}
	var cmd *exec.Cmd
	switch gruntime.GOOS {
	case "windows":
		cmd = exec.Command("explorer", profileBase)
	case "darwin":
		cmd = exec.Command("open", profileBase)
	default: // Linux and others
		cmd = exec.Command("xdg-open", profileBase)
	}
	return cmd.Start()
}

func (a *App) SelectFile() (string, error) {
	fileBytes, err := wruntime.OpenFileDialog(a.ctx, wruntime.OpenDialogOptions{
		Title: "Select a firefox executable to target",
	})
	if err != nil {
		return "", err
	}
	if len(fileBytes) == 0 {
		return "", nil
	}
	// [56] convert []bytes to strings!!!! remember.
	return string(fileBytes), nil
}

// //////////////////////////////////////////////////////////////////////////////////

func (a *App) ProcessGit() (bool, error) {
	// git console
	logToConsole := func(message string) {
		wruntime.EventsEmit(a.ctx, "logToGitConsole", message)
	}
	if a.cfg.SelectedTheme == "" || a.cfg.SelectedProfile == "" {
		err := fmt.Errorf("selected_theme or selected_profile is empty")
		logToConsole(err.Error())
		return false, err
	}
	themeURL, ok := a.cfg.SavedThemes[a.cfg.SelectedTheme]
	if !ok {
		err := fmt.Errorf("selected theme %s not found in saved_themes", a.cfg.SelectedTheme)
		logToConsole(err.Error())
		return false, err
	}
	profilePath := filepath.Join(a.cfg.ProfileBase, a.cfg.SelectedProfile)
	chromePath := filepath.Join(profilePath, "chrome")

	if a.cfg.BackupChrome {
		if _, err := os.Stat(chromePath); err == nil {
			timestamp := time.Now().Format("20060102150405")
			backupPath := filepath.Join(profilePath, fmt.Sprintf("chrome-%s", timestamp))
			if err := os.Rename(chromePath, backupPath); err != nil {
				err = fmt.Errorf("failed to backup chrome folder: %w", err)
				logToConsole(err.Error())
				return false, err
			}
			logToConsole(fmt.Sprintf("Backed up chrome folder to: %s", backupPath))
		}
	} else {
		if err := os.RemoveAll(chromePath); err != nil && !os.IsNotExist(err) {
			err = fmt.Errorf("failed to delete chrome folder: %w", err)
			logToConsole(err.Error())
			return false, err
		}
	}
	// git clone
	cmd := exec.Command("git", "clone", themeURL, chromePath)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		err = fmt.Errorf("git clone failed for %s: %w", themeURL, err)
		logToConsole(err.Error())
		if stderr.Len() > 0 {
			logToConsole(fmt.Sprintf("Git stderr: %s", stderr.String()))
		}
		return false, err
	}
	logToConsole(fmt.Sprintf("Cloned theme to: %s", chromePath))
	if stdout.Len() > 0 {
		logToConsole(fmt.Sprintf("Git stdout: %s", stdout.String()))
	}
	// handle double folder
	innerChromePath := filepath.Join(chromePath, "chrome")
	if _, err := os.Stat(innerChromePath); err == nil {
		entries, err := os.ReadDir(innerChromePath)
		if err != nil {
			err = fmt.Errorf("failed to read inner chrome folder: %w", err)
			logToConsole(err.Error())
			return false, err
		}
		for _, entry := range entries {
			src := filepath.Join(innerChromePath, entry.Name())
			dst := filepath.Join(chromePath, entry.Name())
			if err := os.Rename(src, dst); err != nil {
				err = fmt.Errorf("failed to move %s to %s: %w", src, dst, err)
				logToConsole(err.Error())
				return false, err
			}
		}
		if err := os.Remove(innerChromePath); err != nil && !os.IsNotExist(err) {
			err = fmt.Errorf("failed to remove inner chrome folder: %w", err)
			logToConsole(err.Error())
			return false, err
		}
		logToConsole("Flattened double chrome folder")
	}
	if a.cfg.ApplyUserJS {
		userJSPath := filepath.Join(chromePath, "user.js")
		if _, err := os.Stat(userJSPath); err == nil {
			destUserJS := filepath.Join(profilePath, "user.js")
			data, err := os.ReadFile(userJSPath)
			if err != nil {
				err = fmt.Errorf("failed to read user.js: %w", err)
				logToConsole(err.Error())
				return false, err
			}
			if err := os.WriteFile(destUserJS, data, 0644); err != nil {
				err = fmt.Errorf("failed to copy user.js to %s: %w", destUserJS, err)
				logToConsole(err.Error())
				return false, err
			}
			logToConsole(fmt.Sprintf("Copied user.js to: %s", destUserJS))
		}
	}
	if a.cfg.AllowRestart {
		firefoxPath, ok := a.cfg.Firefoxs[a.cfg.FirefoxIs]
		if !ok || firefoxPath == "" {
			err := fmt.Errorf("firefox binary not found for %s", a.cfg.FirefoxIs)
			logToConsole(err.Error())
			return false, err
		}
		// kill firefox
		var cmd *exec.Cmd
		switch gruntime.GOOS {
		case "windows":
			cmd = exec.Command("taskkill", "/F", "/IM", filepath.Base(firefoxPath))
		case "darwin":
			cmd = exec.Command("pkill", "-9", "-f", firefoxPath)
		default: // has to be forceful
			cmd = exec.Command("pkill", "-9", "-f", firefoxPath)
		}
		stdout.Reset()
		stderr.Reset()
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		if err := cmd.Run(); err != nil {
			logToConsole(fmt.Sprintf("Warning: Failed to terminate Firefox: %s", err))
			if stderr.Len() > 0 {
				logToConsole(fmt.Sprintf("Kill: %s", stderr.String()))
			}
		}
		// wait
		for i := 0; i < 10; i++ {
			cmdCheck := exec.Command("pgrep", "-f", filepath.Base(firefoxPath))
			if gruntime.GOOS == "windows" {
				cmdCheck = exec.Command("tasklist", "/FI", fmt.Sprintf("IMAGENAME eq %s", filepath.Base(firefoxPath)))
			}
			stdout.Reset()
			stderr.Reset()
			cmdCheck.Stdout = &stdout
			cmdCheck.Stderr = &stderr
			if err := cmdCheck.Run(); err != nil {
				break
			}
			time.Sleep(500 * time.Millisecond)
		}

		// Start Firefox
		cmd = exec.Command(firefoxPath)
		stdout.Reset()
		stderr.Reset()
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		if err := cmd.Start(); err != nil {
			err = fmt.Errorf("failed to start Firefox: %w", err)
			logToConsole(err.Error())
			if stderr.Len() > 0 {
				logToConsole(fmt.Sprintf("Start stderr: %s", stderr.String()))
			}
			return false, err
		}
		logToConsole(fmt.Sprintf("Restarted Firefox: %s", firefoxPath))
		if stdout.Len() > 0 {
			logToConsole(fmt.Sprintf("Start stdout: %s", stdout.String()))
		}
		if a.cfg.ApplyUserJS {
			time.Sleep(5 * time.Second)
			userJSPath := filepath.Join(profilePath, "user.js")
			if err := os.Remove(userJSPath); err != nil && !os.IsNotExist(err) {
				err = fmt.Errorf("failed to clean up user.js: %w", err)
				logToConsole(err.Error())
				return false, err
			}
			logToConsole(fmt.Sprintf("Cleaned up user.js from: %s", userJSPath))
		}
	}
	logToConsole("All done!")
	return true, nil
}

func (a *App) BrowserOpenURL(url string) {
	wruntime.BrowserOpenURL(a.ctx, url)
}
