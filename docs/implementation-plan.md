# Implementation Plan — Multimodal Enterprise RAG Demo

## Overview
This document describes the implementation plan for the multimodal RAG demo described in `docs/requirements.md`. It focuses on development tasks, project structure, environment setup (virtual environment for Python packages), and infrastructure provisioning using Terraform for Azure resources.

---

## High-level Milestones ✅
1. Design & planning (architecture, security, Terraform module layout)
2. Repo skeleton & local dev environment (venv, linting, tests)
3. Implement backend (Azure Functions: parser, verbalizer, indexer)
4. Implement frontend (Chainlit chat + RAG integration)
5. Infrastructure provisioning (Terraform to create Storage, Azure Search, Functions, App Service, Key Vault, VNet & Private Endpoints)
6. CI/CD (GitHub Actions for tests, Terraform, deployments)
7. Testing, observability, and security hardening
8. Final validation, documentation, and handover

---

## Directory Structure (recommended)
- `src/`
  - `frontend/` — Chainlit app and UI code
  - `functions/` — Azure Functions source code (subfolders for parser, verbalizer, indexer)
  - `shared/` — shared helpers, models, and clients (e.g., Azure Search client, embedding wrappers)
- `infra/`
  - `terraform/` — terraform root + modules
    - `modules/storage/` — Storage + private endpoint
    - `modules/search/` — Azure AI Search + private endpoint
    - `modules/functions/` — Function Apps + VNet Integration
    - `modules/app_service/` — App Service for Chainlit
    - `modules/keyvault/` — Key Vault & access policies
    - `modules/vnet/` — VNet and subnets for private endpoints
- `docs/` — `requirements.md`, `implementation-plan.md`, runbooks, architecture diagrams
- `tests/` — unit, integration and e2e tests
- `.github/workflows/` — CI/CD workflows
- `scripts/` — helper scripts (local deploy, test data generation)

---

## Virtual Environment & Python Dependencies
- Use a per-project Python virtual environment (venv or virtualenv) tracked in `.gitignore`.
- Provide `requirements.txt` (or `constraints.txt`) for freezing dependencies.
- Recommend Python 3.9+ and a short `env-setup.md` describing how to create and activate the venv, install `pip-tools` if pinning is desired, and how to run tests locally.

---

## Terraform & Infrastructure Considerations 🔧
- Use Terraform for infra-as-code. Organize Terraform as reusable modules (see directory structure above).
- Required Azure resources:
  - Storage Account with upload container(s) and private endpoint
  - Azure AI Search service with private endpoint and appropriate index definition
  - Azure Function Apps with VNet integration and public access disabled
  - App Service for Chainlit (public-facing)
  - Key Vault to store secrets and connection strings
  - VNet + subnets to host private endpoints
  - Application Insights for Functions and App Service
- Enforce network isolation:
  - Private Endpoints for Storage, Azure Search, and Function Apps
  - Disable public network access on these services where possible
  - App Service remains public but should use Managed Identity to access Key Vault and other private endpoints via VNet Integration or service endpoints
  - **BlobTrigger note:** This demo uses **BlobTrigger** bindings for ingestion. Ensure the Function App has VNet Integration and can reach the Storage account's private endpoint so blob triggers function correctly; validate the trigger behavior in a private network environment.
- Plan for environment separation (dev/test/prod) and Terraform workspaces or separate state backends

---

## Implementation Phases & Tasks
Phase 1 — Design & Repo Setup
- Finalize architecture diagrams and Terraform module boundaries
- Create repo skeleton and add initial README, license, and contributing guidelines
- Add `.gitignore`, `pre-commit` hooks, and basic linting (flake8/ruff)

Phase 2 — Functions & Backend Implementation
- Function A (parser): **BlobTrigger**; extract text (PDF/DOC/PPT -> markdown) and images; store artifacts in processed container; emit message or event when done. Ensure the Function App has VNet Integration and can reach the Storage account's private endpoint so blob triggers operate correctly.
- Function B (image verbalizer): Trigger by blob or queue; call image captioning model; attach captions to metadata or push to queue
- Function C (indexer): Aggregate markdown and captions; chunk via `llamaindex`; call embeddings API; push vector documents to Azure AI Search
- Shared components: Azure Search client, embedding client, error handling, retry logic

Phase 3 — Frontend (Chainlit)
- Implement chat UI and RAG orchestrator using `llamaindex` for prompt orchestration and Azure Search for retrieval
- Support display of captions and inline images where applicable
- Add basic auth or admin routes if required by the demo

Phase 4 — Infrastructure & Security
- Implement Terraform modules and test in a dev subscription
- Configure Private Endpoints for Storage, Search, and Functions; ensure public network access is disabled
- Set up Key Vault and store secrets; configure Managed Identities for Functions and App Service

Phase 5 — CI/CD & Deployments
- Add GitHub Actions to run linting and tests
- Add job to run `terraform fmt`, `terraform init`, `terraform plan` and `terraform apply` via service principal (manual approval for apply in shared subscriptions)
- Add job to build and deploy Functions and App Service; ensure secrets are provisioned via Key Vault

Phase 6 — Testing & Observability
- Implement unit tests and integration tests (local emulator / Azure resources in a dev environment)
- Create e2e test that uploads a sample document and verifies the entire pipeline
- Configure Application Insights dashboards and alerts

Phase 7 — Final Validation & Documentation
- Run acceptance tests, cost checks for Free tier constraints, and finalize runbooks
- Document manual reindexing and maintenance procedures

---

## Testing Strategy
- Unit tests for parsing, chunking, and embedding wrappers
- Integration tests for Functions (mock or emulator for Blob Storage and Search where possible)
- End-to-end test: upload sample PDF -> extracted markdown/images -> captions generated -> vectors in Azure Search -> Chainlit query returns expected results
- Performance/latency tests for query and ingestion paths

---

## Security & Compliance
- Store all secrets in Azure Key Vault; grant least-privileged access via Managed Identity
- Disable public network access for Storage, Search, and Functions; use Private Endpoints and VNet Integration
- Document data retention and PII handling
- Add CI checks for accidental secret commits

---

## Observability & Operations
- Application Insights for all services (Functions, App Service)
- Centralized logs and metrics; create dashboards for ingestion throughput, queue depth, embedding API error rates, and query latencies
- Alerts for ingestion failures, embedding failures, and search availability issues

---

## Acceptance Criteria
- Demo App deployed: Chainlit app reachable and functional
- Uploading a sample document flows through extraction, verbalization, indexing, and the document is retrievable by Chainlit
- Private Endpoints configured for Storage, Search, and Functions; App Service can query Search via private connectivity or approved path
- Tests and documentation in place

---

## Timeline & Estimates (rough)
- Design & repo setup: 1–2 days
- Backend functions (3 functions): 4–6 days
- Frontend Chainlit integration: 2–3 days
- Terraform infra & network: 3–4 days
- CI/CD and tests: 2–3 days
- Observability, security hardening & docs: 2 days
Total (dev estimate): ~14–20 work days

---

## Next Steps
- Confirm the plan and priorities
- Start with the infra design (Terraform module boundaries and VNet/private endpoint plan)
- Implement the repo skeleton and virtual environment instructions

---

If you'd like, I can now:
- produce a `README` + `env-setup.md` to bootstrap local dev
- scaffold the Terraform module stubs under `infra/terraform/modules/`
- add a sample `.github/workflows/ci.yml` stub for the pipeline

Tell me which to do next.