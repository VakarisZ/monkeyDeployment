# Files used to deploy development version of infection monkey
To deploy other branches (default is develop) just paste git url in corresponding config field.
On windows:
Before running the script you must have git installed.
Cd to scripts directory and use the scripts.
Example usages:
./run_script.bat (Sets up monkey in current directory under .\infection_monkey)
./run_script.bat "C:\test" (Sets up monkey in C:\test)
powershell -ExecutionPolicy ByPass -Command ". .\deploy_windows.ps1; Deploy-Windows -monkey_home C:\test" (Same as above)
Don't forget to add python to PATH or do so while installing it via this script.

On Linux:
You must have root permissions, but don't run the script as root.
Launch deploy_linux.sh from scripts directory.
Example usages:
./deploy_linux.sh (deploys under ./infection_monkey)
./deploy_linux.sh "/home/test/monkey" (deploys under /home/test/monkey)
