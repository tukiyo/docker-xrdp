set -eu

_build() {
	TAG=$1
	if [ $# -eq 2 ];then
		TAG=$2
	fi
	docker build . --no-cache=false -f Dockerfile/${1} -t tukiyo3/xrdp:${TAG}
}

_build core
_build chrome
_build novnc
_build lxde
_build xfce4
_build firefox
_build icewm
_build work latest
