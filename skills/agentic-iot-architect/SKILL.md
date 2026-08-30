---
name: agentic-iot-architect
description: "Design, diagnose, and transform IoT systems using the Agentic IoT concept: connect sensor data directly to decision flows and concrete actions through Perception, Context, Proposal, Human-in-the-loop, Actuation, and Learning. Use when the user asks to make an IoT system Agentic, evaluate an existing IoT architecture, plan a new sensor/AI solution, define autonomy Level 0-4, design decision/action flows, or turn monitoring/alerts into decision automation. Applicable to buildings, factories, leakage, heatstroke, energy, maintenance, logistics, exhibitions, and other IoT domains."
---

# Agentic IoT Architect

## Purpose

Design IoT as a system for decision-making, not merely data collection or visualization. Convert the user's operational problem into a repeatable flow from sensing to context-aware action, while preserving human responsibility where appropriate.

Before designing, read `references/source-concept.md` for the canonical Agentic IoT definitions and `references/design-framework.md` for the working method and output structure.

## Core Principle

Treat Agentic IoT as:

> センサーデータを意思決定フローに直接接続し、状況に応じた最適な行動までを設計するIoTアーキテクチャ

Do not stop at dashboards, thresholds, alerts, or notifications. Always identify what decision a human currently makes after receiving the data, then redesign that decision flow.

## Required Design Sequence

For every Agentic IoT design or assessment, proceed in this order:

1. **Operational problem** — define the field problem and why the current process is slow, inconsistent, labor-intensive, or dependent on experience.
2. **Current human decision** — state what a person currently has to infer, decide, approve, or execute after data is received.
3. **Perception** — convert raw sensor values/events into meaningful states.
4. **Context** — add time, location, equipment state, history, environmental information, external data, structure, or operational conditions needed to interpret the state.
5. **Proposal** — produce concrete next-action candidates with reasons. Prefer multiple action candidates when there is real uncertainty.
6. **Human-in-the-loop** — state what can be automated and what requires human confirmation, approval, or exception handling.
7. **Actuation** — connect the selected decision to a physical or digital action such as equipment control, notification, ticket creation, work order, workflow update, or API call.
8. **Learning** — define what outcome, decision, approval, and action logs should be stored so proposals improve over time.
9. **Autonomy level** — classify the current and target design using Level 0-4.
10. **Implementation path** — recommend the smallest practical first deployment, normally Level 1 unless the use case clearly supports more automation.

## Autonomy Levels

Use exactly these levels unless the user asks for another scale:

- **Level 0: 通知のみ** — abnormality is reported; judgment is left to people.
- **Level 1: 行動提案** — present multiple actions and reasons. Treat this as the default strategic starting point.
- **Level 2: 条件付き自動実行** — execute predefined actions under defined rules.
- **Level 3: 半自律** — AI selects the optimal action and a human approves/executes it.
- **Level 4: 自律＋報告** — the system executes and produces an after-action report.

When recommending Level 2-4, explicitly identify safety, authority, rollback, audit, and exception requirements.

## Design Rules

- Start from the decision problem, not from available sensors.
- Distinguish **raw value**, **recognized state**, **contextual interpretation**, **decision**, and **action**.
- Avoid calling a notification an Agentic action. A notification is usually Level 0 unless it includes a concrete decision proposal.
- Preserve uncertainty. If evidence is insufficient, say what is unknown and propose verification actions instead of pretending certainty.
- Make Human-in-the-loop explicit where physical safety, operational risk, money, access control, or external impact exists.
- Treat Decision Logs as a first-class data asset: situation, evidence, proposal, human decision, executed action, outcome, and later evaluation.
- Prefer open architecture. Agentic IoT is the upper-layer design concept; do not require a specific communication method or platform unless the user specifies one.
- When BUILDICS, ZETA, BLE, LoRaWAN, Wi-Fi, APIs, gateways, BIM, weather data, or other systems are supplied, position them according to their actual role rather than forcing them into the architecture.
- Do not invent product capabilities, deployment results, customer deployments, costs, performance, or integrations not supported by user-provided sources.

## Output Modes

Choose the smallest useful mode based on the user's request.

### Quick Diagnosis

Use when the user asks whether a system is Agentic or what level it is. Return:

- Current architecture summary
- Current autonomy level
- Missing Agentic elements
- Highest-value improvement
- Recommended next level

### Full Agentic IoT Proposal

Use when the user asks to plan or transform a system. Return:

1. Objective and current problem
2. Current human decision flow
3. Agentic IoT architecture table
4. Perception / Context / Proposal / Human-in-the-loop / Actuation / Learning
5. Current and target autonomy level
6. System flow or component architecture
7. Decision Log design
8. Phased implementation plan
9. Expected operational value
10. Main risks and safeguards

### Concept Explanation

Use when the user asks what Agentic IoT means. Explain the difference between:

`センサー → 保存 → 表示`

and

`認識 → 文脈理解 → 行動提示 → 実行`

Emphasize the shift from **見える化** to **動ける化**.

## Quality Check

Before finalizing, confirm internally that:

- The output names the human decision being reduced or standardized.
- All six core elements are either designed or explicitly marked unnecessary.
- At least one concrete action follows the decision.
- The autonomy level is justified.
- The first deployment is realistic and not over-automated.
- Missing evidence is labeled rather than guessed.

## Examples

See `references/examples.md` for canonical examples including leakage detection and heatstroke monitoring.
