am335x_bandgap
==============

**DISCLAIMER: Procede at your own risk.  This process requires modifying dtb files required for booting your Beaglebone Black and identifying it's hardware.  I only assert that it has worked for me and take no responsibility for anything that may or may not happen if you follow or don't follow these steps.**


This is the am335x_bandgap temperature sensor as a dkms module tested under Linux kernel 3.19.3-1-ARCH for the Beaglebone Black.  As best I can determine, this is no longer part of newer kernels because TI has indicated that the sensor is unreliable -- as the case may be, I personally would rather something than nothing.

### Better Device Tree Modification

`dtc` can be installed from pacman or AUR... I am using `dtc-git-patched` from AUR, but I don't really know what it's differences are with the one in the Community repo, other than I believe it to be a little newer.

~~~bash
    $ cd /boot/dtbs
    $ dtc -I dtb -O dts am335x-boneblack.dtb > /root/am335x-boneblack.dts
    $ cd
    $ patch -p0 am335x-boneblack.dts < bandgap.patch
    $ dtc -O dtb -o am335x-boneblack.dtb -b 0 am335x-boneblack.dts
    $ cp /boot/dtbs/am335x-boneblack.dtb /boot/dtbs/am335x-boneblack.dtb.dist
    $ cp am335x-boneblack.dtb /boot/dtbs/am335x-boneblack.dtb
~~~

The `bandgap.patch` is the only one you need for this module to work.  The other patch file also contains changes to enable the ADC pins AIN0-6 and /dev/ttyS1-4 (although 3.19.3 has a hard coded limit of 4 uarts (ttyS0 is already enabled)... supposedly this is patched in the next kernel... we'll see... I really only need 2 of them, and I really hate compiling custom kernels.) I include it here so I have a backup and these notes...

### Module installation

Copy the contents of this repository into /usr/src/am335x_bandgap-20150411 and type
`dkms install am335x_bandgap-20150411` and reboot.

The file `cpu_temp` found in the `00_resources` folder of this repository is a sample script that shows how to get the current reported temperature.

### Original Device Tree Modification

***To give credit to those whose notes and work led to my stuff, I leave this in; however, I recommend you do the above for the device tree files, as it should remain compatible even if the file has already been updated by a new kernel or other code.***

*Requires DKMS to be installed and whatever else is required for building kernel modules.*

*This is a two step process... first you have to rebuild the `/boot/dtbs/am335x-boneblack.dtb` file to add the am335x bandgap sensor... I came across http://archlinuxarm.org/forum/viewtopic.php?f=48&t=8670, which led me to https://gist.github.com/matthewmcneely/bf44655c74096ff96475, where we download `dtb-rebuilder`.  Add the analog definitions he talks about on the last page, or don't, but before you type 'make' as instructed, add the following to `src/arm/am33xx.dtsi` after the mcasp1: entry (or see `am33xx.dtsi` in the `00_resources` folder of this repository):*

                bandgap@44e10448 {
                        compatible = "ti,am335x-bandgap";
                        reg = <0x44e10448 0x8>;
                };

*Then continue with the instructions for using `dtb-rebuilder`.*

### Sources

This module was cobbled together from steps and code found at the following sites:

* https://github.com/beagleboard/meta-beagleboard/blob/master/common-bsp/recipes-kernel/linux/linux-mainline-3.8/resources/0021-hwmon-add-driver-for-the-AM335x-bandgap-temperature-.patch

* https://github.com/chunsj/nxctrl/blob/master/am335x-bandgap/am335x-bandgap.c

* http://archlinuxarm.org/forum/viewtopic.php?f=48&t=8670

* https://gist.github.com/matthewmcneely/bf44655c74096ff96475
