# ITV "Slide-Bot" Data Agent - Architecture & Setup Summary
*Generated on: 7 Mar 2026*

## The Problem
We needed a way to allow non-technical colleagues at ITV to run complex BigQuery data analyses using the `consomme` methodology, but they struggled with:
1. Installing the Gemini CLI and configuring extensions.
2. Generating Google Cloud Service Account keys (which is a security anti-pattern to distribute anyway).
3. Exporting the final insights into a format they could easily consume and share (Google Slides).

## The Solution: GCP Vertex AI Agent Builder
Instead of trying to force a local CLI setup, we shifted to a centralized, serverless architecture using **Google Cloud Vertex AI Agent Builder**. This allows users to simply ping a bot in Google Chat, ask a natural language question, and receive a branded Google Slide Deck in return.

### Key Architectural Components

1. **The Brain (Vertex AI Agent)**
   * **Platform:** Google Cloud Conversational Agents (`agentbuilder.cloud.google.com`).
   * **Playbook Instructions:** The `consomme` skill was rewritten into a strict, unordered Markdown list hierarchy to conform to the Playbook syntax requirements. It instructs the agent to systematically Discover, Understand, Analyze, Validate, and Present data.
   * **Tools (Input):** The pre-built **BigQuery Toolset** was enabled in the Agent, giving it native text-to-SQL capabilities against the `mit-consomme-test` dataset.

2. **The Hands (Cloud Function Slide Generator)**
   * **Platform:** Google Cloud Functions (Gen 2, Python 3.11).
   * **Functionality:** An OpenAPI-compliant webhook that receives a `title` and `bullets` array from the Vertex Agent. 
   * **Execution:** It uses the Drive API to copy the ITV "Golden Template" (`1Dq3CFxCtIVBfGxKAOGRzczLuL1eJQXGCOl_i3D6b_sQ`) into a designated Shared Drive folder (`1YQmH-q3Y1KhPJAa0kg_YHljQ4NahTJsY`), then uses the Slides API to inject the text.
   * **Auth:** Runs securely under a dedicated Service Account (`904029233381-compute@developer.gserviceaccount.com`), which was granted Editor access to the target Google Drive folder.

3. **The Interface (Google Chat)**
   * The Vertex AI Agent is natively integrated with Google Chat. Users authenticate using their standard ITV Google Workspace accounts, completely abstracted from the underlying GCP IAM permissions.

## Key Learnings & Gotchas Discovered

* **Gemini CLI Extension Architecture:** The Gemini CLI `bq-data-analytics` extension is a local wrapper for the exact same underlying ADK (Agent Development Kit) tools used in Vertex AI. This makes prompt logic (like the `consomme` skill) 100% portable between local CLI and Cloud deployments.
* **Extension Installation:** Manually cloning the `bq-data-analytics` repo fails because the `toolbox` binary is missing. You *must* use `gemini extensions install <URL>` so the CLI downloads the platform-specific binary.
* **GCP Service Account Quotas:** Service Accounts have a default Google Drive storage quota of 0 bytes. If a Cloud Function tries to copy a file and retain ownership without a parent folder, it will throw a `403 storageQuotaExceeded` error. The fix is to pass a `parents` array pointing to a folder shared with the Service Account.
* **Slides API Placeholder Nuance:** Deleting text (`deleteText`) from an empty placeholder in a Google Slide throws a `400 Bad Request` error. If placeholders in a template are empty by default, just use `insertText`.
* **Playbook Syntax:** Vertex AI Playbooks require strict unordered markdown lists and specific `${TOOL: tool_name}` syntax to correctly bind instructions to underlying OpenAPI/Prebuilt tools.
* **Console Confusion:** Google has split the AI Agent console. To build an autonomous ReAct agent using Playbooks, you must use `conversational-agents.cloud.google.com`, *not* the legacy `dialogflow.cloud.google.com` (which defaults to rigid, flowchart-based CX agents).

## Project State & Next Steps

All code (Cloud Function `main.py`, `deploy.sh`, `openapi.yaml`, and the modified `INSTRUCTIONS.md`) has been saved to:
`/Users/modha/Repos/consomme/cloud-functions/slide-bot/` and `/Users/modha/Repos/consomme/agent-builder/`

Work is currently tracked in the `consomme` repository's `.bon` tracker under the Outcome: **`consomme-gewagi`** ("ITV users can request data analysis in Google Chat and receive branded Slide decks").

**Remaining Action (consomme-jejihe):**
Enable the Google Chat integration within the Vertex AI Agent Builder console and perform an end-to-end test in the ITV workspace.