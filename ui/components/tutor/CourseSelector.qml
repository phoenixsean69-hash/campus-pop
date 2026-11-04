import QtQuick
import QtQuick.Controls
import "../../theme" as Theme

// Campus Pop course selector. Explicit text, arrow, and popup colors prevent
// system/native styles from making course names invisible in light/dark mode.
ComboBox {
    id: selector
    property bool compact: false

    implicitWidth: compact ? 195 : 240
    implicitHeight: compact ? 38 : 48
    hoverEnabled: true
    font.family: appFontFamily
    font.pixelSize: compact ? 13 : 14
    font.weight: Font.DemiBold

    Theme.Colors { id: palette }

    contentItem: Text {
        text: selector.displayText || "Select course"
        font: selector.font
        color: palette.ink
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        leftPadding: 13
        rightPadding: 42
        elide: Text.ElideRight
    }

    indicator: Text {
        text: "▾"
        font.family: appFontFamily
        font.pixelSize: 20
        font.weight: Font.Bold
        color: selector.activeFocus || selector.popup.visible ? palette.orangeDark : palette.purple
        x: selector.width - width - 15
        y: (selector.height - height) / 2
    }

    background: Rectangle {
        radius: 11
        border.width: selector.activeFocus || selector.popup.visible ? 2 : 1
        border.color: selector.activeFocus || selector.popup.visible ? palette.purple : palette.line
        color: selector.pressed ? palette.orangeSoft : palette.dark ? palette.elevated : "#F6F4FA"
    }

    delegate: ItemDelegate {
        id: option
        width: selector.popup.width - selector.popup.leftPadding - selector.popup.rightPadding
        height: 43
        highlighted: selector.highlightedIndex === index
        contentItem: Text {
            text: modelData
            font.family: appFontFamily
            font.pixelSize: 14
            font.weight: index === selector.currentIndex ? Font.Bold : Font.Medium
            color: palette.ink
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 8
            color: option.highlighted ? palette.purpleSoft : index === selector.currentIndex ? palette.elevated : palette.surface
        }
    }

    popup: Popup {
        y: selector.height + 5
        width: selector.width
        padding: 7
        implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 310)
        background: Rectangle {
            radius: 12
            color: palette.surface
            border.color: palette.line
            border.width: 1.5
        }
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: selector.popup.visible ? selector.delegateModel : null
            currentIndex: selector.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
