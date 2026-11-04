// CAMPUS_POP_PACKS_V34
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme

ColumnLayout {
    id: root
    spacing: 10
    Theme.Colors { id: c }
    readonly property var packs: [
        { key:"pop", name:"Campus Pop", subtitle:"Bright · playful · raised", 
          base:"#FFF3E7", rail:"#FFFDFC", face:"#FF7716", ink:"#20233F", accent:"#9562ED", radius:13 },
        { key:"paper", name:"Paper", subtitle:"Textured · warm · editorial",
          base:"#EEE5D4", rail:"#E1D4BE", face:"#B18C65", ink:"#342F25", accent:"#C7B08A", radius:5 },
        { key:"studio", name:"Studio", subtitle:"Flat · focused · restrained",
          base:"#252D35", rail:"#151E27", face:"#59788D", ink:"#F0F3F6", accent:"#394957", radius:3 }
    ]

    Text {
        text: "APPEARANCE PACKS"
        color: c.muted
        font.family: c.uiFont
        font.weight: Font.Bold
        font.pixelSize: Math.round(12 * c.typeScale)
        font.letterSpacing: 0.8
    }
    Text {
        Layout.fillWidth: true
        text: "Change the whole visual style: typography, corners, buttons, page banners and decorative artwork."
        wrapMode: Text.WordWrap
        color: c.muted
        font.family: c.uiFont
        font.pixelSize: Math.round(13 * c.typeScale)
    }
    GridLayout {
        Layout.fillWidth: true
        columns: root.width < 720 ? 1 : 3
        columnSpacing: 11
        rowSpacing: 11
        Repeater {
            model: root.packs
            delegate: Rectangle {
                id: packTile
                required property var modelData
                readonly property bool chosen: settingsBridge.packKey === modelData.key
                Layout.fillWidth: true
                Layout.preferredHeight: 202
                radius: 12
                color: c.surface
                border.color: chosen ? c.orange : c.line
                border.width: chosen ? 2.5 : 1
                clip: true

                Rectangle {
                    id: preview
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 10
                    height: 112
                    radius: modelData.radius
                    color: modelData.base
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: packTile.modelData.key === "paper"
                        opacity: 0.85
                        source: Qt.resolvedUrl("../../../assets/textures/campus_paper_fibers.png")
                        fillMode: Image.Tile
                    }
                    Rectangle {
                        x: 0; y: 0
                        width: 36; height: parent.height
                        color: modelData.rail
                        Rectangle { x: 7; y: 14; width: 23; height: 5; radius: modelData.radius / 2; color: modelData.accent }
                        Repeater {
                            model: 4
                            Rectangle { x: 7; y: 31 + index * 17; width: 22; height: 6; radius: modelData.radius / 3; color: modelData.ink; opacity: index === 0 ? 0.72 : 0.22 }
                        }
                    }
                    Rectangle {
                        x: 45; y: 12
                        width: Math.max(30, preview.width - 57)
                        height: 34
                        color: modelData.key === "pop" ? "#FDE2C5" : modelData.key === "paper" ? "#F7F0E4" : "#344451"
                        radius: modelData.radius
                        Rectangle { x: 9; y: 8; width: parent.width * .57; height: 6; radius: 2; color: modelData.ink; opacity: .85 }
                        Rectangle { x: 9; y: 20; width: parent.width * .36; height: 4; radius: 2; color: modelData.ink; opacity: .30 }
                    }
                    Row {
                        x: 45; y: 54
                        spacing: 6
                        Repeater {
                            model: 2
                            Rectangle {
                                width: Math.max(27, (preview.width - 64) / 2)
                                height: 32
                                color: index === 0 ? packTile.modelData.face : packTile.modelData.accent
                                radius: packTile.modelData.radius
                                Rectangle { visible: packTile.modelData.key === "pop"; anchors.bottom: parent.bottom; width: parent.width; height: 5; radius: packTile.modelData.radius; color: "#000000"; opacity: .20 }
                                Rectangle { x: 8; y: 9; width: parent.width * .40; height: 5; radius: 2; color: "#FFFFFF"; opacity: .9 }
                                Rectangle { x: 8; y: 19; width: parent.width * .26; height: 3; radius: 2; color: "#FFFFFF"; opacity: .65 }
                            }
                        }
                    }
                }
                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: preview.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    anchors.topMargin: 8
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.name
                            color: c.ink
                            font.family: c.uiFont
                            font.pixelSize: Math.round(15 * c.typeScale)
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text { visible: chosen; text: "✓"; color: c.orangeDark; font.pixelSize: 19; font.weight: Font.Black }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: modelData.subtitle
                        color: c.muted
                        font.family: c.uiFont
                        font.pixelSize: Math.round(11 * c.typeScale)
                        elide: Text.ElideRight
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingsBridge.setPackKey(packTile.modelData.key)
                }
            }
        }
    }
}
