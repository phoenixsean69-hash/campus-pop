import QtQuick 2.15

// Campus Pop | Flat 2D stat card with a genuine transparent curved cut-out.
// No drop shadows, bevels, gradients, or fake 3D styling.
Item {
    id: card
    property string title: ""
    property string subtitle: ""
    property string figure: "—"
    property string iconName: "book"       // book, clock, target, flame
    property color fillColor: "#1464EF"
    signal clicked()

    implicitWidth: 400
    implicitHeight: 176
    clip: false

    readonly property real badgeRadius: Math.min(56, Math.max(46, width * 0.13))
    readonly property real badgeX: width - badgeRadius - 14
    readonly property real badgeY: badgeRadius + 1
    readonly property real bodyTop: 55

    Canvas {
        id: silhouette
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.Image

        function roundedRect(ctx, x, y, w, h, radius) {
            var r = Math.min(radius, w / 2, h / 2);
            ctx.beginPath();
            ctx.moveTo(x + r, y);
            ctx.lineTo(x + w - r, y);
            ctx.quadraticCurveTo(x + w, y, x + w, y + r);
            ctx.lineTo(x + w, y + h - r);
            ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
            ctx.lineTo(x + r, y + h);
            ctx.quadraticCurveTo(x, y + h, x, y + h - r);
            ctx.lineTo(x, y + r);
            ctx.quadraticCurveTo(x, y, x + r, y);
            ctx.closePath();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.save();
            // Flat, solid-color body.
            roundedRect(ctx, 1, card.bodyTop, width - 2, height - card.bodyTop - 2, 27);
            ctx.fillStyle = card.fillColor;
            ctx.fill();

            // Remove part of the body around the circular statistic.
            // This really is transparent, so it follows the dashboard background.
            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();
            ctx.arc(card.badgeX, card.badgeY, card.badgeRadius + 11, 0, 2 * Math.PI);
            ctx.fill();
            ctx.globalCompositeOperation = "source-over";

            // Separate floating circle in the SAME flat color.
            ctx.beginPath();
            ctx.arc(card.badgeX, card.badgeY, card.badgeRadius, 0, 2 * Math.PI);
            ctx.fillStyle = card.fillColor;
            ctx.fill();
            ctx.restore();
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }

    // True vector line icon, not an emoji or stock illustration.
    Canvas {
        id: symbol
        x: 29
        y: card.bodyTop + 29
        width: 56
        height: 56
        antialiasing: true
        renderTarget: Canvas.Image
        onPaint: {
            var c = getContext("2d");
            c.clearRect(0, 0, width, height);
            c.save();
            c.strokeStyle = "#FFFFFF";
            c.lineWidth = 3.7;
            c.lineCap = "round";
            c.lineJoin = "round";
            if (card.iconName === "book") {
                c.beginPath();
                c.moveTo(28, 13); c.bezierCurveTo(19, 9, 11, 9, 6, 13);
                c.lineTo(6, 43); c.bezierCurveTo(14, 39, 21, 39, 28, 44);
                c.bezierCurveTo(35, 39, 43, 39, 50, 43);
                c.lineTo(50, 13); c.bezierCurveTo(42, 9, 35, 9, 28, 13);
                c.lineTo(28, 44); c.stroke();
            } else if (card.iconName === "clock") {
                c.beginPath(); c.arc(28, 28, 21, 0, 2 * Math.PI); c.stroke();
                c.beginPath(); c.moveTo(28, 14); c.lineTo(28, 29); c.lineTo(37, 35); c.stroke();
            } else if (card.iconName === "target") {
                for (var i = 0; i < 3; ++i) {
                    c.beginPath(); c.arc(28, 28, 21 - i * 8, 0, 2 * Math.PI); c.stroke();
                }
            } else if (card.iconName === "flame") {
                c.beginPath();
                c.moveTo(29, 5); c.bezierCurveTo(35, 17, 25, 20, 38, 24);
                c.bezierCurveTo(42, 18, 41, 15, 42, 12);
                c.bezierCurveTo(58, 34, 47, 50, 29, 51);
                c.bezierCurveTo(10, 51, 4, 33, 19, 19);
                c.bezierCurveTo(18, 32, 28, 30, 29, 5); c.stroke();
            }
            c.restore();
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }

    Rectangle {
        x: 101
        y: card.bodyTop + 31
        width: 2
        height: 58
        radius: 1
        color: "#FFFFFF"
        opacity: 0.80
    }

    Text {
        id: label
        x: 116
        y: card.bodyTop + 25
        width: Math.max(80, card.width - 240)
        text: card.title
        color: "white"
        font.family: "Segoe UI"
        font.pixelSize: width > 150 ? 24 : 21
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
    Text {
        x: 116
        y: card.bodyTop + 62
        width: Math.max(80, card.width - 240)
        text: card.subtitle
        color: "white"
        opacity: 0.94
        font.family: "Segoe UI"
        font.pixelSize: 14
        elide: Text.ElideRight
    }
    Text {
        anchors.horizontalCenter: badgeNumberAnchor.horizontalCenter
        anchors.verticalCenter: badgeNumberAnchor.verticalCenter
        width: badgeNumberAnchor.width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "white"
        text: card.figure
        font.family: "Segoe UI"
        font.weight: Font.Bold
        font.pixelSize: card.figure.length > 5 ? 28 : 40
        minimumPixelSize: 19
        fontSizeMode: Text.Fit
        wrapMode: Text.NoWrap
    }
    Item {
        id: badgeNumberAnchor
        x: card.badgeX - card.badgeRadius + 10
        y: card.badgeY - 25
        width: card.badgeRadius * 2 - 20
        height: 50
    }
    // Navigation arrow is an honest interaction cue.
    Canvas {
        x: card.width - 52
        y: card.height - 45
        width: 20
        height: 24
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.strokeStyle = "white";
            ctx.lineWidth = 4;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.moveTo(6, 3); ctx.lineTo(16, 12); ctx.lineTo(6, 21); ctx.stroke();
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.clicked()
    }
}
