import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    width: 960
    height: 690
    minimumWidth: 720
    minimumHeight: 480
    visible: false
    color: "#10192B"
    flags: Qt.Window
    title: "NeruFiles"

    property string selectedPath: ""
    property string selectedName: ""
    property bool selectedIsDirectory: false

    signal closeRequested()
    signal notificationRequested(string message)

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#F010192B"
        border.color: "#8298B9D8"
        clip: true
    }

    function selectItem(path, name, isDirectory) {
        selectedPath = path
        selectedName = name
        selectedIsDirectory = isDirectory
    }

    function clearSelection() {
        selectedPath = ""
        selectedName = ""
        selectedIsDirectory = false
    }

    Connections {
        target: fileSystemModel
        function onOperationFailed(message) {
            root.notificationRequested(message)
        }
        function onCurrentPathChanged() {
            root.clearSelection()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "NeruFiles"
                color: "#F2F5FF"
                font.pixelSize: 19
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            ToolButton {
                text: "−"
                onClicked: root.close()
                ToolTip.text: "Close NeruFiles"
                ToolTip.visible: hovered
            }
        }

        RowLayout {
            Layout.fillWidth: true
            ToolButton {
                text: "←"
                enabled: fileSystemModel.currentPath !== fileSystemModel.homePath
                onClicked: fileSystemModel.goUp()
                ToolTip.text: "Parent folder"
                ToolTip.visible: hovered
            }
            ToolButton {
                text: "Home"
                onClicked: fileSystemModel.goHome()
            }
            ToolButton {
                text: "↻"
                onClicked: fileSystemModel.refresh()
                ToolTip.text: "Refresh"
                ToolTip.visible: hovered
            }
            TextField {
                id: locationField
                Layout.fillWidth: true
                text: fileSystemModel.currentPath
                selectByMouse: true
                color: "#F2F5FF"
                placeholderText: "Folder path"
                onAccepted: fileSystemModel.navigate(text)
                background: Rectangle {
                    radius: 9
                    color: "#79121E35"
                    border.color: "#597D95B8"
                }
            }
            Button {
                text: "Go"
                onClicked: fileSystemModel.navigate(locationField.text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: fileSystemModel.count + " items"
                color: "#9EACC8"
                font.pixelSize: 10
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "New folder"
                onClicked: createFolderDialog.open()
            }
            Button {
                text: "Rename"
                enabled: root.selectedPath.length > 0
                onClicked: {
                    renameField.text = root.selectedName
                    renameDialog.open()
                }
            }
            Button {
                text: "Move to Trash"
                enabled: root.selectedPath.length > 0
                onClicked: trashDialog.open()
            }
            Text {
                text: "Hidden"
                color: "#AAB6D0"
                font.pixelSize: 9
            }
            Switch {
                checked: fileSystemModel.showHidden
                onToggled: fileSystemModel.setShowHidden(checked)
                ToolTip.text: "Show hidden files and folders"
                ToolTip.visible: hovered
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#42617B9F"
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "NAME"; color: "#8EA0C1"; font.pixelSize: 9; font.bold: true; Layout.fillWidth: true }
            Text { text: "TYPE / SIZE"; color: "#8EA0C1"; font.pixelSize: 9; width: 120; horizontalAlignment: Text.AlignRight }
            Text { text: "MODIFIED"; color: "#8EA0C1"; font.pixelSize: 9; width: 140; horizontalAlignment: Text.AlignRight }
        }

        ListView {
            id: entries
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: fileSystemModel
            spacing: 3
            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                id: entryRow
                required property string name
                required property string path
                required property bool isDirectory
                required property string sizeText
                required property string modifiedText
                width: entries.width
                height: 43
                radius: 9
                color: root.selectedPath === entryRow.path ? "#713D5D8B"
                     : rowMouse.containsMouse ? "#40314B6C" : "transparent"
                border.color: root.selectedPath === entryRow.path ? "#7388A8D0" : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: entryRow.isDirectory ? "▰" : "◇"
                        color: entryRow.isDirectory ? "#70C9F0" : "#B9C9E4"
                        font.pixelSize: 18
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: entryRow.name
                        color: "#F2F5FF"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: entryRow.sizeText
                        color: "#AAB6D0"
                        font.pixelSize: 9
                        width: 120
                        horizontalAlignment: Text.AlignRight
                    }
                    Text {
                        text: entryRow.modifiedText
                        color: "#AAB6D0"
                        font.pixelSize: 9
                        width: 140
                        horizontalAlignment: Text.AlignRight
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        root.selectItem(entryRow.path, entryRow.name, entryRow.isDirectory)
                        if (mouse.button === Qt.RightButton)
                            contextMenu.open()
                    }
                    onDoubleClicked: fileSystemModel.openItem(entryRow.path)
                }

                Menu {
                    id: contextMenu
                    MenuItem {
                        text: entryRow.isDirectory ? "Open folder" : "Open"
                        onTriggered: fileSystemModel.openItem(entryRow.path)
                    }
                    MenuItem {
                        text: "Rename"
                        onTriggered: {
                            root.selectItem(entryRow.path, entryRow.name, entryRow.isDirectory)
                            renameField.text = entryRow.name
                            renameDialog.open()
                        }
                    }
                    MenuItem {
                        text: "Move to Trash"
                        onTriggered: {
                            root.selectItem(entryRow.path, entryRow.name, entryRow.isDirectory)
                            trashDialog.open()
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: entries.count === 0
                text: "This folder is empty"
                color: "#8999B7"
                font.pixelSize: 12
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.selectedName.length ? "Selected: " + root.selectedName : "Choose an item"
                color: "#AAB6D0"
                font.pixelSize: 9
                Layout.fillWidth: true
            }
            Text {
                text: "Home folder · local files"
                color: "#778AA9"
                font.pixelSize: 9
            }
        }
    }

    Dialog {
        id: createFolderDialog
        title: "Create folder"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        width: 330
        TextField {
            id: newFolderField
            width: parent.width
            placeholderText: "Folder name"
            onAccepted: createFolderDialog.accept()
        }
        onAccepted: {
            if (fileSystemModel.createFolder(newFolderField.text))
                root.notificationRequested("Folder created")
            newFolderField.clear()
        }
    }

    Dialog {
        id: renameDialog
        title: "Rename item"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        width: 330
        TextField {
            id: renameField
            width: parent.width
            placeholderText: "New name"
            onAccepted: renameDialog.accept()
        }
        onAccepted: {
            if (fileSystemModel.renameItem(root.selectedPath, renameField.text))
                root.notificationRequested("Item renamed")
        }
    }

    Dialog {
        id: trashDialog
        title: "Move to Trash?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        width: 360
        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Move “" + root.selectedName + "” to the user's Trash? It will not be permanently deleted."
            color: "#26344B"
        }
        onAccepted: {
            if (fileSystemModel.moveToTrash(root.selectedPath))
                root.notificationRequested("Moved to Trash")
            root.clearSelection()
        }
    }
}
