#!/usr/bin/env bash

# Regenerate SSH host keys
if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
  dpkg-reconfigure openssh-server
fi

mkdir -p custom/conf data log
# Dump dist configuration
touch custom/conf/app.ini

# Make sure files belong to the right user
chown -R git custom data log
# Recursively going through a bunch of repostories each restart would be too expensive
chown -R git ~git

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
