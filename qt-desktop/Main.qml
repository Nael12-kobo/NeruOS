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
    // NeruOS is the desktop session itself, not a decorated application window.
    // Fullscreen + frameless removes the labwc title bar and window controls.
    flags: Qt.Window | Qt.FramelessWindowHint
    visibility: Window.FullScreen
    title: "NeruOS"
    color: "#080F1A"

    property string activeWorkspace: "NeruSpace"
    property string activeApp: ""
    property bool centerOpen: false
    property bool searchOpen: false
    property bool railVisible: false
    property bool aboutOpen: false
    property bool updatePanelOpen: false
    property bool notificationCenterOpen: false
    property bool sessionPanelOpen: false
    property string pendingDockAlias: ""
    property string aboutHeading: "About NeruOS"
    property date currentTime: new Date()
    property int pendingVolume: 64
    property string notificationText: ""

    WallpaperManager {
        id: wallpaperManager
    }

    readonly property color obsidian: "#080F1A"
    readonly property color midnight: "#151D2F"
    readonly property color cyan: ["#54C8EB", "#6B8AFD", "#A78BFA", "#E879F9"][desktopSettings.accentIndex]
    readonly property color violet: "#9277E8"
    readonly property color aurora: "#E57BFF"
    readonly property color primaryText: "#F2F5FF"
    readonly property color secondaryText: "#AAB6D0"

    property var dockApps: []

    function dockDisplayName(aliasKey) {
        const names = {
            "nerufiles": "NeruFiles",
            "nerubrowser": "NeruBrowser",
            "neruterminal": "NeruTerminal",
            "nerucode": "NeruCode",
            "steam": "Steam",
            "nerugallery": "NeruGallery"
        }
        return names[aliasKey] || ""
    }

    readonly property var dockRunningApplications: {
        const aliases = windowManager.available
                     ? appCatalog.aliasesForWindowAppIds(windowManager.runningAppIds)
                     : appCatalog.runningAliases
        return aliases.map(function(aliasKey) { return root.dockDisplayName(aliasKey) })
                      .filter(function(name) { return name.length > 0 })
    }

    readonly property string dockActiveApplication: root.activeApp.length > 0
        ? root.activeApp
        : root.dockDisplayName(appCatalog.aliasForWindowAppId(windowManager.activeAppId))

    ListModel {
        id: notificationModel
    }

    function rebuildDockApps() {
        const iconMap = {
            "NeruFiles": "qrc:/assets/icons/files.png",
            "NeruBrowser": "qrc:/assets/icons/browser.png",
            "NeruTerminal": "qrc:/assets/icons/terminal.png",
            "NeruCode": "qrc:/assets/icons/code.png",
            "NeruSettings": "qrc:/assets/icons/settings.png",
            "NeruSearch": "qrc:/assets/icons/apps.png",
            "Steam": "qrc:/assets/icons/games.png"
        }
        dockApps = desktopSettings.pinnedApps.map(function(alias) {
            return { name: alias, icon: iconMap[alias] || "qrc:/assets/icons/apps.png" }
        })
    }

    function applySavedWallpaper() {
        if (desktopSettings.wallpaperPath.length > 0)
            wallpaperManager.setWallpaper(desktopSettings.wallpaperPath)
        else
            wallpaperManager.resetWallpaper()
    }

    Component.onCompleted: {
        rebuildDockApps()
        applySavedWallpaper()
    }

    Connections {
        target: desktopSettings
        function onWallpaperPathChanged() {
            root.applySavedWallpaper()
        }
    }

    Connections {
        target: desktopSettings
        function onPinnedAppsChanged() {
            root.rebuildDockApps()
        }
    }

    function openApp(name) {
        centerOpen = false
        searchOpen = false
        aboutOpen = false
        updatePanelOpen = false
        notificationCenterOpen = false
        sessionPanelOpen = false
        railVisible = false

        if (name === "NeruSearch") {
            searchOpen = true
            searchField.forceActiveFocus()
            return
        }

        if (name === "NeruFiles" || name === "NeruSettings") {
            activeApp = name
            return
        }

        activeApp = ""

        // Prefer the compositor's real toplevel list. This activates the
        // existing app window directly instead of opening another copy.
        if (windowManager.available) {
            if (windowManager.activateFirstMatchingAppId(appCatalog.windowIdsForAlias(name)))
                return
        } else if (appCatalog.runningAliases.indexOf(name.toLowerCase()) >= 0) {
            // Older / unsupported sessions retain the process-based fallback.
            workspaceController.showWindowMenu()
            return
        }

        pendingDockAlias = name
        if (!appCatalog.launchAlias(name))
            pendingDockAlias = ""
    }

    function closeTransientUi() {
        centerOpen = false
        searchOpen = false
        aboutOpen = false
        updatePanelOpen = false
        notificationCenterOpen = false
        sessionPanelOpen = false
        activeApp = ""
    }

    function launchDockApp(alias) {
        openApp(alias)
    }

    function appendNotification(application, title, message, timeText, bridgeId) {
        const itemId = bridgeId || 0
        let replaced = false
        if (itemId > 0) {
            for (let i = 0; i < notificationModel.count; ++i) {
                if (notificationModel.get(i).id === itemId) {
                    notificationModel.set(i, {
                        id: itemId,
                        application: application || "Application",
                        title: title || application || "Notification",
                        message: message || "",
                        timeText: timeText || Qt.formatDateTime(new Date(), "hh:mm")
                    })
                    replaced = true
                    break
                }
            }
        }
        if (!replaced) {
            notificationModel.append({
                id: itemId,
                application: application || "Application",
                title: title || application || "Notification",
                message: message || "",
                timeText: timeText || Qt.formatDateTime(new Date(), "hh:mm")
            })
        }
        while (notificationModel.count > 30)
            notificationModel.remove(0)
        notificationText = (title || application || "Notification")
                         + (message ? ": " + message : "")
        notificationTimer.restart()
    }

    function showNotification(message) {
        const now = new Date()
        appendNotification("NeruOS", "NeruOS", message,
                           Qt.formatDateTime(now, "hh:mm"), 0)
    }

    Connections {
        target: notificationBridge
        function onNotificationReceived(id, application, title, message, timeText) {
            root.appendNotification(application, title, message, timeText, id)
        }
        function onNotificationClosed(id, reason) {
            for (let i = notificationModel.count - 1; i >= 0; --i) {
                if (notificationModel.get(i).id === id)
                    notificationModel.remove(i)
            }
        }
    }

    Connections {
        target: workspaceController
        function onActionFailed(message) {
            root.showNotification(message)
        }
    }

    function handleMenuAction(action) {
        const workspaces = ["General", "Coding", "Gaming", "Study"]
        const workspaceIndex = workspaces.indexOf(action)
        if (workspaceIndex >= 0) {
            if (workspaceController.switchTo(workspaceIndex + 1)) {
                activeWorkspace = action
                showNotification("Switched to " + action)
            }
            return
        }

        if (action === "Window Overview") {
            workspaceController.showWindowMenu()
            return
        }
        if (action === "Next Window") {
            workspaceController.nextWindow()
            return
        }
        if (action === "Minimize Window") {
            workspaceController.minimizeActive()
            return
        }
        if (action === "Maximize / Restore") {
            workspaceController.toggleMaximize()
            return
        }
        if (action === "Snap Left") {
            workspaceController.snapActiveLeft()
            return
        }
        if (action === "Snap Right") {
            workspaceController.snapActiveRight()
            return
        }
        if (action === "Close Window") {
            workspaceController.closeActive()
            return
        }
        const moveWorkspace = ["Move to General", "Move to Coding",
                              "Move to Gaming", "Move to Study"].indexOf(action)
        if (moveWorkspace >= 0) {
            workspaceController.moveActiveTo(moveWorkspace + 1)
            return
        }

        if (action === "Choose Wallpaper") {
            wallpaperDialog.open()
            return
        }
        if (action === "Reset Wallpaper") {
            desktopSettings.resetWallpaper()
            return
        }
        if (action === "Toggle Navigation Rail") {
            railVisible = !railVisible
            return
        }
        if (action === "Show Desktop") {
            workspaceController.showDesktop()
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
            openApp("NeruFiles")
            return
        }
        if (action === "Notifications") {
            notificationCenterOpen = true
            return
        }
        if (action === "User & Session") {
            sessionPanelOpen = true
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

    Timer {
        id: notificationTimer
        interval: 4200
        onTriggered: root.notificationText = ""
    }

    Timer {
        id: volumeDebounce
        interval: 180
        repeat: false
        onTriggered: systemControls.setVolume(root.pendingVolume)
    }

    Connections {
        target: systemControls

        function onOperationFailed(message) {
            root.showNotification(message)
        }
    }

    Connections {
        target: fileSystemModel
        function onOperationFailed(message) {
            root.showNotification(message)
        }
    }

    Connections {
        target: sessionManager
        function onActionFailed(action, message) {
            root.showNotification(action + ": " + message)
        }
        function onActionStarted(action) {
            if (action !== "logout" && action !== "restart" && action !== "poweroff")
                root.showNotification(action + " requested")
        }
    }

    Timer {
        id: initialUpdateCheck
        interval: 45000
        repeat: false
        running: true
        onTriggered: updateChecker.checkNow()
    }

    Connections {
        target: updateChecker

        function onCheckFinished(updatesAvailable, count) {
            if (updatesAvailable)
                root.showNotification(updateChecker.message)
        }
    }

    Connections {
        target: appCatalog

        function onLaunchStarted(displayName, appId) {
            root.pendingDockAlias = ""
            root.searchOpen = false
            root.centerOpen = false
            root.showNotification("Launched " + displayName)
        }

        function onLaunchError(displayName, message) {
            root.pendingDockAlias = ""
            root.showNotification(displayName + ": " + message)
        }
    }

    FileDialog {
        id: wallpaperDialog
        title: "Choose a wallpaper for NeruOS"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.svg)"]
        onAccepted: desktopSettings.setWallpaperPath(selectedFile.toString())
    }

    DesktopBackground {
        id: desktopBackground
        anchors.fill: parent
        wallpaperSource: wallpaperManager.currentWallpaper
    }

    // Standalone NeruBar: menu labels follow the active application context.
    NeruBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        z: 20
        blurSource: desktopBackground
        appName: root.activeApp
        workspaceName: root.activeWorkspace
        clockText: Qt.formatDateTime(root.currentTime, "ddd, dd MMM  hh:mm")
        wifiStatus: systemControls.wifiStatus
        bluetoothStatus: systemControls.bluetoothStatus
        audioStatus: systemControls.audioStatus
        batteryStatus: systemControls.batteryStatus
        notificationCount: notificationModel.count
        updateCount: updateChecker.updateCount
        updateState: updateChecker.state
        onSearchRequested: root.openApp("NeruSearch")
        onUpdateCheckRequested: {
            root.updatePanelOpen = true
            root.centerOpen = false
            root.searchOpen = false
            root.aboutOpen = false
            updateChecker.checkNow()
        }
        onCenterRequested: {
            root.centerOpen = !root.centerOpen
            root.searchOpen = false
            root.aboutOpen = false
            root.updatePanelOpen = false
            root.notificationCenterOpen = false
            root.sessionPanelOpen = false
        }
        onNotificationRequested: {
            root.notificationCenterOpen = !root.notificationCenterOpen
            root.centerOpen = false
            root.searchOpen = false
            root.sessionPanelOpen = false
        }
        onSessionRequested: {
            root.sessionPanelOpen = !root.sessionPanelOpen
            root.centerOpen = false
            root.searchOpen = false
            root.notificationCenterOpen = false
        }
        onMenuActionRequested: function(action) {
            root.handleMenuAction(action)
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
                    { label: "Home", icon: "qrc:/assets/icons/home.png", app: "" },
                    { label: "Files", icon: "qrc:/assets/icons/files.png", app: "NeruFiles" },
                    { label: "Store", icon: "qrc:/assets/icons/apps.png", app: "NeruStore" },
                    { label: "Code", icon: "qrc:/assets/icons/code.png", app: "NeruCode" },
                    { label: "Games", icon: "qrc:/assets/icons/games.png", app: "Steam" },
                    { label: "Settings", icon: "qrc:/assets/icons/settings.png", app: "NeruSettings" }
                ]

                delegate: Item {
                    required property var modelData
                    width: navigationRail.width
                    height: 66

                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Image {
                            source: modelData.icon
                            sourceSize.width: 96
                            sourceSize.height: 96
                            width: 30
                            height: 30
                            fillMode: Image.PreserveAspectFit
                            smooth: true
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

    // Floating glass dock. Every app icon is an independent PNG file.
    ApplicationDock {
        id: dock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        z: 50
        blurSource: desktopBackground
        applications: root.dockApps
        runningApplications: root.dockRunningApplications
        activeApplication: root.dockActiveApplication
        onApplicationRequested: function(appName) {
            root.launchDockApp(appName)
        }
    }

    // NeruCenter — hardware/session controls backed by SystemControls.
    Rectangle {
        id: centerPanel
        width: 348
        height: 448
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.rightMargin: 12
        anchors.topMargin: 12
        radius: 24
        color: "transparent"
        border.color: "transparent"
        border.width: 0
        visible: root.centerOpen
        z: 60

        GlassPanel {
            anchors.fill: parent
            sourceItem: desktopBackground
            tint: "#C9EAF2FC"
            borderColor: "#E8FFFFFF"
            cornerRadius: centerPanel.radius
            blurAmount: 0.86
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 19
            spacing: 13

            RowLayout {
                Text {
                    text: "Control Center"
                    color: "#1D2C45"
                    font.pixelSize: 17
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
                        { label: "Wi-Fi", detail: systemControls.wifiStatus,
                          key: "wifi", available: systemControls.wifiAvailable,
                          active: systemControls.wifiEnabled },
                        { label: "Bluetooth", detail: systemControls.bluetoothStatus,
                          key: "bluetooth", available: systemControls.bluetoothAvailable && systemControls.bluetoothKnown,
                          active: systemControls.bluetoothPowered },
                        { label: "Display", detail: systemControls.brightnessStatus,
                          key: "display", available: systemControls.brightnessAvailable,
                          active: systemControls.brightnessWritable },
                        { label: "Sound", detail: systemControls.audioStatus,
                          key: "sound", available: systemControls.audioAvailable,
                          active: systemControls.audioAvailable && !systemControls.audioMuted },
                        { label: "Battery", detail: systemControls.batteryStatus,
                          key: "battery", available: systemControls.batteryAvailable,
                          active: systemControls.batteryStatus.toLowerCase().indexOf("charging") >= 0 }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 13
                        color: !modelData.available ? "#78E9EEF6"
                             : (modelData.active ? "#D6FFFFFF" : "#A7FFFFFF")
                        border.color: "#68FFFFFF"
                        opacity: modelData.available ? 1.0 : 0.78

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 13
                            spacing: 4
                            Text {
                                text: modelData.label
                                color: "#1C2B44"
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: modelData.detail
                                color: "#687991"
                                font.pixelSize: 9
                                elide: Text.ElideRight
                                width: parent.parent.width - 24
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: (modelData.key === "wifi" && modelData.available
                                      && systemControls.wifiKnown && !systemControls.wifiBusy)
                                      || (modelData.key === "bluetooth" && modelData.available
                                      && !systemControls.bluetoothBusy)
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (modelData.key === "wifi")
                                    systemControls.toggleWifi()
                                else if (modelData.key === "bluetooth")
                                    systemControls.toggleBluetooth()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#56708CA8"
            }

            RowLayout {
                Text { text: "Brightness"; color: "#52647D"; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text {
                    text: systemControls.brightnessStatus
                    color: "#1C2B44"
                    font.pixelSize: 10
                }
            }
            Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                enabled: systemControls.brightnessWritable
                onMoved: systemControls.setBrightness(Math.round(value))
                Binding {
                    target: brightnessSlider
                    property: "value"
                    value: systemControls.brightness
                    when: !brightnessSlider.pressed
                }
                ToolTip.text: enabled ? "Adjust display brightness"
                                      : "No writable backlight device is available to this user"
                ToolTip.visible: hovered
            }

            RowLayout {
                Text { text: "Volume"; color: "#52647D"; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: systemControls.audioMuted ? "Unmute" : "Mute"
                    enabled: systemControls.audioAvailable && !systemControls.audioBusy
                    onClicked: systemControls.toggleMute()
                    ToolTip.text: "Toggle output mute"
                    ToolTip.visible: hovered
                }
                Text {
                    text: systemControls.audioStatus
                    color: "#1C2B44"
                    font.pixelSize: 10
                }
            }
            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                enabled: systemControls.audioAvailable && systemControls.audioKnown
                Binding {
                    target: volumeSlider
                    property: "value"
                    value: systemControls.volume
                    when: !volumeSlider.pressed
                }
                onMoved: {
                    root.pendingVolume = Math.round(value)
                    volumeDebounce.restart()
                }
                ToolTip.text: enabled ? "Adjust system output volume"
                                      : "No default audio output is available"
                ToolTip.visible: hovered
            }

            Item { Layout.fillHeight: true }
            Text {
                text: "Wi-Fi uses NetworkManager · Sound uses the active audio session"
                color: "#71829A"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // NeruSearch — native Linux application catalog backed by GIO.
    Rectangle {
        id: searchPanel
        width: Math.min(760, root.width - 40)
        height: Math.min(590, root.height - 150)
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
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "NeruSearch"
                    color: root.primaryText
                    font.pixelSize: 19
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: appCatalog.count + " installed apps"
                    color: root.secondaryText
                    font.pixelSize: 10
                }
                ToolButton {
                    text: "↻"
                    ToolTip.text: "Refresh application catalog"
                    ToolTip.visible: hovered
                    onClicked: {
                        appCatalog.refresh()
                        appFilter.setFilterFixedString(searchField.text)
                    }
                }
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search installed Linux applications..."
                color: root.primaryText
                placeholderTextColor: "#8292AD"
                font.pixelSize: 15
                background: Rectangle {
                    radius: 13
                    color: "#B91A2944"
                    border.color: "#8F9277E8"
                }
                onTextChanged: appFilter.setFilterFixedString(text)
                onAccepted: {
                    if (appList.count > 0 && appList.currentItem)
                        appCatalog.launch(appList.currentItem.appId)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "APPLICATION"
                    color: root.secondaryText
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.2
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "PROCESS STATUS"
                    color: root.secondaryText
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.2
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: appFilter
                currentIndex: count > 0 ? 0 : -1
                ScrollBar.vertical: ScrollBar {}

                delegate: Rectangle {
                    id: appRow
                    required property string displayName
                    required property string appId
                    required property string description
                    required property string executable
                    required property bool running
                    required property int processCount
                    required property bool trackingAvailable
                    required property int index

                    width: appList.width
                    height: 61
                    radius: 11
                    color: rowHover.containsMouse ? "#9C344767"
                         : (appList.currentIndex === appRow.index ? "#4B293E5F" : "transparent")
                    border.color: appList.currentIndex === appRow.index ? "#5578A1C0" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 37
                            Layout.preferredHeight: 37
                            radius: 11
                            color: "#263B5B"
                            Text {
                                anchors.centerIn: parent
                                text: appRow.displayName.length > 0 ? appRow.displayName.charAt(0).toUpperCase() : "A"
                                color: root.cyan
                                font.pixelSize: 17
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: appRow.displayName
                                color: root.primaryText
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: appRow.executable + "  ·  " + appRow.appId
                                color: root.secondaryText
                                font.pixelSize: 9
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: (appRow.running || !appRow.trackingAvailable) ? 105 : 95
                            Layout.preferredHeight: 25
                            radius: 12
                            color: appRow.running ? "#31523F59" : "#26344A"
                            Text {
                                anchors.centerIn: parent
                                text: !appRow.trackingAvailable ? "Unverified"
                                      : (appRow.running ? "Running · " + appRow.processCount : "Not detected")
                                color: appRow.running ? "#9DE5BD" : "#AAB6D0"
                                font.pixelSize: 9
                            }
                        }

                    }

                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        z: 1
                        onClicked: appCatalog.launch(appRow.appId)
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: appList.count === 0
                    text: appCatalog.count === 0
                          ? "No visible desktop applications were found."
                          : "No applications match your search."
                    color: root.secondaryText
                    font.pixelSize: 12
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Running status is detected from matching /proc process names."
                    color: "#7183A4"
                    font.pixelSize: 9
                    Layout.fillWidth: true
                }
                Text {
                    text: "Alt + Space  ·  Esc"
                    color: "#7183A4"
                    font.pixelSize: 9
                }
            }
        }

        onVisibleChanged: {
            if (visible)
                searchField.forceActiveFocus()
        }
    }

    NeruFiles {
        id: filesWindow
        transientParent: root
        visible: root.activeApp === "NeruFiles"
        onClosing: root.activeApp = ""
        onNotificationRequested: function(message) { root.showNotification(message) }
    }

    NeruSettings {
        id: settingsWindow
        transientParent: root
        visible: root.activeApp === "NeruSettings"
        onClosing: root.activeApp = ""
        onWallpaperRequested: wallpaperDialog.open()
        onSessionRequested: {
            root.sessionPanelOpen = true
            root.activeApp = ""
        }
    }

    NotificationCenter {
        id: notificationCenter
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 12
        notificationModel: notificationModel
        visible: root.notificationCenterOpen
        z: 75
        onCloseRequested: root.notificationCenterOpen = false
        onClearRequested: notificationModel.clear()
    }

    SessionPanel {
        id: sessionPanel
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 12
        userName: sessionManager.userName
        lockerAvailable: sessionManager.lockerAvailable
        visible: root.sessionPanelOpen
        z: 76
        onCloseRequested: root.sessionPanelOpen = false
        onActionRequested: function(action) {
            root.sessionPanelOpen = false
            if (action === "lock") sessionManager.lockScreen()
            else if (action === "logout") sessionManager.logOut()
            else if (action === "suspend") sessionManager.suspend()
            else if (action === "restart") sessionManager.restart()
            else if (action === "poweroff") sessionManager.powerOff()
        }
    }

        Rectangle {
        id: updatePanel
        width: Math.min(500, root.width - 36)
        height: Math.min(500, root.height - 150)
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.rightMargin: 18
        anchors.topMargin: 18
        radius: 22
        color: "#F00D172B"
        border.color: "#8295B9D5"
        visible: root.updatePanelOpen
        z: 68

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 19
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "System Updates"
                    color: root.primaryText
                    font.pixelSize: 19
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: "×"
                    onClicked: root.updatePanelOpen = false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                radius: 13
                color: updateChecker.state === "updates" ? "#35324B4A"
                     : updateChecker.state === "error" || updateChecker.state === "unavailable" ? "#3D4B3542"
                     : "#26364F"
                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5
                    Text {
                        text: updateChecker.state === "checking" ? "Checking…"
                              : updateChecker.state === "updates" ? updateChecker.updateCount + " updates available"
                              : updateChecker.state === "current" ? "You're up to date"
                              : updateChecker.state === "error" ? "Could not check updates"
                              : updateChecker.state === "unavailable" ? "Update checker unavailable"
                              : "System update status"
                        color: root.primaryText
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        text: updateChecker.message
                        color: root.secondaryText
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "PACKAGE"
                    color: root.secondaryText
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "VERSION"
                    color: root.secondaryText
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1
                }
            }

            ListView {
                id: updateList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 3
                model: updateChecker.updates
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property string modelData
                    width: updateList.width
                    height: 32
                    radius: 8
                    color: "#54233350"
                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: "#DCE6FA"
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                }
                Label {
                    anchors.centerIn: parent
                    visible: updateList.count === 0
                    text: updateChecker.state === "checking"
                          ? "Contacting package mirrors…"
                          : "No update list to display."
                    color: root.secondaryText
                    font.pixelSize: 11
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: updateChecker.checking ? "Checking…" : "Check again"
                    enabled: !updateChecker.checking
                    onClicked: updateChecker.checkNow()
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: updateChecker.lastChecked.length
                          ? "Checked " + updateChecker.lastChecked
                          : "Not checked yet"
                    color: "#7183A4"
                    font.pixelSize: 8
                }
            }

            Text {
                Layout.fillWidth: true
                text: "This only checks package versions; it never installs updates. The VM Alpha is a live session: changes made inside it are temporary and disappear after shutdown. A persistent NeruOS update channel and installer will come later."
                color: "#93A3C1"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: launchToast
        width: Math.min(560, root.width - 40)
        height: 52
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: dock.top
        anchors.bottomMargin: 26
        radius: 15
        color: "#F0101B31"
        border.color: "#8194B4D0"
        visible: root.notificationText.length > 0
        z: 90

        Text {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.notificationText
            color: root.primaryText
            font.pixelSize: 11
            elide: Text.ElideRight
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
                      ? "NeruOS Nebula Edition. Built with Qt 6, C++, QML and labwc."
                      : "Alt + Space  Open NeruSearch\nAlt + Tab  Switch native windows\nSuper + 1–4  Change workspace\nSuper + Shift + 1–4  Move window to workspace\nSuper + A  Maximize / restore\nSuper + Left / Right  Snap window\nSuper + F  Fullscreen   Super + M  Minimize\nSuper + D  Show desktop   Alt + F4  Close window\nMove pointer to the left edge  Reveal navigation rail"
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

    // Super+1–4 and Super+Shift+1–4 are handled by labwc.
    // Ctrl+Alt+1–4 are shell shortcuts that also update the menu-bar label.
    Shortcut { sequence: "Ctrl+Alt+1"; onActivated: { if (workspaceController.switchTo(1)) root.activeWorkspace = "General" } }
    Shortcut { sequence: "Ctrl+Alt+2"; onActivated: { if (workspaceController.switchTo(2)) root.activeWorkspace = "Coding" } }
    Shortcut { sequence: "Ctrl+Alt+3"; onActivated: { if (workspaceController.switchTo(3)) root.activeWorkspace = "Gaming" } }
    Shortcut { sequence: "Ctrl+Alt+4"; onActivated: { if (workspaceController.switchTo(4)) root.activeWorkspace = "Study" } }

    // Startup animation is a separate lightweight Qt Quick process.
    // See BootSplash.qml; it launches before the full desktop shell.
}
