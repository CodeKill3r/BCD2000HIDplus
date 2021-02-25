# BCD2000HID+

Behringer BCD2000 custom firmware to use w/o driver

As the company no longer supports this device, there is no driver for any modern OS. 
Even when it came out it lacked support for platforms other than winXP.

This cfw adds proper USB Audio and MIDI descriptors to be recognised and used by modern OSes.

MIDI handlers has been rewritten to understand and produce proper USB-MIDI messages.

You have to open the controller and reprogram the EEPROM inside to apply this firmware.

Thanks to Davy for sharing his step by step guide: https://davy.cf/bcd2000
