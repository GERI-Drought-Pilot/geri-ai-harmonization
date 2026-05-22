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
3. **Handle multi-sensor variables**: When multiple sensors exist (SWC_1 through SWC_5), pick the shallowest unless research indicates otherwise. Document the choice.
4. **Handle derived values**: If only max/min temp available, note that mean = (max+min)/2
5. **Handle temporal aggregation**: Note if source is 30-min and needs daily aggregation (mean for temp, sum for precip)
6. **Handle cumulative values**: If precipitation is cumulative, note that daily totals need differencing
7. **Assign confidence**: HIGH (certain), MEDIUM (reasonable with uncertainty), LOW (best guess)

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
