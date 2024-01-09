variable "kube_config_context" {
  description = "Kubernetes context to use for deployment"
  default     = "portfolio"
}
variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "kubeconfig"
}