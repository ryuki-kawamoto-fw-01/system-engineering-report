# Container Registry Module

Azure Container Registry を作成し、コンテナイメージを管理するための Terraform モジュールです。

## 機能

- Azure Container Registry の作成
- SKU 選択（Basic/Standard/Premium）
- ネットワークルール設定（Private Endpoint 対応）
- Geo レプリケーション（Premium SKU のみ）
- イメージ保持ポリシー（Premium SKU のみ）
- 信頼ポリシー（Premium SKU のみ）
- Quarantine ポリシー（Premium SKU のみ）
- Zone 冗長性（Premium SKU のみ）
- カスタマーマネージドキー暗号化（Premium SKU のみ）
- マネージドID サポート
- Log Analytics への診断ログ送信

## 使用例

### 基本構成（Standard SKU、Private Endpoint 使用）

```hcl
module "container_registry" {
  source = "../../modules/container_registry"

  container_registry_name           = "acrgenashtrial01"
  resource_group_name               = module.common.resource_group_name
  location                          = var.location
  sku                               = "Standard"
  admin_enabled                     = false
  public_network_access_enabled     = false
  log_analytics_workspace_id        = module.log_analytics.workspace_id

  tags = local.common_tags
}
```

### Premium SKU（Geo レプリケーション、保持ポリシー有効）

```hcl
module "container_registry" {
  source = "../../modules/container_registry"

  container_registry_name           = "acrgenashtrial01"
  resource_group_name               = module.common.resource_group_name
  location                          = var.location
  sku                               = "Premium"
  admin_enabled                     = false
  public_network_access_enabled     = false
  zone_redundancy_enabled           = true
  
  # Geo レプリケーション設定
  georeplications = [
    {
      location                  = "West US"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = false
      tags                      = local.common_tags
    }
  ]

  # イメージ保持ポリシー
  retention_policy_enabled = true
  retention_policy_days    = 14

  # セキュリティポリシー
  trust_policy_enabled      = true
  quarantine_policy_enabled = true

  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.common_tags
}
```

### ネットワークルール設定（特定IPのみ許可）

```hcl
module "container_registry" {
  source = "../../modules/container_registry"

  container_registry_name           = "acrgenashtrial01"
  resource_group_name               = module.common.resource_group_name
  location                          = var.location
  sku                               = "Premium"
  public_network_access_enabled     = true
  
  network_rule_set = {
    default_action = "Deny"
    ip_rule = [
      {
        action   = "Allow"
        ip_range = "203.0.113.0/24"
      },
      {
        action   = "Allow"
        ip_range = "198.51.100.10/32"
      }
    ]
  }

  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.common_tags
}
```

### マネージドID とカスタマーマネージドキー暗号化

```hcl
module "container_registry" {
  source = "../../modules/container_registry"

  container_registry_name           = "acrgenashtrial01"
  resource_group_name               = module.common.resource_group_name
  location                          = var.location
  sku                               = "Premium"
  public_network_access_enabled     = false

  # マネージドID
  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.acr.id
    ]
  }

  # 暗号化
  encryption = {
    enabled            = true
    key_vault_key_id   = azurerm_key_vault_key.acr.id
    identity_client_id = azurerm_user_assigned_identity.acr.client_id
  }

  log_analytics_workspace_id = module.log_analytics.workspace_id

  tags = local.common_tags
}
```

## 入力変数

| 変数名 | 説明 | 型 | デフォルト | 必須 |
|--------|------|------|-----------|------|
| `container_registry_name` | Container Registry の名前（5-50文字、英数字のみ） | `string` | - | Yes |
| `resource_group_name` | リソースグループ名 | `string` | - | Yes |
| `location` | リージョン | `string` | - | Yes |
| `sku` | SKU（Basic/Standard/Premium） | `string` | `"Standard"` | No |
| `admin_enabled` | 管理者アカウントを有効化するか | `bool` | `false` | No |
| `public_network_access_enabled` | パブリックネットワークアクセスを有効化するか | `bool` | `false` | No |
| `network_rule_set` | ネットワークルール設定 | `object` | `null` | No |
| `georeplications` | Geo レプリケーション設定（Premium のみ） | `list(object)` | `null` | No |
| `retention_policy_enabled` | イメージ保持ポリシー有効化（Premium のみ） | `bool` | `false` | No |
| `retention_policy_days` | イメージ保持日数（Premium のみ） | `number` | `7` | No |
| `trust_policy_enabled` | 信頼ポリシー有効化（Premium のみ） | `bool` | `false` | No |
| `quarantine_policy_enabled` | Quarantine ポリシー有効化（Premium のみ） | `bool` | `false` | No |
| `zone_redundancy_enabled` | Zone 冗長性有効化（Premium のみ） | `bool` | `false` | No |
| `encryption` | 暗号化設定（Premium のみ） | `object` | `null` | No |
| `identity` | マネージドID 設定 | `object` | `null` | No |
| `log_analytics_workspace_id` | Log Analytics Workspace ID | `string` | `null` | No |
| `log_retention_days` | ログ保持日数 | `number` | `30` | No |
| `log_categories` | 有効化するログカテゴリ | `list(string)` | `["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]` | No |
| `tags` | リソースタグ | `map(string)` | `{}` | No |

## 出力値

| 出力名 | 説明 |
|--------|------|
| `id` | Container Registry のリソース ID |
| `name` | Container Registry の名前 |
| `login_server` | Container Registry のログインサーバー URL |
| `admin_username` | 管理者ユーザー名（admin_enabled = true の場合） |
| `admin_password` | 管理者パスワード（admin_enabled = true の場合） |
| `identity_principal_id` | マネージドID プリンシパル ID |
| `identity_tenant_id` | マネージドID テナント ID |
| `resource_group_name` | リソースグループ名 |
| `location` | リージョン |
| `sku` | SKU |

## 設計思想

### セキュリティ

- デフォルトでパブリックアクセスを無効化（`public_network_access_enabled = false`）
- Private Endpoint 経由のアクセスを推奨
- 管理者アカウントはデフォルトで無効化（`admin_enabled = false`）
- マネージドID によるアクセス制御を推奨

### ログとモニタリング

- Log Analytics Workspace への診断ログ送信をサポート
- コンテナレジストリのイベントログを記録：
  - `ContainerRegistryRepositoryEvents`: リポジトリイベント（push/pull/delete）
  - `ContainerRegistryLoginEvents`: ログインイベント
- ログ保持期間はデフォルト30日

### SKU による機能差

- **Basic**: 小規模開発・テスト用、基本機能のみ
- **Standard**: 本番環境用、パフォーマンス向上
- **Premium**: 
  - Geo レプリケーション
  - Zone 冗長性
  - イメージ保持ポリシー
  - 信頼ポリシー
  - Quarantine ポリシー
  - カスタマーマネージドキー暗号化

### ネットワーク構成

- Private Endpoint を使用した閉域構成を推奨
- 必要に応じて IP ベースのアクセス制限も可能
- ネットワークルールは Deny ベースで特定 IP のみ許可する設計

## 注意事項

1. **レジストリ名の制約**:
   - グローバルでユニークである必要がある
   - 5-50文字の英数字のみ使用可能
   - ハイフンやアンダースコアは使用不可

2. **SKU 変更の制約**:
   - Basic → Standard/Premium へのアップグレードは可能
   - ダウングレードは不可（レジストリの再作成が必要）

3. **Premium 専用機能**:
   - Geo レプリケーション、Zone 冗長性、暗号化などは Premium SKU のみ
   - これらの機能を有効化する場合は `sku = "Premium"` を指定

4. **Private Endpoint**:
   - このモジュールは Private Endpoint の作成を含まない
   - 別途 `private_endpoint` モジュールを使用して作成する

## 関連リソース

- [Azure Container Registry ドキュメント](https://docs.microsoft.com/ja-jp/azure/container-registry/)
- [Terraform azurerm_container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)
