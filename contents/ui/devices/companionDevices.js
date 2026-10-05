.pragma library

.import "./airpodsDevice.js" as Airpods
.import "./boseBudsDevice.js" as BoseBuds
.import "./galaxyBudsDevice.js" as GalaxyBuds
.import "./googleBudsDevice.js" as GoogleBuds
.import "./nothingBudsDevice.js" as NothingBuds
.import "./redmiBudsDevice.js" as RedmiBuds
.import "./senhBudsDevice.js" as SenhBuds
.import "./sonyDevice.js" as Sony
.import "./opoBudsDevice.js" as OpoBuds
.import "./edifierBudsDevice.js" as EdifierBuds
.import "./cambrigdeBudsDevice.js" as CambridgeBuds
.import "./gfpsDevice.js" as Gfps


const DeviceDetectors = [
    Airpods.isAirpods,
    BoseBuds.isBoseBuds,
    GalaxyBuds.isGalaxyBuds,
    GoogleBuds.isGoogleBuds,
    NothingBuds.isNothingBuds,
    RedmiBuds.isRedmiBuds,
    SenhBuds.isSenhBuds,
    Sony.isSony,
    OpoBuds.isOpoBuds,
    EdifierBuds.isEdifierBuds,
    CambridgeBuds.isCambridgeBuds,
    Gfps.isGfps,
];

function isBudsLink(device) {
    const bluezDeviceProxy = {};
    bluezDeviceProxy.UUIDs = device.uuids.map(uuid => uuid.toLowerCase());
    bluezDeviceProxy.Name = device.name;
    bluezDeviceProxy.Modalias = device.modalias;

    return DeviceDetectors.some(detector => detector(bluezDeviceProxy));
}
