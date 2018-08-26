. config.sh

docker images | egrep "$WORK_IMAGE " && \
    docker tag $WORK_IMAGE $WORK_IMAGE.$(date +%Y%m%d_%H%M%S)

docker build --pull -t $WORK_IMAGE .
