pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: root

    property PlasmoidItem plasmoidItem
    property var device: null
    property var editModeDemoDevice: null
    property bool isEditMode
    property bool isDesktopMode

    property var activeDevice: {
        if (device)
            return device;

        if (isEditMode)
            return editModeDemoDevice;

        return null;
    }

    property string iconName: {
        if (activeDevice && activeDevice.config && activeDevice.config.commonIcon)
            return activeDevice.config.commonIcon;
        return "headphone1";
    }

    property int percentage: {
        if (activeDevice && activeDevice.state && activeDevice.state.computedBatteryLevel !== undefined)
            return activeDevice.state.computedBatteryLevel;
        return 0;
    }

    property real targetIconSize: {
        if (!plasmoidItem)
            return Kirigami.Units.iconSizes.smallMedium;

        if (isDesktopMode) {
            return Math.min(plasmoidItem.width, plasmoidItem.height) * 0.75;
        }

        const panelHeight = plasmoidItem.height;
        let size;

        if (panelHeight <= 22) {
            size = panelHeight * 0.9;
        } else {
            size = Kirigami.Units.iconSizes.smallMedium;
        }

        return size;
    }

    property int layoutMode: {
        if (!plasmoidItem)
            return 0;

        if (isDesktopMode) {
            const w = plasmoidItem.width / Kirigami.Units.gridUnit;
            const h = plasmoidItem.height / Kirigami.Units.gridUnit;
            if (w > 8 && h > 4)
                return 1;
        }

        return 0;
    }

    property real iconSize: targetIconSize * 0.95
    property real widgetSize: targetIconSize * 0.8
    property real unit: widgetSize / 16

    property real batteryHeight: 14 * unit
    property real batteryWidth: 4 * unit
    property real notchWidth: 2 * unit
    property real notchHeight: 1 * unit
    property real widgetHeight: batteryHeight + notchHeight
    property real spacing: unit

    property url iconSource: Qt.resolvedUrl("../icons/bbm-" + iconName + "-symbolic.svg")
    anchors.centerIn: parent

    Item {
        id: batteryIcon
        anchors.centerIn: root
        width: root.targetIconSize + root.spacing + root.batteryWidth
        height: root.targetIconSize
        visible: root.layoutMode === 0 && root.activeDevice

        Kirigami.Icon {
            id: icon
            width: root.iconSize
            height: root.iconSize
            source: root.iconSource
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
        }

        Item {
            id: batteryBar
            width: root.batteryWidth
            height: root.widgetHeight
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: icon.right
            anchors.leftMargin: root.spacing

            Rectangle {
                id: batteryBackground
                width: root.batteryWidth
                height: root.batteryHeight
                color: "#80808080"
                radius: 1
                anchors.bottom: batteryBar.bottom
            }

            Rectangle {
                id: batteryFill
                width: root.batteryWidth
                height: Math.round(root.batteryHeight * root.percentage / 100)
                color: root.percentage <= 20 ? "#e53935" : "#4caf50"
                radius: 1
                anchors.bottom: batteryBackground.bottom
            }

            Rectangle {
                width: root.notchWidth
                height: root.notchHeight
                color: root.percentage == 100 ? "#4caf50" : "#80808080"
                anchors.bottom: batteryBackground.top
                x: Math.round((batteryBackground.width - root.notchWidth) / 2)
                radius: 0.2
            }
        }
    }

    Item {
        id: batteryWidgetSet
        width: Kirigami.Units.gridUnit * 15
        height: Kirigami.Units.gridUnit * 9
        anchors.centerIn: root
        visible: root.layoutMode === 1 && root.activeDevice

        BatterySetWidget {
            anchors.fill: parent
            device: root.activeDevice
            widgetTitle: root.activeDevice ? root.activeDevice.alias : ""
        }
    }

    onActiveDeviceChanged: {
        if (!root.activeDevice)
            root.plasmoidItem.expanded = false;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.activeDevice) {
                root.plasmoidItem.expanded = !root.plasmoidItem.expanded;
            }
        }
    }
}
