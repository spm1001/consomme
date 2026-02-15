# consommé — Build Plan

## What

A single SKILL.md that combines:
- **Google BQ Data Analytics extension** tools (connectivity)
- **Anthropic knowledge-work-plugins data skills** (methodology)

Stripped to BigQuery-only. Works in both Gemini CLI (`~/.gemini/skills/`) and Claude Code (`~/.claude/skills/`).

## Source Material

### Google extension (clone at /tmp/bq-data-analytics)
- `tools.yaml` — 8 MCP tools: `execute_sql`, `forecast`, `analyze_contribution`, `get_dataset_info`, `get_table_info`, `list_dataset_ids`, `list_table_ids`, `search_catalog`
- `BIGQUERY.md` — 27 lines of setup/IAM guidance

### Anthropic data plugin (https://github.com/anthropics/knowledge-work-plugins/tree/main/data/skills)
- `sql-queries/SKILL.md` (427 lines) — multi-dialect SQL reference. **Keep BQ section only** (~100 lines). Keep common patterns (window functions, CTEs, funnels, cohorts).
- `data-exploration/SKILL.md` (231 lines) — 3-phase profiling methodology. **Keep all**, rewrite example queries as BQ SQL.
- `data-validation/SKILL.md` — QA framework. **Keep as-is**, dialect-agnostic.
- `interactive-dashboard-builder/SKILL.md` (786 lines) — Chart.js dashboard patterns. **Keep as-is**, no SQL dependency.
- `data-visualization/SKILL.md` — chart selection and Python viz. **Keep selectively**.
- `statistical-analysis/SKILL.md` — stats methodology. **Keep selectively**.
- `data-context-extractor/SKILL.md` — **Review, likely skip**.

## Target Structure

```
skills/consomme/SKILL.md    ← The Franken-Skill (~500-600 lines)
install.sh                     ← Symlinks into ~/.gemini/skills/ and/or ~/.claude/skills/
README.md                      ← Already written
```

## SKILL.md Structure

### Frontmatter
```yaml
name: consomme
description: BigQuery data analysis — exploration, SQL craft, validation, and visualization. Assumes BQ Data Analytics extension is installed for MCP tools (execute_sql, forecast, analyze_contribution, catalog search). Use when analysing data, writing queries, exploring datasets, or building dashboards from BigQuery data.
```

### Sections (in order)

1. **Workflow overview** — The decision tree:
   - DISCOVER → UNDERSTAND → ANALYZE → VALIDATE → PRESENT
   - Which tool to use at each stage
   - Reference tools by their MCP names

2. **Tool reference** — Brief description of each of the 8 MCP tools, when to use them, example prompts. Source: Google tools.yaml + BIGQUERY.md.

3. **Data exploration methodology** — 3-phase approach (structural → column-level → relationship discovery). Quality assessment framework. Source: Anthropic data-exploration skill. Rewrite SQL examples for BQ dialect.

4. **BigQuery SQL reference** — BQ-specific date/time, string, JSON, array functions. Performance tips (partition pruning, clustering, APPROX_COUNT_DISTINCT, avoid SELECT *). Source: Anthropic sql-queries skill, BQ section only.

5. **Common SQL patterns** — Window functions, CTEs, funnels, cohort retention. Source: Anthropic sql-queries skill, common patterns section (these are mostly dialect-agnostic).

6. **Validation framework** — Pre-delivery QA checklist. Sanity checks, methodology review, bias detection. Source: Anthropic data-validation skill.

7. **Dashboard builder patterns** — Chart.js base template, KPI cards, filter patterns, CSS system, responsive design, performance guidelines by data size. Source: Anthropic interactive-dashboard-builder skill. This is the longest section — consider whether to include inline or as a reference file.

## Design Decisions

- **Single file vs references/**: Start as single file. If it exceeds ~800 lines, split dashboard-builder into `references/dashboard-patterns.md`.
- **Tool names**: Use the exact MCP tool names (`execute_sql`, not "run a query") so the model maps correctly.
- **No Cowork-isms**: Strip all Cowork plugin infrastructure. This is a pure skill file.
- **Dual-agent**: Must work for both Gemini CLI and Claude Code. No agent-specific syntax. The skill content is identical; only the install location differs.
- **Attribution**: Note both sources in a comment at the top.

## Install Script

Simple symlinker, same pattern as trousse's install.sh:
- Detect whether ~/.gemini/skills/ and/or ~/.claude/skills/ exist
- Create symlink for consomme skill directory
- Print confirmation

## Verification

After building, check:
- [ ] Skill loads in Gemini CLI (`gemini skills list`)
- [ ] Skill loads in Claude Code (appears in available skills)
- [ ] Tool names match the Google extension's tools.yaml exactly
- [ ] All SQL examples are valid BQ dialect
- [ ] No references to Snowflake/Redshift/Databricks/PostgreSQL
- [ ] Dashboard builder patterns are self-contained (no external dependencies beyond Chart.js CDN)
