#!/usr/bin/env python3
"""Judge eval outputs. Usage: judge.py <scenarios.json> <out_dir> <label> [--kind regression|intent]

Reads <out_dir>/<label>/<scenario>/run-*.json (claude -p --output-format json) and prints
passes/valid per scenario. A run is invalid when it ended on an error such as the budget limit.
A run passes when every `require` regex matches, no `forbid` regex matches, and for every
`before` pair the first match of A precedes the first match of B.
"""
import glob, json, os, re, sys

def judge(sc, text):
    flags = re.IGNORECASE
    for r in sc.get("require", []):
        if not re.search(r, text, flags):
            return False
    for r in sc.get("forbid", []):
        if re.search(r, text, flags):
            return False
    for a, b in sc.get("before", []):
        ma, mb = re.search(a, text, flags), re.search(b, text, flags)
        if mb and (not ma or ma.start() > mb.start()):
            return False
    return True

def load(path):
    try:
        d = json.load(open(path, encoding="utf-8"))
    except Exception:
        return None
    if d.get("is_error") or str(d.get("subtype", "")).startswith("error"):
        return None
    return d.get("result", "")

def summarize(scenarios, out_dir, label):
    rows = {}
    for sc in scenarios:
        files = sorted(glob.glob(os.path.join(out_dir, label, sc["id"], "run-*.json")))
        valid = passes = 0
        for f in files:
            text = load(f)
            if text is None:
                continue
            valid += 1
            passes += judge(sc, text)
        rows[sc["id"]] = (passes, valid, len(files) - valid)
    return rows

if __name__ == "__main__":
    scenarios = json.load(open(sys.argv[1], encoding="utf-8"))
    out_dir, label = sys.argv[2], sys.argv[3]
    kind = sys.argv[sys.argv.index("--kind") + 1] if "--kind" in sys.argv else None
    if kind:
        scenarios = [s for s in scenarios if s["kind"] == kind]
    for sid, (p, v, inv) in summarize(scenarios, out_dir, label).items():
        print(f"{sid}\t{p}/{v}\tinvalid={inv}")
