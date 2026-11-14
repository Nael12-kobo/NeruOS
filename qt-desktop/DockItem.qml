import QtQuick
import QtQuick.Controls

Item {
    id: root

    width: 62
    height: 72

    property var app
    property Item coordinateTarget
    property real pointerX: -1
    property string activeApplication: ""
    property var runningApplications: []

    readonly property string applicationName: app && app.name ? app.name : ""
    readonly property url iconSource: app && app.icon ? app.icon : ""
    readonly property real centerX: coordinateTarget
                                      ? mapToItem(coordinateTarget, width / 2, height / 2).x
                                      : 0
    readonly property real targetScale: pointerX < 0
                                        ? 1.0
                                        : Math.max(1.0, 1.52 - Math.abs(pointerX - centerX) / 165)

    Image {
        id: appIcon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 50
        height: 50
        source: root.iconSource
        sourceSize.width: 256
        sourceSize.height: 256
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        scale: root.targetScale
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 5
        height: 5
        radius: 3
        color: root.activeApplication === root.applicationName ? "#8BE0FF" : "#EAF6FF"
        visible: (root.runningApplications.indexOf(root.applicationName) >= 0)
                 || root.activeApplication === root.applicationName
        opacity: visible ? 0.95 : 0
    }

    MouseArea {
        id: hitArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.applicationName)
    }

    ToolTip.visible: hitArea.containsMouse
    ToolTip.text: root.applicationName
    ToolTip.delay: 400

    signal activated(string applicationName)
}
