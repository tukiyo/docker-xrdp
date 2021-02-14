docker stop xrdp
docker rm xrdp

# TAG="icewm"
# TAG="xfce4"
# TAG="lxde"
# TAG="core"
TAG="latest"

# SYS_ADMIN : chrome 使用時に必要
# DAC_READ_SEARCH : smbmount 使用時に必要

# Example
PASS=${USER}@$(date "+%Y")

docker run -it \
    --privileged \
    --name xrdp \
    --restart=always \
    #-u 1001:1001 \
    -e GITHUB_USER=tukiyo \
    -e USER=$USER \
    -e PASSWD=$PASS \
    -v /dev/shm:/dev/shm \
    -p 3389:3389 \
    -p 10022:22 \
  tukiyo3/xrdp-$(uname -m):$TAG
  #yama07/docker-ubuntu-lxde:ubuntu18.04_ja_pulseaudio

#   -u $(id -u):$(id -g) \
docker logs xrdp

# docker run -it -d \
#     --cap-add SYS_ADMIN \
#     --cap-add DAC_READ_SEARCH \
#     --security-opt apparmor:unconfined \
#     --name xrdp \
#     --restart=always \
#     -u $(id -u):$(id -g) \
#     -e USER=user1 \
#     -e PASSWD=hogehoge \
#     -v /dev/shm:/dev/shm \
#     -p 3389:3389 \
#   tukiyo3/xrdp-$(uname -m):$TAG
