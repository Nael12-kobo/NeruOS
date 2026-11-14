import QtQuick

Image {
    id: root

    source: "qrc:/assets/logo-mark.svg"
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    smooth: true
    mipmap: true
    sourceSize.width: Math.max(48, width * 2)
    sourceSize.height: Math.max(48, height * 2)
}
