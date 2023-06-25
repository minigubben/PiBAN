#!/usr/bin/python3

from gpiozero import LED, Button
import os
import sys
import subprocess

# If the switch connected to GPIO 22 is off, (button_select.is_pressed is False) 
# when the script starts, it will run the shred command. Else, it will run the nwipe command. 
# GPIO 17 is the "shred" notification LED.  It will be ON during shred/nwipe operation.
# GPIO 27 is the "ready" LED.  It will be OFF during shred/nwipe, ON at all other times.

led_process = LED(17)
led_ready = LED(27)
button_select = Button(22)

devname = os.path.basename(sys.argv[1])

#-----------------------------------------------------------------------------
# Based on switch on/off, automatically run 1-Pass or 3-Pass
#-----------------------------------------------------------------------------
led_ready.on()

with open('/var/log/PiBAN.log', 'a') as log_file:
    log_file.write(f'NUKING {sys.argv[1]}\n')

led_process.on()
led_ready.off()

# If the switch is pressed (Button returns False when pressed), run shred
if not button_select.is_pressed:
    subprocess.run(['shred', '-v', '--iterations=1', sys.argv[1]])
else:
    subprocess.run(['nwipe', '--autonuke', '--nogui', '--nowait', sys.argv[1]])

led_process.off()
#-----------------------------------------------------------------------------
# Format drive with FAT32
#-----------------------------------------------------------------------------
subprocess.run(['parted', '-s', sys.argv[1], 'mklabel', 'msdos'])
subprocess.run(['parted', '-s', sys.argv[1], 'mkpart', 'primary', 'fat32', '0%', '100%'])
subprocess.run(['mkfs.vfat', '-F', '32', f'{sys.argv[1]}1'])

mntpath = f'/mnt/{os.path.basename(sys.argv[1])}1'
os.makedirs(mntpath, exist_ok=True)

subprocess.run(['mount', f'{sys.argv[1]}1', mntpath])

os.chdir(mntpath)

with open('Erased_With_PiBAN.txt', 'w') as txt_file:
    txt_file.write('This drive has been securely erased and repartitioned with PiBAN\n'
                   'https://github.com/Real-Time-Kodi/PiBAN')

subprocess.run(['cp', f'/tmp/{devname}.log', '.'])

os.chdir('/')

subprocess.run(['umount', mntpath])
os.rmdir(mntpath)
#-----------------------------------------------------------------------------
subprocess.run(['sync'])

led_ready.on()

with open('/var/log/PiBAN.log', 'a') as log_file:
    log_file.write(f'Drive Completed {sys.argv[1]}\n')
