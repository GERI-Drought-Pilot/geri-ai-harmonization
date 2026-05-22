# Derived Harmonization Schema -- FINAL

**Date:** 2026-05-05
**Derived from:** 5 network profiles (ICOS, SAEON, eLTER, TERN, NEON)
**Review iteration:** ONTOLOGY_REVIEW_1 (REVISE, 19 issues) -> Draft 2 (all 19 addressed) -> FINAL
**Decisions documented:** 23 (D001--D023 in DECISION_LOG.json)

This is a copy of `DERIVED_SCHEMA_DRAFT_2.md` -- assumed accepted since all 19 issues are fixed.

---

## 1. Tier Classification

A variable is **Tier 1a** if data is concretely confirmed in 4+ network profiles. **Tier 1b** if it is known-available in 4+ networks but the profiled file did not contain data (e.g., NEON air-temperature parquet was 0 bytes). **Tier 2** if it appears in 3 or 4 networks. **Tier 3** is sparse coverage (1--2 networks) -- noted but not part of the canonical core.

### Tier 1a -- Data-Confirmed Core Variables

| Canonical Name | Description | ICOS | SAEON | eLTER | TERN | NEON |
|---|---|---|---|---|---|---|
| `precipitation` | Liquid-equivalent precipitation total | P | rain_tot | Precip / P_RAIN / precip50 / `Precipitation` | Precip | precipBulk |
| `soil_water_content` | Volumetric soil water content | SWC_1..7 | moisture_soil_s1..s4_avg | SMa### / SMb### / soilmoisture[volpercent] / `soil water content` | Sws (+ Sws_*cm_*) | VSWCMean |
| `soil_temperature` | Soil temperature at depth | TS_1..8 | temp_soil_s1..s2_avg | STa### / STb### / soiltemp[degC] / `soil water temperature` | Ts (+ Ts_*cm_*) | soilTempMean |

### Tier 1b -- Known-Available (4+ networks; NEON not profiled)

| Canonical Name | Description | ICOS | SAEON | eLTER | TERN | NEON |
|---|---|---|---|---|---|---|
| `air_temperature` | Above-ground air temperature | TA | temp_air_avg | Tair*HMP / TA_A,Z,X / `Air Temperature` / T### | Ta (+ Ta_HMP_*) | DP1.00003 (file empty in extract) |
| `relative_humidity` | Air relative humidity | RH | humid_rel_avg | RHIRGA168 / RH168 / `Air Relative Humidity` | RH | (not profiled) |
| `atmospheric_pressure` | Surface barometric pressure | PA | pressure_atm_avg | Pamb / Pamb0 / `Surface Air Pressure` | ps | (not profiled) |
| `wind_speed` | Horizontal wind speed | WS | wind_speed_avg | WS / WS336 / `Wind Speed` | **Ws** | (not profiled) |
| `wind_direction` | Compass wind direction | WD | wind_dir_avg | WD / WD336 / `Wind Direction` | **Wd** | (not profiled) |

### Tier 2 -- Common Extension Variables (3+ networks)

| Canonical Name | Description | Networks (raw names) |
|---|---|---|
| `shortwave_radiation_incoming` | SW down | ICOS (SW_IN), SAEON (rad_short_in_avg), TERN (Fsd) |
| `shortwave_radiation_outgoing` | SW reflected | ICOS (SW_OUT), SAEON (rad_short_out_avg), TERN (Fsu) |
| `longwave_radiation_incoming` | LW down | ICOS (LW_IN), SAEON (rad_long_in_avg), TERN (Fld) |
| `longwave_radiation_outgoing` | LW up | ICOS (LW_OUT), SAEON (rad_long_out_avg), TERN (Flu) |
| `net_radiation` | Net all-wave radiation | ICOS (NETRAD), SAEON (rad_net_avg), TERN (Fn) |
| `vapor_pressure_deficit` | VPD | ICOS (VPD), SAEON (pressure_vapour_def_avg), TERN (VPD) |
| `soil_heat_flux` | Ground heat flux | ICOS (G_1, G_2), SAEON (heat_flux_ground), TERN (Fg) |
| `latent_heat_flux` | LE | SAEON (heat_flux_lat_corr), TERN (Fe) [+ ICOS via EC product] |
| `sensible_heat_flux` | H | SAEON (heat_flux_sens_corr), TERN (Fh) [+ ICOS via EC product] |
| `co2_flux` | NEE/Fc | SAEON (co2_flux_umol), TERN (Fco2) [+ ICOS via EC product] -- see §3.1 sign caveat |
| `friction_velocity` | u* | SAEON (u_star_avg), TERN (ustar) [+ ICOS via EC product] |
| `par_incoming` | PPFD | ICOS (PPFD_IN), SAEON (rad_photo_active_avg), TERN (PAR) |
| `soil_texture_sand` | % sand | ICOS partial (SOIL_TEX_SAND, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_silt` | % silt | ICOS partial (SOIL_TEX_SILT, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_clay` | % clay | ICOS partial (SOIL_TEX_CLAY, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_class` | Categorical (sandy loam, etc.) | eLTER (FI, ES, DE), TERN (soilTextureGrade), NEON, ICOS partial |
| `soil_bulk_density` | Bulk density | ICOS (SOIL_CHEM_BD), eLTER ES, NEON (bulkDensExclCoarseFrag) |
| `soil_organic_carbon` | Organic C | ICOS (SOIL_CHEM_C_ORG), eLTER ES, NEON (megapit) |

### Tier 3 -- Network-specific or sparse

- ICOS: D_SNOW, WTD, multi-level TA_1..9, vegetation chemistry, biomass, LAI, canopy height
- SAEON: u_star, fetch_*, Monin-Obukhov, planetary boundary layer height, sonic-derived T variants, wind components u/v/w
- eLTER: cation exchange capacity, soil pH, base saturation
- TERN: GPP_*, NEP_*, AH (absolute humidity)
- NEON: science review flags, expanded uncertainty per measurement, megapit-only carbonateClay, sand size sub-classes
- **`albedo`** -- only 2 networks (ICOS as `fraction`; SAEON as `pcnt` -- unit mismatch). If ever promoted, canonical would be unitless fraction (0--1); SAEON would divide by 100.

---

## 2. Soil Texture -- Tier Decision

**Evidence:**
- ICOS: `SOIL_TEX_SAND`, `SOIL_TEX_SILT`, `SOIL_TEX_CLAY` for **6 of 40 sites** (BE-Bra, BE-Dor, CZ-BK1, FR-Fon, SE-Htm, SE-Svb).
- SAEON: confirmed absent.
- eLTER: present in DE, ES, AT (Wentworth, requires aggregation), FI (category only).
- TERN: 242-row xlsx with sand/silt/clay percentages.
- NEON: 452-row parquet with sandTotal/clayTotal/siltTotal.

**Decision:** **Tier 2 (4 of 5 networks: ICOS partial, eLTER, TERN, NEON; SAEON absent).**

---

## 3. Canonical Schema -- Variable Definitions

### 3.1 Core measurement variables

| Canonical name | Canonical unit | Type | Notes |
|---|---|---|---|
| `air_temperature` | `degC` | float | Above-canopy; primary sensor preferred |
| `relative_humidity` | `percent` (0--100) | float | |
| `atmospheric_pressure` | `hPa` | float | Station-level. **ICOS native is kPa -- multiply by 10 (see §4.2).** |
| `wind_speed` | `m s-1` | float | |
| `wind_direction` | `degree` (0--360) | float | Compass bearing |
| `precipitation` | `mm` | float | Per measurement interval. Sum (never mean) when aggregating. |
| `soil_water_content` | `m3 m-3` (fraction 0--1) | float | See §4.1 -- includes per-site exceptions for eLTER FI and ICOS FI-Sod. |
| `soil_temperature` | `degC` | float | |
| `shortwave_radiation_incoming` | `W m-2` | float | Positive = downward |
| `shortwave_radiation_outgoing` | `W m-2` | float | Positive = upward |
| `longwave_radiation_incoming` | `W m-2` | float | Positive = downward |
| `longwave_radiation_outgoing` | `W m-2` | float | Positive = upward |
| `net_radiation` | `W m-2` | float | Positive = net downward |
| `par_incoming` | `umol m-2 s-1` | float | |
| `vapor_pressure_deficit` | `hPa` | float | See §4.3 -- ICOS native unit pending empirical verification. |
| `soil_heat_flux` | `W m-2` | float | **Sign: positive = upward (PROVISIONAL** -- per-network verification required). |
| `latent_heat_flux` | `W m-2` | float | Positive = away from surface |
| `sensible_heat_flux` | `W m-2` | float | Positive = away from surface |
| `co2_flux` | `umol m-2 s-1` | float | **Sign: negative = uptake (PROVISIONAL** -- per-network native sign must be verified). |
| `friction_velocity` | `m s-1` | float | |
| `soil_texture_sand` | `percent` (0--100) | float | Mass % sand, USDA |
| `soil_texture_silt` | `percent` (0--100) | float | |
| `soil_texture_clay` | `percent` (0--100) | float | |
| `soil_texture_class` | string | categorical | USDA texture triangle |
| `soil_bulk_density` | `g cm-3` | float | |
| `soil_organic_carbon` | `percent` (0--100) | float | Mass % of dry soil |

### 3.2 Required dimensions (every observations row)

| Field | Type | Notes |
|---|---|---|
| `network` | string | One of {ICOS, SAEON, eLTER, TERN, NEON} |
| `site_id` | string | Network-native site code |
| `latitude` | float | WGS84 decimal degrees |
| `longitude` | float | WGS84 decimal degrees |
| `elevation_m` | float | Site elevation in meters |
| `timestamp_start` | ISO 8601 UTC | Beginning of averaging interval (see §5) |
| `timestamp_end` | ISO 8601 UTC | End of averaging interval |
| `variable` | string | Canonical name from §3.1 |
| `value` | float | Numeric measurement |
| `unit` | string | Canonical unit from §3.1 |
| `depth_m` | float | Below-surface depth (negative; see §9). NULL for atmospheric. |
| `height_m` | float | Above-surface height (positive). NULL for soil. |
| `quality_flag` | int | 0=pass, 1=suspect, 2=fail, 9=missing/unknown (mapping in §8) |
| `uncertainty` | float | Optional expanded uncertainty (k=2) in canonical unit |
| `sensor_id` | string | Optional sensor identifier |
| `replicate` | string | Optional replicate code (a/b/c, 1/2/3, N/S) |
| `data_product` | string | Optional source product (e.g., METEO_L2, DP1.00094, SOHYD-168) |

---

## 4. Per-Network Unit Conversion Tables

### 4.1 Soil Water Content (SWC) -- m3 m-3 (fraction)

| Network / Site | Native unit | Sample range | Actual unit | Conversion |
|---|---|---|---|---|
| ICOS (general) | unlabeled, ~0--100 | 11.47--99.16 | percent | value / 100.0 |
| **ICOS (FI-Sod)** | unlabeled | **0.52--0.58** | **fraction** (anomaly) | **passthrough** (D014) |
| SAEON | `pcnt` | 5.17--35 | percent | value / 100.0 |
| eLTER (DE) | `%` | 26.46--26.59 | percent | value / 100.0 |
| eLTER (AT) | `volpercent` | 29.63--31.18 | percent | value / 100.0 |
| **eLTER (FI)** | `%` (label is wrong) | **0.003--0.689** | **fraction** | **passthrough** (D013) |
| eLTER (ES) | n/a | n/a | structurally absent | n/a |
| TERN | `m^3/m^3` | 0--1.009 | fraction | passthrough; clip > 1.0 to 1.0 with QF=1 |
| NEON | unitless fraction | 0--0.9971 | fraction | passthrough |

#### Implementation safeguard
Before applying any per-network rule, compute per-site min/max of pre-conversion SWC. **If max < 1.0, treat the site as already fraction (passthrough)**, regardless of declared label.

#### Validation
- Range: 0.0 <= value <= 1.0
- Suspect (QF=1): 1.0 < value <= 1.05
- Fail (QF=2): value > 1.05 or < 0
- Sentinels: ICOS `-9999` -> NULL; TERN `-9999.0` -> NULL

### 4.2 Atmospheric Pressure -- hPa

| Network | Native unit | Sample range | Conversion |
|---|---|---|---|
| **ICOS** | **kPa** | 96--98 | **value * 10.0** |
| SAEON | `hpa` | -- | passthrough |
| eLTER | hPa | -- | passthrough |
| TERN | hPa | 980--1020 | passthrough |
| NEON | not profiled | -- | n/a |

Validation: pass [800, 1050]; suspect [300, 800) or (1050, 1100]; fail < 300 or > 1100.

### 4.3 VPD -- hPa

| Network | Declared | Conversion |
|---|---|---|
| ICOS | hPa ("Likely Unit") | passthrough provisionally; verify empirically (mean > 25 hPa or < 0.5 hPa flags reinvestigation) |
| SAEON | `hpa` | passthrough |
| TERN | hPa | passthrough |

### 4.4 Other variables (passthrough)

Air temperature `degC`; RH `percent`; wind speed `m s-1`; wind direction `degree`; soil temp `degC`; radiation `W m-2`; PAR `umol m-2 s-1`; precipitation `mm`. All passthrough across networks (numeric units are aliases).

---

## 5. Temporal Model

ISO 8601 in UTC; `timestamp_start` + `timestamp_end`; default canonical 30 minutes.

### Per-network timestamp conversions

| Network | Native | Conversion |
|---|---|---|
| ICOS | YYYYMMDDHHmm | parse as UTC |
| SAEON | ISO 8601 + numeric | use ISO Timestamp as end; subtract 30 min for start |
| eLTER FI | datetime64[us, UTC] | passthrough |
| eLTER DE | ISO 8601 + Z | passthrough |
| eLTER ES | YYYY-MM-DD | start = T00:00:00Z, end = T23:59:59Z |
| eLTER AT | ISO 8601 +01:00 (CET) | **convert to UTC** |
| TERN | NetCDF numeric | decode using NetCDF units attribute |
| NEON | datetime UTC | passthrough |

### Resolution policy

| Scenario | Rule |
|---|---|
| Native 30-min | passthrough |
| Finer than 30-min | aggregate to 30-min: SUM for precipitation, MEAN for state vars |
| **Coarser than 30-min, finer than daily (e.g., NEON hourly precip)** | **Store at native resolution.** Do NOT disaggregate. Use `data_product` to carry native resolution. |
| Daily | keep at daily; do not interpolate |

For precipitation: always SUM. Splitting hourly into 30-min records is forbidden.

---

## 6. Validation Ranges

| Variable | Pass | Suspect | Fail |
|---|---|---|---|
| air_temperature | [-60, 50] degC | (-80, -60] or (50, 60] | < -80 or > 60 |
| relative_humidity | [0, 100] % | (100, 105] | < 0 or > 105 |
| atmospheric_pressure | [800, 1050] hPa | [300, 800) or (1050, 1100] | < 300 or > 1100 |
| wind_speed | [0, 60] m/s | (60, 113] | < 0 or > 113 |
| wind_direction | [0, 360) degrees | -- | < 0 or >= 360 |
| precipitation | [0, 200] mm/30-min | (200, 500] | < 0 or > 500 |
| soil_water_content | [0, 1.0] m3/m3 | (1.0, 1.05] | < 0 or > 1.05 |
| soil_temperature | [-40, 60] degC | (-50, -40] or (60, 80] | < -50 or > 80 |
| shortwave_radiation_incoming | [0, 1400] W/m2 | (-50, 0) or (1400, 1500] | < -50 or > 1500 |
| shortwave_radiation_outgoing | [0, 1100] W/m2 | (-50, 0) or (1100, 1500] | < -50 or > 1500 |
| longwave_radiation_incoming | [100, 600] W/m2 | (50, 100) or (600, 700] | < 50 or > 700 |
| longwave_radiation_outgoing | [100, 700] W/m2 | (50, 100) or (700, 800] | < 50 or > 800 |
| net_radiation | [-300, 1100] W/m2 | -- | < -500 or > 1300 |
| par_incoming | [0, 2500] umol/m2/s | (-100, 0) or (2500, 3000] | < -100 or > 3000 |
| vapor_pressure_deficit | [0, 60] hPa | (60, 100] | < 0 or > 100 |
| soil_heat_flux | [-300, 300] W/m2 | (-500, -300) or (300, 500) | < -500 or > 500 |
| latent_heat_flux | [-100, 800] W/m2 | (-200, -100) or (800, 1000] | < -200 or > 1000 |
| sensible_heat_flux | [-300, 800] W/m2 | -- | < -500 or > 1000 |
| co2_flux | [-50, 50] umol/m2/s | (-100, -50) or (50, 100) | < -100 or > 100 |
| friction_velocity | [0, 3] m/s | (3, 5] | < 0 or > 5 |
| soil_texture_sand/silt/clay | [0, 100] % | -- | < 0 or > 100 (sum-to-100 +/- 1%) |
| soil_bulk_density | [0.5, 2.5] g/cm3 | (0.1, 0.5) or (2.5, 3.0] | < 0.1 or > 3.0 |
| soil_organic_carbon | [0, 60] % | -- | < 0 or > 60 |

---

## 7. Missing Data Convention

NULL canonical. ICOS/TERN -9999 -> NULL; SAEON empty -> NULL; eLTER NaN -> NULL; NEON native NULL -> NULL. `quality_flag=9` carries missing reason.

---

## 8. Quality Flag Mapping

Canonical: `0=pass, 1=suspect, 2=fail, 9=missing`.

| Network | Native field | Native | Mapping (lookup) |
|---|---|---|---|
| ICOS | (sentinel-driven) | -9999 = missing | -9999 -> {NULL, 9}; else 0 |
| SAEON | `*_ss_itc_test` | 1=good, 2=uncertain, 3=poor, 9=missing | **1->0, 2->1, 3->2, 9->9** |
| eLTER | `FLAGQUA` | 0=good, 1=other | **0->0, 1->1** (suspect, NOT fail) |
| eLTER | `FLAGSTA` | undocumented | drop on ingest with logged justification |
| TERN | `{var}_QCFlag` | 0=good; 1+ undocumented | 0->0, 1..8->1, >=9->2 (provisional) |
| NEON | `finalQF` | 0=pass, 1=fail | 0->0, 1->2 |
| NEON | `VSWCFinalQFSciRvw` | 0=pass, 1=suspect, 2=fail | direct passthrough |

Combining multiple flag fields per measurement: take the maximum canonical flag.

---

## 9. Depth and Height Convention

`depth_m` (negative meters below surface) and `height_m` (positive meters above surface). One column populated per row.

### Per-network conversions

| Network | Native | Conversion |
|---|---|---|
| ICOS (METEO) | sensor index, no depth | depth_m=NULL; index in `replicate`; external lookup pending |
| ICOS (ANCILLARY) | positive cm | depth_m = -value_cm / 100 |
| SAEON | `_s1`..`_s4` codes | depth_m=NULL; code in `replicate`; external lookup pending |
| eLTER FI | negative cm | depth_m = value_cm / 100 |
| eLTER DE (SOHYD) | suffix `010`, `020`, ... | parse cm -> /100 -> negate |
| eLTER DE (SOATM) | "150--5000" | resolve mm vs cm before harmonization |
| eLTER AT | negative cm | depth_m = value_cm / 100 |
| TERN | suffix `_5cm`/`_10cm`/... AND NetCDF `height` attribute | prefer signed `height` attribute (already meters) |
| **NEON** | `verticalPosition` is a CODE ("501"--"509"), NOT meters | **join with `all_sensor_positions_00044_00006` on siteID + HOR.VER**; use metadata `height` column |

### Soil texture depths (in `soil_profiles`)

All normalized to negative meters via `depth_top_m` and `depth_bottom_m`.

---

## 10. Naming Convention

`snake_case`; units in separate `unit` column; sensor/depth/replicate in structured columns.

---

## 11. Schema Structure

| Table | Purpose |
|---|---|
| `observations` | Long format: one row per (network, site, timestamp, variable, depth/height, replicate). Columns from §3.2. |
| `sites` | Static: network, site_id, name, lat/lon, elevation, biome/land_cover, start/end dates. |
| `soil_profiles` | Static: network, site_id, horizon_id, depth_top_m, depth_bottom_m, soil_texture_*, soil_bulk_density, soil_organic_carbon, soil_type_classification, sample_date. |
| `sensors` | Optional: network, site_id, sensor_id, variable, depth/height, start/end datetimes, manufacturer, model. |

---

## 12. Summary of Conventions

| Aspect | Choice |
|---|---|
| Naming | `snake_case`, no units in name |
| Time | ISO 8601 UTC; 30-min default; explicit start/end; coarser-than-30-min stored at native resolution |
| Missing | NULL; quality_flag=9 |
| Quality flags | {0, 1, 2, 9}; per-network lookup in §8 |
| Depth | negative meters |
| Height | positive meters |
| SWC unit | m3 m-3 (eLTER FI and ICOS FI-Sod are passthrough exceptions) |
| Atmospheric pressure | hPa; ICOS x10 from kPa |
| VPD | hPa; ICOS provisional passthrough |
| Schema | long-format observations + static sites/soil_profiles/sensors |
| Texture tier | **Tier 2 (4 of 5 networks: ICOS partial, eLTER, TERN, NEON; SAEON absent)** |
| Texture units | sand/silt/clay each in `percent` (0--100) |
| CO2 flux convention | negative = uptake (PROVISIONAL) |
| Soil heat flux convention | positive = upward (PROVISIONAL) |
| Validation | per-variable plausibility ranges (§6) |

---

## 13. Open Questions

1. ICOS `SWC_1..7` and `TS_1..8` actual depths -- need site metadata table.
2. SAEON `_s1..s4` actual depths -- need site documentation.
3. eLTER Germany SOATM `VERT_OFFSET` 150--5000 -- mm vs cm.
4. eLTER Spain soil-texture tuple ordering -- need eLTER documentation.
5. TERN QC flag value semantics for non-zero codes.
6. NEON `VSWCFinalQFSciRvw` cross-reference to `science_review_flags_*.csv`.
7. **CO2 flux sign convention** -- per-network verification required (empirical: forested daytime should be negative).
8. **Soil heat flux sign convention** -- per-network verification required (empirical: vegetated summer daytime should be positive).
9. **eLTER FLAGSTA** semantics -- dropped on ingest pending documentation.
10. **ICOS VPD** sample values -- verify hPa vs kPa.
11. **Albedo** unit (Tier 3 future) -- SAEON `pcnt` vs ICOS `fraction`.
12. **ICOS FI-Sod SWC** -- verify with ICOS providers.

---

**End of DERIVED_SCHEMA_FINAL**
