# Azure Infrastructure Quick Reference
## ZavaStorefront Deployment

## 🚀 Quick Start

```powershell
# 1. Login
azd auth login
az login

# 2. Deploy everything
azd up

# 3. View app
azd show --url
```

## 📋 Common Commands

### Deployment
```powershell
azd up                    # Full deployment (infrastructure + app)
azd deploy                # Deploy app only (existing infrastructure)
azd provision             # Provision infrastructure only
azd down                  # Delete all resources
```

### Monitoring
```powershell
azd monitor --logs        # Stream application logs
azd monitor --overview    # View metrics dashboard
azd show                  # Show deployment details
```

### Environment Management
```powershell
azd env list              # List environments
azd env select            # Switch environments
azd env new               # Create new environment
azd env set               # Set environment variable
```

## 🔑 Key Environment Variables

Set via `azd env set`:

```powershell
azd env set AZURE_LOCATION westus3
azd env set DOCKER_IMAGE_NAME zavastor:latest
```

## 📦 Resource Names

| Type | Pattern |
|------|---------|
| Resource Group | `rg-zavastor-{env}-westus3` |
| App Service | `app-zavastor-{env}-{token}` |
| Container Registry | `crzavastor{token}` |
| Key Vault | `kv-zavastor-{token}` |
| AI Hub | `aih-zavastor-{env}-{token}` |

## 🔐 RBAC Roles Assigned

| Identity | Role | Scope |
|----------|------|-------|
| Managed Identity | AcrPull | Container Registry |
| Managed Identity | Cognitive Services User | AI Services |
| Managed Identity | Key Vault Secrets User | Key Vault |

## 💡 Troubleshooting Commands

```powershell
# View App Service logs
az webapp log tail --name <app-name> --resource-group <rg-name>

# Restart App Service
az webapp restart --name <app-name> --resource-group <rg-name>

# View role assignments
az role assignment list --assignee <identity-id>

# Check ACR connectivity
az acr login --name <acr-name>
```

## 🌐 Important URLs

After deployment, get URLs with:

```powershell
# App URL
az webapp show --name <app-name> --resource-group <rg-name> --query "defaultHostName" -o tsv

# ACR login server
az acr show --name <acr-name> --query "loginServer" -o tsv

# Key Vault URI
az keyvault show --name <kv-name> --query "properties.vaultUri" -o tsv
```

## 📊 Cost Tracking

```powershell
# View current month costs
az consumption usage list --start-date 2025-12-01 --end-date 2025-12-31

# Set budget alert
az consumption budget create --budget-name zavastor-dev --amount 100 --time-grain monthly --resource-group <rg-name>
```

## 🧹 Cleanup

```powershell
# Delete everything
azd down --force --purge

# Or via Azure CLI
az group delete --name rg-zavastor-dev-westus3 --yes --no-wait
```

## 📁 File Structure

```
src/
├── azure.yaml                    # azd configuration
├── Dockerfile                    # Container definition
├── .dockerignore                 # Docker ignore patterns
├── DEPLOYMENT.md                 # Full deployment guide
├── infra/
│   ├── main.bicep               # Main infrastructure
│   ├── main.parameters.json     # Parameters
│   └── core/
│       ├── host/                # Compute resources
│       ├── security/            # Identity & Key Vault
│       ├── monitor/             # Observability
│       └── ai/                  # AI services
```

## 🎯 Deployment Checklist

- [ ] Azure CLI installed (`az version`)
- [ ] Azure Developer CLI installed (`azd version`)
- [ ] Logged in to Azure (`azd auth login`)
- [ ] Subscription selected (`az account show`)
- [ ] Run `azd up` from src directory
- [ ] Verify deployment (`azd show`)
- [ ] Test application URL
- [ ] Check Application Insights for telemetry

## 🔗 Links

- [Full Deployment Guide](./DEPLOYMENT.md)
- [GitHub Issue #1](https://github.com/shwetabodhankar/tech300-ghcp/issues/1)
- [Azure Portal](https://portal.azure.com)
- [azd Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
