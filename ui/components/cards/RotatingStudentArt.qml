import QtQuick

// Purely visual: rotates through 20 bundled illustrations every 8 seconds.
// When the parent page is hidden, the timer pauses automatically.
Item {
    id: rotator
    clip: true

    property int currentIndex: 0
    property bool firstVisible: true
    readonly property int sceneCount: 20

    function sceneUrl(index) {
        const n = index + 1
        const number = n < 10 ? "0" + n : "" + n
        return Qt.resolvedUrl("../../../assets/illustrations/students/hero_" + number + ".jpg")
    }

    Image {
        id: sceneA
        anchors.fill: parent
        source: rotator.sceneUrl(0)
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        horizontalAlignment: Image.AlignHCenter
        asynchronous: false
        smooth: true
        opacity: rotator.firstVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.InOutQuad } }
    }
    Image {
        id: sceneB
        anchors.fill: parent
        source: rotator.sceneUrl(1)
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        horizontalAlignment: Image.AlignHCenter
        asynchronous: false
        smooth: true
        opacity: rotator.firstVisible ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 650; easing.type: Easing.InOutQuad } }
    }
    Timer {
        interval: 20000
        repeat: true
        running: rotator.visible && rotator.width > 0 && rotator.height > 0
        onTriggered: {
            const next = (rotator.currentIndex + 1) % rotator.sceneCount
            if (rotator.firstVisible) {
                sceneB.source = rotator.sceneUrl(next)
                rotator.firstVisible = false
            } else {
                sceneA.source = rotator.sceneUrl(next)
                rotator.firstVisible = true
            }
            rotator.currentIndex = next
        }
    }
}
