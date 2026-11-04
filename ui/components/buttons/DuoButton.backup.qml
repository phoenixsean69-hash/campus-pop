import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property color fillColor: "#FF8A1F"
    property color shadowColor: "#D96B0B"
    property color textColor: "white"
    property string iconText: ""
    property bool compact: false

    implicitHeight: compact ? 46 : 54
    implicitWidth: compact ? 160 : 190

    padding: 0
    hoverEnabled: true

    background: Item {
        anchors.fill: parent

        // bottom shadow / depth
        Rectangle {
            id: shadowLayer
            x: 0
            y: faceLayer.y + 6
            width: parent.width
            height: parent.height - 2
            radius: 18
            color: control.enabled ? control.shadowColor : "#CFCFCF"
            opacity: 1.0
        }

        // main face
        Rectangle {
            id: faceLayer
            x: pressAnimOffsetX
            y: control.down ? 4 : (control.hovered ? -3 : 0)
            width: parent.width
            height: parent.height - 4
            radius: 18

            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.lighter(control.fillColor, 1.10) }
                GradientStop { position: 1.0; color: control.fillColor }
            }

            border.width: 0

            // glossy top highlight
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                anchors.topMargin: 3
                height: parent.height * 0.38
                radius: 16
                color: "#33FFFFFF"
            }
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 8

        Text {
            visible: control.iconText !== ""
            text: control.iconText
            color: control.textColor
            font.pixelSize: 17
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: control.text
            color: control.textColor
            font.pixelSize: compact ? 15 : 16
            font.bold: true
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }
    }

    property real pressAnimOffsetX: 0

    transform: [
        Rotation {
            id: wobbleRotation
            origin.x: control.width / 2
            origin.y: control.height / 2
            angle: 0
        },
        Scale {
            id: scaleTransform
            origin.x: control.width / 2
            origin.y: control.height / 2
            xScale: control.down ? 0.985 : (control.hovered ? 1.025 : 1.0)
            yScale: control.down ? 0.985 : (control.hovered ? 1.025 : 1.0)
        }
    ]

    Behavior on pressAnimOffsetX {
        NumberAnimation { duration: 55 }
    }

    Behavior on scaleTransform.xScale {
        NumberAnimation { duration: 120 }
    }

    Behavior on scaleTransform.yScale {
        NumberAnimation { duration: 120 }
    }

    SequentialAnimation {
        id: shakeAnim
        running: false

        NumberAnimation { target: wobbleRotation; property: "angle"; to: -4; duration: 45 }
        NumberAnimation { target: wobbleRotation; property: "angle"; to: 4; duration: 55 }
        NumberAnimation { target: wobbleRotation; property: "angle"; to: -3; duration: 45 }
        NumberAnimation { target: wobbleRotation; property: "angle"; to: 2; duration: 40 }
        NumberAnimation { target: wobbleRotation; property: "angle"; to: 0; duration: 45 }
    }

    SequentialAnimation {
        id: nudgeAnim
        running: false

        NumberAnimation { target: control; property: "pressAnimOffsetX"; to: -2; duration: 35 }
        NumberAnimation { target: control; property: "pressAnimOffsetX"; to: 2; duration: 35 }
        NumberAnimation { target: control; property: "pressAnimOffsetX"; to: -1; duration: 30 }
        NumberAnimation { target: control; property: "pressAnimOffsetX"; to: 0; duration: 25 }
    }

    onClicked: {
        shakeAnim.restart()
        nudgeAnim.restart()
    }
}