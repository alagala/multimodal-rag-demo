# Run Instructions — Multimodal RAG Demo

## Prerequisites
- Git installed and a GitHub account
- Azure CLI installed and logged in (`az login`)
- Terraform v1.2+ installed
- (Optional) Azure Functions Core Tools and `func` for local function development
- (Optional) `gh` CLI for GitHub repo creation and management

---

## 1) Create GitHub repository and push code
1. Create repository on GitHub (UI) or use `gh` CLI:
   - gh: `gh repo create <owner>/chainlit-demo --public --source=. --remote=origin --push`
2. Or, using git commands (if repo already created remotely):
   - `git init`
   - `git add .`
   - `git commit -m "Initial commit: multimodal RAG demo"`
   - `git remote add origin https://github.com/<your-org-or-user>/chainlit-demo.git`
   - `git push -u origin main`

> Tip: Use a protected `main` branch and add branch protection rules if collaborating.

---

## 2) Prepare Azure credentials for Terraform
You can run Terraform using your Azure user credentials (interactive `az login`) or a Service Principal. For automation, create a Service Principal and export environment variables:

```bash
# create service principal (example scope can be the resource group or subscription)
az ad sp create-for-rbac --name "sp-chainlit-terraform" --role Contributor

# set environment variables for Terraform (replace values returned by command)
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_TENANT_ID="<tenant>"
export ARM_SUBSCRIPTION_ID="<subscriptionId>"
```

> For CI, store these values in GitHub Actions secrets.

---

## 3) Configure Terraform backend (optional but recommended)
- Configure a remote state backend (e.g., `azurerm` backend) to share state across team members and environments. Add a `backend` block in `providers.tf` or a `backend.tf` file and initialize accordingly.

---

## 4) Initialize Terraform & deploy infra (dev)
1. Change to the env folder:
   - `cd infra/terraform/envs/dev`
2. Initialize Terraform:
   - `terraform init`
3. (Optional) Review variables and modify `terraform.tfvars` or export env vars:
   - `terraform plan -out=tfplan`
4. Apply the plan:
   - `terraform apply "tfplan"` or `terraform apply --auto-approve`

Notes:
- The Terraform defaults set the **resource group** to `rag-demo-rg` and **location** to `westeurope`.
- Review and confirm service SKUs and names before applying.

---

## 5) Post-infra steps
- Retrieve endpoints, storage account names, and connection settings (outputs or Azure portal).
- Provision secrets in Key Vault (embedding API key, Azure Cognitive Search admin key if needed):
  - `az keyvault secret set --vault-name <kv-name> --name "EMBEDDING_API_KEY" --value "<key>"`
- Ensure Managed Identities/role assignments are in place (Functions and App Service need access to Key Vault and Storage as appropriate).

---

## 6) Deploy Azure Functions (backend)
Option A: Use zip deployment via Azure CLI
1. Package each function (or the whole functions app) into a zip file
   - `zip -r functions.zip .` in the function project directory
2. Deploy:
   - `az functionapp deployment source config-zip --resource-group rag-demo-rg --name <FUNCTION_APP_NAME> --src functions.zip`

Option B: Use `func` (local dev)
1. `func azure functionapp publish <FUNCTION_APP_NAME> --python`

Notes:
- Ensure the Function App runtime storage and app settings are configured (connection strings, environment variables pointing to Key Vault or secrets).
- Validate that the Function App has VNet Integration configured to reach Blob Storage private endpoint (required for BlobTrigger).

---

## 7) Deploy Chainlit frontend (App Service)
Option A: Zip deploy via Azure CLI
1. Package the app (if using standard Python app layout):
   - `zip -r app.zip .`
2. Deploy:
   - `az webapp deployment source config-zip --resource-group rag-demo-rg --name <APP_SERVICE_NAME> --src app.zip`

Option B: Use GitHub Actions (recommended for CI/CD)
- Add GitHub Actions workflow to build, test, and deploy to App Service using `azure/webapps-deploy` action and ensure secrets are available as GitHub secrets.

Notes:
- App Service should use a Managed Identity to access Key Vault and optionally to request SAS tokens for Storage uploads.
- If Storage is private, the recommended upload flow is: frontend requests a SAS from a backend API (authenticated) or streams via a proxy so blobs land in the upload container.

---

## 8) Validate the pipeline
1. Open the frontend URL from App Service.
2. Upload a sample PDF/DOC/PPT via the UI.
3. Monitor Function logs (Application Insights or `az functionapp log tail`) and check that:
   - Parser (BlobTrigger) processed the file and created markdown/images
   - Verbalizer processed images and saved captions
   - Indexer pushed vectors to Azure AI Search
4. Query the frontend chat and confirm retrieval and RAG responses.

---

## 9) Cleanup
- To avoid charges, destroy the Terraform-managed resources when finished:
  - `terraform destroy --auto-approve`
- If using remote state, cleanup any storage/resources used for Terraform state.

---

## Troubleshooting tips
- If BlobTriggers do not fire, confirm Function App VNet Integration and that the Functions host can reach the Storage private endpoint.
- Check Key Vault access policies and Managed Identity role assignments.
- Use Application Insights and streaming logs for debugging.

---

If you want, I can create a GitHub Actions workflow to execute the Terraform plan/apply and build/deploy the App Service and Functions automatically.