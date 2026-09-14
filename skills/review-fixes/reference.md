# review-fixes — command reference

Placeholders: `<PROJECT>` = URL-encoded project path (`/`→`%2F`); `<PATH>` = un-encoded; `<OWNER>/<REPO>` for GitHub; `<MR>` = MR/PR number; `<discussion_id>`, `<note_id>` (GitLab); `<PRRT-id>` = GitHub thread node id. Run via `!` if the sandbox blocks the CLI.

## Fetch

GitLab — comments:

```bash
glab mr view <MR> --comments --repo <PATH> > /tmp/mr<MR>.txt 2>&1
```

GitLab — discussion IDs (`--comments` omits them; required to resolve):

```bash
glab api "projects/<PROJECT>/merge_requests/<MR>/discussions" > /tmp/mr<MR>-discussions.json 2>&1
```

GitHub — review threads (yields the thread IDs needed to resolve):

```bash
gh api graphql -f query='
  query {
    repository(owner: "<OWNER>", name: "<REPO>") {
      pullRequest(number: <MR>) {
        reviewThreads(first: 100) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            path
            line
            comments(first: 3) { nodes { body author { login } } }
          }
        }
      }
    }
  }' > /tmp/pr<MR>.json 2>&1
```

If `hasNextPage`, page with `after: endCursor` and merge.

## Resolve / reply

GitLab — resolve:

```bash
glab api --method PUT "projects/<PROJECT>/merge_requests/<MR>/discussions/<discussion_id>/notes/<note_id>?resolved=true" > /dev/null 2>&1 && echo resolved
```

GitLab — reopen a thread resolved too early (same call, `resolved=false`):

```bash
glab api --method PUT "projects/<PROJECT>/merge_requests/<MR>/discussions/<discussion_id>/notes/<note_id>?resolved=false" > /dev/null 2>&1 && echo unresolved
```

GitLab — reply (declined nit):

```bash
glab api --method POST "projects/<PROJECT>/merge_requests/<MR>/discussions/<discussion_id>/notes" --field "body=<reply text>" > /dev/null 2>&1 && echo replied
```

GitHub — resolve:

```bash
gh api graphql -f threadId="<PRRT-id>" -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: { threadId: $threadId }) { thread { isResolved } }
  }' > /dev/null 2>&1 && echo resolved
```

GitHub — reply (declined nit). Omit `pullRequestReviewId` so the reply posts to
the thread, not into a pending draft review:

```bash
gh api graphql -f threadId="<PRRT-id>" -f body="<reply text>" -f query='
  mutation($threadId: ID!, $body: String!) {
    addPullRequestReviewThreadReply(input: { pullRequestReviewThreadId: $threadId, body: $body }) {
      comment { url }
    }
  }'
```

GitHub — reopen a thread resolved too early: `unresolveReviewThread`, same
`threadId` input.
