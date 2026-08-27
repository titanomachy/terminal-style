#!/usr/bin/env python3
"""Create a small, dependency-free SVG badge from kcov's JSON report."""

import argparse
import html
import json
from pathlib import Path


def badge_color(percent: float) -> str:
    if percent >= 90:
        return "#4c1"
    if percent >= 80:
        return "#97ca00"
    if percent >= 70:
        return "#a4a61d"
    if percent >= 60:
        return "#dfb317"
    if percent >= 50:
        return "#fe7d37"
    return "#e05d44"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    report = json.loads(args.report.read_text(encoding="utf-8"))
    percent = float(report["percent_covered"])
    value = html.escape(f"{percent:.1f}%")
    color = badge_color(percent)

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="126" height="20" role="img" aria-label="coverage: {value}">
  <title>coverage: {value}</title>
  <linearGradient id="s" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="r"><rect width="126" height="20" rx="3"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="70" height="20" fill="#555"/>
    <rect x="70" width="56" height="20" fill="{color}"/>
    <rect width="126" height="20" fill="url(#s)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,DejaVu Sans,sans-serif" font-size="11">
    <text x="35" y="15" fill="#010101" fill-opacity=".3">coverage</text>
    <text x="35" y="14">coverage</text>
    <text x="98" y="15" fill="#010101" fill-opacity=".3">{value}</text>
    <text x="98" y="14">{value}</text>
  </g>
</svg>
"""
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(svg, encoding="utf-8")


if __name__ == "__main__":
    main()
