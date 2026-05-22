# eLTER Network Profile

**Network:** European Long-Term Ecosystem Research (eLTER)
**Region:** Europe (Finland, Germany, Spain, Austria)
**Profile Date:** 2026-05-05
**Files Analyzed:** Mixed formats across 4 countries (Parquet, CSV, XLSX)

---

## 1. Data Structure

- **Format:** Mixed -- Parquet (Finland), CSV long-format (Germany), CSV semicolon-delimited (Spain), CSV semicolon with units-in-headers (Austria)
- **Observation types (standard eLTER schema):**
  - SOATM-027: Atmospheric/meteorological
  - SOGEO-001: Soil geomorphological (texture, classification -- static)
  - SOHYD-168: Soil hydrological (water content, temperature -- dynamic)
- **Temporal resolution:** 1-minute (Finland), 10-minute (Germany), daily (Spain), 30-minute (Austria)
- **Timestamp format:** ISO 8601, but timezone varies (UTC for Finland/Germany, local CET for Austria)
- **Missing data:** NaN / empty cells

## 2. Core Variables

### Air Temperature
| Site | Variable Name | Unit | Format |
|------|--------------|------|--------|
| Finland (Hyytiala) | T336, T270icos, T168, T84, T88icos | degC | Wide-format columns with height in name (dm) |
| Germany (DE-HoH) | Tair50HMP, Tair14PT | degC | Long-format VARIABLE column |
| Spain (Donana) | TA_A, TA_Z, TA_X | degree_Celsius | Semicolon CSV long-format |
| Austria (Rosalia) | Air Temperature [deg C] | degC | Unit embedded in header |

- Height encoding: Finland uses decimeters in name (T168 = 16.8m); Germany uses VERT_OFFSET in mm (4900 = 49m tower height)

### Precipitation
| Site | Variable Name | Unit |
|------|--------------|------|
| Finland | Precip, Precipacc, Precipacc_GPM | mm |
| Germany | precip50 | mm |
| Spain | P_RAIN | mm |
| Austria | Precipitation [mm] | mm |

### Soil Water Content
| Site | Variable Name | Unit (declared) | Value Range | Actual Unit |
|------|--------------|----------------|-------------|-------------|
| Finland (SOHYD) | soil water content | % | 0.003-0.689 | **FRACTION (m3/m3) despite % label!** |
| Germany (SOHYD) | SMa010, SMb020, etc. | % | 26.46-26.59 | Volumetric percent |
| Austria (SOHYD) | soilmoisture[volpercent] | volpercent | 29.63-31.18 | Volumetric percent |
| Spain | N/A | -- | -- | No soil moisture data |

- **CRITICAL FINDING:** Finland Hyytiala labels SWC as "%" but values are 0.003-0.689, which is clearly volumetric fraction (m3/m3), NOT percent. This is a labeling error in the eLTER data.
- Germany depth encoding: SMa010 = soil moisture sensor A at 10cm depth
- Austria depth: Single depth at -10cm

### Soil Temperature
| Site | Variable Name | Unit | Depths |
|------|--------------|------|--------|
| Finland | soil water temperature | degC | -3.5, -11.5, -25.5, -50.0 cm |
| Germany | STa010, STb020, etc. | degC | 10, 20, ... 80 cm |
| Austria | soiltemp[degC] | degC | -10 cm |

### Other Variables
- Relative humidity: Finland (RHIRGA168, RH168), Germany (implicit), Austria (Air Relative Humidity [%])
- Wind speed/direction: Finland (WS336, WD336), Germany, Austria, Spain
- Atmospheric pressure: Finland (Pamb0), Germany, Austria, Spain

## 3. Soil Texture (SOGEO-001)

### Finland
- **Variables:** soil type classification, soil texture category, soil texture proportion, soil pH, bulk density, organic carbon, cation exchange capacity, hydraulic conductivity
- **Soil type:** Haplic Podzol
- **Texture:** Sandy loam
- **Proportions:** Stored as generic "soil texture proportion" with clay in MEDIUM column (e.g., 8.6%, 8.7%, 11%)
- **Depth:** VERT_OFFSET_FROM and VERT_OFFSET_TO (cm, negative below surface)

### Germany
- **Variables:** soil texture proportion (clay), soil texture proportion (sand), soil texture proportion (silt), soil texture category (-)
- **Unit:** % (0-100)
- **Example (60-65 cm):** clay=18.15%, sand=11.18%, silt=70.03%
- **Depth:** VERT_OFFSET_FROM, VERT_OFFSET_TO (cm, negative below surface)

### Austria (Rosalia)
- **Particle size distribution** in 5 fractions (Wentworth scale):
  - >2mm, 2-0.2mm, 0.2-0.02mm, 0.02-0.002mm, <0.002mm (clay)
- **NOT directly comparable** to standard sand/silt/clay classification without aggregation

## 4. Key Observations

1. **Highly heterogeneous format** across countries -- no two sites share the same file structure
2. **SWC unit crisis:** Finland labels values as "%" but they are clearly fraction (0-0.689). Germany and Austria correctly use volumetric percent (20-55 range).
3. **Height/depth encoding varies wildly:** Finland uses decimeters in column names, Germany uses mm in VERT_OFFSET, Austria uses cm in column names
4. **Timezone inconsistency:** Austria uses local time (CET +01:00), all others UTC
5. **Soil texture encoding differs:** Germany uses separate rows per fraction, Finland lumps proportions, Austria uses 5-class particle size
6. **Temporal resolution ranges from 1-minute to daily** across sites
7. **Spain has minimal coverage:** Only precipitation (P_RAIN) and some wind/temperature from Donana; no soil moisture or soil temperature
