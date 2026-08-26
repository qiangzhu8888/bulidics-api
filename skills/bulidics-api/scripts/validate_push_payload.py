#!/usr/bin/env python3
"""Validate the structural rules of a BULIDICS HTTP push v1.0 payload."""

import argparse
import json
import re
import sys
from pathlib import Path

FIELD = re.compile(r"^(?P<device_id>[^_]+)_(?P<point>temp|hum|waterLeak)$")


def validate(payload):
    errors = []
    warnings = []
    if not isinstance(payload, dict):
        return ["The payload must be a flat JSON object."], warnings
    if not payload:
        warnings.append("The payload is empty.")
    for key, value in payload.items():
        if not isinstance(key, str):
            errors.append("Every JSON key must be a string.")
            continue
        match = FIELD.fullmatch(key)
        if not match:
            warnings.append(f"Unknown field '{key}'; current receivers should tolerate unknown fields.")
            continue
        point = match.group("point")
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            errors.append(f"'{key}' must contain a JSON number.")
        elif point == "waterLeak" and value not in (0, 1):
            errors.append(f"'{key}' must be 0 (normal) or 1 (leak detected).")
    return errors, warnings


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("json_file", type=Path)
    args = parser.parse_args()
    try:
        payload = json.loads(args.json_file.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}")
        return 2
    errors, warnings = validate(payload)
    for item in warnings:
        print(f"WARNING: {item}")
    for item in errors:
        print(f"ERROR: {item}")
    if errors:
        return 1
    print("OK: payload conforms to the structural BULIDICS HTTP push v1.0 rules.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
