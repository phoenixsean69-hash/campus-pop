// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: root
    property string value: "0"
    property string caption: ""
    property color tint: "#FFF0E5"
    property color accent: "#FF7113"
    implicitHeight: 102
    radius: 16; color: tint
    Theme.Colors { id: c }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 3
        Text { text: root.value; font.family: c.uiFont; font.pixelSize: Math.round(27 * c.typeScale); font.weight: Font.ExtraBold; color: root.accent }
        Text { text: root.caption; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.DemiBold; color: c.ink }
    }
}
