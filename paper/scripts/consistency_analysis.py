#!/usr/bin/env python3
from __future__ import annotations
"""
Inter-Run Consistency Analysis
===============================
Compares repeated harmonization runs for each network to measure reproducibility.

Analyzes:
1. Decision consistency (variable mappings, unit conversions, sensor selection)
2. Output value identity (row-by-row comparison of harmonized data)
3. Processing time variance

Reads from: experiment_logs/runs/
Outputs to: paper/tables/consistency_results.csv, paper/tables/consistency_summary.tex

Usage:
    python paper/scripts/consistency_analysis.py
"""

import json
import os
import glob
import pandas as pd
import numpy as np
from pathlib import Path
from itertools import combinations

PROJECT_ROOT = Path("Accelnet")
RUNS_DIR = PROJECT_ROOT / "experiment_logs" / "runs"
OUTPUT_DIR = PROJECT_ROOT / "paper" / "tables"

NETWORKS = ["icos", "neon", "tern", "saeon", "elter"]
PRODUCTS = ["air_temperature", "precipitation", "soil_moisture", "soil_temperature", "soil_texture"]


def find_runs(network: str) -> list[Path]:
    """Find all run directories for a given network."""
    patterns = [
        f"{network}_all_*",       # icos_all_20260401_HHMMSS
        f"{network}_20*",         # neon_20260401_HHMMSS
        f"{network}_consistency_*",  # new consistency runs
    ]
    runs = []
    for pattern in patterns:
        runs.extend(RUNS_DIR.glob(pattern))
    return sorted(set(runs))


def load_run_log(run_dir: Path) -> dict | None:
    """Load run_log.json or run_metadata.json from a run directory."""
    for name in ["run_log.json", "run_metadata.json"]:
        path = run_dir / name
        if path.exists():
            with open(path) as f:
                return json.load(f)
    return None


def load_harmonized_data(run_dir: Path, network: str, product: str) -> pd.DataFrame | None:
    """Load harmonized output from a run's snapshot directory, or project root as fallback."""
    snapshot_dir = run_dir / "outputs"
    fname = f"harmonized_{network}_{product}"

    for base_dir in [snapshot_dir, PROJECT_ROOT]:
        for ext in [".parquet", ".csv"]:
            path = base_dir / (fname + ext)
            if path.exists():
                try:
                    if ext == ".parquet":
                        return pd.read_parquet(path)
                    else:
                        return pd.read_csv(path)
                except Exception:
                    continue
    return None


def compare_decisions(logs: list[dict]) -> dict:
    """Compare decision lists across runs."""
    decision_lists = []
    for log in logs:
        decisions = log.get("decisions", [])
        decision_lists.append(set(decisions))

    if not decision_lists:
        return {"n_runs": 0, "agreement": None}

    common = set.intersection(*decision_lists) if decision_lists else set()
    union = set.union(*decision_lists) if decision_lists else set()

    return {
        "n_runs": len(decision_lists),
        "common_decisions": len(common),
        "total_unique_decisions": len(union),
        "jaccard_similarity": len(common) / len(union) if union else 1.0,
        "all_identical": len(common) == len(union),
    }


def compare_qc_stats(logs: list[dict]) -> dict:
    """Compare QC statistics across runs."""
    results = {}
    for product in PRODUCTS:
        stats_list = []
        for log in logs:
            qc = log.get("qc_results", {}).get(product, {})
            if qc:
                stats_list.append({
                    "rows": qc.get("total_rows", qc.get("rows")),
                    "sites": qc.get("sites"),
                    "min": qc.get("min"),
                    "max": qc.get("max"),
                    "mean": qc.get("mean"),
                })
        if stats_list:
            df = pd.DataFrame(stats_list)
            results[product] = {
                "n_runs": len(stats_list),
                "rows_identical": df["rows"].nunique() == 1 if "rows" in df else None,
                "sites_identical": df["sites"].nunique() == 1 if "sites" in df else None,
                "min_range": (df["min"].min(), df["min"].max()) if "min" in df and df["min"].notna().any() else None,
                "max_range": (df["max"].min(), df["max"].max()) if "max" in df and df["max"].notna().any() else None,
                "mean_cv": df["mean"].std() / df["mean"].mean() if "mean" in df and df["mean"].notna().any() and df["mean"].mean() != 0 else None,
            }
    return results


def compare_data_identity(run_dirs: list[Path], network: str) -> dict:
    """Compare output data across runs using file checksums (memory-efficient)."""
    import hashlib

    results = {}
    for product in PRODUCTS:
        hashes = []
        for run_dir in run_dirs:
            snapshot_dir = run_dir / "outputs"
            fname = f"harmonized_{network}_{product}"
            found = False
            for base_dir in [snapshot_dir, PROJECT_ROOT]:
                for ext in [".parquet", ".csv"]:
                    path = base_dir / (fname + ext)
                    if path.exists():
                        h = hashlib.md5(open(path, "rb").read()).hexdigest()
                        hashes.append(h)
                        found = True
                        break
                if found:
                    break

        if len(hashes) < 2:
            results[product] = {"n_runs_with_data": len(hashes), "identity_rate": None}
            continue

        unique = len(set(hashes))
        results[product] = {
            "n_runs_with_data": len(hashes),
            "all_identical": unique == 1,
            "identity_rate": 1.0 if unique == 1 else (len(hashes) - unique) / len(hashes),
        }

    return results


def compare_timing(logs: list[dict]) -> dict:
    """Compare processing times across runs."""
    times = [log.get("elapsed_seconds") for log in logs if log.get("elapsed_seconds")]
    if not times:
        return {"n_runs": 0}
    return {
        "n_runs": len(times),
        "mean_seconds": np.mean(times),
        "std_seconds": np.std(times),
        "cv": np.std(times) / np.mean(times) if np.mean(times) > 0 else None,
        "min_seconds": np.min(times),
        "max_seconds": np.max(times),
    }


def analyze_network(network: str) -> dict:
    """Full consistency analysis for one network."""
    run_dirs = find_runs(network)
    print(f"\n{'='*60}")
    print(f"{network.upper()}: found {len(run_dirs)} runs")
    for rd in run_dirs:
        print(f"  - {rd.name}")

    if len(run_dirs) < 2:
        print(f"  Skipping (need >= 2 runs for comparison)")
        return {"network": network, "n_runs": len(run_dirs), "status": "insufficient_runs"}

    # Load run logs
    logs = []
    for rd in run_dirs:
        log = load_run_log(rd)
        if log:
            logs.append(log)

    print(f"  Loaded {len(logs)} run logs")

    # Compare decisions
    decision_result = compare_decisions(logs)
    jac = decision_result.get('jaccard_similarity')
    print(f"  Decisions: Jaccard={jac:.3f}, identical={decision_result.get('all_identical')}" if jac is not None else "  Decisions: n/a (no run logs)")

    # Compare QC stats
    qc_result = compare_qc_stats(logs)
    for product, stats in qc_result.items():
        print(f"  {product}: rows_identical={stats.get('rows_identical')}, "
              f"mean_cv={stats.get('mean_cv', 'n/a')}")

    # Compare actual data
    data_result = compare_data_identity(run_dirs, network)
    for product, stats in data_result.items():
        rate = stats.get("identity_rate")
        print(f"  {product} data identity: {rate:.4f}" if rate else f"  {product} data identity: n/a")

    # Compare timing
    timing_result = compare_timing(logs)
    mean_t = timing_result.get('mean_seconds')
    cv_t = timing_result.get('cv')
    print(f"  Timing: mean={mean_t:.1f}s, CV={cv_t:.3f}" if mean_t and cv_t else "  Timing: n/a")

    return {
        "network": network,
        "n_runs": len(run_dirs),
        "decisions": decision_result,
        "qc_stats": qc_result,
        "data_identity": data_result,
        "timing": timing_result,
    }


def generate_summary_table(results: list[dict]) -> pd.DataFrame:
    """Generate the summary table for the paper."""
    rows = []
    for r in results:
        if r.get("status") == "insufficient_runs":
            rows.append({
                "Network": r["network"].upper(),
                "Runs": r["n_runs"],
                "Mapping Agreement": "---",
                "Value Identity": "---",
                "Time CV": "---",
            })
            continue

        # Aggregate data identity across products
        identities = [
            v.get("identity_rate")
            for v in r.get("data_identity", {}).values()
            if v.get("identity_rate") is not None
        ]
        mean_identity = np.mean(identities) if identities else None

        rows.append({
            "Network": r["network"].upper(),
            "Runs": r["n_runs"],
            "Mapping Agreement": f"{r['decisions']['jaccard_similarity']:.1%}" if r['decisions'].get('jaccard_similarity') is not None else "---",
            "Value Identity": f"{mean_identity:.4f}" if mean_identity else "---",
            "Time CV": f"{r['timing'].get('cv', 0):.2f}" if r['timing'].get('cv') else "---",
        })

    return pd.DataFrame(rows)


def write_latex_table(df: pd.DataFrame, output_path: Path):
    """Write the summary table as LaTeX."""
    cols = list(df.columns)
    col_fmt = "l" + "c" * (len(cols) - 1)
    with open(output_path, "w") as f:
        f.write("% Auto-generated by consistency_analysis.py\n")
        f.write(f"\\begin{{tabular}}{{{col_fmt}}}\n\\toprule\n")
        f.write(" & ".join(cols) + " \\\\\n\\midrule\n")
        for _, row in df.iterrows():
            f.write(" & ".join(str(v) for v in row) + " \\\\\n")
        f.write("\\bottomrule\n\\end{tabular}\n")
    print(f"\nLaTeX table written to: {output_path}")


def main():
    print("Inter-Run Consistency Analysis")
    print(f"Project root: {PROJECT_ROOT}")
    print(f"Runs directory: {RUNS_DIR}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    results = []
    for network in NETWORKS:
        result = analyze_network(network)
        results.append(result)

    # Generate summary
    summary_df = generate_summary_table(results)
    print(f"\n{'='*60}")
    print("SUMMARY TABLE")
    print(summary_df.to_string(index=False))

    # Save outputs
    summary_df.to_csv(OUTPUT_DIR / "consistency_results.csv", index=False)
    write_latex_table(summary_df, OUTPUT_DIR / "consistency_summary.tex")

    # Save full results as JSON
    with open(OUTPUT_DIR / "consistency_full.json", "w") as f:
        json.dump(results, f, indent=2, default=str)
    print(f"Full results: {OUTPUT_DIR / 'consistency_full.json'}")


if __name__ == "__main__":
    main()
