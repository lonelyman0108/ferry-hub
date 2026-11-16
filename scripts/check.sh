#!/usr/bin/env bash
# 仓库唯一门禁入口：本地、钩子、CI、发布脚本都调用它，各处行为一致。
# 用法：scripts/check.sh [--quick|--full]   --quick 只跑通用检查与 lint；默认 --full
# 每一段都是「step 名称」加命令，任何一步失败立即退出；CI 专有的差异只能是环境变量。
set -euo pipefail
cd "$(dirname "$0")/.."
mode=${1:---full}
case "$mode" in
  --quick|--full) ;;
  *) echo "用法：scripts/check.sh [--quick|--full]" >&2; exit 2 ;;
esac

step() { printf '\n==> %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "缺少 $1，安装：$2" >&2; exit 1; }; }
# 把 git 跟踪的、匹配给定 pathspec 的文件读进数组 files
tracked() {
  files=()
  while IFS= read -r -d '' f; do files+=("$f"); done < <(git ls-files -z -- "$@")
}

# ---- 通用检查（所有仓都跑） ----
step 注释中的流程编号
scripts/lint/comments.sh

step shellcheck
need shellcheck "brew install shellcheck / apt-get install shellcheck"
tracked '*.sh' '.githooks/*' ':!:*.conf'
[ "${#files[@]}" -eq 0 ] || shellcheck "${files[@]}"

# Gitea 仓的 workflow 在 .gitea/，GitHub 仓的在 .github/；actionlint 只自动发现后者，所以两边都显式传文件和配置
for dir in .gitea .github; do
  tracked "$dir/workflows/*.yml" "$dir/workflows/*.yaml"
  [ "${#files[@]}" -gt 0 ] || continue
  step "actionlint（${dir}）"
  need actionlint "brew install actionlint"
  actionlint -config-file "$dir/actionlint.yaml" "${files[@]}"
done

# >>> 按栈的快速检查：bootstrap --stack 在这里插入，也可以手写
# ---- generic ----
# <<< 按栈的快速检查

if [ "$mode" = --quick ]; then
  printf '\n快速检查通过\n'
  exit 0
fi

# >>> 按栈的完整检查：bootstrap --stack 在这里插入，也可以手写
need jq "brew install jq / apt-get install jq"

if [ -n "${BASE_SHA:-}" ] && git cat-file -e "$BASE_SHA^{commit}" 2>/dev/null; then
  step "PR 变更范围与版本号检查"
  changed_keys=()
  while IFS= read -r k; do
    [ -n "$k" ] && changed_keys+=("$k")
  done < <(git diff --name-only "$BASE_SHA...HEAD" -- 'sources/' | awk -F/ 'NF>=2 {print $2}' | sort -u)

  if [ "${#changed_keys[@]}" -gt 1 ]; then
    echo "一个 PR 仅允许新增或修改一个来源，本次涉及多个来源：${changed_keys[*]}" >&2
    exit 1
  fi

  if [ "${#changed_keys[@]}" -eq 1 ]; then
    k=${changed_keys[0]}
    if [ -f "sources/$k/source.json" ] && git cat-file -e "$BASE_SHA:sources/$k/source.json" 2>/dev/null; then
      if [ -n "$(git diff --name-only "$BASE_SHA...HEAD" -- "sources/$k/source.json")" ]; then
        old_ver=$(git show "$BASE_SHA:sources/$k/source.json" | jq -r '.meta.version // 0')
        new_ver=$(jq -r '.meta.version // 0' "sources/$k/source.json")
        if [ "$new_ver" -le "$old_ver" ]; then
          echo "sources/$k/source.json 已修改，meta.version（$new_ver）须大于原版本（$old_ver）" >&2
          exit 1
        fi
      fi
    fi
  fi
fi

ferry_commit=${FERRY_COMMIT:-ede2aba39a50b8dad77955d1ae9c852b36393484}
ferry_bin=${FERRY_BIN:-}
if [ -z "$ferry_bin" ]; then
  step "安装 ferry（${ferry_commit}）"
  need go "brew install go"
  tmp_bin=$(mktemp -d)
  trap 'rm -rf "$tmp_bin"' EXIT
  GOTOOLCHAIN=auto GOBIN="$tmp_bin" go install "github.com/lonelyman0108/ferry/cmd/ferry@${ferry_commit}"
  ferry_bin="$tmp_bin/ferry"
fi

step "检查来源定义与测试样例（ferry source check --hub）"
shopt -s nullglob
source_dirs=(sources/*/)
shopt -u nullglob
if [ "${#source_dirs[@]}" -eq 0 ]; then
  echo "sources/ 下没有任何来源目录" >&2
  exit 1
fi
"$ferry_bin" source check --hub "${source_dirs[@]}"

step "校验索引文件（ferry hub index --check）"
"$ferry_bin" hub index --check .
# <<< 按栈的完整检查

printf '\n完整检查通过\n'
