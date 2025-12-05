# Azure Infrastructure Deployment Guide
## ZavaStorefront - GitHub Issue #1

This document provides a comprehensive guide for deploying the ZavaStorefront application infrastructure to Azure.

## 📋 Overview

The infrastructure provisions a complete Azure environment for the ZavaStorefront ASP.NET Core MVC application in the **westus3** region using:

- **Infrastructure as Code**: Bicep modules
- **Deployment Tool**: Azure Developer CLI (azd)
- **Containerization**: Docker (no local installation required)
- **Security**: Managed Identity with RBAC (passwordless)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Resource Group                     │
│                  (rg-zavastor-dev-westus3)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐         ┌─────────────────────┐     │
│  │  App Service     │────────>│  Container Registry │     │
│  │  (Linux/Docker)  │  pulls  │     (ACR Basic)     │     │
│  │    Port: 80      │  image  │  Admin: Disabled    │     │
│  └────────┬─────────┘         └─────────────────────┘     │
│           │                                                 │
│           │ uses                                            │
│           ▼                                                 │
│  ┌──────────────────┐                                      │
│  │ Managed Identity │──── AcrPull ────┐                   │
│  │  (User-Assigned) │                 │                   │
│  └────────┬─────────┘                 │                   │
│           │                            │                   │
│           ├─── Cognitive Services ────┤                   │
│           │         User              │                   │
│           │                            │                   │
│           └─── Key Vault Secrets ─────┘                   │
│                    User                                     │
│                                                             │
│  ┌──────────────────┐         ┌─────────────────────┐     │
│  │ Application      │────────>│  Log Analytics      │     │
│  │   Insights       │  sends  │    Workspace        │     │
│  │  (Monitoring)    │  logs   │   (30 day retain)   │     │
│  └──────────────────┘         └─────────────────────┘     │
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │         Azure AI Foundry Hub                     │     │
│  │  ┌────────────┐  ┌──────────┐  ┌─────────────┐ │     │
│  │  │AI Services │  │Key Vault │  │   Storage   │ │     │
│  │  │  (GPT-4)   │  │  (Secure)│  │  (AI Assets)│ │     │
│  │  └────────────┘  └──────────┘  └─────────────┘ │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security Architecture

### Authentication Flow

1. **App Service** uses **User-Assigned Managed Identity**
2. **Managed Identity** has RBAC roles:
   - `AcrPull` → Pull Docker images from ACR
   - `Cognitive Services User` → Access AI Services
   - `Key Vault Secrets User` → Read AI secrets

**✅ No passwords, connection strings, or access keys required!**

## 📦 Resources Provisioned

| Resource Type | Name Pattern | Purpose | SKU/Tier |
|--------------|--------------|---------|----------|
| Resource Group | `rg-zavastor-dev-westus3` | Container for all resources | - |
| Managed Identity | `id-zavastor-dev-{token}` | Passwordless auth | - |
| Container Registry | `crzavastor{token}` | Docker image storage | Basic |
| App Service Plan | `asp-zavastor-dev-{token}` | Compute for App Service | B1 Linux |
| App Service | `app-zavastor-dev-{token}` | Web application host | - |
| Log Analytics | `log-zavastor-dev-{token}` | Centralized logging | PerGB2018 |
| Application Insights | `appi-zavastor-dev-{token}` | APM & monitoring | - |
| Storage Account | `stzavastor{token}` | AI assets storage | Standard_LRS |
| Key Vault | `kv-zavastor-{token}` | AI secrets management | Standard |
| AI Services | `ais-zavastor-dev-{token}` | Cognitive services | S0 |
| AI Hub | `aih-zavastor-dev-{token}` | AI Foundry workspace | - |

*Note: `{token}` is a unique string generated from subscription ID and environment*

## 🚀 Deployment Instructions

### Prerequisites

Install required tools:

```powershell
# Azure Developer CLI
winget install microsoft.azd

# Azure CLI
winget install microsoft.azurecli
```

Verify installations:

```powershell
azd version
az version
```

### Step 1: Authenticate to Azure

```powershell
# Login with Azure Developer CLI
azd auth login

# Login with Azure CLI
az login

# (Optional) Set default subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 2: Initialize Environment

```powershell
# Navigate to project directory
cd C:\BNP\GHCP\TechWorkshop-L300-GHCP\src

# Initialize azd (if not already done)
azd init
```

When prompted:
- **Environment name**: `dev` (or your preferred name)
- Confirm the environment settings

### Step 3: Deploy Infrastructure & Application

```powershell
# Single command deployment
azd up
```

This command will:
1. ✅ Validate Bicep templates
2. ✅ Create resource group in westus3
3. ✅ Provision all infrastructure resources
4. ✅ Assign RBAC roles to managed identity
5. ✅ Build Docker container image
6. ✅ Push image to Azure Container Registry
7. ✅ Configure App Service with container
8. ✅ Deploy application

**⏱️ Estimated time: 10-15 minutes**

### Step 4: Verify Deployment

```powershell
# View deployment details
azd show

# Open the application in browser
azd show --url
```

Expected output:
```
Services:
  web:
    - Endpoint: https://app-zavastor-dev-xxxxx.azurewebsites.net/

Azure Resources:
  Resource Group: rg-zavastor-dev-westus3
  Location: westus3
```

## 🔄 Development Workflow

### Deploy Application Updates

After making code changes:

```powershell
# Deploy only the application (no infrastructure changes)
azd deploy
```

### View Application Logs

```powershell
# Stream live logs
azd monitor --logs

# Or use Azure CLI
az webapp log tail --name <app-service-name> --resource-group rg-zavastor-dev-westus3
```

### Access Azure Portal

```powershell
# Open resource group in portal
az group show --name rg-zavastor-dev-westus3 --query "properties.portalUrl" -o tsv
```

## 🧹 Clean Up Resources

### Delete All Resources

```powershell
# Remove all Azure resources
azd down

# Confirm deletion when prompted
```

This will:
- Delete the resource group
- Remove all contained resources
- Clean up local azd environment

### Purge Soft-Deleted Resources (Optional)

Key Vault has soft-delete enabled. To completely remove:

```powershell
# List soft-deleted vaults
az keyvault list-deleted

# Purge specific vault
az keyvault purge --name kv-zavastor-xxxxx --location westus3
```

## 🐛 Troubleshooting

### Issue: "azd up" fails with authentication error

**Solution**:
```powershell
azd auth login --use-device-code
az login --use-device-code
```

### Issue: Container fails to pull from ACR

**Symptoms**: App Service shows "Container pull failed"

**Solution**:
1. Verify managed identity has AcrPull role:
   ```powershell
   az role assignment list --assignee <managed-identity-principal-id> --scope <acr-resource-id>
   ```

2. Check App Service configuration:
   ```powershell
   az webapp config show --name <app-name> --resource-group rg-zavastor-dev-westus3 --query "acrUseManagedIdentityCreds"
   ```
   Should return `true`

### Issue: Application Insights not showing data

**Solution**:
1. Check connection string is configured:
   ```powershell
   az webapp config appsettings list --name <app-name> --resource-group rg-zavastor-dev-westus3 --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"
   ```

2. Wait 2-5 minutes for telemetry to appear

### Issue: Deployment quota exceeded

**Symptoms**: "Quota exceeded for Basic SKU in westus3"

**Solution**: Try a different region or upgrade SKU:

```bicep
// In infra/main.bicep, change location parameter
param location string = 'eastus'  // or westus2, centralus

// Or upgrade SKU
sku: {
  name: 'S1'
  tier: 'Standard'
}
```

## 📊 Monitoring & Observability

### Application Insights Queries

Access via Azure Portal > Application Insights > Logs

**Recent exceptions**:
```kusto
exceptions
| where timestamp > ago(1h)
| order by timestamp desc
| project timestamp, type, outerMessage, problemId
```

**Request performance**:
```kusto
requests
| where timestamp > ago(1h)
| summarize count(), avg(duration) by name
| order by avg_duration desc
```

**Failed requests**:
```kusto
requests
| where success == false
| where timestamp > ago(24h)
| project timestamp, name, resultCode, duration
```

### Key Metrics to Monitor

- **Availability**: Target > 99.9%
- **Response Time**: Target < 500ms (p95)
- **Error Rate**: Target < 1%
- **Container Restarts**: Target = 0

## 💰 Cost Management

### Expected Monthly Costs (Dev Environment)

| Resource | Cost | Notes |
|----------|------|-------|
| App Service Plan B1 | $13.14 | 730 hours/month |
| Container Registry Basic | $5.00 | 10GB storage included |
| Application Insights | $2.30 | ~1GB data ingestion |
| Log Analytics | $0.00 | First 5GB free |
| AI Services S0 | $10-50 | Pay-per-use |
| Storage Standard LRS | $1.84 | 50GB storage |
| Key Vault | $0.03 | 10K operations |
| **Total** | **$32-82** | |

### Cost Optimization Tips

1. **Stop when not in use**:
   ```powershell
   az webapp stop --name <app-name> --resource-group rg-zavastor-dev-westus3
   ```

2. **Use Free tier for Log Analytics** (5GB/month)

3. **Scale down App Service Plan**:
   ```powershell
   az appservice plan update --name <plan-name> --resource-group rg-zavastor-dev-westus3 --sku F1
   ```

4. **Delete when not needed**:
   ```powershell
   azd down
   ```

## 🔄 CI/CD Integration (Future)

To set up GitHub Actions:

```powershell
azd pipeline config
```

This will:
- Create a service principal
- Configure GitHub secrets
- Generate `.github/workflows/azure-dev.yml`

## 📚 Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep Language Reference](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure App Service on Linux](https://learn.microsoft.com/azure/app-service/overview)
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)
- [Azure AI Foundry](https://learn.microsoft.com/azure/ai-studio/)
- [Managed Identities for Azure Resources](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/)

## ✅ Acceptance Criteria (Issue #1)

- [x] Bicep modules authored and committed
- [x] azd template provided for development deployment
- [x] Bicep handles App Service/ACR RBAC setup (no passwords)
- [x] Documentation covers local developer workflow (no Docker required)
- [x] All services deployable with single `azd up` command
- [x] App Service Linux with Docker container deployment
- [x] ACR integration via managed identity
- [x] Application Insights monitoring enabled
- [x] Microsoft Foundry (Azure AI Foundry Hub) provisioned in westus3
- [x] All resources in westus3 region
- [x] Dev environment optimized (cost-effective SKUs)

---

**Last Updated**: December 4, 2025  
**Issue Reference**: [GitHub Issue #1](https://github.com/shwetabodhankar/tech300-ghcp/issues/1)
