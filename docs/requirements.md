# Requirements — Multimodal Enterprise RAG Demo

## Overview ✅
This repository contains a demo multimodal Retrieval-Augmented Generation (RAG) application that uses llamaindex and **Azure AI Search** to index enterprise documents and serve a conversational chat frontend. The frontend is implemented in **Python + Chainlit** and is deployed to **Azure App Service (Free tier)**. A separate backend, implemented as **Python Azure Functions**, handles parsing, extracting, verbalizing images, embedding, and indexing documents uploaded to Azure Blob Storage.

> Core idea: Uploads (PDF, DOC, PPT) are parsed into markdown and images; images are verbalized; content is embedded and stored in Azure AI Search; the Chainlit frontend performs RAG queries against the search index to answer user queries.

---

## Goals 🎯
- Provide a reproducible demo showing a multimodal enterprise RAG pipeline using llamaindex + Azure AI Search.
- Demonstrate Azure-hosted deployment: Chainlit frontend on App Service (Free), processing pipeline implemented with Azure Functions and Blob Storage triggers.
- Support text + images in source documents, with image verbalization and multimodal retrieval.

---

## Scope
**In scope:**
- Document ingestion of `.pdf`, `.doc`, `.docx`, `.ppt`, `.pptx` containing text and images.
- Extraction to markdown and image assets, image verbalization (captions/descriptions), embedding generation, indexing in Azure AI Search.
- Chainlit chat UI supporting user queries against the Azure AI Search-backed index and returning RAG-style responses.

**Out of scope (for the demo):**
- Full enterprise single sign-on integrations beyond a basic auth flow (optional future enhancement).
- Commercial-grade SLAs or production-scale autoscaling (demo targets Free tier usage).

---

## Actors / Users
- End user: uses the Chainlit chat UI to query enterprise content.
- Content uploader: uploads documents to the designated Blob Storage container.
- System admin: monitors indexing, health, and re-indexing operations.

---

## Functional Requirements (FR) 🔧
1. FR-001 — Chat Frontend
   - Provide a Chainlit-based chat UI that accepts user queries and displays RAG responses (text, and optionally images or image descriptions).
   - Deployable to Azure App Service (Free tier).

2. FR-002 — Document Upload Trigger
   - When a document is uploaded to the configured Azure Blob Storage upload container, an Azure Function (Function A) triggers to process the file using a **BlobTrigger** binding (direct blob trigger).
   - **Note:** Because a BlobTrigger is used and the Storage account is configured with Private Endpoints and public access disabled, the Azure Function host must have network access to the Storage account's private endpoint (for example via VNet Integration or appropriate network configuration).

3. FR-003 — Document Parsing and Extraction
   - Function A must extract text and images from PDF/DOC/PPT and produce a markdown artifact plus extracted image files.
   - Use `llamaindex` (or compatible pipeline) for text extraction & chunking where appropriate.

4. FR-004 — Image Verbalization
   - Each extracted image triggers a separate Azure Function (Function B) that produces a textual description (caption / verbalization).
   - Descriptions are stored alongside the markdown (or returned to a queue/topic for the next step).

5. FR-005 — Embedding & Indexing
   - After markdown and image descriptions are ready, an Azure Function (Function C) calls the chosen embedding model to generate vectors, and pushes records (vectors + metadata) into **Azure AI Search**.
   - Index entries should include: document id, chunk id, text snippet (markdown), image caption(s), filename, source URL, timestamps, and any metadata (author, page number).

6. FR-006 — Multimodal Retrieval
   - Chainlit frontend queries the Azure AI Search index to retrieve relevant chunks (text or images) and uses llamaindex to assemble RAG answers.

7. FR-007 — Admin & Observability
   - Provide endpoints or Function-to-Function triggers for reindexing documents, health checks, and status.
   - Record logs and metrics for ingestion times, embedding calls, and query latencies.

---

## Non-Functional Requirements (NFR) ⚙️
- NFR-1 — Security
  - Secrets (API keys, connection strings) must be stored securely (Azure Key Vault or Function/App settings) and not committed to repo.
  - All services must use HTTPS endpoints.
  - Consider Azure AD or token-based protection for admin endpoints.
  - **Network isolation:** Azure Blob Storage, Azure AI Search, and **Azure Functions** must be configured with Private Endpoints (Private Link) and public network access disabled. Access to these private resources should be restricted to the App Service and other authorized services (for example via VNet Integration, service private endpoint configuration, or approved IP rules). Note: the App Service itself remains internet-accessible to end users; backend storage/search endpoints and functions must not be publicly exposed.
  - **BlobTrigger requirement:** Because the ingestion pipeline uses BlobTrigger bindings for uploads, Azure Functions must have VNet Integration and outbound access to the Storage account's private endpoint (or otherwise be configured so the Functions host can access blobs).

- NFR-2 — Privacy & Compliance
  - Sensitive PII detection and handling must be documented; retention policy for source docs should be configurable.

- NFR-3 — Performance & Latency
  - Interactive query latency goal: < 5s for cached / short-path responses; < 15s acceptable for cold/full RAG queries (demo constraints).
  - Indexing throughput should be sufficient to process small batches in minutes.

- NFR-4 — Scalability
  - System must be implementable on Azure Free tiers for demo purposes but designed so components can be scaled later (Function plan, higher App Service tier).

- NFR-5 — Reliability
  - Implement retry/backoff patterns for transient failures (Azure Blob, embedding API, Search API).

- NFR-6 — Observability
  - Integrate Application Insights / Azure Monitor for logs, metrics, and tracing across Functions and the App Service.

- NFR-7 — Cost Awareness
  - Minimize embedding API calls (batch embeddings when possible), and respect free-tier quotas.

---

## Technical Requirements & Dependencies 📦
- Python 3.9+ runtime
- Chainlit (frontend)
- llamaindex (document parsing + RAG orchestration)
- Azure Functions (Python) for ingestion, image verbalization, embedding/indexing
- Azure Blob Storage for uploads (designate an upload container)
- Azure AI Search for storing vectors and retrieval
- Embedding model provider (Azure OpenAI or other embedding API) — must be accessible via API key/endpoint
- Azure Key Vault (recommended) for secret storage
- GitHub Actions or other CI for deployments (optional)

---

## Data Flow / Integration Details 🔁
1. User uploads document to Azure Blob Storage (upload container).
2. Blob Storage triggers Azure Function A (parser) via a **BlobTrigger** binding (direct blob trigger). **Note:** BlobTrigger requires the Function host to be able to reach the Storage account's private endpoint (VNet Integration or same VNet).
   - Extract text → produce markdown
   - Extract images → store in a processed-images container and/or emit messages to a queue
3. Each image triggers Azure Function B (image verbalizer):
   - Generate captions / descriptions
   - Store captions or push to message queue
4. Azure Function C (indexer) receives markdown + image captions:
   - Chunk the markdown (llamaindex)
   - Call embedding API to compute vectors
   - Push documents with vectors into Azure AI Search index
5. Chainlit frontend queries Azure AI Search and runs RAG to assemble final answers for users.

---

## Index Schema (Suggested)
- id (string) — unique
- document_id (string)
- chunk_id (string)
- content (text) — the markdown chunk
- image_captions (collection of text)
- url (string) — blob URL
- metadata (object) — author, page, filename
- vector (vector) — embedding
- created_at / updated_at (datetime)

---

## Deployment Requirements & Environment Configuration 🚀
- Azure App Service (Free tier) for Chainlit frontend
- Azure Functions (Consumption or Premium depending on need)
- Azure Storage Account with at least:
  - upload container
  - processed container for images
- Azure AI Search instance and admin key

Environment/App settings (suggested names):
- AZURE_STORAGE_CONNECTION_STRING
- AZURE_SEARCH_ENDPOINT
- AZURE_SEARCH_API_KEY
- EMBEDDING_API_ENDPOINT
- EMBEDDING_API_KEY
- KEYVAULT_URI (optional)

CI/CD: simple GitHub Actions workflows to deploy App Service and Functions via Azure/webapps and Azure/functions actions.

---

## Testing & Acceptance Criteria ✅
- Unit tests for Azure Functions and ingestion/parsing logic.
- Integration test: upload representative PDF/DOC/PPT → verify markdown and images are extracted, images verbalized, vectors stored in Azure AI Search.
- End-to-end test: query via Chainlit UI and verify relevant passages appear in responses.
- Acceptance: end-to-end latency within the NFR limits and accurate retrieval for sample queries.

---

## Error Handling & Retries
- Functions should push failed jobs to a dead-letter queue after configurable retries.
- Indexer should validate embeddings before pushing to Azure AI Search; skip and log items with malformed results.

---

## Future Enhancements (optional) ✨
- Add Azure AD single-sign-on and per-user access control for results
- Add per-tenant or per-collection indexing (multi-tenant support)
- Add a UI to inspect and re-run indexing for individual documents
- Add document versioning and deletion flows

---

## Notes & Assumptions
- This is a demo app intended to demonstrate capabilities and patterns; productionizing the system requires further work (scaling, hardened security policies, cost management).
- "Image verbalization" means generating useful captions/descriptions for images (e.g., via an image captioning model).

---

If you'd like, I can add a sample environment config (.env template), CI workflow, or an index mapping JSON for Azure AI Search next. 🔧