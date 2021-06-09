##################################################
# Provider
##################################################

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

##################################################
# locals for tagging
##################################################
locals {
  common_tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Cost_center = "${var.cost_center}"
    Application = "${var.app_name}"
  }
}

##################################################
# Azure resource group
##################################################
resource "azurerm_resource_group" "rg" {
  name = "${var.environment}-${var.app_name}-rg"
  location = "${var.location}"
}

##################################################
# Azure Vnet
##################################################
data "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-${var.app_name}-vnet"
  resource_group_name = "${var.environment}-${var.app_name}-network-rg"
}

##################################################
# Azure Subnet
##################################################
data "azurerm_subnet" "subnet" {
  name                 = "${var.environment}-${var.app_name}-subnet"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.vnet.resource_group_name}"
}

##################################################
# Application security group
##################################################
resource "azurerm_application_security_group" "asg" {
  name                = "${var.environment}-${var.app_name}-asg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = "${local.common_tags}"
}


##################################################
# Azure Private DNS Zone
##################################################

resource "azurerm_private_dns_zone" "pvtdns" {
  name                = "laya.privatelink.eastus2.azmk8s.io"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

##################################################
# Azure Kubernetes Cluster
##################################################

resource "azurerm_kubernetes_cluster" "aks" {

  name                            = coalesce("${var.environment}",local.app_name)-cluster
  resource_group_name             = "${azurerm_resource_group.rg.name}"
  location                        = "${var.location}"
  dns_prefix_private_cluster      = "${var.app_name}"

### (Optional - Enabling To create pvt aks cluster)
  private_cluster_enabled = true
  private_dns_zone_id     = "${azurerm_private_dns_zone.pvtdns.id}"
  kubernetes_version              = "${k8s_version}"

### (For Additional Security)
  #±± api_server_authorized_ip_ranges = "${var.authorized_ip_addresses}"
  #±± node_resource_group             = "${azurerm_resource_group.rg.name}"


  #### (Optional Role based access implementation)

    role_based_access_control {
    enabled = true

    azure_active_directory {
      managed                = true
      tenant_id              = "${var.aad_tenant_id}"
      admin_group_object_ids = ["${var.aad_admin_group}"]
    }
  }


### Default node pool

  default_node_pool {
    name                = "${var.defaultpool_name}"
    node_count          = "${var.defaultpool_nodecount}"
    vm_size             = "${var.default_node_vmsize}"
    vnet_subnet_id      = "${data.azurerm_subnet.subnet.id}"

    #### Findout (Optional)
    #±± availability_zones  = "${var.availability_zones}"
    #±± enable_auto_scaling = "${var.deault_node_enable_auto_scaling}"
    #±± min_count           = "${var.default_node_min_count}"
    #±± max_count           = "${var.default_node_max_count}"
    #±± max_pods            = "${var.default_node_max_pods}"
    #±± type                = "${var.default_node_type}"
    #±± os_disk_size_gb     = "${var.default_node_os_disk_size_gb}"
    #±± orchestrator_version = "${var.defaultpool.k8s_version}"
  

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "192.168.1.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "192.168.1.0/24"
    load_balancer_sku  = "standard"
  }

  addon_profile {
    #±± (Optional)
    #oms_agent {
    #  enabled                    = "true"
    #  log_analytics_workspace_id = "laya_funapp_workspace"
    #}
    kube_dashboard {
      enabled = true
    }
    azure_policy {
      enabled = true
    }
  }
}
##################################################
# Azure Kubernetes Node Pool
##################################################

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  
  kubernetes_cluster_id = "${azurerm_kubernetes_cluster.aks.id}"
  name                  = "${var.nodepoolname}"
  vm_size               = "${var.nodepool_vmsize}"
  vnet_subnet_id        = "${data.azurerm_subnet.subnet.id}"
  enable_auto_scaling   = "${var.enable_auto_scaling}"
  node_count            = "${var.nodepool_count}"
  min_count             = "${var.nodepool_min_count}"
  max_count             = "${var.nodepool_max_count}"

  ### Check (Optional)
  #±± os_type               = "${var.os_type}"
  #±± os_disk_size_gb       = "${var.os_disk_size_gb}"
  #±± enable_node_public_ip = "${var.enable_node_public_ip}"
  #±± availability_zones    = "${var.availability_zones}"
  #±± orchestrator_version = "${var.nodepools.k8s_version}"
  #±± priority             = "${var.nodepools.priority}"

}

##################################################
# AKS RBAC
##################################################
### Uncomment before running and also needs the tenant variable needs to be filled on the variable file

#±± resource "azurerm_role_assignment" "subnetrole" {
#±±   principal_id         = "{azurerm_kubernetes_cluster.aks.kubelet_identity.object_id}"
#±±   scope                = "{data.azurerm_subnet.subnet.id}"
#±±   role_definition_name = "Network Contributor"
#±± }

#±± resource "azurerm_role_assignment" "pvtdnsrole" {
#±±   principal_id         = "{azurerm_kubernetes_cluster.aks.kubelet_identity.object_id}"
#±±   scope                = "${azurerm_private_dns_zone.pvtdns.id}"
#±±   role_definition_name = "Private DNS Zone Contributor"
#±± }


##################################################
# ACR Details
##################################################

data "azurerm_container_registry" "acr" {
  name                = "${var.registry}"
  resource_group_name = "${var.registry_rg}"
}