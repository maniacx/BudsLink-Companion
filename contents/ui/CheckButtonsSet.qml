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

    readonly property var labels: device.config["box" + boxId + "CheckButton"]

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing * 2

        Repeater {
            model: Math.min(root.labels.length, 2)

            delegate: ColumnLayout {
                id: delegateRoot
                spacing: Kirigami.Units.smallSpacing
                Layout.alignment: Qt.AlignHCenter

                required property int index

                readonly property int indexValue: index + 1
                readonly property string labelText: root.labels[index]
                readonly property string stateProp: "box" + root.boxId + "CheckButton" + indexValue + "State"

                PlasmaComponents3.Label {
                    text: delegateRoot.labelText
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
                }

                QQC2.CheckBox {
                    id: checkbox
                    checked: root.device.state[delegateRoot.stateProp] === 1
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Item {
                        implicitWidth: 0
                        implicitHeight: 0
                    }

                    onToggled: {
                        if (!root.device)
                            return;
                        root.device.callUiAction(delegateRoot.stateProp, checked ? 1 : 0);
                    }
                }
            }
        }
    }
}
