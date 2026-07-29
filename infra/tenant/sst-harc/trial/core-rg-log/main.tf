# -----------------------------------------------------------------------------
# 1. Resource Group
# -----------------------------------------------------------------------------

module "common" {
  source = "../../../../modules/common"

  # parameters
  resource_group_name = local.resource_group_name
  location            = local.rg_location

  # タグ
  tags = local.tags
}

# -----------------------------------------------------------------------------
# 2. Log Analytics Workspace
# -----------------------------------------------------------------------------

module "log_analytics" {
  source = "../../../../modules/log_analytics"

  resource_group_name = module.common.resource_group_name
  location_name       = var.location_log_analytics
  log_name            = local.log_name
  tags                = local.tags

  depends_on = [module.common]
}
