import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-namaz"
    Plasmoid.title: i18n("Karya Namaz")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation

    // Prayer times data
    ListModel {
        id: prayerModel

        Component.onCompleted: {
            // Istanbul default
            append({
                city: "Istanbul",
                date: "",
                times: [
                    { name: "Imsak", time: "04:28", icon: "weather-clear-night" },
                    { name: "Gunes", time: "06:02", icon: "weather-clear" },
                    { name: "Ogle", time: "13:15", icon: "weather-clear" },
                    { name: "Ikindi", time: "17:10", icon: "weather-clear" },
                    { name: "Aksam", time: "20:25", icon: "weather-sunset", isNext: true },
                    { name: "Yatsi", time: "22:00", icon: "weather-clear-night" },
                ]
            })
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 260
        Layout.minimumHeight: 340
        Layout.preferredWidth: 300
        Layout.preferredHeight: 380

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
                    "Konya", "Antalya", "Trabzon", "Erzurum"
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

            // Date
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: new Date().toLocaleDateString("tr_TR", {
                    weekday: "long", day: "numeric",
                    month: "long", year: "numeric"
                })
                font.pixelSize: 12
                color: Qt.rgba(255,255,255,0.5)
            }

            // Prayer times card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: Qt.rgba(15, 52, 96, 0.4)
                border.color: Qt.rgba(255,255,255,0.06)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6

                    Repeater {
                        model: prayerModel.count > 0 ? prayerModel.get(0).times : []

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 8
                            color: modelData.isNext ? Qt.rgba(255, 215, 0, 0.12)
                                                     : "transparent"
                            border.color: modelData.isNext ? Qt.rgba(255, 215, 0, 0.2)
                                                           : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Kirigami.Icon {
                                    source: modelData.icon
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    color: modelData.isNext ? "#FFD700"
                                                            : Qt.rgba(255,255,255,0.5)
                                }

                                Text {
                                    text: modelData.name
                                    color: modelData.isNext ? "#FFD700"
                                                            : Qt.rgba(255,255,255,0.7)
                                    font.pixelSize: 13
                                    font.bold: modelData.isNext
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.time
                                    color: modelData.isNext ? "#FFD700" : "white"
                                    font.pixelSize: 13
                                    font.bold: modelData.isNext
                                    font.letterSpacing: 1
                                }
                            }
                        }
                    }

                    // Next prayer countdown
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 10
                        color: Qt.rgba(255, 215, 0, 0.06)
                        border.color: Qt.rgba(255, 215, 0, 0.1)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "Aksam'a kalan:"
                                color: Qt.rgba(255, 215, 0, 0.6)
                                font.pixelSize: 12
                            }

                            Text {
                                text: "2s 45dk"
                                color: "#FFD700"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
