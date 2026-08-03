# Commit format

## Contents
- Subject line
- Types
- Body
- Trailers
- Signing setup
- Examples

## Subject line

- Pattern: `<type>(<scope>): <imperative summary>`. Scope is optional.
- Imperative mood: "add", "fix", "remove" — not "added" or "adds".
- Maximum 50 characters; hard cap 72.
- Lowercase after the colon; no trailing period.

## Types

| Type       | Use for                                             |
|------------|-----------------------------------------------------|
| `feat`     | A new feature                                       |
| `fix`      | A bug fix                                            |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf`     | Performance improvement                             |
| `docs`     | Documentation only                                  |
| `test`     | Adding or correcting tests                          |
| `build`    | Build system or dependencies                        |
| `ci`       | CI configuration and scripts                        |
| `chore`    | Maintenance that fits no other type                 |
| `style`    | Formatting only, no behavior change                 |
| `revert`   | Reverting a previous commit                         |

## Body

Include a body only when it earns its place: non-obvious reasoning, breaking
changes, migration notes, or issue references.

- Separate from the subject with one blank line.
- Wrap at 72 characters.
- Use `-` for bullets, not `*`.
- Explain **why**, not **what** — the diff already shows what changed.
- Mark breaking changes with a `BREAKING CHANGE:` paragraph.

## Trailers

- Reference issues at the end: `Closes #42`, `Refs #17`.
- Every commit ends with the co-author trailer, on its own line after a blank line:
  `Co-Authored-By: Claude (<MODEL>) <noreply@anthropic.com>`
  where `<MODEL>` is the current model's short name (e.g. `Opus 4.8`).

## Signing setup

Commits must be cryptographically signed. If `git commit -S` fails:

- Verify a signing key exists and is selected:
  `git config --get user.signingkey`
- For GPG, list keys with `gpg --list-secret-keys --keyid-format=long`.
- For SSH signing, ensure `git config gpg.format ssh` and `user.signingkey`
  points to the public key path.
- To sign every commit without `-S`, enable `git config commit.gpgsign true`.

Surface the specific missing piece to the user; do not commit unsigned.

## Examples

Self-explanatory change — subject only:

```
fix(actions): scope query to the current family

Co-Authored-By: Claude (Opus 4.8) <noreply@anthropic.com>
```

Non-obvious reasoning — subject plus body:

```
perf(ledger): cache balance instead of summing entries

Recomputing per render walked the full ledger and dominated scroll
frame time on large families. Cache on write; entries are append-only
so the cached value cannot drift.

Closes #128

Co-Authored-By: Claude (Opus 4.8) <noreply@anthropic.com>
```
