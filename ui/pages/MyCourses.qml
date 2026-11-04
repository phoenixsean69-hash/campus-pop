// CAMPUS_POP_PACKS_V34
// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme
import "../components/buttons" as Duo
import "../components/courses" as Courses

ColumnLayout {
    id: root
    spacing: 13
    signal notice(string message)
    signal openPage(string page)
    signal requestScrollTop()
    property string searchTerm: ""
    property string filterMode: "All courses"
    property string sortMode: "Title"
    property var selectedCourse: null
    property var courses: [
        { title: "Applied Statistics", code: "STA 201", initials: "AS", category: "Mathematics", lecturer: "Course lecturer", topic: "Data types and study design", progress: 65, topicCount: 8, accent: "#F97316", soft: "#FFF0E4", topics: ["Data types and study design", "Descriptive statistics", "Probability foundations", "Conditional probability and Bayes", "Discrete distributions", "Normal distribution and z-scores", "Confidence intervals", "Hypothesis testing and interpretation"] },
        { title: "Python Programming", code: "CSC 203", initials: "PY", category: "Programming", lecturer: "Course lecturer", topic: "Values, variables and types", progress: 40, topicCount: 8, accent: "#2563EB", soft: "#E9F1FF", topics: ["Values, variables and types", "Conditions and loops", "Lists, tuples, sets and dictionaries", "Functions and scope", "Classes and objects", "Files, paths and exceptions", "Modules, packages and environments", "Testing and debugging"] },
        { title: "Computer Systems", code: "CSC 214", initials: "CS", category: "Computing", lecturer: "Course lecturer", topic: "Computer architecture", progress: 72, topicCount: 8, accent: "#8793A7", soft: "#EFF2F6", topics: ["Computer architecture", "Binary representation and logic", "CPU performance and caches", "Memory hierarchy and virtual memory", "Processes, threads and scheduling", "Synchronization and deadlocks", "Storage systems and file systems", "Networks and system diagnostics"] },
        { title: "Software Engineering", code: "SWE 210", initials: "SE", category: "Engineering", lecturer: "Course lecturer", topic: "Software lifecycle and process models", progress: 100, topicCount: 8, accent: "#2563EB", soft: "#E9F1FF", topics: ["Software lifecycle and process models", "Requirements engineering", "UML and system modelling", "Modularity and design principles", "Version control and collaboration", "Software testing strategy", "Quality, security and maintainability", "Project estimation and delivery"] },
        { title: "Discrete Mathematics", code: "MTH 220", initials: "DM", category: "Mathematics", lecturer: "Course lecturer", topic: "Propositional logic", progress: 34, topicCount: 8, accent: "#F97316", soft: "#FFF0E4", topics: ["Propositional logic", "Predicate logic and quantifiers", "Sets and operations", "Relations and functions", "Counting and combinatorics", "Proof methods", "Graphs and trees", "Recurrence and algorithm analysis"] },
        { title: "Database Systems", code: "CSC 216", initials: "DB", category: "Computing", lecturer: "Course lecturer", topic: "Database concepts and DBMS", progress: 0, topicCount: 8, accent: "#8793A7", soft: "#EFF2F6", topics: ["Database concepts and DBMS", "Entity-relationship modelling", "Relational keys and constraints", "SQL SELECT and filtering", "Joins and aggregation", "Normalization and anomalies", "Transactions and ACID", "Indexes, access control and backups"] }
    ]
    readonly property int inProgressCount: courses.filter(function(course) { return course.progress > 0 && course.progress < 100 }).length
    readonly property int completedCount: courses.filter(function(course) { return course.progress >= 100 }).length
    readonly property var filteredCourses: {
        var term = root.searchTerm.toLowerCase().trim()
        var result = root.courses.filter(function(course) {
            var matches = !term || course.title.toLowerCase().includes(term) || course.code.toLowerCase().includes(term) || course.category.toLowerCase().includes(term)
            if (root.filterMode === "In progress") return matches && course.progress > 0 && course.progress < 100
            if (root.filterMode === "Completed") return matches && course.progress >= 100
            if (root.filterMode === "Not started") return matches && course.progress === 0
            return matches
        })
        if (root.sortMode === "Progress") result.sort(function(a,b) {return b.progress - a.progress})
        else result.sort(function(a,b) {return a.title.localeCompare(b.title)})
        return result
    }
    Theme.Colors { id: c }

    ColumnLayout {
        id: listing
        Layout.fillWidth: true
        visible: root.selectedCourse === null
        spacing: 13

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 188
            radius: c.packPop ? 21 : c.panelRadius
            color: c.packPop ? "#FFE1C3" : c.heroSurface
            clip: true
            Image {
                visible: c.showArt
                opacity: c.packStudio ? 0.16 : c.packPaper ? 0.76 : 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.min(360, parent.width * 0.46)
                source: Qt.resolvedUrl("../../assets/illustrations/students/hero_08.jpg")
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Math.min(360, parent.width * 0.46) - 55
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 55
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: c.packPop ? "#FFE1C3" : c.heroSurface }
                    GradientStop { position: 1.0; color: "#00FFE1C3" }
                }
            }
            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 23
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7
                Text { text: "ACADEMIC WORKSPACE"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; font.letterSpacing: 1.2; color: c.packPop ? "#A14C13" : c.orangeDark }
                Text { text: "My Courses"; font.family: c.uiFont; font.pixelSize: Math.round(32 * c.typeScale); font.weight: Font.ExtraBold; color: c.packPop ? "#49230E" : c.ink }
                Text {
                    text: "Organize modules. Pick up where you left off."
                    font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
                    color: c.packPop ? "#84523E" : c.muted
                }
                Duo.DuoButton {
                    Layout.topMargin: 7
                    Layout.preferredHeight: 44
                    Layout.preferredWidth: 145
                    compact: true
                    text: "Add course"
                    iconText: ""
                    fillColor: "#FF7113"; shadowColor: "#C94B04"
                    onClicked: addCourseDialog.open()
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.width < 710 ? 1 : 3
            columnSpacing: 10
            rowSpacing: 10
            Repeater {
                model: [
                    { heading: "My modules", value: String(root.courses.length), color: "#F97316", surface: "#FFF0E5", description: "Course library" },
                    { heading: "In progress", value: String(root.inProgressCount), color: "#8651E7", surface: "#F2E8FF", description: "Currently learning" },
                    { heading: "Completed", value: String(root.completedCount), color: "#0CA78D", surface: "#DDF7EF", description: "Courses finished" }
                ]
                delegate: Rectangle {
                    id: metric
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 94
                    radius: 17
                    color: c.packStudio ? c.cardSurface : c.packPaper ? c.elevated : metric.modelData.surface
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 17
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { text: metric.modelData.value; font.family: c.uiFont; font.pixelSize: Math.round(29 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                            Text { text: metric.modelData.heading; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                            Text { text: metric.modelData.description; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); color: c.muted }
                        }
                        Rectangle {
                            Layout.preferredWidth: 9
                            Layout.preferredHeight: 47
                            radius: 5
                            color: c.packStudio ? c.orange : c.packPaper ? c.orangeDark : metric.modelData.color
                            opacity: 0.83
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 121
            radius: 17
            color: "#FFFFFF"
            border.color: "#EFE7E2"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 9
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        radius: 12
                        color: "#F7F8FB"
                        TextField {
                            id: searchField
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            placeholderText: "Search courses, codes or categories..."
                            placeholderTextColor: "#9AA2B5"
                            color: c.ink
                            font.family: c.uiFont
                            font.pixelSize: Math.round(14 * c.typeScale)
                            background: Item {}
                            onTextChanged: root.searchTerm = text
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 154
                        Layout.preferredHeight: 45
                        radius: 12
                        color: "#FFF1E3"
                        ComboBox {
                            id: sortBox
                            anchors.fill: parent
                            model: ["Sort: Name", "Sort: Progress"]
                            font.family: c.uiFont
                            font.pixelSize: Math.round(13 * c.typeScale)
                            onActivated: root.sortMode = currentIndex === 0 ? "Title" : "Progress"
                            background: Rectangle { color: "transparent" }
                        }
                    }
                }
                Flow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 33
                    spacing: 8
                    Repeater {
                        model: ["All courses", "In progress", "Completed", "Not started"]
                        delegate: Rectangle {
                            id: chip
                            required property string modelData
                            implicitWidth: chipText.implicitWidth + 23
                            height: 31
                            radius: 10
                            color: root.filterMode === chip.modelData ? "#FF7113" : "#F2F3F7"
                            Text {
                                id: chipText
                                anchors.centerIn: parent
                                text: chip.modelData
                                font.family: c.uiFont
                                font.pixelSize: Math.round(13 * c.typeScale)
                                font.weight: Font.Bold
                                color: root.filterMode === chip.modelData ? "#FFFFFF" : "#53607C"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.filterMode = chip.modelData
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 6
            Text {
                text: "Your course library"
                font.family: c.uiFont
                font.pixelSize: Math.round(22 * c.typeScale)
                font.weight: Font.ExtraBold
                color: c.ink
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.filteredCourses.length + (root.filteredCourses.length === 1 ? " course" : " courses")
                font.family: c.uiFont
                font.pixelSize: Math.round(13 * c.typeScale)
                font.weight: Font.DemiBold
                color: c.muted
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.width < 755 ? 1 : 2
            columnSpacing: 12
            rowSpacing: 12
            Repeater {
                model: root.filteredCourses
                delegate: Courses.CourseTile {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 270
                    courseData: modelData
                    onOpenRequested: {
                        root.selectedCourse = modelData
                        detailPage.openTab("Overview")
                        root.requestScrollTop()
                    }
                }
            }
        }

        Rectangle {
            visible: root.filteredCourses.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 155 : 0
            color: "#FFFFFF"; radius: 17; border.color: c.line
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                Text { text: "No matching courses"; font.family: c.uiFont; font.pixelSize: Math.round(20 * c.typeScale); font.weight: Font.Bold; color: c.ink; Layout.alignment: Qt.AlignHCenter }
                Text { text: "Try another search or change the filter."; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted; Layout.alignment: Qt.AlignHCenter }
            }
        }
        Text {
            text: "Preview courses are illustrative. Data persistence will be added with the backend."
            Layout.fillWidth: true
            Layout.topMargin: 4
            horizontalAlignment: Text.AlignHCenter
            font.family: c.uiFont
            font.pixelSize: Math.round(12 * c.typeScale)
            color: "#9B92A1"
        }
    }

    Courses.CourseDetail {
        id: detailPage
        Layout.fillWidth: true
        visible: root.selectedCourse !== null
        courseData: root.selectedCourse === null ? root.courses[0] : root.selectedCourse
        onBackRequested: { root.selectedCourse = null; root.requestScrollTop() }
        onScrollTopRequested: root.requestScrollTop()
        onNotice: function(message) { root.notice(message) }
        onOpenPage: function(page) { root.openPage(page) }
    }

    Dialog {
        id: addCourseDialog
        parent: Overlay.overlay
        modal: true
        focus: true
        width: Math.min(480, parent ? parent.width - 40 : 480)
        x: parent ? Math.round((parent.width - width) / 2) : 0
        y: parent ? Math.round((parent.height - height) / 2) : 0
        padding: 22
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#FFFFFF"; radius: 22; border.color: "#ECE5DF" }
        header: Item { implicitHeight: 0 }
        footer: Item { implicitHeight: 0 }
        contentItem: ColumnLayout {
            spacing: 12
            Text { text: "Add a course"; font.family: c.uiFont; font.pixelSize: Math.round(25 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
            Text { text: "Set up a course card for this UI preview."; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted }
            Text { text: "COURSE NAME"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: c.ink }
            TextField {
                id: titleInput
                Layout.fillWidth: true; Layout.preferredHeight: 46
                placeholderText: "e.g. Data Structures"
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale)
                color: c.ink
                background: Rectangle { color: "#F7F8FC"; radius: 11; border.color: "#E8EAF0" }
            }
            Text { text: "COURSE CODE"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: c.ink }
            TextField {
                id: codeInput
                Layout.fillWidth: true; Layout.preferredHeight: 46
                placeholderText: "e.g. CSC 301"
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale)
                color: c.ink
                background: Rectangle { color: "#F7F8FC"; radius: 11; border.color: "#E8EAF0" }
            }
            Text { text: "CATEGORY"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: c.ink }
            TextField {
                id: categoryInput
                Layout.fillWidth: true; Layout.preferredHeight: 46
                placeholderText: "e.g. Computing"
                font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale)
                color: c.ink
                background: Rectangle { color: "#F7F8FC"; radius: 11; border.color: "#E8EAF0" }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.topMargin: 6
                Rectangle {
                    Layout.preferredWidth: 95; Layout.preferredHeight: 46; radius: 12
                    color: "#F1F2F6"
                    Text { anchors.centerIn: parent; text: "Cancel"; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addCourseDialog.close() }
                }
                Item { Layout.fillWidth: true }
                Duo.DuoButton {
                    text: "Add course"; iconText: ""; compact: true
                    Layout.preferredWidth: 145; Layout.preferredHeight: 46
                    fillColor: "#FF7113"; shadowColor: "#C94B04"
                    onClicked: {
                        var name = titleInput.text.trim()
                        var code = codeInput.text.trim()
                        if (!name || !code) {
                            root.notice("Enter a course name and course code.")
                            return
                        }
                        var category = categoryInput.text.trim() || "General"
                        root.courses = root.courses.concat([{
                            title: name, code: code.toUpperCase(), initials: name.substring(0, 2).toUpperCase(),
                            category: category, lecturer: "Course lecturer", topic: "Getting started",
                            progress: 0, topicCount: 0, accent: "#2584EB", soft: "#E5F1FF",
                            topics: ["Introduction", "Course outline", "Learning resources"]
                        }])
                        root.filterMode = "All courses"
                        root.searchTerm = ""
                        searchField.text = ""
                        titleInput.text = ""
                        codeInput.text = ""
                        categoryInput.text = ""
                        addCourseDialog.close()
                        root.notice("Course added to the UI preview (not saved yet).")
                    }
                }
            }
        }
    }
}
