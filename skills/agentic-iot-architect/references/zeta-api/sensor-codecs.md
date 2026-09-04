# ZETA Sensor Uplink Payload Codecs & Parsing Reference

ZETA 端知能センサー（ZAIoT シリーズ等）の上行データパケットのデコード規約仕様書です。

### 301-ZETA端智能温度传感器-ZAIoT-TD01

# 公共参数说明

| 参数名 | 是否必填 | 说明 |
| --- | --- | --- |
| dataStatus | true | 数据类型说明，参考用，具体需要结合设备业务逻辑确定recovery=解除告警warning=告警normal=常规resp=下行应答illegal=不合法，无法解析数据 |
| header | false | 数据协议头，供参考用 |
| versionNumber | false | 设备版本号，供参考用 |
| completeData | false | 完整解析数据说明，供参考用 |

# 传感器参数字段结构说明

| 字段 | 是否必填 | 说明 |
| --- | --- | --- |
| name | true | 该字段的含义说明 |
| unit | false | 单位 |
| value | false | 值 |

示例："temperature":{"name":"温度","unit":"℃","value":"-0.2"}

# 调用示例

（1）jar包返回实体类com.zifisense.tools.protocollib.entity.ms.case(设备编码).DataInfo结果调用方式示例：
Analysis.result2Bean( 设备类型, 设备型号编码, 主版本号, 原始数据 )
```
com.zifisense.tools.protocollib.entity.ms.case1.DataInfo result =(com.zifisense.tools.protocollib.entity.ms.case1.DataInfo)com.zifisense.tools.protocollib.upstream.Analysis.result2Bean(com.zifisense.tools.protocollib.entity.common.DeviceType.ms,1,0,"800202");
```
（2）jar包返回json结果调用方式示例：
Analysis.result2Json( 设备类型, 设备型号编码, 主版本号, 原始数据 )
```
String result = com.zifisense.tools.protocollib.upstream.Analysis.result2Json(com.zifisense.tools.protocollib.entity.common.DeviceType.ms,1,0,"800202");
```

# 传感器参数

只针对当前数据的解析，如果结果中部分字段为null，则表示该数据不包含该字段内容，可以忽略

## 301-智能温度传感器ZAIoT-TD01

| 参数 | 说明 |
| --- | --- |
| msTemperature | 温度 |
| msWarnType | 告警类型 01高温告警 02低温告警 03数据异常 |
| msLiftWarnType | 解除告警类型 01高温告警    02低温告警   03数据异常 |
| msHeartbeatCycle | 心跳周期 |
| msWarnCycle | 告警周期 |
| msWarnUpperThreshold | 阈值上门限 |
| msWarnLowerThreshold | 阈值下门限 |
| msClearWarnThreshold | 解除告警阈值 |
| msWarnEnable | 告警使能 01-开启 02-关闭 |
| msWarnFilteringDuration | 告警过滤时长 |
| msCollectionCycle | 采集周期 |

示例：
原始数据：2000200010，版本号：1，终端编码：301

```
{
    "completeData": "",
    "currentStatus": null,
    "dataStatus": "resp",
    "header": "20",
    "msClearWarnThreshold": null,
    "msCollectionCycle": null,
    "msHeartbeatCycle": null,
    "msLiftWarnType": null,
    "msTemperature": null,
    "msWarnCycle": null,
    "msWarnEnable": null,
    "msWarnFilteringDuration": null,
    "msWarnLowerThreshold": {
        "name": "阈值下门限",
        "unit": "℃",
        "value": 1.6
    },
    "msWarnType": null,
    "msWarnUpperThreshold": {
        "name": "阈值上门限",
        "unit": "℃",
        "value": 3.2
    },
    "versionNumber": ""
}
```

---

