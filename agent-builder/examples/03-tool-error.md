# Example 3: Tool Error Handling

**Display name:** Handling query errors gracefully
**Description:** User asks about a non-existent table. Agent handles the error without hallucinating.
**Selection strategy:** Always select

---

## Action 1 — User input

```
What are the viewing figures for Q4?
```

## Action 2 — Agent response

```
I'll look for viewing data in the project. Let me check what tables are available.
```

## Action 3 — Tool use

- **Tool:** BigQuery
- **Action:** execute_sql
- **Tool input:**
```json
{
  "sql": "SELECT table_name FROM `mit-consomme-test.survey_data.INFORMATION_SCHEMA.TABLES`",
  "project": "mit-consomme-test"
}
```
- **Tool output:**
```json
{
  "rows": [
    {"table_name": "ohid_survey_raw"}
  ],
  "total_rows": 1
}
```

## Action 4 — Agent response

```
The only table available in this project is `ohid_survey_raw`, which is the OHID mental health survey — it doesn't contain viewing figures. I don't have access to viewing data in this project.

If the viewing data lives in a different BigQuery project, let me know the project and dataset name and I can look there. Otherwise, is there something I can help you explore in the mental health survey data?
```

---

**Summary:** User requested viewing data that doesn't exist in the project. Agent searched available tables, found only survey data, and honestly reported the limitation without making up an answer. Offered alternatives.
**Conversation state:** OK
