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
    title: "NeruOS Nebula — Desktop Prototype"
    color: "#080F1A"

    property string activeWorkspace: "General"
    property string activeApp: ""
    property bool centerOpen: false
    property bool searchOpen: false
    property bool railVisible: false
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
            searchOpen = true
            centerOpen = false
            return
        }
        activeApp = name
        searchOpen = false
        centerOpen = false
        railVisible = false
    }

    function closeTransientUi() {
        centerOpen = false
        searchOpen = false
        activeApp = ""
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

    // NeruBar: top status and application area.
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        height: 52
        radius: 17
        color: "#D90A1222"
        border.color: "#557B96C0"
        border.width: 1
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 14
            spacing: 13

            Image {
                source: "qrc:/assets/logo-mark.svg"
                sourceSize.width: 28
                sourceSize.height: 28
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                fillMode: Image.PreserveAspectFit
            }
            Text {
                text: "NeruOS"
                color: root.primaryText
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Rectangle { width: 1; height: 24; color: "#52627E" }
            Repeater {
                model: ["File", "Edit", "View", "Apps", "Window", "Help"]
                delegate: Text {
                    required property string modelData
                    text: modelData
                    color: root.secondaryText
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.activeWorkspace + " Space"
                color: "#DBE5FA"
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Text { text: "◈"; color: root.secondaryText; font.pixelSize: 17 }
            Text { text: "◖"; color: root.secondaryText; font.pixelSize: 17 }
            Text { text: "▰"; color: root.secondaryText; font.pixelSize: 14 }
            ToolButton {
                text: "⌕"
                font.pixelSize: 20
                onClicked: { root.searchOpen = !root.searchOpen; root.centerOpen = false }
                background: Rectangle { radius: 9; color: parent.hovered ? "#40506E91" : "transparent" }
                contentItem: Text {
                    text: parent.text
                    color: root.primaryText
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            ToolButton {
                text: "◌"
                font.pixelSize: 19
                onClicked: { root.centerOpen = !root.centerOpen; root.searchOpen = false }
                background: Rectangle { radius: 9; color: parent.hovered ? "#40506E91" : "transparent" }
                contentItem: Text {
                    text: parent.text
                    color: root.primaryText
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text {
                text: Qt.formatDateTime(root.currentTime, "ddd, dd MMM  hh:mm")
                color: root.primaryText
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 62
        anchors.top: topBar.bottom
        anchors.topMargin: 64
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
                    width: 6; height: 6; radius: 3
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

    // Hidden navigation rail: reveal from the far-left edge.
    MouseArea {
        x: 0
        y: 82
        width: 7
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
                    { label: "Games", glyph: "✣", app: "Steam" }
                ]
                delegate: Item {
                    required property var modelData
                    width: navigationRail.width
                    height: 74
                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Text {
                            text: modelData.glyph
                            color: "#D5DDF6"
                            font.pixelSize: 25
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
                        onClicked: modelData.app.length ? root.openApp(modelData.app) : root.closeTransientUi()
                    }
                }
            }
        }
    }

    // Workspace selector.
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
                        onClicked: root.activeWorkspace = modelData
                    }
                }
            }
        }
    }

    // Floating dock.
    Rectangle {
        id: dock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        width: Math.min(700, root.width - 48)
        height: 78
        radius: 24
        color: "#E00E1A30"
        border.color: "#7792B5D0"
        border.width: 1
        z: 50
        Row {
            anchors.centerIn: parent
            spacing: 9
            Repeater {
                model: root.dockApps
                delegate: Item {
                    required property var modelData
                    width: 58
                    height: 58
                    Rectangle {
                        anchors.fill: parent
                        radius: 17
                        color: modelData.tint
                        border.color: "#72D6E4FA"
                        border.width: 1
                        gradient: Gradient {
                            GradientStop { position: 0; color: Qt.lighter(modelData.tint, 1.35) }
                            GradientStop { position: 1; color: modelData.tint }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.glyph
                            color: "#F7FAFF"
                            font.pixelSize: modelData.glyph === "</>" ? 15 : 24
                            font.bold: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.openApp(modelData.name)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    // NeruCenter quick settings. Values are UI-only in this prototype.
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
                Text { text: "NeruCenter"; color: root.primaryText; font.pixelSize: 19; font.bold: true }
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: "×"
                    onClicked: root.centerOpen = false
                    contentItem: Text {
                        text: parent.text; color: root.secondaryText
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true
                Repeater {
                    model: [
                        { label: "Wi-Fi", detail: root.wifiEnabled ? "Connected" : "Off", key: "wifi" },
                        { label: "Bluetooth", detail: root.bluetoothEnabled ? "Enabled" : "Off", key: "bluetooth" },
                        { label: "Display", detail: "Night Light", key: "display" },
                        { label: "Sound", detail: root.volume + "%", key: "sound" }
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
                            Text { text: modelData.label; color: root.primaryText; font.pixelSize: 12; font.bold: true }
                            Text { text: modelData.detail; color: root.secondaryText; font.pixelSize: 10 }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.key === "wifi") root.wifiEnabled = !root.wifiEnabled
                                if (modelData.key === "bluetooth") root.bluetoothEnabled = !root.bluetoothEnabled
                            }
                        }
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#52627E" }
            RowLayout {
                Text { text: "Brightness"; color: root.secondaryText; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: root.brightness + "%"; color: root.primaryText; font.pixelSize: 11 }
            }
            Slider {
                Layout.fillWidth: true
                from: 0; to: 100
                value: root.brightness
                onMoved: root.brightness = Math.round(value)
            }
            RowLayout {
                Text { text: "Volume"; color: root.secondaryText; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: root.volume + "%"; color: root.primaryText; font.pixelSize: 11 }
            }
            Slider {
                Layout.fillWidth: true
                from: 0; to: 100
                value: root.volume
                onMoved: root.volume = Math.round(value)
            }
            Item { Layout.fillHeight: true }
            Text {
                text: "Prototype controls only — no hardware changes"
                color: "#778AA9"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Universal application search.
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
                model: ["NeruFiles", "NeruSettings", "NeruTerminal", "Steam"]
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
                        Text { text: "◈"; color: root.cyan; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: modelData; color: root.primaryText; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.openApp(modelData)
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Text {
                text: "ESC closes search"
                color: "#7183A4"
                font.pixelSize: 10
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // Demo application windows: visual previews only.
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
                                width: 10; height: 10; radius: 5
                                color: modelData
                            }
                        }
                    }
                    Text {
                        text: root.activeApp
                        color: root.primaryText
                        font.pixelSize: 13
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Item { Layout.fillWidth: true }
                    ToolButton {
                        text: "×"
                        onClicked: root.activeApp = ""
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#3E59718F" }
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
                              : "This is an interactive UI prototype, not a system service yet."
                        color: root.secondaryText
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        visible: root.activeApp === "NeruSettings"
                        Button { text: "Choose wallpaper"; onClicked: wallpaperDialog.open() }
                        Button { text: "Restore Nebula"; onClicked: root.customWallpaper = "" }
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
                                    Text { text: "▰"; color: root.cyan; font.pixelSize: 31; anchors.horizontalCenter: parent.horizontalCenter }
                                    Text { text: modelData; color: root.primaryText; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
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

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeTransientUi()
    }
}
