# ✈️ Contoso Air

A modern airline booking application demonstrating Azure cloud services and modern web development practices.

[![Node.js Version](https://img.shields.io/badge/node-%3E%3D22.0.0-brightgreen)](https://nodejs.org/)
[![Azure CosmosDB](https://img.shields.io/badge/database-Azure%20CosmosDB-blue)](https://azure.microsoft.com/services/cosmos-db/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)

## 📋 Overview

Contoso Air is a sample airline booking application that showcases modern cloud-native development practices using Azure services. This is a revived and modernized version of the previously archived [microsoft/ContosoAir](https://github.com/microsoft/ContosoAir) demo project.

### ✨ Key Features

- **Modern Tech Stack**: Built with Node.js 22 and Express.js
- **Cloud-Native**: Leverages Azure CosmosDB with MongoDB API 7.0
- **Secure Authentication**: Uses Azure Managed Identity for secure access
- **Responsive Design**: Mobile-friendly booking interface
- **Real-time Updates**: Dynamic flight search and booking capabilities
- **Localization**: Multi-language support with i18n

### 🏗️ Architecture

- **Frontend**: Express.js with Handlebars templating
- **Backend**: RESTful API with Node.js
- **Database**: Azure CosmosDB (MongoDB API)
- **Authentication**: Azure Managed Identity
- **Monitoring**: Prometheus metrics integration

## 📁 Project Structure

```
contoso-air/
├── src/web/                 # Main web application
│   ├── app.js              # Express application entry point
│   ├── routes/             # API routes and controllers
│   ├── views/              # Handlebars templates
│   ├── public/             # Static assets (CSS, JS, images)
│   ├── services/           # Business logic services
│   └── repositories/       # Data access layer
├── infra/                  # Infrastructure configuration
│   └── k8s/               # Kubernetes manifests
├── CONTRIBUTING.md         # Contribution guidelines
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 22.0.0 or later ([Download](https://nodejs.org/))
- **Azure CLI** ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **POSIX-compliant shell** (bash, zsh, or similar)
- **Active Azure subscription** with contributor access

### 🔧 Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/karabasosman/contoso-air.git
   cd contoso-air
   ```

2. **Install dependencies**
   ```bash
   cd src/web
   npm install
   ```

3. **Set up Azure resources** (see [Azure Setup](#azure-setup) below)

4. **Start the application**
   ```bash
   npm start
   ```

5. **Open your browser** and navigate to `http://localhost:3000`

## ☁️ Azure Setup

### Automated Resource Creation

The following script will create all necessary Azure resources:

```bash
# Create random resource identifier
RAND=$RANDOM
export RAND
echo "🔧 Random resource identifier: ${RAND}"

# Set variables
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_RESOURCE_GROUP_NAME=rg-contosoair$RAND
AZURE_COSMOS_ACCOUNT_NAME=db-contosoair$RAND
AZURE_REGION=eastus

echo "📋 Creating Azure resources..."

# Create resource group
echo "  ➤ Creating resource group: $AZURE_RESOURCE_GROUP_NAME"
az group create \
  --name $AZURE_RESOURCE_GROUP_NAME \
  --location $AZURE_REGION

# Create CosmosDB account
echo "  ➤ Creating CosmosDB account: $AZURE_COSMOS_ACCOUNT_NAME"
AZURE_COSMOS_ACCOUNT_ID=$(az cosmosdb create \
  --name $AZURE_COSMOS_ACCOUNT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP_NAME \
  --kind MongoDB \
  --server-version 7.0 \
  --query id -o tsv)

# Create test database
echo "  ➤ Creating test database"
az cosmosdb mongodb database create \
  --account-name $AZURE_COSMOS_ACCOUNT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP_NAME \
  --name test

# Create managed identity
echo "  ➤ Creating managed identity"
AZURE_COSMOS_IDENTITY_ID=$(az identity create \
  --name db-contosoair$RAND-id \
  --resource-group $AZURE_RESOURCE_GROUP_NAME \
  --query id -o tsv)

# Get managed identity principal ID
AZURE_COSMOS_IDENTITY_PRINCIPAL_ID=$(az identity show \
  --ids $AZURE_COSMOS_IDENTITY_ID \
  --query principalId \
  -o tsv)

# Assign role to managed identity
echo "  ➤ Assigning permissions"
az role assignment create \
  --role "DocumentDB Account Contributor" \
  --assignee $AZURE_COSMOS_IDENTITY_PRINCIPAL_ID \
  --scope $AZURE_COSMOS_ACCOUNT_ID

# Export environment variables
echo "  ➤ Setting up environment variables"
export AZURE_COSMOS_CLIENTID=$(az identity show \
  --ids $AZURE_COSMOS_IDENTITY_ID \
  --query clientId \
  -o tsv)
export AZURE_COSMOS_LISTCONNECTIONSTRINGURL=https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP_NAME/providers/Microsoft.DocumentDB/databaseAccounts/$AZURE_COSMOS_ACCOUNT_NAME/listConnectionStrings?api-version=2021-04-15
export AZURE_COSMOS_SCOPE=https://management.azure.com/.default

echo "✅ Azure setup complete!"
echo "💡 Environment variables have been set for this session"
```

### Running the Application

After setting up Azure resources:

```bash
# Navigate to the web application directory
cd src/web

# Install dependencies (if not already done)
npm install

# Start the application
npm start
```

The application will be available at `http://localhost:3000`.

## 🛠️ Development

### Available Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start the application in production mode |

### Environment Variables

The application uses the following environment variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `AZURE_COSMOS_CLIENTID` | Azure Managed Identity Client ID | Yes |
| `AZURE_COSMOS_LISTCONNECTIONSTRINGURL` | CosmosDB connection string URL | Yes |
| `AZURE_COSMOS_SCOPE` | Azure authentication scope | Yes |

### Local Development Tips

1. **Database Connection**: The app connects to Azure CosmosDB using Managed Identity
2. **Hot Reload**: Consider using `nodemon` for development with auto-restart
3. **Debugging**: Use VS Code debugger or Node.js inspector for debugging

## 🐛 Troubleshooting

### Common Issues

**Connection Issues**
- Ensure Azure CLI is logged in: `az login`
- Verify resource group and CosmosDB account exist
- Check that managed identity has proper permissions

**Environment Variables**
- Ensure all required environment variables are set
- Variables are session-specific; re-run setup if starting a new terminal

**Port Conflicts**
- Default port is 3000; ensure it's not in use by another application
- Set `PORT` environment variable to use a different port

**Node.js Version**
- Application requires Node.js 22+; check with `node --version`

### Getting Help

1. Check the [Issues](https://github.com/karabasosman/contoso-air/issues) page
2. Review Azure service status at [Azure Status](https://status.azure.com/)
3. Consult [Azure CosmosDB documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)

## 🧹 Cleanup

To remove all Azure resources created during setup:

```bash
az group delete --name $AZURE_RESOURCE_GROUP_NAME --yes --no-wait
```

⚠️ **Warning**: This will permanently delete all resources in the resource group.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code of conduct
- Development process
- Submitting pull requests
- Reporting issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Based on the original [microsoft/ContosoAir](https://github.com/microsoft/ContosoAir) project
- Built with modern Azure cloud services
- Inspired by real-world airline booking systems

---

**Happy coding!** 🚀 If you have questions or need help, don't hesitate to open an issue.
