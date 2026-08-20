pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.bluezqt as BluezQt
import org.kde.plasma.workspace.dbus as DBus
import org.kde.kirigami as Kirigami
import "Compatibility.js" as Compatibility

PlasmoidItem {
    id: root

    readonly property string instanceId: "BudsLink-Companion-KDE-" + plasmoid.id

    property var devices: ({})
    property var selectedDevice: null
    property var editModeDemoDevice: null
    property string selectedDevicePath: ""
    property bool devicesPresent: false

    property bool isEditMode: Plasmoid.containment.corona.editMode
    property bool isDesktopMode: Plasmoid.formFactor === PlasmaCore.Types.Planar
    property var fullReprstn: null

    readonly property BluezQt.Manager manager: BluezQt.Manager
    property bool compatibleDeviceConnected: false

    readonly property string busName: "io.github.maniacx.BudsLink"
    readonly property string objectPath: "/io/github/maniacx/BudsLink"
    readonly property string managerIface: "io.github.maniacx.BudsLink.DeviceManager"
    property DBus.DBusPendingReply pendingReply
    property bool serviceHeld: false
    property Timer heartbeatTimer
    property int heartbeatInterval: 120 // seconds

    readonly property var compatibleUUIDs: Compatibility.compatibleUUIDs
    property bool initialized: false

    Plasmoid.status: devicesPresent ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

    Plasmoid.backgroundHints: {
        if (root.isEditMode)
            return root.expanded ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.ConfigurableBackground | PlasmaCore.Types.DefaultBackground;
        if (!root.devicesPresent)
            return PlasmaCore.Types.NoBackground;
        if (!root.isDesktopMode)
            return PlasmaCore.Types.DefaultBackground;
        if (root.expanded)
            return PlasmaCore.Types.DefaultBackground;
        return PlasmaCore.Types.ConfigurableBackground | PlasmaCore.Types.DefaultBackground;
    }

    switchWidth: Kirigami.Units.gridUnit * 16.2
    switchHeight: Kirigami.Units.gridUnit * 9.2

    compactRepresentation: CompactRepresentation {
        plasmoidItem: root
        device: root.selectedDevice
        visible: root.devicesPresent
        isEditMode: root.isEditMode
        isDesktopMode: root.isDesktopMode
        editModeDemoDevice: root.editModeDemoDevice
    }

    fullRepresentation: FullRepresentation {
        id: fullReprstnId
        isEditMode: root.isEditMode
        isDesktopMode: root.isDesktopMode
        editModeDemoDevice: root.editModeDemoDevice

        Component.onCompleted: {
            for (let path in root.devices) {
                this.addDeviceTab(root.devices[path]);
            }
            root.fullReprstn = this;
            this.deviceSelected.connect(devicePath => {
                root.selectedDevicePath = devicePath;
                updateCompactDevice();
            });
        }
    }

    DBus.DBusServiceWatcher {
        id: watcher
        busType: DBus.BusType.Session
        watchedService: root.busName

        onRegisteredChanged: {
            if (registered) {
                if (serviceHeld)
                    root.enumerateDevices();
            } else {
                heartbeatTimer.stop();
                root.clearDevices();
                managerSignals.enabled = false;
                serviceHeld = false;
            }
        }
    }

    DBus.SignalWatcher {
        id: managerSignals
        busType: DBus.BusType.Session
        service: root.busName
        path: root.objectPath
        iface: root.managerIface
        enabled: false

        function dbusDeviceAdded(device_path) {
            root._addDevice(String(device_path));
        }

        function dbusDeviceRemoved(device_path) {
            root._removeDevice(String(device_path));
        }
    }

    Component {
        id: deviceComponent
        Device {}
    }

    Component.onCompleted: {
        updateCompatibleState();
        initialized = true;
    }

    Connections {
        target: manager

        function onDeviceAdded(device) {
            updateCompatibleState();
        }

        function onDeviceRemoved(device) {
            updateCompatibleState();
        }

        function onDeviceChanged(device) {
            updateCompatibleState();
        }
    }

    Timer {
        id: heartbeatTimer
        interval: root.heartbeatInterval * 1000
        repeat: true
        running: false

        onTriggered: {
            root.sendHeartbeat();
        }
    }

    function isCompatible(device) {
        const uuids = device.uuids;

        for (let i = 0; i < uuids.length; i++) {
            if (compatibleUUIDs.includes(uuids[i]))
                return true;
        }

        return false;
    }

    onCompatibleDeviceConnectedChanged: {
        if (compatibleDeviceConnected)
            holdService();
        else if (initialized)
            releaseService();
    }

    onIsEditModeChanged: {
        if (root.devicesPresent || !isEditMode) {
            root.editModeDemoDevice = null;
        } else {
            root.editModeDemoDevice = root.getDemoDevice();
        }
    }

    function updateCompatibleState() {
        const list = manager.devices;

        for (let i = 0; i < list.length; i++) {
            const d = list[i];

            if (!d.paired)
                continue;

            if (d.connected && isCompatible(d)) {
                compatibleDeviceConnected = true;
                return;
            }
        }

        compatibleDeviceConnected = false;
    }

    function holdService() {
        if (serviceHeld)
            return;

        pendingReply = DBus.SessionBus.asyncCall({
            service: busName,
            path: objectPath,
            iface: managerIface,
            member: "HoldService",
            arguments: [instanceId]
        });

        pendingReply.finished.connect(() => {
            if (pendingReply.isError)
                return;

            serviceHeld = true;
            managerSignals.enabled = true;

            heartbeatTimer.start();

            if (watcher.registered)
                enumerateDevices();
        });
    }

    function releaseService() {
        if (!serviceHeld)
            return;
        DBus.SessionBus.asyncCall({
            service: busName,
            path: objectPath,
            iface: managerIface,
            member: "ReleaseService",
            arguments: [instanceId]
        });

        heartbeatTimer.stop();

        managerSignals.enabled = false;
        serviceHeld = false;
        clearDevices();
    }

    function sendHeartbeat() {
        if (!serviceHeld)
            return;

        DBus.SessionBus.asyncCall({
            service: busName,
            path: objectPath,
            iface: managerIface,
            member: "HoldService",
            arguments: [instanceId]
        });
    }

    function _addDevice(path) {
        if (devices[path])
            return;

        const obj = deviceComponent.createObject(root, {
            path: path
        });

        if (!obj)
            return;

        obj.handler = () => {
            devices[path] = obj;
            updateCompactDevice();

            if (root.fullReprstn)
                root.fullReprstn.addDeviceTab(obj);

            obj.dbusReady.disconnect(obj.handler);
            obj.handler = null;
        };

        obj.dbusReady.connect(obj.handler);
    }

    function _removeDevice(path) {
        if (!devices[path])
            return;

        let obj = devices[path];

        if (obj.handler) {
            obj.dbusReady.disconnect(obj.handler);
            obj.handler = null;
        }

        if (root.fullReprstn)
            root.fullReprstn.removeDeviceTab(obj);

        obj.destroy();
        delete devices[path];

        updateCompactDevice();
    }

    function clearDevices() {
        if (root.fullReprstn)
            root.fullReprstn.clearAllDevices();

        for (let path in devices)
            devices[path].destroy();

        devices = ({});
        devicesPresent = false;
        selectedDevice = null;
        selectedDevicePath = "";
    }

    function enumerateDevices() {
        pendingReply = DBus.SessionBus.asyncCall({
            service: busName,
            path: objectPath,
            iface: managerIface,
            member: "ListDevices"
        });

        pendingReply.finished.connect(() => {
            if (pendingReply.isError)
                return;
            const list = pendingReply.value;

            for (let path of list)
                _addDevice(String(path));
        });
    }

    function updateCompactDevice() {
        let selected = null;

        if (selectedDevicePath && devices[selectedDevicePath])
            selected = devices[selectedDevicePath];

        if (!selected) {
            const keys = Object.keys(devices);
            if (keys.length > 0)
                selected = devices[keys[0]];
        }

        if (!selected) {
            devicesPresent = false;
            return;
        }

        devicesPresent = true;
        selectedDevice = selected;
        selectedDevicePath = selected.path;
    }

    function createDemoConfig() {
        // Match with datahandler.js in app
        return {
            commonIcon: 'earbuds-stem',
            albumArtIcon: 'earbuds-stem',
            battery1Icon: 'earbuds-stem-left',
            battery2Icon: 'earbuds-stem-right',
            battery3Icon: 'case-normal',
            battery1ShowOnDisconnect: true,
            battery2ShowOnDisconnect: true,
            battery3ShowOnDisconnect: false,
            toggle1Title: '',
            toggle1Button1Icon: null,
            toggle1Button1Name: '',
            toggle1Button2Icon: null,
            toggle1Button2Name: '',
            toggle1Button3Icon: null,
            toggle1Button3Name: '',
            toggle1Button4Icon: null,
            toggle1Button4Name: '',
            optionsBox1: [],
            optionsBox2: [],
            optionsBox3: [],
            optionsBox4: [],
            box1SliderTitle: '',
            box2SliderTitle: '',
            box3SliderTitle: '',
            box4SliderTitle: '',
            box1CheckButton: [],
            box2CheckButton: [],
            box3CheckButton: [],
            box4CheckButton: [],
            box1RadioButton: [],
            box1RadioTitle: '',
            box2RadioButton: [],
            box2RadioTitle: '',
            box3RadioButton: [],
            box3RadioTitle: '',
            box4RadioButton: [],
            box4RadioTitle: '',
            toggle2Title: '',
            toggle2Button1Icon: null,
            toggle2Button1Name: '',
            toggle2Button2Icon: null,
            toggle2Button2Name: '',
            toggle2Button3Icon: null,
            toggle2Button3Name: '',
            toggle2Button4Icon: null,
            toggle2Button4Name: '',
            labelWidth: 4,
            labelIndicatorEnabled: 0,
            panelButtonLabelFixed: true,
            showSettingsButton: false
        };
    }

    function getDemoState() {
        // Match with datahandler.js in app
        return {
            computedBatteryLevel: 0,
            battery1Level: 100,
            battery2Level: 100,
            battery3Level: 100,
            battery1Status: 'discharging',
            battery2Status: 'discharging',
            battery3Status: 'discharging',
            toggle1State: 0,
            toggle1Visible: false,
            optionsBoxVisible: 0,
            box1SliderValue: 0,
            box2SliderValue: 0,
            box3SliderValue: 0,
            box4SliderValue: 0,
            box1CheckButton1State: 0,
            box1CheckButton2State: 0,
            box2CheckButton1State: 0,
            box2CheckButton2State: 0,
            box3CheckButton1State: 0,
            box3CheckButton2State: 0,
            box4CheckButton1State: 0,
            box4CheckButton2State: 0,
            box1RadioButtonState: 0,
            box2RadioButtonState: 0,
            box3RadioButtonState: 0,
            box4RadioButtonState: 0,
            labelIndicator1: '',
            labelIndicator2: '',
            labelIndicator3: '',
            toggle2State: 0,
            toggle2Visible: false
        };
    }

    function getDemoDevice() {
        const demoDevice = {};
        demoDevice.path = "demo-device";
        demoDevice.alias = i18n("Demo Device");
        demoDevice.config = createDemoConfig();
        demoDevice.state = getDemoState();
        return demoDevice;
    }
}
