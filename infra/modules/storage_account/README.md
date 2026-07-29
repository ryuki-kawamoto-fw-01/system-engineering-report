# Storage Account Module

Storage Accountを作成し、ドキュメント・Function App用データを保管するTerraformモジュールです。

## 機能

- Azure Storage Accountの作成
- Blobコンテナの動的作成
- セキュアなネットワーク設定（Private Endpoint対応）
- Blob削除保護・バージョニング
- 変更フィード（Change Feed）の有効化
- Log Analyticsへの診断ログ送信
- TLS 1.2以上の強制
- インフラストラクチャ暗号化

## 必須要件

- Terraform >= 1.0
- Azure Provider (azurerm) >= 3.0

## 使用方法

### 基本的な使用例

```hcl
module "storage_account" {
  source = "../../modules/storage_account"

  resource_group_name      = "rg-example-prod"
  location                 = "japaneast"
  storage_account_name     = "stexampleprod001"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # セキュリティ設定
  public_network_access_enabled = false

  # Blobコンテナの作成
  containers = [
    "documents",
    "function-deployments",
    "backups"
  ]

  # 診断設定（オプション）
  log_analytics_workspace_id = module.log_analytics.id

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Private Endpoint対応の例

```hcl
module "storage_account" {
  source = "../../modules/storage_account"

  resource_group_name      = "rg-example-prod"
  location                 = "japaneast"
  storage_account_name     = "stexampleprod001"
  
  # Private Endpoint使用時はパブリックアクセスを無効化
  public_network_access_enabled = false

  containers = [
    "documents",
    "function-deployments"
  ]

  log_analytics_workspace_id = module.log_analytics.id

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Private Endpointの作成（別モジュール）
module "storage_private_endpoint" {
  source = "../../modules/private_endpoint"

  name                = "pe-storage-blob"
  resource_group_name = "rg-example-prod"
  location            = "japaneast"
  subnet_id           = module.vnet.subnet_ids["subnet-private-endpoint"]

  private_service_connection = {
    name                           = "psc-storage-blob"
    private_connection_resource_id = module.storage_account.id
    subresource_names              = ["blob"]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | リソースグループ名 | string | - | yes |
| location | デプロイ先リージョン | string | - | yes |
| storage_account_name | Storage Account名（3-24文字、小文字・数字のみ） | string | - | yes |
| account_tier | Storage Accountのティア（Standard/Premium） | string | Standard | no |
| account_kind | Storage Accountの種類（Storage/StorageV2/BlobStorage/FileStorage/BlockBlobStorage） | string | StorageV2 | no |
| account_replication_type | レプリケーション種類（LRS/GRS/RAGRS/ZRS/GZRS/RAGZRS） | string | LRS | no |
| access_tier | アクセス層（Hot/Cool）※StorageV2とBlobStorageのみ有効 | string | Hot | no |
| public_network_access_enabled | パブリックネットワークアクセスの有効化 | bool | false | no |
| containers | 作成するBlobコンテナのリスト | list(string) | [] | no |
| log_analytics_workspace_id | 診断ログの送信先Log Analytics Workspace ID | string | null | no |
| tags | リソースタグ | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Storage AccountのリソースID |
| name | Storage Account名 |
| primary_blob_endpoint | プライマリBlobエンドポイント |
| primary_connection_string | プライマリ接続文字列（Sensitive） |
| primary_access_key | プライマリアクセスキー（Sensitive） |
| secondary_access_key | セカンダリアクセスキー（Sensitive） |
| primary_blob_host | プライマリBlobホスト |
| container_ids | 作成されたコンテナのIDマップ |

## セキュリティ設定

### ネットワークセキュリティ

- デフォルトでパブリックアクセス無効（`public_network_access_enabled = false`）
- Private Endpoint経由のアクセスを推奨
- Azure Servicesからのアクセスをバイパス許可

### データ保護

- Blob削除保護: 7日間
- コンテナ削除保護: 7日間
- バージョニング有効
- 変更フィード有効

### 暗号化

- HTTPS通信のみ許可
- TLS 1.2以上を強制
- インフラストラクチャレベルの暗号化を有効化

## 注意事項

1. **Storage Account名の制約**
   - 3-24文字
   - 小文字と数字のみ使用可能
   - Azure全体で一意である必要がある

2. **レプリケーション種類の選択**
   - LRS: 同一データセンター内
   - ZRS: 同一リージョン内の複数ゾーン
   - GRS: 別リージョンへの非同期レプリケーション
   - RAGRS: GRS + 読み取りアクセス

3. **診断設定**
   - Log Analytics Workspace IDを指定することで診断ログを有効化
   - ストレージ操作の監査・トラブルシューティングに有用

4. **Private Endpoint使用時**
   - `public_network_access_enabled = false`を設定
   - Private DNS Zoneの構成が必要
   - 別途Private Endpointモジュールでエンドポイントを作成

## 関連モジュール

- `private_endpoint`: Private Endpointの作成
- `private_dns_zone`: Private DNS Zoneの作成
- `log_analytics`: Log Analytics Workspaceの作成
- `vnet`: Virtual Networkの作成
