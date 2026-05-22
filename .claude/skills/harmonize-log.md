---
name: harmonize-log
description: Track all harmonization runs, decisions, metrics, and provenance for the paper. Every other harmonize skill MUST call this to log its work.
---

# Experiment Logging Skill

You are a scientific record-keeping agent. Every harmonization run must be documented for reproducibility and for the paper. You maintain a structured experiment log that maps directly to paper sections.

## Log Directory

All logs go in `experiment_logs/` in the project root. Create it if it doesn't exist.

```
experiment_logs/
├── runs/
│   └── {network}_{timestamp}/        # One dir per harmonization run
│       ├── run_metadata.json          # Run config, timing, model used
│       ├── ingest_catalog.json        # Copy from pipeline
│       ├── research_report.json       # Copy from pipeline
│       ├── mapping.json               # Copy from pipeline
│       ├── transform_report.json      # Copy from pipeline
│       ├── review_report.json         # Copy from pipeline
│       ├── validation_results.json    # Comparison vs ground truth
│       └── decisions.md               # Human-readable decision log
├── metrics/
│   └── accuracy_summary.csv           # Cross-run accuracy metrics
├── paper/
│   ├── methods_notes.md               # Notes for Methods section
│   ├── results_tables.md              # Pre-formatted tables for paper
│   └── figures_data/                  # Data for generating figures
└── master_log.csv                     # One row per run, summary metrics
```

## What Gets Logged

### 1. Run Metadata (`run_metadata.json`)

```json
{
  "run_id": "icos_20260317_143022",
  "network": "ICOS",
  "timestamp_start": "2026-03-17T14:30:22Z",
  "timestamp_end": "2026-03-17T14:45:11Z",
  "duration_seconds": 889,
  "model": "claude-opus-4-6",
  "skills_used": ["harmonize-ingest", "harmonize-research", "harmonize-map", "harmonize-transform", "harmonize-review"],
  "sites_processed": ["BE-Bra", "BE-Lon", "..."],
  "data_products": ["air_temperature", "precipitation", "soil_moisture", "soil_temperature"],
  "input_files": 42,
  "input_formats": ["csv", "parquet"],
  "total_input_rows": 3420000,
  "total_output_rows": 3420000,
  "human_intervention": false,
  "human_intervention_details": null,
  "notes": "First full ICOS run with all 39 sites"
}
```

### 2. Decision Log (`decisions.md`)

Human-readable record of every non-trivial decision the agent made. This feeds the paper's Methods section.

```markdown
# Decision Log: ICOS Run 2026-03-17

## Variable Selection Decisions
- **Air Temperature**: Selected `TA` (aggregated) over `TA_1` through `TA_10` (profile sensors).
  Rationale: TA is the primary/representative above-canopy measurement.
  Confidence: HIGH

- **Soil Water Content**: Selected `SWC_1` (shallowest sensor, -0.05m).
  Rationale: AccelNet schema specifies single depth; _1 is shallowest per ICOS ETC convention.
  Confidence: MEDIUM — depth assignment based on ICOS Class 1 standard, not site-specific BADM.

## Unit Conversion Decisions
- No conversions needed — ICOS uses degC, mm, % which match AccelNet targets.

## Sensor Height Decisions
- Heights sourced from BE-Bra labelling report (PDF).
  Air temp: 32.2m, Precip: 2.5m, SWC_1: -0.05m, TS_1: -0.015m
- For sites without labelling reports, used ICOS Class 1 standard depths.

## QC Decisions
- Replaced -9999 sentinel values with NaN (15,646 rows for BE-Bra pre-2020-10-25)
- No additional QC removals — all values within physical bounds.

## Temporal Decisions
- Preserved native 30-min resolution. No aggregation applied.
- Timestamps parsed from YYYYMMDDHHmm integer format to ISO 8601.
```

### 3. Validation Results (`validation_results.json`)

```json
{
  "validation_timestamp": "2026-03-17T15:00:00Z",
  "network": "ICOS",
  "ground_truth_source": "Manually harmonized data (2+ years of work)",
  "results_by_site": {
    "BE-Bra": {
      "air_temperature": {
        "n_compared": 72050,
        "correlation": 1.000000,
        "mae": 0.000000,
        "rmse": 0.000000,
        "max_abs_diff": 0.000000,
        "exact_match_pct": 100.0,
        "timestamp_alignment": "perfect",
        "unit_correct": true
      }
    }
  },
  "aggregate_metrics": {
    "overall_correlation": 1.000000,
    "overall_mae": 0.000000,
    "overall_exact_match_pct": 100.0,
    "variables_tested": 4,
    "sites_tested": 1,
    "total_values_compared": 284155
  }
}
```

### 4. Master Log (`master_log.csv`)

One row per run. Append, never overwrite.

```csv
run_id,network,date,duration_sec,sites,products,total_rows,correlation,mae,exact_match_pct,human_intervention,review_status,notes
icos_20260317,ICOS,2026-03-17,889,1,4,87696,1.000,0.000,100.0,false,PASS,BE-Bra only
saeon_20260317,SAEON,2026-03-17,529,8,4,157285,1.000,0.000,100.0,false,PASS_WITH_WARNINGS,30min timestamp offset
elter_20260317,eLTER,2026-03-17,882,15,4,67066,1.000,0.000,100.0,false,FAIL,SWC unit bug found
```

### 5. Paper Assets

#### `methods_notes.md`
After each run, append observations relevant to the Methods section:
- What the agent could figure out autonomously vs what required human input
- What metadata sources were most useful
- Where the agent struggled (format diversity, unit ambiguity, missing metadata)
- Processing time breakdown per skill

#### `results_tables.md`
Pre-formatted tables ready for the paper:

```markdown
## Table 1: Harmonization Accuracy by Network and Variable

| Network | Variable | N Compared | Correlation | MAE | Exact Match % |
|---------|----------|-----------|-------------|-----|---------------|
| ICOS    | Air Temp | 72,050    | 1.000       | 0.000 | 100.0       |
| ICOS    | Precip   | 67,864    | 1.000       | 0.000 | 100.0       |
| ...     | ...      | ...       | ...         | ...   | ...         |

## Table 2: Processing Time Comparison

| Network | Sites | Manual (person-months) | AI (minutes) | Speedup |
|---------|-------|----------------------|--------------|---------|
| ICOS    | 39    | ~6 months            | ~15 min      | ~17,000x |
| ...     | ...   | ...                  | ...          | ...     |

## Table 3: Error Analysis

| Error Type | Network | Frequency | Severity | Auto-detected by Review? |
|-----------|---------|-----------|----------|-------------------------|
| SWC unit (fraction vs %) | eLTER | 1 site | CRITICAL | YES |
| Timestamp convention | SAEON | all sites | LOW | YES |
| ...       | ...     | ...       | ...      | ...                     |
```

#### `figures_data/`
Save data needed to generate paper figures:
- `accuracy_by_network.csv` — for bar chart of accuracy per network
- `processing_time.csv` — for manual vs AI comparison
- `error_types.csv` — for error analysis breakdown
- `coverage_matrix.csv` — sites x variables heatmap of data availability

## When to Log

**Every harmonize skill should log its work.** At minimum:
- **Ingest**: Log files discovered, formats detected, challenges noted
- **Research**: Log sources consulted, metadata found, gaps remaining
- **Map**: Log every mapping decision with rationale and confidence
- **Transform**: Log timing, row counts, QC removals
- **Review**: Log all check results, issues found, action items

## Rules

- NEVER delete or overwrite existing logs. Append only.
- Use ISO 8601 timestamps everywhere.
- Record the model used (claude-opus-4-6, etc.) for reproducibility.
- If human intervention was needed, document exactly what and why.
- Keep decision logs in plain English — they'll be paraphrased for the paper.
- The master_log.csv should be parseable by pandas for quick analysis.
