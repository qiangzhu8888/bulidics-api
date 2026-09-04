# ZETA Server MQTT Protocol Reference

ZiFiSense ZETA 網管平台（ZETA Server）と端末・中継機・基地局間およびアプリケーション連携のための MQTT プロトコルリファレンス仕様書です。

### 使用准备

# 示例代码

```
https://github.com/zifisense/zeta-mqtt-sdk.git
```

# Mqtt连接与认证

```
云平台
国内：tcp://cn-apis.zifisense.com:1883
国外：tcp://en-apis.zifisense.com:1883
独立部署：tcp://IP:1883
```

```
认证用户名：api_key(企业编码) 来源于ZETA 信息管理平台->系统管理->企业管理->企业信息的企业编码
```

```
认证密码：api_secret(企业密钥) 来源于ZETA 信息管理平台->系统管理->企业管理->企业信息的企业密钥
```

```
clientID：api_key:api_secret + 三位随机数字，需要确保唯一。 如：admin:1a2b3c4d56abc125
```

建议一个clientID订阅的在线设备总数不超过10000个，来保证订阅的可靠性。建议在大量设备情况下，通过apikey来划分连接做订阅。
​

# Topic规则

```
a、通用：api_key/version/opType/uid/msgType
```

| params | description | from | value |
| --- | --- | --- | --- |
| api_key | 企业编码 | ZETA信息管理平台 |  |
| version | 接口版本 |  | v1 |
| opType | 操作类型 |  | msgCmd字段：ms：终端mote：中继ap：基站upgrade：远程升级 |
| uid |  | 设备ID | 小写 |
| msgType | 消息类型 |  | subCmd字段+subType字段(为空则不需要该字段) |

b、特殊推送：依照“特殊推送”设置c、备注：
mqtt3.1协议，可以支持mqtt的通配符规则
```
"+"通配一层结构,允许作为层级中任意位置,任意多个
"#"通配多层结构，只允许位于末尾，只允许一个

合法："+/a/b/#","a/+/b","a/+/+/+/b"
不合法："#/b","a/#/b","+/#/b","a/#/+","a/#/b/#"
示例："a/b/c"，则"a/+/c"和"a/#"都可以获取到该topic的数据。
```
mqtt3.1协议以上版本，不支持通配符订阅，只允许完整订阅

# 订阅示例

## 基站心跳包：

### topic 示例：

```
获取单个设备信息： {api_key}/v1/ap/{uid}/heartbeat
如：840ebe6c2bae4d529181263433ece0ef/v1/ap/78fe2342/heartbeat
获取单企业下所有设备信息： {api_key}/v1/ap/+/heartbeat
如：840ebe6c2bae4d529181263433ece0ef/v1/ap/+/heartbeat
获取所有设备信息： +/v1/ap/+/heartbeat
如：+/v1/ap/+/heartbeat
```

### 返回数据：

```
{
  "apTime": 1472626704,
  "apUid": "78fe2342",
  "msgCmd": "ap",
  "msgDirect": "report",
  "msgEncrypt": "none",
  "msgId": 123456,
  "msgPriority": "normal",
  "msgType": "real",
  "msgUid": "1",
  "msgParam": {
      "subCmd": "heartbeat",
      "signal": "1f"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

## 终端上行解析数据：

### topic 示例：

```
获取单个设备信息： {api_key}/jll/property/ms/{uid}/updata
如：840ebe6c2bae4d529181263433ece0ef/jll/property/ms/00000001/updata
获取单企业下所有设备信息： {api_key}/jll/property/ms/+/updata
如：840ebe6c2bae4d529181263433ece0ef/jll/property/ms/+/updata
获取所有设备信息： +/jll/property/ms/+/updata
如：+/jll/property/ms/+/updata
```

### 返回数据：

```
{
  "companyCode": "2dfc3c8ad615451087f421686d1398d6",
  "deviceType": "ZETag路测工具-ZETAG-DT",
  "deviceaddr": "",
  "data": "0071431805940b76806ca700011805940b76806ca7",
  "dataDetail": "{\"completeData\":\"normal,0.1\",\"dataStatus\":\"normal\",\"header\":\"\",\"latitude\":{\"name\":\"纬度值\",\"unit\":\"°\",\"value\":\"24.609298\"},\"latitudeType\":{\"name\":\"纬度类型\",\"unit\":\"\",\"value\":0},\"longitude\":{\"name\":\"经度值\",\"unit\":\"°\",\"value\":\"-118.046358\"},\"longitudeType\":{\"name\":\"经度类型\",\"unit\":\"\",\"value\":1},\"mainVersion\":0,\"rssi\":{\"name\":\"信号强度\",\"unit\":\"\",\"value\":67},\"sqn\":{\"name\":\"序号\",\"unit\":\"\",\"value\":113},\"versionNumber\":\"0.1\"}",
  "deviceCode": 67,
  "deviceVersion": 1,
  "deviceMold": "ms",
  "pid": "",
  "accessKey": "",
  "upTime": "1599549928",
  "deviceId": "00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```
其中，dataDetail替换掉转义字符“\”,然后进行json格式化如下:

```
{
  "completeData": "normal,0.1",
  "dataStatus": "normal",
  "header": "",
  "latitude": {
      "name": "纬度值",
      "unit": "°",
      "value": "24.609298"
  },
  "latitudeType": {
      "name": "纬度类型",
      "unit": "",
      "value": 0
  },
  "longitude": {
      "name": "经度值",
      "unit": "°",
      "value": "-118.046358"
  },
  "longitudeType": {
      "name": "经度类型",
      "unit": "",
      "value": 1
  },
  "mainVersion": 0,
  "rssi": {
      "name": "信号强度",
      "unit": "",
      "value": 67
  },
  "sqn": {
      "name": "序号",
      "unit": "",
      "value": 113
  },
  "versionNumber": "0.1"
}
```

# 下行反馈数据域status

0:发送成功32:ms找不到map33:map找不到netid34:ms找不到ap35:map找不到ap36:ap找不到ip、port17:服务器到基站后端失败18:基站后端到基站前端失败19:设备无反馈1:基站查无此中继2:基站下发多次失败3:一级中继查无此中继4:一级中继下发多次失败5:二级中继查无此中继6:二级中继下发多次失败7:三级中继查无此中继8:三级中继下发多次失败9:下发到终端多次失败10:下发到终端上级设备11:下发到终端超时12: 中继串口无响应15:无下行反馈64:透传数据错误65:旧版指令错误66:旧版本协议错误68:新版指令错误69:新版本版本错误70:新版本协议错误71:下行所在ARM离线10000:数据校验不合法10001:cmd命令找不到10002:操作类型 subType 命令不合法10003:主命令 msgCmd 命令不合法10004:子命令subCmd 命令不合法10005:协议类型不存在10006:打印等级不存在10007:设备类型不存在10008:基站模块未启动成功10009:中继未注册成功10010:终端未注册成功
 
​

---

### 终端

---

#### 终端注册

## 注册到基站

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/reportregisterToAp
获取单企业下所有设备信息： {api_key}/v1/ms/+/reportregisterToAp
获取所有设备信息： +/v1/ms/+/reportregisterToAp
```
​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ms：终端 |
| msgParam | subCmd | 子命令 | report |
|  | msUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | registerToAp：终端注册上基站 |
|  | groupId | 组号 | hex，5个字节表示5个组,ff为无效组号 |
|  | netID | 中继网络号 | 2字节hex |
|  | status | 注册状态 | authenticationPass：接入鉴权成功authenticationRefuse：接入鉴权失败invalidData：过时无效数据 |
|  | version | 软件版本号 | Int：0-255 |
|  | regSeq | 注册序号 | int：0-31 |
|  | regCode | 注册原因 | reboot: 重启send: 发送数据失败重注册request: 下行操作重注册recycle: 上级网络号回收重注册adjust: 网络调整重注册sync: 失去同步重注册resend: 重发网络号（非重注册）unreg：上级非注册态重注册cache: 上级缓存失败重注册outsync: 广播失步重注册 |

### 返回示例

```
{
  "apTime":1597386591,
  "apUid":"00000003",
  "msgCmd":"ms",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"report",
      "netID":"12ab",
      "groupId":"010211ffff",
      "subType":"registerToAp",
      "regCode":"reboot",
      "regSeq":"1",
      "version":"12",
      "msUid":"00000001",
      "status":"authenticationPass"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

## 注册到中继

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/reportregisterToMote
获取单企业下所有设备信息： {api_key}/v1/ms/+/reportregisterToMote
获取所有设备信息： +/v1/ms/+/reportregisterToMote
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ms：终端 |
| msgParam | subCmd | 子命令 | report |
|  | msUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | registerToAp：终端注册上基站 |
|  | groupId | 组号 | hex，5个字节表示5个组,ff为无效组号 |
|  | netID | 中继网络号 | 2字节hex |
|  | status | 注册状态 | authenticationPass：接入鉴权成功authenticationRefuse：接入鉴权失败invalidData：过时无效数据 |
|  | version | 软件版本号 | Int：0-255 |
|  | regSeq | 注册序号 | int：0-31 |
|  | regCode | 注册原因 | reboot: 重启send: 发送数据失败重注册request: 下行操作重注册recycle: 上级网络号回收重注册adjust: 网络调整重注册sync: 失去同步重注册resend: 重发网络号（非重注册）unreg：上级非注册态重注册cache: 上级缓存失败重注册outsync: 广播失步重注册 |

### 返回示例

```
{
  "apTime":1597386591,
  "apUid":"00000003",
  "msgCmd":"ms",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"report",
      "netID":"12ab",
      "groupId":"010211ffff",
      "subType":"registerToMote",
      "regCode":"reboot",
      "regSeq":"1",
      "version":"13",
      "msUid":"00000001",
      "status":"authenticationPass"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 终端心跳包

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/reportheartbeat
获取单企业下所有设备信息： {api_key}/v1/ms/+/reportheartbeat
获取所有设备信息： +/v1/ms/+/reportheartbeat
```
​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ms：终端 |
| msgParam | subCmd | 子命令 | report |
|  | msUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | heartbeat：终端心跳 |
|  | battery | 电量 | int：0~255，实际电量换算规则：(150 + battery值)/100 |
|  | downRssi | 下行RSSI | int：0~255，需要自行添加负号，单位dBm |
|  | upRssi | 上行RSSI | int：0~255，需要自行添加负号，单位dBmzetag下表示Rssi值 |
|  | downMode | 终端下行模式 | off:关闭下行sniff-on:实时下行sniff-off：ACK下行zetag模式下表示序号 |
|  | zetagProtocol | zetag版本号 | int型 |
|  | frameType | 帧类型 | int型 |
|  | sleepMode | 注册休眠模式 | on:打开off:关闭 |
|  | RegFailRate | 注册失败率 | int0~100V2.0以上才有该字段 |
|  | UplinkLoseRate | 上行失败率 | int0~100V2.0以上才有该字段 |
|  | DownlinkLoseRate | 下行失败率 | int0~100V2.0以上才有该字段 |

### 返回示例

```
{
  "apTime":1599210105,
  "apUid":"00000003",
  "msgCmd":"ms",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "msgParam":{
      "sleepMode":"off",
      "subCmd":"report",
      "RegFailRate":"1",
      "downMode":"sniff-on",
      "upRssi":"11",
      "battery":"52",
      "zetagProtocol":"1",
      "UplinkLoseRate":"22",
      "downRssi":"78",
      "frameType":"4",
      "subType":"heartbeat",
      "DownlinkLoseRate":"150",
      "msUid":"0000000f"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 终端上行数据

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/reportuploadData
获取单企业下所有设备信息： {api_key}/v1/ms/+/reportuploadData
获取所有设备信息： +/v1/ms/+/reportuploadData
```
​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ms：终端 |
| msgParam | subCmd | 子命令 | report |
|  | msUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | uploadData：终端上行数据 |
|  | dataEncrypt | 是否有进行数据解密 | none:无解密 devEncrypt:有解密注：不一定会有这个字段，如果没有，默认是无解密 |
|  | dataType | 数据类型 | 1：zetag数据额外包含字段:seq/longitude/latitude/rssi/appData |
|  | seq | zetag序号 | int型(zetag设备才有) |
|  | latitude | 纬度 | float类型小于0南纬，否则北纬 |
|  | longitude | 经度 | float类型小于0西经，否则东经 |
|  | rssi | 信号强度 | int: 0~255zetag下表示Rssi值 |
|  | data | 数据域 | zetag的格式：序号[2]+信号强度[1]+位置信息[8]+应用数据[n] |
|  | appData | zetag的应用data | 应用数据[n] |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":17630,
  "apTime":1599206748,
  "msgEncrypt":"none",
  "msgUid":"7000011e",
  "msgCmd":"ms",
  "apUid":"7000021f",
  "msgParam":{
      "subCmd":"report",
      "subType":"uploadData",
      "msUid":"4f00996c",
      "data":"44de711805964976006a610100",
      "dataType":1,
      "seq":17630,
      "rssi":113,
      "appData":"0100",
      "latitude":24.610254,
      "longitude":118.045387
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 终端反馈下行数据

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/reportresponseDownData
获取单企业下所有设备信息： {api_key}/v1/ms/+/reportresponseDownData
获取所有设备信息： +/v1/ms/+/reportresponseDownData
```
​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd | 主命令 | ms：终端 |  |
| msgParam | subCmd | 子命令 | report |
|  | msUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | responseDownData：上行数据 |
|  | status | 状态 | 参考附录下行反馈status说明 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":6106,
  "apTime":1599196805,
  "msgEncrypt":"none",
  "msgUid":"7000f0f2",
  "apUid":"7000f0f2",
  "msgCmd":"ms",
  "msgParam":{
      "subCmd":"report",
      "subType":"responseDownData",
      "status":10,
      "msUid":"22222319"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 终端登出

### topic说明

```
获取指定设备信息： {api_key}/v1/ms/{uid}/logout
获取单企业下所有设备信息： {api_key}/v1/ms/+/logout
获取所有设备信息： +/v1/ms/+/logout
```
​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ms：终端 |
| msgParam | subCmd | 子命令 | logout：登出 |
|  | msUid | 终端uid | 4字节 hex |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":"0",
  "msgEncrypt":"none",
  "msgCmd":"ms",
  "msgParam":{
      "subCmd":"logout",
      "msUid":"4f00ed0e"
  },
  "msgUid":"52400001",
  "apUid":"52400002",
  "apTime":1599189103,
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

### 中继

---

#### 中继注册

### topic说明

```
获取指定设备信息： {api_key}/v1/mote/{uid}/reportregister
获取单企业下所有设备信息： {api_key}/v1/mote/+/reportregister
获取所有设备信息： +/v1/mote/+/reportregister
```

​

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | mote：中继 |
| msgParam | subCmd | 子命令 | report |
|  | moteUid | 终端uid | 4字节 hex |
|  | subType | 操作类型 | register：中继注册 |
|  | groupId | 组号 | string型，10个字符表示5个字节,ff为无效组号 |
|  | netID | 基站分配给终端网络号 | 2字节hex |
|  | status | 注册状态 | authenticationPass：接入鉴权成功authenticationRefuse：接入鉴权失败invalidData：过时无效数据 |
|  | version | 软件版本号 | string型=协议运行版本号.协议主版本号.协议子版本号 |
|  | regSeq | 注册序号 | int：0-31 |
|  | regCode | 注册原因 | reboot: 重启send: 发送数据失败重注册request: 下行操作重注册recycle: 上级网络号回收重注册adjust: 网络调整重注册sync: 失去同步重注册resend: 重发网络号（非重注册，方便测试人员观察）unreg：上级非注册态重注册cache: 上级缓存失败重注册outsync: 广播失步重注册 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"mote",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"report",
      "netID":"35d3",
      "groupId":"010211ffff",
      "subType":"register",
      "regCode":"reboot",
      "regSeq":"1",
      "version":"10",
      "moteUid":"00000001",
      "status":"authenticationPass"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 中继心跳包

### topic说明

```
获取指定设备信息： {api_key}/v1/mote/{uid}/reportheartbeat
获取单企业下所有设备信息： {api_key}/v1/mote/+/reportheartbeat
获取所有设备信息： +/v1/mote/+/reportheartbeat
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | mote：中继 |
| msgParam | subCmd | 子命令 | report |
|  | moteUid | 中继uid | 4字节 hex |
|  | subType | 操作类型 | heartbeat：心跳 |
|  | battery | 电量 | int：0~255，实际电量换算规则：(150 + battery值)/100 |
|  | flow | 流量，两次心跳包 | int: 0~65535 |
|  | downRssi | 下行RSSI | int：0~255，需要自行添加负号，单位dBm |
|  | upRssi | 上行RSSI | int：0~255，需要自行添加负号，单位dBm |
|  | sleepMode | 注册休眠模式 | on:打开off:关闭 |
|  | RegFailRate | 注册失败率 | int0~100 |
|  | UplinkLoseRate | 上行失败率 | int0~100 |
|  | DownlinkLoseRate | 下行失败率 | int0~100 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"mote",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "sleepMode":"on",
      "subCmd":"report",
      "RegFailRate":"1",
      "UplinkLoseRate":"22",
      "downRssi":"96",
      "subType":"heartbeat",
      "upRssi":"82",
      "battery":"11",
      "moteUid":"00000001",
      "flow":"11",
      "DownlinkLoseRate":"100"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 中继上行数据

### topic说明

```
获取指定设备信息： {api_key}/v1/mote/{uid}/reportuploadData
获取单企业下所有设备信息： {api_key}/v1/mote/+/reportuploadData
获取所有设备信息： +/v1/mote/+/reportuploadData
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | mote：中继 |
| msgParam | subCmd | 子命令 | report |
|  | moteUid | 中继uid | 4字节 hex |
|  | subType | 操作类型 | uploadData：中继上行数据 |
|  | dataEncrypt | 数据包加密类型 | none：无加密devEncrypt:上报数据加密 |
|  | data | 数据 | n字节hex |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"mote",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123457,
  "msgParam":{
      "subCmd":"report",
      "data":"680000",
      "subType":"uploadData",
      "moteUid":"00000001"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 中继反馈下行数据

### topic说明

```
获取指定设备信息： {api_key}/v1/mote/{uid}/reportresponseDownData
获取单企业下所有设备信息： {api_key}/v1/mote/+/reportresponseDownData
获取所有设备信息： +/v1/mote/+/reportresponseDownData
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | mote:中继 |
| msgParam | subCmd | 子命令 | report |
|  | moteUid | 中继uid | 4字节 hex |
|  | subType | 操作类型 | responseDownData：上行数据 |
|  | status | 状态 | 参考附录下行反馈status说明 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"mote",
  "msgDirect":"resp",
  "msgEncrypt":"none",
  "msgId":1,
  "msgParam":{
      "subCmd":"report",
      "subType":"responseDownData",
      "moteUid":"00000001",
      "status":"9"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 中继登出

### topic说明

```
获取指定设备信息： {api_key}/v1/mote/{uid}/logout
获取单企业下所有设备信息： {api_key}/v1/mote/+/logout
获取所有设备信息： +/v1/mote/+/logout
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | mote：中继 |
| msgParam | subCmd | 子命令 | logout：登出 |
|  | moteUid | 中继uid | 4字节 hex |

### 返回示例

```
{
  "apTime":1599445739,
  "apUid":"00000003",
  "msgCmd":"mote",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"logout",
      "moteUid":"00000001"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

### 基站

---

#### 基站登录

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/login
获取单企业下所有设备信息： {api_key}/v1/ap/+/login
获取所有设备信息： +/v1/ap/+/login
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | login：登录 |
|  | signal | 信号强度 | int0-31：对应0-100%99：表示无法检测255：表示以太网 |
|  | protocolVersion | 协议版本号 | 字符串表示两个字节hex |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"login",
      "protocolVersion":"0000",
      "signal":"13"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站登出

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/logout
获取单企业下所有设备信息： {api_key}/v1/ap/+/logout
获取所有设备信息： +/v1/ap/+/logout
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | logout：登出 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"logout"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站心跳包

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/heartbeat
获取单企业下所有设备信息： {api_key}/v1/ap/+/heartbeat
获取所有设备信息： +/v1/ap/+/heartbeat
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | heartbeat：心跳 |
|  | signal | 信号强度 | int0-31：对应0-100%99：表示无法检测255：表示以太网 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"93860500",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"heartbeat",
      "signal":"12"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"2183192.0",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站模块启动

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/apStart
获取单企业下所有设备信息： {api_key}/v1/ap/+/apStart
获取所有设备信息： +/v1/ap/+/apStart
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | apStart：基站模块启动 |
|  | type | 协议类型 | zeta-p: ZETA-P模式zeta-s: ZETA-S模式zeta-p-lite: ZETA-P五零路灯版本zeta-s-lite: ZETA-S五零路灯版本zeta-g：ZETA-G模式 |
|  | status | 启动状态 | normal:正常gps：gps同步没获取到pps：pps脉冲没获取到mac：mac没有正确传输； |
|  | version | 软件版本号 | Int:协议子版本号 |
|  | newComVer | 组合版本号 | string型=协议运行版本号.协议主版本号.协议子版本号 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"apStart",
      "newComVer":"2.36.8",
      "type":"zeta-p",
      "version":"12",
      "status":"normal"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站状态

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/status
获取单企业下所有设备信息： {api_key}/v1/ap/+/status
获取所有设备信息： +/v1/ap/+/status
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | status：获取基站状态 |
|  | status | 启动状态 | online:在线offline:离线 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "subCmd":"status",
      "status":"offline"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置基站时间下行反馈

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/setTime
获取单企业下所有设备信息： {api_key}/v1/ap/+/setTime
获取所有设备信息： +/v1/ap/+/setTime
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | setTime：设置时间 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599460212,
  "msgEncrypt":"none",
  "msgUid":"7000a888",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "result":"success",
      "subCmd":"setTime"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站时间

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getTime
获取单企业下所有设备信息： {api_key}/v1/ap/+/getTime
获取所有设备信息： +/v1/ap/+/getTime
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | getTime：获取时间 |
|  | type | 时间类型 | system：系统时间RTC：实时时钟时间 |
|  | year | 年 | e.g. 2014 |
|  | month | 月 | 1-12 |
|  | day | 日 | 1-31 |
|  | week | 星期 | 0-6 since sunday |
|  | hour | 时 | 0-23 |
|  | min | 分 | 0-59 |
|  | sec | 秒 | 0-59 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":21588,
  "apTime":1599461536,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "subCmd":"getTime",
      "type":"system",
      "year":2020,
      "month":9,
      "day":7,
      "week":1,
      "hour":14,
      "min":52,
      "sec":16
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站复位下行反馈

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reset
获取单企业下所有设备信息： {api_key}/v1/ap/+/reset
获取所有设备信息： +/v1/ap/+/reset
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | reset：复位基站 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599460212,
  "msgEncrypt":"none",
  "msgUid":"7000a888",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "result":"success",
      "subCmd":"reset"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站重启下行反馈

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reboot
获取单企业下所有设备信息： {api_key}/v1/ap/+/reboot
获取所有设备信息： +/v1/ap/+/reboot
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | reboot：重启基站 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599460212,
  "msgEncrypt":"none",
  "msgUid":"7000a888",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "result":"success",
      "subCmd":"reboot"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置基站运行参数下行反馈

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/setApParam
获取单企业下所有设备信息： {api_key}/v1/ap/+/setApParam
获取所有设备信息： +/v1/ap/+/setApParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | setApParam：设置基站参数 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599460212,
  "msgEncrypt":"none",
  "msgUid":"7000a888",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "result":"success",
      "subCmd":"setApParam"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站运行参数

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getApParam
获取单企业下所有设备信息： {api_key}/v1/ap/+/getApParam
获取所有设备信息： +/v1/ap/+/getApParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | getApParam：获取基站参数 |
|  | serverIp | 服务器ip | 字符串 0~32字节 |
|  | serverPort | 服务器port | Int：0-65535 |
|  | connectMode | 通信方式 | gprs:无线网络，eth:以太网 |
|  | apn | 服务器apn | 字符串 0~16字节 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":17221,
  "apTime":1599466457,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "subCmd":"getApParam",
      "connectMode":"eth",
      "serverIp":"192.168.0.230",
      "serverPort":8486,
      "apn":""
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站版本信息

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getVersionInfo
获取单企业下所有设备信息： {api_key}/v1/ap/+/getVersionInfo
获取所有设备信息： +/v1/ap/+/getVersionInfo
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | getVersionInfo：获取基站版本信息 |
|  | version | 版本 | 字符串 |
|  | company | 公司名称 | 字符串 |
|  | website | 公司地址 | 字符串 |
|  | equipment | 设备名称 | 字符串 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":61088,
  "apTime":1599467911,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "subCmd":"getVersionInfo",
      "version":"BS.200731.v2.005 Pv2.000.14 H1",
      "company":"zeta",
      "website":"",
      "equipment":""
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报GPRS模块信息

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getGprsInfo
获取单企业下所有设备信息： {api_key}/v1/ap/+/getGprsInfo
获取所有设备信息： +/v1/ap/+/getGprsInfo
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  |  | 主命令 |
| msgParam | subCmd | 子命令 | getGprsInfo：获取GPRS模块信息 |
|  | rssi | 信号强度 | int:0-31：对应0-100%99：表示无法检测 |
|  | telNum | 执行结果 | success：成功fail：失败 |
|  | mode | 模块运行模式 | 字符串(最大16字节)：“NO SERVICE”,”GSM”,“GPRS”,”EDGE”,“WCDMA”,”HSDPA”,“HSUPA”,”HSPA”,“HSPA+”,”#” |
|  | iccid | SIM卡卡号 | 20个字符串,如:898600MFSSYYGXXXXXXP |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":19782,
  "apTime":1599468671,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "apUid":"00000000",
  "msgCmd":"ap",
  "msgParam":{
      "subCmd":"getGprsInfo",
      "rssi":255,
      "telNum":"#",
      "mode":"eth",
      "iccid":"#"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站模块下行反馈

### topic说明

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reportresponseDownData
获取单企业下所有设备信息： {api_key}/v1/ap/+/reportresponseDownData
获取所有设备信息： +/v1/ap/+/reportresponseDownData
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  |  | 主命令 |
| msgParam | subCmd | 子命令 | report |
|  | subType | 执行结果 | responseDownData：上行数据 |
|  | status | 状态 | 参考附录下行反馈status说明 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599468948,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "apUid":"70002222",
  "msgCmd":"ap",
  "msgParam":{
      "subCmd":"report",
      "subType":"responseDownData",
      "status":0
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站组播下行反馈

### topic说明

####  针对中继：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/multicastmote
获取单企业下所有设备信息： {api_key}/v1/ap/+/multicastmote
获取所有设备信息： +/v1/ap/+/multicastmote
```

####  针对终端：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/multicastms
获取单企业下所有设备信息： {api_key}/v1/ap/+/multicastms
获取所有设备信息： +/v1/ap/+/multicastms
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | multicast:组播 |
|  | subType | 执行结果 | ms:终端mote:中继 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | devGroup | 设备组号 | Int：1-254 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":1923,
  "msgParam":{
      "result":"fail",
      "subCmd":"multicast",
      "subType":"mote",
      "devGroup":"100"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站广播下行反馈

### topic说明

####  针对中继：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/broadcastmote
获取单企业下所有设备信息： {api_key}/v1/ap/+/broadcastmote
获取所有设备信息： +/v1/ap/+/broadcastmote
```

####  针对终端：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/broadcastms
获取单企业下所有设备信息： {api_key}/v1/ap/+/broadcastms
获取所有设备信息： +/v1/ap/+/multicastms
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | broadcast:广播 |
|  | subType | 执行结果 | ms:终端mote:中继 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":54225,
  "msgParam":{
      "result":"fail",
      "subCmd":"broadcast",
      "subType":"ms"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 巡检下行反馈

### topic说明

####  针对中继：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/pollingmote
获取单企业下所有设备信息： {api_key}/v1/ap/+/pollingmote
获取所有设备信息： +/v1/ap/+/pollingmote
```

####  针对终端：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/pollingms
获取单企业下所有设备信息： {api_key}/v1/ap/+/pollingms
获取所有设备信息： +/v1/ap/+/pollingms
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | polling：轮询 |
|  | subType | 执行结果 | ms:终端mote:中继 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":55824,
  "msgParam":{
      "result":"fail",
      "subCmd":"polling",
      "subType":"ms"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 组播巡检下行反馈

### topic说明

####  针对中继：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/multiPollmote
获取单企业下所有设备信息： {api_key}/v1/ap/+/multiPollmote
获取所有设备信息： +/v1/ap/+/multiPollmote
```

####  针对终端：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/multiPollms
获取单企业下所有设备信息： {api_key}/v1/ap/+/multiPollms
获取所有设备信息： +/v1/ap/+/multiPollms
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | multiPoll：轮询 |
|  | subType | 执行结果 | ms:终端mote:中继 |
|  | devGroup | 设备组号 | Int：1-254 |
|  | result | 执行结果 | success：成功fail：失败 |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"ap",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":55824,
  "msgParam":{
      "result":"success",
      "subCmd":"multiPoll",
      "subType":"ms",
      "devGroup":"100"
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 获取基站模块射频信息下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getRfInfo
获取单企业下所有设备信息： {api_key}/v1/ap/+/getRfInfo
获取所有设备信息： +/v1/ap/+/getRfInfo
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | getRfInfo |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":54,
  "apTime":1599536725,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"getRfInfo",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站模块射频信息

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reportRfInfo
获取单企业下所有设备信息： {api_key}/v1/ap/+/reportRfInfo
获取所有设备信息： +/v1/ap/+/reportRfInfo
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | reportRfInfo：上报基站模块射频信息 |
|  | freq | 基础频点 | int单位hz |
|  | protocol | 模块协议 | zeta-p: ZETA-P模式zeta-s: ZETA-S模式zeta-lite: ZETA-LITE模式zeta-g：ZETA-G模式 |
|  | carryMonitor | 载波侦听阈值 | int单位hz |
|  | commRate | 通信速率 | Int: 0~255 |
|  | channelFB1 | FB1信道 | Int: 0~255 |
|  | channelFB2 | FB2信道 | Int: 0~255 |
|  | channelFB3 | FB3信道 | Int: 0~255 |
|  | channelF1 | F1信道 | Int: 0~255 |
|  | maxFrame | 最大帧数 | Int: 0~255 |
|  | maxSubFrame | 最大子帧数 | Int: 0~255 |
|  | gatewayPoint | 网关频点 | Int: 0~255 (10khz) |
|  | motePoint | 中继频点 | Int: 0~255 (10khz) |
|  | msPoint | 终端频点 | Int: 0~255 (10khz) |
|  | gatewaySpeed | 网关速率 | Int: 0~255 |
|  | moteSpeed | 中继速率 | Int: 0~255 |
|  | msSpeed | 终端速率 | Int: 0~255 |
|  | chnSpace | 信道间隔 | Int: 0~255 |
|  | broadRegChn | 基站广播注册信息信道 | Int: 0~255 |
|  | trafficChn | 基站业务信道 | Int: 0~255 |
|  | moteRegChn | 中继注册信道 | Int: 0~255 |
|  | moteTrafficChn | 中继业务信道 | Int: 0~255 |
|  | moteBroadChn | 中继广播信道 | Int: 0~255 |
|  | downTrafficChn | 下行业务信道 | Int: 0~255 |
|  | regTimeSlot | 基站广播注册信息时隙 | Int: 0~255 |
|  | freqHopp | 是否跳频 | 0：否1：是 |
|  | fhGroup | 跳频组号 | Int: 0~255 |
|  | fhRange | 跳频范围 | Int: 0~255 |
|  | transPower | 发射功率 | Int: 0~255 |
|  | slotNumber | 时隙数 | Int：5~30一帧中包含的时隙个数 |
|  | slotSize | 时隙大小 | Int：9~20单位：百毫秒 9 = 900ms |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":0,
  "apTime":1599472941,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"reportRfInfo",
      "protocol":"ZETA-P",
      "gatewayPoint":47150,
      "motePoint":47190,
      "msPoint":47230,
      "gatewaySpeed":1,
      "moteSpeed":1,
      "msSpeed":1,
      "transPower":17,
      "carryMonitor":70
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 获取基站GPS状态下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getGpsStatus
获取单企业下所有设备信息： {api_key}/v1/ap/+/getGpsStatus
获取所有设备信息： +/v1/ap/+/getGpsStatus
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | getGpsStatus |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"getGpsStatus",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站GPS状态

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/getGpsStatus
获取单企业下所有设备信息： {api_key}/v1/ap/+/getGpsStatus
获取所有设备信息： +/v1/ap/+/getGpsStatus
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | reportGpsStatus：上报基站GPS状态 |
|  | status | GPS状态 | normal:正常disabled：GPS未使能time：GPS获取不到时钟信息；pps：GPS获取不到秒脉冲信号； |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"reportGpsStatus",
      "status":"normal"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置基站时区下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/setTimeZone
获取单企业下所有设备信息： {api_key}/v1/ap/+/setTimeZone
获取所有设备信息： +/v1/ap/+/setTimeZone
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | setTimeZone |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"setTimeZone",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站协议

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reportVersion
获取单企业下所有设备信息： {api_key}/v1/ap/+/reportVersion
获取所有设备信息： +/v1/ap/+/reportVersion
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | reportVersion |
|  | protocolVersion | 协议版本号 | 字符串表示两个字节hex |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"reportVersion",
      "protocolVersion":"0108"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置GPS信息下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/setGps
获取单企业下所有设备信息： {api_key}/v1/ap/+/setGps
获取所有设备信息： +/v1/ap/+/setGps
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | setGps |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"setGps",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 清除基站发送数据缓存下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/clearArmSendBuff
获取单企业下所有设备信息： {api_key}/v1/ap/+/clearArmSendBuff
获取所有设备信息： +/v1/ap/+/clearArmSendBuff
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | clearArmSendBuff |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"ap",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"clearArmSendBuff",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### GPS轨迹数据上行

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/reportZetagGpsTrail
获取单企业下所有设备信息： {api_key}/v1/ap/+/reportZetagGpsTrail
获取所有设备信息： +/v1/ap/+/reportZetagGpsTrail
```

### 返回参数说明

| root | parent | child | description | value |
| --- | --- | --- | --- | --- |
| deviceaddr |  |  | 设备地址 |  |
| deviceAlias |  |  | 设备别名 |  |
| msgDirect |  |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  |  | 数据包加密类型 | none：无加密 |
| apTime |  |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  |  | 数据包主控ID Uid | 4字节hex |
| apUid |  |  | 数据包基站Uid | 4字节hex |
| msgCmd |  |  | 主命令 | ap：基站 |
| msgParam | subCmd |  | 子命令 | reportZetagGpsTrail |
|  | trails[A] | dottime | 打点时间 | 秒级时间戳 |
|  |  | latitude | 纬度 | 小于0南纬，否则北纬 |
|  |  | longitude | 经度 | 小于0西经，否则东经 |
|  |  | azimuth | 航向数据 | （0~359正北为0，顺时针）如果方向数据为65535(Hex格式的0xFFFF)表示无航向数据 |
|  |  | speed | 速度数据 | 单位： 0.1km/h |
|  |  | height | 高度数据 | 单位：米 |
|  | data |  | 原始数据 |  |

### 返回示例

```
{
  "msgEncrypt":"none",
  "msgType":"real",
  "apTime":1472626704,
  "msgDirect":"report",
  "msgId":123456,
  "msgParam":{
      "subCmd":"reportZetagGpsTrail",
      "trails":[
          {
              "dottime":"1590893794",
              "latitude":"-21.7476",
              "azimuth":55,
              "speed":4,
              "longitude":"104.7476",
              "height":2
          },
          {
              "dottime":"1590990698",
              "latitude":"23.7476",
              "azimuth":254,
              "speed":2,
              "longitude":"114.7476",
              "height":5
          }
      ]
  },
  "apUid":"00000003",
  "msgUid":"00000001",
  "msgPriority":"normal",
  "msgCmd":"ap",
  "deviceAlias":"这是别名",
  "deviceaddr":""
}
```

---

### 远程升级

---

#### 设置ftp参数下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/setFtpParam
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/setFtpParam
获取所有设备信息： +/v1/upgrade/+/setFtpParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：基站 |
| msgParam | subCmd | 子命令 | setFtpParam |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"setFtpParam",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报FTP服务器参数

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/getFtpParam
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/getFtpParam
获取所有设备信息： +/v1/upgrade/+/getFtpParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | getFtpParam：获取FTP服务器参数 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | serverIp | 服务器ip | 字符串，例: 192.168.1.2 |
|  | serverPort | 服务器端口 | Int：0-65535 |
|  | fileName | 升级文件名 | 字符串长度<=128 |
|  | username | FTP 帐号 | 字符串 |
|  | password | FTP 密码 | 字符串 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":65452,
  "apTime":1599545138,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"success",
      "subCmd":"getFtpParam",
      "serverIp":"118.178.95.186",
      "serverPort":21,
      "fileName":"BaseStation",
      "username":"ftpupgrade",
      "password":"BSupgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### ARM升级下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/startApUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/startApUpgrade
获取所有设备信息： +/v1/upgrade/+/startApUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：基站 |
| msgParam | subCmd | 子命令 | startApUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":28870,
  "apTime":1599545905,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"success",
      "subCmd":"startApUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报ARM升级结果

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/report
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/report
获取所有设备信息： +/v1/upgrade/+/report
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | report：ARM升级结果反馈 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | errorCode | 执行结果失败原因 | null: 下载文件成功unknown: 未知错误dir: 升级目录无法找到conn:服务器无法连接auth:帐号无法登录服务器trans: 设置传输类型错误system: 查询服务器系统错误file:无法找到升级文件permission: 无法创建本地文件session:网络链路存在问题,请重启基站尝试再次升级. |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":28870,
  "apTime":1599545909,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"fail",
      "subCmd":"report",
      "errorCode":"conn"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站模块升级下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/startModuleUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/startModuleUpgrade
获取所有设备信息： +/v1/upgrade/+/startModuleUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：基站 |
| msgParam | subCmd | 子命令 | startModuleUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546174,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"success",
      "subCmd":"startModuleUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站模块升级结果

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/moduleUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/moduleUpgrade
获取所有设备信息： +/v1/upgrade/+/moduleUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | moduleUpgrade：基站模块升级结果反馈 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | errorCode | 执行结果失败原因 | null: 升级成功unknown: 未知错误inprocess: 目标正在升级,无法响应本次操作file: 下载升级文件失败tmp：AP回复暂时无法升级fail: AP回复升级失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546178,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"fail",
      "subCmd":"moduleUpgrade",
      "errorCode":"file"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置ftp参数下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/setFtpParam
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/setFtpParam
获取所有设备信息： +/v1/upgrade/+/setFtpParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | setFtpParam |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":25468,
  "apTime":1599538006,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "subCmd":"setFtpParam",
      "result":"success"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报FTP服务器参数

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/getFtpParam
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/getFtpParam
获取所有设备信息： +/v1/upgrade/+/getFtpParam
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | getFtpParam：获取FTP服务器参数 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | serverIp | 服务器ip | 字符串，例: 192.168.1.2 |
|  | serverPort | 服务器端口 | Int：0-65535 |
|  | fileName | 升级文件名 | 字符串长度<=128 |
|  | username | FTP 帐号 | 字符串 |
|  | password | FTP 密码 | 字符串 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":65452,
  "apTime":1599545138,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"success",
      "subCmd":"getFtpParam",
      "serverIp":"118.178.95.186",
      "serverPort":21,
      "fileName":"BaseStation",
      "username":"ftpupgrade",
      "password":"BSupgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### ARM升级下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/startApUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/startApUpgrade
获取所有设备信息： +/v1/upgrade/+/startApUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | startApUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":28870,
  "apTime":1599545905,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"success",
      "subCmd":"startApUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报ARM升级结果

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/report
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/report
获取所有设备信息： +/v1/upgrade/+/report
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | report：ARM升级结果反馈 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | errorCode | 执行结果失败原因 | null: 下载文件成功unknown: 未知错误dir: 升级目录无法找到conn:服务器无法连接auth:帐号无法登录服务器trans: 设置传输类型错误system: 查询服务器系统错误file:无法找到升级文件permission: 无法创建本地文件session:网络链路存在问题,请重启基站尝试再次升级. |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":28870,
  "apTime":1599545909,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"00000000",
  "msgParam":{
      "result":"fail",
      "subCmd":"report",
      "errorCode":"conn"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站模块升级下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/startModuleUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/startModuleUpgrade
获取所有设备信息： +/v1/upgrade/+/startModuleUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | startModuleUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546174,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"success",
      "subCmd":"startModuleUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站模块升级结果

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/moduleUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/moduleUpgrade
获取所有设备信息： +/v1/upgrade/+/moduleUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd | 子命令 | moduleUpgrade：基站模块升级结果反馈 |
|  | result | 执行结果 | success：成功fail：失败 |
|  | errorCode | 执行结果失败原因 | null: 升级成功unknown: 未知错误inprocess: 目标正在升级,无法响应本次操作file: 下载升级文件失败tmp：AP回复暂时无法升级fail: AP回复升级失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546178,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"fail",
      "subCmd":"moduleUpgrade",
      "errorCode":"file"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置基站全量升级FTP服务器参数下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/setFtpApFullUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/setFtpApFullUpgrade
获取所有设备信息： +/v1/upgrade/+/setFtpApFullUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | setFtpApFullUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546174,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"success",
      "subCmd":"setFtpApFullUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 设置基站模块下多终端/中继升级参数下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/setUpgradeParamMutil
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/setUpgradeParamMutil
获取所有设备信息： +/v1/upgrade/+/setUpgradeParamMutil
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | setUpgradeParamMutil |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546174,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"success",
      "subCmd":"setUpgradeParamMutil"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 基站模块下多终端/中继升级控制下行反馈

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/startDevsInModuleUpgrade
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/startDevsInModuleUpgrade
获取所有设备信息： +/v1/upgrade/+/startDevsInModuleUpgrade
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据包流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 数据包优先级 | high：高优先级normal：普通 |
| msgType |  | 数据包操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 数据包唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 数据包加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 数据包主控ID Uid | 4字节hex |
| apUid |  | 数据包基站Uid | 4字节hex |
| msgCmd |  | 主命令 | upgrade |
| msgParam | subCmd | 子命令 | startDevsInModuleUpgrade |
|  | result | 执行结果 | success：成功，fail：失败 |

### 返回示例

```
{
  "msgDirect":"report",
  "msgPriority":"normal",
  "msgType":"real",
  "msgId":48379,
  "apTime":1599546174,
  "msgEncrypt":"none",
  "msgUid":"70002222",
  "msgCmd":"upgrade",
  "apUid":"70002222",
  "msgParam":{
      "result":"success",
      "subCmd":"startDevsInModuleUpgrade"
  },
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

#### 上报基站模块下多终端/中继升级结果

### topic说明：

```
获取指定设备信息： {api_key}/v1/upgrade/{uid}/devsInModuleUpgradeReport
获取单企业下所有设备信息： {api_key}/v1/upgrade/+/devsInModuleUpgradeReport
获取所有设备信息： +/v1/upgrade/+/devsInModuleUpgradeReport
```

### 返回参数说明

| root | parent | child | description | value |
| --- | --- | --- | --- | --- |
| deviceaddr |  |  | 设备地址 |  |
| deviceAlias |  |  | 设备别名 |  |
| msgDirect |  |  | 流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  |  | 优先级 | high：高优先级normal：普通 |
| msgType |  |  | 操作类型 | real：实时操作cache：缓存操作 |
| msgId |  |  | 消息标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  |  | 加密类型 | none：无加密 |
| apTime |  |  | TimeStamp | 秒级Unix 时间戳 |
| msgUid |  |  | 主控ID Uid | 4字节hex |
| apUid |  |  | 基站Uid | 4字节hex |
| msgCmd |  |  | 主命令 | upgrade：远程升级 |
| msgParam | subCmd |  | 子命令 | devsInModuleUpgradeReport基站模块下多终端/中继升级结果 |
|  | devType |  | 设备类型 | ms终端mote中继 |
|  | status |  | 执行结果 | success：成功fail：失败 |
|  | devInfos[A] | uid | 设备UID | 4字节hex |

### 返回示例

```
{
  "apTime":1472626704,
  "apUid":"00000003",
  "msgCmd":"upgrade",
  "msgDirect":"report",
  "msgEncrypt":"none",
  "msgId":123456,
  "msgParam":{
      "devType":"ms",
      "result":"success",
      "subCmd":"devsInModuleUpgradeReport",
      "devInfos":[
          {
              "uid":"11111154"
          },
          {
              "uid":"11111153"
          }
      ]
  },
  "msgPriority":"normal",
  "msgType":"real",
  "msgUid":"00000001",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

### 设备服务

---

#### 设备告警上报

### topic说明：

```
获取指定设备信息： {api_key}/v1/ap/{uid}/alarm
获取单企业下所有设备信息： {api_key}/v1/ap/+/alarm
获取所有设备信息： +/v1/ap/+/alarm
```

### 返回参数说明

| root | parent | description | value |
| --- | --- | --- | --- |
| deviceaddr |  | 设备地址 |  |
| deviceAlias |  | 设备别名 |  |
| msgDirect |  | 数据流向 | req：请求resp：请求回复report：上报ack：上报响应 |
| msgPriority |  | 优先级 | high：高优先级normal：普通 |
| msgType |  | 操作类型 | real：实时操作cache：缓存操作 |
| msgId |  | 唯一标识 | 最大65535的随机值，配合设备id和命令类型短时间内唯一 |
| msgEncrypt |  | 加密类型 | none：无加密 |
| apTime |  | Unix TimeStamp | 秒级Unix 时间戳 |
| msgUid |  | 主控ID Uid | 4字节hex |
| apUid |  | 基站Uid | 4字节hex |
| msgCmd |  | 主命令 | ap：基站 |
| msgParam | subCmd | 子命令 | alarm：告警上报 |
|  | dataType | 数据类型 | 0告警产生1告警自动解除 |
|  | devType | 设备类型 | 0终端1中继2基站3服务器 |
|  | devUid | 设备uid | 4字节 hex |
|  | serverIp | 服务器IP | devType为3时有效 |
|  | warnNum | 告警编码 | 1000剩余内存不足，1001磁盘空间不足，1002进程故障，1003链路故障 ，1004GPS信号异常，1005射频模块故障，1006低电告警 |
|  | warnLevel | 告警级别 | int：0一般告警1严重告警2紧急告警 |
|  | maybeReason | 告警原因/恢复原因 | int，以下表示告警原因:0:内存使用率比较高1:磁盘空间占用超过门限2:进程故障，无法正常运行100:设备层与web平台通信故障101:基站与设备层通信故障300:ARM与AP模块串口通信故障400：GPS同步异常401：GPS串口通信异常500：射频模块初始化失败501：射频模块发送异常600：电池电压低以下表示恢复原因:1000000:复位1000001:正常恢复 |
|  | msgType | 定位信息类型 | int型,请忽略掉整型数最高位的0,只是为了排版整齐0表示无定位信息21002：进程号(进程故障)21003：AP模块编号(链路故障)21005：AP模块编号(模块故障) |
|  | msgValue | 定位信息值 | int型具体含义由定位信息类型定义 |

### 返回示例

```
{
  "msgType":"real",
  "msgEncrypt":"none",
  "apTime":1599544012,
  "msgDirect":"report",
  "msgId":0,
  "msgParam":{
      "devType":2,
      "subCmd":"alarm",
      "devUid":"0000000b",
      "maybeReason":1000000,
      "msgType":0,
      "warnLevel":0,
      "warnNum":1001,
      "dataType":1,
      "serverIp":"",
      "msgValue":0
  },
  "apUid":"0000000b",
  "msgUid":"ffff0124",
  "msgPriority":"normal",
  "msgCmd":"ap",
  "deviceAlias":"设备的别名-1",
  "deviceaddr":"福建省厦门市湖里区华荣路30-42"
}
```

---

### 特殊推送

---

#### 终端、中继上行数据解析

### topic说明：

```
获取单企业下设备信息： {api_key}/jll/property/{deviceMold}/{deviceId}/updata
获取单企业下所有设备信息： {api_key}/jll/property/{deviceMold}/+/updata
```

### 返回参数说明

注:parsedData数据中的nameEn目前只有VTC01/VTD10/VTD01/VSS01/TD01/MCZ1ZT设备才有完整的翻译

| root | dataType | description | value |
| --- | --- | --- | --- |
| deviceId | String(8) | 设备ID | 四字节16进制值小写 |
| deviceMold | String | 设备类型 | ms：终端mote：中继 |
| deviceaddr | String | 设备地址 | 平台的设备地址 |
| deviceAlias | String | 设备别名 | 平台的设备别名 |
| companyCode | String | 企业编码 | 平台的企业编码 |
| deviceType | String | 传感器类型 |  |
| deviceCode | Int | 传感器类型编码 |  |
| deviceVersion | Int | 传感器软件版本号 |  |
| dataDetail | String | 解析后数据 | json格式详情见《传感器应用层上行数据说明》 |
| parsedData | JsonObject | 解析后数据 | json格式详情见《传感器应用层上行数据说明》 |
| data | String | 解析前数据 |  |
| pid | String(32) | 特殊识别码pid | onenet平台对接用 |
| accessKey | String(64) | 特殊识别码pkey | onenet平台对接用 |
| upTime | Long | 推送时间毫秒级时间戳 |  |

### 返回示例

```
{
  "companyCode":"fd5c1589215abf5bc94520aac741c1ad",
  "deviceType":"双模车检器-CPS2ZT",
  "data":"fdfe01031e63001f5ebabd310200170236018300100dc61bcb08800e0300010267fe22000c0007",
  "dataDetail":"{\"acquisitionCycle\":null,\"alarmCycle\":null,\"alarmType\":null,\"clearAlarmThreshold\":null,\"clearAlarmType\":null,\"completeData\":\"resp,心跳周期: 4min\",\"dataStatus\":\"resp\",\"enableStatus\":null,\"header\":\"10\",\"heartCycle\":{\"name\":\"心跳周期\",\"unit\":\"min\",\"value\":4},\"lowerThreshold\":null,\"temperature\":null,\"upperThreshold\":null,\"versionNumber\":\"\"}",
  "parsedData":{
          "acquisitionCycle": null,
          "alarmCycle": null,
          "alarmType": null,
          "clearAlarmThreshold": null,
          "clearAlarmType": null,
          "completeData": "resp,心跳周期: 4min",
          "dataStatus": "resp",
          "enableStatus": null,
          "header": "10",
          "heartCycle": {
              "name": "心跳周期",
              "nameEn": "heart cycle",
              "unit": "min",
              "value": 4
          },
          "lowerThreshold": null,
          "temperature": null,
          "upperThreshold": null,
          "versionNumber": ""
      },
  "pid":"",
  "dataFlag":0,
  "deviceCode":5001,
  "deviceAlias":"地下车库001",
  "deviceVersion":0,
  "deviceId":"0000000f",
  "upTime":1599548506710,
  "deviceaddr":"",
  "accessKey":"",
  "deviceMold":"ms"
}
```

---

#### 设备信息

### topic说明：

```
{apiKey}/jll/property/{deviceType}/{deviceId}/deviceInfo
```

### 返回参数说明

| root | dataType | description | value |
| --- | --- | --- | --- |
| deviceId | string | 设备ID |  |
| optType | int | 操作类型 | 1-新增2-修改3-删除 |
| deviceType | string | 设备类型 | ap: 基站mote: 中继ms: 终端 |
| alias | String | 设备别名 |  |
| sensorTypeCode | int | 设备型号编码 |  |
| sensorTypeName | string | 设备型号名称 |  |
| authKey | string | 设备鉴权密钥 | deviceType为ms/mote时有效 |
| keeloqKey | string | 设备加解密密钥 | deviceType为ms/mote时有效 |
| armKey | string | 核心板鉴权密钥 | deviceType为ap时有效 |
| appVersion | string | 应用版本 |  |
| addr | String | 地址 |  |
| longitude | float | 经度 |  |
| latitude | float | 纬度 |  |
| optTime | Long | 变更时间秒级时间戳 |  |

### 返回示例

```
{
  "deviceType":"ms",
  "authKey":"",
  "appVersion":"0",
  "sensorTypeName":"PM2.5感应器-PMO1ZT",
  "latitude":"31.32813",
  "deviceId":"00000002",
  "optType":2,
  "alias":"00000002",
  "sensorTypeCode":2,
  "armKey":"",
  "addr":"上海市嘉定区蕰北路",
  "optTime":1599549131,
  "keeloqKey":"",
  "longitude":"121.313221"
}
```

---

#### 设备低电

### topic说明：

```
{apiKey}/jll/property/{deviceType}/{deviceId}/lowBattery
```

### 返回参数说明

| root | dataType | description | value |
| --- | --- | --- | --- |
| deviceId | string | 设备ID | ​ |
| deviceType | string | 设备类型 | ap: 基站mote: 中继ms: 终端 |
| batteryValue | float | 电量值 | ​ |
| upTime | long | 告警时间秒级时间戳 | ​ |
| deviceaddr | String | 设备地址 | 平台的设备地址 |
| deviceAlias | String | 设备别名 | 平台的设备别名 |

### 返回示例

```
{
  "deviceType":"ms",
  "upTime":1599549252,
  "batteryValue":"2.02",
  "deviceId":"0000000f",
  "deviceAlias":"地下车库001",
  "deviceaddr":"福建省厦门市集美区88号"
}
```

---

