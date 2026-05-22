# Derived Harmonization Schema -- Draft 2

**Date:** 2026-05-05
**Revision of:** Draft 1 (2026-05-04)
**Changes from Draft 1:** Addresses ALL 19 issues from ONTOLOGY_REVIEW_1.md (2 CRITICAL, 5 HIGH, 8 MEDIUM, 4 LOW).

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

(Issue 18 fix: TERN wind speed corrected from `ws` to `Ws`; wind direction from `wd` to `Wd` -- NetCDF variable names are case-sensitive.)

### Tier 2 -- Common Extension Variables (3+ networks)

| Canonical Name | Description | Networks (raw names) |
|---|---|---|
| `shortwave_radiation_incoming` | SW down | ICOS (SW_IN), SAEON (rad_short_in_avg), TERN (**Fsd**) |
| `shortwave_radiation_outgoing` | SW reflected | ICOS (SW_OUT), SAEON (rad_short_out_avg), TERN (**Fsu**) |
| `longwave_radiation_incoming` | LW down | ICOS (LW_IN), SAEON (rad_long_in_avg), TERN (**Fld**) |
| `longwave_radiation_outgoing` | LW up | ICOS (LW_OUT), SAEON (rad_long_out_avg), TERN (**Flu**) |
| `net_radiation` | Net all-wave radiation | ICOS (NETRAD), SAEON (rad_net_avg), TERN (**Fn**) |
| `vapor_pressure_deficit` | VPD | ICOS (VPD), SAEON (pressure_vapour_def_avg), TERN (VPD) |
| `soil_heat_flux` | Ground heat flux | ICOS (G_1, G_2), SAEON (heat_flux_ground), TERN (**Fg**) |
| `latent_heat_flux` | LE | SAEON (heat_flux_lat_corr), TERN (**Fe**) [+ ICOS via EC product] |
| `sensible_heat_flux` | H | SAEON (heat_flux_sens_corr), TERN (**Fh**) [+ ICOS via EC product] |
| `co2_flux` | NEE/Fc | SAEON (co2_flux_umol), TERN (**Fco2**) [+ ICOS via EC product] -- see §3.1 sign caveat |
| `friction_velocity` | u* | SAEON (u_star_avg), TERN (ustar) [+ ICOS via EC product] |
| `par_incoming` | PPFD | ICOS (PPFD_IN), SAEON (rad_photo_active_avg), TERN (**PAR**) |
| `soil_texture_sand` | % sand | ICOS partial (SOIL_TEX_SAND, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_silt` | % silt | ICOS partial (SOIL_TEX_SILT, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_clay` | % clay | ICOS partial (SOIL_TEX_CLAY, 6/40 sites), eLTER DE/ES, TERN, NEON |
| `soil_texture_class` | Categorical (sandy loam, etc.) | eLTER (FI, ES, DE), TERN (soilTextureGrade), NEON, ICOS partial |
| `soil_bulk_density` | Bulk density | ICOS (SOIL_CHEM_BD), eLTER ES, NEON (bulkDensExclCoarseFrag) |
| `soil_organic_carbon` | Organic C | ICOS (SOIL_CHEM_C_ORG), eLTER ES, NEON (megapit) |

(Issue 6 fix: TERN names corrected -- `Fsd` not `Fsd_Total`; `Fn` not `Fn_4cmpt`; `Fe` not `LE`; `Fh` not `H`; `Fco2` not `Fc/NEE`; `PAR` not `PAR_total`. These match the TERN profile and the NetCDF variable names.)

### Tier 3 -- Network-specific or sparse

- ICOS: D_SNOW, WTD, multi-level TA_1..9, vegetation chemistry, biomass, LAI, canopy height
- SAEON: u_star, fetch_*, Monin-Obukhov, planetary boundary layer height, sonic-derived T variants, wind components u/v/w
- eLTER: cation exchange capacity, soil pH, base saturation
- TERN: GPP_*, NEP_*, AH (absolute humidity)
- NEON: science review flags, expanded uncertainty per measurement, megapit-only carbonateClay, sand size sub-classes
- **`albedo`** -- only 2 networks (ICOS as `fraction`; SAEON as `pcnt` -- unit mismatch). Moved here from Tier 2 in Draft 1 (Issue 7 fix). If ever promoted, canonical would be unitless fraction (0--1); SAEON would divide by 100 (Issue 17 note).

(Issue 7 fix: albedo removed from the Tier 2 table; the Draft-1 "(only 2; drop to Tier 3)" annotation is resolved.)

---

## 2. Soil Texture -- Tier Decision (corrected)

**Evidence (Issue 3 fix):**
- **ICOS:** ANCILLARY files contain `SOIL_TEX_SAND`, `SOIL_TEX_SILT`, `SOIL_TEX_CLAY` for **6 of 40 sites** (BE-Bra, BE-Dor, CZ-BK1, FR-Fon, SE-Htm, SE-Svb). Example BE-Bra 0--5cm: sand=91.67%, silt=4.87%, clay=3.47%. Remaining 34 sites have only `SOIL_TEX_ROCK` or no texture data. (Per ICOS profile §3.) Draft 1's claim that sand/silt/clay are "NOT in METEO ANCILLARY" was incorrect; they ARE in the ANCILLARY product, just sparsely.
- **SAEON:** **Confirmed absent.** "No soil texture data found in any SAEON CSV files."
- **eLTER:** Present in DE (rows for sand/silt/clay %), ES (string tuple), AT (5-class Wentworth -- requires aggregation to USDA 3-class), FI (texture category only).
- **TERN:** `tern_soil_texture_data.xlsx` with sand_percentage, clay_percentage, silt_percentage (242 rows).
- **NEON:** `sandTotal`, `clayTotal`, `siltTotal` (% lab-analyzed, 452 records, 0 nulls).

**Decision:** Soil texture is **Tier 2** -- present in **4 of 5 networks** (ICOS partial, eLTER, TERN, NEON; SAEON absent). Austria's 5-class Wentworth scheme aggregates to USDA before harmonization.

`soil_texture_class` (categorical "sandy loam", etc.) is **Tier 2** (eLTER, TERN, NEON, ICOS partial).

(Issue 16 fix: every section using a coverage count now states "**Tier 2 (4 of 5 networks: ICOS partial, eLTER, TERN, NEON; SAEON absent)**" -- consistent across §2, §12 Summary, and Decision Log D003.)

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
| `soil_heat_flux` | `W m-2` | float | **Sign: positive = upward (PROVISIONAL** -- per-network verification required; see Open Question 8 and §6 validation). |
| `latent_heat_flux` | `W m-2` | float | Positive = away from surface |
| `sensible_heat_flux` | `W m-2` | float | Positive = away from surface |
| `co2_flux` | `umol m-2 s-1` | float | **Sign: negative = uptake (PROVISIONAL** -- per-network native sign must be verified before ingest by checking that daytime values at forested sites are predominantly negative; see Open Question 7). |
| `friction_velocity` | `m s-1` | float | |
| `soil_texture_sand` | `percent` (0--100) | float | Mass % sand, USDA |
| `soil_texture_silt` | `percent` (0--100) | float | |
| `soil_texture_clay` | `percent` (0--100) | float | |
| `soil_texture_class` | string | categorical | USDA texture triangle |
| `soil_bulk_density` | `g cm-3` | float | |
| `soil_organic_carbon` | `percent` (0--100) | float | Mass % of dry soil |

(Issues 12 and 13: CO2 flux and soil heat flux sign conventions are now flagged PROVISIONAL with explicit empirical verification criteria. Schema does not pretend to resolve what the profiles cannot.)

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

#### Evidence per network (revised; Issue 1 and Issue 11 fixes)

| Network / Site | Native unit | Sample range | Actual unit | Source |
|---|---|---|---|---|
| ICOS (general) | unlabeled, ~0--100 | 11.47--99.16 (e.g., FR-Gri 40.71--40.90; SE-Deg 58.9--99.16) | percent | ICOS profile §2 |
| **ICOS (FI-Sod)** | unlabeled | **0.52--0.58** | **fraction** (anomaly) | ICOS profile "CRITICAL FINDING"; D014 |
| SAEON | `pcnt` | 5.17--35 | percent | SAEON profile row 23 |
| eLTER (DE) | `%` | 26.46--26.59 | percent | eLTER profile, "Volumetric percentage (0--100%)" |
| eLTER (AT) | `volpercent` | 29.63--31.18 | percent | eLTER profile, Austria SOHYD |
| **eLTER (FI)** | `%` (label is wrong) | **0.003--0.689** | **fraction** (mislabeled in source) | eLTER profile §2 "CRITICAL FINDING"; D013 |
| **eLTER (ES)** | n/a | n/a | **structurally absent** -- no soil moisture data | eLTER profile §2, Spain row |
| TERN | `m^3/m^3` | 0--1.009 | fraction | TERN profile §2.3 |
| NEON | unitless fraction | 0--0.9971 (mean 0.1625) | fraction | NEON profile §2 |

#### Decision: Canonical = `m3 m-3` (fraction 0--1)

Rationale unchanged from Draft 1 -- CF Conventions, alignment with TERN/NEON, lossless conversion, "%" disambiguation.

#### Per-network conversion rules (revised)

| Network / Site | Native column | Conversion |
|---|---|---|
| ICOS (general) | `SWC_1..7` | value / 100.0 |
| **ICOS (FI-Sod)** | `SWC_1..7` | **passthrough** (already fraction; flag for verification) |
| SAEON | `moisture_soil_s1..s4_avg` | value / 100.0 |
| eLTER (DE) | `SMa###` / `SMb###` | value / 100.0 |
| eLTER (AT) | `soilmoisture[volpercent]` | value / 100.0 |
| **eLTER (FI)** | `soil water content` | **passthrough** -- DO NOT divide by 100 (mislabeled in source) |
| **eLTER (ES)** | n/a | structurally absent -- no harmonization needed |
| TERN | `Sws`, `Sws_*cm_*` | passthrough; clip values >1.0 to 1.0 with quality_flag=1 |
| NEON | `VSWCMean` | passthrough |

#### Implementation safeguard (Issue 11)
Before applying any per-network rule, compute the per-site min/max of pre-conversion SWC. **If max < 1.0, treat the site as already fraction (passthrough)**, regardless of the declared label. This catches both eLTER FI and ICOS FI-Sod automatically and protects against future site-level mislabeling. The two named exceptions are documented; the heuristic is the safety net.

#### Validation rules
- Range: 0.0 <= value <= 1.0
- Suspect (QF=1): 1.0 < value <= 1.05
- Fail (QF=2): value > 1.05 or value < 0
- Sentinel: ICOS `-9999` -> NULL; TERN `-9999.0` -> NULL

#### Data-quality warnings
- **eLTER Finland Hyytiala** -- SWC values 0.003--0.689 are labeled `%` but are physically fraction. Source-data mislabeling. Local conversion treats this as fraction.
- **ICOS FI-Sod** -- SWC values 0.52--0.58 differ from all other ICOS sites (4--99). Plausible only as fraction in a boreal organic soil. Treated as fraction; flagged for verification with ICOS data providers.

---

### 4.2 Atmospheric Pressure -- hPa (NEW per Issue 2)

| Network | Native unit | Sample range | Conversion |
|---|---|---|---|
| **ICOS** | **kPa** (per profile "Likely Unit") | PA: 96--98 (=> 960--980 hPa) | **value * 10.0** |
| SAEON | `hpa` | -- | passthrough |
| eLTER | `hPa` (Pamb / Pamb0; AT `Surface Air Pressure [hPa]`) | -- | passthrough |
| TERN | `hPa` (NetCDF `units`) | ps -- | passthrough |
| NEON | not profiled | -- | n/a |

#### Validation
- Plausible: 800 <= value <= 1050 hPa (sea-level surface stations).
- Suspect: 300--800 (high-altitude) or 1050--1100.
- Fail: < 300 or > 1100.

#### Why this matters
ICOS PA values of 96--98 are kPa (= 960--980 hPa, standard surface pressure). Treating them as hPa (Draft 1) would record ICOS pressure as ~96 hPa -- about Mars's surface pressure. The Draft-1 statement "hPa matches all 4 networks that report it" was incorrect for ICOS.

---

### 4.3 Vapor Pressure Deficit (VPD) -- hPa (NEW per Issue 9)

| Network | Native unit (declared) | Sample range | Conversion |
|---|---|---|---|
| ICOS | `hPa` ("Likely Unit" per profile §2 Other Variables table) | (sample values not in profile) | **passthrough provisionally**; verify empirically |
| SAEON | `hpa` (pressure_vapour_def_avg) | -- | passthrough |
| TERN | `hPa` (NetCDF `units`) | -- | passthrough |

#### Verification rule
Typical surface VPD ranges 0--40 hPa (= 0--4 kPa). At ingest:
- If site-mean ICOS VPD over a year is 0--10 hPa (typical) -> assume hPa, passthrough.
- If site-mean is 0--1 hPa (suspiciously low) AND the values look like 0.5--3 -> values are kPa, multiply by 10.
- If site-mean is consistently >25 hPa -> flag for unit reinvestigation.

The Draft-1 narrative "ICOS VPD x10 from kPa" contradicted the ICOS profile's own "Likely Unit: hPa." The conservative provisional resolution is passthrough with a runtime check.

---

### 4.4 Other unit-bearing variables (passthrough)

These are passthrough across all networks:
- Air temperature: `degC` everywhere.
- Relative humidity: `percent` (0--100) everywhere; SAEON literal `pcnt` is an alias.
- Wind speed: `m s-1` everywhere (SAEON literal `m_per_sec`).
- Wind direction: `degree` (0--360) everywhere.
- Soil temperature: `degC` everywhere.
- Radiation (SW/LW/Net): `W m-2` everywhere (SAEON literal `w_per_m2`).
- PAR: `umol m-2 s-1` everywhere (SAEON literal `umol_per_m2_per_s`).
- Precipitation: `mm` per interval everywhere.

---

## 5. Temporal Model

**Decision:** ISO 8601 in **UTC**; `timestamp_start` and `timestamp_end`; default canonical resolution 30 minutes.

### Per-network conversions

| Network | Native format | Conversion |
|---|---|---|
| ICOS | YYYYMMDDHHmm | Parse as UTC; produce timestamp_start and timestamp_end from native columns |
| SAEON | ISO 8601 + redundant numeric | Use ISO `Timestamp` as timestamp_end; subtract 30 min for start |
| eLTER FI (parquet) | datetime64[us, UTC] | Passthrough |
| eLTER DE (CSV) | ISO 8601 with Z | Passthrough |
| eLTER ES (CSV) | YYYY-MM-DD (daily) | Set start=T00:00:00Z, end=T23:59:59Z |
| eLTER AT (CSV) | ISO 8601 +01:00 (CET) | **Convert to UTC** (subtract 1 h CET / 2 h CEST) |
| TERN | NetCDF numeric (seconds-since-epoch) | Decode using NetCDF `units` attribute |
| NEON | datetime UTC (GMT) | Passthrough |

### Resolution policy (revised per Issue 10)

| Scenario | Rule |
|---|---|
| Native 30-min | Passthrough |
| Native finer than 30-min (eLTER FI 1-min, eLTER DE 10-min) | Aggregate to 30-min: SUM for precipitation, MEAN for state variables. Preserve native resolution in raw archive. |
| **Native coarser than 30-min, finer than daily (e.g., NEON hourly precipitation)** | **Store at native resolution.** `timestamp_start`/`timestamp_end` span the full native interval (60 min for hourly). DO NOT disaggregate to sub-native resolution -- there is no information about within-interval distribution. Use the `data_product` field to carry the native resolution. |
| Native daily (eLTER ES) | Keep at daily resolution; do not interpolate. start=T00:00:00Z, end=T23:59:59Z. |

For precipitation specifically: always SUM (never mean) when aggregating sub-native to 30-min. Splitting hourly into two 30-min records is forbidden.

---

## 6. Validation Ranges (NEW per Issue 15)

Every canonical variable has a plausibility range. Values outside the **fail** range are flagged QF=2 (value retained, flagged). Values in the **suspect** range are flagged QF=1.

| Variable | Plausible (pass) | Suspect | Fail | Notes |
|---|---|---|---|---|
| air_temperature | [-60, 50] degC | (-80, -60] or (50, 60] | < -80 or > 60 | Vostok record -89.2; Death Valley 56.7 |
| relative_humidity | [0, 100] % | (100, 105] | < 0 or > 105 | Sensor saturation |
| atmospheric_pressure | [800, 1050] hPa | [300, 800) or (1050, 1100] | < 300 or > 1100 | Suspect range covers high altitude / unit error |
| wind_speed | [0, 60] m/s | (60, 113] | < 0 or > 113 | Highest reliably-measured surface wind ~113 m/s |
| wind_direction | [0, 360) degrees | -- | < 0 or >= 360 | 360 == 0 |
| precipitation | [0, 200] mm/30-min | (200, 500] | < 0 or > 500 | World records ~305 mm/h |
| soil_water_content | [0, 1.0] m3/m3 | (1.0, 1.05] | < 0 or > 1.05 | See §4.1 |
| soil_temperature | [-40, 60] degC | (-50, -40] or (60, 80] | < -50 or > 80 | Permafrost; bare arid surface |
| shortwave_radiation_incoming | [0, 1400] W/m2 | (-50, 0) or (1400, 1500] | < -50 or > 1500 | Solar constant ~1361 |
| shortwave_radiation_outgoing | [0, 1100] W/m2 | (-50, 0) or (1100, 1500] | < -50 or > 1500 | |
| longwave_radiation_incoming | [100, 600] W/m2 | (50, 100) or (600, 700] | < 50 or > 700 | |
| longwave_radiation_outgoing | [100, 700] W/m2 | (50, 100) or (700, 800] | < 50 or > 800 | |
| net_radiation | [-300, 1100] W/m2 | -- | < -500 or > 1300 | |
| par_incoming | [0, 2500] umol/m2/s | (-100, 0) or (2500, 3000] | < -100 or > 3000 | |
| vapor_pressure_deficit | [0, 60] hPa | (60, 100] | < 0 or > 100 | Used to detect ICOS unit error (§4.3) |
| soil_heat_flux | [-300, 300] W/m2 | (-500, -300) or (300, 500) | < -500 or > 500 | Used in sign-convention check (§3.1) |
| latent_heat_flux | [-100, 800] W/m2 | (-200, -100) or (800, 1000] | < -200 or > 1000 | |
| sensible_heat_flux | [-300, 800] W/m2 | -- | < -500 or > 1000 | |
| co2_flux | [-50, 50] umol/m2/s | (-100, -50) or (50, 100) | < -100 or > 100 | Used in sign-convention check (§3.1) |
| friction_velocity | [0, 3] m/s | (3, 5] | < 0 or > 5 | |
| soil_texture_sand | [0, 100] % | -- | < 0 or > 100 | Sum-to-100 with silt+clay (+/- 1%) |
| soil_texture_silt | [0, 100] % | -- | < 0 or > 100 | |
| soil_texture_clay | [0, 100] % | -- | < 0 or > 100 | |
| soil_bulk_density | [0.5, 2.5] g/cm3 | (0.1, 0.5) or (2.5, 3.0] | < 0.1 or > 3.0 | Organic horizons can be < 0.5 |
| soil_organic_carbon | [0, 60] % | -- | < 0 or > 60 | Organic horizons up to ~58% (peat) |

Sentinel detection: any canonical value of -9999 reaching this validation table indicates a missed sentinel-conversion step upstream and is treated as fail with quality_flag=9.

---

## 7. Missing Data Convention

Canonical: **NULL**. All sentinels converted to NULL on ingest.

| Network | Sentinel | Canonical |
|---|---|---|
| ICOS | -9999 | NULL |
| SAEON | empty cell | NULL; QC code 9 -> quality_flag=9 |
| eLTER | NaN, empty | NULL |
| TERN | -9999.0 | NULL |
| NEON | native NULL | NULL |

`quality_flag=9` carries the "missing" reason. No magic numbers in canonical output.

---

## 8. Quality Flag Mapping (NEW per Issue 14)

Canonical scheme: `0=pass, 1=suspect, 2=fail, 9=missing/unknown`.

### Per-network mapping (explicit lookup, NOT arithmetic -- Issue 4 fix)

| Network | Native field | Native values | Canonical mapping (lookup) |
|---|---|---|---|
| ICOS | (no QC column in METEO; sentinel-driven) | -9999 = missing | value=-9999 -> {value: NULL, QF: 9}; otherwise QF: 0 |
| SAEON | `*_ss_itc_test` | 1=good, 2=uncertain, 3=poor, 9=missing | **1->0, 2->1, 3->2, 9->9** (explicit lookup; 9->9 is direct, not "9-1=8") |
| eLTER | `FLAGQUA` | 0=good, 1=other | **0->0, 1->1** (suspect, NOT fail; "other" is ambiguous and may be unchecked or manually overridden -- Issue 5 fix) |
| eLTER | `FLAGSTA` (status flag, e.g., 900000.0) | numeric codes; semantics undocumented in profile | **Drop on ingest with logged justification** ("FLAGSTA semantics unresolved -- omit pending eLTER documentation review"). DO NOT mix into `quality_flag`. Tracked in Open Question 9. |
| TERN | `{var}_QCFlag` | int; 0=good per profile; 1+ semantics undocumented | 0->0, 1..8->1 (suspect), >=9 -> 2 (fail) provisionally; conservative pending TERN QC documentation. Open Question 5. |
| NEON (precip, soil temp) | `finalQF` | 0=pass, 1=fail | 0->0, 1->2 |
| NEON (soil moisture) | `VSWCFinalQFSciRvw` | 0=pass, 1=suspect, 2=fail | 0->0, 1->1, 2->2 (direct passthrough) |

### Issues addressed
- **Issue 4 (SAEON arithmetic):** Draft 1 said "subtract 1, keep 9", but 9-1=8 != 9. Fixed with explicit lookup.
- **Issue 5 (eLTER aggressiveness):** Draft 1 mapped FLAGQUA=1 to QF=2 (fail). "Other" is ambiguous; demoted to QF=1 (suspect) to avoid destroying potentially usable data. FLAGSTA addressed by dropping with justification.
- **Issue 14 (no body section):** Draft 1 had QC mapping only in Decision D009. This section is now in the body.

### Combining multiple flag fields
When a network provides multiple flag fields per measurement (e.g., NEON `finalQF` + `VSWCFinalQFSciRvw`), take the **maximum** canonical flag across all fields. Fail (2) trumps suspect (1) trumps pass (0); missing (9) trumps everything.

---

## 9. Depth and Height Convention

- **Depth (below surface):** `depth_m`, **negative meters** (e.g., -0.10).
- **Height (above surface):** `height_m`, **positive meters** (e.g., 2.0).
- Each row carries exactly one; the other is NULL.

### Rationale
- Negative-down is the CF Convention.
- Meters is SI.
- Two columns avoid the NEON-style ambiguity (`verticalPosition` could be either).

### Per-network conversions (NEON corrected per Issue 8)

| Network | Native | Conversion |
|---|---|---|
| ICOS | `SOIL_TEX_PROFILE_MIN/MAX` in cm (positive); SWC_1..7 / TS_1..8 carry no depth in CSV | Texture: depth_m = -value_cm / 100. SWC/TS: **requires external depth lookup**; until then, store sensor index in `replicate` and depth_m=NULL with a "depth-pending" tag. |
| SAEON | `_s1`, `_s2`, `_s3`, `_s4` codes | **Requires external lookup.** Until then, store layer index in `replicate` and depth_m=NULL. |
| eLTER (DE SOATM) | "150--5000" range (mm or cm ambiguous) | **Resolve before harmonization** (profile flags Critical Ambiguity). Best guess mm -> /1000 to meters; verify. |
| eLTER (DE SOHYD) | VARIABLE-name suffix `010`, `020`, `080` (cm despite mm-named column) | Parse from VARIABLE name as cm -> /100 -> negate -> meters |
| eLTER (FI SOHYD) | Negative cm | depth_m = value_cm / 100 (already negative) |
| eLTER (AT SOHYD) | Negative cm | Same as Finland |
| TERN | Suffix in variable name (`_5cm`, `_10cm`, `_100cm`, `_180cm`, `_2m`) AND NetCDF `height` attribute (e.g., "-0.1m", "-1m") | Prefer the NetCDF `height` attribute (already in m and signed). Otherwise parse suffix and negate for soil. Atmospheric (e.g., `Ta_HMP_2m`) -> height_m=2.0 (positive). |
| **NEON** | `verticalPosition` is a **depth-level CODE** ("501"--"509"), **NOT meters** | **(1)** Join data files with sensor position metadata (`all_sensor_positions_00044_00006`) using siteID + HOR.VER. **(2)** Extract actual depth from the metadata's `height` column (m). For soil, NEON metadata `height` is already negative -> assign directly to depth_m. **(3)** For atmospheric (e.g., precipitation gauge at 0.44--9.07 m), height_m = positive value. **DO NOT** treat the verticalPosition code as meters -- this would yield depth_m = -501 m, which is absurd. |

(Issue 8 fix: NEON depth conversion in Draft 1 was wrong -- it negated the position code. Soil texture from megapit uses `biogeoTopDepth`/`biogeoBottomDepth` in cm: depth_m = -biogeoTopDepth / 100, stored as range in `soil_profiles`.)

---

## 10. Naming Convention

**Decision:** `snake_case` for canonical variable names; units in a separate `unit` column.

Rationale and evidence unchanged from Draft 1.

---

## 11. Schema Structure -- Long Format + Static Tables

**Decision:** Single long-format `observations` table + static `sites`, `soil_profiles`, `sensors` tables. Rationale unchanged from Draft 1: TERN's 1,827 unique variables collapse to ~30 canonical names; long format scales without schema migrations; wide format would explode columns.

---

## 12. Summary of Conventions

| Aspect | Choice |
|---|---|
| Naming | `snake_case`, no units in name |
| Units in data | Separate `unit` column; canonical units in §3.1; per-network conversions in §4 |
| Time | ISO 8601 UTC; 30-min default; `timestamp_start` + `timestamp_end`; coarser-than-30-min stored at native resolution |
| Missing | NULL (no sentinels); `quality_flag` carries reason |
| Quality flags | Canonical {0=pass, 1=suspect, 2=fail, 9=missing}; per-network lookup table in §8 |
| Depth | Negative meters (below surface) |
| Height | Positive meters (above surface) |
| SWC unit | `m3 m-3` (fraction 0--1); see §4.1 (eLTER FI and ICOS FI-Sod are passthrough exceptions) |
| Atmospheric pressure unit | `hPa`; ICOS x10 from kPa (see §4.2) |
| VPD unit | `hPa`; ICOS provisional passthrough pending sample-value verification (see §4.3) |
| Soil temp | `degC` |
| Schema | Long-format `observations` + static `sites`, `soil_profiles`, `sensors` |
| **Texture tier** | **Tier 2 (4 of 5 networks: ICOS partial, eLTER, TERN, NEON; SAEON absent)** -- consistent across §2, §12, and Decision D003 (Issue 16 fix) |
| Texture units | Sand/silt/clay each in `percent` (0--100) |
| CO2 flux convention | **negative = uptake (PROVISIONAL** -- per-network sign verification required) |
| Soil heat flux convention | **positive = upward (PROVISIONAL** -- per-network verification required) |
| Validation | Plausibility ranges defined per variable (§6) |

---

## 13. Open Questions / Items Requiring External Lookup

1. ICOS `SWC_1..7` and `TS_1..8` actual depths -- need site metadata table.
2. SAEON `_s1.._s4` actual depths -- need site documentation.
3. eLTER Germany SOATM `VERT_OFFSET` 150--5000 -- confirm mm vs cm.
4. eLTER Spain soil-texture tuple ordering (sand, silt, clay) vs (sand, clay, silt) -- needs eLTER documentation.
5. **TERN QC flag value semantics** for non-zero codes (currently provisional 0->0, 1..8->1, >=9->2) -- need TERN QC documentation.
6. NEON `VSWCFinalQFSciRvw` cross-reference to `science_review_flags_*.csv` for flagged date ranges.
7. **CO2 flux sign convention** -- both SAEON and TERN reported as ambiguous in profiles. Canonical is negative=uptake (FLUXNET) but each network's native sign **MUST** be verified before harmonization. Empirical check: at forested sites, daytime growing-season values should be predominantly negative; if predominantly positive in native data, multiply by -1.
8. **ICOS / TERN / SAEON soil heat flux sign convention** -- profiles do not specify upward-positive vs downward-positive. Empirical check: at vegetated surfaces, summer daytime flux should generally be positive (upward) in the upward-positive convention; verify each network during ingest.
9. **eLTER FLAGSTA** semantics (e.g., 900000.0) -- dropped on ingest pending documentation review.
10. **ICOS VPD** sample values -- verify hPa (passthrough) vs kPa (multiply by 10). Profile lists "Likely Unit: hPa"; runtime sanity check: site mean VPD across a year > 25 hPa or < 0.5 hPa flags for unit reinvestigation.
11. **Albedo unit discrepancy** (Tier 3): SAEON `pcnt` vs ICOS `fraction`. If promoted to Tier 2, resolve to fraction and divide SAEON by 100 (Issue 17 note).
12. **ICOS FI-Sod SWC** -- verify with ICOS data providers that values 0.52--0.58 are fraction (not percent).

---

**End of DERIVED_SCHEMA_DRAFT_2**
