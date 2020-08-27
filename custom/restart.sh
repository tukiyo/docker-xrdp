docker stop xrdp
docker rm xrdp

# SYS_ADMIN : chrome 使用時に必要
# DAC_READ_SEARCH : smbmount 使用時に必要

docker run -it -d \
    --cap-add SYS_ADMIN \
    --cap-add DAC_READ_SEARCH \
    --security-opt apparmor:unconfined \
    --name xrdp \
    --restart=always \
    -u $(id -u):$(id -g) \
    -e USER=user1 \
    -e PASSWD=hoge \
    -v /dev/shm:/dev/shm \
    -p 3389:3389 \
  tukiyo3/xrdp:custom

#   --shm-size=1g \
