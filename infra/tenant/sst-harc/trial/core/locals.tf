# =============================================================================
# Local Values - sst-harc/test/core
# =============================================================================
# 繰り返し使用する計算値と命名規則を定義
# =============================================================================
#
# 【命名規則】
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# すべてのリソース名は固定値を使用（環境プレフィックスは使用しない）
#
# パターン: <prefix>-genashi-test-01
# 
# 例:
# - Resource Group: rg-genashi-test-01
# - Storage Account: stgenashitestmain01
# - Virtual Network: vnet-genashi-test-01
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

locals {
  # ===========================================================================
  # 環境変数の参照（environment.tfから取得）
  # ===========================================================================

  # 環境情報
  environment  = var.environment
  tenant_name  = var.tenant_name
  project_name = var.project_name

  # ネットワーク設定
  vnet_address_space = var.vnet_address_space
  subnet_definitions = var.subnet_definitions

  # Log Analytics設定
  log_retention_days = var.log_retention_days

  # Storage Account設定
  storage_account_tier        = var.storage_account_tier
  storage_account_replication = var.storage_account_replication

  # Cosmos DB設定
  cosmosdb_consistency_level = var.cosmosdb_consistency_level
  # cosmosdb_max_throughput    = var.cosmosdb_max_throughput  # 旧実装用（現在未使用）

  # Key Vault設定
  key_vault_sku = var.key_vault_sku

  # App Service設定
  app_service_sku_name  = var.app_service_sku_name
  function_app_sku_name = var.function_app_sku_name

  # タグ設定
  common_tags = {
    "機能名称" = "製造現場アシスタントAI"
    "環境"   = "本番"
  }

  # ロケーション
  location = "japanwest"

  #サブスクリプションID
  subscription_id = var.subscription_id

  # ===========================================================================
  # リソース命名規則（作成されるAzureリソース一覧）
  # ===========================================================================

  # ---------------------------------------------------------------------------
  # 1️⃣ 基盤リソース
  # ---------------------------------------------------------------------------

  # ✅ Resource Group（すべてのリソースを格納するコンテナ）
  resource_group_name    = "rg-genashi-trial-${var.environment_prefix}"
  rg_location            = "japaneast"
  location_log_analytics = "japanwest"

  # ---------------------------------------------------------------------------
  # 2️⃣ 監視・ログ基盤
  # ---------------------------------------------------------------------------

  # ✅ Log Analytics Workspace（全リソースの診断ログを集約）
  log_name = "laws-genashi-trial-${var.environment_prefix}"

  # ---------------------------------------------------------------------------
  # 3️⃣ ネットワーク基盤
  # ---------------------------------------------------------------------------

  # ✅ Virtual Network（閉域ネットワーク構築）
  vnet_name                = "vnet-genashi-trial-${var.environment_prefix}"
  address_space            = ["10.173.8.0/23", "10.173.36.0/23"]
  subnet_01_name           = "snet-genashi-trial-01"
  subnet_01_address_prefix = "10.173.8.64/26"
  # subnet_01_nsg_name       = "snet-genashi-trial-01-nsg"
  subnet_02_name           = "snet-genashi-trial-02"
  subnet_02_address_prefix = "10.173.8.128/26"
  # subnet_02_nsg_name       = "snet-genashi-trial-02-nsg"
  subnet_03_name           = "snet-genashi-trial-03"
  subnet_03_address_prefix = "10.173.9.0/25"
  # subnet_03_nsg_name       = "snet-genashi-trial-03-nsg"
  # ✅ Network Security Groups（サブネットごとのアクセス制御）
  # nsg_app_name                          = "nsg-genashi-trial-app-${var.environment_prefix}"
  # nsg_func_name                         = "nsg-genashi-trial-func-${var.environment_prefix}"
  # nsg_pe_name                           = "nsg-genashi-trial-pe-${var.environment_prefix}"
  # nsg_p5190_spoke_privatesubnet001_name = "P5190-Spoke-PrivateSubnetNSG001"
  # nsg_p5190_spoke_privatesubnet002_name = "P5190-Spoke-PrivateSubnetNSG002"
  # nsg_p5190_spoke_privatesubnet004_name = "P5190-Spoke-PrivateSubnetNSG004"


  # ---------------------------------------------------------------------------
  # ネットワーク層 - Private Endpoints
  # ---------------------------------------------------------------------------

  # ✅ Private Endpoint Names（プライベートエンドポイント名を一元管理）
  # 各Azureリソースへの閉域接続用エンドポイント名
  private_endpoint = {
    storage_blob       = "pep-stgenashitrial${var.environment_prefix}-blob"
    storage_queue      = "pep-stgenashitrial${var.environment_prefix}-queue"
    container_registry = "pep-crgenashitrial${var.environment_prefix}"
    cosmos_db          = "pep-cosno-genashi-trial-${var.environment_prefix}"
    key_vault          = "pep-kv-genashi-trial-${var.environment_prefix}"
    loadbalancer       = "pep-app-load-balancer-trial-${var.environment_prefix}"

    chat           = "pep-func-genashi-trial-${var.environment_prefix}-01-chat"
    rag            = "pep-func-genashi-trial-${var.environment_prefix}-02-rag"
    register       = "pep-func-genashi-trial-${var.environment_prefix}-03-text-register"
    pii            = "pep-func-genashi-trial-${var.environment_prefix}-04-pii"
    prompt         = "pep-func-genashi-trial-${var.environment_prefix}-05-prompt"
    pdf            = "pep-func-genashi-trial-${var.environment_prefix}-08-pdf"
    mfg            = "pep-func-genashi-trial-${var.environment_prefix}-09-mfg"
    agent_rag      = "pep-func-genashi-trial-${var.environment_prefix}-10-agent-rag"
    agent_document = "pep-func-genashi-trial-${var.environment_prefix}-11-agent-document"
    indexer        = "pep-func-genashi-trial-${var.environment_prefix}-14-indexer"
  }

  # ✅ Private Endpoint Network Interface Names（NIC名を一元管理）
  private_endpoint_network_interface = {
    storage_blob       = "nic-stgenashitrial${var.environment_prefix}-blob"
    storage_queue      = "nic-stgenashitrial${var.environment_prefix}-queue"
    container_registry = "nic-crgenashitrial${var.environment_prefix}"
    cosmos_db          = "nic-cosno-genashi-trial-${var.environment_prefix}"
    key_vault          = "nic-kv-genashi-trial-${var.environment_prefix}"
    loadbalancer       = "nic-app-load-balancer-trial-${var.environment_prefix}"

    chat           = "nic-func-genashi-trial-${var.environment_prefix}-01-chat"
    rag            = "nic-func-genashi-trial-${var.environment_prefix}-02-rag"
    register       = "nic-func-genashi-trial-${var.environment_prefix}-03-text-register"
    pii            = "nic-func-genashi-trial-${var.environment_prefix}-04-pii"
    prompt         = "nic-func-genashi-trial-${var.environment_prefix}-05-prompt"
    pdf            = "nic-func-genashi-trial-${var.environment_prefix}-08-pdf"
    mfg            = "nic-func-genashi-trial-${var.environment_prefix}-09-mfg"
    agent_rag      = "nic-func-genashi-trial-${var.environment_prefix}-10-agent-rag"
    agent_document = "nic-func-genashi-trial-${var.environment_prefix}-11-agent-document"
    indexer        = "nic-func-genashi-trial-${var.environment_prefix}-14-indexer"
  }

  # ---------------------------------------------------------------------------
  # 4️⃣ ストレージ基盤
  # ---------------------------------------------------------------------------

  # ✅ Storage Account（ドキュメント保管・Function App用データ格納）
  # 命名制限: 英数字のみ、最大24文字
  # 形式: stgenashitest{suffix}01
  # 例:
  #   - main:     stgenashitestmain01 (20文字)
  #   - function: stgenashitestfunc01 (20文字)
  #   - frontend: stgenashitestfe01 (18文字)
  # Storage Account
  storage_account_name     = "stgenashitrial${var.environment_prefix}dummy" # 最大24文字以内、一意性制約
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # ✅ Storage Container（固定リスト - 18個）
  # メインStorage Accountに作成されるBlobコンテナ
  # 
  # 【コンテナ用途一覧】
  # - agent-container-01/02: AI Foundry
  # - agent-container-03: (用途未定義)
  # - create-minutes: 議事録生成
  # - genashi-test-container01-04: 文書登録
  # - genashi-test-container05: ファイル添付
  # - genashi-test-container06-08: 音声文字起こし
  # - proposal-generator-container: 提案書修正
  # - input-movie-01: 動画アップロード
  # - output-manuals-01: 生成マニュアル保存
  # - image-generation: 画像生成
  # - azure-webjobs-hosts/secrets: Azure Functions内部用
  #
  # 【文書格納フォルダ構造】（Blobコンテナ内の仮想フォルダ - 41個）
  # 01_AI推, 02_営業, 03_設計, 04_BPO, 05_D141, 06_デモ, 07_検証用,
  # 08_生技, 09_IT本, 10_産業, 11_産3事, 12_産CS, 14_産推営, 15_産1営,
  # 16_産2営, 17_産3営, 18_産4営, 19_産5営, 20_産6営, 21_産7営, 22_関戦企,
  # 23_関1本, 24_関2本, 25_関3本, 26_全国P事, 27_産1事, 28_産2事, 29_産DX事,
  # 30_研開本, 31_げんあしQ&A, 32_パ1本, 33_パ2本, 34_パ3本, 35_公統1,
  # 36_産PM, 37_ES-AI推, 38_金融, 39_サービス仕様書チェック, 40_LE推, 41_HISYS-PS
  #
  # 【RAG構成】
  # - 文書格納: Azure Blob Storage
  # - 検索基盤: Azure AI Search（インデックス: 親1個 + 子2個）
  # - 対象文書: 規格、設計基準書、業務文書、Q&A、サービス仕様書、部署文書
  # - 処理フロー: 文書アップロード → Blob → チャンク分割 → Embedding → AI Search → RAG検索 → LLM回答

  # ---------------------------------------------------------------------------
  # Storage Containers
  # ---------------------------------------------------------------------------
  # すべてのコンテナを非公開（private）で作成する。
  # 用途ごとに分類して管理する。

  storage_container_names = [
    # AI Foundry
    "agent-container-01",
    "agent-container-02",
    "agent-container-03",

    # 業務機能
    "create-minutes",
    "proposal-generator-container",
    "image-generation",

    # 文書・ファイル処理
    "genashi-trial-01",
    "genashi-trial-02",
    "genashi-trial-03",
    "genashi-trial-04",
    "genashi-trial-05",
    "genashi-trial-06",
    "genashi-trial-07",
    "genashi-trial-08",

    # 動画・マニュアル
    "input-movie-01",
    "output-manuals-01",

    # Azure Functions内部管理
    "azure-webjobs-hosts",
    "azure-webjobs-secrets"
  ]

  # main.tfへ渡すコンテナ定義
  storage_containers = [
    for name in local.storage_container_names : {
      name                  = name
      container_access_type = "private"
    }
  ]

  # ---------------------------------------------------------------------------
  # Storage Queues
  # ---------------------------------------------------------------------------
  # Azure FunctionsのBlob Trigger、動画処理およびエラー処理で使用する
  # Storage Queueを用途別に管理する。

  storage_queues = [
    # Blob Trigger用キュー
    # 各Function Appの処理対象Blobを管理
    "azure-webjobs-blobtrigger-func-genashi-trial-06-pagesplit", # ページ分割処理
    "azure-webjobs-blobtrigger-func-genashi-trial-07-markdown",  # Markdown変換処理
    "azure-webjobs-blobtrigger-func-genashi-trial-08-pdf",       # PDF変換処理
    "azure-webjobs-blobtrigger-func-genashi-trial-12-page-std",  # 標準エージェント用ページ分割
    "azure-webjobs-blobtrigger-func-genashi-trial-13-mark-std",  # 標準エージェント用Markdown変換

    # 動画処理用キュー
    # 動画処理の制御メッセージおよびワークアイテムを管理
    "funcgenashitrialmovie001-control-00", # 動画処理制御 00
    "funcgenashitrialmovie001-control-01", # 動画処理制御 01
    "funcgenashitrialmovie001-control-02", # 動画処理制御 02
    "funcgenashitrialmovie001-control-03", # 動画処理制御 03
    "funcgenashitrialmovie001-workitems",  # 動画処理ワークアイテム

    # エラー処理用キュー
    # Blob Triggerで処理に失敗したメッセージを保持
    "webjobs-blobtrigger-poison"
  ]

  # Storage Folder Placeholders (Azure Functions用の仮想ディレクトリ)
  storage_folder_placeholders = [
    # azure-webjobs-hosts
    {
      container_name = "azure-webjobs-hosts"
      folder_path    = "blobreceipts"
    },
    {
      container_name = "azure-webjobs-hosts"
      folder_path    = "blobscaninfo"
    },
    {
      container_name = "azure-webjobs-hosts"
      folder_path    = "ids"
    },
    {
      container_name = "azure-webjobs-hosts"
      folder_path    = "locks"
    },
    {
      container_name = "azure-webjobs-hosts"
      folder_path    = "synctriggers"
    },
    # agent-container-01
    {
      container_name = "agent-container-01"
      folder_path    = "規格"
    },
    {
      container_name = "agent-container-01"
      folder_path    = "設計基準書"
    },
    # azure-webjobs-secrets
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-01-chat"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-09-mfg"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-04-pii"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-05-prompt"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-02-rag"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-03-text-register"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-11-agent-document"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-10-agent-rag"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-07-markdown"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-movie-001"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-06-pagesplitter"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-08-pdf"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-14-indexer"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-12-page-std"
    },
    {
      container_name = "azure-webjobs-secrets"
      folder_path    = "func-genashi-trial-13-mark-std"
    },
    # genashi-trial-01
    # -- ハンズオン環境用 -- 
    {
      container_name = "genashi-trial-01"
      folder_path    = "インデックス１"
    },
    {
      container_name = "genashi-trial-01"
      folder_path    = "インデックス２"
    },
    {
      container_name = "genashi-trial-01"
      folder_path    = "インデックス３"
    },
    # -- 本番環境用 -- 
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "01_AI推"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "02_営業"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "03_設計"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "04_BPO"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "05_D141"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "06_デモ"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "07_検証用"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "08_生技"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "09_IT本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "10_産業"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "11_産3事"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "12_産ＣＳ"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "14_産推営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "15_産1営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "16_産2営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "17_産3営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "18_産4営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "19_産5営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "20_産6営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "21_産7営"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "22_関戦企"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "23_関1本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "24_関2本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "25_関3本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "26_全国P事"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "27_産1事"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "28_産2事"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "29_産DX事"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "30_研開本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "31_げんあしQ&A"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "32_パ１本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "33_パ２本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "34_パ３本"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "35_公統１"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "36_産ＰＭ"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "37_ES-AI推"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "38_金融"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "39_サービス仕様書チェック"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "40_LE推"
    # },
    # {
    #   container_name = "genashi-trial-01"
    #   folder_path    = "41_HISYS-PS"
    # },
    # genashi-trial-02
    # -- 本番環境用 --
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "01_AI推"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "05_D141"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "06_デモ"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "07_検証用"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "09_IT本"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "10_産業"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "12_産ＣＳ"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "18_産4営"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "21_産7営"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "24_関2本"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "25_関3本"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "26_全国P事"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "28_産2事"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "29_産DX事"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "35_公統１"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "36_産ＰＭ"
    # },
    # {
    #   container_name = "genashi-trial-02"
    #   folder_path    = "37_ES-AI推"
    # },
    # genashi-trial-03
    # -- 本番環境用 --
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "01_AI推"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "05_D141"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "06_デモ"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "07_検証用"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "09_IT本"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "10_産業"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "12_産ＣＳ"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "18_産4営"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "21_産7営"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "24_関2本"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "25_関3本"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "26_全国P事"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "28_産2事"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "29_産DX事"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "35_公統１"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "36_産ＰＭ"
    # },
    # {
    #   container_name = "genashi-trial-03"
    #   folder_path    = "37_ES-AI推"
    # },
    # genashi-trial-04
    # -- 本番環境用 --
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "01_AI推"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "05_D141"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "06_デモ"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "07_検証用"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "09_IT本"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "10_産業"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "12_産ＣＳ"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "18_産4営"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "21_産7営"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "24_関2本"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "25_関3本"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "26_全国P事"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "28_産2事"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "29_産DX事"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "35_公統１"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "36_産ＰＭ"
    # },
    # {
    #   container_name = "genashi-trial-04"
    #   folder_path    = "37_ES-AI推"
    # },
    # genashi-trial-05
    # -- 本番環境用 --
    # {
    #   container_name = "genashi-trial-05"
    #   folder_path    = "temp"
    # },
    # genashi-trial-06
    # -- ハンズオン環境用 --
    {
      container_name = "genashi-trial-06"
      folder_path    = "規格"
    },
    {
      container_name = "genashi-trial-06"
      folder_path    = "設計書"
    }

  ]

  # ✅ Storage Account 診断設定名
  # 形式: diag-st-genashi-trial-${var.environment_prefix}-{subresource}
  storage_diagnostic_blob_name  = "diag-st-genashi-trial-${var.environment_prefix}-blob"
  storage_diagnostic_queue_name = "diag-st-genashi-trial-${var.environment_prefix}-queue"

  # ---------------------------------------------------------------------------
  # 5️⃣ コンテナ基盤
  # ---------------------------------------------------------------------------

  # ✅ Azure Container Registry（コンテナイメージ管理）
  # 命名制限: 英数字のみ（小文字）、最大50文字
  # 一意性制約あり
  # 形式: crgenashitrial${var.environment_prefix}
  container_registry_name = "crgenashitrial${var.environment_prefix}"

  # ✅ Container Registry診断設定
  # 形式: diag-crgenashitrial${var.environment_prefix}
  container_registry_diagnostic_setting_name = "diag-crgenashitrial${var.environment_prefix}"

  # ✅ Container Registry Private Endpoint
  # Network Layer の private_endpoint.container_registry で管理
  # → pep-crgenashitrial${var.environment_prefix}

  # ✅ Container Registry Private Endpoint NIC
  # Network Layer の private_endpoint_network_interface.container_registry で管理
  # → nic-crgenashitrial${var.environment_prefix}

  # ✅ Container Registry Private DNS Zone
  # Network Layer の private_dns_zones.container_registry で管理
  # → privatelink.azurecr.io

  # ✅ Storage Account (メインストレージ)
  # storage_account_name で管理

  # ✅ Storage Account Private Endpoints
  # → private_endpoint.storage_blob
  # → private_endpoint.storage_queue
  # に移行

  # ---------------------------------------------------------------------------
  # 6️⃣ Cosmos DB
  # ---------------------------------------------------------------------------

  # ✅ Cosmos DB（メタデータ・履歴データ永続化）
  cosmosdb = {
    # -------------------------------------------------------------------------
    # Cosmos DBアカウント基本設定
    # -------------------------------------------------------------------------
    account_name                    = "cosno-genashi-trial-${var.environment_prefix}"
    public_network_access_enabled   = false
    enable_automatic_failover       = true
    enable_multiple_write_locations = false
    disable_local_auth              = true
    enable_free_tier                = false
    capacity_mode                   = "Provisioned"
    minimal_tls_version             = "Tls12"
    network_acl_bypass              = "None"
    analytical_storage_enabled      = false

    # -------------------------------------------------------------------------
    # 一貫性ポリシー
    # -------------------------------------------------------------------------
    consistency_policy = {
      consistency_level       = "BoundedStaleness"
      max_interval_in_seconds = 300
      max_staleness_prefix    = 100
    }

    # -------------------------------------------------------------------------
    # バックアップポリシー
    # -------------------------------------------------------------------------
    backup_policy = {
      type                = "Periodic"
      interval_in_minutes = 240 # 4時間
      retention_in_hours  = 8
      storage_redundancy  = "Local"
    }

    # -------------------------------------------------------------------------
    # フェールオーバー設定
    # -------------------------------------------------------------------------
    failover_locations = [
      {
        location          = "japanwest"
        failover_priority = 0
        zone_redundant    = false
      }
    ]

    # -------------------------------------------------------------------------
    # データベース設定
    # すべて共有Autoscaleスループットを使用
    # -------------------------------------------------------------------------
    databases = [
      {
        name = "cosmos-genashi-trial-01"
        autoscale_settings = {
          max_throughput = 1000
        }

        containers = [
          {
            name               = "ban-word"
            partition_key_path = "/category"
          },
          {
            name               = "dictionary"
            partition_key_path = "/category"
          },
          {
            name               = "hiyari-hat"
            partition_key_path = "/category"
          },
          {
            name               = "message"
            partition_key_path = "/userId"
          },
          {
            name               = "message-agent"
            partition_key_path = "/category"
          },
          {
            name               = "message-rag"
            partition_key_path = "/userId"
          },
          {
            name               = "past-qa"
            partition_key_path = "/category"
          },
          {
            name               = "speech-to-text"
            partition_key_path = "/userId"
          },
          {
            name               = "template"
            partition_key_path = "/category"
          },
          {
            name               = "thread"
            partition_key_path = "/userId"
          },
          {
            name               = "thread-agent"
            partition_key_path = "/userId"
          },
          {
            name               = "thread-rag"
            partition_key_path = "/userId"
          },
          {
            name               = "use-case-search"
            partition_key_path = "/category"
          }
        ]
      },
      {
        name = "cosmos-genashi-trial-02"
        autoscale_settings = {
          max_throughput = 1000
        }

        containers = [
          {
            name               = "advice-consulting"
            partition_key_path = "/userId"
          },
          {
            name               = "advice-react"
            partition_key_path = "/userId"
          },
          {
            name               = "code-explanation"
            partition_key_path = "/userId"
          },
          {
            name               = "company-analysis"
            partition_key_path = "/userId"
          },
          {
            name               = "corporate-survey"
            partition_key_path = "/userId"
          },
          {
            name               = "create-design-document"
            partition_key_path = "/userId"
          },
          {
            name               = "create-idea"
            partition_key_path = "/userId"
          },
          {
            name               = "create-mail"
            partition_key_path = "/userId"
          },
          {
            name               = "create-minutes"
            partition_key_path = "/userId"
          },
          {
            name               = "create-prompt"
            partition_key_path = "/userId"
          },
          {
            name               = "create-technology-proposal"
            partition_key_path = "/userId"
          },
          {
            name               = "image-generation"
            partition_key_path = "/userId"
          },
          {
            name               = "market-research"
            partition_key_path = "/userId"
          },
          {
            name               = "new-product-proposal"
            partition_key_path = "/userId"
          },
          {
            name               = "quality-report"
            partition_key_path = "/userId"
          },
          {
            name               = "quality-standard-document"
            partition_key_path = "/userId"
          },
          {
            name               = "research-report"
            partition_key_path = "/userId"
          },
          {
            name               = "schedule"
            partition_key_path = "/userId"
          },
          {
            name               = "summary"
            partition_key_path = "/userId"
          },
          {
            name               = "supposed-question"
            partition_key_path = "/userId"
          },
          {
            name               = "talk-script"
            partition_key_path = "/userId"
          },
          {
            name               = "text-correction"
            partition_key_path = "/userId"
          },
          {
            name               = "translation"
            partition_key_path = "/userId"
          },
          {
            name               = "wall-hitting"
            partition_key_path = "/userId"
          }
        ]
      },
      {
        name = "cosmos-genashi-trial-03"
        autoscale_settings = {
          max_throughput = 1000
        }

        containers = [
          {
            name               = "brainstorming"
            partition_key_path = "/userId"
          },
          {
            name               = "business-plan"
            partition_key_path = "/userId"
          },
          {
            name               = "code-explanation"
            partition_key_path = "/userId"
          },
          {
            name               = "crisis-management-scenarios"
            partition_key_path = "/userId"
          },
          {
            name               = "defect-analysis-report"
            partition_key_path = "/userId"
          },
          {
            name               = "design-document-review"
            partition_key_path = "/userId"
          },
          {
            name               = "error-analysis"
            partition_key_path = "/userId"
          },
          {
            name               = "incident-report"
            partition_key_path = "/userId"
          },
          {
            name               = "judge-idea"
            partition_key_path = "/userId"
          },
          {
            name               = "key-point-extraction"
            partition_key_path = "/userId"
          },
          {
            name               = "needs-survey"
            partition_key_path = "/userId"
          },
          {
            name               = "product-expansion-aarrr"
            partition_key_path = "/userId"
          },
          {
            name               = "production-tech-list"
            partition_key_path = "/userId"
          },
          {
            name               = "product-service-benefit-idea"
            partition_key_path = "/userId"
          },
          {
            name               = "risk-assessment"
            partition_key_path = "/userId"
          },
          {
            name               = "sales-forecast"
            partition_key_path = "/userId"
          },
          {
            name               = "task-breakdown"
            partition_key_path = "/userId"
          },
          {
            name               = "technology-training"
            partition_key_path = "/userId"
          },
          {
            name               = "text-check"
            partition_key_path = "/userId"
          },
          {
            name               = "transcription-handwritten"
            partition_key_path = "/userId"
          },
          {
            name               = "trouble-shooting-guide"
            partition_key_path = "/userId"
          },
          {
            name               = "use-case-search"
            partition_key_path = "/category"
          }
        ]
      },
      {
        name = "cosmos-genashi-trial-04"
        autoscale_settings = {
          max_throughput = 1000
        }

        containers = [
          {
            name               = "flow-designer"
            partition_key_path = "/userId"
          },
          {
            name               = "movie-manual"
            partition_key_path = "/userId"
          },
          {
            name               = "product-catchphrase"
            partition_key_path = "/userId"
          },
          {
            name               = "product-promotion-strategy"
            partition_key_path = "/userId"
          },
          {
            name               = "marketing-strategy"
            partition_key_path = "/userId"
          },
          {
            name               = "tech-assess"
            partition_key_path = "/userId"
          }
        ]
      }
    ]

    # -------------------------------------------------------------------------
    # 診断設定
    # -------------------------------------------------------------------------
    diagnostic_setting_name = "diag-cosmos-genashi-trial-${var.environment_prefix}"
  }


  # ---------------------------------------------------------------------------
  # 7️⃣ 認証・シークレット管理基盤
  # ---------------------------------------------------------------------------

  # Key Vault
  key_vault = {
    name                          = "kv-genashi-trial-${var.environment_prefix}" # 一意性制約 3-24文字
    tenant_id                     = var.tenant_id
    sku_name                      = "standard"
    public_network_access_enabled = true
    # network_acls_bypass             = "AzureServices"
    # network_acls_default_action     = "Allow"
    rbac_authorization_enabled       = true
    enabled_for_deployment          = false
    enabled_for_disk_encryption     = false
    enabled_for_template_deployment = false
    soft_delete_retention_days      = 7
    purge_protection_enabled        = false
    diagnostic_setting_name         = "diag-kv-genashi-trial-${var.environment_prefix}"
  }

  # Key Vault Secret Names (Function App Credentials + Easy Auth)
  key_vault_secret_names = {
    orchestrator_agent_api_credential    = "ORCHESTRATOR-AGENT-API-CREDENTIAL"
    orchestrator_api_url                 = "ORCHESTRATOR-API-URL"
    orchestrator_document_api_credential = "ORCHESTRATOR-DOCUMENT-API-CREDENTIAL"
    orchestrator_file_api_credential     = "ORCHESTRATOR-FILE-API-CREDENTIAL"
    orchestrator_it_api_credential       = "ORCHESTRATOR-IT-API-CREDENTIAL"
    orchestrator_mfg_api_credential      = "ORCHESTRATOR-MFG-API-CREDENTIAL"
    orchestrator_pii_api_url             = "ORCHESTRATOR-PII-API-URL"
    orchestrator_rag_api_url             = "ORCHESTRATOR-RAG-API-URL"
    orchestrator_standard_api_credential = "ORCHESTRATOR-STANDARD-API-CREDENTIAL"
    orchestrator_use_case_api_credential = "ORCHESTRATOR-USE-CASE-API-CREDENTIAL"
    # microsoft_provider_authentication_secret はapp_serviceモジュールで管理されるため削除
  }


  # ---------------------------------------------------------------------------
  # 8️⃣ Webアプリケーション基盤（App Service）
  # ---------------------------------------------------------------------------

  # ✅ App Service Plan 01
  # Frontend / Load Balancer 用
  # SKU : Premium v3
  # OS  : Linux

  app_service_plan_01_name     = "asp-genashi-trial-${var.environment_prefix}-01"
  app_service_plan_01_sku_name = var.app_service_sku_name
  app_service_plan_01_os_type  = "Linux"

  # ✅ App Service Plan 02
  # Azure Functions 用
  # SKU : Elastic Premium EP1
  # OS  : Linux

  app_service_plan_02_name                         = "asp-genashi-trial-${var.environment_prefix}-02"
  app_service_plan_02_sku_name                     = var.function_app_sku_name
  app_service_plan_02_os_type                      = "Linux"
  app_service_plan_02_maximum_elastic_worker_count = 20

  # ---------------------------------------------------------------------------
  # App Service
  # ---------------------------------------------------------------------------

  # Frontend App Service
  frontend_app_service_name          = "frontend-genashi-trial-${var.environment_prefix}-01"
  frontend_app_service_runtime_stack = "22-lts"

  # Load Balancer App Service
  loadbalancer_app_service_name          = "app-load-balancer-genashi-trial-${var.environment_prefix}-01"
  loadbalancer_app_service_runtime_stack = "8.0"

  # Application Insights
  app_service_application_insights = {
    frontend     = "appi-frontend-genashi-trial-${var.environment_prefix}"
    loadbalancer = "appi-app-load-balancer-genashi-trial-${var.environment_prefix}"
  }

  # Diagnostic Settings
  app_service_diagnostic_settings = {
    frontend     = "diag-frontend-genashi-trial-${var.environment_prefix}"
    loadbalancer = "diag-app-load-balancer-genashi-trial-${var.environment_prefix}"
  }

  # ---------------------------------------------------------------------------
  # 9️⃣ サーバーレス基盤（Azure Functions）
  # ---------------------------------------------------------------------------

  # ✅ Function Apps
  # サーバーレスバックエンド処理を行う14個のFunction Appを定義する。
  #
  # 【App Service Plan割当】
  #
  # App Service Plan 01（P3v3）
  # - 01-chat
  # - 02-rag
  # - 03-text-register
  # - 04-pii
  # - 05-prompt
  # - 09-mfg
  # - 10-agent-rag
  # - 11-agent-document
  # - 14-indexer
  #
  # App Service Plan 02（EP1 / Elastic Premium）
  # - 06-pagesplitter
  # - 07-markdown
  # - 08-pdf
  # - 12-page-std
  # - 13-mark-std
  #
  # Plan IDの割当はmain.tfで行う。
  # Plan名・SKU・OS等はapp_service_plan_01_*、
  # app_service_plan_02_* のlocal値で管理する。
  #
  # 診断設定名はlocal.function_diagnostic_settingsで管理する。
  # Application Insights名はlocal.function_application_insightsで管理する。
  # Private Endpoint名はlocal.private_endpointで管理する。

  function_app = {
    # 01: チャット
    # Plan: P3v3
    chat = {
      name           = "func-genashi-trial-${var.environment_prefix}-01-chat"
      python_version = "3.12"
    }

    # 02: RAG処理
    # Plan: P3v3
    rag = {
      name           = "func-genashi-trial-${var.environment_prefix}-02-rag"
      python_version = "3.12"
    }

    # 03: 文書登録・文書プレビュー
    # Plan: P3v3
    register = {
      name           = "func-genashi-trial-${var.environment_prefix}-03-text-register"
      python_version = "3.12"
    }

    # 04: 個人情報検知
    # Plan: P3v3
    pii = {
      name           = "func-genashi-trial-${var.environment_prefix}-04-pii"
      python_version = "3.12"
    }

    # 05: プロンプト管理
    # Plan: P3v3
    prompt = {
      name           = "func-genashi-trial-${var.environment_prefix}-05-prompt"
      python_version = "3.12"
    }

    # 06: ページ分割
    # Plan: EP1
    pagesplitter_001 = {
      name           = "func-genashi-trial-${var.environment_prefix}-06-pagesplitter"
      python_version = "3.12"
    }

    # 07: Markdown変換
    # Plan: EP1
    markdown_001 = {
      name           = "func-genashi-trial-${var.environment_prefix}-07-markdown"
      python_version = "3.12"
    }

    # 08: PDF変換
    # Plan: EP1
    # ACRのコンテナーイメージを使用するため、
    # main.tfではpython_versionをnullとして設定する。
    pdf = {
      name           = "func-genashi-trial-${var.environment_prefix}-08-pdf"
      python_version = "3.12"
    }

    # 09: 製造データ分析
    # Plan: P3v3
    mfg = {
      name           = "func-genashi-trial-${var.environment_prefix}-09-mfg"
      python_version = "3.12"
    }

    # 10: エージェントRAG
    # Plan: P3v3
    agent_rag = {
      name           = "func-genashi-trial-${var.environment_prefix}-10-agent-rag"
      python_version = "3.12"
    }

    # 11: エージェント文書処理
    # Plan: P3v3
    agent_document = {
      name           = "func-genashi-trial-${var.environment_prefix}-11-agent-document"
      python_version = "3.12"
    }

    # 12: 標準エージェント用ページ分割
    # Plan: EP1
    pagesplitter_002 = {
      name           = "func-genashi-trial-${var.environment_prefix}-12-page-std"
      python_version = "3.12"
    }

    # 13: 標準エージェント用Markdown変換
    # Plan: EP1
    markdown_002 = {
      name           = "func-genashi-trial-${var.environment_prefix}-13-mark-std"
      python_version = "3.12"
    }

    # 14: インデクサー連携
    # Plan: P3v3
    indexer = {
      name           = "func-genashi-trial-${var.environment_prefix}-14-indexer"
      python_version = "3.12"
    }
  }

  # Function App診断設定 (ordered by number 01-14)
  function_diagnostic_settings = {
    chat            = "diag-func-genashi-trial-${var.environment_prefix}-01-chat"
    rag             = "diag-func-genashi-trial-${var.environment_prefix}-02-rag"
    register        = "diag-func-genashi-trial-${var.environment_prefix}-03-text-register"
    pii             = "diag-func-genashi-trial-${var.environment_prefix}-04-pii"
    prompt          = "diag-func-genashi-trial-${var.environment_prefix}-05-prompt"
    pagesplitter_001 = "diag-func-genashi-trial-${var.environment_prefix}-06-pagesplitter"
    markdown_001    = "diag-func-genashi-trial-${var.environment_prefix}-07-markdown"
    pdf             = "diag-func-genashi-trial-${var.environment_prefix}-08-pdf"
    mfg             = "diag-func-genashi-trial-${var.environment_prefix}-09-mfg"
    agent_rag       = "diag-func-genashi-trial-${var.environment_prefix}-10-agent-rag"
    agent_document  = "diag-func-genashi-trial-${var.environment_prefix}-11-agent-document"
    pagesplitter_002 = "diag-func-genashi-trial-${var.environment_prefix}-12-page-std"
    markdown_002    = "diag-func-genashi-trial-${var.environment_prefix}-13-mark-std"
    indexer         = "diag-func-genashi-trial-${var.environment_prefix}-14-indexer"
  }

  # Function App Application Insights名 (ordered by number 01-14)
  function_application_insights = {
    chat            = "appi-func-genashi-trial-${var.environment_prefix}-01-chat"
    rag             = "appi-func-genashi-trial-${var.environment_prefix}-02-rag"
    register        = "appi-func-genashi-trial-${var.environment_prefix}-03-text-register"
    pii             = "appi-func-genashi-trial-${var.environment_prefix}-04-pii"
    prompt          = "appi-func-genashi-trial-${var.environment_prefix}-05-prompt"
    pagesplitter_001 = "appi-func-genashi-trial-${var.environment_prefix}-06-pagesplitter"
    markdown_001    = "appi-func-genashi-trial-${var.environment_prefix}-07-markdown"
    pdf             = "appi-func-genashi-trial-${var.environment_prefix}-08-pdf"
    mfg             = "appi-func-genashi-trial-${var.environment_prefix}-09-mfg"
    agent_rag       = "appi-func-genashi-trial-${var.environment_prefix}-10-agent-rag"
    agent_document  = "appi-func-genashi-trial-${var.environment_prefix}-11-agent-document"
    pagesplitter_002 = "appi-func-genashi-trial-${var.environment_prefix}-12-page2"
    markdown_002    = "appi-func-genashi-trial-${var.environment_prefix}-13-mark2"
    indexer         = "appi-func-genashi-trial-${var.environment_prefix}-14-indexer"
  }

  # ---------------------------------------------------------------------------
  # 🔟 プライベートネットワーク基盤（Private DNS / Private Endpoint）
  # ---------------------------------------------------------------------------

  private_dns_zones = {

    # Storage
    blob  = "privatelink.blob.core.windows.net"
    queue = "privatelink.queue.core.windows.net"

    # Cosmos DB
    cosmos_db = "privatelink.documents.azure.com"

    # Key Vault
    key_vault = "privatelink.vaultcore.azure.net"

    # App Service / Functions
    app_service = "privatelink.azurewebsites.net"

    # Container Registry
    container_registry = "privatelink.azurecr.io"

    # Azure OpenAI
    openai = "privatelink.openai.azure.com"

    # Azure AI Search
    search_service = "privatelink.search.windows.net"

    # Azure AI Services
    cognitive_services = "privatelink.cognitiveservices.azure.com"

    # Azure AI Foundry
    services_ai = "privatelink.services.ai.azure.com"
  }

  # ---------------------------------------------------------------------------
  # 🔟A Event Grid
  # ---------------------------------------------------------------------------

  event_grid = {
    system_topic_name              = "egst-genashi-trial-${var.environment_prefix}"
    diagnostic_setting_name        = "diag-egst-genashi-trial-${var.environment_prefix}"
    pdf_subscription_name          = "converttopdf"
    pagesplitter_subscription_name = "pagesplitter"
    markdown_subscription_name     = "mrkdown"
    pdf_container_path             = "/blobServices/default/containers/genashi-trial-01/"
    pagesplitter_container_path    = "/blobServices/default/containers/genashi-trial-02/"
    markdown_container_path        = "/blobServices/default/containers/genashi-trial-03/"
  }

  # ---------------------------------------------------------------------------
  # 1️⃣1️⃣ 監視・アラート基盤（Azure Monitor）
  # ---------------------------------------------------------------------------

  azure_monitor = {

    # -------------------------------------------------------------------------
    # Action Group
    # -------------------------------------------------------------------------
    # アラート通知先
    action_group_name       = "ag-genashi-trial"
    action_group_short_name = "trial"
    action_group_enabled    = true

    # アクショングループ設計書準拠
    email_receivers = [
      {
        name                    = "Generative-AI_-EmailAction-"
        email_address           = "Generative-AI@hitachi-systems.com"
        use_common_alert_schema = false
      }
    ]

    # -------------------------------------------------------------------------
    # Resource Health Alert
    # -------------------------------------------------------------------------
    # Azureリソースの正常性イベントを監視
    resource_health_alert_name           = "ResourceHealthAlert-genashi-trial"
    resource_health_evaluation_frequency = "PT5M"
    resource_health_window_duration      = "PT5M"
    resource_health_severity             = 1
    resource_health_enabled              = true
    resource_health_auto_mitigation      = true

    resource_health_query = <<-EOT
      AzureActivity
      | where CategoryValue contains "ResourceHealth"
      | where Level !contains "informational"
      | where ResourceGroup == "rg-genashi-trial-${var.environment_prefix}"

    EOT

    # -------------------------------------------------------------------------
    # Service Health Alert（全般）
    # -------------------------------------------------------------------------
    # Azureサービス全般の障害・計画メンテナンスを監視
    service_health_alert_01_name = "ServiceHealthAlert-genashi-trial-01"
    service_health_01_enabled    = true

    service_health_01_locations = [
      "Global",
      "Japan West"
    ]

    # 全サービス監視
    service_health_01_services = null

    # -------------------------------------------------------------------------
    # Service Health Alert（Azure OpenAI）
    # -------------------------------------------------------------------------
    # Azure OpenAI Service専用監視
    service_health_alert_02_name = "ServiceHealthAlert-genashi-trial-02"
    service_health_02_enabled    = true

    service_health_02_locations = [
      "East US 2",
      "Global",
      "Sweden Central"
    ]

    service_health_02_services = [
      "Azure OpenAI Service"
    ]

    # -------------------------------------------------------------------------
    # Subscription Scope
    # -------------------------------------------------------------------------
    service_health_scopes = [
      "/subscriptions/${var.subscription_id}"
    ]
  }

  # ---------------------------------------------------------------------------
  # 1️⃣3️⃣ Event Grid基盤
  # ---------------------------------------------------------------------------

  # ✅ Event Grid System Topic
  # Azure StorageのBlobイベントを検知し、各Function Appへ連携する。
  # Storage Accountをイベントソースとして利用する。
  system_topic_name = "egst-genashi-trial-hs"

  # ✅ Event Grid 診断設定
  # Event GridのログおよびメトリックをLog Analyticsへ送信する。
  diagnostic_setting_name = "diag-egst-genashi-trial-hs"

  # ✅ Event Subscription（PDF変換）
  # genashi-trial-01 コンテナへのファイル登録を契機として
  # PDF変換Functionを起動する。
  pdf_subscription_name = "converttopdf"

  # 対象コンテナ
  pdf_container_path = "/blobServices/default/containers/genashi-trial-01/"

  # ✅ Event Subscription（ページ分割）
  # genashi-trial-02 コンテナへのファイル登録を契機として
  # ページ分割Functionを起動する。
  pagesplitter_subscription_name = "pagesplitter"

  # 対象コンテナ
  pagesplitter_container_path = "/blobServices/default/containers/genashi-trial-02/"

  # ✅ Event Subscription（Markdown変換）
  # genashi-trial-03 コンテナへのファイル登録を契機として
  # Markdown変換Functionを起動する。
  markdown_subscription_name = "mrkdown"

  # 対象コンテナ
  markdown_container_path = "/blobServices/default/containers/genashi-trial-03/"

  # ===========================================================================
  # 診断設定
  # ===========================================================================

  # Storage Account の診断設定名
  storage_account_diagnostic_settings = {
    blob  = "diag-storage-blob-${var.environment_prefix}"
    queue = "diag-storage-queue-${var.environment_prefix}"
  }


  # ===========================================================================
  # 共通タグ（コスト管理・運用管理用）
  # ===========================================================================

  # すべてのリソースに付与するタグ
  tags = {
    "機能名称" = "製造現場アシスタントAI"
    "環境"   = "本番"
  }
}
