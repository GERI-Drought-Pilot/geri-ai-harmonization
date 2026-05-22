# Iteration History

**Experiment:** Vocabulary Derivation from Raw Environmental Data
**Date:** 2026-05-05
**Total iterations:** Draft 1 -> Review 1 (REVISE, 19 issues) -> Draft 2 (this revision) -> FINAL

---

## Timeline

| Step | Document | Status |
|---|---|---|
| 1. Profiling | 5 NETWORK_PROFILE_*.md files | complete |
| 2. Draft 1 | DERIVED_SCHEMA_DRAFT_1.md + DECISION_LOG.json (D001--D012, D013--D017) | complete |
| 3. Review 1 | ONTOLOGY_REVIEW_1.md -- Verdict: REVISE (19 issues: 2 CRITICAL, 5 HIGH, 8 MEDIUM, 4 LOW) | complete |
| 4. Draft 2 | DERIVED_SCHEMA_DRAFT_2.md + DECISION_LOG.json (D018--D023 added; pre-existing decisions revised) | this iteration |
| 5. Final | DERIVED_SCHEMA_FINAL.md (assumes Review 2 ACCEPT) | complete |

---

## Changes from Draft 1 to Draft 2 -- by Issue ID

The 19 issues from ONTOLOGY_REVIEW_1 are addressed below. Each entry: what changed, where, why.

### CRITICAL

#### Issue 1 -- eLTER Finland SWC mislabeling
- **Change:** Split eLTER SWC conversion into per-country sub-rules. Finland is **passthrough**; Germany and Austria divide by 100. Spain explicitly noted as structurally absent. Added eLTER FI to the SWC evidence table with values 0.003--0.689.
- **Where:** Schema §4.1; CROSS_NETWORK_MAPPING.md §2; Decision D013 (already existed; rationale tightened).
- **Why:** Draft 1 applied a uniform `value/100.0` to all eLTER SWC, which would convert Finland's 0.003--0.689 to 0.00003--0.00689 -- physically impossible (below hygroscopic water). Source data labels are wrong; physical reasoning is the controlling evidence.

#### Issue 2 -- ICOS atmospheric pressure unit (kPa, not hPa)
- **Change:** Added a per-network atmospheric-pressure conversion table (§4.2). ICOS PA = `value * 10.0`. SAEON, eLTER, TERN passthrough. NEON not profiled. Updated D010 to acknowledge ICOS exception. Added new D018 documenting the pressure decision specifically.
- **Where:** Schema §4.2 (new section); CROSS_NETWORK_MAPPING.md §5; Decision D010 narrative; Decision D018 (new).
- **Why:** Draft 1 §3.1 set canonical pressure as hPa and D010 claimed "hPa matches all 4 networks that report it" -- wrong. ICOS profile says PA "Likely Unit: kPa" with values 96--98. Treating these as hPa would record ~96 hPa surface pressure (Mars-like). Validation [800, 1050] hPa pass range now catches missed conversions.

### HIGH

#### Issue 3 -- ICOS soil-texture evidence factually wrong
- **Change:** Corrected §2 to state that ICOS ANCILLARY DOES contain SOIL_TEX_SAND, SOIL_TEX_SILT, SOIL_TEX_CLAY for 6 of 40 sites (BE-Bra, BE-Dor, CZ-BK1, FR-Fon, SE-Htm, SE-Svb). Updated network count to "4 of 5 (ICOS partial, eLTER, TERN, NEON; SAEON absent)." Updated Decision D003 evidence field.
- **Where:** Schema §2; Decision D003.
- **Why:** Draft 1 stated ICOS sand/silt/clay numeric fractions are NOT in METEO ANCILLARY. The ICOS profile §3 explicitly documents these columns with example values (BE-Bra: sand=91.67%, silt=4.87%, clay=3.47%). The error inflated SAEON's structural absence into a methodological claim about ICOS.

#### Issue 4 -- SAEON QC flag arithmetic self-contradictory
- **Change:** Replaced "subtract 1, keep 9" with explicit lookup: 1->0, 2->1, 3->2, 9->9. Added Decision D019 documenting this fix.
- **Where:** Schema §8; Decision D009 narrative; Decision D019 (new).
- **Why:** Subtracting 1 from 9 yields 8, not 9. The rule was mathematically impossible to implement as stated. Lookup table is unambiguous and testable.

#### Issue 5 -- eLTER QC flag mapping oversimplified / FLAGSTA unhandled
- **Change:** eLTER FLAGQUA `1` now maps to QF=1 (suspect) instead of QF=2 (fail). FLAGSTA dropped on ingest with logged justification. Added Decision D020 documenting these.
- **Where:** Schema §8; Decision D009 narrative; Decision D020 (new).
- **Why:** "Other" is ambiguous (could be unchecked, manual override, or suspect). Mapping it to fail is data-destructive. FLAGSTA semantics are undocumented; cannot be safely mixed into the canonical flag without external documentation. Tracked as Open Question 9.

#### Issue 6 -- TERN native variable names wrong
- **Change:** Corrected all TERN names to match the profile: `Fsd` (not `Fsd_Total`), `Fn` (not `Fn_4cmpt`), `Fe` (not `LE`), `Fh` (not `H`), `Fco2` (not `Fc/NEE`), `PAR` (not `PAR_total`).
- **Where:** Schema §1 Tier 1 and Tier 2 tables; CROSS_NETWORK_MAPPING.md §9, §11, §12.
- **Why:** Wrong names cause lookup/mapping failures during NetCDF ingest. The TERN profile §2 lists the actual NetCDF variable names; Draft 1 used short forms or invented suffix variants.

#### Issue 7 -- albedo Tier 2/Tier 3 contradiction
- **Change:** Removed `albedo` from the Tier 2 table; added it to Tier 3 with a unit-discrepancy note (Issue 17 fix combined here).
- **Where:** Schema §1 Tier 2 table (removed); §1 Tier 3 list (added with note).
- **Why:** Draft 1 had it in the Tier 2 table with a parenthetical "drop to Tier 3" -- an implementer would not know which to honor. Albedo has only 2 networks (ICOS, SAEON), failing the 3+ Tier 2 threshold.

### MEDIUM

#### Issue 8 -- NEON verticalPosition is a code, not meters
- **Change:** Corrected NEON depth conversion: join data files with sensor position metadata (`all_sensor_positions_00044_00006`) on siteID + HOR.VER; use metadata `height` column (m, signed). Soil sensors yield depth_m directly; atmospheric sensors yield height_m. Added Decision D021 documenting the corrected method.
- **Where:** Schema §9; CROSS_NETWORK_MAPPING.md §19; Decision D008 evidence; Decision D021 (new).
- **Why:** Draft 1's `depth_m = -float(verticalPosition)` would yield -501 m for the shallowest sensor. NEON profile §3 explicitly states actual depths are NOT in the data files and require a metadata join.

#### Issue 9 -- ICOS VPD unit unverified
- **Change:** Added a per-network VPD conversion table (§4.3). ICOS provisional passthrough with empirical verification rule (mean > 25 hPa or < 0.5 hPa flags reinvestigation). Removed the contradictory "ICOS x10" assertion from D010.
- **Where:** Schema §4.3 (new); Decision D010 narrative.
- **Why:** ICOS profile lists VPD "Likely Unit: hPa." Draft 1's D010 said "ICOS conversion is x10" (implying kPa native) -- contradictory. Until ICOS sample VPD values are confirmed empirically, the conservative choice is passthrough with a runtime sanity check.

#### Issue 10 -- temporal model lacks coarser-than-canonical rule
- **Change:** Added explicit rule: data coarser than 30-min but finer than daily (e.g., NEON hourly precipitation) is stored at native resolution with `timestamp_start`/`timestamp_end` spanning the full native interval. Do NOT disaggregate to sub-native resolution. Use `data_product` to carry the native resolution.
- **Where:** Schema §5 Resolution policy; Decision D016 (already existed; rule emphasized).
- **Why:** Draft 1's resolution policy addressed only finer-than-canonical (aggregate up) and daily (keep). Splitting hourly precipitation into two 30-min records introduces false within-interval precision.

#### Issue 11 -- ICOS FI-Sod SWC anomaly
- **Change:** Added FI-Sod-specific passthrough rule. Added a general implementation safeguard: if max site SWC < 1.0 pre-conversion, treat as fraction (passthrough), regardless of label. Added FI-Sod to Open Questions for verification with ICOS.
- **Where:** Schema §4.1; CROSS_NETWORK_MAPPING.md §2; Decision D014 (already existed); Open Question 12.
- **Why:** Draft 1's blanket `value/100.0` for ICOS would convert FI-Sod's 0.52--0.58 to 0.0052--0.0058 -- impossibly dry for a continuously-monitored boreal forest. Site-level passthrough plus the general safeguard prevents future site-level mislabelings from corrupting data silently.

#### Issue 12 -- CO2 flux sign convention contradiction
- **Change:** Marked co2_flux sign convention "negative = uptake (PROVISIONAL)" in §3.1. Added explicit empirical verification rule: at forested sites, daytime growing-season values should be predominantly negative; if predominantly positive, multiply by -1. Open Question 7 elevated to required pre-harmonization step.
- **Where:** Schema §3.1, §13 Open Questions.
- **Why:** Draft 1 declared the convention while Open Question 7 simultaneously declared the per-network native sign unknown. An implementer might apply the convention blindly. Demoting to provisional with empirical verification resolves the inconsistency.

#### Issue 13 -- soil heat flux sign convention unverifiable
- **Change:** Marked soil_heat_flux sign convention "positive = upward (PROVISIONAL)". Added empirical validation rule: at vegetated surfaces, summer daytime flux should be predominantly positive in the upward-positive convention. Open Question 8 elevated to required pre-harmonization step.
- **Where:** Schema §3.1, §13 Open Questions.
- **Why:** ICOS, TERN, SAEON profiles do not specify upward-positive vs downward-positive. Some soil-physics traditions use downward-positive. Without verification, values silently enter the harmonized dataset with inverted meaning.

#### Issue 14 -- QC flag mapping section missing from draft body
- **Change:** Added a dedicated §8 "Quality Flag Mapping" section with the per-network lookup table.
- **Where:** Schema §8 (new section).
- **Why:** Draft 1 had QC mapping only in Decision D009 of the Decision Log. Implementers reading the schema body alone would not know how to map flags. Cross-referencing with §4.1's SWC table format provides parallel structure.

#### Issue 15 -- no validation ranges beyond SWC
- **Change:** Added §6 "Validation Ranges" with pass / suspect / fail ranges for every canonical variable. Added Decision D022 documenting this.
- **Where:** Schema §6 (new section); Decision D022 (new).
- **Why:** Draft 1 had validation ranges only for SWC. Without per-variable plausibility ranges, sentinel values that escape detection (e.g., a network introducing a new sentinel) corrupt downstream analyses. Also catches unit-conversion errors at ingest (e.g., ICOS PA at 96 fails [800, 1050] hPa pass range).

### LOW

#### Issue 16 -- soil-texture count inconsistency between sections
- **Change:** Used a single consistent count throughout: "Tier 2 (4 of 5 networks: ICOS partial, eLTER, TERN, NEON; SAEON absent)." Updated §2 body text and §12 Summary table.
- **Where:** Schema §2, §12.
- **Why:** Draft 1's §2 body said "3 of 5 networks" while §10 Summary said "4 of 5". After Issue 3 was fixed (ICOS does have texture for 6/40 sites), 4 of 5 is correct everywhere.

#### Issue 17 -- albedo unit discrepancy
- **Change:** Added a note in the Tier 3 entry for albedo: SAEON `pcnt` (percent) vs ICOS `fraction`. If ever promoted to Tier 2, canonical would be unitless fraction (0--1) and SAEON would divide by 100.
- **Where:** Schema §1 Tier 3 list.
- **Why:** Forward-looking note so the SWC-style fraction-vs-percent ambiguity is not rediscovered later.

#### Issue 18 -- TERN wind speed case mismatch
- **Change:** Corrected TERN wind speed from `ws` (lowercase) to `Ws`; wind direction from `wd` to `Wd`. NetCDF variable names are case-sensitive.
- **Where:** Schema §1 Tier 1b table; CROSS_NETWORK_MAPPING.md §7, §8.
- **Why:** Lookup/mapping would fail at ingest with the wrong case.

#### Issue 19 -- decision-log confidence scores uncalibrated
- **Change:** Replaced numeric `confidence` with `confidence_qualitative` (HIGH/MEDIUM/LOW) and added `confidence_criteria` field per decision. Calibration: HIGH = all networks verified or physically unambiguous; MEDIUM = majority verified with some inference / pending documentation; LOW = significant uncertainty. Added Decision D023 documenting the change.
- **Where:** DECISION_LOG.json (all entries); Decision D023 (new).
- **Why:** Draft 1's numeric scores (0.80--0.95) were uncalibrated and inversely correlated with evidence quality (D003, which contained an Issue-3 factual error, had the highest confidence 0.95). Qualitative ratings with explicit criteria are honest and reviewer-checkable.

---

## Summary of Decision Log Growth

| Phase | Decisions | Notes |
|---|---|---|
| Draft 1 (initial) | D001--D012 (12 decisions) | Original schema |
| Draft 1 (extended pre-review) | D013--D017 (5 added) | eLTER FI fix, ICOS FI-Sod, Tier 1a/1b, precip resampling, data_product field |
| **Draft 2 (this revision)** | **D018--D023 (6 added)** | **Pressure conversion (D018), SAEON QC lookup (D019), eLTER QC fix (D020), NEON depth fix (D021), validation ranges (D022), confidence rubric (D023)** |
| Total | **23 decisions** | |

Pre-existing decisions D001--D017 had their **evidence**, **rationale**, and **confidence** fields revised where Issue 1--19 corrections affected them; new decisions D018--D023 document the structural changes.

---

## Files Updated in this Iteration

| File | Update |
|---|---|
| `DERIVED_SCHEMA_DRAFT_2.md` | Comprehensive revision addressing all 19 issues; new sections §4.2 pressure, §4.3 VPD, §6 validation ranges, §8 QC mapping; revised §1 tiers, §2 texture, §3.1 sign conventions, §4.1 SWC, §5 temporal, §9 NEON depth, §13 open questions. |
| `DECISION_LOG.json` | D001--D017 evidence/rationale/confidence revised; D018--D023 added; numeric `confidence` replaced with `confidence_qualitative` + `confidence_criteria`. |
| `CROSS_NETWORK_MAPPING.md` | TERN names corrected (Issue 6); TERN case fixed (Issue 18); ICOS FI-Sod and eLTER FI passthrough rules; ICOS pressure x10; NEON depth metadata join; QC lookup tables. |
| `DERIVED_SCHEMA_FINAL.md` | Copy of Draft 2 (assumes reviewer ACCEPT since all 19 issues are addressed). |
| `ITERATION_HISTORY.md` (this file) | Per-issue change log. |

---

**End of ITERATION_HISTORY**
