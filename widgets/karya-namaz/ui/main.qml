import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-namaz"
    Plasmoid.title: i18n("Karya Namaz")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.minimumWidth: 220
        Layout.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            // Şehir seçici
            PlasmaComponents.ComboBox {
                id: citySelector
                Layout.fillWidth: true
                model: ["İstanbul", "Ankara", "İzmir", "Bursa",
                    "Antalya", "Konya", "Trabzon", "Erzurum"]
                currentIndex: 0
            }

            // Tarih
            Text {
                text: new Date().toLocaleDateString("tr_TR", {
                    weekday: "long",
                    day: "numeric",
                    month: "long",
                    year: "numeric"
                })
                font.pixelSize: 13
                color: Qt.rgba(1,1,1,0.7)
                Layout.alignment: Qt.AlignHCenter
            }

            // Vakit kartı
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                radius: 16
                color: Qt.rgba(0.2, 0.3, 0.5, 0.3)
                border.color: Qt.rgba(1, 1, 1, 0.1)

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    // Sol sütun: vakit adları
                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        Text { text: "İmsak"; color: Qt.rgba(1,1,1,0.6); font.pixelSize: 13 }
                        Text { text: "Güneş"; color: Qt.rgba(1,1,1,0.6); font.pixelSize: 13 }
                        Text { text: "Öğle"; color: Qt.rgba(1,1,1,0.6); font.pixelSize: 13 }
                        Text { text: "İkindi"; color: Qt.rgba(1,1,1,0.6); font.pixelSize: 13 }
                        Text { text: "Akşam"; color: "white"; font.pixelSize: 14; font.bold: true }
                        Text { text: "Yatsı"; color: Qt.rgba(1,1,1,0.6); font.pixelSize: 13 }
                    }

                    // Sağ sütun: saatler
                    ColumnLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignRight

                        Text { text: "04:28"; color: "white"; font.pixelSize: 13 }
                        Text { text: "06:02"; color: "white"; font.pixelSize: 13 }
                        Text { text: "13:15"; color: "white"; font.pixelSize: 13 }
                        Text { text: "17:10"; color: "white"; font.pixelSize: 13 }
                        Text { text: "20:25"; color: "#FFD700"; font.pixelSize: 14; font.bold: true }
                        Text { text: "22:00"; color: "white"; font.pixelSize: 13 }
                    }
                }
            }

            // Kalan süre
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Akşam'a kalan süre: 2s 45dk"
                font.pixelSize: 12
                color: "#FFD700"
            }

            Item { Layout.fillHeight: true }
        }
    }
}
