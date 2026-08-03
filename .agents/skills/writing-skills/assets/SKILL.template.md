---
name: [skill-name]
description: [Third-person, action-oriented capability description. State what the skill does and when to use it. Include positive triggers. End with negative triggers: "Do not use for [X]." Max 1,024 characters.]
---

# [Skill Title]

[One or two sentences of orienting context — what this skill accomplishes and the key idea an agent needs before following the steps.]

## Procedures

Copy this checklist and track progress:

```
Progress:
- [ ] Step 1: [Phase]
- [ ] Step 2: [Phase]
```

**Step 1: [Action phase]**
1. [Third-person imperative instruction, e.g., "Extract the query parameters from the request."]
2. [Instruction referencing an asset, e.g., "Read `assets/template.json` to structure the output."]

**Step 2: [Action phase]**
1. [Conditional/decision logic, e.g., "If source maps are required, run `scripts/build.sh`; otherwise skip to Step 3."]
2. [Just-in-time reference load, e.g., "Read `references/auth-flow.md` to map the error codes."]
3. Run `python3 scripts/[script-name].py` to [perform the deterministic action].

## Error handling

- If `scripts/[script-name].py` fails due to [specific edge case], [recovery step].
- If [condition B] occurs, read `references/[troubleshooting-file].md`.
