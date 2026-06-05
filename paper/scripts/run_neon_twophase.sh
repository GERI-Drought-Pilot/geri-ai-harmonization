#!/bin/bash
#
# Two-phase NEON harmonization: SELECT (committed) then TRANSFORM (consumes it).
#
# Rationale: a single end-to-end pipeline run reliably picks the WRONG
# precipitation product (secondary/tipping) because it sees bulk-data volume
# cues while deciding. An isolated selection step (metadata only) picks the
# CORRECT primary weighing gauge 5/5. So we separate the phases architecturally:
#   Phase 1 (select): metadata-only, writes selection.json (the committed choice)
#   Phase 2 (transform): reads selection.json, transforms ONLY those sources
#
# Usage: bash paper/scripts/run_neon_twophase.sh [n_runs]

set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"
RAW_NEON="$PROJECT_ROOT/Downloads/geri-data/neon"
N_RUNS="${1:-1}"

SELECT_PROMPT_BASE="You are performing ONLY the source-selection step for NEON — do NOT transform or load bulk data. Read the harmonize-schema skill (GERI target: air temperature, precipitation, soil water content, soil temperature, soil texture) and the harmonize-map skill (Source Selection Protocol). Raw NEON L1 products are in ${RAW_NEON}/ as DP1.xxxxx.001 subfolders; more than one candidate may exist for a target variable. Inspect ONLY headers, readme_*.csv, variables_*.csv, sensor_positions files, and web search — never full data files, and never use data-volume cues (row count, site count, file size, resolution-matching). For each of the five target products decide which raw NEON source/variable to use, anchoring on the schema's definition, researching what each candidate measures, and cross-referencing peer RIs' RAW data at ${PROJECT_ROOT}/Downloads/geri-data/{icos,saeon,elter,tern}/ only as a last resort. Forbidden: anything under geri-harmonized/, geri-working/, governance handbook, term mapping template. Write selection.json as a JSON list; each item: {target, chosen_source:{dp_id,file,variable}, alternatives_rejected:[...], reasoning, escalation_steps_used:[...], confidence}."

for i in $(seq 1 "$N_RUNS"); do
    ts=$(date +%Y%m%d_%H%M%S)
    run_dir="$RUNS_DIR/neon_twophase_${ts}_$i"
    mkdir -p "$run_dir"
    echo "============================================================"
    echo "Two-phase NEON run $i/$N_RUNS -> $run_dir"
    echo "--- Phase 1: SELECT (metadata only) ---"
    sel="$run_dir/selection.json"
    claude -p "${SELECT_PROMPT_BASE} Write your selection to ${sel}" \
        --dangerously-skip-permissions --model opus --output-format json \
        > "$run_dir/select_output.json" 2>"$run_dir/select_stderr.log" || echo "  (select non-zero)"
    if [ ! -f "$sel" ]; then echo "  SELECT FAILED — no selection.json; skipping transform"; continue; fi
    echo "  selection committed:"; python3 -c "
import json
for it in json.load(open('$sel')):
    cs=it.get('chosen_source',{})
    print('   ', it.get('target'), '->', cs.get('dp_id'), cs.get('file'), cs.get('variable'))
" 2>/dev/null || echo "   (unparable)"

    echo "--- Phase 2: TRANSFORM (consumes committed selection) ---"
    TRANSFORM_PROMPT="Harmonize the raw NEON data to the GERI schema using the COMMITTED source selection in ${sel}. The selection is FINAL — use exactly the dp_id/file/variable named there for each target product; do NOT reconsider, substitute, or change the source for any reason, and ignore any data-volume observations (more rows/sites, different resolution) you encounter while loading. Read the harmonize-schema skill for target columns and unit rules and the harmonize-transform skill. Raw data are in ${RAW_NEON}/. Apply the schema's unit rules (e.g., soil water content MUST be percent 0-100; depths negative meters), apply NEON finalQF==0 quality filtering where the chosen product carries finalQF, replace -9999/sentinels with NaN, and attach site coordinates/heights from sensor_positions metadata. Process large soil products in chunks (soil moisture and soil temperature each ~180-200M rows across 8 chunks). Forbidden: anything under geri-harmonized/, geri-working/, governance handbook, term mapping template. Produce harmonized_neon_<product>.csv and .parquet at the project root for all five products, and write a decision log + qc report to ${run_dir}/. Finish only when all five output files exist."
    start=$SECONDS
    claude -p "$TRANSFORM_PROMPT" \
        --dangerously-skip-permissions --model opus --output-format json \
        > "$run_dir/transform_output.json" 2>"$run_dir/transform_stderr.log" || echo "  (transform non-zero)"
    echo "  transform done in $((SECONDS-start))s"
    for f in "$PROJECT_ROOT"/harmonized_neon_*.parquet; do [ -f "$f" ] && mkdir -p "$run_dir/outputs" && cp "$f" "$run_dir/outputs/"; done
done
echo "Done. Verify precip resolution: 60min=weighing(correct), 30min=tipping(wrong)."
