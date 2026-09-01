#!/usr/bin/env python3
"""Report Claude Code token usage from local transcripts.

Reads ~/.claude/projects/**/*.jsonl and sums real usage over the rolling
5-hour window and the trailing 7 days -- the two units Claude Code plan
limits actually use. Also reports what past subagent runs cost, so an
estimate can be anchored on history instead of guessed.

Usage: token-budget.py [--json] [--hours N] [--days N]
"""
import json, sys, glob, os, statistics
from datetime import datetime, timedelta, timezone

# Input-equivalent weights: output is ~5x input, cache write 1.25x, cache read 0.1x.
# ponytail: one comparable number beats four incomparable ones. Weights are
# Anthropic's published ratios; update here if pricing ratios change.
W = {"input_tokens": 1.0, "cache_creation_input_tokens": 1.25,
     "cache_read_input_tokens": 0.1, "output_tokens": 5.0}


def rows():
    for path in glob.glob(os.path.expanduser("~/.claude/projects/*/*.jsonl")):
        try:
            fh = open(path, errors="replace")
        except OSError:
            continue
        with fh:
            for line in fh:
                try:
                    d = json.loads(line)
                except ValueError:
                    continue
                msg = d.get("message") or {}
                usage = msg.get("usage")
                ts = d.get("timestamp")
                if not usage or not ts:
                    continue
                try:
                    when = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                except ValueError:
                    continue
                yield {
                    "when": when,
                    "raw": sum(usage.get(k, 0) or 0 for k in W),
                    "weighted": sum((usage.get(k, 0) or 0) * w for k, w in W.items()),
                    "model": msg.get("model", "?"),
                    "sidechain": bool(d.get("isSidechain")),
                    "session": d.get("sessionId", "?"),
                    "req": d.get("requestId") or d.get("uuid"),
                }


def main():
    args = sys.argv[1:]
    hours = int(args[args.index("--hours") + 1]) if "--hours" in args else 5
    days = int(args[args.index("--days") + 1]) if "--days" in args else 7
    now = datetime.now(timezone.utc)

    seen, all_rows = set(), []
    for r in rows():                      # dedupe retries/resumes by request id
        if r["req"] in seen:
            continue
        seen.add(r["req"])
        all_rows.append(r)

    win = [r for r in all_rows if r["when"] > now - timedelta(hours=hours)]
    week = [r for r in all_rows if r["when"] > now - timedelta(days=days)]

    def tot(rs, key="weighted"):
        return int(sum(r[key] for r in rs))

    # what a subagent run has historically cost (weighted), from the last 30 days
    recent = [r for r in all_rows if r["when"] > now - timedelta(days=30)]
    sc = {}
    for r in recent:
        if r["sidechain"]:
            sc[r["session"]] = sc.get(r["session"], 0) + r["weighted"]
    sub = sorted(sc.values())

    by_model = {}
    for r in win:
        by_model[r["model"]] = by_model.get(r["model"], 0) + r["weighted"]

    out = {
        "window_hours": hours,
        "window_weighted": tot(win),
        "window_raw": tot(win, "raw"),
        "window_messages": len(win),
        "window_by_model": {k: int(v) for k, v in sorted(by_model.items(), key=lambda x: -x[1])},
        "trailing_days": days,
        "trailing_weighted": tot(week),
        "subagent_runs_30d": len(sub),
        "subagent_median_weighted": int(statistics.median(sub)) if sub else None,
        "subagent_p90_weighted": int(sub[int(len(sub) * 0.9)]) if sub else None,
        "note": "Weighted = input-equivalent tokens. Plan limits are not exposed "
                "locally; run /usage in an interactive terminal for the real "
                "remaining percentage. These are consumption numbers, not quota.",
    }
    if "--json" in args:
        print(json.dumps(out, indent=2))
        return
    f = lambda n: f"{n:,}" if isinstance(n, int) else "n/a"
    print(f"Rolling {hours}h:   {f(out['window_weighted'])} weighted  "
          f"({f(out['window_raw'])} raw, {out['window_messages']} messages)")
    for m, v in out["window_by_model"].items():
        print(f"  {m:<28} {f(int(v))}")
    print(f"Trailing {days}d:   {f(out['trailing_weighted'])} weighted")
    if sub:
        print(f"Subagent run:  median {f(out['subagent_median_weighted'])}, "
              f"p90 {f(out['subagent_p90_weighted'])}  (n={len(sub)}, 30d)")
    else:
        print("Subagent run:  no history yet")
    print(f"\n{out['note']}")


if __name__ == "__main__":
    main()
