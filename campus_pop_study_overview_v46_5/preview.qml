import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    width: 1000
    height: 610
    title: "Campus Pop | 2D Study Overview Preview"
    color: "#F6F8FC"
    StudyOverview {
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 24 }
        courseCount: 6
        studyHours: 0
        weeklyGoalPercent: 0
        streakDays: 1
        onCoursesClicked: console.log("My Courses clicked")
        onStudyTimeClicked: console.log("Study Time clicked")
        onWeeklyGoalClicked: console.log("Weekly Goal clicked")
        onStudyStreakClicked: console.log("Study Streak clicked")
    }
}
