#!/bin/sh

[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap stop INT
trap stop TERM

# Copy over default config files
[ ! -f /atlas/config/atlasmanager.cfg ] && cp /atlas/staging/atlasmanager.cfg /atlas/config/atlasmanager.cfg
[ ! "$(ls -A /etc/atlasmanager/instances)" ] && cp -Ra /atlas/staging/instances /etc/atlasmanager

# TODO: Start server here

# TODO: Ensure cron is running

echo "[hit enter key to exit] or run 'docker stop <container>'"
read < /tmp/FIFO &
wait

# stop service and clean up here
echo "Stopping Atlas"

# TODO: Stop server here

echo "exited $0"
