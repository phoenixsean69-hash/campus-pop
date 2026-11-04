// CAMPUS_POP_PACKS_V34
import QtQuick
import QtQuick.Controls
import "../../theme" as Theme

Button {
    id: control

    // Keep the public properties used across HeroBanner, Quick Actions and the AI panel.
    property color fillColor: "#FF7A13"
    property color shadowColor: "#CE5600"
    property color textColor: "#FFFFFF"
    property string iconText: ""
    property bool compact: false
    // CAMPUS_POP_DUO_PACKS_V33
    Theme.Colors { id: c }
    property bool reduceMotion: settingsBridge.reducedMotion
    property real wobbleAngle: 0

    implicitHeight: compact ? 46 : 54
    implicitWidth: Math.max(compact ? 125 : 160,
                            label.implicitWidth + (iconText.length > 0 ? symbol.implicitWidth + 9 : 0) + 34)
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font.family: c.uiFont
    font.pixelSize: compact ? 15 : 16
    font.weight: Font.ExtraBold

    // Animate the button itself without addressing a transform ID from a Behavior.
    scale: reduceMotion ? 1 : (down ? 0.985 : (hovered ? 1.018 : 1))
    Behavior on scale {
        enabled: !control.reduceMotion
        NumberAnimation { duration: 115; easing.type: Easing.OutCubic }
    }

    transform: Rotation {
        origin.x: control.width / 2
        origin.y: control.height / 2
        angle: control.wobbleAngle
    }

    background: Item {
        Rectangle {
            x: 0
            y: c.buttonDepth
            width: parent.width
            height: parent.height - c.buttonDepth
            radius: c.buttonRadius
            visible: c.buttonDepth > 0
            color: control.enabled ? control.shadowColor : "#C7C7CB"
        }
        Rectangle {
            x: 0
            y: control.down ? c.buttonDepth : 0
            width: parent.width
            height: parent.height - c.buttonDepth
            radius: c.buttonRadius
            color: !control.enabled ? "#D8D8DE" : c.packPop
                ? (control.hovered ? Qt.lighter(control.fillColor, 1.08) : control.fillColor)
                : (control.hovered ? Qt.lighter(c.orange, 1.08) : c.orange)
            Behavior on y { NumberAnimation { duration: 70 } }
        }
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: c.buttonRadius
            border.width: control.activeFocus ? 2 : 0
            border.color: c.ink
        }
    }

    contentItem: Item {
        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: c.packPop ? (control.down ? 2 : -2) : 0
            spacing: 9

            Text {
                id: symbol
                visible: control.iconText.length > 0
                text: control.iconText
                color: control.textColor
                font.family: control.font.family
                font.pixelSize: control.font.pixelSize + 3
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: label
                text: control.text
                color: control.enabled ? control.textColor : "#666670"
                font: control.font
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    SequentialAnimation {
        id: clickWobble
        running: false
        NumberAnimation { target: control; property: "wobbleAngle"; to: -3; duration: 45 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: 3; duration: 65 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: -1.5; duration: 55 }
        NumberAnimation { target: control; property: "wobbleAngle"; to: 0; duration: 60 }
    }

    onClicked: {
        if (!reduceMotion)
            clickWobble.restart()
    }
}
