. config.sh
. common-run.sh
. user-run.sh

docker run $DOCKER_OPTS \
       $@ \
       $WORK_IMAGE
