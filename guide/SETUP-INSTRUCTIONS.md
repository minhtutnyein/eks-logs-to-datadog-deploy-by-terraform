# Setup Instructions

Your `terraform.tfvars` file has been created with your AWS configuration!

## Next Steps

### 1. Get Your Datadog API Key

**Option A: If you already have a Datadog account**
1. Log in to https://app.datadoghq.com/
2. Go to **Organization Settings** → **API Keys**
3. Copy an existing key or create a new one

**Option B: If you need to create a Datadog account**
1. Sign up at https://www.datadoghq.com/free-datadog-trial/
2. Complete the registration
3. Get your API key from **Organization Settings** → **API Keys**

### 2. Update terraform.tfvars

Edit the file and replace the placeholder:

```bash
# Open the file in your editor
vi terraform.tfvars
# or
nano terraform.tfvars
```

Find this line:
```
datadog_api_key = "<YOUR_DATADOG_API_KEY>"
```

Replace with your actual API key:
```
datadog_api_key = "1234567890abcdef1234567890abcdef"
```

### 3. Verify Your EKS Cluster

Make sure you have an existing EKS cluster or set `create_eks_cluster = true` to create one:

```bash
# Check if you have a cluster
aws eks list-clusters --region ap-northeast-1 --profile dev-tf-admin

# If you have a cluster named "master-eks-cluster", configure kubectl:
aws eks update-kubeconfig --region ap-northeast-1 --name master-eks-cluster --profile dev-tf-admin

# Verify connection
kubectl get nodes
```

**If you don't have a cluster yet**, edit `terraform.tfvars` and change:
```
create_eks_cluster = true
```

### 4. Deploy Datadog

Once you've added your API key:

```bash
./apply.sh
```

This will:
- Initialize Terraform
- Show you the deployment plan
- Deploy Datadog agent to your cluster
- Display access information

### 5. Access Datadog Dashboard

After deployment (2-3 minutes), access Datadog at:
- **Infrastructure**: https://app.datadoghq.com/infrastructure
- **Logs**: https://app.datadoghq.com/logs
- **APM**: https://app.datadoghq.com/apm/traces

## Current Configuration

Your `terraform.tfvars` is configured with:

- **AWS Region**: ap-northeast-1
- **AWS Profile**: dev-tf-admin
- **Cluster Name**: master-eks-cluster
- **Datadog Site**: datadoghq.com (US region)
- **Create Cluster**: false (using existing cluster)

## Customization

You can customize the deployment by editing `terraform.tfvars`:

### Common Customizations

**Disable features you don't need:**
```hcl
enable_apm            = false  # Disable APM
enable_process_agent  = false  # Disable process monitoring
```

**Adjust resource limits:**
```hcl
agent_resources_limits_memory = "1Gi"  # Increase memory
```

**Exclude specific namespaces from log collection:**
```hcl
log_collection_config = {
  container_collect_all = true
  container_exclude     = [
    "name:datadog-agent",
    "kube_namespace:kube-system"
  ]
  container_include     = []
}
```

## Troubleshooting

### Error: "Datadog API Key not configured"
- Make sure you replaced `<YOUR_DATADOG_API_KEY>` with your actual API key
- No angle brackets or quotes around the key

### Error: "Cluster not found"
- Verify cluster exists: `aws eks list-clusters --region ap-northeast-1 --profile dev-tf-admin`
- Check cluster name matches in terraform.tfvars
- Or set `create_eks_cluster = true` to create a new cluster

### Error: "Access denied"
- Verify your AWS credentials: `aws sts get-caller-identity --profile dev-tf-admin`
- Ensure your IAM user/role has EKS permissions

## Documentation

- **README.md**: Complete documentation
- **guide/QUICKSTART.md**: Quick start guide
- **guide/TROUBLESHOOTING.md**: Detailed troubleshooting
- **guide/MIGRATION-FROM-ELK.md**: Migration from ELK stack

## Support

Need help? Check the documentation in the `guide/` folder or visit:
- Datadog Documentation: https://docs.datadoghq.com/
- Datadog Support: support@datadoghq.com

---

**Ready to deploy?** Add your Datadog API key to `terraform.tfvars` and run `./apply.sh`!
