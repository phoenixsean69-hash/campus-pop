import QtQuick

// Screen-specific illustration for the existing (UI-only) workspace pages.
Item {
    id: scene
    property string sectionName: "My Courses"
    clip: true

    readonly property var artForPage: ({
        "My Courses": "hero_08.jpg",
        "AI Tutor": "hero_05.jpg",
        "Study Planner": "hero_06.jpg",
        "Practice Lab": "hero_03.jpg",
        "Focus Studio": "hero_15.jpg",
        "Performance": "hero_13.jpg",
        "Notes & Files": "hero_18.jpg",
        "Resources": "hero_10.jpg",
        "Settings": "hero_14.jpg"
    })

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/illustrations/students/" +
                               (scene.artForPage[scene.sectionName] || "hero_07.jpg"))
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: false
    }
}
