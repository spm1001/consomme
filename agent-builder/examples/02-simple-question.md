# Example 2: What Are People Worried About?

**Display name:** Top worries overview
**Description:** User asks a broad question. Agent finds the worry questions using question_stem, compares net worry scores, generates slide.
**Selection strategy:** Always select

---

## Action 1 — User input

```
What are people most worried about?
```

## Action 2 — Agent response

```
I'll find the worry-related questions in the survey. Let me search for them.
```

## Action 3 — Tool use

- **Tool:** BigQuery
- **Action:** executeQuery
- **Tool input:**
```json
{
  "sql": "SELECT DISTINCT question_code, question_text FROM `mit-consomme-test.survey_data.itv_mood_of_the_nation_2026_v1` WHERE question_text LIKE '%worried%' OR question_stem LIKE '%worried%' ORDER BY question_code"
}
```
- **Tool output:**
```json
{
  "columns": ["question_code", "question_text"],
  "rows": [
    {"question_code": "B1", "question_text": "How worried, if at all, are you about the cost of living?"},
    {"question_code": "B2", "question_text": "How worried are you about your personal finances?"},
    {"question_code": "B3", "question_text": "How worried are you about the state of the NHS?"},
    {"question_code": "B4", "question_text": "How worried are you about crime and safety?"}
  ],
  "totalRows": 4,
  "jobId": "job-worry-qs-001"
}
```

## Action 4 — Tool use

- **Tool:** BigQuery
- **Action:** executeQuery
- **Tool input:**
```json
{
  "sql": "SELECT question_code, question_text, pct, base_n FROM `mit-consomme-test.survey_data.itv_mood_of_the_nation_2026_v1` WHERE question_code IN ('B1', 'B2', 'B3', 'B4') AND segment = 'total' AND label = 'Net: Worried' ORDER BY pct DESC"
}
```
- **Tool output:**
```json
{
  "columns": ["question_code", "question_text", "pct", "base_n"],
  "rows": [
    {"question_code": "B1", "question_text": "How worried, if at all, are you about the cost of living?", "pct": 0.62, "base_n": 2249},
    {"question_code": "B2", "question_text": "How worried are you about your personal finances?", "pct": 0.56, "base_n": 2249},
    {"question_code": "B3", "question_text": "How worried are you about the state of the NHS?", "pct": 0.54, "base_n": 2249},
    {"question_code": "B4", "question_text": "How worried are you about crime and safety?", "pct": 0.49, "base_n": 2249}
  ],
  "totalRows": 4,
  "jobId": "job-worry-nets-001"
}
```

## Action 5 — Playbook invocation

- **Playbook:** Validation
- **Playbook state:** OK
- **Preceding conversation summary:** Net worry scores for 4 topics, all from total population (n=2,249). Cost of living 62%, personal finances 56%, NHS 54%, crime 49%. Need to check plausibility.
- **Execution summary:** Validation passed. All base sizes identical (total population). Percentages are plausible — cost of living consistently polls as top concern in UK surveys. No red flags.

## Action 6 — Agent response

```
Cost of living is the top worry by a clear margin. Let me create the slide.
```

## Action 7 — Tool use

- **Tool:** Generate_Slide_Deck
- **Action:** generateSlideDeck
- **Tool input:**
```json
{
  "title": "Cost of Living Remains the UK's Top Worry at 62%",
  "bullets": [
    "Cost of living: 62% worried — the highest of all topics measured",
    "Personal finances: 56% worried — closely linked to cost of living pressure",
    "NHS: 54% worried — over half the population concerned about healthcare",
    "Crime and safety: 49% worried — the lowest of the four but still nearly half the population",
    "Source: ITV Mood of the Nation 2026 (Q.B1-B4), n=2,249 UK adults 18+. 'Net: Worried' combines 'Very worried' and 'Fairly worried'."
  ]
}
```
- **Tool output:**
```json
{
  "message": "Slide deck generated successfully.",
  "url": "https://docs.google.com/presentation/d/2xyz789ghi012/edit",
  "presentationId": "2xyz789ghi012"
}
```

## Action 8 — Agent response

```
Cost of living dominates: 62% of UK adults are worried about it. Personal finances and the NHS follow closely, both above 50%.

View the slide deck: https://docs.google.com/presentation/d/2xyz789ghi012/edit

Would you like to see how these worries differ by generation or social grade?
```

---

**Summary:** Identified 4 worry topics. Cost of living leads at 62%, followed by personal finances (56%), NHS (54%), crime (49%). Generated slide deck with question context.
**Conversation state:** OK
