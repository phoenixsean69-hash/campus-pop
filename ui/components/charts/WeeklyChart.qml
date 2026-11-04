import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme

// All figures derive from the currently active local student's saved focus records.
Rectangle {
    id: chart
    implicitHeight: 275
    radius: c.packPop ? 17 : c.panelRadius
    color: c.cardSurface
    border.color: c.cardBorder
    Theme.Colors { id: c }
    readonly property var days: workspaceBridge.dailyFocus
    readonly property real maximumMinutes: Math.max(60, days.reduce(function(maximum, day) {
        return Math.max(maximum, Number(day.minutes) || 0)
    }, 0))
    readonly property int weekMinutes: workspaceBridge.weeklyFocusMinutes
    readonly property int goalMinutes: Math.max(0, settingsBridge.weeklyGoal * 60)
    readonly property real goalPercent: goalMinutes > 0 ? 100 * weekMinutes / goalMinutes : 0
    readonly property bool hasActivity: days.some(function(day) { return Number(day.minutes) > 0 })

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 9
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 2
                Text { text: "Your Progress This Week"; font.family: c.uiFont; font.pixelSize: Math.round(18*c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                Text { text: "Recorded focus sessions · last 7 days"; font.family: c.uiFont; font.pixelSize: Math.round(12*c.typeScale); color: c.muted }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 140
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    spacing: 4
                    Repeater {
                        model: chart.days
                        delegate: Item {
                            required property var modelData
                            width: (parent.width - 24)/7
                            height: parent.height
                            Rectangle {
                                x: (parent.width - width)/2
                                width: Math.min(24, Math.max(9, parent.width * 0.65))
                                height: Math.max(1, (parent.height - 34) * Math.min(1, Math.max(0, Number(modelData.minutes) || 0) / chart.maximumMinutes))
                                anchors.bottom: nameText.top
                                anchors.bottomMargin: 7
                                radius: 5
                                color: c.orange
                                opacity: Number(modelData.minutes) > 0 ? 1 : 0.10
                            }
                            Text {
                                id: nameText
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: String(modelData.day || "")
                                font.family: c.uiFont
                                font.pixelSize: Math.round(10 * c.typeScale)
                                color: c.muted
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: !chart.hasActivity
                    text: "No focus sessions recorded yet"
                    color: c.muted
                    font.family: c.uiFont
                    font.pixelSize: Math.round(12 * c.typeScale)
                }
            }
            Column {
                Layout.preferredWidth: 108
                Layout.alignment: Qt.AlignVCenter
                spacing: 9
                Rectangle {
                    width: 108; height: 67; radius: 11; color: c.tealSoft
                    Column {
                        anchors.centerIn: parent
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: (chart.weekMinutes/60).toFixed(1) + " h"; font.pixelSize: Math.round(19*c.typeScale); font.bold: true; color: c.ink }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "This week"; font.pixelSize: Math.round(11*c.typeScale); color: c.muted }
                    }
                }
                Rectangle {
                    width: 108; height: 67; radius: 11; color: c.purpleSoft
                    Column {
                        anchors.centerIn: parent
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: chart.goalMinutes > 0 ? Math.round(chart.goalPercent) + "%" : "—"; font.pixelSize: Math.round(19*c.typeScale); font.bold: true; color: c.ink }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Weekly goal"; font.pixelSize: Math.round(11*c.typeScale); color: c.muted }
                    }
                }
            }
        }
    }
}
