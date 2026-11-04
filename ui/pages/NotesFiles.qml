// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../theme" as Theme
import "../components/workspace" as W

ColumnLayout {
    id: root
    signal notice(string message)
    spacing: 14
    Theme.Colors { id: c }
    property string selectedNote: ""
    property string summaryText: ""
    property string summaryTitle: "Imported material"
    readonly property var importedFiles: workspaceBridge.files
    property string currentFileId: ""
    FileDialog {
        id: uploadDialog
        title: "Import study material"
        nameFilters: ["Documents (*.pdf *.docx *.txt *.md *.pptx *.xlsx)", "All files (*)"]
        onAccepted: {
            var error = workspaceBridge.importFile(selectedFile.toString())
            root.notice(error ? "Import failed: " + error : "File imported into StudySpace.")
        }
    }
    W.PageBanner { Layout.fillWidth: true; heading: "Notes & Files"; subtitle: "Keep your handwritten ideas and course material together."; illustration: "hero_18.jpg" }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 600 ? 1 : 2; rowSpacing: 12; columnSpacing: 12
        Rectangle {
            Layout.fillWidth: true; implicitHeight: noteEditor.implicitHeight + 34; radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout {
                id: noteEditor
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: 17; spacing: 9
                W.SectionHeading { Layout.fillWidth: true; heading: "Write a note"; subtitle: "Your work is saved on this PC." }
                W.TextInputBox { id: noteTitle; Layout.fillWidth: true; placeholderText: "Note title" }
                ScrollView {
                    Layout.fillWidth: true; Layout.preferredHeight: 190; clip: true
                    TextArea {
                        id: noteBody; placeholderText: "Write your ideas, definitions, summaries or key formulas…"
                        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
                        color: c.ink; wrapMode: TextEdit.Wrap
                        background: Rectangle { radius: 10; color: c.elevated; border.color: c.line }
                    }
                }
                W.SolidAction {
                    text: "Save note"; Layout.alignment: Qt.AlignRight
                    onClicked: {
                        if (workspaceBridge.addNote(noteTitle.text, noteBody.text)) {
                            noteTitle.text = ""; noteBody.text = ""; root.notice("Note saved.")
                        } else root.notice("A title and note text are both required.")
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true; implicitHeight: savedNotes.implicitHeight + 34; radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
            ColumnLayout {
                id: savedNotes
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: 17; spacing: 10
                W.SectionHeading { Layout.fillWidth: true; heading: "Saved notes"; subtitle: workspaceBridge.notes.length + " notes available" }
                Text { visible: workspaceBridge.notes.length === 0; text: "No notes yet. Create one to get started."; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted; Layout.preferredHeight: 58 }
                Repeater {
                    model: workspaceBridge.notes
                    delegate: Rectangle {
                        id: noteRow
                        required property var modelData
                        Layout.fillWidth: true; Layout.preferredHeight: 67; radius: 11
                        color: c.elevated
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 6
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 3
                                Text { Layout.fillWidth: true; text: noteRow.modelData.title; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); font.weight: Font.Bold; color: c.ink; elide: Text.ElideRight }
                                Text { text: noteRow.modelData.when; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted }
                            }
                            W.SolidAction { text: "Read"; Layout.preferredWidth: 65; Layout.preferredHeight: 36; onClicked: { root.selectedNote = noteRow.modelData.body; readDialog.open() } }
                            W.SolidAction { text: "×"; Layout.preferredWidth: 36; Layout.preferredHeight: 36; fillColor: "#FDE5E2"; bottomColor: "#E6AAA3"; labelColor: "#A33F35"; onClicked: workspaceBridge.deleteNote(noteRow.modelData.id) }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: filesBody.implicitHeight + 36; radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: filesBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 18; spacing: 11
            RowLayout {
                Layout.fillWidth: true
                W.SectionHeading { Layout.fillWidth: true; heading: "My course files"; subtitle: "Imported documents are copied to local StudySpace storage." }
                W.SolidAction { text: "Import file"; onClicked: uploadDialog.open() }
            }
            Text { visible: workspaceBridge.files.length === 0; text: "No documents imported yet. PDF, DOCX, TXT, MD, PPTX and XLSX are supported."; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); color: c.muted; Layout.preferredHeight: 56; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            Repeater {
                model: workspaceBridge.files
                delegate: Rectangle {
                    id: fileRow
                    required property var modelData
                    Layout.fillWidth: true; Layout.preferredHeight: 55; radius: 11; color: c.elevated
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 9
                        Text { text: fileRow.modelData.type; color: c.orangeDark; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); font.weight: Font.ExtraBold }
                        Text { text: fileRow.modelData.name; Layout.fillWidth: true; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale); elide: Text.ElideRight }
                        W.SolidAction { text: "Open"; Layout.preferredHeight: 36; Layout.preferredWidth: 67; onClicked: workspaceBridge.openFile(fileRow.modelData.id) }
                        W.SolidAction { text: "Remove"; Layout.preferredHeight: 36; Layout.preferredWidth: 77; fillColor: "#F5E8E6"; bottomColor: "#DFC8C5"; labelColor: "#9D493C"; onClicked: workspaceBridge.deleteFile(fileRow.modelData.id) }
                    }
                }
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true; implicitHeight: summaryBody.implicitHeight + 38
        radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
        ColumnLayout {
            id: summaryBody
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: 18; spacing: 10
            W.SectionHeading { Layout.fillWidth: true; heading: "Document summary"; subtitle: "Local extractive summary. Source sentences only; no AI-generated content yet." }
            W.VisibleCombo {
                id: fileSelect; Layout.fillWidth: true
                model: ["Select a document"].concat(root.importedFiles.map(function(row){return row.name}))
                onActivated: { root.currentFileId = currentIndex > 0 && currentIndex <= root.importedFiles.length ? root.importedFiles[currentIndex-1].id : "" }
            }
            Flow { Layout.fillWidth: true; spacing: 8
                W.SolidAction {
                    text: "Preview text"
                    enabled: root.currentFileId.length > 0
                    onClicked: { root.summaryText = workspaceBridge.extractFileText(root.currentFileId); root.summaryTitle = fileSelect.currentText }
                }
                W.SolidAction {
                    text: "Summarise document"; enabled: root.currentFileId.length > 0
                    fillColor: "#7E51E8"; bottomColor: "#5A2FB8"
                    onClicked: { root.summaryText = workspaceBridge.summarizeFile(root.currentFileId); root.summaryTitle = "Summary — " + fileSelect.currentText }
                }
                W.SolidAction {
                    text: "Save as note"; enabled: root.summaryText.length > 0 && !root.summaryText.startsWith("Could not")
                    fillColor: "#0DAB91"; bottomColor: "#087B6B"
                    onClicked: root.notice(workspaceBridge.addNote(root.summaryTitle, root.summaryText) ? "Summary saved to your notes." : "Could not save summary.")
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 205; radius: 12; color: c.elevated; border.color: c.line
                ScrollView { anchors.fill: parent; anchors.margins: 12; clip: true
                    TextArea {
                        readOnly: true; selectByMouse: true
                        text: root.summaryText.length ? root.summaryText : "Import a file, choose it above, then select Preview text or Summarise document."
                        color: c.ink; wrapMode: TextEdit.Wrap
                        font.family: c.uiFont; font.pixelSize: Math.round(14 * c.typeScale)
                        background: Rectangle { color: "transparent" }
                    }
                }
            }
            Text { Layout.fillWidth: true; text: "Works locally with TXT, Markdown, DOCX, PPTX, XLSX and text-based PDFs (with pypdf). Extractive summaries select important original sentences; AI summarization arrives with V21."; wrapMode: Text.WordWrap; color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale) }
        }
    }
    Dialog {
        id: readDialog
        title: "Saved note"
        modal: true
        width: Math.min(root.width - 32, 620)
        height: Math.min(480, root.height - 25)
        anchors.centerIn: Overlay.overlay
        standardButtons: Dialog.Close
        background: Rectangle { color: c.surface; radius: 17; border.color: c.line }
        ScrollView {
            anchors.fill: parent; clip: true
            TextArea { text: root.selectedNote; readOnly: true; wrapMode: TextEdit.Wrap; font.family: c.uiFont; font.pixelSize: Math.round(15 * c.typeScale); color: c.ink; background: Rectangle { color: "transparent" } }
        }
    }
}
