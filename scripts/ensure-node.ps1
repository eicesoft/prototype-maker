# 确保本机有可用的 Node.js (v22.23.x) 与 npm，可选启用 pnpm。Windows PowerShell 版。
#
# 设计（与 ensure-node.sh 对齐）：
# - 已存在且大版本为 22 的 Node 直接复用，不动用户环境。
# - 没有/版本不符时，通过 fnm (跨平台 Node 版本管理器) 装到用户目录，免管理员权限。
#   优先 winget 安装 fnm；winget 不可用时直接下载 fnm 二进制并加入用户 PATH。
# - 把 fnm 激活行写进 PowerShell profile（幂等），保证后续新开的 shell 也能找到 node/npm。
# - 本脚本既可被 create-project.ps1 dot-source 调用，也可直接运行自检；
#   加 --pnpm 会顺带启用 pnpm。
$ErrorActionPreference = 'Stop'

$NodeMajor = 22
$NodeVersion = '22.23'   # fnm install 22.23 会自动取 22.23.x 最新
$FnmDir = Join-Path $env:LOCALAPPDATA 'fnm'

function Test-Node { $null -ne (Get-Command node -ErrorAction SilentlyContinue) }
function Get-NodeMajor {
    try { (node -v) -replace '^v(\d+)\..*', '$1' } catch { '' }
}

# 把 fnm 目录加入用户 PATH（持久）和当前会话 PATH
function Add-FnmToPath {
    if (-not (Test-Path $FnmDir)) { return }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -and $userPath -notlike "*$FnmDir*") {
        [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $FnmDir), 'User')
    }
    if ($env:Path -notlike "*$FnmDir*") { $env:Path = $env:Path.TrimEnd(';') + ';' + $FnmDir }
}

# 激活 fnm 注入的 node 到当前会话
function Invoke-FnmEnv {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

if (Test-Node -and (Get-NodeMajor) -eq "$NodeMajor") {
    Write-Host ">>> 已检测到 Node $(node -v)，npm $(npm -v)，跳过安装"
} else {
    Write-Host ">>> 未检测到合适的 Node.js，准备安装 v$NodeVersion.x"

    # 1) 确保 fnm 可用
    if ($null -eq (Get-Command fnm -ErrorAction SilentlyContinue)) {
        Write-Host ">>> 安装 fnm (Node 版本管理器)"
        if ($null -ne (Get-Command winget -ErrorAction SilentlyContinue)) {
            winget install --id Schniz.fnm --accept-package-agreements --accept-source-agreements --silent
        } else {
            New-Item -ItemType Directory -Force -Path $FnmDir | Out-Null
            $zip = Join-Path $FnmDir 'fnm.zip'
            $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/Schniz/fnm/releases/latest' -Headers @{ 'User-Agent' = 'prototype-maker' }
            $asset = $rel.assets | Where-Object { $_.name -like 'fnm-windows.zip' } | Select-Object -First 1
            if ($null -eq $asset) { throw '未找到 fnm-windows.zip 发布资产' }
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
            Expand-Archive -Path $zip -DestinationPath $FnmDir -Force
            Remove-Item $zip -Force
        }
    }
    Add-FnmToPath

    # 2) 安装 Node 并激活到当前会话
    $env:FNM_DIR = $FnmDir
    Invoke-FnmEnv
    fnm install $NodeVersion
    fnm default $NodeVersion
    fnm use $NodeVersion
    Invoke-FnmEnv
    Write-Host ">>> Node 安装完成: $(node -v)，npm $(npm -v)"

    # 3) 把 fnm 激活行写进 PowerShell profile（幂等）
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
    $line = 'fnm env --use-on-cd | Out-String | Invoke-Expression'
    if ((Test-Path $profilePath) -and ((Get-Content $profilePath -Raw -ErrorAction SilentlyContinue) -like '*fnm env*')) {
        # 已存在，跳过
    } elseif (Test-Path $profilePath) {
        Add-Content -Path $profilePath -Value "`n# fnm`n$line"
    } else {
        Set-Content -Path $profilePath -Value "# fnm`n$line"
    }
}

# 可选：启用 pnpm（用 Node 自带的 corepack，无需管理员权限）
if ($args -contains '--pnpm') {
    if ($null -eq (Get-Command pnpm -ErrorAction SilentlyContinue)) {
        Write-Host '>>> 启用 pnpm (corepack)'
        try { corepack enable; corepack prepare pnpm@latest --activate } catch { npm install -g pnpm }
    }
    Write-Host ">>> pnpm: $(pnpm -v)"
}

# 自检：当前会话必须能跑 node/npm（create-project.ps1 会紧接着用）
if (-not (Test-Node)) { throw 'Node 仍不可用，请检查 fnm 安装是否成功' }
Write-Host ">>> 环境就绪: node $(node -v) / npm $(npm -v)"
