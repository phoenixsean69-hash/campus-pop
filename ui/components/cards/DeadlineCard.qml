// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: root
    radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder; implicitHeight: 205
    signal openPlanner()
    Theme.Colors { id: c }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 13; spacing: 9
        RowLayout { Layout.fillWidth: true
            ColumnLayout { spacing: 0; Text { text: "Upcoming Deadlines"; font.pixelSize: Math.round(17 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
Text { text: "Don't miss these important dates"; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted } }
            Item { Layout.fillWidth: true }
            Text { text: "View All  →"; color: c.orangeDark; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPlanner() } }
        }
        Repeater {
            model: [
                {name:"Statistics Assignment 2",due:"Due tomorrow, 11:59 PM",priority:"HIGH",bg:"#FFF0EF",fg:"#D52A39"},
                {name:"Python Project (Part A)",due:"Due Friday",priority:"MED",bg:"#FFF3E3",fg:"#DE7A14"},
                {name:"Computer Systems Quiz",due:"Due Monday",priority:"LOW",bg:"#EAF8F0",fg:"#189E63"}
            ]
            delegate: Rectangle { required property var modelData; Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 35; radius: 10; color: c.dark ? c.elevated : modelData.bg
                RowLayout { anchors.fill: parent; anchors.leftMargin: 9; anchors.rightMargin: 8; spacing: 8
                    Text { text: "▤"; font.pixelSize: Math.round(23 * c.typeScale); color: modelData.fg }
                    ColumnLayout { Layout.fillWidth: true; spacing: 0; Text { text: modelData.name; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: c.ink; elide: Text.ElideRight; Layout.fillWidth: true }
Text { text: modelData.due; font.pixelSize: Math.round(12 * c.typeScale); color: modelData.fg } }
                    Text { text: modelData.priority; font.pixelSize: Math.round(12 * c.typeScale); color: modelData.fg; font.weight: Font.ExtraBold }
                }
            }
        }
    }
}
