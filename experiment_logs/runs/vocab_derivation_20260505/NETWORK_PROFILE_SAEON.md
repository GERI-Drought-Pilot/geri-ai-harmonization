# SAEON Network Profile

**Network:** South African Environmental Observation Network (SAEON)
**Region:** South Africa (grassland, savanna, fynbos ecosystems)
**Profile Date:** 2026-05-05
**Files Analyzed:** 8 Eddy Covariance CSV files

---

## 1. Data Structure

- **Format:** Wide-format CSV, comma-delimited
- **Comment lines:** Lines starting with `#` (citation info)
- **Unit row:** Row 2 (after header) contains unit abbreviations for each column
- **File naming:** `saeonflux_{SiteName}_{Ecosystem}_Eddy_Covariance.csv`
- **Temporal resolution:** 30-minute intervals
- **Timestamp format:** ISO 8601 (`2024-07-31T18:30:00`) in `Timestamp` column, plus `timestamp_start`/`timestamp_end` in `YYYYMMDDHHmm` format
- **Missing data:** Empty cells (no sentinel value)
- **Naming style:** lowercase_with_underscores, descriptive prefixes

## 2. Core Variables

### Air Temperature
- **Columns:** `temp_air_avg`, `temp_air_EC100_avg`, `temp_air_sonic_avg`, `temp_air_sonic_only_avg`, `temp_air_sonic_only_sd`
- **Unit:** `deg_c` (degrees Celsius)
- **Multiple sensors:** EC100 probe, sonic anemometer, general/hybrid
- **Typical discrepancy:** Sonic > hybrid > EC100 by ~1-2 degC

### Precipitation
- **Column:** `rain_tot`
- **Unit:** `mm` (total per 30-min period)

### Soil Moisture
- **Columns:** `moisture_soil_s1_avg` through `moisture_soil_s4_avg`
- **Unit:** `pcnt` (percent, volumetric)
- **Evidence from data:** Benfontein Karoo values 5.17-5.84 (arid); other sites up to ~35%
- **Depth encoding:** `_s1` through `_s4` (actual depths not specified in CSV)
- **Availability:** s1, s2 in all 8 files; s3, s4 in 6/8 files (Cath Peak and Jonkershoek lack deeper layers)

### Soil Temperature
- **Columns:** `temp_soil_s1_avg`, `temp_soil_s2_avg`
- **Unit:** `deg_c`
- **Depth encoding:** Same `_s1`, `_s2` convention as soil moisture
- **All 8 sites** have both layers

### Other Variables Present
| Variable | Unit | Description |
|----------|------|-------------|
| humid_rel_avg | pcnt | Relative humidity |
| pressure_atm_avg | hpa | Atmospheric pressure |
| pressure_vapour_def_avg | hpa | Vapor pressure deficit |
| rad_short_in_avg, rad_short_out_avg | w_per_m2 | Shortwave radiation |
| rad_long_in_avg, rad_long_out_avg | w_per_m2 | Longwave radiation |
| rad_net_avg | w_per_m2 | Net radiation |
| rad_photo_active_avg | umol_per_m2_per_s | PAR |
| heat_flux_ground | w_per_m2 | Ground heat flux |
| heat_flux_lat_corr | w_per_m2 | Latent heat flux |
| heat_flux_sens_corr | w_per_m2 | Sensible heat flux |
| wind_speed_avg, wind_dir_avg | m_per_sec, deg | Wind |
| co2_flux_umol | umol_per_m2_per_s | CO2 flux |
| albedo | pcnt | Surface albedo |
| Latitude, Longitude | degrees | Site coordinates (constant per file) |

## 3. Soil Texture

**No soil texture data** found in any SAEON CSV files. Only continuous timeseries soil moisture and temperature are provided.

## 4. Site Metadata

- **8 sites** across South Africa:
  1. Benfontein Karoo (arid grassland)
  2. Benfontein Savanna
  3. Cath Peak Grassland
  4. Jonkershoek Fynbos
  5. Maputaland Coastal Cashews Grassland
  6. Maputaland Umhlabuyalingana Grassland
  7. Skukuza Savanna
  8. Spioenkop Savanna
- Coordinates embedded in each data file as constant columns

## 5. Key Observations

1. **Explicit unit row** in CSV (row 2) -- units are clearly specified, unlike ICOS
2. **SWC in percent** (unit `pcnt`), values 5-35 range
3. **No soil texture** data available -- only timeseries soil measurements
4. **Depth suffixes** `_s1` through `_s4` without explicit depth metadata
5. **Multiple temperature sensors** per site (EC100, sonic, hybrid) -- need to choose canonical
6. **Quality flags** use `ss_itc_test` convention (1=good, 2=uncertain, 3=poor, 9=missing)
7. **Consistent structure** across all 8 sites with minor column variations
