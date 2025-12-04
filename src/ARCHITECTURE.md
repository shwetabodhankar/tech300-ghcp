# Azure Architecture Diagram
## ZavaStorefront Infrastructure

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         Azure Subscription                               │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │              Resource Group: rg-zavastor-dev-westus3              │ │
│  │                        Region: westus3                             │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Compute Layer                               │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  App Service Plan (asp-zavastor-dev-xxxxx)          │     │   │
│  │  │  SKU: B1 (Basic, Linux)                             │     │   │
│  │  │  OS: Linux                                           │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  │           │                                                    │   │
│  │           │ hosts                                              │   │
│  │           ▼                                                    │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  App Service (app-zavastor-dev-xxxxx)               │     │   │
│  │  │  Type: Linux Container                               │     │   │
│  │  │  Runtime: Docker                                     │     │   │
│  │  │  HTTPS Only: ✓                                       │     │   │
│  │  │  Always On: Disabled (dev)                           │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│                              │ pulls image                              │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                Container Registry Layer                         │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Azure Container Registry (crzavastorxxxxx)         │     │   │
│  │  │  SKU: Basic                                          │     │   │
│  │  │  Admin: Disabled                                     │     │   │
│  │  │  Image: zavastor:latest                             │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Security Layer                              │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  User-Assigned Managed Identity                     │     │   │
│  │  │  (id-zavastor-dev-xxxxx)                           │     │   │
│  │  │                                                      │     │   │
│  │  │  Assigned To: App Service                           │     │   │
│  │  │                                                      │     │   │
│  │  │  RBAC Roles:                                        │     │   │
│  │  │  ├─► AcrPull → Container Registry                  │     │   │
│  │  │  ├─► Cognitive Services User → AI Services         │     │   │
│  │  │  └─► Key Vault Secrets User → Key Vault           │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Key Vault (kv-zavastor-xxxxx)                     │     │   │
│  │  │  SKU: Standard                                      │     │   │
│  │  │  RBAC: Enabled                                      │     │   │
│  │  │  Purpose: AI service secrets                       │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                   Observability Layer                           │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Log Analytics Workspace                            │     │   │
│  │  │  (log-zavastor-dev-xxxxx)                          │     │   │
│  │  │  Retention: 30 days                                 │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  │           │                                                    │   │
│  │           │ stores logs                                        │   │
│  │           ▼                                                    │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Application Insights                               │     │   │
│  │  │  (appi-zavastor-dev-xxxxx)                         │     │   │
│  │  │                                                      │     │   │
│  │  │  Connected to: App Service                          │     │   │
│  │  │  Features:                                           │     │   │
│  │  │  ├─ Request tracking                                │     │   │
│  │  │  ├─ Dependency tracking                             │     │   │
│  │  │  ├─ Exception monitoring                            │     │   │
│  │  │  └─ Live metrics                                    │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    AI Services Layer                            │   │
│  │                                                                 │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Azure AI Services (ais-zavastor-dev-xxxxx)        │     │   │
│  │  │  SKU: S0 (Standard)                                 │     │   │
│  │  │  Kind: AIServices                                    │     │   │
│  │  │  Models: GPT-4, Phi (available)                    │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  │           │                                                    │   │
│  │           │ connected to                                       │   │
│  │           ▼                                                    │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Azure AI Foundry Hub                               │     │   │
│  │  │  (aih-zavastor-dev-xxxxx)                          │     │   │
│  │  │                                                      │     │   │
│  │  │  Workspace Type: Hub                                │     │   │
│  │  │  Region: westus3 (GPT-4/Phi support)              │     │   │
│  │  │                                                      │     │   │
│  │  │  Dependencies:                                       │     │   │
│  │  │  ├─ AI Services (connection)                       │     │   │
│  │  │  ├─ Storage Account                                 │     │   │
│  │  │  ├─ Key Vault                                       │     │   │
│  │  │  └─ Application Insights                           │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  │           │                                                    │   │
│  │           │ uses                                               │   │
│  │           ▼                                                    │   │
│  │  ┌──────────────────────────────────────────────────────┐     │   │
│  │  │  Storage Account (stzavastorxxxxx)                 │     │   │
│  │  │  SKU: Standard_LRS                                  │     │   │
│  │  │  Purpose: AI assets, models, datasets              │     │   │
│  │  └──────────────────────────────────────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════

                          Data Flow Diagram

┌────────────┐                  ┌─────────────────┐
│   User     │───── HTTPS ─────>│   App Service   │
│  (Browser) │<──── Response ───│  (Port 80/443)  │
└────────────┘                  └────────┬────────┘
                                         │
                           ┌─────────────┴─────────────┐
                           │                           │
                           ▼                           ▼
                  ┌─────────────────┐      ┌──────────────────┐
                  │  Application    │      │   AI Services    │
                  │    Insights     │      │   (via MI)       │
                  │  (Telemetry)    │      │  GPT-4 / Phi     │
                  └─────────────────┘      └──────────────────┘

═══════════════════════════════════════════════════════════════════════════

                    Security & Authentication Flow

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  App Service                                                    │
│      │                                                          │
│      │ authenticates as                                         │
│      ▼                                                          │
│  Managed Identity (MI)                                          │
│      │                                                          │
│      ├──────► [AcrPull Role] ──────────► Container Registry   │
│      │                                    (Pull Images)         │
│      │                                                          │
│      ├──────► [Cognitive Services] ─────► AI Services          │
│      │         User Role                  (Inference)           │
│      │                                                          │
│      └──────► [Key Vault Secrets] ──────► Key Vault           │
│                User Role                   (Read Secrets)       │
│                                                                 │
│  ✓ No passwords                                                │
│  ✓ No connection strings                                       │
│  ✓ No access keys                                              │
│  ✓ All via Azure AD                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════

                        Deployment Flow

Developer Machine                    Azure Cloud
─────────────────                    ────────────

┌─────────────┐
│  azd up     │
└──────┬──────┘
       │
       ├───► 1. Provision Infrastructure (Bicep)
       │         ├─ Create Resource Group
       │         ├─ Deploy Managed Identity
       │         ├─ Deploy ACR, App Service Plan, App Service
       │         ├─ Deploy Monitoring (App Insights, Log Analytics)
       │         ├─ Deploy AI Hub, AI Services, Key Vault, Storage
       │         └─ Assign RBAC Roles
       │
       ├───► 2. Build Docker Image
       │         └─ Multi-stage build (SDK → Runtime)
       │
       ├───► 3. Push to ACR
       │         └─ Using ACR Tasks (no local Docker)
       │
       └───► 4. Deploy to App Service
                 └─ Configure container settings
                 └─ Set environment variables
                 └─ Start application

═══════════════════════════════════════════════════════════════════════════

                           Network Diagram

Internet                  Azure (westus3)
────────                  ───────────────

  User
   │
   │ HTTPS (443)
   │
   ▼
┌──────────────────┐
│  App Service     │
│  Public Endpoint │
└────────┬─────────┘
         │
         │ (internal)
         │
         ├──────────────────────────┐
         │                          │
         ▼                          ▼
┌─────────────────┐      ┌──────────────────┐
│  ACR            │      │  AI Services     │
│  (private pull) │      │  (private API)   │
└─────────────────┘      └──────────────────┘
         │                          │
         └──────────┬───────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │  Application Insights│
         │  (Azure Backbone)    │
         └──────────────────────┘

═══════════════════════════════════════════════════════════════════════════

Legend:
───────
MI   = Managed Identity
ACR  = Azure Container Registry
RBAC = Role-Based Access Control
SKU  = Stock Keeping Unit (pricing tier)
