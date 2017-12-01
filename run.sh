xhost + 123.123.123.123
docker run -it \
       -v /Users/ilya/safeplace:/home/ilya/safeplace \
       -v /Users/ilya/shared:/home/ilya/shared \
       -v /Users/ilya/Downloads:/home/ilya/Downloads \
       -u ilya \
       -e DISPLAY=123.123.123.123:0 \
       --rm \
       $@ \
       work
