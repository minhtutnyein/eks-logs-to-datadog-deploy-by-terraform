# Quick Start Guide - Datadog on EKS

## Prerequisites Checklist

- [ ] Datadog account created at [datadoghq.com](https://www.datadoghq.com/)
- [ ] Datadog API key obtained
- [ ] AWS CLI configured
- [ ] kubectl configured for EKS cluster
- [ ] Terraform installed (>= 1.0)

## Step-by-Step Deployment

### 1. Get Your Datadog API Key

1. Log in to Datadog: https://app.datadoghq.com/
2. Navigate to: **Organization Settings** → **API Keys**
3. Click **New Key** or copy an existing key
4. Save the key securely

### 2. Prepare Configuration

```bash
cd eks-datadog-logs-deploy-by-terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
datadog_api_key = "paste-your-api-key-here"
aws_region      = "ap-northeast-1"
cluster_name    = "your-cluster-name"
aws_profile     = "your-aws-profile"
```

### 3. Deploy

```bash
chmod +x apply.sh
./apply.sh
```

### 4. Verify Deployment

Wait 2-3 minutes, then check:

```bash
# Check pods
kubectl get pods -n datadog

# Check agent status
kubectl exec -n datadog -it $(kubectl get pods -n datadog -l app=datadog -o jsonpath='{.items[0].metadata.name}') -- agent status
```

### 5. Access Datadog

Open your browser:
- **Infrastructure**: https://app.datadoghq.com/infrastructure
- **Logs**: https://app.datadoghq.com/logs
- **APM**: https://app.datadoghq.com/apm/traces

You should see your EKS cluster and logs flowing within 2-3 minutes.

## What Gets Deployed

```
datadog namespace
├── datadog-agent (DaemonSet)          # Runs on each node
│   └── Collects logs, metrics, traces
├── datadog-cluster-agent (Deployment) # Cluster-level monitoring
│   └── 2 replicas for HA
└── datadog-clusterchecks (Deployment) # Cluster checks
    └── 2 replicas for distributed checks
```

## Testing Log Collection

Deploy a test pod:
```bash
kubectl run test-nginx --image=nginx -n default
kubectl logs -f test-nginx
```

In Datadog Logs Explorer:
1. Filter: `kube_namespace:default`
2. Filter: `pod_name:test-nginx`
3. You should see nginx logs

## Next Steps

1. **Explore Dashboards**: Check out the Kubernetes dashboard
2. **Set Up Alerts**: Create monitors for important metrics
3. **Enable APM**: Instrument your applications for tracing
4. **Customize Tags**: Add custom tags in `helm-values/datadog-values.yaml`
5. **Review Costs**: Monitor usage in Datadog settings

## Common First-Time Issues

**No logs appearing?**
- Wait 2-3 minutes for initial sync
- Check agent status: `kubectl exec -n datadog ... -- agent status`
- Verify API key is correct

**Pods not starting?**
- Check API key: `kubectl get secret -n datadog datadog-secret -o yaml`
- View pod logs: `kubectl logs -n datadog <pod-name>`

**High costs?**
- Adjust log retention in Datadog UI
- Use log exclusion filters
- Disable unused features (APM, process monitoring)

## Support

- Documentation: https://docs.datadoghq.com/
- Community: https://www.datadoghq.com/community/
- This README: `README.md`
