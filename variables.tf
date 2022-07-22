variable "monitor_diagnostic_setting" {
  type        = any
  default     = {}
  description = "resource definition, default settings are defined within locals and merged with var settings"
}
variable "monitor_action_group" {
  type        = any
  default     = {}
  description = "resource definition, default settings are defined within locals and merged with var settings"
}

variable "monitor_activity_log_alert" {
  type        = any
  default     = {}
  description = "resource definition, default settings are defined within locals and merged with var settings"
}

variable "monitor_scheduled_query_rules_alert" {
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
        category = []
        enabled  = false
        retention_policy = {
          days    = 0
          enabled = false
        }
      }
      metric = {
        category = []
        enabled  = false
        retention_policy = {
          days    = 0
          enabled = false
        }
      }
    }
    monitor_action_group = {
      name       = ""
      short_name = ""
      enabled    = true
      arm_role_receiver = {
        # name                          = ""
        # role_id = ""
        # use_common_alert_schema = null
      }
      email_receiver = {
        name                    = ""
        use_common_alert_schema = true
      }
      event_hub_receiver = {
        # name = ""
        # tenant_id = null
        # use_common_alert_schema = true
      }
      tags = {}
    }
    monitor_activity_log_alert = {
      name        = ""
      enabled     = true
      description = null
      criteria = {
        operation_name          = null
        resource_provider       = null
        resource_type           = null
        resource_group          = null
        resource_id             = null
        caller                  = null
        level                   = null
        status                  = null
        sub_status              = null
        recommendation_type     = null
        recommendation_category = null
        recommendation_impact   = null
        resource_health         = {}
        service_health          = {}
      }
      action = {
        webhook_properties = null
      }
      tags = {}
    }
    monitor_scheduled_query_rules_alert = {
      name                    = ""
      frequency               = 60
      time_window             = 60
      authorized_resource_ids = null
      auto_mitigation_enabled = null
      description             = null
      enabled                 = true
      severity                = null
      throttling              = null
      action = {
        custom_webhook_payload = null
        email_subject          = null
      }
      trigger = {
        threshold      = 0
        metric_trigger = {}
      }
    }
  }

  # compare and merge custom and default values
  monitor_diagnostic_setting_values = {
    for monitor_diagnostic_setting in keys(var.monitor_diagnostic_setting) :
    monitor_diagnostic_setting => merge(local.default.monitor_diagnostic_setting, var.monitor_diagnostic_setting[monitor_diagnostic_setting])
  }
  monitor_action_group_values = {
    for monitor_action_group in keys(var.monitor_action_group) :
    monitor_action_group => merge(local.default.monitor_action_group, var.monitor_action_group[monitor_action_group])
  }
  monitor_activity_log_alert_values = {
    for monitor_activity_log_alert in keys(var.monitor_activity_log_alert) :
    monitor_activity_log_alert => merge(local.default.monitor_activity_log_alert, var.monitor_activity_log_alert[monitor_activity_log_alert])
  }
  monitor_scheduled_query_rules_alert_values = {
    for monitor_scheduled_query_rules_alert in keys(var.monitor_scheduled_query_rules_alert) :
    monitor_scheduled_query_rules_alert => merge(local.default.monitor_scheduled_query_rules_alert, var.monitor_scheduled_query_rules_alert[monitor_scheduled_query_rules_alert])
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
  monitor_action_group = {
    for monitor_action_group in keys(var.monitor_action_group) :
    monitor_action_group => merge(
      local.monitor_action_group_values[monitor_action_group],
      {
        for config in ["email_receiver"] :
        config => {
          for key in keys(local.monitor_action_group_values[monitor_action_group][config]) :
          key => merge(local.default.monitor_action_group[config], local.monitor_action_group_values[monitor_action_group][config][key])
        }
      }
    )
  }
  monitor_activity_log_alert = {
    for monitor_activity_log_alert in keys(var.monitor_activity_log_alert) :
    monitor_activity_log_alert => merge(
      local.monitor_activity_log_alert_values[monitor_activity_log_alert],
      {
        for config in ["criteria", "action"] :
        config => {
          for key in keys(local.monitor_activity_log_alert_values[monitor_activity_log_alert][config]) :
          key => merge(local.default.monitor_activity_log_alert[config], local.monitor_activity_log_alert_values[monitor_activity_log_alert][config][key])
        }
      }
    )
  }
  monitor_scheduled_query_rules_alert = {
    for monitor_scheduled_query_rules_alert in keys(var.monitor_scheduled_query_rules_alert) :
    monitor_scheduled_query_rules_alert => merge(
      local.monitor_scheduled_query_rules_alert_values[monitor_scheduled_query_rules_alert],
      {
        for config in ["action", "trigger"] :
        config => merge(local.default.monitor_scheduled_query_rules_alert[config], local.monitor_scheduled_query_rules_alert_values[monitor_scheduled_query_rules_alert][config])
      }
    )
  }
}
