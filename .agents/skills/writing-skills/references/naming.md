# Naming conventions

## Contents
- Gerund form (preferred)
- Format rules
- Acceptable alternatives
- Names to avoid

## Gerund form (preferred)

Name skills in **gerund form** (verb + `-ing`) so the name reads as the activity the skill provides:

- `writing-skills`
- `processing-pdfs`
- `analyzing-spreadsheets`
- `managing-databases`
- `testing-code`
- `writing-documentation`

## Format rules

- 1–64 characters.
- Lowercase letters, numbers, and single hyphens only (`^[a-z0-9]+(-[a-z0-9]+)*$`) — no leading, trailing, or consecutive hyphens.
- Must match the parent directory name exactly.
- Must not contain XML tags.
- Must not contain the reserved words `anthropic` or `claude`.

## Acceptable alternatives

When gerund form reads awkwardly, these are acceptable:

- Noun phrases: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

Whichever pattern is chosen, apply it consistently across a skill collection.

## Names to avoid

- Vague: `helper`, `utils`, `tools`
- Overly generic: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`
- Mixing patterns within one collection.
