# Iteration History: Ontology Derivation

**Experiment**: ontology_derivation_20260401
**Date**: 2026-04-01

---

## Timeline

| Event | Artifact | Status |
|-------|----------|--------|
| Draft 1 written | DERIVED_SCHEMA_DRAFT_1.md | Complete |
| Decision Log v1 | DECISION_LOG.json (D001-D008) | Complete |
| Review Round 1 | ONTOLOGY_REVIEW_1_CRITICAL.md | Verdict: REVISE |
| Draft 2 written | DERIVED_SCHEMA_DRAFT_2.md | Complete |
| Decision Log v2 | DECISION_LOG.json (D001-D012) | Complete |
| Review Round 2 | ONTOLOGY_REVIEW_2.md | Verdict: ACCEPT |
| Final deliverables | DERIVED_SCHEMA_FINAL.md, CROSS_NETWORK_MAPPING.md | Complete |

---

## Draft 1 -> Draft 2: Changes

### Critical Issues Fixed (from ONTOLOGY_REVIEW_1_CRITICAL.md)

**C1 (HIGH) - RH Tier 1 Misclassification**:
- Problem: RH was classified as Tier 1 ("all 5 networks") but NEON has no RH in profiled data products. The justification "derivable from water vapor" was speculative.
- Fix: Demoted RH to Tier 2 (4/5 networks). Tier 1 now contains exactly 4 variables: air_temperature, precipitation, soil_water_content, soil_temperature. Added Decision D009 documenting the principle "derivable != present."

**C2 (TRIVIAL) - Section 4.1 Title Contradiction**:
- Problem: Title said "Tidy Long Format" but the design decision chose wide format.
- Fix: Retitled to "Wide Format with Depth-in-Column-Name."

**C3 (HIGH) - eLTER Depth Conversion Missing**:
- Problem: Schema chose positive-downward cm but eLTER uses negative cm (VERT_OFFSET: -10, -20, -30). No conversion formula was provided.
- Fix: Added eLTER depth conversion to Appendix A: `depth_cm = abs(VERT_OFFSET)`. Documented that eLTER's negative convention comes from CF oceanographic conventions.

**C4 (HIGH) - Soil Texture Units Ambiguity**:
- Problem: "Percent (%)" did not specify mass % vs volume %.
- Fix: Verified NEON uses laboratory grain size analysis (mass-based). eLTER profile explicitly states "percentage by mass." Updated units table to read "Percent by mass" and noted in soil texture table description.

**C5 (MEDIUM) - VPD SAEON Units Verification**:
- Problem: Decision D008 claimed SAEON VPD is in hPa but cited no source.
- Fix: Verified from SAEON profile: `pressure_vapour_def_avg` listed with unit `hpa` and sample values 6.2-12.8. Confirmed hPa. Added source citation in schema.

**C6 (MEDIUM) - QC Flag Mappings Incomplete**:
- Problem: eLTER mapping only showed FLAGQUA 0->0. SAEON "ITC test" reference was unclear.
- Fix: Completed eLTER mapping (0->0, 1->1, 2->2). Clarified that SAEON ITC test flags apply only to flux variables (CO2, ET, sensible/latent heat, momentum), not meteorological variables. Added specific thresholds: ITC 1-2 -> Good, 3-5 -> Suspect, 6-7 -> Bad. Added ICOS mapping using _N count. Added NEON finalQF + component QM thresholds.

**C7 (HIGH) - Coverage Inconsistency**:
- Problem: Tier 2 table claimed atmospheric_pressure, net_radiation, and VPD were present in TERN, but the mapping table showed TERN cells empty.
- Fix: Verified against TERN profile. Corrected: atmospheric_pressure to 3/5 (TERN has P in base variable list but not in L3 detail), net_radiation to 2/5 (TERN Fa is available energy, not net radiation), VPD to 2/5 (not a direct TERN variable). Added Decision D010 documenting these corrections.

**C8 (LOW) - Missing Data Conversion Incomplete**:
- Problem: "Others: trivially mapped" was vague. eLTER CSV and NEON specifics not listed.
- Fix: Explicitly listed conversion rules for all 5 networks in Section 7.1.

### Moderate Issues Addressed

**M1 - Multi-Height Air Temp Already Decided**: Removed from Open Questions (was already resolved by Section 5.2).

**M2 - Non-Integer Depth Naming**: Added guidance: use nearest integer in column name, record exact depth in metadata table.

**M3 - Aggregation Methods**: Added Section 6.2 with per-variable-type aggregation rules (mean for intensive, sum for extensive, vector mean for directional).

**M4 - Site ID Collision (FI-Hyy)**: Added note in Section 9.2 that cross-network sites use the same site_id, differentiated by `network` column.

**M5 - Snow Depth Decision**: Excluded variables now documented in Section 2.3.

### New Decisions Added

| ID | Category | Summary |
|----|----------|---------|
| D009 | variable_identification | RH demoted to Tier 2; principle "derivable != present" established |
| D010 | variable_identification | Net radiation, VPD, atmospheric pressure coverage corrected |
| D011 | temporal | Sub-30-min aggregation methods specified per variable type |
| D012 | schema_structure | Multiple soil profiles handled via profile_id column |

### Enhancements Added

- Section 2.3: Variables considered but excluded (with rationale)
- Section 4.1: Variable-width schema note, non-integer depth guidance, profile_id for dual profiles
- Section 6.2: Aggregation methods table
- Section 6.3: Coarser-than-30-min data handling
- Section 7.1: NaN/NULL terminology note
- Section 8.1: Complete per-network QC mapping with thresholds
- Section 10: eLTER SO module provenance notes
- Section 12: Revision history in draft itself

---

## Draft 2 -> Final: Changes

No substantive changes. Reviewer Round 2 verdict was ACCEPT. Minor observations from Round 2 review (M1-M5) are documented below as implementation notes for the final schema but do not change the schema content:

- M1: Decision D002 text updated to reference D009 superseding its RH claim
- M2: VPD and net_radiation at 2/5 retained with asterisk notation (below strict Tier 2 threshold but included for scientific importance)
- M3: Coarser-than-30-min data stored at native resolution; users should filter by temporal_resolution
- M4: TERN replicate sensors should be averaged before entering harmonized table; NEON horizontal positions vary by site
- M5: ICOS _N as QC proxy is an approximation (measures data presence, not sensor calibration quality)

---

## Review Verdicts

| Round | Reviewer | Draft Reviewed | Verdict | Critical Issues | Concerns |
|-------|----------|----------------|---------|-----------------|----------|
| 1 | Ontology Reviewer | Draft 1 | REVISE | 8 | 5 |
| 2 | Ontology Reviewer | Draft 2 | ACCEPT | 0 (all resolved) | 5 minor (non-blocking) |

---

**End of Iteration History**
