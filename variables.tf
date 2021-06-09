##### Global Variable #####

#### Tags ####

variable "owner" {
  type        = string
  description = "The name of the infra provisioner or owner"
  default     = "Prem"
}
variable "environment" {
  type        = string
  description = "The environment name"
  default = "dev"
}
variable "cost_center" {
  type        = string
  description = "The cost_center name for this project"
  default     = "laya-project"
}
variable "app_name" {
  type        = string
  description = "Application name of IFRS project"
  default     = "funapp"
}
variable "location" {
  type        = string
  description = "Cluster location, used for resource group too"
  default     = "northeurope"
}

#### Variables ####

variable "vm_size" {
  type        = string
  description = "Size of the vms to create for DNS"
  default     = "Standard_B16ms"
}
variable "sshkey" {
  type        = string
  description = "ssh key for the admin user"
  default     = ""
}
variable "dnsips" {
  type        = list(string)
  description = "List of IPs for the DNS VMs"
  default     = []
}
variable "zone_name" {
  type        = string
  description = "Zone name of the powerdns"
  default     = "analytics.atradiusnet.com"
}

variable "defaultpool_name" {
  type        = number
  description = "The name of default node"
  default = "laya-funapp"
}
variable "default_node_vmsize" {
  type        = string
  description = "The size of the default node"
  default = "Standard_D2_v2"
}
variable "defaultpool_nodecount" {
  type        = number
  description = "The number of node of the default node"
  default = 1
}

### For security reason I am leaving it blank pls fill in when you execute
#±± variable "aad_tenant_id" {
#±±   type        = string
#±±   description = "The tenant id where the active directory is maintained"
#±±   default = ""
#±± }
#±± variable "aad_admin_group" {
#±±   type        = string
#±±   description = "The active dir. group name"
#±±   default = ""
#±± }


### Node details ###

variable "nodepool_count" {
  type        = number
  description = "The number of node for pool"
  default = 1
}
variable "nodepool_vmsize" {
  type        = "string"
  description = "The VM size for nodepool"
  default = "Standard_B16ms"
}

variable "nodepool_min_count" {
  type        = number
  description = "The min no. of nodepool on auto scale"
  default = 1
}
variable "nodepool_max_count" {
  type        = number
  description = "The max no. of nodepool on auto scale"
  default = 2
}

variable "enable_auto_scaling" {
  type        = string
  description = "The define to turn on/off scale"
  default = true
}

### Service principal ###
variable "client_id" {
  type        = "string"
  description = "The SP client id for the cluster"
}
variable "client_secret" {
  type        = "string"
  description = "The SP client secret for the cluster"
}

### Network ###
variable "vnet_name" {
  type        = "string"
  description = "The core network environment vnet name"
}
variable "vnet_rg_name" {
  type        = "string"
  description = "The core network vnet resource group name"
}
variable "subnet_name" {
  type        = "string"
  description = "The cluster network subnet resource name"
}

### Kube version
variable "k8s_version" {
  type        = "string"
  description = "The version number of kuberents for the cluster"
  default     = "1.21.0"
}

### ACR Details
variable "registry" {
  type        = "string"
  description = "The name of the container registry"
  default     = "laya"
}

variable "registry_rg" {
  type        = "string"
  description = "The RG name of the container registry"
  default     = "laya_acr_rg"
}


