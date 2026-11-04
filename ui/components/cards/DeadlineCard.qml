import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme

// No synthetic assignments: only real, unfinished saved planner tasks.
Rectangle {
    id: root
    implicitHeight: 229
    radius: c.packPop ? 17 : c.panelRadius
    color: c.cardSurface
    border.color: c.cardBorder
    signal openPlanner()
    Theme.Colors { id: c }
    readonly property var upcoming: {
        var all = workspaceBridge.tasks.filter(function(task) { return !task.done })
        all.sort(function(a, b) {
            var aa = a.due || "9999-12-31", bb = b.due || "9999-12-31"
            return aa === bb ? 0 : aa < bb ? -1 : 1
        })
        return all.slice(0, 3)
    }
    function deadlineText(due) {
        if (!due) return "No due date"
        var deadline = new Date(due + "T00:00:00")
        if (isNaN(deadline.getTime())) return "Due: " + due
        var today = new Date()
        today.setHours(0,0,0,0)
        var days = Math.round((deadline.getTime() - today.getTime()) / 86400000)
        if (days < 0) return "Overdue " + Math.abs(days) + "d"
        if (days === 0) return "Due today"
        if (days === 1) return "Due tomorrow"
        return "Due " + due
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 13
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 0
                Text { text: "Upcoming Deadlines"; font.family: c.uiFont; font.pixelSize: Math.round(17*c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                Text { text: "Your saved study tasks"; font.family: c.uiFont; font.pixelSize: Math.round(12*c.typeScale); color: c.muted }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "View All  →"
                color: c.orangeDark
                font.family: c.uiFont
                font.pixelSize: Math.round(13*c.typeScale)
                font.bold: true
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPlanner() }
            }
        }
        Text {
            visible: root.upcoming.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: "No upcoming tasks. Add one in Study Planner."
            wrapMode: Text.WordWrap
            color: c.muted
            font.family: c.uiFont
            font.pixelSize: Math.round(13*c.typeScale)
        }
        Repeater {
            model: root.upcoming
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 38
                radius: 9
                color: c.surfaceSoft
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 9
                    spacing: 7
                    Rectangle { Layout.preferredWidth: 5; Layout.preferredHeight: 30; radius: 2; color: modelData.priority === "High" ? c.danger : c.orange }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text { Layout.fillWidth: true; text: modelData.title || "Untitled task"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(13*c.typeScale); font.bold: true; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: root.deadlineText(modelData.due); color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(11*c.typeScale); elide: Text.ElideRight }
                    }
                    Text { text: String(modelData.priority || "").toUpperCase(); color: c.orangeDark; font.family: c.uiFont; font.bold: true; font.pixelSize: Math.round(10*c.typeScale) }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPlanner() }
            }
        }
    }
}
