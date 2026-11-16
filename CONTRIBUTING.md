# 贡献规范

欢迎向 `ferry-hub` 贡献新的来源规则或更新已有来源。动手之前，请先阅读 [README 收录原则](README.md#边界与收录原则)：只收录**本人账号、本人设备、每次回传可见**场景下的来源规则。

本仓的提交、分支、PR 与来源校验规则都写在这里；钩子 `.githooks/commit-msg` 与 CI 按同一份规则校验。

## 初始化

克隆后执行一次 `scripts/bootstrap.sh`，它会启用 `.githooks`（`git config core.hooksPath` 应输出 `.githooks`）并检查工具。

## 来源提交规则

1. **一个 PR 只改一个来源**：每次 PR 仅允许新增或修改 `sources/<key>/` 下的一个来源目录，便于审阅与回滚。
2. **目录名与 `key` 一致**：来源目录路径必须为 `sources/<key>/`，且与 `source.json` 中的 `source.key` 完全一致。
3. **必备文件齐全**：每个 `sources/<key>/` 目录必须包含：
   - `source.json`：符合 Ferry `schema/source.v1.json` 的 JSON 外壳（`format: 1`），`source.icon` 留空（不内嵌 base64）。
   - `README.md`：说明 App 触发步骤、提取字段、输出变量与有效性探测方式。
   - `cases.json`：至少 1 条脱敏后的请求样例与期望提取值，覆盖 `source.json` 中声明的全部字段。
   - `icon.svg`（或 `icon.png` / `icon.webp` / `icon.jpg`，可选但推荐）：直接存放图标文件本身（≤ 64 KB），不存 base64。
4. **修改已有来源时递增版本号**：若 PR 修改了已存在的 `sources/<key>/source.json`，必须将 `meta.version` 递增（大于 `main` 分支上的当前版本号）。
5. **同步更新 `index.json`**：在仓库根目录运行 `ferry hub index .` 生成最新的 `index.json` 并随 PR 一起提交；CI 会运行 `ferry hub index --check .` 校验索引与源文件完全一致。
6. **严禁真实凭证**：`cases.json` 中的 Token、Cookie、设备号等必须替换为带 `sample` / `redacted` / `dummy` 等标记的虚构值。

## 本地验证流程

```bash
ferry source check --hub sources/<key>
ferry hub index .
scripts/check.sh
```

## 分支与 PR

- `main` 受保护，所有改动走 PR，只允许 squash 合并，合并后删除分支。
- 分支名 `<type>/<slug>`，例如 `feat/source-ninebot`；slug 只用小写字母、数字、连字符。
- 用 `scripts/pr.sh` 开 PR；门禁相关改动用 `scripts/pr.sh --no-merge`。
- PR 标题就是 main 上的提交标题；描述分三节：变更 / 验证 / 未覆盖。

## 提交规范

格式：`<emoji> <type>(<scope>): <中文主题>`

- 首行 ≤ 72 个字符（中文算 1 个），主题动词开头、末尾不加句号。
- scope 可省，推荐填来源的 `key`（如 `feat(ninebot): 新增九号出行签到来源`）。
- **禁止任何署名或评审 trailer**（`Co-authored-by`、`Signed-off-by`、`Reviewed-on`、`Reviewed-by` 等）。
- 首行不写需求号、阶段号这类流程编号。

| emoji | type | 用途 |
|---|---|---|
| ✨ | feat | 新增或增强来源规则 |
| 🐛 | fix | 修复来源匹配、提取或探测规则 |
| ♻️ | refactor | 重构，行为不变 |
| ✅ | test | 补充或调整测试样例 |
| 📝 | docs | 文档、注释 |
| 👷 | ci | workflow、CI 脚本、钩子 |
| 🔧 | chore | 工程配置、杂项 |
| ⏪️ | revert | 回滚 |

常用 scope：各来源的 `key`（如 `ninebot`）、`index`、`ci`

## 受管文件

第二行写着「受管文件，来自 ci-workflows@…」的文件（提交钩子、`scripts/ci/` 下的脚本、`scripts/pr.sh` 等）由维护者从共享的规范仓同步过来，各项目保持一致。不要在本仓直接改。

## 门禁

`scripts/check.sh`（纯文档改动可用 `--quick`）：注释流程编号、shellcheck、actionlint、单 PR 单来源与 `meta.version` 递增检查、`ferry source check --hub`、`ferry hub index --check`。
