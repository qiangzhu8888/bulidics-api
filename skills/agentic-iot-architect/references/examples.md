# Canonical Examples

## Example 1: Building leakage monitoring

### Input
A building uses batteryless leakage sensors, a BLE gateway, and an IoT platform. The goal is to reduce the time from leakage detection to field response.

### Agentic design

| Item | Example |
|---|---|
| Operational problem | An alert is detected, but staff still have to determine whether it is real, where it may originate, and what to do. |
| Current human decision | Judge urgency, probable source area, whether to inspect immediately, and whom to dispatch. |
| Perception | Convert sensor reactions into states such as first detection, persistent leakage, spread, recovery, or suspected false positive. |
| Context | Compare nearby sensors, reaction order, rainfall, prior incidents, zone/roof structure, and elapsed time. |
| Proposal | Suggest actions such as immediate inspection of Zone A, continue monitoring for 10 minutes, or escalate to facility management, each with rationale. |
| Human-in-the-loop | Require human approval before dispatch or physical equipment intervention where operational risk exists. |
| Actuation | Create work order/ticket, notify responsible personnel, show suspected zone, or trigger a predefined workflow. |
| Learning | Save actual leakage source, sensor reaction sequence, chosen action, response time, and whether the proposal was correct. |
| Recommended start | Level 1: action proposal. Progress toward Level 3 after enough validated Decision Logs exist. |

The Agentic output should sound like: "A/B/C sensor sequence and building context indicate that Zone A is the leading source candidate; inspect Zone A first. If no visible leakage is found within the defined window, inspect the next-ranked zone." It should not stop at "Sensor A reacted."

## Example 2: Heatstroke monitoring

### Input
Temperature/humidity or WBGT sensors are used at a school or childcare facility. External weather data may be available.

### Agentic design

- **Perception:** detect normal, caution, dangerous, rapidly worsening, or recovery states.
- **Context:** combine location, time, outdoor/indoor activity, recent trend, weather forecast, occupancy/activity plan, and local rules if supplied.
- **Proposal:** recommend hydration, activity reduction, indoor relocation, temporary stop, or monitoring continuation with rationale.
- **Human-in-the-loop:** staff approve activity changes; emergency or safety procedures remain governed by applicable policy.
- **Actuation:** notify staff, display prioritized locations, create an action checklist, or update an operational workflow.
- **Learning:** record action taken, later WBGT trend, symptoms/events if legitimately available, and whether the recommendation was useful.
- **Recommended start:** Level 1. Only automate low-risk notifications/workflow steps until operational criteria are validated.

## Example 3: Quick assessment request

### User request
"この既存IoTはAgentic IoTと言える？ センサー異常をダッシュボードに表示して、担当者へメールします。"

### Expected answer pattern

- Current level: Level 0
- Reason: It performs detection/display/notification, but the human must still interpret the situation and decide the next action.
- Missing elements: Context, concrete Proposal, explicit Human-in-the-loop design, Actuation integration, Learning/Decision Logs.
- Best next step: Add Level 1 proposals such as "inspect now / continue monitoring / stop equipment" with evidence and record the operator's choice and result.
