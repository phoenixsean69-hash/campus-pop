// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: root
    signal courseClicked(string course)
    radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
    implicitHeight: 244
    Theme.Colors { id: c }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 14; spacing: 8
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout { spacing: 0; Text { text: "Continue Learning"; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
Text { text: "Pick up where you left off"; font.pixelSize: Math.round(13 * c.typeScale); color: c.muted } }
            Item { Layout.fillWidth: true }
            Text { text: "View All  →"; color: c.orangeDark; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.courseClicked("My Courses") } }
        }
        Repeater {
            model: [
                {title:"Applied Statistics",topic:"Probability & distributions",percent:65,color:"#FF7316",bg:"#F3E4FF",icon:"▥"},
                {title:"Python Programming",topic:"Functions, OOP & modules",percent:40,color:"#7951EF",bg:"#E6EFFF",icon:"{ }"},
                {title:"Computer Systems",topic:"Memory & concurrency",percent:72,color:"#0DB69B",bg:"#E2F9F2",icon:"▦"}
            ]
            delegate: Rectangle {
                id: item
                required property var modelData
                Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 48; radius: 10
                color: hover.containsMouse ? c.orangeSoft : c.elevated; border.color: c.line
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 9; anchors.rightMargin: 10; spacing: 9
                    Rectangle { Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 10; color: item.modelData.bg; Text { anchors.centerIn: parent; text: item.modelData.icon; color: item.modelData.color; font.pixelSize: Math.round(19 * c.typeScale); font.weight: Font.ExtraBold } }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 3
                        Text { text: item.modelData.title; color: c.ink; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                        Text { text: item.modelData.topic; color: c.muted; font.pixelSize: Math.round(12 * c.typeScale); elide: Text.ElideRight; Layout.fillWidth: true }
                        RowLayout { Layout.fillWidth: true; spacing: 7
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: "#E9EBF4"; Rectangle { width: parent.width * item.modelData.percent / 100; height: parent.height; radius: 3; color: item.modelData.color } }
                            Text { text: item.modelData.percent + "%"; font.pixelSize: Math.round(12 * c.typeScale); color: c.ink; font.weight: Font.Bold }
                        }
                    }
                    Rectangle { Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14; color: "#FFF1DF"; Text { anchors.centerIn: parent; text: "▶"; color: c.orange; font.pixelSize: Math.round(15 * c.typeScale) } }
                }
                MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.courseClicked(item.modelData.title) }
            }
        }
    }
}
