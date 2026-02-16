# consomme — BigQuery Data Analyst (Gemini Extension)

## Prerequisites

This extension provides **methodology only**. You also need the BQ MCP tools.
Install: `gemini extensions install googlecloudplatform/bq-data-analytics`

If BQ tool calls fail with "tool not found", the BQ Data Analytics extension is missing.

## Gemini-Specific Behaviour

- **Shape detection:** State your assessment and proceed. Don't wait for confirmation — Gemini CLI doesn't support interactive prompts mid-analysis. If the shape turns out wrong, switch methodology and note the correction.
- **Project ID:** Use the BIGQUERY_PROJECT environment variable for all BQ tool calls.

## Methodology

@./skills/consomme/SKILL.md

## Reference: SQL Patterns

@./skills/consomme/references/sql-reference.md

## Reference: Statistical Analysis

@./skills/consomme/references/statistical-analysis.md

## Reference: Survey Profiling

@./skills/consomme/references/profiling-survey.md

## Reference: Time Series Profiling

@./skills/consomme/references/profiling-timeseries.md

## Reference: Warehouse Profiling

@./skills/consomme/references/profiling-warehouse.md

## Reference: Dashboard Patterns

@./skills/consomme/references/dashboard-patterns.md
