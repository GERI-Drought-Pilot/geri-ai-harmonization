# Derived Harmonization Schema -- FINAL

**Date**: 2026-04-01
**Author**: Lead Ontology Agent
**Source**: 5 network profiles (ICOS, SAEON, eLTER, TERN, NEON)
**Status**: FINAL -- accepted after 2 review rounds
**Review History**: Draft 1 -> REVISE (8 critical issues) -> Draft 2 -> ACCEPT
**Changes from Draft 1**: See Section 12 (Revision History)

---

## 1. Scope

This schema defines a unified data model for harmonizing half-hourly environmental observations across five research infrastructure networks:

| Network | Region | Sites | Format | Primary Variables |
|---------|--------|-------|--------|-------------------|
| ICOS | Europe (14 countries) | 39 | CSV | Meteorology + soil |
| SAEON | South Africa | 8 flux towers | CSV (wide + long) | Flux tower + obs DB |
| eLTER | Europe (4 countries) | 4+ | CSV, Parquet, Excel | Atmosphere + hydrology + soil |
| TERN | Australia | 31 | NetCDF | Full flux + met + soil |
| NEON | USA | 81 | Parquet | Met + soil + soil texture |

**Note**: SAEON count refers to flux tower sites only. The observation database contains additional weather stations across multiple SAEON nodes.

---

## 2. Core Variables

Variables are tiered by cross-network availability. **Tier 1** = present in all 5 networks. **Tier 2** = present in 3-4 networks.

### 2.1 Tier 1 Variables (all 5 networks)

| Canonical Name | Description | ICOS | SAEON | eLTER | TERN | NEON |
|----------------|-------------|------|-------|-------|------|------|
| `air_temperature` | Air temperature | TA | temp_air_avg | Tair50HMP / T336 / TA_A / "Air Temperature" | Ta | tempTripleMean |
| `precipitation` | Precipitation accumulation | P | rain_tot | precip50 / Precip / P_RAIN | Precip | precipBulk |
| `soil_water_content` | Volumetric soil water content | SWC_1..5 | moisture_soil_s1..s4_avg | SMa010..SMb080 | Sws_5cm..80cm | VSWCMean |
| `soil_temperature` | Soil temperature at depth | TS_1..6 | temp_soil_s1..s2_avg | STa005..STb080 | Ts_5cm..80cm | soilTempMean |

### 2.2 Tier 2 Variables (3-4 networks)

| Canonical Name | Description | Networks Present | Count |
|----------------|-------------|-----------------|-------|
| `relative_humidity` | Relative humidity | ICOS, SAEON, eLTER, TERN | 4/5 |
| `wind_speed` | Wind speed | ICOS, SAEON, eLTER, TERN | 4/5 |
| `wind_direction` | Wind direction | ICOS, SAEON, eLTER, TERN | 4/5 |
| `atmospheric_pressure` | Atmospheric pressure | ICOS, SAEON, eLTER | 3/5 |
| `shortwave_radiation_in` | Incoming shortwave radiation | ICOS, SAEON, TERN | 3/5 |
| `shortwave_radiation_out` | Outgoing shortwave radiation | ICOS, SAEON, TERN | 3/5 |
| `longwave_radiation_in` | Incoming longwave radiation | ICOS, SAEON, TERN | 3/5 |
| `longwave_radiation_out` | Outgoing longwave radiation | ICOS, SAEON, TERN | 3/5 |
| `net_radiation` | Net radiation | ICOS, SAEON | 2/5 * |
| `vapor_pressure_deficit` | Vapor pressure deficit | ICOS, SAEON | 2/5 * |
| `soil_heat_flux` | Ground/soil heat flux | ICOS, SAEON, TERN | 3/5 |
| `soil_texture_sand` | Sand fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) | 3/5 |
| `soil_texture_clay` | Clay fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) | 3/5 |
| `soil_texture_silt` | Silt fraction (%) | ICOS (ancillary), NEON, eLTER (SOGEO) | 3/5 |

**Coverage corrections from Draft 1 (reviewer feedback C2, S1-S3)**:

- **Relative humidity**: Demoted from Tier 1 to Tier 2. NEON does not provide RH in the profiled data products (only air temp, precip, soil temp, soil moisture, soil texture). While RH could theoretically be derived from water vapor measurements, the profiled NEON parquet files do not include a humidity data product. Claiming 5/5 for a variable that requires derivation in one network would be misleading.

- **Atmospheric pressure**: Corrected to 3/5. TERN's L3 profile does not list a surface pressure variable. Present in ICOS (PA), SAEON (pressure_atm_avg), and eLTER (airpres50/Pamb0/"Surface Air Pressure [hPa]" across Germany, Finland, Austria).

- **Net radiation**: Corrected to 2/5. ICOS has NETRAD, SAEON has rad_net_avg. TERN has `Fa` (available energy = Rn - G), which is NOT the same as net radiation. Retained in Tier 2 as a borderline variable; implementations should note limited coverage.

- **Vapor pressure deficit**: Corrected to 2/5. Only ICOS (VPD) and SAEON (pressure_vapour_def_avg) provide VPD directly. TERN and eLTER could derive VPD from Ta + RH, but derivable is not the same as present. Retained as Tier 2 for networks that do provide it.

### 2.3 Variables Considered but Excluded

The following variables are present in some networks but excluded from the core schema:

| Variable | Networks | Reason for Exclusion |
|----------|----------|---------------------|
| CO2 flux | SAEON, TERN | Not in ICOS METEO, not in NEON profiled products |
| Sensible/Latent heat flux | SAEON, TERN | Eddy covariance products; different processing chains |
| Snow depth | ICOS (D_SNOW, high-latitude only) | Only 1 network; limited site coverage |
| Water table depth | ICOS (WTD, subset sites) | Only 1 network |
| Albedo | ICOS (ALB), SAEON (albedo) | Only 2 networks with direct measurement |
| Absolute humidity | TERN (AH) | Only 1 network |
| CO2 concentration | TERN (CO2), SAEON (co2_mol_frac) | Not in Tier 1-2 scope |

---

## 3. Unit Standardization

### 3.1 Standard Units Table

| Canonical Variable | Canonical Unit | Symbol | Justification |
|--------------------|----------------|--------|---------------|
| `air_temperature` | Degrees Celsius | degC | Universal across all 5 networks |
| `soil_temperature` | Degrees Celsius | degC | Universal across all 5 networks |
| `precipitation` | Millimeters | mm | Universal across all 5 networks |
| `relative_humidity` | Percent | % | Universal across all reporting networks |
| `atmospheric_pressure` | Hectopascals | hPa | ICOS (hPa), SAEON (hPa), eLTER (hPa) |
| `wind_speed` | Meters per second | m/s | Universal |
| `wind_direction` | Degrees | deg | Meteorological convention (0=N, 90=E, 180=S, 270=W) |
| `shortwave_radiation_in` | Watts per square meter | W/m2 | Universal |
| `shortwave_radiation_out` | Watts per square meter | W/m2 | Universal |
| `longwave_radiation_in` | Watts per square meter | W/m2 | Universal |
| `longwave_radiation_out` | Watts per square meter | W/m2 | Universal |
| `net_radiation` | Watts per square meter | W/m2 | Universal |
| `vapor_pressure_deficit` | Kilopascals | kPa | ICOS (kPa); SAEON uses hPa -- requires /10 conversion |
| `soil_heat_flux` | Watts per square meter | W/m2 | Universal |
| `soil_texture_sand` | Percent by mass | % (mass) | Standard pedological convention; NEON lab grain size analysis, eLTER "percentage by mass" |
| `soil_texture_clay` | Percent by mass | % (mass) | Same as sand |
| `soil_texture_silt` | Percent by mass | % (mass) | Same as sand |

### 3.2 CRITICAL: Soil Water Content Units (Decision D001)

This is the highest-risk unit decision in the entire schema.

**Evidence from each network:**

| Network | Raw Variable | Raw Unit | Range Observed | Storage Convention |
|---------|-------------|----------|----------------|--------|
| ICOS | SWC_1..5 | % (volumetric) | 29-45% | Percent (0-100) |
| SAEON | moisture_soil_s1_avg | pcnt (percent) | 34-35% | Percent (0-100) |
| eLTER | SMa010..SMb080 | % | 28-31% | Percent (0-100) |
| TERN | Sws_5cm..80cm | m3/m3 (fraction) | 0.0-~0.5 | Fraction (0-1) |
| NEON | VSWCMean | m3/m3 (fraction) | 0.0-0.997 | Fraction (0-1) |

**Decision**: Standardize to **fractional units (m3/m3)**, range 0.0-1.0.

**Rationale**:
1. **Scientific convention**: The CF (Climate and Forecasting) standard uses `m3 m-3` for `soil_moisture_content`. TERN follows CF conventions natively.
2. **Lossless conversion**: Converting from percent to fraction (divide by 100) is trivial and lossless.
3. **Ambiguity prevention**: Percent values (e.g., 35%) can be confused with gravimetric moisture or relative saturation. Fraction (0.35 m3/m3) is unambiguous.
4. **NEON and TERN native**: 112 sites (81 + 31) already use fraction natively.
5. **Known failure mode**: SWC unit confusion is the #1 critical test case for this project.

**Conversion required**:
- ICOS: divide by 100 (SWC values 29% -> 0.29)
- SAEON: divide by 100 (moisture_soil values 34% -> 0.34)
- eLTER: divide by 100 (SM values 28% -> 0.28)
- TERN: no conversion needed
- NEON: no conversion needed

**Validation rule**: After conversion, all values MUST fall in [0.0, 1.0]. Values outside this range indicate conversion error. Additionally, values > 0.4 m3/m3 should be flagged as potentially unreliable per NEON sensor saturation guidance (though high values can be physically valid in organic or clay-rich soils, e.g., ICOS FI-Hyy SWC_5 = 40.86% -> 0.4086).

**Note on eLTER Austria** (reviewer Q1): The Austria data headers explicitly use `[vol percent]` / `[volpercent]`, confirming percent convention. Division by 100 is correct for all eLTER sites.

---

## 4. Schema Structure

### 4.1 Design Decision: Wide Format with Depth-in-Column-Name

The harmonized output uses a **wide format** with one row per site-timestamp combination, and core variables as columns. This matches the dominant pattern in ICOS, SAEON flux files, and TERN, and is the natural format for analysis in pandas/R.

Depth-varying variables (soil temperature, soil moisture) encode depth in the column name as `{variable}_{depth}cm`. A companion depth-metadata table provides exact depth values per site.

**Variable-width schema note**: Because measurement depths vary by site (one site may have 5/10/20/40/80cm, another 8/15/30/60cm), the column set is site-adaptive. This is well-handled by Parquet (columnar format with schema evolution) but requires care in fixed-schema databases. Implementations should either: (a) use a union of all observed depths with NaN for uninstalled sensors, or (b) use per-network/per-site schemas.

**Non-integer depths**: Where sensor installation results in non-integer depths (e.g., 7.5cm, 15.5cm), encode as the nearest integer in the column name (e.g., `soil_temperature_8cm`) and record the exact depth in the depth metadata table. This preserves readable column names while retaining precision in metadata.

**Duplicate soil profiles at same site**: When a network provides multiple soil profiles at the same site (e.g., eLTER Germany has profiles A and B at Hohes Holz), both are included as separate rows distinguished by a `profile_id` column. The depth metadata table maps each profile to its specific sensor locations.

### 4.2 Primary Observation Table Schema

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `network` | string | Source network identifier | "ICOS", "NEON", etc. |
| `site_id` | string | Canonical site identifier | "FI-Hyy", "ABBY" |
| `profile_id` | string | Soil profile identifier (NULL for single-profile sites) | "a", "b", NULL |
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
| `profile_id` | string | Soil profile ID ("a", "b", or NULL) |
| `variable` | string | "soil_water_content" or "soil_temperature" |
| `depth_index` | int | Ordinal index (1, 2, 3...) |
| `column_name_cm` | int | Value used in column name (nearest integer cm) |
| `actual_depth_cm` | float | Exact depth below surface (cm, positive downward) |
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

**Decision**: Encode depth as **positive centimeters below surface**. Column names use `{variable}_{depth}cm` format. Exact depths stored in depth metadata table.

**Rationale**:
1. TERN uses positive cm natively in variable names
2. eLTER Germany encodes depth in cm (the negative VERT_OFFSET is a convention artifact)
3. Centimeters are the natural unit for soil science (most measurement depths are 5-80cm)
4. Positive-downward avoids sign confusion

### 5.2 Height Convention for Atmospheric Sensors

Height is encoded as **positive meters above ground surface**. For the primary harmonized table, only one representative air temperature is selected per site-timestamp (typically the standard meteorological height, ~2m). Multi-height profiles are not in scope for the primary table but can be provided as supplementary data.

### 5.3 Known Depth Metadata Gaps

- **ICOS**: Profile indices (SWC_1..5, TS_1..6) require ancillary metadata lookup per site. Exact depths vary by site installation.
- **SAEON**: Layer indices (_s1 through _s4) have no published depth mapping in the flux tower files. The observation database sensor metadata fields may provide this. **Action needed**: Inspect SAEON observation DB sensor/instrument descriptions for depth information.
- **NEON**: verticalPosition codes require per-site sensor_positions metadata files for resolution.
- **Recommendation**: Where exact depth is unknown, populate `actual_depth_cm` as NULL in the depth metadata table. Do not approximate.

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

### 6.2 Aggregation Methods for Sub-30-Minute Data

When aggregating higher-resolution data (eLTER 10-min, SAEON 5-min DB, NEON 1-min) to 30-minute intervals, the aggregation function depends on the variable type:

| Variable Type | Aggregation Method | Variables |
|---|---|---|
| **Intensive (state)** | Arithmetic mean | air_temperature, relative_humidity, atmospheric_pressure, soil_water_content, soil_temperature, shortwave/longwave radiation (in/out), net_radiation, vapor_pressure_deficit, soil_heat_flux |
| **Extensive (accumulation)** | Sum | precipitation |
| **Directional** | Vector mean (atan2 of sin/cos components) | wind_direction |
| **Scalar speed** | Arithmetic mean | wind_speed |

**Note**: Wind direction requires vector averaging to avoid the 360/0 discontinuity. Scalar averaging of wind direction is incorrect (e.g., mean of 350 and 10 is NOT 180).

### 6.3 Coarser-than-30-Minute Data

Data at coarser resolution (e.g., eLTER Spain daily precipitation) is stored at its native resolution. The timestamp_start and timestamp_end columns define the actual averaging period. Do not interpolate coarse data to 30-minute intervals.

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
| NEON | NaN / null in Parquet |

**Decision**: Use **IEEE 754 NaN** (Not a Number) for all missing values. No sentinel values.

**Rationale**:
1. NaN is the standard for scientific computing (numpy, pandas, R)
2. Sentinel values like -9999 are error-prone (can be accidentally included in calculations)
3. NaN propagates correctly through arithmetic operations
4. All target output formats (Parquet, CSV, NetCDF) support NaN natively

**Conversion required**:
- ICOS: Replace all -9999 with NaN
- SAEON: Replace empty strings and blanks with NaN
- eLTER: Replace blanks with NaN; Parquet NaN already compatible
- TERN: NaN already used natively
- NEON: NaN/null already compatible

**Terminology note**: Throughout this schema, "NaN" refers to IEEE 754 NaN as implemented in scientific computing frameworks (numpy.nan, float('nan'), R's NaN). In database contexts, this maps to SQL NULL. The terms are used interchangeably for the same semantic meaning: "no value present."

---

## 8. Quality Flag Model

Each observation variable in the primary table has an optional companion quality flag column with suffix `_qc`. Quality flags are harmonized to a 4-level scheme:

| Flag Value | Meaning | Description |
|------------|---------|-------------|
| 0 | Good | Passed all quality checks |
| 1 | Suspect | Marginal quality; use with caution |
| 2 | Bad | Failed quality checks; exclude from analysis |
| NaN | Unknown | No QC information available |

### 8.1 Network-Specific QC Mapping Rules

| Network | QC Source | Flag=0 (Good) | Flag=1 (Suspect) | Flag=2 (Bad) |
|---------|----------|---------------|-------------------|---------------|
| **ICOS** | _N (sample count), _SD (std dev) | _N >= 3 and value != -9999 | _N = 1 or 2 (low sample count) | _N = 0 or value = -9999 |
| **SAEON** | *_ss_itc_test (1-7 scale) | ITC test = 1 or 2 | ITC test = 3, 4, or 5 | ITC test = 6 or 7 |
| **eLTER** | FLAGQUA (numeric) | FLAGQUA = 0 | FLAGQUA = 1 | FLAGQUA >= 2 |
| **TERN** | _QCFlag (per variable) | QCFlag = 0 | QCFlag = 1 | QCFlag >= 2 |
| **NEON** | finalQF (0=pass, 1=fail) + component QMs | finalQF = 0 and all component QMs < 10% | finalQF = 0 but any component QM >= 10% | finalQF = 1 |

**Notes**:
- ICOS does not have a dedicated QC flag; quality is inferred from sample count (_N) and the presence of non-sentinel values. _N >= 3 ensures at least 3 valid measurements in the 30-minute window.
- SAEON ITC test values are ordinal (1=best steady-state, 7=worst). The 1-2/3-5/6-7 split follows common eddy covariance practice.
- NEON's component quality metrics (rangeFailQM, persistenceFailQM, etc.) are percentages. The 10% threshold distinguishes occasional vs. systematic quality issues.

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

Disambiguation via the `network` column prevents collision (e.g., FI-Hyy exists in both ICOS and eLTER datasets).

---

## 10. Cross-Network Variable Mapping

| Canonical Name | ICOS | SAEON | eLTER (DE) | eLTER (FI) | eLTER (ES) | eLTER (AT) | TERN | NEON |
|----------------|------|-------|------------|------------|------------|------------|------|------|
| air_temperature | TA | temp_air_avg | Tair50HMP | T336 | TA_A | "Air Temperature [deg C]" | Ta | tempTripleMean |
| relative_humidity | RH | humid_rel_avg | RH50HMP | RH168 | -- | "Air Relative Humidity [%]" | RH | -- |
| atmospheric_pressure | PA | pressure_atm_avg | airpres50 | Pamb0 | -- | "Surface Air Pressure [hPa]" | -- | -- |
| precipitation | P | rain_tot | precip50 | Precip | P_RAIN | -- | Precip | precipBulk |
| wind_speed | WS | wind_speed_avg | WS49_2D | WS336 | -- | "Wind Speed [m s-1]" | Ws | -- |
| wind_direction | WD | wind_dir_avg | WD49_2D | WD336 | -- | "Wind Direction [deg]" | Wd | -- |
| soil_water_content | SWC_1..5 | moisture_soil_s1..s4_avg | SMa010..SMb080 | (SOHYD) | -- | (SOHYD) | Sws_Xcm | VSWCMean |
| soil_temperature | TS_1..6 | temp_soil_s1..s2_avg | STa005..STb080 | (SOHYD) | -- | (SOHYD) | Ts_Xcm | soilTempMean |
| shortwave_radiation_in | SW_IN | rad_short_in_avg | -- | -- | -- | -- | Fsd | -- |
| shortwave_radiation_out | SW_OUT | rad_short_out_avg | -- | -- | -- | -- | Fsu | -- |
| longwave_radiation_in | LW_IN | rad_long_in_avg | -- | -- | -- | -- | Fld | -- |
| longwave_radiation_out | LW_OUT | rad_long_out_avg | -- | -- | -- | -- | Flu | -- |
| net_radiation | NETRAD | rad_net_avg | -- | -- | -- | -- | -- | -- |
| vapor_pressure_deficit | VPD | pressure_vapour_def_avg | -- | -- | -- | -- | -- | -- |
| soil_heat_flux | G_1..2 | heat_flux_ground | -- | -- | -- | -- | Fg | -- |
| soil_texture_sand | ANCILLARY | -- | SOGEO | SOGEO | SOGEO | -- | -- | sandTotal |
| soil_texture_clay | ANCILLARY | -- | SOGEO | SOGEO | SOGEO | -- | -- | clayTotal |
| soil_texture_silt | ANCILLARY | -- | SOGEO | SOGEO | SOGEO | -- | -- | siltTotal |

**eLTER Standard Observation module sources**: SOATM = atmosphere variables (air temp, RH, wind, pressure, precip); SOHYD = hydrology variables (soil moisture, soil temperature); SOGEO = geology/soil (texture, particle size).

**Soil heat flux absence in eLTER**: Confirmed absent from all profiled eLTER sites. eLTER SOHYD focuses on soil moisture and temperature, not heat flux.

---

## 11. Open Questions

1. **SAEON soil layer depths**: The flux tower files use ordinal indices (_s1 through _s4) with no published depth mapping. The observation database sensor metadata may contain this information. Requires follow-up data inspection.

2. **eLTER Finland sensor ID resolution**: Codes like T336, RH168 require METHOD parquet file inspection to resolve to physical quantities and measurement heights.

3. **Snow depth**: Available in ICOS high-latitude sites (D_SNOW) and possibly in unprofiled NEON data products. Not included in v1 schema. Could be added as a Tier 2 variable in a future revision if cross-network coverage is confirmed.

4. **ICOS SWC near 0.4 threshold**: ICOS FI-Hyy SWC_5 converts to 0.4086 m3/m3, which is at NEON's sensor reliability threshold. The schema includes a validation note but does not reject these values, as high SWC is physically valid in organic/clay soils. Implementations should flag but not exclude values > 0.4.

---

## 12. Revision History (Draft 1 -> Draft 2)

| Change | Category | Description | Reviewer Reference |
|--------|----------|-------------|-------------------|
| RH demoted to Tier 2 | Critical fix | NEON does not provide RH in profiled data products. Tier 1 now has 4 variables (air_temp, precip, SWC, soil_temp) | C2 |
| Section 4.1 title fixed | Critical fix | Changed "Tidy Long Format" to "Wide Format with Depth-in-Column-Name" to match actual design decision | C1 |
| NaN/NULL terminology clarified | Critical fix | Added terminology note in Section 7 explaining NaN = NULL equivalence | C3 |
| Atmospheric pressure corrected to 3/5 | Coverage fix | TERN does not provide surface pressure in L3 profile | S3 |
| Net radiation corrected to 2/5 | Coverage fix | TERN Fa (available energy) != net radiation | S2 |
| VPD corrected to 2/5 | Coverage fix | Only ICOS and SAEON provide VPD directly | S1 |
| Soil heat flux eLTER confirmed absent | Coverage fix | eLTER SOHYD does not include heat flux | S4 |
| Non-integer depth guidance added | Enhancement | Section 4.1 specifies nearest-integer column names + exact depth in metadata | S5 |
| Aggregation methods specified | Enhancement | Section 6.2 defines mean/sum/vector-mean by variable type | S6 |
| QC flag mappings detailed | Enhancement | Section 8.1 provides specific thresholds per network | S7 |
| profile_id column added | Enhancement | Handles eLTER Germany dual soil profiles (A and B) | S5 |
| Variable-width schema note added | Enhancement | Section 4.1 acknowledges site-adaptive column sets | S5 |
| Excluded variables documented | Enhancement | Section 2.3 lists variables considered but not included | Review suggestion |
| SAEON site count clarified | Minor fix | "8 flux towers" instead of "8-9" | Review S1.1 |
| eLTER SO module sources noted | Enhancement | Mapping table notes SOATM/SOHYD/SOGEO provenance | Review suggestion |
| eLTER Austria SWC confirmed percent | Clarification | Section 3.2 confirms Austria [volpercent] = percent | Reviewer Q1 |
| ICOS 0.4 threshold note added | Clarification | Section 3.2 and Open Question 4 address FI-Hyy boundary case | Reviewer Q2 |
| Open Question 1 (multi-height) removed | Cleanup | Already resolved by Section 5.2 (single representative height) | Review Section 11 |

---

## Appendix A: Conversion Formulas

| Source | Target | Formula |
|--------|--------|---------|
| SWC percent -> fraction | ICOS, SAEON, eLTER -> canonical | value / 100.0 |
| VPD hPa -> kPa | SAEON -> canonical | value / 10.0 |
| eLTER depth negative -> positive cm | eLTER (DE, AT) -> canonical | abs(VERT_OFFSET) or depth_cm = -1 * VERT_OFFSET |
| -9999 -> NaN | ICOS -> canonical | replace(-9999, NaN) |
| Empty/blank -> NaN | SAEON, eLTER CSV -> canonical | replace("", NaN); replace(blank, NaN) |
| YYYYMMDDHHmm -> ISO 8601 | ICOS, SAEON flux -> canonical | parse and format as YYYY-MM-DDTHH:MM:SSZ |
| Wind direction sub-30min -> 30min | eLTER, SAEON DB, NEON -> canonical | atan2(mean(sin(dir_rad)), mean(cos(dir_rad))) * 180/pi |

---

**End of Draft 2**
