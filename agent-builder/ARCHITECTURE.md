# Agent Builder Architecture: Bridging the Skill Gap

## The Delta: Gemini CLI Extension vs Agent Builder

The Gemini CLI `bigquery-data-analytics` extension provides 8 MCP tools via a `toolbox` binary:

| Toolbox Tool | Purpose | Agent Builder Equivalent |
|---|---|---|
| `execute_sql` | Run SQL | `${TOOL: BigQuery}` — likely yes |
| `get_table_info` | Schema inspection | `${TOOL: BigQuery}` — likely yes |
| `get_dataset_info` | Dataset metadata | `${TOOL: BigQuery}` — likely yes |
| `list_dataset_ids` | List datasets | `${TOOL: BigQuery}` — likely yes |
| `list_table_ids` | List tables | `${TOOL: BigQuery}` — likely yes |
| `search_catalog` | Semantic table search | `${TOOL: BigQuery}` — **check** |
| `forecast` | BQML time-series forecasting | **Missing — no equivalent** |
| `analyze_contribution` | Key-driver / contribution analysis | **Missing — no equivalent** |

### What this means

The basic query-and-inspect loop works. But two of the most powerful analytical tools — `forecast` and `analyze_contribution` — are custom `toolbox` tool kinds, not standard BigQuery API calls. Agent Builder's built-in BigQuery toolset almost certainly doesn't include them.

### Compensating mechanisms

1. **Python code snippets** (`@Action`) — Agent Builder can run Python server-side. Statistical tests, chart logic, and even `google-cloud-bigquery` client calls could live here.
2. **Raw BQML SQL** — The forecast tool is a wrapper around `CREATE MODEL ... OPTIONS(model_type='ARIMA_PLUS')`. The agent could write this SQL directly via `execute_sql`, though it's more complex.
3. **OpenAPI tools** — Like Generate_Slide_Deck, you could wrap forecast/contribution as Cloud Functions with OpenAPI schemas.

### Recommendation

For v1, accept the gap: focus the Agent Builder bot on the **query → validate → present** loop using the built-in BigQuery toolset + Generate_Slide_Deck. If forecast/contribution are needed later, wrap them as Cloud Functions.

## Playbook Hierarchy (Option B)

```
Consomme Slide-Bot (Default Generative Playbook)
├── ${PLAYBOOK: Data Profiling}     — shape detection, schema profiling
├── ${PLAYBOOK: SQL Patterns}       — BQ dialect, anti-patterns, common queries
├── ${PLAYBOOK: Validation}         — QA checklist, statistical significance
└── ${TOOL: Generate_Slide_Deck}    — final output
```

Each sub-playbook carries the deep knowledge from one or two SKILL.md reference files.
The top-level playbook is the conductor — it orchestrates the 5-stage workflow and delegates to sub-playbooks for domain knowledge.

## Files

| File | Agent Builder Entity |
|---|---|
| `playbooks/00-slide-bot.md` | Default Generative Playbook instructions |
| `playbooks/01-data-profiling.md` | Data Profiling sub-playbook |
| `playbooks/02-sql-patterns.md` | SQL Patterns sub-playbook |
| `playbooks/03-validation.md` | Validation sub-playbook |
| `examples/` | Worked examples for the Examples tab |
