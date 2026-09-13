# Skills repo conventions

This repo ships agent skills installable via `npx skills add`.

## Structure

One directory per skill under `skills/<name>/`, each with a `SKILL.md`. A skill
may carry helper files (`reference.md`, `scripts/`, …) — keep them inside the
skill's directory so a partial install (`-s <name>`) stays self-contained.

## Frontmatter

Every `SKILL.md` starts with YAML:

- `name` — kebab-case, matches the directory name.
- `description` — one paragraph: what it does, when to use it, trigger phrases.
  This is what the agent sees in its skill list, so make the trigger explicit.
- `license` — `MIT`.

## Style

- Write for the agent, not a human reader: imperative, no hedging, concrete
  commands over prose. See the skills themselves for the tone.
- Keep skills short. A skill that needs to be longer than ~200 lines is really
  two skills.
- No project-specific hardcoding: detect host, project path, and conventions
  from the environment at runtime.
