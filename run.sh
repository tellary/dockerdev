docker run -it \
       -v /Users/ilya/safeplace:/home/ilya/safeplace \
       -v /Users/ilya/shared:/home/ilya/shared \
       -u ilya \
       work $1
