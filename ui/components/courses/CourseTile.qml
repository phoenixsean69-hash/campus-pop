// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Theme
import "../buttons" as Duo

Rectangle {
    id: tile
    required property var courseData
    signal openRequested()

    implicitHeight: 270
    radius: 19
    color: "#FFFFFF"
    border.width: 2
    clip: true

    readonly property string titleLower: String(courseData.title || "").toLowerCase()
    readonly property string artName: {
        if (titleLower.indexOf("statistic") !== -1) return "statistics"
        if (titleLower.indexOf("python") !== -1) return "python"
        if (titleLower.indexOf("computer") !== -1 || titleLower.indexOf("hardware") !== -1) return "systems"
        if (titleLower.indexOf("software") !== -1 || titleLower.indexOf("engineer") !== -1) return "software"
        if (titleLower.indexOf("mathematic") !== -1 || titleLower.indexOf("discrete") !== -1) return "mathematics"
        if (titleLower.indexOf("database") !== -1 || titleLower.indexOf("sql") !== -1) return "database"
        return "general"
    }
    // Exactly three border families across every course card.
    readonly property color borderColor: {
        if (artName === "statistics" || artName === "mathematics") return "#F97316"
        if (artName === "python" || artName === "software") return "#2563EB"
        return "#8793A7"
    }
    readonly property color softColor: {
        if (artName === "statistics" || artName === "mathematics") return "#FFF0E4"
        if (artName === "python" || artName === "software") return "#E9F1FF"
        return "#EFF2F6"
    }
    border.color: borderColor

    Theme.Colors { id: c }

    // No decorative top strip: the full outline carries the accent color.
    MouseArea {
        id: tileMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.openRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 101
            spacing: 7

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                spacing: 7
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 9
                    Rectangle {
                        Layout.preferredWidth: 49
                        Layout.preferredHeight: 49
                        radius: 14
                        color: tile.softColor
                        Text {
                            anchors.centerIn: parent
                            text: tile.courseData.initials
                            font.family: c.uiFont
                            font.weight: Font.ExtraBold
                            font.pixelSize: Math.round(18 * c.typeScale)
                            color: tile.borderColor
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: tile.courseData.title
                            font.family: c.uiFont
                            font.weight: Font.ExtraBold
                            font.pixelSize: Math.round(17 * c.typeScale)
                            color: c.ink
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: tile.courseData.code + "  ·  " + tile.courseData.category
                            font.family: c.uiFont
                            font.pixelSize: Math.round(12 * c.typeScale)
                            color: c.muted
                            elide: Text.ElideRight
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: tile.courseData.topic
                    font.family: c.uiFont
                    font.pixelSize: Math.round(13 * c.typeScale)
                    color: "#606E83"
                    elide: Text.ElideRight
                }
                Item { Layout.fillHeight: true }
            }

            Image {
                Layout.preferredWidth: tile.width < 440 ? 96 : 118
                Layout.preferredHeight: tile.width < 440 ? 91 : 107
                source: Qt.resolvedUrl("../../../assets/icons/courses/" + tile.artName + ".svg")
                sourceSize.width: 236
                sourceSize.height: 214
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                asynchronous: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Rectangle {
                Layout.preferredWidth: statusLabel.implicitWidth + 20
                Layout.preferredHeight: 23
                radius: 8
                color: tile.courseData.progress >= 100 ? "#E0F5EB" : tile.courseData.progress === 0 ? "#F1F1F5" : tile.softColor
                Text {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: tile.courseData.progress >= 100 ? "Completed" : tile.courseData.progress === 0 ? "Not started" : "In progress"
                    color: tile.courseData.progress >= 100 ? "#17875A" : tile.courseData.progress === 0 ? "#72788A" : tile.borderColor
                    font.family: c.uiFont
                    font.weight: Font.Bold
                    font.pixelSize: Math.round(12 * c.typeScale)
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: tile.courseData.topicCount + " topics"
                font.family: c.uiFont
                font.pixelSize: Math.round(12 * c.typeScale)
                font.weight: Font.DemiBold
                color: c.muted
            }
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Course progress"
                font.family: c.uiFont
                font.pixelSize: Math.round(12 * c.typeScale)
                color: c.muted
            }
            Item { Layout.fillWidth: true }
            Text {
                text: tile.courseData.progress + "%"
                font.family: c.uiFont
                font.pixelSize: Math.round(15 * c.typeScale)
                font.weight: Font.ExtraBold
                color: tile.borderColor
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            color: "#EEF0F4"
            radius: 4
            clip: true
            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, Number(tile.courseData.progress))) / 100
                height: parent.height
                radius: 4
                color: tile.borderColor
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 5
            spacing: 6
            Text {
                text: tile.courseData.lecturer
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.family: c.uiFont
                font.pixelSize: Math.round(12 * c.typeScale)
                color: c.muted
            }
            Duo.DuoButton {
                text: "Open course"
                iconText: ""
                compact: true
                Layout.preferredWidth: 128
                Layout.preferredHeight: 39
                fillColor: tile.borderColor
                shadowColor: Qt.darker(tile.borderColor, 1.42)
                onClicked: tile.openRequested()
            }
        }
    }
}
