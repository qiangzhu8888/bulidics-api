# Agentic IoT Canonical Concept

## Definition

Agentic IoT is an IoT architecture that directly connects sensor data to decision flows and designs the optimal action according to the situation. Its role is not merely to record or visualize data, but to support or delegate repeatable operational judgment.

The central shift is:

**従来型IoT:** センサー → 保存 → 表示

**Agentic IoT:** 認識 → 文脈理解 → 行動提示 → 実行

The essential value changes from **見える化** to **動ける化**.

## Why it is needed

Many IoT systems already collect sufficient data but still require a person to interpret every alert, compare history, infer the cause, decide the next step, and coordinate action. This creates notification fatigue, delayed decisions, and dependence on individual experience. Agentic IoT treats the missing decision structure as the primary design problem.

## Six core elements

1. **Perception（認識）** — convert a raw value or event into a meaningful operational state.
2. **Context（文脈）** — interpret that state using time, location, equipment status, history, adjacent observations, external data, or other relevant conditions.
3. **Proposal（行動提案）** — present concrete next-action candidates and their rationale rather than only sending an alert.
4. **Human-in-the-loop** — retain human responsibility for approval, exceptions, safety, ethics, and high-impact decisions where appropriate.
5. **Actuation（実行）** — connect the selected action to physical control or a digital workflow such as a work order, ticket, message, or API call.
6. **Learning（学習）** — store decisions, actions, outcomes, and corrections so future proposals can improve.

## Autonomy evolution

- **Level 0 — 通知のみ:** detect and notify; humans perform the interpretation and decision.
- **Level 1 — 行動提案:** provide action options and reasons; humans select or approve.
- **Level 2 — 条件付き自動実行:** execute predefined actions when explicit conditions are met.
- **Level 3 — 半自律:** AI selects the preferred action and a human approves/executes it.
- **Level 4 — 自律＋報告:** the system executes and generates an after-action report.

The practical default is to begin at Level 1. This creates Decision Logs while keeping risk under human control. Those logs form a Decision Dataset that can support later automation.

## Architectural position

Agentic IoT is an upper-layer design concept and should remain open to multiple sensing, communication, platform, AI, and workflow technologies. ZETA, BLE, LoRaWAN, Wi-Fi, LTE, gateways, BUILDICS, BIM, weather data, LLMs, and external APIs can contribute to an implementation, but none of them alone defines Agentic IoT.

## Design principle

Always ask:

**「データを見たあと、人は何を判断しているのか？」**

Then redesign that judgment as:

**状態認識 → 文脈理解 → 判断候補 → 人間承認 → 実行 → 結果学習**

A system that only detects, visualizes, or notifies remains conventional IoT unless it meaningfully reduces or standardizes the next decision.
