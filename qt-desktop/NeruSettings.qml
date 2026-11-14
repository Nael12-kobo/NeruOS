import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    width: 860
    height: 650
    minimumWidth: 680
    minimumHeight: 500
    visible: false
    color: "#10192B"
    flags: Qt.Window
    title: "NeruSettings"

    property int selectedSection: 0
    signal closeRequested()
    signal wallpaperRequested()
    signal sessionRequested()

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#F010192B"
        border.color: "#8298B9D8"
        clip: true
    }

    readonly property var sections: ["Appearance", "Dock", "System", "Session"]
    readonly property var accents: ["#54C8EB", "#6B8AFD", "#A78BFA", "#E879F9"]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 19
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "NeruSettings"
                color: "#F2F5FF"
                font.pixelSize: 19
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            ToolButton {
                text: "×"
                onClicked: root.close()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 155
                Layout.fillHeight: true
                radius: 13
                color: "#70111D33"
                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 5
                    Repeater {
                        model: root.sections
                        delegate: Rectangle {
                            required property string modelData
                            required property int index
                            width: parent.width
                            height: 39
                            radius: 9
                            color: root.selectedSection === index ? "#6B3F5C82" : "transparent"
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 11
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                color: root.selectedSection === index ? "#FFFFFF" : "#BDCAE0"
                                font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.selectedSection = index
                            }
                        }
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.selectedSection

                // Appearance
                Flickable {
                    clip: true
                    contentHeight: appearanceColumn.implicitHeight
                    ColumnLayout {
                        id: appearanceColumn
                        width: parent.width
                        spacing: 14
                        Text {
                            text: "Appearance"
                            color: "#F2F5FF"
                            font.pixelSize: 17
                            font.bold: true
                        }
                        Text {
                            text: "Make Nebula feel like yours."
                            color: "#AAB6D0"
                            font.pixelSize: 10
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 106
                            radius: 13
                            color: "#1C2E4A"
                            clip: true
                            Image {
                                anchors.fill: parent
                                source: desktopSettings.wallpaperPath.length
                                        ? desktopSettings.wallpaperPath
                                        : "qrc:/assets/nebula-wallpaper.png"
                                fillMode: Image.PreserveAspectCrop
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: "#33081224"
                                radius: 13
                                border.color: "#7286A9CC"
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Wallpaper"; color: "#E6ECF8"; font.pixelSize: 12; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Choose…"
                                onClicked: root.wallpaperRequested()
                            }
                            Button {
                                text: "Reset"
                                onClicked: desktopSettings.resetWallpaper()
                            }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#3F587493" }
                        Text { text: "Accent color"; color: "#E6ECF8"; font.pixelSize: 12; font.bold: true }
                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: root.accents
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    width: 34
                                    height: 34
                                    radius: 17
                                    color: modelData
                                    border.width: desktopSettings.accentIndex === index ? 3 : 1
                                    border.color: desktopSettings.accentIndex === index ? "#FFFFFF" : "#8299B9"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: desktopSettings.accentIndex = index
                                    }
                                }
                            }
                        }
                        Text {
                            text: "Preferences are saved in your user profile and restored after login."
                            color: "#8597B5"
                            font.pixelSize: 9
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Dock
                Flickable {
                    clip: true
                    contentHeight: dockColumn.implicitHeight
                    ColumnLayout {
                        id: dockColumn
                        width: parent.width
                        spacing: 12
                        Text { text: "Dock"; color: "#F2F5FF"; font.pixelSize: 17; font.bold: true }
                        Text {
                            text: "Pin or unpin applications. Changes are saved automatically."
                            color: "#AAB6D0"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Repeater {
                            model: [
                                { name: "NeruFiles", detail: "File manager" },
                                { name: "NeruBrowser", detail: "Web browser" },
                                { name: "NeruTerminal", detail: "Terminal" },
                                { name: "NeruCode", detail: "Code editor" },
                                { name: "NeruSettings", detail: "System settings" },
                                { name: "NeruSearch", detail: "Application search" },
                                { name: "Steam", detail: "Game launcher" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 45
                                radius: 9
                                color: "#3B253B5C"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 11
                                    anchors.rightMargin: 10
                                    Text { text: modelData.name; color: "#F2F5FF"; font.pixelSize: 11; Layout.fillWidth: true }
                                    Text { text: modelData.detail; color: "#9EACC8"; font.pixelSize: 9 }
                                    Switch {
                                        checked: desktopSettings.isPinned(modelData.name)
                                        onToggled: desktopSettings.togglePinned(modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }

                // System
                Flickable {
                    clip: true
                    contentHeight: systemColumn.implicitHeight
                    ColumnLayout {
                        id: systemColumn
                        width: parent.width
                        spacing: 13
                        Text { text: "System"; color: "#F2F5FF"; font.pixelSize: 17; font.bold: true }
                        Text { text: "NeruOS Nebula Edition"; color: "#D9E3F4"; font.pixelSize: 13 }
                        Text { text: "Qt 6 · C++ · QML · Wayland · labwc"; color: "#AAB6D0"; font.pixelSize: 10 }
                        Text { text: "System packages and updates are managed by the NeruOS image. This panel does not run privileged commands."; color: "#8597B5"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Button {
                            text: "Reset desktop preferences"
                            onClicked: resetPreferencesDialog.open()
                        }
                    }
                }

                // Session
                ColumnLayout {
                    spacing: 12
                    Text { text: "Session"; color: "#F2F5FF"; font.pixelSize: 17; font.bold: true }
                    Text { text: "Manage your current NeruOS session."; color: "#AAB6D0"; font.pixelSize: 10 }
                    Button { text: "Open Power & Session controls"; onClicked: root.sessionRequested() }
                    Text {
                        text: "The Alpha live image currently signs in automatically as the live user. A real graphical login manager is not enabled in this build."
                        color: "#8597B5"
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Dialog {
        id: resetPreferencesDialog
        title: "Reset desktop preferences?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        Label {
            text: "This resets the wallpaper, accent color, and pinned applications to their defaults."
            wrapMode: Text.WordWrap
            color: "#26344B"
        }
        onAccepted: desktopSettings.resetPreferences()
    }
}
