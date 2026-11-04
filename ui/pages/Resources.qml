// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme" as Theme
import "../components/workspace" as W

ColumnLayout {
    id: root
    signal notice(string message)
    spacing: 14
    Theme.Colors { id: c }
    property var sites: [
        {name:"Python Documentation", description:"Official language tutorial, library reference and examples.", subject:"PROGRAMMING", url:"https://docs.python.org/3/"},
        {name:"OpenStax", description:"Free peer-reviewed textbooks across mathematics and science.", subject:"TEXTBOOKS", url:"https://openstax.org/subjects"},
        {name:"MIT OpenCourseWare", description:"University lecture notes and open course materials.", subject:"COURSE MATERIAL", url:"https://ocw.mit.edu/"},
        {name:"Khan Academy", description:"Practice and explanations for mathematics and statistics.", subject:"PRACTICE", url:"https://www.khanacademy.org/"},
        {name:"SQLite Documentation", description:"Database language and transaction reference.", subject:"DATABASES", url:"https://sqlite.org/docs.html"},
        {name:"Qt for Python", description:"PySide6 tutorials and API reference.", subject:"DESKTOP DEVELOPMENT", url:"https://doc.qt.io/qtforpython-6/"}
    ]
    W.PageBanner { Layout.fillWidth: true; heading: "Resources"; subtitle: "A practical collection of learning references and useful tools."; illustration: "hero_20.jpg" }
    // CAMPUS_POP_RESOURCE_SYNC_V26
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 192
        radius: c.packPop ? 17 : c.panelRadius
        color: c.surface
        border.color: c.line
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { text: "Open Knowledge Library"; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                    Text { text: "Python, Java, C++, JavaScript, Visual Basic, mathematics & statistics"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
                W.SolidAction { text: libraryBridge.busy ? "Importing..." : "Sync Library"; enabled: !libraryBridge.busy; onClicked: libraryBridge.sync() }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: c.line }
            Text { Layout.fillWidth: true; text: libraryBridge.status; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.ink; wrapMode: Text.WordWrap }
            Text { text: libraryBridge.sources + " resources · " + libraryBridge.passages + " searchable passages"; font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted }
            Text { text: "Downloads only when you click Sync. Attribution and licenses are shown in AI Tutor answers."; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); color: c.muted; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        }
    }
    W.SectionHeading { Layout.fillWidth: true; heading: "Learning library"; subtitle: "Public resources open in your web browser; imported personal files stay on your device." }
    GridLayout {
        Layout.fillWidth: true; columns: root.width < 650 ? 1 : 2; rowSpacing: 11; columnSpacing: 11
        Repeater {
            model: root.sites
            delegate: Rectangle {
                id: tile
                required property var modelData
                Layout.fillWidth: true; Layout.preferredHeight: 170
                radius: c.packPop ? 17 : c.panelRadius; color: c.cardSurface; border.color: c.cardBorder
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 17; spacing: 6
                    Text { text: tile.modelData.subject; font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); font.weight: Font.Bold; color: c.orangeDark; font.letterSpacing: 0.8 }
                    Text { text: tile.modelData.name; font.family: c.uiFont; font.pixelSize: Math.round(18 * c.typeScale); font.weight: Font.ExtraBold; color: c.ink }
                    Text { text: tile.modelData.description; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); color: c.muted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    Item { Layout.fillHeight: true }
                    W.SolidAction { Layout.alignment: Qt.AlignRight; text: "Open resource"; onClicked: Qt.openUrlExternally(tile.modelData.url) }
                }
            }
        }
    }
}
