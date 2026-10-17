# `~/.claude/` — personal Claude Code config

Tracked in [nyzn/dotfiles](https://github.com/nyzn/dotfiles) so the same setup
follows me to any machine. Everything here loads in **every** repo, so it must
stay repo-agnostic: no `apps/<name>/` paths, no project-specific conventions.
Repo-specific config belongs in that repo's own `.claude/`.

```
~/.claude/
├── .gitignore          # whitelist — everything else here stays untracked
├── settings.json       # model, plugins, caveman hooks, statusline
├── skills/             # personal skills, available in every repo
│   ├── open-pr/  review-pr/  fix-pr/  pr-description/  review-user/
│   ├── conventional-commit/
│   ├── reflect/
│   ├── video-editor/         # SKILL.md, brand.md, captions.py, setup.sh
│   └── broll-organizer/
├── agents/             # personal sub-agents
│   ├── code-reviewer.md  security-auditor.md     # review layer
│   ├── architect.md  backend-dev.md  frontend-dev.md  test-engineer.md
│   └── tech-lead.md  budget-guard.md             # coordination layer
└── hooks/
    ├── validate-bash.sh      # generic PreToolUse guard (not wired by default)
    ├── token-budget.py       # reads local transcripts, reports token usage
    └── caveman-*             # caveman plugin companion scripts
```

## The agent team

Two review agents, four implementers, two coordinators. All pinned to a cheap
model on purpose — a subagent inherits nothing from the session's model, so an
unpinned agent silently bills at Opus rates.

| Agent | Owns | Model |
|---|---|---|
| `architect` | boundaries, contracts, data flow, failure modes, migration path | sonnet |
| `backend-dev` | endpoints, services, schema, migrations, jobs, external clients | sonnet |
| `frontend-dev` | components, state, styling, a11y, and frontend performance | sonnet |
| `test-engineer` | backend, frontend and E2E tests; flake diagnosis | sonnet |
| `code-reviewer` | correctness and convention review of a diff; base sync | sonnet |
| `security-auditor` | secrets, injection, dependency and external-call risk | sonnet |
| `tech-lead` | splits a cross-layer feature, closes with one recommendation | sonnet |
| `budget-guard` | measured token consumption, go/trim/defer on a fan-out | haiku |

**Subagents cannot spawn subagents.** `tech-lead` therefore returns a
delegation brief and the main session dispatches it; `budget-guard` gates that
brief when it fans out to three or more agents. Every agent reads the host
repo's `CLAUDE.md` and `.claude/rules/` at runtime, so they carry no project
knowledge of their own and work unchanged in any repo.

`budget-guard` runs `hooks/token-budget.py`, which sums real usage out of the
local transcripts under `projects/` over the rolling 5h window and the trailing
7 days. It reports **consumption, not remaining quota** — plan limits are not
readable from disk, so the true remaining percentage still comes from `/usage`
in an interactive terminal.

## Video skills

`video-editor` (cut, caption, reframe, montage → Reels/TikTok/Shorts/YouTube)
and `broll-organizer` (sorts `~/Movies/B-roll kit/`) moved here from
`nyzn/mono` — they don't touch any repo, so they belong in every repo.

- **One-time per machine:** `~/.claude/skills/video-editor/setup.sh` — installs
  ffmpeg (ffmpeg-full on macOS for libass), whisper.cpp + model, the B-roll
  folders, and the HeyGen Hyperframes skills via `npx skills add -g`.
- **macOS and Linux.** The skill resolves ffmpeg, font (Futura → Inter →
  DejaVu Sans) and work dir at runtime, so it also runs in cloud sessions.
- **claude.ai / cloud sessions** don't see this folder. There the skill comes
  in as an account skill (same `SKILL.md`); it fetches `brand.md` and
  `captions.py` from this repo's raw URL when they're missing — so edit them
  here, never in a copy.
- **Hyperframes skills are third-party and untracked.** They land in
  `~/.claude/skills/<name>/`, and `.gitignore` lists each one explicitly
  *below* `!/skills/**`. If a Hyperframes update adds a skill, add its line
  there before committing anything under `skills/`.

## The .gitignore is a whitelist

`~/.claude` also holds `.credentials.json`, `history.jsonl`, `projects/`,
`sessions/`, and plugin caches. **The dotfiles repo is public.** So
`.gitignore` ignores `*` and re-includes only the paths above. Adding anything
new to the repo means adding an explicit `!` line — do that deliberately, and
never for a file that could contain a token or a transcript.

## Portability

`settings.json` uses `node` from `PATH` and `$HOME/.claude/...`, never absolute
`/Users/...` paths — that's what makes it work on a second machine. Keep it that
way when editing.

Plugins are declared in `settings.json` (`enabledPlugins` +
`extraKnownMarketplaces`); Claude Code installs them from those declarations on
a new machine. The plugin *installs* under `plugins/` are untracked on purpose.
