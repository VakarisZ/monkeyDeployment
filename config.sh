#!/usr/bin/env bash
# Absolute monkey's path
MONKEY_HOME_DIR="/home/vakaris/monkey"
# Url of public git repository that contains monkey's source code
MONKEY_GIT_URL="https://github.com/guardicore/monkey"
# Link to the latest python download or install it manually
PYTHON_URL="https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi"

# Monkey paths
VAR_ISLAND_PATH="/var/monkey/monkey_island"
MAIN_ISLAND_PATH="$MONKEY_HOME_DIR/monkey/monkey_island"
MONKEY_COMMON_PATH="/var/monkey/common/"
MONGO_PATH="$VAR_ISLAND_PATH/bin/mongodb"
MONGO_BIN_PATH="$MONGO_PATH/bin"
ISLAND_DB_PATH="$VAR_ISLAND_PATH/db"
ISLAND_BINARIES_PATH="$VAR_ISLAND_PATH/cc/binaries"

# Monkey binaries
LINUX_32_BINARY_URL="https://github.com/guardicore/monkey/releases/download/1.6/monkey-linux-32"
LINUX_32_BINARY_NAME="monkey-linux-32"
LINUX_64_BINARY_URL="https://github.com/guardicore/monkey/releases/download/1.6/monkey-linux-64"
LINUX_64_BINARY_NAME="monkey-linux-64"
WINDOWS_32_BINARY_URL="https://github.com/guardicore/monkey/releases/download/1.6/monkey-windows-32.exe"
WINDOWS_32_BINARY_NAME="monkey-windows-32.exe"
WINDOWS_64_BINARY_URL="https://github.com/guardicore/monkey/releases/download/1.6/monkey-windows-64.exe"
WINDOWS_64_BINARY_NAME="monkey-windows-64.exe"

# Mongo url's
MONGO_DEBIAN_URL="https://downloads.mongodb.org/linux/mongodb-linux-x86_64-debian81-latest.tgz"
MONGO_UBUNTU_URL="https://downloads.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-latest.tgz"
