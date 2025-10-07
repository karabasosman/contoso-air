# Contoso Air - Modernized Airline Booking Demo

A sample airline booking application used for demos and learning purposes, showcasing modern cloud-native architecture and Azure best practices.

## 🎯 Project Overview

This repository is a revived and modernized version of the previously archived [microsoft/ContosoAir](https://github.com/microsoft/ContosoAir) demo project. The application has been completely rebuilt with current technology standards and cloud-native practices, making it an ideal reference for:

- Modern web application architecture with Node.js
- Azure cloud services integration
- Secure authentication patterns
- Container orchestration with Kubernetes
- CI/CD pipelines with GitHub Actions

## ✨ Key Features

### Application Features
- **Flight Search & Booking**: Search flights between cities and complete bookings
- **User Authentication**: Secure login system with Passport.js
- **Booking Management**: View and manage flight bookings
- **Multi-language Support**: Internationalization (i18n) with English and Spanish
- **Responsive Design**: Mobile-friendly UI with Bootstrap 5
- **Monitoring**: Built-in Prometheus metrics for observability

### Technical Features
- **Node.js 22**: Latest LTS version for optimal performance
- **Azure CosmosDB**: MongoDB API 7.0 for scalable data storage
- **Managed Identity**: Passwordless authentication to Azure services
- **Containerized**: Docker support for consistent deployments
- **Kubernetes Ready**: Production-grade K8s manifests with HPA support
- **CI/CD Pipeline**: Automated build and deployment with GitHub Actions
- **Security Hardened**: Non-root containers, resource limits, and security contexts

## 🏗️ Architecture

```
├── src/web/                 # Main web application
│   ├── routes/             # Express route handlers
│   ├── services/           # Business logic layer
│   ├── repositories/       # Data access layer (CosmosDB)
│   ├── views/              # Handlebars templates
│   ├── public/             # Static assets (CSS, JS, images)
│   └── Dockerfile          # Container definition
├── infra/k8s/              # Kubernetes manifests
│   ├── k8s-deployment.yaml # Deployment and Service
│   ├── k8s-hpa.yaml        # Horizontal Pod Autoscaler
│   └── k8s-configmap.yaml  # Configuration
└── .github/workflows/      # CI/CD pipelines
    └── azure-kubernetes-service.yml
```

## 🚀 Modernization Highlights

This project represents a comprehensive modernization effort (tracked in Azure DevOps - Task #1892) that includes:

1. **Technology Stack Upgrade**
   - Migrated to Node.js 22 from older versions
   - Updated to Express 5.x with modern middleware
   - Integrated Azure SDK v4 for identity management
   - Updated all dependencies to latest stable versions

2. **Authentication Modernization**
   - Implemented Azure Managed Identity for passwordless auth
   - Removed hardcoded credentials from codebase
   - Added DefaultAzureCredential pattern for secure access

3. **Infrastructure as Code**
   - Created Kubernetes deployment manifests
   - Implemented horizontal pod autoscaling
   - Added resource requests and limits
   - Configured health checks and security contexts

4. **CI/CD Pipeline**
   - GitHub Actions workflow for automated builds
   - Container image building with Azure ACR
   - Automated deployment to Azure Kubernetes Service
   - OpenID Connect (OIDC) authentication for secure deployments

5. **Developer Experience**
   - Comprehensive setup documentation
   - Clear prerequisite requirements
   - Step-by-step deployment guide
   - Local development support

To get started, follow the setup instructions below, which will guide you through configuring the necessary Azure resources and running the application locally.

## 📋 Prerequisites

- **Node.js**: Version 22.0.0 or later ([Download](https://nodejs.org/))
- **Azure CLI**: Latest version ([Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **POSIX Shell**: bash or zsh (Linux/macOS/WSL)
- **Azure Subscription**: Required for CosmosDB and other services
- **Docker** (optional): For containerized development
- **kubectl** (optional): For Kubernetes deployment

## 🛠️ Getting Started

### Step 1: Azure Resource Setup

Create an Azure CosmosDB account with MongoDB API and configure managed identity authentication:

```bash
# Create random resource identifier for unique names
RAND=$RANDOM
export RAND
echo "Random resource identifier will be: ${RAND}"

# Set variables for Azure resources
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_RESOURCE_GROUP_NAME=rg-contosoair$RAND
AZURE_COSMOS_ACCOUNT_NAME=db-contosoair$RAND
AZURE_REGION=eastus

# Create resource group
az group create \
--name $AZURE_RESOURCE_GROUP_NAME \
--location $AZURE_REGION

# Create CosmosDB account with MongoDB API 7.0
AZURE_COSMOS_ACCOUNT_ID=$(az cosmosdb create \
--name $AZURE_COSMOS_ACCOUNT_NAME \
--resource-group $AZURE_RESOURCE_GROUP_NAME \
--kind MongoDB \
--server-version 7.0 \
--query id -o tsv)

# Create test database for booking data
az cosmosdb mongodb database create \
  --account-name $AZURE_COSMOS_ACCOUNT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP_NAME \
  --name test
```

### Step 2: Configure Managed Identity

Set up Azure Managed Identity for passwordless authentication:

```bash
# Create managed identity
AZURE_COSMOS_IDENTITY_ID=$(az identity create \
--name db-contosoair$RAND-id \
--resource-group $AZURE_RESOURCE_GROUP_NAME \
--query id -o tsv)

# Get managed identity principal ID
AZURE_COSMOS_IDENTITY_PRINCIPAL_ID=$(az identity show \
--ids $AZURE_COSMOS_IDENTITY_ID \
--query principalId \
-o tsv)

# Assign DocumentDB role to managed identity
az role assignment create \
--role "DocumentDB Account Contributor" \
--assignee $AZURE_COSMOS_IDENTITY_PRINCIPAL_ID \
--scope $AZURE_COSMOS_ACCOUNT_ID

# Export environment variables for application
export AZURE_COSMOS_CLIENTID=$(az identity show \
--ids $AZURE_COSMOS_IDENTITY_ID \
--query clientId \
-o tsv)
export AZURE_COSMOS_LISTCONNECTIONSTRINGURL=https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP_NAME/providers/Microsoft.DocumentDB/databaseAccounts/$AZURE_COSMOS_ACCOUNT_NAME/listConnectionStrings?api-version=2021-04-15
export AZURE_COSMOS_SCOPE=https://management.azure.com/.default
```

### Step 3: Run the Application Locally

Clone the repository and start the application:

```bash
# Clone the repository (if not already done)
git clone https://github.com/karabasosman/contoso-air.git
cd contoso-air

# Navigate to the web application directory
cd src/web

# Install dependencies
npm install

# Start the application
npm start
```

The application will be available at `http://localhost:3000`

### Step 4: Explore the Application

- **Home Page**: Browse featured destinations and deals
- **Search Flights**: Search for flights between cities with date selection
- **Book Flight**: Complete the booking process (requires Azure CosmosDB setup)
- **View Bookings**: See your booking history and receipt

## 🐳 Docker Deployment

Build and run the application using Docker:

```bash
# Build the Docker image
docker build -t contoso-air:latest ./src/web

# Run the container
docker run -p 3000:3000 \
  -e AZURE_COSMOS_CLIENTID=$AZURE_COSMOS_CLIENTID \
  -e AZURE_COSMOS_LISTCONNECTIONSTRINGURL=$AZURE_COSMOS_LISTCONNECTIONSTRINGURL \
  -e AZURE_COSMOS_SCOPE=$AZURE_COSMOS_SCOPE \
  contoso-air:latest
```

## ☸️ Kubernetes Deployment

Deploy to Azure Kubernetes Service (AKS):

```bash
# Set up kubectl context
az aks get-credentials --resource-group <your-rg> --name <your-aks-cluster>

# Apply Kubernetes manifests
kubectl apply -f infra/k8s/

# Check deployment status
kubectl get pods -l app=contoso-air-web
kubectl get svc contoso-air-web

# View application logs
kubectl logs -l app=contoso-air-web --tail=50 -f
```

The deployment includes:
- **Deployment**: 2 replicas with resource limits
- **Service**: ClusterIP service on port 80
- **HPA**: Horizontal Pod Autoscaler (2-10 replicas based on CPU)
- **Security**: Non-root user, security contexts, and resource constraints

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/azure-kubernetes-service.yml`) automates:

1. **Build**: Container image creation with Azure Container Registry
2. **Push**: Image pushed to ACR with git SHA tag
3. **Deploy**: Automated deployment to AKS cluster

### Setup GitHub Actions

Configure the following secrets in your GitHub repository:

- `AZURE_CLIENT_ID`: Service Principal client ID
- `AZURE_TENANT_ID`: Azure AD tenant ID  
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID

Update workflow environment variables:
```yaml
env:
  AZURE_CONTAINER_REGISTRY: "your-acr-name"
  CONTAINER_NAME: "contoso-air"
  RESOURCE_GROUP: "your-resource-group"
  CLUSTER_NAME: "your-aks-cluster"
```

## 🧹 Cleanup

Remove all Azure resources when you're done:

```bash
az group delete --name $AZURE_RESOURCE_GROUP_NAME --yes --no-wait
```

## 📊 Project Status

This project is actively maintained and represents the modernization work completed in:
- **Azure DevOps Task**: #1892 - "Modernize Contoso Air Demo Application"

### Completed Work Items
✅ Node.js 22 upgrade and dependency modernization  
✅ Azure Managed Identity integration  
✅ CosmosDB MongoDB API 7.0 migration  
✅ Kubernetes deployment manifests  
✅ GitHub Actions CI/CD pipeline  
✅ Docker containerization with security hardening  
✅ Comprehensive documentation  
✅ Prometheus monitoring integration  
✅ Security best practices implementation  

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see [LICENSE.md](LICENSE.md) for details.

## 🔗 Related Resources

- [Original ContosoAir Repository](https://github.com/microsoft/ContosoAir) (archived)
- [Azure CosmosDB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [Azure Managed Identity Documentation](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 📧 Support

For issues and questions:
- Open an issue in this repository
- Refer to Azure DevOps project for detailed task tracking
- Check existing documentation and guides

---

**Note**: This is a demo application intended for learning and demonstration purposes. For production use, additional security hardening, monitoring, and testing would be required.
