import QtQuick
import QtQuick.Effects

Item {
    id: root

    property Item sourceItem
    property color tint: "#66243B60"
    property color borderColor: "#66FFFFFF"
    property real cornerRadius: 18
    property real blurAmount: 0.72

    readonly property point sourceOrigin: sourceItem
                                          ? mapToItem(sourceItem, 0, 0)
                                          : Qt.point(0, 0)

    ShaderEffectSource {
        id: backdropCapture
        anchors.fill: parent
        sourceItem: root.sourceItem
        sourceRect: root.sourceItem
                    ? Qt.rect(root.sourceOrigin.x, root.sourceOrigin.y,
                              root.width, root.height)
                    : Qt.rect(0, 0, root.width, root.height)
        live: true
        hideSource: false
        recursive: false
        smooth: true
    }

    Rectangle {
        id: roundedMask
        anchors.fill: parent
        radius: root.cornerRadius
        color: "white"
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: backdropCapture
        autoPaddingEnabled: false
        blurEnabled: true
        blur: root.blurAmount
        blurMax: 32
        maskEnabled: true
        maskSource: roundedMask
    }

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.tint
        border.width: 1
        border.color: root.borderColor
    }
}
