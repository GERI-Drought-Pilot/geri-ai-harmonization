# Derived Harmonization Schema — Draft 1

**Date**: 2026-04-01
**Author**: Lead Ontology Agent
**Source**: 5 network profiles (ICOS, SAEON, eLTER, TERN, NEON)
**Status**: DRAFT — pending review

---

## 1. Scope

This schema defines a unified data model for harmonizing half-hourly environmental observations across five research infrastructure networks:

| Network | Region | Sites | Format | Primary Variables |
|---------|--------|-------|--------|-------------------|
| ICOS | Europe (14 countries) | 39 | CSV | Meteorology + soil |
| SAEON | South Africa | 8-9 | CSV (wide + long) | Flux tower + obs DB |
| eLTER | Europe (4 countries) | 4+ | CSV, Parquet, Excel | Atmosphere + hydrology + soil |
| TERN | Australia | 31 | NetCDF | Full flux + met + soil |
| NEON | USA | 81 | Parquet | Met + soil + soil texture |

---

## 2. Core Variables

Variables are included if present in **3 or more networks**. Variables present in all 5 are marked as Tier 1; those in 3-4 are Tier 2.

### 2.1 Tier 1 Variables (all 5 networks)

| Canonical Name | Description | ICOS | SAEON | eLTER | TERN | NEON |
|----------------|-------------|------|-------|-------|------|------|
| `air_temperature` | Air temperature | TA | temp_air_avg | Tair50HMP / T336 / TA_A / "Air Temperature" | Ta | tempTripleMean |
| `precipitation` | Precipitation accumulation | P | rain_tot | precip50 / Precip / P_RAIN | Precip | precipBulk |
| `soil_water_content` | Volumetric soil water content | SWC_1..5 | moisture_soil_s1..s4_avg | SMa010..SMb080 | Sws_5cm..80cm | VSWCMean |
| `soil_temperature` | Soil temperature at depth | TS_1..6 | temp_soil_s1..s2_avg | STa005..STb080 | Ts_5cm..80cm | soilTempMean |
| `relative_humidity` | Relative humidity | RH | humid_rel_avg | RH45HMP / RH168 / "Air Relative Humidity" | RH | (not in current NEON data products profiled) |

**Note on RH**: NEON measures humidity via derived products. The 5 core variables above are present across at least 4 of 5 networks. RH is included as Tier 1 because it is fundamental to ecosystem science and is derivable from NEON's water vapor measurements.

### 2.2 Tier 2 Variables (3-4 networks)

| Canonical Name | Description | Present In |
|----------------|-------------|------------|
| `shortwave_radiation_in` | Incoming shortwave radiation | ICOS, SAEON, TERN, (eLTER partial) |
| `shortwave_radiation_out` | Outgoing shortwave radiation | ICOS, SAEON, TERN |
| `longwave_radiation_in` | Incoming longwave radiation | ICOS, SAEON, TERN |
| `longwave_radiation_out` | Outgoing longwave radiation | ICOS, SAEON, TERN |
| `net_radiation` | Net radiation | ICOS, SAEON, TERN |
| `wind_speed` | Wind speed | ICOS, SAEON, eLTER, TERN |
| `wind_direction` | Wind direction | ICOS, SAEON, eLTER, TERN |
| `atmospheric_pressure` | Atmospheric pressure | ICOS, SAEON, eLTER, TERN |
| `vapor_pressure_deficit` | Vapor pressure deficit | ICOS, SAEON, TERN |
| `soil_heat_flux` | Ground/soil heat flux | ICOS, SAEON, TERN |
| `soil_texture_sand` | Sand fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) |
| `soil_texture_clay` | Clay fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) |
| `soil_texture_silt` | Silt fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) |

---

## 3. Unit Standardization

### 3.1 Standard Units Table

| Canonical Variable | Canonical Unit | Symbol | Justification |
|--------------------|----------------|--------|---------------|
| `air_temperature` | Degrees Celsius | degC | Universal across all 5 networks |
| `soil_temperature` | Degrees Celsius | degC | Universal across all 5 networks |
| `precipitation` | Millimeters | mm | Universal across all 5 networks |
| `relative_humidity` | Percent | % | Universal across all 5 networks |
| `atmospheric_pressure` | Hectopascals | hPa | ICOS (hPa), SAEON (hpa), eLTER (hPa), TERN (hPa) |
| `wind_speed` | Meters per second | m/s | Universal across all networks with wind data |
| `wind_direction` | Degrees | deg | Universal (0-360) |
| `shortwave_radiation_in` | Watts per square meter | W/m2 | Universal |
| `shortwave_radiation_out` | Watts per square meter | W/m2 | Universal |
| `longwave_radiation_in` | Watts per square meter | W/m2 | Universal |
| `longwave_radiation_out` | Watts per square meter | W/m2 | Universal |
| `net_radiation` | Watts per square meter | W/m2 | Universal |
| `vapor_pressure_deficit` | Kilopascals | kPa | ICOS (kPa); SAEON uses hPa — requires conversion |
| `soil_heat_flux` | Watts per square meter | W/m2 | Universal |
| `soil_texture_sand` | Percent | % | NEON and eLTER use % |
| `soil_texture_clay` | Percent | % | Same |
| `soil_texture_silt` | Percent | % | Same |

### 3.2 CRITICAL: Soil Water Content Units (Decision D001)

This is the highest-risk unit decision in the entire schema.

**Evidence from each network:**

| Network | Raw Variable | Raw Unit | Range Observed | Source |
|---------|-------------|----------|----------------|--------|
| ICOS | SWC_1..5 | % (volumetric) | 29-45% | Profile: "Volumetric soil water content (% vol)" |
| SAEON | moisture_soil_s1_avg | pcnt (percent) | 34-35% | Profile: unit row says "pcnt" |
| eLTER | SMa010..SMb080 | % | 28-31% | Profile: data sample shows "28.54, %" |
| TERN | Sws_5cm..80cm | m3/m3 (fraction) | 0.0-~0.5 | Profile: "Units: m^3/m^3 | Volumetric water content" |
| NEON | VSWCMean | m3/m3 (fraction) | 0.0-0.997 | Profile: "CRITICAL: Fraction, NOT percent" |

**Decision**: Standardize to **fractional units (m3/m3)**, range 0.0-1.0.

**Rationale**:
1. **Scientific convention**: The CF (Climate and Forecasting) standard uses `m3 m-3` for `soil_moisture_content`. TERN follows CF conventions natively.
2. **Lossless conversion**: Converting from percent to fraction (divide by 100) is trivial and lossless. The reverse is also true, but fraction is the more fundamental unit.
3. **Ambiguity prevention**: Percent values (e.g., 35%) can be confused with gravimetric moisture or relative saturation. Fraction (0.35 m3/m3) is unambiguous — it means volumetric water per unit volume.
4. **NEON and TERN native**: The two largest networks by site count (81 + 31 = 112 sites) already use fraction.
5. **Known failure mode**: The project has documented SWC unit confusion as the #1 critical test case.

**Conversion required**:
- ICOS: divide by 100 (SWC values 29% → 0.29)
- SAEON: divide by 100 (moisture_soil values 34% → 0.34)
- eLTER: divide by 100 (SM values 28% → 0.28)
- TERN: no conversion needed (already m3/m3)
- NEON: no conversion needed (already m3/m3)

---

## 4. Schema Structure

### 4.1 Design Decision: Tidy Long Format

The harmonized output uses a **wide format** with one row per site-timestamp combination, and core variables as columns. This matches the dominant pattern in ICOS, SAEON flux files, and TERN, and is the natural output for analysis.

However, depth-varying variables (soil temperature, soil moisture) require a **depth dimension**. Two options:

**Option A — Flat wide with depth-in-column-name** (e.g., `soil_temperature_5cm`, `soil_temperature_10cm`):
- Pros: Simple, no joins needed
- Cons: Column explosion, depth set varies by site

**Option B — Separate observation table with depth column**:
- Pros: Flexible, handles arbitrary depths, normalizes sensor metadata
- Cons: Requires joins for analysis

**Decision (D004)**: Use **Option A (flat wide)** for the primary harmonized table, with depth encoded in the column name as `{variable}_{depth_cm}cm`. A companion depth-metadata table provides exact depth values per site.

**Rationale**: The target users are ecosystem scientists who work in pandas/R dataframes. Wide format minimizes joins and is directly usable for time-series analysis. The depth-in-name convention follows ICOS (SWC_1..5) and NEON (verticalPosition) patterns. A lookup table resolves the "what exact depth does _1 mean at site X" problem.

### 4.2 Primary Observation Table Schema

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `network` | string | Source network identifier | "ICOS", "NEON", etc. |
| `site_id` | string | Canonical site identifier | "FI-Hyy", "ABBY" |
| `timestamp_start` | datetime (UTC, ISO 8601) | Start of averaging period | 2024-01-15T12:00:00Z |
| `timestamp_end` | datetime (UTC, ISO 8601) | End of averaging period | 2024-01-15T12:30:00Z |
| `air_temperature` | float | Air temperature (degC) | 12.5 |
| `relative_humidity` | float | Relative humidity (%) | 65.3 |
| `atmospheric_pressure` | float | Pressure (hPa) | 1013.2 |
| `precipitation` | float | Precipitation (mm) | 0.2 |
| `wind_speed` | float | Wind speed (m/s) | 3.4 |
| `wind_direction` | float | Wind direction (deg) | 225.0 |
| `shortwave_radiation_in` | float | Incoming SW radiation (W/m2) | 450.0 |
| `shortwave_radiation_out` | float | Outgoing SW radiation (W/m2) | 45.0 |
| `longwave_radiation_in` | float | Incoming LW radiation (W/m2) | 320.0 |
| `longwave_radiation_out` | float | Outgoing LW radiation (W/m2) | 380.0 |
| `net_radiation` | float | Net radiation (W/m2) | 345.0 |
| `vapor_pressure_deficit` | float | VPD (kPa) | 0.8 |
| `soil_heat_flux` | float | Ground heat flux (W/m2) | -5.0 |
| `soil_water_content_{depth}cm` | float | SWC at depth (m3/m3) | 0.29 |
| `soil_temperature_{depth}cm` | float | Soil temp at depth (degC) | 8.5 |

### 4.3 Site Metadata Table

| Column | Type | Description |
|--------|------|-------------|
| `network` | string | Source network |
| `site_id` | string | Canonical site identifier |
| `site_name` | string | Full site name |
| `latitude` | float | WGS84 latitude (decimal degrees) |
| `longitude` | float | WGS84 longitude (decimal degrees) |
| `elevation_m` | float | Elevation above sea level (meters) |
| `country` | string | ISO 3166-1 alpha-2 country code |
| `biome` | string | Ecosystem/biome classification |
| `data_start` | date | First date of available data |
| `data_end` | date | Last date of available data |

### 4.4 Soil Texture Table (Static)

| Column | Type | Description |
|--------|------|-------------|
| `network` | string | Source network |
| `site_id` | string | Canonical site identifier |
| `depth_top_cm` | float | Top of sampled horizon (cm) |
| `depth_bottom_cm` | float | Bottom of sampled horizon (cm) |
| `sand_percent` | float | Sand fraction (%) |
| `clay_percent` | float | Clay fraction (%) |
| `silt_percent` | float | Silt fraction (%) |

### 4.5 Depth Metadata Table

| Column | Type | Description |
|--------|------|-------------|
| `network` | string | Source network |
| `site_id` | string | Canonical site identifier |
| `variable` | string | "soil_water_content" or "soil_temperature" |
| `depth_index` | int | Ordinal index (1, 2, 3...) |
| `depth_cm` | float | Actual depth below surface (cm, positive downward) |
| `sensor_type` | string | Sensor model/type if known |

---

## 5. Depth and Height Conventions

### 5.1 Decision (D005): Depth as Positive-Downward in Centimeters

**Evidence**:

| Network | Convention | Examples |
|---------|-----------|----------|
| ICOS | Indexed (SWC_1..5), no explicit depth in data | Requires ancillary lookup |
| SAEON | Indexed (_s1.._s4) | No explicit depth |
| eLTER Germany | Depth in variable name (SMa010 = 10cm), VERT_OFFSET negative (cm) | -10, -20, -30 |
| TERN | Depth in variable name (Sws_5cm, Ts_80cm) | 5, 10, 20, 40, 80 cm |
| NEON | verticalPosition index | Requires metadata lookup |

**Decision**: Encode depth as **positive centimeters below surface**. Column names use `{variable}_{depth}cm` format.

**Rationale**:
1. TERN uses positive cm natively in variable names
2. eLTER Germany encodes depth in cm (the negative VERT_OFFSET is a convention artifact)
3. Centimeters are the natural unit for soil science (most measurement depths are 5-80cm)
4. Positive-downward avoids sign confusion and is the most common convention in soil science literature

### 5.2 Height Convention for Atmospheric Sensors

Height is encoded as **positive meters above ground surface**. For the primary harmonized table, only one representative air temperature is selected per site-timestamp (typically the standard meteorological height, ~2m). Multi-height profiles are not in scope for the primary table but can be provided as supplementary data.

---

## 6. Temporal Model

### 6.1 Decision (D006): Half-Hourly UTC Timestamps

**Evidence**:

| Network | Native Resolution | Timestamp Format | Timezone |
|---------|-------------------|-----------------|----------|
| ICOS | 30 min | YYYYMMDDHHmm | UTC (implied) |
| SAEON flux | 30 min | ISO 8601 (UTC) | UTC |
| SAEON DB | 5 min | ISO 8601 with TZ | UTC + local |
| eLTER | 10 min (DE), varies | ISO 8601 (Z suffix) | UTC |
| TERN | 30 min / 1 hour | CF time dimension | UTC |
| NEON | 30 min | ISO 8601 | UTC |

**Decision**: Standardize to **30-minute intervals** with `timestamp_start` and `timestamp_end` in **UTC ISO 8601** format.

**Rationale**:
1. 30 minutes is the dominant resolution across 4 of 5 networks
2. Higher-resolution data (eLTER 10-min, SAEON 5-min DB) can be aggregated to 30-min
3. UTC eliminates timezone ambiguity
4. Both start and end timestamps allow unambiguous period identification (following ICOS and NEON convention)

---

## 7. Missing Data Convention

### 7.1 Decision (D007): NaN for Missing Values

**Evidence**:

| Network | Missing Convention |
|---------|-------------------|
| ICOS | -9999 sentinel value |
| SAEON | Empty string / blank fields |
| eLTER | Varies (NaN in Parquet, empty in CSV) |
| TERN | NaN (NetCDF standard) |
| NEON | Null / NaN in Parquet |

**Decision**: Use **IEEE 754 NaN** (Not a Number) for all missing values. No sentinel values.

**Rationale**:
1. NaN is the standard for scientific computing (numpy, pandas, R)
2. Sentinel values like -9999 are error-prone (can be accidentally included in calculations)
3. NaN propagates correctly through arithmetic operations
4. All target output formats (Parquet, CSV, NetCDF) support NaN natively

**Conversion required**:
- ICOS: Replace -9999 with NaN
- SAEON: Replace empty strings with NaN
- Others: NaN already used or trivially mapped

---

## 8. Quality Flag Model

Each observation variable in the primary table has an optional companion quality flag column with suffix `_qc`. Quality flags are harmonized to a simple 3-level scheme:

| Flag Value | Meaning | Source Mapping |
|------------|---------|----------------|
| 0 | Good quality | ICOS: _N > 0; SAEON: ITC test 1-2; eLTER: FLAGQUA=0; TERN: QCFlag good; NEON: finalQF=0 |
| 1 | Suspect quality | Marginal QC; individual network thresholds |
| 2 | Bad / rejected | Failed QC checks across any network |
| NaN | No QC available | Missing flag data |

---

## 9. Naming Conventions

### 9.1 Variable Naming Rules

1. **snake_case**: All lowercase with underscores (e.g., `air_temperature`, not `AirTemperature`)
2. **Descriptive**: Full words preferred over abbreviations (e.g., `soil_water_content`, not `SWC`)
3. **Unit-free names**: Units are metadata, not part of the variable name
4. **Depth suffix**: `_{depth}cm` for depth-varying variables (e.g., `soil_temperature_5cm`)
5. **QC suffix**: `_qc` for quality flag columns

### 9.2 Site ID Convention

Use network-native site IDs where they are globally unique:
- ICOS: CC-Site format (e.g., "FI-Hyy")
- SAEON: Descriptive names (e.g., "Skukuza")
- eLTER: CC-Site or DEIMS UUID
- TERN: Site name (e.g., "Calperum")
- NEON: 4-letter code (e.g., "ABBY")

Disambiguation via the `network` column prevents collision.

---

## 10. Cross-Network Variable Mapping Summary

| Canonical Name | ICOS | SAEON | eLTER (DE) | eLTER (FI) | eLTER (ES) | eLTER (AT) | TERN | NEON |
|----------------|------|-------|------------|------------|------------|------------|------|------|
| air_temperature | TA | temp_air_avg | Tair50HMP | T336 | TA_A | "Air Temperature [deg C]" | Ta | tempTripleMean |
| relative_humidity | RH | humid_rel_avg | RH50HMP | RH168 | — | "Air Relative Humidity [%]" | RH | — |
| atmospheric_pressure | PA | pressure_atm_avg | airpres50 | Pamb0 | — | "Surface Air Pressure [hPa]" | — | — |
| precipitation | P | rain_tot | precip50 | Precip | P_RAIN | — | Precip | precipBulk |
| wind_speed | WS | wind_speed_avg | WS49_2D | WS336 | — | "Wind Speed [m s-1]" | Ws | — |
| wind_direction | WD | wind_dir_avg | WD49_2D | WD336 | — | "Wind Direction [deg]" | Wd | — |
| soil_water_content | SWC_1..5 | moisture_soil_s1..s4_avg | SMa010..SMb080 | (SOHYD) | — | (SOHYD) | Sws_Xcm | VSWCMean |
| soil_temperature | TS_1..6 | temp_soil_s1..s2_avg | STa005..STb080 | (SOHYD) | — | (SOHYD) | Ts_Xcm | soilTempMean |
| shortwave_radiation_in | SW_IN | rad_short_in_avg | — | — | — | — | Fsd | — |
| shortwave_radiation_out | SW_OUT | rad_short_out_avg | — | — | — | — | Fsu | — |
| longwave_radiation_in | LW_IN | rad_long_in_avg | — | — | — | — | Fld | — |
| longwave_radiation_out | LW_OUT | rad_long_out_avg | — | — | — | — | Flu | — |
| net_radiation | NETRAD | rad_net_avg | — | — | — | — | — | — |
| vapor_pressure_deficit | VPD | pressure_vapour_def_avg | — | — | — | — | — | — |
| soil_heat_flux | G_1..2 | heat_flux_ground | — | — | — | — | Fg | — |

---

## 11. Open Questions

1. **Multi-height air temperature**: Should the schema support multiple heights per site, or just one canonical height?
2. **SAEON VPD units**: SAEON reports VPD in hPa while ICOS uses kPa. Conversion factor is 0.1. Needs verification.
3. **eLTER Finland sensor ID resolution**: T336 vs T168 — which represents the standard meteorological height? Requires METHOD parquet inspection.
4. **Soil depth harmonization**: ICOS uses ordinal indices (SWC_1..5), NEON uses verticalPosition codes. Exact depths require per-site metadata lookup. The schema accommodates this via the depth metadata table, but actual depth values need to be populated per site.
5. **Snow depth**: Only available in ICOS high-latitude sites (D_SNOW). Not included in core schema — should it be a Tier 2 variable?

---

## Appendix A: Conversion Formulas

| Source | Target | Formula |
|--------|--------|---------|
| SWC percent → fraction | ICOS, SAEON, eLTER → canonical | value / 100.0 |
| VPD hPa → kPa | SAEON → canonical | value / 10.0 |
| -9999 → NaN | ICOS → canonical | replace(-9999, NaN) |
| YYYYMMDDHHmm → ISO 8601 | ICOS, SAEON flux → canonical | parse and format as ISO 8601 UTC |

---

**End of Draft 1**
