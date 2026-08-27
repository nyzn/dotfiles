---
name: review-user
description: Ask the user to review a specific piece of code inside a pull request and capture their feedback on how to solve it. Use when a change is ambiguous, architecturally significant, or needs a human decision before you act. Pairs with review-pr for findings that aren't safe to auto-fix.
---

# Ask the user to review specific code

Some findings can't be auto-fixed — they hinge on intent, a product decision, or a
trade-off only the author can settle. This skill surfaces one specific slice of a
PR to the user and collects a concrete decision on how to proceed.

## When to use

- A `review-pr` finding is ambiguous or could be interpreted multiple ways.
- The change touches something architecturally significant (schema, public API,
  auth, cross-cutting behavior).
- You have two plausible fixes and need the author to pick.

## Steps

1. **Isolate the slice.** Identify the exact file + line range in the PR that needs
   a human eye. Pull that hunk from the PR diff — don't ask about the whole PR.
2. **Frame the question with context.** Include enough that the user can answer
   without scrolling back: the file:line, the relevant code, why it's in question,
   and the concrete options you see (with your recommendation first).
3. **Ask via `AskUserQuestion`.** Present the options as distinct, mutually
   exclusive choices where possible. Keep each option's implication clear
   (what happens if chosen). Always leave room for a free-form answer.
4. **Capture the decision.** Record the user's choice and any notes. If they picked
   a direction, restate it as the actionable fix so `fix-pr` (or you) can apply it.
5. **Close the loop.** If the code lives in a PR review thread, reply to that thread
   with the resolution so the PR reflects the decision. Then proceed to implement or
   hand off to `fix-pr`.

## Notes

- One decision per ask — don't bundle unrelated questions into one prompt.
- Never guess on architecturally significant changes; that's exactly what this
  skill is for.
- This is the human-in-the-loop counterpart to `review-pr`: `review-pr` marks what
  it's confident about; `review-user` escalates what it isn't.

## Checklist

- [ ] Exact file:line slice isolated (not the whole PR)
- [ ] Question includes code + context + options, recommendation first
- [ ] Asked via `AskUserQuestion` with a free-form escape hatch
- [ ] Decision captured and restated as an actionable fix
- [ ] PR review thread updated with the resolution if applicable
