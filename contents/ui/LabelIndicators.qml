pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: root

    property var device
    property int contentWidth

    readonly property var config: device.config
    readonly property var state: device.state

    readonly property var labels: [state.labelIndicator1, state.labelIndicator2, state.labelIndicator3]
    readonly property var visibleLabels: labels.filter(l => l && l.length > 0)
    readonly property int visibleCount: visibleLabels.length

    property int labelHorizontalPadding: Kirigami.Units.smallSpacing * 2
    property int labelVerticalPadding: 2 * Kirigami.Units.smallSpacing / 4
    property int rowSpacing: Kirigami.Units.smallSpacing
    property int rowVerticalPadding: Kirigami.Units.smallSpacing
    property int roundIndicatorsCorner: Kirigami.Units.smallSpacing

    width: contentWidth
    readonly property int indicatorHeight: Math.round(Kirigami.Theme.smallFont.pixelSize + labelVerticalPadding * 2)
    implicitHeight: indicatorHeight + rowVerticalPadding * 2

    Item {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.indicatorHeight
        anchors.margins: root.rowVerticalPadding

        Repeater {
            model: root.visibleLabels

            delegate: Rectangle {
                id: indicator
                required property string modelData
                required property int index

                radius: root.roundIndicatorsCorner
                color: Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.highlightColor    // accent tint
                , Kirigami.Theme.backgroundColor   // base surface
                , 0.8                            // strength
                )
                /*
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: Qt.lighter(Kirigami.Theme.highlightColor, 1.15)
        }
        GradientStop {
            position: 1.0
            color: Kirigami.adjustColor(Kirigami.Theme.highlightColor, 25)
        }
    }

*/                height: root.indicatorHeight
                width: label.implicitWidth + root.labelHorizontalPadding * 2

                PlasmaComponents3.Label {
                    id: label
                    anchors.centerIn: parent
                    text: indicator.modelData
                    font.family: "Inter"
                    font.contextFontMerging: true
                    font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                anchors.verticalCenter: parent.verticalCenter

                x: {
                    if (root.visibleCount === 1)
                        return (root.width - width) / 2;
                    if (root.visibleCount === 2)
                        return index === 0 ? 0 : root.width - width;
                    if (root.visibleCount === 3)
                        return index === 0 ? 0 : index === 1 ? (root.width - width) / 2 : root.width - width;
                    return 0;
                }
            }
        }
    }

    visible: visibleCount > 0
}
