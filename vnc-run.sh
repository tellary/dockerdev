. config.sh
. common-run.sh
. user-run.sh

DOCKER_OPTS="$DOCKER_OPTS -p 127.0.0.1:5901:5901"

docker run $DOCKER_OPTS \
       $@ \
       $WORK_IMAGE
