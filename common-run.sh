#!/bin/bash

BASE_DIR=$HOME
xhost + 123.123.123.123
DOCKER_OPTS="-it \
       -v $BASE_DIR/safeplace:/home/ilya/safeplace \
       -v $BASE_DIR/shared:/home/ilya/shared \
       -v $BASE_DIR/Downloads:/home/ilya/Downloads \
       -v $BASE_DIR/Desktop:/home/ilya/Desktop \
       -v $BASE_DIR/.ssh:/home/ilya/.ssh \
       -e DISPLAY=123.123.123.123:0"
