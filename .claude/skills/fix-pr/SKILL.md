---
name: fix-pr
description: Fix the bugs marked on a pull request — review comments and findings from review-pr — then commit and push the fixes. Use when the user asks to fix a PR, address review comments, or resolve marked findings.
---

# Fix marked PR bugs

Take the findings marked on a pull request (inline review comments, especially the
severity-tagged ones from `review-pr`) and resolve them with focused commits.

## Steps

1. **Gather the findings.** Read the PR's review threads and comments via the
   GitHub MCP tools (`pull_request_read` with `get_review_comments` / `get_reviews`
   / `get_comments`). Collect unresolved ones; note the file:line and severity tag
   (`[bug]`, `[convention]`, `[test]`, `[nit]`).
2. **Triage.** Order by severity: `[bug]` first, then `[convention]`, `[test]`,
   `[nit]`. For anything ambiguous or architecturally significant, **don't guess** —
   route it through `review-user` before touching code.
3. **Fix on the PR's branch.** Check out the head branch. Make the smallest change
   that resolves each finding; match surrounding style. Keep one logical fix per
   commit. Add a regression test where a `[bug]`/`[test]` finding calls for it
   (repo testing rule).
4. **Verify.** Run the affected app's tests (`./mvnw test` / `pnpm test`) and, for
   runtime changes, exercise the flow (the `verify` skill) before pushing. Don't
   claim a fix is verified if tests weren't run — say what ran and what didn't.
5. **Commit & push.** Use `conventional-commit` (`fix(<app>): …`). Push to the same
   branch (`git push -u origin <branch>`, backoff on network error).
6. **Resolve the threads.** Reply to each addressed review thread with what changed
   and resolve it (`resolve_review_thread`). If a finding was intentionally not
   fixed, reply explaining why instead of resolving silently.
7. **Report** what was fixed, what was deferred (and why), and test results.

## Notes

- Don't expand scope: fix the marked findings, not unrelated code you notice.
- If fixing one finding reveals a larger problem, surface it (comment or
  `review-user`) rather than silently doing a big refactor.
- Loop-friendly: after pushing, new review rounds or CI results may mark more
  findings — re-run this skill on them until the PR is clean.

## Checklist

- [ ] Unresolved marked findings gathered with file:line + severity
- [ ] Ambiguous/architectural items routed to `review-user`, not guessed
- [ ] Fixes made on the PR head branch, smallest-change, style-matched
- [ ] Regression test added where a bug/test finding required it
- [ ] Affected app tests run (and runtime flow verified); results stated
- [ ] Committed via `conventional-commit` and pushed to the same branch
- [ ] Review threads replied to and resolved (or explained if not fixed)
