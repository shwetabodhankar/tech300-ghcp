# Zava Storefront - ASP.NET Core MVC

A simple e-commerce storefront application built with .NET 6 ASP.NET MVC.

## Features

- **Product Listing**: Browse a catalog of 8 sample products with images, descriptions, and prices
- **Shopping Cart**: Add products to cart with session-based storage
- **Cart Management**: View cart, update quantities, remove items
- **Checkout**: Simple checkout process that clears cart and shows success message
- **Responsive Design**: Mobile-friendly layout using Bootstrap 5

## Technology Stack

- .NET 6
- ASP.NET Core MVC
- Bootstrap 5
- Bootstrap Icons
- Session-based state management (no database)

## Project Structure

```
ZavaStorefront/
├── Controllers/
│   ├── HomeController.cs      # Products listing and add to cart
│   └── CartController.cs       # Cart operations and checkout
├── Models/
│   ├── Product.cs              # Product model
│   └── CartItem.cs             # Cart item model
├── Services/
│   ├── ProductService.cs       # Static product data
│   └── CartService.cs          # Session-based cart management
├── Views/
│   ├── Home/
│   │   └── Index.cshtml        # Products listing page
│   ├── Cart/
│   │   ├── Index.cshtml        # Shopping cart page
│   │   └── CheckoutSuccess.cshtml  # Checkout success page
│   └── Shared/
│       └── _Layout.cshtml      # Main layout with cart icon
└── wwwroot/
    ├── css/
    │   └── site.css            # Custom styles
    └── images/
        └── products/           # Product images directory
```

## How to Run Locally

1. Navigate to the project directory:
   ```bash
   cd ZavaStorefront
   ```

2. Run the application:
   ```bash
   dotnet run
   ```

3. Open your browser and navigate to:
   ```
   https://localhost:5001
   ```

## Deploy to Azure

This application is configured for deployment to Azure using the Azure Developer CLI (azd) with containerized deployment to Azure App Service.

### Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription
- **No Docker installation required** - azd handles container builds in Azure

### Infrastructure Overview

The deployment provisions the following Azure resources in **westus3**:

- **Azure App Service** (Linux, B1 SKU) - Hosts the containerized application
- **Azure Container Registry** (Basic SKU) - Stores Docker images
- **Application Insights** - Monitoring and telemetry
- **Log Analytics Workspace** - Centralized logging
- **Azure AI Foundry Hub** - AI workloads (GPT-4, Phi models)
- **Azure AI Services** - Cognitive services for AI integration
- **Azure Key Vault** - Secrets management for AI services
- **Storage Account** - AI assets storage
- **User-Assigned Managed Identity** - Passwordless authentication via RBAC

All resources use **managed identity with RBAC** - no passwords or connection strings stored.

### Deployment Steps

1. **Login to Azure**:
   ```bash
   azd auth login
   az login
   ```

2. **Initialize and deploy** (first time):
   ```bash
   azd up
   ```
   
   This single command will:
   - Prompt for environment name (e.g., `dev`)
   - Prompt for Azure subscription
   - Provision all infrastructure using Bicep
   - Build the Docker container image
   - Push the image to Azure Container Registry
   - Deploy the container to App Service
   - Configure managed identity and RBAC roles

3. **View your deployed application**:
   ```bash
   azd show
   ```
   
   Or visit the URL displayed after deployment completes.

### Subsequent Deployments

After initial provisioning, you can deploy application updates without reprovisioning infrastructure:

```bash
azd deploy
```

### View Application Logs

```bash
azd monitor --logs
```

Or view logs in the Azure Portal via Application Insights.

### Infrastructure Details

The infrastructure is defined in Bicep modules located in the `infra/` directory:

```
infra/
├── main.bicep                    # Main orchestration file
├── main.parameters.json          # Parameters file
└── core/
    ├── host/
    │   ├── appservice.bicep      # App Service configuration
    │   ├── appserviceplan.bicep  # App Service Plan
    │   └── container-registry.bicep  # Azure Container Registry
    ├── security/
    │   ├── managed-identity.bicep    # User-assigned identity
    │   ├── keyvault.bicep           # Key Vault for AI
    │   └── role-assignment.bicep    # RBAC role assignments
    ├── monitor/
    │   ├── applicationinsights.bicep # Application Insights
    │   └── loganalytics.bicep       # Log Analytics Workspace
    └── ai/
        ├── ai-hub.bicep             # Azure AI Foundry Hub
        ├── ai-services.bicep        # Azure AI Services
        └── storage.bicep            # Storage for AI assets
```

### Security Features

- ✅ **No admin passwords**: ACR uses managed identity with `AcrPull` role
- ✅ **RBAC-based access**: All Azure resource access via role assignments
- ✅ **HTTPS only**: App Service enforces HTTPS
- ✅ **TLS 1.2 minimum**: Modern encryption standards
- ✅ **Managed identities**: Passwordless authentication to Azure services

### Cost Optimization

This configuration uses Basic/Standard SKUs optimized for development environments:

| Resource | SKU | Estimated Cost/Month (USD) |
|----------|-----|---------------------------|
| App Service Plan | B1 Basic Linux | ~$13 |
| Container Registry | Basic | ~$5 |
| Application Insights | Pay-as-you-go | ~$2-5 |
| Log Analytics | 5GB free tier | ~$0-2 |
| AI Foundry Hub | S0 Standard | ~$10-50 |
| Storage Account | Standard LRS | ~$1-2 |
| Key Vault | Standard | ~$0.03 |
| **Total** | | **~$31-87/month** |

### Environment Variables

The following environment variables are automatically configured by the deployment:

- `APPLICATIONINSIGHTS_CONNECTION_STRING` - Application Insights connection
- `ASPNETCORE_ENVIRONMENT` - Set to `Development`
- `AZURE_OPENAI_ENDPOINT` - AI Services endpoint
- `AI_HUB_WORKSPACE_ID` - Azure AI Foundry workspace ID
- `WEBSITES_PORT` - Container port (80)
- `DOCKER_REGISTRY_SERVER_URL` - ACR login server

### Clean Up Resources

To delete all Azure resources:

```bash
azd down
```

This will remove the resource group and all contained resources.

### Troubleshooting

**Issue**: Deployment fails with authentication error  
**Solution**: Run `azd auth login` and `az login` to refresh credentials

**Issue**: Container fails to start  
**Solution**: Check logs with `azd monitor --logs` or view in Azure Portal

**Issue**: App Service can't pull from ACR  
**Solution**: Verify managed identity has `AcrPull` role (automatically configured)

### Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)

## Product Images

The application includes 8 sample products. Product images are referenced from:
- `/wwwroot/images/products/`

If images are not found, the application automatically falls back to placeholder images from placeholder.com.

To add custom product images, place JPG files in `wwwroot/images/products/` with these names:
- headphones.jpg
- smartwatch.jpg
- speaker.jpg
- charger.jpg
- usb-hub.jpg
- keyboard.jpg
- mouse.jpg
- webcam.jpg

## Sample Products

1. Wireless Bluetooth Headphones - $89.99
2. Smart Fitness Watch - $199.99
3. Portable Bluetooth Speaker - $49.99
4. Wireless Charging Pad - $29.99
5. USB-C Hub Adapter - $39.99
6. Mechanical Gaming Keyboard - $119.99
7. Ergonomic Wireless Mouse - $34.99
8. HD Webcam - $69.99

## Application Flow

1. **Landing Page**: Displays all products in a responsive grid
2. **Add to Cart**: Click "Buy" button to add products to cart
3. **View Cart**: Click cart icon (top right) to view cart contents
4. **Update Cart**: Modify quantities or remove items
5. **Checkout**: Click "Checkout" button to complete purchase
6. **Success**: View confirmation and return to products

## Session Management

- Cart data is stored in session
- Session timeout: 30 minutes
- No data persistence (cart clears when session expires)
- Cart is cleared after successful checkout

## Logging

The application includes structured logging for:
- Product page loads
- Adding products to cart
- Cart operations (update, remove)
- Checkout process

Logs are written to console during development.
