import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.XmlListModel 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-hava"
    Plasmoid.title: i18n("Karya Hava")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation

    // Weather data model
    ListModel {
        id: weatherModel

        Component.onCompleted: {
            // Istanbul default data
            append({
                city: "Istanbul",
                temp: 24,
                feelsLike: 22,
                condition: "Acik",
                humidity: 45,
                wind: 12,
                icon: "weather-clear",
                forecast: [
                    { day: "Pzt", temp: 26, icon: "weather-clear" },
                    { day: "Sali", temp: 28, icon: "weather-clear" },
                    { day: "Car", temp: 22, icon: "weather-clouds" },
                    { day: "Per", temp: 18, icon: "weather-showers" },
                    { day: "Cum", temp: 25, icon: "weather-clear" },
                    { day: "Cmt", temp: 23, icon: "weather-clouds" },
                    { day: "Paz", temp: 27, icon: "weather-clear" },
                ]
            })
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 320
        Layout.minimumHeight: 380
        Layout.preferredWidth: 360
        Layout.preferredHeight: 420

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // City selector
            PlasmaComponents.ComboBox {
                id: citySelector
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: [
                    "Istanbul", "Ankara", "Izmir", "Bursa",
                    "Antalya", "Adana", "Trabzon", "Erzurum",
                    "Gaziantep", "Diyarbakir", "Samsun", "Konya",
                    "Eskisehir", "Kayseri", "Mersin", "Kocaeli"
                ]
                currentIndex: 0

                background: Rectangle {
                    radius: 10
                    color: Qt.rgba(255,255,255,0.06)
                    border.color: Qt.rgba(255,255,255,0.1)
                }
                contentItem: Text {
                    text: citySelector.currentText
                    color: "white"
                    font.pixelSize: 14
                    leftPadding: 12
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Main weather card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 16
                color: Qt.rgba(15, 52, 96, 0.4)
                border.color: Qt.rgba(255,255,255,0.06)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    // Weather icon
                    Kirigami.Icon {
                        source: "weather-clear"
                        implicitWidth: 64
                        implicitHeight: 64
                        color: "#f1c40f"
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "24 C"
                            font.pixelSize: 40
                            font.bold: true
                            color: "white"
                        }

                        Text {
                            text: "Acik, hissedilen 22 C"
                            font.pixelSize: 13
                            color: Qt.rgba(255,255,255,0.6)
                        }

                        RowLayout {
                            spacing: 16
                            Text {
                                text: "Nem: %45"
                                font.pixelSize: 11
                                color: Qt.rgba(255,255,255,0.4)
                            }
                            Text {
                                text: "Ruzgar: 12 km/h"
                                font.pixelSize: 11
                                color: Qt.rgba(255,255,255,0.4)
                            }
                        }
                    }
                }
            }

            // Hourly forecast strip
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.2)
                border.color: Qt.rgba(255,255,255,0.04)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Repeater {
                        model: [
                            { hour: "12:00", temp: "24", icon: "weather-clear" },
                            { hour: "15:00", temp: "26", icon: "weather-clear" },
                            { hour: "18:00", temp: "22", icon: "weather-clouds" },
                            { hour: "21:00", temp: "19", icon: "weather-clear-night" },
                            { hour: "00:00", temp: "17", icon: "weather-clear-night" },
                            { hour: "03:00", temp: "16", icon: "weather-clear-night" },
                        ]

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.hour
                                font.pixelSize: 10
                                color: Qt.rgba(255,255,255,0.4)
                            }

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignHCenter
                                source: modelData.icon
                                implicitWidth: 20
                                implicitHeight: 20
                                color: Qt.rgba(255,255,255,0.7)
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.temp + " C"
                                font.pixelSize: 11
                                color: "white"
                            }
                        }
                    }
                }
            }

            // Weekly forecast
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.2)
                border.color: Qt.rgba(255,255,255,0.04)

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 7
                    rowSpacing: 4
                    columnSpacing: 2

                    Repeater {
                        model: weatherModel.get(0)?.forecast || []

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.day
                                font.pixelSize: 11
                                color: Qt.rgba(255,255,255,0.5)
                            }

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignHCenter
                                source: modelData.icon
                                implicitWidth: 24
                                implicitHeight: 24
                                color: Qt.rgba(255,255,255,0.8)
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.temp + " C"
                                font.pixelSize: 12
                                color: "white"
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
