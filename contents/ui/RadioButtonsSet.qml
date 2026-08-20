pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var device
    property int boxId: 1

    Layout.fillWidth: true
    height: column.implicitHeight

    readonly property var labels: device.config["box" + boxId + "RadioButton"]
    readonly property int currentState: device.state["box" + boxId + "RadioButtonState"]
    readonly property string stateProp: "box" + root.boxId + "RadioButtonState"

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            text: root.device.config["box" + root.boxId + "RadioTitle"]
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Math.max(0, 50 - (repeater.count * 10))
            uniformCellSizes: true

            QQC2.ButtonGroup {
                id: group
                exclusive: true
            }

            Repeater {
                id: repeater
                model: root.labels

                delegate: ColumnLayout {
                    id: delegateRoot
                    spacing: Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignHCenter

                    required property string modelData
                    required property int index

                    readonly property int indexValue: index + 1

                    QQC2.RadioButton {
                        checked: root.currentState === parent.indexValue
                        QQC2.ButtonGroup.group: group
                        Layout.alignment: Qt.AlignHCenter
                        contentItem: Item {
                            implicitWidth: 0
                            implicitHeight: 0
                        }

                        onClicked: {
                            if (!root.device)
                                return;
                            root.device.callUiAction(root.stateProp, parent.indexValue);
                        }
                    }

                    PlasmaComponents3.Label {
                        text: delegateRoot.modelData
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 60
                        font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }
        }
    }
}
