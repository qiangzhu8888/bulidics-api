---
name: bulidics-water-leak-monitor
description: Implement, review, and troubleshoot BULIDICS water-leak monitoring, including waterLeak parsing, per-device state transitions, duplicate suppression, freshness checks, history behavior, and push-versus-polling risks. Use for BULIDICS leak sensors or payload fields ending in _waterLeak; do not use for temperature, humidity, gateway, or generic API questions.
---

# BULIDICS Water Leak Monitor

Apply the target sensor behavior without confusing sensor state, communication freshness, data validity, and API availability.

## Route the task

- Read [references/sensor-behavior.md](references/sensor-behavior.md) for payloads, observed transmission behavior, interface facts, and application defaults.
- Read [references/state-machine.md](references/state-machine.md) when implementing status calculation, history, persistence, UI labels, or tests.
- Use `$bulidics-api` for full HTTP push or REST protocol implementation and conformance review when it is installed.

## Required behavior

- Treat `deviceId` as a string and keep state separately for every device.
- Read the value from `${deviceId}_waterLeak`; accept only numeric `0` or `1` and reject booleans, missing keys, malformed JSON, and other values.
- Interpret `0` as dry/released and `1` as water leak.
- Repeated observations of the same sensor state do not create new sensor-history entries.
- Keep API errors and invalid data separate from the last known sensor state. Never convert a failed request into a dry state.
- When the latest value is `1`, use data age to decide whether communication needs checking. A stale `0` remains dry because this sensor sends no heartbeat after release.
- Do not claim that latest-value polling captures every transition. A one-time `0` can be missed if `0 -> 1` occurs between polls. Use push delivery or a confirmed event-history source when complete transition history is required.
- Do not put BULIDICS `Apikey`, Dify MCP URLs, or other credentials in skill files, generated source code, or logs.
- Use the official product spelling `BULIDICS` in prose and generated artifacts.

## Deterministic evaluation

When a JSON record is available, run `scripts/evaluate_water_leak.py`. Its result distinguishes initialization, append, and ignore history actions. Treat the script as a local state-evaluation check, not proof that the endpoint, device, gateway, or MCP server is reachable.

For live data obtained through Dify MCP or another tool, distinguish:

1. MCP/tool availability;
2. BULIDICS API success;
3. payload validity;
4. sensor state;
5. sensor communication freshness.

Report uncertainty instead of inferring dry, online, or recovered from missing evidence.
