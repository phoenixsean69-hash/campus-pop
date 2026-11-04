// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
ColumnLayout {
    id: root
    property string heading: ""
    property string subtitle: ""
    spacing: 3
    Theme.Colors { id: c }
    Text {
        Layout.fillWidth: true
        text: root.heading
        font.family: c.uiFont; font.pixelSize: Math.round(24 * c.typeScale); font.weight: Font.ExtraBold
        color: c.ink; wrapMode: Text.WordWrap
    }
    Text {
        visible: root.subtitle.length > 0
        Layout.fillWidth: true
        text: root.subtitle
        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
        color: c.muted; wrapMode: Text.WordWrap
    }
}
