// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
import "../buttons" as Duo
Rectangle {
    id: hero
    signal startStudy()
    signal askTutor()
    implicitHeight: 174; radius: 22; color: settingsBridge.themeKey === "campus" ? "#FFE3C3" : c.orangeSoft; clip: true
    Theme.Colors { id: c }
    RotatingStudentArt {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Math.min(465, parent.width * 0.50)
    }
    // Fade the boundary into the cream banner without covering the words.
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: Math.min(465, parent.width * 0.50) - 48
        width: 48
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: settingsBridge.themeKey === "campus" ? "#FFE3C3" : c.orangeSoft }
            GradientStop { position: 1.0; color: "#00FFE3C3" }
        }
    }
    ColumnLayout {
        anchors.left: parent.left; anchors.leftMargin: 22
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Text { text: "YOUR LEARNING SPACE"; color: c.orangeDark; font.pixelSize: Math.round(13 * c.typeScale); font.bold: true; font.letterSpacing: 1.4 }
        Text { text: "Make today count!"; color: c.ink; font.pixelSize: hero.width < 680 ? 25 : 31; font.weight: Font.ExtraBold }
        Text { text: "Keep going. Your next achievement starts here."; color: c.muted; font.pixelSize: Math.round(14 * c.typeScale) }
        RowLayout {
            Layout.topMargin: 9
            spacing: 10
            Duo.DuoButton {
                text: "Start Studying"
                iconText: "▶"
                Layout.preferredWidth: 174
                Layout.preferredHeight: 46
                fillColor: c.orange
                shadowColor: c.orangeDark
                onClicked: hero.startStudy()
            }
            Duo.DuoButton {
                text: "Ask AI Tutor"
                iconText: "✦"
                Layout.preferredWidth: 157
                Layout.preferredHeight: 46
                fillColor: "#9254ED"
                shadowColor: "#6D28B5"
                onClicked: hero.askTutor()
            }
        }
    }
}
