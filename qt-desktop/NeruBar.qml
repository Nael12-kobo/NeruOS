import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    implicitHeight: 42
    radius: 14
    color: "transparent"
    border.color: "transparent"
    border.width: 0

    property Item blurSource
    property string appName: ""
    property string workspaceName: "General"
    property string clockText: ""
    property string dateText: ""
    property string wifiStatus: "Checking…"
    property string bluetoothStatus: "Checking…"
    property string audioStatus: "Checking…"
    property string batteryStatus: "No battery detected"
    property int notificationCount: 0
    property int updateCount: 0
    property string updateState: "idle"
    property string activeMenu: ""
    property real menuAnchorX: 24
    property var menuOptions: []

    signal searchRequested()
    signal centerRequested()
    signal notificationRequested()
    signal sessionRequested()
    signal updateCheckRequested()
    signal menuActionRequested(string action)

    GlassPanel {
        anchors.fill: parent
        sourceItem: root.blurSource
        tint: "#68172F52"
        borderColor: "#70EAF4FF"
        cornerRadius: root.radius
        blurAmount: 0.72
    }

    function contextName() {
        return appName.length > 0 ? appName : "NeruOS"
    }

    function menusForContext() {
        if (appName === "NeruFiles")
            return ["File", "Edit", "View", "Go", "Window", "Help"]
        if (appName === "NeruCode")
            return ["File", "Edit", "Selection", "View", "Run", "Terminal", "Help"]
        if (appName === "NeruSettings")
            return ["NeruSettings", "Appearance", "Desktop", "System", "Help"]
        if (appName === "Steam")
            return ["Steam", "View", "Friends", "Games", "Help"]
        if (appName === "NeruStore")
            return ["Store", "Categories", "Library", "Help"]
        return ["NeruOS", "File", "View", "Workspace", "Window", "Help"]
    }

    function actionsForMenu(menuName) {
        if (menuName === "File")
            return ["New Window", "Choose Wallpaper"]
        if (menuName === "Edit")
            return ["Undo", "Redo", "Select All"]
        if (menuName === "View")
            return ["Toggle Navigation Rail", "Reset Wallpaper"]
        if (menuName === "Workspace")
            return ["General", "Coding", "Gaming", "Study", "Notifications", "User & Session"]
        if (menuName === "Window")
            return ["Window Overview", "Next Window", "Minimize Window",
                    "Maximize / Restore", "Snap Left", "Snap Right",
                    "Close Window", "Show Desktop",
                    "Move to General", "Move to Coding", "Move to Gaming", "Move to Study"]
        if (menuName === "Help")
            return ["About NeruOS", "Keyboard Shortcuts"]
        if (menuName === "NeruOS" || menuName === "NeruSettings")
            return ["About NeruOS", "NeruSettings", "NeruSearch"]
        if (menuName === "Apps" || menuName === "Store")
            return ["NeruFiles", "NeruCode", "Steam", "NeruSettings"]
        if (menuName === "Appearance" || menuName === "Desktop")
            return ["Choose Wallpaper", "Reset Wallpaper", "Toggle Navigation Rail"]
        if (menuName === "Games" || menuName === "Steam")
            return ["Steam Library", "Proton Compatibility", "Controller Setup"]
        if (menuName === "Run" || menuName === "Terminal")
            return ["NeruTerminal", "NeruCode"]
        return ["NeruSearch", "NeruFiles", "NeruSettings"]
    }

    function toggleMenu(menuName, anchorX) {
        if (activeMenu === menuName) {
            activeMenu = ""
            menuOptions = []
            return
        }
        activeMenu = menuName
        menuAnchorX = anchorX
        menuOptions = actionsForMenu(menuName)
    }

    function closeMenu() {
        activeMenu = ""
        menuOptions = []
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 11
        spacing: 7

        DesktopLogo {
            Layout.preferredWidth: 23
            Layout.preferredHeight: 23
        }

        Text {
            text: root.contextName()
            color: "#FFFFFF"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            Layout.maximumWidth: 112
            elide: Text.ElideRight
        }

        Rectangle {
            width: 1
            height: 19
            color: "#58D5E2F8"
        }

        Repeater {
            model: root.menusForContext()

            delegate: Item {
                required property string modelData
                width: menuLabel.implicitWidth + 10
                Layout.preferredHeight: 32

                Text {
                    id: menuLabel
                    anchors.centerIn: parent
                    text: modelData
                    color: (root.activeMenu === modelData || menuHover.containsMouse)
                           ? "#FFFFFF" : "#E0E9F9"
                    font.pixelSize: 11
                    font.weight: root.activeMenu === modelData ? Font.DemiBold : Font.Normal
                }

                MouseArea {
                    id: menuHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMenu(modelData, parent.x)
                }
            }
        }

        Item { Layout.fillWidth: true }

        Text {
            text: root.workspaceName
            color: "#D6E3F7"
            font.pixelSize: 9
            opacity: 0.82
            visible: root.width > 1120
        }

        ToolButton {
            id: updateButton
            text: root.updateState === "checking" ? "…" : "↻"
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.updateCheckRequested()
            ToolTip.text: root.updateCount > 0
                          ? root.updateCount + " update(s) available"
                          : "Check system updates"
            ToolTip.visible: hovered
            contentItem: Text {
                text: updateButton.text
                color: root.updateCount > 0 ? "#A8F0C8" : "#F0F5FF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: updateButton.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: "⌁"
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.centerRequested()
            ToolTip.text: "Wi-Fi · " + root.wifiStatus
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#F0F5FF"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: "ᛒ"
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.centerRequested()
            ToolTip.text: "Bluetooth · " + root.bluetoothStatus
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#F0F5FF"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: "◖"
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.centerRequested()
            ToolTip.text: "Sound · " + root.audioStatus
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#F0F5FF"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        Item {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28

            Text {
                anchors.centerIn: parent
                text: "▰"
                color: root.batteryStatus.indexOf("No battery") >= 0 ? "#8391AA" : "#F0F5FF"
                font.pixelSize: 14
            }

            HoverHandler { id: batteryHover }
            ToolTip.visible: batteryHover.hovered
            ToolTip.text: root.batteryStatus
        }

        ToolButton {
            text: "Search"
            Layout.preferredWidth: 48
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.searchRequested()
            ToolTip.text: "Open NeruSearch"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#FFFFFF"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: "☷"
            Layout.preferredWidth: 27
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.centerRequested()
            ToolTip.text: "Control Center"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#FFFFFF"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: root.notificationCount > 0 ? "●" : "◌"
            Layout.preferredWidth: 27
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.notificationRequested()
            ToolTip.text: root.notificationCount > 0
                          ? root.notificationCount + " notifications"
                          : "Notification Center"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#FFFFFF"
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        ToolButton {
            text: "●"
            Layout.preferredWidth: 26
            Layout.preferredHeight: 28
            padding: 0
            onClicked: root.sessionRequested()
            ToolTip.text: "User and session"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#DDE8F8"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#42FFFFFF" : "transparent"
            }
        }

        Text {
            text: root.clockText
            color: "#FFFFFF"
            font.pixelSize: 10
            font.weight: Font.DemiBold
            Layout.leftMargin: 2
        }
    }

    Rectangle {
        id: menuPopover
        x: Math.max(12, Math.min(root.menuAnchorX - 8, root.width - width - 12))
        y: parent.height + 8
        width: 218
        height: Math.max(46, root.menuOptions.length * 39 + 14)
        radius: 14
        color: "#EE142744"
        border.color: "#83D7E6FF"
        visible: root.activeMenu.length > 0
        z: 100

        Column {
            anchors.fill: parent
            anchors.margins: 7
            spacing: 2

            Repeater {
                model: root.menuOptions

                delegate: Rectangle {
                    required property string modelData
                    width: menuPopover.width - 14
                    height: 35
                    radius: 8
                    color: actionHover.containsMouse ? "#735D7CA7" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 11
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: "#F1F5FF"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: actionHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.menuActionRequested(modelData)
                            root.closeMenu()
                        }
                    }
                }
            }
        }
    }
}
