output "monitor_action_group" {
  description = "azurerm_monitor_action_group results"
  value = {
    for monitor_action_group in keys(azurerm_monitor_action_group.monitor_action_group) :
    monitor_action_group => {
      id   = azurerm_monitor_action_group.monitor_action_group[monitor_action_group].id
      name = azurerm_monitor_action_group.monitor_action_group[monitor_action_group].name
    }
  }
}
