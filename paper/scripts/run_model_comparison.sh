#!/bin/bash
#
# Model Comparison: run SAEON harmonization with Opus, Sonnet, and Haiku.
# Framed as accessibility — "Can ecologists use a cheaper model?"
#
# Usage:
#   ./run_model_comparison.sh

set -euo pipefail

PROJECT_ROOT="/Users/karnst/Documents/Accelnet/Accelnet"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"

SAEON_PROMPT="Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the SAEON flux tower data for all 8 sites. Raw data is in /Users/karnst/Documents/Accelnet/Downloads/geri-data/saeon/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID."

run_model() {
    local model="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local run_id="model_comparison_saeon_${model}_${timestamp}"
    local run_dir="$RUNS_DIR/$run_id"
    local output_snapshot="$run_dir/outputs"

    echo "============================================================"
    echo "Model comparison: $model"
    echo "Run ID: $run_id"
    echo "============================================================"

    mkdir -p "$run_dir" "$output_snapshot"

    local start_time=$SECONDS

    claude -p "$SAEON_PROMPT" \
        --dangerously-skip-permissions \
        --model "$model" \
        --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || {
        echo "  WARNING: claude exited with non-zero status"
    }

    local elapsed=$(( SECONDS - start_time ))

    # Snapshot outputs
    for f in "$PROJECT_ROOT"/harmonized_saeon_*.{csv,parquet}; do
        [ -f "$f" ] && cp "$f" "$output_snapshot/"
    done

    cat > "$run_dir/experiment_metadata.json" <<EOF
{
    "run_id": "$run_id",
    "experiment": "model_comparison",
    "network": "saeon",
    "model": "$model",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "elapsed_seconds": $elapsed
}
EOF

    echo "  Completed in ${elapsed}s"
    echo ""
}

echo "Model Comparison Study (SAEON, 8 sites)"
echo "============================================================"
echo ""

run_model "opus"
run_model "sonnet"
run_model "haiku"

echo "============================================================"
echo "Model comparison runs complete."
echo "Compare: accuracy, processing time, output quality."
echo "============================================================"
