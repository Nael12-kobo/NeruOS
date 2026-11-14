import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 54
    radius: 17
    color: "#D90A1222"
    border.color: "#557B96C0"
    border.width: 1

    property string appName: ""
    property string workspaceName: "General"
    property string clockText: ""
    property string dateText: ""
    property string activeMenu: ""
    property real menuAnchorX: 24
    property var menuOptions: []

    signal searchRequested()
    signal centerRequested()
    signal menuActionRequested(string action)

    function contextName() {
        return appName.length > 0 ? appName : "Desktop"
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
            return ["New Window", "Choose Wallpaper", "Close Window"]
        if (menuName === "Edit")
            return ["Undo", "Redo", "Select All"]
        if (menuName === "View")
            return ["Toggle Navigation Rail", "Reset Wallpaper"]
        if (menuName === "Workspace")
            return ["General", "Coding", "Gaming", "Study"]
        if (menuName === "Window")
            return ["Close Window", "Show Desktop"]
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
        anchors.leftMargin: 15
        anchors.rightMargin: 13
        spacing: 9

        Image {
            source: "qrc:/assets/logo-mark.svg"
            sourceSize.width: 27
            sourceSize.height: 27
            Layout.preferredWidth: 27
            Layout.preferredHeight: 27
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: root.contextName()
            color: "#F2F5FF"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            Layout.maximumWidth: 112
            elide: Text.ElideRight
        }

        Rectangle { width: 1; height: 23; color: "#52627E" }

        Repeater {
            model: root.menusForContext()

            delegate: Item {
                required property string modelData
                width: menuLabel.implicitWidth + 8
                Layout.preferredHeight: 34

                Text {
                    id: menuLabel
                    anchors.centerIn: parent
                    text: modelData
                    color: (root.activeMenu === modelData || menuHover.containsMouse) ? "#FFFFFF" : "#AAB6D0"
                    font.pixelSize: 11
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
            color: "#D8E4FA"
            font.pixelSize: 10
            font.weight: Font.DemiBold
            visible: root.width > 1040
        }

        ToolButton {
            text: "◈"
            onClicked: root.centerRequested()
            ToolTip.text: "NeruCenter"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#AAB6D0"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 8; color: parent.hovered ? "#40506E91" : "transparent" }
        }

        ToolButton {
            text: "◖"
            onClicked: root.centerRequested()
            ToolTip.text: "Sound and system status"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#AAB6D0"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 8; color: parent.hovered ? "#40506E91" : "transparent" }
        }

        ToolButton {
            text: "⌕"
            onClicked: root.searchRequested()
            ToolTip.text: "NeruSearch"
            ToolTip.visible: hovered
            contentItem: Text {
                text: parent.text
                color: "#F2F5FF"
                font.pixelSize: 19
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 8; color: parent.hovered ? "#40506E91" : "transparent" }
        }

        Text {
            text: root.clockText
            color: "#F2F5FF"
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }
    }

    Rectangle {
        id: menuPopover
        x: Math.max(12, Math.min(root.menuAnchorX - 8, root.width - width - 12))
        y: parent.height + 8
        width: 218
        height: Math.max(46, root.menuOptions.length * 39 + 14)
        radius: 14
        color: "#F0101B31"
        border.color: "#8194B4D0"
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
                    color: actionHover.containsMouse ? "#725A6E9A" : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 11
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: "#EAF0FF"
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

    MouseArea {
        anchors.fill: parent
        visible: false
        onClicked: root.closeMenu()
    }
}
