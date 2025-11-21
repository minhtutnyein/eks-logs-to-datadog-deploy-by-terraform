output "datadog_namespace" {
  description = "Kubernetes namespace for Datadog"
  value       = kubernetes_namespace.datadog.metadata[0].name
}

output "datadog_agent_status_command" {
  description = "Command to check Datadog agent status"
  value       = "kubectl exec -n ${var.datadog_namespace} -it $(kubectl get pods -n ${var.datadog_namespace} -l app=datadog -o jsonpath='{.items[0].metadata.name}') -- agent status"
}

output "datadog_dashboard_url" {
  description = "Datadog dashboard URL"
  value       = "https://app.${var.datadog_site}/infrastructure/map"
}

output "datadog_logs_url" {
  description = "Datadog logs explorer URL"
  value       = "https://app.${var.datadog_site}/logs"
}

output "datadog_apm_url" {
  description = "Datadog APM URL"
  value       = "https://app.${var.datadog_site}/apm/traces"
}

output "datadog_cluster_name" {
  description = "Cluster name used in Datadog"
  value       = var.datadog_cluster_name != "" ? var.datadog_cluster_name : var.cluster_name
}

output "deployment_commands" {
  description = "Useful commands for managing Datadog"
  value       = <<-EOT
    # Check Datadog agent pods
    kubectl get pods -n ${var.datadog_namespace} -l app=datadog

    # Check Datadog agent status
    kubectl exec -n ${var.datadog_namespace} -it $(kubectl get pods -n ${var.datadog_namespace} -l app=datadog -o jsonpath='{.items[0].metadata.name}') -- agent status

    # View Datadog agent logs
    kubectl logs -n ${var.datadog_namespace} -l app=datadog --tail=50

    # Check cluster agent status
    kubectl exec -n ${var.datadog_namespace} -it $(kubectl get pods -n ${var.datadog_namespace} -l app=datadog-cluster-agent -o jsonpath='{.items[0].metadata.name}') -- agent status

    # View all Datadog resources
    kubectl get all -n ${var.datadog_namespace}

    # Access Datadog Dashboard
    echo "Datadog Infrastructure: https://app.${var.datadog_site}/infrastructure"
    echo "Datadog Logs: https://app.${var.datadog_site}/logs"
    echo "Datadog APM: https://app.${var.datadog_site}/apm/traces"

    # Test log collection from a pod
    kubectl run test-log --image=busybox -n default -- sh -c "while true; do echo 'Test log from Kubernetes'; sleep 5; done"
  EOT
}

output "log_collection_status" {
  description = "Log collection configuration status"
  value = {
    enabled               = var.enable_logs
    container_collect_all = var.log_collection_config.container_collect_all
    container_exclude     = var.log_collection_config.container_exclude
    container_include     = var.log_collection_config.container_include
  }
}

output "monitoring_features" {
  description = "Enabled monitoring features"
  value = {
    logs           = var.enable_logs
    metrics        = var.enable_metrics
    apm            = var.enable_apm
    process_agent  = var.enable_process_agent
    cluster_checks = var.enable_cluster_checks
  }
}
