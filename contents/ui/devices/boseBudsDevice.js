.pragma library

var BoseBudsUUID = '00000000-deca-fade-deca-deafdecacaff';
var SppUUid = '00001101-0000-1000-8000-00805f9b34fb';

var SupportedModels = [
    '400C', // QuietComfort 35
    '4020', // QuietComfort 35 II
    '4064', // QuietComfort Earbuds II
    '4062', // QuietComfort Ultra Earbuds (2nd Gen)
    '4082', // QuietComfort Ultra Headphones (2nd Gen)
    '4072', // QuietComfort Ultra Earbuds
    '4066', // QuietComfort Ultra Headphones
];

function isBoseBuds(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    var modalias = bluezDeviceProxy.Modalias ?? '';

    if (!uuids.includes(BoseBudsUUID) || !uuids.includes(SppUUid))
        return false;

    if (!modalias)
        return false;

    var regex = /v009Ep([0-9A-Fa-f]{4})d/;
    var match = modalias.match(regex);
    if (!match)
        return false;

    var modelId = match[1].toUpperCase();
    return SupportedModels.includes(modelId);
}
