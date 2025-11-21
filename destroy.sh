#!/bin/bash

# Exit on any error
set -e

echo "======================================"
echo "Datadog Destruction Script for EKS"
echo "======================================"
echo ""

echo "⚠️  WARNING: This will destroy all Datadog resources!"
echo ""
read -p "Are you sure you want to destroy all resources? (yes/no): " confirmation

if [ "$confirmation" = "yes" ]; then
    echo ""
    echo "Step 1: Planning destruction..."
    terraform plan -destroy -out=destroy.tfplan
    echo "✅ Destruction plan created"
    echo ""
    
    read -p "Proceed with destruction? Type 'destroy' to confirm: " final_confirmation
    
    if [ "$final_confirmation" = "destroy" ]; then
        echo ""
        echo "Step 2: Destroying resources..."
        terraform apply destroy.tfplan
        echo "✅ Resources destroyed"
        echo ""
        
        # Clean up plan file
        rm -f destroy.tfplan
        
        echo "🧹 Cleanup complete!"
        echo ""
        echo "Note: If you created an EKS cluster, it has been destroyed."
        echo "If you were using an existing cluster, only Datadog components were removed."
    else
        echo "❌ Destruction cancelled"
        rm -f destroy.tfplan
        exit 1
    fi
else
    echo "❌ Destruction cancelled"
    exit 1
fi
