[![CI](https://github.com/KRisti0w/lab07/actions/workflows/ci.yml/badge.svg)](https://github.com/KRisti0w/lab07/actions/workflows/ci.yml)
## Отчёт к lab06
В рамках выполнения данной лабораторной работы мною были выполнены команды из tutorial с некоторыми изменениями:
1) Скопирован репозиторий из lab05.
2) Изменён CMakeLists.txt:
```bash
$ git diff
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 5bdfc64..f29080c 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1,5 +1,11 @@
 cmake_minimum_required(VERSION 3.10)
 project(print)
+set(PRINT_VERSION_MAJOR 0)
+set(PRINT_VERSION_MINOR 1)
+set(PRINT_VERSION_PATCH 0)
+set(PRINT_VERSION_TWEAK 0)
+set(PRINT_VERSION ${PRINT_VERSION_MAJOR}.${PRINT_VERSION_MINOR}.${PRINT_VERSION_PATCH}.${PRINT_VERSION_TWEAK})
+set(PRINT_VERSION_STRING "v${PRINT_VERSION}")
 set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error")

 set(CMAKE_CXX_STANDARD 11)

```
3) Добавлены файлы DESCRIPTION и ChangeLog.md
```bash
$ cat DESCRIPTION
Static C++ library for printing

$ cat > ChangeLog.md <<EOF
> * $(LANG=en_US date +'%a %b %d %Y') ${GITHUB_USERNAME} <${GITHUB_EMAIL}> 0.1.0.0
- Initial RPM release
> EOF
```
4) Написан конфигурационный файл для CPack CPackConfig.cmake:
```cmake
include(InstallRequiredSystemLibraries)
set(CPACK_PACKAGE_CONTACT danila.obidovskiy@gmail.com)
set(CPACK_PACKAGE_VERSION_MAJOR ${PRINT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PRINT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PRINT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION_TWEAK ${PRINT_VERSION_TWEAK})
set(CPACK_PACKAGE_VERSION ${PRINT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/DESCRIPTION)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "static C++ library for printing")

set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_SOURCE_DIR}/README.md)

set(CPACK_RPM_PACKAGE_NAME "print-devel")
set(CPACK_RPM_PACKAGE_LICENSE "MIT")
set(CPACK_RPM_PACKAGE_GROUP "print")
set(CPACK_RPM_CHANGELOG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ChangeLog.md)
set(CPACK_RPM_PACKAGE_RELEASE 1)

set(CPACK_DEBIAN_PACKAGE_NAME "libprint-dev")
set(CPACK_DEBIAN_PACKAGE_PREDEPENDS "cmake >= 3.0")
set(CPACK_DEBIAN_PACKAGE_RELEASE 1)

include(CPack)
```
5) Запушены все изменения и тег:
```bash
Username for 'https://github.com': KRisti0w
Password for 'https://KRisti0w@github.com':
Перечисление объектов: 77, готово.
Подсчет объектов: 100% (77/77), готово.
При сжатии изменений используется до 2 потоков
Сжатие объектов: 100% (42/42), готово.
Запись объектов: 100% (77/77), 19.55 КиБ | 3.91 МиБ/с, готово.
Total 77 (delta 25), reused 67 (delta 22), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (25/25), done.
To https://github.com/KRisti0w/lab06.git
 * [new branch]      main -> main
 * [new tag]         v0.1.0.0 -> v0.1.0.0
```

6) Произведена ручная сборка (2мя способами)

Первый способ:
```bash
$ cmake -H. -B_build
-- The C compiler identification is GNU 14.2.0
-- The CXX compiler identification is GNU 14.2.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Examples will be built in /home/kristina/KRisti0w/workspace/projects/lab06/_build
-- Configuring done (3.2s)
-- Generating done (0.0s)
-- Build files have been written to: /home/kristina/KRisti0w/workspace/projects/lab06/_build

$ cmake --build _build
[ 16%] Building CXX object CMakeFiles/print.dir/sources/print.cpp.o
[ 33%] Linking CXX static library libprint.a
[ 33%] Built target print
[ 50%] Building CXX object CMakeFiles/example1.dir/examples/example1.cpp.o
[ 66%] Linking CXX executable example1
[ 66%] Built target example1
[ 83%] Building CXX object CMakeFiles/example2.dir/examples/example2.cpp.o
[100%] Linking CXX executable example2
[100%] Built target example2

$ cd _build
$ cpack -G "TGZ"
CPack: Create package using TGZ
CPack: Install projects
CPack: - Run preinstall target for: print
CPack: - Install project: print []
CPack: Create package
CPack: - package: /home/kristina/KRisti0w/workspace/projects/lab06/_build/print-0.1.0.0-Linux.tar.gz generated.
```

В результате выполнения сгенерирован архив print-0.1.0.0-Linux.tar.gz

7) Этот архив помещен в локальную директорию artifacts:
```bash
$ mkdir artifacts
$ mv _build/*.tar.gz artifacts
$ tree artifacts
artifacts
└── print-0.1.0.0-Linux.tar.gz

1 directory, 1 file
```
