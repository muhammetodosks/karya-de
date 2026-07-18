import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-hava"
    Plasmoid.title: i18n("Karya Hava")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.minimumWidth: 280
        Layout.minimumHeight: 320

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Şehir seçici
            PlasmaComponents.ComboBox {
                id: citySelector
                Layout.fillWidth: true
                model: [
                    "İstanbul", "Ankara", "İzmir", "Bursa",
                    "Antalya", "Adana", "Trabzon", "Erzurum",
                    "Gaziantep", "Diyarbakır", "Samsun", "Konya"
                ]
                currentIndex: 0
                displayText: currentText
            }

            // Ana hava durumu
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                radius: 16
                color: Qt.rgba(0.2, 0.3, 0.5, 0.3)
                border.color: Qt.rgba(1, 1, 1, 0.1)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "☀️"
                        font.pixelSize: 48
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "24°C"
                        font.pixelSize: 32
                        color: "white"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Açık, hissedilen 22°C"
                        font.pixelSize: 14
                        color: Qt.rgba(1,1,1,0.7)
                    }
                }
            }

            // Haftalık tahmin
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData
                            font.pixelSize: 11
                            color: Qt.rgba(1,1,1,0.6)
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: index % 2 === 0 ? "☀️" : "⛅"
                            font.pixelSize: 20
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Math.round(20 + Math.random() * 10) + "°"
                            font.pixelSize: 12
                            color: "white"
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
