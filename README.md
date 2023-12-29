[![Python application](https://github.com/antoniofs23/Columnar/actions/workflows/python-app.yml/badge.svg)](https://github.com/antoniofs23/Columnar/actions/workflows/python-app.yml)

# Quick Intro

This was very much a passion project since I didn't want to install a whole new window manager or mess around with existing linux based window managers that were overly complicated. All I wanted was to tile my open windows into columns with the press of a key. 

Alas **Columnar!** A stupid simple tiling-window-manager:
1. `F7`: starts auto tiling
2. `F8`: swap active window to a center tile 
3. `F9`: minimizes a window
4. `F10`: stops columnar

>[!NOTE]
>This was built for my needs on a 49" ultrawide monitor. If anyone wants to add more functionality, improve it for smaller screens, or fix a bug? feel free to send a pull request!

## Installation

1. clone this repo to your home directory via:  `git clone https://github.com/antoniofs23/Columnar.git`
2. In app directory run the `INSTALL.sh` file

>[!NOTE]
>*the install file assumes python is already installed (which it normally is)* if not python3 is required prior to running `INSTALL.sh`. To quickly check if python is installed run `python -V` in your terminal

### running the app
The app should auto-start on login.
However, it can also be run through the `columnar` terminal command

---

The app lives on your top-menu-bar:

![Screenshot from 2023-12-29 14-40-08](https://github.com/antoniofs23/Columnar/assets/39067846/0d0917b2-53ab-4b2b-9b53-bdf8ce719021)

- The app is on by deafult and can be seen on your linux panel
- To exit press `F10` (this removes the icon)

# App functionality-walkthrough

Press `F7` after clicking `activate` on the app icon to auto-tile:
![Screencast from 12-12-2023 08_40_52 PM](https://github.com/antoniofs23/Columnar/assets/39067846/3de5a45f-81e2-4fac-8121-066edee2e4e7)

Press  `F9` to minimize a window:
![Screencast from 12-12-2023 08_50_15 PM](https://github.com/antoniofs23/Columnar/assets/39067846/96c08ce9-fdf0-457c-9a52-303ff03e3405)

Press `F7` again to re-tile ignoring minimized windows
![Screencast from 12-12-2023 08_50_33 PM](https://github.com/antoniofs23/Columnar/assets/39067846/dce00eef-2ede-4bb5-9424-c4e4ae551f70)

Press `F8` to swap the active window with the center window (if num of tiles is even then moves to left-center)
![Screencast from 12-12-2023 08_51_00 PM](https://github.com/antoniofs23/Columnar/assets/39067846/9faca0eb-f869-4fed-b3ec-60199168bf20)

You can always press `F7` to re-tile after mninizing or closing some windows. That should cover everything!



