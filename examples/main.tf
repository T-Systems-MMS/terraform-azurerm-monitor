module "monitor" {
  source = "../modules/azure/terraform-monitor"
  monitor_diagnostic_setting = {
    virtual_network.name = {
      target_resource_id         = virtual_network.id
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
      metric = {
        category = ["AllMetrics"]
        enabled  = true
        retention_policy = {
          days    = 30
          enabled = true
        }
      }
    }
    frontdoor.name = {
      target_resource_id         = frontdoor.id
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
      log = {
        category = ["FrontdoorWebApplicationFirewallLog"]
        enabled  = true
        retention_policy = {
          days    = 30
          enabled = true
        }
      }
      metric = {
        category = ["AllMetrics"]
        enabled  = true
        retention_policy = {
          days    = 30
          enabled = true
        }
      }
    }
  }
}
