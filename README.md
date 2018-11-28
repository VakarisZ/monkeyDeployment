# Files used to deploy development version of infection monkey
On windows:
Review config.ps1 file and change $MONKEY_HOME_DIR variable.
Launch run_script.bat as administrator from script directory.
Don't forget to add python to PATH or do so while installing it via the script.
On Linux:
Review config.sh file and change $MONKEY_HOME_DIR variable.
Launch deploy_linux.sh from local directory as root (sudo ./deploy_linux.sh)