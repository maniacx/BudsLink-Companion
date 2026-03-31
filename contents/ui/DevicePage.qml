pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Flickable {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    property bool hovering

    HoverHandler {
        target: root
        onHoveredChanged: root.hovering = hovered
    }

    PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
        property bool shouldShow: root.hovering || hovered || pressed
        policy: PlasmaComponents3.ScrollBar.AsNeeded

        opacity: shouldShow ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    property int widgetWidth: Kirigami.Units.gridUnit * 15
    property var device
    readonly property var config: device.config
    readonly property bool toggleSet1Enabled: config.toggle1Button1Icon && config.toggle1Button2Icon
    readonly property bool toggleSet2Enabled: config.toggle2Button1Icon && config.toggle2Button2Icon

    contentHeight: columnLayout.implicitHeight
    contentWidth: width

    ColumnLayout {
        id: columnLayout
        width: root.contentWidth
        spacing: Kirigami.Units.smallSpacing * 4

        DeviceHeader {
            device: root.device
            contentWidth: root.widgetWidth
            Layout.alignment: Qt.AlignHCenter
        }

        WidgetCard {
            Layout.alignment: Qt.AlignHCenter
            cardWidth: root.widgetWidth
            content: [
                BatterySetWidget {
                    device: root.device
                }
            ]
        }

        Loader {
            active: root.toggleSet1Enabled
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: WidgetCard {
                cardWidth: root.widgetWidth
                content: [
                    ToggleButtonsSet {
                        device: root.device
                        isSecondSet: false
                    }
                ]
            }
        }

        Loader {
            active: root.toggleSet2Enabled
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: WidgetCard {
                cardWidth: root.widgetWidth
                content: [
                    ToggleButtonsSet {
                        device: root.device
                        isSecondSet: true
                    }
                ]
            }
        }

        Loader {
            active: root.device.config.labelIndicatorEnabled > 0

            Layout.alignment: Qt.AlignHCenter

            sourceComponent: LabelIndicators {
                device: root.device
                contentWidth: root.widgetWidth
            }
        }
    }
}
