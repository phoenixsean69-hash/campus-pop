// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
import "../buttons" as Duo
import "../../data/CourseContent.js" as StudyContent

ColumnLayout {
    id: detail
    required property var courseData
    property string activeTab: "Overview"
    property int selectedTopicIndex: -1
    property int selectedMaterialIndex: -1
    property int selectedAssignmentIndex: -1
    property bool answerRevealed: false
    readonly property var content: StudyContent.findCourse(courseData.code)
    readonly property var activeTopic: content && selectedTopicIndex >= 0 && selectedTopicIndex < content.topics.length ? content.topics[selectedTopicIndex] : null
    readonly property var activeMaterial: content && selectedMaterialIndex >= 0 && selectedMaterialIndex < content.materials.length ? content.materials[selectedMaterialIndex] : null
    readonly property var activeAssignment: content && selectedAssignmentIndex >= 0 && selectedAssignmentIndex < content.assignments.length ? content.assignments[selectedAssignmentIndex] : null
    signal backRequested()
    signal notice(string message)
    signal openPage(string page)
    signal scrollTopRequested()
    spacing: 13
    Theme.Colors { id: c }

    function openTab(name) {
        activeTab = name
        selectedTopicIndex = -1
        selectedMaterialIndex = -1
        selectedAssignmentIndex = -1
        answerRevealed = false
        scrollTopRequested()
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Rectangle {
            Layout.preferredWidth: 127
            Layout.preferredHeight: 38
            radius: 11
            color: "#F1F2F6"
            Text {
                anchors.centerIn: parent
                text: "‹  All courses"
                font.family: c.uiFont
                font.pixelSize: Math.round(14 * c.typeScale)
                font.weight: Font.Bold
                color: c.ink
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: detail.backRequested() }
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "COURSE WORKSPACE"
            font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale)
            font.weight: Font.Bold; font.letterSpacing: 1.0; color: c.muted
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 180
        radius: 19
        color: detail.courseData.soft
        clip: true
        Rectangle {
            width: 225; height: 225; radius: 113
            anchors.right: parent.right; anchors.rightMargin: -58
            anchors.top: parent.top; anchors.topMargin: -63
            color: detail.courseData.accent; opacity: 0.11
        }
        Image {
            anchors.right: parent.right
            anchors.rightMargin: 9
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(148, parent.width * 0.22)
            height: 142
            source: {
                var s=String(detail.courseData.title || "").toLowerCase()
                var icon=s.indexOf("statistic")>=0?"statistics":s.indexOf("python")>=0?"python":s.indexOf("computer")>=0?"systems":s.indexOf("software")>=0?"software":s.indexOf("discrete")>=0?"mathematics":s.indexOf("database")>=0?"database":"general"
                return Qt.resolvedUrl("../../../assets/icons/courses/"+icon+".svg")
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Math.min(158, parent.width*0.23)
            anchors.top: parent.top
            anchors.margins: 22
            spacing: 9
            Text {
                text: detail.courseData.code + "  ·  " + detail.courseData.category
                font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold
                color: detail.courseData.accent
            }
            Text {
                text: detail.courseData.title
                font.family: c.uiFont; font.pixelSize: Math.round(27 * c.typeScale)
                font.weight: Font.ExtraBold; color: c.ink
                Layout.fillWidth: true; elide: Text.ElideRight
            }
            Text {
                text: detail.courseData.topicCount + " learning units  ·  " + (detail.content ? "3 reading resources" : "Course outline pending")
                font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: "#667189"
                Layout.fillWidth: true; elide: Text.ElideRight
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                Text {
                    text: "Course progress"
                    font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.ink
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: detail.courseData.progress + "%"
                    font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
                    font.weight: Font.Bold; color: detail.courseData.accent
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 9; radius: 5
                color: "#FFFFFF"
                Rectangle {
                    width: parent.width * detail.courseData.progress / 100
                    height: parent.height; radius: 5; color: detail.courseData.accent
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 4
        columnSpacing: 8
        Repeater {
            model: ["Overview", "Topics", "Materials", "Assignments"]
            delegate: Rectangle {
                id: tab
                required property string modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 12
                color: detail.activeTab === tab.modelData ? "#FF7113" : "#EFF1F5"
                Text {
                    anchors.centerIn: parent
                    text: tab.modelData
                    font.family: c.uiFont
                    font.weight: Font.Bold
                    font.pixelSize: Math.round(14 * c.typeScale)
                    color: detail.activeTab === tab.modelData ? "#FFFFFF" : "#27324D"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: detail.openTab(tab.modelData)
                }
            }
        }
    }

    // Overview is a reading-friendly summary of each built-in course.
    Rectangle {
        visible: detail.activeTab === "Overview"
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? overviewBody.implicitHeight + 42 : 0
        radius: 18; color: "#FFFFFF"; border.color: "#ECE8E4"
        ColumnLayout {
            id: overviewBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 21; spacing: 12
            Text {
                text: "About this course"
                font.family: c.uiFont; font.pixelSize: Math.round(22 * c.typeScale)
                font.weight: Font.ExtraBold; color: c.ink
            }
            Text {
                Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: detail.content ? detail.content.description : "This course has been added to your library. An academic outline can be added when course editing is connected."
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); lineHeight: 1.25
                color: "#536078"
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#ECE8E4" }
            Text {
                text: "Learning outcomes"
                font.family: c.uiFont; font.pixelSize: Math.round(17 * c.typeScale)
                font.weight: Font.ExtraBold; color: c.ink
                visible: !!detail.content
            }
            Repeater {
                model: detail.content ? detail.content.outcomes : []
                delegate: RowLayout {
                    id: outcome
                    required property string modelData
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        Layout.preferredWidth: 7; Layout.preferredHeight: 7
                        radius: 4; color: detail.courseData.accent
                    }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.WordWrap
                        text: outcome.modelData
                        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: "#33415B"
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#ECE8E4"
                visible: !!detail.content
            }
            Text {
                text: "START HERE"
                font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold
                font.letterSpacing: 1.0; color: detail.courseData.accent
                visible: !!detail.content
            }
            Text {
                text: detail.content ? detail.content.topics[0].title : "No learning units yet"
                font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.Bold
                color: c.ink
            }
            Duo.DuoButton {
                visible: !!detail.content
                Layout.topMargin: 4; Layout.preferredWidth: 204; Layout.preferredHeight: 47
                text: "Start first lesson"; iconText: ""
                fillColor: "#FF7113"; shadowColor: "#C94B04"
                onClicked: {
                    detail.activeTab = "Topics"
                    detail.selectedTopicIndex = 0
                    detail.answerRevealed = false
                    detail.scrollTopRequested()
                }
            }
        }
    }

    // Full list; selecting a lesson reveals substantive notes and a check question.
    Rectangle {
        visible: detail.activeTab === "Topics" && detail.selectedTopicIndex < 0
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? topicList.implicitHeight + 40 : 0
        radius: 18; color: "#FFFFFF"; border.color: "#ECE8E4"
        ColumnLayout {
            id: topicList
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 20; spacing: 10
            Text {
                text: "Learning units"
                font.family: c.uiFont; font.pixelSize: Math.round(22 * c.typeScale)
                font.weight: Font.ExtraBold; color: c.ink
            }
            Text {
                text: detail.content ? "Choose a unit to open its lesson and worked example." : "No lessons have been provided for this newly added course."
                font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted
                Layout.fillWidth: true; wrapMode: Text.WordWrap
            }
            Repeater {
                model: detail.content ? detail.content.topics : []
                delegate: Rectangle {
                    id: topicRow
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 71
                    color: topicRow.index % 2 === 0 ? "#FFF8F2" : "#F6F8FB"
                    radius: 12
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 13
                        Rectangle {
                            Layout.preferredWidth: 35; Layout.preferredHeight: 35; radius: 11
                            color: detail.courseData.soft
                            Text {
                                anchors.centerIn: parent; text: String(topicRow.index+1)
                                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale)
                                font.weight: Font.ExtraBold; color: detail.courseData.accent
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.minimumWidth: 0; spacing: 2
                            Text {
                                Layout.fillWidth: true; elide: Text.ElideRight
                                text: topicRow.modelData.title
                                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale)
                                font.weight: Font.Bold; color: c.ink
                            }
                            Text {
                                Layout.fillWidth: true; elide: Text.ElideRight
                                text: topicRow.modelData.objective
                                font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted
                            }
                        }
                        Text { text: "Read  ›"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: detail.courseData.accent }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            detail.selectedTopicIndex = topicRow.index
                            detail.answerRevealed = false
                            detail.scrollTopRequested()
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: detail.activeTab === "Topics" && detail.activeTopic !== null
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? lessonBody.implicitHeight + 46 : 0
        radius: 18; color: "#FFFFFF"; border.color: "#ECE8E4"
        ColumnLayout {
            id: lessonBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 23; spacing: 13
            Text {
                text: "‹  Back to all units"
                font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold
                color: detail.courseData.accent
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { detail.selectedTopicIndex=-1; detail.answerRevealed=false; detail.scrollTopRequested() }
                }
            }
            Text {
                text: detail.activeTopic ? detail.activeTopic.title : ""
                font.family: c.uiFont; font.pixelSize: Math.round(23 * c.typeScale); font.weight: Font.ExtraBold
                color: c.ink; Layout.fillWidth: true; wrapMode: Text.WordWrap
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: objectiveText.implicitHeight + 24
                radius: 12; color: "#FFF2E5"
                Text {
                    id: objectiveText
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 12
                    text: "OBJECTIVE  ·  " + (detail.activeTopic ? detail.activeTopic.objective : "")
                    font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap; color: "#8A481B"
                }
            }
            Text { text: "Lesson notes"; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text {
                Layout.fillWidth: true; wrapMode: Text.WordWrap; lineHeight: 1.35
                text: detail.activeTopic ? detail.activeTopic.lesson : ""
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); color: "#34425B"
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: exampleBody.implicitHeight + 30
                radius: 13; color: "#E9F2FF"
                ColumnLayout {
                    id: exampleBody
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 15; spacing: 7
                    Text { text: "Worked example"; font.family: c.uiFont; font.pixelSize: Math.round(16 * c.typeScale); font.weight: Font.ExtraBold; color: "#204C91" }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.WordWrap; lineHeight: 1.28
                        text: detail.activeTopic ? detail.activeTopic.example : ""
                        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: "#33415B"
                    }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#ECE8E4" }
            Text { text: "Check your understanding"; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text {
                Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: detail.activeTopic ? detail.activeTopic.question : ""
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.DemiBold; color: "#354157"
            }
            Duo.DuoButton {
                text: detail.answerRevealed ? "Hide answer" : "Reveal answer"
                iconText: ""; compact: true
                Layout.preferredWidth: 168; Layout.preferredHeight: 43
                fillColor: "#2563EB"; shadowColor: "#1746A3"
                onClicked: detail.answerRevealed = !detail.answerRevealed
            }
            Rectangle {
                visible: detail.answerRevealed
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? answerText.implicitHeight + 26 : 0
                radius: 12; color: "#E1F7ED"
                Text {
                    id: answerText
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 13
                    text: detail.activeTopic ? detail.activeTopic.answer : ""
                    font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); wrapMode: Text.WordWrap
                    color: "#19654C"; lineHeight: 1.25
                }
            }
            // CAMPUS_POP_REAL_TOPIC_PROGRESS_V47
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 10
                color: c.tealSoft
                readonly property bool isComplete: {
                    var change = courseProgressBridge.courses
                    return detail.activeTopic !== null && courseProgressBridge.topicCompleted(detail.courseData.code, detail.selectedTopicIndex)
                }
                Text {
                    anchors.centerIn: parent
                    text: parent.isComplete ? "✓ Topic marked completed — click to undo" : "Mark topic completed"
                    color: c.ink
                    font.family: c.uiFont
                    font.pixelSize: Math.round(13 * c.typeScale)
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        courseProgressBridge.setTopicCompleted(detail.courseData.code, detail.selectedTopicIndex, !parent.isComplete)
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.topMargin: 6
                Text {
                    text: "Unit " + (detail.selectedTopicIndex+1) + " of " + (detail.content ? detail.content.topics.length : 0)
                    font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.muted
                }
                Item { Layout.fillWidth: true }
                Duo.DuoButton {
                    visible: !!detail.content && detail.selectedTopicIndex < detail.content.topics.length - 1
                    text: "Next unit"
                    iconText: ""; compact: true
                    Layout.preferredWidth: 138; Layout.preferredHeight: 43
                    fillColor: "#FF7113"; shadowColor: "#C94B04"
                    onClicked: { detail.selectedTopicIndex += 1; detail.answerRevealed=false; detail.scrollTopRequested() }
                }
            }
        }
    }

    // Custom course topics are user-authored, not synthetic lessons.
    Rectangle {
        visible: detail.activeTab === "Topics" && !detail.content
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? customTopicBody.implicitHeight + 36 : 0
        radius: 17; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: customTopicBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 17; spacing: 8
            Text { text: "Your course topics"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(17*c.typeScale); font.bold: true }
            Text { text: "Add the actual topics from your course outline. Mark a topic only when you finish it."; Layout.fillWidth: true; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12*c.typeScale) }
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: newCustomTopic
                    Layout.fillWidth: true
                    placeholderText: "Course topic name"
                }
                Button {
                    text: "Add topic"
                    onClicked: {
                        if (courseProgressBridge.addTopic(detail.courseData.code, newCustomTopic.text))
                            newCustomTopic.text = ""
                        else detail.notice("Enter a unique topic name.")
                    }
                }
            }
            Repeater {
                model: detail.courseData.topics || []
                delegate: Rectangle {
                    required property int index
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 39
                    radius: 9; color: c.surfaceSoft
                    readonly property bool completed: {
                        var change = courseProgressBridge.courses
                        return courseProgressBridge.topicCompleted(detail.courseData.code, index)
                    }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                        Text { Layout.fillWidth: true; text: modelData; color: c.ink; font.family: c.uiFont; elide: Text.ElideRight }
                        Text { text: completed ? "✓ Completed" : "Mark done"; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: 12; font.bold: true }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: courseProgressBridge.setTopicCompleted(detail.courseData.code, index, !completed)
                    }
                }
            }
        }
    }

    // Reading resources are actual in-app text, not falsely labeled uploaded PDFs.
    Rectangle {
        visible: detail.activeTab === "Materials"
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? materialsBody.implicitHeight + 42 : 0
        radius: 18; color: "#FFFFFF"; border.color: "#ECE8E4"
        ColumnLayout {
            id: materialsBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 21; spacing: 11
            Text { text: "Study materials"; font.family: c.uiFont; font.pixelSize: Math.round(22 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text {
                text: detail.content ? "Open a reference sheet, guide or practice set." : "No reference materials have been added to this course yet."
                font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted
                Layout.fillWidth: true; wrapMode: Text.WordWrap
            }
            Repeater {
                model: detail.content ? detail.content.materials : []
                delegate: Rectangle {
                    id: materialRow
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    radius: 12
                    color: detail.selectedMaterialIndex === materialRow.index ? "#FFF0E4" : "#F7F8FB"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 13; spacing: 12
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.minimumWidth: 0; spacing: 3
                            Text { text: materialRow.modelData.title; Layout.fillWidth: true; elide: Text.ElideRight; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                            Text { text: materialRow.modelData.kind + "  ·  " + materialRow.modelData.summary; Layout.fillWidth: true; elide: Text.ElideRight; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted }
                        }
                        Text { text: detail.selectedMaterialIndex === materialRow.index ? "Open" : "Read  ›"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: "#D75C0C" }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { detail.selectedMaterialIndex = materialRow.index; detail.scrollTopRequested() }
                    }
                }
            }
            Rectangle {
                visible: detail.activeMaterial !== null
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? readingBody.implicitHeight + 30 : 0
                radius: 13; color: "#ECF4FF"
                ColumnLayout {
                    id: readingBody
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 15; spacing: 8
                    Text { text: detail.activeMaterial ? detail.activeMaterial.title : ""; font.family: c.uiFont; font.pixelSize: Math.round(17 * c.typeScale); font.weight: Font.ExtraBold; color: "#204C91" }
                    Text { text: detail.activeMaterial ? detail.activeMaterial.body : ""; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); lineHeight: 1.28; color: "#354157" }
                }
            }
        }
    }

    Rectangle {
        visible: detail.activeTab === "Assignments"
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? assignmentsBody.implicitHeight + 42 : 0
        radius: 18; color: "#FFFFFF"; border.color: "#ECE8E4"
        ColumnLayout {
            id: assignmentsBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 21; spacing: 11
            Text { text: "Practice assignments"; font.family: c.uiFont; font.pixelSize: Math.round(22 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text {
                text: detail.content ? "Self-paced practice briefs. No official deadlines or submission records are attached." : "No practice assignments have been added to this course yet."
                font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted
                Layout.fillWidth: true; wrapMode: Text.WordWrap
            }
            Repeater {
                model: detail.content ? detail.content.assignments : []
                delegate: Rectangle {
                    id: assignmentRow
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true; Layout.preferredHeight: 75; radius: 12
                    color: detail.selectedAssignmentIndex === assignmentRow.index ? "#FFF0E4" : "#F7F8FB"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 13; spacing: 12
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.minimumWidth: 0; spacing: 3
                            Text { text: assignmentRow.modelData.title; Layout.fillWidth: true; elide: Text.ElideRight; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                            Text { text: assignmentRow.modelData.focus + "  ·  Self-paced"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                        Text { text: "Details  ›"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: "#D75C0C" }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { detail.selectedAssignmentIndex = assignmentRow.index; detail.scrollTopRequested() }
                    }
                }
            }
            Rectangle {
                visible: detail.activeAssignment !== null
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? briefBody.implicitHeight + 30 : 0
                radius: 13; color: "#ECF4FF"
                ColumnLayout {
                    id: briefBody
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 15; spacing: 10
                    Text { text: "Task brief"; font.family: c.uiFont; font.pixelSize: Math.round(17 * c.typeScale); font.weight: Font.ExtraBold; color: "#204C91" }
                    Text { text: detail.activeAssignment ? detail.activeAssignment.brief : ""; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: "#354157" }
                    Text { text: "Deliverables"; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                    Text { text: detail.activeAssignment ? detail.activeAssignment.deliverables : ""; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: "#354157" }
                    Text { text: "Suggested marking guide"; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                    Text { text: detail.activeAssignment ? detail.activeAssignment.rubric : ""; Layout.fillWidth: true; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: "#354157" }
                }
            }
        }
    }
}
