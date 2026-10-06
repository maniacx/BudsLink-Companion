'use strict';

const SamsungMepSppUUID = 'f8620674-a1ed-41ab-a8b9-de9ad655729d';

function isGalaxyBuds(bluezDeviceProxy) {
    const uuids = bluezDeviceProxy.UUIDs ?? [];
    return uuids.includes(SamsungMepSppUUID);
}
