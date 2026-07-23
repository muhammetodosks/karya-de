import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.icon: "karya-sistem"
    Plasmoid.title: i18n("Karya Sistem")
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground

    preferredRepresentation: fullRepresentation

    // CPU data source (fallback values when systemmonitor not available)
    property double cpuLoad: 0.0
    property double memUsed: 0.0
    property double memTotal: 0.0
    property double diskUsed: 0.0
    property double diskTotal: 0.0
    property double netIn: 0.0
    property double netOut: 0.0
    property bool dataReady: false

    PlasmaCore.DataSource {
        id: cpuSource
        engine: "systemmonitor"
        connectedSources: ["cpu/cpu0/SystemLoad"]
        interval: 2000
        onDataChanged: {
            var value = data["SystemLoad"] || 0
            cpuLoad = value
            dataReady = true
        }
    }

    PlasmaCore.DataSource {
        id: memSource
        engine: "systemmonitor"
        connectedSources: ["mem/physical/ApplicationMemory"]
        interval: 2000
        onDataChanged: {
            memUsed = data["ApplicationMemory"] || 2457600
            memTotal = data["TotalMemory"] || 8388608
        }
    }

    PlasmaCore.DataSource {
        id: diskSource
        engine: "systemmonitor"
        connectedSources: ["disk/root/Used"]
        interval: 5000
        onDataChanged: {
            diskUsed = data["Used"] || 45200000
            diskTotal = data["Total"] || 256000000
        }
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
                                text: "%" + Math.round(cpuLoad)
                                font.pixelSize: 20
                                font.bold: true
                                color: "#4a90d9"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 80
                                height: 8
                                radius: 4
                                color: Qt.rgba(255,255,255,0.06)

                                Rectangle {
                                    width: parent.width * Math.min(cpuLoad / 100, 1)
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
                                text: (memUsed / 1048576).toFixed(1) + " / " + (memTotal / 1048576).toFixed(1) + " GB"
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
                                    width: parent.width * Math.min(memTotal > 0 ? memUsed / memTotal : 0, 1)
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
                                text: (diskUsed / 1048576).toFixed(1) + " / " + (diskTotal / 1048576).toFixed(1) + " GB"
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
                                    width: parent.width * Math.min(diskTotal > 0 ? diskUsed / diskTotal : 0, 1)
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
                                text: "In: " + (netIn / 1024).toFixed(1) + " KB/s"
                                font.pixelSize: 13
                                color: "#2ecc71"
                            }
                            Text {
                                text: "Out: " + (netOut / 1024).toFixed(1) + " KB/s"
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
