cmake_minimum_required(VERSION 3.10)
project(Myproject)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_TOOLCHAIN_FILE "vcpkg/scripts/buildsystems/vcpkg.cmake")

add_executable(Myproject src/main.cpp)
