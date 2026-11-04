// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
import "../buttons" as Duo
Rectangle {
    id: root
    signal notice(string message)
    signal openPage(string page)
    property bool showSchedule: true
    property bool showAI: true
    color: "transparent"
    Theme.Colors { id: c }

    function routeSchedule(title) {
        if (title === "Practice Questions") {
            root.openPage("Practice Lab")
            return
        }
        if (title === "Plan for the Week") {
            root.openPage("Study Planner")
            return
        }
        root.openPage("My Courses")
    }

    function handleAssistantAction(label) {
        if (label === "Explain a concept") {
            settingsBridge.queueTutorDraft("Explain a concept from my current course.", "Explain", true)
            root.openPage("AI Tutor")
            return
        }
        if (label === "Summarise my notes") {
            root.openPage("Notes & Files")
            root.notice("Open Notes & Files and use the local summary action.")
            return
        }
        if (label === "Generate practice questions") {
            root.openPage("Practice Lab")
            return
        }
        root.openPage("Study Planner")
    }

    function sendAssistantPrompt() {
        var draft = aiInput.text.trim()
        if (!draft) {
            root.notice("Type a question first.")
            return
        }
        settingsBridge.queueTutorDraft(draft, "Explain", true)
        aiInput.text = ""
        root.openPage("AI Tutor")
    }

    Flickable {
        id: panelScroll
        // CAMPUS_POP_PANEL_SCROLL_V31
        // One measured extent per stable layout. A Flickable whose contentHeight
        // follows a live ColumnLayout implicitHeight can jump when the pointer
        // reaches the end and layouts are recalculated.
        property real stableExtent: 0
        readonly property real scrollBottom: Math.max(0, contentHeight - height)
        boundsMovement: Flickable.StopAtBounds
        pixelAligned: true
        flickDeceleration: 6000

        function refreshExtent() {
            settleExtent.restart()
        }
        onWidthChanged: refreshExtent()
        onHeightChanged: refreshExtent()
        Component.onCompleted: refreshExtent()
        onMovingChanged: {
            // Never recompute scroll bounds during a wheel gesture or kinetic flick.
            if (!moving && stableExtent <= 0)
                refreshExtent()
        }
        Connections {
            target: root
            function onShowScheduleChanged() { panelScroll.refreshExtent() }
            function onShowAIChanged() { panelScroll.refreshExtent() }
        }
        Timer {
            id: settleExtent
            interval: 180
            repeat: false
            onTriggered: {
                if (panelScroll.moving || panelScroll.dragging || panelScroll.flicking) {
                    restart()
                    return
                }
                var natural = Math.ceil(body.implicitHeight + 14)
                if (!isFinite(natural) || natural <= 0) {
                    restart()
                    return
                }
                panelScroll.stableExtent = Math.max(panelScroll.height, natural)
                // Clamp only when the layout changes (not on each scroll tick).
                if (panelScroll.contentY > panelScroll.scrollBottom)
                    panelScroll.contentY = panelScroll.scrollBottom
                else if (panelScroll.contentY < 0)
                    panelScroll.contentY = 0
            }
        }

        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, stableExtent)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: body
            width: panelScroll.width - 5
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Duo.DuoButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.preferredHeight: 46
                    compact: true
                    text: "Today's Plan"
                    iconText: ""
                    fillColor: "#FF7A13"
                    shadowColor: "#CF5D06"
                    onClicked: {
                        root.showSchedule = true
                        root.openPage("Study Planner")
                    }
                }
                Duo.DuoButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.preferredHeight: 46
                    compact: true
                    text: "AI Assistant"
                    iconText: ""
                    fillColor: "#9254ED"
                    shadowColor: "#6D28B5"
                    onClicked: {
                        root.showAI = true
                        root.openPage("AI Tutor")
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.showSchedule ? 363 : 48
                radius: c.packPop ? 17 : c.panelRadius
                color: c.surface
                border.color: c.line
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 11
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Today's Schedule"; font.family: c.uiFont; font.pixelSize: Math.round(17 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                        Item { Layout.fillWidth: true }
                        Text { text: "Monday"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.showSchedule
                        spacing: 3
                        Repeater {
                            model: [
                                {time:"09:00",name:"Applied Statistics",status:"✓",done:true},
                                {time:"10:30",name:"Python Programming",status:"✓",done:true},
                                {time:"13:00",name:"Statistics Revision",status:"▶",done:false},
                                {time:"15:00",name:"Practice Questions",status:"○",done:false},
                                {time:"16:30",name:"Plan for the Week",status:"○",done:false}
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.minimumHeight: 40
                                radius: 12
                                color: index === 2 ? c.orangeSoft : "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10
                                    Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: modelData.done ? c.success : index === 2 ? c.orange : c.muted }
                                    Text { text: modelData.time; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: index === 2 ? Font.Bold : Font.Medium; Layout.preferredWidth: 44 }
                                    Text { text: modelData.name; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: index === 2 ? Font.Bold : Font.Medium; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Rectangle {
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        radius: 14
                                        color: modelData.done ? c.successSoft : index === 2 ? c.surface : "transparent"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.status
                                            color: modelData.done ? c.success : index === 2 ? c.orange : c.muted
                                            font.pixelSize: Math.round(15 * c.typeScale)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.routeSchedule(modelData.name) }
                            }
                        }
                    }
                    Rectangle { visible: root.showSchedule; Layout.fillWidth: true; Layout.preferredHeight: 1; color: c.line }
                    RowLayout {
                        visible: root.showSchedule
                        Layout.fillWidth: true
                        Text { text: "Upcoming"; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                        Item { Layout.fillWidth: true }
                        Text { text: "View All →"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: c.orangeDark; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPage("Study Planner") } }
                    }
                    RowLayout {
                        visible: root.showSchedule
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: 10
                            color: c.dangerSoft
                            border.color: c.dark ? "#5A3740" : "#FFD3D9"
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0
                                Text { text: "Assignment"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: c.danger }
                                Text { text: "1 day left"; font.family: c.uiFont; font.pixelSize: Math.round(19 * c.typeScale); font.weight: Font.ExtraBold; color: c.danger }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPage("Study Planner") }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: 10
                            color: c.purpleSoft
                            border.color: c.dark ? "#4A3E69" : "#E6D4FB"
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0
                                Text { text: "Exam"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: c.purple }
                                Text { text: "12 days left"; font.family: c.uiFont; font.pixelSize: Math.round(19 * c.typeScale); font.weight: Font.ExtraBold; color: c.purple }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPage("Study Planner") }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.showAI ? 336 : 50
                radius: 17
                color: c.purpleSoft
                border.color: c.line
                clip: true
                Rectangle { x: parent.width - 95; y: 170; width: 180; height: 180; radius: 90; color: c.dark ? "#3A3054" : "#EBD1FF"; opacity: 0.85 }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "AI Study Assistant"; font.family: c.uiFont; font.pixelSize: Math.round(17 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                        Item { Layout.fillWidth: true }
                        Text { text: "↗"; font.pixelSize: Math.round(22 * c.typeScale); color: c.purple; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openPage("AI Tutor") } }
                    }
                    Text { visible: root.showAI; text: "Get instant help with your studies."; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted }
                    Flow {
                        visible: root.showAI
                        Layout.fillWidth: true
                        spacing: 8
                        Repeater {
                            model: ["Explain a concept", "Summarise my notes", "Generate practice questions", "Plan my study week"]
                            delegate: Duo.DuoButton {
                                required property string modelData
                                text: modelData
                                compact: true
                                implicitHeight: 38
                                fillColor: c.dark ? "#DEC8FF" : "#E2CCFF"
                                shadowColor: c.dark ? "#A689DF" : "#BFA2EA"
                                textColor: "#4C277A"
                                onClicked: root.handleAssistantAction(modelData)
                            }
                        }
                    }
                    Item { visible: root.showAI; Layout.fillHeight: true }
                    Rectangle {
                        visible: root.showAI
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        radius: 13
                        color: c.inputSurface
                        border.color: c.line
                        border.width: 1.5
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 6
                            TextField {
                                id: aiInput
                                Layout.fillWidth: true
                                placeholderText: "Ask a question..."
                                placeholderTextColor: c.muted
                                color: c.ink
                                font.family: c.uiFont
                                font.pixelSize: Math.round(14 * c.typeScale)
                                background: Item {}
                                onAccepted: root.sendAssistantPrompt()
                            }
                            Text { text: "⌁"; color: c.purple; font.pixelSize: Math.round(22 * c.typeScale); MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.openPage("Notes & Files"); root.notice("Import your notes there, then use Summarise.") } } }
                            Rectangle { Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 10; color: c.orange; Text { anchors.centerIn: parent; text: "➤"; color: "white"; font.pixelSize: Math.round(19 * c.typeScale) }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.sendAssistantPrompt() } }
                        }
                    }
                }
            }
        }
    }
}
