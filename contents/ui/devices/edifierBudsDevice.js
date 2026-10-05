.pragma library

var EdifierSppUUID = 'edf00000-edfe-dfed-fedf-edfedfedfedf';

function isEdifierBuds(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(EdifierSppUUID);
}
