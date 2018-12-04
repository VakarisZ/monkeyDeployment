if "%~1" == "" ( 
    powershell -ExecutionPolicy ByPass -Command ". .\deploy_windows.ps1; Deploy-Windows"
) else (
    powershell -ExecutionPolicy ByPass -Command ". .\deploy_windows.ps1; Deploy-Windows -monkey_home %~1"
)