# Testing consommé

## 1. Installation (no BQ needed)

```bash
# Install
./install.sh

# Verify symlinks
./install.sh --verify

# Check both locations
ls -la ~/.gemini/skills/bq-analyst
ls -la ~/.claude/skills/bq-analyst
```

✅ Both symlinks point to `skills/bq-analyst` in this repo.

## 2. Skill loads in agent

### Gemini CLI

```bash
gemini skills list
```

✅ `bq-analyst` appears in the list.

### Claude Code / Amp

Start a new session in any project. The skill should appear in available skills. Test with:

> "What skills do you have for BigQuery?"

✅ Agent mentions bq-analyst skill.

## 3. End-to-end with BigQuery

### Prerequisites

- [ ] Gemini CLI installed (`npm i -g @anthropic-ai/gemini-cli` or via installer)
- [ ] Signed in: `gemini auth login`
- [ ] BQ extension installed: `gemini extensions install https://github.com/gemini-cli-extensions/bigquery-data-analytics`
- [ ] Extension configured with your GCP project ID
- [ ] Your Google account has `roles/bigquery.user` on the project
- [ ] Data exists in BigQuery (e.g., advertiser data loaded from Sheets)

### Test sequence

Run these in Gemini CLI, one at a time. Each tests a different stage of the workflow.

#### Discovery (search_catalog, list_dataset_ids, list_table_ids)

> "What datasets do I have?"

✅ Returns a list of dataset IDs from your project.

> "What tables are in the [dataset_name] dataset?"

✅ Returns table names.

#### Schema understanding (get_table_info, get_dataset_info)

> "Show me the schema for [dataset.table]"

✅ Returns column names, types, partitioning info.

#### Exploration methodology (execute_sql + skill methodology)

> "Profile the [table] table — show me data quality, distributions, and any issues"

✅ Agent follows the 3-phase profiling approach:
- Structural (row count, grain, primary key)
- Column-level (nulls, distinct counts, distributions)
- Quality assessment (completeness, consistency flags)

#### Analysis (execute_sql)

> "Show me the top 10 advertisers by total spend in the last 30 days"

✅ Generates valid BigQuery SQL with DATE_SUB, runs it, returns results.

#### Forecasting (forecast)

> "Forecast [metric] for the next 3 months based on historical data"

✅ Uses the `forecast` tool, returns projections.

#### Contribution analysis (analyze_contribution)

> "Why did total spend change last month compared to the month before?"

✅ Uses `analyze_contribution` tool, identifies key drivers.

#### Validation (skill methodology)

> "Check that analysis — does everything look right?"

✅ Agent runs sanity checks (magnitude, cross-validation, red flags).

#### Visualization

> "Build me an interactive dashboard showing advertiser performance over time"

✅ Generates self-contained HTML file with Chart.js, KPI cards, filters.

## 4. Negative tests

> "Query my PostgreSQL database"

✅ Agent does NOT use BQ tools — skill correctly scoped to BigQuery only.

> "Set up a new BigQuery dataset"

✅ Agent handles this as infrastructure, not analysis — may note it's outside skill scope.

## 5. Forge validation

```bash
# Structure lint (target: 85+)
python3 ~/.claude/skills/skill-forge/scripts/lint_skill.py skills/bq-analyst

# Description quality (target: 70+)
python3 ~/.claude/skills/skill-forge/scripts/score_description.py skills/bq-analyst
```

Current scores: Lint 90/100, CSO 77/100.
