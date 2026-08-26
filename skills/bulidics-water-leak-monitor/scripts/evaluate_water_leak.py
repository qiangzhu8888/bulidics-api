#!/usr/bin/env python3
"""Evaluate one BULIDICS water-leak observation without network access."""

import argparse
import json
import sys
import time
from pathlib import Path


class EvaluationError(ValueError):
    pass


def normalize_timestamp(value):
    if isinstance(value, bool):
        raise EvaluationError("latestDataTime must be a millisecond timestamp, not a boolean")
    if isinstance(value, str):
        if not value.strip().isdigit():
            raise EvaluationError("latestDataTime string must contain only digits")
        value = int(value.strip())
    elif isinstance(value, (int, float)):
        value = int(value)
    else:
        raise EvaluationError("latestDataTime must be a number or numeric string")
    if value < 0:
        raise EvaluationError("latestDataTime must not be negative")
    return value


def parse_raw_data(value):
    if isinstance(value, str):
        try:
            value = json.loads(value)
        except json.JSONDecodeError as exc:
            raise EvaluationError(f"latestRawData is not valid JSON: {exc}") from exc
    if not isinstance(value, dict):
        raise EvaluationError("latestRawData must decode to a JSON object")
    return value


def evaluate(record, previous=None, now_ms=None, threshold_seconds=90):
    if not isinstance(record, dict):
        raise EvaluationError("input must be a JSON object")

    device_id = record.get("deviceId")
    if not isinstance(device_id, str) or not device_id:
        raise EvaluationError("deviceId must be a non-empty string")

    raw = parse_raw_data(record.get("latestRawData"))
    key = f"{device_id}_waterLeak"
    if key not in raw:
        raise EvaluationError(f"latestRawData is missing '{key}'")

    value = raw[key]
    if isinstance(value, bool) or not isinstance(value, (int, float)) or value not in (0, 1):
        raise EvaluationError(f"'{key}' must be numeric 0 or 1")
    value = int(value)

    latest_ms = normalize_timestamp(record.get("latestDataTime"))
    now_ms = int(time.time() * 1000) if now_ms is None else normalize_timestamp(now_ms)
    threshold_ms = int(threshold_seconds * 1000)
    if threshold_ms <= 0:
        raise EvaluationError("threshold_seconds must be greater than zero")

    warnings = []
    age_ms = now_ms - latest_ms
    if age_ms < 0:
        warnings.append("latestDataTime is later than now_ms; age was clamped to zero")
        age_ms = 0

    sensor_status = "water_leak" if value == 1 else "dry"
    communication_status = "check_required" if value == 1 and age_ms > threshold_ms else "normal"

    if previous is None:
        history_action = "initialize"
        state_changed = False
    else:
        if isinstance(previous, bool) or previous not in (0, 1):
            raise EvaluationError("previous must be 0 or 1")
        state_changed = int(previous) != value
        history_action = "append" if state_changed else "ignore"

    return {
        "deviceId": device_id,
        "waterLeak": value,
        "sensorStatus": sensor_status,
        "communicationStatus": communication_status,
        "dataStatus": "valid",
        "latestDataTime": latest_ms,
        "ageMilliseconds": age_ms,
        "stateChanged": state_changed,
        "historyAction": history_action,
        "warnings": warnings,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("json_file", type=Path)
    parser.add_argument("--previous", type=int, choices=(0, 1))
    parser.add_argument("--now-ms", type=int)
    parser.add_argument("--threshold-seconds", type=float, default=90)
    args = parser.parse_args()

    try:
        record = json.loads(args.json_file.read_text(encoding="utf-8"))
        result = evaluate(
            record,
            previous=args.previous,
            now_ms=args.now_ms,
            threshold_seconds=args.threshold_seconds,
        )
    except (OSError, UnicodeError, json.JSONDecodeError, EvaluationError) as exc:
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False))
        return 1

    print(json.dumps({"ok": True, "result": result}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
