#!/bin/bash

ON_MAC=
LOCAL=/data/scratch
PWD=`pwd`

SCRATCHSPACE=${LOCAL}/scratchspace
FS=${SCRATCHSPACE}/fs
IMAGE=${FS}/image

ZIPFILE=I9500UBUFNC1_I9500UWMFNC1_COL.zip
TARFILE=I9500UBUFNC1_I9500UWMFNC1_I9500UBUFNA2_HOME.tar.md5
FLASHFILE=${PWD}/I9500_kernel.tar

BOOTIMG=boot.img

UNPACKBOOTIMG=/data/android/bin/unpackbootimg
MKBOOTIMG=/data/android/bin/mkbootimg
if [ "x$ON_MAC" = "x1" ]; then
    KERNEL=/data/GT-I9500-KK/artifacts/arch/arm/boot/zImage
else
    KERNEL=/data/GT-I9500-KK/updates/arch/arm/boot/zImage
fi

OLDRAMDISK=initramfs.cpio.gz
NEWKERNEL=boot.bin-zImage
RAMDISK=boot.bin-ramdisk.gz

PAGESIZE=2048
BASE=10000000

function doit {
    echo "$@"
    eval "$@"

    res=$?
    if [ $res != 0 ];then
        echo "failed [$@]"
        exit $res
    fi
}

doit pushd .
doit make
doit cd ${LOCAL}


if [ ! -d "${IMAGE}" ]; then
    doit mkdir -pv ${IMAGE}
fi

if [ ! -e "${SCRATCHSPACE}/${TARFILE}" ]; then
    doit unzip -d ${SCRATCHSPACE} ${ZIPFILE} ${TARFILE}
fi

if [ ! -e "${FS}/${BOOTIMG}" ]; then
    doit pushd .
    doit cd ${FS}
    doit tar xf ${SCRATCHSPACE}/${TARFILE}
    doit popd
fi

doit cd ${IMAGE}

doit ${UNPACKBOOTIMG} ${FS}/${BOOTIMG}
doit mv ${OLDRAMDISK} ${RAMDISK}
doit cp ${KERNEL} ${NEWKERNEL}
doit ${MKBOOTIMG} --kernel ${NEWKERNEL} --ramdisk ${RAMDISK} --pagesize ${PAGESIZE} --base ${BASE} -o ${BOOTIMG}
doit tar cf ${FLASHFILE} ${BOOTIMG}

if [ "x$ON_MAC" = "x" ]; then
    doit cp ${FLASHFILE} /mnt/hgfs/shared/samsung/
else
    doit cp ${FLASHFILE} /mnt/vmhgfs/sup/samsung/
fi

doit popd
