# BULIDICS API Codex Skill

Codex skill for implementing, reviewing, and troubleshooting integrations against the BULIDICS HTTP push v1.0 and RESTful API v1.0.2 specifications.

## Included guidance

- Selection between HTTP push and REST API interfaces
- Push payload structure, success criteria, timeouts, and retries
- REST authentication, endpoint catalog, parameters, and source cautions
- Clear separation of current requirements from future candidates
- Structural validation of HTTP push JSON payloads

## Install

Place this repository at:

```text
~/.codex/skills/bulidics-api
```

Then invoke the skill as `$bulidics-api`, or allow Codex to select it automatically for relevant BULIDICS integration requests.

## Validation

```bash
python scripts/validate_push_payload.py payload.json
```

The validator checks payload structure only. It does not confirm device registration or endpoint connectivity.
