pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property var device
    property int boxId
    property int widgetWidth

    readonly property var config: device.config
    readonly property var options: config["optionsBox" + boxId]

    spacing: Kirigami.Units.smallSpacing * 3
    Layout.alignment: Qt.AlignHCenter

    Repeater {
        model: root.options

        delegate: Loader {
            Layout.alignment: Qt.AlignHCenter
            required property string modelData
            sourceComponent: {
                if (modelData === "slider")
                    return sliderComp;

                if (modelData === "check-button")
                    return checkComp;

                if (modelData === "radio-button")
                    return radioComp;

                return null;
            }
        }
    }

    Component {
        id: sliderComp
        SliderWidget {
            device: root.device
            boxId: root.boxId
        }
    }

    Component {
        id: checkComp
        CheckButtonsSet {
            device: root.device
            boxId: root.boxId
        }
    }

    Component {
        id: radioComp
        RadioButtonsSet {
            device: root.device
            boxId: root.boxId
        }
    }
}
