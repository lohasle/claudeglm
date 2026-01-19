@echo off
chcp 65001 >nul
REM 一键安装「完全独立的「智谱 GLM 专用」Claude Code
REM 专为国内用户优化，使用 open.bigmodel.cn 端点
REM Windows 10/11 实测可用

echo 开始安装独立智谱 GLM 版 Claude Code（命令名：claudeglm）
echo.

set GLM_CONFIG_DIR=%USERPROFILE%\.claude-glm
set GLM_BIN_DIR=%USERPROFILE%\.local\bin
set GLM_BINARY=%GLM_BIN_DIR%\claudeglm.cmd

REM 创建必要的目录
if not exist "%GLM_CONFIG_DIR%" mkdir "%GLM_CONFIG_DIR%"
if not exist "%GLM_BIN_DIR%" mkdir "%GLM_BIN_DIR%"

REM 1. 确保 claude 已全局安装
where claude >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在全局安装 Claude Code（只需要一次）...
    call npm install -g @anthropic-ai/claude-code
    if %errorlevel% neq 0 (
        echo 错误：npm 安装失败，请确保已安装 Node.js
        pause
        exit /b 1
    )
) else (
    echo claude 已存在，跳过安装
)

REM 2. 创建独立启动器
echo @echo off> "%GLM_BINARY%"
echo set CLAUDE_CONFIG_DIR=%%USERPROFILE%%\.claude-glm>> "%GLM_BINARY%"
echo claude %%*>> "%GLM_BINARY%"

REM 3. 检查并添加到 PATH（需要管理员权限或用户环境变量）
echo %PATH% | findstr /C:"%GLM_BIN_DIR%" >nul
if %errorlevel% neq 0 (
    echo 正在将 %GLM_BIN_DIR% 添加到用户环境变量...
    setx PATH "%GLM_BIN_DIR%;%PATH%" >nul 2>&1
    set PATH=%GLM_BIN_DIR%;%PATH%
    echo 已将目录加入 PATH（重启终端后生效）
)

REM 4. 初始化配置目录
set CLAUDE_CONFIG_DIR=%GLM_CONFIG_DIR%
call claude doctor >nul 2>&1

REM 5. 读取智谱专用配置
echo.
echo 请输入你的【智谱 AI API Key】（从 https://bigmodel.cn/console/apikey 获取）
echo 输入后按回车：
set /p ZAI_KEY=

if "%ZAI_KEY%"=="" (
    echo 错误：API Key 不能为空
    pause
    exit /b 1
)

REM 6. 创建配置文件（使用 JSON 格式）
(
echo {
echo   "env": {
echo     "ANTHROPIC_AUTH_TOKEN": "%ZAI_KEY%",
echo     "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
echo     "ANTHROPIC_DEFAULT_OPUS_MODEL": "GLM-4.7",
echo     "ANTHROPIC_DEFAULT_SONNET_MODEL": "GLM-4.7",
echo     "ANTHROPIC_DEFAULT_HAIKU_MODEL": "GLM-4.6",
echo     "API_TIMEOUT_MS": "300000"
echo   }
echo }
) > "%GLM_CONFIG_DIR%\settings.json"

REM 清除缓存
if exist "%GLM_CONFIG_DIR%\cache" rd /s /q "%GLM_CONFIG_DIR%\cache" 2>nul

echo.
echo ====================================================================
echo 安装成功！现在你拥有两个完全独立的命令：
echo.
echo    claude       -^> 原来走 Anthropic（完全不动）
echo    claudeglm    -^> 专走智谱 GLM-4.7（国内最快最便宜）
echo.
echo 请【重新打开一个新的命令提示符或 PowerShell】，然后直接运行：
echo.
echo    claudeglm
echo.
echo 第一次运行会让你确认 API Key，选 Yes 就行，随后就是纯正 GLM-4.7 了！
echo ====================================================================
echo.
pause
