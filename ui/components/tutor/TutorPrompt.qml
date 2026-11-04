import QtQuick
import QtQuick.Controls

Rectangle {
    id: prompt
    property string title: ""
    property string subtitle: ""
    property color accent: "#8B5CF6"
    property color surface: "#F5EEFF"
    signal selected()

    implicitWidth: 208
    implicitHeight: 74
    radius: 13
    color: hover.containsMouse ? Qt.darker(surface, 1.04) : surface
    border.color: hover.containsMouse ? accent : "#E7E1EE"
    border.width: hover.containsMouse ? 1.5 : 1

    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on border.color { ColorAnimation { duration: 130 } }

    Rectangle {
        width: 4
        height: parent.height - 24
        radius: 2
        color: prompt.accent
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
    }
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.right: parent.right
        anchors.rightMargin: 11
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Text {
            text: prompt.title
            color: "#253251"
            font.family: appFontFamily
            font.pixelSize: 14
            font.weight: Font.ExtraBold
            elide: Text.ElideRight
            width: parent.width
        }
        Text {
            text: prompt.subtitle
            color: "#728098"
            font.family: appFontFamily
            font.pixelSize: 12
            width: parent.width
            elide: Text.ElideRight
        }
    }
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: prompt.selected()
    }
}
