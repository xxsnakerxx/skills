---
name: review-fixes
description: Fix and resolve MR/PR review comments one at a time, on GitLab (glab) or GitHub (gh). Use when the user asks to address or fix review comments, resolve review threads, work through an MR/PR review, or resumes "review-fixes".
argument-hint: "[<MR|PR number> | docs/review/mr<N>-fixes.md]"
license: MIT
---

# Review fixes

Fetch → map → fix one-by-one → resolve. Exact commands for each step live in
`reference.md` — open it at the section named here.

## Environment

- Detect host + project from the remote, never hardcode. `git remote get-url origin`: host contains `gitlab` → `glab`; `github.com`/GH-Enterprise → `gh`. Project path is everything after the host (`git@host:group/repo.git` → `group/repo`).
- Placeholders: `<PROJECT>` = URL-encoded project path (`/`→`%2F`); `<PATH>` = un-encoded; `<OWNER>/<REPO>` for GitHub; `<MR>` = MR/PR number.
- `glab`/`gh` may be blocked in a sandbox (network/TLS). Try the command once; if it fails for an environment reason, hand it to the user with the `!` prefix (opencode/Claude Code) and **wait for confirmation it ran**. Never assume a handed-off command succeeded.
- Optional dependency: `grilling` — the `grilling` skill from `mattpocock/skills` (`npx skills add mattpocock/skills -s grilling`), used to stress-test a fix choice or a decline. Not `grill-me` / `grill-with-docs`.

## Step 0 — Resume check (first)

Determine `<MR>`: explicit number → number in a fix-map path argument (`docs/review/mr1715-fixes.md`→`1715`) → `ls docs/review/` (a single `mr<N>-fixes.md` is the one to resume) → else ask.

If `docs/review/mr<MR>-fixes.md` exists, don't refetch — Read it, go to Step 3 on the next unchecked item. Else Step 1.

## Step 1 — Fetch

Redirect to a file so nothing truncates; read it after. Commands: `reference.md` → **Fetch**.

- GitLab: `--comments` shows notes but omits discussion IDs — also fetch discussions and build a note-id → discussion-id map.
- GitHub: the `reviewThreads` query yields thread IDs directly (needed to resolve). Unresolved threads are the work.
- **No comments → say so and stop**; there is nothing to fix.

## Step 2 — Build the fix-map

Detect the **commit-message prefix** from the project — don't hardcode it. The ticket id is usually in the source branch name (`git branch --show-current`), the MR title, or recent commits; match the form the project uses (`[6832455]`, `ABC-123`, …). Record it at the top so it survives `/clear`. Ask only if it can't be inferred.

`mkdir -p docs/review`, then create `docs/review/mr<MR>-fixes.md`: one checklist item per comment, grouped **🐛 Bugs** (first) / **⚠️ Data / comments** / **💬 Nits / questions**. Each item: short title, exact `file:line`, one-line problem summary, the resolve handle (`[note #id, disc <discussion_id>]` GitLab / `[thread <PRRT-id>]` GitHub), and a `- [ ]` box. Copy the **Workflow rules** block verbatim (self-contained after `/clear`). Present the grouped summary.

> ### Workflow rules
> - **One item per session**, then STOP — don't start the next.
> - One fix = one commit; bugs first.
> - **Never commit automatically** — propose a prefixed message, commit only on explicit request.
> - After each fix, resolve its thread. If no fix is needed (declined/deferred nit), draft a reply instead, then resolve.
> - When done, tick `- [ ]`→`- [x]` and note the commit/reply. This doc is the source of truth — resumable after `/clear`.

## Step 3 — Do ONE item, then stop

Next unchecked item (bugs first), exactly one. Pick **1 or 2**, then always do **3 and 4**:

1. **Code fix needed:** make the change, follow project conventions (CLAUDE.md). After non-trivial edits run the project's typecheck/lint/formatter — whatever the repo defines (CLAUDE.md / package.json scripts / Makefile), not a hardcoded command. Print a prefixed commit message; **don't commit until asked**. When committing, stage only the fix's files — never `git add .`/`-A`; the fix-map (untracked) must not be committed.
   - If the bug has **>1 plausible fix** and you picked one, invoke `grilling` on it *before editing* (if that skill isn't installed, challenge the choice yourself with two or three hard questions). Skip for mechanical fixes (stale comment, magic strings → constants, inline styles).
2. **No fix needed** (declined/deferred nit, or reviewer mistaken): don't touch code — draft a short polite reply in the thread's language explaining why.
   - Before drafting a decline/design-answer, invoke `grilling` on your stance (if not installed, stress-test it yourself) — declining is highest-risk; make sure it survives being pushed on.
3. **Resolve the thread** (commands: `reference.md` → **Resolve / reply**). Sandbox-blocked → print, wait for confirmation before ticking.
4. **Update the fix-map:** tick the item, note the commit/reply.

**Then STOP.** Tell the user to `/clear` and re-invoke `review-fixes docs/review/mr<MR>-fixes.md` for the next item.

**Last item** (no `- [ ]` left): don't suggest `/clear` — confirm the MR is done and **ask whether to delete `docs/review/mr<MR>-fixes.md`** (scratch). Delete only on yes.

## Resolve / reply

Commands for both hosts — resolve, reply (declined nit), and reopen — are in
`reference.md` → **Resolve / reply**. The GitHub reply omits
`pullRequestReviewId` so it posts to the thread, not a pending draft review.
