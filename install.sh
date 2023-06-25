#!/bin/bash
sudo apt update
sudo apt -y install secure-delete nwipe python3-gpiozero python3-pip
pip3 install RPi.GPIO
sudo touch /var/log/PiBAN.log
sudo ./update.sh
