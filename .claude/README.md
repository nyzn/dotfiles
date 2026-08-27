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
│   └── reflect/
├── agents/             # personal sub-agents
│   ├── code-reviewer.md
│   └── security-auditor.md
└── hooks/
    ├── validate-bash.sh      # generic PreToolUse guard (not wired by default)
    └── caveman-*             # caveman plugin companion scripts
```

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
