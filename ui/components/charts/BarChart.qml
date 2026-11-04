// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
ColumnLayout {
    id: root
    property var series: []
    property color barColor: "#F97316"
    property string emptyText: "Nothing recorded yet"
    readonly property real maximum: series.reduce(function(best, i) { return Math.max(best, Number(i.value) || 0) }, 1)
    spacing: 11
    Theme.Colors { id: c }
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 164
        spacing: 8
        Repeater {
            model: root.series
            delegate: ColumnLayout {
                id: col
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5
                Text {
                    Layout.fillWidth: true
                    text: String(col.modelData.value)
                    horizontalAlignment: Text.AlignHCenter
                    font.family: c.uiFont; font.pixelSize: Math.round(12 * c.typeScale); color: c.muted
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(35, parent.width * 0.70)
                        height: Math.max(4, parent.height * (Math.max(0, Number(col.modelData.value) || 0) / root.maximum))
                        radius: 6
                        color: root.barColor
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: String(col.modelData.name || col.modelData.day || "")
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.family: c.uiFont; font.pixelSize: Math.round(11 * c.typeScale); color: c.muted
                }
            }
        }
    }
    Text {
        visible: root.series.length === 0 || root.series.every(function(x) { return !(Number(x.value) > 0) })
        Layout.fillWidth: true
        text: root.emptyText
        color: c.muted
        font.family: c.uiFont
        font.pixelSize: Math.round(13 * c.typeScale)
        horizontalAlignment: Text.AlignHCenter
    }
}
