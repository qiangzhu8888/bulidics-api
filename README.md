# BULIDICS Agent Skills

Portable skills for implementing and operating BULIDICS integrations in Codex, Cursor, Claude Code, and other Agent Skills-compatible tools.

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

## Quick install on Windows

Download or clone this repository, then double-click `install.cmd`. The installer:

- installs both skills for Codex and Cursor under `~/.agents/skills/`;
- installs both skills for Claude Code under `~/.claude/skills/`;
- backs up an existing skill before replacing it;
- records the installed version without storing any credentials.

Run `verify.cmd` to check the installation and `uninstall.cmd` to remove only the BULIDICS skills installed by this kit. Japanese instructions are in `README_インストール.txt`.

## Manual installation

For Codex and Cursor, copy the skill folders to:

```text
~/.agents/skills/bulidics-api/SKILL.md
~/.agents/skills/bulidics-water-leak-monitor/SKILL.md
```

For Claude Code, copy the same folders to:

```text
~/.claude/skills/bulidics-api/SKILL.md
~/.claude/skills/bulidics-water-leak-monitor/SKILL.md
```

In Codex, invoke them as `$bulidics-api` and `$bulidics-water-leak-monitor`. In Cursor and Claude Code, invoke them as `/bulidics-api` and `/bulidics-water-leak-monitor`. Automatic selection is also available for relevant requests.

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
