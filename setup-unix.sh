#!/bin/bash

check_package() {
    local package="$1"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew list "$package" &>/dev/null
        return $?
    elif command -v apt-get &>/dev/null; then
        dpkg -l "$package" 2>/dev/null | grep -q "^ii"
        return $?
    elif command -v dnf &>/dev/null; then
        dnf list installed "$package" &>/dev/null
        return $?
    elif command -v yum &>/dev/null; then
        yum list installed "$package" &>/dev/null
        return $?
    elif command -v pacman &>/dev/null; then
        pacman -Qi "$package" &>/dev/null
        return $?
    else
        return 1
    fi
}


install_missing_packages() {
    local package_manager="$1"
    local packages="$2"
    local install_cmd="$3"
    
    local missing_packages=""
    
    echo "Checking required packages..."
    for pkg in $packages; do
        if ! check_package "$pkg"; then
            missing_packages="$missing_packages $pkg"
        fi
    done
    
    if [ -n "$missing_packages" ]; then
        echo "Installing missing packages:$missing_packages"
        if ! eval "$install_cmd $missing_packages"; then
            echo "Failed to install some packages. Please check your permissions and try again."
            return 1
        fi
    else
        echo "All required packages are already installed."
    fi
    
    return 0
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
    else
        echo "CMake is already installed."
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PACKAGES="cmake curl zip unzip tar"
    
    if command -v apt-get &>/dev/null; then
        install_missing_packages "apt" "$PACKAGES" "sudo apt-get install -y"
    elif command -v dnf &>/dev/null; then
        install_missing_packages "dnf" "$PACKAGES" "sudo dnf install -y"
    elif command -v yum &>/dev/null; then
        install_missing_packages "yum" "$PACKAGES" "sudo yum install -y"
    elif command -v pacman &>/dev/null; then
        echo "Using pacman package manager"
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
