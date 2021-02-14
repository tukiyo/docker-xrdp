DATE=$(date "+%Y%m")

docker run -it -d \
 --cap-add SYS_ADMIN \
 --cap-add DAC_READ_SEARCH \
 --security-opt apparmor:unconfined \
 --name xrdp \
 --hostname xrdp \
 --restart=always \
 -u 1000:1000 \
 -e GITHUB_USER=tukiyo \
 -e USER=focal \
 -e PASSWD="[focal@${DATE}]" \
 -v $(pwd)/../docker-xrdp-home:/home \
 -v /dev/shm:/dev/shm \
 -v /dev/fuse:/dev/fuse \
 -p 3389:3389 \
 -p 10022:22 \
 tukiyo3/xrdp-$(uname -m):core
