.pragma library

const EdifierSppUUID = 'edf00000-edfe-dfed-fedf-edfedfedfedf';

function isEdifierBuds(bluezDeviceProxy) {
    const uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(EdifierSppUUID);
}
