.pragma library

var QualcommVendorUuids = [
    '0000eb04-d102-11e1-9b23-00025b00a5a5',
    '0000eb05-d102-11e1-9b23-00025b00a5a5',
    '0000eb06-d102-11e1-9b23-00025b00a5a5',
    '0000eb07-d102-11e1-9b23-00025b00a5a5',
];

var SppUUid = '00001101-0000-1000-8000-00805f9b34fb';

var SupportedModelsNamePatterns = [
    /^Melomania A100/,
];

function isCambridgeBuds(bluezDeviceProxy) {
    var uuids = bluezDeviceProxy.UUIDs ?? [];
    var name = bluezDeviceProxy.Name ?? '';

    if (!uuids.includes(SppUUid))
        return false;

    if (!QualcommVendorUuids.every(uuid =>
        uuids.includes(uuid)
    ))
        return false;

    return SupportedModelsNamePatterns.some(pattern =>
        pattern.test(name)
    );
}
