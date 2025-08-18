import './css/imports.css';
import './windowrules.js';

let initialized = false;
let validcfg = null;

const initLog = document.getElementById('log');
const errorreturnedLog = document.getElementById('error');
const initW = document.getElementById('init');
const gitConsole = document.getElementById("gitConsole");
const toggleConsoleBtn = document.getElementById("toggleConsoleBtn");

function log(message) { initLog.textContent = message; console.log(message); }
function errorReturned(message) { errorreturnedLog.textContent = message; console.error(message); }
function logToConsole(...args) {
    const message = args.map(a => (typeof a === 'object' ? JSON.stringify(a) : a)).join(' ');
    gitConsole.value += message + "\n";
    gitConsole.scrollTop = gitConsole.scrollHeight;
}
['log','error','warn','info'].forEach(fn => {
    const original = console[fn];
    console[fn] = (...args) => {
        original(...args); logToConsole(...args);
    };
});
window.runtime.EventsOn("logToGitConsole", (message) => {
    gitConsole.value += message + "\n";
    gitConsole.scrollTop = gitConsole.scrollTop;
});
toggleConsoleBtn?.addEventListener("click", () => {
    if (gitConsole.style.display === "none") {
        gitConsole.style.display = "block"; toggleConsoleBtn.textContent = "Hide Console";
    } else {
        gitConsole.style.display = "none"; toggleConsoleBtn.textContent = "Show Console";
    }
}); // revisit

// init // [0] ///////////////////////////////////////////////////////////////////////////////////////////////

async function checkOS() {
    log("Detecting OS...");
    const osName = await window.go.main.App.GetOS();
    await delay(800);
    log(`Operating System detected: ${osName}`);
    await delay(200);
    if (!osName) {
        errorReturned("Couldnt detect operating system..");
    }
    return osName;
}

async function checkGit() {
    log("Checking if git is installed...");
    const gitInstalled = await window.go.main.App.IsGitInstalled();
    if (!gitInstalled) {
        errorReturned("Git is not installed. Go get it!");
    }
    await delay(200); return gitInstalled;
}

async function checkConfig() {
    log("Searching for configuration...");
    let configExists = await window.go.main.App.CheckConfigExists();
    if (!configExists) {
        log("Configuration missing, creating new one..");
        await window.go.main.App.CreateConfig();
        log("Configuration created.");
        configExists = true;
    } else {
        log("Configuration found.");
    }
    await delay(200); return configExists;
}

async function validateConfig() {
    log("Validating configuration...");
    const cfg = await window.go.main.App.ValidateConfig();
    if (!cfg) {
        errorReturned("Configuration invalid..");
    } else {
        validcfg = cfg;
        log("Validated.")
    }
    await delay(300); return cfg;
}

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function initialize() {
    try {
        const osName = await checkOS();
        const gitInstalled = await checkGit();            // [0]
        const configExists = await checkConfig();
        const cfg = await validateConfig();
        if ((cfg && gitInstalled) || validcfg) {
            initialized = true;
            log("Ready.");
            await delay(2000);
            initW.classList.remove('initializing');
            connectConfig();
            initW.classList.add('doneinit');
            await delay(1000);
            initW.classList.add('initted');
            //initW.style.display = "none"; 
            //window.location.href = "./app.html";
            //await window.go.main.App.SendtoApp();
        } else if (!gitInstalled) {
            errorReturned("Git required for gituserChrome...");
        } else {
            errorReturned("Init failure. What a bummer..");
        }
    } catch (e) {
        errorReturned("Init failed: " + e.message);
    }
}

initialize();

// //////////////////////////////////////////////////////////////////////////////////////////////////////////

window.compactWindow();

// //////////////////////////////////////////////////////////////////////////////////////////////////////////

const sidebarToggle = document.querySelector('.nav-sidebar');
const sidebar = document.querySelector('.sidebar');

if (sidebarToggle && sidebar) {
    sidebarToggle.addEventListener('click', () => {
        if (sidebar.hasAttribute('collapsed')) {
            sidebar.removeAttribute('collapsed');
        } else {
            sidebar.setAttribute('collapsed', '');
        }
    });
}

const navMap = {
    '.nav-setup': document.querySelectorAll('.nav-setup.nav-entry'),
    '.nav-fcss': document.querySelectorAll('.nav-fcss.nav-entry'),
    '.nav-git': document.querySelectorAll('.nav-git.nav-entry'),
    '.nav-settings': document.querySelectorAll('.nav-settings.nav-entry'),
    '.nav-more': document.querySelectorAll('.nav-more.nav-entry')
};

Object.entries(navMap).forEach(([cls, nodeList]) => {
    nodeList.forEach(el => {
        el.addEventListener('click', () => sendTo(cls));
    });
});

function sendTo(targetClass) {
    if (!targetClass) return;
    const cls = targetClass.startsWith('.') ? targetClass.slice(1) : targetClass;
    document.querySelectorAll('.nav-entry[selected]').forEach(el => {
        el.removeAttribute('selected');
    });
    document.querySelectorAll(`.nav-entry.${cls}`).forEach(el => {
        el.setAttribute('selected', '');
    });
    document.querySelectorAll('.page[selected]').forEach(el => {
        el.removeAttribute('selected');
    });
    document.querySelectorAll(`.page.${cls}`).forEach(el => {
        el.setAttribute('selected', '');
    });
}

// //////////////////////////////////////////////////////////////////////////////////////////////////////////

const gitCheckbox      = document.getElementById("git_is");
const osDropdown       = document.getElementById("os_is");
const firefoxDropdown  = document.getElementById("firefox_is");
const profileDropdown  = document.getElementById("selected_profile");
const themeDropdown    = document.getElementById("selected_theme");
const applyjsCheckbox  = document.getElementById("apply_userjs");
const allowresCheckbox = document.getElementById("allow_restart");
const backupCheckbox   = document.getElementById("backup_chrome");

async function connectConfig() {
    const cfg = await window.go.main.App.ValidateConfig(); // [2]
    if (!cfg) {
        console.log("Config not found.");
        console.debug("connectConfig: Config not found.", cfg);
        return;
    } console.debug("connectConfig: Config found.", cfg);

    if (gitCheckbox)      { gitCheckbox.checked = cfg.git_is; }
    if (applyjsCheckbox)  { applyjsCheckbox.checked = cfg.apply_userjs; }
    if (allowresCheckbox) { allowresCheckbox.checked = cfg.allow_restart; }
    if (backupCheckbox)   { backupCheckbox.checked = cfg.backup_chrome; }

    if (osDropdown) {
        osDropdown.innerHTML = "";
        ["windows", "darwin", "linux"].forEach(os => {
            const opt = document.createElement("option"); opt.value = os;
            opt.textContent = os.charAt(0).toUpperCase() + os.slice(1);
            if (cfg.os_is === os) opt.selected = true;
            osDropdown.appendChild(opt);
        });
    }
    if (firefoxDropdown) {
        firefoxDropdown.innerHTML = "";
        Object.keys(cfg.firefoxs).forEach(fx => {
            const opt = document.createElement("option"); opt.value = fx;
            opt.textContent = fx;
            if (cfg.firefox_is === fx) opt.selected = true;
            firefoxDropdown.appendChild(opt);
        });
    }
    if (profileDropdown) {
        profileDropdown.innerHTML = "";
        cfg.firefox_profiles.forEach(profile => {
            const opt = document.createElement("option"); opt.value = profile;
            opt.textContent = profile;
            if (cfg.selected_profile === profile) opt.selected = true;
            profileDropdown.appendChild(opt);
        });
    }
    if (themeDropdown) {
        themeDropdown.innerHTML = "";
        const placeholder = document.createElement("option");
        placeholder.value = "placeholder";
        placeholder.textContent = "-- Select a theme --";
        placeholder.disabled = true;
        placeholder.selected = !cfg.selected_theme;
        themeDropdown.appendChild(placeholder);
        Object.keys(cfg.saved_themes).forEach(theme => {
            const opt = document.createElement("option");
            opt.value = theme;
            opt.textContent = theme;
            if (cfg.selected_theme === theme) opt.selected = true;
            themeDropdown.appendChild(opt);
        });
    }
    window.globalConfig = cfg;
}

// ////////////////////////////////////////////////////////////////////////////////////////////////////////// [3]

async function updateConfigValue(key, value) {
    if (!window.globalConfig) {
        console.debug("updateConfigValue: globalConfig is undefined");
        return;
    }
    window.globalConfig[key] = value;
    try {
        await window.go.main.App.WriteToConfig(key, value);
        console.log(`Config updated: ${key} = ${value}`);
    } catch (err) {
        console.error("updateConfigValue: failed to write to config:", err);
    }
}
function attachConfigListeners() {
    const container = document.querySelector(".nav-setup .page-container");
    if (!container) {
        console.debug("attachConfigListeners: can't attach listeners to nav-setup page");
        return;
    }
    container.querySelectorAll("select").forEach(sel => {
        console.debug("Attaching listener to select:", sel.id);
        sel.addEventListener("change", () => {
            console.debug("attachConfigListeners: change detected");
            updateConfigValue(sel.id, sel.value);
        });
    });
    container.querySelectorAll("input").forEach(inp => {
        console.debug("Attaching listener to input:", inp.id);
        inp.addEventListener("change", () => {
            let value;
            if (inp.type === "checkbox") {
                value = inp.checked;
            } else {
                value = inp.value;
            }
            console.debug(`attachConfigListeners: input ${inp.id} changed to`, value);
            updateConfigValue(inp.id, value);
        });
    });
}
(async function initConfig() {
    try {
        await connectConfig();
        //console.debug("initConfig");
        attachConfigListeners();
    } catch (err) {
        //console.debug("initConfig failed:", err);
    }
})();

// //////////////////////////////////////////////////////////////////////////////////////////////////////////

let settingsInitialized = false;

const settingsPage = document.querySelector(".nav-settings");
const saveSettingsBtn = document.getElementById("saveSettingsBtn");
const inputsMap = {
    fsFBinary: ["Firefox", "fsFBinary", "fsFBinaryInput"],
    fsFdBinary: ["Firefox Developer Edition", "fsFdBinary", "fsFdBinaryInput"],
    fsFnBinary: ["Firefox Nightly", "fsFnBinary", "fsFnBinaryInput"],
    fsLBinary: ["Librewolf", "fsLBinary", "fsLBinaryInput"],
    fsZBinary: ["Zen Browser", "fsZBinary", "fsZBinaryInput"],
    fsFloorpBinary: ["Floorp", "fsFloorpBinary", "fsFloorpBinaryInput"],
    fsProfile: [null, "fsProfile", "fsProfileInput"]
};

async function connectSettings() {
    const cfg = window.globalConfig;
    if (!cfg) {
        console.error("Attempt to connect to settings config failed..");
        return;
    } console.debug("Settings Configuration:", cfg);

    for (const [key, [firefoxKey, btnId, inputId]] of Object.entries(inputsMap)) {
        const inputEl = document.getElementById(inputId);
        if (!inputEl) continue;
        inputEl.value = firefoxKey ? (cfg.firefoxs[firefoxKey] || "") : "";
        console.debug(`Settings cfg ${firefoxKey}:`, inputEl.value);
    }
    const themeInput = document.getElementById("selectTheme");
    
    if (themeInput) {
        const selTheme = cfg.selected_theme;
        if (selTheme && cfg.saved_themes[selTheme]) {
            themeInput.value = cfg.saved_themes[selTheme];
            themeInput.dataset.theme = selTheme;
        } else {
            themeInput.value = "";
            themeInput.dataset.theme = "";
        }
        console.debug("Settings cfg theme input value:", themeInput.value);
    }
}

// Add / remove theme buttons
const addThemeBtn = document.getElementById("addTheme");
const removeThemeBtn = document.getElementById("removeTheme");

function parseThemeInput(val) {
    val = val.trim();
    if (!val) return null;
    let name, url;
    if (!val.startsWith("http://") && !val.startsWith("https://")) {val = "https://" + val;}
    try {
        const u = new URL(val);url = u.href;
        const allowedHosts = ["github.com", "gitlab.com", "codeberg.org"];
        if (!allowedHosts.includes(u.hostname)) return null;
        const parts = u.pathname.split("/").filter(Boolean);
        if (parts.length < 2) return null; name = parts[1];
    } catch {
        return null;
    } return { name, url };
}

function isThemeInSaved(cfg, name, url) {
    return Object.entries(cfg.saved_themes).some(
        ([savedName, savedUrl]) => savedName === name || savedUrl === url
    );
}

async function addTheme(cfg, name, url, themeInput) {
    cfg.saved_themes[name] = url;
    cfg.selected_theme = name;
    await window.go.main.App.WriteToConfig(`saved_themes.${name}`, url);
    await window.go.main.App.WriteToConfig("selected_theme", name);
    themeInput.value = "";
    themeInput.dataset.theme = "";
    await connectConfig();
    console.log(`Theme added: ${name} => ${url}`);
}
async function removeTheme(cfg, name, themeInput) {
    await window.go.main.App.RemoveFromConfig(`saved_themes.${name}`);
    delete cfg.saved_themes[name];
    if (Object.keys(cfg.saved_themes).length === 0) {
        cfg.saved_themes["ff-ultima"] = "https://github.com/soulhotel/ff-ultima";
        cfg.selected_theme = "ff-ultima";
        await window.go.main.App.WriteToConfig(`saved_themes.ff-ultima`, cfg.saved_themes["ff-ultima"]);
        await window.go.main.App.WriteToConfig("selected_theme", "ff-ultima");
        themeInput.value = "";
        themeInput.dataset.theme = "";
    } else {
        cfg.selected_theme = Object.keys(cfg.saved_themes)[0];
        await window.go.main.App.WriteToConfig("selected_theme", cfg.selected_theme);
        themeInput.value = "";
        themeInput.dataset.theme = "";
    }
    await connectConfig();
    console.log(`Theme removed: ${name}`);
}
addThemeBtn?.addEventListener("click", async () => {
    const cfg = window.globalConfig;
    const themeInput = document.getElementById("selectTheme");
    if (!cfg || !themeInput) return;
    const parsed = parseThemeInput(themeInput.value);
    if (!parsed) return;
    const { name, url } = parsed;
    if (isThemeInSaved(cfg, name, url)) {
        console.log("Theme already saved.");
        themeInput.value = "";
        return;
    }
    await addTheme(cfg, name, url, themeInput);
});
removeThemeBtn?.addEventListener("click", async () => {
    const cfg = window.globalConfig;
    const themeInput = document.getElementById("selectTheme");
    if (!cfg || !themeInput) return;
    const parsed = parseThemeInput(themeInput.value);
    if (!parsed) return;
    const { name, url } = parsed;
    if (!isThemeInSaved(cfg, name, url)) {
        console.log("Theme not found.");
        themeInput.value = "";
        return;
    }
    await removeTheme(cfg, name, themeInput);
});

function attachFileSelectors() {
    for (const [key, [firefoxKey, btnId, inputId]] of Object.entries(inputsMap)) {
        const btn = document.getElementById(btnId);
        const inputEl = document.getElementById(inputId);
        if (!btn || !inputEl) continue;

        btn.addEventListener("click", async () => {
            const path = await window.go.main.App.SelectFile();
            if (!path) return;
            if (path) {
                const cfg = window.globalConfig;
                if (!cfg) return;
                if (firefoxKey) {
                    inputEl.value = path;
                    cfg.firefoxs[firefoxKey] = path;
                    await window.go.main.App.WriteToConfig(`firefoxs.${firefoxKey}`, path);
                } else if (key === "fsProfile") {
                    const folderName = path.split(/[/\\]/).pop();
                    inputEl.value = folderName;
                    cfg.selected_profile = folderName;
                    await window.go.main.App.WriteToConfig("selected_profile", folderName);
                    const lastSep = Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\"));
                    const folderBase = lastSep >= 0 ? path.slice(0, lastSep) : path;
                    cfg.profile_base = folderBase;
                    await window.go.main.App.WriteToConfig("profile_base", folderBase);
                }
                console.log(`Updated config for ${key}:`, path);
            }
        });
    }
}

const openConfBtn = document.getElementById("openConf");
const resetConfBtn = document.getElementById("resetConf");
const deleteConfBtn = document.getElementById("deleteConf");
const openProfilesBtn = document.getElementById("openProfiles");

openConfBtn?.addEventListener("click", async () => {
    try {
        await window.go.main.App.OpenConfig();
    } catch (err) {
        console.error("Error opening config:", err);
    }
});
resetConfBtn?.addEventListener("click", async () => {
    try {
        await window.go.main.App.ResetConfig();
        sendTo('.nav-git');
        gitConsole.value = "";
        console.log("Config deleted. Re-initializing...");
        await initialize();
    } catch (err) {
        console.error("Error resetting config:", err);
    }    
});
deleteConfBtn?.addEventListener("click", async () => {
    try {
        await window.go.main.App.DeleteConfig(); /*reinit*/
    } catch (err) {
        console.error("Error deleting config:", err);
    }
});
openProfilesBtn?.addEventListener("click", async () => {
    try {
        await window.go.main.App.OpenProfiles();
    } catch (err) {
        console.error("Error opening profile path", err);
    }
});

function attachsaveSettingsBtn() {
    if (!saveSettingsBtn) return;
    saveSettingsBtn.addEventListener("click", async () => {
        const cfg = window.globalConfig;
        if (!cfg) return;
        for (const [key, [firefoxKey, btnId, inputId]] of Object.entries(inputsMap)) {
            const inputEl = document.getElementById(inputId);
            if (!inputEl) continue;

            if (firefoxKey) {
                cfg.firefoxs[firefoxKey] = inputEl.value;
                await window.go.main.App.WriteToConfig(`firefoxs.${firefoxKey}`, inputEl.value);
            } else if (inputEl.value.trim()) {
                if (!cfg.firefox_profiles.includes(inputEl.value.trim())) {
                    cfg.firefox_profiles.push(inputEl.value.trim());
                    await window.go.main.App.WriteToConfig(`firefox_profiles`, cfg.firefox_profiles);
                    inputEl.value = "";
                }
            }
        }
        const themeInput = document.getElementById("selectTheme");
        if (themeInput) {
            const parsed = parseThemeInput(themeInput.value);
            if (parsed) {
                const { name, url } = parsed;
                if (!cfg.saved_themes[name] && !Object.values(cfg.saved_themes).includes(url)) {
                    cfg.saved_themes[name] = url;
                    await window.go.main.App.WriteToConfig(`saved_themes.${name}`, url);
                    console.log(`Theme added via Save & Exit: ${name} => ${url}`);
                } else {
                    console.log(`Theme already in saved_themes: ${name}`);
                }
            }
            themeInput.value = "";
            themeInput.dataset.theme = "";
        }
        await connectConfig();
        sendTo('.nav-setup');
        console.log("Configuration updated.");
        console.debug("CONFIG SAVED", cfg);
    });
}

const settingsPageNav = document.querySelectorAll('.nav-settings');

settingsPageNav?.forEach(entry => {
    entry.addEventListener('click', async () => {
        if (settingsInitialized) return;

        await connectSettings();
        attachFileSelectors();
        attachsaveSettingsBtn();

        settingsInitialized = true;
    });
});

// //////////////////////////////////////////////////////////////////////////////////////////////////////////

const submitGitBtn = document.getElementById("submitgitBtn");
const statusLabel = document.getElementById("status");

async function submitGit() {
    sendTo('.nav-git');
    gitConsole.value = "";
    log("Validating configuration...");
    const cfg = await window.go.main.App.ValidateConfig();
    if (!cfg) {
        errorReturned("Configuration invalid..");
    } 
    validcfg = cfg;
    log("Validated.", cfg);
    statusLabel.value = "";
    try {
        await window.go.main.App.ProcessGit();
    } catch (e) {
        errorReturned("Error processing theme: " + e.message);
        logToConsole("Error processing theme: " + e.message);
    }
    return cfg;
}

submitGitBtn?.addEventListener("click", async () => {
    await submitGit();
});


document.getElementById("link-gituserChrome").onclick = () => {
    window.go.main.App.BrowserOpenURL('https://github.com/soulhotel/git-userChrome');
};
document.getElementById("link-css-store").onclick = () => {
    window.go.main.App.BrowserOpenURL('https://firefoxcss-store.github.io/');
};
document.getElementById("link-css-subreddit").onclick = () => {
    window.go.main.App.BrowserOpenURL('https://www.reddit.com/r/firefoxcss');
};
document.getElementById("link-support").onclick = () => {
    window.go.main.App.BrowserOpenURL('https://github.com/sponsors/soulhotel');
};
document.getElementById("link-git").onclick = () => {
    window.go.main.App.BrowserOpenURL('https://github.com/soulhotel/git-userChrome?tab=readme-ov-file#need-git-click-here');
};

