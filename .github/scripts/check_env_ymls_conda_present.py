#!/usr/bin/env python3
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

DEP_RE = re.compile(r"^\s*-\s+(.+?)\s*$")
KEY_RE = re.compile(r"^\s*([A-Za-z0-9_-]+)\s*:\s*(.*?)\s*$")

def normalize_name(name: str) -> str:
    n = name.strip().lower()
    n = n.replace("_", "-")
    return n

def extract_name(dep: str) -> str:
    """
    Extract conda package name from a dependency spec.
    Examples:
      "xarray>=2024.10" -> "xarray"
      "py-xgboost~=2.1.1=cpu*" -> "py-xgboost"
      "numpy" -> "numpy"
    """
    s = dep.split("#", 1)[0].strip().strip("'").strip('"')
    # take everything up to first version/build operator occurrence
    m = re.search(r"(==|>=|<=|!=|~=|=|>|<)", s)
    name = s[:m.start(1)].strip() if m else s.strip()
    return normalize_name(name)

def parse_conda_deps_only(path: Path) -> Set[str]:
    deps: Set[str] = set()
    in_dependencies = False
    in_pip_block = False
    pip_indent = None

    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    for line in lines:
        if not line.strip() or line.lstrip().startswith("#"):
            continue

        # detect top-level keys
        km = KEY_RE.match(line)
        if km and len(line) - len(line.lstrip()) == 0:
            key = km.group(1)
            if key == "dependencies":
                in_dependencies = True
                in_pip_block = False
                pip_indent = None
            else:
                if key != "dependencies":
                    in_dependencies = False
                    in_pip_block = False
                    pip_indent = None
            continue

        if not in_dependencies:
            continue

        dm = DEP_RE.match(line)
        if not dm:
            continue

        item = dm.group(1).strip()

        # Start pip block, ignore all entries under it
        if item == "pip:":
            in_pip_block = True
            pip_indent = len(line) - len(line.lstrip())
            continue

        if in_pip_block:
            cur_indent = len(line) - len(line.lstrip())
            if pip_indent is not None and cur_indent <= pip_indent:
                in_pip_block = False
                pip_indent = None
            else:
                continue  # ignore pip deps for the simple test

        name = extract_name(item)
        if name:
            deps.add(name)

    # Drop a few non-packages if they appear
    deps.discard("pip")
    return deps

def conda_list_json(env: str) -> Dict[str, str]:
    txt = subprocess.check_output(["conda", "list", "-n", env, "--json"], text=True)
    data = json.loads(txt)
    return {normalize_name(rec["name"]): rec.get("version", "") for rec in data if rec.get("name")}

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--env", default="notebook")
    ap.add_argument("--glob", default="env-*.yml", help="Glob (within /repo) for env files")
    ap.add_argument("--repo-root", default=".", help="Repo root inside container (default: .)")
    args = ap.parse_args()

    repo_root = Path(args.repo_root)
    files = sorted(repo_root.glob(args.glob))
    if not files:
        print(f"ERROR: No files matched {args.glob} under {repo_root}", file=sys.stderr)
        return 2

    required: Set[str] = set()
    for f in files:
        required |= parse_conda_deps_only(f)

    installed = conda_list_json(args.env)
    missing = sorted([p for p in required if p not in installed])

    print(f"Checked conda env: {args.env}")
    print(f"Env files: {', '.join(str(p) for p in files)}")
    print(f"Required conda packages (from yml deps): {len(required)}")
    print(f"Installed conda packages: {len(installed)}\n")

    if missing:
        print("MISSING packages:")
        for m in missing:
            print(f"  - {m}")
        return 1

    print("OK: all conda packages listed in env-*.yml are present.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
