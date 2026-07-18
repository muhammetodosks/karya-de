import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#1a1a2e"

    // Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#0f3460" }
        }
    }

    // Decorative circles
    Repeater {
        model: [
            { x: 0.15, y: 0.2, r: 200, color: Qt.rgba(74/255, 144/255, 217/255, 0.05) },
            { x: 0.85, y: 0.7, r: 280, color: Qt.rgba(108/255, 92/255, 231/255, 0.04) },
            { x: 0.7, y: 0.15, r: 140, color: Qt.rgba(74/255, 144/255, 217/255, 0.03) },
        ]
        Rectangle {
            x: parent.width * modelData.x - modelData.r / 2
            y: parent.height * modelData.y - modelData.r / 2
            width: modelData.r * 2
            height: modelData.r * 2
            radius: modelData.r
            color: modelData.color
        }
    }

    // Login card
    Rectangle {
        id: loginCard
        width: 400
        height: 480
        anchors.centerIn: parent
        radius: 24
        color: Qt.rgba(30/255, 30/255, 50/255, 0.7)
        border.color: Qt.rgba(255, 255, 255, 0.08)
        border.width: 1

        layer {
            enabled: true
            effect: FastBlur {
                radius: 32
                transparentBorder: true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // Logo
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72
                radius: 18
                color: "#4a90d9"

                Text {
                    anchors.centerIn: parent
                    text: "K"
                    color: "white"
                    font.pixelSize: 36
                    font.bold: true
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Karya DE"
                color: "white"
                font.pixelSize: 24
                font.bold: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Hos Geldiniz"
                color: Qt.rgba(255,255,255,0.5)
                font.pixelSize: 14
                visible: true
            }

            Item { height: 10 }

            // Username input
            TextField {
                id: usernameField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Kullanici Adi"
                font.pixelSize: 16
                color: "white"
                background: Rectangle {
                    radius: 12
                    color: Qt.rgba(255,255,255,0.06)
                    border.color: usernameField.activeFocus ? "#4a90d9" : Qt.rgba(255,255,255,0.1)
                    border.width: usernameField.activeFocus ? 2 : 1
                }
                leftPadding: 16
            }

            // Password input
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Sifre"
                echoMode: TextInput.Password
                font.pixelSize: 16
                color: "white"
                background: Rectangle {
                    radius: 12
                    color: Qt.rgba(255,255,255,0.06)
                    border.color: passwordField.activeFocus ? "#4a90d9" : Qt.rgba(255,255,255,0.1)
                    border.width: passwordField.activeFocus ? 2 : 1
                }
                leftPadding: 16
                onAccepted: loginButton.clicked()
            }

            Item { height: 10 }

            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                text: "Giris Yap"
                font.pixelSize: 16
                font.bold: true

                background: Rectangle {
                    radius: 14
                    color: parent.hovered ? "#5ba0e9" : "#4a90d9"
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    // Trigger SDDM login
                    sddm.login(usernameField.text, passwordField.text, sessionSelector.currentValue)
                }
            }

            // Session selector
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Oturum:"
                    color: Qt.rgba(255,255,255,0.5)
                    font.pixelSize: 13
                }

                ComboBox {
                    id: sessionSelector
                    Layout.fillWidth: true
                    model: [
                        { text: "Karya DE (Wayland)", value: "karya-wayland" },
                        { text: "Karya DE (X11)", value: "karya-x11" },
                    ]
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: 0
                    font.pixelSize: 13

                    background: Rectangle {
                        radius: 8
                        color: Qt.rgba(255,255,255,0.05)
                        border.color: Qt.rgba(255,255,255,0.1)
                    }
                    contentItem: Text {
                        text: sessionSelector.currentText
                        color: "white"
                        font: sessionSelector.font
                        leftPadding: 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Power buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: "Kapa"
                    Layout.fillWidth: true
                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? Qt.rgba(255/255, 95/255, 87/255, 0.3)
                                              : Qt.rgba(255,255,255,0.05)
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Qt.rgba(255,255,255,0.6)
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: sddm.powerOff()
                }

                Button {
                    text: "Yeniden Baslat"
                    Layout.fillWidth: true
                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? Qt.rgba(46/255, 204/255, 113/255, 0.3)
                                              : Qt.rgba(255,255,255,0.05)
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Qt.rgba(255,255,255,0.6)
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: sddm.reboot()
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Karya DE v1.0.0"
                color: Qt.rgba(255,255,255,0.2)
                font.pixelSize: 12
            }
        }
    }

    // Virtual keyboard support
    Keyboard {
        anchors.bottom: parent.bottom
        visible: false
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            passwordField.text = ""
            passwordField.focus = true
        }
    }
}
