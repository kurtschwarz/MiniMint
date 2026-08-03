---
name: creating-commits
description: Writes terse Conventional Commits messages and creates signed commits with a Co-Authored-By trailer naming the current Claude model. Use when committing staged changes, writing or amending a commit message, or when asked to commit. Do not use for pull-request descriptions, changelogs, or release notes.
---

# Creating Commits

Write commit messages that prioritize reasoning over description: a Conventional Commits subject, a body only when the diff is not self-explanatory. Every commit this skill creates is cryptographically signed and ends with a `Co-Authored-By` trailer naming the current Claude model.

## Workflow

Copy this checklist and track progress:

```
Commit Progress:
- [ ] Step 1: Inspect the staged changes
- [ ] Step 2: Compose the message
- [ ] Step 3: Append the Co-Authored-By trailer
- [ ] Step 4: Create the signed commit
- [ ] Step 5: Verify the signature and trailer
```

**Step 1: Inspect the staged changes**
1. Run `git diff --cached --stat` then `git diff --cached` to see exactly what is staged.
2. If nothing is staged, stop and report it — do not run `git add -A` unless the user asked to stage everything.
3. If the staged changes mix unrelated concerns, tell the user and suggest splitting into separate commits.

**Step 2: Compose the message**
1. Follow the format in [references/commit-format.md](references/commit-format.md): `<type>(<scope>): <imperative subject>`, subject ≤50 chars (hard cap 72), no trailing period.
2. Add a body only for non-obvious reasoning, breaking changes, migration notes, or issue references. Wrap at 72 chars; use `-` bullets.
3. Strip noise: no "This commit…", no first-person voice, no restating file names the diff already shows.

**Step 3: Append the Co-Authored-By trailer**
1. Leave one blank line after the subject or body, then add exactly:
   `Co-Authored-By: Claude (<MODEL>) <noreply@anthropic.com>`
2. Replace `<MODEL>` with the current model's short name (for example `Opus 4.8`, `Sonnet 5`, `Haiku 4.5`) — use the model actually running this session.
3. See [assets/commit-message.template.txt](assets/commit-message.template.txt) for the full shape.

**Step 4: Create the signed commit**
1. All commits MUST be signed. Commit with `-S`:
   ```bash
   git commit -S -m "<subject>" -m "<body>" -m "Co-Authored-By: Claude (<MODEL>) <noreply@anthropic.com>"
   ```
   (Each `-m` becomes a paragraph; the trailer goes in its own `-m`.) For a single-line commit, use one `-m` for the subject and one for the trailer.
2. If signing fails because no key is configured, follow [references/commit-format.md](references/commit-format.md) → "Signing setup"; do not fall back to an unsigned commit.
3. Never push, amend published history, or add `--no-verify` unless the user explicitly asks.

**Step 5: Verify the signature and trailer**
1. Run `git log -1 --show-signature` and confirm the signature is present and the `Co-Authored-By` trailer names the current model.
2. If the signature is missing, the commit is not acceptable — recreate it once signing is fixed.

## Error handling

- If `git commit -S` reports `gpg failed to sign the data` or `no signing key`, signing is not configured — read [references/commit-format.md](references/commit-format.md) → "Signing setup" and surface the fix to the user rather than committing unsigned.
- If the subject cannot fit 50 characters without losing meaning, use up to 72 and move detail into the body.
- If pre-commit hooks reject the commit, report the hook output and fix the underlying issue — do not bypass with `--no-verify`.
