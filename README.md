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

# Reboot the device daily (Optional)
If you would like to have your Ubuntu Core device reboot daily at a specific time, you can use the kiosk_reboot.service and kiosk_reboot.timer files included in the Main Repository here.

* Create the kiosk_reboot.service file using this command:
sudo vi /etc/systemd/system/kiosk_reboot.service and add the contents from the file I have here.

* Next, create the kiosk_reboot.timer service using this command:
sudo vi /etc/systemd/system/kiosk_reboot.timer.

Once you have both files saved, simply enable and start the kiosk_reboot.timer.
* Enter the following command in terminal:
sudo systemctl enable kiosk_reboot.timer && sudo systemctl start kiosk_reboot.timer

The reboot time is in UTC since that is the default timezone setting for Ubuntu Core. Adjust as needed.
