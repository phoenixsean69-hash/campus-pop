import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "TutorMarkup.js" as TutorMarkup
import "../../theme" as Theme

Item {
    id: root
    signal followUpRequested(string question)
    property var threadModel: null
    property int replyIndex: -1
    // CAMPUS_POP_RICH_RESPONSES_V36
    // CAMPUS_POP_MESSAGE_V27
    Theme.Colors { id: palette }
    property string message: ""
    property bool fromStudent: true
    property string attachedName: ""
    width: parent ? parent.width : 400
    implicitHeight: bubble.height + 16
    height: implicitHeight

    Rectangle {
        id: bubble
        width: Math.min(root.width - 42, root.fromStudent ? 530 : 590)
        height: messageColumn.implicitHeight + 26
        radius: 16
        anchors.right: root.fromStudent ? parent.right : undefined
        anchors.left: root.fromStudent ? undefined : parent.left
        anchors.rightMargin: root.fromStudent ? 16 : 0
        anchors.leftMargin: root.fromStudent ? 0 : 16
        color: root.fromStudent ? palette.purpleSoft : palette.surface
        border.color: palette.line

        Column {
            id: messageColumn
            x: 14
            y: 12
            width: parent.width - 28
            spacing: 7
            Text {
                text: root.fromStudent ? "YOU" : "CAMPUS POP"
                font.family: appFontFamily
                font.pixelSize: 11
                font.weight: Font.ExtraBold
                font.letterSpacing: 0.7
                color: root.fromStudent ? palette.purple : palette.orangeDark
            }
            Text {
                width: parent.width
                text: root.fromStudent ? root.message : TutorMarkup.render(root.message, palette.dark)
                textFormat: root.fromStudent ? Text.PlainText : Text.RichText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: appFontFamily
                font.pixelSize: 15
                font.weight: Font.Medium
                lineHeight: 1.19
                color: palette.ink
            }
            Text {
                visible: root.attachedName !== ""
                width: parent.width
                text: "Document: " + root.attachedName
                font.family: appFontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: palette.purple
                wrapMode: Text.WordWrap
            }
        }
    
        // CAMPUS_POP_REPLY_READER_V37_1: assistant replies have a reading-mode button.
        Rectangle {
            id: cpExpandReplyAction
            visible: !root.fromStudent && root.message.trim().length > 0
            width: 35
            height: 33
            radius: 9
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 10
            anchors.topMargin: 7
            z: 3
            color: cpExpandHover.pressed ? palette.purpleSoft : (cpExpandHover.containsMouse ? palette.elevated : palette.surface)
            border.color: cpExpandHover.containsMouse ? palette.purple : palette.line
            border.width: 1
            Canvas {
                id: cpExpandGlyph
                anchors.centerIn: parent
                width: 18
                height: 18
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = palette.ink
                    ctx.lineWidth = 1.7
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(2, 7); ctx.lineTo(2, 2); ctx.lineTo(7, 2)
                    ctx.moveTo(11, 2); ctx.lineTo(16, 2); ctx.lineTo(16, 7)
                    ctx.moveTo(2, 11); ctx.lineTo(2, 16); ctx.lineTo(7, 16)
                    ctx.moveTo(11, 16); ctx.lineTo(16, 16); ctx.lineTo(16, 11)
                    ctx.stroke()
                }
            }
            Connections {
                target: palette
                function onInkChanged() { cpExpandGlyph.requestPaint() }
            }
            MouseArea {
                id: cpExpandHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: cpFullscreenAnswer.open()
            }
            ToolTip.visible: cpExpandHover.containsMouse
            ToolTip.text: "Expand response"
            ToolTip.delay: 550
        }

    }


    // Full-window reading mode; keeps the conversation and the original response untouched.
        // CAMPUS_POP_INTERACTIVE_READER_V38
    // Full-window conversation reading: opening any answer positions that answer in view.
    Popup {
        id: cpFullscreenAnswer
        parent: Overlay.overlay
        x: 0
        y: 0
        width: parent ? parent.width : 960
        height: parent ? parent.height : 700
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape
        background: Rectangle { color: palette.canvas }

        function sendReaderQuestion() {
            var question = cpReaderDraft.text.trim()
            if (question.length === 0) return
            root.followUpRequested(question)
            cpReaderDraft.text = ""
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: cpFullscreenAnswer.width < 720 ? 12 : 22
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 12
                color: palette.surface
                border.color: palette.line
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 14
                    spacing: 12
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: "CAMPUS POP  ·  STUDY CONVERSATION"
                            font.family: appFontFamily
                            font.pixelSize: 12
                            font.weight: Font.ExtraBold
                            color: palette.purple
                        }
                        Text {
                            text: "Expanded reading view"
                            font.family: appFontFamily
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: palette.ink
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 92
                        Layout.preferredHeight: 36
                        radius: 9
                        color: cpReaderCloseHover.containsMouse ? palette.purpleSoft : palette.elevated
                        border.color: palette.line
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "×"; font.pixelSize: 22; color: palette.ink }
                            Text { text: "Close"; font.family: appFontFamily; font.pixelSize: 14; color: palette.ink }
                        }
                        MouseArea {
                            id: cpReaderCloseHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cpFullscreenAnswer.close()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: palette.surface
                border.color: palette.line
                clip: true

                ListView {
                    id: cpReaderThread
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    model: root.threadModel
                    spacing: 14
                    boundsBehavior: Flickable.StopAtBounds
                    boundsMovement: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Rectangle {
                        id: cpReadBubble
                        required property int index
                        required property var model
                        readonly property bool isStudent: Boolean(model.fromStudent)
                        width: Math.min(1020, Math.max(160, cpReaderThread.width - 30))
                        x: Math.max(10, (cpReaderThread.width - width) / 2)
                        height: cpReadBubbleBody.implicitHeight + 28
                        radius: 13
                        color: isStudent ? palette.purpleSoft : palette.surface
                        border.color: palette.line
                        border.width: 1

                        Column {
                            id: cpReadBubbleBody
                            x: 15
                            y: 13
                            width: cpReadBubble.width - 30
                            spacing: 9
                            Text {
                                width: parent.width
                                text: cpReadBubble.isStudent ? "YOU" : "CAMPUS POP"
                                font.family: appFontFamily
                                font.pixelSize: 11
                                font.weight: Font.ExtraBold
                                color: cpReadBubble.isStudent ? palette.purple : palette.orangeDark
                            }
                            Text {
                                width: parent.width
                                text: cpReadBubble.isStudent ? String(cpReadBubble.model.message || "") :
                                    TutorMarkup.render(String(cpReadBubble.model.message || ""), palette.dark)
                                textFormat: cpReadBubble.isStudent ? Text.PlainText : Text.RichText
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.family: appFontFamily
                                font.pixelSize: cpReadBubble.isStudent ? 15 : 17
                                lineHeight: 1.25
                                color: palette.ink
                                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                            }
                            Text {
                                visible: Boolean(cpReadBubble.model.attachedName)
                                width: parent.width
                                text: "Attached: " + String(cpReadBubble.model.attachedName || "")
                                wrapMode: Text.WordWrap
                                font.family: appFontFamily
                                font.pixelSize: 12
                                color: palette.muted
                            }
                        }
                    }
                    onCountChanged: {
                        if (cpFullscreenAnswer.opened && count > 0)
                            Qt.callLater(function() { cpReaderThread.positionViewAtEnd() })
                    }
                }
                Text {
                    visible: !root.threadModel
                    anchors.centerIn: parent
                    width: parent.width - 60
                    text: TutorMarkup.render(root.message, palette.dark)
                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.family: appFontFamily
                    font.pixelSize: 17
                    color: palette.ink
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 108
                radius: 12
                color: palette.surface
                border.color: palette.line
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    TextArea {
                        id: cpReaderDraft
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        wrapMode: TextEdit.Wrap
                        placeholderText: "Ask a follow-up question..."
                        placeholderTextColor: palette.muted
                        color: palette.ink
                        font.family: appFontFamily
                        font.pixelSize: 15
                        background: Item {}
                        Keys.onPressed: function(event) {
                            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) &&
                                    (event.modifiers & Qt.ControlModifier)) {
                                cpFullscreenAnswer.sendReaderQuestion()
                                event.accepted = true
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Ctrl + Enter to send  ·  Esc to close"
                            font.family: appFontFamily
                            font.pixelSize: 12
                            color: palette.muted
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 33
                            radius: 9
                            color: cpReaderSendHover.pressed ? palette.purple :
                                (cpReaderSendHover.containsMouse ? palette.purple : palette.purpleSoft)
                            border.color: palette.purple
                            Text {
                                anchors.centerIn: parent
                                text: "Send"
                                color: cpReaderSendHover.containsMouse ? "#FFFFFF" : palette.ink
                                font.family: appFontFamily
                                font.pixelSize: 14
                                font.weight: Font.Bold
                            }
                            MouseArea {
                                id: cpReaderSendHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: cpFullscreenAnswer.sendReaderQuestion()
                            }
                        }
                    }
                }
            }
        }
        onOpened: {
            cpReaderDraft.text = ""
            Qt.callLater(function() {
                if (cpReaderThread.count > 0)
                    cpReaderThread.positionViewAtIndex(Math.max(0, Math.min(root.replyIndex, cpReaderThread.count - 1)), ListView.Beginning)
            })
        }
    }

}
