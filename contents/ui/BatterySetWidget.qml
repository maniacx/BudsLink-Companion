pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: column.implicitHeight
    Layout.margins: Kirigami.Units.smallSpacing * 2

    property var device: null
    property string widgetTitle: i18n("Battery Level")

    readonly property var batteryModel: {
        if (!device || !device.config || !device.state)
            return [];

        let batteries = [];
        for (let i = 1; i <= 3; i++) {
            let icon = device.config["battery" + i + "Icon"];
            if (!icon)
                continue;

            batteries.push({
                index: i,
                icon: icon,
                level: device.state["battery" + i + "Level"] ?? 0,
                status: device.state["battery" + i + "Status"] ?? "disconnected",
                showOnDisconnect: device.config["battery" + i + "ShowOnDisconnect"] ?? false
            });
        }
        return batteries;
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing * 2

        PlasmaComponents3.Label {
            text: root.widgetTitle
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            id: row
            spacing: Kirigami.Units.smallSpacing * 6
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                id: repeater
                model: root.batteryModel

                delegate: ColumnLayout {
                    id: delegateRoot
                    spacing: Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignHCenter
                    required property var modelData

                    visible: {
                        if (modelData.level === 0)
                            return false;

                        if (modelData.showOnDisconnect)
                            return true;

                        return modelData.status !== "disconnected";
                    }

                    CircleBatteryWidget {
                        iconName: delegateRoot.modelData.icon
                        percentage: delegateRoot.modelData.level
                        status: delegateRoot.modelData.status
                        Layout.alignment: Qt.AlignHCenter
                    }

                    PlasmaComponents3.Label {
                        text: delegateRoot.modelData.level + "%"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Math.round(Kirigami.Theme.smallFont.pixelSize)
                    }
                }
            }
        }
    }
}
