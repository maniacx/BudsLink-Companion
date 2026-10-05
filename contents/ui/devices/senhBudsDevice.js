.pragma library

var SenhBudsUUID = 'a2129ff3-081b-4c45-8afe-469d9c4842ec';

function isSenhBuds(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(SenhBudsUUID);
}

