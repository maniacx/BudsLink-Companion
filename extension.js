'use strict';
import Gio from 'gi://Gio';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import {BudsLinkCompanion} from './lib/budsLinkCompanion.js';

Gio._promisify(Gio.DBusProxy, 'new');
Gio._promisify(Gio.DBusProxy, 'new_for_bus');
Gio._promisify(Gio.DBusProxy.prototype, 'call');
Gio._promisify(Gio.DBusConnection.prototype, 'call');
Gio._promisify(Gio.InputStream.prototype, 'read_bytes_async');
Gio._promisify(Gio.OutputStream.prototype, 'write_all_async');

export default class BudsLinkCompanionExtension extends Extension {
    // BudsLink need to access control earbuds ANC feature and Battery Level.
    // Therefore unlock-dialog session mode is used.
    enable() {
        this._settings = this.getSettings();
        this._budsLinkCompanion = new BudsLinkCompanion(this._settings, this.path, this.uuid);
    }

    disable() {
        this._budsLinkCompanion.destroy();
        this._budsLinkCompanion = null;
        this._settings = null;
    }
}

