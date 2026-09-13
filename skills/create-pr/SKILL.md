---
name: create-pr
description: Analyze the current branch's changes, propose a pull/merge request title + short description, and create the PR/MR after the user approves. Accepts an optional target branch argument. Use when the user asks to open a PR/MR for the current branch or wants a PR title and description.
argument-hint: "[<target-branch>]"
license: MIT
---

# Create PR

Turn the current branch's diff into a pull/merge request. Host CLI is `gh`
(GitHub) or `glab` (GitLab) — detect from the remote URL. CLI recipes
(merged-list, exists-check, create, rewrite) live in `reference.md`.

Before anything: `git branch --show-current` must be non-empty (not detached),
and there must be commits between the target and `HEAD`. Stop and report if not.

## 1. Remote and target branch

`origin` is a convention, not a guarantee:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}   # <remote>/<branch>, if set
git remote                                                    # else: the only one, or `origin`
```

A fork has two remotes (fork + canonical, often `upstream`); target the
canonical one — `gh repo view --json parent` (or compare remote URLs), ask if
still ambiguous.

Target branch — use the argument if given, otherwise never default straight to
`main` (branches are often stacked):

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}   # 1. upstream, minus remote prefix
git log --oneline --decorate -30                              # 2. nearest ancestor branch
git remote show <remote> | sed -n 's/.*HEAD branch: //p'      # 3. remote HEAD, last resort
```

If step 2 below shows far more commits than this branch contributed, the target
is wrong — say so and ask.

## 2. Read the changes

```bash
git fetch <remote> <target> --quiet
git log --oneline <remote>/<target>..HEAD
git diff <remote>/<target>...HEAD --stat
```

If `git fetch` fails, fall back to the local `<remote>/<target>` ref, say so,
warn the base may be stale; don't repair the connection. If `git status --short`
is non-empty, name the uncommitted files — they won't be in the MR — and ask.

Read the **commit messages first**: with commit discipline they are already the
list of decisions the bullets want. Draft from the log, then read the diff to
check and fill in detail. Where messages are noise (`wip`, `fix`), work from the
diff alone. Skip noise in the diff: lockfiles, generated output, vendored code,
binaries, bulk-translated locales. If large, read substantive files first and
delegate the rest.

## 3. Draft title + description

Fill a template if one exists: `.gitlab/merge_request_templates/*.md`,
`.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`.
Otherwise skim recently merged ones for the project's conventions (commands:
`reference.md` → **Recent merged**).

Copy their language, whether a ticket id appears and in what form, and any
leading line the project always opens with. A ticket id belongs in the body only
if those MRs carry one; `#123` (native) or `ABC-123` (tracker integration)
becomes a cross-link, a bare number is just text.

Title: short imperative, capitalized, ~70 chars — `Add call driver button with
contact modal`. Strip commit-convention prefixes (bracketed ticket id,
Conventional Commits `fix:`) unless merged titles keep them.

Description: Markdown. One sentence of user-visible effect, then bullets.
Backticks for identifiers, paths, flags. Budget by diff size — a hard cap:

- ≤5 files: the sentence only, no bullets
- ≤20 files: at most 4 bullets
- more: at most 6 bullets, plus one optional trailing line naming what the
  reviewer should **not** expect to find

One bullet = one sentence, two lines max, choice and reason in that same
sentence. A reason needing its own sentence is a design doc, not a bullet.

A bullet earns its place only if **both** hold:

- a reviewer who has read the file list still would not know it
- the reviewer would act differently if it were false

Order by how likely a reviewer is to disagree, never file order: first
behavioural choices (branches by platform/breakpoint/role/state, feature gating,
fallback path), then, if the cap allows, API/schema/config changes, new shared
modules or options, migrations/flags/deploy actions.

Leave out: markup/CSS structure, layout containers, moves, renames, refactor
mechanics, the diffstat, low-level guards, and lifecycle wiring that follows an
existing convention — all of it only restates the code. Prior broken state
belongs in the commit message.

Before showing the draft, cut: drop every bullet failing the two tests, merge
bullets sharing a subject, delete clauses explaining how it used to work. Over
the cap means you listed inventory — cut, don't reword.

```markdown
Bad:  - Rate limiting is now applied per API key instead of per client IP: the
        old per-IP bucket lumped everyone behind a corporate NAT into a single
        quota, which generated support tickets for months.
Good: - Rate limits key on the API key rather than the client IP, so users
        sharing an office NAT stop draining one another's quota.
```

## 4. Confirm, then create

Check the branch does not already have one (commands: `reference.md` →
**Existing PR/MR?**). If one exists, offer to rewrite its description instead.

State the direction — `<source-branch> → <target-branch>` — then show the draft.
Ask for approval with the multiple-choice question tool (`AskUserQuestion` in
Claude Code, `question` in opencode), not prose, so it's one keystroke: options
`Create` / `Create as draft` / `Edit the description`. Skip only if the user
already said which. Don't ask about assignees, reviewers or labels — projects
that want them set them by rule.

After approval: push unpushed commits (`git push -u <remote> HEAD`), write the
description to a scratchpad file, then create (commands: `reference.md` →
**Create**). Omit merge-behaviour flags to inherit project defaults. Print the
URL.

If neither CLI is installed or authenticated, say so once and hand over the
title and description as text for the web form — do not drive the API by hand.

Links into the code only on request — the reviewer opens the diff anyway. Link
files on the **source branch**, never the target, and never compute diff anchors
(`#diff-<sha256>R<n>`, `#<sha1>_<old>_<new>`): they depend on exact new-side
line numbers and break silently.
