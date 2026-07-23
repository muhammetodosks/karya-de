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

    property string currentTemp: "24"
    property string currentCondition: "Acik"
    property string currentFeels: "22"
    property string currentHumidity: "45"
    property string currentWind: "12"
    property string currentCity: "Istanbul"

    // Weather data model
    ListModel {
        id: weatherModel
    }

    function loadCityData(city) {
        weatherModel.clear()
        currentCity = city

        var data = {
            "Istanbul": { temp: 24, feels: 22, cond: "Acik", humid: 45, wind: 12 },
            "Ankara": { temp: 18, feels: 16, cond: "Acik", humid: 35, wind: 8 },
            "Izmir": { temp: 28, feels: 26, cond: "Acik", humid: 50, wind: 15 },
            "Bursa": { temp: 22, feels: 20, cond: "Parçali bulutlu", humid: 48, wind: 10 },
            "Antalya": { temp: 30, feels: 28, cond: "Acik", humid: 55, wind: 12 },
            "Adana": { temp: 32, feels: 30, cond: "Acik", humid: 40, wind: 8 },
            "Trabzon": { temp: 20, feels: 18, cond: "Kapali", humid: 60, wind: 20 },
            "Erzurum": { temp: 12, feels: 10, cond: "Az bulutlu", humid: 30, wind: 15 },
            "Gaziantep": { temp: 26, feels: 24, cond: "Acik", humid: 32, wind: 10 },
            "Diyarbakir": { temp: 28, feels: 26, cond: "Acik", humid: 28, wind: 12 },
            "Samsun": { temp: 22, feels: 20, cond: "Parçali bulutlu", humid: 55, wind: 18 },
            "Konya": { temp: 20, feels: 18, cond: "Acik", humid: 30, wind: 12 },
            "Eskisehir": { temp: 18, feels: 16, cond: "Acik", humid: 35, wind: 10 },
            "Kayseri": { temp: 20, feels: 18, cond: "Az bulutlu", humid: 32, wind: 14 },
            "Mersin": { temp: 30, feels: 28, cond: "Acik", humid: 50, wind: 10 },
            "Kocaeli": { temp: 24, feels: 22, cond: "Parçali bulutlu", humid: 48, wind: 12 }
        }

        var d = data[city] || data["Istanbul"]
        currentTemp = d.temp
        currentCondition = d.cond
        currentFeels = d.feels
        currentHumidity = d.humid
        currentWind = d.wind

        weatherModel.append({
            city: city,
            temp: d.temp,
            feelsLike: d.feels,
            condition: d.cond,
            humidity: d.humid,
            wind: d.wind,
            icon: "weather-clear",
            forecast: [
                { day: "Pzt", temp: d.temp + 2, icon: "weather-clear" },
                { day: "Sali", temp: d.temp + 4, icon: "weather-clear" },
                { day: "Car", temp: d.temp - 2, icon: "weather-clouds" },
                { day: "Per", temp: d.temp - 6, icon: "weather-showers" },
                { day: "Cum", temp: d.temp + 1, icon: "weather-clear" },
                { day: "Cmt", temp: d.temp - 1, icon: "weather-clouds" },
                { day: "Paz", temp: d.temp + 3, icon: "weather-clear" },
            ]
        })
    }

    Component.onCompleted: {
        loadCityData("Istanbul")
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

                onActivated: {
                    loadCityData(model[index])
                }

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
                            text: currentTemp + " C"
                            font.pixelSize: 40
                            font.bold: true
                            color: "white"
                        }

                        Text {
                            text: currentCondition + ", hissedilen " + currentFeels + " C"
                            font.pixelSize: 13
                            color: Qt.rgba(255,255,255,0.6)
                        }

                        RowLayout {
                            spacing: 16
                            Text {
                                text: "Nem: %" + currentHumidity
                                font.pixelSize: 11
                                color: Qt.rgba(255,255,255,0.4)
                            }
                            Text {
                                text: "Ruzgar: " + currentWind + " km/h"
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
                            { hour: "12:00", temp: currentTemp, icon: "weather-clear" },
                            { hour: "15:00", temp: parseInt(currentTemp) + 2, icon: "weather-clear" },
                            { hour: "18:00", temp: parseInt(currentTemp) - 2, icon: "weather-clouds" },
                            { hour: "21:00", temp: parseInt(currentTemp) - 5, icon: "weather-clear-night" },
                            { hour: "00:00", temp: parseInt(currentTemp) - 7, icon: "weather-clear-night" },
                            { hour: "03:00", temp: parseInt(currentTemp) - 8, icon: "weather-clear-night" },
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
                        model: weatherModel.count > 0 ? weatherModel.get(0).forecast : []

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
