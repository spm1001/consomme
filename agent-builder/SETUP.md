# Consomme Slide-Bot — Setup Runbook

Complete setup guide for the ITV data analysis bot in Google Chat.
Covers GCP project config, Agent Builder setup, tool registration, playbook hierarchy, and Chat integration.

## Prerequisites

- GCP project: `mit-consomme-test` (project number: 904029233381)
- Region: `europe-west2`
- `gcloud` CLI authenticated with Owner or Editor role on the project
- Cloud Function `generate-slide-deck` deployed (see `cloud-functions/slide-bot/deploy.sh`)
- ITV Golden Template: `1Dq3CFxCtIVBfGxKAOGRzczLuL1eJQXGCOl_i3D6b_sQ`
- Shared Drive output folder: `1YQmH-q3Y1KhPJAa0kg_YHljQ4NahTJsY`

## Step 1. Enable Required APIs

```bash
gcloud services enable \
  dialogflow.googleapis.com \
  discoveryengine.googleapis.com \
  aiplatform.googleapis.com \
  connectors.googleapis.com \
  integrations.googleapis.com \
  secretmanager.googleapis.com \
  cloudfunctions.googleapis.com \
  run.googleapis.com \
  drive.googleapis.com \
  slides.googleapis.com \
  bigquery.googleapis.com \
  --project=mit-consomme-test
```

**Why each matters:**

| API | Purpose |
|-----|---------|
| `dialogflow.googleapis.com` | Core Conversational Agents runtime |
| `discoveryengine.googleapis.com` | Vertex AI Agent Builder (agents, playbooks) |
| `aiplatform.googleapis.com` | Vertex AI platform (model serving for the agent) |
| `connectors.googleapis.com` | Connector tools (BigQuery connector) |
| `integrations.googleapis.com` | Dependency of connectors |
| `secretmanager.googleapis.com` | Required by Integration Connectors |
| `cloudfunctions.googleapis.com` | Hosts Generate_Slide_Deck function |
| `run.googleapis.com` | Cloud Functions Gen2 runs on Cloud Run |
| `drive.googleapis.com` | Slide template copying |
| `slides.googleapis.com` | Slide content injection |
| `bigquery.googleapis.com` | Data queries |

**Gotcha:** If `connectors.googleapis.com` is not enabled, the "Create" button in Tools will silently fail (no error, just doesn't respond).

## Step 2. Deploy the Cloud Function

```bash
cd cloud-functions/slide-bot
bash deploy.sh
```

Verify it works:

```bash
curl -X POST \
  https://europe-west2-mit-consomme-test.cloudfunctions.net/generate-slide-deck \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Slide", "bullets": ["Point 1", "Point 2"]}'
```

Should return `{"message": "Slide deck generated successfully.", "url": "...", "presentationId": "..."}`.

**Gotcha:** The Cloud Function's service account (`904029233381-compute@developer.gserviceaccount.com`) needs Editor access on the Shared Drive output folder — otherwise `403 storageQuotaExceeded`. The `parents` array in the copy request routes ownership to the folder, avoiding SA quota issues.

## Step 3. Create the Agent

1. Go to [conversational-agents.cloud.google.com](https://conversational-agents.cloud.google.com) (NOT dialogflow.cloud.google.com — that defaults to CX flows, not playbooks)
2. Select project `mit-consomme-test`
3. Click **Create agent** → **Build your own**
4. Name: `Consomme Slide-Bot`
5. Region: `europe-west2`
6. Conversation start: **Playbook**
7. Click **Create**

This creates the Default Generative Playbook automatically.

## Step 4. Register Tools

### 4a. BigQuery Connector Tool

**Pre-requisite:** The connector's service account needs BigQuery access. Grant BEFORE creating:

```bash
gcloud projects add-iam-policy-binding mit-consomme-test \
  --member="serviceAccount:904029233381-compute@developer.gserviceaccount.com" \
  --role="roles/bigquery.user" --quiet

gcloud projects add-iam-policy-binding mit-consomme-test \
  --member="serviceAccount:904029233381-compute@developer.gserviceaccount.com" \
  --role="roles/bigquery.dataViewer" --quiet
```

Then create the connector:

1. In the agent, go to **Tools** → **Create** → **Connector** → **BigQuery**
2. This redirects to Integration Connectors. Create a new connection:
   - Connection name: `bq-consomme`
   - Location: `europe-west2`
   - Service account: `904029233381-compute@developer.gserviceaccount.com`
   - Config: `project_id` = `mit-consomme-test`, `dataset_id` = `survey_data`
3. Wait for status ACTIVE (5-10 minutes on first creation — check in [Connectors console](https://console.cloud.google.com/connectors/connections?project=mit-consomme-test))
4. Back in Agent Builder, select the `bq-consomme` connection
5. Enable `ExecuteCustomQuery` action (gives the agent SQL execution)
6. Optionally enable entity operations (List, Get) for table browsing
7. Name the tool: `BigQuery`
8. Save

**Note the exact tool name** — playbook instructions reference it as `${TOOL: BigQuery}`. If you name it differently, update the instructions.

**Gotcha:** If the SA lacks BigQuery roles, creation takes ~10 minutes then silently fails: "Unable to create a connector instance." No useful error detail. Grant roles first.

### 4b. Generate_Slide_Deck OpenAPI Tool

1. **Tools** → **Create** → **OpenAPI**
2. Paste the contents of `cloud-functions/slide-bot/openapi.yaml`
3. Or use **Use Gemini** and provide:
   - URL: `https://europe-west2-mit-consomme-test.cloudfunctions.net/generate-slide-deck`
   - Method: POST
   - Sample input: `{"title": "Test", "bullets": ["Point 1"]}`
   - Sample output: `{"message": "Slide deck generated successfully.", "url": "https://docs.google.com/presentation/d/abc/edit", "presentationId": "abc"}`
4. **Authentication:** Dialogflow Service Agent
5. Name the tool: `Generate_Slide_Deck`
6. Save
7. Use the **Test** button to verify it works

### 4c. Grant Invoker Role to Dialogflow Service Agent

The Dialogflow Service Agent needs permission to call the Cloud Function:

```bash
PROJECT_NUMBER=904029233381

# Grant Cloud Functions invoker
gcloud functions add-invoker-policy-binding generate-slide-deck \
  --region=europe-west2 \
  --project=mit-consomme-test \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com"

# Grant Cloud Run invoker (Gen2 functions run on Cloud Run)
gcloud run services add-iam-policy-binding generate-slide-deck \
  --region=europe-west2 \
  --project=mit-consomme-test \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

**Gotcha:** If the function and agent are in the same project, the Dialogflow Service Agent auth *should* work without explicit grants. But if it returns 403, these are the grants you need.

## Step 5. Create Sub-Playbooks

Create three Task playbooks in Agent Builder. For each, click the playbooks icon → **Create** → **Task playbook**.

### 5a. Data Profiling

- **Name:** `Data Profiling`
- **Goal:** `Detect the data shape (survey, warehouse, or time series) and profile key columns before any analytical query is written.`
- **Instructions:** Paste from `playbooks/01-data-profiling.md` (everything below the `---` line)

### 5b. SQL Patterns

- **Name:** `SQL Patterns`
- **Goal:** `Ensure all SQL follows BigQuery dialect rules and common analytical patterns.`
- **Instructions:** Paste from `playbooks/02-sql-patterns.md` (everything below the `---` line)

### 5c. Validation

- **Name:** `Validation`
- **Goal:** `Cross-check every analysis before presenting results. Catch errors before they become slide decks.`
- **Instructions:** Paste from `playbooks/03-validation.md` (everything below the `---` line)

## Step 6. Configure the Default Generative Playbook

1. Click the Default Generative Playbook (starred)
2. **Goal:** `You are a BigQuery Data Analyst expert. Your goal is to systematically explore datasets, run complex SQL queries to answer user questions, and present your analytical findings as a formatted ITV-branded Google Slide Deck.`
3. **Instructions:** Paste from `playbooks/00-slide-bot.md` (everything below the `---` line)
4. **Save**

Verify that `${PLAYBOOK: Data Profiling}`, `${PLAYBOOK: SQL Patterns}`, `${PLAYBOOK: Validation}`, `${TOOL: BigQuery}`, and `${TOOL: Generate_Slide_Deck}` are highlighted/linked in the instructions. If any show as plain text, the name doesn't match — check the exact names from Steps 4 and 5.

## Step 7. Add Examples

Add at least 4 examples to the Default Generative Playbook via the **Examples** tab. Use the structured format — each step is an action added via the **+** button.

The example files are in `examples/`:

| File | Display Name | What It Teaches |
|------|-------------|-----------------|
| `01-survey-crosstab.md` | Regional mental health comparison | Full happy path with Tool use JSON |
| `02-simple-question.md` | Overall wellbeing summary | Clarification flow for vague questions |
| `03-tool-error.md` | Handling query errors gracefully | No-data-found without hallucinating |
| `04-drilldown.md` | Drill down into age groups | Follow-up question re-using context |

For each example:
1. **Display name** and **Description** from the file header
2. Add actions in order via **+** button, selecting the correct action type
3. For **Tool use** actions: fill in Tool, Action (operationId), Tool input (JSON), Tool output (JSON)
4. For **Playbook invocation** actions: fill in Playbook name, Input summary, Output summary
5. Set **Summary** at the bottom (the text after "Summary:" in each file)
6. Set **Conversation state** to `OK`
7. Set **Selection strategy** to `Always select` for all 4 examples

**Tip from Google's docs:** "Spend more time writing thorough examples than writing perfectly precise instructions." The examples drive behavior more than the instruction text.

**Tip:** You can also create examples by chatting with the agent in the simulator, then clicking **Save as example**. This is faster for iterating.

## Step 8. Enable Google Chat Integration

1. In Agent Builder, go to the agent's **Integrations** section
2. Enable **Google Chat**
3. Configure the Chat app settings (name, avatar, description)
4. Assign the app to your Google Workspace domain or specific users for testing

## Step 9. Grant IAM Permissions

The agent's service account needs BigQuery access:

```bash
PROJECT_NUMBER=904029233381

# BigQuery read access for the agent
gcloud projects add-iam-policy-binding mit-consomme-test \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com" \
  --role="roles/bigquery.user"

# BigQuery metadata viewer
gcloud projects add-iam-policy-binding mit-consomme-test \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com" \
  --role="roles/bigquery.metadataViewer"
```

## Step 10. Test End-to-End

1. Open the simulator in Agent Builder
2. Send: "Which regions have the lowest mental health scores?"
3. Verify the agent:
   - Gets the table schema (Tool use: BigQuery)
   - Profiles the data (Playbook invocation: Data Profiling)
   - Runs a cross-tabulation query with confidence intervals
   - Validates the results (Playbook invocation: Validation)
   - Calls Generate_Slide_Deck with title and bullets
   - Returns a Slide URL
4. Open the Slide URL and verify the content is on the ITV template

Then test via Google Chat:
1. Find the bot in Google Chat
2. Send the same question
3. Verify the full flow works end-to-end

## Architecture Diagram

```
User (Google Chat)
    │
    ▼
Vertex AI Agent (Consomme Slide-Bot)
    │
    ├── ${PLAYBOOK: Data Profiling}     ← shape detection, column profiling
    ├── ${PLAYBOOK: SQL Patterns}       ← BQ dialect, statistical queries
    ├── ${PLAYBOOK: Validation}         ← QA checklist, significance tests
    │
    ├── ${TOOL: BigQuery}               ← Connector tool → BQ in mit-consomme-test
    │       └── ExecuteCustomQuery      ← arbitrary SQL execution
    │
    └── ${TOOL: Generate_Slide_Deck}    ← OpenAPI tool → Cloud Function
            └── POST /generate-slide-deck
                    │
                    ├── Drive API: copy ITV Golden Template
                    └── Slides API: inject title + bullets
```

## Known Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| Create button in Tools doesn't respond | `connectors.googleapis.com` not enabled | Enable the API (Step 1) |
| Cloud Function returns `403 storageQuotaExceeded` | SA has 0-byte Drive quota | Pass `parents` array pointing to shared folder |
| `deleteText` on empty placeholder throws 400 | Slides API rejects delete on empty text | Use `insertText` only (no delete) |
| Agent hallucates instead of saying "I don't know" | No anti-hallucination instruction | Add: "If you don't get data back from the tool, respond that you don't know" |
| `${PLAYBOOK: Name}` shows as plain text | Name doesn't match an existing playbook | Check exact spelling and capitalization |
| Agent doesn't use tools despite instructions | Missing or insufficient examples | Add at least 4 examples with Tool use actions |
| Use `conversational-agents.cloud.google.com` | `dialogflow.cloud.google.com` defaults to CX flows | Wrong console = no playbook option |
| Connector creation fails silently | SA missing BigQuery roles | Grant `bigquery.user` + `bigquery.dataViewer` to connector SA before creating |
| `secretmanager.googleapis.com` not enabled | Integration Connectors depends on it | Enable it in Step 1 — no error message, just broken UI |
| Connector takes 5-10 minutes | Normal for first creation — provisions infrastructure | Check status in Connectors console, not Agent Builder |

## File Index

| Path | Purpose |
|------|---------|
| `SETUP.md` | This file — complete setup runbook |
| `ARCHITECTURE.md` | Design decisions, Gemini CLI vs Agent Builder delta |
| `SLIDE_BOT_SUMMARY.md` | Original architecture notes from session 1 |
| `INSTRUCTIONS.md` | Original flat instructions (superseded by playbooks/) |
| `playbooks/00-slide-bot.md` | Top-level playbook instructions |
| `playbooks/01-data-profiling.md` | Data Profiling sub-playbook |
| `playbooks/02-sql-patterns.md` | SQL Patterns sub-playbook |
| `playbooks/03-validation.md` | Validation sub-playbook |
| `examples/01-survey-crosstab.md` | Example: regional comparison |
| `examples/02-simple-question.md` | Example: vague question → summary |
| `examples/03-tool-error.md` | Example: no data found |
| `examples/04-drilldown.md` | Example: drill-down follow-up |
| `../cloud-functions/slide-bot/main.py` | Cloud Function source |
| `../cloud-functions/slide-bot/openapi.yaml` | OpenAPI schema for the tool |
| `../cloud-functions/slide-bot/deploy.sh` | Deployment script |
