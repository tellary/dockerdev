docker images | egrep 'work ' && \
    docker tag work work.$(date +%Y%m%d_%H%M%S)
   
docker build -t work .
