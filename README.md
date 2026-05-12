# 🏦 Hello Bank — Beginner Cloud Engineering Project

> A hands-on learning project covering **every major cloud tool** in one real working application.
> Built on AWS + Azure using Terraform, Kubernetes (EKS/AKS), Helm, Traefik, Kyverno, Istio, GitLab CI/CD, Datadog, and CloudWatch.

---

## 📋 Table of Contents

- [What Is This Project?](#what-is-this-project)
- [Architecture Overview](#architecture-overview)
- [Tools & Why We Use Them](#tools--why-we-use-them)
- [Project Structure](#project-structure)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 0 — Prerequisites & Tool Installation](#step-0--prerequisites--tool-installation-windows)
  - [Step 1 — The Application](#step-1--the-application-app)
  - [Step 2 — Infrastructure with Terraform](#step-2--infrastructure-with-terraform-terraform)
  - [Step 3 — Kubernetes Cluster](#step-3--kubernetes-cluster-kubernetes)
  - [Step 4 — CI/CD Pipeline](#step-4--cicd-pipeline-gitlab-ciyml)
  - [Step 5 — Monitoring](#step-5--monitoring-monitoring)
- [How Everything Connects](#how-everything-connects)
- [Free Tier Resources Used](#free-tier-resources-used)
- [Learning Order for Beginners](#learning-order-for-beginners)
- [Common Commands Reference](#common-commands-reference)
- [Troubleshooting](#troubleshooting)

---

## What Is This Project?

**Hello Bank** is a beginner-friendly cloud engineering project that simulates a real banking application. It is intentionally simple — a Python API with two routes (`/balance` and `/transfer`) — so you can focus entirely on understanding **how the infrastructure and DevOps tools work**, not the application code.

Every tool in the stack does exactly one job:

| Tool | One-Line Job |
|---|---|
| **GitLab CI/CD** | Automatically tests, builds, and deploys your code on every push |
| **Terraform** | Creates all cloud infrastructure (servers, networks, databases) as code |
| **AWS VPC** | Private network that isolates your resources from the internet |
| **AWS EC2** | A free virtual server to run basic workloads |
| **AWS S3** | Stores files and logs in the cloud |
| **AWS RDS (PostgreSQL)** | Managed database — stores account and transaction data |
| **AWS EKS** | Runs your app containers using Kubernetes on AWS |
| **AWS ELB** | Distributes incoming traffic across multiple app instances |
| **AWS KMS** | Encrypts sensitive data at rest (database, S3) |
| **AWS Transfer Family** | Secure SFTP endpoint for inter-bank file transfers |
| **Azure VM** | Mirror server on Azure for disaster recovery |
| **Azure AKS** | Azure's version of Kubernetes |
| **Azure App Gateway** | Azure load balancer with built-in Web Application Firewall |
| **Azure Guardrails** | Azure Policy rules that enforce governance |
| **Helm** | Package manager for Kubernetes — deploys your app in one command |
| **Traefik** | Routes HTTP traffic to the correct service inside Kubernetes |
| **Kyverno** | Blocks insecure Kubernetes deployments (e.g. containers running as root) |
| **Istio** | Encrypts all traffic between services inside the cluster (mTLS) |
| **Datadog** | Application performance monitoring — traces every API call |
| **CloudWatch** | AWS-native logs and alerting |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitLab CI/CD                            │
│          push code → test → build image → deploy                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼───────┐
                    │   Terraform    │
                    │ Creates all    │
                    │ infra below    │
                    └───┬─────────┬──┘
                        │         │
         ┌──────────────▼──┐   ┌──▼──────────────┐
         │      AWS        │   │      Azure      │
         │  (primary)      │   │  (disaster rec.)│
         │                 │   │                 │
         │ VPC             │   │ Virtual Network │
         │  └ Public Subnet│   │  └ Azure VM     │
         │  └ Private Sub. │   │  └ AKS cluster  │
         │                 │   │  └ App Gateway  │
         │ EC2 (t2.micro)  │   │  └ Guardrails   │
         │ S3 Bucket       │   └─────────────────┘
         │ RDS PostgreSQL  │
         │ ELB             │
         │ EKS Cluster     │
         │  └ Helm Charts  │
         │  └ Traefik      │
         │  └ Kyverno      │
         │  └ Istio mTLS   │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   Monitoring    │
         │ Datadog + CW    │
         └─────────────────┘
```
```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS (eu-west-1)                          │
│                                                                 │
│  ┌──────────┐    ┌──────────────────────────────────────────┐   │
│  │  GitLab  │───▶│              EKS Cluster                │    │
│  │  CI/CD   │    │  ┌──────────┐   ┌─────────────────────┐  │   │
│  └──────────┘    │  │ Traefik  │   │   hello-bank-app    │  │   │
│                  │  │ Ingress  │─▶│   (FastAPI × 2)     │  │   │
│  ┌──────────┐    │  └──────────┘   └─────────────────────┘  │   │
│  │  Azure   │    │  ┌──────────┐  ┌──────────────────────┐  │   │
│  │  (ACR +  │    │  │ Kyverno  │  │       Istio mTLS     │  │   │
│  │  Storage)│    │  └──────────┘  └──────────────────────┘  │   │
│  └──────────┘    └──────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────┐    ┌─────────────┐   ┌──────────────────┐     │
│  │  EC2 t2.micro│    │ RDS Postgres│   │    S3 Bucket     │     │
│  │  (Bastion)   │    │ db.t3.micro │   │  (App Assets)    │     │
│  └──────────────┘    └─────────────┘   └──────────────────┘     │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              VPC (10.0.0.0/16)                           │   │
│  │  Public Subnet: 10.0.1.0/24                              │   │
│  │  Private Subnets: 10.0.10.0/24 · 10.0.11.0/24            │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

```

### Traffic Flow (What Happens When Someone Uses the Bank App)

```
User Browser
     │
     ▼ HTTPS
AWS ELB (Load Balancer)
     │  terminates SSL, forwards to cluster
     ▼
Traefik (Kubernetes Ingress)
     │  routes /balance → banking service
     ▼
hello-bank Pod (FastAPI app)
     │  mTLS encrypted via Istio
     ▼
RDS PostgreSQL (database)
     │  encrypted at rest via KMS
     ▼
Response back to user
```

---

## Tools & Why We Use Them

### Why Terraform instead of clicking in the AWS Console?

Clicking in the console is fine once. But imagine you accidentally delete your entire network — with Terraform you run `terraform apply` and everything is recreated in minutes. Terraform also lets your whole team use the exact same infrastructure, every time. This is called **Infrastructure as Code (IaC)**.

### Why Kubernetes (EKS) instead of just EC2?

EC2 is a single server. If it crashes, your app is down. Kubernetes runs multiple copies of your app across multiple servers — if one crashes, traffic automatically shifts to the others. It also handles deployments with zero downtime and auto-scales during traffic spikes.

### Why Helm instead of raw Kubernetes YAML?

Kubernetes config is YAML files. Without Helm you'd need separate files for staging vs production. Helm is a package manager — one chart, different values files. `helm upgrade --install hello-bank ./helm/hello-bank-app` and you're done.

### Why Traefik instead of Nginx?

Traefik automatically discovers Kubernetes services and configures routing without manual config. When you add a new service, Traefik picks it up instantly. Nginx needs manual updates every time.

### Why Kyverno?

Without Kyverno, a developer could accidentally deploy a container running as root (admin user), exposing a serious security vulnerability. Kyverno **blocks** non-compliant deployments before they happen — it's like a security checkpoint at the gate.

### Why Istio?

By default, traffic between your pods inside Kubernetes is unencrypted. Istio adds a sidecar proxy to every pod and forces all pod-to-pod communication to use **mutual TLS (mTLS)** — meaning both sides verify each other's identity and all data is encrypted, even inside the cluster.

### Why Datadog AND CloudWatch?

CloudWatch is built into AWS — great for infrastructure metrics (EC2 CPU, RDS connections). Datadog goes deeper — it traces individual API calls through every service, shows you which database query is slow, and works across both AWS and Azure in one dashboard.

---

## Project Structure

```
hello-bank/
│
├── .gitlab-ci.yml              ← CI/CD pipeline (runs on every git push)
├── README.md                   ← This file
│
├── app/                        ← Your banking application code
│   ├── Dockerfile              ← Packages app into a container image
│   ├── requirements.txt        ← Python dependencies
│   └── main.py                 ← FastAPI app with /balance and /transfer
│
├── terraform/                  ← All infrastructure as code
│   ├── main.tf                 ← Entry point — calls all modules
│   ├── variables.tf            ← Input variables (region, names)
│   ├── outputs.tf              ← Prints IP addresses, URLs after deploy
│   ├── terraform.tfvars        ← Your actual values
│   │
│   └── modules/                ← Each module = one AWS service
│       ├── vpc/                ← Private network
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── security-groups/    ← Firewall rules
│       │   ├── main.tf
│       │   └── variables.tf
│       ├── ec2/                ← Free-tier server
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── s3/                 ← File storage bucket
│       │   ├── main.tf
│       │   └── variables.tf
│       ├── rds/                ← PostgreSQL database
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── eks/                ← Kubernetes cluster on AWS
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── azure/              ← Azure mirror (VM + AKS)
│           ├── main.tf
│           └── variables.tf
│
├── kubernetes/                 ← Everything Kubernetes-related
│   ├── helm/
│   │   └── hello-bank-app/     ← Helm chart for the banking app
│   │       ├── Chart.yaml      ← Chart metadata
│   │       ├── values.yaml     ← Default config (image, replicas, ports)
│   │       └── templates/
│   │           ├── deployment.yaml  ← How many pods to run
│   │           ├── service.yaml     ← Exposes app inside cluster
│   │           └── ingress.yaml     ← Makes app reachable from outside
│   ├── traefik/
│   │   ├── values.yaml         ← Traefik Helm config
│   │   └── ingress-route.yaml  ← URL routing rules
│   ├── kyverno/
│   │   └── no-root-policy.yaml ← Blocks root containers
│   └── istio/
│       └── peer-auth.yaml      ← Forces mTLS between all pods
│
├── monitoring/
│   ├── cloudwatch-alarm.tf     ← Alert if EC2 CPU > 80%
│   └── datadog-values.yaml     ← Datadog agent Helm config
│
└── scripts/
    ├── install-tools.bat       ← Installs all tools on Windows
    └── connect-eks.bat         ← Connects kubectl to your EKS cluster
```

---

## Step-by-Step Setup Guide

### Step 0 — Prerequisites & Tool Installation (Windows)

Before writing any code, install all required tools. Open **PowerShell as Administrator** and run:

aws configure
# AWS Access Key ID:     AKIA...
# AWS Secret Access Key: xxxx...
# Default region:        eu-west-1
# Default output format: json

### Step 1 — The Application (`app/`)

The app is a minimal Python FastAPI web server. It has two endpoints that simulate a banking API:

The Dockerfile packages this app so Kubernetes can run it:

---

### Step 2 — Infrastructure with Terraform (`terraform/`)

Terraform creates everything on AWS in the correct order. Each module is independent — you can understand each one in isolation.

**How Terraform works — three commands:**

```
terraform init    → downloads the AWS plugin (do this once)
terraform plan    → shows what WILL change (no actual changes)
terraform apply   → actually creates resources on AWS
terraform destroy → deletes everything (useful for learning/saving costs)
```

**Module execution order** (Terraform figures this out automatically from dependencies):

```
1. VPC          — network must exist first
2. Subnets      — live inside the VPC
3. Security Groups — reference the VPC
4. EC2          — needs subnet + security group
5. S3           — independent, can run in parallel
6. RDS          — needs private subnets + security group
7. EKS          — needs private subnets
```

**Run Terraform:**

```powershell
cd terraform
terraform init
terraform plan          # review what will be created
terraform apply         # type 'yes' when prompted
```

After `terraform apply` completes, it prints outputs:

```
Outputs:
ec2_public_ip   = "34.245.xx.xx"
rds_endpoint    = "hello-bank-db.xxxx.eu-west-1.rds.amazonaws.com"
eks_cluster_name = "hello-bank-eks"
s3_bucket_name  = "hello-bank-logs-xxxx"
```

**Key concept — why modules?** Each folder under `modules/` is self-contained. If you need to change the database, you only touch `modules/rds/`. Nothing else breaks.

**Free tier note:** The following instance types are free for 12 months on a new AWS account:
- EC2: `t3.micro` (750 hours/month)
- RDS: `db.t3.micro` (750 hours/month, 20GB storage)
- S3: 5GB storage free

---

### Step 3 — Kubernetes Cluster (`kubernetes/`)

After Terraform creates the EKS cluster, connect `kubectl` to it:

```powershell
aws eks update-kubeconfig --name hello-bank-eks --region eu-west-1
kubectl get nodes   # should show your worker nodes
```

#### 3a — Install Traefik (Ingress Controller)

Traefik acts as the front door of your cluster — all external HTTP traffic goes through it first.

```powershell
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --namespace traefik --create-namespace -f kubernetes/traefik/values.yaml
kubectl get pods -n traefik   # should show traefik pod Running
```

**What Traefik does:** Without Traefik, there is no way to reach your app from a browser. Traefik reads `IngressRoute` resources and automatically knows to send `GET /balance` to the hello-bank service.

#### 3b — Install Kyverno (Security Policies)

```powershell
helm repo add kyverno https://kyverno.github.io/kyverno
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
kubectl apply -f kubernetes/kyverno/no-root-policy.yaml
```

Test that Kyverno is working — try to deploy a root container (it should be blocked):

```powershell
kubectl run bad-pod --image=nginx --namespace=hello-bank
# Expected: Error from server: pods "bad-pod" is forbidden: runAsNonRoot required
```

#### 3c — Install Istio (Service Mesh)

```powershell
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio-base istio/base --namespace istio-system --create-namespace
helm install istiod istio/istiod --namespace istio-system
kubectl label namespace hello-bank istio-injection=enabled
kubectl apply -f kubernetes/istio/peer-auth.yaml
```

**What the label does:** `istio-injection=enabled` tells Istio to automatically inject a sidecar proxy into every pod in the `hello-bank` namespace. You do not change your application code at all — Istio handles encryption transparently.

#### 3d — Deploy the Banking App with Helm

```powershell
helm install hello-bank ./kubernetes/helm/hello-bank-app \
  --namespace hello-bank \
  --create-namespace \
  --set image.repository=your-dockerhub-username/hello-bank \
  --set image.tag=latest

kubectl get pods -n hello-bank          # see your app pods
kubectl get svc -n hello-bank           # see the service
kubectl logs -n hello-bank -l app=hello-bank  # see app logs
```

**Verify the app is running:**

```powershell
kubectl port-forward -n hello-bank svc/hello-bank-app 8080:8080
# Open: http://localhost:8080/balance/ACC001
```

---

### Step 4 — CI/CD Pipeline (`.gitlab-ci.yml`)

The pipeline runs automatically on every `git push`. It has three stages:

```
Stage 1: test    → runs pytest, verifies app imports correctly
Stage 2: build   → builds Docker image, pushes to GitLab registry
Stage 3: deploy  → runs helm upgrade on your EKS cluster
```

**Push your first change and watch the pipeline:**

```powershell
git add .
git commit -m "feat: initial hello-bank deployment"
git push origin main
# Go to GitLab → CI/CD → Pipelines → watch it run
```

**Why `when: manual` on deploy?** This means you have to click a button in GitLab to trigger the deployment. Prevents accidental deployments — in banking, you always want a human approving production changes.

---

### Step 5 — Monitoring (`monitoring/`)

#### CloudWatch Alarm (AWS native)

The CloudWatch alarm is part of Terraform — it is created automatically with `terraform apply`:

View alarms in AWS Console → CloudWatch → Alarms.

#### Datadog (Application Monitoring)

Sign up for a free Datadog account at [datadoghq.com](https://www.datadoghq.com) (free tier available).


After ~2 minutes, open Datadog → Infrastructure → your cluster nodes appear. Go to APM → Traces to see individual API calls traced through the app.

---

## How Everything Connects

Here is the complete flow from writing code to users seeing the app:

```
 You write code in VS Code
         │
         ▼
 git push → GitLab
         │
         ├── Stage 1: test-app
         │     Runs pytest
         │     ✅ Pass → continue
         │     ❌ Fail → pipeline stops, you get email
         │
         ├── Stage 2: build-image
         │     docker build → docker push
         │     Image tagged with commit SHA
         │     Stored in GitLab Container Registry
         │
         └── Stage 3: deploy (manual click)
               helm upgrade hello-bank
               Kubernetes pulls new image
               Rolling update — zero downtime
               Old pods removed after new ones healthy

 User visits https://your-bank-url.com
         │
         ▼
 AWS ELB → receives HTTPS request
         │
         ▼
 Traefik → routes to /balance or /transfer
         │
         ▼
 hello-bank Pod (FastAPI)
         │  (Istio sidecar encrypts this hop with mTLS)
         ▼
 RDS PostgreSQL → reads/writes account data
         │  (KMS encrypts data at rest)
         ▼
 Response → back up the same chain to user

 Meanwhile...
 Kyverno   → watching every new pod, blocks policy violations
 Datadog   → tracing every request, alerting on errors
 CloudWatch → monitoring EC2 and RDS health metrics
```

---

## Free Tier Resources Used

| AWS Service | Free Tier Limit | This Project Uses |
|---|---|---|
| EC2 | 750 hrs/month of t2.micro | 1 × t2.micro |
| RDS | 750 hrs/month of db.t3.micro, 20GB | 1 × db.t3.micro, 20GB |
| S3 | 5GB storage, 20k GET, 2k PUT | < 1GB |
| EKS | $0.10/hr per cluster ⚠️ | 1 cluster (NOT free) |
| CloudWatch | 10 metrics, 3 dashboards free | 1 alarm |
| Data Transfer | 1GB/month free | minimal |

> ⚠️ **Important:** EKS control plane costs $0.10/hr (~$72/month). For learning, run `terraform destroy` when not actively working. The worker nodes (EC2 instances) also count against your EC2 free tier.

**To minimize costs while learning:**

```powershell
# Pause learning session — destroy everything
terraform destroy

# Resume learning — recreate everything (takes ~15 min)
terraform apply
```

---

## Learning Order for Beginners

Work through one step per week. Each week builds on the last:

```
Week 1 — Terraform + VPC + EC2
  Goal: Run 'terraform apply' successfully
  Win: See your EC2 instance in AWS Console
  Command: terraform apply -target=module.vpc -target=module.ec2

Week 2 — S3 + RDS + Security Groups
  Goal: Deploy the database
  Win: Connect to PostgreSQL with a DB client
  Command: terraform apply

Week 3 — EKS + kubectl
  Goal: Connect to your Kubernetes cluster
  Win: 'kubectl get nodes' shows worker nodes
  Command: aws eks update-kubeconfig --name hello-bank-eks

Week 4 — Helm + App Deployment
  Goal: Deploy hello-bank app to Kubernetes
  Win: curl http://localhost:8080/balance/ACC001 returns JSON
  Command: helm install hello-bank ./kubernetes/helm/hello-bank-app

Week 5 — Traefik + Kyverno
  Goal: Route traffic + enforce security
  Win: App accessible via domain; root pod blocked
  Command: kubectl apply -f kubernetes/kyverno/no-root-policy.yaml

Week 6 — Istio
  Goal: Enable mTLS between pods
  Win: Kiali dashboard shows encrypted service mesh
  Command: kubectl label namespace hello-bank istio-injection=enabled

Week 7 — GitLab CI/CD
  Goal: Push code and watch pipeline deploy automatically
  Win: git push → pipeline runs → app updated with zero downtime
  Command: git push origin main

Week 8 — Monitoring
  Goal: See metrics and traces in Datadog + CloudWatch
  Win: Dashboard shows live request rate, latency, errors
  Command: helm install datadog datadog/datadog ...
```

---

## Common Commands Reference

```powershell
# ── Terraform ─────────────────────────────────────
terraform init                          # download providers (run once)
terraform plan                          # preview changes
terraform apply                         # create/update infrastructure
terraform destroy                       # delete everything
terraform output                        # show output values

# ── Kubernetes / kubectl ──────────────────────────
kubectl get pods -n hello-bank          # list all pods
kubectl get svc -n hello-bank           # list services
kubectl logs -n hello-bank <pod-name>   # view pod logs
kubectl describe pod <pod-name>         # debug a pod
kubectl exec -it <pod-name> -- sh       # shell into a pod

# ── Helm ─────────────────────────────────────────
helm list -A                            # list all releases
helm install hello-bank ./helm/...      # install chart
helm upgrade hello-bank ./helm/...      # update chart
helm uninstall hello-bank               # remove chart
helm template ./helm/... | less         # preview YAML output

# ── AWS CLI ──────────────────────────────────────
aws eks update-kubeconfig --name hello-bank-eks --region eu-west-1
aws s3 ls                               # list S3 buckets
aws rds describe-db-instances           # list databases
aws ec2 describe-instances              # list EC2 instances

# ── GitLab ───────────────────────────────────────
git add .
git commit -m "feat: description"
git push origin main                    # triggers pipeline
```

---

## Troubleshooting

### `terraform apply` fails with "no valid credential sources"

```powershell
aws configure          # re-enter your AWS credentials
aws sts get-caller-identity   # verify credentials work
```

### `kubectl get nodes` shows "No resources found"

```powershell
aws eks update-kubeconfig --name hello-bank-eks --region eu-west-1
kubectl config current-context   # verify correct cluster
```

### Pod is in `CrashLoopBackOff`

```powershell
kubectl logs -n hello-bank <pod-name> --previous   # see crash logs
kubectl describe pod -n hello-bank <pod-name>      # see events
```

### Kyverno blocking your deployment

This means your container is running as root. Fix the Dockerfile:

```dockerfile
# Add these lines before CMD
RUN useradd -m appuser
USER appuser
```

### Helm install fails with "cannot re-use a name"

```powershell
helm uninstall hello-bank -n hello-bank
helm install hello-bank ./kubernetes/helm/hello-bank-app -n hello-bank
```

### EKS nodes not joining the cluster

Check the node group IAM role has these policies attached:
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryReadOnly`

---

## Author

Built as a learning project for junior cloud engineers.
Every tool in this stack is used in real production banking systems worldwide.

---

## License

MIT — use freely for learning and personal projects.
