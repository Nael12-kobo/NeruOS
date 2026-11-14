import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root

    anchors.fill: parent
    color: "#030713"
    opacity: 1

    // The boot screen mirrors the supplied HTML preview.
    // Keep this configurable so the animation can be tuned without
    // changing the desktop shell.
    property string animationMode: "draw" // "draw" or "continuous"
    property real speedMultiplier: 1.0
    property bool rippleEnabled: true
    property bool loadingDotsEnabled: true
    property real drawOffset: animationMode === "draw" ? 10 : 0

    signal finished()

    function scaledDuration(milliseconds) {
        return Math.max(100, Math.round(milliseconds / Math.max(0.5, speedMultiplier)))
    }

    // Soft aura behind the logo.
    Rectangle {
        id: aura
        width: 270
        height: 270
        radius: width / 2
        anchors.centerIn: parent
        color: "#263D67D8"
        opacity: 0.35
        scale: 1.0

        SequentialAnimation on scale {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation {
                from: 1.0
                to: 1.08
                duration: root.scaledDuration(1400)
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                from: 1.08
                to: 1.0
                duration: root.scaledDuration(1400)
                easing.type: Easing.InOutSine
            }
        }
    }

    // Two expanding light ripples, staggered by half a cycle.
    Repeater {
        model: 2

        delegate: Rectangle {
            id: rippleItem
            required property int index

            width: 220
            height: 220
            radius: width / 2
            anchors.centerIn: parent
            color: "transparent"
            border.width: 1
            border.color: index === 0 ? "#4D7F8CFF" : "#3D4CC9F0"
            opacity: 0.0
            scale: 0.75
            visible: root.rippleEnabled

            SequentialAnimation {
                loops: Animation.Infinite
                running: root.rippleEnabled && root.visible
                PauseAnimation {
                    duration: index === 0 ? 0 : root.scaledDuration(1300)
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: rippleItem
                        property: "scale"
                        from: 0.75
                        to: 1.65
                        duration: root.scaledDuration(2600)
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: rippleItem
                        property: "opacity"
                        from: 0.55
                        to: 0.0
                        duration: root.scaledDuration(2600)
                        easing.type: Easing.OutCubic
                    }
                }
                ScriptAction {
                    script: {
                        rippleItem.scale = 0.75
                        rippleItem.opacity = 0.55
                    }
                }
            }
        }
    }

    Item {
        id: logoPulse
        width: 340
        height: 290
        anchors.centerIn: parent
        scale: 1.0
        y: 0

        SequentialAnimation {
            running: root.visible
            loops: Animation.Infinite
            ParallelAnimation {
                NumberAnimation {
                    target: logoPulse
                    property: "y"
                    from: 0
                    to: -6
                    duration: root.scaledDuration(1400)
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: logoPulse
                    property: "scale"
                    from: 1.0
                    to: 1.03
                    duration: root.scaledDuration(1400)
                    easing.type: Easing.InOutSine
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: logoPulse
                    property: "y"
                    from: -6
                    to: 0
                    duration: root.scaledDuration(1400)
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: logoPulse
                    property: "scale"
                    from: 1.03
                    to: 1.0
                    duration: root.scaledDuration(1400)
                    easing.type: Easing.InOutSine
                }
            }
        }

        // A faint permanent path acts as the ghost track from the preview.
        Shape {
            id: ghostLogo
            anchors.fill: parent
            preferredRendererType: Shape.GeometryRenderer

            ShapePath {
                strokeColor: "#247D8DFA"
                strokeWidth: 64
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"
                PathSvg {
                    path: "M 62 212 L 126 94 C 138 72 168 72 180 94 L 228 182 C 240 204 270 204 282 182 L 314 122"
                }
            }
        }

        // Main animated stroke. Dash offset moves the visible segment along
        // the original SVG path without converting the logo into a bitmap.
        Shape {
            id: animatedLogo
            anchors.fill: parent
            preferredRendererType: Shape.GeometryRenderer

            ShapePath {
                id: animatedStroke
                strokeWidth: 64
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [10, 10]
                dashOffset: root.drawOffset

                strokeGradient: LinearGradient {
                    id: logoGradient
                    x1: 30
                    y1: 260
                    x2: 330
                    y2: 50

                    GradientStop { id: gradientStart; position: 0.0; color: "#4CC9F0" }
                    GradientStop { id: gradientMiddle; position: 0.5; color: "#6B8AFD" }
                    GradientStop { id: gradientEnd; position: 1.0; color: "#E066FF" }
                }

                PathSvg {
                    path: "M 62 212 L 126 94 C 138 72 168 72 180 94 L 228 182 C 240 204 270 204 282 182 L 314 122"
                }
            }
        }
    }

    // Cycle the three gradient stops like the uploaded SVG preview.
    SequentialAnimation {
        id: gradientFlow
        running: root.visible
        loops: Animation.Infinite

        ParallelAnimation {
            ColorAnimation {
                target: gradientStart
                property: "color"
                from: "#4CC9F0"
                to: "#6B8AFD"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientMiddle
                property: "color"
                from: "#6B8AFD"
                to: "#E066FF"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientEnd
                property: "color"
                from: "#E066FF"
                to: "#4CC9F0"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
        }
        ParallelAnimation {
            ColorAnimation {
                target: gradientStart
                property: "color"
                from: "#6B8AFD"
                to: "#E066FF"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientMiddle
                property: "color"
                from: "#E066FF"
                to: "#4CC9F0"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientEnd
                property: "color"
                from: "#4CC9F0"
                to: "#6B8AFD"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
        }
        ParallelAnimation {
            ColorAnimation {
                target: gradientStart
                property: "color"
                from: "#E066FF"
                to: "#4CC9F0"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientMiddle
                property: "color"
                from: "#4CC9F0"
                to: "#6B8AFD"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
            ColorAnimation {
                target: gradientEnd
                property: "color"
                from: "#6B8AFD"
                to: "#E066FF"
                duration: root.scaledDuration(1067)
                easing.type: Easing.Linear
            }
        }
    }

    // Draw mode follows the source preview: reveal, hold, then clear.
    SequentialAnimation {
        id: drawLoop
        running: root.visible && root.animationMode === "draw"
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "drawOffset"
            from: 10
            to: 0
            duration: root.scaledDuration(1170)
            easing.type: Easing.InOutCubic
        }
        PauseAnimation { duration: root.scaledDuration(260) }
        NumberAnimation {
            target: root
            property: "drawOffset"
            from: 0
            to: 10
            duration: root.scaledDuration(1170)
            easing.type: Easing.InOutCubic
        }
    }

    // Continuous mode keeps the stroke moving along the same path.
    SequentialAnimation {
        id: continuousLoop
        running: root.visible && root.animationMode === "continuous"
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "drawOffset"
            from: 10
            to: 0
            duration: root.scaledDuration(2200)
            easing.type: Easing.Linear
        }
    }

    Row {
        id: loadingDots
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logoPulse.bottom
        anchors.topMargin: 10
        spacing: 10
        visible: root.loadingDotsEnabled

        Repeater {
            model: 3

            delegate: Rectangle {
                id: loadingDot
                required property int index
                width: 9
                height: 9
                radius: width / 2
                color: index === 0 ? "#4CC9F0"
                     : index === 1 ? "#6B8AFD"
                                   : "#E066FF"
                opacity: 0.35
                y: 0

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: root.loadingDotsEnabled && root.visible
                    PauseAnimation {
                        duration: root.scaledDuration(200 * loadingDot.index)
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: loadingDot
                            property: "y"
                            from: 0
                            to: -6
                            duration: root.scaledDuration(280)
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            target: loadingDot
                            property: "opacity"
                            from: 0.35
                            to: 1.0
                            duration: root.scaledDuration(280)
                        }
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: loadingDot
                            property: "y"
                            from: -6
                            to: 0
                            duration: root.scaledDuration(280)
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            target: loadingDot
                            property: "opacity"
                            from: 1.0
                            to: 0.35
                            duration: root.scaledDuration(280)
                        }
                    }
                    PauseAnimation {
                        duration: root.scaledDuration(840)
                    }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loadingDots.bottom
        anchors.topMargin: 17
        text: "NeruOS"
        color: "#F1F5FF"
        font.pixelSize: 27
        font.weight: Font.DemiBold
        font.letterSpacing: 3.2
        renderType: Text.QtRendering
    }

    // Hold the splash long enough to be seen, then reveal the desktop.
    SequentialAnimation {
        id: exitAnimation
        running: true
        PauseAnimation { duration: root.scaledDuration(3600) }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: root.scaledDuration(550)
            easing.type: Easing.OutCubic
        }
        ScriptAction {
            script: {
                root.visible = false
                root.finished()
            }
        }
    }
}
