// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
import "../buttons" as Duo

Rectangle {
    id: root
    signal actionSelected(string action)
    radius: 17
    color: c.purpleSoft
    border.color: c.line
    implicitHeight: 229
    Theme.Colors { id: c }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 11

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true
                Text {
                    text: "Quick Actions"
                    font.family: "Nunito"
                    font.pixelSize: Math.round(19 * c.typeScale)
                    font.weight: Font.ExtraBold
                    color: c.ink
                }
                Text {
                    text: "Your study tools, one click away"
                    font.family: "Nunito"
                    font.pixelSize: Math.round(14 * c.typeScale)
                    color: c.muted
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 134
            Layout.minimumHeight: 134
            Layout.maximumHeight: 134
            columns: 2
            rowSpacing: 8
            columnSpacing: 12

            Repeater {
                model: [
                    { title: "Ask AI Tutor", subtitle: "Explain & summarise", icon: "ai-tutor", fill: "#9254ED", depth: "#6D28B5", page: "AI Tutor" },
                    { title: "Focus Mode", subtitle: "Pomodoro timer", icon: "focus", fill: "#FF8026", depth: "#C95707", page: "Focus Studio" },
                    { title: "Create Practice", subtitle: "Quizzes & flashcards", icon: "practice", fill: "#3B82F6", depth: "#1D4ED8", page: "Practice Lab" },
                    { title: "Add to Planner", subtitle: "Task or deadline", icon: "planner", fill: "#10A987", depth: "#047857", page: "Study Planner" }
                ]

                delegate: Duo.DuoActionCard {
                    id: actionCard
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 62
                    Layout.minimumHeight: 62
                    Layout.maximumHeight: 62
                    title: modelData.title
                    subtitle: modelData.subtitle
                    iconName: modelData.icon
                    fillColor: modelData.fill
                    depthColor: modelData.depth
                    onActivated: root.actionSelected(actionCard.modelData.page)
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
