.pragma library

var GfpsUUID = 'df21fe2c-2515-4fdb-8886-f12c4d67927c';

function isGfps(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(GfpsUUID);
}


