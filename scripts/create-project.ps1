# 生成高保真原型项目骨架：Vite + Vue 3 + Element Plus + vue-router（Windows PowerShell 版）
# 用法: create-project.ps1 <项目目录名> [父目录]
param(
    [Parameter(Mandatory = $true, Position = 0)][string]$Name,
    [Parameter(Position = 1)][string]$Parent = '.'
)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = (Join-Path (Join-Path (Join-Path $ScriptDir '..') 'assets') 'template' | Resolve-Path).Path

# 脚手架前先确保 Node (v22.23.x) / npm 可用；缺失则自动经 fnm 安装。
# dot-source 进当前会话，故装好的 node 立刻可用于下面的 npm create / npm install。
. (Join-Path $ScriptDir 'ensure-node.ps1')

if ($Parent -ne '.') { Set-Location $Parent }
if (Test-Path $Name) { throw "错误: 目录 $Name 已存在" }

Write-Host ">>> 创建 Vite + Vue3 项目: $Name"
npm create vite@latest $Name -- --template vue

Set-Location $Name

Write-Host '>>> 安装依赖 (element-plus, vue-router, icons)'
npm install
npm install element-plus vue-router@4 @element-plus/icons-vue

Write-Host '>>> 写入原型模板文件'
New-Item -ItemType Directory -Force -Path 'src/views', 'src/styles', 'src/router' | Out-Null
Copy-Item (Join-Path $TemplateDir 'src/main.js')          'src/main.js'          -Force
Copy-Item (Join-Path $TemplateDir 'src/App.vue')          'src/App.vue'          -Force
Copy-Item (Join-Path $TemplateDir 'src/router/index.js')  'src/router/index.js'  -Force
Copy-Item (Join-Path $TemplateDir 'src/views/Home.vue')   'src/views/Home.vue'   -Force
Copy-Item (Join-Path $TemplateDir 'src/styles/theme.css') 'src/styles/theme.css' -Force

# 清掉 Vite 默认示例
Remove-Item -Path 'src/components/HelloWorld.vue' -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'src/components' -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'src/style.css' -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'src/assets' -Force -Recurse -ErrorAction SilentlyContinue

# 替换 index.html 标题占位
$idx = Join-Path (Get-Location) 'index.html'
if (Test-Path $idx) {
    (Get-Content $idx -Raw) -replace '<title>.*</title>', '<title>原型系统</title>' |
        Set-Content $idx -NoNewline
}

Write-Host ">>> 完成。下一步: cd $Name && npm run dev"
