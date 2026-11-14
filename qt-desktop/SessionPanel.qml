import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string userName: "neru"
    property bool lockerAvailable: false
    signal closeRequested()
    signal actionRequested(string action)

    width: 330
    height: 365
    radius: 21
    color: "transparent"
    border.color: "transparent"

    GlassPanel {
        anchors.fill: parent
        sourceItem: null
        tint: "#E5EAF1FA"
        borderColor: "#E8FFFFFF"
        cornerRadius: root.radius
        blurAmount: 0.4
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Text { text: "User & Session"; color: "#1D2C45"; font.pixelSize: 16; font.bold: true }
            Item { Layout.fillWidth: true }
            ToolButton { text: "×"; onClicked: root.closeRequested() }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 70
            radius: 12
            color: "#BFFFFFFF"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 13
                Rectangle {
                    width: 42
                    height: 42
                    radius: 21
                    color: "#D8E6F7"
                    Text { anchors.centerIn: parent; text: root.userName.charAt(0).toUpperCase(); color: "#29456C"; font.pixelSize: 17; font.bold: true }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Text { text: root.userName; color: "#1D2C45"; font.pixelSize: 12; font.bold: true }
                    Text { text: "Active NeruOS session"; color: "#73829A"; font.pixelSize: 9 }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: "Lock Screen"
            enabled: root.lockerAvailable
            onClicked: root.actionRequested("lock")
        }
        Button {
            Layout.fillWidth: true
            text: "Log Out"
            onClicked: logoutDialog.open()
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#8295ADC5" }
        RowLayout {
            Layout.fillWidth: true
            Button { Layout.fillWidth: true; text: "Suspend"; onClicked: suspendDialog.open() }
            Button { Layout.fillWidth: true; text: "Restart"; onClicked: restartDialog.open() }
            Button { Layout.fillWidth: true; text: "Power Off"; onClicked: poweroffDialog.open() }
        }
        Text {
            text: root.lockerAvailable ? "Locking uses the installed session locker and PAM."
                                       : "No screen locker is installed. Lock is disabled to avoid an unusable locked session."
            color: "#71829A"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Dialog {
        id: logoutDialog
        title: "Log out?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        Label { text: "Close the current NeruOS session?"; color: "#25344B" }
        onAccepted: root.actionRequested("logout")
    }
    Dialog {
        id: suspendDialog
        title: "Suspend?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        Label { text: "Put this computer to sleep?"; color: "#25344B" }
        onAccepted: root.actionRequested("suspend")
    }
    Dialog {
        id: restartDialog
        title: "Restart NeruOS?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        Label { text: "Restart the computer? Unsaved work may be lost."; color: "#25344B" }
        onAccepted: root.actionRequested("restart")
    }
    Dialog {
        id: poweroffDialog
        title: "Power off?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        Label { text: "Shut down the computer? Unsaved work may be lost."; color: "#25344B" }
        onAccepted: root.actionRequested("poweroff")
    }
}
