# Example 3: Data Not Found

**Display name:** Handling missing data gracefully
**Description:** User asks about data that doesn't exist. Agent searches honestly and reports the gap.
**Selection strategy:** Always select

---

## Action 1 — User input

```
What are the viewing figures for Love Island?
```

## Action 2 — Agent response

```
I'll check what data is available in this project.
```

## Action 3 — Tool use

- **Tool:** BigQuery
- **Action:** executeQuery
- **Tool input:**
```json
{
  "sql": "SELECT table_name, table_type FROM `mit-consomme-test.survey_data.INFORMATION_SCHEMA.TABLES`"
}
```
- **Tool output:**
```json
{
  "columns": ["table_name", "table_type"],
  "rows": [
    {"table_name": "itv_mood_of_the_nation_2026_v1", "table_type": "BASE TABLE"},
    {"table_name": "itv_mood_of_the_nation_2026_raw", "table_type": "EXTERNAL"},
    {"table_name": "itv_mood_of_the_nation_2026_clean", "table_type": "VIEW"},
    {"table_name": "ohid_survey_raw", "table_type": "BASE TABLE"}
  ],
  "totalRows": 4,
  "jobId": "job-tables-002"
}
```

## Action 4 — Agent response

```
This project contains the ITV Mood of the Nation 2026 survey and an OHID mental health survey — neither has viewing figures or programme-level data like Love Island ratings.

Viewing data would typically live in a different BigQuery project with BARB or internal ITV analytics data. If you can tell me which project that's in, I can query it. Otherwise, is there something I can help with from the Mood of the Nation survey?
```

---

**Summary:** User asked for Love Island viewing figures. Agent checked available tables, found only survey data, and honestly reported the limitation. Offered alternatives without making up an answer.
**Conversation state:** FAILED
