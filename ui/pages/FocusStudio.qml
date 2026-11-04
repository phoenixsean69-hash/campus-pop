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
    property string mode: "Focus"
    property int totalSeconds: settingsBridge.focusMinutes * 60
    property int remaining: totalSeconds
    property bool running: false
    property bool paused: false
    property bool saved: false
    property double endsAt: 0
    property string course: "Applied Statistics"
    readonly property int elapsed: Math.max(0,totalSeconds-remaining)
    readonly property real ratio: totalSeconds > 0 ? Math.min(1,elapsed/totalSeconds) : 0
    property string goal: ""
    function formatted(seconds) {
        var m = Math.floor(Math.max(0, seconds) / 60), s = Math.max(0, seconds) % 60
        return (m<10?"0":"")+m+":"+(s<10?"0":"")+s
    }
    function setDuration(seconds, newMode) {
        running = false; paused = false; saved = false
        mode = newMode; totalSeconds = seconds; remaining = seconds
        ring.requestPaint()
    }
    function startOrPause() {
        if (running) { tick(); running = false; paused = true; return }
        if (remaining <= 0) return
        endsAt = Date.now() + remaining * 1000
        running = true; paused = false
    }
    function tick() {
        if (!running) return
        remaining = Math.max(0,Math.ceil((endsAt-Date.now())/1000))
        ring.requestPaint()
        if (remaining <= 0) finish()
    }
    function finish() {
        if (saved) return
        running = false; paused = false; saved = true
        if (mode === "Focus") workspaceBridge.recordFocus(totalSeconds,course)
        if (settingsBridge.notificationsEnabled) root.notice(mode === "Focus" ? "Focus session completed and saved." : "Break finished. Ready to study?")
        settingsBridge.playTimeUpAlarm() // CAMPUS_POP_V35_TIMEUP
    }
    function savePartial() {
        if (saved || mode !== "Focus") return
        if (running) tick()
        if (elapsed < 30) { root.notice("Complete at least 30 seconds before saving time."); return }
        workspaceBridge.recordFocus(elapsed,course)
        saved = true; running = false; paused = false
        root.notice("Partial focus time saved.")
    }
    Timer { interval: 250; repeat: true; running: root.running; onTriggered: root.tick() }
    Connections { target: settingsBridge
        function onFocusMinutesChanged() { if (!root.running && !root.paused && root.mode === "Focus") root.setDuration(settingsBridge.focusMinutes*60,"Focus") }
        function onAppearanceChanged() { ring.requestPaint() }
    }
    W.PageBanner { Layout.fillWidth: true; heading: "Focus Studio"; subtitle: "Set your intention, stay focused, and take a proper break."; illustration: "hero_11.jpg" }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 740 ? 1 : 2; rowSpacing: 12; columnSpacing: 12
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 445; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12
                RowLayout { Layout.fillWidth: true
                    Text { text: root.mode.toUpperCase() + " SESSION"; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.ExtraBold }
                    Item { Layout.fillWidth: true }
                    Text { text: root.paused ? "Paused" : root.running ? "In progress" : root.saved ? "Completed" : "Ready"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
                }
                Item { Layout.fillWidth: true; Layout.fillHeight: true
                    Canvas {
                        id: ring
                        anchors.centerIn: parent
                        width: Math.min(230,parent.width-20); height: width
                        onPaint: {
                            var ctx=getContext("2d")
                            ctx.clearRect(0,0,width,height)
                            var radius=width/2-13
                            ctx.lineCap="round"; ctx.lineWidth=13
                            ctx.beginPath(); ctx.arc(width/2,height/2,radius,0,Math.PI*2)
                            ctx.strokeStyle=c.line; ctx.stroke()
                            ctx.beginPath(); ctx.arc(width/2,height/2,radius,-Math.PI/2,-Math.PI/2+Math.PI*2*root.ratio)
                            ctx.strokeStyle=c.orange; ctx.stroke()
                        }
                    }
                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: root.formatted(root.remaining); color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(38 * c.typeScale); font.weight: Font.ExtraBold }
                        Text { Layout.alignment: Qt.AlignHCenter; text: Math.round(root.ratio*100)+"% elapsed"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
                    }
                }
                RowLayout { Layout.fillWidth: true; spacing: 9
                    W.SolidAction { Layout.fillWidth: true; text: root.running ? "Pause" : root.paused ? "Resume" : root.saved ? "Completed" : "Start"; enabled: !root.saved; onClicked: root.startOrPause() }
                    W.SolidAction { Layout.fillWidth: true; text: "Reset"; fillColor: "#64748B"; bottomColor: "#334155"; onClicked: root.setDuration(root.totalSeconds,root.mode) }
                    W.SolidAction { Layout.fillWidth: true; text: "Save time"; enabled: !root.saved && root.mode === "Focus" && root.elapsed >= 30; fillColor: "#1BA78C"; bottomColor: "#087461"; onClicked: root.savePartial() }
                }
                Text { Layout.fillWidth: true; text: root.mode === "Break" ? "Breaks are not counted as study time." : "Timer is based on real elapsed time, even when the window is minimised."; color: c.muted; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 445; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 13
                W.SectionHeading { Layout.fillWidth: true; heading: "Build your session"; subtitle: "Select a preset and course before starting." }
                Text { text: "TIMER PRESETS"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
                GridLayout { Layout.fillWidth: true; columns: 2; rowSpacing: 8; columnSpacing: 8
                    W.SolidAction { Layout.fillWidth: true; text: "25 / 5"; enabled: !root.running; onClicked: root.setDuration(25*60,"Focus") }
                    W.SolidAction { Layout.fillWidth: true; text: "50 / 10"; enabled: !root.running; fillColor: "#7D56E8"; bottomColor: "#5D31BC"; onClicked: root.setDuration(50*60,"Focus") }
                    W.SolidAction { Layout.fillWidth: true; text: "My default"; enabled: !root.running; fillColor: "#2563EB"; bottomColor: "#1E40AF"; onClicked: root.setDuration(settingsBridge.focusMinutes*60,"Focus") }
                    W.SolidAction { Layout.fillWidth: true; text: "Break " + settingsBridge.breakMinutes + "m"; enabled: !root.running; fillColor: "#0DA888"; bottomColor: "#067961"; onClicked: root.setDuration(settingsBridge.breakMinutes*60,"Break") }
                }
                Text { text: "COURSE"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
                W.VisibleCombo { Layout.fillWidth: true; enabled: !root.running; model: ["Applied Statistics","Python Programming","Computer Systems","Software Engineering","Discrete Mathematics","Database Systems","Independent study"]; onActivated: root.course = currentText }
                Text { text: "YOUR FOCUS GOAL"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
                W.TextInputBox { Layout.fillWidth: true; text: root.goal; placeholderText: "What will you finish this session?"; onEditingFinished: root.goal = text }
                Text { Layout.fillWidth: true; text: "Today: " + workspaceBridge.weeklyFocusMinutes + " minutes recorded this week"; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                Item { Layout.fillHeight: true }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: focusAlarmBody.implicitHeight + 32
        radius: (typeof c.packStudio !== "undefined" && c.packStudio) ? 7 : 16
        color: c.surface
        border.color: c.line
        ColumnLayout {
            id: focusAlarmBody
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 8
            W.AlarmTonePicker {
                Layout.fillWidth: true
                subtitle: "Plays when a focus session or break reaches zero"
                onNotice: function(message) { root.notice(message) }
            }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: history.implicitHeight + 36; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: history; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 18; spacing: 9
            W.SectionHeading { Layout.fillWidth: true; heading: "Session history"; subtitle: "Only saved focus time contributes to your Performance charts." }
            Text { visible: workspaceBridge.recentFocus.length === 0; text: "No sessions recorded yet."; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale) }
            Repeater { model: workspaceBridge.recentFocus
                delegate: RowLayout { id: entry; required property var modelData; Layout.fillWidth: true; spacing: 9
                    Text { Layout.fillWidth: true; text: entry.modelData.course || "Unassigned"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    Text { text: entry.modelData.minutes + " min"; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale) }
                }
            }
        }
    }
}
