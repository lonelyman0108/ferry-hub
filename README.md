# ferry-hub

[Ferry](https://github.com/lonelyman0108/ferry) 官方来源规则仓库：收录个人账号在本人设备上的请求匹配、字段提取与有效性探测规则，供 Ferry「浏览仓库」与在线链接导入使用。

## 边界与收录原则

与 [Ferry 的使用范围](https://github.com/lonelyman0108/ferry#边界)一致，本仓库只收录满足以下条件的来源定义：

- **本人账号、本人设备**：仅提取使用者本人账号在本人设备上发出的请求凭证（如签到脚本所需的 Token、Cookie）。
- **每次回传可见**：默认保持 `notify: "always"`，关闭手机端通知或开启调试模式的定义需在说明中注明原因。
- **探测域名受限**：`probe.url` 与 `Host` 请求头的域名必须落在 `matchers` 声明的域名范围内，且匹配域名不得使用过宽泛的通配符（如 `*`、`*.com`、公共托管后缀）。
- **样例严格脱敏**：`cases.json` 中的请求头与请求体必须使用虚构脱敏数据，严禁提交真实账号的 Token、Cookie 或隐私信息。

## 目录结构

```text
ferry-hub/
├── index.json                  # 仓库索引（由 ferry hub index 生成，含各来源摘要与 SHA-256）
└── sources/
    └── <key>/
        ├── source.json         # 来源 JSON 外壳（$schema 指向 Ferry schema/source.v1.json）
        ├── icon.svg            # 来源图标文件（支持 .svg / .png / .webp / .jpg，不存 base64）
        ├── README.md           # 触发方式、提取字段与输出变量说明
        └── cases.json          # 脱敏请求样例与期望提取结果（CI 逐条试跑）
```

## 已收录来源

| 来源 | 标识（`key`） | 版本 | 说明 | 在线导入链接 |
|---|---|---|---|---|
| [九号出行](sources/ninebot/README.md) | `ninebot` | `v1` | 提取签到请求中的 `Authorization` 与 `deviceId` | `https://raw.githubusercontent.com/lonelyman0108/ferry-hub/main/sources/ninebot/source.json` |

### 导入方式

1. **在 Ferry 内直接浏览导入**：打开 Ferry 管理界面「来源 → 浏览仓库」，勾选所需来源一键导入或更新。
2. **通过链接导入**：打开 Ferry 管理界面「来源 → 导入 → 在线链接」，粘贴上表中的 `raw.githubusercontent.com` 地址；或访问以下格式的路由直接打开导入预览：
   ```text
   http://<你的 Ferry 地址>/sources/import?url=https://raw.githubusercontent.com/lonelyman0108/ferry-hub/main/sources/ninebot/source.json
   ```

## 本地校验与生成索引

```bash
scripts/bootstrap.sh                          # 首次克隆后启用提交钩子并检查工具
ferry source check --hub sources/<key>        # 校验单个来源目录（定义、安全规则、README、cases.json 与图标文件）
ferry hub index .                             # 根据 sources/* 重新生成 index.json
scripts/check.sh                              # 完整门禁检查（与 CI 完全一致）
```

## 许可证

[Apache-2.0](LICENSE)，第三方声明见 [NOTICE](NOTICE)。

## 文档

- 贡献规范：[CONTRIBUTING.md](CONTRIBUTING.md)
- agent 工作约定：[AGENTS.md](AGENTS.md)
- 文档索引：[docs/README.md](docs/README.md)
- 更新日志：[CHANGELOG.md](CHANGELOG.md)
