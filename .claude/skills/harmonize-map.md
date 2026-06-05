---
name: harmonize-map
description: Create semantic mappings from source variables to AccelNet target schema using ingest catalog and research findings. Use after ingest and research are complete.
---

# Mapping Skill

You are a semantic mapping agent. Your job is to create precise, justified mappings from source data variables to the AccelNet harmonized schema.

## Before You Start

Read these files from the working directory:
- `ingest_catalog.json` — what data exists, column names, formats
- `research_report.json` — network conventions, sensor metadata, unit info

Also read the `harmonize-schema` skill to know the exact target columns and unit requirements.

## What You Do

For each data file in the ingest catalog:

1. **Map each source column** to the closest AccelNet target variable
2. **Determine unit conversions**:
   - SWC fraction (0-1) → multiply by 100 to get percent (0-100)
   - Temperature in Kelvin → subtract 273.15 for Celsius
   - Depths in cm → divide by 100 for meters
   - Heights stored as positive for below-ground → negate for AccelNet convention
3. **Handle multi-sensor / multi-product variables**: When more than one source sensor OR more than one source data product could supply a target variable, follow the **Source Selection Protocol** below. Do not choose by convenience (e.g., matching temporal resolution); choose by semantic match to the target variable. Document the candidates and the choice.
4. **Handle derived values**: If only max/min temp available, note that mean = (max+min)/2
5. **Handle temporal aggregation**: Note if source is 30-min and needs daily aggregation (mean for temp, sum for precip)
6. **Handle cumulative values**: If precipitation is cumulative, note that daily totals need differencing
7. **Assign confidence**: HIGH (certain), MEDIUM (reasonable with uncertainty), LOW (best guess)

## Source Selection Protocol (multiple candidate products or sensors)

**Selection is a SEPARATE, GATED PHASE that happens BEFORE any transformation.** Decide *which* source supplies each target variable first, using only metadata (headers, readme/variables files, sensor positions, and web research) — do NOT load or transform bulk data while selecting. Commit your decisions to `mapping.json` before the transform skill runs. This separation matters: making the selection while in the middle of transforming bulk data leads to choices driven by convenience rather than meaning.

**Do NOT use data-volume cues as selection criteria.** Row count, number of sites, file size, and "this product's resolution matches the others" are NOT valid reasons to pick a source. A product is not more correct because it has more rows or more sites. Choose strictly by which candidate measures the quantity the schema defines.

A network may publish more than one data product or sensor stream that could each plausibly supply a target variable. Choosing among them is a selection decision distinct from transformation, and it must be made on the *meaning* of the data, not on convenience cues such as matching temporal resolution, file size, or naming similarity. When you face such a choice, escalate in this order and stop as soon as the choice is unambiguous:

1. **Anchor on schema semantics.** Read the target variable's exact definition and units in the `harmonize-schema` skill. Identify which candidate measures precisely that physical quantity. Often this alone settles it.

2. **Research the candidates.** If still uncertain, use web search and the source documentation to understand what each candidate instrument or product actually measures and how they differ, then select the one whose measured quantity matches the target definition. Cite what you find.

3. **Cross-reference peer RIs (last resort).** If genuine uncertainty remains, examine how the *other* Research Infrastructures' RAW source data supply the analogous variable, and choose the option consistent across networks.
   - You MAY read other RIs' raw source data directories for this comparison.
   - You MUST NOT read any harmonized, processed, or answer-key outputs (e.g., anything under `geri-harmonized/`, `geri-working/`, the governance handbook, or the term mapping template). The comparison is to peer *raw* data only.

4. **Document the decision.** In `mapping.json`, record every candidate considered, the evidence from each escalation step you used, the final selection, and a confidence level. A well-justified MEDIUM is better than an unexamined HIGH.

For multi-sensor cases (which tower level, which soil plot/depth), apply the same anchoring and research steps, and preserve whatever dimension the schema asks for (e.g., keep per-depth records when the schema carries a depth column) rather than collapsing it.

## Output

Write `mapping.json` to the working directory:

```json
{
  "mapping_timestamp": "ISO timestamp",
  "target_schema": "AccelNet Governance Handbook",
  "source_network": "network name",
  "file_mappings": [
    {
      "source_file": "relative/path/to/file",
      "site_id": "SITE_ID",
      "site_name": "Site Name",
      "data_product": "air_temperature|precipitation|soil_moisture|soil_temperature|soil_texture",
      "mappings": {
        "airTemp_mean_degC": {
          "source_column": "TA",
          "unit_conversion": "none",
          "confidence": "HIGH",
          "rationale": "ICOS TA is standard air temperature in degC",
          "sensor_height_m": 32.2,
          "instrument": "Vaisala HMP155",
          "sensor_source": "labelling report"
        }
      },
      "unmapped_source_columns": ["RH", "PA", "SW_IN"],
      "warnings": []
    }
  ],
  "global_warnings": [
    "Cross-site SWC unit check required during review"
  ]
}
```

## Critical Rules

- **ALWAYS flag SWC units** — most common harmonization error. Values 0-1 = fraction (needs *100). Values 0-100 = already percent.
- **ALWAYS check sensor height sign convention** — AccelNet uses negative for below-ground.
- **ALWAYS note timestamp convention** — period-beginning vs period-ending.
- **Never map a column without justification**. A LOW confidence mapping with a warning is better than a wrong HIGH.
- **Separate output by data product** — air temperature, precipitation, soil moisture, soil temperature, and soil texture are separate tables in the target schema.
- If the research report has warnings, incorporate them.
