#!/bin/bash

BASE_DIR=$HOME
DOCKER_OPTS="-it \
       -v $BASE_DIR/safeplace:/home/ilya/safeplace \
       -v $BASE_DIR/shared:/home/ilya/shared \
       -v $BASE_DIR/Downloads:/home/ilya/Downloads \
       -v $BASE_DIR/Desktop:/home/ilya/Desktop \
       -v $BASE_DIR/.ssh:/home/ilya/.ssh \
       -e DISPLAY=host.docker.internal:0 \
       -p 127.0.0.1:5901:5901 \
       --security-opt seccomp:unconfined"
