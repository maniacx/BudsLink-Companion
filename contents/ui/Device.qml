pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.workspace.dbus as DBus

Item {
    id: device

    signal dbusReady

    property string path
    property string alias: ""
    property var config
    property var state
    property var handler

    readonly property string busName: "io.github.maniacx.BudsLink"
    readonly property string iface: "io.github.maniacx.BudsLink.Device"

    DBus.Properties {
        id: props

        busType: DBus.BusType.Session
        service: device.busName
        path: device.path
        iface: device.iface

        property string alias: String(properties.Alias || "")
        property string configStr: String(properties.Config || "")
        property string stateStr: String(properties.State || "")

        onAliasChanged: {
            device.alias = alias;
        }

        onConfigStrChanged: {
            if (configStr.length > 0)
                device.config = JSON.parse(configStr);
        }

        onStateStrChanged: {
            if (stateStr.length > 0)
                device.state = JSON.parse(stateStr);
        }

        onRefreshed: {
            device.alias = alias;

            if (configStr.length > 0) {
                device.config = JSON.parse(configStr);
            }

            if (stateStr.length > 0) {
                device.state = JSON.parse(stateStr);
            }

            device.dbusReady();
        }
    }

    function callUiAction(actionName, value) {
        DBus.SessionBus.asyncCall({
            service: busName,
            path: device.path,
            iface: device.iface,
            member: "UiAction",
            arguments: [actionName, value]
        });
    }
}
