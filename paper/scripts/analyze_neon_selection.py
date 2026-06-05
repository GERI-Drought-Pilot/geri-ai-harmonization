#!/usr/bin/env python3
"""Analyze NEON selection-test runs for honesty and consistency.

Checks, across all runs, which raw NEON source each run chose per target
product, and whether the decisive precipitation choice is the correct
PRIMARY weighing gauge (DP1.00044 / WEIPRE) rather than the secondary
tipping (DP1.00045 / DP1.00006 SECPRE) or throughfall (THRPRE).
"""
import json, glob, os, re
from collections import defaultdict

RUNS = sorted(glob.glob(os.path.expanduser(
    os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "experiment_logs/runs/neon_selection/sel_*"))))

CORRECT = {
    "precipitation": "DP1.00044",   # WEIPRE primary weighing gauge = total precip
    "air_temperature": "DP1.00003", # TAAT
    "soil_water_content": "DP1.00094",
    "soil_moisture": "DP1.00094",
    "soil_temperature": "DP1.00041",
    "soil_texture": "DP1.00096",
}

def classify_precip(text):
    t = text.lower()
    if "00044" in t or "weipre" in t or "weighing" in t: return "PRIMARY/weighing (DP1.00044) ✓ CORRECT"
    if "00045" in t or "tippre" in t or "tipping" in t: return "secondary/tipping (DP1.00045) ✗"
    if "00006" in t or "secpre" in t: return "secondary (DP1.00006 SECPRE) ✗"
    if "thrpre" in t or "throughfall" in t: return "throughfall (THRPRE) ✗✗"
    return "UNCLEAR: " + text[:60]

def norm_target(s):
    s = s.lower().replace(" ", "_")
    if "precip" in s: return "precipitation"
    if "air" in s and "temp" in s: return "air_temperature"
    if "moist" in s or "water_content" in s or "swc" in s: return "soil_water_content"
    if "soil" in s and "temp" in s: return "soil_temperature"
    if "textur" in s: return "soil_texture"
    return s

print(f"Found {len(RUNS)} selection runs\n")
precip_choices = []
per_target = defaultdict(list)

for r in RUNS:
    sel = os.path.join(r, "selection.json")
    name = os.path.basename(r)
    if not os.path.exists(sel):
        print(f"{name}: NO selection.json"); continue
    try:
        data = json.load(open(sel))
    except Exception:
        # tolerate selection embedded in text
        data = None
    items = []
    if isinstance(data, list): items = data
    elif isinstance(data, dict):
        items = data.get("selections") or data.get("products") or [v for v in data.values() if isinstance(v, dict)] or [data]
    print(f"=== {name} ===")
    for it in items:
        if not isinstance(it, dict): continue
        tgt = norm_target(str(it.get("target") or it.get("product") or ""))
        cs = it.get("chosen_source") or it.get("chosen") or {}
        cs_str = json.dumps(cs) if isinstance(cs, dict) else str(cs)
        conf = it.get("confidence","?")
        esc = it.get("escalation_steps_used") or it.get("escalation") or []
        per_target[tgt].append(cs_str)
        if tgt == "precipitation":
            verdict = classify_precip(cs_str + " " + str(it.get("reasoning","")))
            precip_choices.append(verdict)
            print(f"  PRECIP -> {verdict}  [conf={conf}, escalation={esc}]")
        else:
            dp = next((d for d in re.findall(r'DP1\.\d+', cs_str)), "?")
            ok = "✓" if CORRECT.get(tgt,"")==dp else ("?" if dp=="?" else "✗")
            print(f"  {tgt}: {dp} {ok}  [conf={conf}]")
    print()

print("="*60)
print("PRECIPITATION CONSISTENCY (the decisive selection):")
from collections import Counter
for v,c in Counter(precip_choices).items():
    print(f"  {c}/{len(precip_choices)} runs: {v}")
correct_n = sum(1 for v in precip_choices if "CORRECT" in v)
print(f"\n  Correct (primary weighing) in {correct_n}/{len(precip_choices)} runs")
if precip_choices:
    if correct_n == len(precip_choices):
        print("  VERDICT: CONSISTENTLY CORRECT — agent selects honestly and reliably.")
    elif correct_n == 0:
        print("  VERDICT: CONSISTENTLY WRONG — agent does not pick primary; consider Experiment-2 (team) approach.")
    else:
        print("  VERDICT: INCONSISTENT — agent is not reliable on selection; consider Experiment-2 (team) approach.")
