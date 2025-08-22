export namespace main {
	
	export class Config {
	    git_is: boolean;
	    os_is: string;
	    firefox_is: string;
	    firefoxs: Record<string, string>;
	    firefox_profiles: Record<string, string>;
	    selected_profile: string;
	    saved_themes: Record<string, string>;
	    selected_theme: string;
	    apply_userjs: boolean;
	    allow_restart: boolean;
	    backup_chrome: boolean;
	
	    static createFrom(source: any = {}) {
	        return new Config(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.git_is = source["git_is"];
	        this.os_is = source["os_is"];
	        this.firefox_is = source["firefox_is"];
	        this.firefoxs = source["firefoxs"];
	        this.firefox_profiles = source["firefox_profiles"];
	        this.selected_profile = source["selected_profile"];
	        this.saved_themes = source["saved_themes"];
	        this.selected_theme = source["selected_theme"];
	        this.apply_userjs = source["apply_userjs"];
	        this.allow_restart = source["allow_restart"];
	        this.backup_chrome = source["backup_chrome"];
	    }
	}
	export class Window {
	    width: string;
	    height: string;
	    color-scheme: Record<string, boolean>;
	    "sidebar-state": string;
	
	    static createFrom(source: any = {}) {
	        return new Window(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.width = source["width"];
	        this.height = source["height"];
	        this["color-scheme"] = source["color-scheme"];
	        this["sidebar-state"] = source["sidebar-state"];
	    }
	}

}

