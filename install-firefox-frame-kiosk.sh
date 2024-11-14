#!/bin/bash

snap install ubuntu-frame;

snap install firefox;

snap connect firefox:wayland ubuntu-frame:wayland;

############################################################################################################
###################################### CREATE THE SYSTEMD SERVICE FILE #####################################
############################################################################################################
echo "Creating kiosk.service systemd.service file...";

cat <<EOF > kiosk.service
[Unit]
# https://www.freedesktop.org/software/systemd/man/systemd.unit.html#%5BUnit%5D%20Section%20Options \
Description=Firefox Wayland Kiosk
After=snap.ubuntu-frame.daemon.service snap.ubuntu-frame-osk.daemon.service getty.target network.target network-online.target
Wants=snap.ubuntu-frame-osk.daemon.service
Requires=snap.ubuntu-frame.daemon.service
Conflicts=display-manager.service
StartLimitIntervalSec=0

[Service]
# https://discourse.ubuntu.com/t/environment-variables-for-wayland-hackers/12750
Type=simple
Restart=always
RestartSec=3
Environment=WAYLAND_DISPLAY=wayland-0
Environment=MOX_CRASHREPORTER_DISABLE=1
Environment=GDK_BACKEND=wayland
Environment=MOZ_ENABLE_WAYLAND=1
Environment=HOME=/root
Environment=XDG_RUNTIME_DIR=/run/user/0
Environment=XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/snapd/desktop
ExecStartPre=/snap/bin/firefox --CreateProfile "default"
ExecStart=/bin/sh -c 'export KIOSK_URL=\$(cat $HOME/kiosk_url); exec /snap/bin/firefox -P default --kiosk --private-window --disable-pinch \$KIOSK_URL'
#ExecStart=/snap/bin/firefox -P default --kiosk --private-window --disable-pinch "https://www.yahoo.com"
Nice=15

[Install]
WantedBy=graphical.target
EOF
echo "done";
############################################################################################################


############################################################################################################
################################# CREATE THE KIOSK URL FILE ################################################
############################################################################################################
echo "Creating kiosk_url storage file...";
echo "https://nwdigital.cloud" | tee kiosk_url;
echo "done";
############################################################################################################



############################################################################################################
################################# CREATE THE KIOSK SCRIPT FILE #############################################
############################################################################################################
echo "Creating kiosk script handler file...";

cat <<EOF > kiosk
#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Syntax: scriptTemplate [-g|h|v|V]"
   echo "options:"
   echo "-r     Restart the kiosk" 
   echo "-h     Print this Help."
   echo "-u     Sets the url for the kiosk."
}

############################################################
# Process the input options. Add options as needed.        #
############################################################

# Get the options
while getopts ":rhu" option; do
    case \$option in
        r) # restart kiosk
            sudo systemctl restart kiosk 
            echo "Restarting Kiosk"
            exit;; 
        h) # display Help
            Help
            exit;;
        u) # update url
            echo \$2 > /home/nwdigital/kiosk_url
            sudo systemctl restart kiosk
            echo "New url is now: " \$2
            exit;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
   esac
done
EOF

echo "Making kiosk script executable";
sudo chmod a+x kiosk;
echo "done";
############################################################################################################


############################################################################################################
echo "Moving kiosk.service to /etc/systemd/system/kiosk.service";
sudo mv kiosk.service /etc/systemd/system/;
echo "Kiosk Installed Successfully...";
sudo systemctl enable kiosk.service;
echo "Kiosk service enabled...";
sleep 2;
echo "Starting Ubuntu-Frame...";
sleep 2;
snap start ubuntu-frame;
sleep 10;
sudo systemctl start kiosk.service;
echo "Kiosk starting...";
sleep 2;
############################################################################################################

echo "Installation Complete!";
