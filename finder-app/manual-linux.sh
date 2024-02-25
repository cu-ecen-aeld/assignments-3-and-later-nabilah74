#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make mrproper
    make defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${OUTDIR}/rootfs modules_install
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_PATH=${OUTDIR}/linux-stable/arch/${ARCH}/boot install
    echo "Kernel built successfully"
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
sudo mkdir -p "${OUTDIR}/rootfs"/{bin,dev,etc,home,lib,mnt/root,proc,sbin,sys,tmp,usr/bin,usr/lib,usr/sbin}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
sudo make CONFIG_PREFIX=${OUTDIR}/rootfs/ install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
sudo mkdir -p "${OUTDIR}/rootfs/lib"
sudo cp $(find /usr/aarch64-none-linux-gnu/lib/ -name "libm.so*" -o -name "libc.so*") "${OUTDIR}/rootfs/lib/"

# TODO: Make device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}/writer/
make clean
make
sudo cp ${FINDER_APP_DIR}/writer/writer ${OUTDIR}/rootfs/home/

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
sudo mkdir -p ${OUTDIR}/rootfs/home/finder
sudo cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
sudo cp ${FINDER_APP_DIR}/finder_utils.sh ${OUTDIR}/rootfs/home/
sudo cp ${FINDER_APP_DIR}/writer/writer ${OUTDIR}/rootfs/home/
sudo cp ${FINDER_APP_DIR}/reader.sh ${OUTDIR}/rootfs/home/
sudo cp ${FINDER_APP_DIR}/logger.sh ${OUTDIR}/rootfs/home/

# TODO: Chown the root directory
sudo chown -R root:root ${OUTDIR}/rootfs/

# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs/
sudo find . | sudo cpio -H newc -ov --owner root:root > ../initramfs.cpio
cd ..
gzip initramfs.cpio