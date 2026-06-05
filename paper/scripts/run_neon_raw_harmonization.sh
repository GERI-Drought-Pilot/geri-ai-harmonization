#!/bin/bash
#
# Honest NEON harmonization — RAW data version.
#
# Fixes the original NEON runs, which incorrectly read pre-processed
# intermediates from geri-working/ (where inputs were already in target
# schema, making the result circular). This version points the same
# 6-skill agent pipeline at the genuinely RAW NEON L1 data products
# (DP1.xxxxx.001) downloaded from CyVerse, exactly as the other four
# networks were run against their raw downloads.
#
# Raw NEON products in Downloads/geri-data/neon/:
#   DP1.00003.001  Triple-aspirated air temperature (TAAT_30min)
#   DP1.00006.001  Secondary + throughfall precipitation
#   DP1.00044.001  Weighing-gauge precipitation
#   DP1.00045.001  Tipping-bucket precipitation (TIPPRE_30min)
#   DP1.00041.001  Soil temperature (ST_30_minute, 8 chunks)
#   DP1.00094.001  Soil water content (SWS_30_minute, 8 chunks)
#   DP1.00096.001  Megapit soil physical properties (texture)
#
# Usage: bash paper/scripts/run_neon_raw_harmonization.sh [n_runs]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"
RAW_NEON="$PROJECT_ROOT/Downloads/geri-data/neon"
META_NEON="$PROJECT_ROOT/Downloads/geri/geri-metadata/neon"
N_RUNS="${1:-1}"

PROMPT="Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the raw NEON data for all available sites, and EXECUTE IT END TO END AUTONOMOUSLY. Do NOT stop to ask for approval or confirmation at any point — make and document your best decisions and carry them through to written output files in this single run. The raw data are NEON Level-1 data products in ${RAW_NEON}/, organized by NEON data product ID (DP1.xxxxx.001) subfolders. Several products exist (including more than one precipitation product); discover the full structure yourself via ingest. Supplementary metadata (sensor_positions, site metadata) are in ${META_NEON}/ and within each product folder. These are raw products: they contain horizontalPosition/verticalPosition codes, finalQF quality flags, and native NEON units. Where more than one product or sensor could supply a target variable, follow the Source Selection Protocol in the map skill: anchor on the schema's definition of the variable, research the candidates to see what each actually measures, and only as a last resort cross-reference how the other Research Infrastructures' RAW data supply the analogous variable. The other RIs' raw data are available at ${PROJECT_ROOT}/Downloads/geri-data/{icos,saeon,elter,tern}/ for that cross-reference. You MUST NOT read any harmonized, processed, or answer-key outputs (nothing under geri-harmonized/ or geri-working/, and not the governance handbook or term mapping template). Apply NEON quality flags, perform any needed unit conversions, and map to the GERI target schema. Process the large soil products in chunks if needed to avoid memory exhaustion (soil moisture and soil temperature each have ~180-200M rows across 8 chunks). You MUST produce, in this run, harmonized output written to the project root as harmonized_neon_<product>.csv and harmonized_neon_<product>.parquet for all five products (air_temperature, precipitation, soil_temperature, soil_moisture, soil_texture). Write a decision log, mapping.json, and QC report to experiment_logs/runs/ with a timestamped run ID. Finish only when the output files exist on disk."

for i in $(seq 1 "$N_RUNS"); do
    timestamp=$(date +%Y%m%d_%H%M%S)
    run_id="neon_raw_${timestamp}"
    run_dir="$RUNS_DIR/$run_id"
    mkdir -p "$run_dir"

    echo "============================================================"
    echo "NEON RAW harmonization — run $i of $N_RUNS — $run_id"
    echo "============================================================"

    start_time=$SECONDS
    claude -p "$PROMPT" \
        --dangerously-skip-permissions \
        --model opus \
        --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || {
        echo "  WARNING: claude exited non-zero"
    }
    elapsed=$(( SECONDS - start_time ))

    for f in "$PROJECT_ROOT"/harmonized_neon_*.parquet; do
        [ -f "$f" ] && mkdir -p "$run_dir/outputs" && cp "$f" "$run_dir/outputs/"
    done

    cat > "$run_dir/experiment_metadata.json" <<EOF
{
    "run_id": "$run_id",
    "network": "neon",
    "experiment": "raw_harmonization",
    "input_source": "Downloads/geri-data/neon (raw NEON L1 data products)",
    "run_number": $i,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "elapsed_seconds": $elapsed,
    "model": "opus"
}
EOF
    echo "  Completed in ${elapsed}s -> $run_dir"
done

echo "============================================================"
echo "Done. Validate: python3 paper/scripts/validate_neon.py"
echo "============================================================"
