# Water-leak state model

## Separate status dimensions

Do not collapse all failures into one status.

| Dimension | Values | Meaning |
|---|---|---|
| `sensorStatus` | `unknown`, `dry`, `water_leak` | Physical state inferred from valid data |
| `communicationStatus` | `normal`, `check_required`, `unknown` | Freshness judgment for the sensor stream |
| `dataStatus` | `valid`, `missing`, `invalid` | Payload and timestamp validity |
| `apiStatus` | `available`, `error`, `unknown` | BULIDICS API or MCP request result |

An API or MCP error does not prove that the sensor is dry, leaking, offline, or recovered. Preserve the last known state and report the request failure separately.

## Sensor transitions

Maintain one record per `deviceId`.

```text
unknown --0--> dry
unknown --1--> water_leak
dry ----1----> water_leak
water_leak --0--> dry
```

- Initial valid data initializes the current state.
- Append sensor history only for `dry -> water_leak` or `water_leak -> dry`.
- Ignore repeated `dry -> dry` and `water_leak -> water_leak` observations for sensor history.
- Communication-status changes may be stored in a separate operational audit log; do not present them as physical leak transitions.

## Freshness

With a default threshold of 90 seconds:

| Latest valid value | Data age | Sensor status | Communication status |
|---:|---:|---|---|
| `0` | any age | `dry` | `normal` |
| `1` | within threshold | `water_leak` | `normal` |
| `1` | over threshold | `water_leak` | `check_required` |

A stale `1` remains the last known leak state. Show a communication warning instead of silently changing it to dry.

## Persistence

For Dify workflows or stateless MCP calls, persist at least the following in a durable store keyed by `deviceId`:

```json
{
  "deviceId": "F233624175AB",
  "waterLeak": 1,
  "sensorStatus": "water_leak",
  "latestDataTime": 1778569833000,
  "updatedAt": 1778569835000
}
```

Use a database or equivalent durable store when state must survive independent workflow runs. Do not use one global previous-state variable for multiple devices.

## Polling limitation

If only the latest value is available, this sequence can be invisible to a 30-second poller:

```text
poll sees 1 -> sensor sends 0 once -> sensor sends 1 again -> poll sees 1
```

The identical poll results do not prove that no release occurred. Do not generate a complete transition history from latest snapshots unless the source guarantees that transitions cannot be missed.
