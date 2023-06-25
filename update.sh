#!/bin/bash

sudo rm /usr/local/bin/nuke.sh &>/dev/null
sudo rm /usr/local/bin/usbmount.sh &>/dev/null
sudo rm /etc/udev/rules.d/usbmount.rules &>/dev/null

sudo cp nuke.py /usr/local/bin/nuke.py
sudo cp usbmount.sh /usr/local/bin/usbmount.sh
sudo cp usbmount.rules /etc/udev/rules.d/usbmount.rules

sudo chmod +x /usr/local/bin/nuke.py /usr/local/bin/usbmount.sh

sudo udevadm control --reload-rules
