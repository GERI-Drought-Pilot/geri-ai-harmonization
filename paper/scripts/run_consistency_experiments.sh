#!/bin/bash
#
# Run repeated harmonization experiments for inter-run consistency analysis.
# Each run invokes the full 6-skill pipeline via Claude Code CLI, then
# copies harmonized outputs to a timestamped directory for comparison.
#
# Usage:
#   bash paper/scripts/run_consistency_experiments.sh [network] [n_runs]
#   bash paper/scripts/run_consistency_experiments.sh              # all networks
#   bash paper/scripts/run_consistency_experiments.sh saeon 5      # 5 SAEON runs
#
# Prerequisites: claude CLI in PATH, ANTHROPIC_API_KEY set

set -euo pipefail

PROJECT_ROOT="Accelnet"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"

get_needed_runs() {
    case "$1" in
        icos)  echo 1 ;;
        neon)  echo 3 ;;
        tern)  echo 4 ;;
        saeon) echo 5 ;;
        elter) echo 5 ;;
    esac
}

get_prompt() {
    case "$1" in
        icos)
            echo "Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the ICOS METEO L2 data for all 39 sites. Raw data is in Downloads/geri-data/icos/data/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID." ;;
        neon)
            echo "Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the NEON data for all available sites. Raw data is in Downloads/geri-data/neon/ (raw NEON Level-1 DP1.xxxxx.001 products) and metadata in Downloads/geri-metadata/neon/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID." ;;
        tern)
            echo "Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the TERN OzFlux L3 NetCDF data for all available sites. Raw data is in Downloads/geri-data/tern/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID." ;;
        saeon)
            echo "Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the SAEON flux tower data for all 8 sites. Raw data is in Downloads/geri-data/saeon/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID." ;;
        elter)
            echo "Run the full harmonization pipeline (schema, ingest, research, map, transform, review) on the eLTER data for all 15 stations. Raw data is in Downloads/geri-data/elter/. Output harmonized CSVs and Parquets to the project root. Log results to experiment_logs/runs/ with a timestamped run ID." ;;
    esac
}

run_one() {
    local network="$1"
    local run_num="$2"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local run_id="${network}_consistency_${timestamp}"
    local run_dir="$RUNS_DIR/$run_id"
    local output_snapshot="$run_dir/outputs"
    local prompt=$(get_prompt "$network")

    echo "============================================================"
    echo "[$network] Run $run_num — $run_id"
    echo "============================================================"

    mkdir -p "$run_dir" "$output_snapshot"

    local start_time=$SECONDS

    claude -p "$prompt" \
        --dangerously-skip-permissions \
        --model opus \
        --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || {
        echo "  WARNING: claude exited with non-zero status"
    }

    local elapsed=$(( SECONDS - start_time ))

    # Snapshot outputs
    # Only snapshot parquets (CSVs are too large for NEON — 27GB+ each)
    for f in "$PROJECT_ROOT"/harmonized_${network}_*.parquet; do
        [ -f "$f" ] && cp "$f" "$output_snapshot/"
    done

    cat > "$run_dir/experiment_metadata.json" <<EOF
{
    "run_id": "$run_id",
    "network": "$network",
    "experiment": "consistency",
    "run_number": $run_num,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "elapsed_seconds": $elapsed,
    "model": "opus"
}
EOF

    echo "  Completed in ${elapsed}s. Outputs saved to $output_snapshot"
    echo ""
}

# Main
target_network="${1:-all}"
override_count="${2:-}"

echo "Consistency Experiment Runner"
echo "Project: $PROJECT_ROOT"
echo "Target: $target_network"
echo ""

if [ "$target_network" = "all" ]; then
    for network in icos neon tern saeon elter; do
        n=${override_count:-$(get_needed_runs "$network")}
        for i in $(seq 1 "$n"); do
            run_one "$network" "$i"
        done
    done
else
    n=${override_count:-$(get_needed_runs "$target_network")}
    for i in $(seq 1 "$n"); do
        run_one "$target_network" "$i"
    done
fi

echo "============================================================"
echo "All consistency runs complete."
echo "Run: python3 paper/scripts/consistency_analysis.py"
echo "============================================================"
