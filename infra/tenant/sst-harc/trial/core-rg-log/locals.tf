locals {
  # ✅ Resource Group
  resource_group_name = "rg-genashi-trial-${var.environment_prefix}"
  rg_location         = "japaneast"

  # ✅ Log Analytics Workspace
  log_name = "laws-genashi-trial-${var.environment_prefix}"

  # ✅ 共通タグ
  tags = {
    "機能名称" = "製造現場アシスタントAI"
    "環境"   = "本番"
  }
}
