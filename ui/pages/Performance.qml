// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme
import "../components/workspace" as W
import "../components/charts" as Charts
ColumnLayout {
    id: root
    spacing: 14
    Theme.Colors { id: c }
    readonly property int goal: settingsBridge.weeklyGoal * 60
    readonly property int achieved: workspaceBridge.weeklyFocusMinutes
    readonly property var goalSplit: [{name:"Completed",value:Math.min(goal,achieved)},{name:"Remaining",value:Math.max(0,goal-achieved)}]
    W.PageBanner { Layout.fillWidth: true; heading: "Performance"; subtitle: "Your learning activity, measured from actual sessions and practice."; illustration: "hero_13.jpg" }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 670 ? 2 : 4; rowSpacing: 10; columnSpacing: 10
        W.MetricBox { Layout.fillWidth: true; value: (workspaceBridge.totalFocusMinutes/60).toFixed(1) + "h"; caption: "Total focus"; tint: c.orangeSoft; accent: c.orangeDark }
        W.MetricBox { Layout.fillWidth: true; value: (workspaceBridge.weeklyFocusMinutes/60).toFixed(1) + "h"; caption: "This week"; tint: c.purpleSoft; accent: c.purple }
        W.MetricBox { Layout.fillWidth: true; value: String(workspaceBridge.quizCount); caption: "Practice sessions"; tint: c.tealSoft; accent: c.teal }
        W.MetricBox { Layout.fillWidth: true; value: workspaceBridge.quizCount ? workspaceBridge.quizAccuracy + "%" : "—"; caption: "Practice accuracy"; tint: c.amberSoft; accent: c.orangeDark }
    }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 740 ? 1 : 2; rowSpacing: 12; columnSpacing: 12
        Rectangle {
            Layout.fillWidth: true; implicitHeight: timeBody.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout { id: timeBody; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 18; spacing: 8
                W.SectionHeading { Layout.fillWidth: true; heading: "Study time by course"; subtitle: "Pie chart · recorded focus sessions" }
                Charts.DonutChart { Layout.fillWidth: true; series: workspaceBridge.courseFocus; donut: false; emptyText: "Start a Focus Studio session to see course distribution." }
            }
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: goalBody.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout { id: goalBody; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 18; spacing: 8
                W.SectionHeading { Layout.fillWidth: true; heading: "Weekly goal"; subtitle: "Doughnut chart · minutes completed / planned" }
                Charts.DonutChart { Layout.fillWidth: true; series: root.goalSplit; donut: true; palette: [c.orange, c.line]; centerText: Math.min(100,Math.round(root.achieved / Math.max(1, root.goal) * 100)) + "%" }
                Text { Layout.fillWidth: true; text: root.achieved + " of " + root.goal + " planned minutes"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.muted; horizontalAlignment: Text.AlignHCenter }
            }
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: barBody.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout { id: barBody; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 18; spacing: 9
                W.SectionHeading { Layout.fillWidth: true; heading: "Weekly focus"; subtitle: "Bar chart · daily minutes, last seven days" }
                Charts.BarChart { Layout.fillWidth: true; series: workspaceBridge.dailyFocus.map(function(d) {return {name:d.day, value:d.minutes}}); barColor: c.orange; emptyText: "No recorded focus this week." }
            }
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: quizBody.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout { id: quizBody; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 18; spacing: 9
                W.SectionHeading { Layout.fillWidth: true; heading: "Practice accuracy"; subtitle: "Bar chart · by course" }
                Charts.BarChart { Layout.fillWidth: true; series: workspaceBridge.courseAccuracy; barColor: c.teal; emptyText: "Complete a quiz to see accuracy by course." }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: topicBody.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: topicBody; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 18; spacing: 10
            W.SectionHeading { Layout.fillWidth: true; heading: "Topic mastery signals"; subtitle: "Only based on attempted questions; not a formal mastery diagnosis." }
            Text { visible: workspaceBridge.topicAccuracy.length === 0; Layout.fillWidth: true; text: "No topic-level scores yet. Try a topic-filtered quiz in Practice Lab."; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); wrapMode: Text.WordWrap }
            Repeater { model: workspaceBridge.topicAccuracy
                delegate: ColumnLayout { id: topicRow; required property var modelData; Layout.fillWidth: true; spacing: 5
                    RowLayout { Layout.fillWidth: true
                        Text { Layout.fillWidth: true; text: topicRow.modelData.name; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                        Text { text: topicRow.modelData.value + "%"; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    }
                    Rectangle { Layout.fillWidth: true; height: 9; radius: 4; color: c.line
                        Rectangle { width: parent.width * Math.min(1, topicRow.modelData.value/100); height: parent.height; radius: 4; color: c.teal }
                    }
                }
            }
        }
    }
}
