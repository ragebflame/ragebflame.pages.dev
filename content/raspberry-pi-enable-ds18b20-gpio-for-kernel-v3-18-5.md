+++
title = "Enabling the DS18B20 GPIO for Raspberry Pi kernel v3.18.5+"
date = 2015-02-25

[taxonomies]
tags = ["raspberry pi", "programming", "linux"]
+++

I noticed that the DS18B20 temperature sensor had stopped working correctly after upgrading the kernel on the Pi. Not to worry, the fix is simple.

First, check the kernel version:

```bash
pi@raspberrypi $ cat /proc/version
Linux version 3.18.7+ (dc4@dc4-XPS13-9333) (gcc version 4.8.3 20140303 (prerelease) (crosstool-NG linaro-1.13.1+bzr2650 - Linaro GCC 2014.03) )
```

If the version is **3.18.5** or later, then you need to add the following to `/boot/config.txt`

```text
dtoverlay=w1-gpio
```

This is assuming your DS18B20 is connected using three wires and a 4K7 resistor, With data on to Pin 7 (GPIO4). This is the usual way of hooking it up. Its very well documented [by Cambridge University](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/temperature/).

Any changes to `/boot/config.txt` will require a reboot of the Pi. When its back up you should see the sensor again.

```bash
pi@raspberrypi /sys/bus/w1/devices $ cat /28-00000521b2b8/w1_slave
28 01 4b 46 7f ff 08 10 4c : crc=4c YES
28 01 4b 46 7f ff 08 10 4c t=18500
```
