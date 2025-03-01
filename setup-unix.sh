#!/bin/bash

check_package() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew list "$1" &>/dev/null
    elif command -v apt-get &>/dev/null; then
        dpkg -l "$1" &>/dev/null
    elif command -v dnf &>/dev/null; then
        dnf list installed "$1" &>/dev/null
    elif command -v yum &>/dev/null; then
        yum list installed "$1" &>/dev/null
    elif command -v pacman &>/dev/null; then
        pacman -Qi "$1" &>/dev/null
    fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v cmake &>/dev/null; then
        echo "CMake not found. Installing..."
        if command -v brew &>/dev/null; then
            brew install cmake
        else
            echo "Homebrew not found. Please install Homebrew first with:"
            echo "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PACKAGES="cmake curl zip unzip tar"

    if command -v apt-get &>/dev/null; then
        MISSING_PACKAGES=""
        for pkg in $PACKAGES; do
            if ! check_package "$pkg"; then
                MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
            fi
        done
        if [ ! -z "$MISSING_PACKAGES" ]; then
            echo "Installing missing packages:$MISSING_PACKAGES"
            sudo apt-get install -y $MISSING_PACKAGES
        fi
    elif command -v dnf &>/dev/null; then
        MISSING_PACKAGES=""
        for pkg in $PACKAGES; do
            if ! check_package "$pkg"; then
                MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
            fi
        done
        if [ ! -z "$MISSING_PACKAGES" ]; then
            echo "Installing missing packages:$MISSING_PACKAGES"
            sudo dnf install -y $MISSING_PACKAGES
        fi
    elif command -v yum &>/dev/null; then
        MISSING_PACKAGES=""
        for pkg in $PACKAGES; do
            if ! check_package "$pkg"; then
                MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
            fi
        done
        if [ ! -z "$MISSING_PACKAGES" ]; then
            echo "Installing missing packages:$MISSING_PACKAGES"
            sudo yum install -y $MISSING_PACKAGES
        fi
    elif command -v pacman &>/dev/null; then
        echo "Installing packages with --needed flag"
        sudo pacman -S --needed --noconfirm cmake curl zip unzip tar
    else
        echo "Unsupported Linux distribution. Please install CMake manually."
        exit 1
    fi
else
    echo "Unsupported operating system. Please install dependencies manually"
    exit 1
fi

echo "CMake is ready."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VCPKG_DIR="${SCRIPT_DIR}/vcpkg"

if [ ! -d "${VCPKG_DIR}" ]; then
    echo "Installing vcpkg..."
    mkdir -p "${VCPKG_DIR}"
    git clone --depth=1 https://github.com/Microsoft/vcpkg.git "${VCPKG_DIR}"
    cd "${VCPKG_DIR}"

    ./bootstrap-vcpkg.sh

    rm -rf .git .gitignore .gitmodules .gitattributes .github

    echo "vcpkg installation completed!"
    echo "cmake installed"
else
    echo "vcpkg is already installed"
fi
