resource "azurerm_private_endpoint" "this" {
	name                          = var.private_endpoint_name
	resource_group_name           = var.resource_group_name
	location                      = var.location
	subnet_id                     = var.subnet_id
	custom_network_interface_name = var.custom_network_interface_name

	private_service_connection {
		name                           = "${var.private_endpoint_name}-conn"
		private_connection_resource_id = var.private_connection_resource_id
		is_manual_connection           = false
		subresource_names              = var.subresource_names
	}

	# Private DNS Zone Group for DNS integration
	dynamic "private_dns_zone_group" {
		for_each = var.enable_private_dns_zone_group && length(var.private_dns_zone_ids) > 0 ? [1] : []
		content {
			name                 = var.private_dns_zone_group_name
			private_dns_zone_ids = var.private_dns_zone_ids
		}
	}

	tags = var.tags
}

