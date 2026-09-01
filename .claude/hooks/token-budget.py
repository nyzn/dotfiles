#!/usr/bin/env python3
"""Report Claude Code token usage from local transcripts.

Reads ~/.claude/projects/**/*.jsonl and sums real usage over the rolling
5-hour window and the trailing 7 days -- the two units Claude Code plan
limits actually use. Also reports what past subagent runs cost, so an
estimate can be anchored on history instead of guessed.

Usage: token-budget.py [--json] [--hours N] [--days N] [--selftest]
"""
import argparse, json, glob, os, statistics
from datetime import datetime, timedelta, timezone

# Input-equivalent weights: output is ~5x input, cache write 1.25x, cache read 0.1x.
# ponytail: one comparable number beats four incomparable ones. Weights are
# Anthropic's published ratios; update here if pricing ratios change.
W = {"input_tokens": 1.0, "cache_creation_input_tokens": 1.25,
     "cache_read_input_tokens": 0.1, "output_tokens": 5.0}


def parse(line):
    """One transcript line -> a usage row, or None if it carries no usage."""
    try:
        d = json.loads(line)
    except ValueError:
        return None
    msg = d.get("message") or {}
    usage, ts = msg.get("usage"), d.get("timestamp")
    if not usage or not ts:
        return None
    try:
        when = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except ValueError:
        return None
    return {
        "when": when,
        "raw": sum(usage.get(k, 0) or 0 for k in W),
        "weighted": sum((usage.get(k, 0) or 0) * w for k, w in W.items()),
        "model": msg.get("model", "?"),
        "sidechain": bool(d.get("isSidechain")),
        "uuid": d.get("uuid"),
        "parent": d.get("parentUuid"),
        "req": d.get("requestId") or d.get("uuid"),
    }


def read_all():
    for path in glob.glob(os.path.expanduser("~/.claude/projects/*/*.jsonl")):
        try:
            fh = open(path, errors="replace")
        except OSError:
            continue
        with fh:
            for line in fh:
                row = parse(line)
                if row:
                    yield row


def run_roots(rows):
    """Map each sidechain row's uuid to the uuid of the run it belongs to.

    A subagent's lines are written into the *parent* session's file and carry
    the parent's sessionId, so sessionId cannot separate one run from another.
    The conversation root can: walk parentUuid up while the parent is still a
    sidechain row, and the row you stop on is the run.

    Built from every sidechain row, including request-id duplicates, so a
    dropped duplicate can't break a chain and split one run into two.
    """
    sc = [r for r in rows if r["sidechain"]]
    uuids = {r["uuid"] for r in sc}
    parent = {r["uuid"]: r["parent"] for r in sc}
    roots = {}
    for r in sc:
        u, seen = r["uuid"], set()
        while True:
            p = parent.get(u)
            if p is None or p not in uuids or p in seen:
                break
            seen.add(u)
            u = p
        roots[r["uuid"]] = u
    return roots


def summarize(rows, now, hours, days):
    roots = run_roots(rows)

    seen, kept = set(), []
    for r in rows:                        # dedupe retries/resumes by request id
        if r["req"] in seen:
            continue
        seen.add(r["req"])
        kept.append(r)

    win = [r for r in kept if r["when"] > now - timedelta(hours=hours)]
    week = [r for r in kept if r["when"] > now - timedelta(days=days)]
    tot = lambda rs, k="weighted": int(sum(r[k] for r in rs))

    # what one subagent run has historically cost (weighted), over the last 30 days
    runs = {}
    for r in kept:
        if r["sidechain"] and r["when"] > now - timedelta(days=30):
            root = roots.get(r["uuid"], r["uuid"])
            runs[root] = runs.get(root, 0) + r["weighted"]
    sub = sorted(runs.values())

    by_model = {}
    for r in win:
        by_model[r["model"]] = by_model.get(r["model"], 0) + r["weighted"]

    return {
        "window_hours": hours,
        "window_weighted": tot(win),
        "window_raw": tot(win, "raw"),
        "window_messages": len(win),
        "window_by_model": {k: int(v) for k, v in sorted(by_model.items(), key=lambda x: -x[1])},
        "trailing_days": days,
        "trailing_weighted": tot(week),
        "subagent_runs_30d": len(sub),
        "subagent_median_weighted": int(statistics.median(sub)) if sub else None,
        "subagent_p90_weighted": int(sub[min(int(len(sub) * 0.9), len(sub) - 1)]) if sub else None,
        "note": "Weighted = input-equivalent tokens. Plan limits are not exposed "
                "locally; run /usage in an interactive terminal for the real "
                "remaining percentage. These are consumption numbers, not quota.",
    }


def render(out):
    f = lambda n: f"{n:,}" if isinstance(n, int) else "n/a"
    lines = [f"Rolling {out['window_hours']}h:   {f(out['window_weighted'])} weighted  "
             f"({f(out['window_raw'])} raw, {out['window_messages']} messages)"]
    lines += [f"  {m:<28} {f(int(v))}" for m, v in out["window_by_model"].items()]
    lines.append(f"Trailing {out['trailing_days']}d:   {f(out['trailing_weighted'])} weighted")
    if out["subagent_runs_30d"]:
        lines.append(f"Subagent run:  median {f(out['subagent_median_weighted'])}, "
                     f"p90 {f(out['subagent_p90_weighted'])}  "
                     f"(n={out['subagent_runs_30d']}, 30d)")
    else:
        lines.append("Subagent run:  no history yet")
    return "\n".join(lines) + f"\n\n{out['note']}"


def selftest():
    now = datetime.now(timezone.utc)
    at = lambda mins: (now - timedelta(minutes=mins)).isoformat().replace("+00:00", "Z")

    def line(uuid, parent, sidechain, req, out_tok, mins=1):
        return json.dumps({
            "uuid": uuid, "parentUuid": parent, "isSidechain": sidechain,
            "requestId": req, "timestamp": at(mins),
            "message": {"model": "m", "usage": {"input_tokens": 10,
                        "cache_creation_input_tokens": 100,
                        "cache_read_input_tokens": 1000,
                        "output_tokens": out_tok}},
        })

    # one main row, then two distinct subagent runs (a->b, c->d) under it
    raw = [line("main", None, False, "r0", 0),
           line("a", "main", True, "r1", 0), line("b", "a", True, "r2", 0),
           line("c", "main", True, "r3", 0), line("d", "c", True, "r4", 0)]
    rows = [parse(l) for l in raw]
    assert all(rows), "every synthetic line must parse"

    # 10*1 + 100*1.25 + 1000*0.1 + 0*5 = 235
    assert rows[0]["weighted"] == 235, rows[0]["weighted"]
    assert rows[0]["raw"] == 1110, rows[0]["raw"]

    out = summarize(rows, now, hours=5, days=7)
    assert out["subagent_runs_30d"] == 2, out["subagent_runs_30d"]     # not 1 (sessionId) and not 4
    assert out["subagent_median_weighted"] == 470, out             # two rows per run
    assert out["window_weighted"] == 235 * 5, out["window_weighted"]

    # a request-id duplicate is counted once but must not split a run
    dup = rows + [parse(line("b2", "a", True, "r2", 0))]
    assert summarize(dup, now, 5, 7)["subagent_runs_30d"] == 2

    # rows outside the window drop out of the window total but stay in the week
    old = [parse(line("old", None, False, "r9", 0, mins=60 * 8))]
    o = summarize(rows + old, now, hours=5, days=7)
    assert o["window_weighted"] == 235 * 5 and o["trailing_weighted"] == 235 * 6, o

    # p90 index must stay in range for every length
    for n in range(1, 25):
        rs = [parse(line(f"x{i}", "main", True, f"q{i}", i)) for i in range(n)]
        assert summarize(rs, now, 5, 7)["subagent_p90_weighted"] is not None

    print("selftest ok")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    ap.add_argument("--hours", type=int, default=5, help="rolling window, default 5")
    ap.add_argument("--days", type=int, default=7, help="trailing window, default 7")
    ap.add_argument("--selftest", action="store_true", help="run assertions and exit")
    a = ap.parse_args()

    if a.selftest:
        return selftest()

    out = summarize(list(read_all()), datetime.now(timezone.utc), a.hours, a.days)
    print(json.dumps(out, indent=2) if a.json else render(out))


if __name__ == "__main__":
    main()
