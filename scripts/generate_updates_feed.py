#!/usr/bin/env python3
"""Generate updates.json dynamically from repo state.

Usage:
  python scripts/generate_updates_feed.py

This script reads pubspec.yaml version and latest git commit metadata,
then writes updates.generated.json so update feed can be refreshed without
manually editing JSON content each time files change.
"""

from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
OUT = ROOT / "updates.generated.json"


def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, cwd=ROOT).decode().strip()


def parse_version() -> str:
    for line in PUBSPEC.read_text().splitlines():
        if line.startswith("version:"):
            return line.split(":", 1)[1].strip().split("+")[0]
    return "0.0.0"


def main() -> None:
    version = parse_version()
    commit = run(["git", "rev-parse", "--short", "HEAD"])
    subject = run(["git", "log", "-1", "--pretty=%s"])

    data = {
        "version": version,
        "notes": f"{subject} (commit {commit})",
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "url": "https://example.com/latest.apk",
        "newFeatures": [
            "Notification stream available in More section",
            "Admin-only sender mode auto-enabled for kuldeepky538@gmail.com",
            "Live app version detection",
        ],
    }

    OUT.write_text(json.dumps(data, indent=2) + "\n")
    print(f"Generated {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
