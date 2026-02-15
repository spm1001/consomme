# OHID Survey Datamap

Source: Google Sheet "OHID Survey Raw Data", second tab ("Datamap").
Dataset: `mit-consomme-test.survey_data.ohid_survey_raw`

## Screening / Demographics

| Column | Question | Values |
|--------|----------|--------|
| `record` | Record number | Open numeric |
| `uuid` | Participant identifier | Open text |
| `date` | Completion time and date | Timestamp |
| `status` | Participant status | 1=Terminated, 2=Overquota, 3=Qualified, 4=Partial |
| `S0` | Consent agreement | 1=Agree, 2=Disagree |
| `S1` | What is your age? | 1=Less than 18, 2=18-24, 3=25-34, 4=35-44, 5=45-54, 6=55-64, 7=Over 65 |
| `S2` | What is your gender? | 1=Male, 2=Female, 3=Other gender identity, 4=Prefer not to say |
| `S3` | In which region do you live? | 1=East of England, 2=London, 3=Midlands, 4=North East Yorkshire & The Humber, 5=North West, 6=Northern Ireland, 7=Scotland, 8=South East, 9=South West, 10=Wales |

## Q1: Actions taken for wellbeing (multi-select, binary 0/1)

"Which of the following actions have you taken to protect your mental health and wellbeing in the last couple of weeks?"

| Column | Label |
|--------|-------|
| `Q1r1` | Done physical activity (e.g. gone for a walk etc.) |
| `Q1r2` | Talked to someone I trust |
| `Q1r3` | Prioritised getting enough sleep |
| `Q1r4` | Spent time in nature |
| `Q1r5` | Planned something nice to look forward to |
| `Q1r6` | Downloaded or used a mental health or wellbeing app |
| `Q1r7` | Used a website to answer a specific query on mental health or wellbeing |
| `Q1r8` | Used a website for general information on mental health or wellbeing |
| `Q1r9` | Subscribed to or read an email newsletter on mental health or wellbeing |
| `Q1r10` | Other |
| `Q1r11` | Prefer not to say |
| `Q1r12` | None of the above |

## Q2: Attitude statements (Likert 1-5 + 6=Prefer not to say)

"How strongly do you agree or disagree with the following statements?"

Values: 1=Strongly disagree, 2=Somewhat disagree, 3=Neither agree nor disagree, 4=Somewhat agree, 5=Strongly agree, 6=Prefer not to say

| Column | Statement |
|--------|-----------|
| `Q2r1` | I can imagine myself taking action to protect my mental health and wellbeing |
| `Q2r2` | Wellbeing and better mental health support is relevant to me |
| `Q2r3` | I believe there are effective actions that people can use to take care of their mental health |
| `Q2r4` | I believe I can take action to protect my mental health and wellbeing |
| `Q2r5` | Taking action to protect my own mental health and wellbeing is likely to have a positive impact |

## Q3: Brand awareness (multi-select, binary 0/1)

"Before today, which of the following have you heard of?"

| Column | Brand |
|--------|-------|
| `Q3r1` | NHS Every Mind Matters - Find Your Little Big Thing |
| `Q3r2` | Catch It - Mood Diary App |
| `Q3r3` | CALM - Campaign Against Living Miserably |
| `Q3r4` | Headspace App - Meditation and Sleep Made Simple |
| `Q3r5` | Change4Life |
| `Q3r6` | None of the above |

## Q4: Brand consideration (single-select 1-6)

"The next time you are looking for wellbeing and better mental health support, which of the following are you most likely to consider?"

| Value | Brand |
|-------|-------|
| 1 | NHS Every Mind Matters - Find Your Little Big Thing |
| 2 | Catch It - Mood Diary App |
| 3 | CALM - Campaign Against Living Miserably |
| 4 | Headspace App - Meditation and Sleep Made Simple |
| 5 | Change4Life |
| 6 | None of the above |

## Q5: Ad recall (multi-select, binary 0/1)

"Which of the following have you seen advertised in the past few weeks?"

| Column | Brand |
|--------|-------|
| `Q5r1` | NHS Every Mind Matters - Find Your Little Big Thing |
| `Q5r2` | Catch It - Mood Diary App |
| `Q5r3` | CALM - Campaign Against Living Miserably |
| `Q5r4` | Headspace App - Meditation and Sleep Made Simple |
| `Q5r5` | Change4Life |
| `Q5r6` | None of the above |

## Other

| Column | Description | Notes |
|--------|-------------|-------|
| `qtime` | Total interview time (seconds) | Has placeholder value 999999; outlier detection found 136 values outside IQR bounds |
| `RID` | Respondent ID | UUID format, unique per respondent |
