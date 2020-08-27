#!/bin/sh
set -e

_usage() {
	cat << EOF
docker run -it -d \
 --cap-add SYS_ADMIN \
 --cap-add DAC_READ_SEARCH \
 --security-opt apparmor:unconfined \
 --name xrdp \
 --restart=always \
 -u 1000:1000 \
 -e USER=developer \
 -e PASSWD='$(_mkpasswd)' \
 -v /dev/shm:/dev/shm \
 -p 3389:3389 \
 tukiyo3/xrdp:chrome
EOF
}

_lenB() {
	echo -n $1 | wc -c
}
_mkpasswd() {
	# 記号混じりのパスワード生成 (紛らわしい文字は除外)
	echo -n $(openssl rand -base64 8 | tr '1iI0O' '@*#$=')
}

# アカウント環境変数 START
if [ "$USER_ID" = "" -o "$USER_ID" = "0" ];then
	USER_ID=1000
fi
if [ "$GROUP_ID" = "" -o "$GROUP_ID" = "0" ];then
	GROUP_ID=1000
fi
if [ "$USER" = "root" -o "$USER" = "" ];then
	USER="developer"
fi
if [ "$GROUP" = "root" -o "$GROUP" = "" ];then
	GROUP="$USER"
fi
if [ "$PASSWD" = "" -o $(_lenB "$PASSWD") -lt 8 ];then
	# パスワードが8文字未満の場合は自動生成のものを使用する
	PASSWD=$(_mkpasswd)
fi
# アカウント環境変数 END

# 接続方法の表示
echo "rdesktop -u${USER} -p'${PASSWD}' -g 1024x768 localhost"


echo "------------------------------------------------------------"

# Add group
echo -n "GROUP_ID: $GROUP_ID "
if [ ! $(getent group $GROUP) ]; then
    groupadd -g $GROUP_ID $GROUP
fi

# Add user
echo -n "USER_ID: $USER_ID "
if [ ! $(getent passwd $USER) ]; then
    export HOME=/home/$USER
    # sudoグループにも追加
    useradd -d ${HOME} -m -s /bin/bash -u $USER_ID -g $GROUP_ID -G sudo,audio $USER
fi

# Revert permissions
sudo chmod u-s /usr/sbin/useradd /usr/sbin/groupadd

# 指定が何もなかった場合
if [ $# -eq 0 ]; then
    # Set login user name
    echo -n "USER: $USER "

    # Set login password
    echo "PASSWD: $PASSWD"
    echo ${USER}:${PASSWD} | sudo chpasswd

    if [ ! -e ${HOME}/.xsession ]; then
        cp /etc/skel/.xsession ${HOME}/.xsession
    fi
    if [ ! -e /etc/xrdp/rsakeys.ini ]; then
        sudo -u xrdp -g xrdp xrdp-keygen xrdp /etc/xrdp/rsakeys.ini > /dev/null 2>&1
    fi

    set -- /usr/bin/supervisord -c /etc/supervisor/xrdp.conf
    if [ $USER_ID != "0" ]; then
        if [ ! -e /usr/local/bin/_gosu ]; then
            sudo install -g $GROUP_ID -m 4750 $(which gosu) /usr/local/bin/_gosu
            set -- /usr/local/bin/_gosu root "$@"
        fi
    fi

    # 起動方法を表示
    echo
    echo "[ usage ] "
    echo $(_usage)
    echo
    echo "docker logs xrdp | head -n 9"
fi
unset PASSWD

# fix: google-chrome
sudo chmod 1777 /dev/shm

# pulseaudio
/usr/bin/pulseaudio --start --log-target=syslog

echo "------------------------------------------------------------"
exec "$@"
