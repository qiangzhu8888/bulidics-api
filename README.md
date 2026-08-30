# BULIDICS Agent Skills

Portable skills for implementing and operating BULIDICS integrations in Codex, Cursor, and other Agent Skills-compatible tools.

## Included skills

| Skill | Purpose |
|---|---|
| `bulidics-api` | Implement and review BULIDICS HTTP push v1.0 and RESTful API v1.0.2 integrations. |
| `bulidics-water-leak-monitor` | Evaluate water-leak sensor state, transition history, duplicate delivery, communication freshness, and polling data-loss risk. |

Each folder under `skills/` is an independent skill with its own `SKILL.md`, references, and deterministic validation scripts.

## Repository layout

```text
skills/
├── bulidics-api/
└── bulidics-water-leak-monitor/
```

## Install for Codex

Copy the desired skill folders into `~/.codex/skills/` so that each `SKILL.md` is located directly under its skill directory:

```text
~/.codex/skills/bulidics-api/SKILL.md
~/.codex/skills/bulidics-water-leak-monitor/SKILL.md
```

Invoke them as `$bulidics-api` and `$bulidics-water-leak-monitor`. Automatic selection is also enabled for relevant requests.

## Install for Cursor

Place the desired skill folders under `~/.cursor/skills/` for global use or `.cursor/skills/` for one project. Cursor also discovers skills in Codex-compatible `~/.codex/skills/` locations.

Invoke them from Agent chat as `/bulidics-api` and `/bulidics-water-leak-monitor`.

## Validation

API push payload:

```bash
python skills/bulidics-api/scripts/validate_push_payload.py payload.json
```

Water-leak observation:

```bash
python skills/bulidics-water-leak-monitor/scripts/evaluate_water_leak.py record.json --previous 0
```

The scripts validate local data structure and state rules only. They do not prove that a device, BULIDICS endpoint, Dify workflow, or MCP server is reachable.

## Security

Do not commit BULIDICS `Apikey` values, Dify MCP URLs, or customer endpoint credentials. Keep live access and secrets in the API or MCP runtime, not in skill files.
