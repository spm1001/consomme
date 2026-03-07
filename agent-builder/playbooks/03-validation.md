# Validation — Sub-Playbook

Paste into a new playbook named **"Validation"**.

**Goal:** Cross-check every analysis before presenting results to the user. Catch errors before they become slide decks.

---

- Run through this checklist before calling ${TOOL: Generate_Slide_Deck}. If any check fails, investigate and fix before proceeding.

## Data Quality Checks

- Source tables are correct — are these the right tables for this question?
- Data freshness — note the "as of" date. Stale data should be flagged.
- No unexpected gaps in time series or missing segments.
- Null rates checked in key columns — nulls handled appropriately (excluded or noted).
- No double-counting from bad joins — check with COUNT(DISTINCT id) after every join.
- All WHERE clauses and filters are correct — no unintended exclusions.

## Calculation Checks

- GROUP BY includes all non-aggregated columns.
- Rate/percentage denominators are correct and non-zero (use SAFE_DIVIDE or NULLIF).
- Date comparisons use same period length — partial periods excluded or noted.
- JOIN types are appropriate — no many-to-many joins inflating counts.
- Metric definitions match how stakeholders define them — ask if unsure.

## Reasonableness Checks

- Numbers are in a plausible range:
  - Revenue is not negative
  - Percentages are between 0% and 100%
  - Segment percentages sum to approximately 100%
  - User counts match known figures if available
- No unexplained jumps or drops in time series.
- Results are consistent with other known sources (dashboards, prior reports) if mentioned.

## Statistical Validity

- When comparing groups, differences MUST be tested for significance. Do not eyeball.
  - For proportions: use the z-test (see ${PLAYBOOK: SQL Patterns} for the query).
  - For means: use confidence intervals — if CIs don't overlap, the difference is likely real.
  - Minimum sample size: 30 per group. Flag any segment below this as unreliable.
- Multiple comparisons: if testing many segments, use Bonferroni correction (divide significance threshold by number of comparisons — e.g., p < 0.005 instead of p < 0.05 when testing 10 segments).
- Beware Simpson's Paradox: always check overall results AND segment-level results. If they disagree, investigate segment sizes.

## Red Flags That Require Investigation

- Any metric changing >50% period-over-period without obvious cause
- Counts or sums that are exact round numbers (suggests fabricated or placeholder data)
- Rates exactly at 0% or 100%
- Results that perfectly confirm the hypothesis (too clean = suspicious)
- Identical values across time periods or segments

## Before Presenting

- Distill to the single most important finding as the slide title.
- Each bullet should contain a specific number, comparison, or finding — not vague statements.
- State limitations explicitly: small sample sizes, data gaps, assumptions made.
- Include the date range and data source in the bullets.
