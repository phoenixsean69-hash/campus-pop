// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme
ColumnLayout {
    id: root
    property var series: []
    property bool donut: true
    property string centerText: ""
    property string emptyText: "No activity yet"
    property var palette: ["#F97316", "#2563EB", "#14B8A6", "#8B5CF6", "#F59E0B", "#64748B"]
    readonly property real total: series.reduce(function(sum, item) {return sum + Math.max(0,Number(item.value) || 0)}, 0)
    spacing: 10
    Theme.Colors { id: c }
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 195
        Canvas {
            id: canvas
            anchors.centerIn: parent
            width: Math.min(190,parent.width)
            height: 190
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var cx = width / 2, cy = height / 2, r = 78
                if (root.total <= 0) {
                    ctx.beginPath(); ctx.arc(cx,cy,r,0,Math.PI*2)
                    ctx.lineWidth = 22; ctx.strokeStyle = c.line; ctx.stroke()
                    return
                }
                var angle = -Math.PI/2
                for (var i=0;i<root.series.length;i++) {
                    var value=Math.max(0,Number(root.series[i].value) || 0)
                    if (value <= 0) continue
                    var sweep = Math.PI*2*value/root.total
                    ctx.beginPath();ctx.moveTo(cx,cy);ctx.arc(cx,cy,r,angle,angle+sweep);ctx.closePath()
                    ctx.fillStyle = root.palette[i % root.palette.length];ctx.fill()
                    angle += sweep
                }
                if (root.donut) {
                    ctx.beginPath();ctx.arc(cx,cy,51,0,Math.PI*2)
                    ctx.fillStyle = c.surface;ctx.fill()
                }
            }
        }
        Text {
            visible: root.donut
            anchors.centerIn: parent
            text: root.total > 0 ? (root.centerText.length ? root.centerText : Math.round(root.total) + "") : "—"
            color: c.ink
            font.family: c.uiFont
            font.pixelSize: Math.round(24 * c.typeScale)
            font.weight: Font.ExtraBold
        }
    }
    Text {
        visible: root.total <= 0
        Layout.fillWidth: true
        text: root.emptyText
        horizontalAlignment: Text.AlignHCenter
        color: c.muted
        font.family: c.uiFont
        font.pixelSize: Math.round(13 * c.typeScale)
    }
    Repeater {
        model: root.total > 0 ? root.series : []
        delegate: RowLayout {
            id: segment
            required property var modelData
            required property int index
            Layout.fillWidth: true
            visible: (Number(modelData.value) || 0) > 0
            spacing: 8
            Rectangle { Layout.preferredWidth: 10; Layout.preferredHeight: 10; radius: 3; color: root.palette[segment.index % root.palette.length] }
            Text { Layout.fillWidth: true; text: segment.modelData.name; elide: Text.ElideRight; color: c.ink; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale) }
            Text { text: String(segment.modelData.value); color: c.muted; font.family: c.uiFont; font.pixelSize: Math.round(13 * c.typeScale); font.weight: Font.Bold }
        }
    }
    onSeriesChanged: canvas.requestPaint()
    onPaletteChanged: canvas.requestPaint()
    onDonutChanged: canvas.requestPaint()
    Connections { target: settingsBridge; function onAppearanceChanged() { canvas.requestPaint() } }
}
