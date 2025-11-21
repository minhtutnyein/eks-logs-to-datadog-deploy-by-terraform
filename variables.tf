variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = ""
}

variable "datadog_namespace" {
  description = "Kubernetes namespace for Datadog components"
  type        = string
  default     = "datadog"
}

variable "datadog_api_key" {
  description = "Datadog API Key (required)"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application Key (optional, for advanced features)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  description = "Datadog site (datadoghq.com, datadoghq.eu, us3.datadoghq.com, us5.datadoghq.com, ap1.datadoghq.com, ddog-gov.com)"
  type        = string
  default     = ""
}

variable "datadog_cluster_name" {
  description = "Cluster name tag for Datadog (used to identify your cluster in Datadog UI)"
  type        = string
  default     = ""
}

variable "enable_logs" {
  description = "Enable log collection"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

variable "enable_apm" {
  description = "Enable APM (Application Performance Monitoring)"
  type        = bool
  default     = true
}

variable "enable_process_agent" {
  description = "Enable process monitoring"
  type        = bool
  default     = true
}

variable "enable_cluster_checks" {
  description = "Enable cluster-level checks"
  type        = bool
  default     = true
}

variable "datadog_helm_chart_version" {
  description = "Version of Datadog Helm chart"
  type        = string
  default     = "" # Latest by default
}

variable "agent_resources_requests_cpu" {
  description = "CPU request for Datadog agent"
  type        = string
  default     = ""
}

variable "agent_resources_requests_memory" {
  description = "Memory request for Datadog agent"
  type        = string
  default     = ""
}

variable "agent_resources_limits_cpu" {
  description = "CPU limit for Datadog agent"
  type        = string
  default     = ""
}

variable "agent_resources_limits_memory" {
  description = "Memory limit for Datadog agent"
  type        = string
  default     = ""
}

variable "enable_bookinfo_demo" {
  description = "Enable deployment of Istio Bookinfo demo application"
  type        = bool
  default     = false
}

variable "create_eks_cluster" {
  description = "Whether to create a new EKS cluster or use existing one"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = ""
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = ""
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "log_collection_config" {
  description = "Custom log collection configuration"
  type = object({
    container_collect_all = bool
    container_exclude     = list(string)
    container_include     = list(string)
  })
  default = {
    container_collect_all = true
    container_exclude     = ["name:datadog-agent"]
    container_include     = []
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
