#!/usr/bin/env bash
#
# PreToolUse hook for Bash tool calls. OPTIONAL — wire it up yourself in
# .claude/settings.json (see .claude/README.md) if you want it active:
#
#   "hooks": { "PreToolUse": [ { "matcher": "Bash",
#     "hooks": [ { "type": "command",
#       "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validate-bash.sh" } ] } ] }
#
# Reads the tool-call JSON on stdin. Exit 0 = allow, exit 2 = block (the
# message on stderr is shown to the agent). It's a safety net, not a sandbox.

input="$(cat)"

block() {
  echo "validate-bash: blocked — $1" >&2
  exit 2
}

# Recursive delete of root / home.
if printf '%s' "$input" | grep -Eq 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+(/|~|\$HOME|\.\.)([[:space:]"]|$)'; then
  block "recursive delete of root, home, or parent"
fi

# Classic fork bomb.
if printf '%s' "$input" | grep -Fq ':(){ :|:& };:'; then
  block "fork bomb"
fi

# Force-push (protect the shared main branch and history in general).
if printf '%s' "$input" | grep -Eq 'git[[:space:]]+push[^|]*(--force([[:space:]=]|$)|[[:space:]]-f([[:space:]]|$))'; then
  block "force-push (rewriting shared history) — use a normal push or branch instead"
fi

# Piping a remote script straight into a shell.
if printf '%s' "$input" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh)'; then
  block "piping a downloaded script directly into a shell"
fi

exit 0
