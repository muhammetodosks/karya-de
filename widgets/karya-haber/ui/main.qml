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

    Plasmoid.icon: "karya-haber"
    Plasmoid.title: i18n("Karya Haber")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation

    // News data
    ListModel {
        id: newsModel

        Component.onCompleted: {
            append({ title: "Cumhurbaskani yeni projeleri acikladi",
                     source: "Anadolu Ajansi", time: "10:24", category: "Gundem" })
            append({ title: "Borsa gunu yukselisle kapatti",
                     source: "Bloomberg HT", time: "18:15", category: "Ekonomi" })
            append({ title: "Turkiye'nin en sicak gunu yasandi",
                     source: "MGM", time: "14:30", category: "Hava" })
            append({ title: "Yeni yerli otomobil tanitildi",
                     source: "TOGG", time: "11:00", category: "Teknoloji" })
            append({ title: "Milli takim hazirlik macinda galip",
                     source: "TFF", time: "22:45", category: "Spor" })
            append({ title: "Karya DE 1.0 surumu yayinlandi",
                     source: "Karya", time: "09:00", category: "Teknoloji" })
            append({ title: "Istanbul'da toplu tasima zamlandi",
                     source: "IBB", time: "16:20", category: "Gundem" })
            append({ title: "Yeni egitim yili basladi",
                     source: "MEB", time: "08:00", category: "Egitim" })
            append({ title: "Turk bilim insanlarindan buyuk basari",
                     source: "TUBITAK", time: "13:45", category: "Bilim" })
            append({ title: "Antalya'da turizm rekoru",
                     source: "Kultur Turizm", time: "11:30", category: "Turizm" })
        }
    }

    property string selectedCategory: "Tum"

    fullRepresentation: Item {
        Layout.minimumWidth: 320
        Layout.minimumHeight: 360
        Layout.preferredWidth: 380
        Layout.preferredHeight: 500

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Son Haberler"
                    font.pixelSize: 18
                    font.bold: true
                    color: "white"
                    Layout.fillWidth: true
                }

                PlasmaComponents.ComboBox {
                    id: categoryFilter
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 32
                    model: ["Tum", "Gundem", "Ekonomi", "Teknoloji", "Spor", "Bilim", "Egitim"]
                    currentIndex: 0
                    font.pixelSize: 12

                    background: Rectangle {
                        radius: 8
                        color: Qt.rgba(255,255,255,0.06)
                        border.color: Qt.rgba(255,255,255,0.1)
                    }
                    contentItem: Text {
                        text: categoryFilter.currentText
                        color: "white"
                        font.pixelSize: 12
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // News list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.2)
                border.color: Qt.rgba(255,255,255,0.04)

                ListView {
                    id: newsList
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    clip: true

                    model: VisualItemModel {
                        Repeater {
                            model: newsModel

                            Rectangle {
                                width: newsList.width - 16
                                height: 64
                                radius: 10
                                color: index % 2 === 0 ? Qt.rgba(255,255,255,0.03)
                                                       : Qt.rgba(255,255,255,0.06)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    // Category indicator
                                    Rectangle {
                                        width: 4
                                        height: 36
                                        radius: 2
                                        color: {
                                            switch(model.category) {
                                                case "Gundem": return "#e74c3c"
                                                case "Ekonomi": return "#f39c12"
                                                case "Teknoloji": return "#3498db"
                                                case "Spor": return "#2ecc71"
                                                case "Bilim": return "#9b59b6"
                                                default: return "#4a90d9"
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Layout.fillWidth: true

                                        Text {
                                            text: model.title
                                            color: "white"
                                            font.pixelSize: 13
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            Layout.fillWidth: true
                                        }

                                        RowLayout {
                                            spacing: 8
                                            Text {
                                                text: model.source
                                                color: Qt.rgba(255,255,255,0.3)
                                                font.pixelSize: 10
                                            }
                                            Text {
                                                text: model.time
                                                color: Qt.rgba(255,255,255,0.2)
                                                font.pixelSize: 10
                                            }
                                            Text {
                                                text: model.category
                                                color: {
                                                    switch(model.category) {
                                                        case "Gundem": return "#e74c3c"
                                                        case "Ekonomi": return "#f39c12"
                                                        case "Teknoloji": return "#3498db"
                                                        case "Spor": return "#2ecc71"
                                                        default: return "#4a90d9"
                                                    }
                                                }
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Open news in browser
                                        Qt.openUrlExternally("https://karya-de.org/haber")
                                    }
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        width: 6
                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle {
                            radius: 3
                            color: Qt.rgba(255,255,255,0.2)
                        }
                    }
                }
            }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                Text {
                    text: newsModel.count + " haber"
                    color: Qt.rgba(255,255,255,0.3)
                    font.pixelSize: 11
                }

                Text {
                    text: "Daha Fazla >"
                    color: "#4a90d9"
                    font.pixelSize: 12
                    font.bold: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://karya-de.org/haber")
                    }
                }
            }
        }
    }
}
