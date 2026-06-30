terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.resource_group_name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.resource_group_name}-nrg"
  oidc_issuer_enabled = true

  default_node_pool {
    name                 = var.node_pool_name
    vm_size              = "Standard_D2ps_v5"
    auto_scaling_enabled = true
    max_count            = 3
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}# to do: generate the ssh keys using tls_private_key
# upload the key to key vault

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
        key_data = trimspace(file(var.ssh_public_key))
    }
  }

  network_profile {
      network_plugin = "azure"
      load_balancer_sku = "standard"
  }

    
  }


