xhost + 123.123.123.123
docker run -it \
       -v ~/safeplace:/home/ilya/safeplace \
       -v ~/work:/home/ilya/work \
       -v ~/shared:/home/ilya/shared \
       -v ~/Downloads:/home/ilya/Downloads \
       -v ~/.gradle:/home/ilya/.gradle \
       -v ~/.ssh:/home/ilya/.ssh \
       -u ilya \
       -e DISPLAY=123.123.123.123:0 \
       --rm \
       $@ \
       work
