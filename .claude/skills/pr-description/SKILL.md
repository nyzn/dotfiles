---
name: pr-description
description: Write a clear pull-request description — a summary of what the PR does and why, the changes, and (for app-related PRs) a "How to test" section with the exact steps to exercise the feature in the running app. Use when the user asks to write, draft, or improve a PR description / body.
---

# PR description

Produce a pull-request body that a reviewer can read top-to-bottom and understand
**what changed, why, and how to verify it**. Base it on the actual diff, not on
the task prompt — read the code before you describe it.

If a PR template exists (`.github/pull_request_template.md`,
`.github/PULL_REQUEST_TEMPLATE.md`, root `PULL_REQUEST_TEMPLATE.md`, or
`docs/PULL_REQUEST_TEMPLATE.md`), mirror its headings and fill them from the diff.
The structure below is the default when there is no template.

## Steps

1. **Read the diff.** `git diff main...HEAD` (and `git log main..HEAD --oneline`).
   Identify which package/app/module is touched and read its `CLAUDE.md` or
   `README.md`, then scope the description to it.
2. **Find the "why".** Pull intent from the linked issue, the branch name, and
   the commits. Say what problem this solves, not just what files moved.
3. **Decide if it's runtime-related.** If the change affects something runnable
   (endpoint, UI view, compose service, migration, CLI), you **must** include a
   [How to test](#how-to-test) section with concrete steps. Pure docs / agent-config
   / tooling PRs can omit it — say "No app runtime affected" instead.
4. **Write the body** using the [template](#template).
5. **Honor repo copy rules** if the project documents any (e.g. neutral,
   informational-only wording for finance-adjacent products).
6. Present the body for the user to use; only create/update the PR if asked.

## Template

```md
## What & why
<1–3 sentences: what this PR does and the problem it solves.>

## Changes
- <bullet per meaningful change, grouped by area (backend / frontend / db / infra)>
- <migrations, new endpoints, new components, config — call out anything a reviewer must notice>

## How to test
<Only for app-related PRs. Give exact, copy-pasteable steps. See guidance below.>

## Notes
<Optional: breaking changes, version-pin deviations, follow-ups, screenshots.>
```

## How to test

Make the steps runnable, matched to the project's own `README.md` / `CLAUDE.md`. A good
"How to test" section covers:

1. **Setup** — from the directory the project documents, its own run command
   (e.g. `cp .env.example .env` then `docker compose up --build`, or the dev-mode
   command). Use the tooling the project actually declares, not an assumed one.
2. **The exercise** — the exact action that hits the new code:
   - **Backend:** the request, e.g.
     `curl -s localhost:<port>/api/<path>` (relative `/api`, real port from the
     app's compose/config), and what the response should contain.
   - **Frontend:** the URL/route to open, what to click, and what should render —
     including the required loading / empty / error states where relevant.
   - **DB / migration:** confirm the migration applies and the schema validates
     on startup.
3. **Expected result** — state the pass condition explicitly ("returns 200 with a
   `score` field", "sparkline renders for a valid ticker, snackbar on error"), so
   the reviewer knows what "works" looks like.
4. **Auth, if applicable** — if the app sits behind an IdP or needs a token, note
   how to obtain one.

## Checklist

- [ ] Description built from the actual diff, scoped to the affected area
- [ ] "What & why" explains the problem, not just the files
- [ ] Changes grouped and reviewer-relevant items called out (migrations, endpoints, breaking changes)
- [ ] "How to test" present with runnable steps for runtime PRs (or explicitly marked N/A)
- [ ] Existing PR template honored if one is present
- [ ] Repo copy rules honored, if any
