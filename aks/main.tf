
resource "random_string" "cluster_name" {
  length  = 18
  special = false
  upper   = false
  number  = false
}

/*
resource "azurerm_log_analytics_workspace" "test" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}
*/
resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "cap-${random_string.cluster_name.result}"
    location            = "${var.location}"
    resource_group_name = "${var.az_resource_group}"
    dns_prefix          = "${var.dns_prefix}"
    kubernetes_version  = "${var.k8s_version}"

    linux_profile {
        admin_username = "${var.agent_admin}"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.node_count}"
        vm_size         = "${var.machine_type}"
        os_type         = "Linux"
        os_disk_size_gb = "${var.disk_size_gb}"
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    tags = "${var.cluster_labels}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}
