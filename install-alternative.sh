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
Description=Firefox Wayland Kiosk
After=snap.ubuntu-frame.daemon.service snap.ubuntu-frame-osk.daemon.service getty.target network.target network-online.target
Wants=snap.ubuntu-frame-osk.daemon.service
Requires=snap.ubuntu-frame.daemon.service
Conflicts=display-manager.service
#StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=3
EnvironmentFile=/home/$USER/kiosk_env_file
EnvironmentFile=/home/$USER/kiosk_url
ExecStartPre=/bin/sleep 5
ExecStartPre=/snap/bin/firefox --CreateProfile "default"
ExecStart=/snap/bin/firefox -P default -turbo -purgecaches -private-window --kiosk --disable-pinch \$KIOSK_URL
#Nice=1

[Install]
WantedBy=graphical.target
EOF
echo "kiosk.service created";
############################################################################################################

############################################################################################################
################################# CREATE THE KIOSK ENV FILE ################################################
############################################################################################################

echo "Creating Kiosk Environment Files";
cat <<EOF > kiosk_env_file
WAYLAND_DISPLAY=wayland-0
MOX_CRASHREPORTER_DISABLE=1
GDK_BACKEND=wayland
MOZ_ENABLE_WAYLAND=1
HOME=/root
XDG_RUNTIME_DIR=/run/$USER/0
XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/snapd/desktop
EOF
echo "Environment Files Created Successfully";

############################################################################################################
################################# CREATE THE KIOSK URL FILE ################################################
############################################################################################################

echo "Creating kiosk_url storage file...";
echo "KIOSK_URL=https://nwdigital.cloud" | tee kiosk_url;
echo "kiosk_url storage created";

############################################################################################################
############################## CREATE THE KIOSK REBOOT SERVICE #############################################
############################################################################################################

echo "Creating kiosk reboot service"
cat <<EOF > kiosk_reboot.service
[Unit]
Description=Ubuntu Core Reboot Service

[Service]
Type=simple
ExecStart=/sbin/reboot

[Install]
WantedBy=multi-user.target
EOF
echo "kiosk_reboot.service created"

############################################################################################################
############################### CREATE THE KIOSK REBOOT TIMER ##############################################
############################################################################################################

echo "Creating the kiosk reboot timer"
cat <<EOF > kiosk_reboot.timer
[Unit]
Description=Kiosk Reboot Timer

[Timer]
#OnCalendar=*:0/05
# every 5 minutes

OnCalendar=*-*-* 12:00:00
# every day at 6 am CST based on UTC time

[Install]
WantedBy=timers.target
EOF
echo "kiosk_reboot.timer created"

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
            echo "Restarting Kiosk"
            sudo systemctl restart kiosk 
            echo "Restart Successful"
            exit;; 
        h) # display Help
            Help
            exit;;
        u) # update url
            echo KIOSK_URL=\$2 > /home/$USER/kiosk_url
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
echo "Moving kiosk_reboot.service to /etc/systemd/system/kiosk_reboot.service";
sudo mv kiosk_reboot.service /etc/systemd/system/;

echo "Moving kiosk_reboot.timer to /etc/systemd/system/kiosk_reboot.timer";
sudo mv kiosk_reboot.timer /etc/systemd/system/;
sudo systemctl enable kiosk_reboot.timer;
sudo systemctl start kiosk_reboot.timer;
echo "Kiosk reboot timer enabled and started";

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
