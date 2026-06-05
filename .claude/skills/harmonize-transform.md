---
name: harmonize-transform
description: Write and execute transformation code to produce harmonized output from raw data using the mapping specification. Use after mapping is complete.
---

# Transform Skill

You are a data transformation agent. Your job is to write and execute Python code that reads raw data files and produces harmonized output according to the mapping specification.

## Before You Start

Read these files from the working directory:
- `mapping.json` — variable mappings, unit conversions, confidence scores
- `ingest_catalog.json` — file format details, encodings, delimiters
- `research_report.json` — sensor heights and site metadata

**Source selection is already decided — do NOT re-open it here.** The committed `mapping.json` names exactly which source product/file/variable feeds each target column; that choice was made in the map phase on the basis of meaning, using metadata and research. Transform only the chosen sources. Do NOT switch to a different candidate product, and do NOT let data-volume observations you encounter while loading (more rows, more sites, a more convenient resolution) change the selection. If you find concrete evidence a mapping is genuinely wrong, stop and return an action item to the map skill rather than silently substituting a different source.

Also read the `harmonize-schema` skill to verify output column names and types.

## What You Do

1. **Write a Python transformation script** that:
   - Reads each raw data file listed in the mapping
   - Applies the specified column mappings
   - Performs unit conversions (SWC fraction→percent, depth cm→m, etc.)
   - Handles missing data (replace -9999, NaN, NA, empty with NaN)
   - Applies temporal aggregation if needed (30-min→daily: mean for temp, sum for precip)
   - Handles cumulative→interval conversion where specified
   - Adds site metadata (coordinates, elevation, sensor heights, instruments)
   - Produces **separate output per data product** (air temp, precip, soil moisture, soil temp, soil texture)

2. **Handle format diversity**:
   - CSV: detect delimiter, encoding, header rows, unit rows
   - Parquet: use pyarrow or pandas
   - NetCDF: use xarray or netCDF4
   - Excel: use openpyxl
   - Handle large files with chunked reading if >500MB

3. **Apply basic QC during transform**:
   - Air temperature: [-60, 60] degC
   - Soil temperature: [-30, 70] degC
   - Precipitation: [0, 500] mm per interval
   - SWC: [0, 100] percent (AFTER unit conversion)
   - Flag and count removed values

4. **Save output** per data product as both CSV and Parquet:
   - `harmonized_{network}_air_temperature.csv` / `.parquet`
   - `harmonized_{network}_precipitation.csv` / `.parquet`
   - `harmonized_{network}_soil_moisture.csv` / `.parquet`
   - `harmonized_{network}_soil_temperature.csv` / `.parquet`
   - `harmonized_{network}_soil_texture.csv` / `.parquet`

5. **Write a transform report** to `transform_report.json`:

```json
{
  "transform_timestamp": "ISO timestamp",
  "network": "network name",
  "output_files": ["harmonized_icos_air_temperature.csv", "..."],
  "total_rows_per_product": {"air_temperature": 72050, "precipitation": 67864},
  "sites_processed": ["BE-Bra", "..."],
  "per_site_summary": {
    "BE-Bra": {
      "air_temperature": {"valid": 72050, "missing": 15646, "qc_removed": 0},
      "precipitation": {"valid": 67864, "missing": 19832, "qc_removed": 2}
    }
  },
  "qc_summary": {
    "total_removed": 7,
    "by_variable": {"airTemp_mean_degC": {"removed": 5, "reason": "below -60 degC"}}
  },
  "warnings": []
}
```

## Rules

- Use `uv` for Python package installs
- Write clean, readable code with comments
- Handle errors gracefully — if one file fails, log it and continue
- Never load a 1GB+ file entirely into memory — use chunked reading
- The script should be re-runnable (idempotent)
- Print progress to stdout
