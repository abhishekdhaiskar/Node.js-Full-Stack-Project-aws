fullstack-project/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── k8s-manifests/
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── ingress.yaml
│   ├── secrets.yaml
│   └── configmap.yaml
│
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── App.js
│   │   └── index.js
│   └── Dockerfile
│
└── backend/
    ├── src/
    │   └── index.js
    ├── package.json
    ├── .env.example
    └── Dockerfile

**Push Fullstack Project to GitHub**
we can use also vscode for push
cd fullstack-project/

# Initialize git
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial fullstack project with Terraform, K8s, Frontend and Backend"

# Create a new repo on GitHub first (manually or use GitHub CLI)

# Add remote URL (replace with your actual repo URL)
git remote add origin https://github.com/abhishekdhaiskar/fullstack-project-aws.git

# Push to GitHub
git push -u origin master  # or 'main' depending on your default branch



## PART 2: Deploy the Project on AWS

We'll cover **EKS + RDS + App Deployment**. Since your project has infra in `terraform/` and app manifests in `k8s-manifests/`, here's the complete step-by-step:



## 🚀 **Step-by-Step: Run on AWS (EKS + RDS)**


### 🌐 **Step 1: Prerequisites Installed**

Install the following:

```bash
# AWS CLI
sudo apt install awscli -y

# Terraform
sudo apt install terraform -y

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin


### 🔐 **Step 2: Configure AWS CLI**
aws configure

* Access Key
* Secret Key
* Region (e.g., us-west-2)
* Output format (json)

### 🏗️ **Step 3: Apply Terraform to Create Infra (EKS + RDS)**

cd terraform/

terraform init
terraform plan
terraform apply -auto-approve

✅ After successful apply:

* EKS cluster is created
* RDS (Postgres or MySQL) is created
* Terraform output gives EKS name and DB endpoint

### ☸️ **Step 4: Connect kubectl to EKS**

```bash
aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION>
kubectl get nodes
```

### 🐳 **Step 5: Build and Push Docker Images (Frontend + Backend)**

1. Create a free [DockerHub](https://hub.docker.com/) account if you don’t have one.
# Build and push frontend
cd ../frontend/
docker build -t yourdockerhub/frontend-app .
docker push yourdockerhub/frontend-app

# Build and push backend
cd ../backend/
docker build -t yourdockerhub/backend-app .
docker push yourdockerhub/backend-app


✅ You can also use **ECR** instead of DockerHub (ask if you want those steps too).

### ⚙️ **Step 6: Update K8s manifests with correct image names**

In:

* `frontend-deployment.yaml` → `image: yourdockerhub/frontend-app`
* `backend-deployment.yaml` → `image: yourdockerhub/backend-app`

Also update:

* `configmap.yaml` with correct `DB_HOST`, etc.
* `secrets.yaml` with `DB_USER`, `DB_PASSWORD`

### ☸️ **Step 7: Apply Kubernetes Manifests**
cd ../k8s-manifests/

kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f ingress.yaml


### 🌐 **Step 8: Access Your App**
If you're using an Ingress Controller + LoadBalancer (e.g., NGINX ingress), check:

kubectl get svc -n ingress-nginx

Find External IP and map your domain to it in DNS.

Then access:
https://dhaiskar-abhi.shop

## ✅ Optional Enhancements
* Use **ArgoCD** for GitOps deployment
* Add **HTTPS with Let's Encrypt** and **cert-manager**
* Setup **CI/CD with GitHub Actions**
