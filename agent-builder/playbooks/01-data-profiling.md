# Data Profiling — Sub-Playbook

Paste into a new playbook named **"Data Profiling"**.

**Goal:** Identify the data shape and profile the table before any analytical query is written.

---

- Before profiling, detect the data shape by looking at table count, column count, and naming patterns.
  - **Survey data** — Single wide table, many columns, column names are questions or codes (e.g., Q1, S3, satisfaction_score). No FK relationships.
  - **Warehouse data** — Multiple tables with ID columns and foreign key relationships. Star or snowflake schema.
  - **Time series data** — A date/timestamp column drives the analysis. Questions are about trends, forecasts, or anomalies.
- Ask the user to confirm: "This looks like [survey/warehouse/time series] data — is that right?"
- Mixed shapes are common. A warehouse might contain a survey fact table, or time series in a star schema. Match the profiling approach to the user's question, not just the table structure.

## Survey Data Profiling

- Check for a datamap or codebook. Survey data almost always uses numeric codes (e.g., S3=7 means Scotland). Without the datamap, you will misinterpret results.
  - Ask: "Do you have a datamap or codebook for this survey?"
  - Check column descriptions in table metadata — they sometimes contain labels.
  - If no datamap, profile distinct values and show the user before labelling anything.
- Classify columns:
  - **Respondent ID** — unique per row
  - **Demographic/segmentation** — age group, region, department (low cardinality)
  - **Likert/numeric response** — scaled 1-5, 1-7, 1-10
  - **Categorical** — single-select multiple choice
  - **Multi-select** — either comma-separated in one column, or binary 0/1 columns per option
  - **Open-text** — free-form, high cardinality, skip for SQL analysis
- Profile Likert columns:
  - Frequency distribution (count and percentage per score value)
  - Mean, median, mode
  - Check scale consistency — are all questions on the same scale?
  - Watch for off-scale codes: values outside the expected range (e.g., 6="prefer not to say" on a 1-5 scale, 99="don't know"). Exclude these from mean/median calculations.
  - Check for ceiling/floor effects (>50% giving max or min score)
- Profile categorical columns:
  - Frequency table with counts and percentages
  - Look for unexpected categories, typos, or "Other" variants
- For multi-select columns encoded as binary 0/1:
  - SUM each column to get selection count; divide by COUNT(*) for percentage
  - These are the most common encoding for multi-select in survey data
- Check for common Sheets import artefacts:
  - Empty trailing rows (filter with WHERE key_column IS NOT NULL)
  - Mixed types in numeric columns (use SAFE_CAST to find non-numeric values)
  - Inconsistent casing (Yes/yes/YES)
  - Whitespace (use TRIM)

## Survey Quality Assessment

- **Straight-lining**: Respondents giving identical answers to all Likert questions. Check by comparing q1=q2=q3=...=qN. Below 10% is normal, 10-20% warrants a note, above 20% is a red flag.
- **Completion rate**: Check null rates by question position. Later questions often have higher drop-off.
- **Duplicate submissions**: Check for duplicate respondent IDs or identical response patterns across all columns.
- **Low base sizes**: Flag any segment with fewer than 30 respondents as unreliable for comparison.

## Warehouse Data Profiling

- Identify fact tables (many rows, numeric measures, FK columns) vs dimension tables (few rows, descriptive attributes, PK column).
- Check primary key uniqueness on each table.
- Check foreign key integrity: do all FK values in the fact table exist in the dimension table? Count orphan records.
- Profile completeness: what percentage of rows have non-null values for each column? Rate as green (>95%), yellow (80-95%), orange (50-80%), red (<50%).

## Time Series Profiling

- Identify the time grain: what is the interval between rows? (daily, weekly, monthly)
  - Check with MIN/MAX date, COUNT(DISTINCT date), and average rows per date.
- Detect gaps: generate the expected date range and LEFT JOIN to find missing periods.
- Check for the current incomplete period — always exclude it from trend comparisons.
- Look for seasonality patterns in daily or weekly distributions.
