#!/usr/bin/env bash
# 生成高保真原型项目骨架：Vite + Vue 3 + Element Plus + vue-router
# 用法: create-project.sh <项目目录名> [父目录]
set -euo pipefail

NAME="${1:?用法: create-project.sh <项目目录名> [父目录]}"
PARENT="${2:-.}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets/template" && pwd)"

cd "$PARENT"
if [ -d "$NAME" ]; then
  echo "错误: 目录 $NAME 已存在" >&2
  exit 1
fi

echo ">>> 创建 Vite + Vue3 项目: $NAME"
npm create vite@latest "$NAME" -- --template vue --no-interactive 2>/dev/null || \
  npm create vite@latest "$NAME" -- --template vue

cd "$NAME"

echo ">>> 安装依赖 (element-plus, vue-router, icons, 按需引入插件)"
npm install
npm install element-plus vue-router@4 @element-plus/icons-vue
npm install -D unplugin-vue-components

echo ">>> 写入原型模板文件"
mkdir -p src/views src/styles src/router
cp "$TEMPLATE_DIR/vite.config.js"        vite.config.js
cp "$TEMPLATE_DIR/src/main.js"          src/main.js
cp "$TEMPLATE_DIR/src/App.vue"           src/App.vue
cp "$TEMPLATE_DIR/src/router/index.js"   src/router/index.js
cp "$TEMPLATE_DIR/src/views/Home.vue"    src/views/Home.vue
cp "$TEMPLATE_DIR/src/styles/theme.css"  src/styles/theme.css

# 清掉 Vite 默认示例
rm -f src/components/HelloWorld.vue src/style.css
rmdir src/components 2>/dev/null || true
rm -rf src/assets

# 替换 index.html 标题占位
sed -i '' 's|<title>.*</title>|<title>原型系统</title>|' index.html 2>/dev/null || \
  sed -i 's|<title>.*</title>|<title>原型系统</title>|' index.html

echo ">>> 完成。下一步: cd $NAME && npm run dev"
