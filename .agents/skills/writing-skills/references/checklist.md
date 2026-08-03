# Skill review checklist

Every item must pass before a skill is considered done.

## Metadata & discovery
- [ ] `name` is 1–64 chars, lowercase letters/numbers/single hyphens, matches the parent directory.
- [ ] `name` uses gerund form (or a documented acceptable alternative) and no reserved words (`anthropic`, `claude`).
- [ ] `description` is third person, non-empty, ≤1,024 chars.
- [ ] `description` states both what the skill does and when to use it, and includes negative triggers.
- [ ] `scripts/validate-metadata.py` passes for the final name and description.

## File structure & paths
- [ ] Only `references/`, `scripts/`, and `assets/` subfolders are used (whichever are needed).
- [ ] No `README.md`, `CHANGELOG.md`, or other human-facing docs inside the skill.
- [ ] All paths use forward slashes.
- [ ] Directory layout is flat and named descriptively (`form-validation.md`, not `doc2.md`).

## Logic & instructions
- [ ] SKILL.md body is under 500 lines.
- [ ] Steps are numbered, third-person imperative, with clear decision points.
- [ ] Degree of freedom matches task fragility.
- [ ] Terminology is consistent throughout.
- [ ] Examples are concrete, not abstract.
- [ ] No time-sensitive information (or isolated in an "Old patterns" section).

## Progressive disclosure
- [ ] Large schemas/guides live in `references/`, linked one level deep from SKILL.md.
- [ ] Reference files over 100 lines have a table of contents.

## Scripts & determinism
- [ ] Scripts are small single-purpose CLIs that take arguments.
- [ ] Instructions say whether to execute or read each script.
- [ ] Scripts handle errors with descriptive messages (no deferring to the agent).
- [ ] No unexplained magic constants; required packages are listed.

## Error handling
- [ ] SKILL.md has an error-handling section covering common failure states.
- [ ] Validation/verification steps exist for critical or destructive operations.
