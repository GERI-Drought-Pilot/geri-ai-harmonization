# GERI AI Harmonization

LLM agent pipeline for autonomous harmonization of environmental monitoring data across global research infrastructures.

**Paper:** Karns, T.D., Hagen, C.J., Deshpande, K., SanClements, M.D., Laney, C., Ruddell, B.L., Loescher, H.W., & Swetnam, T.L. (2026). Large language model agents autonomously harmonize environmental data across global research infrastructures. *Ecological Informatics* (in review).

## Overview

This repository contains the agent skill definitions, experiment logs, and analysis scripts for an LLM-based data harmonization pipeline tested across five research infrastructures:

| Network | Region | Sites | Formats |
|---------|--------|-------|---------|
| [NEON](https://www.neonscience.org/) | USA | 47 | Parquet, CSV |
| [ICOS](https://www.icos-cp.eu/) | Europe | 39 | CSV |
| [eLTER](https://elter-ri.eu/) | Europe | 15 | Parquet, CSV, Excel |
| [TERN](https://www.tern.org.au/) | Australia | 10 | NetCDF, Excel |
| [SAEON](https://www.saeon.ac.za/) | South Africa | 8 | CSV |

The pipeline harmonizes five data products (air temperature, precipitation, soil water content, soil temperature, soil texture) across 119 sites and 22.97 million rows without pre-built mapping tables or format-specific code.

## Repository Structure

```
.claude/
  skills/
    harmonize-schema.md      # Skill 1: Read target harmonization schema
    harmonize-ingest.md      # Skill 2: Discover and profile raw data files
    harmonize-research.md    # Skill 3: Web search for metadata gaps
    harmonize-map.md         # Skill 4: Semantic variable mapping
    harmonize-transform.md   # Skill 5: Unit conversion and QC filtering
    harmonize-review.md      # Skill 6: Cross-site validation (with loop-back)
    harmonize-log.md         # Structured experiment logging
    ontology-derivation-team.md  # Multi-agent vocabulary derivation protocol
  agents/
    ontology-profiler.md     # Network profiler agent definition
    ontology-reviewer.md     # Schema reviewer agent definition

experiment_logs/
  master_log.csv             # All experiment runs with metrics
  paper/
    methods_notes.md         # Detailed observations from experiments
    results_tables.md        # Pre-formatted results for the paper
  runs/                      # Per-run artifacts (decision logs, QC reports, mappings)

paper/
  main.tex                   # Manuscript (elsarticle class)
  references.bib             # Bibliography
  figures/                   # Publication figures
  tables/                    # Generated result tables
  scripts/                   # Experiment runners and analysis
    consistency_analysis.py  # Inter-run reproducibility analysis
    run_consistency_experiments.sh
    run_ablation.sh
    run_model_comparison.sh
    run_vocab_derivation.sh
    generate_figures.py
```

## How the Pipeline Works

The pipeline comprises six sequential skills executed by an LLM (Claude) through [Claude Code](https://claude.ai/claude-code). Each skill is a structured prompt that reads upstream artifacts and produces structured output for downstream skills:

**Schema** &rarr; **Ingest** &rarr; **Research** &rarr; **Map** &rarr; **Transform** &rarr; **Review**

The Review skill can loop back to upstream skills when issues are detected (e.g., unit ambiguities identified through cross-site comparison).

No network-specific rules, variable mapping tables, or format parsers are embedded in the skills. The agent derives all mappings from semantic understanding of column names, units, and external metadata at each invocation.

## Key Results

- **100% accuracy** on all validated tests (exact value-by-value match against human-harmonized ground truth)
- **100% reproducibility** across 25 repeated runs (5 per network, bit-identical output verified by MD5 checksum)
- **SWC unit ambiguity detected** autonomously via cross-site review; removing the review skill allowed the error to propagate undetected
- **Vocabulary derivation**: multi-agent team independently converged on the same 5 core variables as human experts
- **Model accessibility**: Opus, Sonnet, and Haiku all produced identical output on SAEON

## Running the Pipeline

Prerequisites: [Claude Code CLI](https://claude.ai/claude-code) with API access.

```bash
# Run harmonization on a network (interactive)
claude
# Then invoke skills: /harmonize-schema, /harmonize-ingest, etc.

# Run consistency experiments (batch)
bash paper/scripts/run_consistency_experiments.sh saeon 5

# Run ablation study
bash paper/scripts/run_ablation.sh

# Run model comparison
bash paper/scripts/run_model_comparison.sh

# Analyze consistency results
python3 paper/scripts/consistency_analysis.py
```

## Data Availability

- **Harmonized data**: [GERI DataONE Repository](https://geri.dataone.org/)
- **Raw source data**: Available from each network's public data portal (NEON, ICOS, TERN, SAEON, eLTER)
- Raw data is not redistributed in this repository

## Acknowledgments

This work was supported by the U.S. National Science Foundation AccelNet program ([NSF-2301655](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2301655): GERI - Harmonizing Data to Address Ecological Drought). NEON is sponsored by the U.S. NSF and managed under cooperative support agreement NSF-2217817 to Battelle.

## License

Apache License 2.0 — see [LICENSE](LICENSE)
