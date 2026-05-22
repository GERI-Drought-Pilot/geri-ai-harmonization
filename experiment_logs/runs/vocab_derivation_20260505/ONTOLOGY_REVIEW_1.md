# Ontology Review 1 -- DERIVED_SCHEMA_DRAFT_1

**Reviewer:** Critical Reviewer Agent (Opus)
**Date:** 2026-05-05
**Document Reviewed:** DERIVED_SCHEMA_DRAFT_1.md + DECISION_LOG.json (D001--D012)
**Profiles Cross-Referenced:** NETWORK_PROFILE_ICOS.md, NETWORK_PROFILE_SAEON.md, NETWORK_PROFILE_ELTER.md, NETWORK_PROFILE_TERN.md, NETWORK_PROFILE_NEON.md

---

## Verdict: **REVISE**

The draft schema is well-structured and demonstrates thorough cross-network analysis. The SWC unit decision, long-format schema design, and depth/height two-column approach are all scientifically defensible. The decision log is exemplary in format. However, two critical factual errors would produce incorrect harmonized values, five high-severity issues would cause implementation failures, and several medium-severity gaps in internal consistency and completeness must be addressed before the schema is safe to implement.

---

## Summary

| Severity | Count |
|---|---|
| CRITICAL | 2 |
| HIGH | 5 |
| MEDIUM | 8 |
| LOW | 4 |
| **Total** | **19** |

---

## Issues

### CRITICAL

---

**Issue 1: eLTER Finland SWC is mislabeled as percent -- draft would produce nonsensical values**

- **Severity:** CRITICAL
- **Location:** Draft Section 4, SWC conversion rules; Decision D001
- **Description:** The eLTER profile contains an explicit "CRITICAL FINDING" (Section 2, Soil Water Content): Finland Hyytiala labels SWC as "%" but values are 0.003--0.689, which is clearly volumetric fraction (m3/m3), not percent. The draft's SWC conversion rules (Section 4) treat ALL eLTER data uniformly: "eLTER SMa###/SMb### and Austria soilmoisture[volpercent]: value_canonical = value_native / 100.0". Applying this to Finland would produce values of 0.00003--0.00689 -- physically meaningless for soil water content. The SWC evidence table in Section 4 does not include Finland at all; it only lists eLTER (DE) and eLTER (AT), silently dropping an entire country's data from the conversion plan.
- **Fix required:** (1) Split the eLTER conversion rule into three sub-rules: Germany (divide by 100), Austria (divide by 100), Finland (passthrough -- already fraction despite label). (2) Add eLTER Finland to the evidence table in Section 4 with its actual value range. (3) Add a data quality warning about the mislabeled unit. (4) Note that eLTER Spain has no soil moisture data (structurally absent) -- this is currently undocumented.

---

**Issue 2: ICOS atmospheric pressure unit is kPa, not hPa -- conversion rule missing**

- **Severity:** CRITICAL
- **Location:** Draft Section 3.1 (atmospheric_pressure canonical unit: hPa); Decision D010
- **Description:** The ICOS profile (Section 2, "Other Variables") lists PA with "Likely Unit" of `kPa` and values ~96--98. Values of 96--98 kPa correspond to 960--980 hPa, which is standard surface pressure. The draft schema (Section 3.1) sets the canonical unit as hPa, and Decision D010 claims "hPa matches all 4 networks that report it." This is incorrect: ICOS reports PA in kPa, not hPa. The draft provides no per-network pressure conversion table (unlike the detailed SWC table in Section 4), so there is no mechanism to catch this during implementation. Ingesting ICOS PA values of 96--98 as hPa (when the true pressure is 960--980 hPa) would produce catastrophically wrong pressure data.
- **Fix required:** (1) Add a per-network pressure conversion table analogous to the SWC table. (2) State explicitly: ICOS PA requires multiplication by 10 (kPa to hPa). (3) Verify SAEON (profile: `hpa`), eLTER (profile: `hPa`), and TERN (profile: `hPa`) are passthrough. (4) Update Decision D010 to acknowledge the ICOS exception.

---

### HIGH

---

**Issue 3: ICOS does have sand/silt/clay numerics -- draft evidence is factually wrong**

- **Severity:** HIGH
- **Location:** Draft Section 2 (Soil Texture Tier Decision); Decision D003
- **Description:** The draft states: "ICOS: SOIL_TEX_ROCK present, but sand/silt/clay numeric fractions NOT in METEO ANCILLARY." The ICOS profile Section 3 explicitly documents three columns: `SOIL_TEX_SAND` (% 0--100, example: 91.67 at BE-Bra), `SOIL_TEX_SILT` (example: 4.87), and `SOIL_TEX_CLAY` (example: 3.47). The profile notes "Not all sites have sand/clay/silt (some only have rock content)," meaning coverage is partial -- but numeric fractions exist. This means soil texture numeric fractions are present in 4 of 5 networks (ICOS partial, eLTER, TERN, NEON), with only SAEON absent. The Tier 2 classification still holds, but the supporting evidence in both Section 2 and Decision D003 is factually incorrect.
- **Fix required:** (1) Correct Section 2 to state ICOS ANCILLARY contains SOIL_TEX_SAND, SOIL_TEX_SILT, SOIL_TEX_CLAY for a subset of sites. (2) Update the network count to "4 of 5 (ICOS partial, eLTER, TERN, NEON; SAEON absent)." (3) Update Decision D003 evidence field.

---

**Issue 4: SAEON QC flag mapping arithmetic is self-contradictory**

- **Severity:** HIGH
- **Location:** Decision D009
- **Description:** Decision D009 states SAEON's flags are {1, 2, 3, 9} and maps them via "subtract 1, keep 9" to canonical {0, 1, 2, 9}. This is self-contradictory: subtracting 1 from 9 yields 8, not 9. The mapping must use a lookup table, not arithmetic. SAEON profile Key Observation #6 confirms: 1=good, 2=uncertain, 3=poor, 9=missing.
- **Fix required:** Replace "subtract 1, keep 9" with an explicit lookup: SAEON 1->0 (pass), 2->1 (suspect), 3->2 (fail), 9->9 (missing, special case). The 9->9 mapping is a direct assignment, not subtraction.

---

**Issue 5: eLTER QC flag mapping is oversimplified and potentially data-destructive**

- **Severity:** HIGH
- **Location:** Decision D009
- **Description:** Decision D009 maps eLTER FLAGQUA as "0->0, 1->2" (binary to pass/fail). But the eLTER profile defines FLAGQUA as "0=good, 1=other." The meaning of "other" is ambiguous -- it could be suspect, unchecked, or manually overridden, not necessarily "fail." Mapping "other" to quality_flag=2 (fail) is an aggressive interpretation that would exclude potentially usable data. Additionally, the eLTER profile documents a separate FLAGSTA field (status flag, float values like 900000.0) that is completely unaddressed in the QC mapping. The draft body (Sections 6 and 9 do not exist in the draft -- QC mapping appears only in the Decision Log) has no QC section at all, so an implementer reading only the draft would not know how to map flags.
- **Fix required:** (1) Map eLTER FLAGQUA 1 to quality_flag=1 (suspect) rather than 2 (fail). (2) Document how FLAGSTA is handled (drop with justification, or map specific values). (3) Add a dedicated QC flag mapping section to the draft body, not just in the Decision Log.

---

**Issue 6: TERN native variable names are wrong in the draft**

- **Severity:** HIGH
- **Location:** Draft Section 1 Tier 1 and Tier 2 tables
- **Description:** Multiple TERN variable names in the draft do not match the TERN profile:
  - Tier 1: `shortwave_radiation_incoming` lists TERN as `Fsd_Total`. Profile says `Fsd`.
  - Tier 1: `net_radiation` lists TERN as `Fn_4cmpt`. Profile says `Fn`.
  - Tier 2: `latent_heat_flux` lists TERN as `LE`. Profile says `Fe`.
  - Tier 2: `sensible_heat_flux` lists TERN as `H`. Profile says `Fh`.
  - Tier 2: `co2_flux` lists TERN as `Fc, NEE`. Profile says `Fco2`.
  - Tier 2: `par_incoming` lists TERN as `PAR_total`. Profile says `PAR`.
  These are the network-native names that will be used during ingest -- incorrect names will cause lookup/mapping failures.
- **Fix required:** Correct all TERN native variable names to match the profile: Fsd (not Fsd_Total), Fn (not Fn_4cmpt), Fe (not LE), Fh (not H), Fco2 (not Fc/NEE), PAR (not PAR_total). If variants with suffixes exist in the actual NetCDF files, list them as alternates alongside the primary name.

---

**Issue 7: Albedo is listed in Tier 2 table but annotated as Tier 3 -- contradictory placement**

- **Severity:** HIGH
- **Location:** Draft Section 1, Tier 2 table
- **Description:** The Tier 2 table includes `albedo` with a parenthetical note "only 2; drop to Tier 3." The entry remains in the Tier 2 table rather than being removed. This is internally contradictory: a variable cannot simultaneously be Tier 2 (by placement) and Tier 3 (by annotation). An implementer would not know whether to include or exclude it.
- **Fix required:** Move albedo out of the Tier 2 table and into the Tier 3 bullet list. It has only 2 networks (ICOS, SAEON), which does not meet the 3+ threshold defined for Tier 2.

---

### MEDIUM

---

**Issue 8: NEON verticalPosition is a depth-level code (501--509), not meters**

- **Severity:** MEDIUM
- **Location:** Draft Section 7 (Depth/Height Convention), NEON row; Decision D008
- **Description:** The draft states for NEON: "verticalPosition in meters (positive)" and provides conversion "Negate for soil sensors -> depth_m = -float(verticalPosition)." The NEON profile (Section 2 and 3) clearly states verticalPosition values are codes "501" through "509" representing depth levels, and "Actual depths are NOT in the data files -- must be looked up in sensor position metadata." Applying the draft's conversion would produce depth_m = -501, -502, etc., which is absurd. Decision D008 evidence also incorrectly states "NEON: verticalPosition in METERS, POSITIVE (0.06, 0.15, 0.30, 1.00)." The values 0.06, 0.15, 0.30, 1.00 appear in the sensor position metadata file's `height` column, not in the data file's `verticalPosition` column.
- **Fix required:** Correct the NEON depth conversion to: (1) Join data files with sensor position metadata (`all_sensor_positions_00044_00006`) using HOR.VER codes. (2) Extract the actual depth in meters from the metadata's `height` column. (3) Negate for soil sensors. (4) Flag this as requiring an external metadata join (similar to ICOS and SAEON depth lookups).

---

**Issue 9: VPD unit for ICOS may already be hPa -- conversion rule unverified**

- **Severity:** MEDIUM
- **Location:** Draft Section 3.1 (VPD note); Decision D010
- **Description:** The ICOS profile lists VPD with "Likely Unit" of `hPa` (Section 2 table). Decision D010 states "VPD-in-hPa matches SAEON/TERN; ICOS conversion is x10," implying ICOS VPD is in kPa. These statements contradict each other. If ICOS VPD is already in hPa, no conversion is needed and applying x10 would produce values 10x too large. The profile does not give sample VPD values to disambiguate empirically.
- **Fix required:** Verify ICOS VPD values. Typical VPD ranges 0--40 hPa (0--4 kPa). If ICOS values are 0--40, they are hPa (passthrough). If 0--4, they are kPa (multiply by 10). Add sample values to the evidence table and correct the conversion rule.

---

**Issue 10: NEON precipitation is hourly, not 30-min -- temporal model has no rule for coarser-than-canonical data**

- **Severity:** MEDIUM
- **Location:** Draft Section 5 (Temporal Model), Resolution policy
- **Description:** The NEON profile (Section 1) states precipitation temporal resolution is "hourly." The draft's temporal model sets 30-min as canonical and its resolution policy addresses only finer-than-canonical (aggregate up) and daily (keep as-is). There is no rule for data that is coarser than 30-min but finer than daily. Splitting hourly precipitation into two 30-min records would be scientifically indefensible (when did the rain fall within the hour?).
- **Fix required:** Add a resolution policy rule: "Data at resolutions coarser than 30-min but finer than daily (e.g., NEON hourly precipitation): store at native resolution with timestamp_start/end spanning the full interval. Do not disaggregate precipitation to sub-native resolution."

---

**Issue 11: ICOS FI-Sod SWC anomaly not addressed in conversion rules**

- **Severity:** MEDIUM
- **Location:** Draft Section 4 (SWC conversion rules)
- **Description:** The ICOS profile flags FI-Sod as having SWC values of 0.52--0.58, which appears to be fraction (m3/m3) while all other ICOS sites show values 4--99 (percent). The draft's conversion rule blanket-divides all ICOS SWC by 100. For FI-Sod, this would produce values 0.0052--0.0058, which is physically unreasonable (essentially oven-dry, implausible for a continuously-monitored boreal forest). The draft's validation rule (flag fail if < 0) would not catch this; the post-conversion values are positive but still nonsensical.
- **Fix required:** Either (1) add a site-specific exception for FI-Sod (passthrough), or (2) add a general heuristic: "If all SWC values at a site are < 1.0 pre-conversion, assume they are already fraction and skip division by 100." Flag FI-Sod for verification with ICOS data providers (add to Open Questions).

---

**Issue 12: CO2 flux sign convention is simultaneously declared and declared unknown**

- **Severity:** MEDIUM
- **Location:** Draft Section 3.1 (co2_flux: "negative = uptake") vs. Open Question #7
- **Description:** The schema sets canonical convention "negative = uptake" but Open Question #7 states "both SAEON and TERN reported as ambiguous; each network's native sign must be verified." This creates an internally inconsistent document: the schema defines a convention it cannot yet implement because the per-network native conventions are unknown. An implementer might apply the convention blindly, potentially inverting signs for networks that use a different native convention.
- **Fix required:** Either (1) keep the stated convention but add a mandatory verification step with specific criteria ("verify by checking that daytime values at forested sites are predominantly negative"), or (2) demote co2_flux to conditional/provisional status pending sign verification.

---

**Issue 13: Soil heat flux sign convention stated but unverifiable**

- **Severity:** MEDIUM
- **Location:** Draft Section 3.1 (soil_heat_flux: "positive = upward"); Open Question #8
- **Description:** The draft sets "positive = upward" for soil heat flux, but Open Question #8 notes ICOS's sign convention is "undocumented." The TERN and SAEON profiles do not specify sign convention for heat flux either. No per-network conversion rule exists for potential sign-flipping. If any network uses "positive = downward" (common in some soil physics traditions), values would silently enter the harmonized dataset with inverted meaning.
- **Fix required:** (1) Add per-network sign convention evidence. (2) If not verifiable from profiles, add empirical validation: "During daytime summer, soil heat flux should generally be positive (upward) at surface -- verify during ingest." (3) Elevate Open Question #8 to a required pre-harmonization verification.

---

**Issue 14: Draft body has no QC flag mapping section**

- **Severity:** MEDIUM
- **Location:** Draft schema body (all sections)
- **Description:** The QC flag mapping exists only in Decision D009 of the Decision Log. The draft body (Section 3.2) defines `quality_flag` as "0 = pass, 1 = suspect, 2 = fail, 9 = missing/unknown" but provides no per-network mapping table. An implementer working from the draft alone (without reading the decision log) would have no guidance on how to convert SAEON's {1,2,3,9}, eLTER's {0,1}, TERN's {0,...,9}, or NEON's {0,1,2} to the canonical scheme.
- **Fix required:** Add a "Quality Flag Mapping" section to the draft body with a per-network conversion table, analogous to the SWC conversion table in Section 4.

---

**Issue 15: No validation ranges for variables other than SWC**

- **Severity:** MEDIUM
- **Location:** Draft Section 3.1
- **Description:** SWC has explicit validation ranges (Section 4: 0.0 to 1.0, suspect if >1.0, fail if >1.05). No other variable has validation ranges defined. Air temperature, precipitation, wind speed, radiation, and other variables all have physically plausible ranges that should be enforced during ingest. Without validation, sentinel values like -9999 that escape detection (e.g., if a network introduces a new sentinel) would corrupt the dataset.
- **Fix required:** Add a validation table with plausible ranges for all canonical variables. Suggested ranges: air_temperature [-80, 70] degC, precipitation [0, 500] mm/30-min, wind_speed [0, 113] m/s, wind_direction [0, 360] degrees, atmospheric_pressure [300, 1100] hPa, relative_humidity [0, 100] %, radiation [-50, 1500] W/m2, etc.

---

### LOW

---

**Issue 16: Soil texture count inconsistency between Section 2 and Section 10**

- **Severity:** LOW
- **Location:** Draft Section 2 vs. Section 10 Summary
- **Description:** Section 10 Summary states "Texture tier: Tier 2 (4 of 5 networks; SAEON absent)." Section 2 body text states "present in 3 of 5 networks with comparable USDA-style fractions: eLTER, TERN, NEON; partially in ICOS via category." The "4 of 5" in the summary apparently counts ICOS's partial contribution; the "3 of 5" in the body does not. This is further complicated by Issue 3 (ICOS does have numeric fractions for some sites). The two counts are internally contradictory.
- **Fix required:** After correcting Issue 3, use a single consistent count in both sections. Recommended: "4 of 5 networks (ICOS partial, eLTER, TERN, NEON; SAEON absent)."

---

**Issue 17: SAEON albedo unit mismatch noted but unresolved**

- **Severity:** LOW
- **Location:** Draft Section 1 Tier 2 table
- **Description:** SAEON profile lists albedo with unit `pcnt` (percent, 0--100). ICOS profile lists albedo as `fraction`. The draft lists albedo for both networks but defines no canonical unit for albedo (it is being demoted to Tier 3). If albedo is ever promoted back, the fraction-vs-percent ambiguity must be resolved, similar to SWC.
- **Fix required:** Add a note in the Tier 3 list about the unit discrepancy for future reference.

---

**Issue 18: TERN wind speed variable name case mismatch**

- **Severity:** LOW
- **Location:** Draft Section 1, Tier 1 table
- **Description:** The Tier 1 table lists TERN's wind speed as `ws` (lowercase). The TERN profile (Section 2, Other Variables table) lists it as `Ws` (capitalized). NetCDF variable names are case-sensitive. Using `ws` instead of `Ws` during ingest would fail to find the variable.
- **Fix required:** Correct to `Ws` (matching the TERN profile), or verify the actual case in the NetCDF files.

---

**Issue 19: Decision log confidence scores lack calibration**

- **Severity:** LOW
- **Location:** DECISION_LOG.json, all entries
- **Description:** Each decision carries a confidence score (0.80--0.95) with no definition of what the scale means. Decision D001 (SWC unit) has confidence 0.85 despite being the most thoroughly evidenced decision. Decision D003 (soil texture tier) has confidence 0.95 despite containing a factual error about ICOS (Issue 3). The scores do not correlate with evidence quality and may mislead reviewers about which decisions are well-founded.
- **Fix required:** Either (1) define calibration criteria (e.g., 0.90+ = all networks verified; 0.80--0.89 = majority verified with some inference; <0.80 = significant uncertainty), or (2) replace with qualitative ratings (HIGH/MEDIUM/LOW) with criteria, or (3) remove scores entirely and let the evidence speak for itself.

---

## Verification Checklist

| Criterion | Status | Notes |
|---|---|---|
| Tier 1/2 variable classification correct | PARTIAL | Tier 1 reasoning is valid for 4/5 but NEON data gap acknowledged only in notes. Albedo Tier 2/3 contradictory (Issue 7). |
| Network coverage counts match profiles | FAIL | Soil texture count contradicts between sections (Issue 16). ICOS texture evidence wrong (Issue 3). |
| SWC unit choice scientifically defensible | PASS | CF Convention alignment, clear rationale, good evidence table. |
| SWC conversion rules correct per network | FAIL | eLTER Finland would produce nonsensical values (Issue 1). ICOS FI-Sod not handled (Issue 11). |
| Unit choices justified for all variables | PARTIAL | SWC excellent. Pressure has a critical error (Issue 2). VPD uncertain (Issue 9). No conversion tables for most variables. |
| Naming conventions consistent | PASS | snake_case, units separate, well-justified. |
| Depth/height conventions clear | PARTIAL | Design is good. NEON verticalPosition conversion is wrong (Issue 8). |
| QC flag mapping complete | FAIL | SAEON arithmetic wrong (Issue 4). eLTER oversimplified (Issue 5). No section in draft body (Issue 14). |
| Missing data handling comprehensive | PASS | NULL convention with per-network sentinel conversion. |
| Decision log cites evidence | PASS | All 12 decisions cite specific per-network evidence. |
| Decision log considers alternatives | PASS | Every decision lists 2--4 alternatives with reasoning. |
| Internal consistency | FAIL | Texture counts contradict (Issue 16). CO2 flux convention vs. open question (Issue 12). Albedo Tier 2/3 (Issue 7). |
| Completeness (profile variables covered) | PARTIAL | No per-network conversion tables for pressure, VPD, radiation, wind. No validation ranges beyond SWC. |

---

## Strengths Worth Preserving

1. **SWC unit decision (Section 4)** is the gold standard for this document -- thorough evidence table, CF Convention alignment, per-network conversion rules, validation ranges. Every other unit decision should follow this template.

2. **Long-format schema (Section 9)** is well-justified with concrete evidence (TERN's 1,827 variables collapsing to ~30 canonical names).

3. **Depth/height two-column design (Section 7)** correctly resolves the NEON ambiguity and aligns with CF Conventions.

4. **Open Questions list (Section 11)** is intellectually honest about unresolved items. This is better than false certainty.

5. **Decision log structure** with per-network evidence and alternatives considered is publication-quality.

---

## Required Actions for Draft 2

### Must fix (CRITICAL + HIGH)
1. Add eLTER Finland as a passthrough exception in SWC conversion rules (Issue 1)
2. Add per-network pressure conversion table; ICOS PA x10 for kPa->hPa (Issue 2)
3. Correct ICOS soil texture evidence to reflect SOIL_TEX_SAND/SILT/CLAY presence (Issue 3)
4. Fix SAEON QC flag mapping to explicit lookup, not arithmetic (Issue 4)
5. Map eLTER FLAGQUA=1 to suspect (not fail); address FLAGSTA (Issue 5)
6. Correct all TERN native variable names to match profile (Issue 6)
7. Move albedo to Tier 3 or remove "drop to Tier 3" annotation (Issue 7)

### Should fix (MEDIUM)
8. Correct NEON depth conversion to use metadata join, not verticalPosition codes (Issue 8)
9. Verify ICOS VPD unit empirically (Issue 9)
10. Add temporal resolution rule for coarser-than-canonical data (Issue 10)
11. Handle ICOS FI-Sod SWC anomaly (Issue 11)
12. Resolve CO2 flux sign convention contradiction (Issue 12)
13. Add soil heat flux sign verification step (Issue 13)
14. Add QC flag mapping section to draft body (Issue 14)
15. Add validation ranges for all variables (Issue 15)

### Consider (LOW)
16. Reconcile texture counts between sections (Issue 16)
17. Note albedo unit discrepancy in Tier 3 (Issue 17)
18. Verify TERN wind speed case sensitivity (Issue 18)
19. Calibrate or remove decision confidence scores (Issue 19)

---

**End of ONTOLOGY_REVIEW_1**
