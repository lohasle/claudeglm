#!/usr/bin/env bash
# 一键安装「完全独立的「智谱 GLM 专用」Claude Code
# 专为国内用户优化，使用 open.bigmodel.cn 端点
# MacBook M1/M2/M3/M4 实测一次成功

set -e

echo "开始安装独立智谱 GLM 版 Claude Code（命令名：claudeglm）"

GLM_CONFIG_DIR="$HOME/.claude-glm"
GLM_BIN_DIR="$HOME/.local/bin"
GLM_BINARY="$GLM_BIN_DIR/claudeglm"

mkdir -p "$GLM_CONFIG_DIR" "$GLM_BIN_DIR"

# 1. 确保 claude 已全局安装
if ! command -v claude &> /dev/null; then
    echo "正在全局安装 Claude Code（只需要一次）..."
    npm install -g @anthropic-ai/claude-code
else
    echo "claude 已存在，跳过安装"
fi

# 2. 创建独立启动器
cat > "$GLM_BINARY" <<'EOF'
#!/usr/bin/env bash
export CLAUDE_CONFIG_DIR="$HOME/.claude-glm"
exec claude "$@"
EOF
chmod +x "$GLM_BINARY"

# 3. 确保 PATH 通畅
if ! echo "$PATH" | grep -q "$GLM_BIN_DIR"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" 2>/dev/null || true
    export PATH="$GLM_BIN_DIR:$PATH"
    echo "已将 $GLM_BIN_DIR 加入 PATH"
fi

# 4. 初始化配置目录
CLAUDE_CONFIG_DIR="$GLM_CONFIG_DIR" claude doctor >/dev/null 2>&1 || true

# 5. 读取智谱专用配置（严格按你要求）
echo ""
echo "请粘贴你的【智谱 AI API Key】（从 https://bigmodel.cn/console/apikey 获取）"
echo "输入后直接回车（屏幕不显示字符，安全）"
read -s ZAI_KEY
echo ""

cat > "$GLM_CONFIG_DIR/settings.json" <<EOF
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_KEY",
    "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "GLM-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "GLM-4.7",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "GLM-4.6",
    "API_TIMEOUT_MS": "300000"
  }
}
EOF

chmod 600 "$GLM_CONFIG_DIR/settings.json"
rm -rf "$GLM_CONFIG_DIR/cache" 2>/dev/null || true

echo ""
echo "===================================================================="
echo "安装成功！现在你拥有两个完全独立的命令："
echo ""
echo "   claude       → 原来走 Anthropic（完全不动）"
echo "   claudeglm    → 专走智谱 GLM-4.7（国内最快最便宜）"
echo ""
echo "请新开一个终端（或 source ~/.zshrc），然后直接运行："
echo ""
echo "   claudeglm"
echo ""
echo "第一次运行会让你确认 API Key，选 Yes 就行，随后就是纯正 GLM-4.7 了！"
echo "===================================================================="
