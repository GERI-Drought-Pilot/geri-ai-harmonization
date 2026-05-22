# Cross-Network Variable Mapping

**Date:** 2026-05-05
**Schema version:** DERIVED_SCHEMA_DRAFT_2 / DERIVED_SCHEMA_FINAL

For each canonical variable, this document lists the raw column name in each network, its native unit, and the conversion rule to canonical units. Use as the implementation reference for the harmonization pipeline.

---

## 1. Precipitation -- canonical `mm` per native interval

| Network | Raw Variable | Raw Unit | Native Resolution | Conversion |
|---|---|---|---|---|
| ICOS | `P` | mm | 30-min total | passthrough |
| SAEON | `rain_tot` | mm | 30-min total | passthrough |
| eLTER (FI) | `Precip` (also `Precipacc`, `Precipacc_GPM`) | mm | 1-min | SUM to 30-min |
| eLTER (DE) | `precip50` | mm | 10-min | SUM three to 30-min |
| eLTER (ES) | `P_RAIN` | mm | daily | keep daily |
| eLTER (AT) | `Precipitation [mm]` | mm | 30-min | passthrough; convert timestamp CET -> UTC |
| TERN | `Precip` (also `Precipa`, `Precipb`) | mm | 30-min | passthrough |
| NEON | `precipBulk` | mm | hourly | **keep hourly** (do not split; timestamp_start/end span 60 min) |

Rule (D016): always SUM (never mean) when aggregating sub-canonical precipitation. Never disaggregate coarser-than-canonical (NEON hourly, eLTER ES daily).

---

## 2. Soil Water Content -- canonical `m3 m-3` (fraction 0--1)

| Network / Site | Raw Variable | Raw Unit (declared) | Sample Range | Actual Unit | Conversion |
|---|---|---|---|---|---|
| ICOS (general) | `SWC_1` .. `SWC_7` | unlabeled | 4--99 | percent | value / 100.0 |
| **ICOS (FI-Sod)** | `SWC_1` .. `SWC_7` | unlabeled | 0.52--0.58 | **fraction** (anomaly within ICOS) | **passthrough** (D014) |
| SAEON | `moisture_soil_s1..s4_avg` | `pcnt` | 5.17--35 | percent | value / 100.0 |
| eLTER (DE) | `SMa###`, `SMb###` | `%` | 26.46--26.59 | percent | value / 100.0 |
| eLTER (AT) | `soilmoisture[volpercent]` | `volpercent` | 29.63--31.18 | percent | value / 100.0 |
| **eLTER (FI)** | `soil water content` | `%` (LABEL IS WRONG) | 0.003--0.689 | **fraction** (mislabeled in source) | **passthrough** (D013) |
| eLTER (ES) | (none) | -- | -- | structurally absent | n/a |
| TERN | `Sws`, `Sws_*cm_*` | `m^3/m^3` (NetCDF units) | 0--1.009 | fraction | passthrough; clip > 1.0 to 1.0 with QF=1 |
| NEON | `VSWCMean` | unitless fraction | 0--0.9971 | fraction | passthrough |

Implementation safeguard: If max site SWC < 1.0 pre-conversion, treat the site as already fraction (passthrough), regardless of declared label. Catches both eLTER FI and ICOS FI-Sod automatically.

---

## 3. Soil Temperature -- canonical `degC`

| Network | Raw Variable | Raw Unit | Conversion |
|---|---|---|---|
| ICOS | `TS_1` .. `TS_8` | degC (inferred) | passthrough |
| SAEON | `temp_soil_s1_avg`, `temp_soil_s2_avg` | `deg_c` | passthrough |
| eLTER (FI) | `soil water temperature` | degC | passthrough (note: "water" is contextual, refers to soil water temp = soil temp) |
| eLTER (DE) | `STa###`, `STb###` | degC | passthrough |
| eLTER (AT) | `soiltemp[degC]` | degC | passthrough; convert timestamp CET -> UTC |
| eLTER (ES) | (none) | -- | n/a |
| TERN | `Ts`, `Ts_*cm_*` | degC | passthrough |
| NEON | `soilTempMean` | degC | passthrough |

---

## 4. Air Temperature -- canonical `degC`

| Network | Raw Variable | Raw Unit | Notes | Conversion |
|---|---|---|---|---|
| ICOS | `TA` (aggregate); `TA_1` .. `TA_9` (multi-height) | degC | Use TA as primary | passthrough |
| SAEON | `temp_air_avg`; also `temp_air_EC100_avg`, `temp_air_sonic_avg` | `deg_c` | Use temp_air_avg | passthrough |
| eLTER (FI) | `T336`, `T270icos`, `T168`, `T84`, `T88icos` | degC | Height in decimeters in name | passthrough; parse height from name |
| eLTER (DE) | `Tair50HMP`, `Tair14PT` | degC | Sensor type in name | passthrough |
| eLTER (ES) | `TA_A`, `TA_Z`, `TA_X` | `degree_Celsius` | Multiple stations | passthrough |
| eLTER (AT) | `Air Temperature [deg C]` | degC | Unit in header | passthrough; convert timestamp CET -> UTC |
| TERN | `Ta`; also `Ta_HMP_30m`, `Ta_HMP_7m` | degC | Height & sensor in name | passthrough; use Ta as primary |
| NEON | (DP1.00003 file empty in profile extract) | -- | Not in this dataset | n/a |

---

## 5. Atmospheric Pressure -- canonical `hPa` (Issue 2 fix)

| Network | Raw Variable | Raw Unit | Sample Range | Conversion |
|---|---|---|---|---|
| **ICOS** | `PA` | **kPa** (per profile "Likely Unit") | 96--98 | **value * 10.0** |
| SAEON | `pressure_atm_avg` | `hpa` | -- | passthrough |
| eLTER (FI) | `Pamb0`, `Pamb` | hPa | -- | passthrough |
| eLTER (DE) | (implicit in SOATM) | hPa | -- | passthrough |
| eLTER (AT) | `Surface Air Pressure [hPa]` | hPa | -- | passthrough |
| TERN | `ps` | hPa (NetCDF units) | 980--1020 | passthrough |
| NEON | not profiled | -- | -- | n/a |

Validation: pass [800, 1050] hPa; suspect [300, 800) or (1050, 1100]; fail < 300 or > 1100. Tight pass range catches missed ICOS x10 conversion (96 hPa would fail).

---

## 6. Relative Humidity -- canonical `percent` (0--100)

| Network | Raw Variable | Raw Unit | Conversion |
|---|---|---|---|
| ICOS | `RH`, `RH_1` .. `RH_9` | % | passthrough |
| SAEON | `humid_rel_avg` | `pcnt` | passthrough |
| eLTER (FI) | `RHIRGA168`, `RH168` | % | passthrough |
| eLTER (AT) | `Air Relative Humidity [%]` | % | passthrough |
| TERN | `RH` | % (NetCDF units) | passthrough |
| NEON | not profiled | -- | n/a |

---

## 7. Wind Speed -- canonical `m s-1` (Issue 18 fix: TERN `Ws` not `ws`)

| Network | Raw Variable | Raw Unit | Conversion |
|---|---|---|---|
| ICOS | `WS` | m/s | passthrough |
| SAEON | `wind_speed_avg` | `m_per_sec` | passthrough |
| eLTER (FI) | `WS336` | m/s | passthrough |
| eLTER (DE) | (implicit) | m/s | passthrough |
| eLTER (ES) | `WS_X`, `WS_Z`, `WS_A` | m/s | passthrough |
| eLTER (AT) | `Wind Speed [m s-1]` | m/s | passthrough |
| TERN | **`Ws`** (case-sensitive) | m/s | passthrough |
| NEON | not profiled | -- | n/a |

---

## 8. Wind Direction -- canonical `degree` (0--360)

| Network | Raw Variable | Raw Unit | Conversion |
|---|---|---|---|
| ICOS | `WD` | degrees | passthrough |
| SAEON | `wind_dir_avg` | `deg` | passthrough |
| eLTER (FI) | `WD336` | degrees | passthrough |
| eLTER (ES) | `WD_X`, `WD_Z`, `WD_A` | degree | passthrough |
| eLTER (AT) | `Wind Direction [deg]` | degrees | passthrough |
| TERN | **`Wd`** (case-sensitive) | degrees | passthrough |
| NEON | not profiled | -- | n/a |

---

## 9. Radiation Variables -- canonical `W m-2` (Issue 6 fix: TERN names corrected)

| Canonical | ICOS | SAEON | TERN | Conversion |
|---|---|---|---|---|
| `shortwave_radiation_incoming` | `SW_IN` | `rad_short_in_avg` | **`Fsd`** (not `Fsd_Total`) | passthrough |
| `shortwave_radiation_outgoing` | `SW_OUT` | `rad_short_out_avg` | **`Fsu`** | passthrough |
| `longwave_radiation_incoming` | `LW_IN` | `rad_long_in_avg` | **`Fld`** | passthrough |
| `longwave_radiation_outgoing` | `LW_OUT` | `rad_long_out_avg` | **`Flu`** | passthrough |
| `net_radiation` | `NETRAD` | `rad_net_avg` | **`Fn`** (not `Fn_4cmpt`) | passthrough |
| `par_incoming` | `PPFD_IN` | `rad_photo_active_avg` | **`PAR`** (not `PAR_total`) | passthrough |

Units: ICOS W/m2; SAEON `w_per_m2`, `umol_per_m2_per_s`; TERN W/m^2 / umol/m^2/s. All numeric aliases of canonical units.

---

## 10. Vapor Pressure Deficit -- canonical `hPa` (Issue 9 fix)

| Network | Raw Variable | Raw Unit (declared) | Conversion |
|---|---|---|---|
| ICOS | `VPD`, `VPD_1..9` | hPa ("Likely Unit" per profile §2) | **passthrough provisionally**; verify empirically (see §4.3 of schema) |
| SAEON | `pressure_vapour_def_avg` | `hpa` | passthrough |
| TERN | `VPD` | hPa (NetCDF units) | passthrough |

Runtime sanity check: site mean VPD across a year > 25 hPa or < 0.5 hPa flags for unit reinvestigation.

---

## 11. Soil Heat Flux -- canonical `W m-2` (Issue 13: sign provisional)

| Network | Raw Variable | Raw Unit | Conversion |
|---|---|---|---|
| ICOS | `G_1`, `G_2` | W/m2 | passthrough; **verify sign** (positive=upward target) |
| SAEON | `heat_flux_ground` | `w_per_m2` | passthrough; verify sign |
| TERN | **`Fg`** (also `Fg_8cma`, `Fg_8cmb`) | W/m^2 | passthrough; verify sign |

Sign convention: positive = upward (PROVISIONAL). Empirical verification: at vegetated surfaces, summer daytime flux should be predominantly positive in the upward-positive convention. Multiply by -1 if a network uses downward-positive.

---

## 12. Latent / Sensible / CO2 Flux (Issue 6 fix: TERN names; Issue 12: CO2 sign provisional)

| Canonical | SAEON | TERN | ICOS (via EC product) |
|---|---|---|---|
| `latent_heat_flux` | `heat_flux_lat_corr` | **`Fe`** (not `LE`) | (EC product) |
| `sensible_heat_flux` | `heat_flux_sens_corr` | **`Fh`** (not `H`) | (EC product) |
| `co2_flux` | `co2_flux_umol` | **`Fco2`** (not `Fc/NEE`) | (EC product) |
| `friction_velocity` | `u_star_avg` | `ustar` | (EC product) |

CO2 flux sign convention: negative = uptake (FLUXNET) **PROVISIONAL**. Empirical verification: at forested sites, daytime growing-season values should be predominantly negative; if predominantly positive in native data, multiply by -1.

---

## 13. Soil Texture (Static) -- canonical `percent` (0--100), in `soil_profiles` table

| Network | Sand | Silt | Clay | Unit | Depth Convention | Coverage |
|---|---|---|---|---|---|---|
| ICOS | `SOIL_TEX_SAND` | `SOIL_TEX_SILT` | `SOIL_TEX_CLAY` | % (0--100) | `SOIL_TEX_PROFILE_MIN/MAX` in cm from mineral soil top | 6 of 40 sites (Issue 3 fix) |
| eLTER (DE) | `soil texture proportion (sand)` | `soil texture proportion (silt)` | `soil texture proportion (clay)` | % | `VERT_OFFSET_FROM/TO` in negative cm | per-site rows |
| eLTER (FI) | `soil texture proportion` (parse by MEDIUM column) | (same) | (same) | % | `VERT_OFFSET_FROM/TO` in negative cm | category + proportion |
| eLTER (AT) | aggregate: pct_2_to_0_2mm + pct_0_2_to_0_02mm | pct_0_02_to_0_002mm | pct_lt_0_002mm | % | depth_top_cm / depth_bottom_cm | Wentworth -> USDA aggregation |
| TERN | `sand_percentage` | `silt_percentage` | `clay_percentage` | % (0--100) | `soilDepthMin_Metre` / `soilDepthMax_Metre` | 242 rows |
| NEON | `sandTotal` | `siltTotal` | `clayTotal` | % (0--100) | `biogeoTopDepth` / `biogeoBottomDepth` in cm | 452 rows, 0 nulls |
| SAEON | n/a | n/a | n/a | -- | -- | structurally absent |

Austria Wentworth-to-USDA aggregation:
- Sand = pct_2_to_0_2mm + pct_0_2_to_0_02mm (2 mm to 0.02 mm)
- Silt = pct_0_02_to_0_002mm (0.02 mm to 0.002 mm)
- Clay = pct_lt_0_002mm (< 0.002 mm)
- Gravel = pct_gt_2mm (excluded; recorded in metadata)

---

## 14. Soil Texture Class -- canonical string (USDA), in `soil_profiles` table

| Network | Raw Variable | Notes |
|---|---|---|
| ICOS | (partial; from numeric fractions) | derive USDA class from sand/silt/clay |
| eLTER (FI) | `soil texture category` | "Sandy loam" etc. |
| eLTER (DE) | `soil texture category (-)` | derive from numeric fractions |
| eLTER (AT) | (Wentworth -- aggregate then derive) | -- |
| TERN | `soilTextureGrade` | "Clay loam", "Sandy loam", etc. |
| NEON | (megapit horizon-related; derive from sandTotal/siltTotal/clayTotal) | -- |
| SAEON | n/a | -- |

---

## 15. Soil Bulk Density and Organic Carbon (static)

| Canonical | ICOS | eLTER ES | NEON | Unit |
|---|---|---|---|---|
| `soil_bulk_density` | `SOIL_CHEM_BD` | `dry bulk density` | `bulkDensExclCoarseFrag` | g cm-3 |
| `soil_organic_carbon` | `SOIL_CHEM_C_ORG` | `soil organic carbon content` | (megapit) | percent (0--100) |

---

## 16. Missing Data Sentinel Mapping

| Network | Sentinel | Canonical |
|---|---|---|
| ICOS | -9999 | NULL |
| SAEON | empty cell | NULL |
| eLTER | NaN, empty | NULL |
| TERN | -9999.0 | NULL |
| NEON | native NULL | NULL |

---

## 17. Timestamp Format Mapping

| Network | Native Format | Example | Timezone | Conversion |
|---|---|---|---|---|
| ICOS | YYYYMMDDHHmm | 201801010000 | UTC (assumed) | parse to ISO 8601 UTC |
| SAEON | ISO 8601 | 2024-07-31T18:30:00 | UTC | use as timestamp_end; -30 min for start |
| eLTER FI | datetime64[us, UTC] | 1996-01-01 00:00:00+00:00 | UTC | passthrough |
| eLTER DE | ISO 8601 + Z | 2015-01-01T00:10:00Z | UTC | passthrough |
| eLTER ES | YYYY-MM-DD | 1978-11-01 | (daily) | start=T00:00:00Z, end=T23:59:59Z |
| eLTER AT | ISO 8601 +01:00 | 2020-12-01 13:00:00+01:00 | CET | **convert to UTC** |
| TERN | NetCDF numeric (seconds since epoch) | -- | UTC | decode using NetCDF units attribute |
| NEON | datetime UTC (GMT) | 2017-06-16 00:00:00+00:00 | UTC | passthrough |

---

## 18. Quality Flag Mapping (Issue 4, 5, 14 fixes)

Canonical: `0=pass, 1=suspect, 2=fail, 9=missing`.

| Network | Native field | Native values | Mapping (lookup, NOT arithmetic) |
|---|---|---|---|
| ICOS | (none in METEO) | -9999 = missing | value=-9999 -> {value:NULL, QF:9}; else QF=0 |
| SAEON | `*_ss_itc_test` | 1=good, 2=uncertain, 3=poor, 9=missing | 1->0, 2->1, 3->2, 9->9 |
| eLTER | `FLAGQUA` | 0=good, 1=other | 0->0, 1->1 (suspect, NOT fail) |
| eLTER | `FLAGSTA` | undocumented | drop on ingest with logged justification |
| TERN | `{var}_QCFlag` | 0=good; 1+ undocumented | 0->0, 1..8->1, >=9->2 (provisional) |
| NEON | `finalQF` | 0=pass, 1=fail | 0->0, 1->2 |
| NEON | `VSWCFinalQFSciRvw` | 0=pass, 1=suspect, 2=fail | 0->0, 1->1, 2->2 |

Combining: when multiple flag fields apply, take the maximum canonical flag.

---

## 19. Depth / Height Conventions

| Network | Native | Conversion to depth_m / height_m |
|---|---|---|
| ICOS (METEO) | SWC_1..7, TS_1..8 (sensor index, no depth) | depth_m=NULL; index in `replicate`; **external lookup pending** |
| ICOS (ANCILLARY) | `SOIL_TEX_PROFILE_MIN/MAX` in positive cm | depth_m = -value_cm / 100 |
| SAEON | `_s1`..`_s4` codes | depth_m=NULL; code in `replicate`; **external lookup pending** |
| eLTER (FI SOHYD) | VERT_OFFSET in negative cm | depth_m = value_cm / 100 |
| eLTER (DE SOHYD) | suffix `010`, `020`, `080` (cm despite mm-named column) | parse from VARIABLE name as cm -> /100 -> negate |
| eLTER (DE SOATM) | "150--5000" (mm or cm ambiguous) | resolve before harmonization (best guess mm -> /1000) |
| eLTER (AT) | negative cm | depth_m = value_cm / 100 |
| TERN | suffix `_5cm`/`_10cm`/`_180cm`/`_2m` AND NetCDF `height` attribute | prefer `height` attribute (already signed m); else parse suffix and negate for soil |
| **NEON** | `verticalPosition` is a CODE ("501"--"509"), NOT meters (Issue 8 fix) | **join with `all_sensor_positions_00044_00006` on siteID + HOR.VER**; use metadata `height` column (m, signed) |
| NEON (texture, megapit) | `biogeoTopDepth`, `biogeoBottomDepth` in positive cm | depth_top_m = -biogeoTopDepth/100; depth_bottom_m = -biogeoBottomDepth/100 |

---

**End of CROSS_NETWORK_MAPPING**
