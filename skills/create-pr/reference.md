# create-pr — command reference

Placeholders: `<remote>`, `<target>`, `<branch>`, `<title>`. Write the body to a
scratchpad file first — `body=$(mktemp)` (remove when done).

## Recent merged

```bash
gh pr list --state merged -L 3 --json number,title,body
glab mr list --state merged -P 3   # then: glab mr view <iid>
```

## Existing PR/MR?

```bash
gh pr list --head <branch>
glab mr list --source-branch <branch>
```

## Create

```bash
gh pr create --base <target> --title "<title>" --body-file "$body"
```

`glab` has **no** `--description-file`; `--yes --no-editor` are required or it
hangs / opens an editor:

```bash
glab mr create --source-branch "$(git branch --show-current)" \
  --target-branch <target> --title "<title>" \
  --description "$(cat "$body")" --yes --no-editor
```

On request: `--draft` (both); `--remove-source-branch`, `--squash-before-merge`
(glab).

## Rewrite an existing description

```bash
gh pr edit <number> --body-file "$body"
glab mr update <iid> --description "$(cat "$body")"
```
