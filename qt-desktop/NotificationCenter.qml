import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property var notificationModel
    signal closeRequested()
    signal clearRequested()

    width: 370
    height: Math.min(520, parent ? parent.height - 110 : 520)
    radius: 22
    color: "transparent"
    border.color: "transparent"

    GlassPanel {
        anchors.fill: parent
        sourceItem: null
        tint: "#E5EAF1FA"
        borderColor: "#E8FFFFFF"
        cornerRadius: root.radius
        blurAmount: 0.45
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 17
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Notification Center"; color: "#1D2C45"; font.pixelSize: 16; font.bold: true }
            Item { Layout.fillWidth: true }
            ToolButton { text: "Clear all"; onClicked: root.clearRequested() }
            ToolButton { text: "×"; onClicked: root.closeRequested() }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 7
            model: root.notificationModel
            ScrollBar.vertical: ScrollBar {}
            delegate: Rectangle {
                id: notificationRow
                required property string title
                required property string message
                required property string timeText
                width: list.width
                height: 72
                radius: 12
                color: "#BFFFFFFF"
                border.color: "#72FFFFFF"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: notificationRow.title; color: "#1C2B44"; font.pixelSize: 11; font.bold: true; Layout.fillWidth: true }
                        Text { text: notificationRow.timeText; color: "#75839A"; font.pixelSize: 8 }
                    }
                    Text {
                        text: notificationRow.message
                        color: "#4F5F76"
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
            Label {
                anchors.centerIn: parent
                visible: list.count === 0
                text: "You're all caught up"
                color: "#66758B"
                font.pixelSize: 12
            }
        }

        Text {
            text: list.count + " notifications"
            color: "#75839A"
            font.pixelSize: 9
            Layout.alignment: Qt.AlignRight
        }
    }
}
