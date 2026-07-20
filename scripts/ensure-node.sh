#!/usr/bin/env bash
# 确保本机有可用的 Node.js (v22.23.x) 与 npm，可选启用 pnpm。
#
# 设计：
# - 已存在且大版本为 22 的 Node 直接复用，不动用户环境。
# - 没有/版本不符时，通过 nvm (Node Version Manager) 装到用户目录，免 sudo。
# - nvm 的 profile 写入由其官方安装脚本负责；这里额外做一次幂等兜底，
#   保证后续新开的 shell 也能找到 node/npm。
# - 本脚本既可被 create-project.sh source 调用（在脚手架前自检），
#   也可直接 `bash ensure-node.sh` 自检；加 `--pnpm` 会顺带启用 pnpm。
set -euo pipefail

NODE_MAJOR=22
NODE_VERSION="22.23"   # nvm install 22.23 会自动取 22.23.x 最新
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

have_node() { command -v node >/dev/null 2>&1; }
node_major_version() {
  node -v 2>/dev/null | sed -E 's/^v([0-9]+)\..*/\1/'
}

# 兜底：把 nvm 激活行写进 shell profile（幂等，已存在则跳过）
ensure_profile_nvm() {
  local line='export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
  local f
  for f in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -d "$(dirname "$f")" ] || continue
    touch "$f"
    if ! grep -q 'NVM_DIR' "$f" 2>/dev/null; then
      printf '\n# nvm\n%s\n' "$line" >> "$f"
    fi
  done
}

if have_node && [ "$(node_major_version)" = "$NODE_MAJOR" ]; then
  echo ">>> 已检测到 Node $(node -v)，npm $(npm -v)，跳过安装"
else
  echo ">>> 未检测到合适的 Node.js，准备安装 v${NODE_VERSION}.x"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo ">>> 安装 nvm (Node Version Manager)"
    if command -v curl >/dev/null 2>&1; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    elif command -v wget >/dev/null 2>&1; then
      wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    else
      echo "错误: 需要 curl 或 wget 来安装 nvm" >&2
      exit 1
    fi
  fi
  ensure_profile_nvm

  # 在当前进程激活 nvm，使随后即可使用 node/npm
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  echo ">>> Node 安装完成: $(node -v)，npm $(npm -v)"
fi

# 可选：启用 pnpm（用 Node 自带的 corepack，无需全局权限）
if [ "${1:-}" = "--pnpm" ]; then
  if ! command -v pnpm >/dev/null 2>&1; then
    echo ">>> 启用 pnpm (corepack)"
    corepack enable >/dev/null 2>&1 || true
    corepack prepare pnpm@latest --activate >/dev/null 2>&1 || npm install -g pnpm
  fi
  echo ">>> pnpm: $(pnpm -v)"
fi

# 自检：当前进程必须能跑 node/npm（create-project.sh 会紧接着用）
if ! have_node; then
  echo "错误: Node 仍不可用，请检查 nvm 安装是否成功" >&2
  exit 1
fi
echo ">>> 环境就绪: node $(node -v) / npm $(npm -v)"
