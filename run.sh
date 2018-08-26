. config.sh
. common-run.sh

docker run -it $DOCKER_OPTS \
       -v $BASE_DIR/work:/home/ilya/work \
       -v dot-gradle:/home/ilya/.gradle \
       -u ilya \
       $@ \
       $WORK_IMAGE
