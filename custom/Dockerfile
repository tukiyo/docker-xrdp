FROM tukiyo3/xrdp:chrome

MAINTAINER tukiyo3 <tukiyo3@gmail.com>

# 必要そうなもの
RUN pkgadd.sh \
      # メッセージの日本語表記対応
      language-pack-ja \
      # 日本語の絵文字対応
      fonts-noto-cjk fonts-noto-color-emoji

# 必須ではないが、当起動スクリプトに組み込んだもの
RUN pkgadd.sh \
      # logrotate用
      cron logrotate \
      # ssh接続可
      openssh-server openssh-client 

# 以下は自由に変更可能
RUN pkgadd.sh \
      # リモート接続用
      remmina \
      # audio
      pulseaudio \
      # cifsの利用には --cap-add DAC_READ_SEARCH と --security-opt apparmor:unconfined オプションが必要
      cifs-utils \
      # その他
      autossh \
      expect \
      gnutls-bin \
      mailutils mutt \
      nkf \
      pinta \
      ranger \
      rdesktop \
      rsync \
      screen \
      sshfs \
      tig \
      vim-gtk \
      w3m \
      xfce4-screenshooter \
      xtightvncviewer \
      xvfb

RUN \
    # sshdは鍵認証を必須に
    sed -i -e "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Set supervisord conf for xrdp service
RUN { \
      # cron (logrotate用など)
      echo "[program:cron]"; \
      echo "command=/usr/sbin/cron -f"; \
      # sshd
      echo "[program:sshd]"; \
      echo "command=/usr/sbin/sshd -D"; \
    } >> /etc/supervisor/xrdp.conf
