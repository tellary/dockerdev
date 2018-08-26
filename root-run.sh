. config.sh
. common-run.sh

docker run -it $DOCKER_OPTS \
       --rm \
       $@ \
       $WORK_IMAGE
