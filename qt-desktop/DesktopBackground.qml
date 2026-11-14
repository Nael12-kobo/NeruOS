import QtQuick

Item {
    id: root

    property url wallpaperSource: "qrc:/assets/nebula-wallpaper.png"

    Image {
        anchors.fill: parent
        source: root.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
    }
}
