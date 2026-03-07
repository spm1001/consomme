# Example 4: Gender Differences on Cost of Living Worry

**Display name:** Gender breakdown of cost of living worry
**Description:** User asks a follow-up to compare gender differences on the top worry topic.
**Selection strategy:** Always select

---

## Action 1 — User input

```
How does cost of living worry differ between men and women?
```

## Action 2 — Agent response

```
I'll pull the full breakdown of B1 (cost of living worry) by gender, including the component responses not just the net score.
```

## Action 3 — Tool use

- **Tool:** BigQuery
- **Action:** executeQuery
- **Tool input:**
```json
{
  "sql": "SELECT segment_value, label, pct, base_n FROM `mit-consomme-test.survey_data.itv_mood_of_the_nation_2026_v1` WHERE question_code = 'B1' AND segment IN ('total', 'gender') AND NOT is_net ORDER BY segment_value, label_order"
}
```
- **Tool output:**
```json
{
  "columns": ["segment_value", "label", "pct", "base_n"],
  "rows": [
    {"segment_value": "Female", "label": "Very worried", "pct": 0.28, "base_n": 1152},
    {"segment_value": "Female", "label": "Fairly worried", "pct": 0.38, "base_n": 1152},
    {"segment_value": "Female", "label": "Not very worried", "pct": 0.22, "base_n": 1152},
    {"segment_value": "Female", "label": "Not at all worried", "pct": 0.08, "base_n": 1152},
    {"segment_value": "Female", "label": "Don't know", "pct": 0.04, "base_n": 1152},
    {"segment_value": "Male", "label": "Very worried", "pct": 0.20, "base_n": 1097},
    {"segment_value": "Male", "label": "Fairly worried", "pct": 0.34, "base_n": 1097},
    {"segment_value": "Male", "label": "Not very worried", "pct": 0.29, "base_n": 1097},
    {"segment_value": "Male", "label": "Not at all worried", "pct": 0.13, "base_n": 1097},
    {"segment_value": "Male", "label": "Don't know", "pct": 0.04, "base_n": 1097},
    {"segment_value": "Total", "label": "Very worried", "pct": 0.24, "base_n": 2249},
    {"segment_value": "Total", "label": "Fairly worried", "pct": 0.36, "base_n": 2249},
    {"segment_value": "Total", "label": "Not very worried", "pct": 0.26, "base_n": 2249},
    {"segment_value": "Total", "label": "Not at all worried", "pct": 0.10, "base_n": 2249},
    {"segment_value": "Total", "label": "Don't know", "pct": 0.04, "base_n": 2249}
  ],
  "totalRows": 15,
  "jobId": "job-gender-worry-001"
}
```

## Action 4 — Playbook invocation

- **Playbook:** Validation
- **Playbook state:** OK
- **Preceding conversation summary:** Cost of living worry (B1) by gender. Female n=1,152, Male n=1,097 — both large bases. Women show higher "Very worried" (28% vs 20%). Need to check percentages sum correctly.
- **Execution summary:** Validation passed. Percentages sum to ~100% for each segment (rounding). Gender base sizes are adequate. The 8pp gap on "Very worried" is the key finding.

## Action 5 — Agent response

```
Women are notably more worried about the cost of living. The "Very worried" category is 28% for women vs 20% for men — an 8 percentage point gap. Let me generate the slide.
```

## Action 6 — Tool use

- **Tool:** Generate_Slide_Deck
- **Action:** generateSlideDeck
- **Tool input:**
```json
{
  "title": "Women Are Significantly More Worried About the Cost of Living Than Men",
  "bullets": [
    "28% of women are 'Very worried' about cost of living vs 20% of men (+8 percentage points)",
    "Net worry (Very + Fairly worried): women 66% vs men 54% — a 12pp gender gap",
    "Men are more likely to say 'Not very worried' (29% vs 22%) or 'Not at all worried' (13% vs 8%)",
    "Both genders have large base sizes (women n=1,152, men n=1,097) — differences are robust",
    "Source: ITV Mood of the Nation 2026 (Q.B1), n=2,249 UK adults 18+."
  ]
}
```
- **Tool output:**
```json
{
  "message": "Slide deck generated successfully.",
  "url": "https://docs.google.com/presentation/d/3pqr456stu789/edit",
  "presentationId": "3pqr456stu789"
}
```

## Action 7 — Agent response

```
Women are carrying more financial anxiety — two-thirds (66%) are worried about the cost of living compared to just over half (54%) of men. The gap is strongest at the "Very worried" end.

View the slide deck: https://docs.google.com/presentation/d/3pqr456stu789/edit

Would you like to see this by generation as well, or look at a different worry topic?
```

---

**Summary:** Compared cost of living worry by gender. Women are 12pp more worried overall (66% vs 54%), with the sharpest gap at "Very worried" (28% vs 20%). Generated slide deck.
**Conversation state:** OK
