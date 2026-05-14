[![CI](https://github.com/KRisti0w/lab08/actions/workflows/ci.yml/badge.svg)](https://github.com/KRisti0w/lab08/actions/workflows/ci.yml)
## Отчёт к lab08
В рамках выполнения данной лабораторной работы мною были выполнены команды из tutorial с некоторыми изменениями:
1) Скопирован репозиторий из lab07.
2) Написан Dockerfile:
```dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -yy gcc g++ cmake git

COPY . print/
WORKDIR print
> RUN if [ ! -f demo/main.cpp ]; then \
      mkdir -p demo && \
      echo '#include <iostream>' > demo/main.cpp && \
      echo '#include <fstream>' >> demo/main.cpp && \
      echo 'int main() { std::string s; while(std::cin >> s) std::cout << s << std::endl; return 0; }' >> demo/main.cpp; \
    fi
> RUN cmake -H. -B_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install -DBUILD_TESTS=OFF -DBUILD_DEMO=ON -DBUILD_EXAMPLES=ON
RUN cmake --build _build
RUN cmake --build _build --target install
> RUN cd _install/bin && \
    if [ -f print_demo ]; then ln -s print_demo demo; fi && \
    if [ -f example1 ]; then ln -s example1 demo; fi && \
    ls -la

ENV LOG_PATH /home/logs/log.txt

VOLUME /home/logs

WORKDIR _install/bin

ENTRYPOINT ["./demo"]
```


3) Произведена сборка Docker-образа
```bash
 sudo docker build --no-cache -t logger .
[+] Building 51.3s (15/15) FINISHED                                                                      docker:default
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 933B                                                                               0.0s
 => [internal] load metadata for docker.io/library/ubuntu:20.04                                                    1.5s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [ 1/10] FROM docker.io/library/ubuntu:20.04@sha256:8feb4d8ca5354def3d8fce243717141ce31e2c428701f6682bd2fafe15  0.0s
 => [internal] load build context                                                                                  0.1s
 => => transferring context: 120.94kB                                                                              0.1s
 => CACHED [ 2/10] RUN apt update && apt install -yy gcc g++ cmake git                                             0.0s
 => [ 3/10] COPY . print/                                                                                          0.4s
 => [ 4/10] WORKDIR print                                                                                          0.2s
 => [ 5/10] RUN if [ ! -f demo/main.cpp ]; then       mkdir -p demo &&       echo '#include <iostream>' > demo/ma  0.8s
 => [ 6/10] RUN cmake -H. -B_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install -DBUILD_TESTS=OFF   12.8s
 => [ 7/10] RUN cmake --build _build                                                                              31.5s
 => [ 8/10] RUN cmake --build _build --target install                                                              1.7s
 => [ 9/10] RUN cd _install/bin &&     if [ -f print_demo ]; then ln -s print_demo demo; fi &&     if [ -f exampl  0.9s
 => [10/10] WORKDIR _install/bin                                                                                   0.2s
 => exporting to image                                                                                             0.7s
 => => exporting layers                                                                                            0.6s
 => => writing image sha256:9b09c8610504a0072bba87094cd12f66c7ce3af7ecb10abe3824ddc587b79af0                       0.0s
 => => naming to docker.io/library/logger
```
Результат сборки:
```bash
$ sudo docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
logger       latest    9b09c8610504   12 minutes ago   530MB
<none>       <none>    947b462dda87   22 minutes ago   530MB
```
4) Запущен контейнер
```bash
$ docker run -it -v "$(pwd)/logs/:/home/logs/" logger
text1
text2
text3
```
Результат:
```bash
$ sudo docker inspect logger
[
    {
        "Id": "sha256:947b462dda8708679814851e7b97f53207c9e838492d59656b5742992e0e1805",
        "RepoTags": [
            "logger:latest"
        ],
        "RepoDigests": [],
        "Parent": "",
        "Comment": "buildkit.dockerfile.v0",
        "Created": "2026-05-14T09:24:07.905004513+03:00",
        "DockerVersion": "",
        "Author": "",
        "Config": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "DEBIAN_FRONTEND=noninteractive",
                "LOG_PATH=/home/logs/log.txt"
            ],
            "Cmd": [
                "./demo",
                "./print_demo",
                "./example1",
                "./example2"
            ],
            "ArgsEscaped": true,
            "Image": "",
            "Volumes": {
                "/home/logs": {}
            },
            "WorkingDir": "/print/_install/bin",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.opencontainers.image.ref.name": "ubuntu",
                "org.opencontainers.image.version": "20.04"
            }
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 529801379,
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/az92orgs278rt0mu1va5nddya/diff:/var/lib/docker/overlay2/j0ta90mgb460dliim2vnm1f4y/diff:/var/lib/docker/overlay2/lflghbbon6krd1p2q4iy53nj7/diff:/var/lib/docker/overlay2/wjylvy4mq2mr07iidhdq1udu4/diff:/var/lib/docker/overlay2/sfd60g0mf73mz7wbkqmbnynao/diff:/var/lib/docker/overlay2/eex0ey7ok7f85zg0mkgaofy58/diff:/var/lib/docker/overlay2/lzsf99ej2ye3n0zoro2h2kxz2/diff:/var/lib/docker/overlay2/80f46ad31334c679742f6acb2a4dd8d8f08936900b2906a208cc51294b01bd9b/diff",
                "MergedDir": "/var/lib/docker/overlay2/qnd78ckvv2vylpcf7ycoimeu5/merged",
                "UpperDir": "/var/lib/docker/overlay2/qnd78ckvv2vylpcf7ycoimeu5/diff",
                "WorkDir": "/var/lib/docker/overlay2/qnd78ckvv2vylpcf7ycoimeu5/work"
            },
            "Name": "overlay2"
        },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:470b66ea5123c93b0d5606e4213bf9e47d3d426b640d32472e4ac213186c4bb6",
                "sha256:4fe49cc1e7cc74508e3cba02f5498eb0254af0a5fd71cd4fde5dfb276929598c",
                "sha256:272d035a48d560af53a2f2dcb95cda07804bc60dd8db7419bd5e755394e6b19c",
                "sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef",
                "sha256:ea223464a3aad4c1111e74b213c3455f329ee88f7a5c5de7af0958b58c976948",
                "sha256:c25e1e1244224f7d3dc856261068d18de8b0fd55fc3d2dafabcf41e38a5aad32",
                "sha256:622a620a89ef320287d482026ce553503fa8570a0ba1a672f8f0c86fd2e5327a",
                "sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef",
                "sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef"
            ]
        },
        "Metadata": {
            "LastTagTime": "2026-05-14T09:24:08.078446802+03:00"
        }
    }
]
```
```bash
$ cat logs/log.txt
text1
text2
text3
```
5) В ci.yml добавлена часть кода про docker
```cmake
...

 docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t logger .
```

6) Изменения в ci.yml и Dockerfile запушены в репозиторий
