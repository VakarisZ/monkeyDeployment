#!/bin/bash
source config.sh

handle_error () {
    echo "Fix the errors above and rerun the script"
    exit 1
}


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
    git clone ${MONKEY_GIT_URL} ${MONKEY_HOME_DIR} 2>&1 || handle_error
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
sudo python -m pip install -r ${requirements} || handle_error

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

# If a user haven't installed mongo manually check if we can install it with our script
if [[ ! -f "$MONGO_BIN_PATH/mongod" ]] && { [[ ${kernel} != *"x86_64"* ]] || \
   { [[ ${linux_dist} != *"Debian"* ]] && [[ ${linux_dist} != *"Ubuntu"* ]]; }; }; then
    echo "Script does not support your operating system for mongodb installation.
    Reference monkey island readme and install it manually"
    exit 1
fi

# Download mongo
if [[ ! -f "$MONGO_BIN_PATH/mongod" ]]; then
    if [[ ${linux_dist} == *"Debian"* ]]; then
        wget -c -N -O "/tmp/mongo.tgz" ${MONGO_DEBIAN_URL}
    elif [[ ${linux_dist} == *"Ubuntu"* ]]; then
        wget -c -N -O "/tmp/mongo.tgz" ${MONGO_UBUNTU_URL}
    fi
    sudo tar --strip 2 --wildcards -C ${MONGO_BIN_PATH} -zxvf /tmp/mongo.tgz mongo*/bin/* || handle_error
else
    echo "Mongo db already installed"
fi

sudo apt-get install openssl

# Generate SSL certificate
${MAIN_ISLAND_PATH}/linux/create_certificate.sh
cp -r ${MAIN_ISLAND_PATH}/cc ${VAR_ISLAND_PATH} || handle_error

# Install npm
sudo apt-get install npm

cd "$VAR_ISLAND_PATH/cc/ui" || handle_error
npm update
npm run dist

# Monkey setup
sudo apt-get update
sudo apt-get install python-pip python-dev libffi-dev upx libssl-dev libc++1
cd ${MONKEY_HOME_DIR}/monkey/infection_monkey || handle_error
pip install -r requirements.txt

# Build samba
sudo apt-get install gcc-multilib
cd ${MONKEY_HOME_DIR}/monkey/infection_monkey/monkey_utils/sambacry_monkey_runner
chmod +x ./build.sh || handle_error
./build.sh

chmod +x ${MONKEY_HOME_DIR}/monkey/infection_monkey/build_linux.sh

exit 0