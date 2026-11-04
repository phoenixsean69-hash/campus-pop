import QtQuick
import QtQuick.Controls

Button {
    id: control

    // A raised, two-line Campus Pop action button.
    signal activated()
    property string title: "Action"
    property string subtitle: ""
    property string iconName: "ai-tutor"
    property color fillColor: "#9254ED"
    property color depthColor: "#6D28B5"
    property real wobbleAngle: 0
    property bool reduceMotion: settingsBridge.reducedMotion

    implicitHeight: 62
    implicitWidth: 170
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    z: hovered ? 2 : 0

    // This transforms the whole clickable card, without changing GridLayout positioning.
    scale: reduceMotion ? 1 : (down ? 0.985 : (hovered ? 1.018 : 1))
    Behavior on scale {
        enabled: !control.reduceMotion
        NumberAnimation { duration: 125; easing.type: Easing.OutCubic }
    }

    transform: Rotation {
        origin.x: control.width / 2
        origin.y: control.height / 2
        angle: control.wobbleAngle
    }

    background: Item {
        // Dark, thick extrusion: always visible even when the face is raised.
        Rectangle {
            x: 0
            y: 8
            width: parent.width
            height: parent.height - 8
            radius: 16
            color: control.enabled ? control.depthColor : "#A7A7AE"
        }

        Rectangle {
            id: face
            x: 0
            y: control.down ? 7 : ((!control.reduceMotion && control.hovered) ? -4 : 0)
            width: parent.width
            height: parent.height - 9
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(control.fillColor, 1.15) }
                GradientStop { position: 0.42; color: Qt.lighter(control.fillColor, 1.04) }
                GradientStop { position: 1.0; color: control.fillColor }
            }
            opacity: control.enabled ? 1 : 0.55

            Behavior on y {
                enabled: !control.reduceMotion
                NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
            }

            // Glossy rim and diffuse top highlight, giving a beveled surface.
            Rectangle {
                x: 7
                y: 4
                width: parent.width - 14
                height: 3
                radius: 2
                color: "#FFFFFF"
                opacity: 0.48
            }
            Rectangle {
                x: 7
                y: 10
                width: parent.width - 14
                height: Math.max(9, parent.height * 0.22)
                radius: 9
                color: "#FFFFFF"
                opacity: 0.10
            }
        }
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "transparent"
            border.width: control.activeFocus ? 2 : 0
            border.color: "#20243A"
        }
    }

    contentItem: Item {
        Row {
            x: 16
            y: (parent.height - height) / 2 - 5 + (control.down ? 6 : ((!control.reduceMotion && control.hovered) ? -4 : 0))
            width: Math.max(0, parent.width - 32)
            spacing: 9

            

            Column {
                width: parent.width
                spacing: 0

                Text {
                    width: parent.width
                    text: control.title
                    color: "#FFFFFF"
                    font.family: "Nunito"
                    font.pixelSize: 17
                    font.weight: Font.ExtraBold
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: control.subtitle
                    color: "#FFFFFF"
                    opacity: 0.94
                    font.family: "Nunito"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }
        }
    }

    SequentialAnimation {
        id: wobble
        NumberAnimation { target: control; property: "wobbleAngle"; to: -3.3; duration: 46 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: 3.3; duration: 60 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: -1.8; duration: 48 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: 0; duration: 57 }
    }

    // Wait briefly before navigating so the click shake is actually visible.
    Timer {
        id: activateTimer
        interval: 235
        repeat: false
        onTriggered: control.activated()
    }

    onClicked: {
        if (!reduceMotion)
            wobble.restart()
        activateTimer.restart()
    }
}
