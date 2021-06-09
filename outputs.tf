##########################
# Outputs
##########################

### AKS

output "aks_id" {
  description = "AKS resource id"
  value       = "${azurerm_kubernetes_cluster.aks.id}"
}

output "aks_nodes_pools_ids" {
  description = "Ids of AKS nodes pools"
  value       = "${azurerm_kubernetes_cluster_node_pool.node_pools.*.id}"
}

output "aks_nodes_pools_names" {
  description = "Names of AKS nodes pools"
  value       = "${azurerm_kubernetes_cluster_node_pool.node_pools.*.name}"
}

output "aks_kube_config_raw" {
  description = "Raw kube config to be used by kubectl command"
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
  sensitive   = true
}

output "aks_kube_config" {
  description = "Kube configuration of AKS Cluster"
  value       = "${azurerm_kubernetes_cluster.aks.kube_config}"
  sensitive   = true
}

output "aks_user_managed_identity" {
  value       = "${azurerm_kubernetes_cluster.aks.kubelet_identity}"
  description = "The User Managed Identity used by AKS Agents"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate}"
}