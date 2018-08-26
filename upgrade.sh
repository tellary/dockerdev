. config.sh

docker tag $WORK_IMAGE prev_work &&
docker build -t $WORK_IMAGE -f Dockerfile.upgrade . &&
docker rmi prev_work
