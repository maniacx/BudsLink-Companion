# BudsLink Companion - Plasma Widget (KDE)

### Panel Widget

<img src="https://github.com/maniacx/BudsLink-Companion/blob/main/images/plasma-panel-widget.png" alt="Plasma Panel Widget" width="600"/>


### Desktop Widget

<img src="https://github.com/maniacx/BudsLink-Companion/blob/main/images/plasma-desktop-widget.png" alt="Plasma Desktop Widget" width="700"/>


* BudsLink Companion provides desktop integration for the Flatpak application BudsLink [**BudsLink**](https://github.com/maniacx/BudsLink).
* It acts as a bridge between the BudsLink service and the Kde Plasma desktop environment, exposing device controls through a system tray applet.

## Features
* Automatically starts the BudsLink service in background mode
* Communicates with BudsLink via D-Bus
* System tray icon with a popup menu
* Quick access to device controls, including:
* Battery information
* Noise control (ANC / transparency modes)
* Launch Apps Device settings


### Installation
1. Ensure the BudsLink Flatpak application is installed:
2. Download and extract this branch as ZIP archive (or git clone).
3. Open a terminal and navigate to the extracted directory:
```
cd path/to/extracted-folder
./install.sh
```
4. Restart the Plasma shell
```
systemctl restart --user plasma-plasmashell
```
5. Right click on Panel or Desktop and `Add Widget`.
