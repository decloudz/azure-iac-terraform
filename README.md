# GCSE Prime EDM Terraform Infrastructure

This repository contains Terraform configuration for deploying and managing the GCSE Prime EDM infrastructure in Azure.

## Architecture

The infrastructure includes the following components:

- **Azure Kubernetes Service (AKS)** - For containerized application workloads
- **Azure Container Registry (ACR)** - For storing and managing container images
- **Azure DNS** - For domain name management
- **Azure Key Vault** - For secrets management
- **Azure PostgreSQL** - For database services
- **Azure Virtual Network** - For network isolation and security
- **Azure Monitor** - For monitoring and diagnostics
- **Cert Manager & External DNS** - For certificate and DNS automation

## Infrastructure Components

| Component | Description |
|-----------|-------------|
| AKS | Managed Kubernetes cluster with workload identity support |
| ACR | Container registry with geo-replication capability |
| DNS | Azure DNS zones for domain management |
| Key Vault | Secure storage for secrets and certificates |
| PostgreSQL | Managed PostgreSQL database with private endpoints |
| Virtual Networks | Hub and spoke network architecture |
| Log Analytics | Centralized logging and monitoring |
| Application Gateway | Ingress controller for AKS |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version 1.3.9 or later)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (version 2.30.0 or later)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with your AKS cluster version)
- [kubelogin](https://github.com/Azure/kubelogin) (needed for AKS authentication)

## Directory Structure

```
gcse-prime-edm-terraform/
├── environments/              # Environment-specific configurations
│   ├── dev-variables.tfvars   # Development environment variables
│   ├── staging-variables.tfvars # Staging environment variables
│   └── prod-variables.tfvars  # Production environment variables
├── modules/                   # Reusable Terraform modules
│   ├── database/              # Database module
│   ├── dns/                   # DNS module
│   ├── kubernetes/            # Kubernetes module
│   ├── monitoring/            # Monitoring module
│   ├── networking/            # Networking module
│   └── security/              # Security module
├── scripts/                   # Helper scripts
├── .gitignore                 # Git ignore file
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable declarations
├── locals.tf                  # Local values
├── backend.tf                 # Backend configuration
├── providers.tf               # Provider configurations
└── README.md                  # This file
```

## Module Structure

The infrastructure is organized into the following modules:

1. **networking** - Manages VNets, subnets, NSGs, and other network resources
2. **kubernetes** - Manages AKS cluster and related resources
3. **database** - Manages PostgreSQL database and related resources
4. **security** - Manages Key Vault, certificates, and security-related resources
5. **monitoring** - Manages Log Analytics workspace and monitoring components
6. **dns** - Manages DNS zones and records

This modular approach provides:
- Improved maintainability and readability
- Better separation of concerns
- Ability to reuse modules across environments
- Easier testing and validation

## Local Development

### Setup

1. Install the required tools (Terraform, Azure CLI, kubectl, kubelogin)
2. Authenticate to Azure CLI:
   ```bash
   az login
   ```
3. Select the appropriate subscription:
   ```bash
   az account set --subscription "Your Subscription Name"
   ```

### Initialize Terraform

```bash
terraform init \
  -backend-config="resource_group_name=<state_resource_group>" \
  -backend-config="storage_account_name=<state_storage_account>" \
  -backend-config="container_name=<state_container>" \
  -backend-config="key=<environment>.terraform.tfstate"
```

### Plan Changes

```bash
terraform plan -var-file="environments/<environment>-variables.tfvars" -out=tfplan
```

### Apply Changes

```bash
terraform apply tfplan
```

## CI/CD Pipeline

This repository includes an Azure DevOps pipeline configuration (`azure-pipelines.yml`) that automates the deployment process:

1. **Validate Stage**: Initializes Terraform, validates the configuration, and creates a deployment plan.
2. **Deploy Stage**: Applies the validated Terraform plan to the specified environment.

The pipeline uses modern OpenID Connect (OIDC) authentication to securely authenticate with Azure without storing credentials.

### Pipeline Setup

The pipeline is configured to:

- Run automatically on commits to the main branch
- Allow selection of the target environment (dev, staging, prod)
- Use environment-specific variable groups (`GCSE-PrimeEDM-Dev`, `GCSE-PrimeEDM-Staging`, `GCSE-PrimeEDM-Prod`)
- Use a common variable group (`GCSE-PrimeEDM-Common`) for shared authentication variables
- Leverage workload identity federation for secure Azure authentication via the `AzureServiceConnection` service connection

For detailed pipeline configuration, see `azure-pipelines.yml`.

## Authentication Options

We use the modern Workload Identity Federation (OIDC) approach for pipeline authentication. This method:

- Eliminates the need to store service principal secrets
- Follows Zero Trust security principles
- Simplifies credential management

For a comprehensive guide to all available authentication options, see [AUTHENTICATION_OPTIONS.md](AUTHENTICATION_OPTIONS.md).
For detailed setup instructions for the OIDC authentication, see [OIDC_SETUP.md](OIDC_SETUP.md).

## Troubleshooting

For common issues and their solutions, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Test your changes locally
4. Submit a pull request to `main`

## License

Proprietary - GCSE Prime EDM project

## Support

For support, please contact [your contact information]

## Environment Setup

### Preparing Environment Variables

1. Copy the example variables file to create your environment-specific file:
   ```bash
   cp environments/dev-variables.tfvars.example environments/dev-variables.tfvars
   ```

2. Edit `environments/dev-variables.tfvars` and replace the placeholder values with your actual values.
   **IMPORTANT: Never commit this file to version control as it contains sensitive information.**

### State Management

This project uses Azure Storage for remote state management. The state files are not committed to Git.
To set up the Azure Storage for state management, run:

```bash
./scripts/create-terraform-storage.sh
```