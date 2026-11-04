// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
Rectangle {
    id: root
    property string kicker: "YOUR STUDYSPACE"
    property string heading: ""
    property string subtitle: ""
    property string illustration: ""
    implicitHeight: 149
    radius: 18; color: c.orangeSoft; clip: true
    Theme.Colors { id: c }
    Image {
        visible: root.illustration.length > 0
        source: Qt.resolvedUrl("../../../assets/illustrations/students/" + root.illustration)
        anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom
        width: Math.min(260, parent.width * 0.36)
        fillMode: Image.PreserveAspectCrop; asynchronous: true; smooth: true
    }
    Rectangle {
        anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.right: parent.right; anchors.rightMargin: Math.min(260, parent.width * 0.36) - 53
        width: 55
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: c.orangeSoft }
            GradientStop { position: 1; color: "#00FFFFFF" }
        }
    }
    ColumnLayout {
        anchors.left: parent.left; anchors.leftMargin: 23
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - Math.min(255, parent.width * .37) - 25
        spacing: 5
        Text { text: root.kicker; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); font.weight: Font.Bold; font.letterSpacing: 1.2; color: c.orangeDark }
        Text { Layout.fillWidth: true; text: root.heading; font.family: c.uiFont; font.pixelSize: Math.round(26 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink; elide: Text.ElideRight }
        Text { Layout.fillWidth: true; text: root.subtitle; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted; wrapMode: Text.WordWrap }
    }
}
