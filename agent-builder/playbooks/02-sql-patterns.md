# SQL Patterns — Sub-Playbook

Paste into a new playbook named **"SQL Patterns"**.

**Goal:** Ensure all SQL follows BigQuery dialect rules and avoids common mistakes.

---

- Every SQL query you write must follow these BigQuery-specific rules. Violations will cause errors or wrong results.

## Dialect Rules (Non-Negotiable)

- **No ILIKE.** BigQuery does not support ILIKE. Use `LOWER(col) LIKE '%pattern%'` instead.
- **DATE_TRUNC syntax.** Use `DATE_TRUNC(column, MONTH)` — the period is an identifier, not a string. Never write `DATE_TRUNC('month', column)`.
- **APPROX_COUNT_DISTINCT.** For cardinality on large tables, use `APPROX_COUNT_DISTINCT(col)` instead of `COUNT(DISTINCT col)`. Much cheaper.
- **No implicit type coercion for dates.** Use `DATE('2024-01-01')` or `PARSE_DATE('%Y-%m-%d', string_col)`, not bare strings.
- **SAFE_ prefix.** Use `SAFE_CAST`, `SAFE_DIVIDE`, `SAFE.PARSE_DATE` to handle bad data without query failure.
- **Array access.** Use `OFFSET(n)` for 0-based or `ORDINAL(n)` for 1-based. `APPROX_QUANTILES(x, 100)[OFFSET(50)]` for median.

## Cost Awareness

- BigQuery bills per byte scanned.
- Always filter on partition columns when available.
- Never use `SELECT *` — select only the columns you need.
- For large tables, use `dry_run: true` first to preview cost.
- Aggregate with GROUP BY before pulling data — don't LIMIT raw rows.

## Common Patterns

- **Frequency distribution:**
  ```sql
  SELECT col, COUNT(*) AS n,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
  FROM table GROUP BY col ORDER BY n DESC
  ```

- **Cross-tabulation (survey segments):**
  ```sql
  SELECT segment, COUNT(*) AS n,
    ROUND(AVG(score), 2) AS avg_score,
    ROUND(100.0 * COUNTIF(score >= 4) / COUNT(*), 1) AS pct_positive
  FROM table WHERE segment IS NOT NULL
  GROUP BY segment HAVING COUNT(*) >= 30
  ORDER BY avg_score DESC
  ```

- **Confidence interval for segment means:**
  ```sql
  SELECT segment, COUNT(*) AS n, AVG(score) AS mean,
    AVG(score) - 1.96 * STDDEV(score) / SQRT(COUNT(*)) AS ci_lower,
    AVG(score) + 1.96 * STDDEV(score) / SQRT(COUNT(*)) AS ci_upper
  FROM table GROUP BY segment
  ```

- **Z-test for proportions (two groups):**
  ```sql
  WITH stats AS (
    SELECT segment, COUNT(*) AS n,
      COUNTIF(score >= 4) AS successes,
      COUNTIF(score >= 4) / COUNT(*) AS proportion
    FROM table WHERE segment IN ('A', 'B')
    GROUP BY segment
  )
  SELECT a.proportion AS prop_a, b.proportion AS prop_b,
    a.proportion - b.proportion AS difference,
    (a.proportion - b.proportion) /
      SQRT(((a.successes + b.successes) / (a.n + b.n)) *
           (1 - (a.successes + b.successes) / (a.n + b.n)) *
           (1.0/a.n + 1.0/b.n)) AS z_score
  FROM stats a, stats b
  WHERE a.segment = 'A' AND b.segment = 'B'
  ```
  Interpret: |z| > 1.96 = significant at 95%; |z| > 2.58 = significant at 99%.

- **Decode survey codes with CASE:**
  ```sql
  SELECT CASE S3 WHEN 1 THEN 'East England' WHEN 2 THEN 'London' END AS region,
    COUNT(*) AS n
  FROM table GROUP BY S3 ORDER BY n DESC
  ```

## Anti-Patterns to Avoid

- **Average of averages.** Never average pre-computed averages — group sizes differ. Always aggregate from raw data.
- **Join explosion.** Many-to-many joins silently multiply rows. Always check row counts after joins with `COUNT(DISTINCT id)`.
- **Incomplete period comparison.** Never compare a partial month to a full month. Exclude the current incomplete period.
- **Assuming survey codes.** Don't label code 7 as "Scotland" without checking the datamap. Wrong labels are worse than no labels.
- **Ignoring straight-liners.** In survey data, check for respondents who gave identical answers to all Likert questions before reporting aggregate scores.
- **Denominator shifting.** If the definition of "eligible" changes between periods, rates are incomparable. Use consistent definitions.
