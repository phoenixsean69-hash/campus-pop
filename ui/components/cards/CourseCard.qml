import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme

Rectangle {
    id: course
    property string courseTitle: "Course"
    property string subtitle: "Current topic"
    property int progress: 0
    property color accent: "#F97316"
    property color accentSoft: "#FFF0E4"
    signal clicked()
    implicitHeight: 136
    radius: 16; color: "white"; border.color: "#F0E8E0"
    Theme.Colors { id: colors }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8
        RowLayout {
            spacing: 10
            Rectangle {
                Layout.preferredWidth: 38; Layout.preferredHeight: 38
                color: course.accentSoft; radius: 11
                Text { anchors.centerIn: parent; text: "✦"; color: course.accent; font.pixelSize: 22 }
            }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 3
                Text { text: course.courseTitle; color: colors.ink; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: course.subtitle; color: colors.muted; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
            }
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Learning progress"; color: colors.muted; font.pixelSize: 13 }
            Item { Layout.fillWidth: true }
            Text { text: course.progress + "%"; color: course.accent; font.pixelSize: 14; font.bold: true }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 7
            radius: 4; color: "#F0F0F3"
            Rectangle { width: parent.width * course.progress / 100; height: parent.height; radius: 4; color: course.accent }
        }
    }
    MouseArea {
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: course.clicked()
    }
}
