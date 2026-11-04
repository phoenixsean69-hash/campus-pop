// CAMPUS_POP_PACKS_V34
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme

ColumnLayout {
    id: root
    spacing: 12
    Theme.Colors { id: c }

    ColumnLayout {
        visible: c.packPaper
        Layout.fillWidth: true
        spacing: 8
        Text { text: "PAPER TEXTURE"; color: c.ink; font.family: c.uiFont; font.weight: Font.Bold; font.pixelSize: Math.round(14 * c.typeScale) }
        Text {
            Layout.fillWidth: true
            text: "Adjust the paper grain throughout Campus Pop. This setting only applies to Paper."
            wrapMode: Text.WordWrap
            color: c.muted
            font.family: c.uiFont
            font.pixelSize: Math.round(12 * c.typeScale)
        }
        GridLayout {
            Layout.fillWidth: true
            columns: root.width < 440 ? 1 : 3
            columnSpacing: 9
            rowSpacing: 9
            Repeater {
                model: [ {key:"soft",name:"Soft"}, {key:"medium",name:"Medium"}, {key:"strong",name:"Strong"} ]
                delegate: Rectangle {
                    id: paperLevel
                    required property var modelData
                    readonly property bool selected: settingsBridge.paperIntensity === modelData.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 43
                    radius: c.controlRadius
                    color: selected ? c.orangeSoft : c.cardSurface
                    border.width: selected ? 2 : 1
                    border.color: selected ? c.orange : c.cardBorder
                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                        color: c.ink
                        font.family: c.uiFont
                        font.pixelSize: 13
                        font.weight: selected ? Font.Bold : Font.Medium
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsBridge.setPaperIntensity(paperLevel.modelData.key)
                    }
                }
            }
        }
    }
    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: c.line }
    Text {
        text: "CUSTOMISE THE PACK"
        color: c.muted
        font.family: c.uiFont
        font.pixelSize: Math.round(12 * c.typeScale)
        font.weight: Font.Bold
        font.letterSpacing: 0.8
    }
    GridLayout {
        Layout.fillWidth: true
        columns: root.width < 660 ? 1 : 2
        columnSpacing: 14
        rowSpacing: 12
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: "Layout density"; color: c.ink; font.family: c.uiFont; font.weight: Font.Bold; font.pixelSize: Math.round(14 * c.typeScale) }
            RowLayout {
                spacing: 8
                Repeater {
                    model: [{key:"comfortable",title:"Comfortable"}, {key:"compact",title:"Compact"}]
                    delegate: Rectangle {
                        id: densityTile
                        required property var modelData
                        readonly property bool selected: settingsBridge.layoutDensity === modelData.key
                        Layout.preferredWidth: 128
                        Layout.preferredHeight: 42
                        radius: c.controlRadius
                        color: selected ? c.orangeSoft : c.elevated
                        border.width: selected ? 2 : 1
                        border.color: selected ? c.orange : c.line
                        Text { anchors.centerIn: parent; text: modelData.title; color: c.ink; font.family: c.uiFont; font.pixelSize: 12; font.weight: selected ? Font.Bold : Font.Medium }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingsBridge.setLayoutDensity(densityTile.modelData.key) }
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: "Text size"; color: c.ink; font.family: c.uiFont; font.weight: Font.Bold; font.pixelSize: Math.round(14 * c.typeScale) }
            ComboBox {
                id: typeScalePicker
                Layout.preferredWidth: 180
                Layout.preferredHeight: 42
                model: ["90% — Small", "100% — Normal", "110% — Large", "120% — Extra large"]
                currentIndex: Math.max(0, [90,100,110,120].indexOf(settingsBridge.fontScale))
                onActivated: settingsBridge.setFontScale([90,100,110,120][currentIndex])
                font.family: c.uiFont
                font.pixelSize: 13
                contentItem: Text { text: typeScalePicker.displayText; color: c.ink; font: typeScalePicker.font; verticalAlignment: Text.AlignVCenter; leftPadding: 12; rightPadding: 25 }
                background: Rectangle { color: c.elevated; radius: c.controlRadius; border.color: c.line; border.width: 1 }
                indicator: Text { text: "⌄"; x: typeScalePicker.width - 26; anchors.verticalCenter: parent.verticalCenter; color: c.ink; font.pixelSize: 23 }
                delegate: ItemDelegate {
                    width: typeScalePicker.width
                    contentItem: Text { text: modelData; color: c.ink; font.family: c.uiFont; font.pixelSize: 13; leftPadding: 10 }
                    background: Rectangle { color: highlighted ? c.orangeSoft : c.surface }
                }
                popup: Popup {
                    y: typeScalePicker.height + 4
                    width: typeScalePicker.width
                    implicitHeight: contentItem.implicitHeight + 12
                    padding: 6
                    background: Rectangle { color: c.surface; radius: c.controlRadius; border.color: c.line }
                    contentItem: ListView { clip: true; implicitHeight: contentHeight; model: typeScalePicker.popup.visible ? typeScalePicker.delegateModel : null; currentIndex: typeScalePicker.highlightedIndex }
                }
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 12
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text { text: "Student illustrations"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
            Text { Layout.fillWidth: true; text: "Show or hide decorative student artwork in page banners."; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
        }
        Switch {
            checked: settingsBridge.showIllustrations
            onToggled: settingsBridge.setShowIllustrations(checked)
        }
    }
    Text {
        Layout.fillWidth: true
        text: "Packs set sensible defaults; you can customise them here. Your choices are saved on this PC."
        color: c.muted
        font.family: c.uiFont
        font.pixelSize: Math.round(12 * c.typeScale)
        wrapMode: Text.WordWrap
    }
}
