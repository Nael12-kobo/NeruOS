import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: splashWindow

    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen
    color: "#030713"
    title: "NeruOS"

    BootAnimation {
        anchors.fill: parent
        animationMode: "draw"
        speedMultiplier: 1.0
        rippleEnabled: true
        loadingDotsEnabled: true
        onFinished: Qt.quit()
    }
}
