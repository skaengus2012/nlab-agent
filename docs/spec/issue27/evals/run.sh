#!/usr/bin/env bash
# Behavior eval runner for the #27 instruction changes.
# Usage: run.sh <label> <skills_dir|-> <model> <runs> <out_dir> [scenario_id ...]
#   label       name of this condition, e.g. baseline, control, after
#   skills_dir  directory holding <skill>/SKILL.md copies to inject; "-" runs without any instruction (control)
#   model       e.g. claude-sonnet-5-5
#   runs        runs per scenario; finished runs are skipped, so the script can be resumed
#   out_dir     where results are written (created if missing)
# Environment: EVAL_CAP_USD (total hard cap, default 25), EVAL_RUN_BUDGET_USD (per run; default 0.50, 0.10 for haiku)
set -u

if [ "$#" -lt 5 ]; then
    sed -n '2,9p' "$0" >&2
    exit 64
fi
label="$1"; skills_dir="$2"; model="$3"; runs="$4"; out_dir="$5"; shift 5
only=("$@")

here="$(cd "$(dirname "$0")" && pwd -P)"
cap="${EVAL_CAP_USD:-25}"
case "$model" in
    *haiku*) run_budget="${EVAL_RUN_BUDGET_USD:-0.10}" ;;
    *)       run_budget="${EVAL_RUN_BUDGET_USD:-0.50}" ;;
esac
mkdir -p "$out_dir"
cost_file="$out_dir/cost.total"
[ -f "$cost_file" ] || echo 0 > "$cost_file"
{
    echo "model=$model"
    echo "claude=$(claude --version)"
    echo "effort=medium"
    echo "note=--append-system-prompt-file is not listed as its own flag in 'claude --help'"
} > "$out_dir/meta-$label.txt"

ids="$(python3 -c "import json,sys; print('\n'.join(s['id'] for s in json.load(open(sys.argv[1]))))" "$here/scenarios.json")"

for id in $ids; do
    if [ "${#only[@]}" -gt 0 ] && [[ ! " ${only[*]} " =~ " $id " ]]; then continue; fi
    skill="$(python3 -c "import json,sys; print([s for s in json.load(open(sys.argv[1])) if s['id']==sys.argv[2]][0]['skill'])" "$here/scenarios.json" "$id")"
    prompt="$(python3 -c "import json,sys; print([s for s in json.load(open(sys.argv[1])) if s['id']==sys.argv[2]][0]['prompt'])" "$here/scenarios.json" "$id")"
    mkdir -p "$out_dir/$label/$id"
    for i in $(seq 1 "$runs"); do
        out="$out_dir/$label/$id/run-$i.json"
        [ -s "$out" ] && continue
        total="$(cat "$cost_file")"
        if python3 -c "import sys; sys.exit(0 if float(sys.argv[1]) < float(sys.argv[2]) else 1)" "$total" "$cap"; then :; else
            echo "STOP: total cost $total reached the cap $cap" >&2; exit 2
        fi
        args=(-p "$prompt" --disable-slash-commands --model "$model" --effort medium
              --max-budget-usd "$run_budget" --output-format json --strict-mcp-config
              --no-session-persistence --tools "")
        if [ "$skills_dir" != "-" ]; then
            args+=(--append-system-prompt-file "$skills_dir/$skill/SKILL.md")
        fi
        # Fresh empty working directory for every run so no project instructions leak in.
        wd="$(mktemp -d)"
        ( cd "$wd" && claude "${args[@]}" > "$out" 2> "$out.err" )
        rm -rf "$wd"
        python3 - "$out" "$cost_file" <<'PY'
import json, sys
try:
    cost = float(json.load(open(sys.argv[1])).get("total_cost_usd", 0))
except Exception:
    cost = 0.0
total = float(open(sys.argv[2]).read() or 0) + cost
open(sys.argv[2], "w").write(f"{total:.4f}")
PY
        echo "done: $label/$id/run-$i (total \$$(cat "$cost_file"))"
    done
done
