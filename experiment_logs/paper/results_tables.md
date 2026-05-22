# Results Tables (Draft)

## Table 1: Feasibility Test — Harmonization Accuracy by Network and Variable

| Network | Sites | Variable | N Compared | Correlation | MAE | Exact Match % |
|---------|-------|----------|-----------|-------------|-----|---------------|
| ICOS | 1 (BE-Bra) | Air Temperature | 72,050 | 1.000000 | 0.000 | 100.0 |
| ICOS | 1 (BE-Bra) | Precipitation | 67,864 | 1.000000 | 0.000 | 100.0 |
| ICOS | 1 (BE-Bra) | Soil Water Content | 72,191 | 1.000000 | 0.000 | 100.0 |
| ICOS | 1 (BE-Bra) | Soil Temperature | 72,191 | 1.000000 | 0.000 | 100.0 |
| SAEON | 8 | Air Temperature | 148,370 | 1.000000 | 0.000 | 100.0 |
| SAEON | 8 | Precipitation | 148,835 | 1.000000 | 0.000 | 100.0 |
| SAEON | 8 | Soil Water Content | 147,599 | 1.000000 | 0.000 | 100.0 |
| SAEON | 8 | Soil Temperature | 145,366 | 1.000000 | 0.000 | 100.0 |
| eLTER | 1 (Hohes Holz) | Air Temperature | 3,778 | 1.000000 | 0.000 | 100.0 |
| eLTER | 1 (Hohes Holz) | Precipitation | 3,905 | 0.999952 | 0.001 | 100.0 |

## Table 2: Discrepancies Found

| Network | Issue | Severity | Type | Detected by Review? |
|---------|-------|----------|------|---------------------|
| eLTER | SWC units: fraction (0-1) vs percent (0-100) at Hyytiala | CRITICAL | Unit conversion | YES (cross-site comparison) |
| eLTER | Duplicate site: Hohes Holz appears twice with different sensors | MEDIUM | Sensor selection | YES |
| eLTER | Sensor height inconsistency across Donana sub-stations | LOW | Metadata quality | YES |
| SAEON | 30-min timestamp offset (period-beginning vs period-ending) | MEDIUM | Convention | YES |
| SAEON | 8,915 extra NaN rows for data gaps | LOW | Design choice | n/a |
| ICOS | 15,646 padding rows before data collection start | LOW | Design choice | n/a |
| ICOS | Sensor heights left as NaN (fixed in research pass) | MEDIUM | Missing metadata | YES |

## Table 3: Format Diversity

| Network | Formats Encountered | Formats Successfully Processed |
|---------|--------------------|-----------------------------|
| ICOS | CSV | CSV |
| SAEON | CSV | CSV |
| eLTER | Parquet, CSV (comma + semicolon), Excel, Word, PDF, ZIP | Parquet, CSV, Excel, Word |
| TERN | NetCDF (L3 primary, L6 fallback) | NetCDF |
| NEON | Parquet, CSV | Parquet, CSV |

## Table 4: TERN Blind Test — Validation Against Answer Keys

| Check | Status | Accuracy | Details |
|-------|--------|----------|---------|
| Variable selection | PASS | 100% | Ta and Precip (merged best-estimate) correctly chosen over sensor-specific variants |
| Date ranges | PASS | 100% | All 5 overlap sites matched answer key to the minute |
| Data coverage | PASS | 100% | Coverage within 1-2% of answer key values |
| Value accuracy | PASS | 100% | Spot-checked values match raw NetCDF source exactly |
| Sensor heights | PASS_WITH_WARNINGS | 80% | 4/5 sites matched (AU-Wom has placeholder metadata in source NetCDF) |
| Instrument names | PASS_WITH_WARNINGS | 80% | 4/5 sites matched (AU-Wom source quality issue) |

**Validated sites (overlap with answer key)**: AU-Boy, AU-Cum, AU-TTE, AU-Tum, AU-Wom (5/10 agent sites)
**Agent-only sites**: AU-Cpr, AU-DaS, AU-Dry, AU-Gin, AU-Whr
**Answer-key-only sites**: Ridgefield (AU-Rgf), RobsonCreek (AU-Rob), Warra (AU-War)

## Table 5: Processing Time (Feasibility Tests)

| Network | Sites | Agent Duration (sec) | Notes |
|---------|-------|---------------------|-------|
| ICOS (BE-Bra) | 1 | 324 | Local files only |
| ICOS (research) | 1 | 382 | Web research for sensor metadata |
| SAEON | 8 | 529 | All flux tower sites |
| eLTER | 15 stations | 882 | Most complex — 4 countries, mixed formats |
| TERN (blind test) | 10 | 801 | First NetCDF format; 5 sites validated against answer keys |
| ICOS (all 39) | 39 | 947 | Full-scale: 5 data products, 9.6M rows |
| NEON (blind test) | 47 | 731 | Unseen network: 5 products, SWC conversion detected |

## Table 6: ICOS All-39-Sites Blind Test

| Data Product | Sites | Rows | Value Range | Validation |
|-------------|-------|------|-------------|------------|
| Air Temperature | 39 | 2,444,325 | [-50.0, 48.1] degC | PASS - values match raw CSV |
| Precipitation | 39 | 2,335,582 | [0, 115.62] mm | PASS - no negatives |
| Soil Moisture | 39 | 2,422,153 | [0, 99.97] % | PASS - confirmed percent not fraction |
| Soil Temperature | 39 | 2,424,843 | [-20.2, 39.0] degC | PASS |
| Soil Texture | 6 | 28 | sand+clay+silt=100% | PASS |

## Table 7: NEON Blind Test — Unseen Network

| Data Product | Sites | Rows | Value Range | Validation |
|-------------|-------|------|-------------|------------|
| Air Temperature | 47 | 5,430,052 | reasonable degC | PASS - schema correct, values plausible |
| Precipitation | 4 | 308,694 | [0, 48.91] mm | PASS - matches raw precipBulk |
| Soil Moisture | 1 | 1,709,144 | [0, 58.32] % | PASS - fraction→percent conversion detected |
| Soil Temperature | 1 | 3,727,824 | [-0.77, 34.47] degC | PASS |
| Soil Texture | 47 | 346 | sand+clay+silt=100% | PASS - two sources combined |

**Critical test:** Agent autonomously detected VSWCMean was in fraction (0-1) and converted to percent (0-100).
**Site coverage note:** Raw input files only contained 1-4 sites for soil/precip products (data subset limitation, not agent error). Answer keys show 46-47 sites per product.

## Table 8: Ontology Derivation Experiment — Agent vs Human Schema

**Setup**: Agent team (5 profilers + 1 reviewer + lead) given ONLY raw data from 5 networks. No access to Governance Handbook, Term Mapping Template, existing schema, or any harmonized outputs. Must independently derive a unified ontology and trace all decisions.

**Team composition**: 5 Haiku profilers (one per network, parallel), 1 Opus reviewer, 1 Opus lead. Iterative research→present→review loop.

### Core Variable Identification

| Human Schema Product | Agent Derived? | Agent Canonical Name | Tier | Confidence |
|---------------------|----------------|---------------------|------|------------|
| Air Temperature | YES | `air_temperature` | 1 (5/5) | 0.85 |
| Precipitation | YES | `precipitation` | 1 (5/5) | 0.85 |
| Soil Moisture | YES | `soil_water_content` | 1 (5/5) | 0.85 |
| Soil Temperature | YES | `soil_temperature` | 1 (5/5) | 0.85 |
| Soil Texture | YES | `soil_texture_sand/clay/silt` | 2 (3/5) | 0.85 |

**Result**: 5/5 core data products independently identified.

### Key Design Divergences

| Aspect | Agent Derived | Human Schema | Assessment |
|--------|--------------|--------------|------------|
| SWC units | Fraction m3/m3 (0-1) | Percent (0-100) | Agent cited CF conventions + NEON/TERN majority. Human chose interpretability. Both defensible. |
| Depth convention | Positive cm below surface | Negative meters below surface | Agent more intuitive for soil science. Human uses signed SI units. |
| Schema layout | Single wide table + companion tables | 5 separate tables per data product | Human includes per-row metadata (instrument, height). |
| Naming convention | snake_case (`air_temperature`) | camelCase (`airTemp_mean_degC`) | Agent aligned with CF/Python. Human aligned with project convention. |
| Column names | Unit-free | Unit-embedded (e.g., `_degC`) | Stylistic. |
| Missing data | NaN | NaN | MATCH |
| Temporal resolution | 30-min UTC ISO 8601 | 30-min UTC ISO 8601 | MATCH |

### Cross-Network Variable Mapping Accuracy

| Network | Variables Mapped | Raw Names Correct? | Units Correct? | Conversion Correct? |
|---------|----------------|--------------------|----------------|---------------------|
| ICOS | 14 | YES | YES | YES (SWC /100, -9999→NaN) |
| SAEON | 13 | YES | YES | YES (SWC /100, VPD /10) |
| eLTER | 11 (4 countries) | YES | YES | YES (SWC /100, depth abs()) |
| TERN | 12 | YES | YES | YES (native fraction kept) |
| NEON | 6 | YES | YES | YES (native fraction kept) |

### Decision Quality

| Metric | Value |
|--------|-------|
| Total decisions documented | 12 |
| Decisions with evidence from all 5 networks | 12/12 |
| Decisions with alternatives considered | 12/12 |
| Mean confidence score | 0.89 |
| Review rounds | 2 (Draft 1 → REVISE → Draft 2 → ACCEPT) |
| Critical issues found by reviewer | 8 (all fixed in Draft 2) |

### Integrity Verification (No Cheating)

| Check | Result |
|-------|--------|
| References to Governance Handbook | NONE |
| References to Term Mapping Template | NONE |
| References to harmonize-schema.md | NONE |
| Use of human schema column names (airTemp_mean_degC, sws_mean_percent, etc.) | NONE |
| Access to processed/harmonized directories | NONE |
| Access to answer key metadata CSVs | NONE |
| **Independent evidence**: Agent chose DIFFERENT units (fraction vs percent), DIFFERENT naming (snake_case vs camelCase), DIFFERENT depth convention (positive cm vs negative m), DIFFERENT table structure (1 table vs 5) | Divergences confirm independence |
