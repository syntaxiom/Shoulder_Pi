# Shoulder_Pi
This is a general purpose game engine that runs on the Raspberry Pi 3 using ARM assembly.

## Important notes
You need to be in console mode (shortcut Ctrl+Alt+F1) to run the code.
To get back to GUI mode, press Ctrl+Alt+F7.

See parts 5, 6, and 7 of the compote.blogspot link. It's important for accessing RGB values.

Need to offset by 1 each 4 division for color

## Transparency/Opacity Formula
C1 = [R1, G1, B1]

C2 = [R2, G2, B2]

C2 is overlayed on top of C1. p = Opacity. 0 <= p <= 1.

C3 = [(1 - p)*R1 + p*R2, (1 - p)*G1 + p*G2, (1 - p)*B1 + p*B2]

## Helpful resources
http://raspberrycompote.blogspot.com/2012/12/low-level-graphics-on-raspberry-pi-part_9509.html

https://www.raspberrypi.org/documentation/hardware/raspberrypi/peripheral_addresses.md

http://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/screen01.html

https://github.com/ICTeam28/PiFox
