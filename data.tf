data "azurerm_monitor_diagnostic_categories" "monitor_diagnostic_categories" {
  for_each    = var.monitor_diagnostic_setting
  resource_id = local.monitor_diagnostic_setting[each.key].target_resource_id
}
