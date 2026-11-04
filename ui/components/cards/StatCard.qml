// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: card
    property string value: "0"
    property string label: "Metric"
    property string helper: ""
    property string icon: "book"
    property string iconHue: "orange"
    property color tint: "#F97316"
    property color tintSurface: "#FFF0E4"
    radius: 16; color: c.dark ? c.elevated : tintSurface; implicitHeight: 103; border.color: c.line
    Theme.Colors { id: c }
    RowLayout {
        anchors.fill: parent; anchors.margins: 11; spacing: 8
        Rectangle {
            Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 12
            color: c.surface; opacity: 0.95
            Image { anchors.centerIn: parent; width: 25; height: 25; sourceSize.width: 25; sourceSize.height: 25; source: Qt.resolvedUrl("../../../assets/icons/"+card.icon+"-"+card.iconHue+".svg") }
        }
        ColumnLayout {
            Layout.fillWidth: true; spacing: 0
            Text { text: card.value; font.pixelSize: Math.round(27 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text { text: card.label; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.DemiBold; color: c.ink }
            Text { text: card.helper; font.pixelSize: Math.round(12 * c.typeScale); color: c.orangeDark; elide: Text.ElideRight; Layout.fillWidth: true; visible: card.helper.length > 0 }
        }
    }
}
