# Testing consommé

## 1. Installation (no BQ needed)

```bash
# Install
./install.sh

# Verify symlinks
./install.sh --verify

# Check both locations
ls -la ~/.gemini/skills/consomme
ls -la ~/.claude/skills/consomme
```

✅ Both symlinks point to `skills/consomme` in this repo.

## 2. Skill loads in agent

### Gemini CLI

```bash
gemini skills list
```

✅ `consomme` appears in the list.

### Claude Code / Amp

Start a new session in any project. The skill should appear in available skills. Test with:

> "What skills do you have for BigQuery?"

✅ Agent mentions consomme skill.

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
python3 ~/.claude/skills/skill-forge/scripts/lint_skill.py skills/consomme

# Description quality (target: 70+)
python3 ~/.claude/skills/skill-forge/scripts/score_description.py skills/consomme
```

Current scores: Lint 99/100, CSO 79/100.

## 6. Round 1 — SQL Validation (PASSED ✅)

All SQL snippets from `statistical-analysis.md` and `profiling-survey.md` run correctly against real survey data in `mit-consomme-test.survey_data.ohid_survey_raw` (1,320 rows, 39 cols).

Patterns tested and verified:
- Likert distribution with percentage
- Cross-tabulation with `HAVING COUNT(*) >= 30`
- Confidence intervals by group
- Z-test for proportions
- Chi-squared test for independence
- IQR outlier detection

## 7. Round 2 — Skill Workflow Testing (PASSED ✅)

### Test 2.1: Data Shape Detection ✅

Followed Section 3 heuristics against `ohid_survey_raw`:

| Signal | Expected | Actual | Match |
|--------|----------|--------|-------|
| Single table in dataset | Survey signal | ✅ 1 table | ✅ |
| Wide table, many columns | Survey signal | ✅ 39 cols, 1,320 rows | ✅ |
| Column names are question codes | Survey signal | ✅ S0-S3, Q1r1-Q1r12, Q2r1-Q2r5, etc. | ✅ |
| No FK relationships | Survey signal | ✅ Self-contained | ✅ |

**Verdict:** All three heuristic rows in the detection table fire correctly. An agent following the skill would identify this as survey data and route to `profiling-survey.md`.

### Test 2.2: Survey Profiling Flow ✅

Followed `profiling-survey.md` phases against real data:

**Phase 1 (Structural Understanding):**
- 1,320 respondents, 1,320 unique RIDs, 100% consented
- Respondent ID: `RID` (STRING, UUID format)
- Demographics: S1 (age, 5 values: 2-6), S2 (gender, 4 values), S3 (region, 10 values)
- No age code 1 (<18) or 7 (65+) in data — these brackets were screened out

**Phase 2 (Column-Level):**
- Likert Q2r1 distribution: strongly positive skew (44% score 5, 34.6% score 4, only 1.1% "prefer not to say")
- Zero null rates across all question columns — complete responses
- All SQL patterns from the reference worked as-is

**Phase 3 (Cross-Tabulation):**
- Brand awareness by region with `HAVING n >= 30`: correctly excluded Northern Ireland (n=7)
- Scotland (n=67) lowest at 32.8% vs Midlands highest at 53.4%

**Quality Assessment:**
- Straight-lining detected: 410 respondents (31.1%) gave identical scores across all 5 Q2 Likert items
- The skill's straight-lining detection SQL pattern worked correctly
- ⚠ **Finding:** 31% straight-liners is high — worth flagging in any real analysis

### Test 2.3: analyze_contribution ✅

Tested: "Why is brand awareness lower in Scotland?"

- Input: Scotland (region 7) as test vs regions 3,4,5 as control
- Metric: `SUM(aware_of_emm)` (Q3r1)
- Dimensions: `age_group`, `gender`
- Tool ran successfully, returned 20 ranked contributors
- Top insight: overall difference = -280 (22 vs 302), -92.7% relative difference
- Gender=2 (female) is the largest dimensional contributor (225 absolute contribution)
- Age_group=4 (35-44) second largest contributor

**Verdict:** The tool works well for survey cross-group comparison. The skill's recipe in Section 2 (the `analyze_contribution` example) maps correctly to this use case.

### Test 2.4: Chart.js Dashboard ✅

Built a self-contained HTML dashboard at `test-outputs/ohid-survey-dashboard.html` following `dashboard-patterns.md`:

- 308 lines, 3 Chart.js charts + KPI row + data table
- Used the base template structure, CSS system, bar chart patterns
- KPI cards: respondents, EMM awareness, avg attitude score, straight-liner warning
- Chart 1: Brand awareness by region (horizontal bar, Scotland highlighted red)
- Chart 2: Actions taken for wellbeing (horizontal bar, sorted)
- Chart 3: Likert distribution (stacked bar, all 5 Q2 statements)
- Regional breakdown data table with small-n warnings

**Verdict:** The dashboard-patterns.md reference provides sufficient patterns and CSS to build a complete dashboard. No gaps found.

### Observations / Potential Skill Improvements

1. **Straight-liner threshold:** profiling-survey.md detects straight-liners but doesn't suggest what threshold warrants concern (e.g., >10% is high, >20% is a red flag). The 31.1% here is very high.

2. **Encoded survey data:** The profiling-survey.md multi-select pattern assumes comma-separated values, but this survey uses binary 0/1 columns (Q1r1-Q1r12, Q3r1-Q3r6, Q5r1-Q5r6). Both encodings are common. The reference should mention the binary-column pattern and how to profile it (SUM each column).

3. **"Prefer not to say" handling:** Q2 Likert scale has 6 = "prefer not to say". The reference mentions filtering scale responses but doesn't explicitly call out this common survey pattern. Worth adding: "Watch for off-scale codes (e.g., 6='prefer not to say' on a 1-5 scale) — exclude from mean/median calculations."

4. **analyze_contribution with survey data:** Works well but requires careful framing — the "metric" for binary 0/1 survey responses is `SUM(column)` which gives total count of 1s. Worth noting in the tool recipe.

5. **Northern Ireland small sample:** The `HAVING n >= 30` filter correctly excluded NI (n=7) from statistical comparisons, validating the skill's guidance.

### Test 2.5: search_catalog ✅

Searched with natural language prompt: "mental health survey questionnaire responses"
- Found both the table (`ohid_survey_raw`) and dataset (`survey_data`)
- Confirms semantic search works without knowing exact table names

### Bugs Found and Fixed

**SRI hash bug in dashboard-patterns.md:** The Chart.js `<script>` tags had fabricated `integrity` hashes. Chrome silently refused to load the scripts, producing a blank page. Fixed: removed SRI attributes, switched to explicit `/dist/chart.umd.min.js` paths. Also fixed in the generated test dashboard.

### Skill Improvements Applied (Round 2)

| Change | File | What |
|--------|------|------|
| Datamap/codebook section | `profiling-survey.md` | Where to find datamaps, CASE pattern for decoding, "don't guess codes" |
| Cross-reference to stats | `profiling-survey.md` | Link to `statistical-analysis.md` after cross-tab section |
| Binary multi-select pattern | `profiling-survey.md` | SUM-each-column pattern alongside comma-separated |
| Off-scale codes | `profiling-survey.md` | Guidance on "prefer not to say" values outside Likert range |
| Straight-liner thresholds | `profiling-survey.md` | <10% typical, 10-20% note, >20% red flag |
| Survey note for analyze_contribution | `SKILL.md` | SUM(binary_col) tip + cast dimensions to STRING |
| Anti-patterns section | `SKILL.md` | 10-row table — pushed lint from 99 to 100 |
| Survey dashboard pattern | `dashboard-patterns.md` | Layout guide, Likert colour scale, base-size conventions |
| Fix CDN script tags | `dashboard-patterns.md` | Removed bogus SRI hashes |

### Post-Round 2 Scores

- Lint: **100/100** (was 99 — anti-patterns section added)
- CSO: **79/100** (unchanged — timing_gates and action_verbs hold it back)
- SKILL.md: **352 lines** (under 500 limit)

## 8. Gemini CLI Extension Testing (PASSED ✅)

Tested the Gemini CLI extension scaffold (commit c2c4d7c) on Gemini CLI 0.28.2.

### 8.1: Extension Discovery ✅

```bash
gemini extensions list
```

- Extension recognised: `consomme (0.1.0)`
- Context file detected: `CONSOMME.md`
- Agent skill discovered: `consomme` (from `skills/consomme/SKILL.md`)
- Settings captured: `BIGQUERY_PROJECT=mit-consomme-test` (from `.env`)

### 8.2: @import Resolution ✅

Asked Gemini: "What are the five stages of the consomme workflow? What does the SQL reference say about ILIKE?"

- Correctly identified: Discover, Understand, Analyze, Validate, Present
- Correctly cited SQL reference: BigQuery has no `ILIKE`, use `LOWER(col) LIKE` instead
- **Confirms:** CONSOMME.md's `@./skills/consomme/SKILL.md` and all 6 `@./skills/consomme/references/*.md` imports resolve correctly

### 8.3: Command Discovery ✅

All four namespaced commands appeared in Gemini's command listing:

| Command | Description |
|---------|-------------|
| `/consomme-dashboard` | Build a Chart.js HTML dashboard from BigQuery data |
| `/consomme-explore` | Explore a BigQuery project or dataset — list tables, catalog search |
| `/consomme-profile` | Profile a BigQuery table — schema, shape detection, quality assessment |
| `/consomme-validate` | Run QA checklist against the current analysis |

### 8.4: /consomme-profile Command ✅

Ran `/consomme-profile mit-consomme-test.survey_data.ohid_survey_raw` — Gemini correctly:

- Detected **survey shape** from column patterns (question codes, wide table)
- Applied **survey profiling methodology** from the reference
- Generated Likert distribution SQL with `COUNTIF`, top-2-box scoring
- Generated multi-select binary profiling using `UNPIVOT`
- Generated straight-liner detection SQL matching `profiling-survey.md` pattern
- Correctly used the datamap (knew about `qtime` placeholder `999999`)
- Applied `HAVING COUNT(*) >= 30` for small-sample filtering

**Note:** BQ tool calls failed because the Google BQ Data Analytics extension was not installed — Gemini fell back to generating SQL with explanations. This is the expected behaviour when the tool dependency is missing. The methodology layer worked correctly regardless.

### 8.5: Install Flow ✅

Tested `install.sh` changes:

- `--dry-run`: correctly shows skill symlink to `~/.claude/skills` only (not `~/.gemini/skills`), detects and would remove legacy Gemini skill symlink, shows extension link step
- `--verify`: checks both Claude skill symlink and Gemini extension link, warns about legacy symlinks
- Legacy `~/.gemini/skills/consomme` symlink removed (replaced by extension at `~/.gemini/extensions/consomme`)

### Assumptions Verified

| # | Assumption | Result |
|---|-----------|--------|
| 1 | `@./path` imports resolve relative to CONSOMME.md | ✅ All 7 imports resolved |
| 2 | Commands in `commands/` directory are discovered | ✅ All 4 commands listed |
| 3 | Settings from `.env` are available | ✅ `BIGQUERY_PROJECT` shown in `extensions list` |
| 4 | Extension + skill don't conflict | ✅ Legacy skill symlink removed; extension subsumes it |

### Not Yet Tested

- `gemini extensions install <github-url>` from a clean machine (requires pushing to GitHub)
- `${BIGQUERY_PROJECT}` expansion inside TOML prompt strings (needs BQ extension for end-to-end test)
- Full profiling with live BQ tool execution (needs BQ Data Analytics extension installed)

## 9. Round 3 — Time Series & Forecast (pending)

Needs time-series data to test:
- `forecast` tool with real temporal data
- `profiling-timeseries.md` gap detection, grain detection, seasonality checks
- `profiling-warehouse.md` multi-table FK/star-schema profiling

Options: synthetic daily metrics table, or find a public BQ dataset with time series.

## 9. Round 4 — Claude Code Platform Parity (pending)

Test in Claude Code for platform parity with Amp.
