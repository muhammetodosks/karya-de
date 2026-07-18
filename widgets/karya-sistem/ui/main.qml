import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.systemmonitor 1.0 as SystemMonitor

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-sistem"
    Plasmoid.title: i18n("Karya Sistem")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation

    // CPU data source
    PlasmaCore.DataSource {
        id: cpuSource
        engine: "systemmonitor"
        connectedSources: ["cpu/cpu0/SystemLoad"]
        interval: 2000
    }

    // Memory data source
    PlasmaCore.DataSource {
        id: memSource
        engine: "systemmonitor"
        connectedSources: ["mem/physical/ApplicationMemory"]
        interval: 2000
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 280
        Layout.minimumHeight: 280
        Layout.preferredWidth: 320
        Layout.preferredHeight: 340

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            // CPU Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.3)
                border.color: Qt.rgba(255,255,255,0.04)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Kirigami.Icon {
                        source: "cpu"
                        implicitWidth: 28
                        implicitHeight: 28
                        color: "#4a90d9"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Islemci"
                            font.pixelSize: 12
                            color: Qt.rgba(255,255,255,0.5)
                        }

                        RowLayout {
                            spacing: 8

                            Text {
                                text: "%45"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#4a90d9"
                            }

                            Item { Layout.fillWidth: true }

                            // Mini CPU bar
                            Rectangle {
                                width: 80
                                height: 8
                                radius: 4
                                color: Qt.rgba(255,255,255,0.06)

                                Rectangle {
                                    width: parent.width * 0.45
                                    height: parent.height
                                    radius: 4
                                    color: "#4a90d9"
                                }
                            }
                        }
                    }
                }
            }

            // Memory Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.3)
                border.color: Qt.rgba(255,255,255,0.04)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Kirigami.Icon {
                        source: "memory"
                        implicitWidth: 28
                        implicitHeight: 28
                        color: "#6c5ce7"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Bellek"
                            font.pixelSize: 12
                            color: Qt.rgba(255,255,255,0.5)
                        }

                        RowLayout {
                            spacing: 8

                            Text {
                                text: "3.2 / 8.0 GB"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#6c5ce7"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 80
                                height: 8
                                radius: 4
                                color: Qt.rgba(255,255,255,0.06)

                                Rectangle {
                                    width: parent.width * 0.4
                                    height: parent.height
                                    radius: 4
                                    color: "#6c5ce7"
                                }
                            }
                        }
                    }
                }
            }

            // Disk Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.3)
                border.color: Qt.rgba(255,255,255,0.04)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Kirigami.Icon {
                        source: "drive-harddisk"
                        implicitWidth: 28
                        implicitHeight: 28
                        color: "#2ecc71"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Disk"
                            font.pixelSize: 12
                            color: Qt.rgba(255,255,255,0.5)
                        }

                        RowLayout {
                            spacing: 8

                            Text {
                                text: "45.2 / 256 GB"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#2ecc71"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 80
                                height: 8
                                radius: 4
                                color: Qt.rgba(255,255,255,0.06)

                                Rectangle {
                                    width: parent.width * 0.18
                                    height: parent.height
                                    radius: 4
                                    color: "#2ecc71"
                                }
                            }
                        }
                    }
                }
            }

            // Network Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 12
                color: Qt.rgba(15, 52, 96, 0.3)
                border.color: Qt.rgba(255,255,255,0.04)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Kirigami.Icon {
                        source: "network-wireless"
                        implicitWidth: 28
                        implicitHeight: 28
                        color: "#f39c12"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Ag"
                            font.pixelSize: 12
                            color: Qt.rgba(255,255,255,0.5)
                        }

                        RowLayout {
                            spacing: 16
                            Text {
                                text: "In: 1.2 MB/s"
                                font.pixelSize: 13
                                color: "#2ecc71"
                            }
                            Text {
                                text: "Out: 340 KB/s"
                                font.pixelSize: 13
                                color: "#e74c3c"
                            }
                        }
                    }
                }
            }
        }
    }
}
