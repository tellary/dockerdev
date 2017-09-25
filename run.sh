xhost + 123.123.123.123
docker run -it \
       -v /Users/ilya/safeplace:/home/ilya/safeplace \
       -v /Users/ilya/shared:/home/ilya/shared \
       -u ilya \
       -e DISPLAY=123.123.123.123:0 \
       work
