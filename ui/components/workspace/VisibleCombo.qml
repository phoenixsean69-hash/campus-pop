// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import "../../theme" as Theme
ComboBox {
    id: control
    implicitHeight: 50
    implicitWidth: 170
    font.family: c.uiFont
    font.pixelSize: Math.round(16 * c.typeScale)
    font.weight: Font.DemiBold
    Theme.Colors { id: c }

    contentItem: Text {
        leftPadding: 16
        rightPadding: 38
        text: control.displayText
        color: c.ink
        font: control.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        text: "⌄"
        font.family: c.uiFont
        font.pixelSize: Math.round(26 * c.typeScale)
        font.weight: Font.Bold
        color: control.activeFocus || control.popup.visible ? c.orangeDark : c.muted
        x: control.width - width - 12
        anchors.verticalCenter: parent.verticalCenter
    }

    background: Rectangle {
        radius: 14
        color: control.pressed ? c.orangeSoft : c.inputSurface
        border.color: control.activeFocus || control.popup.visible ? c.orange : c.line
        border.width: control.activeFocus || control.popup.visible ? 2 : 1.5
    }

    delegate: ItemDelegate {
        id: delegate
        width: control.width
        height: 44
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: modelData
            color: c.ink
            font.family: c.uiFont
            font.pixelSize: Math.round(14 * c.typeScale)
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }
        background: Rectangle {
            radius: 8
            color: delegate.highlighted ? c.orangeSoft : c.surface
        }
    }

    popup: Popup {
        y: control.height + 6
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight + 14, 270)
        padding: 7
        background: Rectangle {
            radius: 12
            color: c.surface
            border.color: c.line
            border.width: 1
        }
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
