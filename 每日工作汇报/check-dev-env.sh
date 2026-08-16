#!/usr/bin/env bash
# macOS Web 开发环境只读检测脚本：不会安装软件或修改系统配置。

set -u

ok_count=0
missing_count=0
warning_count=0
suggestions=()

ok() {
  printf '✓ %s\n' "$1"
  ok_count=$((ok_count + 1))
}

missing() {
  printf '✗ %s\n' "$1"
  missing_count=$((missing_count + 1))
}

warning() {
  printf '⚠ %s\n' "$1"
  warning_count=$((warning_count + 1))
}

add_suggestion() {
  local item
  for item in "${suggestions[@]:-}"; do
    [[ "$item" == "$1" ]] && return
  done
  suggestions+=("$1")
}

# Compare x.y.z versions. Returns success when $1 >= $2.
version_at_least() {
  local installed="$1" required="$2"
  awk -v installed="$installed" -v required="$required" '
    BEGIN {
      split(installed, current, ".")
      split(required, minimum, ".")
      for (i = 1; i <= 3; i++) {
        current_part = current[i] + 0
        minimum_part = minimum[i] + 0
        if (current_part > minimum_part) exit 0
        if (current_part < minimum_part) exit 1
      }
      exit 0
    }
  '
}

command_version() {
  "$@" 2>/dev/null | head -n 1
}

printf '================================\n'
printf 'Mac Web 开发环境检测报告\n'
printf '================================\n\n'

printf '系统：\n'
if [[ "$(uname -s)" != "Darwin" ]]; then
  warning "当前系统不是 macOS；部分检测结果可能不准确"
else
  macos_version="$(sw_vers -productVersion 2>/dev/null || echo '未知')"
  ok "macOS ${macos_version}"
fi

case "$(uname -m)" in
  arm64) ok 'Apple Silicon (arm64)' ;;
  x86_64) ok 'Intel (x86_64)' ;;
  *) warning "未知 CPU 架构：$(uname -m)" ;;
esac

free_disk_kb="$(df -Pk / 2>/dev/null | awk 'NR == 2 {print $4}')"
if [[ "$free_disk_kb" =~ ^[0-9]+$ ]]; then
  free_disk_gb=$((free_disk_kb / 1024 / 1024))
  if (( free_disk_gb < 20 )); then
    warning "可用磁盘空间 ${free_disk_gb} GB（建议至少保留 20 GB）"
    add_suggestion '清理磁盘空间，建议至少保留 20 GB 供依赖、镜像和构建缓存使用'
  else
    ok "可用磁盘空间 ${free_disk_gb} GB"
  fi
else
  warning '无法读取可用磁盘空间'
fi

memory_bytes="$(sysctl -n hw.memsize 2>/dev/null || true)"
if [[ "$memory_bytes" =~ ^[0-9]+$ ]]; then
  memory_gb=$((memory_bytes / 1024 / 1024 / 1024))
else
  # 某些受限终端不允许读取 hw.memsize，使用 macOS 的硬件报告作后备。
  memory_gb="$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Memory:/ {print $2; exit}')"
fi
if [[ "$memory_gb" =~ ^[0-9]+$ ]]; then
  if (( memory_gb < 8 )); then
    warning "内存 ${memory_gb} GB（建议至少 8 GB）"
    add_suggestion '8 GB 内存可用于轻量开发；运行 Docker 和本地数据库时建议 16 GB 或以上'
  else
    ok "内存 ${memory_gb} GB"
  fi
else
  warning '无法读取内存容量'
fi

printf '\n开发工具：\n'
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode Command Line Tools ($(xcode-select -p))"
else
  missing 'Xcode Command Line Tools 未安装'
  add_suggestion '安装 Xcode Command Line Tools：xcode-select --install'
fi

if command -v brew >/dev/null 2>&1; then
  ok "Homebrew ($(brew --version 2>/dev/null | head -n 1))"
else
  missing 'Homebrew 未安装'
  add_suggestion '安装 Homebrew（用于管理 Node.js、pnpm 等开发工具）'
fi

printf '\n编程环境：\n'
if command -v node >/dev/null 2>&1; then
  node_version="$(node --version | sed 's/^v//')"
  if version_at_least "$node_version" '20.0.0'; then
    ok "Node.js v${node_version}"
  else
    warning "Node.js v${node_version}（建议 20 或更高版本）"
    add_suggestion '升级 Node.js 至当前 LTS 版本（建议 20+）'
  fi
else
  missing 'Node.js 未安装'
  add_suggestion '安装 Node.js 当前 LTS 版本（建议 20+）'
fi

if command -v npm >/dev/null 2>&1; then
  npm_version="$(npm --version 2>/dev/null || true)"
  if [[ -n "$npm_version" ]]; then
    ok "npm v${npm_version}"
  else
    warning 'npm 已找到，但无法读取版本'
  fi
else
  missing 'npm 未安装'
fi

if command -v pnpm >/dev/null 2>&1; then
  ok "pnpm v$(pnpm --version 2>/dev/null)"
else
  missing 'pnpm 未安装'
  add_suggestion '安装 pnpm：corepack enable && corepack prepare pnpm@latest --activate'
fi

if command -v python3 >/dev/null 2>&1; then
  python_version="$(python3 --version 2>&1 | awk '{print $2}')"
  if version_at_least "$python_version" '3.9.0'; then
    ok "Python3 v${python_version}"
  else
    warning "Python3 v${python_version}（建议 3.9 或更高版本）"
    add_suggestion '升级 Python3 至 3.9 或更高版本'
  fi
else
  missing 'Python3 未安装'
  add_suggestion '安装 Python3（部分前端原生依赖构建时需要）'
fi

if command -v git >/dev/null 2>&1; then
  git_version="$(git --version | awk '{print $3}')"
  if version_at_least "$git_version" '2.30.0'; then
    ok "Git v${git_version}"
  else
    warning "Git v${git_version}（建议 2.30 或更高版本）"
    add_suggestion '升级 Git 至 2.30 或更高版本'
  fi
else
  missing 'Git 未安装'
  add_suggestion '安装 Git'
fi

printf '\n编辑器：\n'
if command -v code >/dev/null 2>&1; then
  ok 'VS Code（命令行 code 可用）'
elif [[ -d '/Applications/Visual Studio Code.app' || -d "$HOME/Applications/Visual Studio Code.app" ]]; then
  ok 'VS Code 已安装（可在 VS Code 中启用 code 命令）'
else
  missing 'VS Code 未安装'
  add_suggestion '安装 Visual Studio Code，并推荐安装 ESLint、Prettier、Tailwind CSS IntelliSense 扩展'
fi

printf '\n容器环境：\n'
if command -v docker >/dev/null 2>&1; then
  ok "Docker CLI ($(docker --version 2>/dev/null | sed 's/Docker version //'))"
  if docker info >/dev/null 2>&1; then
    ok 'Docker 正在运行'
  else
    warning 'Docker 已安装但未运行（请启动 Docker Desktop）'
    add_suggestion '启动 Docker Desktop，以运行数据库和容器化部署环境'
  fi
else
  missing 'Docker 未安装'
  add_suggestion '安装 Docker Desktop（本地数据库和 Docker 部署需要）'
fi

printf '\n网络：\n'
if command -v curl >/dev/null 2>&1 && curl --silent --fail --connect-timeout 5 --max-time 10 https://github.com >/dev/null 2>&1; then
  ok 'GitHub 可访问'
else
  warning 'GitHub 不可访问或连接超时'
  add_suggestion '检查网络、代理或公司防火墙，确保可以访问 github.com'
fi

if command -v curl >/dev/null 2>&1 && curl --silent --fail --connect-timeout 5 --max-time 10 https://registry.npmjs.org/-/ping >/dev/null 2>&1; then
  ok 'npm registry 可访问'
else
  warning 'npm registry 不可访问或连接超时'
  add_suggestion '检查网络或 npm registry 配置（npm config get registry）'
fi

printf '\n建议：\n'
if (( ${#suggestions[@]} == 0 )); then
  printf '✓ 当前环境满足 React、Next.js、TypeScript、Tailwind CSS、数据库和 Docker 开发的基础要求。\n'
else
  i=1
  for suggestion in "${suggestions[@]}"; do
    printf '%d. %s\n' "$i" "$suggestion"
    i=$((i + 1))
  done
fi

printf '\n检测汇总：%d 项正常，%d 项缺失，%d 项需要关注\n' "$ok_count" "$missing_count" "$warning_count"
printf '================================\n'
