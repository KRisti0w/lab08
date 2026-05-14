FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -yy gcc g++ cmake git

COPY . print/
WORKDIR print
RUN if [ ! -f demo/main.cpp ]; then \
      mkdir -p demo && \
      echo '#include <iostream>' > demo/main.cpp && \
      echo '#include <fstream>' >> demo/main.cpp && \
      echo 'int main() { std::string s; while(std::cin >> s) std::cout << s << std::endl; return 0; }' >> demo/main.cpp; \
    fi

RUN cmake -H. -B_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install -DBUILD_TESTS=OFF -DBUILD_DEMO=ON -DBUILD_EXAMPLES=ON
RUN cmake --build _build
RUN cmake --build _build --target install
RUN cd _install/bin && \
    if [ -f print_demo ]; then ln -s print_demo demo; fi && \
    if [ -f example1 ]; then ln -s example1 demo; fi && \
    ls -la

ENV LOG_PATH /home/logs/log.txt

VOLUME /home/logs

WORKDIR _install/bin

ENTRYPOINT ["./demo"]
