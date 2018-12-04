# Files used to deploy development version of infection monkey
To deploy other branches (default is develop) just paste git url in corresponding config field.<br>
On windows:<br>
Before running the script you must have git installed.<br>
Cd to scripts directory and use the scripts.<br>
Example usages:<br>
./run_script.bat (Sets up monkey in current directory under .\infection_monkey)<br>
./run_script.bat "C:\test" (Sets up monkey in C:\test)<br>
powershell -ExecutionPolicy ByPass -Command ". .\deploy_windows.ps1; Deploy-Windows -monkey_home C:\test" (Same as above)<br>
Don't forget to add python to PATH or do so while installing it via this script.<br>

On Linux:<br>
You must have root permissions, but don't run the script as root.<br>
Launch deploy_linux.sh from scripts directory.<br>
Example usages:<br>
./deploy_linux.sh (deploys under ./infection_monkey)<br>
./deploy_linux.sh "/home/test/monkey" (deploys under /home/test/monkey)<br>
