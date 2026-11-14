import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

ApplicationWindow {
    id: root
    width: 1440
    height: 900
    minimumWidth: 1024
    minimumHeight: 640
    visible: true
    visibility: Window.Maximized
    title: "NeruOS Nebula — Standalone Shell Prototype"
    color: "#080F1A"

    property string activeWorkspace: "General"
    property string activeApp: ""
    property bool centerOpen: false
    property bool searchOpen: false
    property bool railVisible: false
    property bool aboutOpen: false
    property string aboutHeading: "About NeruOS"
    property url customWallpaper: ""
    property date currentTime: new Date()
    property int brightness: 78
    property int volume: 64
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true

    readonly property color obsidian: "#080F1A"
    readonly property color midnight: "#151D2F"
    readonly property color cyan: "#54C8EB"
    readonly property color violet: "#9277E8"
    readonly property color aurora: "#E57BFF"
    readonly property color primaryText: "#F2F5FF"
    readonly property color secondaryText: "#AAB6D0"

    property var dockApps: [
        { name: "NeruSearch", glyph: "⌕", tint: "#4C8FEA" },
        { name: "NeruFiles", glyph: "▰", tint: "#54C8EB" },
        { name: "NeruBrowser", glyph: "◉", tint: "#55A9E8" },
        { name: "NeruTerminal", glyph: ">_", tint: "#354765" },
        { name: "NeruCode", glyph: "</>", tint: "#368ED8" },
        { name: "Steam", glyph: "✣", tint: "#23395F" },
        { name: "NeruGallery", glyph: "▧", tint: "#9277E8" },
        { name: "NeruSettings", glyph: "⚙", tint: "#71819E" }
    ]

    function openApp(name) {
        if (name === "NeruSearch") {
            searchOpen = !searchOpen
            centerOpen = false
            aboutOpen = false
            return
        }
        activeApp = name
        searchOpen = false
        centerOpen = false
        aboutOpen = false
        railVisible = false
    }

    function closeTransientUi() {
        centerOpen = false
        searchOpen = false
        aboutOpen = false
        activeApp = ""
    }

    function handleMenuAction(action) {
        if (["General", "Coding", "Gaming", "Study"].indexOf(action) >= 0) {
            activeWorkspace = action
            activeApp = ""
            return
        }

        if (action === "Choose Wallpaper") {
            wallpaperDialog.open()
            return
        }
        if (action === "Reset Wallpaper") {
            customWallpaper = ""
            return
        }
        if (action === "Toggle Navigation Rail") {
            railVisible = !railVisible
            return
        }
        if (action === "Close Window" || action === "Show Desktop") {
            activeApp = ""
            return
        }
        if (action === "About NeruOS") {
            aboutHeading = "About NeruOS"
            aboutOpen = true
            activeApp = ""
            return
        }
        if (action === "Keyboard Shortcuts") {
            aboutHeading = "Keyboard Shortcuts"
            aboutOpen = true
            activeApp = ""
            return
        }
        if (action === "New Window") {
            activeApp = "NeruFiles"
            return
        }
        if (action.length > 0)
            openApp(action)
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.currentTime = new Date()
    }

    FileDialog {
        id: wallpaperDialog
        title: "Choose a wallpaper for NeruOS"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.svg)"]
        onAccepted: root.customWallpaper = selectedFile
    }

    Image {
        anchors.fill: parent
        source: root.customWallpaper.toString().length > 0
                ? root.customWallpaper
                : "qrc:/assets/nebula-wallpaper.svg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#30050A18" }
            GradientStop { position: 0.58; color: "#18070D22" }
            GradientStop { position: 1.0; color: "#9A070D20" }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#10050A18"
    }

    // Standalone NeruBar: menu labels follow the active application context.
    NeruBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        z: 20
        appName: root.activeApp
        workspaceName: root.activeWorkspace
        clockText: Qt.formatDateTime(root.currentTime, "ddd, dd MMM  hh:mm")
        onSearchRequested: root.openApp("NeruSearch")
        onCenterRequested: {
            root.centerOpen = !root.centerOpen
            root.searchOpen = false
            root.aboutOpen = false
        }
        onMenuActionRequested: function(action) {
            root.handleMenuAction(action)
        }
    }

    // Calm desktop identity.
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 62
        anchors.top: topBar.bottom
        anchors.topMargin: 70
        spacing: 9
        z: 2

        Text {
            text: "Find your flow."
            color: "#F3F5FF"
            font.pixelSize: 38
            font.weight: Font.Light
        }
        Text {
            text: "A calm space for everything you create."
            color: "#D5DDF4"
            font.pixelSize: 15
        }
        Rectangle {
            width: 156
            height: 29
            radius: 15
            color: "#A50B1730"
            border.color: "#657C9CB9"
            Row {
                anchors.centerIn: parent
                spacing: 7
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.cyan
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "NEBULA EDITION"
                    color: "#D8E7FC"
                    font.pixelSize: 9
                    font.letterSpacing: 1.1
                    font.bold: true
                }
            }
        }
    }

    // Hidden navigation rail: a narrow hot-zone reveals it on demand.
    MouseArea {
        x: 0
        y: 82
        width: 8
        height: parent.height - 164
        hoverEnabled: true
        z: 30
        onEntered: root.railVisible = true
    }

    Rectangle {
        id: navigationRail
        x: 14
        y: 84
        width: 76
        height: Math.min(460, parent.height - 190)
        radius: 23
        color: "#E00B1428"
        border.color: "#607D99C2"
        visible: root.railVisible
        opacity: visible ? 1 : 0
        z: 31
        Behavior on opacity { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onExited: root.railVisible = false
        }

        Column {
            anchors.fill: parent
            anchors.topMargin: 14
            anchors.bottomMargin: 14
            spacing: 7

            Repeater {
                model: [
                    { label: "Home", glyph: "⌂", app: "" },
                    { label: "Files", glyph: "▰", app: "NeruFiles" },
                    { label: "Store", glyph: "◇", app: "NeruStore" },
                    { label: "Code", glyph: "</>", app: "NeruCode" },
                    { label: "Games", glyph: "✣", app: "Steam" },
                    { label: "Settings", glyph: "⚙", app: "NeruSettings" }
                ]

                delegate: Item {
                    required property var modelData
                    width: navigationRail.width
                    height: 66

                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Text {
                            text: modelData.glyph
                            color: "#D5DDF6"
                            font.pixelSize: 23
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: modelData.label
                            color: root.secondaryText
                            font.pixelSize: 9
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.app.length
                                    ? root.openApp(modelData.app)
                                    : root.closeTransientUi()
                    }
                }
            }
        }
    }

    // Workspace presets.
    Rectangle {
        id: workspaceStrip
        anchors.top: topBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 18
        width: 360
        height: 44
        radius: 15
        color: "#A90B1428"
        border.color: "#4D7185AE"
        z: 12

        Row {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 4

            Repeater {
                model: ["General", "Coding", "Gaming", "Study"]

                delegate: Rectangle {
                    required property string modelData
                    width: (workspaceStrip.width - 18) / 4
                    height: 34
                    radius: 11
                    color: root.activeWorkspace === modelData ? "#7E594AB4" : "transparent"
                    border.color: root.activeWorkspace === modelData ? "#9277E8" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: root.activeWorkspace === modelData ? "#FFFFFF" : root.secondaryText
                        font.pixelSize: 10
                        font.weight: root.activeWorkspace === modelData ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeWorkspace = modelData
                    }
                }
            }
        }
    }

    // Standalone floating NeruDock with pointer-driven magnification.
    NeruDock {
        id: dock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        z: 50
        applications: root.dockApps
        activeApplication: root.activeApp
        onApplicationRequested: function(appName) {
            root.openApp(appName)
        }
    }

    // NeruCenter — visual control prototype; no hardware APIs are connected yet.
    Rectangle {
        id: centerPanel
        width: 360
        height: 430
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.rightMargin: 18
        anchors.topMargin: 18
        radius: 22
        color: "#F00D172B"
        border.color: "#8495B9D5"
        visible: root.centerOpen
        z: 60

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 19
            spacing: 13

            RowLayout {
                Text {
                    text: "NeruCenter"
                    color: root.primaryText
                    font.pixelSize: 19
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: "×"
                    onClicked: root.centerOpen = false
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { label: "Wi-Fi", detail: root.wifiEnabled ? "Demo: Connected" : "Demo: Off", key: "wifi" },
                        { label: "Bluetooth", detail: root.bluetoothEnabled ? "Demo: Enabled" : "Demo: Off", key: "bluetooth" },
                        { label: "Display", detail: "Night Light (demo)", key: "display" },
                        { label: "Sound", detail: root.volume + "% (demo)", key: "sound" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 13
                        color: "#B8233553"
                        border.color: "#456A84AA"

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 13
                            spacing: 4
                            Text {
                                text: modelData.label
                                color: root.primaryText
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: modelData.detail
                                color: root.secondaryText
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.key === "wifi")
                                    root.wifiEnabled = !root.wifiEnabled
                                if (modelData.key === "bluetooth")
                                    root.bluetoothEnabled = !root.bluetoothEnabled
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#52627E"
            }

            RowLayout {
                Text { text: "Brightness (demo)"; color: root.secondaryText; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: root.brightness + "%"; color: root.primaryText; font.pixelSize: 11 }
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.brightness
                onMoved: root.brightness = Math.round(value)
            }

            RowLayout {
                Text { text: "Volume (demo)"; color: root.secondaryText; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: root.volume + "%"; color: root.primaryText; font.pixelSize: 11 }
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.volume
                onMoved: root.volume = Math.round(value)
            }

            Item { Layout.fillHeight: true }
            Text {
                text: "Prototype values only — hardware controls are not connected"
                color: "#778AA9"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // NeruSearch — local UI demonstration.
    Rectangle {
        id: searchPanel
        width: Math.min(610, root.width - 40)
        height: 340
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topBar.bottom
        anchors.topMargin: 24
        radius: 23
        color: "#F00D172B"
        border.color: "#8298B9D8"
        visible: root.searchOpen
        z: 61

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 13

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search apps, files, settings..."
                color: root.primaryText
                placeholderTextColor: "#8292AD"
                font.pixelSize: 15
                background: Rectangle {
                    radius: 13
                    color: "#B91A2944"
                    border.color: "#8F9277E8"
                }
                onAccepted: root.openApp(text.trim().length ? text.trim() : "NeruFiles")
            }

            Text {
                text: "SUGGESTED APPS"
                color: root.secondaryText
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.4
            }

            Repeater {
                model: ["NeruFiles", "NeruSettings", "NeruTerminal", "NeruCode", "Steam"]

                delegate: Rectangle {
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 11
                    color: rowHover.containsMouse ? "#9C344767" : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        spacing: 10
                        Text {
                            text: "◈"
                            color: root.cyan
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData
                            color: root.primaryText
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openApp(modelData)
                    }
                }
            }

            Item { Layout.fillHeight: true }
            Text {
                text: "Alt + Space opens search · Esc closes"
                color: "#7183A4"
                font.pixelSize: 10
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // Demo application window. Opening an app changes NeruBar's menu context.
    Rectangle {
        id: appWindow
        width: Math.min(790, root.width - 100)
        height: Math.min(530, root.height - 190)
        anchors.centerIn: parent
        radius: 20
        color: "#F00E1729"
        border.color: "#8191AFCB"
        visible: root.activeApp.length > 0
        z: 62

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 54
                color: "#C7192943"
                radius: 20

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 16
                    Row {
                        spacing: 7
                        Repeater {
                            model: ["#FF687A", "#F2C56A", "#61D69B"]
                            delegate: Rectangle {
                                required property string modelData
                                width: 10
                                height: 10
                                radius: 5
                                color: modelData
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.activeApp
                        color: root.primaryText
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    ToolButton {
                        text: "×"
                        onClicked: root.activeApp = ""
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3E59718F"
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 18

                    Text {
                        text: root.activeApp === "NeruSettings" ? "Personalize your space"
                              : root.activeApp === "NeruFiles" ? "Your files, beautifully organized"
                              : root.activeApp === "NeruStore" ? "Discover your next app"
                              : root.activeApp === "Steam" ? "Your game library"
                              : root.activeApp === "NeruCode" ? "Create something new"
                              : "Welcome to " + root.activeApp
                        color: root.primaryText
                        font.pixelSize: 23
                        font.weight: Font.Medium
                    }

                    Text {
                        text: root.activeApp === "NeruSettings" ? "Make Nebula feel like yours."
                              : root.activeApp === "NeruFiles" ? "A clean starting point for folders and projects."
                              : root.activeApp === "NeruStore" ? "A concept storefront for the NeruOS ecosystem."
                              : root.activeApp === "Steam" ? "Gaming tools and compatible titles will live here."
                              : "This is an interactive shell prototype, not a system service yet."
                        color: root.secondaryText
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        visible: root.activeApp === "NeruSettings"
                        Button {
                            text: "Choose wallpaper"
                            onClicked: wallpaperDialog.open()
                        }
                        Button {
                            text: "Restore Nebula"
                            onClicked: root.customWallpaper = ""
                        }
                    }

                    GridLayout {
                        visible: root.activeApp === "NeruFiles"
                        columns: 3
                        columnSpacing: 14
                        rowSpacing: 14

                        Repeater {
                            model: ["Documents", "Downloads", "Pictures", "Projects", "Music", "Videos"]
                            delegate: Rectangle {
                                required property string modelData
                                Layout.preferredWidth: 145
                                Layout.preferredHeight: 105
                                radius: 14
                                color: "#A21A2943"
                                border.color: "#52617D9B"
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "▰"
                                        color: root.cyan
                                        font.pixelSize: 31
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: modelData
                                        color: root.primaryText
                                        font.pixelSize: 11
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        visible: root.activeApp === "NeruStore" || root.activeApp === "Steam"
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            model: root.activeApp === "Steam"
                                    ? ["Steam Library", "Proton Compatibility", "Controller Setup", "Game Settings"]
                                    : ["NeruCode", "NeruGallery", "NeruTerminal", "NeruSpace"]
                            delegate: Rectangle {
                                required property string modelData
                                Layout.preferredWidth: 230
                                Layout.preferredHeight: 75
                                radius: 13
                                color: "#A21A2943"
                                border.color: "#52617D9B"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: root.primaryText
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                    Text {
                        text: "NeruOS Nebula Prototype — UI preview only"
                        color: "#778AA9"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    Rectangle {
        id: aboutDialog
        width: Math.min(420, root.width - 40)
        height: aboutHeading === "About NeruOS" ? 250 : 300
        anchors.centerIn: parent
        radius: 22
        color: "#F00D172B"
        border.color: "#8298B9D8"
        visible: root.aboutOpen
        z: 70

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            Image {
                source: "qrc:/assets/logo-mark.svg"
                sourceSize.width: 54
                sourceSize.height: 54
                Layout.preferredWidth: 54
                Layout.preferredHeight: 54
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: root.aboutHeading
                color: root.primaryText
                font.pixelSize: 21
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: root.aboutHeading === "About NeruOS"
                      ? "NeruOS Nebula — standalone shell prototype. Built with Qt 6 and QML. This is not a bootable OS image."
                      : "Alt + Space  Open NeruSearch\nEsc  Close overlays\nMove pointer to the left edge  Reveal navigation rail\nHover over NeruDock icons  Magnify"
                color: root.secondaryText
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Item { Layout.fillHeight: true }
            Button {
                text: "Close"
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.aboutOpen = false
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeTransientUi()
    }

    Shortcut {
        sequence: "Alt+Space"
        onActivated: {
            root.searchOpen = !root.searchOpen
            root.centerOpen = false
            root.aboutOpen = false
            if (root.searchOpen)
                searchField.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: "Ctrl+Alt+1"
        onActivated: root.activeWorkspace = "General"
    }
    Shortcut {
        sequence: "Ctrl+Alt+2"
        onActivated: root.activeWorkspace = "Coding"
    }
    Shortcut {
        sequence: "Ctrl+Alt+3"
        onActivated: root.activeWorkspace = "Gaming"
    }
    Shortcut {
        sequence: "Ctrl+Alt+4"
        onActivated: root.activeWorkspace = "Study"
    }
}
