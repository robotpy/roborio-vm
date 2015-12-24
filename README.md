QEMU RoboRIO ARM Virtual Machine
================================

This is a set of scripts that extracts the files for National Instruments 
Real Time Linux from the RoboRIO image zipfile, creates an image from them,
and provides a script that allows you to run them via the QEMU emulator.

What can you use this for? Well, if you need to compile packages that are
difficult to cross compile or build on a resource constrained system,
or do testing that requires an ARM platform but does not require actual
NI hardware.. this might be for you.

Tested with:

* Fedora 22, OSX (run only)
* QEMU 2.5.0
* FRC images: 2016v18
  * I tried 2015v23, but there's an error starting the NI configuration daemon
    and so ssh refuses to start.

It probably works on other Linux distributions, and may even work with OSX if
you adjust the scripts to work there.

Requirements
------------

For creating an image:

* A linux host with the following installed:
  * mkfs
  * unzip
  * qemu-img, qemu-nbd
  * root permissions

For running the created image:

* QEMU arm emulator (qemu-system-arm)
  * Works on Linux and OSX

Creating the Virtual Machine root filesystem
--------------------------------------------

First, you need the image zipfile that is distributed with the FRC Update Suite.
On a machine with the RoboRIO imaging program installed, you can find it at:

    C:\Program Files (x86)\National Instruments\LabVIEW 2015\project\roboRIO Tool\FRC Images

Copy the zipfile to your Linux host, and run the following:

    ./create_rootfs.sh /path/to/FRC_roboRIO_*.zip
  
Give it a few minutes, enter in your password when prompted, and at the end you 
should end up with an image file and a kernel file. This only needs to be done
once.

Running the Virtual Machine
---------------------------

Simple command:

    ./run_vm.sh

At the moment there are a lot of error messages, but eventually it will finish
starting and you can login via the console or via SSH.

To SSH into your VM, you can execute the following:

    ssh admin@localhost -p 10022
  
Snapshots
---------

QEMU has good support for snapshots and other such things. When the rootfs is
created, an initial snapshot is created in case you want to revert the VM
back to a 'pristine' state. To do so:

    qemu-img snapshot -a initial roborio.img

Known issues
------------

* I haven't figured out a good way to safely shutdown the system
* Probably should use a different filesystem for the image
* Lots of error messages on bootup, would be nice if we could use the actual
  kernel used on the RoboRIO (this seems like it should be possible)

Contributing new changes
========================

This is intended to be a project that all members of the FIRST community can
quickly and easily contribute to. If you find a bug, or have an idea that you
think others can use:

1. [Fork this git repository](https://github.com/robotpy/roborio-vm/fork) to your github account
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. Create new Pull Request on github

Authors
=======

* Dustin Spicuzza (dustin@virtualroadside.com)

These scripts are not endorsed or associated with Xilinx, FIRST Robotics, or
National Instruments.
