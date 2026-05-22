# NEON Network Profile

**Network:** National Ecological Observatory Network (NEON)
**Region:** United States (47 terrestrial sites across 20 ecoclimatic domains)
**Profile Date:** 2026-05-05
**Files Analyzed:** 14 Parquet files + metadata CSVs

---

## 1. Data Structure

- **Format:** Parquet files, wide-format with one row per site-position-timestep
- **Temporal resolution:** 30-minute intervals (soil temp, soil moisture), hourly (precipitation)
- **Timestamp format:** ISO 8601 datetime with timezone (`2017-06-16 00:00:00+00:00`)
- **Timestamp columns:** `startDateTime`, `endDateTime`
- **Missing data:** NaN (float) or null
- **Position encoding:** `horizontalPosition` (sensor plot, "001"-"005") + `verticalPosition` (depth code, "501"-"509")
- **Quality flags:** `finalQF` (0=pass, 1=fail) or `VSWCFinalQFSciRvw` (0=pass, 1=suspect, 2=fail)

## 2. Core Variables

### Air Temperature
- **File:** `neon_airtemperature_data.parquet` -- **EMPTY (0 bytes)**
- Air temperature data not available in this dataset extract
- NEON product DP1.00003.001 exists but was not downloaded with data

### Precipitation
- **File:** `neon_precipitation_data.parquet` (363,624 rows)
- **Column:** `precipBulk`
- **Unit:** mm (total per interval)
- **Uncertainty:** `precipBulkExpUncert` (mm)
- **Quality:** `finalQF` (0=pass 37%, 1=suspect 38%, 2=fail 25%)
- **Instruments:** "weighing gauge" and "tipping bucket"
- **Position metadata:** `height` (sensor height above ground, typically 0.44-9.07 m)

### Soil Moisture (VSWC)
- **File:** `neon_soilmoisture_data.parquet` (4,235,520 rows)
- **Column:** `VSWCMean` (also `VSWCMinimum`, `VSWCMaximum`, `VSWCVariance`)
- **Unit:** FRACTION (0-1 scale, NOT percent)
- **Evidence:** VSWCMean range 0.0000-0.9971, mean=0.1625
- **Uncertainty:** `VSWCExpUncert` (fraction, can be very high -- up to 0.93)
- **Quality:** `VSWCFinalQFSciRvw` (0=pass 59.5%, 1=suspect 40.5%)
- **Vertical positions:** "501" through "508" (8 depth levels per plot)
- **Horizontal positions:** "001" through "005" (5 plots per site)
- **~19% null values** in measurement columns

### Soil Temperature
- **File:** `neon_soiltemperature_data.parquet` (4,764,960 rows)
- **Column:** `soilTempMean` (also `soilTempMinimum`, `soilTempMaximum`, `soilTempVariance`)
- **Unit:** degC
- **Value range:** -9.86 to 36.00 degC
- **Uncertainty:** `soilTempExpUncert` (degC, typically 0.13-0.15)
- **Quality:** `finalQF` (0=pass ~78%)
- **Vertical positions:** "501" through "509" (9 depth levels)

### Soil Texture
- **File:** `neon_soiltexture_data.parquet` (452 rows)
- **Columns:** `sandTotal`, `clayTotal`, `siltTotal`
- **Unit:** % (0-100)
- **Evidence:** sandTotal 1.6-97.6, clayTotal 0.0-61.9, siltTotal 1.3-78.8
- **Depth columns:** `biogeoTopDepth`, `biogeoBottomDepth` (cm from surface)
- **Depth range:** 0-210 cm (many irregular intervals based on soil horizons)
- **Additional metadata:** `pitID`, `decimalLatitude`, `decimalLongitude`, `collectDate`
- **Complete coverage:** 0 nulls in texture variables

## 3. Position and Depth Conventions

### HOR.VER System
- **Horizontal:** Plot number (001-005), representing different spatial locations within a site
- **Vertical:** Depth level code (501-509)
  - 501 = shallowest sensor
  - 509 = deepest sensor
  - Actual depths are NOT in the data files -- must be looked up in sensor position metadata

### Sensor Position Metadata
- **File:** `all_sensor_positions_00044_00006`
- **Columns:** siteID, HOR.VER, referenceLocationID, lat/lon/elevation, eastOffset, northOffset, height, instrument
- **Height column:** Sensor height above ground (m) -- for soil sensors this would be depth below ground
- Note: The combined positions file merges soil water (00006) and soil temp (00044) products

### Soil Texture Depths
- Use actual soil horizon boundaries (`biogeoTopDepth`, `biogeoBottomDepth`) in cm
- Not indexed by the HOR.VER system (one-time megapit excavation, not continuous sensors)

## 4. Metadata and Quality

### Uncertainty
Every NEON measurement includes expanded uncertainty (`ExpUncert`):
- 95% confidence interval (k=2)
- Same unit as measurement
- Can exceed measurement value for VSWC (known calibration issues)

### Science Review Flags
- Stored in `science_review_flags_*.csv` files
- Include date ranges, justification text, and field name
- Example: Throughfall precipitation flagged unreliable at certain sites due to sensor blockage

### Variables Dictionary
- `variables_00003.csv` (precipitation), `variables_00006` (soil water), `variables_00044` (soil temp)
- Fields: table, fieldName, description, dataType, units

## 5. Key Observations

1. **VSWC in FRACTION (0-1)**, NOT percent -- confirmed by value range and max=0.9971
2. **Air temperature file is empty** (0 bytes) -- data not available in this extract
3. **Rich uncertainty metadata** -- every variable has expanded uncertainty and quality flags
4. **Depth levels are coded** (501-509) without explicit depth values in the data files themselves
5. **Soil texture from megapit** -- one-time laboratory analysis, not continuous monitoring
6. **High QF failure rates** -- precipitation only 37% pass, soil moisture 59.5% pass
7. **Multiple horizontal positions** per site (up to 5 plots) enable spatial analysis
8. **No explicit unit columns** in data files -- units must be looked up in variables dictionary
