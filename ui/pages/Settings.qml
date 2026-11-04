// CAMPUS_POP_GENERAL_PACK_V33
// CAMPUS_POP_INLINE_PROFILE_V32
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
    property var palettes: [
        { key:"campus", title:"Campus Pop", accent:"#FF7113" },
        { key:"ocean", title:"Ocean Blue", accent:"#2563EB" },
        { key:"slate", title:"Slate Studio", accent:"#64748B" }
    ]
    W.InlineProfileCard { Layout.fillWidth: true; onNotice: function(message) { root.notice(message) } }
    


    Rectangle {
        Layout.fillWidth: true; implicitHeight: appearanceBody.implicitHeight + 42
        radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: appearanceBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20
            spacing: 14
            W.SectionHeading { Layout.fillWidth: true; heading: "Appearance"; subtitle: "The accent palette and light/dark mode are independent." }
            W.AppearancePacks { Layout.fillWidth: true }
            Text { text: "COLOR PALETTE"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
            GridLayout {
                Layout.fillWidth: true; columns: root.width < 600 ? 1 : 3; columnSpacing: 10; rowSpacing: 10
                Repeater {
                    model: root.palettes
                    delegate: Rectangle {
                        id: paletteTile
                        required property var modelData
                        Layout.fillWidth: true; Layout.preferredHeight: 76; radius: 13
                        color: c.elevated
                        border.width: settingsBridge.themeKey === paletteTile.modelData.key ? 2 : 1
                        border.color: settingsBridge.themeKey === paletteTile.modelData.key ? paletteTile.modelData.accent : c.line
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 13; spacing: 10
                            Rectangle { Layout.preferredWidth: 25; Layout.preferredHeight: 25; radius: 8; color: paletteTile.modelData.accent }
                            Text { Layout.fillWidth: true; text: paletteTile.modelData.title; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold; color: c.ink }
                            Text { visible: settingsBridge.themeKey === paletteTile.modelData.key; text: "✓"; color: c.orangeDark; font.pixelSize: Math.round(20 * c.typeScale); font.bold: true }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingsBridge.setThemeKey(paletteTile.modelData.key) }
                    }
                }
            }
            Text { text: "APPEARANCE MODE"; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.Bold }
            GridLayout {
                Layout.fillWidth: true; columns: root.width < 600 ? 1 : 3; columnSpacing: 10; rowSpacing: 10
                Repeater {
                    model: [{key:"system",title:"Device theme",icon:"▣"},{key:"light",title:"Light",icon:"☀"},{key:"dark",title:"Dark",icon:"☾"}]
                    delegate: Rectangle {
                        id: modeTile
                        required property var modelData
                        Layout.fillWidth: true; Layout.preferredHeight: 75; radius: 13
                        color: settingsBridge.appearanceMode === modeTile.modelData.key ? c.orangeSoft : c.elevated
                        border.width: settingsBridge.appearanceMode === modeTile.modelData.key ? 2 : 1
                        border.color: settingsBridge.appearanceMode === modeTile.modelData.key ? c.orange : c.line
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 9
                            Text { text: modeTile.modelData.icon; color: c.orangeDark; font.pixelSize: Math.round(22 * c.typeScale) }
                            Text { Layout.fillWidth: true; text: modeTile.modelData.title; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                            Text { visible: settingsBridge.appearanceMode === modeTile.modelData.key; text: "✓"; color: c.orangeDark; font.pixelSize: Math.round(19 * c.typeScale); font.bold: true }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: settingsBridge.setAppearanceMode(modeTile.modelData.key) }
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                text: settingsBridge.appearanceMode === "system" ? "Following the Windows appearance setting." : "Using " + settingsBridge.appearanceMode + " appearance until you change it."
                color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale)
            }
            W.AppearanceExtras { Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true; spacing: 10
                ColumnLayout { Layout.fillWidth: true; spacing: 3
                    Text { text: "Reduce motion"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); font.weight: Font.Bold }
                    Text { Layout.fillWidth: true; text: "Suppress decorative wobble and other optional animation."; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
                }
                Switch { checked: settingsBridge.reducedMotion; onToggled: settingsBridge.setReducedMotion(checked) }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: profileBody.implicitHeight + 40; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: profileBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 11
            W.SectionHeading { Layout.fillWidth: true; heading: "Academic details"; subtitle: "Programme and study level. Your name and courses are edited above." }
            W.TextInputBox { id: programName; Layout.fillWidth: true; text: settingsBridge.program; placeholderText: "Programme / major (optional)" }
            W.VisibleCombo { id: levelPicker; Layout.fillWidth: true; model: ["Undergraduate","Postgraduate","Diploma","Other"]; currentIndex: Math.max(0,["Undergraduate","Postgraduate","Diploma","Other"].indexOf(settingsBridge.studyLevel)) }
            W.SolidAction { text: "Save academic details"; Layout.alignment: Qt.AlignRight; onClicked: { settingsBridge.setProgram(programName.text); settingsBridge.setStudyLevel(levelPicker.currentText); root.notice("Academic details saved.") } }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: studyBody.implicitHeight + 40; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: studyBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 12
            W.SectionHeading { Layout.fillWidth: true; heading: "Study and focus"; subtitle: "These preferences control your timer and weekly targets." }
            // CAMPUS_POP_V35_TIMEUP — shared alarm tone picker
            W.AlarmTonePicker { Layout.fillWidth: true; onNotice: function(message) { root.notice(message) } }

            GridLayout { Layout.fillWidth: true; columns: root.width < 650 ? 1 : 3; columnSpacing: 10; rowSpacing: 8
                ColumnLayout { Layout.fillWidth: true
                    Text { text: "Focus length"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    W.VisibleCombo { Layout.fillWidth: true; model: ["15 min","25 min","45 min","60 min"]; currentIndex: [15,25,45,60].indexOf(settingsBridge.focusMinutes); onActivated: settingsBridge.setFocusMinutes([15,25,45,60][currentIndex]) }
                }
                ColumnLayout { Layout.fillWidth: true
                    Text { text: "Short break"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    W.VisibleCombo { Layout.fillWidth: true; model: ["5 min","10 min","15 min"]; currentIndex: [5,10,15].indexOf(settingsBridge.breakMinutes); onActivated: settingsBridge.setBreakMinutes([5,10,15][currentIndex]) }
                }
                ColumnLayout { Layout.fillWidth: true
                    Text { text: "Weekly target"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    W.VisibleCombo { Layout.fillWidth: true; model: ["5 hours","10 hours","15 hours","20 hours"]; currentIndex: [5,10,15,20].indexOf(settingsBridge.weeklyGoal); onActivated: settingsBridge.setWeeklyGoal([5,10,15,20][currentIndex]) }
                }
            }
            RowLayout { Layout.fillWidth: true
                ColumnLayout { Layout.fillWidth: true; spacing: 3
                    Text { text: "Time-up alarms"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    Text { text: "Play your selected tone in Practice Lab and Focus Studio."; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
                }
                Switch { checked: settingsBridge.alarmEnabled; onToggled: settingsBridge.setAlarmEnabled(checked) }
            }
            RowLayout { Layout.fillWidth: true
                ColumnLayout { Layout.fillWidth: true; spacing: 3
                    Text { text: "Study reminders"; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                    Text { text: "Controls in-app completion notices; OS alerts are not enabled yet."; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
                }
                Switch { checked: settingsBridge.notificationsEnabled; onToggled: settingsBridge.setNotificationsEnabled(checked) }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: aiBody.implicitHeight + 40; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: aiBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 12
            W.SectionHeading { Layout.fillWidth: true; heading: "AI and accessibility"; subtitle: "Preferences are stored now; AI behaviour will use them when the tutor backend is connected." }
            RowLayout { Layout.fillWidth: true
                Text { text: "Preferred explanation style"; Layout.fillWidth: true; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }
                W.VisibleCombo { Layout.preferredWidth: 178; model: ["Concise","Step by step","Detailed"]; currentIndex: ["Concise","Step by step","Detailed"].indexOf(settingsBridge.aiStyle); onActivated: settingsBridge.setAiStyle(currentText) }
            }
            Text { Layout.fillWidth: true; text: "AI Tutor is not automatically retrained by this preference. When connected, the selected style will guide its answers."; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: dataBody.implicitHeight + 40; radius: c.packPop ? 18 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout { id: dataBody; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 12
            W.SectionHeading { Layout.fillWidth: true; heading: "Data and privacy"; subtitle: "Study data is stored on this PC. Export before resetting." }
            Flow { Layout.fillWidth: true; spacing: 10
                W.SolidAction { text: "Export backup"; onClicked: { var p=workspaceBridge.exportData(); root.notice(p ? "Backup exported: " + p : "Export failed") } }
                W.SolidAction { text: "Reset settings"; fillColor: "#64748B"; bottomColor: "#334155"; onClicked: { settingsBridge.resetPreferences(); root.notice("Settings restored to defaults.") } }
                W.SolidAction { text: "Clear study data"; fillColor: "#DC564B"; bottomColor: "#A12F27"; onClicked: confirmClear.open() }
            }
            Text { Layout.fillWidth: true; text: "Clearing study data deletes saved tasks, notes, imported copies, sessions and quiz results. It cannot be undone."; wrapMode: Text.WordWrap; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted }
        }
    }
    Dialog { id: confirmClear; title: "Clear all study data?"; modal: true; width: Math.min(390, root.width - 35); anchors.centerIn: Overlay.overlay
        standardButtons: Dialog.Yes | Dialog.Cancel
        onAccepted: { workspaceBridge.clearStudyData(); root.notice("Study data cleared.") }
        background: Rectangle { radius: c.packPop ? 15 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder }
        Text { width: 340; wrapMode: Text.WordWrap; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); text: "Your notes, imported copies, tasks, focus sessions and quiz history will be deleted. Export first if you need a backup." }
    }
}
