import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../theme" as Theme

Rectangle {
    id: root
    anchors.fill: parent
    visible: !profileBridge.onboarded || profileBridge.editing
    z: 3000
    color: "#CC101729"
    property int step: 0
    property var chosenCourses: []
    Theme.Colors { id: c }

    readonly property var courseCatalog: [
        "Applied Statistics", "Python Programming", "Computer Systems",
        "Software Engineering", "Discrete Mathematics", "Database Systems"
    ]

    function toggleCourse(course) {
        var copy = chosenCourses.slice(0)
        var i=copy.indexOf(course)
        if (i>=0) copy.splice(i,1)
        else copy.push(course)
        chosenCourses=copy
    }

    Component.onCompleted: {
        step=profileBridge.onboarded ? 1 : 0
        chosenCourses=profileBridge.enrolledCourses.length ? profileBridge.enrolledCourses.slice(0) : ["Applied Statistics", "Python Programming"]
        usernameField.text=profileBridge.username === "Student" && !profileBridge.onboarded ? "" : profileBridge.username
    }

    onVisibleChanged: if (visible) {
        step=profileBridge.onboarded ? 1 : 0
        chosenCourses=profileBridge.enrolledCourses.length ? profileBridge.enrolledCourses.slice(0) : ["Applied Statistics", "Python Programming"]
        usernameField.text=profileBridge.username === "Student" && !profileBridge.onboarded ? "" : profileBridge.username
        errorLabel.text=""
    }

    FileDialog {
        id: photoDialog
        title: "Select a profile picture"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp)"]
        onAccepted: {
            if (!profileBridge.pickAvatar(selectedFile.toString()))
                errorLabel.text=profileBridge.lastError
            else errorLabel.text=""
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(690, root.width - 36)
        height: Math.min(620, root.height - 36)
        color: c.surface
        radius: 24
        border.color: c.line
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.min(28,Math.max(18,card.width*0.04))
            spacing: 13

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Campus Pop"
                    color: c.ink
                    font.family: appFontFamily
                    font.pixelSize: 24
                    font.weight: Font.ExtraBold
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.step===0 ? "WELCOME" : root.step===1 ? "YOUR PROFILE" : "MY COURSES"
                    color: c.orangeDark
                    font.family: appFontFamily
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: c.line }

            ColumnLayout {
                visible: root.step===0
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                Item { Layout.fillHeight: true }
                Text {
                    text: "Your learning space.\nYour pace."
                    Layout.fillWidth: true
                    font.family: appFontFamily
                    font.pixelSize: Math.min(40,card.width*0.06)
                    font.weight: Font.ExtraBold
                    color: c.ink
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: "Get organised with your courses, study offline, and track what you've learned. Set up your profile to get started."
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.family: appFontFamily
                    font.pixelSize: 17
                    color: c.muted
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    radius: 15
                    color: c.purpleSoft
                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 32
                        wrapMode: Text.WordWrap
                        text: "Offline-first • Private study notes • Course-based help"
                        color: c.purple
                        font.family: appFontFamily
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                Item { Layout.fillHeight: true }
            }

            ColumnLayout {
                visible: root.step===1
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 13
                Text { text: "Create your student profile"; color: c.ink; font.family: appFontFamily; font.pixelSize: 25; font.weight: Font.ExtraBold }
                Text { text: "Choose a username and an optional profile photo. Both stay on this device."; color: c.muted; font.family: appFontFamily; font.pixelSize: 15; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                RowLayout {
                    Layout.topMargin: 16
                    spacing: 15
                    Rectangle {
                        Layout.preferredWidth: 82
                        Layout.preferredHeight: 82
                        radius: 22
                        color: c.orangeSoft
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: profileBridge.avatarUrl
                            fillMode: Image.PreserveAspectCrop
                            visible: source.toString().length>0
                            cache: false
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: profileBridge.avatarUrl.length===0
                            text: profileBridge.initials
                            color: c.orangeDark
                            font.family: appFontFamily
                            font.pixelSize: 25
                            font.weight: Font.Bold
                        }
                    }
                    ColumnLayout {
                        spacing: 8
                        Rectangle {
                            Layout.preferredHeight: 44
                            Layout.preferredWidth: 165
                            radius: 12
                            color: c.purpleSoft
                            border.color: c.line
                            Text { anchors.centerIn: parent; text: "Choose photo"; font.family: appFontFamily; color: c.purple; font.pixelSize: 14; font.weight: Font.Bold }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: photoDialog.open() }
                        }
                        Text { text: "PNG, JPG, WebP or BMP • max 10 MB"; color: c.muted; font.family: appFontFamily; font.pixelSize: 12 }
                    }
                }
                Text { Layout.topMargin: 15; text: "USERNAME"; color: c.ink; font.family: appFontFamily; font.pixelSize: 12; font.weight: Font.Bold }
                TextField {
                    id: usernameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    placeholderText: "Enter your name"
                    placeholderTextColor: c.muted
                    color: c.ink
                    font.family: appFontFamily
                    font.pixelSize: 17
                    background: Rectangle { radius: 13; color: c.elevated; border.color: usernameField.activeFocus ? c.orange : c.line; border.width: usernameField.activeFocus ? 2 : 1 }
                }
                Item { Layout.fillHeight: true }
            }

            ColumnLayout {
                visible: root.step===2
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                Text { text: "Which courses are you studying?"; color: c.ink; font.family: appFontFamily; font.pixelSize: 24; font.weight: Font.ExtraBold; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                Text { text: "Select your current courses. The offline tutor will prioritise these materials."; color: c.muted; font.family: appFontFamily; font.pixelSize: 15; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                GridLayout {
                    Layout.fillWidth: true
                    columns: card.width < 520 ? 1 : 2
                    columnSpacing: 10
                    rowSpacing: 10
                    Repeater {
                        model: root.courseCatalog
                        delegate: Rectangle {
                            id: courseTile
                            required property string modelData
                            readonly property bool picked: root.chosenCourses.indexOf(modelData)>=0
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            radius: 13
                            color: picked ? c.orangeSoft : c.elevated
                            border.color: picked ? c.orange : c.line
                            border.width: picked ? 2 : 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 9
                                Rectangle {
                                    Layout.preferredWidth: 25
                                    Layout.preferredHeight: 25
                                    radius: 8
                                    color: courseTile.picked ? c.orange : c.surface
                                    border.color: courseTile.picked ? c.orange : c.line
                                    Text { anchors.centerIn: parent; text: "✓"; visible: courseTile.picked; color: "white"; font.pixelSize: 17; font.weight: Font.Bold }
                                }
                                Text { Layout.fillWidth: true; text: courseTile.modelData; color: c.ink; font.family: appFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleCourse(courseTile.modelData) }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            Text {
                id: errorLabel
                Layout.fillWidth: true
                color: c.danger
                font.family: appFontFamily
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                text: ""
                visible: text.length>0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 49
                    radius: 13
                    color: c.elevated
                    border.color: c.line
                    visible: root.step>0 || profileBridge.onboarded
                    Text { anchors.centerIn: parent; text: root.step>1 ? "Back" : profileBridge.onboarded ? "Cancel" : "Back"; font.family: appFontFamily; font.pixelSize: 15; font.weight: Font.Bold; color: c.ink }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: {
                        if (root.step>1)root.step--
                        else if (profileBridge.onboarded)profileBridge.closeEditor()
                        else root.step=0
                    } }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 51
                    radius: 14
                    color: c.orange
                    Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 5; radius: 3; color: c.orangeDark; opacity: 0.6 }
                    Text { anchors.centerIn: parent; text: root.step===0 ? "Get started →" : root.step===1 ? "Choose courses →" : "Finish setup ✓"; font.family: appFontFamily; font.pixelSize: 15; font.weight: Font.ExtraBold; color: "white" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: {
                        if (root.step===0)root.step=1
                        else if (root.step===1) {
                            if (usernameField.text.trim().length<2) errorLabel.text="Enter a username (at least two characters)."
                            else { errorLabel.text="";root.step=2 }
                        } else if (!profileBridge.finish(usernameField.text,JSON.stringify(root.chosenCourses)))
                            errorLabel.text=profileBridge.lastError
                    } }
                }
            }
        }
    }
}
