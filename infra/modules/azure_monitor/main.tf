# Action Group
resource "azurerm_monitor_action_group" "action_group" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  enabled             = var.action_group_enabled

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  tags = var.tags
}

# Resource Health Alert (Scheduled Query Rule)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_health_alert" {
  name                = var.resource_health_alert_name
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency    = var.resource_health_evaluation_frequency
  window_duration         = var.resource_health_window_duration
  scopes                  = var.resource_health_scopes
  severity                = var.resource_health_severity
  enabled                 = var.resource_health_enabled
  description             = var.resource_health_alert_name
  auto_mitigation_enabled = var.resource_health_auto_mitigation

  criteria {
    query                   = var.resource_health_query
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }

    resource_id_column = "_ResourceId"
  }

  action {
    action_groups = [azurerm_monitor_action_group.action_group.id]
  }

  tags = var.tags
}

# Service Health Alert 01
resource "azurerm_monitor_activity_log_alert" "service_health_alert_01" {
  name                = var.service_health_alert_01_name
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = var.service_health_scopes
  enabled             = var.service_health_01_enabled

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = var.service_health_01_events
      locations = var.service_health_01_locations
      services  = var.service_health_01_services
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = var.tags
}

# Service Health Alert 02
resource "azurerm_monitor_activity_log_alert" "service_health_alert_02" {
  name                = var.service_health_alert_02_name
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = var.service_health_scopes
  enabled             = var.service_health_02_enabled

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = var.service_health_02_events
      locations = var.service_health_02_locations
      services  = var.service_health_02_services
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = var.tags
}
