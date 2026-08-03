#!/usr/bin/env python3
"""Validate agent-skill frontmatter (name and description) against the conventions.

Usage:
    python3 validate-metadata.py --name <skill-name> [--description "<text>"]

Exits 0 and prints a success message when all checks pass; exits 1 and prints
every problem to stderr otherwise, so the calling agent can self-correct.
"""

import argparse
import re
import sys

# Names: 1-64 chars, lowercase alphanumerics separated by single hyphens.
# No leading/trailing/consecutive hyphens.
NAME_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NAME_MAX = 64
DESCRIPTION_MAX = 1024
RESERVED_WORDS = ("anthropic", "claude")
# Whole-word first/second-person pronouns that signal a non-third-person description.
PERSON_PATTERN = re.compile(r"\b(i|me|my|we|our|us|you|your)\b", re.IGNORECASE)


def validate_name(name):
    errors = []
    if not 1 <= len(name) <= NAME_MAX:
        errors.append(f"name must be 1-{NAME_MAX} characters (got {len(name)}).")
    if not NAME_PATTERN.match(name):
        errors.append(
            "name must use only lowercase letters, numbers, and single hyphens "
            "(no leading, trailing, or consecutive hyphens)."
        )
    for word in RESERVED_WORDS:
        if word in name.lower():
            errors.append(f"name must not contain the reserved word '{word}'.")
    return errors


def validate_description(description):
    errors = []
    if not description.strip():
        errors.append("description must not be empty.")
    if len(description) > DESCRIPTION_MAX:
        errors.append(
            f"description must be at most {DESCRIPTION_MAX} characters (got {len(description)})."
        )
    found = sorted({m.lower() for m in PERSON_PATTERN.findall(description)})
    if found:
        errors.append(
            "description should be written in the third person; found first/second-person "
            f"word(s): {', '.join(found)}. Prefer imperative style like 'Creates...' or 'Updates...'."
        )
    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate agent-skill metadata.")
    parser.add_argument("--name", required=True, help="Skill name (matches parent directory).")
    parser.add_argument("--description", default="", help="Skill description text.")
    args = parser.parse_args()

    errors = validate_name(args.name)
    if args.description:
        errors.extend(validate_description(args.description))

    if errors:
        print("Metadata validation failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        sys.exit(1)

    print("Metadata OK.")
    sys.exit(0)


if __name__ == "__main__":
    main()
