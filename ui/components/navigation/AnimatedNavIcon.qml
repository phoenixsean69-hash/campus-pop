import QtQuick
import QtQuick.Layouts

// Displays a genuine Flaticon animated GIF. Animation runs only while hovered.
Item {
    id: iconRoot
    property string iconName: "dashboard"
    property bool hovered: false
    property bool reducedMotion: false

    implicitWidth: 31
    implicitHeight: 31

    AnimatedImage {
        id: movingIcon
        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/animated-icons-themed/" + iconRoot.iconName + ".gif")
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: true
        playing: iconRoot.hovered && !iconRoot.reducedMotion
        onStatusChanged: {
            if (status === Image.Ready && !iconRoot.hovered)
                currentFrame = 0
        }
    }

    // Keep a static, licensed icon visible if a GIF fails at runtime.
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/flaticon/" + iconRoot.iconName + ".png")
        visible: movingIcon.status !== Image.Ready
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    scale: iconRoot.hovered ? 1.09 : 1
    Behavior on scale {
        NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
    }

    onHoveredChanged: {
        if (hovered && !reducedMotion && movingIcon.status === Image.Ready)
            movingIcon.currentFrame = 0
    }
}
