# Create Datadog namespace
resource "kubernetes_namespace" "datadog" {
  metadata {
    name = var.datadog_namespace
    labels = {
      name = var.datadog_namespace
    }
  }
}

# Create Kubernetes secret for Datadog API keys
resource "kubernetes_secret" "datadog_api_key" {
  metadata {
    name      = "datadog-secret"
    namespace = kubernetes_namespace.datadog.metadata[0].name
  }

  data = {
    api-key = var.datadog_api_key
    app-key = var.datadog_app_key
  }

  type = "Opaque"
}

# Deploy Datadog Agent using Helm chart
resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = kubernetes_namespace.datadog.metadata[0].name
  version    = var.datadog_helm_chart_version != "" ? var.datadog_helm_chart_version : null

  # Datadog Site and API Keys
  set {
    name  = "datadog.apiKeyExistingSecret"
    value = kubernetes_secret.datadog_api_key.metadata[0].name
  }

  set {
    name  = "datadog.site"
    value = var.datadog_site
  }

  # Cluster name for identification in Datadog
  set {
    name  = "datadog.clusterName"
    value = var.datadog_cluster_name != "" ? var.datadog_cluster_name : var.cluster_name
  }

  # Enable log collection
  set {
    name  = "datadog.logs.enabled"
    value = var.enable_logs
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = var.log_collection_config.container_collect_all
  }

  # Enable APM
  set {
    name  = "datadog.apm.portEnabled"
    value = var.enable_apm
  }

  # Enable process agent
  set {
    name  = "datadog.processAgent.enabled"
    value = var.enable_process_agent
  }

  set {
    name  = "datadog.processAgent.processCollection"
    value = var.enable_process_agent
  }

  # Enable cluster checks
  set {
    name  = "clusterAgent.enabled"
    value = var.enable_cluster_checks
  }

  # Cluster checks runner
  set {
    name  = "clusterChecksRunner.enabled"
    value = var.enable_cluster_checks
  }

  # Resource limits for agent
  set {
    name  = "agents.containers.agent.resources.requests.cpu"
    value = var.agent_resources_requests_cpu
  }

  set {
    name  = "agents.containers.agent.resources.requests.memory"
    value = var.agent_resources_requests_memory
  }

  set {
    name  = "agents.containers.agent.resources.limits.cpu"
    value = var.agent_resources_limits_cpu
  }

  set {
    name  = "agents.containers.agent.resources.limits.memory"
    value = var.agent_resources_limits_memory
  }

  # Enable Kubernetes state metrics
  set {
    name  = "datadog.kubeStateMetricsEnabled"
    value = var.enable_metrics
  }

  # Enable orchestrator explorer
  set {
    name  = "datadog.orchestratorExplorer.enabled"
    value = true
  }

  # Enable network monitoring
  set {
    name  = "datadog.networkMonitoring.enabled"
    value = true
  }

  # Enable live container monitoring
  set {
    name  = "datadog.containerExclude"
    value = join(" ", var.log_collection_config.container_exclude)
  }

  # Enable DogStatsD
  set {
    name  = "datadog.dogstatsd.useHostPort"
    value = true
  }

  # Use values file for additional configuration
  values = [
    templatefile("${path.module}/helm-values/datadog-values.yaml", {
      DATADOG_CLUSTER_NAME = var.datadog_cluster_name != "" ? var.datadog_cluster_name : var.cluster_name
      AWS_REGION           = var.aws_region
    })
  ]

  depends_on = [
    kubernetes_namespace.datadog,
    kubernetes_secret.datadog_api_key
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 600

  lifecycle {
    ignore_changes = [
      version
    ]
  }
}

# Deploy Kube State Metrics (if not already present)
resource "helm_release" "kube_state_metrics" {
  count      = var.enable_metrics ? 1 : 0
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = kubernetes_namespace.datadog.metadata[0].name
  version    = "5.15.2"

  set {
    name  = "prometheus.monitor.enabled"
    value = false
  }

  depends_on = [
    kubernetes_namespace.datadog
  ]

  wait    = true
  timeout = 300
}
