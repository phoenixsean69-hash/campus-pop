// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import "../../theme" as Theme
Button {
    id: root
    property color fillColor: c.orange
    property color bottomColor: c.orangeDark
    property color labelColor: "#FFFFFF"
    property real wobbleAngle: 0
    implicitHeight: 43
    implicitWidth: Math.max(105, label.implicitWidth + 30)
    hoverEnabled: true
    Theme.Colors { id: c }
    transform: Rotation {
        origin.x: root.width / 2
        origin.y: root.height / 2
        angle: root.wobbleAngle
    }
    SequentialAnimation {
        id: wobble
        NumberAnimation { target: root; property: "wobbleAngle"; to: -2; duration: 40 }
        NumberAnimation { target: root; property: "wobbleAngle"; to: 2; duration: 50 }
        NumberAnimation { target: root; property: "wobbleAngle"; to: 0; duration: 60 }
    }
    onClicked: { if (!settingsBridge.reducedMotion) wobble.restart() }
    background: Item {
        Rectangle { anchors.fill: parent; anchors.topMargin: 4; radius: 12; color: root.enabled ? root.bottomColor : "#BEC2CA" }
        Rectangle {
            anchors.fill: parent; anchors.bottomMargin: root.down ? 0 : 4
            anchors.topMargin: root.hovered && !settingsBridge.reducedMotion ? -2 : 0
            radius: 12; color: root.enabled ? root.fillColor : "#D0D4DA"
        }
    }
    contentItem: Text {
        id: label; text: root.text; color: root.labelColor
        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.ExtraBold
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }
}
