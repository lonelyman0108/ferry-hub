# 九号出行（`ninebot`）

提取九号出行 App 签到接口中的登录凭证与设备标识，供本人青龙等自动化签到脚本使用。

## 触发方式

1. 确保手机代理客户端已启用 Ferry 订阅与 `cn-cbu-gateway.ninebot.com` 的 MITM 解密。
2. 打开九号出行 App，进入「福利中心 / 每日签到」页面并点击「签到」（当日已签到时点击同样会触发请求）。

## 提取字段与输出变量

| 字段 `key` | 位置 | 说明 | 输出变量 |
|---|---|---|---|
| `authorization` | 请求头 `Authorization` | 登录 JWT 令牌（敏感字段） | `NINEBOT_AUTHORIZATION` |
| `device_id` | 请求体 JSON `deviceId` | 设备标识 | `NINEBOT_DEVICE_ID` |

## 有效性探测

请求 `https://cn-cbu-gateway.ninebot.com/portal/api/user-sign/v2/status`，校验响应满足 `status == 200 && json.code == 0`。
