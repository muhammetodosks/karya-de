// Karya DE Main Layout
// Loads top panel + dock

var plasma = getApi("plasma");

// Top panel
var topPanel = new Panel("karya-panel-top");
topPanel.height = 36;
topPanel.position = "top";
topPanel.location = "top";
topPanel.alignment = "center";
topPanel.floating = false;
topPanel.hiding = "none";
topPanel.lengthMode = "fill";
topPanel.screen = 0;

// Kickoff (Application Menu)
var kickoff = topPanel.addWidget("org.kde.plasma.kickoff");
kickoff.currentConfigGroup = ["Shortcuts"];
kickoff.writeConfig("global", "Alt+F1");
kickoff.currentConfigGroup = ["General"];
kickoff.writeConfig("icon", "karya-logo");

// Icon Tasks
var iconTasks = topPanel.addWidget("org.kde.plasma.icontasks");
iconTasks.currentConfigGroup = ["General"];
iconTasks.writeConfig("launchers", [
    "org.kde.dolphin.desktop",
    "org.kde.konsole.desktop",
    "firefox.desktop",
    "org.kde.kate.desktop"
]);
iconTasks.writeConfig("groupingStrategy", 0);
iconTasks.writeConfig("showOnlyCurrentScreen", true);

// Spacer
topPanel.addWidget("org.kde.plasma.marginsseparator");

// System Tray
var systemTray = topPanel.addWidget("org.kde.plasma.systemtray");
systemTray.currentConfigGroup = ["General"];
systemTray.writeConfig("icons", [
    "org.kde.plasma.brightness",
    "org.kde.plasma.networkmanagement",
    "org.kde.plasma.volume",
    "org.kde.plasma.battery",
    "org.kde.plasma.bluetooth",
    "org.kde.plasma.notifications"
]);
systemTray.writeConfig("showAllItems", false);

// Digital Clock
var clock = topPanel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["General"];
clock.writeConfig("dateFormat", "longDate");
clock.writeConfig("dateRole", 2);
clock.writeConfig("timeFormat", "24h");
clock.writeConfig("timeZone", "Europe/Istanbul");
clock.writeConfig("firstDayOfWeek", 1);
clock.writeConfig("showSeconds", false);
clock.writeConfig("showDate", true);

// Dock (bottom)
var dock = new Panel("karya-dock");
dock.height = 48;
dock.position = "bottom";
dock.location = "bottom";
dock.alignment = "center";
dock.floating = true;
dock.hiding = "autohide";
dock.lengthMode = "fit";
dock.maxLength = 600;
dock.screen = 0;

var dockTasks = dock.addWidget("org.kde.plasma.icontasks");
dockTasks.currentConfigGroup = ["General"];
dockTasks.writeConfig("launchers", [
    "org.kde.dolphin.desktop",
    "org.kde.konsole.desktop",
    "firefox.desktop",
    "org.kde.kate.desktop",
    "org.kde.gwenview.desktop",
    "org.kde.kcalc.desktop",
    "org.kde.spectacle.desktop",
    "org.kde.systemsettings.desktop"
]);
dockTasks.writeConfig("groupingStrategy", 1);
dockTasks.writeConfig("showOnlyCurrentScreen", true);

// Apply wallpaper
var wallpaper = new Wallpaper;
wallpaper.writeConfig("Image", "/usr/share/wallpapers/karya-default.jpg");
wallpaper.writeConfig("FillMode", 2); // CenterAutoCrop
