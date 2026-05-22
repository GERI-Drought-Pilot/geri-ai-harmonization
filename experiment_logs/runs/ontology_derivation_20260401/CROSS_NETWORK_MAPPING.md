# Cross-Network Variable Mapping

**Date**: 2026-04-01
**Schema Version**: Final (accepted Draft 2)
**Purpose**: For each canonical variable, how each network's raw variable name maps to the unified name, what unit conversion is needed, and implementation notes.

---

## Notation

- `--` = Variable not available in this network
- `(derivable)` = Can be computed from other variables but not provided directly
- Conversion shows the formula to transform raw values to canonical units

---

## 1. air_temperature

| Field | Value |
|-------|-------|
| **Canonical name** | `air_temperature` |
| **Canonical unit** | degC |
| **Tier** | 1 (5/5 networks) |
| **Conversion** | None required (all networks use Celsius) |

| Network | Raw Variable(s) | Raw Unit | Selection Rule | Notes |
|---------|-----------------|----------|----------------|-------|
| ICOS | `TA` | degC | Use aggregated TA (mean across heights) | TA_1..10 are multi-height profiles |
| SAEON | `temp_air_avg` | deg_c | Use temp_air_avg | Also available: temp_air_EC100_avg, temp_air_sonic_avg (sensor-specific) |
| eLTER (DE) | `Tair50HMP` | degC | Use primary HMP sensor | 50 = ~50m height at Hohes Holz tower |
| eLTER (FI) | `T336` | degC | Use sensor closest to standard height | T168, T84 also available; requires METHOD metadata |
| eLTER (ES) | `TA_A` | degC | Use TA_A | TA_Z also present (different height?) |
| eLTER (AT) | "Air Temperature [deg C]" column header | degC | Direct column read | Unit embedded in header |
| TERN | `Ta` | degC | Use aggregated Ta | Ta_HMP_2m, Ta_HMP_23m etc. are height-specific |
| NEON | `tempTripleMean` | Celsius | Use tempTripleMean | Triple-aspirated thermometer; filter by finalQF=0 |

---

## 2. precipitation

| Field | Value |
|-------|-------|
| **Canonical name** | `precipitation` |
| **Canonical unit** | mm (30-min accumulation) |
| **Tier** | 1 (5/5 networks) |
| **Conversion** | Aggregation may be needed for sub-30-min data |

| Network | Raw Variable(s) | Raw Unit | Selection Rule | Notes |
|---------|-----------------|----------|----------------|-------|
| ICOS | `P` | mm | Direct (30-min accumulation) | |
| SAEON | `rain_tot` | mm | Direct (30-min total) | |
| eLTER (DE) | `precip50` | mm | Sum 10-min values within 30-min window | Also: precip_back, precip_ombro (backup sensors) |
| eLTER (FI) | `Precip` | mm | Sum if sub-30-min | Precipacc is cumulative (do not use directly) |
| eLTER (ES) | `P_RAIN` | mm | Direct or sum depending on resolution | Daily data at some stations |
| eLTER (AT) | Not profiled | -- | -- | |
| TERN | `Precip` | mm | Direct | |
| NEON | `precipBulk` | mm | Direct (30-min) | Weighing gauge (DP1.00044.001); also tipping bucket data |

---

## 3. soil_water_content

| Field | Value |
|-------|-------|
| **Canonical name** | `soil_water_content_{depth}cm` |
| **Canonical unit** | m3/m3 (fraction, 0.0-1.0) |
| **Tier** | 1 (5/5 networks) |
| **Conversion** | ICOS, SAEON, eLTER: divide by 100; TERN, NEON: no conversion |

| Network | Raw Variable(s) | Raw Unit | Conversion | Depth Encoding | Notes |
|---------|-----------------|----------|------------|----------------|-------|
| ICOS | `SWC_1` .. `SWC_5` | % (volumetric) | / 100.0 | Ordinal index (1=shallowest ~5cm, 5=deepest ~50cm). Exact depth in ancillary. | _SD and _N companion fields available |
| SAEON | `moisture_soil_s1_avg` .. `moisture_soil_s4_avg` | pcnt | / 100.0 | Ordinal index (_s1 shallowest). Exact depths unknown -- requires sensor metadata. | Up to 4 layers |
| eLTER (DE) | `SMa010`, `SMa020`, `SMa030`, `SMa040`, `SMa050`, `SMa080`, `SMb010` .. `SMb080` | % | / 100.0 | Depth in variable name: last 3 digits = cm. `a`/`b` = profile A/B. | Two profiles at Hohes Holz |
| eLTER (FI) | SOHYD-168 variables | % | / 100.0 | VERT_OFFSET column (negative cm). Convert: abs(VERT_OFFSET). | Long-format Parquet |
| eLTER (AT) | SOHYD variables | % (vol) | / 100.0 | Headers contain "[vol percent]" or "[volpercent]" | |
| TERN | `Sws_5cm`, `Sws_10cm`, `Sws_20cm`, `Sws_40cm`, `Sws_80cm` etc. | m3/m3 | None | Depth in variable name (cm). Multiple sensors per depth: `Sws_5cma`, `Sws_5cmb` -- average replicates. | QCFlag companion variable |
| NEON | `VSWCMean` | m3/m3 | None | `verticalPosition` column + sensor_positions metadata. | Values > 0.4 may indicate sensor saturation |

**CRITICAL WARNING**: This is the #1 unit conversion risk. Always verify converted values fall in [0.0, 1.0]. A value like 29.0 after conversion (instead of 0.29) means the division by 100 was not applied.

---

## 4. soil_temperature

| Field | Value |
|-------|-------|
| **Canonical name** | `soil_temperature_{depth}cm` |
| **Canonical unit** | degC |
| **Tier** | 1 (5/5 networks) |
| **Conversion** | None (all use Celsius) |

| Network | Raw Variable(s) | Raw Unit | Depth Encoding | Notes |
|---------|-----------------|----------|----------------|-------|
| ICOS | `TS_1` .. `TS_6` | degC | Ordinal (1=shallowest ~5cm, 6=deepest ~60cm) | |
| SAEON | `temp_soil_s1_avg`, `temp_soil_s2_avg` | deg_c | Ordinal (_s1 shallowest). Only 2 layers in profile. | |
| eLTER (DE) | `STa005` .. `STb080` | degC | Depth in name: last 3 digits = cm (005=5cm, 080=80cm). `a`/`b` = profile. | Depths: 5, 10, 20, 30, 40, 50, 80 cm |
| eLTER (FI) | SOHYD-168 variables | degC | VERT_OFFSET (negative cm) | Long-format |
| TERN | `Ts_5cm`, `Ts_10cm`, `Ts_20cm`, `Ts_40cm`, `Ts_80cm` etc. | degC | Depth in variable name. Multiple sensors: `Ts_5cma`, `Ts_5cmb` -- average. | |
| NEON | `soilTempMean` | Celsius | `verticalPosition` + metadata | Platinum resistance thermometer |

---

## 5. relative_humidity

| Field | Value |
|-------|-------|
| **Canonical name** | `relative_humidity` |
| **Canonical unit** | % |
| **Tier** | 2 (4/5 networks) |
| **Conversion** | None |

| Network | Raw Variable(s) | Raw Unit | Notes |
|---------|-----------------|----------|-------|
| ICOS | `RH` | % | RH_1..9 are multi-height profiles |
| SAEON | `humid_rel_avg` | pcnt | Also: humid_rel_ec100_avg, humid_rel_sonic_avg |
| eLTER (DE) | `RH50HMP` | % | Also RH45HMP |
| eLTER (FI) | `RH168` | % | Also RHIRGA168 |
| eLTER (AT) | "Air Relative Humidity [%]" | % | Unit in header |
| TERN | `RH` | percent | Height-specific: RH_HMP_2m etc. |
| NEON | -- | -- | Not in profiled data products |

---

## 6. wind_speed

| Field | Value |
|-------|-------|
| **Canonical name** | `wind_speed` |
| **Canonical unit** | m/s |
| **Tier** | 2 (4/5 networks) |

| Network | Raw Variable(s) | Raw Unit | Notes |
|---------|-----------------|----------|-------|
| ICOS | `WS` | m/s | |
| SAEON | `wind_speed_avg` | m_per_sec | Also: _max, _min, _sd, u/v/w components |
| eLTER (DE) | `WS49_2D` | m/s | 2D anemometer at 49m |
| eLTER (FI) | `WS336` | m/s | Also WSU336 |
| eLTER (AT) | "Wind Speed [m s-1]" | m/s | |
| TERN | `Ws` | m/s | Also Ws_SONIC_Av, Ws_RMY2m_Av etc. |
| NEON | -- | -- | Not in profiled products |

---

## 7. wind_direction

| Field | Value |
|-------|-------|
| **Canonical name** | `wind_direction` |
| **Canonical unit** | deg (0-360, meteorological convention) |
| **Tier** | 2 (4/5 networks) |

| Network | Raw Variable(s) | Raw Unit | Notes |
|---------|-----------------|----------|-------|
| ICOS | `WD` | deg | 0-360 |
| SAEON | `wind_dir_avg` | deg | |
| eLTER (DE) | `WD49_2D` | deg | |
| eLTER (FI) | `WD336` | deg | Also WDU336 |
| eLTER (AT) | "Wind Direction [deg]" | deg | |
| TERN | `Wd` | degrees | Wd_SONIC_Av, Wd_RMY2m_Av etc. |
| NEON | -- | -- | |

---

## 8. atmospheric_pressure

| Field | Value |
|-------|-------|
| **Canonical name** | `atmospheric_pressure` |
| **Canonical unit** | hPa |
| **Tier** | 2 (3/5 networks) |

| Network | Raw Variable(s) | Raw Unit | Notes |
|---------|-----------------|----------|-------|
| ICOS | `PA` | hPa | |
| SAEON | `pressure_atm_avg` | hpa | |
| eLTER (DE) | `airpres50` | hPa | Also airpres_back |
| eLTER (FI) | `Pamb0` | hPa | |
| eLTER (AT) | "Surface Air Pressure [hPa]" | hPa | |
| TERN | -- | -- | P listed in base variable inventory but not detailed in L3 catalog |
| NEON | -- | -- | |

---

## 9. Radiation Variables (shortwave_radiation_in/out, longwave_radiation_in/out, net_radiation)

| Canonical Name | ICOS | SAEON | TERN | Others |
|----------------|------|-------|------|--------|
| shortwave_radiation_in | SW_IN (W/m2) | rad_short_in_avg (w_per_m2) | Fsd (W/m^2) | -- |
| shortwave_radiation_out | SW_OUT (W/m2) | rad_short_out_avg (w_per_m2) | Fsu (W/m^2) | -- |
| longwave_radiation_in | LW_IN (W/m2) | rad_long_in_avg (w_per_m2) | Fld (W/m^2) | -- |
| longwave_radiation_out | LW_OUT (W/m2) | rad_long_out_avg (w_per_m2) | Flu (W/m^2) | -- |
| net_radiation | NETRAD (W/m2) | rad_net_avg (w_per_m2) | -- (Fa is available energy, not Rn) | -- |

All radiation variables use W/m2 natively. No conversion needed.

---

## 10. vapor_pressure_deficit

| Field | Value |
|-------|-------|
| **Canonical name** | `vapor_pressure_deficit` |
| **Canonical unit** | kPa |
| **Tier** | 2* (2/5 networks direct) |

| Network | Raw Variable(s) | Raw Unit | Conversion | Notes |
|---------|-----------------|----------|------------|-------|
| ICOS | `VPD` | kPa | None | VPD_1..9 are multi-height profiles |
| SAEON | `pressure_vapour_def_avg` | hPa | / 10.0 | Confirmed: profile lists unit as "hpa", values 6.2-12.8 |
| TERN | -- (derivable from Ta + RH) | -- | VPD = es(Ta) * (1 - RH/100) | Not a direct variable |
| eLTER | -- | -- | -- | |
| NEON | -- | -- | -- | |

---

## 11. soil_heat_flux

| Field | Value |
|-------|-------|
| **Canonical name** | `soil_heat_flux` |
| **Canonical unit** | W/m2 |
| **Tier** | 2 (3/5 networks) |

| Network | Raw Variable(s) | Raw Unit | Notes |
|---------|-----------------|----------|-------|
| ICOS | `G_1`, `G_2` | W/m2 | Multiple heat flux plates; average or select primary |
| SAEON | `heat_flux_ground` | w_per_m2 | |
| TERN | `Fg` | W/m^2 | Fg_8cma, Fg_8cmb etc. (multiple sensors) |
| eLTER | -- | -- | Not in SOATM or SOHYD |
| NEON | -- | -- | |

---

## 12. Soil Texture (sand, clay, silt)

| Field | Value |
|-------|-------|
| **Canonical names** | `soil_texture_sand`, `soil_texture_clay`, `soil_texture_silt` |
| **Canonical unit** | % (by mass) |
| **Tier** | 2 (3/5 networks) |
| **Type** | Static (not time-series) |

| Network | Raw Variables | Notes |
|---------|--------------|-------|
| ICOS | ANCILLARY files (GRP_BASAL_AREA etc.) | Long-format ancillary; requires extraction from VARIABLE_GROUP |
| SAEON | -- | Not in profiled data |
| eLTER | SOGEO-001 files | Available for DE, FI, ES sites |
| TERN | -- | Not in profiled data |
| NEON | `sandTotal`, `clayTotal`, `siltTotal` | Lab grain size analysis (mass %). Also in megapit_data. |

---

## Summary: Conversion Quick Reference

| Variable | Networks Needing Conversion | Formula |
|----------|---------------------------|---------|
| soil_water_content | ICOS, SAEON, eLTER | value / 100.0 (percent to fraction) |
| vapor_pressure_deficit | SAEON | value / 10.0 (hPa to kPa) |
| depth (eLTER) | eLTER (DE, AT) | abs(VERT_OFFSET) (negative to positive cm) |
| missing values | ICOS | replace(-9999, NaN) |
| missing values | SAEON, eLTER CSV | replace("", NaN); replace(blank, NaN) |
| timestamps | ICOS | parse YYYYMMDDHHmm to ISO 8601 UTC |

All other variables require no unit conversion -- only column renaming and potential temporal aggregation.

---

**End of Cross-Network Mapping**
