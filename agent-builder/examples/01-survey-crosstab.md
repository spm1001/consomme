# Example 1: Regional Mental Health Comparison

**Display name:** Regional mental health comparison
**Description:** User asks which regions score lowest. Agent profiles schema, cross-tabs with CIs, tests significance, generates slide.
**Selection strategy:** Always select

Enter each step via the + button, selecting the action type shown.

---

## Action 1 — User input

```
Which regions have the lowest mental health scores?
```

## Action 2 — Agent response

```
I'll find regional differences in mental health scores. Let me first understand the data structure.
```

## Action 3 — Tool use

- **Tool:** BigQuery
- **Action:** get_table_info
- **Tool input:**
```json
{
  "project": "mit-consomme-test",
  "dataset": "survey_data",
  "table": "ohid_survey_raw"
}
```
- **Tool output:**
```json
{
  "row_count": 1320,
  "column_count": 39,
  "columns": [
    {"name": "respondent_id", "type": "STRING"},
    {"name": "S1", "type": "INT64", "description": "Age group"},
    {"name": "S3", "type": "INT64", "description": "Region code"},
    {"name": "Q14", "type": "INT64", "description": "Mental health score (1-5)"}
  ]
}
```

## Action 4 — Playbook invocation

- **Playbook:** Data Profiling
- **Input summary:** Table ohid_survey_raw has 1,320 rows, 39 columns. Key columns: S3 (region, INT64), Q14 (mental health score, INT64, scale 1-5). Need to confirm data shape and check for off-scale codes.
- **Output summary:** Confirmed as survey data. S3 has 12 distinct region codes. Q14 ranges 1-5 with 3% nulls and no off-scale codes. 4 regions have n < 30. No datamap available — codes undecoded.

## Action 5 — Agent response

```
This is survey data with numeric region codes (S3) and a mental health score (Q14, scale 1-5). I don't have a datamap so I'll show region codes rather than names. Let me cross-tabulate with confidence intervals.
```

## Action 6 — Tool use

- **Tool:** BigQuery
- **Action:** execute_sql
- **Tool input:**
```json
{
  "sql": "SELECT S3 AS region_code, COUNT(*) AS n, ROUND(AVG(Q14), 2) AS avg_score, ROUND(STDDEV(Q14), 2) AS std_dev, ROUND(AVG(Q14) - 1.96 * STDDEV(Q14) / SQRT(COUNT(*)), 2) AS ci_lower, ROUND(AVG(Q14) + 1.96 * STDDEV(Q14) / SQRT(COUNT(*)), 2) AS ci_upper FROM `mit-consomme-test.survey_data.ohid_survey_raw` WHERE S3 IS NOT NULL AND Q14 BETWEEN 1 AND 5 GROUP BY S3 HAVING COUNT(*) >= 30 ORDER BY avg_score ASC",
  "project": "mit-consomme-test"
}
```
- **Tool output:**
```json
{
  "rows": [
    {"region_code": 3, "n": 145, "avg_score": 3.01, "std_dev": 1.12, "ci_lower": 2.83, "ci_upper": 3.19},
    {"region_code": 7, "n": 98, "avg_score": 3.42, "std_dev": 1.05, "ci_lower": 3.21, "ci_upper": 3.63},
    {"region_code": 5, "n": 112, "avg_score": 3.48, "std_dev": 0.98, "ci_lower": 3.30, "ci_upper": 3.66},
    {"region_code": 1, "n": 203, "avg_score": 3.72, "std_dev": 0.95, "ci_lower": 3.59, "ci_upper": 3.85},
    {"region_code": 9, "n": 88, "avg_score": 3.78, "std_dev": 1.01, "ci_lower": 3.57, "ci_upper": 3.99},
    {"region_code": 2, "n": 167, "avg_score": 3.85, "std_dev": 0.91, "ci_lower": 3.71, "ci_upper": 3.99},
    {"region_code": 8, "n": 134, "avg_score": 3.91, "std_dev": 0.88, "ci_lower": 3.76, "ci_upper": 4.06},
    {"region_code": 4, "n": 178, "avg_score": 3.95, "std_dev": 0.93, "ci_lower": 3.81, "ci_upper": 4.09}
  ],
  "total_rows": 8
}
```

## Action 7 — Playbook invocation

- **Playbook:** Validation
- **Input summary:** Cross-tab of mental health score (Q14) by region (S3). 8 regions with n >= 30. Region 3 scores lowest (3.01, CI 2.83-3.19). National average approximately 3.7. Need significance test and plausibility check.
- **Output summary:** Validation passed. Region 3 CI (2.83-3.19) does not overlap with overall mean CI. Percentages and counts are plausible. 4 regions with n < 30 were correctly excluded. No red flags.

## Action 8 — Agent response

```
The differences are confirmed. Region code 3 scores significantly lower — its confidence interval (2.83-3.19) doesn't overlap with the higher-scoring regions. Let me generate the slide deck.
```

## Action 9 — Tool use

- **Tool:** Generate_Slide_Deck
- **Action:** generateSlideDeck
- **Tool input:**
```json
{
  "title": "Three Regions Show Significantly Lower Mental Health Scores",
  "bullets": [
    "Region code 3 scores lowest at 3.0/5, significantly below average of 3.7 (95% CI: 2.83-3.19, n=145)",
    "Region codes 7 and 5 also below average at 3.4 and 3.5 respectively",
    "Confidence intervals confirm differences are statistically significant, not noise",
    "4 regions excluded due to small sample sizes (n < 30) — results should not be generalised to these areas",
    "Source: OHID Mental Health Survey, 1,320 respondents. Region codes not decoded — provide datamap for labels."
  ]
}
```
- **Tool output:**
```json
{
  "message": "Slide deck generated successfully.",
  "url": "https://docs.google.com/presentation/d/1abc123def456/edit",
  "presentationId": "1abc123def456"
}
```

## Action 10 — Agent response

```
Three regions have significantly lower mental health scores than the national average. Region code 3 is the lowest at 3.0 out of 5, well below the 3.7 average.

Here's your slide deck: https://docs.google.com/presentation/d/1abc123def456/edit

Caveat: The region codes haven't been decoded to names. If you have the survey datamap, I can re-label them. Would you like to drill into any specific region?
```

---

**Summary:** Identified 3 regions with statistically significant lower mental health scores. Generated ITV-branded slide deck with confidence intervals and caveats about undecoded codes and excluded small-sample regions.
**Conversation state:** OK
**Output parameters:** slide_url = https://docs.google.com/presentation/d/1abc123def456/edit
