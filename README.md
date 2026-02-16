# consommé

BigQuery data analysis skill for AI coding agents. Takes messy data and produces crystal-clear insights — the technique does the work, not the person.

## Status

**Robustness:** Beta — actively developed

**Works with:** Claude Code, Gemini CLI, Amp

**Install:** `gemini extensions install` (Gemini) or `./install.sh` (Claude Code / Amp)

**Requires:** GCP project with BigQuery API (or just a Google Sheet for light analysis)

Combines:
- **[Google's BQ Data Analytics extension](https://github.com/gemini-cli-extensions/bigquery-data-analytics)** — MCP tools for direct BigQuery connectivity (`execute_sql`, `forecast`, `analyze_contribution`, catalog search)
- **[Anthropic's data analysis skill](https://github.com/anthropics/skills/tree/main/skills/data-analysis)** — systematic approaches to data exploration, SQL craft, validation, and visualization — stripped to BQ-only

Works with both **Gemini CLI** and **Claude Code**.

## Install

### Gemini CLI (one command)

```bash
gemini extensions install https://github.com/spm1001/consomme
```

You'll be prompted for your BigQuery Project ID. Then install the BQ tools extension:

```bash
gemini extensions install https://github.com/gemini-cli-extensions/bigquery-data-analytics
```

Commands available immediately: `/consomme`, `/consomme-profile`, `/consomme-explore`, `/consomme-dashboard`, `/consomme-validate`, `/consomme-sheets`, `/consomme-ingest`.

### Claude Code / Amp

```bash
git clone https://github.com/spm1001/consomme.git
cd consomme && ./install.sh
```

Requires a BQ MCP server configured separately (ADC or service account).

### No BigQuery? No problem.

`/consomme-sheets <google-sheet-url>` analyses Google Sheets directly — no BQ access needed. Works for datasets up to ~5K rows. Requires the [mise](https://github.com/spm1001/mise-en-space) MCP server for Sheet fetching.

## Prerequisites (for BigQuery features)

- A GCP project with BigQuery API enabled
- Your Google account granted `roles/bigquery.user` on the project

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
