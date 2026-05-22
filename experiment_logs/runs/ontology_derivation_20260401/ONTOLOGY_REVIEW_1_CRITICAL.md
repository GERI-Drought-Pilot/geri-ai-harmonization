# Critical Ontology Review — Draft 1

**Reviewer**: Critical Ontology Reviewer  
**Date**: 2026-04-01  
**Draft Reviewed**: DERIVED_SCHEMA_DRAFT_1.md + DECISION_LOG.json  
**Networks Verified**: ICOS, SAEON, eLTER, TERN, NEON profiles

**VERDICT**: **REVISE**

---

## Executive Summary

Draft 1 demonstrates strong evidence-based reasoning and correctly handles the #1 critical test (SWC units). The decision to standardize to fractional m3/m3 is **exemplary** — well-evidenced, properly justified with CF conventions, and includes explicit conversion formulas.

However, **8 critical issues** require immediate correction before acceptance:

1. ✗ **RH falsely classified as Tier 1** (NEON has no RH in profiled data)
2. ✗ **Schema structure section title contradicts content** (says "Long" but chooses "Wide")
3. ✗ **eLTER depth sign convention not converted** (negative → positive mapping missing)
4. ✗ **Soil texture units ambiguous** (mass % vs volume % not specified)
5. ✗ **VPD SAEON unit claim unverified** (no direct evidence of hPa in profile)
6. ✗ **Quality flag mapping incomplete** (eLTER, SAEON mappings vague)
7. ✗ **Network coverage claims inconsistent** (Tier 2 table vs mapping table)
8. ✗ **Missing data conversion incomplete** (eLTER CSV, NEON not listed)

**Strengths preserved**: SWC units (D001), temporal model (D006), NaN convention (D007), depth metadata table design, CF-aligned naming.

---

## CRITICAL ISSUE #1: Relative Humidity Tier 1 Misclassification

**Location**: Section 2.1, line 37-38

**Claim**: "RH is included as Tier 1 because it is fundamental to ecosystem science and is derivable from NEON's water vapor measurements."

**Evidence Check**:
- ICOS: ✓ RH present (profile confirms)
- SAEON: ✓ humid_rel_avg (profile confirms)
- eLTER: ✓ RH50HMP, RH168, "Air Relative Humidity [%]" (profile confirms)
- TERN: ✓ RH present (profile confirms)
- NEON: ✗ **NOT PRESENT** — NETWORK_PROFILE_NEON has NO RH variable listed

**The Problem**:
1. Tier 1 is defined as "all 5 networks" but RH is in only 4/5
2. "Derivable from water vapor" is **speculation** — NEON profile shows no H2O vapor variable either
3. The schema note admits "not in current NEON data products profiled" but still places RH in Tier 1

**Why This Is Critical**:
This is a **factual error** that undermines schema credibility. If the profiler found no RH in NEON, the ontology cannot claim RH is in "all 5 networks."

**Required Fix**:
- **Move `relative_humidity` to Tier 2** (present in 4 networks)
- Update Tier 1 to contain only: air_temperature, precipitation, soil_water_content, soil_temperature (the actual 4 variables in all 5 networks)
- Remove speculative justification about NEON derivability
- Update decision log with honest coverage assessment

**Impact**: High — affects variable tier classification and downstream prioritization

---

## CRITICAL ISSUE #2: Schema Structure Title Contradicts Content

**Location**: Section 4.1, line 119

**Title**: "4.1 Design Decision: Tidy Long Format"

**Actual Decision**: Option A — Flat wide with depth-in-column-name (wide format)

**The Problem**:
The section title says "Long Format" but the decision, rationale, and table schema all describe **wide format**. This is internally contradictory and will confuse implementers.

**Evidence**:
- Decision D004 explicitly states: "Use **Option A (flat wide)**"
- Section 4.2 shows wide table with variables as columns
- Rationale says: "Wide format minimizes joins and is directly usable"

**Required Fix**:
Retitle to: **"4.1 Design Decision: Wide Format with Depth-Encoded Columns"**

**Impact**: Medium — confusing but obvious once reading the content

---

## CRITICAL ISSUE #3: eLTER Depth Sign Convention Not Converted

**Location**: Section 5.1, Appendix A

**The Problem**:
The schema chooses **positive-downward cm** (5, 10, 20...) but eLTER Germany and Austria use **negative cm** (-10, -20, -30...). The schema acknowledges this but provides **no conversion rule**.

**Evidence from NETWORK_PROFILE_ELTER**:
- Germany: "VERT_OFFSET negative (cm)" with values -10, -20, -30
- Austria: "ver_offset[cm] column with negative values (-10 = 10 cm below surface)"
- eLTER profile Section 10 "Ambiguities" explicitly flags this as "Lerhforst Vertical Offset Signs" requiring resolution

**Current State**:
- Section 5.1 says "positive-downward avoids sign confusion"
- No conversion formula in Appendix A for eLTER depths
- Rationale dismisses negative convention as "a convention artifact" without justification

**Required Fix**:
Add to Appendix A:
```
| Source | Target | Formula |
|--------|--------|---------|
| eLTER VERT_OFFSET → depth_cm | Negative → Positive | abs(VERT_OFFSET) or -1 * VERT_OFFSET |
```

**Why Justify?**: eLTER's negative-downward is also scientifically valid (used in CF conventions for ocean depths). Document why positive is preferred (e.g., "soil science convention prefers positive-downward, ocean science uses negative").

**Impact**: High — missing conversion rule means eLTER data cannot be harmonized correctly

---

## CRITICAL ISSUE #4: Soil Texture Units Ambiguity

**Location**: Section 2.2 (soil_texture_*), Section 3.1

**The Problem**:
The schema states soil texture is in "Percent (%)" but does not specify **mass percent or volume percent**.

**Evidence**:
- **eLTER profile** (Section "Soil Texture Proportions"): "Units: `%` **(percentage by mass)**"
- **NEON**: No unit specification in decision log or schema
- **Soil texture is typically mass %**, but the schema must state this explicitly

**Why This Matters**:
If NEON uses volume % (unusual but possible), this creates a **unit mismatch** similar to SWC. The schema treated SWC units as the #1 critical test — soil texture deserves the same scrutiny.

**Required Fix**:
1. Verify NEON soil texture units from profile (mass % or volume %?)
2. Add explicit unit definition in Section 3.1:
   - `soil_texture_sand`: **Percent by mass** (%, mass basis)
3. If both networks use mass %, state this in rationale
4. If units differ, flag as critical harmonization issue and choose standard (mass % is standard)

**Impact**: High — potential unit mismatch for Tier 2 variable

---

## CRITICAL ISSUE #5: VPD Unit Verification Gap

**Location**: Section 3.1 (VPD row), Decision D008

**The Claim**:
"SAEON uses hPa — requires conversion" (divide by 10 → kPa)

**Evidence Check**:
- NETWORK_PROFILE_SAEON does **not** explicitly state VPD units in the Variables Catalog
- Decision log D008 claims "SAEON: pressure_vapour_def_avg in hPa, sample values 6.2-12.8 hPa"
- **No source cited** for the "hPa" claim

**The Problem**:
The VPD unit conversion is stated as fact but not verified against the profile. If SAEON actually uses kPa (like ICOS), no conversion is needed. If units are unknown, VPD should be flagged "NEEDS VERIFICATION."

**Required Fix**:
1. **Check NETWORK_PROFILE_SAEON** for explicit VPD unit documentation
2. If units confirmed as hPa: keep decision, cite source
3. If units not documented: flag VPD as "provisional pending unit verification" in Section 11 Open Questions
4. If units are kPa: remove conversion requirement

**Impact**: Medium — affects data transformation accuracy

---

## CRITICAL ISSUE #6: Quality Flag Mapping Incomplete

**Location**: Section 8

**The Problem**:
The 3-level QC scheme provides source mappings but they are incomplete:

1. **SAEON "ITC test 1-2"**: NETWORK_PROFILE_SAEON does not mention "ITC test" — what is this?
2. **eLTER FLAGQUA**: Profile shows FLAGQUA uses 0/1/2 (good/medium/bad), but schema only maps 0→0. Where do FLAGQUA=1 and FLAGQUA=2 map?
3. **ICOS _N counter**: "_N > 0" is a sample count, not a quality flag. Does ICOS provide actual QC flags?

**Evidence from NETWORK_PROFILE_ELTER**:
Section "Quality Flags": "FLAGQUA: Quality indicator (0 = good, 1 = medium, 2 = bad in SAQC system)"

**Required Fix**:
1. Complete eLTER mapping: FLAGQUA 0→0, 1→1, 2→2 (appears to be 1:1)
2. Clarify or correct SAEON "ITC test" reference
3. Verify ICOS quality criteria beyond sample count

**Impact**: Medium — affects data quality interpretation

---

## CRITICAL ISSUE #7: Network Coverage Inconsistency

**Location**: Section 2.2 (Tier 2 table) vs Section 10 (Mapping table)

**The Problem**:
The Tier 2 table and cross-network mapping table give conflicting coverage claims:

| Variable | Tier 2 Table Says | Mapping Table Shows | Discrepancy |
|----------|-------------------|---------------------|-------------|
| `atmospheric_pressure` | ICOS, SAEON, eLTER, TERN | ICOS, SAEON, eLTER (TERN empty) | TERN claimed but not mapped |
| `net_radiation` | ICOS, SAEON, TERN | ICOS, SAEON only | TERN claimed but not mapped |
| `vapor_pressure_deficit` | ICOS, SAEON, TERN | ICOS, SAEON (TERN empty) | TERN claimed but not mapped |

**Evidence Check**:
- NETWORK_PROFILE_TERN L3 variables: No explicit "pressure", "NETRAD", or "VPD" listed
- TERN has Ta and RH, so VPD is derivable, but **not present as a native variable**

**Required Fix**:
1. **Verify each Tier 2 variable** against all 5 network profiles
2. Reconcile Tier 2 table with mapping table (both must agree)
3. Clarify whether "present" means native variable or derivable
4. If derivable counts, document derivation method per network

**Impact**: High — affects Tier 2 threshold claims (3+ networks)

---

## CRITICAL ISSUE #8: Missing Data Conversion Incomplete

**Location**: Section 7.1

**Current List**:
- ICOS: Replace -9999 with NaN ✓
- SAEON: Replace empty strings with NaN ✓
- Others: "NaN already used or trivially mapped"

**Evidence from Profiles**:
- **NETWORK_PROFILE_ELTER**: "eLTER: Varies (NaN in Parquet, **empty in CSV**)"
- **NETWORK_PROFILE_NEON**: Missing data convention not explicitly documented

**The Problem**:
"Trivially mapped" is vague and implies "not checked." eLTER CSV files require empty→NaN conversion (just like SAEON), but this is not listed.

**Required Fix**:
Explicitly list:
- ICOS: -9999 → NaN
- SAEON: empty string → NaN
- **eLTER CSV**: empty string → NaN
- eLTER Parquet: NaN (no conversion)
- TERN: NaN (no conversion)
- **NEON**: [verify from profile and list]

**Impact**: Low — minor completeness issue but affects implementation

---

## MODERATE ISSUES (Should Fix)

### M1. Multi-Height Air Temperature Decision Already Made

**Location**: Section 11 Open Questions #1

**The Issue**: Section 5.2 already states "only one representative air temperature is selected per site-timestamp (typically ~2m)." This is a decision, not an open question.

**Fix**: Move from Open Questions to Decision Log as D009.

---

### M2. Depth Column Naming for Non-Integer Depths

**Location**: Section 4.1, depth naming convention

**The Issue**: `{variable}_{depth}cm` works for 5cm, 10cm, but what about 7.5cm? 12.5cm?

**Fix**: Specify rounding rule or allow decimals (e.g., `soil_water_content_7.5cm` or `soil_water_content_8cm`).

---

### M3. Aggregation Methods Not Specified

**Location**: Section 6.1

**The Issue**: Schema says eLTER 10-min and SAEON 5-min "can be aggregated to 30-min" but doesn't specify how:
- Temperature: arithmetic mean
- Precipitation: sum
- Wind direction: vector average

**Fix**: Add aggregation method table in Section 6 or Appendix.

---

### M4. Site ID Collision Risk (FI-Hyy)

**Location**: Section 9.2

**The Issue**: ICOS uses "FI-Hyy", eLTER also has "FI-Hyy" (Hyytiälä). Are these the same site?

**Fix**: Document that cross-network sites use same site_id, `network` column differentiates data source.

---

### M5. Snow Depth Decision Not Documented

**Location**: Section 11 Open Questions #5

**The Issue**: Snow depth is mentioned as "not included" but no decision is recorded.

**Fix**: Add Decision D010: "Snow depth excluded (present in ICOS only, below Tier 2 threshold)."

---

## STRENGTHS TO PRESERVE

### ✓ SWC Units Decision (D001) — EXEMPLARY

This is the gold standard for evidence-based ontology design:
- Tabulated evidence from all 5 networks with exact units and value ranges
- Considered alternatives (percent vs fraction) with pros/cons
- Justified with scientific standards (CF conventions)
- Acknowledged as #1 known failure mode
- Provided explicit conversion formulas (percent → fraction: divide by 100)

**All critical decisions should match this rigor.**

---

### ✓ Temporal Model (D006) — SOLID

30-minute UTC with start+end timestamps is well-evidenced and correct. The ISO 8601 choice eliminates timezone ambiguity.

---

### ✓ NaN Convention (D007) — CORRECT

NaN over sentinels (-9999) is the right modern choice for scientific computing. Well-justified.

---

### ✓ Depth Metadata Table (Section 4.5) — ELEGANT

The companion depth metadata table solves the ICOS/NEON ordinal-index problem (SWC_1, verticalPosition) while keeping the primary table wide and analysis-friendly.

---

### ✓ CF-Aligned Naming (D003) — SOUND

snake_case descriptive names aligned with CF conventions (air_temperature, soil_water_content) are readable and standard-compliant.

---

## SUMMARY OF REQUIRED CHANGES

| ID | Priority | Issue | Effort |
|----|----------|-------|--------|
| C1 | HIGH | RH Tier 1 → Tier 2 (NEON has no RH) | Low |
| C2 | HIGH | Fix section 4.1 title (Long → Wide) | Trivial |
| C3 | HIGH | Add eLTER depth conversion (negative → positive) | Low |
| C4 | HIGH | Specify soil texture units (mass % vs volume %) | Low |
| C5 | MEDIUM | Verify VPD SAEON units (hPa claim) | Low |
| C6 | MEDIUM | Complete QC flag mappings (eLTER, SAEON) | Medium |
| C7 | HIGH | Reconcile Tier 2 vs mapping table coverage | Medium |
| C8 | LOW | Complete missing data conversion list | Trivial |
| M1-M5 | LOW | Moderate issues (see above) | Low each |

**Total Estimated Effort**: 2-3 hours if all evidence is in profiles, 4-6 hours if raw data verification needed.

---

## VERDICT: REVISE

**Recommendation**: Return to lead for revision addressing 8 critical issues. The schema foundation is solid — the SWC decision proves the lead can execute evidence-based reasoning at the required rigor. The issues are primarily:
- Factual accuracy (RH Tier 1 error)
- Completeness (missing conversion rules, QC mappings)
- Internal consistency (title contradictions, coverage claims)

**Next Steps**:
1. Lead addresses critical issues C1-C8
2. Lead optionally addresses moderate issues M1-M5
3. Lead produces Draft 2
4. Reviewer re-evaluates Draft 2
5. Iterate until ACCEPT

**Confidence in Review**: High. All critiques cite specific profile sections, decision log entries, or schema locations.

**Reviewer Notes**: The SWC units decision demonstrates this team understands the critical nature of unit harmonization and can execute rigorous evidence-based design. With the identified gaps filled, this ontology will be production-ready.
