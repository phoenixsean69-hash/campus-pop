import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme

Rectangle {
    id: chart

    signal focusRequested()

    implicitHeight: 310
    radius: 18
    color: c.cardSurface
    border.color: "#D6E2FA"
    border.width: 1

    Theme.Colors { id: c }

    property int selectedWeek: 0

    readonly property var weeks: workspaceBridge.weeklyActivity
    readonly property var weekData: weeks.length > selectedWeek
        ? weeks[selectedWeek]
        : ({ label: "This week", days: [], totalMinutes: 0, sessions: 0 })

    readonly property var days: weekData.days || []
    readonly property real totalMinutes: Number(weekData.totalMinutes) || 0
    readonly property int sessions: Number(weekData.sessions) || 0
    readonly property real goalMinutes: Math.max(0, settingsBridge.weeklyGoal * 60)
    readonly property int goalPercent: goalMinutes > 0
        ? Math.round(totalMinutes * 100 / goalMinutes)
        : 0

    readonly property real maxMinutes: Math.max(
        60,
        days.reduce(function(best, day) {
            return Math.max(best, Number(day.minutes) || 0)
        }, 0)
    )

    readonly property bool hasActivity: days.some(function(day) {
        return Number(day.minutes) > 0
    })

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: chart.selectedWeek === 0
                        ? "Your Progress This Week"
                        : "Your Study Progress"
                    color: c.ink
                    font.family: c.uiFont
                    font.pixelSize: Math.round(18 * c.typeScale)
                    font.weight: Font.ExtraBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "Recorded focus sessions · Monday–Sunday"
                    color: c.muted
                    font.family: c.uiFont
                    font.pixelSize: Math.round(11 * c.typeScale)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.preferredWidth: 130
                Layout.preferredHeight: 32
                radius: 16
                color: "#EEF1FF"
                border.color: "#CBD6FF"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 9
                    spacing: 5

                    Text {
                        text: "‹"
                        color: chart.selectedWeek < chart.weeks.length - 1
                            ? "#172D64" : "#ADB8D5"
                        font.pixelSize: 22

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: chart.selectedWeek < chart.weeks.length - 1
                            onClicked: chart.selectedWeek += 1
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: chart.weekData.label
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: "#172D64"
                        font.family: c.uiFont
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "›"
                        color: chart.selectedWeek > 0
                            ? "#172D64" : "#ADB8D5"
                        font.pixelSize: 22

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: chart.selectedWeek > 0
                            onClicked: chart.selectedWeek -= 1
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 11

            Item {
                id: plot
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 170
                clip: true

                Row {
                    anchors.fill: parent
                    spacing: 7

                    Repeater {
                        model: chart.days

                        delegate: Item {
                            id: dayItem

                            required property var modelData
                            readonly property real minutes:
                                Math.max(0, Number(modelData.minutes) || 0)

                            width: Math.max(12, (parent.width - 42) / 7)
                            height: parent.height

                            Rectangle {
                                id: backgroundBar

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: dayLabel.top
                                anchors.bottomMargin: 9

                                width: Math.min(40, dayItem.width * 0.82)
                                height: Math.max(35, dayItem.height - 42)
                                radius: 11
                                color: "#DDE9FF"
                                opacity: dayItem.modelData.future ? 0.55 : 0.92
                            }

                            Rectangle {
                                anchors.horizontalCenter: backgroundBar.horizontalCenter
                                anchors.bottom: backgroundBar.bottom

                                width: backgroundBar.width
                                height: dayItem.minutes > 0
                                    ? Math.max(5,
                                        backgroundBar.height
                                        * Math.min(1,
                                            dayItem.minutes / chart.maxMinutes))
                                    : 0

                                radius: 11
                                color: "#087FFF"
                                visible: dayItem.minutes > 0
                            }

                            Text {
                                id: dayLabel
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: dayItem.modelData.day || ""
                                color: "#405D95"
                                font.family: c.uiFont
                                font.pixelSize: Math.round(11 * c.typeScale)
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton

                                ToolTip.visible: containsMouse
                                ToolTip.delay: 250
                                ToolTip.text:
                                    dayItem.modelData.date
                                    + "\n"
                                    + dayItem.minutes.toFixed(1)
                                    + " min · "
                                    + dayItem.modelData.sessions
                                    + " sessions"
                            }
                        }
                    }
                }

                Rectangle {
                    visible: !chart.hasActivity

                    anchors.centerIn: parent
                    width: Math.min(parent.width - 10, 330)
                    height: 65
                    radius: 29

                    color: "#FFFFFF"
                    border.color: "#CFD8FF"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Text {
                            text: "◷"
                            color: "#7519D0"
                            font.pixelSize: 28
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: chart.selectedWeek === 0
                                    ? "Start a focus session"
                                    : "No sessions recorded"
                                color: "#14366A"
                                font.family: c.uiFont
                                font.pixelSize: Math.round(12 * c.typeScale)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: chart.selectedWeek === 0
                                    ? "Build your weekly chart"
                                    : "Try another week"
                                color: "#5C719D"
                                font.family: c.uiFont
                                font.pixelSize: Math.round(11 * c.typeScale)
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            visible: chart.selectedWeek === 0
                            text: "›"
                            color: "#7519D0"
                            font.pixelSize: 24
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: chart.selectedWeek === 0
                        cursorShape: Qt.PointingHandCursor
                        onClicked: chart.focusRequested()
                    }
                }
            }

            Column {
                Layout.preferredWidth: chart.width < 610 ? 147 : 160
                Layout.alignment: Qt.AlignVCenter
                spacing: 7

                Repeater {
                    model: [
                        {
                            title: "Study time",
                            value: (chart.totalMinutes / 60).toFixed(1) + " h",
                            color: "#9AF2CF",
                            accent: "#008F63",
                            icon: "◷"
                        },
                        {
                            title: "Weekly goal",
                            value: chart.goalMinutes > 0
                                ? chart.goalPercent + "%" : "—",
                            color: "#D6B7F9",
                            accent: "#6B15C8",
                            icon: "◎"
                        },
                        {
                            title: "Sessions",
                            value: String(chart.sessions),
                            color: "#AAD6FF",
                            accent: "#0876E8",
                            icon: "▥"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 59
                        radius: 14
                        color: modelData.color

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 7
                            spacing: 7

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 23
                                text: modelData.icon
                                color: modelData.accent
                                font.pixelSize: 25
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 2
                                height: 30
                                radius: 1
                                color: modelData.accent
                                opacity: 0.65
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    text: modelData.title
                                    font.family: c.uiFont
                                    font.pixelSize: Math.round(11 * c.typeScale)
                                    color: "#203965"
                                }

                                Text {
                                    text: modelData.value
                                    font.family: c.uiFont
                                    font.pixelSize: Math.round(20 * c.typeScale)
                                    font.weight: Font.ExtraBold
                                    color: "#071B43"
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: chart.sessions
                + (chart.sessions === 1 ? " session" : " sessions")
                + (chart.selectedWeek === 0
                    ? " this week" : " in the selected week")
            color: "#5974A9"
            font.family: c.uiFont
            font.pixelSize: Math.round(11 * c.typeScale)
            horizontalAlignment: Text.AlignHCenter
        }
    }
}