# Derived Harmonization Schema — Draft 1

**Date:** 2026-05-04
**Synthesized from:** 5 network profiles (ICOS, SAEON, eLTER, TERN, NEON)
**Goal:** Unified vocabulary and conventions for harmonizing environmental observations across global Research Infrastructures.

---

## 1. Tier Classification

A variable is **Tier 1** if it appears in **all 5 networks** (or 4/5 with one network having a structural reason for absence). It is **Tier 2** if it appears in **3 or 4 networks**. Tier 3 (1–2 networks) variables are noted but not part of the canonical core schema.

### Tier 1 — Core Variables (all/nearly all networks)

| Canonical Name | Description | ICOS | SAEON | eLTER | TERN | NEON |
|---|---|---|---|---|---|---|
| `air_temperature` | Above-ground air temperature | TA | temp_air_avg | Tair*HMP / TA_Z / Air Temperature / T### | Ta (+ Ta_HMP_*, Ta_SONIC_Av) | (no continuous Ta in profile, but air-temp tower data referenced) |
| `relative_humidity` | Air relative humidity | RH | humid_rel_avg | RH / Air Relative Humidity / RHIRGA168 | RH | (megapit context only — see notes) |
| `atmospheric_pressure` | Surface barometric pressure | PA | pressure_atm_avg | Pamb / Pamb0 / Surface Air Pressure | ps | (not core) |
| `wind_speed` | Horizontal wind speed | WS | wind_speed_avg | WS / WS336 / Wind Speed | ws / u, v | (not core) |
| `wind_direction` | Compass wind direction | WD | wind_dir_avg | WD / WD336 / Wind Direction | wd | (not core) |
| `precipitation` | Liquid-equivalent precipitation total | P | rain_tot | Precip / P_RAIN | Precip | precipBulk |
| `soil_water_content` | Volumetric soil water content | SWC_1..5 | moisture_soil_s1..s4_avg | SMa###/SMb### / soilmoisture[volpercent] | Sws (+ Sws_*cm_*) | VSWCMean |
| `soil_temperature` | Soil temperature at depth | TS_1..6 | temp_soil_s1..s2_avg | STa###/STb### / soiltemp[degC] / soil water temperature | Ts (+ Ts_*cm_*) | soilTempMean |
| `shortwave_radiation_incoming` | Incoming SW (solar) radiation | SW_IN | rad_short_in_avg | (sometimes) | Fsd_Total | (not in profile) |
| `net_radiation` | Net all-wave radiation | NETRAD | rad_net_avg | (varies) | Fn_4cmpt | (not in profile) |

**Notes on Tier 1 universality:**
- NEON's profile focuses on soil + precipitation parquet products; air-temperature/humidity/wind are part of NEON's broader SAAT/2DWSD products and are presumed present at the network level (but not characterized in the supplied profile).
- For the purposes of this draft, `air_temperature`, `relative_humidity`, `wind_speed`, `wind_direction`, `precipitation`, `soil_water_content`, `soil_temperature` are treated as **Tier 1** because they appear with first-class status in 4+ profiles and the fifth network is known to provide them through other products.

### Tier 2 — Common Extension Variables (3+ networks)

| Canonical Name | Description | Networks |
|---|---|---|
| `longwave_radiation_incoming` | LW down | ICOS (LW_IN), SAEON (rad_long_in_avg), TERN (Fld_*) |
| `longwave_radiation_outgoing` | LW up | ICOS (LW_OUT), SAEON (rad_long_out_avg), TERN (Flu_*) |
| `shortwave_radiation_outgoing` | SW reflected | ICOS (SW_OUT), SAEON (rad_short_out_avg), TERN (Fsu_*) |
| `vapor_pressure_deficit` | VPD | ICOS (VPD), SAEON (pressure_vapour_def_avg), TERN (VPD) |
| `soil_heat_flux` | Ground heat flux | ICOS (G_1, G_2), SAEON (heat_flux_ground), TERN (Fg_*) |
| `latent_heat_flux` | LE | SAEON (heat_flux_lat_corr), TERN (LE) [+ ICOS via EC product] |
| `sensible_heat_flux` | H | SAEON (heat_flux_sens_corr), TERN (H) [+ ICOS via EC product] |
| `co2_flux` | NEE/Fc | SAEON (co2_flux_umol), TERN (Fc, NEE) [+ ICOS via EC product] |
| `friction_velocity` | u* | SAEON (u_star_avg), TERN (ustar) [+ ICOS via EC product] |
| `albedo` | Surface albedo | ICOS (ALB), SAEON (albedo) — only 2; **drop to Tier 3** |
| `par_incoming` | Photosynthetic photon flux density | ICOS (PPFD_IN), SAEON (rad_photo_active_avg), TERN (PAR_total) |
| `soil_texture_sand` | % sand | ICOS (SOIL_TEX via tuple) [partial], eLTER DE/ES, TERN (sand_percentage), NEON (sandTotal) |
| `soil_texture_silt` | % silt | eLTER DE/ES, TERN, NEON |
| `soil_texture_clay` | % clay | eLTER DE/ES, TERN, NEON |
| `soil_texture_class` | Categorical class (sandy loam, etc.) | eLTER (FI, ES, DE), TERN (soilTextureGrade), NEON (megapit horizonName-related) |
| `soil_bulk_density` | Bulk density | ICOS (SOIL_CHEM_BD), eLTER ES (dry bulk density), NEON (bulkDensExclCoarseFrag) |
| `soil_organic_carbon` | Organic C | ICOS (SOIL_CHEM_C_ORG), eLTER ES (soil organic carbon content), NEON (megapit) |

### Tier 3 — Network-specific or sparse (kept for traceability, not in core schema)

- ICOS: D_SNOW, WTD, multi-level TA_1..9, vegetation chemistry, biomass, LAI, canopy height
- SAEON: u_star, fetch_*, Monin-Obukhov, planetary boundary layer height, sonic-derived T variants, wind components u/v/w
- eLTER: cation exchange capacity, soil pH, base saturation
- TERN: GPP_*, NEP_*, AH (absolute humidity)
- NEON: science review flags, expanded uncertainty per measurement, megapit-only carbonateClay, sand size sub-classes

---

## 2. Soil Texture — Tier Decision

**Evidence:**
- **ICOS:** SOIL_TEX_ROCK present, but sand/silt/clay numeric fractions **not** in METEO ANCILLARY (per profile §2 and §3 "Missing soil texture numeric columns").
- **SAEON:** **Confirmed absent** — "No soil texture data found in any SAEON CSV files."
- **eLTER:** Present in DE (separate rows for sand/silt/clay %), ES (string tuple), AT (Wentworth particle-size classes — different scheme), FI (texture category only).
- **TERN:** `tern_soil_texture_data.xlsx` with sand_percentage, clay_percentage, silt_percentage.
- **NEON:** `sandTotal`, `clayTotal`, `siltTotal` (% lab-analyzed, sparse 452 records).

**Decision:** Soil texture (sand/silt/clay %) is **Tier 2** (present in 3 of 5 networks with comparable USDA-style fractions: eLTER, TERN, NEON; partially in ICOS via category). Austria's Wentworth scheme requires aggregation to 3-class before harmonization. SAEON is structurally absent.

`soil_texture_class` (categorical, e.g. "Sandy loam") is **Tier 2** (eLTER, TERN, NEON, ICOS partial).

---

## 3. Canonical Schema — Variable Definitions

### 3.1 Core measurement variables (Tier 1 + selected Tier 2)

| Canonical name | Canonical unit | Type | Notes |
|---|---|---|---|
| `air_temperature` | `degC` | float | Above-canopy air temp; primary sensor preferred when multiple |
| `relative_humidity` | `percent` (0–100) | float | |
| `atmospheric_pressure` | `hPa` | float | Station-level (not sea-level corrected unless documented) |
| `wind_speed` | `m s-1` | float | |
| `wind_direction` | `degree` (0–360) | float | Compass bearing |
| `precipitation` | `mm` | float | Per measurement interval (typically 30 min) |
| `soil_water_content` | **`m3 m-3`** (fraction 0–1) | float | See §4 for unit-decision rationale |
| `soil_temperature` | `degC` | float | |
| `shortwave_radiation_incoming` | `W m-2` | float | |
| `shortwave_radiation_outgoing` | `W m-2` | float | |
| `longwave_radiation_incoming` | `W m-2` | float | |
| `longwave_radiation_outgoing` | `W m-2` | float | |
| `net_radiation` | `W m-2` | float | |
| `par_incoming` | `umol m-2 s-1` | float | |
| `vapor_pressure_deficit` | `hPa` | float | Convert from kPa where needed (×10) |
| `soil_heat_flux` | `W m-2` | float | Sign convention: positive = upward |
| `latent_heat_flux` | `W m-2` | float | |
| `sensible_heat_flux` | `W m-2` | float | |
| `co2_flux` | `umol m-2 s-1` | float | Convention: negative = uptake |
| `friction_velocity` | `m s-1` | float | |
| `soil_texture_sand` | `percent` (0–100) | float | Mass % sand, USDA particle-size cutoffs |
| `soil_texture_silt` | `percent` (0–100) | float | |
| `soil_texture_clay` | `percent` (0–100) | float | |
| `soil_texture_class` | string | categorical | USDA texture triangle class names |
| `soil_bulk_density` | `g cm-3` | float | |
| `soil_organic_carbon` | `percent` (0–100) | float | Mass % of soil dry mass |

### 3.2 Required dimensions (every measurement row must carry)

| Field | Type | Notes |
|---|---|---|
| `network` | string | One of {ICOS, SAEON, eLTER, TERN, NEON} |
| `site_id` | string | Network-native site code |
| `latitude` | float | WGS84 decimal degrees |
| `longitude` | float | WGS84 decimal degrees |
| `elevation_m` | float | Site elevation above sea level (meters) |
| `timestamp_start` | ISO 8601 UTC | Beginning of averaging interval (see §5) |
| `timestamp_end` | ISO 8601 UTC | End of averaging interval |
| `variable` | string | Canonical name from §3.1 |
| `value` | float | Numeric measurement |
| `unit` | string | Canonical unit from §3.1 |
| `depth_m` | float | Below-surface depth (negative; see §7). NULL for atmospheric vars. |
| `height_m` | float | Above-surface height (positive). NULL for soil vars. |
| `quality_flag` | int | 0 = pass, 1 = suspect, 2 = fail, 9 = missing/unknown |
| `uncertainty` | float | Optional expanded uncertainty in canonical unit (NULL when not provided) |
| `sensor_id` | string | Optional sensor identifier (HMP, SONIC, EC100, IRGA, etc.) |
| `replicate` | string | Optional replicate code (a/b/c, 1/2/3, N/S) |

---

## 4. SWC Unit Decision — Fraction (0–1) vs. Percent (0–100)

### Evidence per network

| Network | Native unit | Sample range | Source citation |
|---|---|---|---|
| **ICOS** | unlabeled, range ~0–100 | SWC_1..5: 29.63, 33.94, 34.88, 44.46, 40.87 | "dimensionless/%; ~0-100"; profile §1 SWC row |
| **SAEON** | `pcnt` (percent) | moisture_soil_s1_avg: 34.5–34.8 | profile row 23, "values suggest 0–100 scale" |
| **eLTER (DE)** | `%` (volumetric percent) | SMa###: 20–35 | profile §SOHYD-168 Germany, "Soil Moisture Units: Volumetric percentage (0-100%, not fraction)" |
| **eLTER (AT)** | `volpercent` | soilmoisture[volpercent]: 1.0–55.44 | profile §SOHYD-168 Austria |
| **TERN** | `m3/m3` (fraction) | Sws: 0 to 1.0086 | profile §1.3, "Units are FRACTION (m³/m³), NOT percentage" |
| **NEON** | unitless fraction | VSWCMean: 0.0–0.9971 | profile §SOIL MOISTURE, "VSWCMaximum max value is 1.0, not 100.0" |

**Tally:** 3 networks (ICOS, SAEON, eLTER) report SWC as percent (0–100). 2 networks (TERN, NEON) report as fraction (0–1). The two are mathematically equivalent (×100).

### Decision: **Canonical unit = `m3 m-3` (fraction, 0–1)**

### Rationale
1. **CF Conventions and SI alignment.** The CF standard name `volume_fraction_of_water_in_soil` has canonical unit `1` (dimensionless ratio), expressed as `m3 m-3`. Adopting fraction aligns the harmonized schema with the dominant scientific-data standard (used by NetCDF-CF, CMIP, FLUXNET, and increasingly by ICOS-ETC's own L4 products).
2. **Avoids precision loss.** Fractions preserve the natural numerical resolution of capacitance/TDR sensors, which produce ε → θ in the 0–1 range natively. Networks reporting "percent" are doing a ×100 cosmetic transform on top of fraction-domain measurements.
3. **TERN and NEON are already correct.** Two of five networks (TERN, NEON) already store fraction. Choosing percent would force a destructive ×100 round on those data; choosing fraction only requires a simple ÷100 on ICOS/SAEON/eLTER values.
4. **Disambiguates "percent of what".** "%" is overloaded — it can mean volumetric, gravimetric, or saturation percent. Fraction (m³/m³) is unambiguously volumetric.
5. **Conversion is trivial and lossless** in either direction; the choice is about which form is canonical, not about feasibility.

### Conversion rules for non-canonical inputs
- ICOS `SWC_*` (assumed %): `value_canonical = value_native / 100.0`
- SAEON `moisture_soil_s*_avg` (`pcnt`): `value_canonical = value_native / 100.0`
- eLTER `SMa###`/`SMb###` and Austria `soilmoisture[volpercent]`: `value_canonical = value_native / 100.0`
- TERN `Sws`: passthrough (already `m3 m-3`); clip values >1.0 to 1.0 with a quality flag of 1 (TERN sample shows 1.0086 oversaturation)
- NEON `VSWCMean`: passthrough

### Validation rules
- Range: 0.0 ≤ value ≤ 1.0 (flag suspect if 1.0 < value ≤ 1.05; flag fail if > 1.05 or < 0)
- Sentinel handling: ICOS `-9999` → NULL; TERN `-9999.0` → NULL

---

## 5. Temporal Model

**Decision:** Canonical timestamps as **ISO 8601 in UTC** with explicit `timestamp_start` and `timestamp_end` columns. Default canonical resolution: **30 minutes**.

### Per-network conversions

| Network | Native format | Conversion |
|---|---|---|
| **ICOS** | `YYYYMMDDHHMM` (e.g., 201801010000) | Parse as UTC; produce `timestamp_start` and `timestamp_end` from native columns |
| **SAEON** | `YYYY-MM-DDTHH:MM:SS` (capital T) + redundant numeric `timestamp_start`/`timestamp_end` | Use ISO `Timestamp` as `timestamp_end`; subtract 30 min for `timestamp_start`. Drop numeric duplicates. |
| **eLTER (FI parquet)** | datetime64[us, UTC] | Passthrough; format ISO |
| **eLTER (DE CSV)** | `2015-01-01T00:00:00Z` | Already UTC; passthrough |
| **eLTER (ES CSV)** | `YYYY-MM-DD` (daily) | Set `timestamp_start = YYYY-MM-DDT00:00:00Z`, `timestamp_end = YYYY-MM-DDT23:59:59Z` |
| **eLTER (AT CSV)** | `2020-12-01 13:00:00+01:00` (CET) | **Convert to UTC** (subtract 1 h in winter, 2 h DST). Critical: all profiles flag this. |
| **TERN** | NetCDF numeric (seconds-since-epoch) | Decode using NetCDF `units` attribute (e.g., "seconds since 1800-01-01"); convert to UTC ISO |
| **NEON** | datetime UTC (timezone GMT) | Passthrough |

### Resolution policy
- Native 30-min data: keep as-is.
- Native 1–10 min data (eLTER FI, eLTER DE): aggregate to 30-min averages (precipitation: sum) for cross-network analyses; preserve native resolution in a separate raw archive.
- Daily data (eLTER ES): keep at daily resolution; do not interpolate.

---

## 6. Missing Data Convention

**Decision:** Use **`NULL` (database NULL / NaN in pandas / empty in CSV)** in the canonical schema. All sentinel values from native networks are converted to NULL on ingest.

### Per-network conversions
- **ICOS:** `-9999` → NULL (used universally; profile §1)
- **SAEON:** Empty cell → NULL; QC code `9` in `*_ss_itc_test` → quality_flag=9, value retained if present
- **eLTER:** NaN, empty string → NULL
- **TERN:** `-9999.0` → NULL (used consistently per profile §"Known Ambiguities #2")
- **NEON:** Native NULL → NULL

**No magic numbers** appear in the canonical output. A separate `quality_flag` column carries quality information; NULL value with quality_flag=9 means "missing".

---

## 7. Depth and Height Convention

**Decision:**
- **Depth (below surface):** stored as **negative meters** (e.g., −0.10 m for 10 cm depth) in column `depth_m`.
- **Height (above surface):** stored as **positive meters** (e.g., 2.0 m) in column `height_m`.
- Each row carries exactly one of the two (the other is NULL).

### Rationale
- Negative-down is the **CF Convention** for vertical coordinates referenced to the surface and matches eLTER (Finland: VERT_OFFSET −5 to −60 cm; Austria: −10 cm).
- Meters (rather than cm) is SI and aligns with NEON's `verticalPosition` in meters and TERN's NetCDF practice when converted.
- Positive-height for atmospheric sensors avoids sign-flipping ambiguity at the surface (z = 0).

### Per-network conversions

| Network | Native | Conversion |
|---|---|---|
| **ICOS** | `SOIL_TEX_PROFILE_MIN/MAX` in cm (positive) | `depth_m = -value_cm / 100`; for SWC_1..5 / TS_1..6, requires external depth lookup table (profile §3 recommendation) |
| **SAEON** | `_s1`, `_s2`, `_s3`, `_s4` codes (no depth in data) | Requires external lookup. Until then, store layer index in `replicate` field and depth_m=NULL with a "depth-pending" quality flag |
| **eLTER (DE SOATM)** | "150–5000" (units ambiguous: mm or cm) | **Resolve before harmonization** (profile §"Critical Ambiguities #4"); likely millimeters → ÷1000 to meters |
| **eLTER (DE SOHYD)** | VARIABLE-name suffix `010`, `020`, `080` (cm despite mm-named column) | Parse from VARIABLE name as cm → ÷100 → negate → meters |
| **eLTER (FI SOHYD)** | Negative cm | `depth_m = value_cm / 100` (already negative) |
| **eLTER (AT SOHYD)** | Negative cm | Same as Finland |
| **TERN** | Suffix in variable name `_5cm`, `_10cm`, `_100cm`, `_180cm`, `_2m`, etc. | Parse suffix → convert cm to m → negate (soil) or keep positive (atmospheric like `Ta_HMP_2m` → height_m=2.0) |
| **NEON** | `verticalPosition` in meters (positive) | Negate for soil sensors → `depth_m = -float(verticalPosition)`; for atmospheric (precipitation `0.06`), use as `height_m` |

---

## 8. Naming Convention

**Decision:** **`snake_case`** for canonical variable names; units are **NOT** embedded in names (carried in a separate `unit` column).

### Evidence
- ICOS: SCREAMING_SNAKE_CASE (TA, RH, SW_IN), no units in names but uses suffix indices (_1..5)
- SAEON: lower_snake_case (temp_air_avg, moisture_soil_s1_avg), units in some sensor identifiers (`co2_flux_umol`, `evapotrans_per_hour`)
- eLTER: mixed — Parquet UPPER_SNAKE (T336, RH168), CSV mixed (`Tair50HMP`), Austria has units in headers (`Air Temperature [deg C]`)
- TERN: PascalCase abbreviated (Ta, Sws, Ts, Precip) with cm/m suffixes (`Sws_10cm`)
- NEON: camelCase (soilTempMean, VSWCMean, precipBulk)

### Rationale
- `snake_case` is widely used in scientific Python (xarray, pandas), CF Conventions discourage spaces and special characters, and it is unambiguously parseable.
- Avoiding units-in-names prevents the eLTER-Austria style problem (`soilmoisture[volpercent]`) and SAEON's embedded units (`co2_flux_umol`) from leaking into downstream code. The `unit` column is the single source of truth.
- Avoiding camelCase (NEON) vs. PascalCase (TERN) variation; snake_case is a common compromise.
- Multi-level / replicated measurements: encode in **separate columns** (`depth_m`, `replicate`, `sensor_id`) rather than appending to variable name.

---

## 9. Schema Structure — One Long Table vs. Many Wide Tables

**Decision:** **Single long-format table** (`observations`) with the columns in §3.2, plus separate static tables for site/sensor/soil-profile metadata.

### Tables

1. **`observations`** (long format, one row per timestamp × variable × depth × replicate)
   - Core columns from §3.2
   - Optimized for cross-network queries: filter by `variable='soil_water_content'` returns all SWC observations from all networks in canonical units.

2. **`sites`** (static, one row per site)
   - `network`, `site_id`, `site_name`, `latitude`, `longitude`, `elevation_m`, `biome`, `nlcd_class`/`igbp_class`, `start_date`, `end_date`

3. **`soil_profiles`** (static, one row per site × depth horizon)
   - `network`, `site_id`, `horizon_id`, `depth_top_m`, `depth_bottom_m`, `soil_texture_sand`, `soil_texture_silt`, `soil_texture_clay`, `soil_texture_class`, `soil_bulk_density`, `soil_organic_carbon`, `soil_pH`, `soil_type_classification`, `sample_date`

4. **`sensors`** (optional, one row per sensor deployment)
   - `network`, `site_id`, `sensor_id`, `variable`, `depth_m`/`height_m`, `start_datetime`, `end_datetime`, `manufacturer`, `model`

### Rationale
- ICOS METEO is wide (~57–92 columns), SAEON is wide (67 cols), TERN is NetCDF (effectively wide), NEON is long (one variable per parquet), eLTER is mixed (FI parquet wide, DE/ES/AT CSV long).
- A long format is the **lowest-common-denominator** that all five can be reshaped into. eLTER already uses it for DE/ES/AT.
- Long format scales to networks adding new variables without schema migrations.
- Wide format would require a column per (variable × depth × replicate × sensor) combination, exploding to thousands of columns for TERN.
- Static metadata is small enough to keep wide for ergonomic site lookups.

---

## 10. Summary of Conventions

| Aspect | Choice |
|---|---|
| Naming | `snake_case`, no units in name |
| Units in data | Carried in separate `unit` column; canonical units listed in §3.1 |
| Time | ISO 8601 UTC; 30-min default; `timestamp_start` + `timestamp_end` |
| Missing | NULL (no sentinel values); `quality_flag` carries reason |
| Depth | Negative meters (below surface) |
| Height | Positive meters (above surface) |
| SWC unit | `m3 m-3` (fraction 0–1) — see §4 |
| Soil temp | `degC` |
| Schema | Long-format `observations` + static `sites`, `soil_profiles`, `sensors` |
| Texture tier | Tier 2 (4 of 5 networks; SAEON absent) |
| Texture units | Sand/silt/clay each in `percent` (0–100) |

---

## 11. Open Questions / Items Requiring External Lookup

1. ICOS `SWC_1..5` and `TS_1..6` actual depths — need site metadata table (profile §5 recommendation #1).
2. SAEON `_s1..s4` actual depths — need site documentation.
3. eLTER Germany SOATM `VERT_OFFSET` 150–5000 — confirm mm vs cm.
4. eLTER Spain soil-texture tuple ordering (sand, silt, clay) vs (sand, clay, silt) — needs eLTER documentation confirmation.
5. TERN QC flag value semantics (0 = pass, 1–9 = ?) — need TERN QC documentation.
6. NEON `VSWCFinalQFSciRvw` cross-reference to `science_review_flags_*.csv` for flagged date ranges.
7. CO2 flux sign convention — both SAEON and TERN reported as ambiguous in profiles; canonical schema selects negative=uptake (FLUXNET convention) but each network's native sign must be verified.
8. ICOS soil heat flux `G` sign convention (positive = upward) — profile flagged as undocumented.

---

**End of DERIVED_SCHEMA_DRAFT_1**
