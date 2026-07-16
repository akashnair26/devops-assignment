# Monitoring: Prometheus + Grafana
## Install order matters

1. Install `kube-prometheus-stack` *first**. It registers the `ServiceMonitor` CRD the app chart depends on.
2. Then install the `hello-world` app chart.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack-values.yaml \
  --set grafana.adminPassword="$(openssl rand -base64 24)"

helm install hello-world ../helm/hello-world -n hello-world --create-namespace
```

## Viewing

```bash
# Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```
