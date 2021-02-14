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
 -e GITHUB_USER=tukiyo \
 -e USER=${USER} \
 -e PASSWD='[${USER}@$(date "+%Y%m")]' \
 -v /dev/shm:/dev/shm \
 -p 13389:3389 \
 -p 10022:22 \
 tukiyo3/xrdp-$(uname -m):latest
EOF
}

_add_authorized_keys() {
	USER="${1}"
	GITHUB_USER="${2}"
	if [ "${GITHUB_USER}" = "" ];then
		return
	fi
	if [ -e /home/${USER}/.ssh ];then
		echo "[skip] /home/${USER}/.ssh already exists."
		return
	fi
	mkdir -p /home/${USER}/.ssh
	/usr/bin/curl -o /home/${USER}/.ssh/authorized_keys "https://github.com/${GITHUB_USER}.keys"
	chmod 400 /home/${USER}/.ssh/authorized_keys
	chown ${USER} /home/${USER}/.ssh/authorized_keys
	echo "    ssh ${USER}@localhost -p 10022"
}
_lenB() {
	echo -n $1 | wc -c
}
_mkpasswd() {
	# 記号混じりのパスワード生成 (紛らわしい文字は除外)
	#echo -n $(openssl rand -base64 4 | tr '1iI0O' '@*#$=')
	echo -n ${USER}@$(date "+%Y");
}

# docker run 時の -u の値を取得
USER_ID=$(id -u)
GROUP_ID=$(id -g)
# アカウント環境変数 START
if [ "$USER_ID" = "" -o "$USER_ID" = "0" ];then
	USER_ID=1000
fi
if [ "$GROUP_ID" = "" -o "$GROUP_ID" = "0" ];then
	GROUP_ID=1000
fi
if [ "$USER" = "root" -o "$USER" = "" ];then
	USER="focal"
fi
if [ "$GROUP" = "root" -o "$GROUP" = "" ];then
	GROUP="$USER"
fi
if [ "$PASSWD" = "" ];then
	# パスワードが8文字未満の場合は自動生成のものを使用する
	PASSWD=$(_mkpasswd)
fi
# アカウント環境変数 END

# Add group
if [ ! $(getent group $GROUP) ]; then
    groupadd -g $GROUP_ID $GROUP
fi

# Add user
if [ ! $(getent passwd $USER) ]; then
    export HOME=/home/$USER
    # sudoグループにも追加
    useradd -d ${HOME} -m -s /bin/bash -u $USER_ID -g $GROUP_ID -G sudo $USER
fi

# Revert permissions
sudo chmod u-s /usr/sbin/useradd /usr/sbin/groupadd

if [ $# -eq 0 ]; then
    # Set login user name

    # Set login password
    echo ${USER}:${PASSWD} | sudo chpasswd

    # retrive .ssh/authorized_keys from Github
    _add_authorized_keys "$USER" "$GITHUB_USER"

    if [ ! -e ${HOME}/.xsession ]; then
        cp /etc/skel/.xsession ${HOME}/.xsession
    fi
    if [ ! -e /etc/xrdp/rsakeys.ini ]; then
        sudo -u xrdp -g xrdp xrdp-keygen xrdp /etc/xrdp/rsakeys.ini > /dev/null 2>&1
    fi

    # supervisord の起動
    set -- /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

    if [ ! -e /usr/local/bin/_gosu ]; then
        sudo install -g $GROUP_ID -m 4750 $(which gosu) /usr/local/bin/_gosu
        set -- /usr/local/bin/_gosu root "$@"
    fi

    # 起動方法を表示
    echo "[ usage ] "
    echo "    ${USER}:${GROUP}=${USER_ID}:${GROUP_ID} pass: ${PASSWD}"
    echo "    rdesktop -u${USER} -p'${PASSWD}' -g 1024x768 localhost"
    echo "    "$(_usage)
fi
unset PASSWD

# chromeの起動に必要
sudo chmod 1777 /dev/shm

echo "------------------------------------------------------------"
exec "$@"
