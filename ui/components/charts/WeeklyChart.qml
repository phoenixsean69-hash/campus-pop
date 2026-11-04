// CAMPUS_POP_GENERAL_PACK_V33
import QtQuick
import QtQuick.Layouts
import "../../theme" as Theme

Rectangle {
    id: chart
    implicitHeight: 275
    radius: 17
    color: "#FFFFFF"
    border.color: "#F0E5DF"

    Theme.Colors { id: c }
    property var values: [1.5, 1.0, 2.1, 2.7, 3.4, 1.9, 2.0]
    property var days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 9

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Your Progress This Week"
                    font.pixelSize: Math.round(18 * c.typeScale)
                    font.weight: Font.ExtraBold
                    color: c.ink
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: "Study time, goals and consistency"
                    font.pixelSize: Math.round(13 * c.typeScale)
                    color: c.muted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        Item {
            id: chartBody
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 158

            // Explicit positions keep the plot from collapsing inside a RowLayout.
            Item {
                id: plotArea
                anchors.left: parent.left
                anchors.right: statColumn.left
                anchors.rightMargin: 12
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Item {
                    id: graph
                    x: 0
                    y: 12
                    width: parent.width
                    height: Math.max(70, parent.height - 47)

                    Repeater {
                        model: 5
                        delegate: Item {
                            required property int index
                            x: 0
                            y: (graph.height - 1) * index / 4 - 7
                            width: graph.width
                            height: 15
                            Text {
                                text: (4 - index) + "h"
                                color: c.muted
                                font.pixelSize: Math.round(12 * c.typeScale)
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                x: 34
                                width: Math.max(0, parent.width - 35)
                                height: 1
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#E8EDF2"
                            }
                        }
                    }

                    Item {
                        id: bars
                        x: 36
                        y: 0
                        width: Math.max(0, parent.width - 39)
                        height: graph.height

                        Repeater {
                            model: 7
                            delegate: Item {
                                required property int index
                                readonly property real slotWidth: bars.width / 7
                                x: index * slotWidth
                                y: 0
                                width: slotWidth
                                height: bars.height

                                Rectangle {
                                    width: Math.max(7, Math.min(29, parent.width * 0.60))
                                    height: Math.max(3, parent.height * chart.values[index] / 4)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    radius: 5
                                    color: index === 4 ? "#F97316" : "#FFA95C"
                                }
                                Text {
                                    y: parent.height + 8
                                    width: parent.width
                                    text: chart.days[index]
                                    horizontalAlignment: Text.AlignHCenter
                                    color: c.muted
                                    font.pixelSize: Math.round(12 * c.typeScale)
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: statColumn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                width: chartBody.width < 420 ? 100 : 118

                Rectangle {
                    width: statColumn.width
                    height: 72
                    radius: 12
                    color: "#E1F8F0"
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "12.4 h"
                            font.pixelSize: Math.round(20 * c.typeScale)
                            font.weight: Font.ExtraBold
                            color: "#078B72"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Study time"
                            font.pixelSize: Math.round(12 * c.typeScale)
                            color: "#357D70"
                        }
                    }
                }
                Rectangle {
                    width: statColumn.width
                    height: 72
                    radius: 12
                    color: "#E1F8F0"
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "85%"
                            font.pixelSize: Math.round(20 * c.typeScale)
                            font.weight: Font.ExtraBold
                            color: "#078B72"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Goal reached"
                            font.pixelSize: Math.round(12 * c.typeScale)
                            color: "#357D70"
                        }
                    }
                }
            }
        }
    }
}
