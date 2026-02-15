# consommé

BigQuery data analysis skill for AI coding agents. Takes messy data and produces crystal-clear insights — the technique does the work, not the person.

## Status

**Robustness:** Beta — actively developed
**Works with:** Claude Code, Gemini CLI
**Install:** Clone + symlink skill
**Requires:** Python 3.11+, GCP project with BigQuery API

Combines:
- **[Google's BQ Data Analytics extension](https://github.com/gemini-cli-extensions/bigquery-data-analytics)** — MCP tools for direct BigQuery connectivity (`execute_sql`, `forecast`, `analyze_contribution`, catalog search)
- **[Anthropic's data analysis skill](https://github.com/anthropics/skills/tree/main/skills/data-analysis)** — systematic approaches to data exploration, SQL craft, validation, and visualization — stripped to BQ-only

Works with both **Gemini CLI** and **Claude Code**.

## Prerequisites

- A GCP project with BigQuery API enabled
- Your Google account granted `roles/bigquery.user` on the project

### For Gemini CLI users

```bash
# 1. Sign in to Gemini CLI (browser-based, no gcloud needed)
gemini auth login

# 2. Install the BQ extension (provides MCP tools)
gemini extensions install https://github.com/gemini-cli-extensions/bigquery-data-analytics

# 3. Configure the extension
gemini extensions config bigquery-data-analytics
#    → Set Project ID to your GCP project
#    → useClientOAuth is enabled automatically — the extension
#      piggybacks on your Gemini CLI sign-in for BigQuery access

# 4. Install consommé skill
./install.sh
```

### For Claude Code users

```bash
# 1. Configure a BQ MCP server in your settings
#    (requires a separate BigQuery MCP server + ADC or service account)

# 2. Install consommé skill
./install.sh
```

## What you get

| Layer | What it does |
|-------|-------------|
| **Discovery** | Find tables, explore schemas, understand what data exists |
| **Exploration** | 3-phase data profiling methodology — structural, column-level, relationships |
| **SQL craft** | BigQuery-specific SQL reference — window functions, CTEs, funnels, cohorts |
| **Analysis** | Natural language → SQL → results, plus forecasting and contribution analysis |
| **Validation** | Pre-delivery QA framework — sanity checks before sharing |
| **Visualization** | Interactive HTML dashboards with Chart.js, filters, KPI cards |

## Project setup

For teams working with specific datasets, drop a `GEMINI.md` or `CLAUDE.md` in your project directory:

```
advertiser-analysis/
├── GEMINI.md              ← "Our advertiser data lives in project X, dataset Y"
└── .gemini/settings.json  ← BQ extension config (auto-created on install)
```

## The Kitchen

Consommé is part of [Batterie de Savoir](https://spm1001.github.io/batterie-de-savoir/) — a suite of tools for AI-assisted knowledge work, each named for a station in a professional kitchen brigade. See the [full brigade and design principles](https://spm1001.github.io/batterie-de-savoir/) for how the tools fit together.

## License

Apache-2.0
