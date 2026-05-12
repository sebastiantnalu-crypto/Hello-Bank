@echo off
echo ================================================
echo  Hello Bank — Deploy App to Kubernetes
echo ================================================
echo.

set NAMESPACE=hello-bank
set IMAGE_TAG=latest

:: Install/upgrade Traefik
echo [1/5] Installing Traefik ingress controller...
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm upgrade --install traefik traefik/traefik ^
  --namespace traefik --create-namespace ^
  -f kubernetes/traefik/values.yaml

:: Install/upgrade Kyverno
echo [2/5] Installing Kyverno security policies...
helm repo add kyverno https://kyverno.github.io/kyverno
helm repo update
helm upgrade --install kyverno kyverno/kyverno ^
  --namespace kyverno --create-namespace

:: Apply Kyverno policy
echo [3/5] Applying no-root policy...
kubectl apply -f kubernetes/kyverno/no-root-policy.yaml

:: Install/upgrade Istio
echo [4/5] Installing Istio service mesh...
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm upgrade --install istio-base istio/base ^
  --namespace istio-system --create-namespace
helm upgrade --install istiod istio/istiod ^
  --namespace istio-system

:: Deploy Hello Bank app
echo [5/5] Deploying Hello Bank app...
helm upgrade --install hello-bank ./kubernetes/helm/hello-bank-app ^
  --namespace %NAMESPACE% --create-namespace ^
  --set image.tag=%IMAGE_TAG%

:: Apply Traefik routes
kubectl apply -f kubernetes/traefik/middleware.yaml
kubectl apply -f kubernetes/traefik/ingressroute.yaml

:: Apply Istio mTLS
kubectl apply -f kubernetes/istio/peer-auth.yaml

echo.
echo Waiting for pods to be ready...
kubectl rollout status deployment/hello-bank-app -n %NAMESPACE%

echo.
echo ================================================
echo  Deployment complete!
echo  Check pods:    kubectl get pods -n hello-bank
echo  Check routes:  kubectl get ingressroute -n hello-bank
echo  Get LB IP:     kubectl get svc -n traefik
echo ================================================
pause