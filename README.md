# Baseline/Endline Survey Cleaning & Analysis (Stata)

**Author:** Gunjan Sharma
**Date:** Feb 18, 2026

## Overview

This project cleans and analyzes a **baseline/endline survey dataset** (20-item questionnaire administered to the same participants at two time points), written as a modular Stata pipeline. It merges administrative, baseline, and endline data; cleans and labels variables; computes demographic and outcome measures; and produces summary tables and visualizations comparing scores over time.

## Data

Input is a single Excel workbook (not included in this repository — see `.gitignore`):

- `Stata Exercise Data.xlsx`, containing four sheets:
  - **administrative** — participant IDs
  - **baseline** — baseline survey responses (`q_1`–`q_20`) plus timestamp, gender, date of birth
  - **endline** — endline survey responses (`question__1`–`question__20`) plus timestamp
  - **variable labels** — question text/labels to attach to each `q_#` variable

## Pipeline Structure

All scripts live in `do/` and are run in order by `do/master.do`:

| Script | Purpose |
|---|---|
| `master.do` | Sets global paths and runs the full pipeline end-to-end, with logging. |
| `1_merge.do` | Imports the administrative, baseline, and endline sheets; cleans IDs and timestamps; renames question variables with `bl_`/`el_` prefixes; merges all three 1:1 on participant ID into `master_wide.dta`. |
| `2_variable_labels.do` | Reads the "variable labels" sheet and programmatically generates and applies `label variable` commands to both baseline and endline question variables. |
| `3_clean.do` | Cleans `gender` (standardizes text, encodes numeric), parses `dob` to a proper date, checks response ranges (1–5) and missingness on all 40 question items, and computes the baseline-to-endline time gap. |
| `4_demographic.do` | Computes participant age in months at baseline and endline (and the difference between them) from date of birth and survey timestamps. |
| `5_score_streak.do` | For each participant, computes the **longest run of non-decreasing consecutive question scores** at baseline and endline (a custom streak-detection algorithm). |
| `6_pct_per_question.do` | For each of the 20 questions, computes the **percent of participants who improved** (endline score > baseline score) and exports the results. |
| `7_visualization.do` | *(exploratory, not part of the core task)* Produces box plots, scatter plots, histograms, and bar charts comparing baseline vs. endline mean scores overall, by gender, and by age group, plus summary tables. |

## Key Outputs

Running the pipeline produces (in `clean/` and `output/`, both git-ignored):

- `master_analysis_ready.dta` — final analysis dataset with demographics, streak measures, and improvement indicators
- `score_streaks.xlsx` — longest non-decreasing score streak per participant, baseline and endline
- `pct_improved_per_question.xlsx` — percent of participants improving on each of the 20 questions
- `fig1`–`fig6` PNGs and `table_age_group_means.xlsx` — visualizations and summary table of scores by gender/age group
- `master_run.log` — full run log from `master.do`

## Setup

1. Clone this repository.
2. Place `Stata Exercise Data.xlsx` in a `data/` folder (create it if needed).
3. Open `do/master.do` and update the `global PROJ` path at the top to point to your local project folder (it currently points to the original author's machine).
4. Run `do/master.do` in Stata (version 19+). It will automatically create `clean/`, `output/`, and `logs/` folders and run all seven scripts in sequence.

> Each numbered script also has a "standalone" guard, so any individual step can be run on its own (it falls back to a default `PROJ` path if the global isn't already set from `master.do`).

## Repository Structure

```
.
├── do/
│   ├── master.do              # Orchestrates the full pipeline
│   ├── 1_merge.do
│   ├── 2_variable_labels.do
│   ├── 3_clean.do
│   ├── 4_demographic.do
│   ├── 5_score_streak.do
│   ├── 6_pct_per_question.do
│   └── 7_visualization.do
├── README.md
└── .gitignore                  # Excludes raw data, generated datasets, logs, and figures
```

## Requirements

- Stata (version 19 or later)
