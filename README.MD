## Soulseek docker

Inspired by https://github.com/realies/soulseek-docker

### Build

docker-compose.yml sample:

```
version: '2.3'
services:
  soulseek:
    image: soulseek
    build:
      context: .
    container_name: soulseek
    restart: always
    volumes:
      - "./Downloads:/data/Soulseek Downloads"
      - "~/.soulseek/data:/data/.SoulseekQt"
      - "~/.soulseek/logs:/data/Soulseek Chat Logs"
      - /etc/localtime:/etc/localtime:ro
      - /etc/machine-id:/etc/machine-id:ro
    environment:
      - PUID=${UID}
      - PGID=${GID}
```

UID come from `$(id -u)`, GID come from `$(id -g)`

### Hidpi

To set HiDpi (for instance, 4k with double pixel density), just add following environment variables:

```
- QT_SCALE_FACTOR=2
- RESOLUTION=3840x2160
```

And reduce zoom of the browser window to 50% (see https://github.com/novnc/noVNC/issues/768 )