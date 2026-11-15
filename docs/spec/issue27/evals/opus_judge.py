#!/usr/bin/env python3
"""Blind second grader. Usage: opus_judge.py <scenarios.json> <out_dir> <label> [--model M] [--cap USD] [scenario_id ...]

Grades every valid run-*.json under <out_dir>/<label> with an LLM against the scenario's `rubric`.
The grader sees only the rubric, the task prompt and the response. It never sees the condition label,
the skill text, or the regex rules. Results are cached in <out_dir>/judge/<label>/<scenario>/run-N.json,
so the script can be resumed. Stops when the cumulative grading cost reaches --cap.
"""
import glob, json, os, subprocess, sys, tempfile, time

def arg(name, default):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default

scenarios = {s["id"]: s for s in json.load(open(sys.argv[1], encoding="utf-8"))}
out_dir, label = sys.argv[2], sys.argv[3]
model = arg("--model", "claude-opus-5-5")
cap = float(arg("--cap", "10"))
skip = {sys.argv.index(x) for x in ("--model", "--cap") if x in sys.argv}
skip |= {i + 1 for i in skip}
only = [a for i, a in enumerate(sys.argv[4:], 4) if i not in skip]
cost_file = os.path.join(out_dir, "judge", "cost.total")
os.makedirs(os.path.dirname(cost_file), exist_ok=True)
total = float(open(cost_file).read()) if os.path.exists(cost_file) else 0.0

TEMPLATE = """You are grading one response against a rubric. Be strict and literal about the rubric.

TASK GIVEN TO THE ASSISTANT:
{prompt}

RESPONSE TO GRADE (it may be written in Korean or English; judge the behavior, not the language):
<response>
{response}
</response>

RUBRIC:
{rubric}

Reply with JSON only, no other text: {{"pass": true or false, "reason": "one short sentence"}}"""

for sid, sc in scenarios.items():
    if only and sid not in only:
        continue
    for f in sorted(glob.glob(os.path.join(out_dir, label, sid, "run-*.json"))):
        try:
            d = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        if d.get("is_error") or str(d.get("subtype", "")).startswith("error"):
            continue
        dst = os.path.join(out_dir, "judge", label, sid, os.path.basename(f))
        if os.path.exists(dst) and os.path.getsize(dst) > 0:
            continue
        if total >= cap:
            print(f"STOP: grading cost {total:.2f} reached cap {cap}", file=sys.stderr); sys.exit(2)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        prompt = TEMPLATE.format(prompt=sc["prompt"], response=d.get("result", ""), rubric=sc["rubric"])
        wd = tempfile.mkdtemp()
        cmd = ["claude", "-p", prompt, "--disable-slash-commands", "--model", model, "--effort", "medium",
               "--max-budget-usd", "0.50", "--output-format", "json", "--strict-mcp-config",
               "--no-session-persistence", "--tools", ""]
        # The CLI can briefly disappear while it updates itself; wait for it instead of crashing.
        for attempt in range(60):
            try:
                r = subprocess.run(cmd, cwd=wd, capture_output=True, text=True)
                break
            except (FileNotFoundError, PermissionError):
                time.sleep(10)
        else:
            print("STOP: claude CLI unavailable for 10 minutes", file=sys.stderr); sys.exit(3)
        try:
            res = json.loads(r.stdout)
            cost = float(res.get("total_cost_usd", 0))
            txt = res.get("result", "")
            verdict = json.loads(txt[txt.index("{"): txt.rindex("}") + 1])
            rec = {"pass": bool(verdict["pass"]), "reason": verdict.get("reason", ""), "cost": cost}
        except Exception as e:
            rec = {"pass": None, "reason": f"unparsable: {e}", "cost": 0.0}
            cost = 0.0
        total += cost
        open(cost_file, "w").write(f"{total:.4f}")
        json.dump(rec, open(dst, "w", encoding="utf-8"), ensure_ascii=False)
        print(f"graded {label}/{sid}/{os.path.basename(f)} pass={rec['pass']} (total ${total:.3f})")
