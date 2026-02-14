---
name: bq-analyst
description: BigQuery data analysis — BEFORE writing any BQ query, load this for methodology and dialect reference. Provides 5-stage workflow (discover → understand → analyse → validate → present) mapped to MCP tools (execute_sql, forecast, analyze_contribution, catalog search). Triggers on 'analyse this data', 'explore the dataset', 'what tables do we have', 'build a dashboard', 'query BigQuery', 'why did this metric change'. (user)
---

<!-- Sources: Google BQ Data Analytics extension (Apache-2.0), Anthropic knowledge-work-plugins (MIT) -->

# BigQuery Data Analyst

Systematic methodology for exploring, querying, validating, and visualizing BigQuery data using MCP tools.

## When to Use

- Analysing data in BigQuery — exploring datasets, writing queries, building dashboards
- User asks about data, metrics, trends, or patterns and the data lives in BigQuery
- Building interactive HTML dashboards from query results
- Validating an analysis before sharing with stakeholders

## When NOT to Use

- Data is not in BigQuery (different warehouse, local CSV, etc.)
- User is writing application code that happens to query BQ (they need a client library, not an analysis skill)
- Pure infrastructure tasks (creating datasets, managing IAM) — use GCP console or CLI directly

## 1. Workflow Overview

Every analysis follows five stages. Use the MCP tools mapped to each stage:

```
DISCOVER → UNDERSTAND → ANALYZE → VALIDATE → PRESENT
```

| Stage | Purpose | MCP Tools |
|-------|---------|-----------|
| **Discover** | Find relevant tables and datasets | `search_catalog`, `list_dataset_ids`, `list_table_ids` |
| **Understand** | Learn schema, shape, and quality | `get_dataset_info`, `get_table_info`, `execute_sql` |
| **Analyze** | Query, aggregate, model | `execute_sql`, `forecast`, `analyze_contribution` |
| **Validate** | Check results before sharing | `execute_sql` (cross-checks, spot-checks) |
| **Present** | Visualize and communicate | Results from above stages → charts, dashboards, tables |

**Start at Discover** unless the user names specific tables. Never skip Understand — always profile before analyzing.

## 2. Tool Reference

### Discovery Tools

**`search_catalog`** — Find tables, views, models, routines, or connections by keyword. Use first when the user describes data conceptually ("advertiser performance", "user events") rather than naming specific tables.

**`list_dataset_ids`** — List all datasets in the project. Use to orient when entering an unfamiliar project.

**`list_table_ids`** — List all tables in a specific dataset. Use after identifying a relevant dataset to see what's available.

### Schema Tools

**`get_dataset_info`** — Get dataset-level metadata (description, labels, location, default expiration). Use to understand dataset purpose and organization.

**`get_table_info`** — Get table metadata including schema (column names and types), partitioning configuration, clustering fields, and row count. Use before writing any query against a table.

### Analysis Tools

**`execute_sql`** — Execute SQL statements against BigQuery. The primary workhorse — used for profiling, analysis, and validation queries. Returns results directly.

**`forecast`** — Forecast time series data. Use when the user asks about projections, predictions, or future trends based on historical patterns.

**`analyze_contribution`** — Analyze contribution of dimensions to changes in a key metric. Use when the user asks "why did X change?" or "what's driving the increase/decrease in Y?"

### Setup Requirements

- **`BIGQUERY_PROJECT`** environment variable must be set to the GCP project ID
- **Read access**: `roles/bigquery.user` on the user's Google account
- **Write access** (if creating tables/views): additionally `roles/bigquery.dataEditor`
- **Gemini CLI**: Authentication is automatic — the extension uses the Gemini CLI sign-in (`gemini auth login`) via client OAuth. No gcloud CLI needed.
- **Claude Code**: Requires a BigQuery MCP server configured with ADC or service account credentials

## 3. Data Exploration Methodology

Before analyzing any dataset, profile it systematically. Use `get_table_info` for schema discovery and `execute_sql` for profiling queries.

### Phase 1: Structural Understanding

Establish the basics before touching the data:

**Table-level questions (answer all before proceeding):**
- How many rows and columns?
- What is the grain — one row per what?
- What is the primary key? Is it unique?
- When was the data last updated?
- How far back does the data go?

**Column classification** — categorize every column as one of:

| Type | Description | Examples |
|------|-------------|---------|
| **Identifier** | Unique keys, foreign keys | user_id, order_id |
| **Dimension** | Categorical attributes for grouping | status, region, category |
| **Metric** | Quantitative values for measurement | revenue, count, duration |
| **Temporal** | Dates and timestamps | created_at, event_date |
| **Text** | Free-form text fields | description, notes |
| **Boolean** | True/false flags | is_active, has_purchased |
| **Structural** | JSON, arrays, nested structures | metadata, tags |

### Phase 2: Column-Level Profiling

Profile every column with `execute_sql`. Compute:

**All columns:**
- Null count and null rate
- Distinct count and cardinality ratio (distinct / total)
- Most common values (top 5–10 with frequencies)
- Least common values (bottom 5 — to spot anomalies)

**Numeric columns (metrics):**
- min, max, mean, median (APPROX_QUANTILES for p50)
- Standard deviation
- Percentiles: p1, p5, p25, p75, p95, p99
- Zero count, negative count (if unexpected)

**String columns (dimensions, text):**
- Min/max/avg length
- Empty string count
- Pattern analysis (do values follow a format?)
- Case consistency (all upper, all lower, mixed?)

**Date/timestamp columns:**
- Min date, max date
- Null dates, future dates (if unexpected)
- Distribution by month/week
- Gaps in time series

**Boolean columns:**
- True count, false count, null count
- True rate

### Phase 3: Relationship Discovery

After profiling individual columns:

- **Foreign key candidates**: ID columns that might link to other tables
- **Hierarchies**: Columns forming natural drill-down paths (country → region → city)
- **Correlations**: Numeric columns that move together (use CORR function)
- **Derived columns**: Columns computed from others
- **Redundant columns**: Columns with identical or near-identical information

### Quality Assessment Framework

#### Completeness Score

Rate each column:

| Rating | Non-null rate | Action |
|--------|--------------|--------|
| 🟢 Complete | >99% | Good to use |
| 🟡 Mostly complete | 95–99% | Investigate the nulls |
| 🟠 Incomplete | 80–95% | Understand why, assess impact |
| 🔴 Sparse | <80% | May need imputation or exclusion |

#### Consistency Checks

Look for:
- **Value format inconsistency**: "USA", "US", "United States", "us"
- **Type inconsistency**: Numbers stored as strings, dates in various formats
- **Referential integrity**: Foreign keys with no matching parent record
- **Business rule violations**: Negative quantities, end dates before start dates, percentages > 100
- **Cross-column consistency**: Status = "completed" but completed_at is null

#### Accuracy Indicators

Red flags for accuracy issues:
- **Placeholder values**: 0, -1, 999999, "N/A", "TBD", "test"
- **Default value dominance**: Suspiciously high frequency of a single value
- **Stale data**: updated_at shows no recent changes in an active system
- **Impossible values**: Ages > 150, dates in the far future, negative durations
- **Round number bias**: All values ending in 0 or 5 (suggests estimation)

#### Timeliness

- When was the table last updated?
- What is the expected update frequency?
- Is there a lag between event time and load time?
- Are there gaps in the time series?

## 4. SQL Reference and Patterns

BigQuery-specific functions (date/time, string, arrays/structs), performance tips, and common analytical patterns (window functions, CTEs, cohort retention, funnels, deduplication) are in `references/sql-reference.md`.

Read that reference when writing or reviewing any SQL query. Key points to always remember:

- **No `ILIKE`** in BigQuery — use `LOWER(col) LIKE '%pattern%'`
- **`DATE_TRUNC(col, MONTH)`** not `DATE_TRUNC('month', col)` — the period is an identifier, not a string
- **`APPROX_COUNT_DISTINCT()`** for large-scale cardinality — much cheaper than `COUNT(DISTINCT)`
- **Always filter on partition columns** — BigQuery bills per byte scanned
- **Avoid `SELECT *`** — select only the columns you need

## 6. Validation Framework

Run through these checks before sharing any analysis.

### Pre-Delivery QA Checklist

**Data quality:**
- [ ] Source tables verified — are they the right ones for this question?
- [ ] Data is fresh enough — noted the "as of" date
- [ ] No unexpected gaps in time series or missing segments
- [ ] Null rates checked in key columns — nulls handled appropriately
- [ ] No double-counting from bad joins or duplicate source records
- [ ] All WHERE clauses and filters are correct — no unintended exclusions

**Calculation checks:**
- [ ] GROUP BY includes all non-aggregated columns
- [ ] Rate/percentage denominators are correct and non-zero
- [ ] Date comparisons use same period length — partial periods excluded or noted
- [ ] JOIN types are appropriate — many-to-many joins haven't inflated counts
- [ ] Metric definitions match how stakeholders define them

**Reasonableness:**
- [ ] Numbers are in a plausible range (revenue not negative, percentages 0–100%)
- [ ] No unexplained jumps or drops in time series
- [ ] Key numbers match other known sources (dashboards, prior reports, finance data)
- [ ] Edge cases considered (empty segments, zero-activity periods, new entities)

**Presentation:**
- [ ] Bar charts start at zero, axes labelled, scales consistent
- [ ] Appropriate precision and formatting (currency, percentages, thousands separators)
- [ ] Titles state the insight, not just the metric — date ranges specified
- [ ] Known limitations and assumptions stated explicitly

### Common Pitfalls

**Join explosion** — A many-to-many join silently multiplies rows, inflating counts and sums. Always check row counts after joins. Use `COUNT(DISTINCT a.id)` instead of `COUNT(*)` when counting entities through joins.

**Survivorship bias** — Analyzing only entities that exist today ignores those that were deleted, churned, or failed. Always ask: "who is NOT in this dataset?"

**Incomplete period comparison** — Comparing a partial month to a full month. Always filter to complete periods, or compare same-number-of-days.

**Denominator shifting** — The denominator changes between periods (e.g., "eligible" users redefined), making rates incomparable. Use consistent definitions across all compared periods.

**Average of averages** — Averaging pre-computed averages gives wrong results when group sizes differ. Always aggregate from raw data.

**Timezone mismatches** — Different sources use different timezones, causing misalignment. Standardize to a single timezone (UTC recommended) before analysis.

**Selection bias in segmentation** — Defining segments by the outcome being measured creates circular logic ("power users generate more revenue" — they became power users BY generating revenue). Define segments based on pre-treatment characteristics, not outcomes.

### Result Sanity Checking

**Magnitude checks:**

| Metric Type | Sanity Check |
|-------------|-------------|
| User counts | Match known MAU/DAU figures? |
| Revenue | Right order of magnitude vs. known ARR? |
| Conversion rates | Between 0% and 100%? Match dashboard figures? |
| Growth rates | Is 50%+ MoM realistic, or a data issue? |
| Averages | Reasonable given the distribution? |
| Percentages | Segment percentages sum to ~100%? |

**Cross-validation techniques:**
1. Calculate the same metric two different ways — verify they match
2. Spot-check individual records — pick a few entities and trace manually
3. Compare to known benchmarks — dashboards, finance reports, prior analyses
4. Reverse engineer — if total revenue is X, does per-user × user count ≈ X?
5. Boundary checks — filter to a single day, user, or category — are micro-results sensible?

**Red flags that warrant investigation:**
- Any metric changing >50% period-over-period without obvious cause
- Counts or sums that are exact round numbers
- Rates exactly at 0% or 100%
- Results that perfectly confirm the hypothesis
- Identical values across time periods or segments

### Documentation Template

Every non-trivial analysis should record:

```
## Analysis: [Title]
Question: [What's being answered]
Sources: [Tables used, as-of dates]
Definitions: [How key metrics are calculated]
Methodology: [Steps taken]
Assumptions: [What's assumed and why]
Limitations: [Known gaps and their impact]
Key Findings: [Results with supporting evidence]
```

## 7. Visualization

### Chart Selection Guide

| What You're Showing | Best Chart | Alternatives |
|---------------------|-----------|--------------|
| Trend over time | Line chart | Area chart (cumulative/composition) |
| Comparison across categories | Vertical bar | Horizontal bar (many categories) |
| Ranking | Horizontal bar | Dot plot, slope chart (two periods) |
| Part-to-whole composition | Stacked bar | Treemap (hierarchical) |
| Composition over time | Stacked area | 100% stacked bar (proportion focus) |
| Distribution | Histogram | Box plot (comparing groups) |
| Correlation (2 variables) | Scatter plot | Bubble chart (add 3rd variable as size) |
| Correlation (many variables) | Heatmap | Pair plot |
| Flow / process | Sankey diagram | Funnel chart (sequential stages) |
| Performance vs. target | Bullet chart | Gauge (single KPI only) |
| Multiple KPIs at once | Small multiples | Dashboard with separate charts |

**When NOT to use:**
- **Pie charts**: Avoid unless <6 categories. Humans compare angles poorly — use bar charts instead.
- **3D charts**: Never. They distort perception and add no information.
- **Dual-axis charts**: Use cautiously — they can imply false correlation. Label both axes clearly.
- **Stacked bar (many categories)**: Hard to compare middle segments. Use small multiples or grouped bars.

### Dashboard Patterns

For interactive HTML dashboards with Chart.js, KPI cards, filters, and responsive design, see `references/dashboard-patterns.md`.

That reference covers:
- Self-contained HTML/JS base template with Chart.js CDN
- KPI card components with period-over-period change indicators
- Line, bar, and doughnut chart creation patterns
- Dropdown and date-range filter implementation
- Sortable data tables
- CSS design system (color variables, layout grid, responsive breakpoints, print styles)
- Performance guidelines by data size (when to pre-aggregate, chart point limits, DOM pagination)
