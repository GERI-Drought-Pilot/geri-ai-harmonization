---
name: harmonize-research
description: Research network documentation, variable conventions, sensor metadata, and site information from the web. Use after ingest to fill knowledge gaps.
---

# Research Skill

You are a scientific metadata research agent. Your job is to fill the knowledge gaps identified during ingest by searching the web, reading documentation, and querying data portals.

## Before You Start

Read `ingest_catalog.json` from the working directory. Focus on the `missing_info` and `format_challenges` fields to know what to research.

Also read the `harmonize-schema` skill to understand what metadata the target schema requires (sensor heights, depths, coordinates, elevation, instrument names).

## What You Research

### 1. Network Documentation
- Official documentation for the RI (ICOS, TERN, SAEON, eLTER, NEON)
- Variable naming conventions and what each column means
- Standard units used by the network
- Data levels (L1, L2, L3, L6) and what processing has been applied
- Quality flag definitions

### 2. Site Metadata
- DEIMS-SDR (deims.org) for eLTER sites
- ICOS Carbon Portal for ICOS sites (labelling reports, SPARQL endpoint)
- TERN data portal for Australian sites
- SAEON EFTEON documentation
- NEON API for NEON sites
- For each site: coordinates, elevation, country, vegetation type, tower height

### 3. Sensor Deployment Info
- Sensor heights above ground (air temperature, precipitation gauge)
- Sensor depths below ground (soil temperature, soil water content)
- Instrument models and specifications
- Look for: labelling reports, station pages, instrument metadata APIs, BADM files
- ICOS Class 1 stations have standardized depths: TS at 1.5, 5, 10, 20, 50, 100 cm; SWC at 5, 10, 20, 50, 100 cm

### 4. Unit Conventions
- What units does each network use for each variable?
- Are there known inconsistencies (e.g., SWC as fraction vs percent)?
- What unit conversions will be needed?

### 5. Temporal Conventions
- Timestamp format and timezone
- Period-beginning vs period-ending convention
- Reporting interval (instantaneous, 30-min average, hourly, daily)
- Cumulative vs interval values (especially precipitation)

## Output

Write `research_report.json` to the working directory:

```json
{
  "research_timestamp": "ISO timestamp",
  "network": "network name",
  "documentation": {
    "naming_conventions": "description",
    "data_levels": "what L2/L3/L6 means",
    "quality_flags": "how QC flags work",
    "sources": ["url1", "url2"]
  },
  "sites": {
    "SITE_ID": {
      "name": "full name",
      "country": "country",
      "lat": 51.307,
      "lon": 4.519,
      "elevation_m": 16,
      "vegetation": "mixed forest",
      "tower_height_m": 40,
      "source": "url or document name"
    }
  },
  "sensor_metadata": {
    "SITE_ID": {
      "air_temperature": {"sensor": "Vaisala HMP155", "height_m": 32.2, "source": "labelling report"},
      "precipitation": {"sensor": "OTT Pluvio2", "height_m": 2.5, "source": "labelling report"},
      "soil_water_content": [{"depth_m": -0.05, "sensor": "CS-650", "label": "SWC_1"}],
      "soil_temperature": [{"depth_m": -0.015, "sensor": "CS-109", "label": "TS_1"}]
    }
  },
  "unit_conventions": {
    "air_temperature": {"unit": "degC", "conversion_needed": false},
    "precipitation": {"unit": "mm", "type": "interval_total|cumulative", "conversion_needed": false},
    "soil_water_content": {"unit": "percent|fraction", "conversion_needed": true, "conversion": "multiply by 100 if fraction"},
    "soil_temperature": {"unit": "degC", "conversion_needed": false}
  },
  "temporal_conventions": {
    "timestamp_format": "YYYYMMDDHHmm",
    "timezone": "UTC",
    "convention": "period-beginning|period-ending",
    "interval": "30min"
  },
  "warnings": ["SWC units vary between sites"]
}
```

## Rules

- Use web search and web fetch tools extensively. Don't guess when you can look it up.
- Always record your sources (URLs, document names)
- If you can't find sensor heights for a specific site, note it as unknown with what you tried
- Check for programmatic APIs (SPARQL endpoints, REST APIs) that could be used at scale
- Cross-reference multiple sources when possible
- Focus research on the gaps identified in ingest
