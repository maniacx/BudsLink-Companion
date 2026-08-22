# BudsLink Companion - Cinnamon Applet

<img src="https://github.com/maniacx/BudsLink-Companion/blob/main/images/cinnamon-applet.png" alt="Cinnamon Applet" width="500"/>


* BudsLink Companion provides desktop integration for the Flatpak application BudsLink [**BudsLink**](https://github.com/maniacx/BudsLink).
* It acts as a bridge between the BudsLink service and the Cinnamon desktop environment, exposing device controls through a system tray applet.

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
2. Download and extract the latest release ZIP archive.
3. Open a terminal and navigate to the extracted directory:
```
cd path/to/extracted-folder
./install.sh
```
4. Restart the Cinnamon shell to load the applet
5. Navigate to Applets, Enable BudsLink Companion
