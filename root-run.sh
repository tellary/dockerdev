docker run -it \
       -v /Users/ilya/safeplace:/home/ilya/safeplace \
       -v /Users/ilya/shared:/home/ilya/shared \
       -v /Users/ilya/Downloads:/home/ilya/Downloads \       
       -e DISPLAY=123.123.123.123:0 \
       work
