'use strict';
import GObject from 'gi://GObject';

import {BluetoothIndicator} from './widgets/bluetoothIndicator.js';
import {OnHoverMenu} from './widgets/onHoverMenu.js';
import {MultimodeIndicator} from './widgets/multimodeIndicator.js';

export const WidgetManager = GObject.registerClass({
    GTypeName: 'BudsLinkCompanion_WidgetManagerEnhanced',
    Properties: {
        'batteryPercentage': GObject.ParamSpec.int('batteryPercentage', '', 'Battery Percentage',
            GObject.ParamFlags.READWRITE, 0, 100, 0),
    },
}, class WidgetManager extends GObject.Object {
    _init(toggle, path, device) {
        super._init();
        this.toggle = toggle;
        this.settings = toggle.settings;
        this.path = path;
        this.device = device;
        this.alias = device.alias;
        this.gIcon = toggle.gIcon;
        this._dataHandler = device.dataHandler;
        this.deviceIcon = this._dataHandler.getConfig().commonIcon;
        this.widgetInfo = toggle.widgetInfo;
        this._enableMultimodeIndicator = toggle.multimodeIndicatorEnabled;
        this.hoverModeEnabled = toggle.hoverModeEnabled;
        this.isUnlockSession = this.widgetInfo.isUnlockSession;

        this.device.connectObject('notify::alias', () => this._aliasUpdated(this.alias), this);

        this._dataHandler.connectObject(
            'configuration-changed', () => {
                this.deviceIcon = this._dataHandler.getConfig().commonIcon;
                this.indicator?.updateProperties(this.deviceIcon);
            },
            'properties-changed', () => {
                const battProps = this._dataHandler.getProps();
                this.batteryPercentage  = battProps.computedBatteryLevel;
            },
            this
        );

        const battProps = this._dataHandler.getProps();
        this.batteryPercentage  = battProps.computedBatteryLevel;

        if (this.toggle.panelButton && !this.isUnlockSession) {
            this._popupMenuWidgetItem =
                    this.toggle.panelButton.addDevice(this.path, this.alias, this._dataHandler);
        }

        this._startIndicator();
    }

    _aliasUpdated(alias) {
        if (this._onHoverMenu)
            this._onHoverMenu.updateAlias(alias);
        if (this._enableMultimodeIndicator)
            this.indicator?.updateAlias(alias);
        if (this.toggle.panelButton)
            this._popupMenuWidgetItem?.updateAlias(alias);
    }

    _startIndicator() {
        if (this.indicator || !this.deviceIcon || !this._dataHandler)
            return;

        if (!this.toggle.indicatorEnabled)
            return;

        if (this._enableMultimodeIndicator) {
            this.indicator = new MultimodeIndicator(this, this._dataHandler);
            return;
        }

        this.indicator = new BluetoothIndicator(this);
        this.toggle.addIndicatorWidget(this.indicator);

        if (this.hoverModeEnabled && !this.isUnlockSession && !this._onHoverMenu) {
            this._onHoverMenu = new OnHoverMenu(this.indicator, this.settings, this.gIcon,
                this.path, this.alias, this.widgetInfo, this._dataHandler);
        }
    }

    _destroyIndicator() {
        this._onHoverMenu?.destroy();
        this._onHoverMenu = null;
        this.indicator?.destroy();
        this.indicator = null;
    }

    _destroyOnDisconnect() {
        this._dataHandler?.disconnectObject(this);
        this._dataHandler = null;
        this.toggle?.panelButton?.removeDevice(this.path);
        this._popupMenuWidgetItem = null;
        this._destroyIndicator();
    }

    destroy() {
        this.settings?.disconnectObject(this);
        this.device?.disconnectObject(this);
        this.disconnectObject(this);
        this._destroyOnDisconnect();
        this.settings = null;
        this.toggle = null;
        this.device = null;
    }
});
