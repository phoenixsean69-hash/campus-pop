// CAMPUS_POP_PACKS_V34
// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick

import QtQuick.Controls

import QtQuick.Layouts

import QtQuick.Dialogs

import "../../theme" as Theme



// CAMPUS_POP_INLINE_PROFILE_V32_1

Rectangle {

    id: root

    signal notice(string message)

    readonly property var courseCatalog: [

        "Applied Statistics", "Python Programming", "Computer Systems",

        "Software Engineering", "Discrete Mathematics", "Database Systems"

    ]

    property var chosenCourses: []

    property bool coursesExpanded: false

    property string pendingPhoto: ""

    property string errorText: ""

    readonly property string previewUrl: pendingPhoto.length > 0 ? pendingPhoto : profileBridge.avatarUrl

    implicitHeight: content.implicitHeight

    radius: c.packPop ? 22 : c.panelRadius

    color: c.surface

    border.color: c.line

    border.width: 1

    clip: true

    Theme.Colors { id: c }



    function resetDraft() {

        displayName.text = profileBridge.username

        chosenCourses = profileBridge.enrolledCourses.slice(0)

        coursesExpanded = false

        pendingPhoto = ""

        errorText = ""

    }

    function toggleCourse(name) {

        var items = chosenCourses.slice(0)

        var idx = items.indexOf(name)

        if (idx >= 0) items.splice(idx, 1)

        else items.push(name)

        chosenCourses = items

        errorText = ""

    }

    function saveProfile() {

        if (!profileBridge.saveInlineProfile(displayName.text, JSON.stringify(chosenCourses), pendingPhoto)) {

            errorText = profileBridge.lastError

            return

        }

        resetDraft()

        notice("Profile saved.")

    }

    Component.onCompleted: resetDraft()

    onVisibleChanged: if (visible) resetDraft()



    FileDialog {

        id: photoDialog

        title: "Choose your Campus Pop profile photo"

        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)"]

        onAccepted: {

            root.pendingPhoto = selectedFile.toString()

            root.errorText = ""

        }

    }



    component EditChip: Rectangle {

        id: chip

        signal clicked()

        property string glyph: "✎"

        width: 28

        height: 28

        radius: 10

        color: !c.packPop ? (mouse.containsMouse ? c.orangeSoft : c.elevated) : mouse.pressed ? (c.dark ? "#D86A11" : "#FFD8BA") : (mouse.containsMouse ? (c.dark ? "#F59A52" : "#FFE7D3") : (c.dark ? "#F0872A" : "#FFF1E4"))

        border.color: c.packPop ? (c.dark ? "#8B3B09" : "#F3C29A") : c.line

        border.width: 1

        Behavior on color { ColorAnimation { duration: 90 } }

        Text {

            anchors.centerIn: parent

            text: chip.glyph

            color: c.dark ? "#241936" : c.orangeDark

            font.family: c.uiFont

            font.pixelSize: Math.round(14 * c.typeScale)

            font.weight: Font.Black

        }

        MouseArea {

            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: chip.clicked()

        }

    }



    component RaisedPrimaryButton: Item {

        id: btn

        signal clicked()

        property string label: "Save profile"

        property bool compact: root.width < 560

        width: compact ? 132 : 170

        height: compact ? 54 : 58



        Rectangle {

            anchors.left: parent.left

            anchors.right: parent.right

            anchors.bottom: parent.bottom
            visible: c.packPop

            height: parent.height - (c.packPop ? 8 : 0)

            radius: c.packPop ? 16 : c.buttonRadius

            color: c.dark ? "#9F470A" : "#B95510"

        }

        Rectangle {

            id: face

            anchors.left: parent.left

            anchors.right: parent.right

            y: c.packPop && mouse.pressed ? 6 : 0

            height: parent.height - (c.packPop ? 8 : 0)

            radius: c.packPop ? 16 : c.buttonRadius

            gradient: Gradient {

                orientation: Gradient.Vertical

                GradientStop { position: 0.0; color: c.packPop ? (c.dark ? "#FF952F" : "#FF972F") : c.orange }

                GradientStop { position: 1.0; color: c.packPop ? (c.dark ? "#E97216" : "#F07C1B") : c.orange }

            }

            border.color: c.dark ? "#F4A25A" : "#E8771D"

            border.width: 1

            Behavior on y { NumberAnimation { duration: 75 } }



            Rectangle {

                anchors.left: parent.left

                anchors.right: parent.right

                anchors.top: parent.top

                anchors.leftMargin: 10

                anchors.rightMargin: 10

                anchors.topMargin: 5

                height: parent.height * 0.28

                radius: 12

                color: "#FFFFFF"

                opacity: c.packPop ? 0.17 : 0

            }

            Text {

                anchors.centerIn: parent

                text: btn.label

                color: "#FFFFFF"

                font.family: c.uiFont

                font.pixelSize: compact ? 14 : 16

                font.weight: Font.ExtraBold

            }

        }

        MouseArea {

            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: btn.clicked()

        }

    }



    ColumnLayout {

        id: content

        anchors.left: parent.left

        anchors.right: parent.right

        anchors.top: parent.top

        spacing: 0



        Rectangle {

            id: hero

            Layout.fillWidth: true

            Layout.preferredHeight: 202

            color: c.dark ? "#292940" : "#FFF2E8"

            clip: true



            Image {

                anchors.top: parent.top

                anchors.right: parent.right

                anchors.bottom: parent.bottom

                width: Math.max(235, parent.width * 0.44)

                source: root.previewUrl.length > 0

                    ? root.previewUrl

                    : Qt.resolvedUrl("../../../assets/illustrations/students/hero_06.jpg")

                fillMode: Image.PreserveAspectCrop

                verticalAlignment: Image.AlignVCenter

                smooth: true

                asynchronous: true

                cache: false

            }

            Rectangle {

                anchors.fill: parent

                gradient: Gradient {

                    orientation: Gradient.Horizontal

                    GradientStop { position: 0.0; color: c.dark ? "#292940" : "#FFF2E8" }

                    GradientStop { position: 0.54; color: c.dark ? "#292940" : "#FFF2E8" }

                    GradientStop { position: 0.79; color: c.dark ? "#00292940" : "#00FFF2E8" }

                    GradientStop { position: 1.0; color: "#00000000" }

                }

            }

            ColumnLayout {

                anchors.left: parent.left

                anchors.leftMargin: 30

                anchors.verticalCenter: parent.verticalCenter

                width: Math.max(215, parent.width * 0.59 - 26)

                spacing: 8

                Text {

                    text: "YOUR STUDYSPACE"

                    color: c.orangeDark

                    font.family: c.uiFont

                    font.pixelSize: Math.round(12 * c.typeScale)

                    font.weight: Font.Bold

                    font.letterSpacing: 1.1

                }

                Text {

                    text: "Settings"

                    color: c.ink

                    font.family: c.uiFont

                    font.pixelSize: Math.round(32 * c.typeScale)

                    font.weight: Font.ExtraBold

                }

                Text {

                    Layout.fillWidth: true

                    text: "Personalise your space. Changes save when you choose Save profile."

                    color: c.muted

                    font.family: c.uiFont

                    font.pixelSize: Math.round(14 * c.typeScale)

                    wrapMode: Text.WordWrap

                }

            }

            // CAMPUS_POP_PHOTO_BUTTON_V32_2
            Item {
                id: photoAction
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                width: 152
                height: 43

                // Full rounded backing, not the thin bottom line used previously.
                Rectangle {
                    x: 0
                    y: c.packPop ? 5 : 0
                    visible: c.packPop
                    width: parent.width
                    height: parent.height - (c.packPop ? 5 : 0)
                    radius: c.packPop ? 13 : c.buttonRadius
                    color: c.dark ? "#4B247F" : "#6733A4"
                }
                Rectangle {
                    id: photoFace
                    x: 0
                    y: c.packPop && photoClick.pressed ? 5 : 0
                    width: parent.width
                    height: parent.height - (c.packPop ? 5 : 0)
                    radius: c.packPop ? 13 : c.buttonRadius
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: c.packPop ? (c.dark ? "#B184FF" : "#A36AF2") : c.orange }
                        GradientStop { position: 1.0; color: c.packPop ? (c.dark ? "#8550DB" : "#8545D7") : c.orange }
                    }
                    border.color: c.dark ? "#C39AFE" : "#915BE0"
                    border.width: 1
                    Behavior on y { NumberAnimation { duration: 85 } }

                    // Low-key bevel similar to the existing 3D Campus Pop CTAs.
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 11
                        anchors.rightMargin: 11
                        anchors.topMargin: 4
                        height: 8
                        radius: 4
                        color: "#FFFFFF"
                        opacity: c.packPop ? (photoClick.containsMouse ? 0.23 : 0.13) : 0
                    }
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Item {
                            width: 19
                            height: 19
                            // Camera silhouette drawn with QML geometry: no font glyphs.
                            Rectangle {
                                x: 1; y: 6; width: 17; height: 11
                                radius: 3; color: "#FFFFFF"
                            }
                            Rectangle {
                                x: 5; y: 3; width: 8; height: 5
                                radius: 2; color: "#FFFFFF"
                            }
                            Rectangle {
                                x: 6; y: 8; width: 7; height: 7
                                radius: 4
                                color: c.packPop ? (c.dark ? "#8E55DD" : "#9052DB") : c.orangeDark
                                border.color: "#FFFFFF"
                                border.width: 1
                            }
                        }
                        Text {
                            text: "Change photo"
                            color: "#FFFFFF"
                            font.family: c.uiFont
                            font.pixelSize: Math.round(13 * c.typeScale)
                            font.weight: Font.ExtraBold
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                MouseArea {
                    id: photoClick
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: photoDialog.open()
                }
            }

        }



        Rectangle {

            Layout.fillWidth: true

            implicitHeight: Math.max(110, infoRow.implicitHeight + 34)

            color: c.surface

            RowLayout {

                id: infoRow

                anchors.left: parent.left

                anchors.right: parent.right

                anchors.verticalCenter: parent.verticalCenter

                anchors.leftMargin: 22

                anchors.rightMargin: 25

                spacing: 18



                ColumnLayout {

                    Layout.fillWidth: true

                    spacing: 4

                    RowLayout {

                        spacing: 8

                        TextField {

                            id: displayName

                            Layout.preferredWidth: Math.min(260, Math.max(130, root.width * 0.35))

                            Layout.preferredHeight: 46

                            selectByMouse: true

                            maximumLength: 48

                            font.family: c.uiFont

                            font.pixelSize: Math.round(19 * c.typeScale)

                            font.weight: Font.Bold

                            color: c.ink

                            placeholderText: "Your name"

                            placeholderTextColor: c.muted

                            leftPadding: 0

                            rightPadding: 4

                            background: Rectangle {

                                color: "transparent"

                                Rectangle {

                                    anchors.bottom: parent.bottom

                                    height: 2

                                    width: parent.width

                                    color: displayName.activeFocus ? c.orange : "transparent"

                                }

                            }

                            onAccepted: root.saveProfile()

                        }

                        EditChip {

                            glyph: "✎"

                            onClicked: {

                                displayName.forceActiveFocus()

                                displayName.selectAll()

                            }

                        }

                    }

                    RowLayout {

                        spacing: 8

                        Text {

                            text: root.chosenCourses.length + " selected " + (root.chosenCourses.length === 1 ? "course" : "courses")

                            color: c.orangeDark

                            font.family: c.uiFont

                            font.pixelSize: Math.round(14 * c.typeScale)

                            font.weight: Font.DemiBold

                        }

                        EditChip {

                            glyph: root.coursesExpanded ? "−" : "+"

                            onClicked: root.coursesExpanded = !root.coursesExpanded

                        }

                    }

                }

                Item { Layout.fillWidth: true }

                RaisedPrimaryButton {

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    label: "Save profile"

                    onClicked: root.saveProfile()

                }

            }

        }

        Rectangle {

            Layout.fillWidth: true

            Layout.preferredHeight: 1

            color: c.line

            visible: root.coursesExpanded

        }

        Rectangle {

            Layout.fillWidth: true

            visible: root.coursesExpanded

            implicitHeight: root.coursesExpanded ? coursesBody.implicitHeight + 30 : 0

            color: c.dark ? c.elevated : "#F7F3FC"

            ColumnLayout {

                id: coursesBody

                anchors.left: parent.left

                anchors.right: parent.right

                anchors.top: parent.top

                anchors.margins: 15

                spacing: 10

                Text {

                    text: "YOUR COURSES  ·  SELECT THE MODULES YOU'RE TAKING"

                    color: c.muted

                    font.family: c.uiFont

                    font.pixelSize: Math.round(12 * c.typeScale)

                    font.weight: Font.Bold

                    wrapMode: Text.WordWrap

                }

                Flow {

                    Layout.fillWidth: true

                    spacing: 9

                    Repeater {

                        model: root.courseCatalog

                        delegate: Rectangle {

                            id: chip

                            required property string modelData

                            readonly property bool chosen: root.chosenCourses.indexOf(modelData) >= 0

                            width: Math.min(246, Math.max(160, root.width - 38))

                            height: 39

                            radius: 11

                            color: chosen ? c.orangeSoft : c.surface

                            border.color: chosen ? c.orange : c.line

                            border.width: chosen ? 2 : 1

                            Row {

                                anchors.centerIn: parent

                                spacing: 8

                                Text { text: chip.chosen ? "✓" : "+"; color: chip.chosen ? c.orangeDark : c.muted; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold }

                                Text { text: chip.modelData; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.DemiBold }

                            }

                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleCourse(chip.modelData) }

                        }

                    }

                }

            }

        }

        Text {

            visible: root.errorText.length > 0

            Layout.fillWidth: true

            Layout.leftMargin: 20

            Layout.rightMargin: 20

            Layout.topMargin: 8

            Layout.bottomMargin: 8

            text: root.errorText

            color: c.danger

            font.family: c.uiFont

            font.pixelSize: Math.round(13 * c.typeScale)

            wrapMode: Text.WordWrap

        }

    }

}

