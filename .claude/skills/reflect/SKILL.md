---
name: reflect
description: Audit existing skills (project .claude/skills/ and personal ~/.claude/skills/) and recommend improvements — cut token cost, sharpen trigger descriptions, split overloaded skills, and fix drift from repo conventions. Use when the user wants to review, optimize, refine, or "reflect on" the skills, or asks why a skill isn't triggering / is too expensive.
---

# Reflect on the skills

Take a deep dive into the existing skills — project (`.claude/skills/`) and
personal (`~/.claude/skills/`) — and produce a concrete, prioritized set of
improvements. The goal is skills that are **cheap to load, easy to trigger, and
single-purpose**, loading only when the task matches so context stays light.

Personal skills load in *every* repo, so hold them to a stricter bar: no
project-specific paths, commands, or conventions in a `~/.claude/skills/` skill.

This skill reviews and proposes; it only edits skills when the user says to apply
the findings.

## When to use

- "Review / optimize / refine the skills."
- "Why isn't `<skill>` triggering?" or "why is `<skill>` so token-heavy?"
- Periodic hygiene pass after skills have grown or drifted from conventions.

## Steps

1. **Inventory.** List every skill: `ls .claude/skills/*/SKILL.md ~/.claude/skills/*/SKILL.md`. Read each
   `SKILL.md` in full, plus any bundled reference files it points to. Note the
   line/byte count of each — size is the proxy for load cost.
2. **Measure the front matter.** The `description` is what the model reads on
   *every* session to decide whether to load the skill. Check each one against
   the [description rubric](#description-rubric) below.
3. **Measure the body.** The body only loads when the skill triggers, but a
   bloated body is paid for on every invocation. Look for the
   [body smells](#body-smells).
4. **Check for split / merge candidates.** See [when to split](#split-vs-merge).
5. **Check convention drift.** Does each project skill still match the root
   `CLAUDE.md` and `.claude/rules/*`? Stale commands, renamed modules, dead file
   paths, and duplicated rule text (that should be a `@`-import instead) all
   count. For a personal skill, drift means the opposite: repo-specific detail
   that leaked in and now misfires elsewhere.
6. **Report.** Emit a findings table (below), most-impactful first. For each
   finding give: skill, category, the problem, and the concrete fix.
7. **Apply only if asked.** If the user says to proceed, make the edits, keep
   each skill's `name`/dir in sync, and commit with a conventional commit
   (`refactor(agent): …` or `docs(agent): …`). Otherwise stop at the report.

## What to look for

### Description rubric

The `description` is the highest-leverage, always-loaded text. A good one:

- **Names concrete triggers** — the verbs/nouns a user would actually say
  ("commit", "scaffold an app"), so the model matches reliably.
- **States what it does AND when to use it** — both halves, in one or two
  sentences. Front-load the distinctive words.
- **Is tight** — no filler, no restating the body. Every token here is paid on
  every session, for every skill.
- **Doesn't overlap** a sibling skill's triggers — overlap causes mis-fires and
  wasted loads. Flag pairs whose descriptions could both match the same prompt.

Flag descriptions that are vague ("helps with skills"), missing the *when*,
overly long, or collide with another skill.

### Body smells

- **Duplicated convention text.** Rules already in `.claude/rules/*` or a
  `CLAUDE.md` should be referenced, not copy-pasted — the copy goes stale and
  costs tokens on every load.
- **Over-long examples / templates.** Keep one canonical example, not five.
  Large boilerplate templates belong in a bundled reference file the skill points
  to, so they load only when actually needed.
- **Instructions the model already knows.** Generic advice ("write clean code")
  adds tokens without steering behavior. Keep only repo-specific, non-obvious
  guidance.
- **Dead content.** Paths, commands, or app names that no longer exist.

### Split vs merge

- **Split** a skill when it covers two distinct triggers that rarely co-occur, or
  when only one of several sections is ever needed at a time — splitting lets the
  model load just the relevant half. Each resulting skill should have its own
  crisp description.
- **Merge** two skills when their descriptions overlap so much that the model
  can't tell them apart, or when one is a thin wrapper around the other.
- Prefer the smallest number of skills that each have a clear, non-overlapping
  trigger.

## Findings report format

Present findings as a table, highest impact first:

| Skill | Category | Problem | Fix |
|---|---|---|---|
| `<name>` | token-cost / trigger / split / drift | <what's wrong> | <concrete change> |

Then a one-line recommendation of which fixes to apply first. Do **not** edit any
skill until the user confirms.

## Checklist

- [ ] Every `SKILL.md` (and bundled refs) read in full
- [ ] Each `description` checked against the rubric (triggers, what+when, tightness, no overlap)
- [ ] Bodies checked for duplicated rules, oversized templates, generic filler, dead content
- [ ] Split/merge candidates identified
- [ ] Convention drift checked (project skills vs `CLAUDE.md`/rules; personal skills for leaked repo specifics)
- [ ] Findings reported most-impactful first; edits applied only if the user asked
