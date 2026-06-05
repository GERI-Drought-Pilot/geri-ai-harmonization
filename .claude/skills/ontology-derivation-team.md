---
name: ontology-derivation-team
description: Launch an Agent Team to autonomously derive a data harmonization ontology from raw environmental data across 5 research networks. Iterative research→present→review loop.
---

# Ontology Derivation — Agent Team Experiment

## Goal

Derive a unified data harmonization schema/ontology from raw environmental data across 5 research networks (ICOS, SAEON, eLTER, TERN, NEON) — WITHOUT ever seeing the existing AccelNet schema. Then trace every decision the team made.

## Team Structure

Create an agent team with these roles:

### Profiler Teammates (5 — one per network, use ontology-profiler agent type, Sonnet model)
1. **ICOS Profiler** — Profile `Downloads/geri-data/icos/data/` (39 CSV files, European flux towers)
2. **SAEON Profiler** — Profile `Downloads/geri-data/saeon/` (South African flux towers)
3. **eLTER Profiler** — Profile `Downloads/geri-data/elter/` (European multi-format: CSV, Parquet, Excel)
4. **TERN Profiler** — Profile `Downloads/geri-data/tern/` (Australian NetCDF files)
5. **NEON Profiler** — Profile `Downloads/geri-data/neon/` (raw NEON Level-1 DP1.xxxxx.001 products) and `Downloads/geri-metadata/neon/` (US sites)

### Reviewer Teammate (1 — use ontology-reviewer agent type, Opus model)
6. **Reviewer** — Critically reviews each draft ontology and sends it back with issues

### Lead (you)
- Synthesize profiler findings into a unified ontology
- Present drafts to the Reviewer
- Iterate based on review feedback
- Document every decision with rationale

## Iterative Process

The team follows a research → present → review → revise loop:

### Round 1: Profiling
1. Spawn all 5 Profilers in parallel
2. Each Profiler catalogs their network's variables, units, naming conventions, metadata
3. Each writes `NETWORK_PROFILE_{name}.md` to the working directory
4. Lead waits for all 5 to complete

### Round 2: First Draft Ontology
1. Lead reads all 5 profiles
2. Lead identifies cross-network commonalities (which variables appear in all/most networks?)
3. Lead proposes a unified schema:
   - What data products to define
   - Canonical variable names
   - Unit standardization (with justification for each choice)
   - Schema structure (one table vs many, what metadata to include)
   - Depth/height conventions
   - Temporal model
   - Missing data conventions
4. Lead writes `DERIVED_SCHEMA_DRAFT_1.md` and `DECISION_LOG.json`
5. Lead sends draft to Reviewer

### Round 3: First Review
1. Reviewer reads the draft and all 5 network profiles
2. Reviewer evaluates: consistency, completeness, justification quality, edge cases
3. Reviewer writes `ONTOLOGY_REVIEW_1.md` with verdict: ACCEPT / REVISE / MAJOR_REVISION
4. If issues found, Reviewer sends specific feedback to Lead

### Round 4+: Iteration
1. Lead reads review feedback
2. Lead may ask specific Profilers to investigate gaps (e.g., "TERN Profiler: check if Sws units are fraction or percent in the NetCDF attributes")
3. Lead revises the schema, updating `DERIVED_SCHEMA_DRAFT_{N}.md` and `DECISION_LOG.json`
4. Lead sends revised draft to Reviewer
5. Repeat until Reviewer gives ACCEPT

### Final: Documentation
1. Lead produces final deliverables:
   - `DERIVED_SCHEMA_FINAL.md` — the complete ontology
   - `DECISION_LOG.json` — every decision with ID, evidence, alternatives, rationale, confidence
   - `CROSS_NETWORK_MAPPING.md` — for each variable, how each network's raw name maps to the canonical name
   - `ITERATION_HISTORY.md` — what changed between drafts and why
2. All outputs go in `experiment_logs/runs/ontology_derivation_{timestamp}/`

## Decision Log Format

Every non-trivial decision must be logged in `DECISION_LOG.json`:

```json
[
  {
    "id": "D001",
    "category": "variable_identification",
    "question": "What are the core variables present across all networks?",
    "evidence": {
      "ICOS": "TA, P, SWC_1-5, TS_1-6 found in METEO L2 CSV",
      "SAEON": "temp_air_avg, rain_tot, moisture_soil_s1_avg, temp_soil_s1_avg",
      "eLTER": "Tair50HMP, precip50, SMa010, STa010 (varies by country)",
      "TERN": "Ta, Precip, Sws, Ts in NetCDF",
      "NEON": "tempTripleMean, precipBulk, VSWCMean, soilTempMean"
    },
    "alternatives_considered": [
      "Include radiation variables (only 3/5 networks have them)",
      "Include wind (4/5 have it but naming is very inconsistent)"
    ],
    "decision": "5 core products: air temperature, precipitation, soil moisture, soil temperature, soil texture",
    "rationale": "These 5 variables appear across all 5 networks, making them the natural consensus set for cross-RI harmonization. Radiation and wind are available in most but not all, and could be added as extensions.",
    "confidence": 0.95
  },
  {
    "id": "D002",
    "category": "unit_standardization",
    "question": "What unit for soil water content?",
    "evidence": {
      "ICOS": "SWC values range 0-100, appears to be percent",
      "SAEON": "moisture_soil values range 0-100, percent",
      "eLTER": "SM values vary — some sites 0-100, Hyytiala 0-0.5 (fraction!)",
      "TERN": "Sws units attribute says m^3/m^3 (volumetric fraction)",
      "NEON": "VSWCMean values 0-0.5 range (fraction)"
    },
    "alternatives_considered": [
      "Use fraction (0-1) — matches 2/5 networks natively",
      "Use percent (0-100) — matches 2/5 networks natively, more interpretable"
    ],
    "decision": "Percent (0-100)",
    "rationale": "Percent is more interpretable to non-specialists, less prone to confusion (a value of 0.35 could be misread as 35% or 0.35%), and conversion is trivial (×100). Networks using fraction must be explicitly converted.",
    "confidence": 0.85
  }
]
```

## CRITICAL FILE ACCESS RESTRICTIONS

ALL team members (Lead, Profilers, Reviewer) must NOT access:
- `Geri Data Governance Handbook.xlsx`
- `Term mapping template.xlsx`  
- `.claude/skills/harmonize-schema.md`
- Any `harmonized_*.csv`, `harmonized_*.parquet`, `harmonize_*_test.py`, `harmonize_*_all_sites.py`
- Any `Processed/`, `processed/`, `harmonized/` directories
- `experiment_logs/paper/`
- Any `proc_*` files
- `mapping.json`, `review_report.json`
- `Ta_Precip_variable_attributes_*.csv`

ALL team members CAN access:
- Raw data files (headers + 3-5 rows only for large files)
- Metadata files (sensor positions, variable definitions, site info CSVs)
- Web search and web fetch
- Python for lightweight inspection (DO NOT load full multi-GB files — computer will crash)

## Success Criteria

The experiment succeeds if the team:
1. Identifies the same core variables as the human schema (air temp, precip, SWC, soil temp, soil texture)
2. Makes a defensible unit choice for SWC (the critical test)
3. Proposes a reasonable schema structure
4. Documents every decision with evidence and rationale
5. Goes through at least 2 review iterations
6. Produces a complete cross-network variable mapping
