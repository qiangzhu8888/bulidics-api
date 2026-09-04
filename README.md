# BULIDICS Agent Skills

Portable skills for implementing and operating BULIDICS integrations and Agentic IoT design in Codex, Cursor, and other Agent Skills-compatible tools.

## Included skills

| Skill | Purpose |
|---|---|
| `agentic-iot-architect` | Design, diagnose, and transform IoT systems using Agentic IoT concepts, including ZiFiSense ZETA Server API & MQTT integrations. |
| `bulidics-api` | Implement and review BULIDICS HTTP push v1.0 and RESTful API v1.0.2 integrations. |
| `bulidics-water-leak-monitor` | Evaluate water-leak sensor state, transition history, duplicate delivery, communication freshness, and polling data-loss risk. |
| `agentic-iot-architect` | Design, diagnose, and transform IoT systems from monitoring/visualization into context-aware decision and action flows using the Agentic IoT framework. |

Each folder under `skills/` is an independent skill with its own `SKILL.md`, references, and optional validation scripts.

## Repository layout

```text
skills/
├── agentic-iot-architect/
├── bulidics-api/
├── bulidics-water-leak-monitor/
└── agentic-iot-architect/
```

## Install for Codex

Copy the desired skill folders into `~/.codex/skills/` so that each `SKILL.md` is located directly under its skill directory:

```text
~/.codex/skills/bulidics-api/SKILL.md
~/.codex/skills/bulidics-water-leak-monitor/SKILL.md
~/.codex/skills/agentic-iot-architect/SKILL.md
```

Invoke them as `$bulidics-api`, `$bulidics-water-leak-monitor`, and `$agentic-iot-architect`. Automatic selection is also enabled for relevant requests.

## Install for Cursor

Place the desired skill folders under `~/.cursor/skills/` for global use or `.cursor/skills/` for one project. Cursor also discovers skills in Codex-compatible `~/.codex/skills/` locations.

Invoke them from Agent chat as `/bulidics-api`, `/bulidics-water-leak-monitor`, and `/agentic-iot-architect`.

## Agentic IoT Architect examples

Typical requests include:

- `この漏水監視システムをAgentic IoT化して`
- `この既存IoTはAgentic IoTのLevelいくつ？`
- `工場設備保全をAgentic IoTで企画して`
- `BUILDICSを使ったAgentic IoT構成を設計して`

The skill starts from the human decision that follows sensor data, then designs Perception, Context, Proposal, Human-in-the-loop, Actuation, Learning, Decision Logs, and a practical Level 0-4 evolution path.

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

Do not commit BULIDICS `Apikey` values, Dify MCP URLs, customer endpoint credentials, or other secrets. Keep live access and secrets in the API or MCP runtime, not in skill files.
