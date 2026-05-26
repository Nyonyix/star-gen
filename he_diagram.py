#!/usr/bin/env python3
"""
hr_diagram_from_galaxy.py
Reads galaxy.json and plots a Hertzsprung‑Russell diagram.
Usage: python hr_diagram_from_galaxy.py galaxy.json [--save plot.png]
"""

import json
import sys
import matplotlib.pyplot as plt
import matplotlib.colors
import numpy as np

# ------------------------------------------------------------
def collect_stars(node):
    """Recursively walk a star system tree and yield all star dicts."""
    if node["type"] == "star":
        yield node
    elif node["type"] == "barycenter":
        if "child_a" in node:
            yield from collect_stars(node["child_a"])
            yield from collect_stars(node["child_b"])

def extract_stars_from_galaxy(filename):
    with open(filename, 'r') as f:
        galaxy = json.load(f)
    temps = []
    lums = []
    for system_id, system_data in galaxy.items():
        root = system_data.get("root_object")
        if root is None:
            continue
        for star in collect_stars(root):
            T = star.get("temperature_K")
            L = star.get("luminosity_Lsun")
            if T is not None and L is not None and T > 0 and L > 0:
                temps.append(T)
                lums.append(L)
    return np.array(temps), np.array(lums)

# ------------------------------------------------------------
def plot_hr(temps, lums, save_path=None):
    fig, ax = plt.subplots(figsize=(10, 8))

    # Scatter plot: colour hot = blue, cool = red
    sc = ax.scatter(temps, lums, c=temps, cmap='RdYlBu', edgecolor='k',
                    alpha=0.6, s=15, norm=matplotlib.colors.LogNorm())
    cbar = plt.colorbar(sc, ax=ax, label='Effective Temperature (K)')

    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.invert_xaxis()

    ax.set_xlabel('Effective Temperature (K)')
    ax.set_ylabel('Luminosity (L$_\odot$)')
    ax.set_title('Hertzsprung–Russell Diagram')

    # Spectral class labels on a secondary x-axis
    ax2 = ax.twiny()
    ax2.set_xscale('log')
    ax2.set_xlim(ax.get_xlim())
    # ax2.invert_xaxis()
    spec_temps = [30000, 10000, 7500, 6000, 5200, 3700, 2400]
    spec_labels = ['O', 'B', 'A', 'F', 'G', 'K', 'M']
    ax2.set_xticks(spec_temps)
    ax2.set_xticklabels(spec_labels)
    ax2.set_xlabel('Spectral Class (approximate)', fontsize=9)

    ax.grid(True, which='both', alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150)
        print(f"HR diagram saved to {save_path}")
    else:
        plt.show()

# ------------------------------------------------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python hr_diagram_from_galaxy.py <galaxy.json> [--save output.png]")
        sys.exit(1)

    filename = sys.argv[1]
    save_path = None
    if "--save" in sys.argv:
        idx = sys.argv.index("--save")
        if idx + 1 < len(sys.argv):
            save_path = sys.argv[idx + 1]

    temps, lums = extract_stars_from_galaxy(filename)
    if len(temps) == 0:
        print("No stars found in the file.")
        sys.exit(1)

    print(f"Found {len(temps)} stars. T range: {temps.min():.0f} – {temps.max():.0f} K, "
          f"L range: {lums.min():.2e} – {lums.max():.2e} L☉")
    plot_hr(temps, lums, save_path)