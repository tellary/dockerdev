docker ps -aqf "status=exited" | xargs -n 1 docker rm
