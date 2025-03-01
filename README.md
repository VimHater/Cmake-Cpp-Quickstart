## 🚀 Overview
Cmake project quickstart with vcpkg

# Project Structure
```
project_root
├── assets
├── build
├── CmakeLists.txt
├── include
├── README.md
└── src
    └── main.cpp

```
# Installation
run `setup-unix.sh` or `setup-windows.bat`
# Build
```
cd build
cmake ..
cmake --build .
```

# Specify build configuration
```
cmake --build . --config Release
cmake --build . --config Debug
```

# Parallel builds
```
cmake --build . -j 4    # Build with 4 cores
cmake --build . --parallel 4
```
