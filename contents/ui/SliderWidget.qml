pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var device
    property int boxId: 1
    property int pendingValue: 0
    property int previousValue: 0
    property bool hasSentDuringDrag: false

    Layout.fillWidth: true
    height: column.implicitHeight

    readonly property string valueProp: "box" + boxId + "SliderValue"
    readonly property string draggingProp: "box" + boxId + "SliderIsDragging"
    readonly property string titleProp: "box" + boxId + "SliderTitle"

    property bool programmaticUpdate: false

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            text: root.device.config[root.titleProp]
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Label {
                text: "−"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 16
                font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
            }

            PlasmaComponents3.Slider {
                id: slider
                Layout.fillWidth: true

                from: 0
                to: 100
                stepSize: 1

                onPressedChanged: {
                    if (!root.device)
                        return;

                    root.device.callUiAction(root.draggingProp, pressed ? 1 : 0);

                    if (!pressed) {
                        debounceTimer.stop();
                        root.device.callUiAction(root.valueProp, root.pendingValue);
                    }
                    root.hasSentDuringDrag = false;
                }

                onValueChanged: {
                    if (!root.device || root.programmaticUpdate || !pressed)
                        return;

                    const v = Math.round(value);
                    root.pendingValue = v;

                    if (!root.hasSentDuringDrag) {
                        root.device.callUiAction(root.valueProp, v);
                        root.previousValue = v;
                        root.hasSentDuringDrag = true;
                        debounceTimer.restart();
                    }
                }
            }

            PlasmaComponents3.Label {
                text: "+"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 16
                font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
            }
        }
    }

    Timer {
        id: debounceTimer
        interval: 200
        repeat: true

        onTriggered: {
            if (!root.device)
                return;

            if (root.previousValue !== root.pendingValue) {
                root.device.callUiAction(root.valueProp, root.pendingValue);
                root.previousValue = root.pendingValue;
            }
        }
    }

    Connections {
        target: root.device

        function onStateChanged() {
            if (!root.device)
                return;

            root.programmaticUpdate = true;
            slider.value = root.device.state[root.valueProp];
            root.programmaticUpdate = false;
        }
    }

    onDeviceChanged: {
        if (!device)
            return;

        root.programmaticUpdate = true;
        slider.value = root.device.state[valueProp];
        root.programmaticUpdate = false;
    }
}
