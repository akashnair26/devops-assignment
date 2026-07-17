## DevOps Take-Home: EKS + Hello World + Helm + Prometheus/Grafana

A Hello World HTTP microservice, running on AWS EKS cluster provisioned by Terraform. Prometheus and Grafana monitor the app and the cluster underneath it.

## Prerequisites


Node.js 20+ - Running/testing the app 
Docker - Building the container image 
Terraform >= 1.8
AWS CLI + credentials - `terraform apply`, `aws eks update-kubeconfig` 
kubectl - Interacting with the cluster 
Helm 3 - Installing the app and monitoring stack 

## Repository layout

```text
app/                Hello World Node.js microservice (native HTTP + prom-client)
terraform/          VPC + EKS + ECR
helm/hello-world/   Helm chart for the app (Deployment, Service, ServiceMonitor, Grafana dashboard)
monitoring/         kube-prometheus-stack
```

## Running it end-to-end

```bash
# 1. Provision the cluster (see terraform/README.md for details)
cd terraform
terraform init --upgrade
terraform plan --detailed-exitcode
terraform apply

aws eks update-kubeconfig --region ap-south-1 --name devops-assignment
kubectl get nodes   # confirm nodes are Ready before moving on
cd ..

# 2. Install monitoring FIRST (registers the ServiceMonitor CRD the app chart needs)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack-values.yaml \
  --set grafana.adminPassword="$(openssl rand -base64 24)"
# save that password, or retrieve it later -- see monitoring/README.md

# 3. Build and push the app image to the ECR repo Terraform created
REPO_URL=$(cd terraform && terraform output -raw ecr_repo_url)
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin "${REPO_URL%/*}"
docker build --platform linux/amd64 -t "$REPO_URL:v2" app/
docker push "$REPO_URL:v2"

# 4. Deploy the app into its own namespace
helm install hello-world ./helm/hello-world -n hello-world --create-namespace

# if you want to upgrade
helm upgrade hello-world ./helm/hello-world -n hello-world --set image.tag=v<number>

# 5. Verify
kubectl get pods -n hello-world
kubectl port-forward -n hello-world svc/hello-world 8080:80 &
curl localhost:8080/          # -> Hello World
curl localhost:8080/healthz   # -> {"status":"ok"}
curl localhost:8080/metrics   # -> Prometheus text format

kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
# open http://localhost:3000, log in, view the "Hello World Service" dashboard
```
