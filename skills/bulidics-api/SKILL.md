---
name: bulidics-api
description: Implement, review, and troubleshoot integrations against the BULIDICS HTTP push and REST API specifications, including payloads, retries, endpoint selection, code examples, and conformance checks. Use when a request mentions BULIDICS data integration, BULIDICS push delivery, or a BULIDICS REST endpoint; do not use for generic IoT or unrelated API work.
---

# BULIDICS API

Help users implement and verify BULIDICS integrations without mixing the two independent interfaces.

## Route the request

Identify the interface before giving implementation guidance:

- **HTTP push:** BULIDICS sends device data to a customer-managed endpoint. Read [references/push-api.md](references/push-api.md).
- **REST API:** A customer or third-party application calls a BULIDICS endpoint. Read [references/rest-api.md](references/rest-api.md).
- Read both references only for comparisons, architecture reviews, or end-to-end designs spanning both interfaces.

If the direction is unclear, infer it from the endpoint and actor names. Ask only when choosing the wrong interface would materially change the answer.

## Specification rules

- Treat the reference files as the current specification baseline. The contained interface versions are HTTP push v1.0 and REST API v1.0.2.
- Preserve endpoint paths, field names, JSON keys, types, status codes, timeouts, and retry values exactly in generated examples.
- Do not silently correct a source inconsistency. State it and ask the user which deployed behavior to target when implementation depends on it.
- Keep current requirements separate from future candidates.
- For HTTP push v1.0, do not add `API Key`, `timestamp`, `messageId`, or structured envelopes unless the user explicitly asks for a proposed future version.
- The REST `Apikey` header applies only to the REST interface. Never transfer it automatically to HTTP push.
- Explain that duplicate push delivery is possible and customer processing should be idempotent, but do not invent a deduplication key.
- Keep device IDs as strings, including numeric-looking IDs.
- Use the official product spelling `BULIDICS` in prose and generated artifacts. Keep protocol tokens, URLs, field names, and code identifiers exactly as specified.
- Answer in the user's language.

## Common tasks

For implementation requests, provide the smallest runnable example that covers parsing, response behavior, timeout/retry implications, and logging relevant to the chosen interface.

For reviews, report:

1. specification violations;
2. interoperability or data-loss risks;
3. optional improvements clearly labeled as non-current or future work.

For push payload checks, run `scripts/validate_push_payload.py` when a JSON file or payload is available. Treat its output as a structural check, not proof that the device is registered or the endpoint is reachable.

For REST endpoint selection, use the endpoint catalog and per-endpoint notes in the REST reference. Preserve the documented double slash in the send-command path when quoting the specification, and flag it for deployment confirmation.
