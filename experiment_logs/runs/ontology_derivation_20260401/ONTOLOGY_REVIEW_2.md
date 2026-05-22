# Ontology Review -- Round 2

**Reviewer**: Reviewer Agent
**Date**: 2026-04-01
**Draft Reviewed**: DERIVED_SCHEMA_DRAFT_2.md
**Decision Log Reviewed**: DECISION_LOG.json (12 entries, D001-D012)

---

## Overall Assessment: ACCEPT

Draft 2 addresses all 3 critical issues and all 7 concerns from Round 1. The schema is now internally consistent, the coverage claims match the mapping table, and the new sections (aggregation methods, QC thresholds, excluded variables, depth guidance) are well-done. The remaining items below are minor observations and suggestions for the implementation phase -- none block acceptance.

---

## Verification of Round 1 Fixes

### Critical Issues -- All Resolved

| ID | Issue | Status | Verification |
|----|-------|--------|-------------|
| C1 | Section 4.1 title contradiction | FIXED | Title now reads "Wide Format with Depth-in-Column-Name" (line 147). Matches decision D004. |
| C2 | RH Tier 1 claim | FIXED | RH demoted to Tier 2 (4/5). Tier 1 now has exactly 4 variables. Decision D009 documents the rationale clearly. |
| C3 | NaN/NULL terminology | FIXED | Section 7.1 now includes a terminology note (line 326) clarifying NaN = NULL equivalence across contexts. |

### Concerns -- All Addressed

| ID | Concern | Status | Notes |
|----|---------|--------|-------|
| S1 | VPD coverage | FIXED | Corrected to 2/5. Decision D010 correctly identifies that derivable != present. |
| S2 | Net radiation coverage | FIXED | Corrected to 2/5. Correctly notes TERN Fa != Rn. |
| S3 | Atmospheric pressure | FIXED | Corrected to 3/5, TERN removed. |
| S4 | Soil heat flux eLTER | CONFIRMED | Absence confirmed and noted in Section 10. |
| S5 | Depth naming | ADDRESSED | Non-integer rounding rule added (Section 4.1, line 155). Variable-width schema acknowledged. profile_id column added for dual profiles. |
| S6 | Aggregation methods | ADDRESSED | Section 6.2 specifies per-variable-type methods including vector mean for wind direction. Appendix A includes the formula. |
| S7 | QC flag mapping | ADDRESSED | Section 8.1 provides specific thresholds per network with justification notes. |

### Reviewer Questions -- All Responded To

| Q | Topic | Response | Satisfactory? |
|---|-------|----------|---------------|
| Q1 | Austria SWC units | Confirmed percent via [volpercent] header | Yes |
| Q2 | ICOS 0.4 threshold | Validation note added; flag but don't exclude | Yes -- pragmatic approach |
| Q3 | SAEON depths | Flagged as Open Question 1 | Acceptable -- requires data inspection |
| Q4 | Snow depth | Excluded from v1, noted in Open Question 3 | Yes -- correct scoping |

---

## Minor Observations (Non-Blocking)

### M1. Decision Log D002 Not Updated to Match Draft 2

The decision log entry D002 still lists RH in Tier 1: "Tier 1 = present in 4-5 networks (air_temperature, precipitation, soil_water_content, soil_temperature, relative_humidity)." This contradicts D009 which demotes RH. The decision text should be updated for consistency, though D009 effectively supersedes it.

### M2. Net Radiation and VPD at 2/5 -- Below Tier 2 Threshold

The Tier 2 table header says "3-4 networks" but net_radiation (2/5) and VPD (2/5) are listed with asterisks. This is handled honestly with the asterisk notation, but strictly speaking these fall below the stated threshold. Consider either:
- Renaming them "Tier 2*" or "Provisional Tier 2" in the table, or
- Creating a "Tier 3" (2/5 networks) for completeness

This is a presentation preference, not a correctness issue. The asterisk approach is fine.

### M3. Section 6.3 Coarser-than-30-Minute Data

The note about eLTER Spain daily precipitation stored at native resolution (line 293-294) is a good addition. However, this means the primary table will have rows with different temporal granularities (some 30-min, some daily). This could surprise users doing time-series joins. Consider adding a note recommending that implementations include a `temporal_resolution` column or filter, or simply exclude coarser-than-30-min data from the primary table and provide it separately.

### M4. profile_id Semantics for TERN and NEON

The profile_id column is motivated by eLTER Germany's A/B profiles (D012). But TERN also has replicate sensors per depth (e.g., Sws_5cma, Sws_5cmb) and NEON has multiple horizontal positions. The decision log says TERN replicates are "typically averaged" and NEON positions vary by site. It would help future implementers to clarify: are TERN replicates pre-averaged before entering the harmonized table, or do they get separate profile_ids? The current text suggests averaging, which is reasonable -- just make it explicit.

### M5. ICOS QC Inference from _N

Using _N (sample count) as a proxy for quality (Section 8.1) is creative but worth flagging as an approximation. ICOS _N tells you how many sensors contributed to the aggregate, not whether the sensors were functioning correctly. A value with _N=4 could still be wrong if all 4 sensors were miscalibrated. This is an inherent limitation of ICOS's QC approach, not a flaw in the schema -- but worth a sentence acknowledging it.

---

## What Improved Most from Draft 1

1. **Coverage honesty**: The corrections to RH, VPD, net_radiation, and atmospheric_pressure make the tier assignments trustworthy. The principle "derivable != present" is now consistently applied.

2. **Aggregation methods (Section 6.2)**: This was a significant gap in Draft 1. The variable-type-based approach (intensive/extensive/directional) is correct and the wind direction vector mean formula in the appendix is a nice touch.

3. **QC flag specificity (Section 8.1)**: The per-network mapping table with concrete thresholds transforms this from a sketch into something implementable.

4. **Section 2.3 (excluded variables)**: Documenting what was considered but excluded, and why, is valuable for future extensibility and prevents re-litigation of these decisions.

5. **Revision history (Section 12)**: Clean traceability from review feedback to changes. Good practice.

---

## Final Assessment

The schema is ready for implementation. The core decisions -- SWC in fraction (m3/m3), wide format with depth-in-column-name, 30-minute UTC intervals, NaN for missing data, CF-aligned snake_case naming -- are all well-justified and internally consistent. The coverage claims now match the evidence. The decision log is thorough (12 entries with evidence, alternatives, and confidence scores).

The open questions (SAEON depths, eLTER Finland sensor IDs, snow depth scope, ICOS 0.4 threshold) are appropriately scoped as implementation-phase work items rather than schema-blocking issues.

**Verdict: ACCEPT**
