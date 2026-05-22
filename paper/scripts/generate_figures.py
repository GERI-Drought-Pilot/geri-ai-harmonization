#!/usr/bin/env python3
"""Generate publication-quality figures for the Ecological Informatics paper."""

import os
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.path import Path

BASE = "Accelnet"
FIG_DIR = os.path.join(BASE, "paper/figures")
os.makedirs(FIG_DIR, exist_ok=True)

NEON_COL  = '#4477AA'
ICOS_COL  = '#EE6677'
TERN_COL  = '#CCBB44'
SAEON_COL = '#AA3377'
ELTER_COL = '#228833'

matplotlib.rcParams.update({
    'font.family': 'sans-serif',
    'font.sans-serif': ['Helvetica', 'Arial', 'DejaVu Sans'],
    'font.size': 11,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
})


def generate_pipeline():
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.set_xlim(-1.5, 14)
    ax.set_ylim(-1.2, 3.8)
    ax.axis('off')

    steps = [
        ('Schema',    '#4477AA', 'Read target\nschema'),
        ('Ingest',    '#66CCEE', 'Discover &\nprofile files'),
        ('Research',  '#228833', 'Web search for\nmetadata'),
        ('Map',       '#CCBB44', 'Semantic variable\nmapping'),
        ('Transform', '#EE6677', 'Unit conversion\n& QC filtering'),
        ('Review',    '#AA3377', 'Cross-site\nvalidation'),
    ]

    box_w, box_h, gap, y0 = 1.65, 1.3, 0.45, 0.35
    positions = []

    for i, (label, color, desc) in enumerate(steps):
        x = i * (box_w + gap)
        positions.append((x, y0))

        shadow = FancyBboxPatch(
            (x + 0.05, y0 - box_h/2 - 0.05), box_w, box_h,
            boxstyle=mpatches.BoxStyle.Round(pad=0.12, rounding_size=0.2),
            facecolor='#C8C8C8', edgecolor='none', zorder=1)
        ax.add_patch(shadow)

        box = FancyBboxPatch(
            (x, y0 - box_h/2), box_w, box_h,
            boxstyle=mpatches.BoxStyle.Round(pad=0.12, rounding_size=0.2),
            facecolor=color, edgecolor='white', linewidth=2.5, zorder=2)
        ax.add_patch(box)

        text_color = '#333333' if color == '#CCBB44' else 'white'
        ax.text(x + box_w/2, y0 + 0.15, label,
                ha='center', va='center', fontsize=12, fontweight='bold',
                color=text_color, zorder=3)
        ax.text(x + box_w/2, y0 - 0.25, desc,
                ha='center', va='center', fontsize=8,
                color=text_color, alpha=0.85, zorder=3)

        if i < len(steps) - 1:
            ax.annotate('', xy=(x + box_w + gap + 0.02, y0),
                        xytext=(x + box_w - 0.02, y0),
                        arrowprops=dict(arrowstyle='->,head_width=0.35,head_length=0.25',
                                        color='#555555', linewidth=2.5), zorder=4)

    review_top_x = positions[5][0] + box_w / 2
    map_top_x = positions[3][0] + box_w / 2
    box_top = y0 + box_h / 2 + 0.12
    arc_peak = box_top + 1.4

    verts = [(review_top_x, box_top), (review_top_x, arc_peak),
             (map_top_x, arc_peak), (map_top_x, box_top)]
    codes = [Path.MOVETO, Path.CURVE4, Path.CURVE4, Path.CURVE4]
    patch = FancyArrowPatch(
        path=Path(verts, codes),
        arrowstyle='->,head_width=8,head_length=10',
        color='#C05621', linewidth=2.5, linestyle='--', zorder=6)
    ax.add_patch(patch)
    ax.text((review_top_x + map_top_x) / 2, arc_peak + 0.15,
            'Issues found', ha='center', va='bottom', fontsize=9,
            fontstyle='italic', color='#C05621', fontweight='bold')

    ax.text(-1.2, y0, 'Raw Data\n(CSV, Parquet,\nNetCDF, Excel)',
            ha='center', va='center', fontsize=9, color='#555555', fontstyle='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#F0F0F0', edgecolor='#CCCCCC', linewidth=0.8))
    ax.annotate('', xy=(positions[0][0] - 0.02, y0), xytext=(-0.5, y0),
                arrowprops=dict(arrowstyle='->,head_width=0.3,head_length=0.2',
                                color='#888888', linewidth=2), zorder=4)

    last_x = positions[5][0] + box_w
    ax.text(last_x + 1.1, y0, 'Harmonized\nOutput',
            ha='center', va='center', fontsize=9, color='#276749',
            fontweight='bold', fontstyle='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#E6F4EA', edgecolor='#276749', linewidth=0.8))
    ax.annotate('', xy=(last_x + 0.45, y0), xytext=(last_x - 0.02, y0),
                arrowprops=dict(arrowstyle='->,head_width=0.3,head_length=0.2',
                                color='#276749', linewidth=2), zorder=4)

    out = os.path.join(FIG_DIR, 'fig_pipeline.pdf')
    plt.savefig(out, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f"  Saved {out}")


def generate_world_map():
    import cartopy.crs as ccrs
    import cartopy.feature as cfeature

    icos = pd.read_csv(f"{BASE}/Downloads/geri-data/icos/icos_site_info.csv")
    neon = pd.read_parquet(f"{BASE}/Downloads/geri/geri-harmonized/neon_sites.parquet")
    tern = pd.read_parquet(f"{BASE}/Downloads/geri/geri-harmonized/tern_sites.parquet")
    saeon = pd.read_excel(f"{BASE}/Downloads/geri/geri-harmonized/saeon_sites.xlsx", header=1)
    elter = pd.read_excel(f"{BASE}/Downloads/geri/geri-harmonized/elter_sites.xlsx")

    experiment_counts = {'NEON': 47, 'ICOS': 39, 'TERN': 10, 'SAEON': 8, 'eLTER': 15}
    networks = [
        ('NEON',  neon['latitude'].values,  neon['longitude'].values,  NEON_COL,  's'),
        ('ICOS',  icos['Latitude (deg)'].values, icos['Longitude (deg)'].values, ICOS_COL, 'o'),
        ('TERN',  tern['Latitude'].values,  tern['Longitude'].values,  TERN_COL,  '^'),
        ('SAEON', saeon['Latitude'].astype(float).values, saeon['Longitude'].astype(float).values, SAEON_COL, 'D'),
        ('eLTER', elter['Latitude (deg)'].values, elter['Longitude (deg)'].values, ELTER_COL, 'p'),
    ]

    fig, ax = plt.subplots(figsize=(8, 4), subplot_kw={'projection': ccrs.Robinson()})
    ax.set_global()
    ax.add_feature(cfeature.OCEAN, facecolor='#E8EEF4', edgecolor='none')
    ax.add_feature(cfeature.LAND, facecolor='#F5F5F3', edgecolor='#CCCCCC', linewidth=0.4)
    ax.add_feature(cfeature.BORDERS, edgecolor='#DDDDDD', linewidth=0.3)
    ax.add_feature(cfeature.COASTLINE, edgecolor='#999999', linewidth=0.5)

    for name, lats, lons, color, marker in networks:
        n = experiment_counts.get(name, len(lats))
        ax.scatter(lons, lats, transform=ccrs.PlateCarree(),
                   c=color, marker=marker, s=40,
                   edgecolors='white', linewidths=0.6,
                   zorder=5, label=f'{name} ({n})', alpha=0.92)

    legend = ax.legend(loc='lower left', frameon=True, framealpha=0.9,
                       edgecolor='#CCCCCC', fancybox=True,
                       markerscale=1.3, handletextpad=0.5,
                       fontsize=9, title='Network (sites)', title_fontsize=10)
    legend.get_frame().set_linewidth(0.5)

    out = os.path.join(FIG_DIR, 'fig_world_map.pdf')
    plt.savefig(out, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f"  Saved {out}")


if __name__ == '__main__':
    print("Generating publication figures...")
    generate_pipeline()
    generate_world_map()
    print("Done.")
