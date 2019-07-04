. config.sh
. common-run.sh

docker run -it $DOCKER_OPTS \
       -v $BASE_DIR/work:/home/ilya/work \
       -v dot-gradle:/home/ilya/.gradle \
       -v $BASE_DIR/.aws:/home/ilya/.aws \
       -u ilya \
       $@ \
       $WORK_IMAGE
