#!/bin/bash

MACHINE=overo

if [ "x${1}" = "x" ]; then
	echo -e "\nUsage: ${0} <block device>\n"
	exit 0
fi

if [ -z "$OETMP" ]; then
	echo -e "\nWorking from local directory"
    SRCDIR=.
else
	echo -e "\nOETMP: $OETMP"

	if [ ! -d ${OETMP}/deploy/images/${MACHINE} ]; then
		echo "Directory not found: ${OETMP}/deploy/images/${MACHINE}"
		exit 1
	fi

	SRCDIR=${OETMP}/deploy/images/${MACHINE}
fi 

if [ ! -f ${SRCDIR}/MLO-${MACHINE} ]; then
	echo -e "File not found: ${SRCDIR}/MLO-${MACHINE}\n"
	exit 1
fi

if [ ! -f ${SRCDIR}/u-boot-${MACHINE}.img ]; then
	echo -e "File not found: ${SRCDIR}/u-boot-${MACHINE}.img\n"
	exit 1
fi

if [ ! -f ${SRCDIR}/uImage-${MACHINE}.bin ]; then
	echo -e "File not found: ${SRCDIR}/uImage-${MACHINE}.bin\n"
	exit 1
fi

DEV=/dev/${1}1

if [ -b $DEV ]; then
	echo "Formatting FAT partition on $DEV"
	sudo mkfs.vfat -F 32 ${DEV} -n BOOT

	echo "Mounting $DEV"
	sudo mount ${DEV} /media/card

	echo "Copying MLO"
	sudo cp ${SRCDIR}/MLO-${MACHINE} /media/card/MLO

	echo "Copying u-boot"
	sudo cp ${SRCDIR}/u-boot-${MACHINE}.img /media/card/u-boot.img

	if [ -f ${SRCDIR}/boot.scr ]; then
		echo "Copying boot.scr"
		sudo cp ${SRCDIR}/boot.scr /media/card/boot.scr

		if [ -f ${SRCDIR}/boot.cmd ]; then
			echo "Copying boot.cmd"
			sudo cp ${SRCDIR}/boot.cmd /media/card/boot.cmd
		fi
	fi

	echo "Copying uImage"
	sudo cp ${SRCDIR}/uImage-${MACHINE}.bin /media/card/uImage

	echo "Unmounting ${DEV}"
	sudo umount ${DEV}
else
	echo -e "\nBlock device not found: $DEV\n"
fi

echo "Done"

