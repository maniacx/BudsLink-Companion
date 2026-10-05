.pragma library

var MaestroUUID = '25e97ff7-24ce-4c4c-8951-f764a708f7b5';

function isGoogleBuds(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(MaestroUUID);
}

