---
name: conventional-commit
description: Stage and create a well-formed Conventional Commit (correct type, scope, imperative subject, Co-Authored-By trailer). Use when the user asks to commit changes, write a commit message, or commit in conventional-commit style.
---

# Conventional commit

Create a commit that follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/).

**Project rules win.** If the repo documents its own commit convention (`CLAUDE.md`,
`.claude/rules/conventional-commits.md`, `CONTRIBUTING.md`, a commitlint config),
read it first and follow it — scope vocabulary and required trailers are per-repo.
This skill is the fallback when the repo says nothing.

## Steps

1. **Inspect** what changed: `git status` and `git diff` (and `git diff --staged`). Understand the change before describing it.
2. **Group** by logical change. If the diff spans unrelated changes, make separate commits.
3. **Pick the type**: `feat` | `fix` | `docs` | `style` | `refactor` | `perf` | `test` | `build` | `ci` | `chore` | `revert`.
4. **Pick the scope**: the package/module/app the change lives in, optionally narrowed (`backend`, `frontend`, `db`), or a repo-level area (`repo`, `ci`). Match the scopes already in `git log --oneline`.
5. **Write the subject**: `<type>(<scope>): <imperative, lowercase, no period>`, ≤ 72 chars. It must read well in `git log --oneline`.
6. **Body** (optional): wrap at ~72 cols, explain *why* not *what*. Add `BREAKING CHANGE:` footer (and `!` after the scope) for breaking changes.
7. **Branch check**: branch off the default branch before committing if the change is non-trivial. Only commit/push when the user has asked you to.
8. **Commit** with the trailer:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<optional body>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Quick reference

| Change | Example subject |
|---|---|
| New feature | `feat(screener): add monthly risk tier` |
| Bug fix | `fix(backend): bound LLM read timeout` |
| Docs | `docs(repo): document .claude project structure` |
| Deps/build | `build(frontend): bump Angular to 21` |
| Refactor | `refactor(scoring): extract sub-scores` |
| Tests | `test(scoring): cover quality-score blending` |

## Don't

- Don't mix unrelated changes in one commit.
- Don't use past tense ("added") — use imperative ("add").
- Don't omit the trailer the repo requires.
- Don't push unless explicitly asked.
