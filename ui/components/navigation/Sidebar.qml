// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: sidebar
    property string currentPage: "Dashboard"
    property bool reduceMotion: false
    signal pageSelected(string page)
    color: c.surface
    implicitWidth: 252
    Theme.Colors { id: c }

    Rectangle { anchors.right: parent.right; height: parent.height; width: 1; color: c.line }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 13
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            spacing: 2
            Text {
                text: "Campus Pop"
                font.family: c.uiFont
                font.pixelSize: Math.round(24 * c.typeScale)
                font.weight: Font.ExtraBold
                color: c.ink
            }
            Text {
                text: "University Study Partner"
                font.family: c.uiFont
                font.pixelSize: Math.round(12 * c.typeScale)
                font.weight: Font.Medium
                color: c.muted
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: c.line }
        Text {
            Layout.leftMargin: 12
            Layout.topMargin: 13
            Layout.bottomMargin: 7
            text: "STUDY WORKSPACE"
            color: c.muted
            font.family: c.uiFont
            font.pixelSize: Math.round(13 * c.typeScale)
            font.weight: Font.Bold
            font.letterSpacing: 1.4
        }

        Repeater {
            model: [
                { title:"Dashboard",icon:"dashboard" }, { title:"My Courses",icon:"courses" },
                { title:"AI Tutor",icon:"ai-tutor" }, { title:"Study Planner",icon:"planner" },
                { title:"Practice Lab",icon:"practice" }, { title:"Focus Studio",icon:"focus" },
                { title:"Performance",icon:"performance" }
            ]
            delegate: Rectangle {
                id: navItem
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 12
                readonly property bool selected: sidebar.currentPage === modelData.title
                color: selected ? c.orangeSoft : itemHover.containsMouse ? c.surfaceSoft : "transparent"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 12
                    spacing: 10
                    AnimatedNavIcon {
                        Layout.preferredWidth: 29
                        Layout.preferredHeight: 29
                        iconName: navItem.modelData.icon
                        hovered: itemHover.containsMouse
                        reducedMotion: sidebar.reduceMotion
                    }
                    Text {
                        text: navItem.modelData.title
                        font.family: c.uiFont
                        font.pixelSize: Math.round(16 * c.typeScale)
                        color: navItem.selected ? c.orangeDark : c.ink
                        font.weight: navItem.selected ? Font.ExtraBold : Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle { visible: navItem.selected; width: 6; height: 6; radius: 3; color: c.orange }
                }
                MouseArea { id: itemHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sidebar.pageSelected(navItem.modelData.title) }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; Layout.topMargin: 10; Layout.bottomMargin: 9; color: c.line }

        Repeater {
            model: [ {title:"Notes & Files",icon:"notes"}, {title:"Resources",icon:"resources"}, {title:"Settings",icon:"settings"} ]
            delegate: Rectangle {
                id: extra
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 10
                readonly property bool selected: sidebar.currentPage === extra.modelData.title
                color: selected ? c.orangeSoft : exMouse.containsMouse ? c.surfaceSoft : "transparent"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 11
                    spacing: 11
                    AnimatedNavIcon {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        iconName: extra.modelData.icon
                        hovered: exMouse.containsMouse
                        reducedMotion: sidebar.reduceMotion
                    }
                    Text {
                        text: extra.modelData.title
                        color: selected ? c.orangeDark : c.ink
                        font.family: c.uiFont
                        font.pixelSize: Math.round(15 * c.typeScale)
                        font.weight: selected ? Font.Bold : Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                }
                MouseArea { id: exMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sidebar.pageSelected(extra.modelData.title) }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 7 }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            radius: 15
            color: c.orangeSoft
            clip: true
            Rectangle { width: 100; height: 100; radius: 50; x: 140; y: -56; color: c.dark ? "#4A4328" : "#FFE1A5"; opacity: 0.9 }
            Rectangle { width: 70; height: 70; radius: 35; x: -25; y: 82; color: c.dark ? "#544026" : "#FFDDA1"; opacity: 0.9 }
            Text { x: 13; y: 14; text: "✦  Keep it going!"; font.family: c.uiFont; font.pixelSize: Math.round(16 * c.typeScale); font.weight: Font.Bold; color: c.orangeDark }
            Text { x: 13; y: 42; text: "1-day learning streak"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale) }
            Row {
                x: 13; y: 72; spacing: 6
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        width: 26; height: 26; radius: 13
                        color: index < 1 ? c.orange : c.dark ? "#D6DCEC" : "#E4E7F4"
                        Text { anchors.centerIn: parent; text: index < 1 ? "✓" : ""; font.pixelSize: Math.round(16 * c.typeScale); color: "white"; font.bold: true }
                    }
                }
            }
        }
    }
}
