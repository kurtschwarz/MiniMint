# Authoring patterns

## Contents
- Degrees of freedom
- Progressive disclosure
- Router / subskill composition
- Templates and examples
- Feedback loops
- Anti-patterns

## Degrees of freedom

Match instruction specificity to how fragile the task is.

- **High freedom** (prose steps): multiple valid approaches, context-dependent decisions. Example: "Analyze the code structure, check for edge cases, suggest improvements."
- **Medium freedom** (pseudocode / parameterized scripts): a preferred pattern with acceptable variation.
- **Low freedom** (exact commands): fragile, order-sensitive, or consistency-critical operations. Example: "Run exactly this: `python3 scripts/migrate.py --verify --backup`. Do not modify the command."

Analogy: a narrow bridge with cliffs needs exact guardrails (low freedom); an open field needs only general direction (high freedom).

## Progressive disclosure

- Keep `SKILL.md` a lean table of contents that points to detail as needed; body under 500 lines.
- Move schemas, deep guides, and troubleshooting into `references/*.md`.
- Keep references **one level deep** — link every reference directly from SKILL.md. Avoid SKILL → a.md → b.md chains, which cause partial reads.
- Bundle large resources freely; files consume no context until read.

## Router / subskill composition

For a skill spanning several domains, keep SKILL.md as a router that points to per-domain reference files, so only the relevant domain loads:

```
data-skill/
├── SKILL.md            # overview + navigation
└── references/
    ├── finance.md
    ├── sales.md
    └── product.md
```

## Templates and examples

- Provide output templates in `assets/` and reference them, rather than inlining large blocks.
- For quality that depends on style, include concrete input/output example pairs — they convey the target better than description.
- State strictness explicitly: "ALWAYS use this exact template" vs. "a sensible default; adapt as needed."

## Feedback loops

For quality-critical tasks, build a validator → fix → repeat loop and instruct the agent to proceed only once validation passes. The validator can be a script or a reference checklist the agent compares against.

## Anti-patterns

- Windows-style backslash paths — always use forward slashes.
- Offering many tool options — give one default plus an escape hatch.
- Time-sensitive phrasing ("before August 2025…") — use a dated "Old patterns" section instead.
- Inconsistent terminology — pick one term per concept.
- `README.md` / `CHANGELOG.md` inside the skill — the agent reads SKILL.md.
- Deferring errors in scripts to the agent — handle them in the script with clear messages.
