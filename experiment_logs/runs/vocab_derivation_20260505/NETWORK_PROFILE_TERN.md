# TERN Network Profile

**Network:** Terrestrial Ecosystem Research Network (TERN)
**Region:** Australia (tropical, temperate, arid ecosystems)
**Profile Date:** 2026-05-05
**Files Analyzed:** 31 NetCDF files (10 L3, 21 L6) + 1 soil texture Excel file

---

## 1. Data Structure

- **Format:** NetCDF (CF-conventions-like), wide-format with one variable per NetCDF variable
- **Processing levels:** L3 (gap-filled, quality-controlled), L6 (post-processed with derived fluxes)
- **Temporal resolution:** 30-minute intervals
- **Timestamp:** NetCDF time dimension (numeric, days/seconds since reference epoch)
- **Missing data:** -9999.0 (not always set in `_FillValue` attributes)
- **Variable metadata:** Rich NetCDF attributes including `units`, `long_name`, `height`, `instrument`, `valid_range`, `statistic_type`
- **QC flags:** Every variable has a companion `{VarName}_QCFlag` (int, 0=good)

## 2. Core Variables

### Air Temperature (Ta)
- **Variable:** `Ta` (aggregate), `Ta_HMP_30m`, `Ta_HMP_7m`, etc.
- **Unit:** `degC` (from NetCDF `units` attribute)
- **Long name:** "Air temperature"
- **Height:** Specified in `height` attribute (e.g., "30m", "7m")
- **Instruments:** HMP45C, HMP155 (humidity-temperature probes)
- **Value range:** -9999 to ~49 degC
- **Present in:** 30/31 files

### Precipitation (Precip)
- **Variable:** `Precip`, `Precipa`, `Precipb` (multiple gauges)
- **Unit:** `mm` (per 30-min interval)
- **Long name:** "Rainfall"
- **Height:** 0.6m (gauge height)
- **Present in:** 30/31 files

### Soil Water Content (Sws) -- CRITICAL VARIABLE
- **Variable:** `Sws` (aggregate), `Sws_5cm`, `Sws_10cm`, `Sws_20cm`, `Sws_100cm`, etc.
- **Unit:** `m^3/m^3` (volumetric FRACTION, 0-1 scale)
- **Long name:** "Soil water content"
- **Height attribute:** Negative values indicating depth (e.g., "-0.08m", "-0.1m", "-1m")
- **Value range:** 0 to ~1.009 (slight oversaturation possible)
- **Spatial replication:** `Sws_10cm_a`, `Sws_10cm_b`, `Sws_10cm_c` or `_N`, `_S`
- **Depth coverage varies by site:**
  - Boyagin: -0.05m, -0.1m
  - Calperum: -0.1m, -1m
  - Collie: -0.05m, -0.1m, -0.3m
  - AliceSpringsMulga: 0 to -0.1m, -1 to -1.2m (range notation)
  - CumberlandPlain: -0.08m, plus angled probes 0-0.15m, 0.08-0.38m vertical

**CONFIRMED: TERN Sws is in m^3/m^3 (fraction), NOT percent.** Sample values: 0.104, 0.361 (CumberlandPlain).

### Soil Temperature (Ts)
- **Variable:** `Ts` (aggregate), `Ts_5cm`, `Ts_10cm`, `Ts_100cm`, etc.
- **Unit:** `degC`
- **Long name:** "Soil temperature"
- **Height attribute:** Negative values (e.g., "-0.08m", "-0.1m", "-1m")
- **Spatial replication:** Same pattern as Sws (`_a`, `_b`, `_c`, `_N`, `_S`)

### Other Variables
| Variable | Units | Long Name | Notes |
|----------|-------|-----------|-------|
| AH | g/m^3 | Absolute humidity | Multiple heights |
| RH | % | Relative humidity | HMP sensor |
| VPD | hPa | Vapor pressure deficit | Computed |
| ps | hPa | Air pressure | Barometer |
| Fsd | W/m^2 | Down-welling shortwave radiation | CNR4 radiometer |
| Fsu | W/m^2 | Up-welling shortwave radiation | |
| Fld | W/m^2 | Down-welling longwave radiation | |
| Flu | W/m^2 | Up-welling longwave radiation | |
| Fn | W/m^2 | Net radiation | |
| Fg | W/m^2 | Ground heat flux | Huskeflux HFP01 |
| PAR | umol/m^2/s | Photosynthetically active radiation | LI190SB |
| Fco2 | umol/m^2/s | CO2 flux | Eddy covariance |
| Fe | W/m^2 | Latent heat flux | |
| Fh | W/m^2 | Sensible heat flux | |
| Ws | m/s | Wind speed | |
| Wd | degrees | Wind direction | |

## 3. Soil Texture (Excel file)

**File:** `tern_soil_texture_data.xlsx`
- **242 rows** covering multiple sites and depth layers
- **Sites identified by:** `fluxTowerNameShort` (matches NetCDF filenames)

### Key Columns
| Column | Unit | Example |
|--------|------|---------|
| sand_percentage | % (0-100) | 76.0 |
| clay_percentage | % (0-100) | 14.0 |
| silt_percentage | % (0-100) | 10.0 |
| soilDepthMin_Metre | m | 0.00 |
| soilDepthMax_Metre | m | 0.05 |
| soilTextureGrade | categorical | "Clay loam", "Sandy loam" |
| soilTextureModifier | categorical | (optional) |
| dataType | categorical | "modelled data" |
| latitude_Degree | deg | -13.0769 |
| longitude_Degree | deg | 131.1178 |

- **Depth layers (metres):** 0-0.05, 0.05-0.15, 0.15-0.30, 0.30-0.60, 0.60-1.00, 1.00-2.00
- **Data source:** Mainly "Soil and Landscape Grid National Soil Attribute Maps" (modelled, 90x90m grid)

## 4. Site Metadata

- **31 flux tower sites** across Australia
- Global attributes in each NetCDF include site name, lat/lon, elevation, vegetation type
- Site names: AliceSpringsMulga, Boyagin, Calperum, Collie, CowBay, CumberlandPlain, DalyUncleared, DryRiver, Emerald, etc.

## 5. Key Observations

1. **SWC in fraction (m^3/m^3)** -- unambiguous from NetCDF `units` attribute. This is the key differentiator from ICOS/SAEON (percent).
2. **Rich metadata** in NetCDF attributes: units, long_name, height, instrument, valid_range, statistic_type
3. **Depth encoding in variable names** (e.g., Sws_10cm) AND in `height` attribute (e.g., "-0.1m")
4. **Spatial replication** with letter suffixes (a/b/c or N/S)
5. **Soil texture depths in metres** (0-0.05, 0.05-0.15, etc.) -- standard GlobalSoilMap layers
6. **One corrupted file:** DryRiver_L3.nc unreadable (HDF error)
7. **No unit row ambiguity** -- units explicitly declared in NetCDF attributes
