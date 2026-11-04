import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme

// CAMPUS_POP_V35_ALARM_TONE_PICKER
ColumnLayout {
    id: root
    signal notice(string message)
    property string subtitle: "One tone for both Practice Lab and Focus Studio"
    readonly property var tones: ["Chime", "Bell", "Pulse", "Digital", "Soft"]
    spacing: 7
    Theme.Colors { id: c }

    Text {
        Layout.fillWidth: true
        text: "TIME-UP ALARM"
        color: c.muted
        font.family: appFontFamily
        font.pixelSize: 12
        font.weight: Font.ExtraBold
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 9
        VisibleCombo {
            id: tonePicker
            Layout.fillWidth: true
            model: root.tones
            currentIndex: Math.max(0, root.tones.indexOf(settingsBridge.alarmTone))
            onActivated: settingsBridge.setAlarmTone(currentText)
        }
        SolidAction {
            text: "Play tone"
            Layout.preferredWidth: 118
            fillColor: "#64748B"
            bottomColor: "#334155"
            onClicked: {
                if (!settingsBridge.previewAlarm())
                    root.notice("The selected alarm could not play. Check Windows audio and the sound files.")
            }
        }
    }
    Text {
        Layout.fillWidth: true
        text: root.subtitle + (settingsBridge.alarmEnabled ? "" : " · Muted in Settings")
        color: c.muted
        font.family: appFontFamily
        font.pixelSize: 12
        wrapMode: Text.WordWrap
    }
}
