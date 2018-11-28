#!/bin/bash
source config.sh

git --version &>/dev/null
git_available=$?
if [[ ${git_available} != 0 ]]; then
    echo "Please install git and re-run this script"
    exit 1
fi

if [[ ! -d ${MONKEY_HOME_DIR} ]]; then
    mkdir -p ${MONKEY_HOME_DIR}
fi

if [[ ! -d "$MONKEY_HOME_DIR/monkey" ]]; then # If not already cloned
    git clone ${MONKEY_GIT_URL} ${MONKEY_HOME_DIR} 2>&1 || exit 1
fi

# Create folders
mkdir -p ${MONGO_BIN_PATH}
mkdir -p ${ISLAND_DB_PATH}
mkdir -p ${ISLAND_BINARIES_PATH}
mkdir -p ${MONKEY_COMMON_PATH}

python_version=`python --version 2>&1`
if [[ ${python_version} == *"command not found"* ]] || [[ ${python_version} != *"Python 2.7"* ]]; then
    echo "Python 2.7 is not found or is not a default interpreter for 'python' command..."
    exit 1
fi
requirements="$MAIN_ISLAND_PATH/requirements.txt"
sudo python -m pip install -r ${requirements} || exit 1

# Download binaries
wget -c -N -P ${ISLAND_BINARIES_PATH} ${LINUX_32_BINARY_URL}
wget -c -N -P ${ISLAND_BINARIES_PATH} ${LINUX_64_BINARY_URL}
wget -c -N -P ${ISLAND_BINARIES_PATH} ${WINDOWS_32_BINARY_URL}
wget -c -N -P ${ISLAND_BINARIES_PATH} ${WINDOWS_64_BINARY_URL}
# Allow them to be executed
chmod a+x "$ISLAND_BINARIES_PATH/$LINUX_32_BINARY_NAME"
chmod a+x "$ISLAND_BINARIES_PATH/$LINUX_64_BINARY_NAME"
chmod a+x "$ISLAND_BINARIES_PATH/$WINDOWS_32_BINARY_NAME"
chmod a+x "$ISLAND_BINARIES_PATH/$WINDOWS_64_BINARY_NAME"

# Get machine type/kernel version
kernel=`uname -mrs`
linux_dist=`lsb_release -a 2> /dev/null`

if [[ ! -f "$MONGO_BIN_PATH/mongod" ]] && [[ ${kernel} != *"x86_64"* ]] || \
   { [[ ${linux_dist} != *"Debian"* ]] && [[ ${linux_dist} != *"Ubuntu"* ]]; }; then
    echo "Script does not support your operating system for mongodb installation.
    Reference monkey island readme and install it manually"
    exit 1
fi

# Download mongo
if [[ ! -f "$MONGO_BIN_PATH/mongod" ]]; then
    if [[ ${linux_dist} == *"Debian"* ]]; then
        wget -c -N -O "/tmp/mongo.tgz" ${MONGO_DEBIAN_URL}
        echo "Unzipped"
    elif [[ ${linux_dist} == *"Ubuntu"* ]]; then
        wget -c -N -O "/tmp/mongo.tgz" ${MONGO_UBUNTU_URL}
        echo "Unzipped"
    fi
    sudo tar --strip 2 --wildcards -C ${MONGO_BIN_PATH} -zxvf /tmp/mongo.tgz mongo*/bin/* || exit 1
else
    echo "Mongo db already installed"
fi

sudo apt-get install openssl

# Generate SSL certificate
${MAIN_ISLAND_PATH}/linux/create_certificate.sh
cp -r ${MAIN_ISLAND_PATH}/cc /var/monkey/monkey_island/ || exit 1

# Install npm
sudo apt-get install npm || exit 1

cd "$VAR_ISLAND_PATH/cc/ui" || exit 1
npm update || exit 1
npm run dist || exit 1

# Monkey setup
sudo apt-get update
sudo apt-get install python-pip python-dev libffi-dev upx libssl-dev libc++1 || exit 1
cd ${MONKEY_HOME_DIR}/infection_monkey || exit 1
pip install -r requirements.txt

# Build samba
sudo apt-get install gcc-multilib
cd ${MONKEY_HOME_DIR}/infection_monkey/monkey_utils/sambacry_monkey_runner
./build.sh

chmod +x ${MONKEY_HOME_DIR}/build_linux.sh

exit 0