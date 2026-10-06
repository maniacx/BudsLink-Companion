'use strict';

const Me = imports.ui.appletManager.applets['BudsLink-Companion@maniacx.github.com'];

const {isAirpods} = Me.lib.devices.airpodsDevice;
const {isBoseBuds} = Me.lib.devices.boseBudsDevice;
const {isGalaxyBuds} = Me.lib.devices.galaxyBudsDevice;
const {isGfps} = Me.lib.devices.gfpsDevice;
const {isGoogleBuds} = Me.lib.devices.googleBudsDevice;
const {isNothingBuds} = Me.lib.devices.nothingBudsDevice;
const {isRedmiBuds} = Me.lib.devices.redmiBudsDevice;
const {isSenhBuds} = Me.lib.devices.senhBudsDevice;
const {isSony} = Me.lib.devices.sonyDevice;
const {isOpoBuds} = Me.lib.devices.opoBudsDevice;
const {isEdifierBuds} = Me.lib.devices.edifierBudsDevice;
const {isCambridgeBuds} = Me.lib.devices.cambrigdeBudsDevice;

const DeviceDetectors = [
    isAirpods,
    isBoseBuds,
    isGalaxyBuds,
    isGoogleBuds,
    isNothingBuds,
    isRedmiBuds,
    isSenhBuds,
    isSony,
    isOpoBuds,
    isEdifierBuds,
    isCambridgeBuds,
    isGfps,
];

function isBudsLink(bluezDeviceProxy) {
    return DeviceDetectors.some(detector => detector(bluezDeviceProxy));
}
