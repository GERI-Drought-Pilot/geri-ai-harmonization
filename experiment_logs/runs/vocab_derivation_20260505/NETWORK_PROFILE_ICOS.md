# ICOS Network Profile

**Network:** Integrated Carbon Observation System (ICOS)
**Region:** Europe (Belgium, Switzerland, Czechia, Germany, Denmark, Finland, France, Greenland, Italy, Netherlands, Norway, Sweden, UK)
**Profile Date:** 2026-05-05
**Files Analyzed:** 39 METEO L2 CSVs + 40 ANCILLARY CSVs (soil texture/chemistry)

---

## 1. Data Structure

- **Format:** Wide-format CSV, comma-delimited
- **File naming:** `ICOSETC_{SITE_ID}_METEO_L2.csv`
- **Site ID format:** `{CC}-{Xxx}` (e.g., FI-Hyy, DE-Tha)
- **Temporal resolution:** 30-minute intervals
- **Timestamp format:** `YYYYMMDDHHmm` (compact numeric, no separators)
- **Timestamp columns:** `TIMESTAMP_START`, `TIMESTAMP_END`
- **Missing data sentinel:** `-9999`

## 2. Core Variables

### Air Temperature
- **Columns:** `TA` (aggregate), `TA_1` through `TA_9` (sensor-level at different heights)
- **Unit:** degC (inferred; values range -32 to +32)
- **Statistic:** Half-hourly mean

### Precipitation
- **Column:** `P`
- **Unit:** mm (per 30-min interval)
- **Statistic:** Total per period

### Soil Water Content (SWC)
- **Columns:** `SWC_1` through `SWC_7` (varies by site, typically 5)
- **Associated:** `SWC_X_SD` (std dev), `SWC_X_N` (sensor count)
- **Unit:** PERCENT (%) -- confirmed by value ranges at most sites
- **Evidence from data:**
  - BE-Bra: 12.15-12.26 (sandy soil, low moisture)
  - BE-Dor: 45.06-45.22
  - CH-Dav: 20.87-20.99
  - FI-Hyy: 11.47-11.48
  - FI-Sii: 82.25-82.39 (peatland)
  - FI-Sod: 0.52-0.58 (**ANOMALY: appears fraction, not percent**)
  - FR-Gri: 40.71-40.90
  - IT-BCi: 42.32-48.13
  - SE-Deg: 58.9-99.16 (peatland)
  - UK-AMo: 68.45-69.92 (peatland)
- **Depth encoding:** Numeric suffix (1-7); actual depths NOT in CSV headers
- **CRITICAL FINDING:** FI-Sod values 0.52-0.58 suggest fraction not percent -- possible inconsistency within ICOS

### Soil Temperature
- **Columns:** `TS_1` through `TS_8` (typically 6)
- **Associated:** `TS_X_SD`, `TS_X_N`
- **Unit:** degC
- **Depth encoding:** Same numeric suffix convention

### Other Variables Present in All Files
| Variable | Description | Likely Unit |
|----------|-------------|-------------|
| RH, RH_1-9 | Relative humidity | % |
| PA | Atmospheric pressure | kPa (values ~96-98) |
| SW_IN, SW_OUT | Shortwave radiation | W/m2 |
| LW_IN, LW_OUT | Longwave radiation | W/m2 |
| PPFD_IN, PPFD_OUT, PPFD_DIF | Photosyn. photon flux density | umol/m2/s |
| G_1, G_2 | Ground heat flux | W/m2 |
| D_SNOW | Snow depth | cm? |
| ALB | Albedo | fraction |
| NETRAD | Net radiation | W/m2 |
| VPD, VPD_1-9 | Vapor pressure deficit | hPa |
| WS | Wind speed | m/s |
| WD | Wind direction | degrees |

## 3. Soil Texture (ANCILLARY L2)

### Structure
- **Format:** Long (key-value) CSV: SITE_ID, GROUP_ID, VARIABLE_GROUP, VARIABLE, DATAVALUE
- **Variable group:** `GRP_SOIL_TEX`
- **Depth reference:** `SOIL_TEX_PROFILE_ZERO_REF` = "Top of mineral soil"
- **Depth columns:** `SOIL_TEX_PROFILE_MIN`, `SOIL_TEX_PROFILE_MAX` (cm)
- **Standard depth layers:** 0-5, 5-15, 15-30, 30-60, 60-100 cm

### Variables
| Variable | Unit | Example |
|----------|------|---------|
| SOIL_TEX_SAND | % (0-100) | 91.67 (BE-Bra, 0-5cm) |
| SOIL_TEX_SILT | % (0-100) | 4.87 (BE-Bra, 0-5cm) |
| SOIL_TEX_CLAY | % (0-100) | 3.47 (BE-Bra, 0-5cm) |
| SOIL_TEX_ROCK | % (0-100) | 22.77 (FI-Hyy, 0-5cm) |

- Not all sites have sand/clay/silt (some only have rock content)
- Statistics: Mean and SD from spatially aggregated samples (typically 3-23 samples)

## 4. Site Metadata
- **File:** `icos_site_info.csv`
- **Fields:** Site ID, Country, Site Name, Latitude (deg), Longitude (deg), Elevation (m)
- **39 sites** across 14 countries

## 5. Key Observations

1. **Standardized format** -- very consistent across all 39 sites
2. **SWC depth mapping unknown** -- numeric suffixes (1-5) lack explicit depth metadata in CSV
3. **SWC predominantly percent** (4-99 range) but FI-Sod is an outlier at 0.52-0.58
4. **Soil texture** uses standard GlobalSoilMap-compatible depth bins
5. **No explicit unit row** in CSV headers -- units must be inferred or looked up
6. **Rich multi-level atmospheric measurements** -- up to 9 height levels for TA, RH, VPD
