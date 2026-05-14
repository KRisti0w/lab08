[![CI](https://github.com/KRisti0w/lab08/actions/workflows/ci.yml/badge.svg)](https://github.com/KRisti0w/lab08/actions/workflows/ci.yml)
## Отчёт к lab08
В рамках выполнения данной лабораторной работы мною были выполнены команды из tutorial с заменой устаревшего hunter на FetchContent:
1) Скопирован репозиторий из lab06.
2) В соответствие с tutorial были установлен hunter и изменён CMakeLists.txt, но в процессе сборки произошла ошибка, связанная с версией компилятора
```bash
------------------------------ ERROR ------------------------------
    https://hunter.readthedocs.io/en/latest/reference/errors/error.internal.html
-------------------------------------------------------------------

CMake Error at cmake/HunterGate.cmake:88 (message):
Call Stack (most recent call first):
  cmake/HunterGate.cmake:98 (hunter_gate_error_page)
  cmake/HunterGate.cmake:347 (hunter_gate_internal_error)
  cmake/HunterGate.cmake:511 (hunter_gate_download)
  CMakeLists.txt:3 (HunterGate)


-- Configuring incomplete, errors occurred!
```
Мною было принято решение не мучиться с адаптацией устаревшего hunter, а попробовать подключить более современный FetchContent

3) Для этого в CMakeLists.txt были внесены следующие изменения:
```bash
$ git diff
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 57997ae..1ce0b56 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -4,6 +4,7 @@ set(CMAKE_CXX_STANDARD 11)
 set(CMAKE_CXX_STANDARD_REQUIRED ON)

 option(BUILD_EXAMPLES "Build examples" OFF)
+option(BUILD_TESTS "Build tests" ON)

 project(print)
 set(PRINT_VERSION_MAJOR 0)
@@ -33,12 +34,19 @@ if(BUILD_EXAMPLES)
   endforeach(EXAMPLE_SOURCE ${EXAMPLE_SOURCES})
 endif()

+include(FetchContent)
+FetchContent_Declare(
+    googletest
+    GIT_REPOSITORY https://github.com/google/googletest.git
+    GIT_TAG        v1.15.2
+)
+FetchContent_MakeAvailable(googletest)
+
 if(BUILD_TESTS)
   enable_testing()
-  add_subdirectory(third-party/gtest)
   file(GLOB ${PROJECT_NAME}_TEST_SOURCES tests/*.cpp)
   add_executable(check ${${PROJECT_NAME}_TEST_SOURCES})
-  target_link_libraries(check ${PROJECT_NAME} gtest_main)
+  target_link_libraries(check ${PROJECT_NAME} GTest::gtest_main)
   add_test(NAME check COMMAND check)
 endif()
```
4) Была произведена ручная сборка и запущен тест
```bash
$ cmake -H. -B_builds -DBUILD_TESTS=ON
kristina@debian:~/KRisti0w/workspace/projects/lab08$ cmake -H. -B_builds -DBUILD_TESTS=ON
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
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Success
-- Found Threads: TRUE
-- Configuring done (4.0s)
-- Generating done (0.0s)
-- Build files have been written to: /home/kristina/KRisti0w/workspace/projects/lab08/_builds

$ cmake --build _builds
[  8%] Building CXX object CMakeFiles/print.dir/sources/print.cpp.o
[ 16%] Linking CXX static library libprint.a
[ 16%] Built target print
[ 25%] Building CXX object _deps/googletest-build/googletest/CMakeFiles/gtest.dir/src/gtest-all.cc.o
[ 33%] Linking CXX static library ../../../lib/libgtest.a
[ 33%] Built target gtest
[ 41%] Building CXX object _deps/googletest-build/googletest/CMakeFiles/gtest_main.dir/src/gtest_main.cc.o
[ 50%] Linking CXX static library ../../../lib/libgtest_main.a
[ 50%] Built target gtest_main
[ 58%] Building CXX object CMakeFiles/check.dir/tests/test1.cpp.o
[ 66%] Linking CXX executable check
[ 66%] Built target check
[ 75%] Building CXX object _deps/googletest-build/googlemock/CMakeFiles/gmock.dir/src/gmock-all.cc.o
[ 83%] Linking CXX static library ../../../lib/libgmock.a
[ 83%] Built target gmock
[ 91%] Building CXX object _deps/googletest-build/googlemock/CMakeFiles/gmock_main.dir/src/gmock_main.cc.o
[100%] Linking CXX static library ../../../lib/libgmock_main.a
[100%] Built target gmock_main

$ cmake --build _builds --target test
Running tests...
Test project /home/kristina/KRisti0w/workspace/projects/lab08/_builds
    Start 1: check
1/1 Test #1: check ............................   Passed    0.01 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   0.01 sec
```
FetchContent успешно скачал и собрал GTest
```bash
$ ls -la _builds/_deps/
итого 20
drwxrwxr-x 5 kristina kristina 4096 мая 13 13:18 .
drwxrwxr-x 7 kristina kristina 4096 мая 13 13:19 ..
drwxrwxr-x 5 kristina kristina 4096 мая 13 13:19 googletest-build
drwxrwxr-x 8 kristina kristina 4096 мая 13 13:18 googletest-src
drwxrwxr-x 4 kristina kristina 4096 мая 13 13:18 googletest-subbuild
```
5) Написан demo и добавлен в CMakeLists.txt
```cpp
#include <print.hpp>

#include <cstdlib>

int main(int argc, char* argv[])
{
  const char* log_path = std::getenv("LOG_PATH");
  if (log_path == nullptr)
  {
    std::cerr << "undefined environment variable: LOG_PATH" << std::endl;
    return 1;
  }
  std::string text;
  while (std::cin >> text)
  {
    std::ofstream out{log_path, std::ios_base::app};
    print(text, out);
    out << std::endl;
  }
}
```

6) Подключён модуль polly и установлен clang

7) Через polly был запущен тест
```bash
Python version: 3.13
Build dir: /home/kristina/KRisti0w/workspace/projects/lab08/_builds/default
Execute command: [
  `which`
  `cmake`
]

[/home/kristina/KRisti0w/workspace/projects/lab08]> "which" "cmake"

/usr/bin/cmake
Execute command: [
  `cmake`
  `--version`
]

[/home/kristina/KRisti0w/workspace/projects/lab08]> "cmake" "--version"

cmake version 3.31.6

CMake suite maintained and supported by Kitware (kitware.com/cmake).
Execute command: [
  `cmake`
  `-H.`
  `-B/home/kristina/KRisti0w/workspace/projects/lab08/_builds/default`
  `-DCMAKE_TOOLCHAIN_FILE=/home/kristina/KRisti0w/workspace/projects/lab08/tools/polly/default.cmake`
]

[/home/kristina/KRisti0w/workspace/projects/lab08]> "cmake" "-H." "-B/home/kristina/KRisti0w/workspace/projects/lab08/_builds/default" "-DCMAKE_TOOLCHAIN_FILE=/home/kristina/KRisti0w/workspace/projects/lab08/tools/polly/default.cmake"

-- [polly] Used toolchain: Default
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
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Success
-- Found Threads: TRUE
-- Configuring done (8.6s)
-- Generating done (0.0s)
-- Build files have been written to: /home/kristina/KRisti0w/workspace/projects/lab08/_builds/default
Execute command: [
  `cmake`
  `--build`
  `/home/kristina/KRisti0w/workspace/projects/lab08/_builds/default`
  `--`
]

[/home/kristina/KRisti0w/workspace/projects/lab08]> "cmake" "--build" "/home/kristina/KRisti0w/workspace/projects/lab08/_builds/default" "--"

[  8%] Building CXX object CMakeFiles/print.dir/sources/print.cpp.o
[ 16%] Linking CXX static library libprint.a
[ 16%] Built target print
[ 25%] Building CXX object _deps/googletest-build/googletest/CMakeFiles/gtest.dir/src/gtest-all.cc.o
[ 33%] Linking CXX static library ../../../lib/libgtest.a
[ 33%] Built target gtest
[ 41%] Building CXX object _deps/googletest-build/googletest/CMakeFiles/gtest_main.dir/src/gtest_main.cc.o
[ 50%] Linking CXX static library ../../../lib/libgtest_main.a
[ 50%] Built target gtest_main
[ 58%] Building CXX object CMakeFiles/check.dir/tests/test1.cpp.o
[ 66%] Linking CXX executable check
[ 66%] Built target check
[ 75%] Building CXX object _deps/googletest-build/googlemock/CMakeFiles/gmock.dir/src/gmock-all.cc.o
[ 83%] Linking CXX static library ../../../lib/libgmock.a
[ 83%] Built target gmock
[ 91%] Building CXX object _deps/googletest-build/googlemock/CMakeFiles/gmock_main.dir/src/gmock_main.cc.o
[100%] Linking CXX static library ../../../lib/libgmock_main.a
[100%] Built target gmock_main
Run tests
Execute command: [
  `ctest`
]

[/home/kristina/KRisti0w/workspace/projects/lab08/_builds/default]> "ctest"

Test project /home/kristina/KRisti0w/workspace/projects/lab08/_builds/default
    Start 1: check
1/1 Test #1: check ............................   Passed    0.01 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   0.02 sec
-
Log saved: /home/kristina/KRisti0w/workspace/projects/lab08/_logs/polly/default/log.txt
-
Generate: 0:00:09.724884s
Build: 0:00:20.402409s
Test: 0:00:00.063267s
-
Total: 0:00:30.192767s
-
SUCCESS
```
8) Произведена сборка и установка в _install
```bash
$ tree _install/
_install/
└── default
    ├── bin
    │   └── demo
    ├── cmake
    │   ├── print-config.cmake
    │   └── print-config-noconfig.cmake
    ├── include
    │   ├── gmock
    │   │   ├── gmock-actions.h
    │   │   ├── gmock-cardinalities.h
    │   │   ├── gmock-function-mocker.h
    │   │   ├── gmock.h
    │   │   ├── gmock-matchers.h
    │   │   ├── gmock-more-actions.h
    │   │   ├── gmock-more-matchers.h
    │   │   ├── gmock-nice-strict.h
    │   │   ├── gmock-spec-builders.h
    │   │   └── internal
    │   │       ├── custom
    │   │       │   ├── gmock-generated-actions.h
    │   │       │   ├── gmock-matchers.h
    │   │       │   ├── gmock-port.h
    │   │       │   └── README.md
    │   │       ├── gmock-internal-utils.h
    │   │       ├── gmock-port.h
    │   │       └── gmock-pp.h
    │   ├── gtest
    │   │   ├── gtest-assertion-result.h
    │   │   ├── gtest-death-test.h
    │   │   ├── gtest.h
    │   │   ├── gtest-matchers.h
    │   │   ├── gtest-message.h
    │   │   ├── gtest-param-test.h
    │   │   ├── gtest_pred_impl.h
    │   │   ├── gtest-printers.h
    │   │   ├── gtest_prod.h
    │   │   ├── gtest-spi.h
    │   │   ├── gtest-test-part.h
    │   │   ├── gtest-typed-test.h
    │   │   └── internal
    │   │       ├── custom
    │   │       │   ├── gtest.h
    │   │       │   ├── gtest-port.h
    │   │       │   ├── gtest-printers.h
    │   │       │   └── README.md
    │   │       ├── gtest-death-test-internal.h
    │   │       ├── gtest-filepath.h
    │   │       ├── gtest-internal.h
    │   │       ├── gtest-param-util.h
    │   │       ├── gtest-port-arch.h
    │   │       ├── gtest-port.h
    │   │       ├── gtest-string.h
    │   │       └── gtest-type-util.h
    │   └── print.hpp
    └── lib
        ├── cmake
        │   └── GTest
        │       ├── GTestConfig.cmake
        │       ├── GTestConfigVersion.cmake
        │       ├── GTestTargets.cmake
        │       └── GTestTargets-noconfig.cmake
        ├── libgmock.a
        ├── libgmock_main.a
        ├── libgtest.a
        ├── libgtest_main.a
        ├── libprint.a
        └── pkgconfig
            ├── gmock_main.pc
            ├── gmock.pc
            ├── gtest_main.pc
            └── gtest.pc

15 directories, 57 files
```

[![Docker Build](https://img.shields.io/badge/docker-build-blue)](https://hub.docker.com/)
