# Decision Log: TERN Full Pipeline Run 2026-05-05 (All Sites)

## Site Selection Decisions

- Processed ALL available NetCDF files: 10 L3 + 18 L6-only = 28 unique sites.
- L3 preferred where available (quality-controlled data).
- L6 used as fallback for corrupt L3 (DryRiver) and for sites with only L6 data.
- L6-only sites: AliceSpringsMulga, Collie, CowBay, Emerald, FletcherviewTropicalRangeland, FoggDam, Litchfield, Longreach, MyallValeA, Ridgefield, RiggsCreek, RobsonCreek, SilverPlains, SturtPlains, WallabyCreek, Wellington, WombatStateForest1, YarramundiControl

## Variable Selection Decisions

- **Air Temperature**: Selected `Ta` (aggregated best-estimate variable).
  Confidence: HIGH

- **Precipitation**: Selected `Precip` (aggregated).
  Confidence: HIGH

- **Soil Water Content**: Selected `Sws` (aggregated best-estimate variable).
  Confidence: HIGH

- **Soil Temperature**: Selected `Ts` (aggregated best-estimate variable).
  Confidence: HIGH

- **Soil Texture**: NOT PRODUCED.
  Rationale: TERN OzFlux NetCDF files contain only time-series flux/met data. Static soil texture not included.

## Unit Conversion Decisions

- **SWC**: Converted from m^3/m^3 (volumetric fraction, 0-1) to percent (0-100) by multiplying by 100.
- **Air Temperature**: No conversion needed (already degC).
- **Soil Temperature**: No conversion needed (already degC).
- **Precipitation**: No conversion needed (already mm per 30-min interval).

## QC Decisions

- Replaced -9999 sentinel values with NaN.
- Applied physical bounds: Ta [-60,60], Ts [-30,70], Precip [0,500], SWC [0,100]%.

## Data Level Decisions

- 9 sites used L3 (quality-controlled).
- 1 sites used L6 as fallback for corrupt L3.
- 18 sites used L6-only (no L3 available).
- L6 data is gap-filled: expect higher valid-value percentages vs L3.

## Metadata Decisions

- L3 sites: metadata from validated hardcoded values (prior runs).
- L6-only sites: lat/lon/elevation extracted from NetCDF global attributes.
- Sites with missing elevation (Collie, Emerald, FoggDam, SturtPlains, WallabyCreek): stored as None.
