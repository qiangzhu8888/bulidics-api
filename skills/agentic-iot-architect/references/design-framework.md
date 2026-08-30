# Agentic IoT Design Framework

## 1. Start from the human decision

Ask or infer from the supplied material:

- What event starts the current workflow?
- What does the operator have to understand?
- What information do they check next?
- What choices do they make?
- Which choices are repetitive enough to standardize?
- Which actions are safe to automate, and which require approval?

The key problem is often not data shortage but the absence of an explicit decision structure.

## 2. Separate the six layers

| Layer | Design question | Typical result |
|---|---|---|
| Perception | What state does the raw data represent? | normal / rising / abnormal / persistent / recovered |
| Context | What makes the state meaningful? | time, operating state, history, adjacent sensors, weather, BIM, schedules |
| Proposal | What should happen next? | inspect, continue monitoring, stop equipment, restart, dispatch staff |
| Human-in-the-loop | Who remains responsible? | approve, reject, override, handle exception |
| Actuation | How does the decision become action? | control command, ticket, Teams message, work order, API request |
| Learning | What should be retained? | evidence, recommendation, decision, result, correctness, response time |

## 3. Decision Log minimum schema

Store at least:

- event_id
- timestamp
- asset/location
- sensor evidence
- recognized state
- contextual evidence
- proposal(s)
- proposal rationale
- confidence or uncertainty if available
- human decision/approval
- executed action
- action timestamp
- outcome
- later evaluation / correction

The objective is to create a Decision Dataset that supports future improvement and higher autonomy.

## 4. Architecture thinking

Use an open layered model:

**Physical world / sensors**
→ **communication / gateway**
→ **IoT platform / data layer**
→ **Perception + Context**
→ **Decision / Proposal agent**
→ **Human approval when required**
→ **Actuation / workflow / control**
→ **Decision Log / Learning**

A product such as BUILDICS can occupy the platform, context, application, workflow, or actuation boundary depending on the actual implementation. ZETA, BLE, LoRaWAN, Wi-Fi, LTE, and similar technologies belong to sensing/communication layers, not to the Agentic definition itself.

## 5. Implementation default

Prefer this staged path unless the case strongly suggests otherwise:

**Phase 1: Level 1**
- Recognize state
- Add context
- Propose actions with rationale
- Human chooses
- Record Decision Logs

**Phase 2: Level 2/3**
- Automate safe and repeatable decisions
- Define approval thresholds and exceptions
- Add rollback/audit paths

**Phase 3: Level 4**
- Autonomous action for sufficiently validated scenarios
- Automatic after-action reporting
- Human exception management and periodic review

## 6. Useful final table

| Item | Design |
|---|---|
| Operational problem | ... |
| Current human decision | ... |
| Perception | ... |
| Context | ... |
| Proposal | ... |
| Human-in-the-loop | ... |
| Actuation | ... |
| Learning | ... |
| Current level | ... |
| Target level | ... |
| First implementation | ... |
