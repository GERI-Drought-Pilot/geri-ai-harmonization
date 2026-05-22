# Ontology Review — Round 1

**Reviewer**: Reviewer Agent
**Date**: 2026-04-01
**Draft Reviewed**: DERIVED_SCHEMA_DRAFT_1.md
**Decision Log Reviewed**: DECISION_LOG.json

---

## Overall Assessment: REVISE

The draft is strong — well-structured, well-evidenced, and makes defensible choices on the hardest decisions (SWC units, temporal resolution, missing data). However, there are internal contradictions in the schema structure description, gaps in network coverage for several Tier 2 variables, and some variables that need re-examination against the profiles. A revision pass should be straightforward.

---

## Critical Issues (Must Fix)

### C1. Internal Contradiction: Wide vs. Long Format

Section 4.1 title says "Tidy Long Format" but the body describes a **wide format** decision (Option A — flat wide with depth-in-column-name). The decision (D004) explicitly says wide. The section title is misleading and must be corrected to avoid confusion in downstream implementation.

**Location**: Section 4.1, line 119

### C2. Relative Humidity Classification as Tier 1 is Questionable

RH is listed as Tier 1 ("all 5 networks") but the schema itself notes NEON does not provide RH in the profiled data products. The footnote acknowledges this and justifies inclusion because RH is "derivable from NEON's water vapor measurements." However:

- Derivable is not the same as present. The schema should not claim a variable is in "all 5 networks" when it requires computation for one of them.
- The NEON profile does not include a humidity data product at all — there is no H2O mixing ratio or dew point in the profiled NEON parquet files (only air temp, precip, soil temp, soil moisture, soil texture).
- If RH must be derived for NEON, the schema should document the derivation method and its dependencies.

**Recommendation**: Either demote RH to Tier 2 (present in 4 networks), or keep it as Tier 1 but add an explicit note that NEON requires derivation and document the method. Be honest about the evidence rather than stretching the definition.

### C3. Missing Data Convention: Section Title Says NaN But Decision Log Says NULL

The schema Section 7 says "NaN for Missing Values" and D007 says "IEEE 754 NaN." This is correct and well-justified. However, the team lead's message to me described the convention as "NULL for missing data (no sentinels)." This inconsistency between the schema and the verbal summary could cause implementation confusion. Ensure all references consistently say NaN, not NULL.

---

## Concerns (Should Address)

### S1. VPD Network Coverage Understated

The mapping table (Section 10) shows VPD only for ICOS and SAEON. However, TERN's profile explicitly lists VPD-related variables (it can be derived from Ta and RH which TERN has). The Tier 2 table (Section 2.2) claims VPD is in "ICOS, SAEON, TERN" but the mapping table shows TERN's VPD cell as empty ("--"). The mapping table and the Tier 2 table should agree.

### S2. Net Radiation Coverage in Mapping Table

The mapping table shows net_radiation only for ICOS and SAEON, but the Tier 2 table lists it as a Tier 2 variable (implying 3+ networks). TERN has `Fa` (available energy = Rn - G) but not a direct `Rn`/NETRAD variable listed in the L3 profile. If TERN does not have a direct net radiation variable, then net_radiation is only in 2 networks and should not be Tier 2. Verify against the actual TERN data.

### S3. Atmospheric Pressure Coverage

The mapping table (Section 10) shows atmospheric_pressure for ICOS, SAEON, eLTER (Germany, Finland, Austria) but the TERN column is empty. The TERN profile does not list a surface pressure variable in the L3 catalog. The Tier 2 table claims "ICOS, SAEON, eLTER, TERN" — is this accurate? If TERN does not provide pressure, the claim needs correction.

### S4. Soil Heat Flux Mapping

The mapping table shows soil_heat_flux for ICOS (G_1..2), SAEON (heat_flux_ground), and TERN (Fg). That is 3 networks, which is correct for Tier 2. However, eLTER Germany has soil-related data in SOHYD files — is soil heat flux truly absent from all eLTER sites? This seems plausible but worth confirming.

### S5. Depth Column Naming May Cause Issues

The `{variable}_{depth}cm` convention (e.g., `soil_water_content_5cm`) works well for standard depths but may cause problems when:
- Depths are non-integer (e.g., 7.5 cm)
- Depths vary significantly across sites (one site has 5/10/20/40/80, another has 8/15/30/60)

The schema should specify how non-integer depths are handled (rounding? decimal in name?) and whether column names are fixed across all sites or site-adaptive.

### S6. Aggregation Method for Sub-30-Minute Data Not Specified

The schema says higher-resolution data (eLTER 10-min, SAEON 5-min DB) "can be aggregated to 30-min" but does not specify the aggregation method. For temperature, the standard is arithmetic mean. For precipitation, it is sum. For wind direction, vector averaging is required. The schema should specify aggregation functions per variable type.

### S7. Quality Flag Mapping is Skeletal

The QC flag model (Section 8) maps to a 3-level scheme (0/1/2/NaN) but the source mappings are vague:
- "ICOS: _N > 0" — this is a completeness check, not a quality flag
- "SAEON: ITC test 1-2" — these are steady-state test values, not general QC
- "NEON: finalQF=0" — correct, but what maps to flag=1 (suspect)?

The mapping needs more specificity, especially the thresholds that distinguish "suspect" from "bad."

---

## Questions for the Lead

1. **eLTER Austria soil moisture units**: The Austria (Lerhforst-Rosalia) data headers say `soilmoisture[volpercent]`. The schema assumes all eLTER soil moisture is in percent (divide by 100). Is there any risk that Austria data is already in fraction? The explicit "volpercent" label suggests percent, but worth confirming.

2. **ICOS SWC values of 29-45%**: The profile shows SWC_1 at FI-Hyy = 29.61% and SWC_5 = 40.86%. After conversion (divide by 100), these become 0.2961 and 0.4086 m3/m3. The 0.4086 value is right at NEON's reliability threshold of 0.4. Is this coincidental, or should there be a validity range check in the schema?

3. **SAEON soil layer depths**: The SAEON profile uses ordinal indices (_s1 through _s4) with no explicit depth information in the profiled data. How will the depth metadata table be populated for SAEON? Is there ancillary metadata we haven't profiled?

4. **Snow depth**: You note D_SNOW (ICOS) as a possible Tier 2 variable. NEON likely has snow depth in other data products not profiled here. Is this worth including, or is it out of scope for the first version?

---

## What's Good

1. **SWC unit decision (D001) is excellent**. The choice of fraction (m3/m3) is well-justified by CF conventions, the NEON/TERN native format, and the ambiguity argument. The evidence table is thorough and the rationale is sound. This passes the critical test.

2. **Temporal model (D006) is solid**. Half-hourly UTC with start+end timestamps is the right call. Well-evidenced from all 5 networks.

3. **Missing data convention (D007) is correct**. NaN over sentinels is the right modern choice. Well-justified.

4. **Naming conventions (D003)** align with CF standards and snake_case is practical for Python/R workflows.

5. **Decision log quality is high**. Each decision has evidence, alternatives, rationale, and confidence scores. This is exactly the level of rigor needed.

6. **The depth metadata table (Section 4.5)** elegantly solves the ICOS/NEON ordinal-index-to-actual-depth problem.

7. **The cross-network variable mapping table (Section 10)** is comprehensive and will be valuable for implementation, despite the coverage gaps noted above.

---

## Specific Feedback by Section

### Section 1 (Scope)
- Good overview. Minor: SAEON is listed as "8-9" sites — the profile shows 8 flux tower sites plus the observation database. Clarify whether the count refers to flux sites only.

### Section 2 (Core Variables)
- Tier system is well-conceived. See C2 (RH classification) and S1-S3 (coverage claims) above.
- Consider adding a note about variables that were considered but excluded (e.g., CO2 flux, latent/sensible heat) and why. This aids future extensibility decisions.

### Section 3 (Unit Standardization)
- SWC decision: Excellent (see above).
- VPD in kPa: Reasonable choice. The ecology literature does favor kPa. Confidence of 0.85 seems appropriate.
- No issues with temperature, precipitation, radiation, or wind units — all are universally consistent.

### Section 4 (Schema Structure)
- Fix the section title contradiction (C1).
- Wide format is defensible for the stated audience (ecosystem scientists in pandas/R). However, acknowledge that the depth-in-column-name approach creates a variable-width schema (different sites have different columns). This has implications for data storage format (Parquet handles this well; fixed-schema databases do not).
- The companion tables (site metadata, soil texture, depth metadata) are well-designed.

### Section 5 (Depth/Height)
- Positive-downward cm is the right call. Well-justified.
- Add guidance on what happens when a network has two soil profiles at the same site (eLTER Germany has profiles A and B). Does the schema pick one, average them, or include both?

### Section 6 (Temporal Model)
- Solid. See S6 about aggregation methods.

### Section 7 (Missing Data)
- Correct. Fix the NULL/NaN terminology inconsistency (C3).

### Section 8 (Quality Flags)
- Needs more specificity (S7). The 3-level scheme is a good simplification but the mapping rules are too vague for implementation.

### Section 9 (Naming Conventions)
- Clean and consistent. No issues.

### Section 10 (Mapping Table)
- Valuable reference. Fix the coverage inconsistencies noted in S1-S3.
- eLTER is broken out by country, which is helpful. Consider noting which eLTER variables come from SOHYD vs SOATM vs SOGEO classification.

### Section 11 (Open Questions)
- Good that these are explicitly flagged. The multi-height air temperature question (Q1) should be resolved in this draft — the current schema already makes the single-height decision (Section 5.2), so Q1 is already answered. Remove or reconcile.

---

## Summary of Required Changes

| ID | Type | Summary | Effort |
|----|------|---------|--------|
| C1 | Critical | Fix Section 4.1 title: "Long" should be "Wide" | Trivial |
| C2 | Critical | RH Tier 1 claim: either demote or document NEON derivation | Medium |
| C3 | Critical | Ensure NaN (not NULL) terminology throughout | Trivial |
| S1 | Concern | VPD: reconcile Tier 2 table with mapping table | Low |
| S2 | Concern | Net radiation: verify 3-network threshold | Low |
| S3 | Concern | Atmospheric pressure: verify TERN coverage | Low |
| S4 | Concern | Soil heat flux: confirm eLTER absence | Low |
| S5 | Concern | Depth naming: handle non-integer/variable depths | Medium |
| S6 | Concern | Aggregation methods per variable type | Medium |
| S7 | Concern | QC flag mapping: add specificity | Medium |

---

**Verdict: REVISE**

The schema is fundamentally sound. The SWC unit decision, temporal model, and naming conventions are all correct. The critical issues are an internal title contradiction, a questionable Tier 1 classification for RH, and a terminology inconsistency — all fixable in a single revision pass. The concerns about coverage verification and aggregation methods should also be addressed to make the schema implementation-ready.
