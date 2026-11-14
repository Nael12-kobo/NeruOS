import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitWidth: 650
    implicitHeight: 90
    radius: 27
    color: "#E00E1A30"
    border.color: "#7792B5D0"
    border.width: 1
    clip: false

    property var applications: []
    property string activeApplication: ""
    property real pointerX: -1
    property bool magnificationEnabled: true
    signal applicationRequested(string appName)

    Row {
        id: dockRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.applications

            delegate: Item {
                id: iconItem
                required property var modelData
                width: 58
                height: 70

                readonly property real centerX: mapToItem(root, width / 2, height / 2).x
                readonly property real targetScale: !root.magnificationEnabled || root.pointerX < 0
                                                    ? 1.0
                                                    : Math.max(1.0, 1.62 - Math.abs(root.pointerX - centerX) / 180)

                Rectangle {
                    id: iconSurface
                    width: 52
                    height: 52
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 16
                    color: iconItem.modelData.tint
                    border.color: "#9AD6E4FA"
                    border.width: 1
                    scale: iconItem.targetScale
                    transformOrigin: Item.Center

                    gradient: Gradient {
                        GradientStop { position: 0; color: Qt.lighter(iconItem.modelData.tint, 1.28) }
                        GradientStop { position: 1; color: iconItem.modelData.tint }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 135
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: iconItem.modelData.glyph
                        color: "#F7FAFF"
                        font.pixelSize: iconItem.modelData.glyph === "</>" ? 15 : 24
                        font.bold: true
                    }
                }

                Rectangle {
                    width: 5
                    height: 5
                    radius: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    color: root.activeApplication === iconItem.modelData.name ? "#54C8EB" : "transparent"
                    visible: root.activeApplication === iconItem.modelData.name
                }

                MouseArea {
                    id: iconHitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.pointerX = iconItem.centerX
                    onPositionChanged: root.pointerX = iconItem.mapToItem(root, mouse.x, mouse.y).x
                    onExited: root.pointerX = -1
                    onClicked: root.applicationRequested(iconItem.modelData.name)
                }

                ToolTip.visible: iconHitArea.containsMouse
                ToolTip.text: iconItem.modelData.name
                ToolTip.delay: 450
            }
        }
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 7
        anchors.horizontalCenter: parent.horizontalCenter
        text: "NERUDOCK"
        color: "#8FA2C4"
        font.pixelSize: 8
        font.letterSpacing: 2.1
    }
}
