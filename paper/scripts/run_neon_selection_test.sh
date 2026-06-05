#!/bin/bash
#
# NEON VARIABLE/PRODUCT SELECTION TEST (selection-only, no transformation).
#
# Goal: test whether the agent HONESTLY and CONSISTENTLY chooses the correct
# raw NEON source product for each GERI target variable. The decisive case is
# precipitation, where NEON offers a primary weighing gauge (DP1.00044 WEIPRE,
# the canonical TOTAL precipitation), a secondary tipping gauge (DP1.00045/
# DP1.00006 SECPRE), and throughfall (DP1.00006 THRPRE). Correct = primary.
#
# Fast: the agent inspects headers/readmes/metadata only and writes a
# selection.json — it does NOT load or transform the bulk data. Run N times to
# measure consistency.
#
# Usage: bash paper/scripts/run_neon_selection_test.sh [n_runs]

set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs/neon_selection"
RAW_NEON="$PROJECT_ROOT/Downloads/geri-data/neon"
N_RUNS="${1:-3}"
mkdir -p "$RUNS_DIR"

PROMPT="You are performing ONLY the source-selection step of data harmonization for NEON — do NOT transform or load bulk data. First read the harmonize-schema skill for the GERI target schema (five data products: air temperature, precipitation, soil water content, soil temperature, soil texture) and the harmonize-map skill for the Source Selection Protocol. The raw NEON Level-1 data products are in ${RAW_NEON}/, organized by NEON data product ID (DP1.xxxxx.001) subfolders. More than one candidate product may exist for a target variable. For EACH of the five target products, decide which raw NEON source product and variable should populate it. Inspect only headers, readme_*.csv, variables_*.csv, and sensor_positions files (and use web search) — do NOT read full data files. Where multiple candidates exist, follow the Source Selection Protocol: anchor on the schema's definition of the variable, research what each candidate actually measures, and only as a last resort cross-reference how the other Research Infrastructures' RAW data supply the analogous variable (raw data at ${PROJECT_ROOT}/Downloads/geri-data/{icos,saeon,elter,tern}/). You MUST NOT read anything under geri-harmonized/, geri-working/, the governance handbook, or the term mapping template. Write a JSON file to the path given below containing, for each of the five target products: {\"target\": <product>, \"chosen_source\": {\"dp_id\": ..., \"file\": ..., \"variable\": ...}, \"alternatives_rejected\": [{\"dp_id/file/variable\":..., \"why_rejected\":...}], \"reasoning\": ..., \"escalation_steps_used\": [\"schema\"|\"research\"|\"peer_ri\"], \"confidence\": \"HIGH|MEDIUM|LOW\"}. Output ONLY the selection decisions; do not produce harmonized data."

for i in $(seq 1 "$N_RUNS"); do
    ts=$(date +%Y%m%d_%H%M%S)
    run_dir="$RUNS_DIR/sel_${ts}_$i"
    mkdir -p "$run_dir"
    echo "=== selection run $i/$N_RUNS -> $run_dir ==="
    full_prompt="${PROMPT} Write your selection to ${run_dir}/selection.json"
    start=$SECONDS
    claude -p "$full_prompt" \
        --dangerously-skip-permissions --model opus --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || echo "  (claude non-zero)"
    echo "  done in $((SECONDS-start))s; selection.json: $([ -f "$run_dir/selection.json" ] && echo yes || echo MISSING)"
done
echo "Analyze: python3 paper/scripts/analyze_neon_selection.py"
