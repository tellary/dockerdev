docker tag work prev_work &&
docker build -t work -f Dockerfile.upgrade . &&
docker tag work prev_work &&
docker rmi prev_work
