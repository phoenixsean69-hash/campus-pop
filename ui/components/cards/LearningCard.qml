// CAMPUS_POP_CONTINUE_LEARNING_V46_10
// Flat, compact Dashboard course rows. Percentages are bound to courseItems,
// not duplicated in this component. A persisted course-progress source is
// still needed before these figures represent verified learning completion.
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme

Rectangle {
    id: root
    property var courseItems: []
    readonly property var visibleCourses: courseItems && courseItems.length
                                          ? courseItems.slice(0, 3) : []
    signal courseClicked(string course)

    implicitHeight: 94 + (visibleCourses.length > 0 ? visibleCourses.length * 57 : 44)
    radius: theme.packPop ? 17 : theme.panelRadius
    color: theme.cardSurface
    border.color: theme.cardBorder
    border.width: 1
    Theme.Colors { id: theme }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 43
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 40
                radius: 2
                color: "#FF6B08"
            }
            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true
                Text {
                    text: "Continue Learning"
                    font.family: theme.headlineFont
                    font.pixelSize: Math.round(18 * theme.typeScale)
                    font.weight: Font.ExtraBold
                    color: theme.ink
                }
                Text {
                    text: "Pick up where you left off"
                    font.family: theme.uiFont
                    font.pixelSize: Math.round(12 * theme.typeScale)
                    color: theme.muted
                }
            }
            Text {
                text: "View All  →"
                color: theme.dark ? "#91B8FF" : "#2563A9"
                font.family: theme.uiFont
                font.pixelSize: Math.round(13 * theme.typeScale)
                font.weight: Font.DemiBold
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.courseClicked("My Courses")
                }
            }
        }

        Repeater {
            model: root.visibleCourses
            delegate: Rectangle {
                id: courseRow
                required property var modelData
                required property int index
                readonly property real progressValue: Math.max(0, Math.min(100, Number(modelData.progress) || 0))
                readonly property color accent: modelData.title === "Applied Statistics" ? "#FF6900"
                    : modelData.title === "Python Programming" ? "#7421CD"
                    : modelData.title === "Computer Systems" ? "#007357"
                    : (modelData.accent || "#2563EB")

                Layout.fillWidth: true
                Layout.preferredHeight: 57
                radius: 12
                color: accent
                border.width: 0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 9

                    Item {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        Canvas {
                            anchors.fill: parent
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "white"
                                ctx.lineWidth = 2.3
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                var name = courseRow.modelData.title
                                ctx.beginPath()
                                if (name === "Applied Statistics") {
                                    ctx.moveTo(3, 28); ctx.lineTo(32, 28)
                                    ctx.moveTo(6, 32); ctx.lineTo(6, 5)
                                    ctx.moveTo(7, 27)
                                    ctx.bezierCurveTo(14, 26, 12, 8, 19, 9)
                                    ctx.bezierCurveTo(25, 10, 24, 27, 32, 28)
                                } else if (name === "Python Programming") {
                                    ctx.moveTo(13, 4)
                                    ctx.bezierCurveTo(7, 4, 9, 11, 9, 13)
                                    ctx.bezierCurveTo(9, 16, 6, 17, 4, 17)
                                    ctx.bezierCurveTo(6, 17, 9, 19, 9, 22)
                                    ctx.bezierCurveTo(9, 25, 7, 31, 13, 31)
                                    ctx.moveTo(22, 4)
                                    ctx.bezierCurveTo(28, 4, 26, 11, 26, 13)
                                    ctx.bezierCurveTo(26, 16, 29, 17, 31, 17)
                                    ctx.bezierCurveTo(29, 17, 26, 19, 26, 22)
                                    ctx.bezierCurveTo(26, 25, 28, 31, 22, 31)
                                } else {
                                    ctx.rect(9, 9, 17, 17)
                                    for (var i = 0; i < 4; i++) {
                                        var p = 11 + i * 5
                                        ctx.moveTo(p, 4); ctx.lineTo(p, 9)
                                        ctx.moveTo(p, 26); ctx.lineTo(p, 31)
                                        ctx.moveTo(4, p); ctx.lineTo(9, p)
                                        ctx.moveTo(26, p); ctx.lineTo(31, p)
                                    }
                                }
                                ctx.stroke()
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 32
                        color: "#FFFFFF"
                        opacity: 0.72
                    }
                    ColumnLayout {
                        Layout.preferredWidth: Math.max(105, Math.min(195, courseRow.width * 0.255))
                        Layout.minimumWidth: 90
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: courseRow.modelData.title || "Course"
                            color: "white"
                            font.family: theme.uiFont
                            font.pixelSize: Math.round((courseRow.width < 500 ? 12 : 14) * theme.typeScale)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: courseRow.modelData.topic || "Current topic"
                            color: "white"
                            opacity: 0.88
                            font.family: theme.uiFont
                            font.pixelSize: Math.round(10 * theme.typeScale)
                            elide: Text.ElideRight
                        }
                    }
                    Rectangle {
                        id: progressTrack
                        Layout.fillWidth: true
                        Layout.minimumWidth: 28
                        Layout.preferredHeight: 16
                        radius: 8
                        color: "#E1E1E6"
                        border.color: "white"
                        border.width: 2
                        clip: true
                        Rectangle {
                            x: 2
                            y: 2
                            width: Math.max(0, (progressTrack.width - 4) * courseRow.progressValue / 100)
                            height: progressTrack.height - 4
                            radius: 6
                            color: Qt.darker(courseRow.accent, 1.11)
                        }
                    }
                    Text {
                        Layout.preferredWidth: 47
                        text: Math.round(courseRow.progressValue) + "%"
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        font.family: theme.headlineFont
                        font.pixelSize: Math.round(14 * theme.typeScale)
                        font.weight: Font.ExtraBold
                    }
                    Text {
                        Layout.preferredWidth: 12
                        text: "›"
                        color: "white"
                        font.family: theme.uiFont
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.courseClicked(courseRow.modelData.title)
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.visibleCourses.length === 0
            text: "No courses yet. Open My Courses to add one."
            color: theme.muted
            font.family: theme.uiFont
            font.pixelSize: Math.round(12 * theme.typeScale)
            wrapMode: Text.Wrap
        }
    }
}
