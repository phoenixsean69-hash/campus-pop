// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: header
    signal panelToggle()
    signal profileRequested()
    signal notice(string message)
    property bool panelOpen: true
    color: c.surface
    implicitHeight: 68
    Theme.Colors { id: c }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: c.line }
    RowLayout {
        anchors.fill: parent; anchors.leftMargin: 22; anchors.rightMargin: 20; spacing: 16
        Rectangle {
            Layout.preferredWidth: Math.min(480, Math.max(210, header.width * 0.44)); Layout.preferredHeight: 40
            radius: 11; color: c.canvas; border.color: c.line
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 12; spacing: 10
                Image { source: Qt.resolvedUrl("../../../assets/icons/basic-search.svg"); Layout.preferredWidth: 17; Layout.preferredHeight: 17 }
                TextField {
                    Layout.fillWidth: true; placeholderText: "Search courses, notes, topics..."
                    font.pixelSize: Math.round(15 * c.typeScale); color: c.ink; background: Item { }
                    onAccepted: header.notice("Search is part of the next functionality milestone.")
                }
                Rectangle { Layout.preferredWidth: 48; Layout.preferredHeight: 23; radius: 6; color: c.orangeSoft; Text { anchors.centerIn: parent; text: "Ctrl + K"; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted } }
            }
        }
        Item { Layout.fillWidth: true }
        Rectangle {
            Layout.preferredWidth: 37; Layout.preferredHeight: 37; radius: 11; color: c.orangeSoft; border.color: c.line
            Image { anchors.centerIn: parent; width: 19; height: 19; source: Qt.resolvedUrl("../../../assets/icons/basic-panel.svg") }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: header.panelToggle(); hoverEnabled: true; ToolTip.visible: containsMouse; ToolTip.text: "Toggle study panel" }
        }
        Rectangle {
            Layout.preferredWidth: 37; Layout.preferredHeight: 37; radius: 11; color: c.orangeSoft; border.color: c.line
            Image { anchors.centerIn: parent; width: 19; height: 19; source: Qt.resolvedUrl("../../../assets/icons/basic-bell.svg") }
            Rectangle { width: 8; height: 8; radius: 4; color: "#EF4444"; anchors.right: parent.right; anchors.top: parent.top; anchors.rightMargin: 4; anchors.topMargin: 4 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: header.notice("Notifications will be linked to planner events.") }
        }
        // CAMPUS_POP_PROFILE_TOPBAR_V25
        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 29; color: c.line }
        Rectangle {
            Layout.preferredWidth: 184
            Layout.preferredHeight: 46
            radius: 12
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                spacing: 9
                Rectangle {
                    Layout.preferredWidth: 39
                    Layout.preferredHeight: 39
                    radius: 13
                    color: c.orangeSoft
                    clip: true
                    Image { anchors.fill: parent; source: profileBridge.avatarUrl; fillMode: Image.PreserveAspectCrop; visible: profileBridge.avatarUrl.length>0; cache: false }
                    Text { anchors.centerIn: parent; visible: profileBridge.avatarUrl.length===0; text: profileBridge.initials; color: c.orangeDark; font.family: c.uiFont; font.weight: Font.Bold; font.pixelSize: Math.round(14 * c.typeScale) }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text { text: profileBridge.username; font.family: c.uiFont; color: c.ink; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text { text: "Edit profile"; font.family: c.uiFont; color: c.muted; font.pixelSize: Math.round(12 * c.typeScale) }
                }
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: header.profileRequested() }
        }
    }
}
