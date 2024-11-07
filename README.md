# firefox-kiosk
FireFox Ubuntu Frame Wayland Kiosk

# REQUIREMENTS
Physical device running freshly installed Ubuntu Core 24

# INSTALLATION - Ubuntu Core 24
To install, simply download the file and save it to your home folder on the target Ubuntu Core device. You can do this with FileZilla or using SCP via terminal.

chmod a+x install-firefox-frame-kiosk.sh
./install-firefox-frame-kiosk.sh

# USAGE
[Intructions Here](https://nwdigital.cloud/blog/2024/11/01/build-firefox-ubuntu-frame-kiosk-on-ubuntu-core-24-with-mir-kiosk/)


# Set ubuntu-frame orientation
* https://mir-server.io/docs/ubuntu-frame-configuration-options

* First get the active display name and append -1 to it.

* $user_bash: `snap logs -n 100 ubuntu-frame`

* To get a list of connected displays: `snap get ubuntu-frame display`

* Then enter the following replacing left or right in the orientation section and replacing HDMI-A-1 with your monitor name.

* To get the currently active layout: `snap get ubuntu-frame display-layout`
