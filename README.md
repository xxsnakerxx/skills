<p align="center">
  <img src="assets/banner.svg" alt="skills — code review / PR workflow agent skills" width="720">
</p>

<p align="center">
  <a href="https://skills.sh/xxsnakerxx/skills"><img src="https://skills.sh/b/xxsnakerxx/skills" alt="skills.sh"></a>
  <a href="https://github.com/xxsnakerxx/skills/actions/workflows/validate.yml"><img src="https://github.com/xxsnakerxx/skills/actions/workflows/validate.yml/badge.svg" alt="Validate"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://github.com/xxsnakerxx/skills/stargazers"><img src="https://img.shields.io/github/stars/xxsnakerxx/skills" alt="GitHub stars"></a>
</p>

Agent skills for the code-review workflow — turn a branch into a well-written
PR, then clear its review feedback one commit at a time. Self-contained, work
with any agent that supports `skills`.

## Install

The `skills` CLI installs into the agent directories it detects. Pick your
agent, or install everywhere:

<details open>
<summary><b>All agents (auto-detect)</b></summary>

```bash
npx skills@latest add xxsnakerxx/skills -s create-pr review-fixes
```

</details>

<details>
<summary><b>Claude Code</b></summary>

```bash
npx skills@latest add xxsnakerxx/skills -s create-pr review-fixes -a claude-code
```

</details>

<details>
<summary><b>opencode</b></summary>

```bash
npx skills@latest add xxsnakerxx/skills -s create-pr review-fixes -a opencode
```

</details>

<details>
<summary><b>Codex</b></summary>

```bash
npx skills@latest add xxsnakerxx/skills -s create-pr review-fixes -a codex
```

</details>

<details>
<summary><b>Cursor</b></summary>

```bash
npx skills@latest add xxsnakerxx/skills -s create-pr review-fixes -a cursor
```

</details>

Pick individual skills with `-s <name>`, or `-s '*'` for everything.

## Skills

| Skill | What it does |
|-------|--------------|
| [create-pr](skills/create-pr/SKILL.md) | Resolve the target branch, read the diff, draft a title + description that follows the project's own conventions, create the PR/MR after approval. |
| [review-fixes](skills/review-fixes/SKILL.md) | Fetch review comments, build a resumable fix-map, and resolve them one commit at a time. |

## What it produces

### create-pr

Give it a branch and it returns a draft, not a diff summary. From
`export-orders-csv` (9 files):

```text
Title   Add CSV export to orders list

Adds an "Export CSV" button to the orders list that downloads the current
filtered view.

- The export respects the active filters rather than the full table, so what
  you see is what you download.
- Exports are capped at 10k rows; larger sets must use the API, since the UI
  paginates and would silently truncate.
- Dates render in the viewer's locale to match the on-screen list, not ISO 8601.
```

One sentence of user-visible effect, then the decisions a reviewer would
actually challenge — no inventory of changed files, no "updated"/"refactored".
It reads the project's merged PRs first and matches their conventions (ticket
ids, template, title style).

### review-fixes

Give it a PR with feedback and it returns a **fix-map**, not a stray pile of
edits. From PR `1715` (GitLab is identical — MRs, `note`/`disc` handles):

```text
## 🐛 Bugs
- [x] Guard empty `items` in Order.total    src/order.ts:42  [thread PRRT_kwDOA1b2C3]
- [ ] Round before summing, not after       src/order.ts:48  [thread PRRT_kwDOA1b2C4]

## ⚠️ Data / comments
- [ ] Link `discount` doc to its DB column  src/order.ts:61  [thread PRRT_kwDOA1b2C5]

## 💬 Nits / questions
- [ ] Rename `tmp` → `subtotal`             src/order.ts:44  [thread PRRT_kwDOA1b2C6]
```

Bugs first, one fix per commit, each item pinned to its `file:line` and resolve
handle. The doc is the source of truth — after `/clear` it resumes on the next
unchecked box and ticks each item off as it's resolved.

## Layout

```
skills/
  <name>/
    SKILL.md       # the workflow
    reference.md   # exact CLI/API commands, opened on demand
```

`npx skills add` discovers skills automatically; helper files stay inside the
skill's directory so a partial install (`-s <name>`) is still self-contained.

## Contributing

See [CLAUDE.md](CLAUDE.md) for the conventions these skills follow. Frontmatter
is validated in CI (`scripts/validate.sh`).
