/**
 * # monitor
 *
 * This module manages Azure Monitor and Diagnostic.
 *
*/
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = var.monitor_diagnostic_setting

  name = local.monitor_diagnostic_setting[each.key].name == "" ? each.key : local.monitor_diagnostic_setting[each.key].name

  target_resource_id         = local.monitor_diagnostic_setting[each.key].target_resource_id
  log_analytics_workspace_id = local.monitor_diagnostic_setting[each.key].log_analytics_workspace_id

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
