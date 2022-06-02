DATE=$(date "+%Y%m")

docker stop xrdp
docker rm xrdp

docker run -it -d \
 --cap-add SYS_ADMIN \
 --cap-add DAC_READ_SEARCH \
 --security-opt seccomp=unconfined \
 --name xrdp \
 --hostname xrdp \
 --restart=always \
 -u 1000:1000 \
 -e GITHUB_USER=tukiyo \
 -e USER=ubuntu \
 -e PASSWD="[ubuntu@${DATE}]" \
 -v $(pwd)/host/:/host/ \
 -v /dev/shm:/dev/shm \
 -v /dev/fuse:/dev/fuse \
 -p 3389:3389 \
 -p 10022:22 \
 tukiyo3/xrdp-$(uname -m):core
