// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme
import "../components/workspace" as W

ColumnLayout {
    id: root
    signal notice(string message)
    spacing: 14
    Theme.Colors { id: c }
    property string selectedCourse: "Applied Statistics"
    property string selectedTopic: "All topics"
    property int questionIndex: 0
    property int selectedAnswer: -1
    property int correctCount: 0
    property bool finished: false
    property var questions: [
        { course: "Applied Statistics", topic: "Probability", q: "A fair coin is flipped twice. What is the probability of two heads?", options: ["1/2", "1/4", "1/8", "3/4"], correct: 1, explanation: "The four equally likely outcomes are HH, HT, TH and TT. Only HH works: 1/4." },
        { course: "Applied Statistics", topic: "Descriptive statistics", q: "Which measure changes most when a very large outlier is added?", options: ["Median", "Mode", "Mean", "Sample size"], correct: 2, explanation: "The mean uses every numerical value and is sensitive to extreme observations." },
        { course: "Python Programming", topic: "Data structures", q: "Which Python container stores unique values?", options: ["List", "Tuple", "Set", "String"], correct: 2, explanation: "A set retains unique elements and supports membership tests and set operations." },
        { course: "Python Programming", topic: "Functions", q: "What does len([3, 6, 9]) return?", options: ["9", "3", "6", "Error"], correct: 1, explanation: "len returns the number of elements, which is three." },
        { course: "Computer Systems", topic: "CPU architecture", q: "Which component executes machine instructions?", options: ["RAM", "CPU", "SSD", "Monitor"], correct: 1, explanation: "The CPU fetches, decodes and executes instructions." },
        { course: "Computer Systems", topic: "Memory", q: "Which memory usually loses its contents when power is off?", options: ["SSD", "ROM", "RAM", "Optical disc"], correct: 2, explanation: "Conventional RAM is volatile memory." },
        { course: "Software Engineering", topic: "Requirements", q: "Which artifact describes a system's required behaviours?", options: ["Requirements specification", "Git commit", "Binary executable", "Compiler"], correct: 0, explanation: "A requirements specification documents functional and non-functional expectations." },
        { course: "Software Engineering", topic: "Testing", q: "Unit tests focus primarily on…", options: ["Entire organisations", "Small units of code", "Network topology", "User salaries"], correct: 1, explanation: "Unit tests exercise isolated components, usually functions or classes." },
        { course: "Discrete Mathematics", topic: "Logic", q: "What is the negation of P AND Q?", options: ["NOT P AND NOT Q", "NOT P OR NOT Q", "P OR Q", "P AND NOT Q"], correct: 1, explanation: "De Morgan's law: NOT(P AND Q) equals (NOT P) OR (NOT Q)." },
        { course: "Discrete Mathematics", topic: "Sets", q: "How many subsets does a 3-element set have?", options: ["3", "6", "8", "9"], correct: 2, explanation: "A set of n elements has 2^n subsets, so 2^3 = 8." },
        { course: "Database Systems", topic: "SQL", q: "Which SQL statement retrieves rows?", options: ["SELECT", "CREATE", "DROP", "GRANT"], correct: 0, explanation: "SELECT retrieves and projects information from tables." },
        { course: "Database Systems", topic: "Keys", q: "What is a primary key used for?", options: ["Compressing images", "Uniquely identifying rows", "Drawing charts", "Encrypting Wi-Fi"], correct: 1, explanation: "A primary key uniquely identifies each record in a relation." }
    ]
    readonly property var availableTopics: ["All topics"].concat(questions.filter(function(q) { return q.course === root.selectedCourse })
        .map(function(q) { return q.topic }).filter(function(t, i, arr) { return arr.indexOf(t) === i }))
    readonly property var activeQuestions: questions.filter(function(q) { return q.course === root.selectedCourse && (root.selectedTopic === "All topics" || q.topic === root.selectedTopic) })
    readonly property var currentQuestion: activeQuestions.length ? activeQuestions[Math.min(questionIndex, activeQuestions.length - 1)] : null
    function restartQuiz() {
        questionIndex = 0
        correctCount = 0
        selectedAnswer = -1
        finished = false
        resetQuestionTimer(false)
    }
    function nextQuestion() {
        if ((selectedAnswer < 0 && !questionTimedOut) || finished) return
        if (questionTimerRunning) tickQuestionTimer()
        if (questionTimerRunning) questionTimerRunning = false
        if (!questionTimedOut && selectedAnswer === currentQuestion.correct) correctCount += 1
        if (questionIndex + 1 >= activeQuestions.length) {
            finished = true
            questionTimerPaused = false
            workspaceBridge.recordQuiz(selectedCourse, correctCount, activeQuestions.length,
                 selectedTopic === "All topics" ? "Mixed topics" : selectedTopic)
            notice("Practice result saved to Performance.")
        } else {
            var timedSession = questionTimerStarted && questionDuration > 0
            questionIndex++
            selectedAnswer = -1
            resetQuestionTimer(timedSession)
        }
    }

    // CAMPUS_POP_V35_TIMEUP — independent countdown for each practice question.
    property int questionDuration: 60
    property int questionRemaining: questionDuration
    property bool questionTimerRunning: false
    property bool questionTimerPaused: false
    property bool questionTimerStarted: false
    property bool questionTimedOut: false
    property double questionDeadline: 0

    function formattedQuestionTime(seconds) {
        var m = Math.floor(Math.max(0, seconds) / 60)
        var v = Math.max(0, seconds) % 60
        return (m < 10 ? "0" : "") + m + ":" + (v < 10 ? "0" : "") + v
    }
    function resetQuestionTimer(autoStart) {
        questionTimerRunning = false
        questionTimerPaused = false
        questionTimerStarted = false
        questionTimedOut = false
        questionRemaining = questionDuration
        if (autoStart && questionDuration > 0) startQuestionTimer()
    }
    function changeQuestionDuration(seconds) {
        // Changing the limit must never unlock an already expired/answered question.
        if (questionTimedOut || selectedAnswer >= 0) {
            questionDuration = seconds
            return
        }
        questionDuration = seconds
        resetQuestionTimer(false)
    }
    function startQuestionTimer() {
        if (finished || questionDuration <= 0 || !currentQuestion || selectedAnswer >= 0 || questionTimedOut)
            return
        questionDeadline = Date.now() + questionRemaining * 1000
        questionTimerStarted = true
        questionTimerRunning = true
        questionTimerPaused = false
    }
    function pauseQuestionTimer() {
        if (!questionTimerRunning) return
        tickQuestionTimer()
        if (!questionTimedOut) {
            questionTimerRunning = false
            questionTimerPaused = true
        }
    }
    function tickQuestionTimer() {
        if (!questionTimerRunning) return
        questionRemaining = Math.max(0, Math.ceil((questionDeadline - Date.now()) / 1000))
        if (questionRemaining === 0) {
            questionTimerRunning = false
            questionTimerPaused = false
            questionTimedOut = true
            settingsBridge.playTimeUpAlarm()
            root.notice("Time is up for this question. Continue to the next question when ready.")
        }
    }
    function answerQuestion(index) {
        if (questionTimedOut || finished) return
        if (questionTimerRunning) tickQuestionTimer()
        if (questionTimedOut) return
        selectedAnswer = index
        questionTimerRunning = false
        questionTimerPaused = false
    }
    Timer {
        interval: 200
        repeat: true
        running: root.questionTimerRunning
        onTriggered: root.tickQuestionTimer()
    }

    W.PageBanner { Layout.fillWidth: true; heading: "Practice Lab"; subtitle: "Build confidence through questions and immediate feedback."; illustration: "hero_08.jpg" }
    W.SectionHeading { Layout.fillWidth: true; heading: "Knowledge check"; subtitle: "Choose a course, then focus on a specific topic." }
    GridLayout { Layout.fillWidth: true; columns: root.width < 560 ? 1 : 2; columnSpacing: 10; rowSpacing: 9
        ColumnLayout { Layout.fillWidth: true; spacing: 5
            Text { text: "Course"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
            W.VisibleCombo {
                id: coursePicker; Layout.fillWidth: true
                model: ["Applied Statistics", "Python Programming", "Computer Systems", "Software Engineering", "Discrete Mathematics", "Database Systems"]
                onActivated: { root.selectedCourse = currentText; root.selectedTopic = "All topics"; root.restartQuiz() }
            }
        }
        ColumnLayout { Layout.fillWidth: true; spacing: 5
            Text { text: "Topic"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
            W.VisibleCombo {
                id: topicPicker; Layout.fillWidth: true
                model: root.availableTopics
                currentIndex: Math.max(0,root.availableTopics.indexOf(root.selectedTopic))
                onActivated: { root.selectedTopic = currentText; root.restartQuiz() }
            }
        }
    }

    // CAMPUS_POP_V35_PRACTICE_TIMER_UI
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: timerControls.implicitHeight + 34
        radius: (typeof c.packStudio !== "undefined" && c.packStudio) ? 7 : 16
        color: c.surface
        border.color: c.line
        border.width: 1
        ColumnLayout {
            id: timerControls
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 11
            W.SectionHeading { Layout.fillWidth: true; heading: "Question timer"; subtitle: "Time limits are per question. Pause or reset whenever you need to." }
            GridLayout {
                Layout.fillWidth: true
                columns: root.width < 640 ? 1 : 2
                rowSpacing: 15
                columnSpacing: 18
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "TIME PER QUESTION"; color: c.muted; font.family: appFontFamily; font.pixelSize: 12; font.weight: Font.Bold }
                    W.VisibleCombo {
                        Layout.fillWidth: true
                        model: ["Untimed", "30 sec", "60 sec", "90 sec", "2 min"]
                        currentIndex: [0, 30, 60, 90, 120].indexOf(root.questionDuration)
                        onActivated: root.changeQuestionDuration([0, 30, 60, 90, 120][currentIndex])
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: root.questionDuration === 0 ? "No limit" : root.formattedQuestionTime(root.questionRemaining)
                            color: root.questionTimedOut ? c.danger : c.ink
                            font.family: appFontFamily
                            font.pixelSize: 28
                            font.weight: Font.ExtraBold
                        }
                        Item { Layout.fillWidth: true }
                        W.SolidAction {
                            text: root.questionTimerRunning ? "Pause" : root.questionTimerPaused ? "Resume" : "Start"
                            enabled: root.questionDuration > 0 && !root.finished && !root.questionTimedOut && root.selectedAnswer < 0
                            onClicked: root.questionTimerRunning ? root.pauseQuestionTimer() : root.startQuestionTimer()
                        }
                        W.SolidAction {
                            text: "Reset clock"
                            fillColor: "#64748B"; bottomColor: "#334155"
                            enabled: !root.finished && !root.questionTimedOut && root.selectedAnswer < 0
                            onClicked: root.resetQuestionTimer(false)
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.questionTimedOut ? "Time up · This question counts as unanswered." :
                              root.questionTimerRunning ? "Counting down" :
                              root.questionTimerPaused ? "Clock paused" :
                              root.questionDuration === 0 ? "Practice without a timer" : "Press Start when you're ready"
                        color: root.questionTimedOut ? c.danger : c.muted
                        font.family: appFontFamily
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
                W.AlarmTonePicker { Layout.fillWidth: true; onNotice: function(message) { root.notice(message) } }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: quizBody.implicitHeight + 46
        radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: quizBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 23; spacing: 16
            RowLayout {
                Layout.fillWidth: true
                Text { text: root.finished ? "RESULT" : "QUESTION " + (root.questionIndex + 1) + " OF " + root.activeQuestions.length; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold; color: c.orangeDark }
                Item { Layout.fillWidth: true }
                Text { text: root.finished ? "Session complete" : root.selectedTopic; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
            }
            Text {
                Layout.fillWidth: true
                text: root.finished ? "You scored " + root.correctCount + " / " + root.activeQuestions.length : (root.currentQuestion ? root.currentQuestion.q : "No questions available for this topic")
                font.family: c.uiFont; font.pixelSize: Math.round(24 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink; wrapMode: Text.WordWrap
            }
            ColumnLayout {
                visible: !root.finished; Layout.fillWidth: true; spacing: 10
                Repeater {
                    model: root.currentQuestion ? root.currentQuestion.options : []
                    delegate: Rectangle {
                        id: optionBox
                        required property string modelData
                        required property int index
                        Layout.fillWidth: true; Layout.preferredHeight: 52; radius: 12
                        color: root.selectedAnswer === optionBox.index ? c.orangeSoft : c.elevated
                        border.color: root.selectedAnswer === optionBox.index ? c.orange : c.line
                        border.width: root.selectedAnswer === optionBox.index ? 2 : 1
                        Text { anchors.fill: parent; anchors.leftMargin: 16; verticalAlignment: Text.AlignVCenter; text: String.fromCharCode(65 + optionBox.index) + ".  " + optionBox.modelData; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: root.selectedAnswer === optionBox.index ? Font.Bold : Font.Medium; color: c.ink }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.answerQuestion(optionBox.index) }
                    }
                }
                Rectangle {
                    visible: root.selectedAnswer >= 0 || root.questionTimedOut; Layout.fillWidth: true
                    implicitHeight: explanation.implicitHeight + 20; radius: 11
                    color: root.currentQuestion && root.selectedAnswer === root.currentQuestion.correct ? c.tealSoft : c.amberSoft
                    Text { id: explanation; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 11; text: root.currentQuestion ? (root.questionTimedOut && root.selectedAnswer < 0 ? "Time up. " : root.selectedAnswer === root.currentQuestion.correct ? "Correct! " : "Not quite. ") + root.currentQuestion.explanation : ""; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.ink }
                }
            }
            W.SolidAction {
                Layout.alignment: Qt.AlignRight
                text: root.finished ? "Try again" : root.questionIndex + 1 === root.activeQuestions.length ? "Finish practice" : "Next question"
                enabled: root.activeQuestions.length > 0 && (root.finished || root.selectedAnswer >= 0 || root.questionTimedOut)
                onClicked: root.finished ? root.restartQuiz() : root.nextQuestion()
            }
        }
    }
    Text {
        Layout.fillWidth: true; text: "Results are based on your submitted answers and saved locally. These are starter questions, not formal examinations."
        font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.muted; wrapMode: Text.WordWrap
    }
}
