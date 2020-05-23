#!/bin/bash

DOCKER_OPTS="$DOCKER_OPTS \
       -v $BASE_DIR/work:/home/ilya/work \
       -v dot-gradle:/home/ilya/.gradle \
       -v $BASE_DIR/.aws:/home/ilya/.aws \
       -v nix:/nix
       -u ilya"
