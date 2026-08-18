pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: column.implicitHeight
    Layout.margins: Kirigami.Units.smallSpacing * 2
    visible: isVisible

    property var device
    property bool isSecondSet: false
    readonly property var config: device.config
    readonly property int currentState: isSecondSet ? device.state.toggle2State : device.state.toggle1State
    readonly property bool isVisible: isSecondSet ? device.state.toggle2Visible : device.state.toggle1Visible

    readonly property bool hasAnyOptions: {
        if (isSecondSet)
            return false;

        const boxes = [config.optionsBox1, config.optionsBox2, config.optionsBox3, config.optionsBox4];

        return boxes.some(arr => arr.length > 0);
    }

    readonly property var buttonModel: {
        if (!device || !device.config)
            return [];

        var icons = [];
        for (var i = 1; i <= 4; i++) {
            var iconName = isSecondSet ? device.config["toggle2Button" + i + "Icon"] : device.config["toggle1Button" + i + "Icon"];

            if (iconName) {
                icons.push({
                    index: i - 1,
                    icon: iconName
                });
            }
        }
        return icons;
    }

    ColumnLayout {
        id: column

        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing * 2

        Label {
            text: root.isSecondSet ? root.device.config.toggle2Title : root.device.config.toggle1Title

            visible: text.length > 0
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing

            ButtonGroup {
                id: group
                exclusive: true
            }

            Repeater {
                model: root.buttonModel

                delegate: PlasmaComponents3.ToolButton {
                    icon.height: 16
                    icon.width: 16

                    leftPadding: 20
                    rightPadding: 20
                    topPadding: 0
                    bottomPadding: 0

                    flat: false
                    ButtonGroup.group: group

                    required property var modelData
                    readonly property int buttonIndex: modelData.index

                    checked: root.currentState === (buttonIndex + 1)

                    icon.source: Qt.resolvedUrl("../icons/" + modelData.icon + ".svg")

                    ToolTip.visible: hovered
                    ToolTip.text: {
                        var i = buttonIndex;

                        return root.isSecondSet ? root.device.config["toggle2Button" + (i + 1) + "Name"] : root.device.config["toggle1Button" + (i + 1) + "Name"];
                    }

                    onClicked: {
                        if (!root.device)
                            return;
                        var stateProp = root.isSecondSet ? "toggle2State" : "toggle1State";
                        root.device.callUiAction(stateProp, buttonIndex + 1);
                    }
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            active: root.hasAnyOptions

            sourceComponent: OptionBox {
                device: root.device
            }
        }
    }
}
