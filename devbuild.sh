#!/bin/bash

SCRIPTDIR="$(dirname `readlink -f $0`)"

BASEIMG="$SCRIPTDIR"/ubuntu-base-20.04-base-amd64.tar.gz
PROOT="$SCRIPTDIR/proot-5.2 -w / "
BUILDDIR="$SCRIPTDIR/.tmp"
DEVSCRIPT="$1"

init() {
	[ ! -d "$BUILDDIR" ] && mkdir -p $BUILDDIR && tar -xzvpf "$BASEIMG" --directory "$BUILDDIR"
}

clean() {
	rm -rf $BUILDDIR
}

info() {
	echo -e "\e[32m$*\e[0m"
}

error() {
	echo -e "\e[31m$*\e[0m"
}

runroot() {
	$PROOT -S $BUILDDIR "$@"
}

runuser() {
	$PROOT -R $BUILDDIR "$@"
}

import_pipe() {
	local data
	rm -r "$BUILDDIR/$1"
	while read -r data; do
		printf "%s\n" "$data" >> "$BUILDDIR/$1"
	done
}

setup_timezone() {
	local TZ="$(wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/p')"
	info SETUP AND CLONE TIMEZONE $TZ
	runroot sh -c 'DEBIAN_FRONTEND="noninteractive" apt -y install tzdata'
	runroot ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
	runroot dpkg-reconfigure --frontend noninteractive tzdata
}

apt_update() {
	info UPDATE PACKAGE INFO
	runroot apt update
}

apt_upgrade() {
	info UPGRADE PACKAGE BASE
	runroot apt -y upgrade
}

create_kvm() {
	local scale=1.3
	local size="$(du -sb $BUILDDIR | awk '{print int($1*'$scale')}')"
	qemu-img create -f qcow2 qtermwidget.img $size -o preallocation=full
}

##########

if [ "$DEVSCRIPT" == "" ]; then
	#clean
	create_kvm
else
	init
	source $DEVSCRIPT
fi
