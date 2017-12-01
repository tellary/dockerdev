set -e
set -x

git clone https://github.com/spring-guides/gs-spring-boot.git
cd gs-spring-boot/initial
gradle build
cd
rm -r gs-spring-boot

gradle --stop
