# Water-leak sensor behavior

## Current BULIDICS interface facts

- The measurement key is `${deviceId}_waterLeak`.
- `deviceId` is a string, including numeric-looking identifiers.
- The value is numeric: `0` means normal/dry and `1` means leak detected.
- HTTP push v1.0 can deliver duplicates because failed deliveries are retried and defines no deduplication key.
- REST device data uses `POST {Host}/common/device/queryDeviceData` with required `deviceId: String`, `startTime: Long`, and `endTime: Long` values.
- REST requires `Content-Type: application/json;charset=UTF-8` and `Apikey` headers.
- Keep the REST `Apikey` separate from HTTP push; push v1.0 does not define an API key.

Example REST result focus:

```json
{
  "deviceId": "F233624175AB",
  "latestRawData": "{\"F233624175AB_waterLeak\":1}",
  "latestDataTime": 1778569833000
}
```

Parsing:

```javascript
const raw = JSON.parse(latestRawData);
const waterLeak = raw[`${deviceId}_waterLeak`];
```

Validate the parsed value before using it.

## Target sensor observations

These are sensor-specific project observations, not universal BULIDICS API guarantees:

- During a leak, value `1` is sent repeatedly about every 8–10 seconds.
- On release, value `0` is sent once and then transmission stops.
- A later leak starts repeated value `1` transmissions again.
- The sensor has no heartbeat after release.

Confirm these observations against the deployed sensor model and firmware when behavior changes or a new model is added.

## Application defaults

These are configurable product requirements, not BULIDICS API limits:

| Setting | Default | Allowed or suggested range |
|---|---:|---:|
| Managed device count | up to 10 | project setting |
| Polling interval | 30 seconds | minimum 8 seconds, subject to platform approval |
| Stale-leak threshold | 90 seconds | 60–120 seconds |
| Visible sensor-history entries | 5 | up to 20 |

Do not represent the 8-second minimum as a documented BULIDICS rate limit. Confirm the permitted REST polling rate with the platform owner.

## Acquisition choice

Use push delivery when every leak/release transition must be captured. Latest-value polling is suitable for a current-status view only if stakeholders accept that a short-lived `0` can be missed. If the deployed REST endpoint returns an interval event list rather than only the latest record, confirm its ordering, pagination, overlap, and deduplication behavior before relying on it for complete history.
