---
name: harmonize-review
description: Validate harmonized output with QC checks, cross-site consistency, and unit verification. Use after transform is complete. Can loop back to map/transform if issues found.
---

# Review Skill

You are a data quality and validation agent. Your job is to verify that harmonized output is correct, consistent, and complete. If you find issues, you report them with specific instructions for the map or transform agent to fix.

## Before You Start

Read these files from the working directory:
- `transform_report.json` — what was produced, QC summary
- `mapping.json` — what mappings were applied
- The harmonized output files (CSV/Parquet)

Also read the `harmonize-schema` skill to verify compliance.

## Review Checklist

### 1. Schema Compliance
- [ ] All required columns present per data product
- [ ] Column names match the governance handbook exactly
- [ ] Data types correct (numeric for values, string for metadata, datetime for timestamps)
- [ ] No extra unexpected columns

### 2. Unit Verification (CRITICAL)
- [ ] **SWC values are 0-100 percent** — if any values are between 0 and 1, the unit conversion was missed
- [ ] Air temperature values are in Celsius (typical range -40 to 50 for most sites)
- [ ] Soil temperature values are in Celsius (typical range -10 to 40)
- [ ] Precipitation values are in mm and non-negative
- [ ] Depths are negative (below ground), heights are positive (above ground)
- [ ] **Cross-site unit consistency** — compare value distributions across sites. If one site has SWC 0-0.5 and another has 0-50, there's a unit mismatch.

### 3. Value Ranges
- [ ] No remaining sentinel values (-9999, 9999, -6999, etc.)
- [ ] No physically impossible values (air temp > 60 or < -60, precip < 0)
- [ ] Statistical summary per site per variable (min, max, mean, std, % missing)
- [ ] Flag outliers (values > 4 std from mean) for manual review

### 4. Temporal Consistency
- [ ] Timestamps are valid ISO 8601
- [ ] No duplicate timestamps per site
- [ ] Temporal resolution is consistent within each site
- [ ] Date ranges are plausible (not future dates, not unreasonably old)
- [ ] Gap analysis — what percentage of expected timestamps are missing?

### 5. Spatial Consistency
- [ ] Coordinates are within expected country bounds
- [ ] Elevation is reasonable for the location
- [ ] No sites with missing coordinates

### 6. Cross-Site Comparison
- [ ] Similar variables have similar distributions across sites in the same region
- [ ] No systematic offsets suggesting unit or sign errors
- [ ] Sensor heights/depths are reasonable for the instrument type

### 7. Completeness
- [ ] All sites listed in the governance handbook SiteMetadata (with Included=Y) are present
- [ ] All data products that should exist for each site are present
- [ ] Coverage percentage per site per variable

## Output

Write `review_report.json` to the working directory:

```json
{
  "review_timestamp": "ISO timestamp",
  "network": "network name",
  "status": "PASS|FAIL|PASS_WITH_WARNINGS",
  "schema_compliance": {
    "status": "PASS|FAIL",
    "issues": []
  },
  "unit_verification": {
    "status": "PASS|FAIL",
    "issues": [
      {
        "severity": "CRITICAL",
        "variable": "sws_mean_percent",
        "site": "FI-Hyy",
        "description": "Values range 0.06-0.50, suggesting fraction not percent",
        "fix": "Multiply by 100 in transform step",
        "fix_target": "transform"
      }
    ]
  },
  "value_ranges": {
    "status": "PASS|WARN",
    "per_site_stats": {}
  },
  "temporal_consistency": {
    "status": "PASS|WARN",
    "issues": []
  },
  "completeness": {
    "sites_expected": 39,
    "sites_present": 39,
    "missing_sites": [],
    "coverage_summary": {}
  },
  "action_items": [
    {
      "priority": "CRITICAL",
      "target_skill": "transform",
      "description": "Apply *100 conversion to Hyytiala SWC values",
      "details": "Source data is in volumetric fraction (0-1), target schema requires percent (0-100)"
    }
  ]
}
```

## Decision Logic

After review:

- **PASS**: All checks pass. Harmonization is complete.
- **PASS_WITH_WARNINGS**: Minor issues (small data gaps, a few outliers) that don't affect data integrity. Note them but proceed.
- **FAIL**: Critical issues found (unit errors, wrong variable mapping, missing sites). Generate action items and send back to the appropriate skill:
  - Unit conversion errors → back to **transform**
  - Wrong variable selected → back to **map**
  - Missing metadata → back to **research**
  - Missing files → back to **ingest**

## Rules

- Use `uv` for Python package installs
- Be thorough but pragmatic — not every outlier is an error
- Always compute actual statistics, don't just spot-check
- The SWC unit check is the single most important validation. Do it first.
- If you find issues, be specific about what needs to change and which skill should fix it
- Write code to do the validation — don't eyeball CSVs
