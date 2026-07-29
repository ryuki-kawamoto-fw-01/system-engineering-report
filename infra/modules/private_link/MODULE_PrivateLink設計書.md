# Private Link Module 設計書

## 概要

このモジュールは、Azure Private Link Serviceを作成し、サービス間プライベート接続を構成します。Private Link Serviceを使用することで、自身のサービスを他のVNetやサブスクリプションから安全にプライベート接続できるようにします。

## 目的

- 独自のAzureサービスをPrivate Link経由で提供
- クロスVNet、クロステナント接続のサポート
- ロードバランサー背後のサービスを安全に公開
- ネットワークトラフィックの完全なプライベート化

## アーキテクチャ

```
┌─────────────────────────────────────────┐
│  Consumer VNet (他のサブスクリプション)   │
│  ┌──────────────────────┐               │
│  │ Private Endpoint     │               │
│  └──────────┬───────────┘               │
└─────────────┼───────────────────────────┘
              │
              │ Private Link Connection
              │
┌─────────────┼───────────────────────────┐
│             ▼                           │
│  ┌──────────────────────┐               │
│  │ Private Link Service │               │
│  │  - NAT IP Config     │               │
│  │  - Auto Approval     │               │
│  └──────────┬───────────┘               │
│             │                           │
│  ┌──────────▼───────────┐               │
│  │ Load Balancer        │               │
│  │ (Frontend IP Config) │               │
│  └──────────┬───────────┘               │
│             │                           │
│  ┌──────────▼───────────┐               │
│  │ Backend Services     │               │
│  │ (VM, AKS, etc.)      │               │
│  └──────────────────────┘               │
│                                         │
│  Provider VNet                          │
└─────────────────────────────────────────┘
```

## 主要リソース

### 1. Private Link Service (`azurerm_private_link_service`)

**役割**: サービスをPrivate Link経由で公開し、Private Endpointからの接続を受け付けます。

**必須パラメータ**:
- `name`: Private Link Serviceの名前
- `location`: デプロイ先リージョン
- `resource_group_name`: リソースグループ名
- `load_balancer_frontend_ip_configuration_ids`: 接続先ロードバランサーのフロントエンドIP構成ID
- `nat_ip_configuration`: NAT用のIP構成（1つ以上必須）

**オプションパラメータ**:
- `auto_approval_subscription_ids`: 自動承認するサブスクリプションID
- `visibility_subscription_ids`: サービスを表示可能なサブスクリプションID
- `enable_proxy_protocol`: TCP Proxyプロトコルの有効化
- `fqdns`: サービスのFQDNリスト

## NAT IP構成

Private Link Serviceは、NAT IP構成を通じてトラフィックを受け付けます。

**パラメータ**:
- `name`: 構成の名前
- `subnet_id`: NAT IPを配置するサブネットID
- `primary`: プライマリ構成かどうか（1つ必須）
- `private_ip_address`: 静的IPアドレス（オプション、動的割り当ても可）
- `private_ip_address_version`: IPv4またはIPv6

**注意事項**:
- 少なくとも1つのNAT IP構成が必要
- 1つの構成を`primary = true`に設定する必要がある
- サブネットには`private_link_service_network_policies_enabled = true`が必要

## セキュリティとアクセス制御

### 自動承認 (Auto Approval)

- `auto_approval_subscription_ids`に指定されたサブスクリプションからの接続は自動承認
- 未指定の場合、すべての接続要求は手動承認が必要

### 可視性制御 (Visibility)

- `visibility_subscription_ids`に指定されたサブスクリプションのみがサービスを検出可能
- 未指定の場合、すべてのサブスクリプションから検出可能（推奨しない）

## 使用例

```hcl
module "private_link" {
  source = "./modules/private_link"

  resource_group_name              = "rg-example"
  location                         = "japaneast"
  private_link_service_name        = "pls-example-service"
  
  # Load BalancerのフロントエンドIP
  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.example.frontend_ip_configuration[0].id
  ]

  # NAT IP構成
  nat_ip_configurations = [
    {
      name               = "primary-nat-config"
      subnet_id          = azurerm_subnet.pls_subnet.id
      primary            = true
      private_ip_address = null  # 動的割り当て
    }
  ]

  # セキュリティ設定
  auto_approval_subscription_ids = [
    "00000000-0000-0000-0000-000000000000"  # 信頼するサブスクリプションID
  ]

  visibility_subscription_ids = [
    "00000000-0000-0000-0000-000000000000"
  ]

  enable_proxy_protocol = false

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

## 出力値

- `private_link_service_id`: Private Link ServiceのリソースID
- `private_link_service_name`: サービス名
- `private_link_service_alias`: 接続時に使用するエイリアス（重要）
- `nat_ip_configuration_ids`: NAT IP構成のIDリスト
- `nat_ip_configuration_private_ips`: NAT IPアドレスリスト

## ベストプラクティス

1. **NAT IP構成**
   - 本番環境では複数のNAT IP構成を設定して冗長性を確保
   - サブネットには十分なIPアドレス空間を確保

2. **アクセス制御**
   - `visibility_subscription_ids`を明示的に設定し、不要な露出を防ぐ
   - `auto_approval_subscription_ids`は信頼できるサブスクリプションのみに限定

3. **ロードバランサー**
   - Standard SKUのロードバランサーを使用（Basic SKUは非対応）
   - 複数のフロントエンドIP構成をサポート

4. **ネットワーク設計**
   - Private Link Service用に専用サブネットを作成
   - サブネットでは`private_link_service_network_policies_enabled = true`を設定

5. **監視**
   - Private Link Serviceの接続状態を監視
   - NAT IPの使用状況とトラフィックパターンを追跡

## 制約事項

- Private Link ServiceはStandard Load Balancerとのみ連携可能
- NAT IP構成には最低1つのプライマリ構成が必要
- サブネットのネットワークポリシーを適切に設定する必要がある
- リージョン間のPrivate Link接続には追加の考慮が必要

## 依存モジュール

- **vnet**: Private Link Service用のサブネット
- **load_balancer**: フロントエンドIP構成（別途作成が必要）

## 関連ドキュメント

- [Azure Private Link Service 公式ドキュメント](https://learn.microsoft.com/azure/private-link/private-link-service-overview)
- [Terraform azurerm_private_link_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_link_service)
