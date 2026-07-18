-- Karya DE - Dock Layout (Latte Dock alternative, native plasma panel)
-- Position: alt, floating, centered

local panel = require("panel")

panel = panel:new({
    alignment = "center",
    height = 48,
    floating = true,
    screen = 0,
    position = "bottom",
    hiding = "autohide",
    lengthMode = "fit",
    offset = 0,
    maxLength = 600,
    widgets = {
        -- Görev yöneticisi
        {
            type = "org.kde.plasma.icontasks",
            config = {
                launchers = {
                    "org.kde.dolphin.desktop",
                    "org.kde.konsole.desktop",
                    "firefox.desktop",
                    "org.kde.kate.desktop",
                    "org.kde.gwenview.desktop",
                    "org.kde.kcalc.desktop",
                    "org.kde.spectacle.desktop",
                    "org.kde.systemsettings.desktop",
                },
                groupingStrategy = 1,  -- group by application
                showOnlyCurrentScreen = true,
                showOnlyCurrentDesktop = false,
            }
        },
    }
})

panel:save("karya-dock")
