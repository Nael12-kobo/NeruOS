import QtQuick

Rectangle {
    id: root

    implicitWidth: Math.max(190, applications.length * 62 + 34)
    implicitHeight: 80
    width: implicitWidth
    height: implicitHeight
    radius: 25
    color: "transparent"
    border.color: "transparent"
    border.width: 0
    clip: false

    property Item blurSource
    property var applications: []
    property var runningApplications: []
    property string activeApplication: ""
    property real pointerX: -1

    signal applicationRequested(string appName)

    GlassPanel {
        anchors.fill: parent
        sourceItem: root.blurSource
        tint: "#70284068"
        borderColor: "#83E9F3FF"
        cornerRadius: root.radius
        blurAmount: 0.78
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        height: 1
        radius: 1
        color: "#66FFFFFF"
    }

    Row {
        id: dockRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.applications

            delegate: DockItem {
                required property var modelData
                app: modelData
                coordinateTarget: root
                pointerX: root.pointerX
                activeApplication: root.activeApplication
                runningApplications: root.runningApplications
                onActivated: function(applicationName) {
                    root.applicationRequested(applicationName)
                }
            }
        }
    }

    HoverHandler {
        onPointChanged: root.pointerX = point.position.x
        onActiveChanged: {
            if (!active)
                root.pointerX = -1
        }
    }
}
