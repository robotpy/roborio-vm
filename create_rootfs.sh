#!/bin/bash -e

NBD_DEVICE=/dev/nbd0

cd `dirname $0`
source params

if [ -f "$IMG_FILE" ]; then
  echo "$IMG_FILE already exists! Please delete it if you wish to build a new image"
  exit 1
fi

if [ "$1" == "" ]; then
  echo "Usage: $0 /path/to/FRC_roboRIO_*.zip"
  exit 1
fi

ROBORIO_ZIP="$1"

QEMU_NBD=`which qemu-nbd`

function abspath {
  return "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

function rm_mount {
  if [ -d mnt ]; then
    sudo umount mnt || true
    rmdir mnt
  fi
}

function rm_unpacked {
  [ ! -d unpacked ] || rm -rf unpacked
}

function cleanup {
  echo "Cleaning up..."
  rm_unpacked
  rm_mount
  
  if [ ! -z "$NBD_DEVICE" ]; then
    sudo "$QEMU_NBD" -d $NBD_DEVICE
  fi
}

trap cleanup EXIT

rm_unpacked
rm_mount

# Unpack the roborio image zipfile, ensure we're sane
mkdir unpacked

unzip "$ROBORIO_ZIP" -d unpacked
# there are two files in there, one is a zip file, unzip the zip file
mkdir unpacked/more
unzip unpacked/*.zip -d unpacked/more

# Make sure the file we're looking for is there
if [ ! -f unpacked/more/systemimage.tar.gz ]; then
  echo "Error: Expected to find systemimage.tar.gz, did not find it!"
  exit 1
fi

# Create the qemu image
qemu-img create -f qcow2 "$IMG_FILE" $HDD_SIZE

# Mount it, format it (requires root access!)
sudo modprobe nbd

sudo "$QEMU_NBD" -d /dev/nbd0
sudo "$QEMU_NBD" -c $NBD_DEVICE "$IMG_FILE"

echo "Formatting image, this may take a few minutes..."
# TODO: probably should use a different filesystem
sudo mkfs.ext3 $NBD_DEVICE 

mkdir mnt
sudo mount -t ext3 $NBD_DEVICE mnt

# Untar the file onto the image..
echo "Unpacking FRC image..."
sudo tar -xf unpacked/more/systemimage.tar.gz --directory mnt

# Modify the startup configuration to enable SSHD
STARTUP_INI_FILE=mnt/etc/natinst/share/ni-rt.ini
sudo python _modify_ini.py ${STARTUP_INI_FILE} SYSTEMSETTINGS host_name roboRIO-VM
sudo python _modify_ini.py ${STARTUP_INI_FILE} SYSTEMSETTINGS sshd.enabled True
sudo python _modify_ini.py ${STARTUP_INI_FILE} SYSTEMSETTINGS ConsoleOut.enabled True

# Unmount it
rm_mount

# Create a snapshot in case someone wants to revert their VM without rebuilding it
qemu-img snapshot -c initial "$IMG_FILE"

echo "Successfully created $IMG_FILE!"
