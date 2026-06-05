#!/bin/bash
#
# Ablation Study: run harmonization with skills removed.
#
# Tests:
#   1. eLTER without review skill — does SWC unit bug slip through?
#   2. SAEON without research skill — what metadata is missed?
#
# Usage:
#   ./run_ablation.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"

run_ablation() {
    local name="$1"
    local prompt="$2"
    local model="${3:-opus}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local run_id="ablation_${name}_${timestamp}"
    local run_dir="$RUNS_DIR/$run_id"
    local output_snapshot="$run_dir/outputs"

    echo "============================================================"
    echo "Ablation: $name"
    echo "Run ID: $run_id"
    echo "============================================================"

    mkdir -p "$run_dir" "$output_snapshot"

    local start_time=$SECONDS

    claude -p "$prompt" \
        --dangerously-skip-permissions \
        --model "$model" \
        --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || {
        echo "  WARNING: claude exited with non-zero status"
    }

    local elapsed=$(( SECONDS - start_time ))

    # Snapshot outputs
    for f in "$PROJECT_ROOT"/harmonized_*.{csv,parquet}; do
        [ -f "$f" ] && cp "$f" "$output_snapshot/"
    done

    cat > "$run_dir/experiment_metadata.json" <<EOF
{
    "run_id": "$run_id",
    "experiment": "ablation",
    "ablation_name": "$name",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "elapsed_seconds": $elapsed,
    "model": "$model"
}
EOF

    echo "  Completed in ${elapsed}s"
    echo ""
}

echo "Ablation Study"
echo "============================================================"
echo ""

# Test 1: eLTER without review
# The critical test — does the SWC fraction-vs-percent bug at Hyytiälä slip through?
run_ablation "elter_no_review" \
    "Run the harmonization pipeline on the eLTER data for all 15 stations, but SKIP the review skill entirely. Run only: schema, ingest, research, map, transform. Do NOT run the review step. Raw data is in ${PROJECT_ROOT}/Downloads/geri-data/elter/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID. IMPORTANT: Do not perform any cross-site comparison or review of the outputs."

# Test 2: SAEON without research
# What happens when the agent can't look up external metadata?
run_ablation "saeon_no_research" \
    "Run the harmonization pipeline on the SAEON flux tower data for all 8 sites, but SKIP the research skill entirely. Run only: schema, ingest, map, transform, review. Do NOT perform any web searches or external metadata lookups. Use only what is available in the data files themselves. Raw data is in ${PROJECT_ROOT}/Downloads/geri-data/saeon/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID."

echo "============================================================"
echo "Ablation runs complete."
echo "Compare outputs against baseline runs to identify differences."
echo "============================================================"
