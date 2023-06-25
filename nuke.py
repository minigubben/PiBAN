#!/usr/bin/env python3
import sys
import subprocess
from gpiozero import LED, Button
import logging

logging.basicConfig(filename='/var/log/PiBAN.log', level=logging.INFO)
log = logging.getLogger('PiBAN')

erase_led = LED(17)
ready_led = LED(27)
erase_switch = Button(22)

def erase_drive(drive):
    erase_led.on()
    ready_led.off()
    if erase_switch.is_pressed:
        log.info("3 Pass Erase Selected")
        subprocess.run(['nwipe', '--autonuke', '--nogui', '--nowait', drive])
    else:
        log.info("1 Pass Erase Selected")
        subprocess.run(['shred', '-v', '--iterations=1', drive])
    erase_led.off()
    ready_led.on()

def format_drive(drive):
    log.info("FORMATTING " + drive)
    subprocess.run(['bash', '-c', f"echo o | sudo fdisk {drive}"])
    subprocess.run(['mkfs.vfat', '-F', '32', drive+'1'])

def main():
    device = sys.argv[1]
    log.info("NUKING " + device)
    erase_drive(device)
    format_drive(device)

if __name__ == "__main__":
    main()
