@echo off
echo ================================================
echo  Hello Bank — Windows Tool Installer
echo  Run this in PowerShell as Administrator
echo ================================================
echo.

:: Step 1 — Install Chocolatey if not already installed
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    echo Chocolatey installed. Refreshing environment...
    call refreshenv
) else (
    echo Chocolatey already installed. Skipping.
)

echo.
echo Installing core tools...
echo.

choco install terraform        -y --version=1.7.5
choco install kubernetes-cli   -y
choco install kubernetes-helm  -y
choco install awscli           -y
choco install azure-cli        -y
choco install git              -y
choco install docker-desktop   -y
choco install python           -y --version=3.11.0

echo.
echo Verifying installations...
echo.

terraform  version
kubectl    version --client
helm       version
aws        --version
az         version
git        --version
docker     --version
python     --version

echo.
echo ================================================
echo  All tools installed!
echo  IMPORTANT: Close and reopen your terminal now.
echo  Then run: aws configure
echo ================================================
pause