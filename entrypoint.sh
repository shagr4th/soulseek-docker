#!/bin/sh
set -e
[ -f /tmp/.X1-lock ] && rm /tmp/.X1-lock
[ -e /tmp/.X11-unix/X1 ] && rm /tmp/.X11-unix/X1
PGID=${PGID:-0}
PUID=${PUID:-0}
[ "$PGID" != 0 ] && [ "$PUID" != 0 ] && \
 groupmod -o -g "$PGID" soulseek && \
 usermod -o -u "$PUID" soulseek && \
 chown -R soulseek:soulseek /app && \
 chown soulseek:soulseek /data/.* && \
 chown soulseek:soulseek /data/*

echo '<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
<desktops>
  <number>1</number>
  <popupTime>0</popupTime>
</desktops>
<applications>
  <application type="normal">
    <fullscreen>yes</fullscreen>
  </application>
</applications>
</openbox_config>' > /etc/xdg/openbox/rc.xml

echo "<!doctype html>
<html lang='en'>
 <head>
  <title>soulseek-docker</title>
  <link rel='icon' href='app/images/soulseek.png'>
  <style>
   html, body, iframe { margin:0; padding: 0; height: 100%; width: 100%; border:0; overflow:hidden }
  </style>
 </head>
 <script>
    var addIframeStyle = function(iframedocument, styles) {
        var css = iframedocument.createElement('style');
        css.type = 'text/css';
        css.appendChild(iframedocument.createTextNode(styles));
        iframedocument.getElementsByTagName('head')[0].appendChild(css);
    }
</script>
 <body>
  <iframe src='vnc.html?autoconnect=true&resize=remote' onload=\"addIframeStyle(this.contentDocument, 'canvas { cursor: inherit !important; }')\"> <!-- Bug curseur avec Firefox -->
  </iframe>
 </body>
</html>" > /usr/share/novnc/index.html

USERNAME=$(getent passwd "$PUID" | cut -d: -f1) && echo "[supervisord]
nodaemon=true
pidfile = /tmp/supervisord.pid
logfile=/dev/fd/1
logfile_maxbytes=0
directory = /tmp

[program:Xvnc]
priority = 100
command = /usr/bin/vncserver :1 -SecurityTypes None -geometry ${RESOLUTION:-1920x1080} -fg
user = $USERNAME
environment = HOME=/data,USER=$USERNAME,LANG=en_US.UTF-8
autorestart=true
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901
autorestart=true
priority=400
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true

[program:soulseek]
user=$USERNAME
environment=HOME=/data,DISPLAY=:1,USER=$USERNAME,QT_SCALE_FACTOR=${QT_SCALE_FACTOR:-1}
command=/app/SoulseekQt
autorestart=true
priority=500
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true" > /etc/supervisord.conf

exec "$@"