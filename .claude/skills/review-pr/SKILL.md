---
name: review-pr
description: Review a pull request's diff for correctness bugs and repo-convention violations, and mark each finding as an inline PR comment. Use when the user asks to review a PR, find bugs in a PR, or check a PR before merge.
---

# Review a PR

Read a pull request's diff, hunt for real defects, and **mark** each one as an
inline comment on the PR so it can be tracked and fixed. This skill finds and
records bugs; the `fix-pr` skill resolves them.

## Steps

1. **Load the PR.** Get the diff and changed files via the GitHub MCP tools
   (`pull_request_read` with `get_diff` / `get_files`). Note which packages/apps
   are touched and read their `CLAUDE.md` for the gotchas you review against.
2. **Review the diff** for, in priority order:
   - **Correctness** — logic errors, null/`None` handling, off-by-one, wrong
     conditionals, unhandled error paths, races, resource leaks.
   - **Contract & data** — API shape drift, DTOs leaking persistence entities,
     schema changes not backed by a migration, entity-only schema drift.
   - **Repo conventions** — whatever the project's `CLAUDE.md` / rules declare:
     module-boundary violations, hardcoded hosts, secrets in code, unbounded
     external calls (missing timeouts/rate limits), missing UI loading/empty/error
     states.
   - **Tests** — new logic without a unit test; bug fix without a regression test.
   Each finding must have a concrete failure scenario — inputs/state → wrong
   result. Skip style nits the formatter already owns.
3. **Verify before marking.** Only mark findings you can justify from the code.
   Prefer a few high-confidence findings over a long speculative list.
4. **Mark each finding** as an inline review comment anchored to the file+line,
   using the PR review flow (`pull_request_review_write` create → 
   `add_comment_to_pending_review` per finding → `submit_pending`). Prefix each with
   a severity tag so `fix-pr` can triage: `[bug]`, `[convention]`, `[test]`,
   `[nit]`. State the problem and the failure scenario, and suggest a direction.
5. **Summarize** in the review body: counts by severity and the single most
   important issue. If the diff is clean, say so and approve — a clean review is a
   valid outcome, not a reason to invent findings.

## Notes

- Be frugal with comments — one per distinct defect, not per line touched.
- For anything ambiguous or architecturally significant, raise it as a question in
  the review rather than asserting a fix; or hand to `review-user` for the author's
  input.
- Deep single-hunk correctness review can be delegated to the `code-reviewer`
  agent; this skill orchestrates and records the results on the PR.

## Checklist

- [ ] PR diff + changed files loaded; affected `CLAUDE.md` read
- [ ] Findings cover correctness, contract/data, conventions, tests
- [ ] Each finding has a concrete failure scenario and a severity tag
- [ ] Findings marked as inline comments anchored to file+line
- [ ] Review summary posted (or clean approval)
