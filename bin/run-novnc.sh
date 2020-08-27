docker run \
 --rm \
 -d \
 -p 3389:3389 \
 -p 127.0.0.1:6080:6080 \
 --cap-add SYS_ADMIN \
 -v /dev/shm:/dev/shm \
 tukiyo3/xrdp:novnc
