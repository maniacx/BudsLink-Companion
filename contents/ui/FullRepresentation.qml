pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents3

PlasmaExtras.Representation {
    id: root

    collapseMarginsHint: true

    property bool isEditMode
    property bool isDesktopMode

    property var devicePages: []
    property var editModeDemoDevice: null
    property bool hasDevice: devicePages.length > 0

    signal deviceSelected(string devicePath)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 9
    Layout.preferredWidth: isDesktopMode ? -1 : Kirigami.Units.gridUnit * 17
    Layout.preferredHeight: isDesktopMode ? -1 : Kirigami.Units.gridUnit * 24

    Component {
        id: tabButtonComponent

        QQC2.TabButton {
            width: 140

            property alias iconSource: iconItem.source
            property alias labelText: labelItem.text

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.bottomMargin: Kirigami.Units.smallSpacing
                anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                anchors.rightMargin: Kirigami.Units.smallSpacing * 2
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    id: iconItem
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }

                PlasmaComponents3.Label {
                    id: labelItem
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlasmaComponents3.SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            currentIndex: tabBar.currentIndex
            onCurrentIndexChanged: {
                if (currentIndex < 0 || currentIndex >= root.devicePages.length)
                    return;
                const path = root.devicePages[currentIndex].devicePath;
                root.deviceSelected(path);
            }
        }

        PlasmaComponents3.TabBar {
            id: tabBar
            position: PlasmaComponents3.TabBar.Footer
            Layout.fillWidth: true
            currentIndex: swipeView.currentIndex
            visible: count > 1

            onCurrentIndexChanged: {
                swipeView.setCurrentIndex(currentIndex);
            }
        }
    }

    Component {
        id: devicePageComponent
        DevicePage {}
    }

    onEditModeDemoDeviceChanged: {
        if (!root.hasDevice && root.editModeDemoDevice) {
            addDeviceTab(root.editModeDemoDevice);
        } else {
            const index = devicePages.findIndex(d => d.devicePath === "demo-device");
            if (index !== -1) {
                const demoPage = devicePages[index].device;
                removeDeviceTab(demoPage);
            }
        }
    }

    function addDeviceTab(device) {
        if (devicePages.some(d => d.device.path === device.path))
            return;

        let page = devicePageComponent.createObject(swipeView, {
            device: device
        });
        swipeView.addItem(page);

        devicePages.push({
            devicePath: device.path,
            device: device,
            page: page
        });

        let tabButton = tabButtonComponent.createObject(tabBar, {
            labelText: device.alias
        });

        tabButton.iconSource = Qt.resolvedUrl("../icons/bbm-" + device.config.commonIcon + "-symbolic.svg");

        tabBar.addItem(tabButton);

        if (devicePages.length === 1) {
            tabBar.setCurrentIndex(-1);
            tabBar.setCurrentIndex(0);
        }
    }

    function removeDeviceTab(device) {
        let index = devicePages.findIndex(d => d.devicePath === device.path);
        if (index === -1)
            return;

        let page = devicePages[index].page;
        swipeView.removeItem(page);
        page.destroy();

        let tabButton = tabBar.itemAt(index);
        if (tabButton) {
            tabBar.removeItem(tabButton);
            tabButton.destroy();
        }

        devicePages.splice(index, 1);
    }

    function clearAllDevices() {
        for (let i = devicePages.length - 1; i >= 0; i--) {
            let entry = devicePages[i];

            swipeView.removeItem(entry.page);
            entry.page.destroy();

            let tabButton = tabBar.itemAt(i);
            if (tabButton) {
                tabBar.removeItem(tabButton);
                tabButton.destroy();
            }
        }

        devicePages = [];

        swipeView.setCurrentIndex(-1);
        tabBar.setCurrentIndex(-1);
    }
}
