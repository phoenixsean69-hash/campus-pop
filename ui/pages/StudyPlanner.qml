// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme
import "../components/workspace" as W
import "../components/charts" as Charts

ColumnLayout {
    id: root
    signal notice(string message)
    spacing: 14
    Theme.Colors { id: c }
    property string filter: "All"
    readonly property var filteredTasks: workspaceBridge.tasks.filter(function(t) {
        return root.filter === "All" || (root.filter === "Open" ? !t.done : t.done)
    })

    W.PageBanner { Layout.fillWidth: true; heading: "Study Planner"; subtitle: "Organise your workload and never lose track of a deadline."; illustration: "hero_02.jpg" }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 620 ? 1 : 3; rowSpacing: 10; columnSpacing: 10
        W.MetricBox { Layout.fillWidth: true; value: String(workspaceBridge.tasks.length); caption: "Total tasks"; tint: c.orangeSoft; accent: c.orange }
        W.MetricBox { Layout.fillWidth: true; value: String(workspaceBridge.openTasks); caption: "Still to do"; tint: "#E8E4FF"; accent: "#7144D8" }
        W.MetricBox { Layout.fillWidth: true; value: String(workspaceBridge.tasks.length - workspaceBridge.openTasks); caption: "Completed"; tint: "#DDF8EE"; accent: "#0B9B7C" }
    }
    GridLayout {
        Layout.fillWidth: true
        columns: root.width < 700 ? 1 : 2
        rowSpacing: 12; columnSpacing: 12
        Rectangle {
            Layout.fillWidth: true; implicitHeight: completeBody.implicitHeight + 34
            radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout {
                id: completeBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: 17; spacing: 9
                W.SectionHeading { Layout.fillWidth: true; heading: "Task progress"; subtitle: "Completion doughnut and deadline urgency" }
                Charts.DonutChart {
                    Layout.fillWidth: true
                    series: [{name:"Completed",value:workspaceBridge.tasks.length-workspaceBridge.openTasks},
                             {name:"Open",value:workspaceBridge.openTasks}]
                    palette: [c.teal,c.orange]
                    centerText: workspaceBridge.tasks.length ? Math.round((workspaceBridge.tasks.length - workspaceBridge.openTasks)*100/workspaceBridge.tasks.length) + "%" : "—"
                    emptyText: "Add a task to see your progress."
                }
                Repeater {
                    model: workspaceBridge.taskUrgency
                    delegate: RowLayout {
                        id: urgencyRow; required property var modelData
                        Layout.fillWidth: true
                        Text { Layout.fillWidth: true; text: urgencyRow.modelData.name; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
                        Text { text: urgencyRow.modelData.value; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: weekBody.implicitHeight + 34
            radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout {
                id: weekBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: 17; spacing: 12
                W.SectionHeading { Layout.fillWidth: true; heading: "Upcoming workload"; subtitle: "Tasks due over the next seven days" }
                Charts.BarChart { Layout.fillWidth: true; series: workspaceBridge.upcomingWeek; barColor: c.orange }
                Text { Layout.fillWidth: true; text: "Due dates use YYYY-MM-DD. Completed tasks are excluded from upcoming workload."; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: compose.implicitHeight + 34; radius: c.packPop ? 17 : c.panelRadius
        color: c.surface; border.color: c.line
        ColumnLayout {
            id: compose
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 17; spacing: 10
            W.SectionHeading { Layout.fillWidth: true; heading: "Create a study task"; subtitle: "Saved on this device automatically." }
            W.TextInputBox { id: taskTitle; Layout.fillWidth: true; placeholderText: "e.g. Finish Statistics Assignment 2" }
            GridLayout {
                Layout.fillWidth: true; columns: root.width < 590 ? 1 : 3; rowSpacing: 8; columnSpacing: 8
                W.TextInputBox { id: taskCourse; Layout.fillWidth: true; placeholderText: "Course / module" }
                W.TextInputBox { id: taskDate; Layout.fillWidth: true; placeholderText: "Due date (YYYY-MM-DD)"; validator: RegularExpressionValidator { regularExpression: /[0-9-]{0,10}/ } }
                W.VisibleCombo {
                    id: taskPriority; Layout.fillWidth: true; Layout.preferredHeight: 43
                    model: ["Medium", "High", "Low"]
                    font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
                    background: Rectangle { radius: 11; color: c.surface; border.color: c.line }
                }
            }
            W.SolidAction {
                text: "Add task"; Layout.alignment: Qt.AlignRight
                onClicked: {
                    if (workspaceBridge.addTask(taskTitle.text, taskCourse.text, taskDate.text, taskPriority.currentText)) {
                        taskTitle.text = ""; taskCourse.text = ""; taskDate.text = ""
                        root.notice("Study task saved.")
                    } else root.notice("Enter a task title and a valid date (YYYY-MM-DD) or leave the date blank.")
                }
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true; spacing: 10
        W.SectionHeading { Layout.fillWidth: true; heading: "Your study tasks"; subtitle: "Tap the circle to mark a task as done." }
        W.VisibleCombo {
            model: ["All", "Open", "Completed"]
            Layout.preferredWidth: 130; Layout.preferredHeight: 42
            font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
            onActivated: root.filter = currentText
            background: Rectangle { radius: 11; color: c.surface; border.color: c.line }
        }
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: taskList.implicitHeight + 25
        radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: taskList
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 13; spacing: 7
            Text {
                visible: root.filteredTasks.length === 0
                text: root.filter === "All" ? "No tasks yet. Add your first study task above." : "No tasks match this filter."
                Layout.fillWidth: true; Layout.preferredHeight: 72
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); color: c.muted
                verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
            }
            Repeater {
                model: root.filteredTasks
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true; Layout.preferredHeight: 76; radius: 12
                    color: modelData.done ? c.elevated : c.orangeSoft
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 25; Layout.preferredHeight: 25; radius: 13
                            color: row.modelData.done ? c.success : c.surface
                            border.width: 2; border.color: row.modelData.done ? c.success : c.orange
                            Text { anchors.centerIn: parent; text: "✓"; visible: row.modelData.done; color: "white"; font.pixelSize: Math.round(17 * c.typeScale); font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: workspaceBridge.toggleTask(row.modelData.id) }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 3
                            Text { Layout.fillWidth: true; text: row.modelData.title; font.family: c.uiFont; font.pixelSize: Math.round(16 * c.typeScale); font.weight: Font.Bold; color: c.ink; elide: Text.ElideRight; font.strikeout: row.modelData.done }
                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.course + (row.modelData.due.length ? "  •  Due " + row.modelData.due : "") + "  •  " + row.modelData.priority
                                font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted; elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: 55; Layout.preferredHeight: 33; radius: 10; color: "#FFF1EB"
                            Text { anchors.centerIn: parent; text: "Delete"; color: "#B94A30"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: workspaceBridge.deleteTask(row.modelData.id) }
                        }
                    }
                }
            }
        }
    }
}
