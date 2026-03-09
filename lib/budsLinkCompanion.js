'use strict';
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import {CompatibleDeviceTracker} from './compatibleDeviceTracker.js';
import {DbusClient} from './dbusClient.js';
import {PanelButtonSingleDevice} from './panelButtonSingleDevice.js';
import {PanelButtonMultiDevice} from './panelButtonMultiDevice.js';
import {WidgetManager} from './widgetManager.js';
import {
    isDarkMode, adjustColorLuminanceToRgba, getAccentColor, hexToColor
} from './widgets/colorHelpers.js';

export const BudsLinkCompanion = GObject.registerClass({
    GTypeName: 'BudsLinkCompanion_BudsLinkCompanionClass',
}, class BudsLinkCompanion extends GObject.Object {
    _init(settings, extensionPath, extuuid) {
        super._init();
        this.settings = settings;
        this.extPath = extensionPath;
        this._extuuid = extuuid;
        this._appSystem = null;
        this._widgetMap = new Map();

        this._idleTimerId = GLib.idle_add(GLib.PRIORITY_LOW, () => {
            if (!Main.panel.statusArea.quickSettings._bluetooth &&
                Main.panel.statusArea.quickSettings._bluetooth.quickSettingsItems[0]
                    ._box.get_first_child().get_stage())
                return GLib.SOURCE_CONTINUE;

            this._bluetoothToggle = Main.panel.statusArea.quickSettings
                ._bluetooth.quickSettingsItems[0];
            this._initBudsLink();
            this._idleTimerId = null;
            return GLib.SOURCE_REMOVE;
        });
    }

    _initializeDbus() {
        this._dbusClient = new DbusClient();

        this._deviceAddedId = this._dbusClient.connect('device-added', (_, path, device) => {
            const widget = new WidgetManager(this, path, device);
            this._widgetMap.set(path, {device, widget});
        });

        this._deviceRemovedId = this._dbusClient.connect('device-removed', (_, path) => {
            const entry = this._widgetMap.get(path);
            if (entry) {
                entry.widget.destroy();
                this._widgetMap.delete(path);
            }
        });

        this._serviceVanishedId = this._dbusClient.connect('service-vanished', () => {
            for (const {widget} of this._widgetMap.values())
                widget.destroy();
        });
        this._startTracker();
    }

    async _startTracker() {
        this._tracker = new CompatibleDeviceTracker();
        await this._tracker.initClient();

        this._tracker.connectObject('notify::device-connected', () => {
            if (this._tracker.deviceConnected)
                this._dbusClient.holdService();
            else
                this._dbusClient.releaseService();
        }, this);

        if (this._tracker.deviceConnected)
            this._dbusClient.holdService();
    }

    _initBudsLink() {
        this._deviceItems = new Map();
        this.connectedColor = '#8fbbf0';
        this._indicatorBox = null;
        this.gIcon = iconName => Gio.icon_new_for_string(
            `${this.extPath}/icons/hicolor/scalable/actions/${iconName}`);

        this._indicatorType = this.settings.get_int('indicator-type');
        this._panelSingleIndicator = this.settings.get_boolean('panel-button-single-indicator');
        this._enableMultimodeIndicator = this.settings.get_boolean('enable-multi-indicator-mode');
        this._enableHoverMode = this.settings.get_boolean('enable-on-hover-mode');

        this.widgetInfo = {
            extPath: this.extPath,
            isUnlockSession: Main.sessionMode.currentMode === 'unlock-dialog',
            indicatorWithText: this.settings.get_boolean('enable-battery-indicator-text'),
            levelIndicatorType: this.settings.get_int('level-indicator-type'),
            levelBarPosition: this.settings.get_int('level-bar-position'),
            levelIndicatorColor: this.settings.get_int('level-indicator-color'),
            levelIndicatorCustomColors: this.settings.get_strv('level-indicator-custom-colors'),
            circleWidgetColor: this.settings.get_int('circle-widget-color'),
            circleWidgetCustomColors: this.settings.get_strv('circle-widget-custom-colors'),
            accentColor: hexToColor('#3584e4'),
        };

        this._updateColors();

        this._themeContext = St.ThemeContext.get_for_stage(global.stage);
        this._themeContext.connectObject('changed', () => {
            this._updateColors();
            this._reloadGUI();
        }, this);

        this.settings.connectObject(
            'changed::indicator-type', () => {
                this._indicatorType = this.settings.get_int('indicator-type');
                this._reloadGUI();
            },
            'changed::panel-button-single-indicator', () => {
                this._panelSingleIndicator =
                    this.settings.get_boolean('panel-button-single-indicator');
                this._reloadGUI();
            },
            'changed::enable-multi-indicator-mode', () => {
                this._enableMultimodeIndicator =
                    this.settings.get_boolean('enable-multi-indicator-mode');
                this._reloadGUI();
            },
            'changed::enable-on-hover-mode', () => {
                this._enableHoverMode = this.settings.get_boolean('enable-on-hover-mode');
                this._reloadGUI();
            },
            'changed::enable-tooltip', () => {
                this._reloadGUI();
            },
            'changed::enable-battery-indicator-text', () => {
                this.widgetInfo.indicatorWithText =
                    this.settings.get_boolean('enable-battery-indicator-text');
                this._reloadGUI();
            },
            'changed::level-indicator-type', () => {
                this.widgetInfo.levelIndicatorType =
                    this.settings.get_int('level-indicator-type');
                this._reloadGUI();
            },
            'changed::level-bar-position', () => {
                this.widgetInfo.levelBarPosition =
                    this.settings.get_int('level-bar-position');
                this._reloadGUI();
            },
            'changed::level-indicator-color', () => {
                this.widgetInfo.levelIndicatorColor =
                    this.settings.get_int('level-indicator-color');
                this._reloadGUI();
            },
            'changed::level-indicator-custom-colors', () => {
                this.widgetInfo.levelIndicatorCustomColors =
                    this.settings.get_strv('level-indicator-custom-colors');
                this._reloadGUI();
            },
            'changed::circle-widget-color', () => {
                this.widgetInfo.circleWidgetColor = this.settings.get_int('circle-widget-color');
                this._reloadGUI();
            },
            'changed::circle-widget-custom-colors', () => {
                this.widgetInfo.circleWidgetCustomColors =
                    this.settings.get_strv('circle-widget-custom-colors');
                this._reloadGUI();
            },
            this
        );

        Main.sessionMode.connectObject(
            'updated', session => {
                this.widgetInfo.isUnlockSession = session.currentMode === 'unlock-dialog';
                this._reloadGUI();
            },
            this
        );
        this._updateIndicatorSettings();

        this._initializeDbus();
    }

    _reloadGUI() {
        for (const entry of this._widgetMap.values())
            entry.widget.destroy();

        this._updateIndicatorSettings();

        for (const [path, entry] of this._widgetMap) {
            const widget = new WidgetManager(this, path, entry.device);
            entry.widget = widget;
        }
    }

    _addIndicatorBoxLayout() {
        this._indicatorBox = new St.BoxLayout({
            x_align: Clutter.ActorAlign.CENTER,
            style_class: 'panel-status-indicators-box',
        });
        if (this._enablePanelButton && !this._panelSingleIndicator && this.panelButton) {
            this.panelButton.add_child(this._indicatorBox);
        } else if (this.enableIndicator) {
            this._indicatorBox.quickSettingsItems = [];
            Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicatorBox);
        }

        this._indicatorBox.connectObject('child-removed', () => {
            if (this._indicatorBox.get_n_children() === 0)
                this._removeIndicatorBoxLayout();
        },
        this
        );
    }

    _removeIndicatorBoxLayout() {
        this._indicatorBox?.disconnectObject(this);
        this._indicatorBox?.destroy();
        this._indicatorBox = null;
    }

    addIndicatorWidget(widget) {
        if (!this._indicatorBox)
            this._addIndicatorBoxLayout();
        this._indicatorBox.add_child(widget);
    }

    _updateIndicatorSettings() {
        this.enableIndicator = this._indicatorType === 0;
        this._enablePanelButton = this._indicatorType === 1;
        this.indicatorEnabled =
                this.enableIndicator || this._enablePanelButton && !this._panelSingleIndicator;
        this.multimodeIndicatorEnabled =
                this.indicatorEnabled && this._enableMultimodeIndicator;
        this.hoverModeEnabled = this.enableIndicator && this._enableHoverMode;

        this.panelButton?.destroy();
        this.panelButton = null;

        if (!this.widgetInfo.isUnlockSession && this._enablePanelButton && !this.panelButton) {
            if (this._panelSingleIndicator) {
                this.panelButton = new PanelButtonSingleDevice(
                    this.settings, this.gIcon, this.widgetInfo);
            } else {
                this.panelButton = new PanelButtonMultiDevice(
                    this.settings, this.gIcon, this.widgetInfo);
            }
            Main.panel.addToStatusArea(this._extuuid, this.panelButton);
        }
    }

    _updateColors() {
        const accentColor = getAccentColor();
        const qsBox = Main.panel.statusArea.quickSettings.menu.box;
        if (!qsBox)
            return;
        const panelBackgroundRGB = qsBox.get_theme_node().get_background_color();
        this.widgetInfo.accentColor = accentColor;
        const luminanceFactor = isDarkMode(panelBackgroundRGB) ? 15 : -5;
        this.connectedColor = adjustColorLuminanceToRgba(accentColor, luminanceFactor);
    }

    destroy() {
        if (this._idleTimerId)
            GLib.source_remove(this._idleTimerId);
        this._idleTimerId = null;

        this._tracker?.destroy();
        this._tracker = null;

        if (this._dbusClient) {
            this._dbusClient.releaseService();
            if (this._deviceAddedId) {
                this._dbusClient.disconnect(this._deviceAddedId);
                this._deviceAddedId = null;
            }

            if (this._deviceRemovedId) {
                this._dbusClient.disconnect(this._deviceRemovedId);
                this._deviceRemovedId = null;
            }

            if (this._serviceVanishedId) {
                this._dbusClient.disconnect(this._serviceVanishedId);
                this._serviceVanishedId = null;
            }
            this._dbusClient?.destroy();
            this._dbusClient = null;
        }

        for (const {widget} of this._widgetMap.values())
            widget.destroy();

        if (this._themeContext)
            this._themeContext.disconnectObject(this);

        if (this.settings)
            this.settings.disconnectObject(this);

        Main.sessionMode.disconnectObject(this);

        this.panelButton?.destroy();
        this.panelButton = null;
        this._deviceItems = null;
        this._removeIndicatorBoxLayout();
        this._themeContext = null;
        this.settings = null;
    }
});

