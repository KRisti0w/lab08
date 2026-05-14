FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -yy gcc g++ cmake git
COPY . print/
WORKDIR print
RUN cmake -H. -B_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install -DBUILD_TESTS=OFF -DBUILD_DEMO=ON
RUN cmake --build _build
RUN cmake --build _build --target install
RUN ls -la _install/bin/
ENV LOG_PATH /home/logs/log.txt

VOLUME /home/logs

WORKDIR _install/bin
CMD ["./demo", "./print_demo", "./example1", "./example2"] || /bin/bash
