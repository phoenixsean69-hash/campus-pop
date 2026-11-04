import QtQuick 2.15
import QtQuick.Layouts 1.15

// Campus Pop | 4-card Study Overview
// Bind its inputs to the existing dashboard metrics; undefined = em dash, not fictitious values.
Item {
    id: overview
    property var courseCount: null
    property var studyHours: null
    property var weeklyGoalPercent: null
    property var streakDays: null
    property bool showHeading: true

    signal coursesClicked()
    signal studyTimeClicked()
    signal weeklyGoalClicked()
    signal studyStreakClicked()

    function known(v) { return v !== undefined && v !== null && String(v) !== ""; }
    function coursesText() { return known(courseCount) ? String(courseCount) : "—"; }
    function hoursText() {
        if (!known(studyHours)) return "—";
        if (typeof studyHours === "number") return studyHours.toFixed(1) + " h";
        var s = String(studyHours).trim();
        return /[hH]$/.test(s) ? s : s + " h";
    }
    function goalText() {
        if (!known(weeklyGoalPercent)) return "—";
        var s = String(weeklyGoalPercent).trim();
        return s.endsWith("%") ? s : s + "%";
    }
    function streakText() {
        if (!known(streakDays)) return "—";
        var s = String(streakDays).trim();
        return /day/i.test(s) ? s : s + " " + (Number(s) === 1 ? "Day" : "Days");
    }

    implicitWidth: 900
    implicitHeight: layout.implicitHeight
    height: implicitHeight

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 14

        RowLayout {
            visible: overview.showHeading
            Layout.fillWidth: true
            spacing: 12
            Rectangle { Layout.preferredWidth: 5; Layout.preferredHeight: 48; radius: 3; color: "#FF8200" }
            ColumnLayout {
                spacing: 1
                Text { text: "Study Overview"; font.family: "Segoe UI"; font.pixelSize: 27; font.weight: Font.Bold; color: "#0B2356" }
                Text { text: "Your learning activity at a glance"; font.family: "Segoe UI"; font.pixelSize: 13; color: "#68748A" }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width < 600 ? 1 : 2
            columnSpacing: 14
            rowSpacing: 8

            NotchedStatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                title: "My Courses"; subtitle: "Enrolled modules"
                iconName: "book"; fillColor: "#1464EF"
                figure: overview.coursesText()
                onClicked: overview.coursesClicked()
            }
            NotchedStatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                title: "Study Time"; subtitle: "Recorded sessions"
                iconName: "clock"; fillColor: "#792DD6"
                figure: overview.hoursText()
                onClicked: overview.studyTimeClicked()
            }
            NotchedStatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                title: "Weekly Goal"; subtitle: "From saved sessions"
                iconName: "target"; fillColor: "#069B76"
                figure: overview.goalText()
                onClicked: overview.weeklyGoalClicked()
            }
            NotchedStatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                title: "Study Streak"; subtitle: "Recorded activity"
                iconName: "flame"; fillColor: "#F96C09"
                figure: overview.streakText()
                onClicked: overview.studyStreakClicked()
            }
        }
    }
}
