// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import "../../theme" as Theme
TextField {
    id: root
    implicitHeight: 43
    font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
    color: c.ink; placeholderTextColor: c.muted
    leftPadding: 13; rightPadding: 12
    Theme.Colors { id: c }
    background: Rectangle {
        radius: 11; color: c.surface; border.color: root.activeFocus ? c.orange : c.line
        border.width: root.activeFocus ? 2 : 1
    }
}
