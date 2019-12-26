#!/bin/bash

BASE_DIR=$HOME
DOCKER_OPTS="-it \
       -v $BASE_DIR/safeplace:/home/ilya/safeplace \
       -v $BASE_DIR/shared:/home/ilya/shared \
       -v $BASE_DIR/Downloads:/home/ilya/Downloads \
       -v $BASE_DIR/Desktop:/home/ilya/Desktop \
       -v $BASE_DIR/.ssh:/home/ilya/.ssh \
       -v /Volumes/MacExtraDrive:/mnt/extra-drive \
       -e DISPLAY=host.docker.internal:0 \
       --security-opt seccomp:unconfined"
