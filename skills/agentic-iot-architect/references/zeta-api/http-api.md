# ZETA Server HTTP Restful API Reference

ZiFiSense ZETA 網管平台（ZETA Server）が提供する HTTP サービスクライアントAPIのリファレンス仕様書です。

## HTTP服务接口

---

### 使用准备

# 请求地址

```
● 云平台国内：https://cn-apis.zifisense.com/
国外：https://en-apis.zifisense.com/
● 独立部署http://ip:25455/
```

## 示例代码

```
https://github.com/zifisense/zeta-http-sdk.git
```

# 获取ACCESS_TOKEN

## 简要描述

根据apikey和secretkey，获取接口调用access_token；获取的token有效期固定2小时，过期后需要重新获取
认证用户名：api_key(企业编码) 来源于ZETA 信息管理平台->系统管理->企业管理->企业信息的企业编码
认证密码：api_secret(企业密钥) 来源于ZETA 信息管理平台->系统管理->企业管理->企业信息的企业密钥

## 请求URL

```

/teamcms/ws/auth_v2/auth_token/query/getWanAccessToken?api_key={API_KEY}&signal=签名值&request_time={REQUEST_TIME}
```

## 请求方式

GET
​

## 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

## 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| signal | True | string | api_key使用(secret_key+request_time直接拼接)做HmacSHA1签名，签名代码参考附录 |
| request_time | True | long | 请求时间，10位秒级时间戳 ；与服务器时差3分钟内请求有效 |

## 请求示例

### 签名示例

```
参数：
api_key = "a4aabf712bfed2529121063433ece0ef"
secret_key = "416e23e82c703e5984b4afa071cc3775"
request_time = 1645068740

签名参数示例：
待签名内容：a4aabf712bfed2529121063433ece0ef
签名key：  416e23e82c703e5984b4afa071cc37751645068740

请求URL示例：
http://ip:25455/teamcms/ws/auth_v2/auth_token/query/getWanAccessToken?api_key=a4aabf712bfed2529121063433ece0ef&signal=6138d59f29a50adc1b20a560f560bc264f196446&request_time=1645068740
```

### 报文示例

```
GET /teamcms/ws/auth_v2/auth_token/query/getWanAccessToken?api_key=a4aabf712bfed2529121063433ece0ef&signal=6138d59f29a50adc1b20a560f560bc264f196446&request_time=1645068740 HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

## 返回参数说明

| 参数 | 类型 | 是否必须 | 描述 |
| --- | --- | --- | --- |
| access_token | True | String(32) | Access_token认证码(有效期固定2小时) |

## 返回示例

正确时返回

```
{
    "data":[
        {
            "access_token":"4bf21b8e6b7c4c02981dea00fd4b4227"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

# 返回结果说明

## 返回参数说明

| 参数 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| data | Array | True | 执行正确时的返回数据查询操作：返回数据结果列表控制操作：返回指令的消息序号 |
| errmsg | String | True | 执行错误时的错误说明 |
| status | Int | True | 接口执行，返回码 |
| ts | Long | True | 返回时间：秒级unix时间戳 |

## 返回码status说明

| 返回码 | 说明 |
| --- | --- |
| -1 | 服务器内部错误，请稍后重试 |
| 0 | 请求成功，正确返回 |
| 10000 | 认证失败，用户名或者密码错误 |
| 10001 | 请求参数错误 |
| 10002 | 不包含access_token参数 |
| 10003 | Access_token过时或者错误 |
| 10004 | 指令下发失败 |

# 签名Java源码

```
import java.security.InvalidKeyException;  
import java.security.NoSuchAlgorithmException;  
import javax.crypto.Mac;  
import javax.crypto.spec.SecretKeySpec; 

public class HMACSHAHelper {
    private static final String HMAC_SHA1 = "HmacSHA1";
    /**
     * 生成签名数据
     * 
     * @param data 待加密的数据   这里为api_key
     * @param key  加密使用的key  这里为secret_key+request_time
     * @return 生成十六进制字符串 
     * @throws InvalidKeyException
     * @throws NoSuchAlgorithmException
     */
    public static String getSHA1Signature(byte[] data, byte[] key) throws InvalidKeyException, NoSuchAlgorithmException {
        SecretKeySpec signingKey = new SecretKeySpec(key, HMAC_SHA1);
        Mac mac = Mac.getInstance(HMAC_SHA1);
        mac.init(signingKey);
        byte[] rawHmac = mac.doFinal(data);
        return CommonUtil.bytesToHexString(rawHmac);
    }
}
```

# CommonUtil工具类

```
public class CommonUtil {
    /**
     * byte数组转字符串   
     * @param src
     * @return
     */
    public static String bytesToHexString(byte[] src){   
        StringBuilder stringBuilder = new StringBuilder("");   
        if (src == null || src.length <= 0) {   
            return null;   
        }   
        for (int i = 0; i < src.length; i++) {   
            int v = src[i] & 0xFF;   
            String hv = Integer.toHexString(v);   
            if (hv.length() < 2) {   
                stringBuilder.append(0);   
            }   
            stringBuilder.append(hv);   
        }   
        return stringBuilder.toString();   
    }   
}
```

---

### 终端

---

#### 获取设备列表

### 简要描述

获取所属企业及其下级企业的终端设备列表
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{api_key}/getMsList?access_token={ACCESS_TOKEN}
```
​

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ms/query/07157af150494fccf8458b20ec6989c1/getMsList?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110"
        },
        {
            "uid":"ab511119"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

### 备注

更多返回错误代码请看接入指南->返回结果说明->返回码status说明

---

#### 获取设备详情

### 简要描述

获取指定终端设备详情
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsDetail?access_token={ACCESS_TOKEN}
```

### 请求方式

GET

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ms/query/abcd1110/getMsDetail?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String | 设备ID |
| alias | True | String | 终端别名 |
| longitude | True | Decimal | 经度 |
| latitude | True | Decimal | 纬度 |
| addr | True | String | 地址 |
| companyname | True | String | 企业名称 |
| authkey | True | String(8) | 鉴权密钥 |
| keeloqKey | True | String(16) | 设备加解密密钥 |
| devicetype | True | String | 终端类型 |
| devCode | True | Int | 终端类型编码 |
| devVersion | True | Int | 设备版本号 |
| warnflag | True | Int | 告警开关0：告警；1：不告警 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110",
            "alias":"电视",
            "longitude":101.125,
            "latitude":45.202,
            "addr":"福建厦门集美海凤路106号顶斌大厦",
            "companyname":"厦门纵行信息科技有限公司",
            "authkey":"2bf13ad1",
            "keeloqKey":"2aaefa4e45ae54df1",
            "devicetype":"水压计",
            "devCode":6,
            "devVersion":0,
            "warnflag":0
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取设备状态

### 简要描述

获取指定终端设备状态
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsStatus?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ms/query/abcd1110/getMsStatus?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String | 设备ID |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| moteuid | True | String | 中继ID |
| netid | True | String | 网络号 |
| regnumber | True | int | 注册序号 |
| regreson | True | String | 注册原因:reboot:重启send:发送数据失败重注册request:下行操作重注册recycle:上级网络号回收重注册adjust:网络调整重注册sync:失去同步重注册resend:重发网络号unreg:上级非注册态重注册cache:上级缓存失败重注册outsync:广播失步重注册 |
| softversion | True | String | 软件版本 |
| status | True | int | 注册状态：1：注册成功2：注册失败3：过期无效 |
| type | True | int | 注册类型：1：注册到基站2：注册到中继 |
| battery | True | int | 电量:（x+150）/100，单位：v |
| uprssi | True | int | 上行RSSI，实际为负值 |
| downrssi | True | int | 下行RSSI，实际为负 |
| downmode | True | int | 下行模式：off：关闭下行sniff-on：实时下行sniff-off：ack下行zetag设备为序号值 |
| sleepmode | True | String | 注册休眠模式on:打开off:关闭 |
| updata | True | String | 上行数据 |
| downdata | True | String | 下行数据 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| lasttime | True | Datetime | 最新下行数据时间(服务器时区时间) |
| lasttimeStamp | True | long | 最新下行数据时间秒级时间戳 |
| linktime | True | Datetime | 最新注册时间(服务器时区时间) |
| linktimeStamp | True | long | 最新注册时间秒级时间戳 |
| heartbeattime | True | Datetime | 最新心跳时间(服务器时区时间) |
| heartbeattimeStamp | True | long | 最新心跳时间秒级时间戳 |
| uploadtime | True | Datetime | 最新上行数据时间(服务器时区时间) |
| uploadtimeStamp | True | long | 最新上行数据时间秒级时间戳 |
| warning | True | int | 告警状态：0：正常1：告警中 |
| offlinemb | True | int | 离线/在线标志：0：在线1：离线 |
| downflag | True | int | 下行状态：-1：待执行0：成功1：失败 |
| upgradestatus | True | int | 升级状态：0：未升级1：已启动升级，待反馈结果2：升级成功3：升级失败 |
| upgradetime | True | Datetime | 最新升级时间(服务器时区时间) |
| upgradetimeStamp | True | long | 最新升级时间秒级时间戳 |
| groupid1 | True | int | 组号1 |
| groupid2 | True | int | 组号2 |
| groupid3 | True | int | 组号3 |
| groupid4 | True | int | 组号4 |
| groupid5 | True | int | 组号5 |
| reregistrationAlarm | True | int | 重注册次数过多告警状态：0：正常1：告警 |
| reconnected | True | int | 待重连状态：0：正常注册连接1：待重连 |
| regFailRate | True | int | 注册失败率 |
| uplinkLoseRate | True | int | 上行失败率 |
| downlinkLoseRate | True | int | 下行失败率 |
| batteryAlarm | True | int | 电量告警状态：0：正常1：告警 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"ABCDE1110",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "moteuid":"E0000011",
            "netid":"0120",
            "regnumber":1,
            "regreson":"reboot",
            "softversion":"2",
            "status":1,
            "type":2,
            "battery":3.202,
            "uprssi":32,
            "downrssi":25,
            "downmode":"sniff-on",
            "updata":"a1110",
            "sleepmode":"on",
            "downdata":"0f0212",
            "aptime":"2016-10-10 12:02:12",
            "aptimeStamp":1476072132,
            "lasttimeStamp":1476072132,
            "linktimeStamp":1476158532,
            "heartbeattimeStamp":1478752332,
            "uploadtimeStamp":1476158532,
            "lasttime":"2016-10-10 12:02:12",
            "linktime":"2016-10-11 12:02:12",
            "heartbeattime":"2016-11-10 12:32:12",
            "uploadtime":"2016-10-11 12:02:12",
            "warning":1,
            "offlinemb":1,
            "downflag":0,
            "upgradestatus":1,
            "upgradetime":"2016-10-11 12:02:12",
            "upgradetimeStamp":1476158532,
            "groupid1":11,
            "groupid2":12,
            "groupid3":13,
            "groupid4":14,
            "groupid5":15,
            "reregistrationAlarm":1,
            "reconnected":1,
            "regFailRate":6,
            "uplinkLoseRate":7,
            "downlinkLoseRate":8
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取上传数据

### 简要描述

根据时间获取指定终端上传数据历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsUploadDataByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/query/00000001/getMsUploadDataByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String(8) | 基站主控ID |
| apuid | True | String(8) | 基站ID |
| updata | True | String | 上行数据内容 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"254adf55fa45a8f548f45a548d566a45",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "updata":"abcd1123",
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        },
        {
            "objectid":"28f548f45a548d566a45",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "updata":"abcd1123",
            "aptime":"2016-10-10 11:25:23",
            "aptimeStamp":1476069923,
            "uptimeStamp":1476069925,
            "uptime":"2016-10-10 11:25:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取注册信息

### 简要描述

根据时间获取指定终端注册历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsRegisterByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/query/00000001/getMsRegisterByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String(8) | 基站主控ID |
| apuid | True | String(8) | 基站ID |
| moteuid | True | String(8) | 中继ID |
| netid | True | String(4) | 网络号 |
| regnumber | True | Int | 注册序号 |
| regreson | True | String | 注册原因:reboot:重启send:发送数据失败重注册request:下行操作重注册recycle:上级网络号回收重注册adjust:网络调整重注册sync:失去同步重注册resend:重发网络号unreg:上级非注册态重注册cache:上级缓存失败重注册outsync:广播失步重注册 |
| softversion | True | String | 软件版本 |
| status | True | Int | 注册状态：1：注册成功2：注册失败3：过期无效 |
| type | True | Int | 注册类型：1：注册到基站2：注册到中继 |
| aptime | True | Int | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s5484265f",
            "msguid":"fbcd1110",
            "apuid":"dbcd1119",
            "moteuid":"f04d1110",
            "netid":"abcd",
            "regnumber":"20",
            "regreson":"unreg",
            "softversion":"v1.0.25",
            "status":1,
            "type":1,
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        },{
            "objectid":"64589841f5484a5484s5484s548411b0",
            "msguid":"fbcd1110",
            "apuid":"dbcd1119",
            "moteuid":"f04d1110",
            "netid":"abcd",
            "regnumber":"21",
            "regreson":"unreg",
            "softversion":"v1.0.25",
            "status":1,
            "type":1,
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取心跳数据

### 简要描述

根据时间获取指定终端心跳历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsHeartBeatByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/query/00000001/getMsHeartBeatByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| battery | True | int | 电量:（x+150）/100，单位：v |
| uprssi | True | int | 上行RSSI，实际为负值 |
| downrssi | True | int | 下行RSSI，实际为负 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | long | 上报时间秒级时间戳 |
| sleepmode | True | String | 注册休眠模式on:打开off:关闭 |
| regFailRate | True | int | 注册失败率 |
| uplinkLoseRate | True | int | 上行失败率 |
| downlinkLoseRate | True | int | 下行失败率 |
| zetagProtocol | True | String | zetag版本号 |
| frameType | True | int | 帧类型 |
| zetagData | True | String | Zetag数据 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "battery":58.52,
            "uprssi":-31,
            "downrssi":-25,
            "downmode":"sniff-on",
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":"1476069743",
            "uptimeStamp":"1476069745",
            "sleepmode":"off",
            "uptime":"2016-10-10 11:22:25",
            "regFailRate":"6",
            "uplinkLoseRate":"7",
            "downlinkLoseRate":"8",
            "zetagProtocol":"10",
            "frameType":"23",
            "zetagData":"0071431805940b76006ca70000"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取下行指令记录

### 简要描述

根据时间获取指定终端下行指令记录
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getMsCtlHistoryByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/query/00000001/getMsCtlHistoryByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| type | True | int | 指令类型1修改级别、2回收、3关停、4开启、5重启、6重注册、7请求时钟同步、8透传数据、9组播、10广播、11新增分组、12终端移出分组、13删除分组、14获取分组信息、15设置设备鉴权信息、16下行模式选择、17休眠模式、18设置载波侦听信号强度阈值、19复位APP端程序、20注册指定基站、21注册指定中继、22清除指定注册列表、23下行开关时段配置、24清除归属黑名单、25长休眠周期 |
| status | True | int | 执行状态300:待执行301:执行成功302:执行失败303:过期无效0:发送成功32:ms找不到map33:map找不到netid34:ms找不到ap35:map找不到ap36:ap找不到ip、port17:服务器到基站后端失败18:基站后端到基站前端失败19:设备无反馈1:基站查无此中继2:基站下发多次失败3:一级中继查无此中继4:一级中继下发多次失败5:二级中继查无此中继6:二级中继下发多次失败7:三级中继查无此中继8:三级中继下发多次失败9:下发到终端多次失败10:下发到终端上级设备11:下发到终端超时12: 中继串口无响应15:无下行反馈64:透传数据错误65:旧版指令错误66:旧版本协议错误68:新版指令错误69:新版本版本错误70:新版本协议错误71:下行所在ARM离线10000:数据校验不合法10001:cmd命令找不到10002:操作类型 subType 命令不合法10003:主命令 msgCmd 命令不合法10004:子命令subCmd 命令不合法10005:协议类型不存在10006:打印等级不存在10007:设备类型不存在10008:基站模块未启动成功10009:中继未注册成功10010:终端未注册成功 |
| downtime | True | int | 指令下发时间(服务器时区时间) |
| downtimeStamp | True | int | 指令下发时间秒级时间戳 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | long | 上报时间秒级时间戳 |
| downdata | True | String | 下行数据域指令内容 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "uid":"00000001",
            "msguid":"abcd1112",
            "apuid":"abcd1119",
            "type":1,
            "status":300,
            "downtime":"2016-10-10 12:45:48",
            "aptime":"2016-10-10 12:46:48",
            "downtimeStamp":"1476074748",
            "aptimeStamp":"1476074808",
            "uptimeStamp":"1476074868",
            "uptime":"2016-10-10 12:47:48",
            "downdata":"1110"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本单播控制

### 简要描述

对指定终端透传数据下行
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/control/{uid}/newCtrlMsUnicast?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String(2n) | 见【终端下行数据域】说明 |

### 终端下行数据域

| 下行指令 | 协议类型 | 说明 |
| --- | --- | --- |
| 修改级别 | P/S/Lite | 0100+级别号（1个字节hex） |
| 回收 | P/S/Lite | 020000 |
| 关停 | P/S/Lite | 030000 |
| 开启 | P/S/Lite | 0400+开启时长（月）（1个字节hex） |
| 重启 | P/S/Lite | 050000 |
| 重注册 | P/S/Lite | 060000 |
| 请求时钟同步 | P | 070000 |
| 鉴权失败 | P/S/Lite | 080000 |
| 设置组号 | Lite | 0900+组号（5字节hex） |
| 下行模式设置 | P/S | 090101 表示sniff_on(实时下行)090102 表示sniff_off(ACK下行) |
| 打开或关闭注册休眠功能 | P/S/Lite | 0A0001 表示打开0A0000 表示关闭 |
| 设置载波侦听信号强度阈值 | Lite | 0B00+阈值(1个字节hex) |
| 控制硬件复位App端程序 | P/S/Lite | 0C0000 |
| 指定注册基站mac[3..0] | P/S | 0D00+基站ID(4个字节hex) |
| 指定注册中继mac[n..0] | P/S/Lite | 0E00+n个中继ID(设置终端注册指定的N个中继mac(对于zeta-p和zeta-lite: 1≤N≤10；对于zeta-s: N=1)) |
| 清除指定注册列表 | P/S/Lite | 0F0000 |
| 下行开关时段配置 | S | 1000+开启时间(1个字节hex)+结束时间((1个字节hex) |
| 清除归属黑名单 | P/S/Lite | 120000 |
| 设置长休眠周期 | P/S/Lite | 1400+长休眠周期（范围0\3\6\12\24）(1个字节hex) |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/control/00000001/newCtrlMsUnicast?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"data":"889954"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本透传数据

### 简要描述

对指定终端透传数据下行(R2版本的ZETA-P、ZETA-S协议的的设备不推荐下发f开头的数据)
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/control/{uid}/newCtrlMsPassthrough?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String(2n) | n个字节hex |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/control/00000001/newCtrlMsPassthrough?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"data":"889954"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":15466
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取应用数据历史

### 简要描述

根据时间获取指定终端应用数据记录注:parsedData数据中的nameEn目前只有VTC01/VTD10/VTD01/VSS01/TD01/MCZ1ZT设备才有完整的翻译
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ms/query/{uid}/getAppDataByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ms/query/00000001/getAppDataByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| rawAppData | True | String | 原始数据 |
| parsedAppData | True | String | 解析后的数据，各字段含义参考【传感器应用层上行数据说明】文档 |
| parsedData | True | JSONString | 解析后的数据，各字段含义参考【传感器应用层上行数据说明】文档 |
| upTime | True | Long | 上报时间，秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110",
            "rawAppData":"100004",
            "parsedAppData":"{"acquisitionCycle":null,"alarmCycle":null,"alarmType":null,"clearAlarmThreshold":null,"clearAlarmType":null,"completeData":"resp,心跳周期: 4min","dataStatus":"resp","enableStatus":null,"header":"10","heartCycle":{"name":"心跳周期","unit":"min","value":4},"lowerThreshold":null,"temperature":null,"upperThreshold":null,"versionNumber":""}",
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
            }
            "upTime":"1594289462"
        },
        {
            "uid":"ab511119",
            "rawAppData":"1209",
            "parsedAppData":"{"acquisitionCycle":null,"alarmCycle":{"name":"上报告警周期","unit":"min","value":9},"alarmType":null,"clearAlarmThreshold":null,"clearAlarmType":null,"completeData":"resp,上报告警周期: 9min","dataStatus":"resp","enableStatus":null,"header":"12","heartCycle":null,"lowerThreshold":null,"temperature":null,"upperThreshold":null,"versionNumber":""}",
            "parsedData":{
                "acquisitionCycle": null,
                "alarmCycle": {
                    "name": "上报告警周期",
                    "nameEn": "alarm cycle",
                    "unit": "min",
                    "value": 9
                },
                "alarmType": null,
                "clearAlarmThreshold": null,
                "clearAlarmType": null,
                "completeData": "resp,上报告警周期: 9min",
                "dataStatus": "resp",
                "enableStatus": null,
                "header": "12",
                "heartCycle": null,
                "lowerThreshold": null,
                "temperature": null,
                "upperThreshold": null,
                "versionNumber": ""
            }
            "upTime":"1594299462"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

### 中继

---

#### 获取设备列表

### 简要描述

获取所属企业及其下级企业的中继设备列表
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{api_key}/getMoteList?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_mote/query/07157af150494fccf8458b20ec6989c1/getMoteList?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110"
        },
        {
            "uid":"ab511119"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

### 备注

更多返回错误代码请看接入指南->返回结果说明->返回码status说明

---

#### 获取设备详情

### 简要描述

获取指定中继设备详情
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteDetail?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_mote/query/abcd1110/getMoteDetail?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String | 设备ID |
| alias | True | String | 别名 |
| longitude | True | Decimal | 经度 |
| latitude | True | Decimal | 纬度 |
| addr | True | String | 地址 |
| companyname | True | String | 企业名称 |
| authkey | True | String(8) | 鉴权密钥 |
| keeloqKey | True | String(16) | 设备加解密密钥 |
| devicetype | True | String | 中继类型 |
| devCode | True | Int | 中继类型编码 |
| devVersion | True | Int | 设备版本号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110",
            "alias":"电视",
            "longitude":101.125,
            "latitude":45.202,
            "addr":"福建厦门集美海凤路106号顶斌大厦",
            "companyname":"厦门纵行信息科技有限公司",
            "authkey":"2bf13ad1",
            "keeloqKey":"2aaefa4e45ae54df1",
            "devicetype":"水压计",
            "devCode":6,
            "devVersion":0,
            "warnflag":0
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取设备状态

### 简要描述

获取指定中继设备状态
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteStatus?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_mote/query/abcd1110/getMoteStatus?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String | 设备ID |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| netid | True | String | 网络号 |
| regnumber | True | int | 注册序号 |
| regreson | True | String | 注册原因:reboot:重启send:发送数据失败重注册request:下行操作重注册recycle:上级网络号回收重注册adjust:网络调整重注册sync:失去同步重注册resend:重发网络号unreg:上级非注册态重注册cache:上级缓存失败重注册outsync:广播失步重注册optimize:网络优化重注册 |
| flow | True | int | 流量 |
| softversion | True | String | 软件版本 |
| status | True | int | 注册状态：1：注册成功2：注册失败3：过期无效 |
| battery | True | int | 电量:（x+150）/100，单位：v |
| uprssi | True | int | 上行RSSI，实际为负值 |
| downrssi | True | int | 下行RSSI，实际为负 |
| updata | True | String | 上行数据 |
| downdata | True | String | 下行数据 |
| sleepmode | True | String | 注册休眠模式on:打开off:关闭 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| lasttime | True | Datetime | 最新下行数据时间(服务器时区时间) |
| lasttimeStamp | True | long | 最新下行数据时间秒级时间戳 |
| linktime | True | Datetime | 最新注册时间(服务器时区时间) |
| linktimeStamp | True | long | 最新注册时间秒级时间戳 |
| heartbeattime | True | Datetime | 最新心跳时间(服务器时区时间) |
| heartbeattimeStamp | True | long | 最新心跳时间秒级时间戳 |
| uploadtime | True | Datetime | 最新上行数据时间(服务器时区时间) |
| uploadtimeStamp | True | long | 最新上行数据时间秒级时间戳 |
| warning | True | int | 告警状态：0：正常1：告警中 |
| offlinemb | True | int | 离线/在线标志：0：在线1：离线 |
| downflag | True | int | 下行状态：-1：待执行0：成功1：失败 |
| upgradestatus | True | int | 升级状态：0：未升级1：已启动升级，待反馈结果2：升级成功3：升级失败 |
| upgradetime | True | Datetime | 最新升级时间(服务器时区时间) |
| upgradetimeStamp | True | long | 最新升级时间秒级时间戳 |
| groupid1 | True | int | 组号1 |
| groupid2 | True | int | 组号2 |
| groupid3 | True | int | 组号3 |
| groupid4 | True | int | 组号4 |
| groupid5 | True | int | 组号5 |
| reregistrationAlarm | True | int | 重注册次数过多告警状态：0：正常1：告警 |
| reconnected | True | int | 待重连状态：0：正常注册连接1：待重连 |
| regFailRate | True | int | 注册失败率 |
| uplinkLoseRate | True | int | 上行失败率 |
| downlinkLoseRate | True | int | 下行失败率 |
| batteryAlarm | True | int | 电量告警状态：0：正常1：告警 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"ABCDE1110",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "netid":"0120",
            "regnumber":1,
            "regreson":"reboot",
            "flow":51,
            "softversion":"2",
            "status":1,
            "battery":3.20,
            "uprssi":32,
            "downrssi":25,
            "updata":"a1110",
            "downdata":"0f0212",
            "sleepmode":"on",
            "aptime":"2016-10-10 12:02:12",
            "aptimeStamp":1476072132,
            "lasttimeStamp":1476072132,
            "linktimeStamp":1476158532,
            "heartbeattimeStamp":1478752332,
            "uploadtimeStamp":1476158532,
            "lasttime":"2016-10-10 12:02:12",
            "linktime":"2016-10-11 12:02:12",
            "heartbeattime":"2016-11-10 12:32:12",
            "uploadtime":"2016-10-11 12:02:12",
            "warning":1,
            "offlinemb":1,
            "downflag":0,
            "upgradestatus":1,
            "upgradetime":"2016-10-11 12:02:12",
            "upgradetimeStamp":1476158532,
            "groupid1":11,
            "groupid2":12,
            "groupid3":13,
            "groupid4":14,
            "groupid5":15,
            "reregistrationAlarm":1,
            "reconnected":1,
            "regFailRate":6,
            "uplinkLoseRate":7,
            "downlinkLoseRate":8
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取上传数据

### 简要描述

根据时间获取指定中继上传数据历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteUploadDataByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/query/00000001/getMoteUploadDataByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String(8) | 基站主控ID |
| apuid | True | String(8) | 基站ID |
| updata | True | String | 上行数据内容 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"254adf55fa45a8f548f45a548d566a45",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "updata":"abcd1123",
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        },
        {
            "objectid":"28f548f45a548d566a45",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "updata":"abcd1123",
            "aptime":"2016-10-10 11:25:23",
            "aptimeStamp":1476069923,
            "uptimeStamp":1476069925,
            "uptime":"2016-10-10 11:25:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取注册信息

### 简要描述

根据时间获取指定中继注册历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteRegisterByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/query/00000001/getMoteRegisterByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String(8) | 基站主控ID |
| apuid | True | String(8) | 基站ID |
| netid | True | String(4) | 网络号 |
| regnumber | True | Int | 注册序号 |
| regreson | True | String | 注册原因:reboot:重启send:发送数据失败重注册request:下行操作重注册recycle:上级网络号回收重注册adjust:网络调整重注册sync:失去同步重注册resend:重发网络号unreg:上级非注册态重注册cache:上级缓存失败重注册outsync:广播失步重注册optimize:网络优化重注册 |
| softversion | True | String | 软件版本 |
| status | True | Int | 注册状态：1：注册成功2：注册失败3：过期无效 |
| aptime | True | Int | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s5484265f",
            "msguid":"fbcd1110",
            "apuid":"dbcd1119",
            "netid":"abcd",
            "regnumber":"20",
            "regreson":"unreg",
            "softversion":"v1.0.25",
            "status":1,
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        },{
            "objectid":"64589841f5484a5484s5484s548411b0",
            "msguid":"fbcd1110",
            "apuid":"dbcd1119",
            "netid":"abcd",
            "regnumber":"21",
            "regreson":"unreg",
            "softversion":"v1.0.25",
            "status":1,
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":1476069743,
            "uptimeStamp":1476069745,
            "uptime":"2016-10-10 11:22:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取心跳数据

### 简要描述

根据时间获取指定中继心跳历史

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteHeartBeatByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/query/00000001/getMoteHeartBeatByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| battery | True | int | 电量:（x+150）/100，单位：v |
| uprssi | True | int | 上行RSSI，实际为负值 |
| downrssi | True | int | 下行RSSI，实际为负 |
| flow | True | int | 流量 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | long | 上报时间秒级时间戳 |
| sleepmode | True | String | 注册休眠模式on:打开off:关闭 |
| regFailRate | True | int | 注册失败率 |
| uplinkLoseRate | True | int | 上行失败率 |
| downlinkLoseRate | True | int | 下行失败率 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "msguid":"F0000011",
            "apuid":"D0000011",
            "battery":58.52,
            "uprssi":-31,
            "downrssi":-25,
            "flow":56,
            "aptime":"2016-10-10 11:22:23",
            "aptimeStamp":"1476069743",
            "uptimeStamp":"1476069745",
            "sleepmode":"off",
            "uptime":"2016-10-10 11:22:25",
            "regFailRate":"6",
            "uplinkLoseRate":"7",
            "downlinkLoseRate":"8"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取下行指令记录

### 简要描述

根据时间获取指定中继下行指令记录
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/query/{uid}/getMoteCtlHistoryByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/query/00000001/getMoteCtlHistoryByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| type | True | int | 1重启指令、2重注册指令、3发心跳包、4请求时钟同步、5回收特定网络号、6关闭中继被注册、回复ack（部分）、转发数据功能、7开启中继被注册、回复ack（部分）、转发数、8单播、9组播、10广播、11新增分组、12终端移出分组、13删除分组、14获取分组信息、15透传数据、16设置设备鉴权信息、17设置组号、18设置发射功率、19切换mote模式、20设置注册基站、21设置设置一级中继、22休眠模式、23设置载波监听信号强度阈值、24设置广播注册起点、25清除指定注册列表、26复位app端程序、27清除归属黑名单、28清除鉴权失败中继记录、29清除鉴权失败终端记录 |
| status | True | int | 执行状态300:待执行301:执行成功302:执行失败303:过期无效0:发送成功32:ms找不到map33:map找不到netid34:ms找不到ap35:map找不到ap36:ap找不到ip、port17:服务器到基站后端失败18:基站后端到基站前端失败19:设备无反馈1:基站查无此中继2:基站下发多次失败3:一级中继查无此中继4:一级中继下发多次失败5:二级中继查无此中继6:二级中继下发多次失败7:三级中继查无此中继8:三级中继下发多次失败9:下发到终端多次失败10:下发到终端上级设备11:下发到终端超时12: 中继串口无响应15:无下行反馈64:透传数据错误65:旧版指令错误66:旧版本协议错误68:新版指令错误69:新版本版本错误70:新版本协议错误71:下行所在ARM离线10000:数据校验不合法10001:cmd命令找不到10002:操作类型 subType 命令不合法10003:主命令 msgCmd 命令不合法10004:子命令subCmd 命令不合法10005:协议类型不存在10006:打印等级不存在10007:设备类型不存在10008:基站模块未启动成功10009:中继未注册成功10010:终端未注册成功 |
| downtime | True | int | 指令下发时间(服务器时区时间) |
| downtimeStamp | True | int | 指令下发时间秒级时间戳 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | long | 上报时间秒级时间戳 |
| downdata | True | String | 下行数据域指令内容 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "uid":"00000001",
            "msguid":"abcd1112",
            "apuid":"abcd1119",
            "type":1,
            "status":300,
            "downtime":"2016-10-10 12:45:48",
            "aptime":"2016-10-10 12:46:48",
            "downtimeStamp":"1476074748",
            "aptimeStamp":"1476074808",
            "uptimeStamp":"1476074868",
            "uptime":"2016-10-10 12:47:48",
            "downdata":"1110"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本单播控制

### 简要描述

对指定中继透传数据下行
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/control/{uid}/newCtrlMoteUnicast?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String(2n) | 见【中继下行数据域】说明 |

### 中继下行数据域

| 下行指令 | 协议类型 | 说明 |
| --- | --- | --- |
| 重启 | P/S/Lite | 010000 |
| 重注册 | P/S/Lite | 020000 |
| 发心跳包 | P/S/Lite | 030000 |
| 请求时钟同步 | P | 040000 |
| 回收特定网络号 | P/S/Lite | 0500+子集的ID（1个字节hex） |
| 关停 | P | 060000 |
| 开启 | P | 070000 |
| 鉴权失败 | P/S | 080000 |
| 设置组号，最多可设置5个组号，0xFF为无效组号 | Lite | 0801+组号（5字节hex） |
| 设置发射功率 | S | 0900+设置范围0-7（1个字节hex）,数值0-7对应发射功率实际值为：-11dbm0dbm10dbm15dbm17dbm19dbm20dbm22dbm |
| 切换中继模式 | Lite | 0A0000 表示motea0A0001 表示moteb |
| 设置中继注册指定某个基站 | P/S/Lite | 0B00+基站ID（4个字节hex） |
| 设置二级中继指定注册一级中继 | P/S/Lite | 0C00+n个中继ID（指定注册中继MAC[(N*4-1)..0])ZETA-L：设置二级中继指定注册一级中继1<=N<=10;ZETA-P：1<=N<=10;ZETA-S：N=1） |
| 设置载波监听信号强度阈值 | Lite | 0D00+阈值（0~127，1个字节hex） |
| 设置注册休眠开关 | P/S | 0E0001 表示开0E0000 表示关 |
| 中继广播注册起点 | S | 0F00+起点(范围0~2)（1个字节hex） |
| 复位APP端程序 | Lite | 100000 |
| 清除指定注册列表 | P/S/Lite | 120000 |
| 清除归属黑名单 | P/S/Lite | 130000 |
| 清除鉴权失败中继记录MAC | P/S/Lite | 140000 |
| 清除鉴权失败终端记录MAC | P/S/Lite | 150000 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/control/00000001/newCtrlMoteUnicast?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"data":"889954"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本透传数据

### 简要描述

对指定中继透传数据下行
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_mote/control/{uid}/newCtrlMotePassthrough?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String(2n) | n个字节hex |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_mote/control/00000001/newCtrlMotePassthrough?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"data":"889954"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":15466
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

### 基站

---

#### 获取设备列表

### 简要描述

获取所属企业及其下级企业的基站设备射频UID列表
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{api_key}/getApList?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ap/query/07157af150494fccf8458b20ec6989c1/getApList?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID(射频ID) |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110"
        },
        {
            "uid":"ab511119"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

### 备注

更多返回错误代码请看接入指南->返回结果说明->返回码status说明

---

#### 获取设备详情

### 简要描述

获取指定基站的设备详情
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApDetail?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ap/query/abcd1110/getApDetail?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String | 设备ID |
| armid | True | String | 基站主控ID |
| alias | True | String | 别名 |
| longitude | True | Decimal | 经度 |
| latitude | True | Decimal | 纬度 |
| addr | True | String | 地址 |
| companyname | True | String | 企业名称 |
| modelstatus | True | String | 模块状态正常：normal异常：abnormal |
| comfreq | True | Int | 通信信道频点 |
| protype | True | String | 协议类型zeta-p：ZETA-P模式zeta-s：ZETA-S模式zeta-g：ZETA-G模式zeta-h：ZETA-H模式 |
| modelversion | True | Int | 模块版本 |
| modeluptime | True | Datetime | 模块最新修改时间(服务器时区时间) |
| modeluptimeStamp | True | Long | 模块最新修改时间秒级时间戳 |
| modelinktime | True | Int | 模块最新登陆时间(服务器时区时间) |
| modelinktimeStamp | True | Int | 模块最新登陆时间秒级时间戳 |
| apstatus | True | String | 基站状态online:在线offline:离线 |
| timetype | True | String | 时间类型system：系统时间RTC：实时时钟时间 |
| timezone | True | Int | 时区(-11~+12) |
| devicetime | True | Datetime | 设备时间(服务器时区时间) |
| devicetimeStamp | True | Long | 设备时间秒级时间戳 |
| week | True | Int | 星期:0-6从周日为0开始算 |
| configversion | True | String | 配置文件版本信息 |
| connectmode | True | String | 连接模式eth：以太网gprs：gprs网络 |
| serverip | True | String | 服务器IP |
| serverport | True | Int | 端口号 |
| rebootinterval | True | Int | 自动重启时间间隔-1~65535,单位分钟.-1表示关闭该功能 |
| networkinterval | True | Int | 网络等待时间窗0~255:单位秒,默认为6秒 |
| heartbeatinterval | True | Int | 心跳包间隔0~255:单位分钟,默认为2分钟 |
| version | True | String | 基站版本 |
| hwversion | True | String | 硬件版本 |
| otherinfo | True | String | 其他信息 |
| armlasttime | True | Datetime | 基站主控最新更新时间(服务器时间) |
| armlasttimeStamp | True | Long | 基站主控最新更新时间秒级时间戳 |
| armlinktime | True | Datetime | 基站主控最新登录时间(服务器时间) |
| armlinktimeStamp | True | Long | 基站主控最新登录时间秒级时间戳 |
| armhearttime | True | Datetime | 基站主控最新心跳时间(服务器时间) |
| armhearttimeStamp | True | Long | 基站主控最新心跳时间秒级时间戳 |
| armgprstime | True | Datetime | 最新gprs上报时间(服务器时间) |
| armgprstimeStamp | True | Long | 最新gprs上报时间秒级时间戳 |
| apsignal | True | Int | 信号强度 |
| telnumber | True | Int | SIM卡电话号码 |
| modelmode | True | Int | 模块运行模式 |
| downdata | True | Int | 最新下行数据 |
| armkey | True | Int | 核心板密钥 |
| armUpgraderesult | True | Int | 基站主控升级结果 |
| iccid | True | Int | SIM卡卡号 |
| protocolVersion | True | Int | 基站主控协议版本 |
| downflag | True | Int | 下行状态：-1：待执行0：成功1：失败 |
| modelUpgraderesult | True | String | 基站模块升级结果 |
| chnspace | True | Int | 信道间隔 |
| broadregchn | True | Int | 基站广播注册信息信道 |
| trafficchn | True | Int | 基站业务信道 |
| moteregchn | True | Int | 中继注册信道 |
| motetrafficchn | True | Int | 中继业务信道 |
| motebroadchn | True | Int | 中继广播信道 |
| downtrafficchn | True | Int | 下行业务信道 |
| regtimeslot | True | Int | 基站广播注册信息时隙 |
| freqhopp | True | Int | 是否跳频：1=是跳频2=非跳频 |
| fhgroup | True | Int | 跳频组号 |
| fhrange | True | Int | 跳频范围 |
| transpower | True | Int | 发射功率 |
| gpsstatus | True | String | GPS状态normal:正常disabled:GPS未启用time:GPS获取不到时钟信息pps:GPS获取不到秒脉冲信号 |
| carryMonitor | True | Int | 载波侦听阈值 |
| commRate | True | Int | 通信速率 |
| channelFb1 | True | Int | FB1信道 |
| channelFb2 | True | Int | FB2信道 |
| channelFb3 | True | Int | FB3信道 |
| channelF1 | True | Int | F1信道 |
| maxFrame | True | Int | 最大帧数 |
| maxSubFrame | True | Int | 最大子帧数 |
| gatewayPoint | True | Int | 网关频点 |
| motePoint | True | Int | 中继频点 |
| msPoint | True | Int | 终端频点 |
| gatewaySpeed | True | Int | 网关速率 |
| moteSpeed | True | Int | 中继速率 |
| msSpeed | True | Int | 终端速率 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "uid":"abcd1110",
            "armid":"afcd1110",
            "alias":"电",
            "longitude":101.125,
            "latitude":45.202,
            "addr":"福建厦门集美海凤路106号顶斌大厦",
            "companyname":"厦门纵行信息科技有限公司",
            "modelstatus":"normal",
            "comfreq":3,
            "protype":"zete-s",
            "modelversion":"3",
            "modeluptime":"2016-10-10 15:54:45",
            "modelinktime":"2016-10-10 15:54:45",
            "modeluptimeStamp":1476086085,
            "modelinktimeStamp":1476086085,
            "apstatus":"online",
            "timetype":"RTC",
            "timezone":8,
            "devicetime":"2016-10-10 15:53:21",
            "devicetimeStamp":1476086001,
            "week":1,
            "configversion":"v4.3.4",
            "connectmode":"gprs",
            "serverip":"192.168.0.1",
            "serverport":8824,
            "rebootinterval":0,
            "networkinterval":0,
            "heartbeatinterval":0,
            "version":"",
            "hwversion":"",
            "otherinfo":"",
            "armlasttime":"",
            "armlinktime":"",
            "armhearttime":"",
            "armgprstime":"",
            "armlasttimeStamp":"",
            "armlinktimeStamp":"",
            "armhearttimeStamp":"",
            "armgprstimeStamp":"",
            "apsignal":15,
            "telnumber":"",
            "modelmode":"",
            "downdata":"",
            "armUpgraderesult":"fail",
            "iccid":"89860009089797989795",
            "protocolVersion":"0205",
            "downflag":1,
            "modelUpgraderesult":"success",
            "chnspace":5,
            "broadregchn":210,
            "trafficchn":0,
            "moteregchn":205,
            "motetrafficchn":102,
            "motebroadchn":55,
            "downtrafficchn":56,
            "regtimeslot":5,
            "freqhopp":1,
            "fhgroup":8,
            "fhrange":13,
            "transpower":121,
            "gpsstatus":"pps",
            "carryMonitor":56,
            "commRate":88,
            "channelFb1":7,
            "channelFb2":7,
            "channelFb3":9,
            "channelF1":8,
            "maxFrame":10,
            "maxSubFrame":10,
            "gatewayPoint":55,
            "motePoint":44,
            "msPoint":44,
            "gatewaySpeed":55,
            "moteSpeed":11,
            "msSpeed":22
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取基站分组号

### 简要描述

获取指定基站的分组号
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApGroupNumbers?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ap/query/abcd1110/getApGroupNumbers?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| groupid | True | Int | 组号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "groupid":"abcd1110"
        },
        {
            "groupid":"ab511119"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取基站分组信息

### 要描述

获取指定基站的分组信息
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApGroupMote?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| groupid | True | Int | 组号,范围：1~255,0表示查询全部分组 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_ap/query/abcd1110/getApGroupMote?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| moteuid | True | String(8) | 中继ID |
| groupid1 | True | Int | 组号 |
| groupid2 | True | Int | 组号 |
| groupid3 | True | Int | 组号 |
| groupid4 | True | Int | 组号 |
| groupid5 | True | Int | 组号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "moteuid":"abcd1110",
            "groupid1":12,
            "groupid2":10,
            "groupid3":0,
            "groupid4":0,
            "groupid5":0
        },
        {
            "moteuid":"abcd1111",
            "groupid1":12,
            "groupid2":11,
            "groupid3":0,
            "groupid4":0,
            "groupid5":0
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取注册数据

### 简要描述

根据时间获取指定基站注册历史
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApRegisterByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ap/query/00000001/getApRegisterByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String | 基站主控ID |
| apuid | True | String | 基站ID |
| apsignal | True | int | 信号强度(0-31：对应0-100%；99：表示无法检测；255：表示以太网) |
| softversion | True | int | 软件版本 |
| protype | True | int | 协议类型zeta-p: ZETA-P模式zeta-s: ZETA-S模式zeta-s-litezeta-p-lite |
| logintime | True | Datetime | 登录时间(服务器时区时间) |
| logintimeStamp | True | long | 登录时间秒级时间戳 |
| logouttime | True | Datetime | 登出时间(服务器时区时间) |
| logouttimeStamp | True | long | 登出时间时间戳 |
| status | True | String | 模块启动状态normal:正常gps:同步没有获取到pps:pps脉冲没有获取到mac:Mac没有正确传输 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | Long | int | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |
| protocolVersion | True | String | 基站主控协议版本 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "msguid":"fbcd1110",
            "apuid":"dbcd1119",
            "softversion":"125",
            "protype":"zeta-s",
            "apsignal":25,
            "logintime":"2016-10-11 12:11:54",
            "logouttime":"2016-10-11 15:11:54",
            "logintimeStamp":1476159114,
            "logouttimeStamp":1476169914,
            "status":"normal",
            "aptime":"2016-10-11 12:11:54",
            "aptimeStamp":1476159114,
            "uptimeStamp":1476159174,
            "uptime":"2016-10-11 12:12:54",
            "protocolVersion":"0109"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取心跳数据

### 简要描述

根据时间获取指定基站心跳数据
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApHeartBeatByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ap/query/00000001/getApHeartBeatByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| apsignal | True | Int | 信号强度(0-31：对应0-100%；99：表示无法检测；255：表示以太网) |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "apsignal":255,
            "aptime":"2016-10-10 11:23:21",
            "aptimeStamp":1476069801,
            "uptimeStamp":1476069805,
            "uptime":"2016-10-10 11:23:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取下行指令记录

### 简要描述

根据时间获取指定基站心跳数据
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApCtlHistoryByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ap/query/00000001/getApHeartBeatByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| msguid | True | String(8) | 基站主控 ID |
| apuid | True | String(8) | 基站ID |
| type | True | Int | 指令类型：1重启基站模块、2回收特定网络号（ID=0全回收）、3设置 Web Server地址、4获取基站状态、5设置基站时间、6获取基站时间、7复位基站、8设置基站运行参数、9获取基站运行参数、10获取基站版本信息、11获取基站通讯模块状态、12设置ZATA参数、13获取zata参数、14获取经纬度参数、15单播、16设置ftp服务器参数、17启动基站ARM升级、18重启ARM、19获取ftp服务器参数、20终端组播、21终端广播、22中继组播、23中继广播24获取gprs信息、25巡检、26组播巡检、27设置跳频组号、28设置发射功率、29重启后端的单片机、30启动基站模块升级、31设置基站自动巡检周期、32 设置radio射频信息、33 设置广播注册信息时隙、34 获取基站模块射频信息、35 获取基站GPS状态、36设置定时任务、通用）、37删除定时任务、38设置路灯定时任务、39设置载波监听信号强度阈值、40设置基站时区、41设置GPS使能开关、42基站全量升级FTP服务器参数设置、43基站模块下多终端/中继升级、44多终端/中继升级参数设置、45启动log上传、46设置log打印等级、47清除基站发送数据缓存、48设置设备鉴权信息、49设置帧数配比、50清除鉴权失败中继记录、51清除鉴权失败终端记录、52设置Gps信息、53启动基站模块ISP下载、54获取log文件名列表、55启动指定LOG文件(部分)上传、56设置车载网关上传模式、57查询车载网关上传模式、58设置车载网关gps打点周期、59查询车载网关gps打点周期 |
| status | True | Int | 执行状态300:待执行301:执行成功302:执行失败303:过期无效0:发送成功32:ms找不到map33:map找不到netid34:ms找不到ap35:map找不到ap36:ap找不到ip、port17:服务器到基站后端失败18:基站后端到基站前端失败19:设备无反馈1:基站查无此中继2:基站下发多次失败3:一级中继查无此中继4:一级中继下发多次失败5:二级中继查无此中继6:二级中继下发多次失败7:三级中继查无此中继8:三级中继下发多次失败9:下发到终端多次失败10:下发到终端上级设备11:下发到终端超时12: 中继串口无响应15:无下行反馈64:透传数据错误65:旧版指令错误66:旧版本协议错误68:新版指令错误69:新版本版本错误70:新版本协议错误71:下行所在ARM离线10000:数据校验不合法10001:cmd命令找不到10002:操作类型 subType 命令不合法10003:主命令 msgCmd 命令不合法10004:子命令subCmd 命令不合法10005:协议类型不存在10006:打印等级不存在10007:设备类型不存在10008:基站模块未启动成功10009:中继未注册成功10010:终端未注册成功 |
| downtime | True | Datetime | 指令下发时间(服务器时区时间) |
| downtimeStamp | True | Long | 指令下发时间秒级时间戳 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "msguid":"abcd1112",
            "apuid":"abcd1119",
            "type":1,
            "status":300,
            "downtime":"2016-10-10 12:45:48",
            "aptime":"2016-10-10 12:46:48",
            "downtimeStamp":1476074748,
            "aptimeStamp":1476074808,
            "uptimeStamp":1476074868,
            "uptime":"2016-10-10 12:47:48"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本下行指令

### 简要描述

对指定基站下行
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/newCtrlApUnicast?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String | 见【基站下行数据域】 |

## 基站下行数据域

| 下行指令 | 协议类型 | data |
| --- | --- | --- |
| 重启 | P/S/Lite/G | 010000 |
| 重注册（回收特定网络号（ID=0全回收）） | P/S/Lite | 0200+子集的ID（1字节hex） |
| 设置跳频组号（注册广播时隙） | S | 0300+跳频组号 |
| 设置发射功率 | S | 0400+设置范围0-7（1字节hex）数值0-7对应发射功率实际值为：-11dbm0dbm10dbm15dbm17dbm19dbm20dbm22dbm |
| 设置基站自动巡检周期 | P | 0500+巡检周期范围1~65535s,小端两个字节存放 |
| 设置radio射频信息 | S | 0600+射频信息按顺序（11个字节hex）：基础频点4字节单位Hz信道间隔1字节单位KHz基站广播注册信息信道1bytes基站业务信道1字节中继注册信道1字节中继业务信道1字节中继广播信道1字节 |
| 下行业务信道1字节 |  |  |
|  | Lite | 0601+射频信息按顺序（9个字节hex）：基础频点4字节单位Hz信道间隔1字节单位KHzFB1信道1字节FB2信道1字节FB3信道1字节F1信道1字节 |
|  | P | 0602+射频信息按顺序（9个字节hex）：网关频点3bytes，单位10KHz中继频点3bytes，单位10KHz终端频点3bytes，单位10KHz |
| 设置广播注册信息时隙 | S | 0700+时隙范围1-20 |
| 设置GPS使能开关 | Lite/S | 080001 开启080000 关闭 |
| 设置载波监听信号强度阈值 | P/S/Lite | 0900+阈值（0~127，1个字节hex） |
| 帧数配比 | Lite | 0A00+帧数（2-64，1字节）、子帧数（8-64，1字节） |
| 重启后端的单片机 | P/S/Lite | 0F0000 |
| 清除鉴权失败中继记录MAC | P/S/Lite | 110000 |
| 清除鉴权失败终端记录MAC | P/S | 120000 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本组播

### 简要描述

对指定基站组播
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/newCtrlApMulticast?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String | n字节数据 |
| subType | 是 | String | 操作类型ms：终端mote：中继 |
| devGroup | 是 | String | 设备组号 1~254 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本广播

### 简要描述

对指定基站广播
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/newCtrlApBroadcast?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String | n字节数据 |
| subType | 是 | String | 操作类型ms：终端mote：中继 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本巡检

### 简要描述

对指定基站巡检
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/newCtrlApPolling?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String | n字节数据 |
| subType | 是 | String | 操作类型ms：终端mote：中继 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 新版本组播巡检

### 简要描述

对指定基站组播巡检
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/newCtrlApMultiPoll?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| data | 是 | String | n字节数据 |
| subType | 是 | String | 操作类型ms：终端mote：中继 |
| devGroup | 是 | String | 设备组号 1~254 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 简单控制指令

### 简要描述

对指定基站下发部分控制指令
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlGetApSimpleCtrl?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| infotype | 是 | String | int，见【具体控制指令类型】 |

### 具体控制指令类型

| 值 | 说明 |
| --- | --- |
| 4 | 获取基站状态 |
| 6 | 获取基站时间 |
| 7 | 复位基站 |
| 9 | 获取基站运行参数 |
| 10 | 获取基站版本信息 |
| 11 | 获取基站通讯模块状态 |
| 13 | 获取ZETA参数（信道） |
| 14 | 获取经纬度参数 |
| 18 | 重启基站主控 |
| 19 | 获取Ftp服务器参数 |
| 24 | 获取gprs信息 |
| 34 | 获取基站模块射频信息 |
| 35 | 获取基站GPS状态 |
| 47 | 清除基站发送数据缓存 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置基站时间

### 简要描述

设置基站时间
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApSetTime?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| timestamp | 是 | long | 秒级的unix时间戳 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置基站时区

### 简要描述

设置基站时区
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApSetTimeZone?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| timezone | 是 | int | 时区，-12~12 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 下发FTP服务器参数

### 简要描述

设置FTP服务器参数
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlSetFtpParams?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| serverIp | 是 | String | 服务器IP |
| serverPort | 是 | int | 服务器端口 |
| fileName | 是 | String | 升级文件名 |
| username | 是 | String | Ftp账号 |
| password | 是 | String | Ftp密码 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 启动基站ARM升级

### 简要描述

启动基站ARM升级
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApUpgrade?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| serverParam | 是 | String | 服务器参数（default:采用默认服务器参数，below:采用下面配置的服务器参数） |
| serverIp | 是 | String | 服务器IP |
| serverPort | 是 | int | 服务器端口 |
| fileName | 是 | String | 升级文件名 |
| username | 是 | String | Ftp账号 |
| password | 是 | String | Ftp密码 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 启动基站模块升级

### 简要描述

启动基站模块升级
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlModuleUpgrade?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| serverIp | 是 | String | 服务器IP |
| serverPort | 是 | int | 服务器端口 |
| fileName | 是 | String | 升级文件名 |
| username | 是 | String | Ftp账号 |
| password | 是 | String | Ftp密码 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置基站定时任务

### 简要描述

设置基站定时任务
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlSetApTask?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| periodType | 是 | String | 周期类型，执行时间为开始时间single: 单次day: 每天循环week: 每周循环interval: 按间隔循环 |
| taskType | 是 | String | unicast:单播任务multicast:组播任务broadcast:广播任务 |
| startDate | 是 | String | 开始时间，格式：yyyy-MM-dd HH:mm,如：2017-11-02 12:03 |
| endDate | 是 | String | 结束时间，格式：yyyy-MM-dd HH:mm,如：2017-11-03 12:03 |
| interval | 否 | Int | 间隔周期，单位分钟(在periodType为interval时有效) |
| week | 否 | Int | 星期，0~6,0代表周日，1代表周一 |
| moteUid | 否 | String | 中继uid(taskType为单播任务时有效)，4字节 hex |
| group | 否 | Int | 组号(taskType为组播任务时有效)，0~255 |
| data | 是 | String | 需要任务透传到中继模块的数据，n字节hex |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置路灯定时任务

### 简要描述

设置路灯定时任务
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlSetLampTask?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| moteUid | 否 | String | 中继uid(taskCmd为单播任务时有效)，4字节 hex |
| taskCmd | 是 | String | 任务操作命令类型on: 开灯off: 关灯dimming: 调光status: 查询灯状态realtime: 查询灯实时信息multiOn: 组播开灯multiOff: 组播关灯mutiDimming: 组播调光multiStatus: 组播查询灯状态multiRealtime: 组播查询灯实时信息broadOn: 广播开灯broadOff: 广播关灯broadDimming: 广播调光broadStatus: 广播查询灯状态broadRealtime: 广播查询灯实时信息 |
| periodType | 是 | String | 周期类型，执行时间为开始时间single: 单次day: 每天循环week: 每周循环interval: 按间隔循环 |
| startDate | 是 | String | 开始时间，格式：yyyy-MM-dd HH:mm,如：2017-11-03 12:03 |
| endDate | 是 | String | 结束时间，格式：yyyy-MM-dd HH:mm,如：2017-11-03 12:03 |
| interval | 否 | Int | 间隔周期，单位分钟(在periodType为interval时有效) |
| week | 否 | Int | 星期，0~6,0代表周日，1代表周一 |
| lightValue | 否 | Int | 调光等级(taskCmd为调光相关操作有效)，范围0～100，分别表示0%～100% |
| group | 否 | Int | 组号(taskType为组播任务时有效)，0~255 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 删除定时任务

### 简要描述

删除定时任务
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlDelTask?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| taskId | 是 | String | 任务ID |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取基站定时任务列表

### 简要描述

获取基站定时任务列表
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getApTask?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| taskId | 是 | Int | 任务ID，0查询全部 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| armUid | 是 | String | 基站主控ID |
| apUid | 是 | String | 基站ID |
| taskId | 是 | String | 任务ID |
| devType | 是 | String | 任务类型0、通用任务1、路灯任务 |
| moteUid | 是 | String | 中继uid(taskCmd为单播任务时有效)，4字节 hex |
| taskType | 是 | int | unicast:单播任务multicast:组播任务broadcast:广播任务 |
| taskCmd | 是 | String | 操作命令：n字节字符串(通用任务时)on: 开灯off: 关灯dimming: 调光status: 查询灯状态realtime: 查询灯实时信息multiOn: 组播开灯multiOff: 组播关灯mutiDimming: 组播调光multiStatus: 组播查询灯状态multiRealtime: 组播查询灯实时信息broadOn: 广播开灯broadOff: 广播关灯broadDimming: 广播调光broadStatus: 广播查询灯状态broadRealtime: 广播查询灯实时信息 |
| periodType | 是 | String | 周期类型，执行时间为开始时间single: 单次day: 每天循环week: 每周循环interval: 按间隔循环 |
| startDate | 是 | String | 开始时间，格式：yyyy-MM-dd HH:mm,如：2017-11-03 12:03 |
| endDate | 是 | String | 结束时间，格式：yyyy-MM-dd HH:mm,如：2017-11-03 12:03 |
| interval | 否 | Int | 间隔周期，单位分钟(在periodType为interval时有效) |
| week | 否 | Int | 星期，0~6,0代表周日，1代表周一 |
| lightValue | 否 | Int | 调光等级(taskCmd为调光相关操作有效)，范围0～100，分别表示0%～100% |
| group | 否 | Int | 组号(taskType为组播任务时有效)，0~255 |
| flag | 是 | String | 基站主控ID |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "objectid":"54a54841f5484a5484s5484s54841aba",
            "apsignal":255,
            "aptime":"2016-10-10 11:23:21",
            "aptimeStamp":1476069801,
            "uptimeStamp":1476069805,
            "uptime":"2016-10-10 11:23:25"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置GPS信息

### 简要描述

设置GPS信息
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApSetGPSInfo?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| longitude | 是 | float | 经度（WGS-84坐标系），例如114.89525 |
| latitude | 是 | float | 纬度（WGS-84坐标系），例如23.889265 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置基站全量升级FTP参数

### 简要描述

设置基站全量升级FTP参数
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApSetFtpApFullUpgrade?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| serverIp | 是 | String | 服务器IP |
| serverPort | 是 | int | 服务器端口 |
| fileName | 是 | String | 升级文件名 |
| username | 是 | String | Ftp账号 |
| password | 是 | String | Ftp密码 |
| devId | 是 | String | 基站ID |
| oldProtocol | 是 | Int | 旧协议类型:1 = ZETA-P241 = ZETA-LITE255 = ZETA-S128 = ZETA-G |
| newProtocol | 是 | Int | 新协议类型:1 = ZETA-P241 = ZETA-LITE255 = ZETA-S128 = ZETA-G |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置基站模块下多终端/中继升级参数

### 简要描述

设置基站模块下多终端/中继升级参数
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApSetUpgradeParamMutil?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| serverIp | 是 | String | 服务器IP |
| serverPort | 是 | int | 服务器端口 |
| fileName | 是 | String | 升级文件名 |
| username | 是 | String | Ftp账号 |
| password | 是 | String | Ftp密码 |
| basePoint | 是 | float | 基础频点 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 基站模块下多终端/中继升级控制

### 简要描述

设置基站模块下多终端/中继升级控制
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/control/{uid}/ctrlApStartDevsInModuleUpgrade?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| devType | 是 | String | 设备类型：ms=终端mote=中继msSensor终端传感器moteSensor中继传感器 |
| devInfos | 是 | int | 需要升级的设备ID，多个使用逗号连接 |

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| msgid | True | Int | 指令序号 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 根据时间获取GPS轨迹数据

### 简要描述

根据时间获取指定基站GPS轨迹数据, 接口中的uid须使用arm的uid

### 请求URL

```
/teamcms/ws/zeta_v2/wan_ap/query/{uid}/getGpsTrailByDate?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| starttime | 是 | Long | 开始时间Unix秒级时间戳 |
| endtime | 是 | Long | 结束时间Unix秒级时间戳 |

### 请求示例

```
POST /teamcms/ws/zeta_v2/wan_ap/query/00000001/getGpsTrailByDate?access_token=a29e66823f9c494b92ed8bf0cd7da886 HTTP/1.1
Content-Type: application/json
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
Content-Length: 88

{"starttime":"1638768002","endtime":"1639632002"}
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| objectid | True | String(32) | 唯一标识 |
| latitude | True | float | 纬度 |
| longitude | True | float | 经度 |
| dottime | True | Int | 打点时间，秒级时间戳 |
| azimuth | True | Int | 航向数据 |
| speed | True | Int | 速度数据，单位： 0.1km/h |
| height | True | Int | 高度数据，单位：米 |
| aptime | True | Datetime | 基站处理时间(服务器时区时间) |
| aptimeStamp | True | Long | 基站处理时间秒级时间戳 |
| uptime | True | Datetime | 上报时间(服务器时区时间) |
| uptimeStamp | True | Long | 上报时间上报秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "dottime":1590893794,
            "latitude":"23.758970000000",
            "aptimeStamp":"1472626704",
            "msguid":1,
            "apuid":3,
            "azimuth":0,
            "speed":0,
            "uptime":"2022-03-01 15:29:11",
            "uptimeStamp":"1646119751",
            "aptime":"2016-08-31 14:58:24",
            "objectid":286520261871022080,
            "longitude":"114.956419000000",
            "height":0
        },
        {
            "dottime":1590990698,
            "latitude":"23.658940000000",
            "aptimeStamp":"1472626704",
            "msguid":1,
            "apuid":3,
            "azimuth":0,
            "speed":0,
            "uptime":"2022-03-01 15:29:11",
            "uptimeStamp":"1646119751",
            "aptime":"2016-08-31 14:58:24",
            "objectid":286520261871022081,
            "longitude":"114.656415000000",
            "height":0
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":1646120114
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取ARM列表

简要描述获取所属企业及其下级企业的基站ARM设备列表请求URL/teamcms/ws/zeta_v2/wan_ap/query/{api_key}/getArmList?access_token={ACCESS_TOKEN}请求方式 POST请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uidHexLike | 否 | String | 网关MAC |
| simNo | 否 | String | SIM卡号 |
| alias | 否 | String | 别名 |
| onlineStatus | 否 | int | 在线状态 0在线 1离线 |
| alarmStatus | 否 | int | 告警状态 1-告警中 |
| armTypes | 否 | String | 网关类型(多个用逗号隔开) 0-APZ1ZT/APZT-GO01 1-APZ1TG/APTG-GO01 2-APZ1TG-F/APTG-GF01 3-APZ2ZT/APZT-GI01 4-APZ1ZT-M/APTG-MO01 5-APZ2ZT-I/APZT-UI01 6-APZC-SDR01 7-APZT-GO10 8-APZT-GO02 9-APZC-EO20 10-MGZC-BD10/BD20/BD30 11-APZ2ZT/APTG-CI20 12-APZT-GO20 |

请求示例
```
GET /teamcms/ws/zeta_v2/wan_ap/query/07157af150494fccf8458b20ec6989c1/getArmList?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```
返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| uid | True | String(8) | 设备ID |
| companyname | True | String | 企业名称 |
| alias | True | String | 别名 |
| armType | True | int | 网关类型 0-APZ1ZT/APZT-GO01 1-APZ1TG/APTG-GO01 2-APZ1TG-F/APTG-GF01 3-APZ2ZT/APZT-GI01 4-APZ1ZT-M/APTG-MO01 5-APZ2ZT-I/APZT-UI01 6-APZC-SDR01 7-APZT-GO10 8-APZT-GO02 9-APZC-EO20 10-MGZC-BD10/BD20/BD30 11-APZ2ZT/APTG-CI20 12-APZT-GO20 |
| usageStatus | True | int | 使用状况 0.已交付  1.调试中 |

返回示例正确时返回:

```
{
    "data":[
        {
            "uid": "00000001",
            "usageStatus": 1,
            "companyname": "厦门纵行信息科技有限公司",
            "alias": "这是别名",
            "armType": 1
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```
备注更多返回错误代码请看接入指南->返回结果说明->返回码status说明

---

### 综合信息

---

#### 获取平台组织结构

### 简要描述

获取平台组织结构
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_syndata/query/{api_key}/getOrgStru?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_syndata/query/07157af150494fccf8458b20ec6989c1/getOrgStru?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| companyid | True | Long | 企业ID |
| parentid | True | Long | 父节点ID |
| levelcode | True | String | 层级编码 |
| parentname | True | String | 父企业名称 |
| companyname | True | String | 企业名称 |
| companycode | True | String(32) | 企业编码 |
| companysecret | True | String(32) | 企业密钥 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "companyid":2,
            "parentid":"1",
            "levelcode":"0000100001",
        	  "parentname":"纵行top",
            "companyname":"纵行",
            "companycode":"5fbcdabcd111c110a343ds1110110",
            "companysecret":"5fbcdabcd11101abcd1abcd1110110abcd1110110"
        },
        {
            "companyid":3,
            "parentid":"1",
            "levelcode":"0000100002",
						"parentname":"纵行top",
            "companyname":"zeta",
            "companycode":"554bcdabcd1fe23244341101abcd11110110",
            "companysecret":"5fbcdabcd11101abcd1abcd1110110abcd"
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 获取平台人员结构

### 简要描述

获取平台人员结构

### 请求URL

```
/teamcms/ws/zeta_v2/wan_syndata/query/{api_key}/getPersonStru?access_token={ACCESS_TOKEN}
```

### 请求方式

GET
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | True | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| api_key | True | string | 企业编码，可在”ZETA信息管理平台”–权限列表–企业信息中查询 |
| access_token | True | string | 请求token，通过“获取ACCESS_TOKEN”接口获取，有效期5分钟 |

### 请求示例

```
GET /teamcms/ws/zeta_v2/wan_syndata/query/07157af150494fccf8458b20ec6989c1/getPersonStru?access_token=c499625387c647888a6d166ee4d447bb HTTP/1.1
Accept: application/json
User-Agent: Apache CXF 2.7.18
Cache-Control: no-cache
Pragma: no-cache
Host: 127.0.0.1:25455
Connection: keep-alive
```

### 返回参数说明

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| companyid | True | Long | 企业ID |
| companyname | True | String | 企业名称 |
| userid | True | Long | 用户ID |
| username | True | String | 用户名称 |
| postname | True | String | 岗位名称 |
| expiretimeStamp | True | Long | 有效期 秒级时间戳 |
| lastlogintimeStamp | True | Long | 最后登录时间 秒级时间戳 |
| createtimeStamp | True | Long | 创建时间 秒级时间戳 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "companyid":2,
            "companyname":"纵行科技",
            "userid":3,
            "username":"张三",
            "postname":"管理员",
            "expiretimeStamp":"2706767601 ",
            "lastlogintimeStamp":" 1444463601",
            "createtimeStamp":" 1441871601 "
        },
        {
            "companyid":3,
            "companyname":"zeta",
            "userid":4,
            "username":"李四",
            "postname":"测试人员",
            "expiretimeStamp":"2706767601",
            "lastlogintimeStamp":" 1444463601",
            "createtimeStamp":" 1441871601 "
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

#### 设置设备鉴权信息(只透传到IOT下发)

### 简要描述

设置设备鉴权信息
​

### 请求URL

```
/teamcms/ws/zeta_v2/wan_syndata/control/{uid}/ctrlSetDevAuthKey?access_token={ACCESS_TOKEN}
```

### 请求方式

POST
​

### 请求头

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| Content-Type | 是 | string | 请求类型： application/json |

### 请求参数

| 参数名 | 是否必须 | 类型 | 说明 |
| --- | --- | --- | --- |
| devType | 是 | String | 设备类型ms:终端；mote:中继；arm：基站主控 |
| authKey | 是 | String | 鉴权密钥，当devType为ms/mote时有效 |
| keeloqKey | 是 | String | 加解密密钥，当devType为ms/mote时有效 |
| armKey | 是 | String | 基站核心板密钥，当devType为arm时有效 |
| opType | 是 | Int | 操作类型15：终端16：中继 |
| appType | 是 | String | 应用类型：unknown: 未知lamp: 路灯tempAndHum: 温湿度pm25:空气质量PM2.5tilt:倾角传感器井盖human:人体红外感应gate:门开关感应smoke:烟感感应waterGage:水压waterLevel: 水位current:电流检测gas:有害气体采样waterMeter:AD采样水表boxGate:光交箱开关感应irrigate:浇灌 |

### 返回示例

正确时返回:

```
{
    "data":[
        {
            "msgid":5465
        }
    ],
    "errmsg":"",
    "status":0,
    "ts":175907811
}
```
错误时返回:

```
{
    "data":[

    ],
    "errmsg":"ERROR REQUEST",
    "status":10001,
    "ts":1475893800
}
```

---

## 更新记录

# http接口api文档

#### 第10次更新

更新日期：2022.03.01
平台版本：v2.12.1.0
更新内容：
1、增加接口【3.27、根据时间获取GPS轨迹数据】

#### 第9次更新

更新日期：2022.02.17
平台版本：v2.12.0.0
更新内容：
1、增加1.10字段parsedData
2、增加v2版本接口，取消参数加密；新增认证接口

#### 第8次更新

更新日期：2021.02.26
平台版本：v2.11.0.1
更新内容：
1、增加下行反馈状态码说明

#### 第7次更新

更新日期：2020.08.10
平台版本：v2.11.0.0
更新内容：
1、新增终端-根据时间查询应用数据历史

#### 第6次更新

更新日期：2019.12.31
平台版本：v2.9.0.5
更新内容：
1、删除基站-组播
2、删除基站-广播
3、删除基站-巡检
4、删除基站-组播巡检
5、新增基站-新版本组播
6、新增基站-新版本广播
7、新增基站-新版本巡检
8、新增基站-新版本组播巡检
9、终端-根据数据获取心跳数据增加字段：zetagData

#### 第5次更新

更新日期：2019.12.09
平台版本：v2.9.0.3
更新内容：
1、接入指南-统一请求前置路径增加云平台地址说明
2、接入指南-加解密说明，增加流程图
3、终端-获取设备详情增加字段：keeloqKey、devCode、devVersion
4、终端-获取设备状态增加字段：warning、offlinemb、downflag、upgradestatus、upgradetime
upgradetimeStamp、groupid1、groupid2、groupid3、groupid4、groupid5、reregistrationAlarm
reconnected、regFailRate、uplinkLoseRate、downlinkLoseRate
5、终端-根据时间获取心跳数据增加字段：regFailRate、uplinkLoseRate、downlinkLoseRate
zetagProtocol、frameType
6、终端-根据时间获取下行指令记录新增指令类型说明
7、删除终端-透传数据
8、新增终端-新版本单播控制
9、新增终端-新版本透传数据
10、中继-获取设备详情增加字段：keeloqKey、devCode、devVersion
11、中继-根据时间获取心跳数据增加字段：regFailRate、uplinkLoseRate、downlinkLoseRate
12、中继-获取设备状态增加字段：warning、offlinemb、downflag、upgradestatus、upgradetime
upgradetimeStamp、reregistrationAlarm、reconnected、regFailRate、uplinkLoseRate
downlinkLoseRate
13、中继-根据时间获取下行指令记录新增指令类型说明
14、删除中继-透传数据
15、新增中继-新版本单播控制
16、新增中继-新版本透传数据
17、基站获取设备详情增加字段：armkey、armUpgraderesult、iccid、protocolVersion、downflag
modelUpgraderesult、chnspace、broadregchn、trafficchn、moteregchn、motetrafficchn
motebroadchn、downtrafficchn、regtimeslot、freqhopp、fhgroup、fhrange、transpower、gpsstatus
carryMonitor、commRate、channelFb1、channelFb2、channelFb3、channelF1、maxFrame
maxSubFrame、gatewayPoint、motePoint、msPoint、gatewaySpeed、moteSpeed、msSpeed
18、基站-根据时间获取注册信息增加字段：protocolVersion
19、基站-根据时间获取下行指令记录新增指令类型代码
20、删除基站-下行指令
21、新增基站-新版本下行指令
22、基站-简单控制指令请求参数（数据类型）增加类型：清除基站发送数据缓存
23、增加基站-设置基站时区
24、基站-设置基站运行参数增加请求参数：connectMode、apn、standbyServerIp、networkInterval
25、增加基站-设置GPS信息
26、增加基站-基站全量升级FTP参数设置
27、增加基站-基站模块下多终端/中继升级参数设置
28、增加基站-基站模块下多终端/中继升级控制命令
29、新增终端/中继/基站-下行指令记录的执行状态说明
30、综合信息-新版本设置设备鉴权信息，增加armKey参数和devType的说明

#### 第4次更新

更新日期：2019.11.05
平台版本：v2.8.1.1
更新内容：
1、终端-根据时间获取上传数据接口删除无用字段Ttimezone

#### 第3次更新

更新日期：2019.03.18
平台版本：v2.8.1.0
更新内容：
1、获取平台人员结构接口新增expiretimeStamp(有效期秒级时间戳)、lastlogintimeStamp (最后登录时间秒级
时间戳)、createtimeStamp (创建时间秒级时间戳)
2、所有返回结果中时间相关的参数，增加对应的秒级时间戳 ( 原时间参数都是服务器所在时区时间 )

#### 第2次更新

更新日期：2018.06.19
平台版本：v2.8.0.0
更新内容：
1、中继-透传数据，增加指令类型
2、终端-透传数据，增加指令类型

#### 第1次更新

更新日期：2017.01.24
平台版本：v2.7.2.0
更新内容：
1、基站-下行指令，增加设置GPS使能开关
​

# mqtt推送api文档

#### 第25次更新

更新日期：2022.03.01
平台版本：v2.15.1.0
更新内容：
1、增加【3.27、ZETA-G 轨迹数据上行】推送

#### 第24次更新

更新日期：2022.02.28
平台版本：v2.15.0.0
更新内容：
1、设备别名(deviceAlias)和设备地址(deviceaddr)公共字段

#### 第23次更新

更新日期：2022.02.17
平台版本：v2.14.0.0
更新内容：
1、增加特殊推送-解析后推送字段parsedData

#### 第22次更新

更新日期：2021.08.19
平台版本：v2.13.0.2
更新内容：
1、修改msgid的说明

#### 第21次更新

更新日期：2021.03.01
平台版本：v2.13.0.1
更新内容：
1、下行反馈数据域status增加状态码说明

#### 第20次更新

更新日期：2020.07.27
平台版本：v2.13.0.0
更新内容：
1、【特殊推送—终端、中继上行数据解析】,
接口增加推送时间的秒级时间戳upTime
2、增加【特殊推送—设备信息】推送接口
3、增加【特殊推送—设备低电】推送接口

#### 第19次更新

更新日期：2020.06.28
平台版本：v2.12.0.1
更新内容：
1、终端心跳包接口参数中
regFailRat/uplinkLoseRate/downlinkLoseRate
改为RegFailRate/UplinkLoseRate/DownlinkLoseRate
2、中继心跳包接口参数中
regFailRat/uplinkLoseRate/downlinkLoseRate
改为RegFailRate/UplinkLoseRate/DownlinkLoseRate

#### 第18次更新

更新日期：2019.12.09
平台版本：v2.12.0.0
更新内容：
1、修改终端、中继上行数据解析
增加pid和accessKey

#### 第17次更新

更新日期：2019.12.02
平台版本：v2.11.0.1
更新内容：
1、修改云平台地址
2、增加设置基站时区结果上报
3、修改获取GPRS模块信息上报，新增字段iccid
4、修改基站登录，新增字段protocolVersion
5、增加基站协议上报
6、修改基站模块启动上报，增加字段newComVer
7、修改中继心跳包，新增字段
regFailRate/uplinkLoseRate/downlinkLoseRate，
flow范围由0~255改为0~65535
8、修改终端心跳包，新增字段
regFailRate/uplinkLoseRate/
downlinkLoseRate/zetaProtocol/frameType
9、修改获取基站模块射频信息上报，
修改字段transPower为-255~255;
新增以下字段：
protocol/carryMonitor/commRate/channelFB1/
channelFB2/channelFB3/channelF1/maxFrame/
maxSubFrame/gatewayPoint/motePoint/msPoint
/gatewaySpeed/moteSpeed/msSpeed
10、修改终端上行数据，新增字段：
dataType/seq/longitude/
latitude/rssi/data/appData
11、修改终端注册到基站/终端注册到中继/中继注册，
分别增加groupId字段
12、新增基站全量升级FTP服务器参数设置上报
13、新增基站模块下多终端/中继升级参数设置上报
14、新增基站模块下多终端/中继升级控制上报
15、新增基站模块下多终端/中继升级结果上报
16、新增设置GPS信息上报
17、修改下行反馈数据域status，新增0x40~0x47
18、新增清除基站发送数据缓存上报
19、删除远程升级中的升级结果反馈上报
20、修改基站ARM升级上报errorCode的value值

#### 第16次更新

更新日期：2019.11.08
平台版本：v2.10.0.0
更新内容：
1、增加特殊推送，终端、中继上行数据解析
2、修改请求示例，增加附录请求示例2.2

#### 第15次更新

更新日期：2019.09.05
平台版本：v2.9.1.1
更新内容：
1、变更连接与认证说明

#### 第14次更新

更新日期：2018.10.10
平台版本：v2.9.1.0
更新内容：
1、增加部分无效上报数据标注

#### 第13次更新

更新日期：2018.06.19
平台版本：v2.9.0.0
更新内容：
1、增加终端登出
2、增加中继登出
3、修改设备告警上报的maybeReason含义

#### 第12次更新

更新日期：2018.02.06
平台版本：v2.8.0.0
更新内容：
1、固定mqtt连接用户名密码
2、增加clientid规定
3、增加topic订阅说明

#### 第11次更新

更新日期：2018.01.04
平台版本：v2.7.0.0
更新内容：
1、增加设置基站时区结果上报

#### 第10次更新

更新日期：2017.12.07
平台版本：v2.6.0.0
更新内容：
1、增加设备告警上报

#### 第9次更新

更新日期：2017.11.29
平台版本：v2.5.1.1
更新内容：
1、电量计算说明修改

#### 第8次更新

更新日期：2017.11.28
平台版本：v2.5.1.0
更新内容：
1、中继注册包，原因增加类型

#### 第7次更新

更新日期：2017.11.02
平台版本：v2.5.0.0
更新内容：
1、增加终端、中继分组结果上报
2、合并arm、模块升级上报
3、增加基站定时任务结果上报

#### 第6次更新

更新日期：2017.9.30
平台版本：v2.4.0.0
更新内容：
1、终端、中继心跳包，增加注册休眠模式字段

#### 第5次更新

更新日期：2017.08.11
平台版本：v2.3.0.0
更新内容：
1、增加基站-获取基站模块射频信息上报
2、增加基站-获取基站GPS状态上报

#### 第4次更新

更新日期：2017.05.18
平台版本：v2.2.0.0
更新内容：
1、增加远程升级-启动基站升级结果上报
2、增加远程升级-启动基站模块升级指令上报
3、增加远程升级-启动基站模块升级结果上报

#### 第3次更新

更新日期：2017.04.06
平台版本：v2.1.1.0
更新内容：
1.终端/中继增加返回注册原因类型

#### 第2次更新

更新日期：2017.03.28
平台版本：v2.1.0.0
更新内容：
1.增加组播巡检上报

#### 第1次更新

更新日期：2017.03.03
平台版本：v2.0.0.0
更新内容：
1.修改终端、中继心跳 上/下行RSSI数据类型为int
2.修改终端、中继、基站下行数据反馈状态
status为int型，并且附录status内容
3.增加GPRS模块信息上报
4.上报基站模块启动增加type及version字段
5.终端/中继注册增加version、上行注册序号及注册原因字段
6.中继心跳包增加流量字段
7.终端注册中继增加上行注册上的中继UID
8.增加巡检上报

#### 初始版本

日期：2016.10.31
平台版本：v1.0.0.0

​
​

---

