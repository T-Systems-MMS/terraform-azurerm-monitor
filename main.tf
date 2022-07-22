/**
 * # monitor
 *
 * This module manages Azure Monitor and Diagnostic.
 *
*/
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = var.monitor_diagnostic_setting

  name                           = local.monitor_diagnostic_setting[each.key].name == "" ? each.key : local.monitor_diagnostic_setting[each.key].name
  target_resource_id             = local.monitor_diagnostic_setting[each.key].target_resource_id
  eventhub_name                  = local.monitor_diagnostic_setting[each.key].eventhub_name
  eventhub_authorization_rule_id = local.monitor_diagnostic_setting[each.key].eventhub_authorization_rule_id
  log_analytics_workspace_id     = local.monitor_diagnostic_setting[each.key].log_analytics_workspace_id
  log_analytics_destination_type = local.monitor_diagnostic_setting[each.key].log_analytics_destination_type
  storage_account_id             = local.monitor_diagnostic_setting[each.key].storage_account_id

  dynamic "log" {
    for_each = local.monitor_diagnostic_setting[each.key].log.category

    content {
      category = local.monitor_diagnostic_setting[each.key].log.category[log.key]
      enabled  = local.monitor_diagnostic_setting[each.key].log.enabled

      retention_policy {
        days    = local.monitor_diagnostic_setting[each.key].log.retention_policy.days
        enabled = local.monitor_diagnostic_setting[each.key].log.retention_policy.enabled
      }
    }
  }
  dynamic "metric" {
    for_each = local.monitor_diagnostic_setting[each.key].metric.category

    content {
      category = local.monitor_diagnostic_setting[each.key].metric.category[metric.key]
      enabled  = local.monitor_diagnostic_setting[each.key].metric.enabled

      retention_policy {
        days    = local.monitor_diagnostic_setting[each.key].metric.retention_policy.days
        enabled = local.monitor_diagnostic_setting[each.key].metric.retention_policy.enabled
      }
    }
  }

  /** disable all other available categories */
  dynamic "log" {
    for_each = setsubtract(data.azurerm_monitor_diagnostic_categories.monitor_diagnostic_categories[each.key].logs, local.monitor_diagnostic_setting[each.key].log.category)

    content {
      category = log.key
      enabled  = false
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
  dynamic "metric" {
    for_each = setsubtract(data.azurerm_monitor_diagnostic_categories.monitor_diagnostic_categories[each.key].metrics, local.monitor_diagnostic_setting[each.key].metric.category)

    content {
      category = metric.key
      enabled  = false
      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }
}

resource "azurerm_monitor_action_group" "monitor_action_group" {
  for_each = var.monitor_action_group

  name                = local.monitor_action_group[each.key].name == "" ? each.key : local.monitor_action_group[each.key].name
  resource_group_name = local.monitor_action_group[each.key].resource_group_name
  short_name          = local.monitor_action_group[each.key].short_name == "" ? each.key : local.monitor_action_group[each.key].short_name
  enabled             = local.monitor_action_group[each.key].enabled

  # dynamic "arm_role_receiver" {
  #   for_each = local.monitor_action_group[each.key].arm_role_receiver
  #   content {
  #     name                    = local.monitor_action_group[each.key].arm_role_receiver[arm_role_receiver.key].name == "" ? arm_role_receiver.key : local.monitor_action_group[each.key].arm_role_receiver[arm_role_receiver.key].name
  #     role_id                 = local.monitor_action_group[each.key].arm_role_receiver[arm_role_receiver.key].role_id
  #     use_common_alert_schema = local.monitor_action_group[each.key].arm_role_receiver[arm_role_receiver.key].use_common_alert_schema
  #   }
  # }

  dynamic "email_receiver" {
    for_each = local.monitor_action_group[each.key].email_receiver
    content {
      name                    = local.monitor_action_group[each.key].email_receiver[email_receiver.key].name == "" ? email_receiver.key : local.monitor_action_group[each.key].email_receiver[email_receiver.key].name
      email_address           = local.monitor_action_group[each.key].email_receiver[email_receiver.key].email_address
      use_common_alert_schema = local.monitor_action_group[each.key].email_receiver[email_receiver.key].use_common_alert_schema
    }
  }

  # dynamic "event_hub_receiver" {
  #   for_each = local.monitor_action_group[each.key].event_hub_receiver
  #   content {
  #     name                    = local.monitor_action_group[each.key].event_hub_receiver[event_hub_receiver.key].name == "" ? event_hub_receiver.key : local.monitor_action_group[each.key].event_hub_receiver[event_hub_receiver.key].name
  #     event_hub_id                  = local.monitor_action_group[each.key].event_hub_receiver[event_hub_receiver.key].event_hub_id
  #     tenant_id = local.monitor_action_group[each.key].event_hub_receiver[event_hub_receiver.key].tenant_id
  #     use_common_alert_schema = local.monitor_action_group[each.key].event_hub_receiver[event_hub_receiver.key].use_common_alert_schema
  #   }
  # }

  tags = local.monitor_action_group[each.key].tags
}

resource "azurerm_monitor_activity_log_alert" "monitor_activity_log_alert" {
  for_each = var.monitor_activity_log_alert

  name                = local.monitor_activity_log_alert[each.key].name == "" ? each.key : local.monitor_activity_log_alert[each.key].name
  resource_group_name = local.monitor_activity_log_alert[each.key].resource_group_name
  scopes              = local.monitor_activity_log_alert[each.key].scopes
  enabled             = local.monitor_activity_log_alert[each.key].enabled
  description         = local.monitor_activity_log_alert[each.key].description

  dynamic "criteria" {
    for_each = local.monitor_activity_log_alert[each.key].criteria

    content {
      category                = local.monitor_activity_log_alert[each.key].criteria[criteria.key].category
      operation_name          = local.monitor_activity_log_alert[each.key].criteria[criteria.key].operation_name
      resource_provider       = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_provider
      resource_type           = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_type
      resource_group          = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_group
      resource_id             = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_id
      caller                  = local.monitor_activity_log_alert[each.key].criteria[criteria.key].caller
      level                   = local.monitor_activity_log_alert[each.key].criteria[criteria.key].level
      status                  = local.monitor_activity_log_alert[each.key].criteria[criteria.key].status
      sub_status              = local.monitor_activity_log_alert[each.key].criteria[criteria.key].sub_status
      recommendation_type     = local.monitor_activity_log_alert[each.key].criteria[criteria.key].recommendation_type
      recommendation_category = local.monitor_activity_log_alert[each.key].criteria[criteria.key].recommendation_category
      recommendation_impact   = local.monitor_activity_log_alert[each.key].criteria[criteria.key].recommendation_impact

      dynamic "resource_health" {
        for_each = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_health != {} ? [1] : []

        content {
          current  = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_health.current
          previous = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_health.previous
          reason   = local.monitor_activity_log_alert[each.key].criteria[criteria.key].resource_health.reason
        }
      }

      dynamic "service_health" {
        for_each = local.monitor_activity_log_alert[each.key].criteria[criteria.key].service_health != {} ? [1] : []

        content {
          events    = local.monitor_activity_log_alert[each.key].criteria[criteria.key].service_health.events
          locations = local.monitor_activity_log_alert[each.key].criteria[criteria.key].service_health.locations
          services  = local.monitor_activity_log_alert[each.key].criteria[criteria.key].service_health.services
        }
      }
    }
  }

  dynamic "action" {
    for_each = local.monitor_activity_log_alert[each.key].action

    content {
      action_group_id    = local.monitor_activity_log_alert[each.key].action[action.key].action_group_id
      webhook_properties = local.monitor_activity_log_alert[each.key].action[action.key].webhook_properties
    }
  }

  tags = local.monitor_activity_log_alert[each.key].tags
}

resource "azurerm_monitor_scheduled_query_rules_alert" "monitor_scheduled_query_rules_alert" {
  for_each = var.monitor_scheduled_query_rules_alert

  name                    = local.monitor_scheduled_query_rules_alert[each.key].name == "" ? each.key : local.monitor_scheduled_query_rules_alert[each.key].name
  resource_group_name     = local.monitor_scheduled_query_rules_alert[each.key].resource_group_name
  location                = local.monitor_scheduled_query_rules_alert[each.key].location
  data_source_id          = local.monitor_scheduled_query_rules_alert[each.key].data_source_id
  frequency               = local.monitor_scheduled_query_rules_alert[each.key].frequency
  query                   = local.monitor_scheduled_query_rules_alert[each.key].query
  time_window             = local.monitor_scheduled_query_rules_alert[each.key].time_window
  authorized_resource_ids = local.monitor_scheduled_query_rules_alert[each.key].authorized_resource_ids
  auto_mitigation_enabled = local.monitor_scheduled_query_rules_alert[each.key].auto_mitigation_enabled
  description             = local.monitor_scheduled_query_rules_alert[each.key].description
  enabled                 = local.monitor_scheduled_query_rules_alert[each.key].enabled
  severity                = local.monitor_scheduled_query_rules_alert[each.key].severity
  throttling              = local.monitor_scheduled_query_rules_alert[each.key].throttling

  action {
    action_group           = local.monitor_scheduled_query_rules_alert[each.key].action.action_group
    custom_webhook_payload = local.monitor_scheduled_query_rules_alert[each.key].action.custom_webhook_payload
    email_subject          = local.monitor_scheduled_query_rules_alert[each.key].action.email_subject
  }

  trigger {
    operator  = local.monitor_scheduled_query_rules_alert[each.key].trigger.operator
    threshold = local.monitor_scheduled_query_rules_alert[each.key].trigger.threshold

    dynamic "metric_trigger" {
      for_each = local.monitor_scheduled_query_rules_alert[each.key].trigger.metric_trigger != {} ? [1] : []

      content {
        metric_column       = local.monitor_scheduled_query_rules_alert[each.key].trigger.metric_trigger.metric_column
        metric_trigger_type = local.monitor_scheduled_query_rules_alert[each.key].trigger.metric_trigger.metric_trigger_type
        operator            = local.monitor_scheduled_query_rules_alert[each.key].trigger.metric_trigger.operator
        threshold           = local.monitor_scheduled_query_rules_alert[each.key].trigger.metric_trigger.threshold
      }
    }
  }
}
