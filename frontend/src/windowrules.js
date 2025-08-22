// win rules

window.windowConfig = null;

//

window.compactWindow = function() {
    function updateCompactAttr() {
        if (window.innerWidth < 1225) {
            document.body.setAttribute("compact", "");
        } else {
            document.body.removeAttribute("compact");
        }
    }
    updateCompactAttr();
    window.removeEventListener("resize", updateCompactAttr);
    window.addEventListener("resize", updateCompactAttr);
};

window.loadWindowConfig = async function () {
    window.windowConfig = await window.go.main.App.LoadWindowConfig();
    console.debug("Window Config loaded");
    console.debug("Window Config:", window.windowConfig);
    const cs = window.windowConfig["color-scheme"] || {};
    const activeScheme = Object.entries(cs).find(([k, v]) => v === true);
    if (activeScheme) document.body.setAttribute("color-scheme", activeScheme[0]);
    const selectScheme = document.getElementById("selectScheme");
    if (selectScheme) {
        selectScheme.innerHTML = "";
        Object.keys(cs).forEach(scheme => {
            const opt = document.createElement("option");
            opt.value = scheme;
            opt.textContent = scheme;
            if (activeScheme && scheme === activeScheme[0]) opt.selected = true;
            selectScheme.appendChild(opt);
        });

        selectScheme.addEventListener("change", (e) => {
            const selected = e.target.value;
            window.setColorScheme(selected);
        });
    }
    const sidebarState = window.windowConfig["sidebar-state"] || "";
    const sidebar = document.querySelector(".sidebar");
    if (sidebarState === "collapsed") {
        sidebar.setAttribute("collapsed", "");
    } else {
        sidebar.removeAttribute("collapsed");
    }
};

window.setColorScheme = async function (schemeName) {
    if (!window.windowConfig) return;

    Object.keys(window.windowConfig["color-scheme"]).forEach(k => window.windowConfig["color-scheme"][k] = false);
    if (window.windowConfig["color-scheme"].hasOwnProperty(schemeName)) {
        window.windowConfig["color-scheme"][schemeName] = true;
    }
    document.body.setAttribute("color-scheme", schemeName);
    await window.go.main.App.UpdateWindowConfig(window.windowConfig);
};

//

window.loadWindowConfig();