#!/bin/sh
set -eu

_build() {
	ARCH=$(uname -m)
	TAG=$1
	if [ $# -eq 2 ];then
		TAG=$2
	fi
	#
	docker build . \
	  --no-cache=false \
	  -f Dockerfile/${ARCH}/${TAG} \
	  -t tukiyo3/xrdp-${ARCH}:${TAG}
}

_build core
_build xfce4
_build latest

# _build novnc
# _build lxde
# _build icewm
