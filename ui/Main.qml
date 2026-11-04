import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "theme" as Theme
import "components/onboarding" as Onboard
import "components/navigation" as Nav
import "components/cards" as Cards
import "components/charts" as Charts
import "components/assistant" as Assistant
import "pages" as Pages
ApplicationWindow {
    id: window
    width: 1640; height: 910
    minimumWidth: 1050; minimumHeight: 680
    visible: true
    // CAMPUS_POP_BRAND_V22
    title: "Campus Pop — Your University Study Partner"
    color: c.canvas
    // CAMPUS_POP_MAIN_PACKS_V33
    Theme.Colors { id: c }
    // STUDYSPACE_ALL_SCREENS_V19
    property string activePage: "Dashboard"
    onActivePageChanged: scroller.contentY = 0
    property bool panelExpanded: true
    readonly property bool showPanel: panelExpanded && width >= 1130 && activePage === "Dashboard"
    function activeContentHeight() {
        switch (activePage) {
            case "Dashboard": return dashboard.implicitHeight
            case "My Courses": return coursesPage.implicitHeight
            case "Study Planner": return plannerPage.implicitHeight
            case "Practice Lab": return practicePage.implicitHeight
            case "Focus Studio": return focusPage.implicitHeight
            case "Performance": return performancePage.implicitHeight
            case "Notes & Files": return notesPage.implicitHeight
            case "Resources": return resourcesPage.implicitHeight
            case "Settings": return settingsPage.implicitHeight
            default: return secondary.implicitHeight
        }
    }
    property string toastMessage: ""
    function showNotice(message) { toastMessage = message; toast.visible = true; toastTimer.restart() }
    Timer { id: toastTimer; interval: 3300; onTriggered: toast.visible = false }

    RowLayout { anchors.fill: parent; spacing: 0
        Nav.Sidebar { Layout.preferredWidth: 252; Layout.fillHeight: true; currentPage: window.activePage; onPageSelected: function(page) { window.activePage = page; scroller.contentY = 0 } }
        ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0
            Nav.TopBar { onProfileRequested: window.activePage = "Settings"; Layout.fillWidth: true; Layout.preferredHeight: 68; panelOpen: window.showPanel; onPanelToggle: window.panelExpanded = !window.panelExpanded; onNotice: function(message) {window.showNotice(message)} }
            Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: c.canvas
                RowLayout { anchors.fill: parent; anchors.margins: c.pagePadding; spacing: c.compact ? 9 : 13
                    Flickable {
                        id: scroller
                        // CAMPUS_POP_NATIVE_SCROLL_V43_BEGIN
                        // Let Qt 6 choose platform-default wheel/touchpad momentum and pixel precision.
                        // CAMPUS_POP_NATIVE_SCROLL_V43_END

                        // CAMPUS_POP_SCROLL_STABILITY_V30
                        // The page's implicitHeight may change during rendering, resizing or
                        // async image loading. Debounce that measurement rather than changing
                        // the Flickable's content range during an active drag/flick.
                        readonly property real measuredPageHeight: Math.max(height, window.activeContentHeight() + 24)
                        property real settledPageHeight: 0
                        onMeasuredPageHeightChanged: scrollHeightSettler.restart()
                        onWidthChanged: scrollHeightSettler.restart()
                        onHeightChanged: scrollHeightSettler.restart()
                        onMovingChanged: {
                            if (!moving) scrollHeightSettler.restart()
                        }
                        Component.onCompleted: scrollHeightSettler.restart()
                        Timer {
                            id: scrollHeightSettler
                            interval: 64
                            repeat: false
                            onTriggered: {
                                // Never change the scrollable extent while the user is flicking.
                                if (scroller.moving || scroller.dragging || scroller.flicking) {
                                    restart()
                                    return
                                }
                                var wanted = scroller.measuredPageHeight
                                if (!isFinite(wanted) || wanted < scroller.height)
                                    wanted = scroller.height
                                wanted = Math.ceil(wanted)
                                if (Math.abs(scroller.settledPageHeight - wanted) > 0.5)
                                    scroller.settledPageHeight = wanted
                                // Restore a valid scroll offset when a page gets shorter.
                                var bottom = Math.max(0, scroller.contentHeight - scroller.height)
                                if (scroller.contentY > bottom)
                                    scroller.contentY = bottom
                                else if (scroller.contentY < 0)
                                    scroller.contentY = 0
                            }
                        }
                        visible: window.activePage !== "AI Tutor"
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true
                        contentWidth: width
                        contentHeight: Math.max(height, settledPageHeight)
                        boundsBehavior: Flickable.StopAtBounds
                        boundsMovement: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; interactive: true }
                        ColumnLayout {
                            id: dashboard; width: scroller.width - 5; spacing: 11
                            visible: window.activePage === "Dashboard"
                            Cards.HeroBanner { Layout.fillWidth: true; Layout.preferredHeight: 186; onStartStudy: window.activePage="Focus Studio"; onAskTutor: window.activePage="AI Tutor" }
                            GridLayout { Layout.fillWidth: true; columns: scroller.width < 690 ? 2 : 4; columnSpacing: 9; rowSpacing: 9
                                Cards.StatCard { Layout.fillWidth: true; Layout.preferredHeight: 111; value:"6"; label:"Courses"; helper:"My modules"; icon:"book"; tint:c.orange; tintSurface:"#FFE8DA" }
                                Cards.StatCard { Layout.fillWidth: true; Layout.preferredHeight: 111; value:(workspaceBridge.totalFocusMinutes / 60).toFixed(1) + " h"; label:"Study hours"; helper:"Recorded sessions"; icon:"timer"; iconHue:"purple"; tint:c.purple; tintSurface:"#EDE1FC" }
                                Cards.StatCard { Layout.fillWidth: true; Layout.preferredHeight: 111; value:Math.round(Math.min(100, 100 * workspaceBridge.weeklyFocusMinutes / (settingsBridge.weeklyGoal * 60))) + "%"; label:"Weekly goal"; helper:"From saved sessions"; icon:"target"; iconHue:"teal"; tint:c.teal; tintSurface:"#DDF7EE" }
                                Cards.StatCard { Layout.fillWidth: true; Layout.preferredHeight: 111; value:String(workspaceBridge.streakDays); label:"Day streak"; helper:"Recorded activity"; icon:"flame"; tint:c.orange; tintSurface:"#FFF0C5" }
                            }
                            GridLayout { Layout.fillWidth: true; columns: scroller.width < 730 ? 1 : 2; columnSpacing: 11; rowSpacing: 11
                                Cards.LearningCard { Layout.fillWidth: true; Layout.preferredHeight: 275; onCourseClicked: function(page) { window.activePage = "My Courses" } }
                                Charts.WeeklyChart { Layout.fillWidth: true; Layout.preferredHeight: 275 }
                                Cards.DeadlineCard { Layout.fillWidth: true; Layout.preferredHeight: 229; onOpenPlanner: window.activePage = "Study Planner" }
                                Cards.QuickActions { Layout.fillWidth: true; Layout.preferredHeight: 229; onActionSelected: function(page) {window.activePage=page} }
                            }
                        }
                        Pages.MyCourses {
                            id: coursesPage
                            width: scroller.width - 5
                            visible: window.activePage === "My Courses"
                            onNotice: function(message) { window.showNotice(message) }
                            onOpenPage: function(page) { window.activePage = page }
                            onRequestScrollTop: scroller.contentY = 0
                        }
                        Pages.StudyPlanner {
                            id: plannerPage
                            width: scroller.width - 5
                            visible: window.activePage === "Study Planner"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        Pages.PracticeLab {
                            id: practicePage
                            width: scroller.width - 5
                            visible: window.activePage === "Practice Lab"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        Pages.FocusStudio {
                            id: focusPage
                            width: scroller.width - 5
                            visible: window.activePage === "Focus Studio"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        Pages.Performance {
                            id: performancePage
                            width: scroller.width - 5
                            visible: window.activePage === "Performance"
                        }
                        Pages.NotesFiles {
                            id: notesPage
                            width: scroller.width - 5
                            visible: window.activePage === "Notes & Files"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        Pages.Resources {
                            id: resourcesPage
                            width: scroller.width - 5
                            visible: window.activePage === "Resources"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        Pages.Settings {
                            id: settingsPage
                            width: scroller.width - 5
                            visible: window.activePage === "Settings"
                            onNotice: function(message) { window.showNotice(message) }
                        }
                        ColumnLayout {
                            id: secondary; width: scroller.width - 5; spacing: 15
                            visible: window.activePage !== "Dashboard" && window.activePage !== "My Courses" && window.activePage !== "AI Tutor" && window.activePage !== "Study Planner" && window.activePage !== "Practice Lab" && window.activePage !== "Focus Studio" && window.activePage !== "Performance" && window.activePage !== "Notes & Files" && window.activePage !== "Resources" && window.activePage !== "Settings"
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 170; radius: 19; color: c.orangeSoft; clip: true
                                Cards.SectionStudentArt {
                                    sectionName: window.activePage
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    width: Math.min(320, parent.width * 0.39)
                                }
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    anchors.rightMargin: Math.min(320, parent.width * 0.39) - 50
                                    width: 50
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: c.orangeSoft }
                                        GradientStop { position: 1.0; color: "#00FFE2C3" }
                                    }
                                }

                                ColumnLayout { anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                                    Text { text: "YOUR WORKSPACE"; font.pixelSize: 13; font.weight: Font.Bold; color: c.orangeDark; font.letterSpacing: 1.4 }
                                    Text { text: window.activePage; font.pixelSize: 31; font.weight: Font.ExtraBold; color: c.ink }
                                    Text { text: "A dedicated space for your academic journey."; font.pixelSize: 15; color: c.muted }
                                }
                            }
                            GridLayout { columns: 2; columnSpacing: 14; rowSpacing: 14; Layout.fillWidth: true
                                Repeater { model: ["Overview","Recent Activity","My Library","Study Tools"]
                                    delegate: Rectangle { required property string modelData; Layout.fillWidth: true; Layout.preferredHeight: 168; radius: 17; color: c.surface; border.color: c.line
                                        ColumnLayout { anchors.fill: parent; anchors.margins: 17; spacing: 9
                                            Rectangle { width: 42; height: 42; radius: 12; color: c.orangeSoft; Text { anchors.centerIn: parent; text: "✦"; font.pixelSize: 23; color: c.orange } }
                                            Text { text: modelData; font.pixelSize: 19; font.weight: Font.Bold; color: c.ink }
                                            Text { text: "This section will be completed in the UI screen phase."; font.pixelSize: 14; wrapMode: Text.WordWrap; color: c.muted; Layout.fillWidth: true }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Pages.AITutor {
                        id: tutorPage
                        visible: window.activePage === "AI Tutor"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onNotice: function(message) { window.showNotice(message) }
                        onOpenPage: function(page) { window.activePage = page }
                    }
                    Assistant.HybridPanel {
                        visible: window.showPanel
                        Layout.preferredWidth: window.showPanel ? 356 : 0
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true
                        onNotice: function(message) {window.showNotice(message)}
                        onOpenPage: function(page) {window.activePage=page}
                    }
                }
            }
        }
    }
    Rectangle {
        id: toast; visible: false; z: 100
        width: Math.min(470, window.width-70); height: 45; radius: 12; color: c.ink
        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 18
        Text { anchors.centerIn: parent; text: window.toastMessage; font.pixelSize: 15; color: "white"; elide: Text.ElideRight; width: parent.width - 28; horizontalAlignment: Text.AlignHCenter }
        MouseArea { anchors.fill: parent; onClicked: toast.visible = false }
    }
    // CAMPUS_POP_ONBOARDING_V25
    Onboard.ProfileOnboarding {
        anchors.fill: parent
    }

    // CAMPUS_POP_PACKS_V34: visual-only tiled paper over all app surfaces.
    Image {
        id: paperGrainOverlay
        anchors.fill: parent
        z: 85
        visible: c.packPaper
        opacity: c.paperTextureOpacity
        source: Qt.resolvedUrl("../assets/textures/campus_paper_fibers.png")
        fillMode: Image.Tile
        asynchronous: false
        smooth: false
        cache: true
    }
}
