# Decision Log: NEON All-Sites Run 20260504_222223

## Data Source Decisions
- **Air Temperature**: Used proc_neon_airtemperature_data.parquet (pre-processed, 47 sites)
  Sensor positions from sensor_positions_selected_00003.csv (topmost tower level per site)
- **Precipitation**: Used proc_neon_precipitation_data.parquet (pre-processed, 46 sites)
  Site coordinates from NEON_Field_Site_Metadata for lat/lon/elevation
- **Soil Moisture**: Used neon_soilmoisture_merged_data.parquet (merged, 39 sites, 179M rows)
  LIMITATION: depth=NaN because verticalPosition was lost during upstream data merge
- **Soil Temperature**: Used chunk_{1-8}_neon_soiltemperature_data.parquet (8 chunks, 39 sites)
  Depth from sensor position height field (already negative meters)
- **Soil Texture**: Used proc_neon_soiltexture_data.parquet (pre-processed, 47 sites)

## Unit Conversion Decisions
- **SWC**: CRITICAL — VSWCMean is fraction (0-1), multiplied by 100 for percent (0-100)
- **Air/Soil Temperature**: Already in Celsius, no conversion needed
- **Precipitation**: Already in mm, no conversion needed
- **Soil Texture**: Already in percent, no conversion needed
- **Depths**: Already negative (meters below ground) in source data

## QC Decisions
- Air temp: dropped NaN + range filter (-80 to 60°C)
- Precipitation: dropped NaN + range filter (0 to 500mm)
- Soil moisture: dropped NaN + range filter (0-100% after conversion)
- Soil temperature: dropped NaN + range filter (-40 to 60°C)
- Soil texture: dropped rows where sand+clay+silt not ≈100 (95-105)

## Known Limitations
- Soil moisture depth=NaN for all rows (39 sites)
  Cause: verticalPosition (501-508) was dropped during upstream merge of raw NEON data
  Impact: Cannot assign sensor depths; would need re-download from NEON API with verticalPosition preserved
- STER site missing from precip (46/47 sites vs 47/47 for air temp)

## Output Summary
- air_temperature: 6,319,753 rows, 47 sites
- precipitation: 2,850,653 rows, 46 sites
- soil_moisture: 123,634,173 rows, 39 sites
- soil_temperature: 177,112,510 rows, 39 sites
- soil_texture: 452 rows, 47 sites
