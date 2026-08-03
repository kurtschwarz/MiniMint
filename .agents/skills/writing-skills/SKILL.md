---
name: writing-skills
description: Creates and refines agent skills — SKILL.md files, reference docs, scripts, and assets — following naming, progressive-disclosure, and metadata conventions. Use when authoring a new skill, restructuring an existing one, fixing skill discovery/frontmatter, or reviewing a skill against best practices. Do not use for writing application feature code, general documentation, or README files.
---

# Writing Skills

Author skills that another agent can discover from metadata alone and execute without guessing. Keep the loaded context lean: metadata is always in the system prompt, `SKILL.md` loads on trigger, and everything else loads only when a step points to it.

## Skill anatomy

```
<skill-name>/
├── SKILL.md              # Metadata + high-level procedures (loaded on trigger, <500 lines)
├── references/           # Schemas, cheatsheets, deep guides (loaded just-in-time)
├── scripts/              # Deterministic CLIs for fragile/repetitive steps (executed, not loaded)
└── assets/               # Templates and static output files
```

Create only the directories a skill actually needs. Do not add `README.md`, `CHANGELOG.md`, or other human-facing docs — the agent reads `SKILL.md`, not a README.

## Authoring workflow

Copy this checklist and track progress:

```
Skill Progress:
- [ ] Step 1: Name and scope the skill
- [ ] Step 2: Write and validate frontmatter
- [ ] Step 3: Draft SKILL.md procedures
- [ ] Step 4: Extract references, scripts, and assets
- [ ] Step 5: Review against references/checklist.md
```

**Step 1: Name and scope the skill**
1. Choose a **gerund-form** name (verb + `-ing`): `writing-skills`, `processing-pdfs`, `analyzing-spreadsheets`. See [references/naming.md](references/naming.md) for the full rules and alternatives.
2. Use lowercase letters, numbers, and single hyphens only; the name must match the parent directory exactly and must not contain the reserved words `anthropic` or `claude`.
3. Define one clear capability. If the skill covers several unrelated domains, split it or use a router pattern (see [references/patterns.md](references/patterns.md)).

**Step 2: Write and validate frontmatter**
1. Copy [assets/SKILL.template.md](assets/SKILL.template.md) as the starting point.
2. Write the `description` in **third person**, stating both what the skill does and when to use it, plus negative triggers ("Do not use for…"). Max 1,024 characters.
3. Validate before continuing: `python3 scripts/validate-metadata.py --name "<name>" --description "<description>"`. Fix every reported error before moving on.

**Step 3: Draft SKILL.md procedures**
1. Write instructions as numbered, third-person imperative steps ("Extract the fields…", "Run the validator…").
2. Match the degree of freedom to the task: high freedom (prose) when many approaches work; low freedom (exact commands, "run exactly this") when the operation is fragile. See [references/patterns.md](references/patterns.md).
3. Assume the reading agent is already capable — add only context it lacks. Keep the body under 500 lines.
4. Use consistent terminology throughout; pick one term per concept and reuse it.

**Step 4: Extract references, scripts, and assets**
1. Move large schemas, deep explanations, and troubleshooting into `references/*.md`, linked **one level deep** from SKILL.md (never reference-to-reference chains).
2. Give reference files longer than 100 lines a table of contents at the top.
3. Put fragile or repetitive logic in `scripts/` as small single-purpose CLIs that take arguments and emit descriptive errors so the agent can self-correct. State whether the agent should **execute** ("Run `scripts/x.py`") or **read** ("See `scripts/x.py` for the algorithm") each script.
4. Put templates and static output in `assets/`. Reference them from steps rather than inlining large blocks.
5. Always use forward slashes in paths, including on Windows.

**Step 5: Review against the checklist**
1. Read [references/checklist.md](references/checklist.md) and confirm every item passes.
2. Re-run `scripts/validate-metadata.py` if the name or description changed.
3. Sanity-check discovery: the description alone should tell an agent whether to trigger the skill.

## Error handling

- If `scripts/validate-metadata.py` reports a name-format error, fix the name and rename the parent directory to match — the two must be identical.
- If the description trips the third-person check, rewrite first/second-person phrasing ("I can help…", "You can…") as third-person imperative ("Generates…", "Analyzes…").
- If SKILL.md exceeds 500 lines, move detail into `references/` per Step 4 rather than trimming necessary steps.
