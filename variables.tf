variable "monitor_diagnostic_setting" {
  type        = any
  default     = {}
  description = "resource definition, default settings are defined within locals and merged with var settings"
}

locals {
  default = {
    # resource definition
    monitor_diagnostic_setting = {
      name                           = ""
      eventhub_name                  = null
      eventhub_authorization_rule_id = null
      log_analytics_workspace_id     = null
      log_analytics_destination_type = null
      storage_account_id             = null
      log = {
        category         = []
        enabled          = false
        retention_policy = {}
      }
      metric = {
        category         = []
        enabled          = false
        retention_policy = {}
      }
    }
  }

  # compare and merge custom and default values
  monitor_diagnostic_setting_values = {
    for monitor_diagnostic_setting in keys(var.monitor_diagnostic_setting) :
    monitor_diagnostic_setting => merge(local.default.monitor_diagnostic_setting, var.monitor_diagnostic_setting[monitor_diagnostic_setting])
  }
  # merge all custom and default values
  monitor_diagnostic_setting = {
    for monitor_diagnostic_setting in keys(var.monitor_diagnostic_setting) :
    monitor_diagnostic_setting => merge(
      local.monitor_diagnostic_setting_values[monitor_diagnostic_setting],
      {
        for config in ["log", "metric"] :
        config => merge(local.default.monitor_diagnostic_setting[config], local.monitor_diagnostic_setting_values[monitor_diagnostic_setting][config])
      }
    )
  }
}
