import QtQuick
import "../../theme" as Theme

// Flat 2D stat card with a transparent curved notch and floating figure.
// Only used on Dashboard; existing StatCard.qml remains unchanged.
Item {
    id: card
    implicitWidth: 310
    implicitHeight: 172

    property var value: "0"
    property string label: ""
    property string helper: ""
    property string icon: "book"
    readonly property string displayValue: value === null || value === undefined ? "—" : String(value)
    property color solidColor: "#0864EF"

    readonly property real bubbleRadius: Math.max(37, Math.min(52, width * 0.13))
    readonly property real bubbleX: width - bubbleRadius - 15
    readonly property real bubbleY: bubbleRadius + 6
    readonly property real topOffset: 48

    Theme.Colors { id: theme }

    // The gap surrounding the circle is transparent, not a fake white overlay.
    Canvas {
        id: backgroundShape
        anchors.fill: parent
        renderTarget: Canvas.Image
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            var r = 22
            var top = card.topOffset
            ctx.clearRect(0, 0, w, h)
            ctx.beginPath()
            ctx.moveTo(r, top)
            ctx.lineTo(w-r, top)
            ctx.quadraticCurveTo(w, top, w, top+r)
            ctx.lineTo(w, h-r)
            ctx.quadraticCurveTo(w, h, w-r, h)
            ctx.lineTo(r, h)
            ctx.quadraticCurveTo(0, h, 0, h-r)
            ctx.lineTo(0, top+r)
            ctx.quadraticCurveTo(0, top, r, top)
            ctx.closePath()
            ctx.fillStyle = card.solidColor
            ctx.fill()

            ctx.globalCompositeOperation = "destination-out"
            ctx.beginPath()
            ctx.arc(card.bubbleX, card.bubbleY, card.bubbleRadius + 9, 0, 2*Math.PI)
            ctx.fill()
            ctx.globalCompositeOperation = "source-over"
            ctx.beginPath()
            ctx.arc(card.bubbleX, card.bubbleY, card.bubbleRadius, 0, 2*Math.PI)
            ctx.fillStyle = card.solidColor
            ctx.fill()
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }

    onSolidColorChanged: backgroundShape.requestPaint()

    // Vector line icon: always white, with no external image dependency.
    Canvas {
        id: iconCanvas
        x: 17
        y: card.topOffset + 30
        width: 42
        height: 42
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)
            ctx.strokeStyle = "#FFFFFF"
            ctx.lineWidth = 2.7
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            var name = card.icon.toLowerCase()
            if (name === "book") {
                ctx.beginPath()
                ctx.moveTo(21,9)
                ctx.bezierCurveTo(16,6,9,7,4,10)
                ctx.lineTo(4,33)
                ctx.bezierCurveTo(10,31,16,32,21,35)
                ctx.bezierCurveTo(26,32,33,31,38,33)
                ctx.lineTo(38,10)
                ctx.bezierCurveTo(33,7,26,6,21,9)
                ctx.lineTo(21,35)
                ctx.stroke()
            } else if (name === "timer") {
                ctx.beginPath()
                ctx.arc(21,21,17,0,2*Math.PI)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(21,11)
                ctx.lineTo(21,22)
                ctx.lineTo(29,27)
                ctx.stroke()
            } else if (name === "target") {
                for (var i=0;i<3;i++) {
                    ctx.beginPath()
                    ctx.arc(21,21,18-i*7,0,2*Math.PI)
                    ctx.stroke()
                }
            } else if (name === "flame") {
                ctx.beginPath()
                ctx.moveTo(22,3)
                ctx.bezierCurveTo(31,15,18,19,30,22)
                ctx.bezierCurveTo(34,17,34,14,34,12)
                ctx.bezierCurveTo(45,27,36,39,22,39)
                ctx.bezierCurveTo(8,39,3,27,15,16)
                ctx.bezierCurveTo(14,26,23,27,22,3)
                ctx.stroke()
            }
        }
        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Rectangle {
        x: 72
        y: card.topOffset + 27
        width: 1
        height: 63
        color: "#FFFFFF"
        opacity: 0.78
    }
    Text {
        id: titleText
        x: 88
        y: card.topOffset + 24
        width: Math.max(70, card.width - card.bubbleRadius*2 - 115)
        text: card.label
        color: "#FFFFFF"
        font.family: theme.uiFont
        font.weight: Font.DemiBold
        font.pixelSize: Math.round((card.width < 350 ? 17 : 21) * theme.typeScale)
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }
    Text {
        x: 88
        y: card.topOffset + 60
        width: titleText.width
        text: card.helper
        color: "#FFFFFF"
        opacity: 0.89
        font.family: theme.uiFont
        font.pixelSize: Math.round(12 * theme.typeScale)
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }
    Text {
        x: card.bubbleX - card.bubbleRadius + 5
        y: card.bubbleY - card.bubbleRadius + 7
        width: card.bubbleRadius*2 - 10
        height: card.bubbleRadius*2 - 14
        text: card.displayValue
        color: "#FFFFFF"
        font.family: theme.uiFont
        font.weight: Font.ExtraBold
        font.pixelSize: 34
        minimumPixelSize: 16
        fontSizeMode: Text.Fit
        wrapMode: Text.NoWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
