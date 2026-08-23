# BudsLink Companion - Plasma Widget (KDE)

### Panel Widget

<img src="https://github.com/maniacx/BudsLink-Companion/blob/main/images/plasma-panel-widget.png" alt="Plasma Panel Widget" width="600"/>


### Desktop Widget

<img src="https://github.com/maniacx/BudsLink-Companion/blob/main/images/plasma-desktop-widget.png" alt="Plasma Desktop Widget" width="700"/>


* BudsLink Companion provides desktop integration for the Flatpak application BudsLink [**BudsLink**](https://github.com/maniacx/BudsLink).
* It acts as a bridge between the BudsLink service and the Kde Plasma desktop environment, exposing device controls through a system tray applet or desktop Widget

## Features
* Automatically starts the BudsLink service in the background and communicates with it through D-Bus.
* Can be used as a system tray/popup widget or placed directly on the desktop.
* Displays device battery information.
* Provides quick access to noise-control modes such as ANC and Transparency.
* Provides quick access to the BudsLink device settings/application for additional features supported by your device.

## Supported Brands 
BudsLink Companion currently works with devices supported by BudsLink, including:

* AirPods
* Beats
* Sony
* Samsung Galaxy Buds
* Nothing / CMF
* Bose
* Sennheiser
* Redmi / Xiaomi

Note: Not every model from these brands is currently supported or tested.
See the complete list of supported and tested models supported by BudsLink app here.

* If your device is supported but not listed in the documentation, please [open an issue on BudsLink](https://github.com/maniacx/BudsLink/issues) and provide the relevant information.
* If your device is not currently supported, you can also request support by [opening an issue on BudsLink](https://github.com/maniacx/BudsLink/issues).


### Installation
1. Ensure the BudsLink Flatpak application is installed:
2. Download and extract this branch as ZIP archive (or git clone).
3. Open a terminal and navigate to the extracted directory:
```
cd path/to/extracted-folder
./install.sh
```
4. Right click on Panel or Desktop and `Add Widget`.

### Uninstallation

---

**GUI method**

1. Right Click on Panel and Select `Add or Manage Widget`.
<img width="496" height="286" alt="Screenshot_20260809_150814" src="https://github.com/user-attachments/assets/8f527b2e-17b1-47aa-9ca4-c4438478ab5a" />

2. Find the BudsLink-Companion Widget in the list and Click on `Remove all instance button` Button (Broom Icon).
<img width="613" height="546" alt="Screenshot_20260809_150853" src="https://github.com/user-attachments/assets/eb6f2ac7-adf4-4f27-8158-843961ea71b4" />

3. Click on `Mark For Installation` Button (Trash Icon)
<img width="630" height="425" alt="Screenshot_20260809_151154" src="https://github.com/user-attachments/assets/dc245315-bd57-4552-8fad-bfd77bf9a858" />

4. Exit Edit Mode
<img width="375" height="188" alt="Screenshot_20260809_151234" src="https://github.com/user-attachments/assets/e6c62f64-b2bd-48f9-9157-17ed29fee658" />

5. this will not instantly remove the widget and will available with an `Undo Delete` Option until you logout or restart PlasmaShell.

---

**Manual Uninstallation**


1. Navigate to folder
`~/.local/share/plasma/plasmoids/com.github.maniacx.BudsLink-Companion`

2. Delete folder `com.github.maniacx.BudsLink-Companion`


3. Restart Plasma-shell
```
systemctl restart --user plasma-plasmashell.service 
```





