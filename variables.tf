variable "" {
  type        = any
  default     = {}
  description = "resource definition, default settings are defined within locals and merged with var settings"
}

locals {
  default = {
    # resource definition
  }

  # compare and merge custom and default values
  # merge all custom and default values
}
