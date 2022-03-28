FROM ubuntu:focal-20220316

ARG SOULSEEK_VERSION=2018-1-30
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
 apt-get install -y binutils ca-certificates curl openbox supervisor tigervnc-common tigervnc-standalone-server fonts-noto-cjk --no-install-recommends && \
 mkdir /usr/share/novnc && \
 curl -fL# https://github.com/novnc/noVNC/archive/master.tar.gz -o /tmp/novnc.tar.gz && \
 tar -xf /tmp/novnc.tar.gz --strip-components=1 -C /usr/share/novnc && \
 mkdir /usr/share/novnc/utils/websockify && \
 curl -fL# https://github.com/novnc/websockify/archive/master.tar.gz -o /tmp/websockify.tar.gz && \
 tar -xf /tmp/websockify.tar.gz --strip-components=1 -C /usr/share/novnc/utils/websockify && \
 ln -s /app/soulseek.png /usr/share/novnc/app/images/soulseek.png && \
 curl -fL# https://www.slsknet.org/SoulseekQt/Linux/SoulseekQt-$SOULSEEK_VERSION-64bit-appimage.tgz -o /tmp/soulseek.tgz && \
 tar -xvzf /tmp/soulseek.tgz -C /tmp && \
 /tmp/SoulseekQt-$SOULSEEK_VERSION-64bit.AppImage --appimage-extract && \
 mv /squashfs-root /app && \
 strip /app/SoulseekQt && \
 useradd -u 1000 -U -d /data -s /bin/false soulseek && \
 usermod -G users soulseek && \
 mkdir /data && \
 mkdir /data/.vnc && echo "openbox-session" > /data/.vnc/xstartup && chmod +x /data/.vnc/xstartup && \
 echo "soulseek:soulseek" | chpasswd && echo "soulseek" | /usr/bin/vncpasswd -f > /data/.vnc/passwd && chmod 600 /data/.vnc/passwd && \
 chown -R soulseek:soulseek /data/.vnc && \
 apt-get purge -y binutils curl && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    XDG_RUNTIME_DIR=/data

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]