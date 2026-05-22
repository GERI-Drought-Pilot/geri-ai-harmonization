---
name: harmonize-schema
description: The AccelNet/GERI target schema for data harmonization. Reference this before any mapping or transformation work.
---

# AccelNet/GERI Harmonized Data Schema

This is the canonical target schema for harmonizing environmental data across Research Infrastructures (NEON, ICOS, TERN, SAEON, eLTER, TERENO).

Source: `GERI Data Governance Handbook.xlsx` (Harmonized sheet)

## Data Products

Five data products, each with its own table structure:

### 1. AIR TEMPERATURE

| Column | Units | Description |
|--------|-------|-------------|
| researchInfrastructure | string | RI name (NEON, TERN, SAEON, eLTER, ICOS, TERENO) |
| country | string | Country |
| siteID | string | Site identifier |
| siteName | string | Site name |
| startDateTime | ISO 8601 | Start of measurement window |
| endDateTime | ISO 8601 | End of measurement window |
| airTemp_mean_degC | degree C | Mean air temperature |
| latitude_deg | degree | Decimal degrees |
| longitude_deg | degree | Decimal degrees |
| elevation | m | Meters above sea level |
| height_m | m | Sensor height above ground |
| instrument | string | Instrument name/model |

### 2. PRECIPITATION

| Column | Units | Description |
|--------|-------|-------------|
| researchInfrastructure | string | RI name |
| country | string | Country |
| siteID | string | Site identifier |
| siteName | string | Site name |
| startDateTime | ISO 8601 | Start of accumulation window |
| endDateTime | ISO 8601 | End of accumulation window |
| precip_tot_mm | mm | Total precipitation |
| latitude | degree | Decimal degrees |
| longitude | degree | Decimal degrees |
| elevation | m | Meters above sea level |
| height_m | m | Gauge height above ground (if known) |
| instrument | string | Instrument name/model |

### 3. SOIL MOISTURE

| Column | Units | Description |
|--------|-------|-------------|
| researchInfrastructure | string | RI name |
| country | string | Country |
| siteID | string | Site identifier |
| siteName | string | Site name |
| startDateTime | ISO 8601 | Start of measurement window |
| endDateTime | ISO 8601 | End of measurement window |
| sws_mean_percent | percent (0-100) | Mean volumetric soil water content. MUST be 0-100 percent, NOT 0-1 fraction. |
| latitude | degree | Decimal degrees |
| longitude | degree | Decimal degrees |
| elevation | m | Meters above sea level |
| depth | m | Sensor depth below ground (negative value) |
| instrument | string | Instrument name/model |

### 4. SOIL TEMPERATURE

| Column | Units | Description |
|--------|-------|-------------|
| researchInfrastructure | string | RI name |
| country | string | Country |
| siteID | string | Site identifier |
| siteName | string | Site name |
| startDateTime | ISO 8601 | Start of measurement window |
| endDateTime | ISO 8601 | End of measurement window |
| soilTemp_Mean_degC | degree C | Mean soil temperature |
| latitude | degree | Decimal degrees |
| longitude | degree | Decimal degrees |
| elevation | m | Meters above sea level |
| depth | m | Sensor depth below ground (negative value) |
| instrument | string | Instrument name/model |

### 5. SOIL TEXTURE (static)

| Column | Units | Description |
|--------|-------|-------------|
| researchInfrastructure | string | RI name |
| siteID | string | Site identifier |
| plotID | string | Plot identifier |
| latitude | degree | Decimal degrees |
| longitude | degree | Decimal degrees |
| dateCollected | YYYY-MM-DD | Collection date |
| depthMax_m | m | Max depth of sampled interval |
| depthMin_m | m | Min depth of sampled interval |
| sand_percent | percentage | Sand fraction |
| clay_percent | percentage | Clay fraction |
| silt_percent | percentage | Silt fraction |
| instrument | string | Method/instrument used |

## Known Naming Discrepancy

The Term Mapping Template (`Term mapping template.xlsx`) uses slightly different column names. Both refer to the same variables:

| Governance Handbook (canonical) | Term Mapping Template (legacy) |
|------|------|
| airTemp_mean_degC | meanAirTemp_degC |
| precip_tot_mm | bulkPrecipitation_mm |
| sws_mean_percent | meanSwc_percent |
| soilTemp_Mean_degC | meanSoilTemp_degC |
| height_m / depth | measHeight_AirTemp_m, measHeight_Precip_m, measHeight_Swc_m, measHeight_soilTemp_m |

Use the governance handbook names. The term mapping template is a legacy working document.

## Critical Unit Rules

- **SWC MUST be percent (0-100)**, not volumetric fraction (0-1). If source data has values between 0 and 1, multiply by 100.
- **Depths are negative** (below ground). If source uses positive values for depth, negate them.
- **Heights are positive** (above ground).
- **Temperature is Celsius**. Convert from Kelvin (subtract 273.15) or Fahrenheit ((F-32)*5/9) if needed.
- **Precipitation is mm**. Convert from m (multiply 1000) if needed.
- **Missing data is NaN**. Replace -9999, NA, empty strings, or any other sentinel values.

## Research Infrastructures

| RI | Short | Country | URL |
|----|-------|---------|-----|
| National Ecological Observatory Network | NEON | United States | https://www.neonscience.org |
| Terrestrial Ecosystem Research Network | TERN | Australia | https://www.tern.org.au/ |
| South African Environmental Observation Network | SAEON | South Africa | — |
| Integrated Carbon Observation System | ICOS | Europe (multi-country) | https://www.icos-cp.eu/ |
| European Long-Term Ecosystem Research | eLTER | Europe (multi-country) | — |
| Terrestrial Environmental Observatories | TERENO | Germany | — |

## Included Sites

The governance handbook `SiteMetadata` sheet lists ~150 sites across all RIs with a Y/N "Included" column. Key metadata per site: RI, site name, short name, station, data products available (Air Temp, Precip, Soil Moisture, Soil Temp, Soil Texture), temporal resolution, instrument, coordinates, elevation.

Reference files:
- `GERI Data Governance Handbook.xlsx` — SiteMetadata sheet for full site list
- `Term mapping template.xlsx` — Glossary sheet for variable definitions

## Data Access

Each RI has different access methods documented in the Access&Citation sheet:
- **NEON**: NEON API (data.neonscience.org)
- **TERN**: OzFlux data portal (data.tern.org.au), netCDF format for time-series; Excel (.xlsx) for soil texture
- **SAEON**: Terrestrial observation monitor API (catalogue.saeon.ac.za), CSV format
- **ICOS**: ICOS Carbon Portal, CSV format
- **eLTER**: Various per-site, mixed formats (CSV, Parquet, Excel)
