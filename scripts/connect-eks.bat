@echo off
echo ================================================
echo  Hello Bank — Connect kubectl to EKS
echo ================================================
echo.

:: Read cluster name and region from Terraform outputs
:: Run this from the repo root after terraform apply

set REGION=eu-west-1
set CLUSTER_NAME=hello-bank-eks

echo Fetching kubeconfig from AWS...
aws eks update-kubeconfig --name %CLUSTER_NAME% --region %REGION%

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Could not connect to EKS. Check that:
    echo   1. aws configure has been run with valid credentials
    echo   2. terraform apply completed successfully
    echo   3. The cluster name matches: %CLUSTER_NAME%
    pause
    exit /b 1
)

echo.
echo Testing connection...
kubectl get nodes

echo.
echo Creating hello-bank namespace if it doesn't exist...
kubectl get namespace hello-bank >nul 2>&1
if %errorlevel% neq 0 (
    kubectl create namespace hello-bank
    echo Namespace created.
) else (
    echo Namespace already exists.
)

echo.
echo Showing cluster info:
kubectl cluster-info

echo.
echo ================================================
echo  Connected! You can now run helm and kubectl.
echo  Next step: scripts\deploy-app.bat
echo ================================================
pause