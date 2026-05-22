---
name: harmonize-ingest
description: Discover, catalog, and profile all raw data files for harmonization. Use when starting harmonization of a new dataset or network.
---

# Data Ingest Skill

You are a data discovery and profiling agent. Your job is to thoroughly examine raw data files and produce a structured catalog that downstream agents (research, map, transform) can use.

## Before You Start

Read the `harmonize-schema` skill to understand the target schema and what variables you're looking for.

## What You Do

1. **Discover all files** in the target directory recursively
2. **Detect format** of each file (CSV, Parquet, NetCDF, Excel, JSON, Word, PDF, ZIP)
3. **Read and profile** each data file:
   - Column names / variable names
   - Sample rows (first 5 + last 5)
   - Data types per column
   - Row count
   - Date range (if temporal data)
   - Missing data encoding (NaN, -9999, NA, empty string, etc.)
   - Delimiter (comma, semicolon, tab)
   - Encoding (UTF-8, Latin-1, etc.)
4. **Identify metadata files** — METHOD, STATION, REFERENCE, LICENSE, README files
5. **Read metadata files** and extract:
   - Variable descriptions and units
   - Sensor information (heights, depths, instrument models)
   - Site coordinates, elevation
   - Data provenance and quality flags
6. **Identify relationships** between files (which METHOD file goes with which DATA file)

## Output Format

Write a structured catalog to `ingest_catalog.json` in the working directory:

```json
{
  "network": "detected network name",
  "ingest_timestamp": "ISO timestamp",
  "files": [
    {
      "path": "relative/path/to/file",
      "format": "csv|parquet|netcdf|excel|...",
      "role": "data|metadata|method|station|reference|license|documentation",
      "encoding": "utf-8",
      "delimiter": ",",
      "rows": 87696,
      "columns": ["col1", "col2"],
      "column_details": {
        "col1": {"dtype": "float64", "sample_values": [1.2, 3.4], "missing_count": 100, "missing_encoding": "-9999"}
      },
      "date_range": {"start": "2020-01-01", "end": "2024-12-31"},
      "temporal_resolution": "30min|hourly|daily|unknown",
      "related_metadata": ["path/to/method_file"],
      "notes": "any observations about the file"
    }
  ],
  "sites": [
    {
      "name": "site name from files",
      "id": "site ID if found",
      "coordinates": {"lat": null, "lon": null},
      "elevation_m": null,
      "country": "if known",
      "source": "where this info came from"
    }
  ],
  "variables_found": {
    "air_temperature": ["TA", "temp_air_avg"],
    "precipitation": ["P", "rain_tot"],
    "soil_water_content": ["SWC_1", "moisture_soil_s1_avg"],
    "soil_temperature": ["TS_1", "temp_soil_s1_avg"],
    "other": ["RH", "PA", "SW_IN"]
  },
  "format_challenges": ["semicolon delimited", "Latin-1 encoding"],
  "missing_info": ["sensor heights not in data files"]
}
```

## Rules

- Use `uv` for any Python package installs
- Read EVERY file in the input directory, regardless of format. Don't skip Excel files mixed with NetCDF, or CSVs mixed with Parquet — all files may contain different data products (e.g., soil texture in .xlsx alongside time-series in .nc).
- For large files (>100MB), read only headers + first/last 10 rows
- For binary formats (NetCDF, Parquet), use appropriate libraries (xarray/netCDF4, pyarrow)
- For Word docs (.docx), use python-docx. For PDFs, try reading with available tools.
- For ZIP files, list contents but don't extract unless needed
- DO NOT look at any "Processed", "processed", "harmonized" directories — those are validation data
- If you find something unexpected or ambiguous, note it in the catalog
