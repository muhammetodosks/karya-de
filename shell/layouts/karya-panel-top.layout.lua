-- Karya DE - Üst Panel Layout
-- Plasma 6 for Karya Desktop Environment

local widget = require("widget")
local panel = require("panel")

panel = panel:new({
    alignment = "center",
    height = 36,
    floating = false,
    screen = 0,
    position = "top",
    hiding = "none",
    lengthMode = "fill",
    offset = 0,
    widgets = {
        -- Sol: Uygulama menüsü + görev yöneticisi
        {
            type = "org.kde.plasma.kickoff",
            config = {
                icon = "karya-logo",
                popupWidth = 400,
                popupHeight = 600,
            }
        },
        {
            type = "org.kde.plasma.icontasks",
            config = {
                launchers = {
                    "org.kde.dolphin.desktop",
                    "org.kde.konsole.desktop",
                    "firefox.desktop",
                    "org.kde.kate.desktop",
                },
                groupingStrategy = 0,
                showOnlyCurrentScreen = true,
            }
        },
        -- Orta: Sistem tepsisi (sağa itmek için spacer)
        {
            type = "org.kde.plasma.marginsseparator",
            config = { expand = true }
        },
        -- Sağ: Sistem tepsisi + saat
        {
            type = "org.kde.plasma.systemtray",
            config = {
                icons = {
                    "org.kde.plasma.brightness",
                    "org.kde.plasma.networkmanagement",
                    "org.kde.plasma.volume",
                    "org.kde.plasma.battery",
                    "org.kde.plasma.bluetooth",
                    "org.kde.plasma.notifications",
                },
                showAllItems = false,
            }
        },
        {
            type = "org.kde.plasma.digitalclock",
            config = {
                dateFormat = "longDate",
                dateRole = 2,
                timeFormat = "24h",
                timeZone = "Europe/Istanbul",
                calendarType = "proleptic-gregorian",
                firstDayOfWeek = 1,
                showSeconds = false,
                showDate = true,
            }
        },
    }
})

panel:save("karya-panel-top")
