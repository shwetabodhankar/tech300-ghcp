# GitHub Actions Deployment Setup

This workflow builds and deploys the ZavaStorefront .NET application as a container to Azure App Service.

## Prerequisites

Your Azure infrastructure must already be provisioned (App Service, Container Registry, etc.) using the Bicep templates in the `infra` folder.

## Required GitHub Secrets

Configure the following secrets in your GitHub repository (Settings → Secrets and variables → Actions):

### 1. `AZURE_CREDENTIALS`

Service principal credentials for Azure login. Create using:

```bash
az ad sp create-for-rbac --name "github-actions-zavastor" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-zavastor-techexcelnew-westus3 \
  --sdk-auth
```

Copy the entire JSON output and save it as the `AZURE_CREDENTIALS` secret.

### 2. `ACR_USERNAME`

Azure Container Registry username. Get it using:

```bash
az acr credential show --name crzavastorejrkivovnq45u --query "username" -o tsv
```

### 3. `ACR_PASSWORD`

Azure Container Registry password. Get it using:

```bash
az acr credential show --name crzavastorejrkivovnq45u --query "passwords[0].value" -o tsv
```

**Note:** You may need to enable admin user on the Container Registry first:

```bash
az acr update --name crzavastorejrkivovnq45u --admin-enabled true
```

## Workflow Trigger

The workflow runs automatically on:
- Push to the `main` branch
- Manual trigger via GitHub Actions UI

## What It Does

1. Checks out the code
2. Logs in to Azure Container Registry
3. Builds the Docker image from `src/Dockerfile`
4. Pushes the image with both commit SHA and `latest` tags
5. Logs in to Azure
6. Deploys the container image to Azure App Service

## Customization

If your resource names differ, update the environment variables at the top of `.github/workflows/deploy.yml`:

- `AZURE_WEBAPP_NAME`: Your App Service name
- `CONTAINER_REGISTRY`: Your ACR login server
- `IMAGE_NAME`: Your Docker image name
