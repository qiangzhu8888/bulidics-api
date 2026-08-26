# BULIDICS RESTful API v1.0.2

## Scope and common rules

Customer systems or third-party applications call BULIDICS to query, register, or operate asset, space, alarm, file, building, gateway, and device data. This interface is independent from HTTP push.

Common request headers:

| Header | Value | Required |
|---|---|---|
| `Content-Type` | `application/json;charset=UTF-8` | yes |
| `Apikey` | String supplied by the platform | yes |

Replace `{Host}` with the host name for the target environment. Requests use `POST` with `raw/json` bodies.

Common response behavior:

- `code` or `Code` = `200`: success
- `500`: server internal error
- `20001`: query error; inspect `msg` or `Msg`

## Endpoint catalog

| No. | Endpoint | Purpose |
|---:|---|---|
| 1 | `{Host}/common/queryAssetInfo` | Query asset data |
| 2 | `{Host}/common/querySpaceInfo` | Query space data |
| 3 | `{Host}/common/queryAssetInfoByClass` | Query assets by category keywords |
| 4 | `{Host}/common/queryAlarmDevice` | Query abnormal-device information and data |
| 5 | `{Host}/common/queryClass` | Query asset classifications |
| 6 | `{Host}/common/problem-reports/summaries` | Query problem reports |
| 7 | `{Host}/common/getS3FileUrl` | Resolve file keys |
| 8 | `{Host}/common/addBuilding` | Add building information |
| 9 | `{Host}/common/queryBuilding` | Query building information |
| 10 | `{Host}/common/queryKanriRoidMaintenanceRecord` | Query Kanri Roid maintenance history |
| 11 | `{Host}/common/queryCancelAlarmDevice` | Query alarm-clear history |
| 12 | `{Host}/common/apgateway/status` | Get AP gateway status list |
| 13 | `{Host}/common/device/queryDeviceData` | Query device data |
| 14 | `{Host}//common/device/sendCommand` | Send a device command |

Source cautions:

- The original API list's No. 5 URL differed from its detailed section. This catalog follows the detailed section: `/common/queryClass`.
- The original API list omitted No. 14; it is included from the detailed section.
- Section 4.10 documents both `{Host}/datacenter/v1/sgs/query` and `{Host}/common/queryKanriRoidMaintenanceRecord`. Confirm the deployed target before implementation.
- The send-command path contains a documented double slash after `{Host}`. Quote it faithfully, but confirm whether the deployed gateway normalizes it.

## Request parameters and response focus

### 1. Asset data

Required request: `udfBuildingId: String`, `symbol: String`.

Response `Data` is an array with asset fields such as `assetName`, `imageInfo`, `pdfList`, `udfAssetId`, `spaceName`, classification fields, manufacturer/model/specifications, manual/drawing URLs, and device information. Device fields include `deviceId`, `deviceSn`, `latestRawData`, `latestDataTime`, `typeUnit`, and `dataValue`.

### 2. Space data

Required request: `udfBuildingId: String`, `udfSpaceId: String`.

Response includes space, tenant, image/PDF, asset, and device information.

### 3. Assets by classification

- `udfBuildingId: String` — required
- `classBig: String` — optional
- `classMedium: String` — optional
- `classSmall: String` — optional

### 4. Abnormal devices

Required request: `udfBuildingId: String`.

Response fields include `floorName`, `spaceName`, `deviceId`, `deviceName`, latest device data, asset symbol, alert status/title/level/type, classification, and device type.

### 5. Asset classifications

Required request: `udfBuildingId: String`.

Response returns building name and arrays for large, medium, and small classifications with names and IDs.

### 6. Problem reports

- `udfBuildingId: String` — required
- `assetSymbol: String` — required
- `startDate: String` — optional; example `2023-09-01`
- `endDate: String` — optional; example `2024-09-01`

Response includes problem-report and maintenance-history fields such as `problemReportId`, `occuredAt`, `title`, `memo`, `repairData`, `repairOccuredAt`, `repairTitle`, and `repairMemo`.

### 7. File keys

Required request: `keys: Array(String)`. Response items contain `key` and S3 `url`.

### 8. Add building

Required request fields include `udfBuildingId`, `buildingName`, and `buildingBucket`. `floorInfoList` contains `revitName`, `apiName`, `offsetUpper`, and `offsetLower`.

### 9. Query building

Required request: `udfBuildingId: String`. Response includes building and floor information matching the add-building model.

### 10. Kanri Roid maintenance history

- `deviceId: String` — required
- `date: String` — required; format `yyyy-mm-dd`
- `targetIds: Array[int]` — optional
- `datatype: int` — optional; `0` normal data, `1` alert data, omitted means all data

Response device entries include `deviceName`, `deviceId`, `platformIdentifyId`, `deviceTypeName`, `messageId`/hash filtering behavior, `rawData`, `receive_ts`, `hashId`, building/floor/project/space/equipment information, `dateKey`, and `targetId`.

The `messageId` here belongs to this REST response model. It does not establish a `messageId` field for the HTTP push v1.0 payload.

### 11. Alarm-clear history

Required request: `udfBuildingId: String`. Response is similar to abnormal-device data and includes `alertCancelTitle`.

### 12. AP gateway status

No request parameters. Response gateway entries include `model`, `imei`, `mac`, `address`, `gps`, `latestHeartbeatTs`, `onlineStatus` (`0` offline, `1` online), and battery percentage.

### 13. Device data

- `deviceId: String` — required
- `endTime: Long` — required; millisecond timestamp; range within seven days
- `startTime: Long` — required; millisecond timestamp

Response includes `deviceId`, `deviceSn`, `latestRawData`, `latestDataTime`, `typeUnit`, and `dataValue`.

### 14. Send device command

The request body is an array:

```json
[
  {
    "imei": "867953060389170",
    "command": "{\"gpio\":1}"
  }
]
```

Both `imei: String` and `command: String` are required. The command is itself encoded as a string.
