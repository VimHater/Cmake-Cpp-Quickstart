@echo off
setlocal enabledelayedexpansion

:: Check if running with admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator
    pause
    exit /b 1
)

:: Check for CMake
where cmake >nul 2>&1
if %errorLevel% neq 0 (
    echo CMake not found. Installing via winget...
    :: Check if winget is available
    where winget >nul 2>&1
    if %errorLevel% neq 0 (
        echo Error: winget is not installed. Please install CMake manually.
        echo Download from: https://cmake.org/download/
        pause
        exit /b 1
    )
    winget install Kitware.CMake
    if %errorLevel% neq 0 (
        echo Failed to install CMake
        pause
        exit /b 1
    )
) else (
    echo CMake is already installed
)

:: Check for Git
where git >nul 2>&1
if %errorLevel% neq 0 (
    echo Git not found. Installing via winget...
    winget install Git.Git
    if %errorLevel% neq 0 (
        echo Failed to install Git
        pause
        exit /b 1
    )
) else (
    echo Git is already installed
)

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "VCPKG_DIR=%SCRIPT_DIR%vcpkg"

:: Check if vcpkg directory already exists
if exist "%VCPKG_DIR%" (
    echo vcpkg is already installed
) else (
    echo Installing vcpkg...
    mkdir "%VCPKG_DIR%"
    git clone --depth=1 https://github.com/Microsoft/vcpkg.git "%VCPKG_DIR%"
    if %errorLevel% neq 0 (
        echo Failed to clone vcpkg
        pause
        exit /b 1
    )

    :: Change to vcpkg directory
    cd /d "%VCPKG_DIR%"

    :: Run bootstrap
    call bootstrap-vcpkg.bat
    if %errorLevel% neq 0 (
        echo Failed to bootstrap vcpkg
        pause
        exit /b 1
    )

    :: Remove git-related files
    rmdir /s /q .git .github 2>nul
    del /f /q .gitignore .gitmodules .gitattributes 2>nul

    echo vcpkg installation completed!
)
