# Gogs for Docker

(c) 2015 Jens Erat <email@jenserat.de>

Redistribution and modifications are welcome, see the LICENSE file for details.

[Gogs](http://www.gogs.io/) is a a self-hosted Git service written in Go.

This Dockerfile provides a Gogs image.

## Setup

Data is stored in several locations, which are also defined as volumes:

- `/opt/gogs/data`:   various uploaded files (avaters, attachments, ...)
- `/opt/gogs/custom`: custom configuration
- `/srv` (`git` user homedirectory): repositories, authorized keys
- `/etc/ssh`:         sshd configuration and host keys

Two ports are exposed, `22` for SSH and `3000` for HTTP. Both can be redirected when publishing them, edit the configuration file appropriately to adjust URIs.

### Configuration

When Gogs is started first, the installation wizard prefills the most important configuration options and generates the database. For further configuration, edit `/opt/gogs/custom/config.ini`. Refer to the [official Gogs documentation](http://gogs.io/docs/advanced/configuration_cheat_sheet.html) for details.

### Database

Gogs supports different database systems, PostgreSQL, MySQL/Maria DB and SQLite. The image brings all required database drivers.

Gogs performs all database maintenance on its own, no manual interaction should be required for ugprades.

## Running a Container

The most basic run command would be:

    docker run -d \
    	--name gogs \
    	--restart always \
    	--publish 22:22 \
    	--publish 3000:3000 \
    	--link gogs-postgresql:db \
    	--volume /srv/gogs/data:/opt/gogs/data \
    	--volume /srv/gogs/ssh:/etc/ssh \
    	--volume /srv/gogs/custom:/opt/gogs/custom \
    	--volume /srv/gogs/home:/srv \
    	jenserat/gogs

You will very likely be required to use another SSH port (or host ip address) and want to change the HTTP port (or link a web proxy server).

## Upgrading and Maintenance

Gogs will automatically upgrade the database. For other maintenance tasks during upgrades, refer to the [Gogs documentation](http://gogs.io/docs/intro/).

To enter the container and perform maintenance, use (given you named the container `gogs`):

    docker exec -ti gogs /bin/bash
