import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-haber"
    Plasmoid.title: i18n("Karya Haber")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 350

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            Text {
                text: "Son Dakika Haberleri"
                font.pixelSize: 16
                font.bold: true
                color: "white"
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                clip: true

                model: ListModel {
                    ListElement { title: "Cumhurbaşkanı yeni projeleri açıkladı"; source: "AA" }
                    ListElement { title: "Borsa günü yükselişle kapattı"; source: "Bloomberg HT" }
                    ListElement { title: "Türkiye'nin en sıcak günü yaşandı"; source: "MGM" }
                    ListElement { title: "Yeni yerli otomobil tanıtıldı"; source: "TOGG" }
                    ListElement { title: "Milli takım hazırlık maçında galip"; source: "TFF" }
                    ListElement { title: "Karya DE 1.0 sürümü yayınlandı"; source: "Karya" }
                }

                delegate: Rectangle {
                    width: parent.width
                    height: 60
                    radius: 10
                    color: Qt.rgba(0.2, 0.3, 0.5, 0.2)
                    border.color: Qt.rgba(1,1,1,0.05)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2

                        Text {
                            text: model.title
                            color: "white"
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }

                        Text {
                            text: model.source + " · " + new Date().toLocaleTimeString("tr_TR", {hour: "2-digit", minute: "2-digit"})
                            color: Qt.rgba(1,1,1,0.4)
                            font.pixelSize: 11
                        }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator {}
            }
        }
    }
}
