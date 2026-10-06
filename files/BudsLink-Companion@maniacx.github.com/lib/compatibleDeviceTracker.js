const Gio = imports.gi.Gio;
const GObject = imports.gi.GObject;

const Me = imports.ui.appletManager.applets['BudsLink-Companion@maniacx.github.com'];
const {getBluezDeviceProxy} = Me.lib.bluezDeviceProxy;
const {isBudsLink} = Me.lib.devices.companionDevices;

const BLUEZ = 'org.bluez';
const OBJ_MANAGER_IFACE = 'org.freedesktop.DBus.ObjectManager';
const FD_PROPS_IFACE = 'org.freedesktop.DBus.Properties';
const DEVICE_IFACE = 'org.bluez.Device1';

var CompatibleDeviceTracker = GObject.registerClass({
    Properties: {
        'device-connected': GObject.ParamSpec.boolean('device-connected', '', '',
            GObject.ParamFlags.READWRITE, false),
    },
}, class CompatibleDeviceTracker extends GObject.Object {
    _init() {
        super._init();
        this._bus = Gio.DBus.system;
        this._devices = new Map();
    }

    async initClient() {
        try {
            const rawManaged = await this._bus.call(
                BLUEZ,
                '/',
                OBJ_MANAGER_IFACE,
                'GetManagedObjects',
                null,
                null,
                Gio.DBusCallFlags.NONE,
                -1,
                null
            );

            const managed = rawManaged.get_child_value(0).deepUnpack();

            for (const [path, ifaces] of Object.entries(managed)) {
                if (!(DEVICE_IFACE in ifaces))
                    continue;

                const props = ifaces[DEVICE_IFACE];

                if (!props?.Paired?.deepUnpack?.())
                    continue;

                const device = getBluezDeviceProxy(path);

                this._devices.set(path, device);
            }

            this._propChangeId = this._bus.signal_subscribe(
                BLUEZ,
                FD_PROPS_IFACE,
                'PropertiesChanged',
                null,
                DEVICE_IFACE,
                Gio.DBusSignalFlags.NONE,
                this._onPropertiesChanged.bind(this)
            );

            this._ifaceAddedId = this._bus.signal_subscribe(
                BLUEZ,
                OBJ_MANAGER_IFACE,
                'InterfacesAdded',
                null,
                null,
                Gio.DBusSignalFlags.NONE,
                this._onInterfacesAdded.bind(this)
            );

            this._ifaceRemovedId = this._bus.signal_subscribe(
                BLUEZ,
                OBJ_MANAGER_IFACE,
                'InterfacesRemoved',
                null,
                null,
                Gio.DBusSignalFlags.NONE,
                this._onInterfacesRemoved.bind(this)
            );

            this._updateDeviceConnected();
        } catch (e) {
            global.log(e);
        }
    }

    _onInterfacesAdded(conn, sender, emitterPath, iface, signal, params) {
        const [path, ifaces] = params.deepUnpack();

        if (!(DEVICE_IFACE in ifaces))
            return;

        const props = ifaces[DEVICE_IFACE];

        if (!props?.Paired?.deepUnpack?.())
            return;

        const device = getBluezDeviceProxy(path);

        this._devices.set(path, device);

        this._updateDeviceConnected();
    }

    _onInterfacesRemoved(conn, sender, emitterPath, iface, signal, params) {
        const [path, ifaces] = params.deepUnpack();
        if (!ifaces.includes(DEVICE_IFACE))
            return;

        if (this._devices.delete(path))
            this._updateDeviceConnected();
    }

    _onPropertiesChanged(conn, sender, path, iface, signal, params) {
        const [ifaceName, changed] = params.deepUnpack();
        if (ifaceName !== DEVICE_IFACE)
            return;

        const device = this._devices.get(path);

        if (!device)
            return;

        if ('Paired' in changed && !changed.Paired.deepUnpack()) {
            this._devices.delete(path);
            this._updateDeviceConnected();
            return;
        }

        if (!('Connected' in changed))
            return;

        this._updateDeviceConnected();
    }

    _updateDeviceConnected() {
        const deviceConnected = [...this._devices.values()].some(
            device => device.Connected && isBudsLink(device));

        if (this.deviceConnected !== deviceConnected)
            this.deviceConnected = deviceConnected;
    }

    destroy() {
        if (this._bus) {
            if (this._propChangeId)
                this._bus.signal_unsubscribe(this._propChangeId);

            if (this._ifaceAddedId)
                this._bus.signal_unsubscribe(this._ifaceAddedId);

            if (this._ifaceRemovedId)
                this._bus.signal_unsubscribe(this._ifaceRemovedId);
        }
        this._devices.clear();
    }
});
