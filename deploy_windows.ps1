# Set variables for script execution
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$webClient = New-Object System.Net.WebClient 

# We check if git is installed
try
{
    git | Out-Null -ErrorAction Stop
   "Git requirement satisfied"
}
catch [System.Management.Automation.CommandNotFoundException]
{
    "Please install git before running this script or add it to path and restart cmd"
    return
}
# Import the config variables
. ./config.ps1
"Config variables from config.ps1 imported"

# Download the monkey
$output = cmd.exe /c "git clone $MONKEY_GIT_URL $MONKEY_HOME_DIR 2>&1"
$binDir = (Join-Path -Path $MONKEY_HOME_DIR -ChildPath $MONKEY_ISLAND_DIR | Join-Path -ChildPath "\bin")
if ( $output -like "*already exists and is not an empty directory.*"){
    "Assuming you already have the source directory"
} elseif ($output -like "fatal:*"){
    "Error while cloning monkey from the repository:"
    $output
    return
} else {
    "Monkey cloned from the repository"
    # Create bin directory
    New-Item -ItemType directory -path $binDir
    "Bin directory added"
}

# We check if python is installed
try
{
    $version = cmd.exe /c '"python" --version  2>&1'
    if ( $version -like 'Python 2.7.*' ) {
        "Python 2.7.* was found, installing dependancies"
    } else {
        throw System.Management.Automation.CommandNotFoundException
    }
}
catch [System.Management.Automation.CommandNotFoundException]
{
    "Downloading python 2.7 ..."
    $webClient.DownloadFile($PYTHON_URL, $TEMP_PYTHON_INSTALLER)
    Start-Process -Wait $TEMP_PYTHON_INSTALLER
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    Remove-Item $TEMP_PYTHON_INSTALLER
}

# Install requirements
$reqPath = Join-Path -Path $MONKEY_HOME_DIR -ChildPath $MONKEY_ISLAND_DIR | Join-Path -ChildPath "\requirements.txt"
& python -m pip install --upgrade pip
& python -m pip install -r $reqPath

# Transfer python file to local directory
"Copying python folder to bin"
Copy-Item $PYTHON_PATH -Destination (Join-Path -Path $binDir -ChildPath "Python27") -Recurse -ErrorAction SilentlyContinue
"Copying python dynamic libraries"
Copy-Item $PYTHON_DLL -Destination (Join-Path -Path $binDir -ChildPath "Python27") -ErrorAction SilentlyContinue

# Download mongodb and openssl
"Downloading mongodb ..."
$webClient.DownloadFile($MONGODB_URL, $TEMP_MONGODB_ZIP)
"Unzipping mongodb"
Expand-Archive $TEMP_MONGODB_ZIP -DestinationPath (Join-Path -Path $binDir -ChildPath "mongodb") -ErrorAction SilentlyContinue
"Removing zip file"
Remove-Item $TEMP_MONGODB_ZIP
"Downloading OpenSSL ..."
$webClient.DownloadFile($OPEN_SSL_URL, $TEMP_OPEN_SSL_ZIP)
"Unzipping OpenSSl"
Expand-Archive $TEMP_OPEN_SSL_ZIP -DestinationPath (Join-Path -Path $binDir -ChildPath "openssl") -ErrorAction SilentlyContinue
"Removing zip file"
Remove-Item $TEMP_OPEN_SSL_ZIP

# Download and install C++ redistributable
"Downloading C++ redistributable ..."
$webClient.DownloadFile($CPP_URL, $TEMP_CPP_INSTALLER)
Start-Process -Wait $TEMP_CPP_INSTALLER
Remove-Item $TEMP_CPP_INSTALLER

# Generate ssl certificate
"Generating ssl certificate"
Push-Location -Path (Join-Path -Path $MONKEY_HOME_DIR -ChildPath $MONKEY_ISLAND_DIR)
. .\windows\create_certificate.bat
Pop-Location


# Adding binaries
"Adding binaries"
$binaries = (Join-Path -Path $MONKEY_HOME_DIR -ChildPath $MONKEY_ISLAND_DIR | Join-Path -ChildPath "\cc\binaries")
New-Item -ItemType directory -path $binaries -ErrorAction SilentlyContinue
$webClient.DownloadFile($LINUX_32_BINARY_URL, (Join-Path -Path $binaries -ChildPath $LINUX_32_BINARY_PATH))
$webClient.DownloadFile($LINUX_64_BINARY_URL, (Join-Path -Path $binaries -ChildPath $LINUX_64_BINARY_PATH))
$webClient.DownloadFile($WINDOWS_32_BINARY_URL, (Join-Path -Path $binaries -ChildPath $WINDOWS_32_BINARY_PATH))
$webClient.DownloadFile($WINDOWS_64_BINARY_URL, (Join-Path -Path $binaries -ChildPath $WINDOWS_64_BINARY_PATH))

# Check if NPM installed
"Installing npm"
try
{
    $version = cmd.exe /c '"npm" --version  2>&1'
    if ( $version -like "*is not recognized*"){
        throw System.Management.Automation.CommandNotFoundException
    } else {
        "Npm already installed"
    }
}
catch [System.Management.Automation.CommandNotFoundException]
{
    "Downloading npm ..."
    $webClient.DownloadFile($NPM_URL, $TEMP_NPM_INSTALLER)
    Start-Process -Wait $TEMP_NPM_INSTALLER
    Remove-Item $TEMP_NPM_INSTALLER
}
#Refresh path 
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
"Updating npm"
& npm i npm
Push-Location -Path (Join-Path -Path $MONKEY_HOME_DIR -ChildPath $MONKEY_ISLAND_DIR | Join-Path -ChildPath "\cc\ui")
& npm update
& npm run dist
Pop-Location





