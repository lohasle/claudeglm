#Requires -Version 7
# 一键安装「完全独立的「智谱 GLM 专用」Claude Code」 - Windows 版
# 命令名为：claudeglm
# 专为国内用户优化，使用 open.bigmodel.cn 端点

Write-Host "开始安装独立智谱 GLM 版 Claude Code（命令名：claudeglm）" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# ======================== 路径定义 ========================
$GLM_CONFIG_DIR = "$HOME\.claude-glm"
$GLM_BIN_DIR    = "$HOME\.local\bin"
$GLM_BINARY     = "$GLM_BIN_DIR\claudeglm.ps1"

# 创建目录
New-Item -ItemType Directory -Path $GLM_CONFIG_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $GLM_BIN_DIR    -Force | Out-Null

# ======================== 1. 安装/检查 claude 全局包 ========================
Write-Host "检查是否已安装 claude..." -NoNewline

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host " 已存在，跳过安装" -ForegroundColor Green
} else {
    Write-Host " 未找到，正在全局安装 @anthropic-ai/claude-code ..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
    Write-Host "全局 claude 安装完成" -ForegroundColor Green
}

# ======================== 2. 创建独立的 claudeglm 启动脚本 ========================
$launcherContent = @'
#requires -Version 7
$ErrorActionPreference = "Stop"

$env:CLAUDE_CONFIG_DIR = "$env:USERPROFILE\.claude-glm"

# 优先使用本地 npx，如果找不到再 fallback 到全局 claude
if (Test-Path ".\node_modules\.bin\claude.cmd") {
    & ".\node_modules\.bin\claude.cmd" @args
} else {
    & claude @args
}
'@

# 写入启动脚本
Set-Content -Path $GLM_BINARY -Value $launcherContent -Encoding UTF8 -NoNewline
Write-Host "已创建独立启动脚本：$GLM_BINARY" -ForegroundColor Green

# ======================== 3. 把 ~/.local/bin 加到 PATH （如果还没有） ========================
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$GLM_BIN_DIR*") {
    Write-Host "正在将 $GLM_BIN_DIR 添加到用户 PATH..." -ForegroundColor Yellow
    
    $newPath = "$currentPath;$GLM_BIN_DIR"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    # 当前会话也立即生效
    $env:Path = "$env:Path;$GLM_BIN_DIR"
    
    Write-Host "已添加进 PATH（当前会话已生效，新终端会自动生效）" -ForegroundColor Green
} else {
    Write-Host "PATH 已包含 $GLM_BIN_DIR，跳过" -ForegroundColor Green
}

# ======================== 4. 初始化配置目录 ========================
$env:CLAUDE_CONFIG_DIR = $GLM_CONFIG_DIR
try {
    & claude doctor | Out-Null
} catch {
    # 第一次运行可能会报错，没关系
}

# ======================== 5. 读取智谱 API Key 并写入配置 ========================
Write-Host ""
Write-Host "请粘贴你的【智谱 AI API Key】" -ForegroundColor Cyan
Write-Host "(从 https://bigmodel.cn/console/apikey 获取)" -ForegroundColor DarkCyan
Write-Host "输入后直接按回车（输入时不会显示字符）：" -ForegroundColor Cyan -NoNewline

$ZAI_KEY = Read-Host -AsSecureString
$ZAI_KEY_Plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ZAI_KEY)
)

Write-Host ""

$settingsJson = @"
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_KEY_Plain",
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "GLM-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "GLM-4.7",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "GLM-4.6",
    "API_TIMEOUT_MS": "300000"
  }
}
"@

# 写入配置文件
Set-Content -Path "$GLM_CONFIG_DIR\settings.json" -Value $settingsJson -Encoding UTF8

# 尽量把文件权限设紧一点（Windows 比较难精确控制）
icacls "$GLM_CONFIG_DIR\settings.json" /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null

# 清缓存（如果存在）
Remove-Item -Path "$GLM_CONFIG_DIR\cache" -Recurse -Force -ErrorAction SilentlyContinue

# ======================== 完成提示 ========================
Write-Host ""
Write-Host ("=" * 70) -ForegroundColor Magenta
Write-Host "          安装完成！现在你拥有两个完全独立的命令：" -ForegroundColor Cyan
Write-Host ""
Write-Host "   claude       → 原来走的 Anthropic（完全不动）" -ForegroundColor Green
Write-Host "   claudeglm    → 专走智谱 GLM-4.7（国内最快最便宜）" -ForegroundColor Green
Write-Host ""
Write-Host "请**新开一个 PowerShell 窗口**，然后直接运行：" -ForegroundColor Yellow
Write-Host ""
Write-Host "   claudeglm" -ForegroundColor White
Write-Host ""
Write-Host "第一次运行可能会让你确认 API Key，选 Yes 即可" -ForegroundColor DarkCyan
Write-Host ("=" * 70) -ForegroundColor Magenta
