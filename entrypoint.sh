#!/bin/sh

# USE the trap if you need to also do manual cleanup after the service is stopped,
#     or need to start multiple services in the one container
trap "echo TRAPed signal" HUP INT QUIT TERM

# TODO: Start server here

# TODO: Ensure cron is running

echo "[hit enter key to exit] or run 'docker stop <container>'"
read

# stop service and clean up here
echo "Stopping Atlas"

# TODO: Stop server here

echo "exited $0"
