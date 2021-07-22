# manjaroid

Interactive shell script that creates a minimal Manjaro ARM Linux subsystem on [Termux](https://termux.com) with the power of [PRoot](https://wiki.termux.com/wiki/PRoot).

### Features

* Pre-configured VNC server
* Audio passthrough
* Emulated `/proc` entries for unrooted devices


## Installation

From Termux, download and execute the installation script with one command:
```
bash <(curl -s https://raw.githubusercontent.com/EncryptedCurse/manjaroid/master/install.sh)
```
Prompts will appear throughout the installation to determine the root directory, whether to install XFCE4, etc. If left blank, text prompts will default to the value within the parentheses and yes/no prompts will default to no.


## Usage

After installation, enter the subsystem using the automatically generated launch script:
```
./manjaroid.sh [username]
```
A username can be optionally specified to directly log into an (existing) account; otherwise, it will default to root.

After login, start the VNC server using the following command:
```
vncserver :1
```
You can use a VNC client like [RealVNC](https://www.realvnc.com) to connect to it (either locally or from a different device within the same network).


## Tips

### Use a different DE/WM

If you decline to install XFCE4 during setup or decide to switch to something else down the line, you will need to append/edit the following line to the end of `/etc/vnc/xstartup` to launch the new DE/WM:

```
exec dbus-launch <command>
```

### Add (more) sudo users

First, run the following command:
```
useradd -m -G wheel <username>
```

Then, append the following line to `/etc/sudoers`:
```
<username> ALL=(ALL) ALL
```

### Disable XFCE4 shadows

```
xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false
xfconf-query -c xfwm4 -p /general/show_frame_shadow -s false
xfconf-query -c xfwm4 -p /general/show_popup_shadow -s false
```

### Install Firefox

```
pacman -S firefox
```

### Install VS Code

```
pacman -S libsecret gnome-keyring xdg-utils code
```

In order to access features that require a GitHub/Microsoft account (e.g. settings sync), ensure that you have a [web browser](#install-firefox) and the supplementary packages installed before attempting to login.
