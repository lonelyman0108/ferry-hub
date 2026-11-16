# ferry-hub

Ferry 官方来源规则仓库：存放 `sources/<key>/{source.json, icon.*, README.md, cases.json}` 与根目录索引 `index.json`。

提交、PR、来源校验的完整规范见 [CONTRIBUTING.md](CONTRIBUTING.md)；本文件只写 agent 需要、又无法从代码推出来的内容，每条约定都附原因。

## 工作方式

- 只在分支或 worktree 上工作，分支名 `<type>/<slug>`；用 `scripts/pr.sh` 开 PR，**不直接提交或推送 main**。原因：main 受保护，PR 是唯一经过门禁的入口。
- 一个 PR 只新增或修改一个 `sources/<key>/` 目录；修改已有 `source.json` 时必须递增 `meta.version`，并运行 `ferry hub index .` 更新 `index.json`。原因：CI 门禁强制校验单来源变更、版本号递增与索引一致性。
- 图标直接存文件本身（如 `sources/<key>/icon.svg`、`icon.png`），不在 `source.json` 或 `index.json` 中存 base64。
- 提交与 PR 标题：`<emoji> <type>(<scope>): <中文主题>`，首行 ≤ 72 字符；**不加任何署名 trailer**（Co-authored-by 等）。
- 提交前跑 `scripts/check.sh`（本地已有编译好的 `ferry` 时可传 `FERRY_BIN=/path/to/ferry scripts/check.sh`），结果写进 PR 的「验证」节。

## 禁区

- 不上传任何真实账号的 Token、Cookie 或隐私数据；`cases.json` 必须使用脱敏虚构值。
- 不改 GitHub 平台设置（secrets、分支保护、Actions 权限），不读取或打印密钥文件。
- 不用 `--no-verify`、`push --force`。
- 改 `.githooks/`、`.github/workflows/`、`scripts/check.sh`、`scripts/ci/` 时，只开 PR（`scripts/pr.sh --no-merge`），由维护者审阅后合并。
- 第二行写着「受管文件」的文件不在本仓直接改。

## 命令

- 门禁：`scripts/check.sh`（`--quick` 只跑通用检查）
- 校验单个来源：`ferry source check --hub sources/<key>`
- 生成索引：`ferry hub index .`
- 校验索引：`ferry hub index --check .`
- 开 PR：`scripts/pr.sh`（`--no-merge` 只开不合并）

## 目录与约定

| 路径 | 内容 |
|---|---|
| `index.json` | 仓库索引文件，由 `ferry hub index .` 生成，切勿手改 |
| `sources/<key>/source.json` | 来源 JSON 外壳定义 |
| `sources/<key>/icon.*` | 来源图标文件（`.svg` / `.png` / `.webp` / `.jpg`） |
| `sources/<key>/README.md` | 来源触发说明、提取字段与输出变量表 |
| `sources/<key>/cases.json` | 脱敏请求样例与期望提取值 |
| `scripts/check.sh` | 唯一门禁入口，本地与 CI 行为一致 |
