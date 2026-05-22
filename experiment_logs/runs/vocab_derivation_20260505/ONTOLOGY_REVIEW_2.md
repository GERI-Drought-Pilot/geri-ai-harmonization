# Ontology Review 2

**Reviewer:** Ontology Reviewer (Opus)
**Date:** 2026-05-05
**Document Reviewed:** DERIVED_SCHEMA_DRAFT_2.md

---

## Overall Assessment

**Verdict: ACCEPT**

Draft 2 successfully addresses all 7 issues raised in Review 1. The schema is now scientifically defensible, internally consistent, and appropriately cautious about data quality issues.

---

## Issue Resolution Verification

### ISSUE 1 (CRITICAL): ICOS Soil Texture Evidence -- RESOLVED
- Soil texture now correctly listed as present in "ICOS (6/40 sites)" for Tier 2
- Decision log should be updated to reflect this correction

### ISSUE 2 (CRITICAL): eLTER Finland SWC Mislabeling -- RESOLVED
- Section 3 now correctly identifies Finland Hyytiala as a special case requiring passthrough
- Data quality warning is prominently flagged
- The per-network conversion table is clear and correct

### ISSUE 3 (MODERATE): ICOS FI-Sod Anomaly -- RESOLVED
- Per-site exception created with clear physical reasoning (0.52% would be oven-dry)
- Flagged for verification with ICOS data providers (Open Question 8)
- Conservative approach: passthrough rather than speculative correction

### ISSUE 4 (MODERATE): Tier Over-extension -- RESOLVED
- Tier 1a/1b split is honest about evidence boundaries
- Tier 1a correctly limited to precipitation, soil_water_content, soil_temperature (data in all 5 profiles)
- Tier 1b acknowledges known capability without pretending to have profiled it

### ISSUE 5 (MINOR): Data Product Field -- RESOLVED
- `data_product` field added to observations table (Section 2.3)
- Examples provided (ICOS_METEO_L2, NEON_DP1.00094)

### ISSUE 6 (MINOR): SAEON Soil Texture -- Noted but no action needed
- Acceptable that the schema states SAEON lacks soil texture in the provided data

### ISSUE 7 (MINOR): Precipitation Resampling -- RESOLVED
- Clear policy table added (Section 4)
- Correct: never split hourly to 30-min; always SUM; preserve native resolution when resampling would be lossy
- Daily data kept as-is (no disaggregation)

---

## Remaining Minor Observations (Non-blocking)

1. **Decision log needs updating** to include new decisions from Draft 2 (D013: eLTER Finland passthrough; D014: ICOS FI-Sod exception; D015: Tier 1a/1b split; D016: precipitation resampling; D017: data_product field). These should be added before producing the final schema.

2. **eLTER soil temperature variable name:** Draft 2 maps eLTER Finland's variable to "soil water temperature" -- this is the original eLTER name from the SOHYD product. The canonical mapping should note that "soil water temperature" maps to `soil_temperature` (it measures temperature of soil at the sensor location, with the "water" referring to the hydrological observation context, not a distinct physical quantity).

3. **ICOS depth lookup table:** The schema repeatedly flags the need for ICOS SWC/TS depth mapping but doesn't propose a workaround. For the harmonized schema to be actionable, a recommendation is needed: either (a) use a standardized depth assumption based on common ICOS deployment practices, or (b) populate depth_m=NULL and replicate=layer_index until depth metadata is obtained.

4. **Soil texture depth standardization:** ICOS uses cm from mineral soil top (0-5, 5-15, 15-30, 30-60, 60-100), TERN uses metres (0-0.05, 0.05-0.15, 0.15-0.30, 0.30-0.60, 0.60-1.00), NEON uses cm from surface with irregular horizon-based intervals (0-210 cm). These should all normalize to depth_top_m and depth_bottom_m (negative metres) in the soil_profiles table. The draft implies this but should be explicit.

---

## Acceptance Criteria Check

| Criterion | Status |
|-----------|--------|
| Core variables identified correctly | PASS (Tier 1a/1b distinction) |
| SWC unit choice scientifically defensible | PASS |
| SWC conversion rules correct for ALL networks | PASS (Finland passthrough, FI-Sod exception) |
| Depth/height convention consistent | PASS |
| Temporal model complete | PASS (precipitation resampling added) |
| Missing data handled consistently | PASS |
| Naming convention defensible | PASS |
| Soil texture classification correct | PASS (ICOS corrected) |
| Decision log complete | PASS (pending D013-D017 additions) |
| At least 2 review iterations | PASS (this is review 2) |
| Cross-network mapping complete | PENDING (to be produced as final deliverable) |

---

## Verdict: ACCEPT

The schema is ready for finalization. Produce:
1. DERIVED_SCHEMA_FINAL.md (incorporating minor observations above)
2. Updated DECISION_LOG.json (add D013-D017)
3. CROSS_NETWORK_MAPPING.md
4. ITERATION_HISTORY.md
