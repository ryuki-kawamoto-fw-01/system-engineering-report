# VNet Module

VNet・サブネット・NSGを作成し、閉域ネットワークを構築するTerraformモジュールです。

## 機能

- Virtual Networkの作成
- 複数サブネットの動的作成
- サブネット委任（Azure Functions、App Service等）のサポート
- Network Security Groups（NSG）の作成とルール定義
- サブネットとNSGの自動関連付け
- Private Endpointネットワークポリシーの制御
- Service Endpointsの設定

## 必須要件

- Terraform >= 1.0
- Azure Provider (azurerm) >= 3.0

## 使用方法

### 基本的な使用例

```hcl
module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = "rg-example-prod"
  location            = "japaneast"
  vnet_name           = "vnet-example-prod"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "subnet-private-endpoint" = {
      address_prefix                             = "10.0.1.0/24"
      private_endpoint_network_policies_enabled  = false
      service_endpoints                          = ["Microsoft.Storage"]
    }
  }

  network_security_groups = {
    "nsg-private-endpoint" = {
      security_rules = [
        {
          name                       = "AllowVNetInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }
      ]
    }
  }

  subnet_nsg_associations = {
    "subnet-private-endpoint" = "nsg-private-endpoint"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### P5190-Spoke環境の実装例

P5190-Spoke環境の具体的な実装例は、以下のファイルを参照してください：

- **example.tfvars**: tfvars形式の設定例
- **example-locals.tf**: locals.tf形式の設定例（モジュール呼び出しを含む）

#### サブネット構成

| サブネット名 | CIDR | 用途 | 委任 |
|------------|------|------|-----|
| P5190-Spoke-PrivateSubnet001 | 10.173.8.64/26 | Private Endpoint | なし |
| P5190-Spoke-PrivateSubnet002 | 10.173.8.128/26 | Function App / Web Apps | Microsoft.Web/serverFarms |
| P5190-Spoke-PrivateSubnet004 | 10.173.9.0/25 | 汎用 | なし |

#### NSGルール概要

**NSG001 (Private Endpoint用)**
- VNet内通信を許可
- インターネットアクセスを許可（アウトバウンド）
- その他すべて拒否

**NSG002 (Function App / Web Apps用)**
- HTTP/HTTPS通信を許可（インバウンド）
- Azure Storage、SQL、Monitorへのアクセスを許可（アウトバウンド）
- VNet内通信を許可
- その他すべて拒否

**NSG004 (汎用)**
- VNet内通信を許可
- Azure Storage、Key Vault、Cosmos DBへのアクセスを許可（アウトバウンド）
- その他すべて拒否

## 入力変数

| 変数名 | 型 | 必須 | デフォルト値 | 説明 |
|--------|-----|------|------------|------|
| resource_group_name | string | ✓ | - | VNetを配置するリソースグループの名前 |
| location | string | - | "japaneast" | リソースのロケーション |
| vnet_name | string | ✓ | - | Virtual Networkの名前 |
| address_space | list(string) | - | ["10.0.0.0/16"] | VNetのアドレス空間（CIDR） |
| subnets | map(object) | - | {} | サブネット定義 |
| network_security_groups | map(object) | - | {} | NSG定義とセキュリティルール |
| subnet_nsg_associations | map(string) | - | {} | サブネット-NSG関連付け |
| tags | map(string) | - | {} | リソースタグ |
| dns_servers | list(string) | - | [] | カスタムDNSサーバー |

### subnetsオブジェクト構造

```hcl
{
  address_prefix                             = string           # 必須
  service_endpoints                          = list(string)     # オプション
  private_endpoint_network_policies_enabled  = bool             # オプション (デフォルト: false)
  private_link_service_network_policies_enabled = bool          # オプション (デフォルト: true)
  delegation = object({                                         # オプション
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
}
```

### network_security_groupsオブジェクト構造

```hcl
{
  security_rules = list(object({
    name                       = string
    priority                   = number       # 100-4096
    direction                  = string       # "Inbound" or "Outbound"
    access                     = string       # "Allow" or "Deny"
    protocol                   = string       # "Tcp", "Udp", "Icmp", "*"
    source_port_range          = string       # "*" or ポート番号
    destination_port_range     = string       # "*" or ポート番号
    source_address_prefix      = string       # CIDR or サービスタグ
    destination_address_prefix = string       # CIDR or サービスタグ
    # 複数指定の場合
    source_port_ranges         = list(string)
    destination_port_ranges    = list(string)
    source_address_prefixes    = list(string)
    destination_address_prefixes = list(string)
  }))
}
```

## 出力値

| 出力名 | 型 | 説明 |
|--------|-----|------|
| vnet_id | string | Virtual NetworkのID |
| vnet_name | string | Virtual Networkの名前 |
| vnet_address_space | list(string) | VNetのアドレス空間 |
| subnet_ids | map(string) | サブネットIDのマップ |
| subnet_address_prefixes | map(list(string)) | サブネットのアドレスプレフィックスマップ |
| nsg_ids | map(string) | NSG IDのマップ |
| nsg_names | map(string) | NSG名のマップ |

## 設計のポイント

### Private Endpointネットワークポリシー

Private Endpoint用サブネットでは、`private_endpoint_network_policies_enabled = false` を設定します。これにより、Private Endpointが正常に動作します。

```hcl
subnets = {
  "subnet-private-endpoint" = {
    address_prefix                             = "10.0.1.0/24"
    private_endpoint_network_policies_enabled  = false  # Private Endpoint用
  }
}
```

### サブネット委任

Azure FunctionsやApp Serviceを統合する場合、サブネット委任が必要です：

```hcl
subnets = {
  "subnet-function" = {
    address_prefix = "10.0.2.0/24"
    delegation = {
      name = "delegation-webapp"
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}
```

### NSGルールの優先度

- 優先度は100-4096の範囲で設定
- 低い数値ほど高優先度
- 100刻みで設定すると、後から挿入しやすい
- 拒否ルールは最低優先度（4096）に設定

### サービスタグの活用

Azureサービスへのアクセス許可には、サービスタグを使用します：

- `VirtualNetwork`: VNet内通信
- `Storage`: Azure Storage
- `AzureKeyVault`: Azure Key Vault
- `Sql`: Azure SQL Database
- `AzureLoadBalancer`: Azure Load Balancer
- `Internet`: インターネット
- `AzureMonitor`: Azure Monitor

## 注意事項

1. **アドレス重複**: サブネットのアドレス空間が重複しないように設計すること
2. **NSG優先度**: 各NSG内でルールの優先度が重複しないこと
3. **委任の制約**: サブネット委任を設定すると、そのサブネットは特定のサービス専用になる
4. **既定ルール**: Azureには既定のNSGルール（priority 65000-65535）があり、明示的なルールより低優先度で適用される
5. **プロバイダーバージョン**: AzureRM Provider 3.x以降を使用すること

## 既定NSGルールについて

Azureは以下の既定ルールを自動的に適用します（明示的に定義不要）：

**インバウンド（優先度65000-65535）**
- AllowVNetInBound (65000)
- AllowAzureLoadBalancerInBound (65001)
- DenyAllInBound (65500)

**アウトバウンド（優先度65000-65535）**
- AllowVnetOutBound (65000)
- AllowInternetOutBound (65001)
- DenyAllOutBound (65500)

カスタムルール（100-4096）でこれらを上書きできます。

## トラブルシューティング

### Private Endpointが作成できない

**症状**: Private Endpointの作成が失敗する

**解決策**: サブネットの`private_endpoint_network_policies_enabled`を`false`に設定

### Function AppのVNet統合が失敗する

**症状**: Function AppのVNet統合エラー

**解決策**: サブネット委任（`Microsoft.Web/serverFarms`）を設定し、十分なアドレス空間を確保（/26以上推奨）

### NSGルールが適用されない

**症状**: 期待した通信制御がされない

**解決策**: 優先度の低いルールが高いルールに上書きされていないか確認。NSGフローログで確認可能。

## 参考リンク

- [Azure Virtual Network](https://learn.microsoft.com/azure/virtual-network/)
- [Network Security Groups](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Private Endpoint](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)
- [VNet統合](https://learn.microsoft.com/azure/app-service/overview-vnet-integration)
- [サービスタグ](https://learn.microsoft.com/azure/virtual-network/service-tags-overview)
