// CAMPUS_POP_PACKS_V34
// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../theme" as Theme
import "../components/buttons" as Duo
import "../components/tutor" as Tutor

Item {
    id: root
    // STUDYSPACE_LLM_V18
    signal notice(string message)
    signal openPage(string page)

    property string selectedCourse: profileBridge.enrolledCourses.length ? profileBridge.enrolledCourses[0] : "Applied Statistics"
    property string studyMode: "Explain"
    property string studyLevel: "Step by step"
    property string attachmentName: ""
    property string attachmentPath: ""
    property bool waitingForReply: false
    property int sessionsStarted: 1
    property string chatHeading: "New conversation"

    readonly property var courseNames: [
        "Applied Statistics", "Python Programming", "Computer Systems",
        "Software Engineering", "Discrete Mathematics", "Database Systems"
    ]
    readonly property var modes: ["Explain", "Guided", "Practice", "Summarise"]
    readonly property var prompts: [
        { title: "Explain a concept", subtitle: "Start from the basics", text: "Explain this concept using a simple real-world example: ", tint: "#8B5CF6", surface: "#F4EBFF" },
        { title: "Work through a problem", subtitle: "Show every step", text: "Help me solve this problem step by step: ", tint: "#F97316", surface: "#FFF0E5" },
        { title: "Test my understanding", subtitle: "Practice with feedback", text: "Ask me five practice questions about ", tint: "#087DBA", surface: "#E9F4FF" },
        { title: "Summarise my notes", subtitle: "Find the key ideas", text: "Summarise the important points in the attached notes.", tint: "#12A78F", surface: "#E5F8F2" }
    ]
    function choosePrompt(value) {
        messageInput.text = value
        messageInput.forceActiveFocus()
        messageInput.cursorPosition = messageInput.length
    }
    function scrollToLatest() {
        Qt.callLater(function() {
            if (chatScroll.contentHeight > chatScroll.height)
                chatScroll.contentY = chatScroll.contentHeight - chatScroll.height
        })
    }
    function sendDraft() {
        if (waitingForReply) {
            notice("StudySpace is still preparing an answer.")
            return
        }
        var draft = messageInput.text.trim()
        if (!draft && !attachmentPath) {
            notice("Type a question or select a document first.")
            return
        }
        if (typeof tutorBridge === "undefined" || !tutorBridge.configured) {
            notice("Offline tutor is unavailable. Please relaunch Campus Pop.")
            return
        }
        var question = draft || "Help me study this attached document."
        conversation.append({"message": question, "fromStudent": true,
                             "attachedName": attachmentName})
        conversation.append({"message": "Preparing your answer…", "fromStudent": false,
                             "attachedName": ""})
        if (chatHeading === "New conversation")
            chatHeading = draft ? draft.slice(0, 34) : "Document discussion"
        var path = attachmentPath
        messageInput.text = ""
        attachmentName = ""
        attachmentPath = ""
        waitingForReply = true
        scrollToLatest()
        // CAMPUS_POP_AUTOCOURSE_V27
        // Reflect the subject explicitly requested by the student in the visible selector.
        if (/\bpython\b/i.test(question) && root.courseNames.indexOf("Python Programming") !== -1)
            root.selectedCourse = "Python Programming"
        else if (/\b(?:statistics|probability|regression|bayes)\b/i.test(question)
                 && root.courseNames.indexOf("Applied Statistics") !== -1)
            root.selectedCourse = "Applied Statistics"
        tutorBridge.ask(question, selectedCourse, studyMode, studyLevel, path)
    }
    function showTutorReply(answer) {
        if (conversation.count > 0)
            conversation.setProperty(conversation.count - 1, "message", answer)
        waitingForReply = false
        scrollToLatest()
    }
    function showTutorError(problem) {
        if (waitingForReply && conversation.count > 0)
            conversation.setProperty(conversation.count - 1, "message",
                                     "Could not get an answer. " + problem)
        waitingForReply = false
        notice(problem)
        scrollToLatest()
    }
    function newChat() {
        if (waitingForReply) {
            notice("Finish the current response before starting a new chat.")
            return
        }
        if (typeof tutorBridge !== "undefined") tutorBridge.newConversation()
        conversation.clear()
        messageInput.text = ""
        attachmentName = ""
        attachmentPath = ""
        chatHeading = "New conversation"
        sessionsStarted += 1
    }


    function applyQueuedTutorDraft() {
        if (typeof settingsBridge === "undefined") return
        var queued = (settingsBridge.tutorDraft || "").trim()
        if (!queued) return
        if (settingsBridge.tutorMode && root.modes.indexOf(settingsBridge.tutorMode) >= 0)
            root.studyMode = settingsBridge.tutorMode
        choosePrompt(queued)
        var shouldSend = settingsBridge.tutorAutoSend
        settingsBridge.clearTutorDraft()
        if (shouldSend)
            sendDraft()
    }

    Component.onCompleted: applyQueuedTutorDraft()
    onVisibleChanged: if (visible) applyQueuedTutorDraft()
    Connections {
        target: settingsBridge
        function onTutorDraftChanged() {
            if (root.visible)
                applyQueuedTutorDraft()
        }
    }

    Theme.Colors { id: c }
    ListModel { id: conversation }
    Connections {
        target: typeof tutorBridge === "undefined" ? null : tutorBridge
        ignoreUnknownSignals: true
        function onReplyReady(answer) { root.showTutorReply(answer) }
        function onRequestFailed(problem) { root.showTutorError(problem) }
    }
    FileDialog {
        id: attachDialog
        title: "Choose study material"
        nameFilters: ["Study documents (*.pdf *.docx *.txt *.md)", "All files (*)"]
        onAccepted: {
            var full = selectedFile.toString()
            root.attachmentPath = full
            root.attachmentName = decodeURIComponent(full.split("/").pop())
            root.notice("Selected " + root.attachmentName + ". Its text will be sent to the AI when you press Send.")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 11
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 132
            radius: 19
            color: c.packPop ? "#F3E6FF" : c.heroSurface
            clip: true
            Image {
                visible: c.showArt
                opacity: c.packStudio ? 0.16 : c.packPaper ? 0.76 : 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.min(365, parent.width * 0.35)
                source: Qt.resolvedUrl("../../assets/illustrations/students/hero_05.jpg")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
            }
            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: Math.min(365, parent.width * 0.35) - 56
                width: 57
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: c.packPop ? "#F3E6FF" : c.heroSurface }
                    GradientStop { position: 1; color: "#00F3E6FF" }
                }
            }
            Column {
                anchors.left: parent.left
                anchors.leftMargin: 23
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { text: "PERSONAL LEARNING SPACE"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; font.letterSpacing: 1.1; color: "#7752B1" }
                Text { text: "AI Study Tutor"; font.family: c.uiFont; font.pixelSize: Math.round(30 * c.typeScale); font.weight: Font.ExtraBold; color: "#20243A" }
                Text { text: "Learn it, practise it, understand it."; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); color: "#745E8D" }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 11

            Rectangle {
                visible: root.width >= 1020
                Layout.preferredWidth: visible ? 208 : 0
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                radius: 17
                color: "#FFFFFF"
                border.color: "#EEE6E2"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 11
                    Duo.DuoButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 49
                        text: "New conversation"
                        compact: true
                        fillColor: "#F97316"
                        shadowColor: "#C75508"
                        onClicked: root.newChat()
                    }
                    Text { text: "YOUR SESSION"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; font.letterSpacing: 1.1; color: "#96A0B2" }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        radius: 11
                        color: "#FFF0E5"
                        Column {
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: 12; anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text { width: parent.width; text: root.chatHeading; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.ExtraBold; color: "#9B440F"; elide: Text.ElideRight }
                            Text { text: "Current conversation"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: "#95694C" }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#F0ECE9" }
                    Text { text: "STUDY MODES"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; font.letterSpacing: 1.1; color: "#96A0B2" }
                    Repeater {
                        model: root.modes
                        delegate: Rectangle {
                            id: modeButton
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 43
                            radius: 11
                            color: root.studyMode === modelData ? "#F0E7FF" : mouse.containsMouse ? "#F7F8FC" : "#FFFFFF"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12; anchors.rightMargin: 12
                                Text { text: modeButton.modelData; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: root.studyMode === modeButton.modelData ? Font.ExtraBold : Font.DemiBold; color: root.studyMode === modeButton.modelData ? "#7840D3" : "#4B5870" }
                                Item { Layout.fillWidth: true }
                                Rectangle { visible: root.studyMode === modeButton.modelData; width: 6; height: 6; radius: 3; color: "#8B5CF6" }
                            }
                            MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.studyMode = modeButton.modelData }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112
                        radius: 14
                        color: "#EAF7FF"
                        Column {
                            anchors.fill: parent; anchors.margins: 13; spacing: 6
                            Text { text: "StudySpace tip"; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.ExtraBold; color: "#185689" }
                            Text { width: parent.width; text: "Choose a course and study mode before asking a question."; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: "#3D6689"; wrapMode: Text.WordWrap }
                        }
                    }
                }
            }

            Rectangle {
                id: chatSurface
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 330
                radius: 17
                color: "#FFFFFF"
                border.color: "#EEE6E2"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        spacing: 9
                        Column {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: root.chatHeading; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: "#20243A"; elide: Text.ElideRight; width: parent.width }
                            Text { text: root.selectedCourse + "  ·  " + root.studyMode; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: "#7F8A9F" }
                        }
                        // CAMPUS_POP_COURSE_SELECTOR_V28: high-contrast compact header selector
                        Tutor.CourseSelector {
                            compact: true
                            visible: root.width < 1240
                            Layout.preferredWidth: visible ? Math.min(205, chatSurface.width * 0.31) : 0
                            Layout.preferredHeight: 38
                            model: root.courseNames
                            currentIndex: root.courseNames.indexOf(root.selectedCourse)
                            onActivated: root.selectedCourse = currentText
                        }
                        Rectangle {
                            visible: root.width < 1020
                            Layout.preferredWidth: visible ? 75 : 0
                            Layout.preferredHeight: 33
                            radius: 10; color: "#FFF0E5"
                            Text { anchors.centerIn: parent; text: "+ New"; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold; color: "#B94D0D" }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.newChat() }
                        }
                        Rectangle {
                            Layout.preferredWidth: 79
                            Layout.preferredHeight: 30
                            radius: 9
                            color: "#F5EFFB"
                            Text { anchors.centerIn: parent; text: root.waitingForReply ? "THINKING…" : (typeof tutorBridge !== "undefined" && tutorBridge.configured ? "OFFLINE READY" : "SETUP NEEDED"); font.family: c.uiFont; font.pixelSize: Math.round(10 * c.typeScale); font.weight: Font.ExtraBold; color: "#7751B2" }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#F1ECEA" }
                    RowLayout {
                        visible: root.width < 1020
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 36 : 0
                        spacing: 6
                        Repeater {
                            model: root.modes
                            delegate: Rectangle {
                                id: smallMode
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 33
                                radius: 9
                                color: root.studyMode === modelData ? "#F0E7FF" : "#F7F8FB"
                                Text { anchors.centerIn: parent; text: smallMode.modelData; color: root.studyMode === smallMode.modelData ? "#7640C9" : "#64728A"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.studyMode = smallMode.modelData }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        Flickable {
                            id: chatScroll
                            visible: conversation.count > 0
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: thread.implicitHeight + 30
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            boundsMovement: Flickable.StopAtBounds
                            flickDeceleration: 4300
                            maximumFlickVelocity: 1200
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Column {
                                id: thread
                                width: chatScroll.width
                                spacing: 5
                                y: 12
                                Repeater {
                                    model: conversation
                                    delegate: Tutor.TutorMessage {
                                        // CAMPUS_POP_READER_FOLLOWUPS_V38
                                        threadModel: conversation
                                        replyIndex: index
                                        onFollowUpRequested: function(question) {
                                            var draft = question.trim()
                                            if (!draft) return
                                            messageInput.text = draft
                                            root.sendDraft()
                                        }

                                        width: thread.width
                                        message: model.message
                                        fromStudent: model.fromStudent
                                        attachedName: model.attachedName
                                    }
                                }
                            }
                        }
                        Column {
                            visible: conversation.count === 0
                            anchors.centerIn: parent
                            width: Math.min(parent.width - 18, 490)
                            spacing: 12
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 54; height: 54; radius: 17; color: "#F3E8FF"
                                Text { anchors.centerIn: parent; text: "✦"; font.pixelSize: Math.round(30 * c.typeScale); color: "#8B5CF6" }
                            }
                            Text { width: parent.width; text: "What would you like to learn?"; horizontalAlignment: Text.AlignHCenter; color: "#20243A"; font.family: c.uiFont; font.pixelSize: Math.round(22 * c.typeScale); font.weight: Font.ExtraBold; wrapMode: Text.WordWrap }
                            Text { width: parent.width; text: "Ask about your current module, or choose a study activity below."; horizontalAlignment: Text.AlignHCenter; color: "#78849A"; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); wrapMode: Text.WordWrap }
                            GridLayout {
                                width: parent.width
                                columns: 2
                                columnSpacing: 8; rowSpacing: 8
                                Repeater {
                                    model: root.prompts
                                    delegate: Tutor.TutorPrompt {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 77
                                        title: modelData.title
                                        subtitle: modelData.subtitle
                                        accent: modelData.tint
                                        surface: modelData.surface
                                        onSelected: root.choosePrompt(modelData.text)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: root.attachmentName !== ""
                        Layout.fillWidth: true
                        Layout.preferredHeight: 33
                        radius: 10
                        color: "#F1E9FC"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 9
                            Text { text: "Selected: " + root.attachmentName; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: "#6840A2"; elide: Text.ElideMiddle; Layout.fillWidth: true }
                            Text { text: "✕"; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold; color: "#6840A2"; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.attachmentName = ""; root.attachmentPath = "" } } }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        radius: 14
                        color: "#F8F8FB"
                        border.color: "#E9E4EE"
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4
                            TextArea {
                                id: messageInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                wrapMode: TextEdit.Wrap
                                placeholderText: "Ask a question about " + root.selectedCourse + "..."
                                placeholderTextColor: "#9CA7BA"
                                color: "#20243A"
                                font.family: c.uiFont
                                font.pixelSize: Math.round(15 * c.typeScale)
                                background: Item {}
                                Keys.onPressed: function(event) {
                                    if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier)) {
                                        root.sendDraft()
                                        event.accepted = true
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle {
                                    Layout.preferredWidth: 107
                                    Layout.preferredHeight: 31
                                    radius: 10
                                    color: "#EEEAF3"
                                    Text { anchors.centerIn: parent; text: "+ Attach notes"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: "#665B7A" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: attachDialog.open() }
                                }
                                Text { text: "Ctrl + Enter to send"; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); color: "#9AA3B4"; visible: chatSurface.width >= 455 }
                                Item { Layout.fillWidth: true }
                                Duo.DuoButton {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 38
                                    compact: true
                                    text: "Send"
                                    fillColor: "#8B5CF6"
                                    shadowColor: "#6427B7"
                                    onClicked: root.sendDraft()
                                }
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.waitingForReply ? "StudySpace is preparing a response…" : "Offline tutor uses course lessons and local files. Answers are grounded in the text available on this PC."
                        font.family: c.uiFont
                        font.pixelSize: Math.round(11 * c.typeScale)
                        color: "#929CB0"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Rectangle {
                visible: root.width >= 1240
                Layout.preferredWidth: visible ? 242 : 0
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                radius: 17
                color: "#FFFFFF"
                border.color: "#EEE6E2"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12
                    Text { text: "Study settings"; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: "#20243A" }
                    Text { text: "COURSE CONTEXT"; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); font.weight: Font.ExtraBold; font.letterSpacing: 1; color: "#8995A9" }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: 11
                        color: "transparent"
                        // CAMPUS_POP_COURSE_SELECTOR_V28: readable study-settings selector
                        Tutor.CourseSelector {
                            anchors.fill: parent
                            anchors.leftMargin: 7
                            anchors.rightMargin: 6
                            model: root.courseNames
                            currentIndex: root.courseNames.indexOf(root.selectedCourse)
                            onActivated: root.selectedCourse = currentText
                        }
                    }
                    Text { text: "EXPLANATION STYLE"; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); font.weight: Font.ExtraBold; font.letterSpacing: 1; color: "#8995A9" }
                    Repeater {
                        model: ["Concise", "Step by step", "Detailed"]
                        delegate: Rectangle {
                            id: level
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 10
                            color: root.studyLevel === modelData ? "#FFF0E6" : "#F8F9FC"
                            border.color: root.studyLevel === modelData ? "#FFD1AA" : "#F1F1F5"
                            Text { anchors.centerIn: parent; text: level.modelData; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: root.studyLevel === level.modelData ? Font.ExtraBold : Font.DemiBold; color: root.studyLevel === level.modelData ? "#BC530F" : "#69758A" }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.studyLevel = level.modelData }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#EEE9E5" }
                    Text { text: "Personal learning"; font.family: c.uiFont; font.pixelSize: Math.round(16 * c.typeScale); font.weight: Font.ExtraBold; color: "#20243A" }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 127
                        radius: 13
                        color: "#E9F7F2"
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6
                            Text { text: "Adaptive lessons"; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.ExtraBold; color: "#0F766A" }
                            Text {
                                width: parent.width
                                text: "Future: learning recommendations will adjust to practice results using an evaluated adaptive policy."
                                font.family: c.uiFont
                                font.pixelSize: Math.round(12 * c.typeScale)
                                wrapMode: Text.WordWrap
                                color: "#357B70"
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Text { text: "AI model: " + (typeof tutorBridge !== "undefined" ? tutorBridge.modelName : "not connected") + "\nLearning policy is not enabled yet."; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: "#8A95A8"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
        }
    }
}
