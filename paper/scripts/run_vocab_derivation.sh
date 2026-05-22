#!/bin/bash
#
# Vocabulary Derivation Reproducibility Test
# Runs the multi-agent vocabulary derivation experiment to test if
# the team converges on the same schema when run again.
#
# Usage:
#   bash paper/scripts/run_vocab_derivation.sh [n_runs]
#   bash paper/scripts/run_vocab_derivation.sh        # 1 run (default)
#   bash paper/scripts/run_vocab_derivation.sh 3      # 3 runs

set -euo pipefail

PROJECT_ROOT="Accelnet"
RUNS_DIR="$PROJECT_ROOT/experiment_logs/runs"
N_RUNS="${1:-1}"

PROMPT='You are running a vocabulary derivation experiment for a research paper. Use the /ontology-derivation-team skill to launch the multi-agent team.

CRITICAL INTEGRITY CONSTRAINTS — enforce these strictly:
- NO agent may access: Geri Data Governance Handbook.xlsx, Term mapping template.xlsx, harmonize-schema.md, any harmonized_*.csv/parquet files, any processed/ or harmonized/ directories, mapping.json, review_report.json, or any answer key metadata CSVs.
- Agents may ONLY access: raw data files in Downloads/geri-data/ and Downloads/geri/, metadata files, web search, and Python for lightweight inspection.
- The team must derive a unified data harmonization vocabulary from raw data ALONE.
- All decisions must be documented with cross-network evidence.
- The reviewer must critically evaluate and issue ACCEPT/REVISE verdict.
- Iterate until ACCEPT.

Save all outputs to experiment_logs/runs/vocab_derivation_{timestamp}/ including:
- DERIVED_SCHEMA_FINAL.md
- DECISION_LOG.json
- CROSS_NETWORK_MAPPING.md
- ITERATION_HISTORY.md
- All draft and review documents'

for i in $(seq 1 "$N_RUNS"); do
    timestamp=$(date +%Y%m%d_%H%M%S)
    run_id="vocab_derivation_${timestamp}"
    run_dir="$RUNS_DIR/$run_id"

    echo "============================================================"
    echo "Vocabulary Derivation Run $i of $N_RUNS — $run_id"
    echo "============================================================"

    mkdir -p "$run_dir"

    start_time=$SECONDS

    claude -p "$PROMPT" \
        --dangerously-skip-permissions \
        --model opus \
        --output-format json \
        > "$run_dir/claude_output.json" 2>"$run_dir/claude_stderr.log" || {
        echo "  WARNING: claude exited with non-zero status"
    }

    elapsed=$(( SECONDS - start_time ))

    cat > "$run_dir/experiment_metadata.json" <<EOF
{
    "run_id": "$run_id",
    "experiment": "vocab_derivation_reproducibility",
    "run_number": $i,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "elapsed_seconds": $elapsed,
    "model": "opus"
}
EOF

    echo "  Completed in ${elapsed}s"
    echo ""
done

echo "============================================================"
echo "Vocabulary derivation runs complete."
echo "Compare outputs against original: experiment_logs/runs/ontology_derivation_20260401/"
echo "============================================================"
