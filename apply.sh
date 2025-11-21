#!/bin/bash

# Exit on any error
set -e

echo "======================================"
echo "Datadog Deployment Script for EKS"
echo "======================================"
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ Error: terraform.tfvars not found!"
    echo ""
    echo "Please create terraform.tfvars from terraform.tfvars.example:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo ""
    echo "Then edit terraform.tfvars with your Datadog API key and configuration."
    exit 1
fi

# Check if DATADOG_API_KEY is set in terraform.tfvars
if grep -q "<YOUR_DATADOG_API_KEY>" terraform.tfvars 2>/dev/null; then
    echo "❌ Error: Datadog API Key not configured!"
    echo ""
    echo "Please edit terraform.tfvars and set your Datadog API key:"
    echo "  datadog_api_key = \"your-actual-api-key\""
    echo ""
    echo "Get your API key from: https://app.datadoghq.com/organization-settings/api-keys"
    exit 1
fi

echo "Step 1: Initializing Terraform..."
terraform init
echo "✅ Terraform initialized"
echo ""

echo "Step 2: Validating Terraform configuration..."
terraform validate
if [ $? -eq 0 ]; then
    echo "✅ Configuration is valid"
else
    echo "❌ Configuration validation failed"
    exit 1
fi
echo ""

echo "Step 3: Planning deployment..."
terraform plan -out=tfplan
echo "✅ Plan created"
echo ""

echo "Step 4: Applying configuration..."
read -p "Do you want to proceed with the deployment? (yes/no): " confirmation

if [ "$confirmation" = "yes" ]; then
    terraform apply tfplan
    echo "✅ Deployment completed"
    echo ""
    
    echo "======================================"
    echo "Datadog Deployment Summary"
    echo "======================================"
    echo ""
    
    # Get outputs
    echo "📊 Datadog Dashboard URLs:"
    terraform output -raw datadog_dashboard_url
    echo ""
    terraform output -raw datadog_logs_url
    echo ""
    terraform output -raw datadog_apm_url
    echo ""
    echo ""
    
    echo "📋 Useful Commands:"
    terraform output -raw deployment_commands
    echo ""
    echo ""
    
    echo "🔍 Next Steps:"
    echo "1. Wait 2-3 minutes for agents to start collecting data"
    echo "2. Visit Datadog dashboard to view your cluster"
    echo "3. Check agent status: kubectl get pods -n datadog"
    echo "4. View logs in Datadog Logs Explorer"
    echo ""
    
    # Clean up plan file
    rm -f tfplan
else
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 1
fi
